# DataXLR8 Build Plan — Multi-Agent Execution

_Updated: 2026-03-05_

## Objective

Build and ship the two P0 MCPs that unlock revenue from recruitment agencies:
1. **enrichment-mcp** (12 tools) — THE WEDGE. Replaces Apollo/ZoomInfo/Clearbit.
2. **crm-mcp** (10 tools) — Replaces Salesforce/HubSpot/Pipedrive.

Then use them + existing email-mcp to start outreach to Sydney recruitment agencies.

---

## Architecture

Every MCP follows the lego block pattern from `dataxlr8-features-mcp`:

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
- `dataxlr8-mcp-core` for DB pool, config, error types
- `rmcp` v0.17 for MCP protocol
- Binary < 7MB, startup < 0.2ms, memory < 10MB

---

## What Exists (Compiling)

| MCP | Tools | Status |
|-----|-------|--------|
| `dataxlr8-mcp-core` | shared lib | compiles |
| `dataxlr8-features-mcp` | 9 tools (flags, overrides, bulk check) | compiles |
| `dataxlr8-contacts-mcp` | 9 tools (CRUD, search, interactions, tags) | compiles |
| `dataxlr8-email-mcp` | 6 tools (send, templates, stats) | compiles |
| `dataxlr8-commissions-mcp` | 8 tools (managers, commissions, leaderboard) | compiles |
| `dataxlr8-web` | Portal (deals, training, contacts, admin) | compiles, running |

---

## What To Build

### 1. `dataxlr8-enrichment-mcp` — THE WEDGE

**Replaces:** Apollo ($49-149/user), ZoomInfo ($15K+/yr), Clearbit (dead), Lusha ($49-79/user)

**Schema:** `enrichment.*`

```sql
CREATE SCHEMA IF NOT EXISTS enrichment;
CREATE TABLE IF NOT EXISTS enrichment.lookups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lookup_type TEXT NOT NULL,
    query JSONB NOT NULL,
    result JSONB,
    source TEXT,
    cached_at TIMESTAMPTZ DEFAULT now(),
    expires_at TIMESTAMPTZ DEFAULT now() + interval '7 days'
);
```

**Tools:**

| # | Tool | What It Does | Data Source |
|---|------|-------------|------------|
| 1 | `enrich_person` | Name + company → email, title, LinkedIn | DNS MX + pattern gen + SMTP |
| 2 | `enrich_company` | Domain → size, tech stack, socials | HTTP headers, DNS, meta tags |
| 3 | `verify_email` | Email → deliverable/catch-all/disposable | SMTP handshake, MX lookup |
| 4 | `domain_emails` | Domain → discoverable emails | Pattern detection + SMTP |
| 5 | `search_people` | Query → matching cached people | FTS on lookups |
| 6 | `reverse_domain` | IP/domain → company info | WHOIS, reverse DNS |
| 7 | `bulk_enrich` | List → enriched records | Batch enrich |
| 8 | `tech_stack` | Domain → technologies | HTTP, JS, DNS |
| 9 | `hiring_signals` | Domain → job postings, growth | Careers page analysis |
| 10 | `social_profiles` | Person/company → social URLs | Cross-platform patterns |
| 11 | `enrichment_stats` | Usage statistics | Query counts |
| 12 | `cache_lookup` | Check cached data | Direct cache query |

**No external API keys needed.** Uses DNS, SMTP, HTTP, WHOIS, embedded disposable domain list.

**Dependencies:** `reqwest`, `hickory-resolver` (DNS/MX), SMTP via raw TCP

### 2. `dataxlr8-crm-mcp` — Salesforce Replacement

**Replaces:** Salesforce ($25-318/user), HubSpot ($15-234/user), Pipedrive ($14-99/user)

**Schema:** `crm.*` (contacts, deals, activities, tasks)

**Tools:**

| # | Tool | What It Does |
|---|------|-------------|
| 1 | `create_contact` | Create contact with custom fields |
| 2 | `search_contacts` | Full-text search with filters |
| 3 | `upsert_deal` | Create/update deal in pipeline |
| 4 | `move_deal` | Move deal between stages |
| 5 | `log_activity` | Log calls, emails, meetings |
| 6 | `get_pipeline` | Pipeline overview with stage counts |
| 7 | `assign_contact` | Assign contact to team member |
| 8 | `create_task` | Follow-up task linked to contact/deal |
| 9 | `import_contacts` | Bulk import from JSON |
| 10 | `export_contacts` | Export with filters |

---

## Build Status

- [x] enrichment-mcp: Cargo.toml + src structure
- [x] enrichment-mcp: Schema setup (db.rs)
- [x] enrichment-mcp: 12 tools implemented (1282 lines)
- [x] enrichment-mcp: `cargo build` passes (37MB binary)
- [x] enrichment-mcp: Pushed to GitHub (pdaxt/dataxlr8-enrichment-mcp, commit 8b4e818)
- [ ] enrichment-mcp: QA tested
- [x] crm-mcp: Cargo.toml + src structure
- [x] crm-mcp: Schema setup (db.rs)
- [x] crm-mcp: 10 tools implemented (1024 lines)
- [x] crm-mcp: `cargo build` passes (24MB binary)
- [x] crm-mcp: Pushed to GitHub (pdaxt/dataxlr8-crm-mcp, commit 6f6dd62)
- [ ] crm-mcp: QA tested
- [ ] Outreach: Templates created in email-mcp
- [ ] Outreach: 50 Sydney recruitment agencies enriched
- [ ] Outreach: Contacts loaded into crm-mcp
- [ ] Outreach: First batch sent

---

## Multi-Agent Execution

| Agent | Location | Task |
|-------|----------|------|
| Coordinator | screen1.pane3 | Orchestrate, monitor, update GitHub |
| Dev A | screen10.pane1 | Build enrichment-mcp |
| Dev B | screen10.pane2 | Build crm-mcp |
| QA | screen10.pane3 | Test both MCPs after build |

Dev A and Dev B run in parallel. QA spawns after both compile.

---

## Revenue Target

$50K/month from recruitment agencies:
- 10 agencies × $5K/month = $50K
- Sell enrichment + CRM + email automation as a bundle
- First 3 clients via Sydney network + cold outreach
