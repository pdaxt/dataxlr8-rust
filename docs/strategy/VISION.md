# DataXLR8 — War Plan

_Updated: 2026-03-05. This is not a pitch deck. This is how we survive._

---

## The Situation

**We need $50K/month to survive. Starting now.**

We have:
- 8 individual Rust MCP repos (core lib + 6 business MCPs + web portal) — all compile, all on GitHub
- A working employee portal (deals pipeline, training, commissions, invites, Google OAuth)
- An AI Opportunity Scanner (chatbot that finds AI savings for businesses)
- Provider-based enrichment architecture with waterfall (Free → Freemium → Paid)
- Strategy docs, market research, Go-To-Market materials
- One founder (Pran) + a fleet of AI agents that ship as fast as a 5-8 person team

We don't have:
- A single paying client
- Cloud hosting infrastructure
- Revenue

**The clock is ticking. Here's exactly what we do.**

---

## Architecture: Individual Repos, Shared Core

Every MCP is its own repo, its own binary, its own release cycle. Connected only through `dataxlr8-mcp-core` as a path dependency.

```
github.com/pdaxt/
├── dataxlr8-mcp-core          # Shared Rust library (DB, config, errors, logging, tool helpers, types)
├── dataxlr8-features-mcp      # Feature flags, A/B testing (9 tools)
├── dataxlr8-enrichment-mcp    # Lead enrichment — THE WEDGE (12 tools)
├── dataxlr8-crm-mcp           # CRM pipeline (10 tools) — absorbs contacts-mcp
├── dataxlr8-email-mcp         # Email sending + templates (6 tools)
├── dataxlr8-commissions-mcp   # Sales commissions + leaderboard (8 tools)
├── dataxlr8-web               # Next.js employee portal
└── dataxlr8-rust              # Strategy docs, architecture decisions
```

**Why individual repos, not monorepo:**
- Each MCP deploys independently — update enrichment without touching CRM
- Clients install only what they need — no bloat
- Different release cadences — enrichment ships weekly, commissions monthly
- Clean dependency graph — mcp-core is the only shared dependency
- Each repo gets its own CI/CD, issues, releases
- Easier for future contributors to work on one MCP without the whole codebase

### Lego Block Pattern

Every MCP follows the exact same structure:

```
dataxlr8-{name}-mcp/
├── Cargo.toml          # rmcp 0.17, dataxlr8-mcp-core (path), sqlx, tokio, serde
├── src/
│   ├── main.rs         # config → logging → db → schema → server → stdio
│   ├── db.rs           # CREATE SCHEMA IF NOT EXISTS {name}; + tables
│   └── tools/
│       └── mod.rs      # types → schema helpers → build_tools() → handlers → ServerHandler
```

For enrichment-mcp (provider-based architecture):
```
dataxlr8-enrichment-mcp/
├── src/
│   ├── main.rs
│   ├── db.rs
│   ├── providers/
│   │   ├── mod.rs      # Provider trait + ProviderTier enum + registry
│   │   ├── dns.rs      # Free: MX, A, AAAA, NS, TXT via hickory-resolver
│   │   ├── smtp.rs     # Free: Email verification via SMTP handshake
│   │   ├── http.rs     # Free: Website scraping (title, meta, headers)
│   │   ├── whois.rs    # Free: Domain registration data
│   │   ├── github.rs   # Free: GitHub API (5K req/hr with token)
│   │   ├── social.rs   # Free: Social media URL patterns
│   │   ├── hunter.rs   # Freemium: Hunter.io email finder
│   │   ├── emailrep.rs # Free: Email reputation scoring
│   │   ├── fullcontact.rs  # Freemium: Person/company enrichment (stub)
│   │   └── pdl.rs      # Freemium: People Data Labs (stub)
│   ├── waterfall.rs    # Try providers cheapest-first, merge results
│   ├── merge.rs        # Multi-provider data merging with confidence scores
│   ├── cache.rs        # PostgreSQL cache with TTL
│   └── tools/
│       └── mod.rs      # Thin MCP tool wrappers calling waterfall
```

