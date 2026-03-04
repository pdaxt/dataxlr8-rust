# Pricing, Revenue Model & Go-To-Market

_Updated: 2026-03-04_

## Revenue Streams

### Stream 1: DataXLR8 Cloud (Primary — Recurring)

Managed hosting for MCP servers. Deploy with one command, scale automatically.

| Tier | Price | MCPs | Tool Calls/mo | Features |
|------|-------|------|--------------|----------|
| **Free** | $0 | 3 | 10,000 | Shared infra, API key auth, basic monitoring |
| **Pro** | $49/mo | 20 | 500,000 | Custom domains, JWT auth, advanced monitoring |
| **Team** | $199/mo | Unlimited | 5,000,000 | Team management, RBAC, priority support |
| **Enterprise** | Custom ($2K+/mo) | Unlimited | Unlimited | SSO, audit, SLA, dedicated infra, VPC, compliance |

**Usage overage:**
- $0.10 per 1,000 tool calls beyond plan limit
- $5/mo per additional MCP (Free/Pro tiers)
- $0.50/GB data transfer beyond included

### Stream 2: MCP Registry (Network Effects — Recurring)

Third-party developers publish MCPs. We take a cut.

| Type | Developer Keeps | DataXLR8 Fee |
|------|----------------|-------------|
| Free MCPs | N/A | $0 (drives adoption) |
| Paid MCPs | 80% | 20% platform fee |
| Verified Premium MCPs | 85% | 15% fee (incentivize quality) |
| Enterprise MCPs | 75% | 25% fee (includes support/compliance) |

### Stream 3: Agency / Custom Builds (Funds Development)

Build custom AI systems for clients using our own MCPs. Revenue funds platform development.

| Engagement | Price | What Client Gets | Platform Benefit |
|-----------|-------|------------------|-----------------|
| Quick Win | $5K-15K | 1-2 custom agents | Battle-tests MCPs |
| Core Build | $25K-50K | Full AI system | Tests composability |
| Enterprise | $75K-200K | Multi-department system | Validates enterprise needs |
| Ongoing | $2K-10K/mo | Managed operations | Recurring revenue |

**Rule:** Every client build uses our open-source MCPs. Custom features get abstracted into configurable MCPs and open-sourced.

---

## Pricing Rationale

### Why These Numbers

| Decision | Rationale |
|----------|-----------|
| Free tier exists | MongoDB, Supabase, Vercel all have free tiers. Required for PLG. |
| $49/mo Pro | Lower than Vercel Pro ($20/dev/mo but adds up). Accessible for indie developers and small startups. |
| $199/mo Team | Competitive with Railway Team ($5/user + usage). Teams of 5+ make this worth it. |
| Enterprise custom | SSO/audit/SLA justifies $2K+/mo. MongoDB Atlas enterprise is $50K+/yr. |
| 20% marketplace cut | Apple takes 30%, Shopify takes variable. 20% is developer-friendly. |

### Comparison to Infrastructure Competitors

| Platform | Free | Pro | Team | Enterprise |
|----------|------|-----|------|-----------|
| **DataXLR8 Cloud** | 3 MCPs, 10K calls | $49/mo | $199/mo | Custom |
| Vercel | 100GB bandwidth | $20/dev/mo | $150/mo+ | Custom |
| Railway | $5 free credit | $5/user + usage | Custom | Custom |
| Supabase | 500MB DB | $25/mo | $599/mo | Custom |
| MongoDB Atlas | 512MB | $57/mo | Pay-as-you-go | $1K+/mo |

### Comparison to What Developers Pay Now (Self-Hosting)

| Self-Hosting MCPs | Cost | DataXLR8 Cloud | Savings |
|-------------------|------|---------------|---------|
| VPS (1-3 MCPs) | $5-20/mo + DevOps time | Free tier ($0) | Free + no DevOps |
| Small deployment (5-10 MCPs) | $50-100/mo + monitoring + security | Pro ($49/mo) | ~50% less + managed |
| Production (10+ MCPs) | $200-500/mo + team to manage | Team ($199/mo) | ~60% less + managed |
| Enterprise (50+ MCPs) | $2K-10K/mo + compliance + security team | Enterprise ($2K+/mo) | SSO, audit, SLA included |

---

## Unit Economics

| Metric | Target | Benchmark |
|--------|--------|-----------|
| CAC (PLG/self-serve) | <$30 | Supabase: ~$20, Vercel: ~$40 |
| CAC (enterprise) | <$5,000 | MongoDB Atlas: ~$10K |
| ARPU (self-serve) | $80/mo | — |
| ACV (enterprise) | $50,000+ | MongoDB: $50K+, Elastic: $100K+ |
| Gross margin (Cloud) | 70%+ | AWS: 30%, Vercel: 60%+, Supabase: 65%+ |
| Monthly churn (self-serve) | <5% | Infrastructure avg: 3-5% |
| NRR (enterprise) | 120%+ | MongoDB: 125%, Elastic: 115% |
| LTV:CAC (self-serve) | >10:1 | — |
| LTV:CAC (enterprise) | >5:1 | — |

### Why Margins Are High

- **Rust efficiency:** 10MB per MCP vs 110MB for Python/TS. We run 10x more MCPs per server.
- **No LLM costs:** BYOK — users bring their own AI keys. We host tools, not inference.
- **Shared infrastructure:** Multi-tenant gateway, shared DB pools, shared monitoring.
- **Binary caching:** Same 6.5MB binary serves all customers with different configs.

