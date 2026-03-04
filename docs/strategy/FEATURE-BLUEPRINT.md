# DataXLR8 Feature Blueprint — AI-Native Business MCPs

_Updated: 2026-03-04_

## What We Build: Business Tools, Not Connectors

Composio connects agents to 500+ existing APIs. DataXLR8 builds the actual business tools agents use — the CRM, enrichment engine, finance system. Not wrappers. The implementations.

---

## The MCP Catalog (What Each Replaces)

### Tier 1: Revenue MCPs (Build First — Months 1-3)

#### `dataxlr8-enrichment-mcp` — THE WEDGE

**Replaces:** Apollo ($49-149/user), ZoomInfo ($15K+/yr), Clearbit (dead), Lusha ($49-79/user)
**Revenue:** $0.005/lookup on Cloud, agency builds, data moat
**Priority:** P0 — ship in Week 2

| Tool | What It Does | Data Sources |
|------|-------------|-------------|
| `enrich_person` | Name + company → email, phone, LinkedIn, title | LinkedIn, GitHub, Google, public records |
| `enrich_company` | Domain → size, funding, tech stack, key people, socials | Website analysis, DNS, Crunchbase-like, job boards |
| `verify_email` | Email → deliverable, catch-all, disposable check | SMTP verification, MX records, pattern detection |
| `domain_emails` | Domain → all discoverable email addresses | Pattern detection + SMTP verification |
| `search_people` | Query (title, company, location) → matching people | Aggregated data from all enrichment lookups |
| `reverse_ip` | IP → company identification | IP-to-ASN mapping, WHOIS |
| `bulk_enrich` | CSV/list → enriched records | All sources, batched |
| `tech_stack` | Domain → technologies used | HTTP headers, JS libraries, DNS records |
| `funding_tracker` | Company → funding history, investors | Public data aggregation |
| `hiring_signals` | Company → open positions, growth rate | Job board scraping |
| `social_profiles` | Person/company → all social accounts | Cross-platform search |
| `news_mentions` | Company → recent news, press releases | News aggregation |

**The data moat:** Every lookup feeds aggregate data. More users → better results → more users.

#### `dataxlr8-crm-mcp` — Replaces Salesforce

**Replaces:** Salesforce ($25-318/user), HubSpot CRM ($15-234/user), Pipedrive ($14-99/user)
**Revenue:** Agency builds (every client needs CRM), Cloud hosting
**Priority:** P0 — ship in Week 3-4

| Tool | What It Does |
|------|-------------|
| `create_contact` | Create contact with custom fields per business |
| `search_contacts` | Full-text search with filters, pagination |
| `upsert_deal` | Create/update deal in pipeline |
| `move_deal` | Move deal between stages with notes |
| `log_activity` | Log calls, emails, meetings against contacts/deals |
| `get_pipeline` | Pipeline overview with stage counts and values |
| `assign_contact` | Assign contact to team member |
| `create_task` | Create follow-up task linked to contact/deal |
| `import_contacts` | Bulk import from CSV/JSON |
| `export_contacts` | Export with filters to CSV/JSON |

**Agent-native advantage:** Agents don't need to navigate Salesforce's 500 UI settings. `upsert_deal` in 0.2ms vs Salesforce API in 200ms.

#### `dataxlr8-email-mcp` — Replaces Outreach + SendGrid

**Replaces:** Outreach ($100/user), SalesLoft ($75/user), SendGrid ($20-90/mo), Mailchimp ($13-350/mo)
**Revenue:** Agency builds, Cloud hosting
**Priority:** P0 — ship in Week 3-4

| Tool | What It Does |
|------|-------------|
| `send_email` | Send email with template variables, tracking |
| `create_template` | Create reusable email template |
| `create_sequence` | Multi-step email sequence with delays |
| `track_opens` | Track email opens and clicks |
| `manage_unsubscribes` | Handle unsubscribe requests, compliance |
| `bulk_send` | Send to list with personalization |

#### `dataxlr8-gateway-mcp` — Infrastructure

**Purpose:** Single HTTPS endpoint routing to all MCPs, auth, metering
**Priority:** P0 — needed for Cloud

| Tool | What It Does |
|------|-------------|
| `health_check` | Status of all deployed MCPs |
| `list_tools` | Available tools across all MCPs |
| `usage_stats` | Tool call counts, latency percentiles |
| `rate_limit_status` | Current rate limit state per API key |
| `config_reload` | Hot-reload tenant configuration |

### Tier 2: Expansion MCPs (Months 3-6)

#### `dataxlr8-finance-mcp` — Replaces QuickBooks + Tally

**Replaces:** QuickBooks ($30-200/mo), Xero ($15-78/mo), Tally (India-specific)
**Revenue:** Agency (India-specific builds with GST)
**Priority:** P1

