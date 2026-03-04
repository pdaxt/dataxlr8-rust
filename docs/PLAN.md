# Migration Plan: DataXLR8 TypeScript Monorepo → Rust Micro MCPs

## Context

The current `pdaxt/dataxlr8` monorepo is a TypeScript/Next.js application with 8 MCP servers, 6 shared packages, 3 Cloudflare Workers, and a full-stack web app. Business logic is embedded in `apps/web/lib/` files that directly access SQLite databases, Google Sheets, and external APIs.

**Problem:** The TypeScript MCP servers have ~10ms latency, ~110MB memory footprint, and slow cold starts. The monorepo couples everything together, making independent deployment impossible.

**Goal:** Rewrite every MCP server in Rust for near-zero latency (~0.2ms), ~10MB memory, instant cold starts, and deploy each as an independent GitHub repo. All MCPs auto-connect via a central gateway.

---

## Stack Change

| Component | Current (TypeScript) | Target (Rust) |
|-----------|---------------------|---------------|
| MCP SDK | `@modelcontextprotocol/sdk` | `rmcp` v0.17+ (official Rust SDK) |
| Database | `better-sqlite3` + Google Sheets + JSON files | `sqlx` + PostgreSQL (single shared DB) |
| HTTP Client | `node-fetch` | `reqwest` |
| Async Runtime | Node.js event loop | `tokio` |
| Serialization | JSON native | `serde` + `serde_json` |
| Schema Validation | `zod` | `serde` derive + custom validators |
| Google APIs | `googleapis` npm | `google-cloud-rust` (official) |
| LiveKit | `livekit-server-sdk` npm | `livekit-api` crate |
| Claude AI | `@anthropic-ai/sdk` | `anthropic-sdk-rust` (community) |
| Email | `resend` npm | `resend_rs` (official) |
| Logging | `pino` | `tracing` + `tracing-subscriber` |
| Build | `tsup` + `tsc` | `cargo build --release` |
| Output | JS bundle + node_modules | Single ~6.5MB native binary |

---

## Complete MCP Inventory (22 Rust MCPs + 1 Gateway)

