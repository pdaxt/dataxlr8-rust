# BRD: dataxlr8-gateway-mcp

**Phase:** 5
**Status:** NOT STARTED
**PG Schema:** N/A (stateless router)
**Source:** New component

---

## Purpose

Central gateway that spawns all Rust MCP binaries as child processes, aggregates their tools, and exposes a single Streamable HTTP endpoint. Claude Code or the web app connects to ONE URL and gets access to ALL 150+ tools.

## Architecture

```
Client (Claude Code / Web App)
    │
    │ HTTP POST http://localhost:3100/mcp
    │
    ▼
┌──────────────────────────┐
│  dataxlr8-gateway-mcp    │
│  - Reads dataxlr8.toml   │
│  - Spawns child MCPs     │
│  - Routes tool calls     │
│  - Health monitoring      │
│  - Tool namespace prefix  │
└──┬──┬──┬──┬──┬──┬──┬──┬─┘
   │  │  │  │  │  │  │  │
  stdio connections to 22 child processes
```

## Config Format (dataxlr8.toml)

```toml
[gateway]
port = 3100
host = "127.0.0.1"
health_interval_secs = 30

[[mcps]]
name = "features"
bin = "./dataxlr8-features-mcp"
env = { DATABASE_URL = "postgres://..." }
auto_restart = true
max_restarts = 3

[[mcps]]
name = "contacts"
bin = "./dataxlr8-contacts-mcp"
auto_restart = true
```

## Behavior

1. **Startup:** Read config, spawn each MCP binary, send `initialize` to each
2. **tools/list:** Aggregate all tools from all MCPs, prefix with MCP name (e.g., `features.create_flag`)
3. **tools/call:** Parse prefix, route to correct child process
4. **Health:** Periodic heartbeat to each child; auto-restart on crash
5. **Shutdown:** Send graceful shutdown to all children

## Tools

Gateway itself has no tools — it exposes all child MCP tools with namespace prefixes.

## Acceptance Criteria

- [ ] Reads and parses dataxlr8.toml
- [ ] Spawns at least 2 child MCPs
- [ ] tools/list aggregates all child tools with prefixes
- [ ] tools/call routes correctly to child
- [ ] Auto-restarts crashed child within 1s
- [ ] Streamable HTTP endpoint works
- [ ] Claude Code can connect via HTTP URL
- [ ] All 150+ tools accessible through single connection
