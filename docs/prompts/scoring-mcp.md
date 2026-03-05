# Agent Prompt: dataxlr8-scoring-mcp

## What This Is

Lead scoring engine. Computes scores for contacts and deals based on configurable rules and signals.

**Repo:** pdaxt/dataxlr8-scoring-mcp
**Path:** /Users/pran/Projects/dataxlr8-scoring-mcp
**Status:** Not started. Agent building.

## Current State

- Repo not yet created
- Depends on dataxlr8-mcp-core for shared helpers
- Consumes data from crm-mcp (contacts, deals, activities) and enrichment-mcp (company data)

## What Needs Doing

### Initial Build

Follow the lego pattern from `_pattern.md`. Implement 8 tools for lead scoring:

- Configurable scoring models with weighted rules
- Rule types: demographic (title, company size), behavioral (email opens, calls), firmographic (industry, tech stack)
- Score decay over time for stale leads
- Score thresholds for lead qualification (MQL, SQL)
- Batch rescoring when rules change

### Schema Design

```
scoring.models           — named scoring models with description
scoring.rules            — individual rules with field, operator, value, points
scoring.scores           — computed scores per entity with breakdown
scoring.thresholds       — named thresholds (e.g. MQL=50, SQL=80)
```

### Done When

- `cargo build` passes
- All 8 tools implemented
- Follows lego pattern
- git push to GitHub

## 8 Tools

1. `create_model` — define a scoring model with name and description
2. `add_rule` — add a scoring rule to a model (field, operator, value, points)
3. `list_rules` — list all rules for a model with point values
4. `score_entity` — compute score for a contact or deal against a model, store result
5. `batch_rescore` — rescore all entities against a model (used after rule changes)
6. `get_score` — retrieve current score and breakdown for an entity
7. `set_threshold` — define qualification thresholds (e.g. MQL=50, SQL=80)
8. `qualified_leads` — list entities that meet or exceed a threshold, ranked by score

## Schema

```sql
scoring.models           — id, name, description, decay_rate_per_day (numeric), created_at
scoring.rules            — id, model_id, field, operator (eq|gt|lt|contains|exists), value, points (integer), category (demographic|behavioral|firmographic)
scoring.scores           — id, model_id, entity_type, entity_id, total_score (integer), breakdown (jsonb), scored_at
scoring.thresholds       — id, model_id, name (e.g. MQL|SQL), min_score (integer)
```
