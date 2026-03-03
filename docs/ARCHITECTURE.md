# DataXLR8 Rust Architecture

## System Overview

```
                    ┌─────────────────────────────┐
                    │   dataxlr8-gateway-mcp      │
                    │   (Rust - Streamable HTTP)   │
                    │                              │
                    │  - Auto-discovers all MCPs   │
                    │  - Routes tool calls         │
                    │  - Health monitoring          │
                    │  - Single connection point    │
                    └──────────┬───────────────────┘
                               │ spawns & manages
            ┌──────────┬───────┼───────┬──────────┬─────────┐
            │          │       │       │          │         │
         ┌──▼──┐  ┌───▼──┐ ┌──▼──┐ ┌──▼──┐  ┌───▼──┐  ┌──▼──┐
         │deals│  │train │ │quote│ │meet │  │notif │  │ ... │
         │ mcp │  │ mcp  │ │ mcp │ │ mcp │  │ mcp  │  │     │
         └─────┘  └──────┘ └─────┘ └─────┘  └──────┘  └─────┘
            │          │       │       │          │
         Postgres   Postgres  Postgres LiveKit   Resend
         (shared)   (shared)  (shared)
```

## Key Design Decisions

### 1. Single PostgreSQL Database, Schema Namespaces

All MCPs connect to **one** PostgreSQL database. Each MCP owns its own schema namespace:

| MCP | Schema | Tables |
|-----|--------|--------|
| features-mcp | `features.*` | flags, flag_overrides |
| contacts-mcp | `contacts.*` | contacts, tags |
| deals-mcp | `deals.*` | deals, activities |
| portal-mcp | `portal.*` | projects, deliverables, comments |
| ... | ... | ... |

**Why:** One database to manage, backup, and monitor. Schema namespaces provide logical isolation without operational complexity.

### 2. Gateway Pattern

The gateway MCP is the auto-connection layer:

1. Reads `dataxlr8.toml` config listing all MCP binary paths
2. Spawns each MCP as a child process (stdio transport)
3. Exposes ALL tools from ALL MCPs through a single Streamable HTTP endpoint
4. Client connects to ONE gateway, gets access to ALL 150+ tools
5. Health checks each MCP on a heartbeat, auto-restarts on crash
6. Tool calls are prefixed: `deals.list_deals`, `meet.create_room`, etc.

### 3. Shared Core Crate

`dataxlr8-mcp-core` provides:
- Database connection pool management (PostgreSQL via sqlx)
- Standard error types with MCP error codes
- Configuration loading from environment variables
- Tracing/logging initialization (logs to stderr, stdout reserved for MCP protocol)

Every MCP depends on this crate. Changes here propagate to all MCPs.

### 4. Each MCP = One Binary

Each MCP compiles to a single native binary (~6-7 MB). No runtime dependencies.
No node_modules. No JVM. Just the binary and a `.env` file.

## Repo Structure (per MCP)

```
dataxlr8-{name}-mcp/
├── Cargo.toml
├── .env.example
├── .gitignore
├── src/
│   ├── main.rs          # Entry point
│   ├── db.rs            # Schema setup (CREATE TABLE IF NOT EXISTS)
│   └── tools/
│       └── mod.rs       # Tool definitions + ServerHandler impl
```

## Technology Stack

| Component | Choice | Why |
|-----------|--------|-----|
| MCP SDK | `rmcp` v0.17 | Official Rust MCP SDK, 3.1k stars |
| Database | `sqlx` v0.8 + PostgreSQL | Async, compile-time checked SQL |
| Async Runtime | `tokio` | Standard Rust async runtime |
| Serialization | `serde` + `serde_json` | Standard Rust serialization |
| Error Handling | `thiserror` + custom `McpError` | Structured errors with MCP error codes |
| Logging | `tracing` + `tracing-subscriber` | Structured logging to stderr |
| Config | `dotenvy` + `std::env` | Simple .env file support |

## Performance Targets

| Metric | TypeScript (current) | Rust (target) |
|--------|---------------------|---------------|
| Tool call latency | ~10ms | ~0.2ms |
| Memory footprint | ~110MB | ~10MB |
| Binary size | ~100MB (node_modules) | ~6.5MB |
| Cold start | ~500ms | ~5ms |

## Gateway Config (dataxlr8.toml)

```toml
[gateway]
port = 3100
host = "127.0.0.1"
health_interval_secs = 30

[[mcps]]
name = "features"
bin = "./target/release/dataxlr8-features-mcp"
auto_restart = true
max_restarts = 3

[[mcps]]
name = "contacts"
bin = "./target/release/dataxlr8-contacts-mcp"
auto_restart = true

# ... all MCPs listed here
```

## Claude Desktop Config (after gateway is built)

```json
{
  "mcpServers": {
    "dataxlr8": {
      "url": "http://localhost:3100",
      "description": "DataXLR8 - All tools via gateway"
    }
  }
}
```

One entry. All 150+ tools. Auto-connected.

## Web App Rewiring

The Next.js web app stays as-is but its data access layer changes:

**Before (direct DB access):**
```
[API Route] → import { listQuotations } from "@/lib/quotation-client"
              → opens SQLite file directly
              → returns data
```

**After (via gateway):**
```
[API Route] → import { callTool } from "@/lib/mcp-gateway-client"
              → callTool("quotation.list_quotations", { status: "active" })
              → HTTP POST to gateway (localhost:3100)
              → gateway routes to quotation-mcp via stdio
              → returns data
```

Zero changes to API routes. Just the data layer gets swapped.