### Shared Core: `dataxlr8-mcp-core`

```rust
pub mod config;   // Config::from_env() — DATABASE_URL, LOG_LEVEL
pub mod db;       // Database::connect() — PgPool wrapper
pub mod error;    // McpError, McpResult, ErrorCode enum
pub mod logging;  // logging::init() — tracing subscriber
pub mod mcp;      // Shared tool helpers: make_schema, json_result, error_result, get_str, etc.
pub mod types;    // Shared data types: PersonData, CompanyData, EmailVerification

pub use config::Config;
pub use db::Database;
pub use error::{ErrorCode, McpError, McpResult};
pub use sqlx::PgPool;
```

The `mcp` and `types` modules eliminate 350+ lines of duplicated helper code across all MCPs.

---

## What We Sell

### Three products, three price points:

**Product 1: AI Quick Win — $5,000 (1 week delivery)**
Replace one painful manual workflow with AI agents.
- Lead enrichment automation (replace Apollo)
- Email sequence automation (replace Outreach)
- CRM setup + data migration (replace Salesforce)
- Reporting dashboard (replace spreadsheets)
- Money-back guarantee: saves 10+ hrs/week or don't pay

**Product 2: AI Core Build — $25,000-75,000 (4-6 weeks)**
Replace 3-5 SaaS tools with a unified AI system.
- Full CRM + pipeline (replaces Salesforce: $75/user/mo)
- Lead enrichment + email verification (replaces Apollo: $49/user/mo)
- Email automation + sequences (replaces Outreach: $100/user/mo)
- Custom AI agents for their specific workflows
- Everything connected, all data in one place

**Product 3: Managed Operations — $2,000-10,000/month (ongoing)**
We run and optimize the system after build.
- Monitoring, updates, new features
- New AI agents as needs evolve
- Priority support
- This is the recurring revenue that compounds

### The $50K/Month Math

```
MONTH 1-2 (RAMP):
  4 × Quick Wins         = $20,000
  1 × Core Build (start) = $25,000 (50% upfront)
  0 × Managed Ops        = $0
  TOTAL                   = $32,500  ← won't hit $50K yet, that's OK

MONTH 3-4 (STEADY STATE):
  2 × Quick Wins         = $10,000
  1 × Core Build         = $50,000 (2nd half + new start)
  3 × Managed Ops        = $12,000
  TOTAL                   = $72,000  ← now exceeding target

MONTH 6+ (COMPOUNDING):
  1 × Quick Win          = $5,000
  1 × Core Build         = $35,000
  6 × Managed Ops        = $24,000
  Cloud subscribers      = $5,000
  TOTAL                   = $69,000
```

**Key insight: Quick Wins are the engine. Every Quick Win client becomes a Core Build prospect (30% convert). Every Core Build becomes a Managed Ops client (60% convert). The pipeline compounds.**

---

## Who We Sell To

### Primary Targets (These People Are Bleeding Money)

#### 1. Recruitment & Staffing Agencies (5-50 people)

**Why them:** They spend the MOST on SaaS per employee. Apollo + LinkedIn Recruiter + Bullhorn/JobAdder + Outreach + CRM = $300-500/user/month. They live and die by lead data.

**The buyer:** Agency owner, Managing Director, Head of Operations

**The pain:**
- Paying $15K+/yr for Apollo or ZoomInfo for candidate/client sourcing
- Manual data entry between 4-5 different tools
- Sequences are manual or use expensive Outreach ($100/user/mo)
- Can't get real-time pipeline visibility without clicking through 3 dashboards

**What we build them:**
- AI agent that auto-enriches candidates from LinkedIn (replaces Apollo)
- Unified CRM with candidate + client pipeline (replaces Bullhorn: $99/user/mo)
- Automated outreach sequences (replaces Outreach)
- Daily KPI report generated automatically (replaces Tableau)