---

## Go-To-Market Strategy

### Phase 1: Win Developers (Month 1-6)

Developers choose infrastructure. They influence startup and enterprise decisions.

**Primary Channels:**

| Channel | Investment | Expected CAC | Timeline |
|---------|-----------|-------------|----------|
| **Open-source (GitHub)** | Dev time | $0 | Month 1 |
| **crates.io / Rust community** | Content | $0 | Month 1 |
| **Blog posts (benchmarks, tutorials)** | Writing time | <$10 | Month 1-3 |
| **Hacker News / Reddit** | Content | $0 | Month 2 |
| **Product Hunt** | One-time | <$5 | Month 3 |
| **Dev.to / Medium** | Content | <$10 | Month 2-6 |
| **Conference talks (RustConf, AI conf)** | Travel | <$50 | Month 4-6 |
| **YouTube (tutorials, benchmarks)** | Production | <$20 | Month 3-6 |

**Key Content:**
1. "Why We Rewrote MCP in Rust: 50x Faster Tool Calls" — benchmark post
2. "The Open-Source Clearbit Replacement (Built in Rust)" — Clearbit vacuum narrative
3. "Build an AI Agent in 5 Minutes with DataXLR8 MCPs" — tutorial
4. "MCP Infrastructure: The Missing Layer" — thought leadership
5. Weekly "MCP Monday" newsletter — ecosystem updates

**PLG Funnel:**
```
Open-source MCP (crates.io/GitHub) → Developer uses locally
  ↓ needs hosting
Cloud Free (3 MCPs, 10K calls) → Sees value
  ↓ hits limits
Cloud Pro ($49/mo) → Production workload
  ↓ team grows
Cloud Team ($199/mo) → Team features
  ↓ company grows
Enterprise (custom) → SSO, compliance, SLA
```

### Phase 2: Win Startups (Month 6-12)

Startups building AI-native products need MCP infrastructure. They don't want to manage it.

**Actions:**
1. Launch MCP Registry — let developers publish and discover MCPs
2. Partner with LangChain, CrewAI, AutoGen — "Runs great on DataXLR8"
3. YC batch outreach — "Free Pro tier for YC companies"
4. Startup program: $500 in Cloud credits for any funded startup
5. Integration guides for every major agent framework

### Phase 3: Win Enterprise (Month 12-24)

Enterprise contracts ($50K+ ACV) provide the revenue to scale.

**Actions:**
1. SOC 2 Type II certification
2. SSO/SAML + RBAC + audit logs
3. Enterprise sales team (2-3 people)
4. Partner with Accenture/Deloitte for implementation
5. Case studies: "How [Company] runs 50 AI agents on DataXLR8"
6. Data residency options (US, EU, APAC)

---

## Growth Benchmarks (From Comparable Companies)

| Company | Time to $1M ARR | Time to $10M ARR | Strategy |
|---------|----------------|------------------|----------|
| Supabase | ~12 months | ~24 months | Open-source Firebase → managed hosting |
| Vercel | ~18 months | ~30 months | Next.js (free) → hosting (paid) |
| Railway | ~18 months | ~36 months | Developer-first PaaS |
| PlanetScale | ~12 months | ~24 months | Open-source Vitess → managed DB |
| Neon | ~12 months | ~24 months | Open-source Postgres → serverless |

**Common pattern:** Open-source project gains traction → managed hosting launches → $1M ARR in 12-18 months → $10M ARR in 24-36 months.

DataXLR8 follows this playbook with MCP-specific infrastructure.

---

## Revenue Projections

| Metric | Month 6 | Month 12 | Month 24 | Month 36 |
|--------|---------|----------|----------|----------|
| **Cloud MRR** | $5K | $20K | $150K | $500K |
| **Agency revenue** | $15K/mo | $25K/mo | $10K/mo (winding down) | $0 |
| **Registry revenue** | $0 | $1K/mo | $20K/mo | $100K/mo |
| **Enterprise ACV** | $0 | $50K/yr (1 contract) | $500K/yr (10 contracts) | $2.5M/yr (50 contracts) |
| **Total ARR** | $240K | $600K | $4M | $15M+ |

---

## Pricing Evolution

### Now (Launch)
- Generous free tier to drive adoption
- Simple per-MCP + tool call pricing
- No enterprise tier (not ready yet)

### 6 Months
- Introduce Team tier
- Usage-based overage pricing
- MCP Registry with paid MCPs

### 12 Months
- Enterprise tier (SSO, audit, SLA)
- Volume discounts for large deployments
- Custom pricing for 100+ MCP deployments

### 24 Months
- Committed-use discounts (annual contracts)
- Reserved capacity pricing
- Marketplace with sophisticated revenue share

---

## Sources
- [SaaStr: The Great SaaS Price Surge of 2025](https://www.saastr.com/the-great-price-surge-of-2025/)
- [Metronome: State of Usage-Based Pricing 2025](https://metronome.com/state-of-usage-based-pricing-2025)
- [BVP: AI Pricing Playbook](https://www.bvp.com/atlas/the-ai-pricing-and-monetization-playbook)
- [Chargebee: Pricing AI Agents Playbook 2026](https://www.chargebee.com/blog/pricing-ai-agents-playbook/)
- MongoDB, Supabase, Vercel, Railway — public pricing pages
- [GenesysGrowth: CAC Benchmarks 2026](https://genesysgrowth.com/blog/customer-acquisition-cost-benchmarks-for-marketing-leaders)
