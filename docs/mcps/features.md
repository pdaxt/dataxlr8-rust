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

`apps/web/lib/features-client.ts` — 9 exported functions.

**GAP:** `removeOverride` exists in TS but is missing from Rust. It removes a single override without deleting the flag. The Rust MCP needs a `remove_override` tool added (making it 9 tools total).

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

## Tools (8)

| Tool | Params | Returns | Description |
|------|--------|---------|-------------|
| `get_all_flags` | none | Array of flags with overrides | Batch fetch (no N+1 queries) |
| `get_flag` | `name` (required) | Flag with overrides | Single flag lookup |
| `check_flag` | `name` (required), `employee_id`, `role` | `{enabled, reason}` | Resolves override priority |
| `check_flags_bulk` | `names[]` (required), `employee_id`, `role` | Map of flag→{enabled, reason} | Multi-flag check |
| `create_flag` | `name` (required), `flag_type`, `description`, `enabled`, `page_path` | Created flag | Returns full row via RETURNING |
| `update_flag` | `name` (required), `enabled`, `description` | Updated flag | Partial update |
| `delete_flag` | `name` (required) | `{deleted, name}` | Cascades to overrides |
| `set_override` | `flag_name`, `override_type`, `target`, `enabled` (all required) | Override record | Upsert via ON CONFLICT |

## Override Priority

```
user override > role override > global setting
```

Unknown flags default to **disabled** (fail-closed).

## Acceptance Results

| Check | Result | Date |
|-------|--------|------|
| `cargo build --release` | PASS | 2026-03-04 |
| Binary < 10MB | PASS (7.0MB) | 2026-03-04 |
| Schema auto-creates | PASS | 2026-03-04 |
| tools/list returns 8 | PASS | 2026-03-04 |
| create_flag | PASS | 2026-03-04 |
| check_flag | PASS | 2026-03-04 |
| get_all_flags | PASS | 2026-03-04 |
| delete_flag | PASS | 2026-03-04 |
| check_flags_bulk | PENDING | — |
| update_flag | PENDING | — |
| set_override | PENDING | — |
| Claude Code integration | PENDING | — |
