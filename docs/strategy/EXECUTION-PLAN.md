# DataXLR8 Execution Plan

_Research date: 2026-03-04_

## The One-Liner Pitch

> **"The business OS that AI agents actually run — starting with travel."**

Not "another CRM with AI." Not "another travel tool." The first MCP-native business platform where any AI agent (Claude, GPT, Gemini) can operate your entire company through 150+ tools at sub-millisecond speed. Start with travel, expand to every vertical.

---

## Current State

### What's Done (Phase 0)
- [x] `dataxlr8-mcp-core` — Shared Rust library (DB pool, config, errors, logging)
- [x] `dataxlr8-features-mcp` — 8 tools, 6.5MB binary, proof of concept
- [x] Code review + critical bug fixes
- [ ] PostgreSQL setup + end-to-end verification
- [ ] Claude Desktop integration test

### What Exists in TypeScript
- Full web app (Next.js) with 70+ API routes
- 8 MCP servers (meeting domain)
- Business logic in `apps/web/lib/` (14 client libraries)
- Google Sheets as database (employee portal)
- Google OAuth authentication

---

## 90-Day Execution Plan

### Month 1: Foundation + Leaf MCPs (Rust Phase 1)

**Week 1-2: Infrastructure**
- [ ] Install PostgreSQL, create `dataxlr8` database
- [ ] Test `dataxlr8-features-mcp` end-to-end (stdio + Claude Desktop)
- [ ] Set up CI/CD for Rust repos (GitHub Actions: test + build + release)

**Week 3-4: Leaf MCPs (no cross-dependencies)**
- [ ] `dataxlr8-contacts-mcp` — Simple CRUD (5 tools)
- [ ] `dataxlr8-commissions-mcp` — JSON → PostgreSQL (5 tools)
- [ ] `dataxlr8-email-mcp` — Resend API wrapper (6 tools)
- [ ] `dataxlr8-employees-mcp` — Google Sheets → PostgreSQL migration (8 tools)

**Deliverable:** 5 working Rust MCPs (features + 4 new), all testable via stdio

### Month 2: Travel Core (The Differentiator)

**Week 5-6: Supplier + Quotation**
- [ ] `dataxlr8-supplier-mcp` — Contract loading, seasonal rates, allotments (6 tools)
- [ ] `dataxlr8-quotation-mcp` — Multi-currency pricing, itinerary builder, GST (6 tools)

**Week 7-8: Booking + Rooming + Deals**
- [ ] `dataxlr8-rooming-mcp` — Group manifests, room assignments (5 tools)
- [ ] `dataxlr8-booking-mcp` — Confirmation workflow, vouchers (4 tools)
- [ ] `dataxlr8-deals-mcp` — Multi-pipeline, forecasting (6 tools)

**Deliverable:** 10 working Rust MCPs covering full travel operations

### Month 3: AI + Gateway + Launch

**Week 9-10: Gateway + Portal**
- [ ] `dataxlr8-gateway-mcp` — Spawns all MCPs, single HTTP endpoint, health monitoring
- [ ] `dataxlr8-portal-mcp` — Client dashboard, deliverables, documents (12 tools)
- [ ] Wire web app to gateway (`lib/mcp-gateway-client.ts`)

**Week 11-12: AI Layer + Pilot**
- [ ] `dataxlr8-ai-analysis-mcp` — AI quotation generation, natural language reports (4 tools)
- [ ] WhatsApp integration via notification MCP
- [ ] PDF generation for proposals/vouchers
- [ ] Ship to 5 pilot DMCs in India

**Deliverable:** Full platform running on Rust MCPs, 5 paying pilot customers

---

## Phase 2 (Month 4-6): Meeting Domain + Enterprise

- [ ] Migrate 8 meeting MCPs (analytics, calendar, copilot, meet, moderation, notification, recording, transcript)
- [ ] Add SSO/SAML
- [ ] Add audit logs
- [ ] Add RBAC
- [ ] Tally/QuickBooks integration
- [ ] Razorpay integration
- [ ] Begin SOC 2 preparation

---

## Phase 3 (Month 7-9): Scale + Open Source

- [ ] Open-source core MCP servers on GitHub
- [ ] Launch managed cloud offering
- [ ] MCP marketplace (third-party plugins)
- [ ] PWA for mobile
- [ ] 50 paying customers target

---

## Key Metrics to Track

| Metric | Month 1 | Month 3 | Month 6 | Month 9 |
|--------|---------|---------|---------|---------|
| Rust MCPs live | 5 | 14 | 22 | 22+ |
| Total tools | 32 | 90 | 150+ | 150+ |
| Pilot customers | 0 | 5 | 20 | 50 |
| MRR | $0 | $2K | $10K | $30K |
| Gateway uptime | — | 99% | 99.5% | 99.9% |

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Rust learning curve | Use `features-mcp` as template, follow `rmcp` macros |
| No official Anthropic Rust SDK | Community crate or raw `reqwest` against Messages API |
| Google Sheets → PostgreSQL migration | Run both in parallel during transition, sync tool |
| 22+ repos to maintain | Shared core crate, consistent CI, gateway config as source of truth |
| Pilot customer churn | Intensive onboarding, weekly check-ins, fast iteration |
| Competitor launches MCP-native | Speed. Being Rust + already in production is the moat |

---

## Competitive Positioning

### vs Tourwriter ($149/user/mo)
- Cheaper ($99/user/mo)
- AI-powered quotation generation (seconds vs hours)
- Client portal (they don't have one)
- Full CRM + operations (they're itinerary-only)

### vs Salesforce ($25-$318/user/mo)
- Travel-specific (they're generic)
- MCP-native AI (theirs is bolted on)
- 10x cheaper for equivalent features
- No implementation consultants needed

### vs Odoo ($24.90/user/mo)
- Travel-specialized (they're generic ERP)
- AI-native (they're adding AI incrementally)
- Rust performance (they're Python)
- MCP ecosystem access (they don't have it)

### vs Zoho ($14-$52/user/mo + MCP server)
- They have an MCP server but it's a wrapper on existing apps
- DataXLR8 is MCP from the ground up
- Travel vertical depth (they're horizontal)
- Rust performance vs their Java/Python stack

---

## The Strategic Sequence

```
Phase 1: Travel vertical (India DMCs) → prove product-market fit
Phase 2: Enterprise features → move upmarket
Phase 3: Open source + cloud → distribution play
Phase 4: Multi-vertical → expand beyond travel
Phase 5: MCP marketplace → platform economics
```

**Revenue targets:**
- Month 6: $10K MRR (20 customers × $500/mo avg)
- Month 12: $50K MRR (100 customers)
- Month 18: $150K MRR (300 customers + enterprise deals)
- Month 24: $500K MRR (scale + open source distribution)
