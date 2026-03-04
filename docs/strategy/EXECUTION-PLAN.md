# DataXLR8 Execution Plan — All Engines From Day 1

_Updated: 2026-03-04_

## The Rule: Nothing Is Sequential. Everything Runs In Parallel.

```
WRONG:  Build MCPs → Launch Cloud → Find Clients → Make Money (12+ months to revenue)
RIGHT:  Find Clients + Build MCPs + Launch Cloud → Money from Week 1
```

---

## Current State

### What Exists
- [x] `dataxlr8-mcp-core` — Shared Rust library (DB pool, config, errors, logging)
- [x] `dataxlr8-features-mcp` — 8 tools, 6.5MB binary, proof of concept
- [x] Next.js web app with BusinessAnalyzer chatbot (AI Opportunity Scanner)
- [x] Slack webhook for high-intent lead detection
- [x] Internal operations web app (team, deals, commissions, suppliers)
- [x] Strategy docs and market research
- [x] Google Sheets operational database
- [x] Resend email integration

### What's Missing
- [ ] enrichment-mcp (THE WEDGE — Clearbit replacement)
- [ ] crm-mcp, email-mcp, finance-mcp, sales-mcp (core business MCPs)
- [ ] `dxlr8` CLI tool
- [ ] DataXLR8 Cloud hosting infrastructure
- [ ] Chrome Extension
- [ ] First 3 paying agency clients
- [ ] Open-source MCPs on GitHub/crates.io

---

## Month 1: Revenue + Foundation (Target: $15K MRR)

### Week 1: First Revenue + Start Building

**Agency (Revenue):**
- [ ] Send 50 LinkedIn + cold email messages: "$5K AI Quick Win — replace spreadsheets in 1 week"
- [ ] Target: SMBs and agencies globally (industry agnostic), Sydney local network
- [ ] Book 5 discovery calls → close 2 Quick Win clients ($10K)
- [ ] Start delivering: build 1-2 AI agents per client using existing MCPs + custom code

**Open-Source (Adoption):**
- [ ] Start building `dataxlr8-enrichment-mcp` in Rust
  - Waterfall enrichment: free data sources (LinkedIn scraping, DNS, WHOIS, Google, GitHub)
  - Email verification via SMTP checks
  - Company tech stack detection
  - 12 tools, target: 6.5MB binary
- [ ] Set up GitHub org with consistent branding

**Content (Pipeline):**
- [ ] Draft blog post: "Why We're Building MCP Servers in Rust"
- [ ] Set up DataXLR8 Twitter/LinkedIn accounts for developer content

### Week 2: Deliver + Ship

**Agency:**
- [ ] Deliver Quick Win #1 and #2
- [ ] Collect testimonials + case studies
- [ ] Send 50 more outreach messages
- [ ] Book 3 more discovery calls

**Open-Source:**
- [ ] Ship `dataxlr8-enrichment-mcp` v0.1.0 to GitHub
- [ ] Publish to crates.io
- [ ] README with quick-start: install, run, first enrichment in 60 seconds
- [ ] Publish blog: "The Open-Source Clearbit Replacement (6.5MB, Rust, 0.2ms)"
- [ ] Submit to Hacker News

**AI Scanner:**
- [ ] Upgrade BusinessAnalyzer chatbot to generate shareable AI opportunity reports
- [ ] Add "Share your report" social sharing buttons

### Week 3: Expand

**Agency:**
- [ ] Close 1 more Quick Win client ($5K) = $15K total Month 1
- [ ] Start upsell conversation with Week 1 clients → $25K core build
- [ ] Create case study template for agency work

**Open-Source:**
- [ ] Start `dataxlr8-crm-mcp` (contacts, deals, pipeline, activities — 10 tools)
- [ ] Start `dataxlr8-email-mcp` (send, templates, sequences — 6 tools)
- [ ] Publish performance benchmarks: Rust MCP vs Python MCP

### Week 4: Scale

**Agency:**
- [ ] Deliver Quick Win #3
- [ ] First upsell: Quick Win client → Core Build ($25K) = pipeline for Month 2
- [ ] Systemize: create agency delivery playbook using DataXLR8 MCPs

