# BRD: dataxlr8-contacts-mcp

**Phase:** 1
**Status:** NOT STARTED
**PG Schema:** `contacts`
**Source:** `apps/web/lib/contact-client.ts` (reads from SQLite `~/.dataxlr8_contacts/contacts.db`)

---

## Purpose

CRM contact management — clients, suppliers, agents. Full CRUD with tags, interaction history, and entity linking.

## Current Data Store

SQLite at `~/.dataxlr8_contacts/contacts.db` with tables:
- `contacts` — main contact records
- `contact_tags` — tag associations
- `contact_interactions` — interaction log (calls, emails, meetings)
- `contact_links` — links to other entities (deals, quotations, etc.)

## Target: PostgreSQL Schema

```sql
CREATE SCHEMA IF NOT EXISTS contacts;

CREATE TABLE contacts.contacts (
    id          TEXT PRIMARY KEY,
    type        TEXT NOT NULL CHECK (type IN ('client', 'supplier', 'agent', 'other')),
    first_name  TEXT NOT NULL,
    last_name   TEXT NOT NULL,
    company     TEXT,
    role        TEXT,
    email       TEXT,
    phone       TEXT,
    mobile      TEXT,
    address     TEXT,
    city        TEXT,
    state       TEXT,
    country     TEXT,
    notes       TEXT,
    source      TEXT,
    status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE contacts.tags (
    id          TEXT PRIMARY KEY,
    contact_id  TEXT NOT NULL REFERENCES contacts.contacts(id) ON DELETE CASCADE,
    tag         TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(contact_id, tag)
);

CREATE TABLE contacts.interactions (
    id          TEXT PRIMARY KEY,
    contact_id  TEXT NOT NULL REFERENCES contacts.contacts(id) ON DELETE CASCADE,
    type        TEXT NOT NULL,
    subject     TEXT,
    notes       TEXT,
    date        TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE contacts.links (
    id            TEXT PRIMARY KEY,
    contact_id    TEXT NOT NULL REFERENCES contacts.contacts(id) ON DELETE CASCADE,
    entity_type   TEXT NOT NULL,
    entity_id     TEXT NOT NULL,
    relationship  TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ON contacts.contacts(type);
CREATE INDEX ON contacts.contacts(status);
CREATE INDEX ON contacts.contacts(email);
CREATE INDEX ON contacts.interactions(contact_id);
CREATE INDEX ON contacts.tags(contact_id);
```

## Tools (5)

| # | Tool | Params | Returns | Source Function |
|---|------|--------|---------|----------------|
| 1 | `list_contacts` | `type?`, `status?`, `city?`, `limit?` (default 50) | Array of ContactSummary | `listContacts()` |
| 2 | `search_contacts` | `query` (required), `limit?` (default 20) | Array of ContactSummary | `searchContacts()` |
| 3 | `get_contact` | `id` (required) | FullContact (with tags, interactions, links) | `getContact()` |
| 4 | `get_contact_stats` | none | `{total, clients, suppliers, agents}` | `getContactStats()` |
| 5 | `create_contact` | `first_name`, `last_name`, `type` (required), rest optional | Created contact | NEW (not in TS) |

## Data Types

**ContactSummary:** `id, type, first_name, last_name, company, role, email, phone, city, country, status, created_at`

**FullContact:** ContactSummary + `mobile, address, state, notes, source, updated_at, tags[], interactions[], links[]`

## Migration Notes

- Source is SQLite — need one-time data migration script
- Search uses LIKE patterns — in PG use `ILIKE` for case-insensitive
- Stats queries use COUNT with type/status filters — simple aggregation

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates on startup
- [ ] `list_contacts` with filters works
- [ ] `search_contacts` finds partial matches
- [ ] `get_contact` returns tags + interactions + links
- [ ] `get_contact_stats` returns correct counts
- [ ] `create_contact` validates type enum
- [ ] Missing contact returns error (not panic)
- [ ] Claude Code integration works