**The pitch:** "You're spending $4K/month on tools for a 10-person team. We'll replace all of it with AI agents for $5K setup + $3K/month managed. That's break-even in Month 2 and $45K/year savings after that."

#### 2. Digital Marketing / Creative Agencies (5-30 people)

**Why them:** They already sell AI to their clients but don't have the tools. They're desperate for a white-label solution. And they spend $200-400/user/month on HubSpot + Mailchimp + SEMrush + Jasper.

**The buyer:** Agency founder, Head of Client Services

**What we build them:**
- AI-powered client reporting (auto-generated weekly/monthly reports)
- Content generation pipeline (replaces Jasper)
- Lead enrichment for their clients' sales teams (replaces Apollo)
- White-label option: they resell to THEIR clients

#### 3. Real Estate Agencies (10-100 agents)

**Why them:** They use terrible CRMs (Rex, AgentBox, Reapit) that cost $200-400/agent/month. They're all about lead follow-up speed. AI can 10x their response time.

**What we build them:**
- AI agent that responds to enquiries in <60 seconds (24/7)
- Smart property matching based on buyer preferences
- Automated follow-up sequences for open home attendees
- Commission calculator + pipeline dashboard

#### 4. Professional Services (Accountants, Lawyers, Consultants — 5-50 people)

**Why them:** They track time, send invoices, manage client comms — all manually or with expensive tools. They're risk-averse but once they buy, they never leave.

#### 5. E-Commerce Businesses ($500K-10M revenue, 5-30 people)

**Why them:** They use Shopify + Klaviyo + Gorgias + inventory tools = $500-2000/month. Customer service is their biggest cost.

---

## What We Have Built

### Shipped & Compiling (All Individual Repos on GitHub)

| Component | Repo | Tools | Status |
|-----------|------|-------|--------|
| `dataxlr8-mcp-core` | pdaxt/dataxlr8-mcp-core | shared lib | compiles |
| `dataxlr8-features-mcp` | pdaxt/dataxlr8-features-mcp | 9 tools (flags, overrides, bulk check) | compiles |
| `dataxlr8-enrichment-mcp` | pdaxt/dataxlr8-enrichment-mcp | 12 tools (enrich, verify, discover) | compiles, refactoring to provider architecture |
| `dataxlr8-crm-mcp` | pdaxt/dataxlr8-crm-mcp | 10 tools (contacts, deals, pipeline) | compiles |
| `dataxlr8-email-mcp` | pdaxt/dataxlr8-email-mcp | 6 tools (send, templates, stats) | compiles |
| `dataxlr8-commissions-mcp` | pdaxt/dataxlr8-commissions-mcp | 8 tools (managers, commissions, leaderboard) | compiles |
| `dataxlr8-web` | pdaxt/dataxlr8-web | Portal (deals, training, contacts, admin) | compiles, running |
| **Total** | **7 repos** | **45 tools** | |

### Absorbing contacts-mcp into crm-mcp

`dataxlr8-contacts-mcp` has 9 tools (CRUD, search, interactions, tags) that overlap with crm-mcp's contact management. CRM is the superset. contacts-mcp will be deprecated and its unique features merged into crm-mcp.

### Must Build Next

| Priority | What | Why |
|----------|------|-----|
| P0 | mcp-core: Add `mcp.rs` + `types.rs` | Eliminate 350 lines duplicated across all MCPs |
| P0 | enrichment-mcp: Provider refactor | Waterfall architecture, pluggable data sources |
| P0 | contacts-mcp → crm-mcp merge | Remove overlap, single source of truth |
| P1 | Gateway/routing for Cloud | Auth, metering, multi-tenant |
| P1 | `dxlr8` CLI tool | Developer experience |

---

## Why Replacement Beats Connection

This is the core thesis. Get this right and everything else follows.

