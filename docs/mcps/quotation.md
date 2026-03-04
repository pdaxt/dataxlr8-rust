# BRD: dataxlr8-quotation-mcp

**Phase:** 2
**Status:** NOT STARTED
**PG Schema:** `quotations`
**Source:** `apps/web/lib/quotation-client.ts` (3 functions) + `mcp-servers/dataxlr8_quotation_mcp/server.py` (21 tools)

---

## Purpose

Quotation management — create, price, and track travel quotations with itineraries, hotel options, pax breakdowns, supplements, destination legs, and versioning. This is one of the most complex MCPs.

## Existing Python MCP Tools (21)

These are the ACTUAL tools from `dataxlr8_quotation_mcp`:

| # | Tool | Description |
|---|------|-------------|
| 1 | `create_quotation` | Create new quotation |
| 2 | `get_quotation` | Get full quotation by ID |
| 3 | `list_quotations` | List quotations with filters |
| 4 | `calculate_pricing` | Calculate pricing breakdown |
| 5 | `update_quotation_status` | Change quotation status |
| 6 | `clone_quotation` | Deep copy a quotation |
| 7 | `version_quotation` | Create a new version |
| 8 | `add_itinerary` | Add itinerary item |
| 9 | `add_hotel_option` | Add hotel option with rates |
| 10 | `set_package_contents` | Set what's included/excluded |
| 11 | `set_child_policy` | Set child pricing policy |
| 12 | `set_coach_tiers` | Set coach tier pricing |
| 13 | `set_foc_policy` | Set free-of-charge policy |
| 14 | `set_terms` | Set terms and conditions |
| 15 | `add_pax_break` | Add pax (group size) pricing break |
| 16 | `compare_pax_breaks` | Compare pax break pricing |
| 17 | `add_optional_service` | Add optional service |
| 18 | `set_markup` | Set markup percentage |
| 19 | `add_supplement` | Add supplement charge |
| 20 | `add_destination_leg` | Add destination leg to itinerary |
| 21 | `quotation_status` | Get quotation system status |

## TypeScript Functions (3)

From `quotation-client.ts` — these are read-only wrappers:
- `listQuotations()` — list with filters
- `getQuotation()` — get full quotation
- `calculatePricing()` — calculate pricing

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates (complex — many tables)
- [ ] All 21 tools from Python MCP ported
- [ ] `calculate_pricing` handles pax breaks, supplements, markup correctly
- [ ] `clone_quotation` deep copies all sub-entities
- [ ] `version_quotation` preserves history
- [ ] Claude Code integration works
