# DataXLR8

**Open-source Rust MCP servers that replace your SaaS stack.**

DataXLR8 is a modular platform of [Model Context Protocol](https://modelcontextprotocol.io/) servers written in Rust. Each MCP is a standalone binary that gives AI agents direct access to business operations — CRM, lead enrichment, email, commissions, and more — without routing through legacy SaaS APIs.

Instead of connecting agents to Salesforce, Apollo, and Outreach through API wrappers, DataXLR8 *is* the CRM, the enrichment engine, and the email system. All data lives in your PostgreSQL database. All tool calls resolve in ~0.2ms.

## Why Replacement Beats Connection

```
CONNECTOR MODEL (Composio, Pipedream):

  Agent --> Connector --> Salesforce API --> Their Database
                      --> Apollo API     --> Their Database
                      --> Outreach API   --> Their Database

  Still paying $75/user for Salesforce
  Still paying $49/user for Apollo
  Data scattered across vendors
  Triple latency: agent -> connector -> API -> DB -> back

REPLACEMENT MODEL (DataXLR8):

  Agent --> crm-mcp        --> YOUR database (0.2ms)
        --> enrichment-mcp --> YOUR database (0.2ms)
        --> email-mcp      --> YOUR database (0.2ms)

  No SaaS licenses
  All data in one place you control
  50x faster tool calls
```

## Architecture

Every MCP is its own repository, its own binary, its own release cycle. They share a single core library (`mcp-core`) for database pooling, configuration, error handling, and common types.

```
                         ┌──────────────────────────────┐
                         │   Any AI Agent               │
                         │   Claude, GPT, LangChain,    │
                         │   CrewAI, AutoGen, Goose     │
                         └──────────────┬───────────────┘
                                        │ stdio / Streamable HTTP
                                        │
         ┌──────────────────────────────────────────────────────────┐
         │                                                          │
    ┌────┴─────┐ ┌───────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐│
    │enrichment│ │    crm    │ │  email  │ │commiss- │ │features ││
    │   mcp    │ │    mcp    │ │   mcp   │ │ions mcp │ │   mcp   ││
    │ 12 tools │ │ 12 tools  │ │ 6 tools │ │ 8 tools │ │ 9 tools ││
    │  6.5MB   │ │   6.5MB   │ │  6.5MB  │ │  6.5MB  │ │  6.5MB  ││
    └────┬─────┘ └─────┬─────┘ └────┬────┘ └────┬────┘ └────┬────┘│
         │             │            │            │            │     │
         │       ┌─────┴────────────┴────────────┴────────────┘     │
         │       │                                                  │
    ┌────┴───────┴──────────────────────────────────────────────┐   │
    │                   dataxlr8-mcp-core                       │   │
    │   config | db (PgPool) | error | logging | mcp helpers    │   │
    │                    shared types                           │   │
    └──────────────────────────┬────────────────────────────────┘   │
                               │                                    │
                        ┌──────┴──────┐          ┌─────────────┐   │
                        │ PostgreSQL  │          │  devtools   │───┘
                        │  (shared)   │          │    mcp      │
                        │  schema per │          │  20 tools   │
                        │    MCP      │          └─────────────┘
                        └─────────────┘
```

Each MCP uses its own PostgreSQL schema (`enrichment.*`, `crm.*`, `email.*`, etc.) within a shared database. Deploy one MCP or all of them — they're independent binaries that compose through shared data.

## MCP Catalog

### Shipped (compiling, on GitHub)

| MCP | Repository | Tools | What It Replaces |
|-----|-----------|-------|-----------------|
| **mcp-core** | [dataxlr8-mcp-core](https://github.com/pdaxt/dataxlr8-mcp-core) | shared lib | — |
| **enrichment-mcp** | [dataxlr8-enrichment-mcp](https://github.com/pdaxt/dataxlr8-enrichment-mcp) | 12 | Apollo, ZoomInfo, Clearbit |
| **crm-mcp** | [dataxlr8-crm-mcp](https://github.com/pdaxt/dataxlr8-crm-mcp) | 12 | Salesforce, HubSpot, Pipedrive |
| **devtools-mcp** | [dataxlr8-devtools-mcp](https://github.com/pdaxt/dataxlr8-devtools-mcp) | 20 | Internal dev tooling |
| **features-mcp** | [dataxlr8-features-mcp](https://github.com/pdaxt/dataxlr8-features-mcp) | 9 | LaunchDarkly |
| **commissions-mcp** | [dataxlr8-commissions-mcp](https://github.com/pdaxt/dataxlr8-commissions-mcp) | 8 | Spreadsheets |
| **email-mcp** | [dataxlr8-email-mcp](https://github.com/pdaxt/dataxlr8-email-mcp) | 6 | SendGrid, Mailchimp |
| **web** | [dataxlr8-web](https://github.com/pdaxt/dataxlr8-web) | portal | Employee portal (Next.js) |
| | | **67 tools** | |

### Planned

| MCP | Tools | What It Replaces | Priority |
|-----|-------|-----------------|----------|
| analytics-mcp | 8 | Tableau, Metabase | P1 |
| pipeline-mcp | 8 | Pipeline automation | P1 |
| scoring-mcp | 8 | Lead scoring engines | P1 |
| scheduler-mcp | 8 | Calendly, cron jobs | P1 |
| notes-mcp | 8 | Meeting note tools | P2 |
| templates-mcp | 8 | Document template tools | P2 |
| webhooks-mcp | 8 | Webhook delivery | P2 |
| finance-mcp | 8 | QuickBooks, Xero | P2 |
| sales-mcp | 10 | Outreach, SalesLoft | P2 |
| scraper-mcp | 6 | Apify, ScrapingBee | P2 |
| gateway-mcp | — | Auth, routing, metering | P3 |

## Performance

Every MCP compiles to a single static binary. No runtime, no node_modules, no virtualenv.

| Metric | DataXLR8 (Rust) | Python (FastMCP) | TypeScript |
|--------|----------------|-----------------|------------|
| Tool call latency | 0.2ms | ~10ms | ~8ms |
| Memory per MCP | ~10MB | ~110MB | ~80MB |
| Binary size | ~6.5MB | ~100MB (venv) | ~100MB (node_modules) |
| Cold start | ~5ms | ~500ms | ~300ms |
| MCPs per $5 VPS | 20+ | 1-2 | 2-3 |

## Quick Start

**Prerequisites:** Rust (1.75+), PostgreSQL

```bash
# 1. Clone the shared core library
git clone https://github.com/pdaxt/dataxlr8-mcp-core.git

# 2. Clone the MCP you want (e.g., enrichment)
git clone https://github.com/pdaxt/dataxlr8-enrichment-mcp.git

# 3. Configure the database
cd dataxlr8-enrichment-mcp
echo 'DATABASE_URL=postgres://user:pass@localhost:5432/dataxlr8' > .env

# 4. Build
cargo build --release

# 5. Verify it works — list available tools
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./target/release/dataxlr8-enrichment-mcp

# 6. Call a tool
echo '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"verify_email","arguments":{"email":"test@example.com"}}}' | ./target/release/dataxlr8-enrichment-mcp
```

### Add to Claude Desktop

Add any MCP to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "dataxlr8-enrichment": {
      "command": "/path/to/dataxlr8-enrichment-mcp",
      "env": {
        "DATABASE_URL": "postgres://user:pass@localhost:5432/dataxlr8"
      }
    },
    "dataxlr8-crm": {
      "command": "/path/to/dataxlr8-crm-mcp",
      "env": {
        "DATABASE_URL": "postgres://user:pass@localhost:5432/dataxlr8"
      }
    }
  }
}
```

## The Lego Pattern

Every MCP follows an identical structure. Adding a new MCP is stamping out the same pattern with different business logic:

```
dataxlr8-{name}-mcp/
├── Cargo.toml          # rmcp 0.17, dataxlr8-mcp-core (path dep), sqlx, tokio, serde
├── src/
│   ├── main.rs         # config -> logging -> db -> schema -> server -> stdio
│   ├── db.rs           # CREATE SCHEMA IF NOT EXISTS {name}; + tables
│   └── tools/
│       └── mod.rs      # types -> schema helpers -> build_tools() -> handlers
```

**Cargo.toml** depends on `dataxlr8-mcp-core` as a path dependency and `rmcp` v0.17 (official Rust MCP SDK).

**main.rs** follows the same 15-line boot sequence: load config from env, init structured logging, connect to PostgreSQL, run schema migrations, start the MCP server on stdio.

**db.rs** creates a dedicated schema namespace in PostgreSQL (`CREATE SCHEMA IF NOT EXISTS {name}`). MCPs don't share tables — they share the database instance.

**tools/mod.rs** defines tool schemas, implements handlers, and wires them into the `ServerHandler` trait. Shared helpers from `mcp-core` (`make_schema`, `json_result`, `error_result`, `get_str`, etc.) eliminate boilerplate.

This pattern means every MCP:
- Compiles to a <7MB binary
- Starts in <5ms
- Uses <10MB of memory
- Self-provisions its database schema on first run
- Works with any MCP client (Claude, GPT, LangChain, CrewAI)

## Tech Stack

- **MCP SDK:** [rmcp](https://crates.io/crates/rmcp) v0.17 — official Rust MCP SDK
- **Database:** [sqlx](https://crates.io/crates/sqlx) v0.8 + PostgreSQL (compile-time checked queries)
- **Async:** [tokio](https://crates.io/crates/tokio)
- **Serialization:** [serde](https://crates.io/crates/serde)
- **Logging:** [tracing](https://crates.io/crates/tracing)
- **License:** MIT

## Documentation

### Strategy & Roadmap

The [docs/strategy/](docs/strategy/) directory contains the full vision, market analysis, and execution plan:

| Document | Description |
|----------|-------------|
| [VISION.md](docs/strategy/VISION.md) | Architecture, revenue model, competitive position, moats |
| [FEATURE-BLUEPRINT.md](docs/strategy/FEATURE-BLUEPRINT.md) | Full MCP catalog with tool specs and composability examples |
| [EXECUTION-PLAN.md](docs/strategy/EXECUTION-PLAN.md) | Week-by-week build and launch plan |
| [BUILD-PLAN.md](docs/strategy/BUILD-PLAN.md) | Current sprint status and multi-agent build coordination |
| [MCP-ECOSYSTEM.md](docs/strategy/MCP-ECOSYSTEM.md) | MCP adoption data, Rust performance edge, framework integrations |
| [MARKET-LANDSCAPE.md](docs/strategy/MARKET-LANDSCAPE.md) | Competitive landscape and market sizing |
| [PRICING-AND-GTM.md](docs/strategy/PRICING-AND-GTM.md) | Pricing tiers, go-to-market channels, revenue projections |
| [CLIENT-ACQUISITION-PLAYBOOK.md](docs/strategy/CLIENT-ACQUISITION-PLAYBOOK.md) | Cold outreach scripts, target profiles, funnel mechanics |

### Agent Prompts

The [docs/prompts/](docs/prompts/) directory contains build instructions for each MCP, used by AI agents during development:

| Prompt | Description |
|--------|-------------|
| [_pattern.md](docs/prompts/_pattern.md) | The lego pattern — file structure, Cargo.toml template, code patterns |
| [enrichment-mcp.md](docs/prompts/enrichment-mcp.md) | Enrichment MCP — provider architecture, waterfall, 12 tools |
| [crm-mcp.md](docs/prompts/crm-mcp.md) | CRM MCP — contacts, deals, pipeline, 12 tools |
| [devtools-mcp.md](docs/prompts/devtools-mcp.md) | DevTools MCP — sessions, code analysis, git ops, 20 tools |
| [analytics-mcp.md](docs/prompts/analytics-mcp.md) | Analytics MCP — events, funnels, time series, 8 tools |
| [pipeline-mcp.md](docs/prompts/pipeline-mcp.md) | Pipeline MCP — stage automation, velocity, forecasting, 8 tools |
| [scoring-mcp.md](docs/prompts/scoring-mcp.md) | Scoring MCP — lead scoring models, qualification, 8 tools |
| [scheduler-mcp.md](docs/prompts/scheduler-mcp.md) | Scheduler MCP — jobs, sequences, retry logic, 8 tools |
| [notes-mcp.md](docs/prompts/notes-mcp.md) | Notes MCP — meeting notes, action items, 8 tools |
| [templates-mcp.md](docs/prompts/templates-mcp.md) | Templates MCP — document rendering, versioning, 8 tools |
| [webhooks-mcp.md](docs/prompts/webhooks-mcp.md) | Webhooks MCP — subscriptions, delivery, retry, 8 tools |

### Other Docs

| Document | Description |
|----------|-------------|
| [BRD.md](docs/BRD.md) | Business Requirements Document |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design decisions |
| [PLAN.md](docs/PLAN.md) | Original migration plan from TypeScript |
| [STATUS.md](docs/STATUS.md) | Live status dashboard |
| [SETUP.md](docs/SETUP.md) | Full setup instructions |
| [ACCEPTANCE.md](docs/ACCEPTANCE.md) | Acceptance criteria and test protocols |

## Contributing

Each MCP is an independent repo. To contribute:

1. Pick an MCP from the planned list above
2. Read [docs/prompts/_pattern.md](docs/prompts/_pattern.md) for the standard structure
3. Read the MCP-specific prompt in `docs/prompts/{name}-mcp.md` for tool specs
4. Follow the lego pattern — `Cargo.toml`, `main.rs`, `db.rs`, `tools/mod.rs`
5. Ensure `cargo build` passes before submitting a PR

---

Built with Rust. Powered by [rmcp](https://github.com/modelcontextprotocol/rust-sdk).
