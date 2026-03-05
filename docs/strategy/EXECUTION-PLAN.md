# DataXLR8 Execution Plan — All Engines From Day 1

_Updated: 2026-03-05_

## The Rule: Nothing Is Sequential. Everything Runs In Parallel.

```
WRONG:  Build MCPs → Launch Cloud → Find Clients → Make Money (12+ months to revenue)
RIGHT:  Find Clients + Build MCPs + Launch Cloud → Money from Week 1
```

---

## Current State

### What Exists (All Compiling, All on GitHub)

| Repo | What | Tools | Commit | Status |
|------|------|-------|--------|--------|
| `dataxlr8-mcp-core` | Shared Rust library | DB, config, errors, logging, mcp helpers, types | e4060c6 | compiles |
| `dataxlr8-features-mcp` | Feature flags, A/B testing | 9 tools | b46d94f | compiles |
| `dataxlr8-enrichment-mcp` | Lead enrichment (THE WEDGE) | 12 tools | 2b55e6f | compiles |
| `dataxlr8-crm-mcp` | CRM pipeline, deals, contacts, interactions, tags | 12 tools | 6ce23ee | compiles |
| `dataxlr8-email-mcp` | Email sending + templates | 6 tools | 1640e5e | compiles |
| `dataxlr8-commissions-mcp` | Sales commissions, leaderboard | 8 tools | 1d9dc69 | compiles |
| `dataxlr8-devtools-mcp` | Dev intelligence, sessions, git ops, QA | 20 tools | 3720c59 | compiles |
| `dataxlr8-contacts-mcp` | Contact management | 9 tools | 1181301 | DEPRECATED (merged into crm-mcp) |
| `dataxlr8-web` | Employee portal | deals, training, commissions, admin | — | compiles, running |
| `dataxlr8-rust` | Strategy docs | architecture, plans | — | — |
| **Total** | **9 repos + docs** | **67 tools** (excl. deprecated) | | |

Additional assets:
- Next.js web app with BusinessAnalyzer chatbot (AI Opportunity Scanner)
- Google Sheets operational database
- Resend email integration
- Google OAuth + Invite System
- Strategy docs and market research

### Architecture: Individual Repos

Every MCP is its own GitHub repo under `pdaxt/`. Connected only through `dataxlr8-mcp-core` as a path dependency. Each deploys independently.

```
dataxlr8-{name}-mcp/
├── Cargo.toml          # rmcp 0.17, dataxlr8-mcp-core (path), sqlx, tokio, serde
├── src/
│   ├── main.rs         # config → logging → db → schema → server → stdio
│   ├── db.rs           # CREATE SCHEMA IF NOT EXISTS {name}; + tables
│   └── tools/
│       └── mod.rs      # types → schema helpers → build_tools() → handlers → ServerHandler
```

### What's Been Completed

- [x] mcp-core: Added `mcp.rs` (shared tool helpers) + `types.rs` (shared data types) — commit e4060c6
- [x] contacts-mcp: Merged unique features (interactions, tags) into crm-mcp — commit 6ce23ee
- [x] All MCPs updated to use shared helpers from mcp-core (via use-shared-helpers PRs)
- [x] devtools-mcp: 20 tools built — sessions, code analysis, git ops, QA gates — commit 3720c59

### What's In Progress

- [ ] enrichment-mcp: Provider-based waterfall architecture refactor

### What's Missing

- [ ] `dxlr8` CLI tool
- [ ] DataXLR8 Cloud hosting infrastructure (gateway, auth, metering)
- [ ] Chrome Extension
- [ ] First 3 paying agency clients
- [ ] Open-source MCPs on crates.io

---

## Month 1: Revenue + Foundation (Target: $15K MRR)

### Week 1: First Revenue + Finish Core

**Agency (Revenue):**
- [ ] Send 50 LinkedIn + cold email messages: "$5K AI Quick Win — replace spreadsheets in 1 week"
- [ ] Target: SMBs and agencies globally (industry agnostic), Sydney local network
- [ ] Book 5 discovery calls → close 2 Quick Win clients ($10K)
- [ ] Start delivering: build 1-2 AI agents per client using existing MCPs + custom code

