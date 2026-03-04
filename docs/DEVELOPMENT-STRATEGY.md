# DataXLR8 Development Strategy

_Full-scale parallel development plan for building AI-native business MCPs in Rust._

_Updated: 2026-03-04_

---

## Current State

### Built and Working (Rust)

| Repo | Tools | Status |
|------|-------|--------|
| `dataxlr8-mcp-core` | — | Shared crate: config, db, error, logging |
| `dataxlr8-features-mcp` | 8 | Production-ready, 3 commits |
| `dataxlr8-contacts-mcp` | 9 | Built, 1 commit |
| `dataxlr8-commissions-mcp` | 8 | Built, 1 commit |
| `dataxlr8-email-mcp` | 6 | Built, 1 commit |
| `dataxlr8-web` | — | Axum + Askama, Google OAuth, team portal started |

### To Be Built (Rust)

| Category | MCPs | Tools | Priority |
|----------|------|-------|----------|
| Revenue MCPs | enrichment, crm, sales, gateway | ~38 | P0 |
| Expansion MCPs | finance, scraper, intelligence | ~24 | P1 |
| Internal MCPs | deals, employees, training, supplier, quotation, portal, rooming, booking | ~55 | P1-P2 |
| Meeting MCPs | meet, recording, transcript, analytics, calendar, copilot, moderation, notification | ~65 | P2-P3 |
| Web App | Public site, employee portal, client portal, training | — | P0 |

### To Be Replaced

| Current | Language | Replacement |
|---------|----------|-------------|
| 12 Python MCPs in `mcp-servers/` | Python | Rust MCPs (above) |
| 8 TypeScript MCPs in `dataxlr8/mcps/` | TypeScript | Rust MCPs (above) |
| Google Sheets backend | API calls | PostgreSQL |
| Next.js web app | TypeScript | Rust Axum web app |

---

## Architecture

### The Stack

```
┌─────────────────────────────────────────────────────┐
│  dataxlr8-web (Rust/Axum)                           │
│  Port 3001 — Marketing + Employee Portal + Client   │
│  Templates: Askama | Auth: Google OAuth | DB: PG    │
└────────────────────┬────────────────────────────────┘
                     │ calls tools via gateway
┌────────────────────▼────────────────────────────────┐
│  dataxlr8-gateway-mcp (Rust)                        │
│  Port 3100 — Spawns all MCPs, routes tool calls     │
│  Single HTTPS endpoint for all 150+ tools           │
└──┬──────┬──────┬──────┬──────┬──────┬───────────────┘
   │      │      │      │      │      │
┌──▼──┐┌──▼──┐┌──▼──┐┌──▼──┐┌──▼──┐┌──▼──┐
│enrich││ crm ││sales││email││fin  ││ ... │  22 Rust MCPs
│ mcp  ││ mcp ││ mcp ││ mcp ││ mcp ││     │  ~6.5MB each
└──┬───┘└──┬──┘└──┬──┘└──┬──┘└──┬──┘└─────┘
   │       │      │      │      │
   └───────┴──────┴──────┴──────┘
                  │
         ┌───────▼────────┐
         │  PostgreSQL     │
         │  dataxlr8 DB   │
         │  Schema/domain  │
         └────────────────┘
```

### PostgreSQL Schema Strategy

Single database `dataxlr8`, one schema per domain:

