# BRD: dataxlr8-deals-mcp

**Phase:** 3
**Status:** NOT STARTED
**PG Schema:** `deals`
**Source:** `apps/web/lib/google-sheets.ts` (Google Sheets `Deals` tab) + `mcp-servers/dataxlr8_deals_mcp`

---

## Purpose

Sales pipeline management — deals, stages, activities, enrichment data. Track deals from lead to close.

## Tools (6)

| # | Tool | Params | Returns | Source Function |
|---|------|--------|---------|----------------|
| 1 | `list_deals` | `employee_id?`, `status?`, `stage?`, `limit?` | Array of Deal | `getDeals()` |
| 2 | `get_deal` | `id` (required) | Full deal with activities | NEW |
| 3 | `create_deal` | `title`, `client_name`, `value`, `stage` | Created deal | `createDeal()` |
| 4 | `update_deal` | `id`, `stage?`, `value?`, `status?` | Updated deal | NEW |
| 5 | `add_activity` | `deal_id`, `type`, `notes` | Created activity | NEW |
| 6 | `get_pipeline_summary` | none | Stage counts + total value | NEW |

## Migration Notes

- Source is Google Sheets `Deals` tab + `Deal_Activities` tab
- Existing Python MCP at `mcp-servers/dataxlr8_deals_mcp` — use its tool definitions as reference
- Pipeline stages: lead → qualified → proposal → negotiation → closed_won / closed_lost

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates
- [ ] Pipeline summary aggregation works
- [ ] Activity log ordered by date
- [ ] Claude Code integration works
