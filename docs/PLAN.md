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

## Migration Phases

### Phase 0: Foundation ✅ COMPLETE
- [x] Install Rust toolchain
- [x] Create `dataxlr8-mcp-core` shared crate
- [x] Build `dataxlr8-features-mcp` as proof-of-concept (8 tools)
- [x] Code review and fix all critical/high issues
- [ ] Install PostgreSQL and verify end-to-end
- [ ] Connect to Claude Desktop and test

### Phase 1: Leaf MCPs — No Cross-Dependencies
| MCP | Complexity | Notes |
|-----|-----------|-------|
| `dataxlr8-contacts-mcp` | Low | Simple CRUD |
| `dataxlr8-commissions-mcp` | Low | JSON file → PostgreSQL |
| `dataxlr8-email-mcp` | Low | Resend API calls |
| `dataxlr8-moderation-mcp` | Medium | 12 tools |

### Phase 2: Core Business MCPs
| MCP | Complexity | Notes |
|-----|-----------|-------|
| `dataxlr8-supplier-mcp` | Medium | Seasonal rates |
| `dataxlr8-quotation-mcp` | Medium | Complex pricing logic |
| `dataxlr8-rooming-mcp` | Medium | References quotations |
| `dataxlr8-portal-mcp` | High | Full CRUD + activity logging |
| `dataxlr8-pdf-mcp` | Medium | PDF generation (typst crate) |

### Phase 3: Google Sheets → PostgreSQL MCPs
| MCP | Complexity | Notes |
|-----|-----------|-------|
| `dataxlr8-employees-mcp` | Medium | Migrate from Google Sheets |
| `dataxlr8-deals-mcp` | Medium | Pipeline logic |
| `dataxlr8-training-mcp` | Medium | Progress tracking |
| `dataxlr8-booking-mcp` | Medium | Google Calendar API |

### Phase 4: Meeting Domain MCPs
| MCP | Complexity | Notes |
|-----|-----------|-------|
| `dataxlr8-meet-mcp` | Medium | LiveKit Rust SDK |
| `dataxlr8-recording-mcp` | Medium | LiveKit egress + S3 |
| `dataxlr8-transcript-mcp` | Medium | Full-text search |
| `dataxlr8-analytics-mcp` | Medium | Aggregations |
| `dataxlr8-calendar-mcp` | Medium | Google Calendar |
| `dataxlr8-copilot-mcp` | High | Anthropic API streaming |
| `dataxlr8-notification-mcp` | Medium | Resend + PostgreSQL |

### Phase 5: AI + Gateway
| MCP | Complexity | Notes |
|-----|-----------|-------|
| `dataxlr8-ai-analysis-mcp` | High | Multi-provider AI routing |
| `dataxlr8-gateway-mcp` | High | Process manager, tool aggregation, HTTP server |

### Phase 6: Web App Rewiring
- Create `lib/mcp-gateway-client.ts` in apps/web
- Replace each `lib/xxx-client.ts` with gateway calls
- Run existing tests after each rewiring

### Phase 7: Cleanup
- Archive old TypeScript MCPs
- Update configs to point to Rust binaries
- Update Claude Desktop to use gateway

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