```sql
-- Revenue MCPs (build first)
CREATE SCHEMA IF NOT EXISTS enrichment;  -- person, company, email verification
CREATE SCHEMA IF NOT EXISTS crm;         -- contacts, deals, pipeline, activities
CREATE SCHEMA IF NOT EXISTS sales;       -- sequences, proposals, scripts
CREATE SCHEMA IF NOT EXISTS finance;     -- invoices, payments, expenses, tax

-- Internal operations (migrate from Google Sheets)
CREATE SCHEMA IF NOT EXISTS employees;   -- team members, sessions, roles
CREATE SCHEMA IF NOT EXISTS training;    -- modules, progress, assessments
CREATE SCHEMA IF NOT EXISTS deals;       -- sales pipeline, activities
CREATE SCHEMA IF NOT EXISTS commissions; -- earnings, payouts

-- Already built
CREATE SCHEMA IF NOT EXISTS features;    -- feature flags
CREATE SCHEMA IF NOT EXISTS contacts;    -- contact management
CREATE SCHEMA IF NOT EXISTS email;       -- templates, sequences, tracking

-- Web app
CREATE SCHEMA IF NOT EXISTS web;         -- sessions, client accounts, auth
CREATE SCHEMA IF NOT EXISTS portal;      -- client projects, deliverables, comments

-- Supporting
CREATE SCHEMA IF NOT EXISTS supplier;    -- supplier rates, rooms
CREATE SCHEMA IF NOT EXISTS quotation;   -- quotes, pricing, versions
CREATE SCHEMA IF NOT EXISTS rooming;     -- room allocations
CREATE SCHEMA IF NOT EXISTS booking;     -- calendar bookings
CREATE SCHEMA IF NOT EXISTS scraper;     -- scrape cache, job results
CREATE SCHEMA IF NOT EXISTS intelligence; -- competitive intel, monitoring
```

Each MCP creates its own tables in `db::setup_schema()`. No MCP reads another's tables directly — cross-MCP communication goes through tool calls via the gateway.

---

## Parallel Development with Tmux

### 4 Screens × 4 Windows × 3 Panes = 48 Agents

See [TMUX-LAYOUT.md](TMUX-LAYOUT.md) for exact pane assignments.

**Screen 1 — `claude6`: MCP Development**
| Window | Pane 0 | Pane 1 | Pane 2 |
|--------|--------|--------|--------|
| W0 | enrichment-mcp (build) | enrichment-mcp (test) | enrichment-mcp (data sources) |
| W1 | crm-mcp (build) | crm-mcp (test) | crm-mcp (schema) |
| W2 | gateway-mcp (build) | gateway-mcp (test) | gateway-mcp (routing) |
| W3 | sales-mcp (build) | finance-mcp (build) | scraper-mcp (build) |

**Screen 2 — `claude6-screen2`: Web + Portals**
| Window | Pane 0 | Pane 1 | Pane 2 |
|--------|--------|--------|--------|
| W0 | Public website (routes) | Public website (templates) | Public website (CSS/JS) |
| W1 | Employee portal (routes) | Employee portal (templates) | Employee portal (test) |
| W2 | Client portal (routes) | Client portal (templates) | Client portal (test) |
| W3 | Training module (routes) | Training module (content) | Training module (test) |

**Screen 3 — `claude6-screen3`: Testing + CI/CD**
| Window | Pane 0 | Pane 1 | Pane 2 |
|--------|--------|--------|--------|
| W0 | MCP integration tests | Cross-MCP tests | Test DB management |
| W1 | Playwright E2E | API endpoint tests | Visual regression |
| W2 | GitHub Actions CI | Release automation | Binary distribution |
| W3 | Performance benchmarks | Load testing | Monitoring |

**Screen 4 — `claude6-screen4`: Infrastructure + Ops**
| Window | Pane 0 | Pane 1 | Pane 2 |
|--------|--------|--------|--------|
| W0 | PostgreSQL migrations | Data migration (Sheets→PG) | Backup strategy |
| W1 | Gateway configuration | Gateway monitoring | Process management |
| W2 | Chrome Extension | Chrome Extension test | Chrome Web Store |
| W3 | Cloud hosting (GCP) | DNS/CDN (Cloudflare) | Deployment scripts |

### Agent Coordination Rules

1. **Each agent owns ONE repo at a time** — no conflicts possible
2. **Lock `dataxlr8-mcp-core` before editing** — shared dependency
3. **Push after every working feature** — small commits, always buildable
4. **Test before commit** — `cargo test && cargo build --release`
5. **No agent modifies another agent's MCP** — communicate via gateway tool calls
6. **Use `multi-agent` MCP** for registration, file locks, and knowledge sharing

---

## Build Order (Revenue-First)

### Wave 1 — Week 1-2 (Ship or Die)

These 4 workstreams run in parallel across Screen 1 and Screen 2:

#### Agent A: `dataxlr8-enrichment-mcp` (THE WEDGE)

