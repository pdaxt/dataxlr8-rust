# DataXLR8 Build Plan — Multi-Agent Execution

_Updated: 2026-03-05_

## Objective

Ship the P0 MCPs and refactor for production quality. Then start outreach to Sydney recruitment agencies.

---

## Architecture

**Individual repos.** Every MCP is its own GitHub repo, connected through `dataxlr8-mcp-core` as a path dependency.

```
dataxlr8-{name}-mcp/
├── Cargo.toml          # rmcp 0.17, dataxlr8-mcp-core (path), sqlx, tokio, serde
├── src/
│   ├── main.rs         # config → logging → db → schema → server → stdio
│   ├── db.rs           # CREATE SCHEMA IF NOT EXISTS {name}; + tables
│   └── tools/
│       └── mod.rs      # types → schema helpers → build_tools() → handlers → ServerHandler
```

- Schema-per-MCP namespace in PostgreSQL
- `dataxlr8-mcp-core` for DB pool, config, error types, shared helpers, shared types
- `rmcp` v0.17 for MCP protocol
- Binary < 7MB, startup < 0.2ms, memory < 10MB

---

## What Exists (All Compiling, All on GitHub, All Branch Protected)

| # | MCP | Repo | Tools | Status |
|---|-----|------|-------|--------|
| 1 | `dataxlr8-mcp-core` | pdaxt/dataxlr8-mcp-core | shared lib | compiles |
| 2 | `dataxlr8-features-mcp` | pdaxt/dataxlr8-features-mcp | 9 tools | compiles |
| 3 | `dataxlr8-enrichment-mcp` | pdaxt/dataxlr8-enrichment-mcp | 12 tools | compiles |
| 4 | `dataxlr8-crm-mcp` | pdaxt/dataxlr8-crm-mcp | 12 tools | compiles |
| 5 | `dataxlr8-email-mcp` | pdaxt/dataxlr8-email-mcp | 6 tools | compiles |
| 6 | `dataxlr8-commissions-mcp` | pdaxt/dataxlr8-commissions-mcp | 8 tools | compiles |
| 7 | `dataxlr8-devtools-mcp` | pdaxt/dataxlr8-devtools-mcp | 20 tools | compiles |
| 8 | `dataxlr8-pipeline-mcp` | pdaxt/dataxlr8-pipeline-mcp | 8 tools | compiles |
| 9 | `dataxlr8-scoring-mcp` | pdaxt/dataxlr8-scoring-mcp | 8 tools | compiles |
| 10 | `dataxlr8-analytics-mcp` | pdaxt/dataxlr8-analytics-mcp | 8 tools | compiles |
| 11 | `dataxlr8-audit-mcp` | pdaxt/dataxlr8-audit-mcp | 8 tools | compiles |
| 12 | `dataxlr8-campaign-mcp` | pdaxt/dataxlr8-campaign-mcp | 8 tools | compiles |
| 13 | `dataxlr8-dashboard-mcp` | pdaxt/dataxlr8-dashboard-mcp | 8 tools | compiles |
| 14 | `dataxlr8-import-mcp` | pdaxt/dataxlr8-import-mcp | 8 tools | compiles |
| 15 | `dataxlr8-integrations-mcp` | pdaxt/dataxlr8-integrations-mcp | 8 tools | compiles |
| 16 | `dataxlr8-invoicing-mcp` | pdaxt/dataxlr8-invoicing-mcp | 8 tools | compiles |
| 17 | `dataxlr8-notes-mcp` | pdaxt/dataxlr8-notes-mcp | 8 tools | compiles |
| 18 | `dataxlr8-notifications-mcp` | pdaxt/dataxlr8-notifications-mcp | 8 tools | compiles |
| 19 | `dataxlr8-reporting-mcp` | pdaxt/dataxlr8-reporting-mcp | 8 tools | compiles |
| 20 | `dataxlr8-scheduler-mcp` | pdaxt/dataxlr8-scheduler-mcp | 8 tools | compiles |
| 21 | `dataxlr8-search-mcp` | pdaxt/dataxlr8-search-mcp | 8 tools | compiles |
| 22 | `dataxlr8-talent-mcp` | pdaxt/dataxlr8-talent-mcp | 10 tools | compiles |
| 23 | `dataxlr8-templates-mcp` | pdaxt/dataxlr8-templates-mcp | 8 tools | compiles |
| 24 | `dataxlr8-webhooks-mcp` | pdaxt/dataxlr8-webhooks-mcp | 8 tools | compiles |
| | `dataxlr8-contacts-mcp` | pdaxt/dataxlr8-contacts-mcp | 9 tools | DEPRECATED |
| | `dataxlr8-web` | pdaxt/dataxlr8-web | Portal | running |
| | **Total** | **24 repos** | **~211 tools** | **all compile** |

---

## Current Sprint: Refactor + Quality

### Phase 1: mcp-core Refactor — DONE

Added shared modules to eliminate duplication across all MCPs:

- [x] Add `src/mcp.rs` — shared tool helpers (make_schema, json_result, error_result, get_str, get_bool, get_str_array)
- [x] Add `src/types.rs` — shared data types (PersonData, CompanyData, EmailVerification, EmailCandidate)
- [x] Update `src/lib.rs` to export new modules
- [x] `cargo build` — passes
- [x] Push to GitHub (commit e4060c6)

### Phase 2: enrichment-mcp Provider Refactor

Restructure from monolithic tools/mod.rs into provider-based waterfall:

