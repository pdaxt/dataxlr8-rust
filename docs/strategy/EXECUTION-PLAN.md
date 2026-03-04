# DataXLR8 Execution Plan

_Updated: 2026-03-04_

## The One-Liner

> **"The infrastructure platform where AI agents get their tools."**

Open-source Rust MCPs for adoption. DataXLR8 Cloud for revenue. MCP Registry for network effects. Enterprise for scale.

---

## Current State

### What Exists
- [x] `dataxlr8-mcp-core` — Shared Rust library (DB pool, config, errors, logging)
- [x] `dataxlr8-features-mcp` — 8 tools, 6.5MB binary, proof of concept
- [x] Next.js web app with BusinessAnalyzer chatbot (lead gen)
- [x] Slack webhook for high-intent lead detection
- [x] Internal operations web app (team, deals, suppliers)
- [x] Strategy docs and market research

### What's Missing (The Gap)

**Open-Source MCPs:**
- [ ] 20+ domain-specific Rust MCP servers
- [ ] Published to crates.io
- [ ] Documentation, examples, tutorials

**DataXLR8 Cloud:**
- [ ] `dxlr8` CLI tool
- [ ] MCP deployment engine (spawn, monitor, scale)
- [ ] Gateway (auth, routing, rate limiting, load balancing)
- [ ] Billing (usage metering, Stripe integration)
- [ ] Monitoring dashboard
- [ ] Multi-tenant infrastructure

**MCP Registry:**
- [ ] Searchable registry of MCP servers
- [ ] Versioning, verification, ratings
- [ ] Developer publishing workflow
- [ ] Revenue share system

**Enterprise:**
- [ ] SSO/SAML
- [ ] RBAC, audit logs
- [ ] SOC 2 Type II (process)
- [ ] SLA framework

---

## 90-Day Plan

### Month 1: Open-Source Foundation (Developer Adoption)

**Week 1-2: Core MCPs**

Build and publish the first batch of Rust MCP servers:

| MCP Server | Tools | Purpose | Priority |
|------------|-------|---------|----------|
| `dataxlr8-crm-mcp` | 10 | Contacts, deals, pipeline | High |
| `dataxlr8-enrichment-mcp` | 12 | Lead/company data enrichment | High |
| `dataxlr8-email-mcp` | 6 | Email sending, templates | High |
| `dataxlr8-scraper-mcp` | 6 | Web scraping engine | High |
| `dataxlr8-gateway-mcp` | 5 | Routing, health, auth | High |

Each MCP:
- Standalone 6.5MB Rust binary
- Full MCP protocol compliance (Streamable HTTP + stdio)
- PostgreSQL storage via `dataxlr8-mcp-core`
- Published to crates.io with MIT license
- README with quick-start, examples, API docs

**Week 3-4: Developer Experience**

- [ ] `dxlr8` CLI — install MCPs, run locally, deploy to cloud
  ```
  cargo install dxlr8
  dxlr8 init my-project
  dxlr8 add crm-mcp enrichment-mcp email-mcp
  dxlr8 run   # Local development
  dxlr8 deploy  # Cloud deployment (later)
  ```
- [ ] Documentation site (mdBook or similar)
- [ ] 3 tutorials: "Build your first agent with DataXLR8 MCPs"
- [ ] GitHub org with consistent branding and READMEs
- [ ] First blog post: "Why We Built MCP Servers in Rust (and You Should Too)"

**Deliverable:** 5 open-source Rust MCPs on crates.io + GitHub, CLI tool, documentation.

### Month 2: More MCPs + Cloud Alpha

**Week 5-6: Expand MCP Catalog**

| MCP Server | Tools | Purpose |
|------------|-------|---------|
| `dataxlr8-finance-mcp` | 8 | Invoicing, expenses, tax |
| `dataxlr8-content-mcp` | 10 | Blog, social, SEO generation |
| `dataxlr8-intelligence-mcp` | 10 | Market research, competitor tracking |
| `dataxlr8-documents-mcp` | 6 | Document analysis, generation |
| `dataxlr8-calendar-mcp` | 5 | Scheduling, availability |
| `dataxlr8-payments-mcp` | 5 | Stripe, Razorpay integration |

**Week 7-8: Cloud Alpha**

- [ ] DataXLR8 Cloud alpha (invite-only)
  - Deploy MCPs with `dxlr8 deploy`
  - Gateway with auth (API keys)
  - Basic monitoring dashboard
  - Usage tracking (tool calls per MCP)
  - Free tier: 3 MCPs, 10K tool calls/mo
- [ ] Stripe integration for billing
- [ ] Landing page: dataxlr8.com/cloud

**Deliverable:** 11 MCPs published, Cloud alpha running, first external users deploying MCPs.

### Month 3: Cloud Beta + Community

**Week 9-10: Cloud Beta Launch**

