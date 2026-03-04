# DataXLR8 Feature Blueprint — Infrastructure Platform

_Updated: 2026-03-04_

## Two Product Lines

1. **Open-Source Rust MCPs** — free, drives adoption
2. **DataXLR8 Cloud** — managed hosting, drives revenue

---

## Product 1: Open-Source Rust MCP Servers

### The Catalog

Every MCP below is a standalone Rust binary. MIT licensed. Published to crates.io and GitHub.

#### Business Operations MCPs

| MCP Server | Tools | Domain | Replaces |
|------------|-------|--------|----------|
| `dataxlr8-crm-mcp` | 10 | Contacts, deals, pipeline, activities | Salesforce API, HubSpot API |
| `dataxlr8-enrichment-mcp` | 12 | Lead/company data enrichment, verification | Apollo, ZoomInfo, Clearbit |
| `dataxlr8-email-mcp` | 6 | Send, receive, templates, tracking | SendGrid API, Resend API |
| `dataxlr8-finance-mcp` | 8 | Invoicing, expenses, tax, accounting | QuickBooks API, Xero API |
| `dataxlr8-payments-mcp` | 5 | Stripe, Razorpay, payment processing | Stripe SDK, payment wrappers |
| `dataxlr8-hr-mcp` | 8 | Employees, leave, payroll, performance | BambooHR API, Gusto API |
| `dataxlr8-calendar-mcp` | 5 | Events, availability, scheduling | Google Calendar API |
| `dataxlr8-documents-mcp` | 6 | Generate, analyze, sign, store | DocuSign API, Google Docs API |

#### Intelligence & Data MCPs

| MCP Server | Tools | Domain | Replaces |
|------------|-------|--------|----------|
| `dataxlr8-intelligence-mcp` | 10 | Market research, competitor tracking | Crayon, Similarweb |
| `dataxlr8-scraper-mcp` | 6 | Web scraping, data extraction | ScrapingBee, Apify |
| `dataxlr8-analytics-mcp` | 6 | KPIs, dashboards, reports | Tableau API, Metabase |
| `dataxlr8-search-mcp` | 4 | Full-text search, semantic search | Algolia, Elasticsearch |

#### Content & Communication MCPs

| MCP Server | Tools | Domain | Replaces |
|------------|-------|--------|----------|
| `dataxlr8-content-mcp` | 10 | Blog, social, SEO, ad copy | Jasper API, Copy.ai |
| `dataxlr8-social-mcp` | 6 | Post to Twitter, LinkedIn, scheduling | Buffer API, Hootsuite |
| `dataxlr8-communication-mcp` | 5 | WhatsApp, SMS, chat | Twilio API |
| `dataxlr8-notifications-mcp` | 4 | Push, email, in-app alerts | OneSignal, Firebase |

#### Sales & Marketing MCPs

| MCP Server | Tools | Domain | Replaces |
|------------|-------|--------|----------|
| `dataxlr8-sales-mcp` | 10 | Sequences, proposals, scripts | Outreach, SalesLoft |
| `dataxlr8-marketing-mcp` | 8 | Campaigns, segmentation, A/B testing | Mailchimp, HubSpot Marketing |
| `dataxlr8-seo-mcp` | 5 | Keywords, rankings, optimization | Ahrefs API, Surfer SEO |

#### Infrastructure MCPs

| MCP Server | Tools | Domain | Replaces |
|------------|-------|--------|----------|
| `dataxlr8-gateway-mcp` | 5 | Routing, health, auth, rate limiting | API gateways |
| `dataxlr8-auth-mcp` | 6 | OAuth, JWT, sessions, RBAC | Auth0, Clerk |
| `dataxlr8-storage-mcp` | 5 | File upload, S3, CDN | AWS S3 SDK |
| `dataxlr8-queue-mcp` | 4 | Job queue, scheduling, retries | Bull, Celery |
| `dataxlr8-cache-mcp` | 3 | Redis caching, invalidation | Redis wrappers |

### Tool Count Summary

| Category | MCPs | Total Tools |
|----------|------|-------------|
| Business Operations | 8 | 60 |
| Intelligence & Data | 4 | 26 |
| Content & Communication | 4 | 25 |
| Sales & Marketing | 3 | 23 |
| Infrastructure | 5 | 23 |
| **Total** | **24** | **157** |

### Shared Core Library: `dataxlr8-mcp-core`

Every MCP depends on this shared crate:

