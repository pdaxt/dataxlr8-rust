# Agent Prompt: dataxlr8-scheduler-mcp

## What This Is

Task scheduling with recurring support. Runs scheduled jobs, reminders, and follow-up sequences.

**Repo:** pdaxt/dataxlr8-scheduler-mcp
**Path:** /Users/pran/Projects/dataxlr8-scheduler-mcp
**Status:** Not started. Agent building.

## Current State

- Repo not yet created
- Depends on dataxlr8-mcp-core for shared helpers
- Will be used by pipeline-mcp, crm-mcp, and webhooks-mcp for scheduled triggers

## What Needs Doing

### Initial Build

Follow the lego pattern from `_pattern.md`. Implement 8 tools for scheduling:

- One-off and recurring job scheduling (cron syntax)
- Follow-up sequences (e.g. email day 1, call day 3, email day 7)
- Job execution tracking with success/failure status
- Missed job detection and retry logic
- Timezone-aware scheduling

### Schema Design

```
scheduler.jobs           — scheduled jobs with cron expression or one-off timestamp
scheduler.sequences      — multi-step follow-up sequences
scheduler.sequence_steps — individual steps within a sequence
scheduler.executions     — execution log with status, output, duration
```

### Done When

- `cargo build` passes
- All 8 tools implemented
- Follows lego pattern
- git push to GitHub

## 8 Tools

1. `schedule_job` — create a one-off or recurring job (cron syntax supported)
2. `list_jobs` — list jobs with filters (status, type, next_run)
3. `cancel_job` — cancel a pending or recurring job
4. `create_sequence` — define a multi-step follow-up sequence with delays
5. `start_sequence` — attach a sequence to a contact/deal and begin execution
6. `sequence_status` — check progress of a running sequence
7. `pending_jobs` — list jobs due for execution in the next N minutes
8. `execution_log` — query execution history with filters (job_id, status, date range)

## Schema

```sql
scheduler.jobs             — id, name, job_type (one_off|recurring), cron_expr, next_run_at, timezone, payload (jsonb), status, created_at
scheduler.sequences        — id, name, description, created_at
scheduler.sequence_steps   — id, sequence_id, step_order, delay_minutes, action_type, action_payload (jsonb)
scheduler.executions       — id, job_id, started_at, finished_at, status (success|failed|skipped), output (jsonb), error
```
