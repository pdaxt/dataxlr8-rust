# BRD: dataxlr8-quotation-mcp

**Phase:** 2
**Status:** NOT STARTED
**PG Schema:** `quotations`
**Source:** `apps/web/lib/quotation-client.ts` (SQLite)

---

## Purpose

Quotation management — create, price, and track travel quotations with line items, pax breakdowns, and supplier references.

## Tools (6)

| # | Tool | Params | Returns | Source Function |
|---|------|--------|---------|----------------|
| 1 | `list_quotations` | `status?`, `client_id?`, `limit?` | Array of QuotationSummary | `listQuotations()` |
| 2 | `get_quotation` | `id` (required) | FullQuotation (with line items, pax) | `getQuotation()` |
| 3 | `calculate_pricing` | `id` (required) | Pricing breakdown | `calculatePricing()` |
| 4 | `create_quotation` | `client_id`, `title`, `travel_dates` | Created quotation | NEW |
| 5 | `update_quotation` | `id`, `status?`, `notes?` | Updated quotation | NEW |
| 6 | `clone_quotation` | `id` | Cloned quotation (new ID) | NEW |

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates
- [ ] `calculate_pricing` handles pax breaks correctly
- [ ] `clone_quotation` deep copies line items
- [ ] Claude Code integration works