```
THE CONNECTOR MODEL (Composio, Glama, Pipedream):

  Your Agent → Connector → Salesforce API → Their Database
                         → Apollo API → Their Database
                         → QuickBooks API → Their Database

  STILL paying $75/user for Salesforce
  STILL paying $49/user for Apollo
  STILL paying for the connector
  Triple latency: agent → connector → API → DB → back
  Data scattered across 15 vendors
  Breaks when they change their API
  Total: $400+/user/month

THE REPLACEMENT MODEL (DataXLR8):

  Your Agent → DataXLR8 CRM MCP → YOUR database (0.2ms)
             → DataXLR8 Enrichment MCP → YOUR database (0.2ms)
             → DataXLR8 Finance MCP → YOUR database (0.2ms)

  No Salesforce license
  No Apollo license
  No connector middleware
  0.2ms direct tool calls (50x faster)
  All data in ONE place you control
  Total: $49/mo flat, no per-user pricing
```

**Stripe didn't build a "connector to PayPal." Stripe built a payment system so good developers stopped using PayPal. That's the difference between a $29M integration company and a $95B infrastructure company.**

---

## Revenue Engines

### Engine 1: Agency (Revenue from Day 1)

Sell custom AI builds using our own MCPs. $5K-200K/project.

Every agency build:
1. Battle-tests our MCPs with real business needs
2. Teaches us what businesses actually want (knowledge moat)
3. Custom features get abstracted into the platform
4. Client becomes a case study and referral source

**Target: $15K Month 1, $50K by Month 4**

### Engine 2: Cloud (Recurring from Month 2-3)

Managed MCP hosting. Developers install open-source MCPs locally, then deploy to Cloud for production.

| Tier | Price | Target Customer |
|------|-------|----------------|
| Free | $0 | Developers trying MCPs (3 MCPs, 10K calls/mo) |
| Pro | $49/mo | Small teams (10 MCPs, 500K calls/mo) |
| Team | $199/mo | Growing companies (unlimited MCPs, 5M calls/mo) |
| Enterprise | Custom | Large orgs (SSO, audit, SLA, dedicated infra) |