**Engineering (Foundation):**
- [x] Build `dataxlr8-enrichment-mcp` — 12 tools, compiles, on GitHub
- [x] Build `dataxlr8-crm-mcp` — 10 tools, compiles, on GitHub
- [ ] Complete enrichment-mcp provider refactor (waterfall: Free → Freemium → Paid)
- [x] Refactor mcp-core: add mcp.rs + types.rs (eliminate duplication) — DONE (e4060c6)
- [x] Merge contacts-mcp into crm-mcp — DONE (6ce23ee)
- [ ] QA test enrichment-mcp (verify_email on real addresses)
- [ ] QA test crm-mcp (full roundtrip: create → search → deal → pipeline)

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
- [ ] Publish enrichment-mcp v0.1.0 to crates.io
- [ ] README with quick-start: install, run, first enrichment in 60 seconds
- [ ] Publish blog: "The Open-Source Clearbit Replacement (6.5MB, Rust, 0.2ms)"
- [ ] Submit to Hacker News

### Week 3: Expand

**Agency:**
- [ ] Close 1 more Quick Win client ($5K) = $15K total Month 1
- [ ] Start upsell conversation with Week 1 clients → $25K core build

**Engineering:**
- [ ] Ship finance-mcp or sales-mcp (next priority MCP)
- [ ] Publish performance benchmarks: Rust MCP vs Python MCP

### Week 4: Scale

**Agency:**
- [ ] Deliver Quick Win #3
- [ ] First upsell: Quick Win client → Core Build ($25K) = pipeline for Month 2
- [ ] Systemize: create agency delivery playbook using DataXLR8 MCPs

**Open-Source:**
- [ ] Publish crm-mcp + email-mcp to crates.io
- [ ] Chrome Extension alpha: LinkedIn enrichment on hover, 10 free/day
- [ ] Start `dxlr8` CLI: `dxlr8 add`, `dxlr8 run` (local dev mode)

**Cloud:**
- [ ] Begin Cloud infrastructure: gateway with auth + routing + metering
- [ ] Set up Stripe billing for Cloud tiers

**Month 1 Deliverables:**
- 3 agency clients = $15K revenue
- 7 open-source MCPs on GitHub (features, enrichment, crm, email, commissions + new)
- Chrome Extension alpha
- Blog post on Hacker News
- Pipeline: 2-3 discovery calls for Month 2

---

## Month 2: Ramp Agency + Cloud Alpha (Target: $26K MRR)

**Agency ($25K):**
- [ ] Deliver first Core Build ($25K)
- [ ] 3 new Quick Win clients ($15K)
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
- [ ] First 10 paying users at $49/mo

---

## Month 3: Cloud Beta + Growth (Target: $38K MRR)

**Agency ($35K):**
- [ ] 2 Core Builds in progress ($50K pipeline)
- [ ] 2 new Quick Win clients ($10K)

**Cloud Beta ($3K):**
- [ ] Public beta launch
- [ ] Pro tier: $49/mo, 10 MCPs, 500K calls
- [ ] Product Hunt launch: "The Open-Source Business MCP Platform"
- [ ] Enrichment pricing: $0.005/lookup
- [ ] 30 paying users

**Open-Source:**
- [ ] Ship intelligence-mcp + scraper-mcp
- [ ] Total: 10+ MCPs on GitHub, 70+ tools
- [ ] Reach out to LangChain, CrewAI for partnership

---

## Month 4-6: Scale (Target: $65K MRR by Month 6)

**Agency:** Steady 2-3 new clients/month, mix of Quick Wins and Core Builds

**Cloud:** Ramp to 150 paid users
- [ ] Team tier: $199/mo
- [ ] Custom domains
- [ ] Auto-scaling
- [ ] RBAC for teams

**Open-Source:** 12+ MCPs total
- [ ] analytics-mcp, documents-mcp, calendar-mcp, auth-mcp
- [ ] Community contributions starting

---

## Month 7-12: Flywheel Spinning (Target: $120K MRR by Month 12)

**Agency:** Becomes selective (only $25K+ builds, decline Quick Wins)

