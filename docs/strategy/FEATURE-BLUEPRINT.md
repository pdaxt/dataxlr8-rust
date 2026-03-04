# DataXLR8 Feature Blueprint — AI Agent Marketplace

_Research date: 2026-03-04_

40+ AI agents across 5 pillars, with Rust MCP tool mappings for the backend.

---

## Architecture: How Agents Map to Rust MCPs

```
User clicks "Run Agent" in Web UI / Chrome Extension / API
  → Next.js API route validates credits + auth
  → Agent Orchestrator selects MCP tools needed
  → Gateway routes to Rust MCP server(s) via stdio
  → MCP executes: API calls, scraping, LLM inference, data enrichment
  → Results cached in Redis, stored in PostgreSQL
  → Credits deducted, response streamed to user
```

Each Rust MCP server handles a domain (enrichment, intelligence, content, etc.) and exposes tools that agents compose together.

### Rust MCP Server Map

| MCP Server | Domain | Tools | Agent Pillars Served |
|------------|--------|-------|---------------------|
| `dataxlr8-enrichment-mcp` | Lead/company data | 12 | Discovery, Sales |
| `dataxlr8-intelligence-mcp` | Market research | 10 | Intelligence |
| `dataxlr8-content-mcp` | Content generation | 10 | Content |
| `dataxlr8-sales-mcp` | Sales automation | 10 | Sales |
| `dataxlr8-operations-mcp` | Workflow/docs | 10 | Operations |
| `dataxlr8-scraper-mcp` | Web scraping engine | 6 | All (data collection) |
| `dataxlr8-credits-mcp` | Usage metering | 4 | All (billing) |
| `dataxlr8-gateway-mcp` | Routing + health | 3 | Infrastructure |

---

## PILLAR 1: DISCOVERY (Lead Generation)

_Competitors: Apollo ($49-149/user), ZoomInfo ($14.9K+/yr), Lusha ($49-79/user)_

| Agent | Credits | Rust MCP Tools Used | Data Sources |
|-------|---------|-------------------|-------------|
| **Lead Enricher** | 15 | `enrichment.enrich_person`, `scraper.linkedin_profile` | LinkedIn, Clearbit-like APIs, public records |
| **Company Scanner** | 25 | `enrichment.enrich_company`, `scraper.website_tech_stack` | Company websites, Crunchbase, LinkedIn |
| **LinkedIn Prospector** | 20 | `enrichment.search_people`, `scraper.linkedin_search` | LinkedIn Sales Nav API, Google |
| **Domain Hunter** | 30 | `enrichment.domain_emails`, `enrichment.verify_email` | DNS records, SMTP verification, pattern matching |
| **Website Visitor ID** | 50 | `enrichment.reverse_ip`, `enrichment.enrich_company` | IP → Company lookup, pixel tracking |
| **Job Board Scanner** | 15 | `scraper.job_boards`, `intelligence.analyze_hiring` | Indeed, LinkedIn Jobs, Greenhouse |
| **Funding Tracker** | 10 | `intelligence.funding_alerts`, `scraper.crunchbase` | Crunchbase, PitchBook, news |
| **Tech Stack Detector** | 10 | `scraper.website_tech_stack` | BuiltWith, Wappalyzer approach |

### Key Enrichment MCP Tools

```rust
// dataxlr8-enrichment-mcp tools
#[tool(description = "Enrich a person by name + company → email, phone, LinkedIn, title")]
async fn enrich_person(name: String, company: Option<String>) -> EnrichedPerson;

#[tool(description = "Full company profile: size, funding, tech stack, key people")]
async fn enrich_company(domain: String) -> CompanyProfile;

#[tool(description = "Find all email addresses for a domain")]
async fn domain_emails(domain: String) -> Vec<EmailResult>;

#[tool(description = "Verify if an email is deliverable")]
async fn verify_email(email: String) -> EmailVerification;

#[tool(description = "Search for people by title, company, location")]
async fn search_people(query: PeopleSearchQuery) -> Vec<PersonResult>;

#[tool(description = "Reverse IP lookup → company identification")]
async fn reverse_ip(ip: String) -> Option<CompanyMatch>;
```

---

## PILLAR 2: SALES (Closing Deals)

_Competitors: Outreach ($100/user), SalesLoft ($75/user), Lemlist ($59/user)_

