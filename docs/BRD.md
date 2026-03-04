# Business Requirements Document: DataXLR8 Rust MCP Platform

**Document Owner:** Pranjal Gupta
**Version:** 1.0
**Created:** 2026-03-04
**Last Updated:** 2026-03-04

---

## 1. Executive Summary

DataXLR8 is a business operations platform built on the Model Context Protocol (MCP). It provides 150+ AI-callable tools spanning CRM, sales, project management, HR, training, and more.

**This project** rewrites the entire platform from TypeScript/Node.js into independent Rust MCP servers — one binary per domain — connected through a central gateway. The result: 50x faster tool calls, 10x less memory, instant cold starts, and fully independent deployment.

---

## 2. Business Objectives

| # | Objective | Success Metric |
|---|-----------|---------------|
| 1 | Eliminate Node.js overhead | Tool call latency < 1ms (from ~10ms) |
| 2 | Reduce memory footprint | < 15MB per MCP (from ~110MB) |
| 3 | Enable independent deployment | Each MCP deploys without touching others |
| 4 | Consolidate data layer | Single PostgreSQL database replaces SQLite + Google Sheets + JSON files |
| 5 | Single connection point | One gateway URL serves all 150+ tools |
| 6 | Zero-downtime updates | Gateway auto-restarts crashed MCPs |

---

## 3. Current State (TypeScript)

### 3.1 Data Sources (Fragmented)
| Source | Used By | Problem |
|--------|---------|---------|
| Google Sheets | Employees, Deals, Training, Invites | 300ms+ latency, rate limits |
| SQLite (Turso) | Contacts, Quotations, Suppliers, Rooming, Portal, PDF, Features | File locks, no shared access |
| JSON files | Commissions, Manager profiles | No querying, manual updates |
| External APIs | Email (Resend), Calendar (Google), LiveKit | OK — stays as-is |

### 3.2 Existing Tool Inventory

**From `apps/web/lib/` client libraries (Category B — extract to Rust MCPs):**

| Client Library | Functions | Maps To Rust MCP |
|----------------|-----------|-----------------|
| `features-client.ts` | 9 functions | `dataxlr8-features-mcp` |
| `contact-client.ts` | 4 functions | `dataxlr8-contacts-mcp` |
| `manager-client.ts` | 5 functions | `dataxlr8-commissions-mcp` |
| `quotation-client.ts` | 3 functions | `dataxlr8-quotation-mcp` |
| `supplier-client.ts` | 5 functions | `dataxlr8-supplier-mcp` |
| `portal-client.ts` | 7 functions | `dataxlr8-portal-mcp` |
| `rooming-client.ts` | 4 functions | `dataxlr8-rooming-mcp` |
| `email.ts` | 6 functions | `dataxlr8-email-mcp` |
| `pdf-client.ts` | 5 functions | `dataxlr8-pdf-mcp` |
| `google-sheets.ts` (employees) | 5 functions | `dataxlr8-employees-mcp` |
| `google-sheets.ts` (training) | 3 functions | `dataxlr8-training-mcp` |
| `google-sheets.ts` (deals) | 2 functions | `dataxlr8-deals-mcp` |
| `google-sheets.ts` (invites) | 4 functions | `dataxlr8-employees-mcp` |
| `portal-write.ts` | 19 functions | `dataxlr8-portal-mcp` |
| `google-calendar.ts` | 3 functions | `dataxlr8-booking-mcp` |
| `anthropic.ts` | 0 functions (exports only client instance) | `dataxlr8-ai-analysis-mcp` |

**From existing Python MCPs (Category A — already have tool definitions):**

| Python MCP | Location | Tools | Purpose |
|------------|----------|-------|---------|
| `dataxlr8_deals_mcp` | `mcp-servers/dataxlr8_deals_mcp` | 14 | Deal pipeline + commissions |
| `dataxlr8_employees_mcp` | `mcp-servers/dataxlr8_employees_mcp` | 14 | Employee management + sessions |
| `dataxlr8_quotation_mcp` | `mcp-servers/dataxlr8_quotation_mcp` | 21 | Quotation CRUD + pricing |
| `dataxlr8_training_mcp` | `mcp-servers/dataxlr8_training_mcp` | 10 | Training modules + progress |
| `dataxlr8_builds_mcp` | `mcp-servers/dataxlr8_builds_mcp` | 12 | Build tracking |
| `dataxlr8_costs_mcp` | `mcp-servers/dataxlr8_costs_mcp` | 11 | Cost/revenue tracking |
| `dataxlr8_metrics_mcp` | `mcp-servers/dataxlr8_metrics_mcp` | 10 | KPIs + health checks |
| `dataxlr8_quality_gate_mcp` | `mcp-servers/dataxlr8_quality_gate_mcp` | 10 | Quality gates + audit |
| `dataxlr8_requirements_mcp` | `mcp-servers/dataxlr8_requirements_mcp` | 8 | Requirements tracking |
| `dataxlr8_testing_mcp` | `mcp-servers/dataxlr8_testing_mcp` | 10 | Test runner + coverage |
| `dataxlr8_vision_mcp` | `mcp-servers/dataxlr8_vision_mcp` | 8 | Vision + milestones |
| **Total Python MCP tools** | | **128** | |

