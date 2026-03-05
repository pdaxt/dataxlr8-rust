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

## What Exists (All Compiling, All on GitHub)

| MCP | Repo | Tools | Commit | Status |
|-----|------|-------|--------|--------|
| `dataxlr8-mcp-core` | pdaxt/dataxlr8-mcp-core | shared lib (config, db, error, logging, mcp helpers, types) | e4060c6 | compiles |
| `dataxlr8-features-mcp` | pdaxt/dataxlr8-features-mcp | 9 tools | b46d94f | compiles |
| `dataxlr8-enrichment-mcp` | pdaxt/dataxlr8-enrichment-mcp | 12 tools | 2b55e6f | compiles (3 warnings) |
| `dataxlr8-crm-mcp` | pdaxt/dataxlr8-crm-mcp | 12 tools (merged contacts) | 6ce23ee | compiles |
| `dataxlr8-email-mcp` | pdaxt/dataxlr8-email-mcp | 6 tools | 1640e5e | compiles (2 warnings) |
| `dataxlr8-commissions-mcp` | pdaxt/dataxlr8-commissions-mcp | 8 tools | 1d9dc69 | compiles (1 warning) |
| `dataxlr8-devtools-mcp` | pdaxt/dataxlr8-devtools-mcp | 20 tools | 3720c59 | compiles |
| `dataxlr8-contacts-mcp` | pdaxt/dataxlr8-contacts-mcp | 9 tools | 1181301 | DEPRECATED (merged into crm-mcp) |
| `dataxlr8-web` | pdaxt/dataxlr8-web | Portal | — | compiles, running |
| **Total** | **9 repos** | **67 tools** (excl. deprecated contacts-mcp) | | |

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