**Why first:** Clearbit died April 2025. Immediate vacuum. Every developer needs enrichment. Usage-based revenue. Data compounds with every lookup.

```
Tools (12):
  enrich_person      — name + company → email, phone, LinkedIn, title
  enrich_company     — domain → size, funding, tech stack, key people
  verify_email       — email → deliverable, catch-all, disposable check
  domain_emails      — domain → all discoverable email addresses
  search_people      — query → matching people from aggregate data
  reverse_ip         — IP → company identification
  bulk_enrich        — CSV/list → enriched records (batch)
  tech_stack         — domain → technologies used
  funding_tracker    — company → funding history
  hiring_signals     — company → open positions, growth rate
  social_profiles    — person/company → all social accounts
  news_mentions      — company → recent news
```

**Data sources (waterfall):** LinkedIn scraping → GitHub API → Google search → DNS/WHOIS → MX records → SMTP verification → public records

**Schema:** `enrichment.persons`, `enrichment.companies`, `enrichment.emails`, `enrichment.lookups` (audit trail)

**Revenue:** $0.005/lookup on Cloud, aggregate data improves with every user

#### Agent B: `dataxlr8-crm-mcp` (Salesforce Replacement)

**Why second:** Every agency client needs CRM. Every AI SDR needs contacts + deals.

```
Tools (10):
  create_contact     — create with custom fields per tenant
  search_contacts    — full-text search with filters, pagination
  upsert_deal        — create/update deal in pipeline
  move_deal          — move between stages with notes
  log_activity       — log calls, emails, meetings
  get_pipeline       — pipeline overview with stage counts
  assign_contact     — assign to team member
  create_task        — follow-up task linked to contact/deal
  import_contacts    — bulk import from CSV/JSON
  export_contacts    — export with filters
```

**Schema:** `crm.contacts`, `crm.deals`, `crm.activities`, `crm.tasks`, `crm.pipeline_stages`

#### Agent C: `dataxlr8-gateway-mcp` (Infrastructure)

**Why parallel:** Cloud hosting needs the gateway. All MCPs connect through it.

```
Tools (5):
  health_check       — status of all deployed MCPs
  list_tools         — available tools across all MCPs
  usage_stats        — tool call counts, latency percentiles
  rate_limit_status  — current rate limit state per API key
  config_reload      — hot-reload tenant configuration
```

**Architecture:** Reads `dataxlr8.toml`, spawns MCPs as child processes (stdio), exposes Streamable HTTP on port 3100, namespaces tools (`enrichment.enrich_person`, `crm.create_contact`), auto-restarts crashed MCPs.

#### Agent D: `dataxlr8-web` Public Website Revamp

**Why parallel:** Need to sell the product. Website must reflect new "replacement not connection" positioning.

**Routes to build:**
```
/              — Hero: "Replace your SaaS stack. $49/mo."
/pricing       — Free / Pro $49 / Team $199 / Enterprise custom
/docs          — Quick start, MCP catalog, API reference
/blog          — Technical content (benchmarks, tutorials, case studies)
/about         — Team, mission, open-source commitment
/scanner       — AI Opportunity Scanner (free lead gen tool)
```

**Tech:** Axum routes + Askama templates + TailwindCSS via CDN + HTMX for interactivity

### Wave 2 — Week 3-4 (Expand)

#### Agent A: `dataxlr8-sales-mcp`
```
Tools (10): generate_opener, generate_sequence, handle_objection,
  generate_proposal, meeting_prep, call_script, follow_up,
  linkedin_message, ab_test_subject, pipeline_forecast
```

#### Agent B: `dataxlr8-finance-mcp`
```
Tools (8): create_invoice, record_payment, track_expense,
  tax_report, profit_loss, balance_sheet, recurring_invoice, tax_calculation
```
**Tax advantage:** Multi-jurisdiction tax (GST/VAT/sales tax) built-in.

#### Agent C: `dataxlr8-scraper-mcp`
```
Tools (6): scrape_page, scrape_linkedin, detect_tech_stack,
  monitor_changes, extract_pricing, scrape_job_boards
```

#### Agent D: Employee Portal + Client Portal

