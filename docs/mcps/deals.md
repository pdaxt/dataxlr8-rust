# BRD: dataxlr8-deals-mcp

**Phase:** 3
**Status:** NOT STARTED
**PG Schema:** `deals`
**Source:** `apps/web/lib/google-sheets.ts` (2 functions) + `mcp-servers/dataxlr8_deals_mcp/server.py` (14 tools)

---

## Purpose

Sales pipeline — deals, stages, activities, commissions, leaderboard.

## Existing Python MCP Tools (14)

From `dataxlr8_deals_mcp`:

| # | Tool | Description |
|---|------|-------------|
| 1 | `list_deals` | List deals with filters |
| 2 | `get_deal` | Get full deal by ID |
| 3 | `create_deal` | Create new deal |
| 4 | `update_deal` | Update deal fields |
| 5 | `advance_deal_stage` | Move deal to next pipeline stage |
| 6 | `close_deal` | Close deal (won/lost) |
| 7 | `list_deal_activities` | List activities for a deal |
| 8 | `add_deal_activity` | Add activity (call, email, meeting) |
| 9 | `get_pipeline_summary` | Pipeline stats by stage |
| 10 | `get_commissions` | List commission records |
| 11 | `record_commission` | Record a commission |
| 12 | `pay_commission` | Mark commission as paid |
| 13 | `get_leaderboard` | Sales leaderboard |
| 14 | `deals_status` | System status |

## TypeScript Functions (2)

From `google-sheets.ts`:
- `getDeals(employeeId?)` — list deals
- `createDeal(data)` — create deal

**Note:** TS source is minimal because most deal logic was already in the Python MCP.

## Target Tool Count: 14 (match Python MCP)

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] All 14 tools ported
- [ ] Pipeline stage progression works correctly
- [ ] Commission tracking integrated
- [ ] Claude Code integration works
