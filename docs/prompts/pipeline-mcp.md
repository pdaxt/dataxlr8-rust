# Agent Prompt: dataxlr8-pipeline-mcp

## What This Is

Sales pipeline automation. Manages deal stages, automations, and pipeline health metrics.

**Repo:** pdaxt/dataxlr8-pipeline-mcp
**Path:** /Users/pran/Projects/dataxlr8-pipeline-mcp
**Status:** Not started. Agent building.

## Current State

- Repo not yet created
- Depends on dataxlr8-mcp-core for shared helpers
- Depends on dataxlr8-crm-mcp for deal/contact data

## What Needs Doing

### Initial Build

Follow the lego pattern from `_pattern.md`. Implement 8 tools for pipeline automation:

- Stage definitions with configurable pipelines (e.g. Sales, Partnerships)
- Automated stage transitions based on rules (e.g. move to "Negotiation" when proposal sent)
- Stale deal detection and alerts
- Pipeline velocity metrics (avg time per stage, conversion rates)
- Forecasting based on stage probabilities

### Schema Design

```
pipeline.pipelines       — named pipelines (Sales, Partnerships, etc.)
pipeline.stages          — ordered stages per pipeline with win_probability
pipeline.automations     — trigger rules for stage transitions
pipeline.stage_history   — timestamped log of every stage change
```

### Done When

- `cargo build` passes
- All 8 tools implemented
- Follows lego pattern
- git push to GitHub

## 8 Tools

1. `create_pipeline` — define a named pipeline with ordered stages
2. `list_pipelines` — list all pipelines with stage counts and deal totals
3. `configure_stage` — set stage properties (win_probability, required_fields, SLA days)
4. `add_automation` — create a trigger rule (e.g. "when activity_type=proposal, move to Negotiation")
5. `evaluate_deal` — run automation rules against a deal and apply transitions
6. `pipeline_velocity` — avg days per stage, conversion rate between stages
7. `stale_deals` — find deals stuck in a stage longer than SLA threshold
8. `forecast` — weighted forecast by stage win_probability across pipeline

## Schema

```sql
pipeline.pipelines       — id, name, description, created_at
pipeline.stages          — id, pipeline_id, name, position, win_probability, sla_days, required_fields (jsonb)
pipeline.automations     — id, pipeline_id, trigger_field, trigger_value, target_stage_id, enabled
pipeline.stage_history   — id, deal_id, from_stage_id, to_stage_id, changed_at, changed_by, reason
```
