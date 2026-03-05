# DataXLR8 Feature Blueprint — AI-Native Business MCPs

_Updated: 2026-03-05_

## What We Build: Business Tools, Not Connectors

Composio connects agents to 500+ existing APIs. DataXLR8 builds the actual business tools agents use — the CRM, enrichment engine, finance system. Not wrappers. The implementations.

**Architecture:** Individual repos. Each MCP is its own GitHub repo, its own binary, its own release cycle. Connected only through `dataxlr8-mcp-core`.

---

## The MCP Catalog

### Currently Shipped (Compiling on GitHub)

#### `dataxlr8-mcp-core` — Shared Library

**Repo:** pdaxt/dataxlr8-mcp-core
**Status:** Compiles. Needs `mcp.rs` + `types.rs` added.

Currently provides:
```rust
pub mod config;   // Config::from_env() — DATABASE_URL, LOG_LEVEL
pub mod db;       // Database::connect() — PgPool wrapper
pub mod error;    // McpError, McpResult, ErrorCode enum
pub mod logging;  // logging::init() — tracing subscriber
```

Planned additions:
```rust
pub mod mcp;      // Shared tool helpers: make_schema(), json_result(), error_result(), get_str(), get_bool(), get_str_array()
pub mod types;    // Shared data types: PersonData, CompanyData, EmailVerification, EmailCandidate
```

The `mcp` module eliminates ~350 lines of duplicated helper code across all MCPs. Every MCP currently copies the same 7 helper functions.

#### `dataxlr8-features-mcp` — Feature Flags & A/B Testing

**Repo:** pdaxt/dataxlr8-features-mcp | **Status:** Compiles | **Tools:** 9

| Tool | What It Does |
|------|-------------|
| `check_flag` | Check if feature flag is enabled for user/context |
| `create_flag` | Create new feature flag |
| `update_flag` | Update flag configuration |
| `delete_flag` | Remove feature flag |
| `list_flags` | List all flags with status |
| `set_override` | Override flag for specific user/context |
| `remove_override` | Remove override |
| `check_flags_bulk` | Check multiple flags at once |
| `seed_page_flags` | Seed flags for a page |

#### `dataxlr8-enrichment-mcp` — THE WEDGE

**Repo:** pdaxt/dataxlr8-enrichment-mcp | **Status:** Compiles, provider refactor in progress
**Replaces:** Apollo ($49-149/user), ZoomInfo ($15K+/yr), Clearbit (dead), Lusha ($49-79/user)
**Revenue:** $0.005/lookup on Cloud, agency builds, data moat

| Tool | What It Does | Data Sources |
|------|-------------|-------------|
| `enrich_person` | Name + company → email, title, LinkedIn | DNS MX + pattern gen + SMTP |
| `enrich_company` | Domain → size, tech stack, socials | HTTP headers, DNS, meta tags |
| `verify_email` | Email → deliverable, catch-all, disposable | SMTP handshake, MX records |
| `domain_emails` | Domain → all discoverable emails | Pattern detection + SMTP verify |
| `search_people` | Query → matching people | FTS on cached lookups |
| `reverse_domain` | IP/domain → company info | WHOIS, reverse DNS |
| `bulk_enrich` | List → enriched records | All sources, batched |
| `tech_stack` | Domain → technologies used | HTTP headers, JS libs, DNS |
| `hiring_signals` | Domain → job postings, growth | Careers page analysis |
| `social_profiles` | Person/company → social URLs | Cross-platform patterns |
| `enrichment_stats` | Usage statistics | Query counts |
| `cache_lookup` | Check cached data | Direct cache query |

**Provider Architecture (refactoring):**
```
providers/
├── mod.rs           # Provider trait + ProviderTier enum (Free/Freemium/Paid)
├── dns.rs           # Free: MX, A, AAAA, NS, TXT via hickory-resolver
├── smtp.rs          # Free: SMTP handshake verification
├── http.rs          # Free: Website scraping, meta tags, headers
├── whois.rs         # Free: Domain registration data
├── github.rs        # Free: GitHub API (5K req/hr, needs GITHUB_TOKEN)
├── social.rs        # Free: Social media URL pattern generation
├── hunter.rs        # Freemium: Hunter.io email finder (HUNTER_API_KEY)
├── emailrep.rs      # Free: Email reputation scoring
├── fullcontact.rs   # Freemium: Person/company enrichment (stub)
└── pdl.rs           # Freemium: People Data Labs (stub)
```