**Note:** Python MCPs for builds, costs, metrics, quality_gate, requirements, testing, and vision are DevOps/meta tools. They are NOT part of the Rust migration (they serve the development process, not the business product). Only deals, employees, quotation, and training Python MCPs need Rust equivalents.

---

## 4. Target State (Rust)

### 4.1 Architecture

```
Claude Code / Web App
        │
        ▼
┌───────────────────────┐
│  dataxlr8-gateway-mcp │  Streamable HTTP on :3100
│  (process manager)    │  Aggregates all tools
└───────┬───────────────┘
        │ spawns via stdio
  ┌─────┼─────┬─────┬─────┬─────┐
  │     │     │     │     │     │
  ▼     ▼     ▼     ▼     ▼     ▼
[feat] [deal] [emp] [sup] [por] [...]  ← 22 Rust binaries (~7MB each)
  │     │     │     │     │     │
  └─────┴─────┴─────┴─────┴─────┘
        │
        ▼
  ┌─────────────┐
  │ PostgreSQL  │  Single DB, schema namespaces
  └─────────────┘
```

### 4.2 MCP Registry (22 MCPs + 1 Gateway)

Each MCP has its own BRD spec at `docs/mcps/{name}.md`.

| # | MCP Name | Phase | PG Schema | Tools | Source | BRD Spec |
|---|----------|-------|-----------|-------|--------|----------|
| 0 | `dataxlr8-mcp-core` | 0 | N/A | N/A (shared lib) | Rust | [core.md](mcps/core.md) |
| 1 | `dataxlr8-features-mcp` | 0 | `features` | 8 (need +1) | TS: 9 fns | [features.md](mcps/features.md) |
| 2 | `dataxlr8-contacts-mcp` | 1 | `contacts` | 5 | TS: 4 fns + 1 new | [contacts.md](mcps/contacts.md) |
| 3 | `dataxlr8-commissions-mcp` | 1 | `commissions` | 5 | TS: 5 fns | [commissions.md](mcps/commissions.md) |
| 4 | `dataxlr8-email-mcp` | 1 | `email` | 6 | TS: 6 fns | [email.md](mcps/email.md) |
| 5 | `dataxlr8-moderation-mcp` | 1 | `moderation` | TBD | **GREENFIELD** | [moderation.md](mcps/moderation.md) |
| 6 | `dataxlr8-supplier-mcp` | 2 | `suppliers` | 6 | TS: 5 fns + 1 new | [supplier.md](mcps/supplier.md) |
| 7 | `dataxlr8-quotation-mcp` | 2 | `quotations` | 21 | Py: 21 tools | [quotation.md](mcps/quotation.md) |
| 8 | `dataxlr8-rooming-mcp` | 2 | `rooming` | 5 | TS: 4 fns + 1 new | [rooming.md](mcps/rooming.md) |
| 9 | `dataxlr8-portal-mcp` | 2 | `portal` | 18 | TS: 26 fns (deduped) | [portal.md](mcps/portal.md) |
| 10 | `dataxlr8-pdf-mcp` | 2 | `pdf` | 5 | TS: 5 fns | [pdf.md](mcps/pdf.md) |
| 11 | `dataxlr8-employees-mcp` | 3 | `employees` | 14 | Py: 14 tools | [employees.md](mcps/employees.md) |
| 12 | `dataxlr8-deals-mcp` | 3 | `deals` | 14 | Py: 14 tools | [deals.md](mcps/deals.md) |
| 13 | `dataxlr8-training-mcp` | 3 | `training` | 10 | Py: 10 tools | [training.md](mcps/training.md) |
| 14 | `dataxlr8-booking-mcp` | 3 | `booking` | 3 | TS: 3 fns | [booking.md](mcps/booking.md) |
| 15 | `dataxlr8-meet-mcp` | 4 | N/A (stateless) | TBD | **GREENFIELD** | [meet.md](mcps/meet.md) |
| 16 | `dataxlr8-recording-mcp` | 4 | `recordings` | TBD | **GREENFIELD** | [recording.md](mcps/recording.md) |
| 17 | `dataxlr8-transcript-mcp` | 4 | `transcripts` | TBD | **GREENFIELD** | [transcript.md](mcps/transcript.md) |
| 18 | `dataxlr8-analytics-mcp` | 4 | `analytics` | TBD | Py: 10 tools (metrics) | [analytics.md](mcps/analytics.md) |
| 19 | `dataxlr8-calendar-mcp` | 4 | `calendar` | TBD | **GREENFIELD** (overlap w/ booking) | [calendar.md](mcps/calendar.md) |
| 20 | `dataxlr8-copilot-mcp` | 5 | `copilot` | TBD | **GREENFIELD** | [copilot.md](mcps/copilot.md) |
| 21 | `dataxlr8-notification-mcp` | 4 | `notifications` | TBD | **GREENFIELD** (overlap w/ email) | [notification.md](mcps/notification.md) |
| 22 | `dataxlr8-ai-analysis-mcp` | 5 | `ai_analysis` | 4 | [ai-analysis.md](mcps/ai-analysis.md) |
| GW | `dataxlr8-gateway-mcp` | 5 | N/A | N/A (router) | [gateway.md](mcps/gateway.md) |

