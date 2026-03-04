# DataXLR8 Execution Plan

_Research date: 2026-03-04_

## The One-Liner Pitch

> **"AI solutions that actually work — one-stop custom AI, done for you."**

Not "another CRM with AI." Not "another data provider." Not "build your own AI." DataXLR8 is the AI-first business operating system: a self-serve agent marketplace PLUS done-for-you custom AI builds, all running on MCP-native Rust infrastructure. No spreadsheets. No PowerPoint. AI-first from the ground up, human-in-the-loop where it matters.

---

## Current State

### What Exists
- [x] Next.js web app with BusinessAnalyzer chatbot (homepage)
- [x] xAI Grok / Ollama integration for AI analysis
- [x] Slack webhook for high-intent lead detection
- [x] Rate limiting per IP
- [x] Business plan with 40+ agent catalog defined
- [x] `dataxlr8-mcp-core` — Shared Rust library (DB pool, config, errors, logging)
- [x] `dataxlr8-features-mcp` — 8 tools, 6.5MB binary, proof of concept
- [x] Internal operations web app (team, deals, suppliers, quotations)

### What's Missing (The Gap)
- [ ] Agent runtime + orchestrator
- [ ] Credit system (Stripe integration)
- [ ] User auth (Supabase)
- [ ] Enrichment APIs (the actual data sources)
- [ ] Chrome Extension
- [ ] Rust MCP servers for agent domains (enrichment, intelligence, content, sales, ops)
- [ ] Gateway for routing agent requests to MCPs

---

## 90-Day Execution Plan

### Month 1: Foundation + First 5 Agents

**Week 1-2: Infrastructure**
- [ ] Set up Supabase (auth, PostgreSQL, RLS policies)
- [ ] Implement Stripe integration (subscriptions + credit packs)
- [ ] Build credit system (balance, transactions, metering)
- [ ] Deploy webhook handlers for Stripe events
- [ ] Set up Redis (job queue, caching)
- [ ] Deploy to Vercel (production)

**Week 3-4: Core Agents**
- [ ] `dataxlr8-enrichment-mcp` — Rust MCP for lead/company enrichment
  - `enrich_person` (name + company → email, phone, LinkedIn, title)
  - `enrich_company` (domain → size, funding, tech stack, key people)
  - `domain_emails` (domain → all email addresses)
  - `verify_email` (email → deliverable check)
- [ ] **Lead Enricher Agent** — first revenue-generating agent (15 credits)
- [ ] **Company Scanner Agent** — full company analysis (25 credits)
- [ ] **Ice Breaker Generator** — personalized openers (5 credits)
- [ ] **Email Sequence Writer** — 5-7 email drip sequences (20 credits)
- [ ] **Competitor Monitor** — track competitor changes (50 credits)

**Deliverable:** Working payment system, credit economy, 5 production agents, basic dashboard.

### Month 2: Growth + Chrome Extension

**Week 5-6: Growth Tools**
- [ ] Chrome Extension (LinkedIn enrichment on hover, 10 free/day)
- [ ] AI Opportunity Scanner (free — top of funnel)
- [ ] Referral program (give $10 get $10 in credits)
- [ ] `dataxlr8-scraper-mcp` — Rust MCP for web scraping
  - `linkedin_profile` (URL → structured data)
  - `website_tech_stack` (domain → technologies used)
  - `pricing_pages` (domain → pricing data extraction)
  - `job_boards` (company → open positions)

**Week 7-8: Marketing + 5 More Agents**
- [ ] Publish 8 blog posts (SEO-targeted)
- [ ] Create 4 lead magnets
- [ ] Product Hunt launch
- [ ] **LinkedIn Prospector** — find decision makers (20 credits)
- [ ] **Job Board Scanner** — hiring signals = buying intent (15 credits)
- [ ] **Meeting Prep Agent** — research + talking points (15 credits)
- [ ] **Social Media Repurposer** — 1 piece → 10 posts (15 credits)
- [ ] **Blog Post Generator** — SEO-optimized articles (25 credits)

**Deliverable:** 10 agents live, Chrome Extension, 3 acquisition channels, first 100 users.

### Month 3: Integrations + Enterprise