- [ ] Public Cloud beta with pricing
  - Pro: $49/mo (20 MCPs, 500K tool calls)
  - Team: $199/mo (unlimited MCPs, 5M tool calls)
- [ ] Custom domains (your-org.dataxlr8.cloud)
- [ ] Auto-scaling based on tool call volume
- [ ] MCP Registry alpha (search, install, versions)

**Week 11-12: Growth**

- [ ] Product Hunt launch ("The AWS of AI Agent Tools")
- [ ] Blog series: Rust MCP benchmarks, case studies
- [ ] Framework partnerships: LangChain, CrewAI integration guides
- [ ] 5 more MCPs from community contributions
- [ ] Hacker News / Reddit / Dev.to presence
- [ ] First paying customer case study

**Deliverable:** Cloud beta with paying users, Registry alpha, 15+ MCPs, developer community forming.

---

## Agency Work (Funds Development)

While building the platform, agency work generates revenue and battle-tests the MCPs:

| Engagement | Price | What We Build | Platform Benefit |
|-----------|-------|---------------|-----------------|
| Quick Win | $5K-15K | 1-2 MCP-powered AI agents | Tests MCPs in production |
| Core Build | $25K-50K | Full AI system on MCPs | Battle-tests composability |
| Enterprise | $75K+ | Multi-department AI system | Validates enterprise needs |

**Rule:** Every custom build uses our open-source MCPs. Client-specific features get abstracted into configurable MCPs and contributed back to open-source.

---

## Rust MCP Server Standards

Every MCP we build follows these standards:

### Performance Targets
| Metric | Target |
|--------|--------|
| Tool call latency | <0.2ms (excluding external API calls) |
| Memory per MCP | <10MB |
| Binary size | <6.5MB |
| Cold start | <5ms |
| Gateway routing | <1ms |

### Code Standards
- Shared `dataxlr8-mcp-core` for DB, config, logging
- `rmcp` v0.17+ for MCP protocol
- `sqlx` for PostgreSQL (compile-time checked queries)
- `serde` for serialization
- `tracing` for structured logging
- Every tool: doc comment, input validation, error handling
- Integration tests for every MCP

### Publication Checklist
- [ ] Builds on Linux, macOS, Windows
- [ ] CI/CD (GitHub Actions)
- [ ] README with quick-start
- [ ] Published to crates.io
- [ ] Docker image available
- [ ] Performance benchmarks in README

---

## Key Metrics

### Developer Adoption (Primary — Month 1-6)

| Metric | Month 1 | Month 3 | Month 6 |
|--------|---------|---------|---------|
| MCPs published | 5 | 15 | 30+ |
| GitHub stars (total) | 500 | 5,000 | 50,000 |
| crate downloads (total) | 10K | 100K | 1M+ |
| Cloud signups | 0 | 500 | 5,000 |
| Cloud paid users | 0 | 50 | 200 |

### Revenue (Secondary — Month 3-12)

| Metric | Month 3 | Month 6 | Month 12 |
|--------|---------|---------|----------|
| Agency revenue | $15K | $30K | $50K |
| Cloud MRR | $0 | $5K | $20K |
| Total MRR | $5K | $15K | $50K |
| ARR run-rate | $60K | $180K | $600K |

### Platform Health

| Metric | Month 6 | Month 12 |
|--------|---------|----------|
| MCPs in Registry | 50 | 500 |
| Third-party MCPs | 10 | 100 |
| Community contributors | 20 | 100 |
| Enterprise inquiries | 5 | 50 |

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| AWS/Google builds MCP hosting | Medium | High | Move fast, build community loyalty, developer experience moat |
| MCP standard changes | Low | High | Active in AAIF governance, adapt quickly |
| Rust developer scarcity | Medium | Medium | Good documentation, easy contribution guides, accept non-Rust MCPs too |
| Low developer adoption | Medium | High | More MCPs, better DX, content marketing, conference talks |
| Agency work distracts from platform | High | Medium | Strict 60/40 split (platform/agency), hire for agency |
| Revenue too slow | Medium | Medium | Agency revenue covers runway while platform grows |

---

## The Strategic Sequence

```
Phase 1: Open-source Rust MCPs → developer adoption (Month 1-3)
Phase 2: DataXLR8 Cloud → monetize hosting (Month 3-6)
Phase 3: MCP Registry → network effects (Month 6-12)
Phase 4: Enterprise tier → high-ACV contracts (Month 12-18)
Phase 5: Marketplace → third-party agent ecosystem (Month 18-24)
Phase 6: Dominance → the default MCP infrastructure (Year 3-5)
```

**Each phase builds on the previous.** Open-source creates adoption. Cloud monetizes adoption. Registry creates lock-in through ecosystem. Enterprise creates revenue at scale. Marketplace creates network effects that are impossible to replicate.
