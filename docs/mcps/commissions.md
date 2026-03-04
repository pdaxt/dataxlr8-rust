# BRD: dataxlr8-commissions-mcp

**Phase:** 1
**Status:** NOT STARTED
**PG Schema:** `commissions`
**Source:** `apps/web/lib/manager-client.ts` (reads from JSON files at `~/.dataxlr8/managers/`)

---

## Purpose

Manager profiles, commission tracking, and leaderboard. Currently stored as flat JSON files — migrating to PostgreSQL for proper querying and aggregation.

## Current Data Store

JSON files at `~/.dataxlr8/managers/`:
- `profiles/*.json` — one file per manager
- `commissions/*.json` — arrays of commission records

## Target: PostgreSQL Schema

```sql
CREATE SCHEMA IF NOT EXISTS commissions;

CREATE TABLE commissions.managers (
    id              TEXT PRIMARY KEY,
    name            TEXT NOT NULL,
    email           TEXT NOT NULL UNIQUE,
    role            TEXT NOT NULL DEFAULT 'manager',
    commission_rate NUMERIC(5,4) NOT NULL DEFAULT 0.10,
    total_earned    NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_pending   NUMERIC(12,2) NOT NULL DEFAULT 0,
    clients         TEXT[] NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE commissions.referrals (
    id               TEXT PRIMARY KEY,
    manager_id       TEXT NOT NULL REFERENCES commissions.managers(id) ON DELETE CASCADE,
    referred_by      TEXT NOT NULL,
    referred_email   TEXT NOT NULL,
    status           TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'expired')),
    commission_share NUMERIC(5,4) NOT NULL DEFAULT 0.05,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE commissions.records (
    id          TEXT PRIMARY KEY,
    manager_id  TEXT NOT NULL REFERENCES commissions.managers(id) ON DELETE CASCADE,
    client_id   TEXT NOT NULL,
    project_id  TEXT NOT NULL,
    amount      NUMERIC(12,2) NOT NULL,
    status      TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'paid')),
    description TEXT NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    paid_at     TIMESTAMPTZ
);

CREATE INDEX ON commissions.records(manager_id);
CREATE INDEX ON commissions.records(status);
CREATE INDEX ON commissions.managers(email);
```

## Tools (6)

| # | Tool | Params | Returns | Source Function |
|---|------|--------|---------|----------------|
| 1 | `list_managers` | none | Array of ManagerProfile | `getManagerProfiles()` |
| 2 | `get_manager` | `email` (required) | ManagerProfile or null | `getManagerByEmail()` |
| 3 | `list_commissions` | `manager_id?` | Array of CommissionRecord | `getCommissions()` |
| 4 | `get_commission_stats` | `manager_id?` | `{totalEarned, totalPending, totalPaid, recentCommissions}` | `getCommissionStats()` |
| 5 | `get_leaderboard` | none | Sorted array `{email, name, totalEarned, dealCount}` | `getLeaderboard()` |
| 6 | `create_commission` | `manager_id`, `client_id`, `project_id`, `amount`, `description` | Created record | NEW (not in TS) |

## Data Types

**ManagerProfile:** `id, name, email, role, clients[], commission_rate, total_earned, total_pending, referrals[]`

**CommissionRecord:** `id, manager_id, client_id, project_id, amount, status, description, created_at, paid_at?`

## Migration Notes

- Source is JSON files — need migration script that reads all profiles + commissions and inserts into PG
- `total_earned` and `total_pending` should be computed from `commissions.records` aggregation
- `clients` array in TS becomes a `TEXT[]` column in PG

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates on startup
- [ ] `list_managers` returns all profiles
- [ ] `get_manager` by email works
- [ ] `list_commissions` with optional manager_id filter
- [ ] `get_commission_stats` computes correct totals
- [ ] `get_leaderboard` sorted by totalEarned desc
- [ ] `create_commission` validates required fields
- [ ] Claude Code integration works