Plus usage-based enrichment: $0.005/lookup (vs Apollo's $0.30+)

**Target: 150 paid users at $80 avg = $12K/mo by Month 6**

### Engine 3: Data Moat (Compounds Forever from Month 3)

Enrichment lookups aggregate anonymized patterns:
- Company X queried 1000 times → we know tech stack, size, growth
- Domain Y verified 500 times → we know deliverability patterns
- More users → better enrichment → more users → better enrichment

Apollo has 275M contacts. ZoomInfo has 321M. We build this into the MCP layer. Once we have 10M lookups, the data advantage is permanent.

### Revenue Targets

| Month | Agency | Cloud | Total |
|-------|--------|-------|-------|
| 1 | $15K | $0 | $15K |
| 2 | $25K | $500 | $25.5K |
| 3 | $35K | $2K | $37K |
| 4 | $50K | $4K | $54K ← crosses $50K |
| 6 | $50K | $12K | $62K |
| 9 | $60K | $35K | $95K |
| 12 | $50K | $70K | $120K |

**Agency is the lifeline for Months 1-4. Cloud takes over by Month 12.**

---

## Competitive Position

### We don't compete with Composio. Different category.

| | Composio | DataXLR8 |
|---|---------|----------|
| What they do | Connect agents to existing SaaS APIs | Replace the SaaS entirely |
| Revenue model | Connector fees | Agency + Cloud + Data |
| Funding | $29M raised | Bootstrapped |
| Technology | Python | Rust (50x faster) |
| # of integrations | 500+ shallow wrappers | 14 deep business tools |
| Customer still pays | Salesforce + Apollo + etc. | Nothing else. Just us. |

### Who we actually replace

| Tool | Their Price | Our Price | Savings |
|------|-----------|-----------|---------|
| Salesforce CRM | $75/user/mo | $49/mo total | $700+/mo for 10 users |
| Apollo.io | $49/user/mo | $0.005/lookup | 60x cheaper |
| Outreach | $100/user/mo | Part of $49/mo | $950+/mo for 10 users |
| HubSpot | $234/user/mo | $49/mo total | $2,290+/mo for 10 users |
| QuickBooks | $80/mo | Part of $49/mo | Included |

---

## Performance Edge (This Is Real, Not Marketing)

| Metric | DataXLR8 (Rust) | Competitors (Python) |
|--------|-----------------|---------------------|
| Tool call latency | 0.2ms | ~10ms (50x slower) |
| Memory per MCP | 10MB | 110MB (11x more) |
| Binary size | 6.5MB | ~100MB (15x bigger) |
| MCPs per $5 server | 20+ | 1-2 (10x less dense) |
| Cold start | 5ms | 500ms (100x slower) |

**To match our performance, a competitor would need to rewrite their entire stack in Rust. That's 2+ years of work.**

---

## What Makes This Unassailable (6 Moats)

1. **Rust performance** — 50x faster. Can't be matched without a full rewrite.
2. **Business depth** — Deep CRM/enrichment/finance logic, not API wrappers. Comes from agency work.
3. **Data aggregation** — Every enrichment lookup improves the data. More users = better data = more users.
4. **Composability** — MCPs share `dataxlr8-mcp-core`. 3+ MCPs deployed = too good to leave.
5. **Open-source trust** — MIT licensed. Developers choose open-source over proprietary (Composio).
6. **Agency knowledge loop** — Every client build makes the MCPs better. Can't replicate without doing the work.

---

## Risks (Honest)

| Risk | What We Do About It |
|------|-------------------|
| No clients in Month 1 | Lower price to $3K. Offer free pilot. First case study > first dollar. |
| Enrichment data quality low at start | Provider-based waterfall: free sources first (DNS, WHOIS, GitHub, HTTP), escalate to freemium (Hunter, EmailRep) only when needed. Confidence scoring on every field. |
| Solo founder, limited bandwidth | AI agent team = 5-8x multiplier. Hire first person when agency revenue covers salary (Month 3-4). |
| Composio notices and pivots | They'd have to rewrite from Python to Rust AND pivot from connectors to replacements. That's 2-3 years. We'll have the data moat by then. |
| Enterprise sales too slow | Don't need enterprise. Quick Wins ($5K) + Core Builds ($25K) + Managed Ops ($3-10K/mo) gets us to $50K without a single enterprise deal. |

---

## The Endgame

In 2030, every business runs AI agents. Those agents need tools — not connectors to legacy SaaS, but native tools built for agents.

DataXLR8 IS those tools. Open-source Rust MCPs that are the CRM, the enrichment engine, the finance system. Faster, cheaper, and better than anything accessed through API wrappers.

**The business that buys a $5K Quick Win today runs on DataXLR8 forever. The developer who installs enrichment-mcp today deploys 10 MCPs on Cloud tomorrow. Every client, every MCP, every lookup makes the system better and harder to compete with.**

**But right now, today, the only thing that matters is the first client. Everything else follows from that.**

---

## Action Items (This Week)

- [ ] Update LinkedIn headline
- [ ] Build 100-person target list (50 recruitment, 50 marketing agencies)
- [ ] Send first 25 connection requests
- [x] Ship enrichment-mcp v0.1 (compiles, on GitHub, refactoring to provider architecture)
- [x] Ship crm-mcp v0.1 (compiles, on GitHub)
- [ ] Refactor mcp-core: add mcp.rs + types.rs
- [ ] Complete enrichment-mcp provider refactor
- [ ] Merge contacts-mcp into crm-mcp
- [ ] Book 3 discovery calls by Friday
- [ ] Close first client by end of Week 2

**$50K/month by Month 4. $120K/month by Month 12. This is how we survive.**
