# BRD: dataxlr8-supplier-mcp

**Phase:** 2
**Status:** NOT STARTED
**PG Schema:** `suppliers`
**Source:** `apps/web/lib/supplier-client.ts` (SQLite)

---

## Purpose

Supplier management for the travel/hospitality business. Tracks hotels, rates, seasonal pricing, and contract terms.

## Current Data Store

SQLite via `db-client.ts` abstraction. Tables: `suppliers`, `supplier_rates`, `supplier_rooms`.

## Tools (6)

| # | Tool | Params | Returns | Source Function |
|---|------|--------|---------|----------------|
| 1 | `list_suppliers` | `city?`, `country?`, `category?`, `status?`, `limit?` | Array of SupplierSummary | `listSuppliers()` |
| 2 | `get_supplier` | `id` (required) | FullSupplier (with rates, rooms) | `getSupplier()` |
| 3 | `compare_rates` | `supplier_ids[]`, `check_in`, `check_out`, `room_type?` | Rate comparison | `compareRates()` |
| 4 | `get_expiring_rates` | `days_ahead?` (default 30) | Rates expiring soon | `getExpiringRates()` |
| 5 | `get_supplier_stats` | none | `{total, byCategory, byCity}` | `getSupplierStats()` |
| 6 | `create_supplier` | `name`, `city`, `country`, `category` | Created supplier | NEW |

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates
- [ ] `list_suppliers` with filters
- [ ] `compare_rates` across suppliers
- [ ] `get_expiring_rates` date math works
- [ ] Claude Code integration works