**Waterfall:** Try providers cheapest-first (Free → Freemium → Paid). Only escalate if confidence < 0.7. Merge results from multiple providers with confidence scoring.

**The data moat:** Every lookup feeds aggregate data. More users → better results → more users.

#### `dataxlr8-crm-mcp` — Replaces Salesforce

**Repo:** pdaxt/dataxlr8-crm-mcp | **Status:** Compiles
**Replaces:** Salesforce ($25-318/user), HubSpot CRM ($15-234/user), Pipedrive ($14-99/user)
**Schema:** `crm.*` (contacts, deals, activities, tasks)

| Tool | What It Does |
|------|-------------|
| `create_contact` | Create contact with custom fields |
| `search_contacts` | Full-text search with filters |
| `upsert_deal` | Create/update deal in pipeline |
| `move_deal` | Move deal between stages |
| `log_activity` | Log calls, emails, meetings |
| `get_pipeline` | Pipeline overview with stage counts |
| `assign_contact` | Assign contact to team member |
| `create_task` | Follow-up task linked to contact/deal |
| `import_contacts` | Bulk import from JSON |
| `export_contacts` | Export with filters |

**Note:** `dataxlr8-contacts-mcp` (9 tools) is being absorbed into crm-mcp. CRM is the superset with deals, activities, and tasks on top of contact management.

#### `dataxlr8-email-mcp` — Email Automation

**Repo:** pdaxt/dataxlr8-email-mcp | **Status:** Compiles
**Replaces:** SendGrid ($20-90/mo), Mailchimp ($13-350/mo)

| Tool | What It Does |
|------|-------------|
| `send_email` | Send email with template variables, tracking |
| `create_template` | Create reusable email template |
| `list_templates` | List available templates |
| `get_template` | Get template details |
| `email_stats` | Delivery and open stats |
| `bulk_send` | Send to list with personalization |

#### `dataxlr8-commissions-mcp` — Sales Commissions

**Repo:** pdaxt/dataxlr8-commissions-mcp | **Status:** Compiles

| Tool | What It Does |
|------|-------------|
| `create_manager` | Register commission manager |
| `record_commission` | Record commission on deal |
| `get_commission_summary` | Manager's commission total |
| `get_leaderboard` | Ranked leaderboard |
| `pay_commission` | Mark commission as paid |
| `manager_stats` | Manager performance stats |
| `list_managers` | All managers |
| `get_manager` | Manager details |

#### `dataxlr8-contacts-mcp` — DEPRECATED (merging into crm-mcp)

**Repo:** pdaxt/dataxlr8-contacts-mcp | **Status:** Compiles, being absorbed

9 tools for contact CRUD, search, interactions, tags. Overlaps with crm-mcp's contact management. Unique features (interactions, tags) will be merged into crm-mcp.

---

### Tier 2: Expansion MCPs (Months 3-6) — Planned

#### `dataxlr8-finance-mcp` — Replaces QuickBooks + Xero

**Replaces:** QuickBooks ($30-200/mo), Xero ($15-78/mo) | **Priority:** P1

| Tool | What It Does |
|------|-------------|
| `create_invoice` | Generate invoice with tax calculation |
| `record_payment` | Record payment against invoice |
| `track_expense` | Log expense with category and receipt |
| `tax_report` | Generate tax return data (GST/VAT/sales tax) |
| `profit_loss` | P&L statement for period |
| `balance_sheet` | Balance sheet snapshot |
| `recurring_invoice` | Set up auto-generated invoices |
| `tax_calculation` | Calculate GST/VAT/sales tax by jurisdiction |

#### `dataxlr8-sales-mcp` — Replaces SalesLoft + Outreach

**Replaces:** Outreach ($100/user), SalesLoft ($75/user) | **Priority:** P1

