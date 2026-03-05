# Agent Prompt: dataxlr8-reporting-mcp

## What This Is

Report generation and ad-hoc queries. Builds reports from cross-MCP data with saved report definitions.

**Repo:** pdaxt/dataxlr8-reporting-mcp
**Path:** /Users/pran/Projects/dataxlr8-reporting-mcp
**Status:** Not started. Agent building.

## Current State

- Repo not yet created
- Depends on dataxlr8-mcp-core for shared helpers
- Reads from schemas owned by other MCPs (crm, pipeline, analytics, enrichment)

## What Needs Doing

### Initial Build

Follow the lego pattern from `_pattern.md`. Implement 8 tools for reporting:

- Saved report definitions with SQL templates and parameters
- Ad-hoc query execution against any schema
- Report scheduling (daily/weekly email digests)
- Output formats: JSON rows, summary stats
- Cross-schema joins (e.g. crm.deals + pipeline.stage_history + analytics.events)

### Schema Design

```
reporting.reports        — saved report definitions with SQL template and parameters
reporting.runs           — execution history with results and duration
reporting.schedules      — recurring report schedules with recipients
```

### Done When

- `cargo build` passes
- All 8 tools implemented
- Follows lego pattern
- git push to GitHub

## 8 Tools

1. `create_report` — define a saved report with name, SQL template, and parameter definitions
2. `list_reports` — list all saved reports with last run info
3. `run_report` — execute a saved report with parameters, store results
4. `ad_hoc_query` — run a raw SQL query (read-only, SELECT only) against any schema
5. `report_history` — list previous runs of a report with row counts and durations
6. `schedule_report` — set up recurring execution (daily, weekly) with output destination
7. `export_run` — retrieve full result set from a previous run as JSON
8. `delete_report` — remove a saved report and its history

## Schema

```sql
reporting.reports        — id, name, description, sql_template, parameters (jsonb), created_at, updated_at
reporting.runs           — id, report_id, parameters (jsonb), row_count, results (jsonb), duration_ms, executed_at
reporting.schedules      — id, report_id, cron_expr, output_type (json|csv), recipients (text[]), enabled, last_run_at
```
