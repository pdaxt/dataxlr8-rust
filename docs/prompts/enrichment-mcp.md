# Agent Prompt: dataxlr8-enrichment-mcp

## What This Is

The Clearbit replacement. THE WEDGE. Lead enrichment using free and freemium data sources.

**Repo:** pdaxt/dataxlr8-enrichment-mcp
**Path:** /Users/pran/Projects/dataxlr8-enrichment-mcp
**Status:** Compiles (12 tools). Provider refactor in progress.

## Current State

- 12 tools implemented in monolithic tools/mod.rs (1306 lines)
- Uses hickory-resolver for DNS/MX, raw TcpStream for SMTP, reqwest for HTTP
- Embedded DISPOSABLE_DOMAINS list
- PostgreSQL cache in enrichment.lookups table

## What Needs Doing

### Provider Refactor (IN PROGRESS)

Restructure from monolithic into provider-based waterfall:

```
src/
├── providers/
│   ├── mod.rs           # Provider trait + ProviderTier enum (Free/Freemium/Paid)
│   ├── dns.rs           # Free: MX, A, AAAA, NS, TXT via hickory-resolver
│   ├── smtp.rs          # Free: SMTP handshake verification
│   ├── http.rs          # Free: Website scraping, meta tags, headers
│   ├── whois.rs         # Free: Domain registration data
│   ├── github.rs        # Free: GitHub API (needs GITHUB_TOKEN)
│   ├── social.rs        # Free: Social media URL patterns
│   ├── hunter.rs        # Freemium: Hunter.io email finder (HUNTER_API_KEY)
│   ├── emailrep.rs      # Free: Email reputation scoring
│   ├── fullcontact.rs   # Freemium: stub
│   └── pdl.rs           # Freemium: stub
├── waterfall.rs         # Try providers cheapest-first, merge results
├── merge.rs             # Multi-provider data merge with confidence scoring
├── cache.rs             # PostgreSQL cache check/store with TTL
└── tools/
    └── mod.rs           # Thin MCP tool wrappers calling waterfall
```

### Provider Trait

```rust
#[async_trait]
pub trait EnrichmentProvider: Send + Sync {
    fn name(&self) -> &str;
    fn tier(&self) -> ProviderTier;  // Free, Freemium, Paid
    async fn enrich_person(&self, first_name: &str, last_name: &str, domain: &str) -> Option<PersonData> { None }
    async fn enrich_company(&self, domain: &str) -> Option<CompanyData> { None }
    async fn find_emails(&self, first_name: &str, last_name: &str, domain: &str) -> Vec<EmailCandidate> { vec![] }
    async fn verify_email(&self, email: &str) -> Option<EmailVerification> { None }
    async fn domain_info(&self, domain: &str) -> Option<serde_json::Value> { None }
}
```

### API Keys (env vars, skip if missing)

- GITHUB_TOKEN — GitHub API (5K req/hr)
- HUNTER_API_KEY — Hunter.io email finder
- EMAILREP_API_KEY — EmailRep (optional, higher limits)

### Priority Order

1. Extract existing DNS/SMTP/HTTP code into providers
2. Add Provider trait + waterfall orchestration
3. Add github.rs provider
4. Add hunter.rs provider
5. Add emailrep.rs provider
6. Stub fullcontact.rs and pdl.rs

### Done When

- `cargo build` passes
- All 12 tools still work
- Provider architecture is pluggable
- git push to GitHub

## 12 Tools

1. `enrich_person` — name + company → email, title, LinkedIn
2. `enrich_company` — domain → size, tech stack, socials
3. `verify_email` — SMTP handshake + MX + disposable check
4. `domain_emails` — pattern detection + SMTP verify
5. `search_people` — FTS on cached lookups
6. `reverse_domain` — WHOIS + reverse DNS
7. `bulk_enrich` — batch version
8. `tech_stack` — HTTP headers, JS libs, DNS
9. `hiring_signals` — careers page analysis
10. `social_profiles` — cross-platform URL patterns
11. `enrichment_stats` — usage counts
12. `cache_lookup` — direct cache check