| Tool | What It Does |
|------|-------------|
| `create_invoice` | Generate invoice with tax calculation |
| `record_payment` | Record payment against invoice |
| `track_expense` | Log expense with category and receipt |
| `gst_report` | Generate GST return data (India) |
| `profit_loss` | P&L statement for period |
| `balance_sheet` | Balance sheet snapshot |
| `recurring_invoice` | Set up auto-generated invoices |
| `tax_calculation` | Calculate GST/VAT/sales tax by jurisdiction |

**India advantage:** GST compliance built-in. QuickBooks doesn't handle Indian tax well. Tally has no AI. We're the only AI-native finance tool with Indian tax compliance.

#### `dataxlr8-sales-mcp` — Replaces SalesLoft + Outreach

**Replaces:** Outreach ($100/user), SalesLoft ($75/user), Lemlist ($59/user)
**Revenue:** Agency builds + Cloud
**Priority:** P1

| Tool | What It Does |
|------|-------------|
| `generate_opener` | Personalized cold email opener from enriched data |
| `generate_sequence` | 5-7 email drip sequence for a persona |
| `handle_objection` | Context-aware objection response |
| `generate_proposal` | Full proposal from deal context |
| `meeting_prep` | Research + talking points for upcoming meeting |
| `call_script` | Phone call script with objection handling |
| `follow_up` | Context-aware follow-up email |
| `linkedin_message` | Personalized LinkedIn outreach |
| `ab_test_subject` | Generate subject line variants |
| `pipeline_forecast` | AI-driven pipeline forecast |

#### `dataxlr8-scraper-mcp` — Data Collection Engine

**Replaces:** Apify ($49-499/mo), ScrapingBee ($49-249/mo)
**Revenue:** Supports enrichment-mcp + intelligence-mcp
**Priority:** P1

| Tool | What It Does |
|------|-------------|
| `scrape_page` | Extract structured data from any URL |
| `scrape_linkedin` | LinkedIn profile/company data |
| `detect_tech_stack` | Domain → technologies (HTTP headers, JS, DNS) |
| `monitor_changes` | Track page changes over time |
| `extract_pricing` | Extract pricing from competitor pages |
| `scrape_job_boards` | Company → open positions from Indeed/LinkedIn |

### Tier 3: Platform MCPs (Months 6-12)

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
  → "Jane, I noticed Acme just closed Series C — congratulations.
     With 40% YoY growth, your sales team must be scaling fast..."

Step 5: email-mcp.send_email({to: "jane@acme.com", subject: ..., body: ...})
  → Email sent, tracking pixel added

Step 6: crm-mcp.log_activity({contact: jane, type: "email", notes: ...})
  → Activity logged, follow-up task created for 3 days

TOTAL TIME: <2 seconds
TOTAL COST: $0.02 (enrichment lookups + compute)
```

**Try doing this with Salesforce ($75/user) + Apollo ($49/user) + Outreach ($100/user) + Composio connector. That's $224/user/month and 10x more latency.**

With DataXLR8: $49/mo total. 0.2ms per tool call. All data in one place.

---

## `dxlr8` CLI

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

EXAMPLES:
    dxlr8 init my-business
    dxlr8 add enrichment-mcp crm-mcp email-mcp
    dxlr8 run                          # Local development
    dxlr8 deploy --cloud               # Deploy to Cloud
    dxlr8 logs enrichment-mcp --follow # Stream logs
```

---

## Shared Core: `dataxlr8-mcp-core`

Every MCP depends on this shared crate:

```rust
pub mod db;       // PostgreSQL pool (sqlx), compile-time checked queries
pub mod config;   // TOML config per tenant, hot-reload
pub mod error;    // Standardized errors: NotFound, Unauthorized, RateLimit
pub mod logging;  // Structured tracing
pub mod auth;     // API key + JWT validation
pub mod metrics;  // Prometheus: tool_call_duration, tool_call_count
pub mod cache;    // Redis caching for enrichment results
```

This shared library means every MCP:
- Connects to the same PostgreSQL database
- Uses the same auth system
- Logs in the same format
- Reports the same metrics
- Works with the same configuration

**Composability comes from shared infrastructure.** Not from glue code.

---

## Tool Count Summary

| Category | MCPs | Tools | Revenue Source |
|----------|------|-------|---------------|
| Enrichment & Data | 3 (enrichment, scraper, intelligence) | 28 | Cloud (per-lookup) + Agency |
| CRM & Sales | 3 (crm, sales, email) | 26 | Agency + Cloud |
| Finance & Ops | 3 (finance, analytics, documents) | 20 | Agency (India) |
| Content & Comm | 3 (content, calendar, notifications) | 19 | Cloud |
| Infrastructure | 2 (gateway, auth) | 11 | Cloud platform |
| **Total** | **14** | **104** | |