**Open-Source:**
- [ ] Ship crm-mcp v0.1.0 + email-mcp v0.1.0 to GitHub/crates.io
- [ ] Chrome Extension alpha: LinkedIn enrichment on hover, 10 free/day
- [ ] Start `dxlr8` CLI: `dxlr8 add`, `dxlr8 run` (local dev mode)

**Cloud:**
- [ ] Begin Cloud infrastructure: gateway with auth + routing + metering
- [ ] Set up Stripe billing for Cloud tiers

**Month 1 Deliverables:**
- 3 agency clients = $15K revenue
- 3 open-source MCPs on GitHub (enrichment, crm, email)
- Chrome Extension alpha
- Blog post on Hacker News
- Pipeline: 2-3 discovery calls for Month 2

---

## Month 2: Ramp Agency + Cloud Alpha (Target: $26K MRR)

**Agency ($25K):**
- [ ] Deliver first Core Build ($25K)
- [ ] 3 new Quick Win clients ($15K)
- [ ] First virtual meetup: "Replace Your SaaS Stack with AI"
- [ ] Referral program: existing clients refer → $500 credit

**Open-Source ($0 but builds pipeline):**
- [ ] Ship `dataxlr8-finance-mcp` (invoicing, expenses, multi-jurisdiction tax — 8 tools)
- [ ] Ship `dataxlr8-sales-mcp` (sequences, proposals, scripts — 10 tools)
- [ ] Performance benchmark blog: "50x Faster: Rust MCP vs Python MCP"
- [ ] Submit enrichment-mcp to Smithery + Glama directories

**Cloud Alpha ($1K):**
- [ ] Launch Cloud alpha (invite-only, 20 users)
- [ ] `dxlr8 deploy` command working
- [ ] Gateway with API key auth + usage metering
- [ ] Free tier: 3 MCPs, 10K calls/mo
- [ ] Basic monitoring dashboard
- [ ] First 10 paying users at $49/mo

**Chrome Extension:**
- [ ] Public beta: 10 free lookups/day
- [ ] LinkedIn enrichment on hover
- [ ] "Powered by DataXLR8" branding
- [ ] Chrome Web Store listing

---

## Month 3: Cloud Beta + Growth (Target: $38K MRR)

**Agency ($35K):**
- [ ] 2 Core Builds in progress ($50K pipeline)
- [ ] 2 new Quick Win clients ($10K)
- [ ] Second virtual meetup: "AI Agents That Replace Your SaaS Stack"
- [ ] First enterprise inquiry (from case study)

**Cloud Beta ($3K):**
- [ ] Public beta launch
- [ ] Pro tier: $49/mo, 10 MCPs, 500K calls
- [ ] Product Hunt launch: "The Open-Source Business MCP Platform"
- [ ] Enrichment pricing: $0.005/lookup
- [ ] 30 paying users

**Open-Source:**
- [ ] Ship `dataxlr8-intelligence-mcp` + `dataxlr8-scraper-mcp`
- [ ] Total: 7 MCPs on GitHub, 50+ tools
- [ ] Framework integration guide: "Using DataXLR8 MCPs with LangChain"
- [ ] Reach out to LangChain, CrewAI for partnership

**Content:**
- [ ] 3 case studies published
- [ ] "How [Agency] Replaced 7 SaaS Tools with AI Agents" blog
- [ ] YouTube tutorial: "Build an AI SDR in 10 Minutes"
- [ ] First hackathon (virtual)

---

## Month 4-6: Scale (Target: $65K MRR by Month 6)

**Agency:** Steady 2-3 new clients/month, mix of Quick Wins and Core Builds

**Cloud:** Ramp to 150 paid users
- [ ] Team tier: $199/mo
- [ ] Custom domains
- [ ] Auto-scaling
- [ ] RBAC for teams

**Open-Source:** 10+ MCPs total
- [ ] analytics-mcp, documents-mcp, calendar-mcp, auth-mcp
- [ ] Community contributions starting
- [ ] 50K+ total downloads

**Enterprise:** First enterprise inquiry → pilot
- [ ] SSO/SAML for enterprise pilot
- [ ] Audit log basics

---

## Month 7-12: Flywheel Spinning (Target: $120K MRR by Month 12)