---

## 5. Constraints

| Constraint | Detail |
|-----------|--------|
| **MCP SDK** | Must use `rmcp` v0.17+ (official Rust SDK) |
| **Transport** | stdio between gateway and MCPs; Streamable HTTP for gateway to clients |
| **Database** | Single PostgreSQL instance, schema-per-MCP isolation |
| **Binary size** | Target < 10MB per MCP |
| **Memory** | Target < 15MB per MCP at steady state |
| **Shared crate** | All MCPs depend on `dataxlr8-mcp-core` for DB, config, errors, logging |
| **Schema creation** | Each MCP auto-creates its schema on startup (`CREATE SCHEMA IF NOT EXISTS`) |
| **Fail-closed** | Unknown feature flags, missing data = disabled/error, never silently succeed |
| **No Claude API** | MCPs don't call Claude API — Claude calls MCPs, not the reverse (except copilot/ai-analysis) |

---

## 6. Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| Tool call latency (p99) | < 5ms |
| Cold start time | < 100ms |
| Crash recovery | Gateway auto-restarts within 1s |
| Max concurrent connections | 5 per MCP (connection pool) |
| Schema migrations | Auto-apply on startup |
| Logging | Structured JSON to stderr via `tracing` |
| Config | `.env` file + `DATABASE_URL` env var |

---

## 7. Acceptance Criteria (per MCP)

Every MCP must pass ALL of these before being marked DONE:

- [ ] `cargo build --release` succeeds with zero warnings
- [ ] Binary size < 10MB
- [ ] Schema auto-creates on first run
- [ ] Schema is idempotent (re-run doesn't break)
- [ ] All tools listed in `tools/list` with proper input schemas
- [ ] Each tool tested via stdio JSON-RPC (create, read, update, delete cycle)
- [ ] Error cases return MCP error format (not panic)
- [ ] Unknown inputs return helpful error messages
- [ ] Connects to shared PostgreSQL without interfering with other schemas
- [ ] Registered and working in Claude Code as MCP server
- [ ] STATUS.md updated with verification results

See [ACCEPTANCE.md](ACCEPTANCE.md) for the full test protocol.

---

## 8. Phase Timeline

| Phase | MCPs | Dependency | Status |
|-------|------|------------|--------|
| **Phase 0** | core + features | None | VERIFIED |
| **Phase 1** | contacts, commissions, email, moderation | Phase 0 | NOT STARTED |
| **Phase 2** | supplier, quotation, rooming, portal, pdf | Phase 1 | NOT STARTED |
| **Phase 3** | employees, deals, training, booking | Phase 2 | NOT STARTED |
| **Phase 4** | meet, recording, transcript, analytics, calendar, notification | Phase 3 | NOT STARTED |
| **Phase 5** | copilot, ai-analysis, gateway | Phase 4 | NOT STARTED |
| **Phase 6** | Web app rewiring | Phase 5 | NOT STARTED |
| **Phase 7** | Cleanup + archive TypeScript | Phase 6 | NOT STARTED |

---

## 9. Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Rust learning curve slows development | HIGH | MEDIUM | Use features-mcp as template; shared core handles boilerplate |
| Schema conflicts between MCPs | HIGH | LOW | Enforced schema namespaces; tested in acceptance criteria |
| rmcp breaking changes | MEDIUM | LOW | Pin to v0.17; test before upgrading |
| Google Sheets migration data loss | HIGH | MEDIUM | Export + verify row counts before/after |
| Gateway becomes bottleneck | MEDIUM | LOW | Gateway only routes, doesn't process; horizontal scaling possible |

---

## 10. Glossary

| Term | Definition |
|------|-----------|
| **MCP** | Model Context Protocol — standard for AI tool calling |
| **Tool** | A single callable function exposed via MCP (e.g., `create_flag`) |
| **Gateway** | The master MCP that spawns and routes to all child MCPs |
| **Schema namespace** | PostgreSQL schema (e.g., `features.*`) isolating each MCP's tables |
| **stdio** | Standard input/output — transport between gateway and child MCPs |
| **rmcp** | Official Rust SDK for MCP |
| **Fail-closed** | Default to denying/disabled when state is unknown |

---

## Appendix A: Repository Map

```
github.com/pdaxt/
├── dataxlr8-rust/              ← This repo (docs + umbrella)
├── dataxlr8-mcp-core/          ← Shared Rust crate
├── dataxlr8-features-mcp/      ← Phase 0 (DONE)
├── dataxlr8-contacts-mcp/      ← Phase 1 (TODO)
├── dataxlr8-commissions-mcp/   ← Phase 1 (TODO)
├── dataxlr8-email-mcp/         ← Phase 1 (TODO)
├── dataxlr8-moderation-mcp/    ← Phase 1 (TODO)
├── ... (18 more)
└── dataxlr8-gateway-mcp/       ← Phase 5 (TODO)
```
