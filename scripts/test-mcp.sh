#!/bin/bash
# test-mcp.sh — E2E test harness for any DataXLR8 Rust MCP
#
# Usage:
#   ./scripts/test-mcp.sh <binary-path> [database-url]
#
# Example:
#   ./scripts/test-mcp.sh ~/Projects/dataxlr8-features-mcp/target/release/dataxlr8-features-mcp
#   ./scripts/test-mcp.sh ./target/release/dataxlr8-contacts-mcp postgres://user@localhost/dataxlr8

set -uo pipefail

BINARY="${1:?Usage: test-mcp.sh <binary-path> [database-url]}"
export DATABASE_URL="${2:-postgres://$(whoami)@localhost/dataxlr8}"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

if [ ! -f "$BINARY" ]; then
    echo "ERROR: Binary not found: $BINARY"
    exit 1
fi

echo "=== DataXLR8 MCP Test Harness ==="
echo "Binary: $BINARY"
echo "DB:     $DATABASE_URL"
echo ""

# Check binary size
SIZE=$(stat -f%z "$BINARY" 2>/dev/null || stat --printf="%s" "$BINARY" 2>/dev/null)
SIZE_MB=$(echo "scale=1; $SIZE / 1048576" | bc)
if (( $(echo "$SIZE_MB > 10" | bc -l) )); then
    echo "FAIL: Binary size ${SIZE_MB}MB exceeds 10MB limit"
else
    echo "PASS: Binary size ${SIZE_MB}MB"
fi

# Check PostgreSQL
if ! pg_isready -q 2>/dev/null; then
    echo "FAIL: PostgreSQL not running"
    exit 1
fi
echo "PASS: PostgreSQL running"

# Create FIFO
PIPE="/tmp/mcp-test-pipe-$$"
OUT="/tmp/mcp-test-out-$$.jsonl"
mkfifo "$PIPE"
trap "rm -f $PIPE $OUT" EXIT

# Start server
"$BINARY" < "$PIPE" > "$OUT" 2>/dev/null &
SERVER_PID=$!
exec 3>"$PIPE"

send() {
    echo "$1" >&3
    sleep 0.5
}

echo ""
echo "--- Protocol Tests ---"

# Initialize
send '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test-harness","version":"1.0"}}}'
send '{"jsonrpc":"2.0","method":"notifications/initialized"}'

# List tools
send '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'

# Unknown tool
send '{"jsonrpc":"2.0","id":99,"method":"tools/call","params":{"name":"nonexistent_tool","arguments":{}}}'

# Wait for responses
sleep 1

# Close pipe
exec 3>&-
sleep 1
kill $SERVER_PID 2>/dev/null
wait $SERVER_PID 2>/dev/null

echo ""
echo "--- Results ---"

# Parse results
python3 -c "
import sys, json

results = []
with open('$OUT') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            data = json.loads(line)
            results.append(data)
        except:
            continue

passed = 0
failed = 0
tools = []

for data in results:
    rid = data.get('id', '?')

    if rid == 1:
        # Initialize
        if 'result' in data and 'protocolVersion' in data['result']:
            print(f'  [{rid}] PASS: initialize (protocol {data[\"result\"][\"protocolVersion\"]})')
            passed += 1
        else:
            print(f'  [{rid}] FAIL: initialize')
            failed += 1

    elif rid == 2:
        # Tools list
        if 'result' in data and 'tools' in data['result']:
            tools = [t['name'] for t in data['result']['tools']]
            has_schema = all('inputSchema' in t for t in data['result']['tools'])
            print(f'  [{rid}] PASS: tools/list ({len(tools)} tools)')
            for t in tools:
                schema_ok = any(
                    tool['name'] == t and tool.get('inputSchema', {}).get('type') == 'object'
                    for tool in data['result']['tools']
                )
                print(f'       - {t} (schema: {\"ok\" if schema_ok else \"MISSING\"})')
            passed += 1
        else:
            print(f'  [{rid}] FAIL: tools/list')
            failed += 1

    elif rid == 99:
        # Unknown tool
        if 'result' in data:
            r = data['result']
            is_err = r.get('isError', False)
            if is_err:
                print(f'  [{rid}] PASS: unknown tool returns error')
                passed += 1
            else:
                print(f'  [{rid}] WARN: unknown tool did not return error')
                passed += 1
        elif 'error' in data:
            print(f'  [{rid}] PASS: unknown tool returns JSON-RPC error')
            passed += 1
        else:
            print(f'  [{rid}] FAIL: unknown tool handling')
            failed += 1

    else:
        if 'result' in data:
            r = data['result']
            if isinstance(r, dict) and 'content' in r:
                is_err = r.get('isError', False)
                status = 'FAIL' if is_err else 'PASS'
                text = r['content'][0]['text'][:100] if r['content'] else ''
                print(f'  [{rid}] {status}: {text}')
                if is_err:
                    failed += 1
                else:
                    passed += 1
            else:
                print(f'  [{rid}] OK')
                passed += 1
        elif 'error' in data:
            print(f'  [{rid}] FAIL: {data[\"error\"].get(\"message\", \"unknown error\")}')
            failed += 1

print()
print(f'=== Summary: {passed} passed, {failed} failed, {len(tools)} tools ===')

if failed > 0:
    sys.exit(1)
"
