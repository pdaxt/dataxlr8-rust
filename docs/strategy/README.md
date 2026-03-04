# DataXLR8 Strategy Documents

**DataXLR8: AI Solutions That Actually Work — Done For You**

The AI-first business operating system. Self-serve agent marketplace + done-for-you custom AI builds, all running on MCP-native Rust infrastructure. No spreadsheets. No PowerPoint. AI-first from the ground up, human-in-the-loop where it matters.

_Last updated: 2026-03-04_

## Documents

| Document | Description |
|----------|-------------|
| [MARKET-LANDSCAPE.md](MARKET-LANDSCAPE.md) | Competitive analysis: Apollo, ZoomInfo, Clearbit, Lusha, Clay + AI agent platforms |
| [AI-AGENT-LANDSCAPE.md](AI-AGENT-LANDSCAPE.md) | AI agent market size, adoption trends, platform economics |
| [MCP-ECOSYSTEM.md](MCP-ECOSYSTEM.md) | How MCP powers the agent marketplace — AAIF, enterprise requirements |
| [PRICING-AND-GTM.md](PRICING-AND-GTM.md) | Credit-based pricing validation, PLG benchmarks, growth playbook |
| [FEATURE-BLUEPRINT.md](FEATURE-BLUEPRINT.md) | 5 agent pillars, 40+ agents, MCP tool mappings for Rust backend |
| [EXECUTION-PLAN.md](EXECUTION-PLAN.md) | 90-day plan: Rust MCPs as agent marketplace backend |

## The Product (What We Sell)

An AI agent marketplace with 5 pillars:
- **Discovery** — Lead enrichment, company scanning, prospecting
- **Sales** — Email sequences, ice breakers, proposals, meeting prep
- **Intelligence** — Competitor monitoring, market sizing, trend analysis
- **Content** — Blog posts, social media, case studies, ad copy
- **Operations** — Meeting summaries, document analysis, workflow automation

## The Tech (How It Works)

- **Frontend:** Next.js web app + Chrome Extension
- **Agent Runtime:** Rust MCP servers (sub-millisecond, 6.5MB binaries)
- **AI Layer:** BYOK (Bring Your Own Keys) — Claude, GPT, Grok, Ollama
- **Data:** PostgreSQL + Redis + external APIs (enrichment, scraping)
- **Payments:** Stripe (subscriptions + credit packs)
- **Gateway:** Single HTTP endpoint spawning all Rust MCPs

## The Business Model

| Tier | Price | Credits/mo |
|------|-------|-----------|
| Free | $0 | 50 |
| Starter | $29/mo | 300 |
| Pro | $79/mo | 1,500 |
| Scale | $199/mo | 5,000 |
| Credit Packs | $9-$499 | 100-10,000 |

## Competitors

| Competitor | Focus | Our Edge |
|------------|-------|----------|
| Apollo.io | Lead data + sequences | Simpler, AI-native agents, not just data |
| ZoomInfo | Enterprise B2B data | 10x cheaper, transparent pricing |
| Clearbit/Breeze | HubSpot-only enrichment | Multi-platform, BYOK, more agent types |
| Lusha | Contact data | Broader agent catalog beyond enrichment |
| Clay | Waterfall enrichment | Pre-built agents (no spreadsheet UX needed) |