| Agent | Credits | Rust MCP Tools Used | AI Model Used |
|-------|---------|-------------------|-------------|
| **Ice Breaker Generator** | 5 | `enrichment.enrich_person`, `sales.generate_opener` | LLM (Claude/GPT) |
| **Email Sequence Writer** | 20 | `enrichment.enrich_person`, `sales.generate_sequence` | LLM |
| **Objection Handler** | 5 | `sales.handle_objection` | LLM |
| **Proposal Generator** | 30 | `enrichment.enrich_company`, `content.generate_proposal` | LLM + templates |
| **Meeting Prep Agent** | 15 | `enrichment.enrich_person`, `enrichment.enrich_company`, `intelligence.recent_news` | LLM |
| **Follow-up Composer** | 5 | `sales.compose_followup` | LLM |
| **LinkedIn Message Writer** | 5 | `enrichment.enrich_person`, `sales.generate_linkedin_msg` | LLM |
| **Call Script Generator** | 10 | `enrichment.enrich_person`, `sales.generate_call_script` | LLM |

### Key Sales MCP Tools

```rust
// dataxlr8-sales-mcp tools
#[tool(description = "Generate personalized cold email opener from enriched data")]
async fn generate_opener(person: EnrichedPerson, context: SalesContext) -> String;

#[tool(description = "Generate 5-7 email sequence for a persona")]
async fn generate_sequence(person: EnrichedPerson, product: ProductInfo) -> EmailSequence;

#[tool(description = "Generate objection response based on common patterns")]
async fn handle_objection(objection: String, context: SalesContext) -> String;

#[tool(description = "Compose context-aware follow-up email")]
async fn compose_followup(thread: EmailThread, context: SalesContext) -> String;
```

---

## PILLAR 3: INTELLIGENCE (Market Research)

_Competitors: Crayon ($30K+/yr), Klue (enterprise), Similarweb ($149+/mo)_

| Agent | Credits | Rust MCP Tools Used | Data Sources |
|-------|---------|-------------------|-------------|
| **Competitor Monitor** | 50 | `intelligence.monitor_competitor`, `scraper.website_changes` | Websites, news, social, job boards |
| **AI Opportunity Scanner** | FREE | `intelligence.scan_opportunities` | Website analysis, industry benchmarks |
| **Market Size Estimator** | 40 | `intelligence.estimate_market`, `scraper.industry_reports` | Public data, reports, census |
| **Trend Analyzer** | 30 | `intelligence.analyze_trends`, `scraper.social_mentions` | News, Twitter, Reddit, Google Trends |
| **Pricing Intelligence** | 25 | `intelligence.track_pricing`, `scraper.pricing_pages` | Competitor websites, G2, Capterra |
| **Review Analyzer** | 20 | `intelligence.analyze_reviews`, `scraper.review_sites` | G2, Capterra, Trustpilot |
| **Patent Monitor** | 35 | `intelligence.monitor_patents`, `scraper.patent_db` | USPTO, Google Patents |
| **Regulatory Scanner** | 30 | `intelligence.scan_regulations` | Government sites, legal databases |

### Key Intelligence MCP Tools

```rust
// dataxlr8-intelligence-mcp tools
#[tool(description = "Monitor competitor: pricing changes, feature launches, hiring, news")]
async fn monitor_competitor(domain: String) -> CompetitorReport;

#[tool(description = "Scan a business for AI automation opportunities")]
async fn scan_opportunities(website: String) -> OpportunityReport;

#[tool(description = "Estimate TAM/SAM/SOM for a market")]
async fn estimate_market(description: String, geography: Option<String>) -> MarketEstimate;

#[tool(description = "Track pricing page changes for a competitor")]
async fn track_pricing(domain: String) -> PricingSnapshot;
```

---

## PILLAR 4: CONTENT (Marketing)

_Competitors: Jasper ($49-125/user), Copy.ai ($49/user), Surfer SEO ($89/mo)_

| Agent | Credits | Rust MCP Tools Used | Output |
|-------|---------|-------------------|--------|
| **Blog Post Generator** | 25 | `content.generate_blog`, `intelligence.keyword_research` | 1500-3000 word SEO article |
| **Social Media Repurposer** | 15 | `content.repurpose_content` | 10 posts from 1 piece |
| **Case Study Writer** | 30 | `content.generate_case_study`, `enrichment.enrich_company` | Full case study + metrics |
| **Landing Page Copy** | 20 | `content.generate_landing_page` | Headline, body, CTAs |
| **Email Newsletter Writer** | 15 | `content.generate_newsletter` | Weekly/monthly draft |
| **Video Script Generator** | 20 | `content.generate_video_script` | YouTube/TikTok ready |
| **SEO Keyword Researcher** | 15 | `intelligence.keyword_research` | Keyword clusters + difficulty |
| **Ad Copy Generator** | 10 | `content.generate_ad_copy` | Google/Meta ad variants |

