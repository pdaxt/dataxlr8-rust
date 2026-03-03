# DataXLR8 Rust — Micro MCP Platform

Rewriting the entire [DataXLR8 TypeScript monorepo](https://github.com/pdaxt/dataxlr8) into independent Rust MCP servers for near-zero latency, minimal memory footprint, and total independence.

## What This Is

DataXLR8 is a business operations platform built on the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/). It provides 150+ AI-callable tools for CRM, sales, project management, meetings, analytics, and more.

This project rewrites everything from TypeScript/Node.js to Rust, resulting in:

| Metric | TypeScript (current) | Rust (target) |
|--------|---------------------|---------------|
| Tool call latency | ~10ms | ~0.2ms |
| Memory per MCP | ~110MB | ~10MB |
| Binary size | ~100MB (node_modules) | ~6.5MB |
| Cold start | ~500ms | ~5ms |
| Dependencies | npm ecosystem | Single static binary |

## Current Status

### Completed (Phase 0)

| Component | Repo | Status |
|-----------|------|--------|
| Shared core library | [dataxlr8-mcp-core](https://github.com/pdaxt/dataxlr8-mcp-core) | Done — DB pool, config, errors, logging |
| Feature flags MCP | [dataxlr8-features-mcp](https://github.com/pdaxt/dataxlr8-features-mcp) | Done — 8 tools, 6.5MB binary |
| Code review & fixes | [docs/ASSESSMENT.md](docs/ASSESSMENT.md) | Done — all critical bugs fixed |

### Remaining (21 MCPs + Gateway)

See [docs/PLAN.md](docs/PLAN.md) for the full migration plan and phase breakdown.

## Architecture

```
┌─────────────────────────────┐
│   dataxlr8-gateway-mcp      │  ← Single HTTP endpoint
│   (spawns & manages all)    │     for Claude Desktop / web app
└──────────┬──────────────────┘
           │ stdio
    ┌──────┼──────┬──────┬──────┐
    │      │      │      │      │
 features deals  meet  portal  ...   ← 22 Rust MCP binaries
    │      │      │      │      │
    └──────┴──────┴──────┴──────┘
           │
    ┌──────▼──────┐
    │ PostgreSQL  │  ← Single database
    │ (shared)    │     Schema namespaces per MCP
    └─────────────┘
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed design decisions.

## Repos

| # | Repository | Purpose | Tools |
|---|-----------|---------|-------|
| 0 | [dataxlr8-mcp-core](https://github.com/pdaxt/dataxlr8-mcp-core) | Shared Rust library | N/A |
| 1 | [dataxlr8-features-mcp](https://github.com/pdaxt/dataxlr8-features-mcp) | Feature flag management | 8 |
| 2-22 | *To be built* | See [PLAN.md](docs/PLAN.md) | 140+ |
| 23 | *dataxlr8-gateway-mcp* | Auto-connector gateway | N/A |

## Quick Start

See [docs/SETUP.md](docs/SETUP.md) for full setup instructions.

```bash
# Prerequisites: Rust, PostgreSQL

# Clone
git clone https://github.com/pdaxt/dataxlr8-mcp-core.git
git clone https://github.com/pdaxt/dataxlr8-features-mcp.git

# Configure
cd dataxlr8-features-mcp
echo 'DATABASE_URL=postgres://dataxlr8:dataxlr8@localhost:5432/dataxlr8' > .env

# Build & run
cargo build --release
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./target/release/dataxlr8-features-mcp
```

## Documentation

| Document | Description |
|----------|-------------|
| [PLAN.md](docs/PLAN.md) | Full migration plan — 7 phases, 24 repos, timeline |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design — gateway, schemas, stack choices |
| [ASSESSMENT.md](docs/ASSESSMENT.md) | Code review findings — bugs found and fixed |
| [SETUP.md](docs/SETUP.md) | Getting started — PostgreSQL, build, test, Claude Desktop |

## Tech Stack

- **MCP SDK:** [rmcp](https://crates.io/crates/rmcp) v0.17 (official Rust MCP SDK)
- **Database:** [sqlx](https://crates.io/crates/sqlx) v0.8 + PostgreSQL
- **Async:** [tokio](https://crates.io/crates/tokio)
- **Serialization:** [serde](https://crates.io/crates/serde)
- **Logging:** [tracing](https://crates.io/crates/tracing)

## The Features MCP (Proof of Concept)

The first completed MCP manages feature flags with 8 tools:

| Tool | Description |
|------|-------------|
| `get_all_flags` | Get all feature flags with overrides |
| `get_flag` | Get a specific flag by name |
| `check_flag` | Check if enabled (respects user/role overrides) |
| `check_flags_bulk` | Check multiple flags at once |
| `create_flag` | Create a new feature flag |
| `update_flag` | Update a flag's status/description |
| `delete_flag` | Delete a flag and all overrides |
| `set_override` | Set role/user override for a flag |

Override priority: **user override > role override > global setting**

Unknown flags default to **disabled** (fail-closed security).

---

*Built with Rust. Powered by [rmcp](https://github.com/modelcontextprotocol/rust-sdk).*