**Week 9-10: CRM Integrations**
- [ ] HubSpot integration ($19/mo add-on)
- [ ] Salesforce integration ($29/mo add-on)
- [ ] Zapier actions (connect to 5000+ apps)
- [ ] Full API documentation + playground
- [ ] `dataxlr8-intelligence-mcp` — Rust MCP for market research
- [ ] `dataxlr8-sales-mcp` — Rust MCP for sales automation

**Week 11-12: Enterprise + Scale**
- [ ] Team workspaces + role management
- [ ] SSO/SAML for enterprise
- [ ] 5 more agents (Website Visitor ID, Market Size Estimator, Pricing Intelligence, etc.)
- [ ] Agent chaining (enrichment → sequence → send)
- [ ] Advanced analytics dashboard

**Deliverable:** 15+ agents, CRM integrations, enterprise-ready, $5K+ MRR target.

---

## Rust MCP Migration Plan

The Rust MCPs serve as the high-performance backend for the agent marketplace:

### Priority 1: Agent-Facing MCPs (Month 1-3)

| MCP | Tools | Purpose |
|-----|-------|---------|
| `dataxlr8-enrichment-mcp` | 12 | Lead/company data enrichment |
| `dataxlr8-scraper-mcp` | 6 | Web scraping engine for data collection |
| `dataxlr8-intelligence-mcp` | 10 | Competitive intel, market research |
| `dataxlr8-sales-mcp` | 10 | Email generation, call scripts |
| `dataxlr8-content-mcp` | 10 | Blog posts, social media, ad copy |
| `dataxlr8-operations-mcp` | 10 | Document analysis, data cleaning |
| `dataxlr8-credits-mcp` | 4 | Usage metering, balance checking |
| `dataxlr8-gateway-mcp` | 3 | Routes requests, health monitoring |

### Priority 2: Internal Operations MCPs (Month 4-6)
These support the company's own operations (travel business side):

| MCP | Tools | Purpose |
|-----|-------|---------|
| `dataxlr8-contacts-mcp` | 5 | Internal CRM |
| `dataxlr8-deals-mcp` | 6 | Sales pipeline |
| `dataxlr8-email-mcp` | 6 | Email sending (Resend) |
| `dataxlr8-employees-mcp` | 8 | Team management |
| `dataxlr8-commissions-mcp` | 5 | Commission tracking |

### Performance Targets (Rust MCPs)

| Metric | Target |
|--------|--------|
| Tool call latency | <0.2ms (excluding external API) |
| Memory per MCP | <10MB |
| Binary size | <6.5MB |
| Cold start | <5ms |
| Gateway routing | <1ms |

---

## Key Metrics

| Metric | Month 1 | Month 3 | Month 6 | Month 12 |
|--------|---------|---------|---------|----------|
| Agents live | 5 | 15 | 25 | 40+ |
| Registered users | 50 | 500 | 2,000 | 10,000 |
| Active users (MAU) | 20 | 200 | 500 | 2,000 |
| Conversion (free→paid) | — | 8% | 10% | 12% |
| MRR | $0 | $5K | $15K | $50K |
| ARPU | — | $65 | $65 | $70 |
| Churn | — | <8% | <5% | <4% |

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Enrichment data quality | High | High | Multi-source verification, confidence scores, waterfall approach |
| LLM costs spike | Medium | High | BYOK model (users bring keys), cache frequent queries |
| Scraping blocks | High | Medium | Proxy rotation, headless browsers, API fallbacks |
| Apollo/ZoomInfo crush us | Low | High | Speed, AI-native agents (not just data), cheaper |
| Low conversion | Medium | High | Free tools hook (Opportunity Scanner, Chrome Extension) |
| Credit model pricing wrong | Medium | Medium | A/B test credit costs, usage analytics |

---

## The Strategic Sequence

```
Phase 1: Lead enrichment + sales agents → prove PMF with sales teams
Phase 2: Intelligence + content agents → expand to marketing teams
Phase 3: Operations agents + integrations → enterprise readiness
Phase 4: Agent chaining + custom builder → platform economics
Phase 5: Community marketplace → network effects
Phase 6: White-label → agency channel
```

**Revenue targets:**
- Month 3: $5K MRR (100 paying users × $50 avg)
- Month 6: $15K MRR (300 paying users)
- Month 12: $50K MRR (1,000 paying users)
- Month 24: $200K MRR (4,000 paying users + enterprise)
