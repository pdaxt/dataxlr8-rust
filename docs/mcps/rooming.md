# BRD: dataxlr8-rooming-mcp

**Phase:** 2 | **Status:** NOT STARTED | **PG Schema:** `rooming`
**Source:** `apps/web/lib/rooming-client.ts` (SQLite)

## Purpose
Rooming list management — room assignments, guest lists, supplier room allocations for travel groups.

## Tools (5)
| # | Tool | Params | Source Function |
|---|------|--------|----------------|
| 1 | `list_rooming_lists` | `quotation_id?`, `status?`, `limit?` | `listRoomingLists()` |
| 2 | `get_rooming_list` | `id` | `getRoomingList()` |
| 3 | `get_by_quotation` | `quotation_id` | `getRoomingByQuotation()` |
| 4 | `export_supplier_rooms` | `rooming_list_id`, `supplier_id?` | `exportSupplierRooms()` |
| 5 | `create_rooming_list` | `quotation_id`, `name` | NEW |

## Acceptance Criteria
- [ ] Build, schema, all tools, Claude Code integration