---

## PILLAR 5: OPERATIONS (Automation)

_Competitors: Notion AI ($10/user), Otter.ai ($16.99/user), Zapier ($29.99+/mo)_

| Agent | Credits | Rust MCP Tools Used | Output |
|-------|---------|-------------------|--------|
| **Meeting Summarizer** | 15 | `operations.summarize_meeting` | Summary + action items |
| **Document Analyzer** | 20 | `operations.analyze_document` | Key insights + entities |
| **Data Cleaner** | 25 | `operations.clean_data` | Standardized CSV/JSON |
| **Report Generator** | 30 | `operations.generate_report` | Formatted report + charts |
| **Workflow Builder** | 20 | `operations.design_workflow` | Automation blueprint |
| **Email Categorizer** | 10 | `operations.categorize_emails` | Sorted + prioritized inbox |
| **Contract Analyzer** | 25 | `operations.analyze_contract` | Key terms + risks |
| **Support Ticket Router** | 15 | `operations.route_ticket` | Category + priority + assignee |

---

## Agent Development Phases

### Phase 1 (Month 1-2): Core Revenue Agents — 5 agents
Revenue-generating agents that prove product-market fit.

| Agent | Why First | Revenue Potential |
|-------|-----------|------------------|
| Lead Enricher | Core use case, direct competitor to Apollo | High — every sales team needs this |
| Company Scanner | Pairs with enrichment, high perceived value | High |
| Competitor Monitor | Sticky — users check weekly | Medium-High |
| Ice Breaker Generator | Low cost to build, high usage frequency | Medium |
| Email Sequence Writer | Saves hours, easy to demonstrate ROI | High |

### Phase 2 (Month 3-4): Growth Agents — 5 agents
Expand agent catalog to increase engagement.

| Agent | Why Next | Growth Impact |
|-------|----------|--------------|
| LinkedIn Prospector | Direct lead gen, Chrome Extension hook | High acquisition |
| Job Board Scanner | Unique angle — hiring signals = buying intent | Medium |
| Meeting Prep Agent | Daily use case for sales teams | Retention |
| Social Media Repurposer | Content marketing teams love this | New segment |
| Blog Post Generator | SEO + content marketing crossover | New segment |

### Phase 3 (Month 5-6): Enterprise Agents — 5 agents
Higher-value agents for larger teams.

| Agent | Why Now | Enterprise Value |
|-------|---------|-----------------|
| Website Visitor ID | Requires pixel — enterprise setup | High ARPU |
| Market Size Estimator | Strategy teams pay premium | High credit usage |
| Pricing Intelligence | Competitive teams need this ongoing | Sticky |
| Contract Analyzer | Legal/ops teams, high trust requirement | Enterprise gate |
| Report Generator | Replaces analyst hours | High perceived value |

### Phase 4 (Month 7-12): Platform Expansion
Turn from tool to platform.

| Feature | What | Why |
|---------|------|-----|
| Custom Agent Builder | Let users create their own agents | Platform economics |
| Agent Chaining | Connect agents in workflows (enrichment → sequence → send) | 10x value |
| Community Marketplace | Third-party agents | Network effects |
| White-label | Agencies rebrand as their own | Enterprise revenue |

---

## Feature Count Summary

| Pillar | Agents | Rust MCP Tools | Phase |
|--------|--------|---------------|-------|
| Discovery | 8 | 12 | 1-3 |
| Sales | 8 | 10 | 1-2 |
| Intelligence | 8 | 10 | 1-3 |
| Content | 8 | 10 | 2-3 |
| Operations | 8 | 10 | 3-4 |
| **Total** | **40** | **52** | |

---

## Free Tools (Top of Funnel)

These are ungated — no signup required:

| Tool | Purpose | Conversion Hook |
|------|---------|----------------|
| AI Opportunity Scanner | Analyze any business for AI savings | "Want to implement these? Sign up" |
| Email Verifier Widget | Embeddable on any site | Powered by DataXLR8 branding |
| Chrome Extension | LinkedIn profile enrichment on hover | 10 free/day, upgrade for more |
| API Playground | Try any agent via API | 50 free calls |