| Tool | What It Does |
|------|-------------|
| `generate_opener` | Personalized cold email opener |
| `generate_sequence` | 5-7 email drip sequence |
| `handle_objection` | Context-aware objection response |
| `generate_proposal` | Full proposal from deal context |
| `meeting_prep` | Research + talking points |
| `call_script` | Phone call script with objection handling |
| `follow_up` | Context-aware follow-up email |
| `linkedin_message` | Personalized LinkedIn outreach |
| `ab_test_subject` | Generate subject line variants |
| `pipeline_forecast` | AI-driven pipeline forecast |

#### `dataxlr8-scraper-mcp` — Data Collection Engine

**Replaces:** Apify ($49-499/mo), ScrapingBee ($49-249/mo) | **Priority:** P1

| Tool | What It Does |
|------|-------------|
| `scrape_page` | Extract structured data from any URL |
| `scrape_linkedin` | LinkedIn profile/company data |
| `detect_tech_stack` | Domain → technologies |
| `monitor_changes` | Track page changes over time |
| `extract_pricing` | Extract pricing from competitor pages |
| `scrape_job_boards` | Company → open positions |

### Tier 3: Platform MCPs (Months 6-12) — Planned

| MCP | Tools | Replaces | Priority |
|-----|-------|----------|----------|
| `intelligence-mcp` | 10 | Crayon ($30K+/yr), Similarweb ($149+/mo) | P2 |
| `content-mcp` | 10 | Jasper ($49-125/user), Copy.ai | P2 |
| `analytics-mcp` | 6 | Tableau, Metabase | P2 |
| `documents-mcp` | 6 | DocuSign, Google Docs API | P3 |
| `calendar-mcp` | 5 | Calendly, Google Calendar | P3 |
| `auth-mcp` | 6 | Auth0, Clerk | P3 |
| `hr-mcp` | 8 | BambooHR, Gusto | P3 |
| `notifications-mcp` | 4 | OneSignal, Firebase | P3 |

---

## Composability: Why 3 MCPs > 3 Separate Tools

### Example: AI SDR Workflow

```
Agent: "Find and email the VP of Sales at Acme Corp"

Step 1: enrichment-mcp.search_people({title: "VP Sales", company: "Acme"})
  → Found: Jane Smith, jane@acme.com, VP Sales, Acme Corp

Step 2: enrichment-mcp.enrich_company({domain: "acme.com"})
  → Acme: 500 employees, Series C, React + AWS stack, growing 40% YoY

Step 3: crm-mcp.create_contact({name: "Jane Smith", email: "jane@acme.com", ...})
  → Contact created in your CRM

Step 4: sales-mcp.generate_opener({person: jane, company: acme})
  → "Jane, I noticed Acme just closed Series C — congratulations..."

Step 5: email-mcp.send_email({to: "jane@acme.com", subject: ..., body: ...})
  → Email sent, tracking pixel added

Step 6: crm-mcp.log_activity({contact: jane, type: "email", notes: ...})
  → Activity logged, follow-up task created for 3 days

TOTAL TIME: <2 seconds
TOTAL COST: $0.02 (enrichment lookups + compute)
```

**With Salesforce ($75/user) + Apollo ($49/user) + Outreach ($100/user) = $224/user/month and 10x more latency.**

With DataXLR8: $49/mo total. 0.2ms per tool call. All data in one place.

---

## `dxlr8` CLI — Planned

```
USAGE:
    dxlr8 <COMMAND>

COMMANDS:
    init        Initialize a new project
    add         Add MCPs to your project
    run         Run MCPs locally (dev mode)
    deploy      Deploy to DataXLR8 Cloud
    status      Check deployment status
    logs        Stream logs from deployed MCPs
    config      Manage MCP configurations
    auth        Login, API keys
```

---

## Tool Count Summary

| Category | MCPs | Tools | Status |
|----------|------|-------|--------|
| **Shipped** | 6 (core, features, enrichment, crm, email, commissions) | 45 | Compiling |
| Enrichment & Data | 3 (enrichment, scraper, intelligence) | 28 | 12 shipped, 16 planned |
| CRM & Sales | 3 (crm, sales, email) | 26 | 16 shipped, 10 planned |
| Finance & Ops | 3 (finance, analytics, documents) | 20 | Planned |
| Content & Comm | 3 (content, calendar, notifications) | 19 | Planned |
| Infrastructure | 2 (gateway, auth) | 11 | Planned |
| Internal | 2 (features, commissions) | 17 | Shipped |
| **Total** | **14** | **104** | |