```rust
// What dataxlr8-mcp-core provides:
pub mod db {
    // PostgreSQL connection pool (sqlx)
    pub async fn connect(config: &Config) -> Pool<Postgres>;
}

pub mod config {
    // TOML-based configuration per tenant
    pub fn load(path: &str) -> Config;
}

pub mod error {
    // Standardized error types across all MCPs
    pub enum McpError { NotFound, Unauthorized, RateLimit, Internal }
}

pub mod logging {
    // Structured tracing
    pub fn init(service_name: &str);
}

pub mod auth {
    // API key + JWT validation
    pub async fn validate(token: &str) -> Result<Claims>;
}

pub mod metrics {
    // Prometheus metrics for monitoring
    pub fn tool_call_duration(mcp: &str, tool: &str, duration: Duration);
    pub fn tool_call_count(mcp: &str, tool: &str);
}
```

### Example MCP: dataxlr8-crm-mcp

```rust
use dataxlr8_mcp_core::{db, config, error::McpError};
use rmcp::{tool, ServerHandler};

#[derive(ServerHandler)]
struct CrmMcp {
    pool: Pool<Postgres>,
    config: CrmConfig,
}

#[tool(description = "Create a new contact with name, email, company, and custom fields")]
async fn create_contact(&self, name: String, email: String, company: Option<String>,
                        fields: Option<HashMap<String, Value>>) -> Result<Contact, McpError>;

#[tool(description = "Search contacts by any field with pagination")]
async fn search_contacts(&self, query: String, limit: Option<i32>,
                         offset: Option<i32>) -> Result<Vec<Contact>, McpError>;

#[tool(description = "Create or update a deal in the pipeline")]
async fn upsert_deal(&self, contact_id: Uuid, title: String, value: f64,
                     stage: String) -> Result<Deal, McpError>;

#[tool(description = "Move a deal to a different pipeline stage")]
async fn move_deal(&self, deal_id: Uuid, stage: String,
                   notes: Option<String>) -> Result<Deal, McpError>;

#[tool(description = "Log an activity (call, email, meeting) against a contact or deal")]
async fn log_activity(&self, entity_id: Uuid, activity_type: ActivityType,
                      notes: String) -> Result<Activity, McpError>;

// ... 5 more tools
```

---

## Product 2: DataXLR8 Cloud Platform

### Cloud Features

#### Deployment Engine

| Feature | Description |
|---------|-------------|
| One-command deploy | `dxlr8 deploy crm-mcp --config client.toml` |
| Multi-MCP deploy | `dxlr8 deploy crm-mcp email-mcp finance-mcp` |
| Auto-gateway | Single endpoint for all deployed MCPs |
| Config management | TOML configs per tenant, hot-reload |
| Version pinning | `dxlr8 deploy crm-mcp@2.1.0` |
| Rollback | `dxlr8 rollback crm-mcp` instant rollback |

#### Scaling & Performance

| Feature | Description |
|---------|-------------|
| Auto-scaling | Scale MCP instances based on tool call volume |
| Edge deployment | Deploy MCPs to edge regions for <50ms globally |
| Load balancing | Distribute tool calls across instances |
| Connection pooling | Share DB connections across MCP instances |
| Cold start optimization | Rust binaries start in <5ms |

#### Monitoring & Observability

| Feature | Description |
|---------|-------------|
| Dashboard | Real-time tool call metrics per MCP |
| Latency tracking | p50/p95/p99 per tool |
| Error alerting | Slack/email/webhook alerts on errors |
| Structured logs | Searchable, filterable log streams |
| Cost tracking | Tool calls, compute, storage per MCP |
| Usage analytics | Which tools used most, by which agents |

#### Security

| Feature | Free | Pro | Team | Enterprise |
|---------|------|-----|------|-----------|
| API key auth | ✓ | ✓ | ✓ | ✓ |
| JWT tokens | — | ✓ | ✓ | ✓ |
| Rate limiting | Basic | Custom | Custom | Custom |
| IP allowlisting | — | — | ✓ | ✓ |
| SSO/SAML | — | — | — | ✓ |
| RBAC | — | — | ✓ | ✓ |
| Audit logs | — | — | — | ✓ |
| Data residency | — | — | — | ✓ |
| VPC peering | — | — | — | ✓ |
| SOC 2 report | — | — | — | ✓ |

#### Developer Experience

| Feature | Description |
|---------|-------------|
| `dxlr8` CLI | Install, run, deploy, monitor — all from terminal |
| Local dev mode | Run MCPs locally with `dxlr8 run` |
| Hot reload | Config changes apply without restart |
| Test mode | Mock external APIs for testing |
| SDK (Rust) | Build custom MCPs with `dataxlr8-mcp-core` |
| SDK (Python) | Python wrapper for building MCPs (via FFI or process) |
| API playground | Try any tool call in the browser |
| Webhooks | Trigger on events (deploy, error, threshold) |

### MCP Registry Features

