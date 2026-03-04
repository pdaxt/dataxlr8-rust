# BRD: dataxlr8-features-mcp

**Phase:** 0
**Status:** VERIFIED
**Repo:** [pdaxt/dataxlr8-features-mcp](https://github.com/pdaxt/dataxlr8-features-mcp)
**PG Schema:** `features`
**Binary size:** 7.0MB

---

## Purpose

Manage feature flags with role-based and user-specific overrides. Controls which features are enabled for which users/roles across the DataXLR8 platform.

## Source (TypeScript)

`apps/web/lib/features-client.ts` — 9 exported functions. All 9 ported to Rust.

## Database Schema

```sql
CREATE SCHEMA IF NOT EXISTS features;

CREATE TABLE features.flags (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL DEFAULT '',
    flag_type   TEXT NOT NULL DEFAULT 'global'
                CHECK (flag_type IN ('global', 'page', 'feature')),
    enabled     BOOLEAN NOT NULL DEFAULT true,
    page_path   TEXT NOT NULL DEFAULT '',
    metadata    JSONB NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE features.flag_overrides (
    id             TEXT PRIMARY KEY,
    flag_id        TEXT NOT NULL REFERENCES features.flags(id) ON DELETE CASCADE,
    override_type  TEXT NOT NULL CHECK (override_type IN ('role', 'user')),
    target         TEXT NOT NULL,
    enabled        BOOLEAN NOT NULL DEFAULT true,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (flag_id, override_type, target)
);
```

## Tools (9/9)

| Tool | Params | Returns | Description |
|------|--------|---------|-------------|
| `get_all_flags` | none | Array of flags with overrides | Batch fetch (no N+1 queries) |
| `get_flag` | `name` (required) | Flag with overrides | Single flag lookup |
| `check_flag` | `name` (required), `employee_id`, `role` | `{enabled, reason}` | Resolves override priority |
| `check_flags_bulk` | `names[]` (required), `employee_id`, `role` | Map of flag→{enabled, reason} | Batch query via ANY($1), no N+1 |
| `create_flag` | `name` (required), `flag_type`, `description`, `enabled`, `page_path` | Created flag | Returns full row via RETURNING |
| `update_flag` | `name` (required), `enabled`, `description` | Updated flag | Partial update |
| `delete_flag` | `name` (required) | `{deleted, name}` | Cascades to overrides |
| `set_override` | `flag_name`, `override_type`, `target`, `enabled` (all required) | Override record | Upsert via ON CONFLICT |
| `remove_override` | `flag_name`, `override_type`, `target` (all required) | `{removed, flag_name, ...}` | Deletes specific override |

## Override Priority

```
user override > role override > global setting
```

Unknown flags default to **disabled** (fail-closed).

## Acceptance Results

| Check | Result | Date |
|-------|--------|------|
| `cargo build --release` | PASS (zero warnings) | 2026-03-04 |
| Binary < 10MB | PASS (7.0MB) | 2026-03-04 |
| Schema auto-creates | PASS | 2026-03-04 |
| tools/list returns 9 | PASS | 2026-03-04 |
| create_flag | PASS | 2026-03-04 |
| get_flag | PASS | 2026-03-04 |
| check_flag (global) | PASS | 2026-03-04 |
| check_flag (with override) | PASS | 2026-03-04 |
| check_flags_bulk (batch) | PASS | 2026-03-04 |
| update_flag | PASS | 2026-03-04 |
| set_override | PASS | 2026-03-04 |
| remove_override | PASS | 2026-03-04 |
| delete_flag | PASS | 2026-03-04 |
| get_all_flags | PASS | 2026-03-04 |
| Unknown tool handling | PASS | 2026-03-04 |
| Graceful shutdown | PASS | 2026-03-04 |
| Claude Code integration | PENDING | — |