### Shared Crate
| # | Repo | Status | Purpose |
|---|------|--------|---------|
| 0 | [`dataxlr8-mcp-core`](https://github.com/pdaxt/dataxlr8-mcp-core) | **DONE** | Shared Rust library: DB pool, error types, config loader, logging |

### Category A: Existing Meeting MCPs (rewrite from TypeScript)
| # | Repo | Tools | Data Store | Status |
|---|------|-------|------------|--------|
| 1 | `dataxlr8-analytics-mcp` | 8 | PostgreSQL | Pending |
| 2 | `dataxlr8-calendar-mcp` | 7 | PostgreSQL + Google Calendar | Pending |
| 3 | `dataxlr8-copilot-mcp` | 6 | PostgreSQL (cache) | Pending |
| 4 | `dataxlr8-meet-mcp` | 9 | Stateless (LiveKit API) | Pending |
| 5 | `dataxlr8-moderation-mcp` | 12 | PostgreSQL | Pending |
| 6 | `dataxlr8-notification-mcp` | 8 | PostgreSQL + Resend | Pending |
| 7 | `dataxlr8-recording-mcp` | 6 | S3/GCS + LiveKit | Pending |
| 8 | `dataxlr8-transcript-mcp` | 9 | PostgreSQL | Pending |

### Category B: New MCPs (extract from web app lib/)
| # | Repo | Source in Web App | Tools | Status |
|---|------|-------------------|-------|--------|
| 9 | `dataxlr8-deals-mcp` | `lib/google-sheets.ts` | 6 | Pending |
| 10 | `dataxlr8-employees-mcp` | `lib/google-sheets.ts` | 8 | Pending |
| 11 | `dataxlr8-training-mcp` | `lib/google-sheets.ts` | 6 | Pending |
| 12 | `dataxlr8-commissions-mcp` | `lib/manager-client.ts` | 5 | Pending |
| 13 | `dataxlr8-quotation-mcp` | `lib/quotation-client.ts` | 6 | Pending |
| 14 | `dataxlr8-supplier-mcp` | `lib/supplier-client.ts` | 6 | Pending |
| 15 | `dataxlr8-contacts-mcp` | `lib/contact-client.ts` | 5 | Pending |
| 16 | `dataxlr8-portal-mcp` | `lib/portal-client.ts` | 12 | Pending |
| 17 | `dataxlr8-rooming-mcp` | `lib/rooming-client.ts` | 5 | Pending |
| 18 | `dataxlr8-booking-mcp` | `lib/google-calendar.ts` | 4 | Pending |
| 19 | `dataxlr8-ai-analysis-mcp` | `lib/anthropic.ts` | 4 | Pending |
| 20 | [`dataxlr8-features-mcp`](https://github.com/pdaxt/dataxlr8-features-mcp) | `lib/features-client.ts` | 8 | **DONE** |
| 21 | `dataxlr8-pdf-mcp` | `lib/pdf-client.ts` | 4 | Pending |
| 22 | `dataxlr8-email-mcp` | `lib/email.ts` | 6 | Pending |

### Gateway
| # | Repo | Status | Purpose |
|---|------|--------|---------|
| 23 | `dataxlr8-gateway-mcp` | Pending | Orchestrator: spawns all MCPs, aggregates tools, single HTTP endpoint |

**Total: 24 Rust repos (1 shared crate + 22 MCPs + 1 gateway)**

---

## Migration Approach: Wave-Based Parallel Development

**Previous approach** (sequential phases) is replaced by **parallel waves** using tmux multi-agent development. See [DEVELOPMENT-STRATEGY.md](DEVELOPMENT-STRATEGY.md) for full details and [TMUX-LAYOUT.md](TMUX-LAYOUT.md) for pane assignments.

### Phase 0: Foundation ✅ COMPLETE
- [x] Install Rust toolchain
- [x] Create `dataxlr8-mcp-core` shared crate
- [x] Build `dataxlr8-features-mcp` as proof-of-concept (8 tools)
- [x] Code review and fix all critical/high issues
- [x] Build `dataxlr8-contacts-mcp` (9 tools)
- [x] Build `dataxlr8-commissions-mcp` (8 tools)
- [x] Build `dataxlr8-email-mcp` (6 tools)
- [x] Start `dataxlr8-web` (Axum, Google OAuth, team portal)
- [ ] Install PostgreSQL and verify end-to-end
- [ ] Connect to Claude Desktop and test

### Wave 1 — Week 1-2 (4 parallel workstreams, 16 agents)

All run simultaneously on Screen 1 + Screen 2:

| Workstream | MCP/Project | Tools | Agent Screen |
|-----------|-------------|-------|-------------|
| **A** | `enrichment-mcp` — THE WEDGE (Clearbit replacement) | 12 | Screen 1, W0 |
| **B** | `crm-mcp` — Salesforce replacement | 10 | Screen 1, W1 |
| **C** | `gateway-mcp` — Infrastructure for Cloud | 5 | Screen 1, W2 |
| **D** | `dataxlr8-web` — Public website revamp | — | Screen 2, W0 |

**Deliverables:** 4 repos with CI/CD, published to GitHub, binaries on Releases

### Wave 2 — Week 3-4 (4 parallel workstreams, +16 agents)

| Workstream | MCP/Project | Tools | Agent Screen |
|-----------|-------------|-------|-------------|
| **A** | `sales-mcp` — Outreach replacement | 10 | Screen 1, W3 |
| **B** | `finance-mcp` — QuickBooks replacement (GST) | 8 | Screen 1, W3 |
| **C** | `scraper-mcp` — Data collection engine | 6 | Screen 1, W3 |
| **D** | Employee + Client Portal | — | Screen 2, W1+W2 |

**Deliverables:** 3 more MCPs, employee portal expanded, client portal MVP

### Wave 3 — Month 2 (expansion, +12 agents)

| Workstream | What |
|-----------|------|
| Internal MCPs | deals, employees, training, supplier, quotation, portal, rooming, booking |
| New revenue MCPs | intelligence-mcp, content-mcp, analytics-mcp |
| Chrome Extension | LinkedIn enrichment overlay |
| Cloud alpha | Gateway deployed on GCP, first external user |
| Data migration | Google Sheets → PostgreSQL |

### Wave 4 — Month 3+ (platform, all 48 agents)

| Workstream | What |
|-----------|------|
| Meeting domain | meet, recording, transcript, calendar, copilot, moderation, notification |
| Enterprise | SSO, RBAC, audit logs |
| Community | Contribution framework, crates.io publishing |

### Legacy Cleanup (parallel with Wave 3+)
- Archive Python MCPs in `mcp-servers/dataxlr8_*`
- Archive TypeScript MCPs in `dataxlr8/mcps/`
- Retire Google Sheets backend
- Update Claude Desktop config to use gateway

---

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Rust learning curve | HIGH | Use `rmcp` macros; follow features-mcp as template |
| No official Anthropic Rust SDK | MEDIUM | Community crate or raw `reqwest` against Messages API |
| Google Sheets Rust client | MEDIUM | `google-cloud-rust` is official + GA |
| 22+ repos to maintain | MEDIUM | Shared crate, consistent CI, gateway config as source of truth |
| Schema evolution | LOW | Use `sqlx::migrate!()` for future schema changes |
| Binary distribution | LOW | GitHub Releases with pre-built binaries per platform |

---

## Verification Plan (per MCP)

1. `cargo check` — compiles without errors
2. `cargo test` — unit tests pass
3. `cargo build --release` — produces binary
4. Manual stdio test with JSON-RPC
5. Connect from Claude Desktop and call each tool
6. After gateway: verify namespaced tool routing
7. After web app rewiring: run existing Playwright tests