**Employee Portal (`/team/*`) — new routes:**
```
/team/deals           — Deal pipeline (Kanban board)
/team/training        — Training modules with progress
/team/training/:slug  — Module content (video, text, quiz)
/team/resources       — Templates, docs, guides
/team/research        — Market research tools
/team/settings        — Profile settings
/team/status          — System status dashboard
```

**Client Portal (`/client/*`) — build from scratch:**
```
/client/login          — Client auth (API key or email magic link)
/client                — Project dashboard
/client/projects/:id   — Project detail, deliverables, timeline
/client/invoices       — Invoice history, payment status
/client/support        — Support tickets
```

### Wave 3 — Month 2 (Scale)

Remaining MCPs from the existing Python/TypeScript inventory, plus:
- intelligence-mcp, content-mcp, analytics-mcp (new revenue MCPs)
- Chrome Extension (enrichment on LinkedIn hover)
- Cloud hosting alpha (deploy gateway + MCPs on GCP)
- Training module content migration from Google Sheets

### Wave 4 — Month 3+ (Platform)

- Meeting domain MCPs (meet, recording, transcript, calendar, copilot)
- documents-mcp, auth-mcp, hr-mcp, notifications-mcp
- Enterprise features (SSO, RBAC, audit logs)
- Community contribution framework

---

## Git-First Workflow

### Repository Structure

Each MCP = its own GitHub repo under `pdaxt/`:

```
pdaxt/dataxlr8-mcp-core          # Shared crate (DONE)
pdaxt/dataxlr8-features-mcp      # DONE
pdaxt/dataxlr8-contacts-mcp      # DONE
pdaxt/dataxlr8-commissions-mcp   # DONE
pdaxt/dataxlr8-email-mcp         # DONE
pdaxt/dataxlr8-enrichment-mcp    # Wave 1
pdaxt/dataxlr8-crm-mcp           # Wave 1
pdaxt/dataxlr8-gateway-mcp       # Wave 1
pdaxt/dataxlr8-sales-mcp         # Wave 2
pdaxt/dataxlr8-finance-mcp       # Wave 2
pdaxt/dataxlr8-scraper-mcp       # Wave 2
pdaxt/dataxlr8-web               # Website + Portals
pdaxt/dataxlr8-rust              # Docs, strategy, specs
... (remaining MCPs)
```

### Per-MCP Workflow

```bash
# 1. Scaffold
./scripts/scaffold-mcp.sh enrichment enrichment

# 2. Initialize git
cd ~/Projects/dataxlr8-enrichment-mcp
git init && git add -A && git commit -m "Scaffold enrichment-mcp"

# 3. Create GitHub repo
gh repo create pdaxt/dataxlr8-enrichment-mcp --private --source=.

# 4. Implement (follow dataxlr8-features-mcp as template)
#    - src/db.rs → CREATE TABLE statements
#    - src/tools/mod.rs → tool definitions + handlers

# 5. Test
cargo test
cargo build --release
./scripts/test-mcp.sh ./target/release/dataxlr8-enrichment-mcp

# 6. Commit and push
git add -A && git commit -m "feat(enrichment): implement 12 tools" && git push

# 7. Tag release
git tag v0.1.0 && git push --tags
```

### Commit Convention

```
<type>(<scope>): <message>

Types: feat, fix, test, docs, refactor, perf, ci
Scope: mcp name or 'core' or 'web' or 'gateway'

Examples:
  feat(enrichment): add enrich_person waterfall lookup
  fix(core): handle connection pool exhaustion gracefully
  test(crm): add pipeline stage transition tests
  docs(strategy): update execution plan with dev orchestration
  perf(gateway): reduce tool routing overhead to <50μs
  ci(enrichment): add GitHub Actions workflow
```

### Branch Strategy

For MCP repos (small, focused):
- `main` — always buildable, push directly for solo work
- `feature/xxx` — for larger features or when multiple agents touch same repo

For `dataxlr8-web` (larger, shared):
- `main` — production
- `develop` — integration
- `feature/public-site` — marketing pages
- `feature/employee-portal` — employee portal expansion
- `feature/client-portal` — client portal build
- `feature/training` — training modules

---

## Testing Strategy

### Level 1: Unit Tests (Per MCP)

