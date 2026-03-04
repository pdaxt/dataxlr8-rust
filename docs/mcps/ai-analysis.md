# BRD: dataxlr8-ai-analysis-mcp

**Phase:** 5 | **Status:** NOT STARTED | **PG Schema:** `ai_analysis`
**External Dependency:** Anthropic Claude API
**Source:** `apps/web/lib/anthropic.ts` exports only a client instance and model constants — NO functions.

## Purpose
AI-powered analysis — scan websites for AI readiness, generate reports, score opportunities.

## Existing Source

`anthropic.ts` contains:
```typescript
export const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
export const MODELS = { /* model names */ };
```

The actual analysis logic is embedded in API routes (e.g., `app/api/scan/route.ts`), NOT in a reusable library. Tool definitions for this MCP need to be designed from scratch based on the scanner's API route behavior.

## Target Tools: TBD

Tools need to be defined by analyzing the scan API routes. Placeholder:

| # | Tool | Description | Confidence |
|---|------|-------------|------------|
| 1 | `analyze_website` | Scan website for AI opportunities | NEEDS DESIGN |
| 2 | `generate_report` | Generate AI opportunity report | NEEDS DESIGN |
| 3 | `get_analysis` | Retrieve stored analysis | NEEDS DESIGN |

**Action required:** Read `apps/web/app/api/scan/` routes to extract actual analysis logic before building this MCP.

## Acceptance Criteria
- [ ] Actual tool definitions grounded in scanner API routes
- [ ] Build, Claude API integration, Claude Code integration