**Agency:** Becomes selective (only $25K+ builds, decline Quick Wins)

**Cloud:** 800 paid users, $70K MRR
- [ ] Enterprise tier live
- [ ] SOC 2 Type II process started
- [ ] Data residency options

**Open-Source:** 15+ MCPs, 200K+ downloads
- [ ] First third-party MCPs built by community
- [ ] "DataXLR8 MCPs" becoming standard reference

**Data Moat:** 10M+ enrichment lookups → aggregate data improving
- [ ] Better enrichment results than Apollo for common queries
- [ ] Data advantage visible in conversion rates

---

## The Enrichment Wedge (The Critical First MCP)

### Why enrichment-mcp Goes First

1. **Clearbit just died** (April 2025) — immediate market vacuum
2. **Every developer needs it** — enrichment is the #1 use case for AI agents
3. **Usage-based revenue** — every lookup = money on Cloud
4. **Data compounds** — every lookup improves aggregate data = permanent moat
5. **Natural expansion** — "I use enrichment-mcp, what else do you have?"
6. **Agency lead gen** — "You spend $15K/yr on Apollo. enrichment-mcp is free. Want us to build you a full system?"

### enrichment-mcp v1.0 Spec

```rust
// 12 tools, all Rust, <6.5MB binary

#[tool] async fn enrich_person(name, company) → EnrichedPerson
  // Waterfall: LinkedIn → GitHub → Google → WHOIS → public records

#[tool] async fn enrich_company(domain) → CompanyProfile
  // Tech stack, size, funding, key people, social profiles

#[tool] async fn verify_email(email) → EmailVerification
  // SMTP check, MX record, disposable detection, catch-all detection

#[tool] async fn domain_emails(domain) → Vec<Email>
  // Pattern detection + verification across common formats

#[tool] async fn search_people(query) → Vec<PersonResult>
  // Title, company, location filters

#[tool] async fn reverse_ip(ip) → CompanyMatch
  // IP → company identification for website visitor tracking

#[tool] async fn bulk_enrich(records) → Vec<EnrichedResult>
  // Batch enrichment for imports

// + 5 more tools for tech stack detection, funding tracking, etc.
```

### Pricing: 60x Cheaper Than Apollo

| Volume | DataXLR8 Cloud | Apollo | ZoomInfo | Savings |
|--------|---------------|--------|----------|---------|
| 1,000 lookups | $5 | $300+ | $500+ | 60-100x |
| 10,000 lookups | $50 | $3,000+ | $5,000+ | 60-100x |
| Self-hosted | $0 | N/A | N/A | ∞ |

---

## MCP Build Priority Order

| Priority | MCP | Tools | Revenue Type | Replaces |
|----------|-----|-------|-------------|----------|
| **P0** | enrichment-mcp | 12 | Cloud (per-lookup) + Agency | Apollo, ZoomInfo, Clearbit |
| **P0** | crm-mcp | 10 | Agency + Cloud | Salesforce, HubSpot |
| **P0** | email-mcp | 6 | Agency + Cloud | SendGrid, Outreach |
| **P0** | gateway-mcp | 5 | Infrastructure | API gateways |
| **P1** | finance-mcp | 8 | Agency (multi-tax) | QuickBooks, Xero |
| **P1** | sales-mcp | 10 | Agency + Cloud | Outreach, SalesLoft |
| **P1** | scraper-mcp | 6 | Cloud + Agency | Apify, ScrapingBee |
| **P2** | intelligence-mcp | 10 | Cloud | Crayon, Similarweb |
| **P2** | content-mcp | 10 | Cloud | Jasper, Copy.ai |
| **P2** | analytics-mcp | 6 | Cloud + Enterprise | Tableau, Metabase |
| **P3** | documents-mcp | 6 | Enterprise | DocuSign, Google Docs |
| **P3** | calendar-mcp | 5 | Agency | Google Calendar |
| **P3** | auth-mcp | 6 | Cloud infrastructure | Auth0, Clerk |
| **P3** | hr-mcp | 8 | Agency | BambooHR, Gusto |

---

## Rust MCP Standards

Every MCP follows these standards:

