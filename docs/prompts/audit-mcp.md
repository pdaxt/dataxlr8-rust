# Agent Prompt: dataxlr8-audit-mcp

## What This Is

Audit trail and compliance. Records every data mutation across all MCPs for accountability and regulatory compliance.

**Repo:** pdaxt/dataxlr8-audit-mcp
**Path:** /Users/pran/Projects/dataxlr8-audit-mcp
**Status:** Not started. Agent building.

## Current State

- Repo not yet created
- Depends on dataxlr8-mcp-core for shared helpers
- All other MCPs will call audit-mcp to log mutations

## What Needs Doing

### Initial Build

Follow the lego pattern from `_pattern.md`. Implement 8 tools for audit:

- Append-only audit log (no updates or deletes on log entries)
- Captures: who, what, when, before/after state
- Query by entity, actor, action type, date range
- Compliance report generation (who accessed what data, when)
- Retention policy support (archive old entries)

### Schema Design

```
audit.entries            — immutable audit log entries
audit.retention_policies — configurable retention rules per entity type
```

### Integration Pattern

Other MCPs call `log_action` after every create/update/delete:

```rust
// In crm-mcp after creating a contact:
audit_mcp.log_action(
    actor: "agent:claude6",
    action: "create",
    entity_type: "contact",
    entity_id: "uuid",
    after: { ...contact_data },
)
```

### Done When

- `cargo build` passes
- All 8 tools implemented
- Follows lego pattern
- git push to GitHub

## 8 Tools

1. `log_action` — record an audit entry (actor, action, entity_type, entity_id, before, after)
2. `query_log` — search audit entries with filters (entity, actor, action, date range)
3. `entity_history` — full change history for a specific entity, ordered chronologically
4. `actor_activity` — all actions performed by a specific actor in a date range
5. `compliance_report` — generate a data access report for an entity or actor (for GDPR/SOC2)
6. `set_retention` — configure retention policy for an entity type (days to keep)
7. `archive_entries` — move entries older than retention policy to cold storage
8. `audit_stats` — counts by action type, entity type, and actor over a period

## Schema

```sql
audit.entries            — id, actor, action (create|update|delete|read|export), entity_type, entity_id, before_state (jsonb), after_state (jsonb), metadata (jsonb), created_at
audit.retention_policies — id, entity_type, retention_days, archive_destination, created_at
```
