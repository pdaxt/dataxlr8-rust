#!/bin/bash
# ============================================================================
# DataXLR8 Rust MCP Platform — Manual Test Guide
# ============================================================================
#
# HOW TO TEST MANUALLY:
#
# 1. AUTOMATED (recommended):
#    python3 ~/Projects/dataxlr8-rust/e2e_test.py
#
# 2. INTERACTIVE (test individual MCPs):
#    Each MCP is a binary that speaks JSON-RPC over stdin/stdout.
#    Use the helper function below to talk to any MCP interactively.
#
# 3. DATABASE INSPECTION:
#    /opt/homebrew/opt/postgresql@17/bin/psql -U dataxlr8 -d dataxlr8
#
# ============================================================================

export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export DATABASE_URL="postgres://dataxlr8:dataxlr8@localhost:5432/dataxlr8"
export RUST_LOG=info

echo "============================================"
echo "DataXLR8 Rust MCP Platform — Manual Testing"
echo "============================================"
echo ""
echo "Prerequisites:"
echo "  PostgreSQL: $(pg_isready 2>&1)"
echo ""
echo "Binaries:"
for mcp in features contacts commissions email; do
    bin=~/Projects/dataxlr8-${mcp}-mcp/target/release/dataxlr8-${mcp}-mcp
    if [ -f "$bin" ]; then
        size=$(ls -lh "$bin" | awk '{print $5}')
        echo "  ✓ ${mcp}-mcp ($size)"
    else
        echo "  ✗ ${mcp}-mcp (NOT FOUND)"
    fi
done

echo ""
echo "============================================"
echo "OPTION 1: Run automated test suite"
echo "============================================"
echo "  python3 ~/Projects/dataxlr8-rust/e2e_test.py"
echo ""
echo "============================================"
echo "OPTION 2: Test individual MCP interactively"
echo "============================================"
echo ""
echo "Pick an MCP to test:"
echo "  1) features  (9 tools: flags, overrides)"
echo "  2) contacts  (9 tools: CRM, tags, interactions)"
echo "  3) commissions (8 tools: managers, payments)"
echo "  4) email     (6 tools: send, templates)"
echo "  5) Run full automated suite"
echo "  q) Quit"
echo ""

read -p "Choice [1-5/q]: " choice

case $choice in
    1) MCP=features; BIN=~/Projects/dataxlr8-features-mcp/target/release/dataxlr8-features-mcp ;;
    2) MCP=contacts; BIN=~/Projects/dataxlr8-contacts-mcp/target/release/dataxlr8-contacts-mcp ;;
    3) MCP=commissions; BIN=~/Projects/dataxlr8-commissions-mcp/target/release/dataxlr8-commissions-mcp ;;
    4) MCP=email; BIN=~/Projects/dataxlr8-email-mcp/target/release/dataxlr8-email-mcp ;;
    5) exec python3 ~/Projects/dataxlr8-rust/e2e_test.py ;;
    q|Q) echo "Bye!"; exit 0 ;;
    *) echo "Invalid choice"; exit 1 ;;
esac

echo ""
echo "Starting $MCP MCP interactively..."
echo "Type JSON-RPC requests, one per line. Ctrl+C to exit."
echo ""
echo "Quick commands to try:"
echo ""

case $MCP in
    features)
        echo '  {"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create_flag","arguments":{"name":"test_flag","enabled":true}}}'
        echo '  {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_all_flags","arguments":{}}}'
        echo '  {"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"check_flag","arguments":{"name":"test_flag"}}}'
        ;;
    contacts)
        echo '  {"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create_contact","arguments":{"first_name":"Test","last_name":"User","email":"test@test.com"}}}'
        echo '  {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"list_contacts","arguments":{}}}'
        echo '  {"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"contact_stats","arguments":{}}}'
        ;;
    commissions)
        echo '  {"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create_manager","arguments":{"name":"Test Manager","email":"test@dataxlr8.com"}}}'
        echo '  {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"list_managers","arguments":{}}}'
        echo '  {"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"leaderboard","arguments":{}}}'
        ;;
    email)
        echo '  {"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create_template","arguments":{"name":"test","subject":"Hi {{name}}","html_body":"<h1>Hello {{name}}</h1>"}}}'
        echo '  {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"list_templates","arguments":{}}}'
        echo '  {"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"email_stats","arguments":{}}}'
        ;;
esac

echo ""
echo "--- Starting MCP (handshake auto-sent) ---"
echo ""

# Start MCP with auto-handshake using python
python3 -c "
import subprocess, json, sys, readline

proc = subprocess.Popen(
    ['$BIN'],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
    env={'DATABASE_URL': '$DATABASE_URL', 'RUST_LOG': 'error', 'PATH': '/usr/bin:/bin'}
)

# Auto handshake
proc.stdin.write(b'{\"jsonrpc\":\"2.0\",\"id\":0,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2024-11-05\",\"capabilities\":{},\"clientInfo\":{\"name\":\"manual\",\"version\":\"1\"}}}\n')
proc.stdin.flush()
r = json.loads(proc.stdout.readline())
print(f'Connected to: {r[\"result\"][\"serverInfo\"][\"name\"]}')

proc.stdin.write(b'{\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}\n')
proc.stdin.flush()

# List tools
proc.stdin.write(b'{\"jsonrpc\":\"2.0\",\"id\":0,\"method\":\"tools/list\"}\n')
proc.stdin.flush()
r = json.loads(proc.stdout.readline())
tools = r['result']['tools']
print(f'Tools ({len(tools)}):')
for t in tools:
    print(f'  - {t[\"name\"]}: {t.get(\"description\",\"\")[:60]}')
print()

try:
    while True:
        line = input('> ')
        if not line.strip():
            continue
        proc.stdin.write((line + '\n').encode())
        proc.stdin.flush()
        resp = proc.stdout.readline()
        if resp:
            print(json.dumps(json.loads(resp), indent=2))
        print()
except (KeyboardInterrupt, EOFError):
    proc.terminate()
    print('\nBye!')
"