Every tool handler gets tested:

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use sqlx::PgPool;

    #[sqlx::test]
    async fn test_create_contact(pool: PgPool) {
        setup_schema(&pool).await.unwrap();
        let server = CrmMcpServer::new(Database::from_pool(pool));

        let args = serde_json::json!({
            "name": "Jane Smith",
            "email": "jane@acme.com",
            "company": "Acme Corp"
        });

        let result = server.handle_create_contact(args).await;
        assert!(result.is_ok());
    }
}
```

**Target:** Every tool has at least 1 happy path + 1 error case test.

### Level 2: Integration Tests (Cross-MCP)

Test complete workflows that span multiple MCPs:

```rust
// Test: Enrichment → CRM → Email flow
#[tokio::test]
async fn test_sdr_workflow() {
    let enrichment = EnrichmentMcpServer::new(db.clone());
    let crm = CrmMcpServer::new(db.clone());
    let email = EmailMcpServer::new(db.clone());

    // 1. Enrich a person
    let person = enrichment.enrich_person("Jane Smith", "Acme Corp").await;
    assert!(person.email.is_some());

    // 2. Create contact in CRM
    let contact = crm.create_contact(person.into()).await;
    assert!(contact.id.is_some());

    // 3. Send email (mock SMTP)
    let sent = email.send_email(contact.email, "Subject", "Body").await;
    assert!(sent.is_ok());
}
```

### Level 3: E2E Tests (Web App)

Playwright tests for the web app:

```
# Test employee portal
playwright.browser_navigate("http://localhost:3001/team/login")
playwright.browser_verify_text_visible("Sign in with Google")
playwright.browser_click("Sign in with Google button")
# ... OAuth flow ...
playwright.browser_verify_text_visible("Dashboard")

# Test client portal
playwright.browser_navigate("http://localhost:3001/client/login")
playwright.browser_fill_form([{ref: "api_key", value: "test_key"}])
playwright.browser_click("Login")
playwright.browser_verify_text_visible("Projects")
```

### Level 4: Performance Tests

Every MCP binary must meet:

| Metric | Target | How to Test |
|--------|--------|-------------|
| Tool call latency | <1ms (db) / <0.2ms (compute) | `hyperfine` or built-in timing |
| Memory footprint | <15MB | `ps aux` during test |
| Binary size | <7MB | `ls -la target/release/` |
| Cold start | <10ms | Time from spawn to first tool call |

### CI/CD (GitHub Actions)

Per-MCP repo `.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: dataxlr8
          POSTGRES_PASSWORD: dataxlr8
          POSTGRES_DB: dataxlr8_test
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with:
          components: clippy, rustfmt

      - name: Format check
        run: cargo fmt --check

      - name: Clippy
        run: cargo clippy -- -D warnings

      - name: Test
        run: cargo test
        env:
          DATABASE_URL: postgres://dataxlr8:dataxlr8@localhost:5432/dataxlr8_test

      - name: Build release
        run: cargo build --release

      - name: Check binary size
        run: |
          SIZE=$(stat -f%z target/release/dataxlr8-*-mcp 2>/dev/null || stat -c%s target/release/dataxlr8-*-mcp)
          echo "Binary size: $((SIZE / 1024 / 1024))MB"
          [ $SIZE -lt 10485760 ] || echo "WARNING: Binary exceeds 10MB"

      - uses: actions/upload-artifact@v4
        with:
          name: binary
          path: target/release/dataxlr8-*-mcp

  release:
    if: startsWith(github.ref, 'refs/tags/')
    needs: check
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: x86_64-unknown-linux-gnu
          - os: macos-latest
            target: aarch64-apple-darwin
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - run: cargo build --release --target ${{ matrix.target }}
      - uses: softprops/action-gh-release@v2
        with:
          files: target/${{ matrix.target }}/release/dataxlr8-*-mcp