| Metric | Target |
|--------|--------|
| Tool call latency | <0.2ms (excluding external API calls) |
| Memory per MCP | <10MB |
| Binary size | <6.5MB |
| Cold start | <5ms |
| Shared library | dataxlr8-mcp-core (DB, config, logging, auth, metrics) |
| MCP SDK | rmcp v0.17+ |
| Database | PostgreSQL via sqlx (compile-time checked) |
| License | MIT |

---

## Key Metrics Dashboard

| Metric | Month 1 | Month 3 | Month 6 | Month 12 |
|--------|---------|---------|---------|----------|
| **Agency clients (active)** | 3 | 7 | 10 | 10 |
| **Agency MRR** | $15K | $35K | $50K | $50K |
| **Cloud paid users** | 0 | 30 | 150 | 800 |
| **Cloud MRR** | $0 | $2K | $12K | $70K |
| **Total MRR** | $15K | $37K | $62K | $120K |
| **MCPs published** | 3 | 7 | 10 | 15 |
| **GitHub stars** | 200 | 2K | 10K | 50K |
| **crate downloads** | 1K | 20K | 100K | 500K |
| **Chrome Extension users** | 0 | 500 | 3K | 10K |
| **Enrichment lookups (total)** | 10K | 200K | 2M | 10M |
| **Blog monthly visitors** | 1K | 10K | 50K | 200K |

---

## Development Orchestration

**Full technical details:** [../DEVELOPMENT-STRATEGY.md](../DEVELOPMENT-STRATEGY.md) | [../TMUX-LAYOUT.md](../TMUX-LAYOUT.md)

### How We Build This Fast

48 Claude agents work in parallel across 4 tmux screens:

| Screen | Focus | Agents | What Gets Built |
|--------|-------|--------|----------------|
| 1 (`claude6`) | MCP Development | 12 | enrichment, crm, gateway, sales, finance, scraper MCPs |
| 2 (`claude6-screen2`) | Web + Portals | 12 | Public site, employee portal, client portal, training |
| 3 (`claude6-screen3`) | Testing + CI/CD | 12 | Integration tests, E2E, GitHub Actions, benchmarks |
| 4 (`claude6-screen4`) | Infrastructure | 12 | PostgreSQL, data migration, Chrome Extension, Cloud |

### Wave Mapping to Weekly Plan

| Week | Wave | Screen 1 (MCPs) | Screen 2 (Web) | Screen 3 (Test) | Screen 4 (Infra) |
|------|------|-----------------|----------------|-----------------|-------------------|
| 1-2 | Wave 1 | enrichment + crm + gateway | Public website | CI templates | PostgreSQL setup |
| 3-4 | Wave 2 | sales + finance + scraper | Employee + Client portal | Integration + E2E | Data migration |
| 5-8 | Wave 3 | Internal MCPs (8) | Training + Docs + Blog | Full test coverage | Chrome Ext + Cloud |
| 9-12 | Wave 4 | Meeting domain (8) | Enterprise features | Performance tests | Production deployment |

### Git-First Protocol

Every agent follows:
1. `cargo test` — must pass before commit
2. `cargo clippy -- -D warnings` — no warnings
3. `cargo build --release` — binary <7MB
4. Small commits, always buildable, push after every feature
5. No agent modifies another agent's repo

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| No agency clients in Month 1 | Medium | High | Lower price to $3K, offer money-back guarantee, increase outreach volume |
| Enrichment data quality too low | High | High | Multi-source waterfall, confidence scores, focus on verifiable data first (email, phone) |
| Composio builds business MCPs | Low | High | They're focused on integration gateway. Our Rust performance + agency knowledge is 2 years ahead. |
| AWS/Cloudflare builds MCP hosting | Medium | Medium | We're not competing on hosting — we're competing on the MCPs themselves. They'd host our MCPs. |
| Agency clients slower than expected | Medium | Medium | Lower price to $3K, money-back guarantee, increase outreach volume, leverage Sydney local network |
| Open-source gets no traction | Medium | High | Clearbit replacement narrative, HN launch, LangChain partnership, performance benchmarks |
| Burn rate too high | Low | High | Agency revenue covers costs from Month 1. No external funding needed for bootstrap phase. |
