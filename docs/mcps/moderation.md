# BRD: dataxlr8-moderation-mcp

**Phase:** 1
**Status:** NOT STARTED
**PG Schema:** `moderation`
**Source:** Planned (no existing TypeScript equivalent — new capability)

---

## Purpose

Content moderation and safety controls for the DataXLR8 platform. Manages blocklists, content rules, audit trails, and automated moderation decisions.

## Target: PostgreSQL Schema

```sql
CREATE SCHEMA IF NOT EXISTS moderation;

CREATE TABLE moderation.rules (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL DEFAULT '',
    rule_type   TEXT NOT NULL CHECK (rule_type IN ('blocklist', 'allowlist', 'regex', 'keyword')),
    pattern     TEXT NOT NULL,
    action      TEXT NOT NULL DEFAULT 'flag' CHECK (action IN ('flag', 'block', 'warn', 'log')),
    enabled     BOOLEAN NOT NULL DEFAULT true,
    priority    INTEGER NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE moderation.actions (
    id          TEXT PRIMARY KEY,
    rule_id     TEXT REFERENCES moderation.rules(id),
    content_id  TEXT NOT NULL,
    content_type TEXT NOT NULL,
    action_taken TEXT NOT NULL,
    reason      TEXT NOT NULL DEFAULT '',
    metadata    JSONB NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE moderation.blocklist (
    id          TEXT PRIMARY KEY,
    value       TEXT NOT NULL UNIQUE,
    type        TEXT NOT NULL CHECK (type IN ('email', 'domain', 'ip', 'word', 'phrase')),
    reason      TEXT NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ON moderation.actions(content_id);
CREATE INDEX ON moderation.actions(created_at);
CREATE INDEX ON moderation.blocklist(type);
```

## Tools (12)

| # | Tool | Params | Returns | Description |
|---|------|--------|---------|-------------|
| 1 | `list_rules` | `rule_type?`, `enabled?` | Array of Rule | List moderation rules |
| 2 | `create_rule` | `name`, `rule_type`, `pattern`, `action?`, `priority?` | Created rule | Add new rule |
| 3 | `update_rule` | `name`, `enabled?`, `action?`, `priority?` | Updated rule | Modify rule |
| 4 | `delete_rule` | `name` | `{deleted}` | Remove rule |
| 5 | `check_content` | `content`, `content_type?` | `{allowed, matched_rules[], action}` | Check content against all rules |
| 6 | `log_action` | `rule_id?`, `content_id`, `content_type`, `action_taken`, `reason?` | Logged action | Record moderation action |
| 7 | `list_actions` | `content_id?`, `limit?` | Array of Action | View action history |
| 8 | `add_to_blocklist` | `value`, `type`, `reason?` | Entry | Add to blocklist |
| 9 | `remove_from_blocklist` | `value` | `{removed}` | Remove from blocklist |
| 10 | `check_blocklist` | `value`, `type?` | `{blocked, reason}` | Check if value is blocked |
| 11 | `list_blocklist` | `type?` | Array of entries | View blocklist |
| 12 | `get_moderation_stats` | none | `{total_rules, total_actions, blocked_today}` | Dashboard stats |

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates
- [ ] Rule CRUD works
- [ ] `check_content` matches regex and keyword rules
- [ ] Blocklist add/remove/check works
- [ ] Action logging and listing works
- [ ] Stats return correct counts
- [ ] Claude Code integration works