```

---

## Website Revamp Plan

### Tech Stack

```
Backend:  Axum 0.8 (Rust)
Templates: Askama (compile-time checked)
CSS:      TailwindCSS (via CDN initially, build step later)
JS:       HTMX (for interactivity without a JS framework)
Auth:     Google OAuth (employees) + API key/magic link (clients)
DB:       PostgreSQL via dataxlr8-mcp-core
```

### Route Map

```
PUBLIC ROUTES (no auth):
  GET  /                    → Marketing homepage
  GET  /pricing             → Pricing page
  GET  /docs                → Documentation hub
  GET  /docs/:section       → Doc section (getting-started, api, mcps)
  GET  /blog                → Blog listing
  GET  /blog/:slug          → Blog post
  GET  /about               → About page
  GET  /scanner             → AI Opportunity Scanner
  POST /api/scanner/analyze → Scanner API endpoint
  GET  /open-source         → GitHub repos, stars, downloads

EMPLOYEE PORTAL (Google OAuth):
  GET  /team/login          → Login page (EXISTS)
  GET  /team                → Dashboard (EXISTS)
  GET  /team/deals          → Deal pipeline (NEW)
  GET  /team/commissions    → Commissions (EXISTS)
  GET  /team/leaderboard    → Leaderboard (EXISTS)
  GET  /team/contacts       → Contacts (EXISTS)
  GET  /team/training       → Training modules (NEW)
  GET  /team/training/:slug → Module content (NEW)
  GET  /team/resources      → Templates & docs (NEW)
  GET  /team/research       → Market research (NEW)
  GET  /team/admin          → Admin panel (EXISTS)
  GET  /team/settings       → Profile settings (NEW)
  GET  /team/status         → System status (NEW)

CLIENT PORTAL (API key / magic link):
  GET  /client/login        → Client login (NEW)
  GET  /client              → Project dashboard (NEW)
  GET  /client/projects/:id → Project detail (NEW)
  GET  /client/invoices     → Invoice history (NEW)
  GET  /client/support      → Support / chat (NEW)