| Feature | Description |
|---------|-------------|
| Search | Find MCPs by keyword, category, language |
| Versions | Semantic versioning, changelog per release |
| Verification | DataXLR8-verified badge for quality MCPs |
| Ratings | Community ratings and reviews |
| Downloads | Track install counts |
| Publishing | `dxlr8 publish` from any MCP project |
| Revenue share | 80/20 split (developer/platform) for paid MCPs |
| Categories | Business, Data, Content, Infrastructure, etc. |
| Dependencies | MCP dependency resolution |

---

## `dxlr8` CLI Specification

```
USAGE:
    dxlr8 <COMMAND>

COMMANDS:
    init        Initialize a new MCP project
    add         Add an MCP to your project
    run         Run MCPs locally (dev mode)
    deploy      Deploy MCPs to DataXLR8 Cloud
    status      Check deployment status
    logs        Stream logs from deployed MCPs
    rollback    Rollback to previous version
    config      Manage MCP configurations
    registry    Search, install, publish MCPs
    monitor     Open monitoring dashboard
    auth        Login, logout, API keys
    upgrade     Upgrade CLI and MCPs

EXAMPLES:
    dxlr8 init my-agents
    dxlr8 add crm-mcp enrichment-mcp email-mcp
    dxlr8 run                              # Local dev
    dxlr8 deploy --region us-east-1        # Deploy to cloud
    dxlr8 registry search "email"          # Find MCPs
    dxlr8 registry publish                 # Publish your MCP
    dxlr8 logs crm-mcp --follow            # Stream logs
    dxlr8 monitor                          # Open dashboard
```

---

## Development Phases

### Phase 1 (Month 1-2): Open-Source Core — 10 MCPs

The foundation. Pure open-source, no cloud yet.

| MCP | Priority | Why First |
|-----|----------|-----------|
| `crm-mcp` | P0 | Most universally needed |
| `enrichment-mcp` | P0 | Unique value, competitive wedge |
| `email-mcp` | P0 | Every agent sends email |
| `scraper-mcp` | P0 | Data collection backbone |
| `gateway-mcp` | P0 | Required for multi-MCP setups |
| `finance-mcp` | P1 | Broad appeal |
| `content-mcp` | P1 | Marketing teams |
| `intelligence-mcp` | P1 | Competitive intelligence |
| `auth-mcp` | P1 | Security baseline |
| `calendar-mcp` | P1 | Scheduling is universal |

### Phase 2 (Month 3-4): Cloud Alpha — 15 MCPs + Hosting

Start monetizing.

| Feature | Priority |
|---------|----------|
| `dxlr8 deploy` command | P0 |
| Gateway with auth + routing | P0 |
| Usage metering | P0 |
| Stripe billing | P0 |
| Monitoring dashboard | P1 |
| 5 more MCPs (sales, marketing, docs, social, payments) | P1 |

### Phase 3 (Month 5-8): Registry + Community — 25+ MCPs

Network effects begin.

| Feature | Priority |
|---------|----------|
| MCP Registry (search, install, publish) | P0 |
| Community contribution workflow | P0 |
| Auto-scaling | P1 |
| Edge deployment | P1 |
| Team features | P1 |
| 10+ community MCPs | P1 |

### Phase 4 (Month 9-18): Enterprise — 30+ MCPs

Revenue at scale.

| Feature | Priority |
|---------|----------|
| SSO/SAML | P0 |
| RBAC + audit logs | P0 |
| SOC 2 Type II | P0 |
| Data residency | P1 |
| VPC peering | P1 |
| Dedicated infrastructure | P1 |
| SLA framework | P1 |

---

## Architecture: How Cloud Works

```
Developer: dxlr8 deploy crm-mcp enrichment-mcp email-mcp
                          │
                          ▼
              ┌───────────────────────┐
              │   DataXLR8 Cloud API  │
              │   (Rust, auth, billing│
              └───────────┬───────────┘
                          │
            ┌─────────────┼─────────────┐
            ▼             ▼             ▼
    ┌──────────┐  ┌──────────┐  ┌──────────┐
    │ crm-mcp  │  │enrich-mcp│  │email-mcp │
    │ (Rust)   │  │ (Rust)   │  │ (Rust)   │
    │ 6.5MB    │  │ 6.5MB    │  │ 6.5MB    │
    └────┬─────┘  └────┬─────┘  └────┬─────┘
         └──────────────┼──────────────┘
                        │
                ┌───────┴───────┐
                │   GATEWAY     │  ← Auth, routing, metering
                │   (Rust)      │  ← Single HTTPS endpoint
                └───────┬───────┘
                        │
         https://org.dataxlr8.cloud/gateway
                        │
              Any AI agent connects here
              (Claude, GPT, LangChain, etc.)
```

Each MCP runs as an isolated process. Gateway handles auth, routing, rate limiting, and billing. Everything in Rust. Everything fast.
