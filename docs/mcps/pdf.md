# BRD: dataxlr8-pdf-mcp

**Phase:** 2 | **Status:** NOT STARTED | **PG Schema:** `pdf`
**Source:** `apps/web/lib/pdf-client.ts` (SQLite)

## Purpose
PDF generation and management — templates, generated PDFs for quotations, reports.

## Tools (5)
| # | Tool | Params | Source Function |
|---|------|--------|----------------|
| 1 | `list_templates` | none | `listTemplates()` |
| 2 | `list_pdfs` | `quotation_id?`, `limit?` | `listGeneratedPdfs()` |
| 3 | `get_pdf` | `id` | `getGeneratedPdf()` |
| 4 | `get_latest_for_quotation` | `quotation_id` | `getLatestPdfForQuotation()` |
| 5 | `generate_pdf` | `template_id`, `data` | NEW (uses typst crate) |

## Notes
- PDF rendering via `typst` Rust crate (no external process)
- Templates stored in PG, rendered to file system

## Acceptance Criteria
- [ ] Build, schema, all tools, PDF renders correctly, Claude Code integration