API ENDPOINTS:
  GET  /api/auth/google          → Start OAuth (EXISTS)
  GET  /api/auth/google/callback → OAuth callback (EXISTS)
  GET  /api/auth/logout          → Logout (EXISTS)
  POST /api/client/auth          → Client auth (NEW)
  GET  /api/team/contacts/search → Contact search (EXISTS)
  POST /api/team/contacts        → Create contact (EXISTS)
  POST /api/team/admin/features/* → Feature flags (EXISTS)
  GET  /api/health               → Health check (NEW)
```

### Template Structure

```
templates/
├── base.html              # Base layout (nav, footer, meta)
├── home.html              # Marketing homepage
├── pricing.html           # Pricing page
├── docs/
│   ├── index.html         # Docs hub
│   └── section.html       # Doc section template
├── blog/
│   ├── index.html         # Blog listing
│   └── post.html          # Blog post template
├── about.html             # About page
├── scanner.html           # AI Scanner
├── team_base.html         # Team layout (sidebar nav)
├── team/
│   ├── dashboard.html     # EXISTS
│   ├── deals.html         # NEW — Kanban pipeline
│   ├── commissions.html   # EXISTS
│   ├── leaderboard.html   # EXISTS
│   ├── contacts.html      # EXISTS
│   ├── training/
│   │   ├── index.html     # Module list
│   │   └── module.html    # Module content
│   ├── resources.html     # NEW
│   ├── research.html      # NEW
│   ├── admin_features.html # EXISTS
│   ├── settings.html      # NEW
│   └── status.html        # NEW
├── client/
│   ├── login.html         # NEW
│   ├── dashboard.html     # NEW
│   ├── project.html       # NEW
│   ├── invoices.html      # NEW
│   └── support.html       # NEW
├── login.html             # Employee login (EXISTS)
└── partials/
    ├── nav.html           # Top nav
    ├── sidebar.html       # Team sidebar
    └── footer.html        # Footer
```

---

## Data Migration Plan

### Google Sheets → PostgreSQL

| Sheet | Target Schema | Migration Strategy |
|-------|---------------|-------------------|
| Employees | `employees.*` | Export → CSV → `COPY` into PG |
| Training_Modules | `training.modules` | Export → seed script |
| Training_Progress | `training.progress` | Export → seed script |
| Deals | `deals.deals` | Export → CSV → `COPY` |
| Deal_Activities | `deals.activities` | Export → CSV → `COPY` |
| Commissions | `commissions.entries` | Already in PG via commissions-mcp |
| Resources | `web.resources` | Export → seed script |
| Invites | `employees.invites` | Export → seed script |

**Migration script:** `scripts/migrate-sheets.sh`
1. Use `google-cloud` MCP to read each sheet
2. Transform to SQL INSERT statements
3. Execute against PostgreSQL
4. Verify row counts match

---

## Multi-Agent Coordination

### Registration Protocol

Each agent on session start:
```
multi-agent.agent_register(
  pane_id="claude6:0.0",
  project="dataxlr8",
  task="Building enrichment-mcp"
)
```

### File Lock Protocol

Before editing shared code (`dataxlr8-mcp-core`):
```
multi-agent.lock_acquire(pane_id="...", files=["dataxlr8-mcp-core/src/lib.rs"])
# ... make changes ...
multi-agent.lock_release(pane_id="...")
```

### Knowledge Sharing

When an agent discovers something useful:
```
multi-agent.kb_add(
  pane_id="...",
  project="dataxlr8",
  category="pattern",
  title="rmcp ServerHandler pattern",
  content="Use Arc<serde_json::Map> for tool schemas, not raw Value"
)
```

### Deregistration

On session end:
```
multi-agent.agent_deregister(pane_id="claude6:0.0")
```

---

## Key Decisions

| Decision | Choice | Why |
|----------|--------|-----|
| One repo per MCP | Yes | Independent deployment, clear ownership, no coupling |
| Single PostgreSQL DB | Yes | One backup, one connection string, schema isolation |
| Axum for web | Yes | Same Rust ecosystem, shares dataxlr8-mcp-core |
| Askama templates | Yes | Compile-time checked, no JS framework needed |
| HTMX for interactivity | Yes | Server-rendered + dynamic without SPA complexity |
| TailwindCSS via CDN | Start | Move to build step when design stabilizes |
| Google OAuth (employees) | Yes | Already working, team uses Google Workspace |
| API key (clients) | Yes | Simple, no OAuth dance for external clients |

---

## Success Metrics

### Week 2 (Wave 1 complete)

- [ ] enrichment-mcp: 12 tools, passing tests, published on GitHub
- [ ] crm-mcp: 10 tools, passing tests, published on GitHub
- [ ] gateway-mcp: routes to all built MCPs, Streamable HTTP working
- [ ] dataxlr8.com: new homepage live with replacement positioning
- [ ] All 4 repos: CI/CD green, binaries on GitHub Releases

### Week 4 (Wave 2 complete)

- [ ] sales-mcp, finance-mcp, scraper-mcp: built and tested
- [ ] Employee portal: deals, training, resources pages
- [ ] Client portal: login, dashboard, project view
- [ ] Cloud alpha: gateway deployed on GCP, first external user

### Month 2 (Wave 3)

- [ ] 10+ Rust MCPs published, 50+ tools available
- [ ] Chrome Extension beta on Chrome Web Store
- [ ] Training modules migrated from Google Sheets to PostgreSQL
- [ ] 3 agency clients using the platform

### Month 3 (Wave 4)

- [ ] Full meeting domain MCPs ported from TypeScript
- [ ] Enterprise features started (SSO, audit logs)
- [ ] 30 Cloud paying users
- [ ] Product Hunt launch

---

## Quick Reference

| What | Where |
|------|-------|
| Strategy docs | `dataxlr8-rust/docs/strategy/` |
| MCP specs | `dataxlr8-rust/docs/mcps/` |
| Architecture | `dataxlr8-rust/docs/ARCHITECTURE.md` |
| Migration plan | `dataxlr8-rust/docs/PLAN.md` |
| Scaffold script | `dataxlr8-rust/scripts/scaffold-mcp.sh` |
| Test script | `dataxlr8-rust/scripts/test-mcp.sh` |
| Tmux layout | `dataxlr8-rust/docs/TMUX-LAYOUT.md` |
| Web app | `dataxlr8-web/` |
| Shared crate | `dataxlr8-mcp-core/` |
| Template MCP | `dataxlr8-features-mcp/` (follow this pattern) |
