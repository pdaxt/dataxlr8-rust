# Agent Prompt: dataxlr8-notes-mcp

## What This Is

Meeting notes and call logs. Captures structured notes linked to contacts, deals, and activities.

**Repo:** pdaxt/dataxlr8-notes-mcp
**Path:** /Users/pran/Projects/dataxlr8-notes-mcp
**Status:** Not started. Agent building.

## Current State

- Repo not yet created
- Depends on dataxlr8-mcp-core for shared helpers
- Links to crm-mcp entities (contacts, deals)

## What Needs Doing

### Initial Build

Follow the lego pattern from `_pattern.md`. Implement 8 tools for notes:

- Meeting notes with attendees, agenda, action items
- Call logs with duration, outcome, next steps
- Full-text search across all notes
- Action item extraction and tracking
- Notes linked to contacts and deals for context

### Schema Design

```
notes.notes              — note content with type (meeting, call, general), linked entities
notes.action_items       — extracted action items with assignee and due date
notes.attachments        — file references attached to notes
```

### Done When

- `cargo build` passes
- All 8 tools implemented
- Follows lego pattern
- git push to GitHub

## 8 Tools

1. `create_note` — create a note (type: meeting|call|general) linked to contact/deal
2. `get_note` — retrieve a note by id with action items and attachments
3. `search_notes` — full-text search across notes with filters (type, entity, date range)
4. `update_note` — update note content or metadata
5. `add_action_item` — add an action item to a note with assignee and due date
6. `complete_action_item` — mark an action item as done
7. `pending_actions` — list open action items across all notes, filterable by assignee
8. `entity_notes` — list all notes linked to a specific contact or deal

## Schema

```sql
notes.notes              — id, note_type (meeting|call|general), title, body, attendees (text[]), contact_id, deal_id, created_at, updated_at
notes.action_items       — id, note_id, description, assignee, due_date, completed_at, created_at
notes.attachments        — id, note_id, filename, url, mime_type, created_at
```