- [ ] Create `src/providers/mod.rs` — Provider trait + ProviderTier enum
- [ ] Extract DNS logic → `src/providers/dns.rs`
- [ ] Extract SMTP logic → `src/providers/smtp.rs`
- [ ] Extract HTTP scraping → `src/providers/http.rs`
- [ ] Add `src/providers/whois.rs` — domain registration data
- [ ] Add `src/providers/github.rs` — GitHub API (GITHUB_TOKEN env var)
- [ ] Add `src/providers/social.rs` — social URL patterns
- [ ] Add `src/providers/hunter.rs` — Hunter.io API (HUNTER_API_KEY env var)
- [ ] Add `src/providers/emailrep.rs` — email reputation
- [ ] Stub `src/providers/fullcontact.rs` + `src/providers/pdl.rs`
- [ ] Create `src/waterfall.rs` — orchestration (Free → Freemium → Paid)
- [ ] Create `src/merge.rs` — multi-provider data merging with confidence
- [ ] Create `src/cache.rs` — PostgreSQL cache extract
- [ ] Slim down `src/tools/mod.rs` — thin wrappers calling waterfall
- [ ] `cargo build` — must pass
- [ ] Push to GitHub

### Phase 3: contacts-mcp → crm-mcp Merge — DONE

- [x] Identified unique features in contacts-mcp (interactions, tags)
- [x] Added `add_interaction` + `tag_contact` tools to crm-mcp (now 12 tools total)
- [x] crm-mcp covers all contacts-mcp functionality
- [x] `cargo build` — passes
- [x] Pushed to GitHub (commit 6ce23ee, PR #1 merged)
- [x] contacts-mcp marked as DEPRECATED

### Phase 4: Update All MCPs to Use Shared Helpers — DONE

- [x] features-mcp: imports `make_schema, empty_schema, json_result, error_result, get_str, get_bool, get_str_array` from mcp-core
- [x] enrichment-mcp: imports `empty_schema, error_result, get_i64, get_str, get_str_array, json_result, make_schema` from mcp-core
- [x] crm-mcp: imports `error_result, get_f64, get_i64, get_str, get_str_array, json_result, make_schema` from mcp-core
- [x] email-mcp: imports `make_schema, empty_schema, json_result, error_result, get_str, get_i64, get_str_array` from mcp-core
- [x] commissions-mcp: imports `make_schema, empty_schema, json_result, error_result, get_str, get_f64, get_i64` from mcp-core
- [x] All: `cargo build` passes
- [x] All: pushed to GitHub (via use-shared-helpers PRs)

### Phase 5: QA

- [ ] enrichment-mcp: `verify_email test@gmail.com` → deliverable
- [ ] enrichment-mcp: `verify_email fake@nonexistent.xyz` → undeliverable
- [ ] enrichment-mcp: `enrich_company google.com` → returns data
- [ ] crm-mcp: create contact → search → create deal → get pipeline roundtrip
- [ ] email-mcp: send test email
- [ ] All MCPs: start binary with DATABASE_URL, verify MCP handshake

---

## Previous Build Status (Completed)

- [x] enrichment-mcp: Cargo.toml + src structure
- [x] enrichment-mcp: Schema setup (db.rs)
- [x] enrichment-mcp: 12 tools implemented
- [x] enrichment-mcp: `cargo build` passes
- [x] enrichment-mcp: Pushed to GitHub (pdaxt/dataxlr8-enrichment-mcp, commit 2b55e6f)
- [x] crm-mcp: Cargo.toml + src structure
- [x] crm-mcp: Schema setup (db.rs)
- [x] crm-mcp: 12 tools implemented (10 original + 2 merged from contacts-mcp)
- [x] crm-mcp: `cargo build` passes
- [x] crm-mcp: Pushed to GitHub (pdaxt/dataxlr8-crm-mcp, commit 6ce23ee)
- [x] BUILD-PLAN.md created and pushed to GitHub
- [x] mcp-core: mcp.rs + types.rs added (commit e4060c6)
- [x] devtools-mcp: 20 tools built and pushed (commit 3720c59)
- [x] Agent prompts created in docs/prompts/ (_pattern.md, enrichment-mcp.md, crm-mcp.md, devtools-mcp.md)
- [x] Phase 1 (mcp-core refactor) completed
- [x] Phase 3 (contacts-mcp → crm-mcp merge) completed
- [x] Phase 4 (shared helpers across all MCPs) completed

---

## After Refactor: Outreach

- [ ] Register all MCPs in Claude Code config
- [ ] Use enrichment-mcp to find emails for 50 Sydney recruitment agencies
- [ ] Use crm-mcp to load contacts with `create_contact`
- [ ] Use email-mcp to create cold outreach templates
- [ ] Track pipeline with `upsert_deal` in crm-mcp
- [ ] Request AWS SES production access (currently sandbox: 200/day)

---

## Multi-Agent Execution

| Agent | Location | Task |
|-------|----------|------|
| Coordinator | screen1.pane3 | Orchestrate, monitor, update GitHub |
| Dev A | screen10.pane1 | enrichment-mcp provider refactor |
| Dev B | screen10.pane2 | Available for next task |
| QA | screen10.pane3 | Test all MCPs after refactor |

---

## Revenue Target

$50K/month from recruitment agencies:
- 10 agencies x $5K/month = $50K
- Sell enrichment + CRM + email automation as a bundle
- First 3 clients via Sydney network + cold outreach
