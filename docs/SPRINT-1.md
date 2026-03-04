# Sprint 1: Get Ready to Email

_Build the minimum needed to start client outreach. No gold-plating. Ship it._

_Created: 2026-03-04_

---

## Goal

Have everything ready to email prospects by end of sprint. That means:
1. **dataxlr8.com** live with new positioning (replacement, not connection)
2. **enrichment-mcp** on GitHub — the wedge product, demo-able
3. **GitHub org** looks professional — repos, READMEs, stars
4. **Demo flow** — can show a prospect the product in 5 minutes

---

## What's Already Done

| Asset | Status |
|-------|--------|
| dataxlr8-web (Axum + Askama) | Runs on port 3001, has team portal |
| dataxlr8-mcp-core | Built, shared crate |
| dataxlr8-features-mcp (8 tools) | Built, on GitHub |
| dataxlr8-contacts-mcp (9 tools) | Built, on GitHub |
| dataxlr8-commissions-mcp (8 tools) | Built, on GitHub |
| dataxlr8-email-mcp (6 tools) | Built, on GitHub |
| PostgreSQL | Running, dataxlr8 DB exists |
| Rust toolchain | cargo 1.92.0 |
| Strategy docs | 8 docs, pushed to GitHub |
| Client acquisition playbook | Written, pushed |

---

## What Needs to Be Built

### Priority 1: Website (Screen 2 agents)

**dataxlr8-web** — revamp homepage + add key pages

| Page | What | Agent |
|------|------|-------|
| `/` (homepage) | Hero: "Replace your SaaS stack. $49/mo." + feature grid + cost comparison + CTA | `screen2:0.0` |
| `/pricing` | 4 tiers: Free / Pro $49 / Team $199 / Enterprise | `screen2:0.1` |
| `/open-source` | GitHub repos, what each MCP does, install instructions | `screen2:0.2` |

**Time estimate:** 1-2 days for all 3 pages

### Priority 2: enrichment-mcp (Screen 1 agents)

**dataxlr8-enrichment-mcp** — THE wedge product

| Task | What | Agent |
|------|------|-------|
| Scaffold + schema | `scaffold-mcp.sh enrichment enrichment` + tables | `claude6:0.0` |
| Core tools (4) | `enrich_company`, `verify_email`, `domain_emails`, `tech_stack` | `claude6:0.1` |
| Lookup tools (4) | `enrich_person`, `search_people`, `social_profiles`, `news_mentions` | `claude6:0.2` |
| Batch + utility (4) | `bulk_enrich`, `reverse_ip`, `funding_tracker`, `hiring_signals` | `claude6:0.0` |

**Data sources for v1 (free, no API keys needed):**
- DNS/MX records (built-in) → email verification, tech stack detection
- HTTP headers + HTML analysis → tech stack, company info
- WHOIS lookup → domain registration, company data
- SMTP verification → email deliverability check
- Google search scraping → social profiles, news
- GitHub API (free tier) → developer profiles

**Time estimate:** 2-3 days for 12 tools

### Priority 3: GitHub Presence (Screen 3 agents)

| Task | What | Agent |
|------|------|-------|
| Org README | pdaxt org README with DataXLR8 branding | `screen3:2.0` |
| enrichment-mcp README | Professional README with quick-start | `screen3:2.1` |
| All MCP READMEs | Consistent branding across all repos | `screen3:2.2` |

**Time estimate:** Half day

### Priority 4: Demo Flow (Screen 2 agents)

| Task | What | Agent |
|------|------|-------|
| Demo script | 5-min demo: enrich a lead → add to CRM → auto-email | `screen2:1.0` |
| Loom video | Record the demo flow | Manual (Pran) |

**Time estimate:** Half day after enrichment-mcp works

---

## Sprint Schedule

### Day 1 (Today)
- [ ] **Website:** Start homepage revamp (`screen2:0.0`)
- [ ] **enrichment-mcp:** Scaffold + schema + first 4 tools (`claude6:0.0-0.2`)
- [ ] **GitHub:** Update org README (`screen3:2.0`)

### Day 2
- [ ] **Website:** Finish homepage + pricing page
- [ ] **enrichment-mcp:** Remaining 8 tools + tests
- [ ] **GitHub:** enrichment-mcp README with install + quick-start

### Day 3
- [ ] **Website:** Open-source page + deploy to production
- [ ] **enrichment-mcp:** Push to GitHub, test end-to-end
- [ ] **Demo:** Script the 5-min demo flow
- [ ] **Gateway:** Get gateway routing to enrichment + existing MCPs

### Day 4
- [ ] **Polish:** Fix bugs, improve copy, test everything
- [ ] **Demo:** Record Loom video
- [ ] **LinkedIn:** Update profile, prepare first content post
- [ ] **Outreach:** Build prospect list (100 targets)

### Day 5
- [ ] **GO:** Start sending outreach messages
- [ ] **Content:** Publish "We Replaced Clearbit" blog post
- [ ] **Monitor:** Track responses, book calls

---

## Tmux Agent Assignments (Sprint 1)

Only need 12 of 48 agents for Sprint 1:

```
Screen 1 (claude6) — enrichment-mcp:
  W0.P0: Build enrichment tools (DNS, SMTP, HTTP)
  W0.P1: Build enrichment tools (search, social)
  W0.P2: Test enrichment-mcp + write unit tests

Screen 2 (claude6-screen2) — Website:
  W0.P0: Homepage route + template
  W0.P1: Pricing page route + template
  W0.P2: Open-source page route + template

Screen 3 (claude6-screen3) — Quality:
  W0.P0: Test website (Playwright)
  W0.P1: Test enrichment-mcp (integration)
  W2.P0: GitHub READMEs + CI

Screen 4 (claude6-screen4) — Infra:
  W0.P0: PostgreSQL schema setup
  W1.P0: Gateway config for new MCPs
  W3.P0: Deploy website to production
```

---

## Definition of Done

Before sending first outreach email:

- [ ] dataxlr8.com homepage live with "Replace your SaaS stack" positioning
- [ ] dataxlr8.com/pricing page live with 4 tiers
- [ ] dataxlr8-enrichment-mcp on GitHub with README + install instructions
- [ ] At least `verify_email` and `enrich_company` tools working end-to-end
- [ ] 5-min demo flow scripted and tested
- [ ] LinkedIn profile updated
- [ ] 100-person prospect list built
- [ ] First LinkedIn content post ready

---

## What We DON'T Need Before Outreach

- Client portal (build when first client signs)
- Training modules (internal only)
- Chrome Extension (Month 2)
- Cloud hosting (Month 2 — self-hosted is fine for demos)
- All 14 MCPs (enrichment + existing 4 is enough)
- Perfect website (good enough > perfect)
- SOC 2, SSO, enterprise features