**Cloud:** 800 paid users, $70K MRR
- [ ] Enterprise tier live
- [ ] SOC 2 Type II process started

**Open-Source:** 15+ MCPs, 200K+ downloads
- [ ] First third-party MCPs built by community

**Data Moat:** 10M+ enrichment lookups → aggregate data improving

---

## MCP Build Priority Order

| Priority | MCP | Tools | Status | Replaces |
|----------|-----|-------|--------|----------|
| **P0** | enrichment-mcp | 12 | compiles, provider refactor | Apollo, ZoomInfo, Clearbit |
| **P0** | crm-mcp | 10 | compiles | Salesforce, HubSpot |
| **P0** | email-mcp | 6 | compiles | SendGrid, Outreach |
| **P0** | mcp-core refactor | — | DONE (e4060c6) | (internal) |
| **P0** | devtools-mcp | 20 | compiles (3720c59) | (internal) |
| **P1** | finance-mcp | 8 | planned | QuickBooks, Xero |
| **P1** | sales-mcp | 10 | planned | Outreach, SalesLoft |
| **P1** | scraper-mcp | 6 | planned | Apify, ScrapingBee |
| **P1** | gateway-mcp | 5 | planned | (infrastructure) |
| **P2** | intelligence-mcp | 10 | planned | Crayon, Similarweb |
| **P2** | content-mcp | 10 | planned | Jasper, Copy.ai |
| **P2** | analytics-mcp | 6 | planned | Tableau, Metabase |
| **P3** | documents-mcp | 6 | planned | DocuSign |
| **P3** | calendar-mcp | 5 | planned | Calendly |
| **P3** | auth-mcp | 6 | planned | Auth0, Clerk |
| **P3** | hr-mcp | 8 | planned | BambooHR, Gusto |

---

## Rust MCP Standards

Every MCP follows these standards:

| Metric | Target |
|--------|--------|
| Tool call latency | <0.2ms (excluding external API calls) |
| Memory per MCP | <10MB |
| Binary size | <7MB |
| Cold start | <5ms |
| Shared library | dataxlr8-mcp-core (DB, config, logging, tool helpers, types) |
| MCP SDK | rmcp v0.17+ |
| Database | PostgreSQL via sqlx |
| License | MIT |
| Repo | Individual repo per MCP |

---

## Development Orchestration

### Multi-Agent Development

Agents work across tmux panes, coordinated by AgentOS:

| Role | Location | What |
|------|----------|------|
| Coordinator | screen1.pane3 | Orchestrate, monitor, update GitHub |
| Dev agents | screen10.panes | Build MCPs in parallel |
| QA agents | screen10/screen1 | Test MCPs after build |

### Git Protocol

Every agent follows:
1. `cargo build` — must pass before commit
2. Small commits, always buildable, push after every feature
3. No agent modifies another agent's repo
4. Descriptive commit messages (no AI attribution)

---

## Key Metrics Dashboard

| Metric | Month 1 | Month 3 | Month 6 | Month 12 |
|--------|---------|---------|---------|----------|
| **Agency clients (active)** | 3 | 7 | 10 | 10 |
| **Agency MRR** | $15K | $35K | $50K | $50K |
| **Cloud paid users** | 0 | 30 | 150 | 800 |
| **Cloud MRR** | $0 | $2K | $12K | $70K |
| **Total MRR** | $15K | $37K | $62K | $120K |
| **MCPs published** | 7 | 10 | 13 | 15 |
| **GitHub stars** | 200 | 2K | 10K | 50K |

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| No agency clients in Month 1 | Medium | High | Lower price to $3K, offer money-back guarantee, increase outreach volume |
| Enrichment data quality too low | High | High | Provider waterfall with confidence scoring. Free sources first, escalate to freemium only when needed. |
| Composio builds business MCPs | Low | High | They're focused on integration gateway. Our Rust performance + agency knowledge is 2 years ahead. |
| Agency clients slower than expected | Medium | Medium | Lower price, money-back guarantee, leverage Sydney local network |
| Open-source gets no traction | Medium | High | Clearbit replacement narrative, HN launch, performance benchmarks |
