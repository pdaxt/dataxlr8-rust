# Agent Prompt: dataxlr8-analytics-mcp

## What This Is

Event tracking and funnel analysis. Records user/deal events and computes conversion funnels.

**Repo:** pdaxt/dataxlr8-analytics-mcp
**Path:** /Users/pran/Projects/dataxlr8-analytics-mcp
**Status:** Not started. Agent building.

## Current State

- Repo not yet created
- Depends on dataxlr8-mcp-core for shared helpers
- Will consume events from crm-mcp, pipeline-mcp, and enrichment-mcp

## What Needs Doing

### Initial Build

Follow the lego pattern from `_pattern.md`. Implement 8 tools for analytics:

- Event ingestion with arbitrary properties (jsonb)
- Funnel definition and conversion analysis
- Time-series aggregation (daily/weekly/monthly)
- Cohort analysis by signup date or first activity
- Metric snapshots for dashboards

### Schema Design

```
analytics.events         — timestamped events with entity_type, entity_id, properties
analytics.funnels        — named funnel definitions with ordered steps
analytics.funnel_steps   — individual steps in a funnel
analytics.metrics        — pre-computed metric snapshots for fast reads
```

### Done When

- `cargo build` passes
- All 8 tools implemented
- Follows lego pattern
- git push to GitHub

## 8 Tools

1. `track_event` — record an event (entity_type, entity_id, event_name, properties)
2. `query_events` — query events with filters (entity, event_name, date range, property match)
3. `create_funnel` — define a conversion funnel with ordered event steps
4. `funnel_report` — compute conversion rates between funnel steps for a date range
5. `time_series` — aggregate event counts by interval (hour, day, week, month)
6. `cohort_analysis` — group entities by first event date, track retention over periods
7. `top_events` — most frequent events ranked by count, filterable by entity_type
8. `metric_snapshot` — compute and store a named metric (e.g. "active_deals", "emails_sent") for dashboard use

## Schema

```sql
analytics.events         — id, entity_type, entity_id, event_name, properties (jsonb), timestamp, source
analytics.funnels        — id, name, description, created_at
analytics.funnel_steps   — id, funnel_id, step_order, event_name, filter_properties (jsonb)
analytics.metrics        — id, metric_name, value (numeric), dimensions (jsonb), computed_at
```
