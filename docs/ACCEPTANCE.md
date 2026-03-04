# Acceptance Criteria & Test Protocol

Every Rust MCP must pass ALL checks below before being marked as VERIFIED in STATUS.md.

---

## Gate 1: Build

| # | Check | Command | Expected |
|---|-------|---------|----------|
| 1.1 | Compiles | `cargo build --release` | Exit 0, zero warnings |
| 1.2 | Binary size | `ls -lh target/release/dataxlr8-{name}-mcp` | < 10MB |
| 1.3 | Dependencies | `cargo tree --depth 1` | Only expected crates |

## Gate 2: Schema

| # | Check | How | Expected |
|---|-------|-----|----------|
| 2.1 | Auto-creates schema | Start MCP with empty DB | Schema + tables created |
| 2.2 | Idempotent | Start MCP again | No errors, no duplicates |
| 2.3 | Namespace isolation | `SELECT schema_name FROM information_schema.schemata` | Only its own schema touched |
| 2.4 | Indexes exist | `\di {schema}.*` in psql | All declared indexes present |

## Gate 3: MCP Protocol

| # | Check | How | Expected |
|---|-------|-----|----------|
| 3.1 | Initialize | Send `initialize` JSON-RPC | Returns protocolVersion, capabilities, serverInfo |
| 3.2 | Tools list | Send `tools/list` | Returns all expected tools with inputSchema |
| 3.3 | Schema correctness | Inspect each tool's inputSchema | Required fields marked, types correct |

## Gate 4: Tool Functionality

For each tool in the MCP:

| # | Check | How | Expected |
|---|-------|-----|----------|
| 4.1 | Happy path | Call with valid params | Returns expected data, isError: false |
| 4.2 | Missing required param | Omit a required field | Returns error message, isError: true |
| 4.3 | Invalid value | Pass wrong type/enum | Returns helpful error, doesn't crash |
| 4.4 | Not found | Query non-existent ID | Returns appropriate error or null |
| 4.5 | CRUD cycle | Create → Read → Update → Read → Delete → Read | Full lifecycle works |

## Gate 5: Error Handling

| # | Check | How | Expected |
|---|-------|-----|----------|
| 5.1 | DB down | Stop PostgreSQL, call tool | Returns error, doesn't panic |
| 5.2 | Invalid JSON | Send malformed JSON-RPC | Returns parse error |
| 5.3 | Unknown tool | Call non-existent tool name | Returns "unknown tool" error |
| 5.4 | Empty input | Call tool with `{}` args | Returns missing param error (not crash) |

## Gate 6: Integration

| # | Check | How | Expected |
|---|-------|-----|----------|
| 6.1 | Claude Code config | Add to `~/.claude.json` | MCP appears in `claude mcp list` |
| 6.2 | Claude Code call | Call a tool from Claude Code | Returns expected result |
| 6.3 | No schema collision | Run alongside other MCPs | Other schemas untouched |

---

## Test Script Template

Use this FIFO-based script to test any MCP via stdio:

```bash
#!/bin/bash
# test-mcp.sh <binary-path> <database-url>
# Example: ./test-mcp.sh ./target/release/dataxlr8-features-mcp postgres://pran@localhost/dataxlr8

BINARY=$1
DATABASE_URL=$2

export DATABASE_URL
mkfifo /tmp/mcp-test-pipe 2>/dev/null || true

# Start server
$BINARY < /tmp/mcp-test-pipe > /tmp/mcp-test-out.jsonl 2>/dev/null &
SERVER_PID=$!
exec 3>/tmp/mcp-test-pipe

# Helper function
send() {
    echo "$1" >&3
    sleep 0.5
}

# Initialize
send '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}'
send '{"jsonrpc":"2.0","method":"notifications/initialized"}'

# List tools
send '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'

# --- Add tool-specific tests here ---
# send '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"TOOL_NAME","arguments":{...}}}'

# Cleanup
exec 3>&-
sleep 1
kill $SERVER_PID 2>/dev/null
wait $SERVER_PID 2>/dev/null
rm -f /tmp/mcp-test-pipe

# Results
echo "=== Test Results ==="
cat /tmp/mcp-test-out.jsonl | python3 -c "
import sys, json
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    data = json.loads(line)
    rid = data.get('id', '?')
    if 'error' in data:
        print(f'  [{rid}] FAIL: {data[\"error\"]}')
    elif 'result' in data:
        r = data['result']
        if isinstance(r, dict) and 'tools' in r:
            tools = [t['name'] for t in r['tools']]
            print(f'  [{rid}] TOOLS: {len(tools)} — {tools}')
        elif isinstance(r, dict) and 'content' in r:
            is_err = r.get('isError', False)
            text = r['content'][0]['text'][:200] if r['content'] else ''
            status = 'FAIL' if is_err else 'PASS'
            print(f'  [{rid}] {status}: {text}')
        else:
            print(f'  [{rid}] OK: {json.dumps(r)[:200]}')
"
```

---

## Updating STATUS.md After Testing

After running tests, update `docs/STATUS.md`:

1. Change component row status to `VERIFIED`
2. Fill in Binary size, Tools count (tested/total), Schema name
3. Add a Verification Log section with each check and date
4. Commit: `git commit -m "status: {name} verified"`
