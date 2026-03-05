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

| MCP | Repo | Tools | Status |
|-----|------|-------|--------|
| `dataxlr8-mcp-core` | pdaxt/dataxlr8-mcp-core | shared lib | compiles |
| `dataxlr8-features-mcp` | pdaxt/dataxlr8-features-mcp | 9 tools | compiles |
| `dataxlr8-enrichment-mcp` | pdaxt/dataxlr8-enrichment-mcp | 12 tools | compiles (commit 8b4e818) |
| `dataxlr8-crm-mcp` | pdaxt/dataxlr8-crm-mcp | 10 tools | compiles (commit 6f6dd62) |
| `dataxlr8-email-mcp` | pdaxt/dataxlr8-email-mcp | 6 tools | compiles |
| `dataxlr8-commissions-mcp` | pdaxt/dataxlr8-commissions-mcp | 8 tools | compiles |
| `dataxlr8-contacts-mcp` | pdaxt/dataxlr8-contacts-mcp | 9 tools | compiles (being absorbed into crm-mcp) |
| `dataxlr8-web` | pdaxt/dataxlr8-web | Portal | compiles, running |

---

## Current Sprint: Refactor + Quality

### Phase 1: mcp-core Refactor

Add shared modules to eliminate duplication across all MCPs:

- [ ] Add `src/mcp.rs` — shared tool helpers (make_schema, json_result, error_result, get_str, get_bool, get_str_array)
- [ ] Add `src/types.rs` — shared data types (PersonData, CompanyData, EmailVerification, EmailCandidate)
- [ ] Update `src/lib.rs` to export new modules
- [ ] `cargo build` — must pass
- [ ] Push to GitHub

### Phase 2: enrichment-mcp Provider Refactor

Restructure from monolithic tools/mod.rs (1306 lines) into provider-based waterfall:

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

### Phase 3: contacts-mcp → crm-mcp Merge

- [ ] Identify unique features in contacts-mcp (interactions, tags)
- [ ] Add interactions + tags tables to crm-mcp schema
- [ ] Add interaction + tag tools to crm-mcp
- [ ] Verify crm-mcp covers all contacts-mcp functionality
- [ ] `cargo build` — must pass
- [ ] Push to GitHub
- [ ] Archive contacts-mcp repo

### Phase 4: Update All MCPs to Use Shared Helpers

- [ ] features-mcp: import helpers from mcp-core instead of local copies
- [ ] enrichment-mcp: import helpers from mcp-core
- [ ] crm-mcp: import helpers from mcp-core
- [ ] email-mcp: import helpers from mcp-core
- [ ] commissions-mcp: import helpers from mcp-core
- [ ] All: `cargo build` passes
- [ ] All: push to GitHub

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
- [x] enrichment-mcp: 12 tools implemented (1306 lines)
- [x] enrichment-mcp: `cargo build` passes
- [x] enrichment-mcp: Pushed to GitHub (pdaxt/dataxlr8-enrichment-mcp, commit 8b4e818)
- [x] crm-mcp: Cargo.toml + src structure
- [x] crm-mcp: Schema setup (db.rs)
- [x] crm-mcp: 10 tools implemented (1024 lines)
- [x] crm-mcp: `cargo build` passes
- [x] crm-mcp: Pushed to GitHub (pdaxt/dataxlr8-crm-mcp, commit 6f6dd62)
- [x] BUILD-PLAN.md created and pushed to GitHub

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
