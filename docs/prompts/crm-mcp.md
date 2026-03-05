# Agent Prompt: dataxlr8-crm-mcp

## What This Is

The Salesforce replacement. CRM with contacts, deals, activities, tasks.

**Repo:** pdaxt/dataxlr8-crm-mcp
**Path:** /Users/pran/Projects/dataxlr8-crm-mcp
**Status:** Compiles (10 tools). Needs contacts-mcp merge.

## Current State

- 10 tools implemented in tools/mod.rs (1024 lines)
- Schema: crm.contacts, crm.deals, crm.activities, crm.tasks
- Full CRUD for contacts/deals, activity logging, pipeline view

## What Needs Doing

### Absorb contacts-mcp

dataxlr8-contacts-mcp has 9 tools that overlap. CRM is the superset. Merge unique features:
- Interaction logging (contacts-mcp has interactions table)
- Tag management (contacts-mcp has tags on contacts)

### Use Shared Helpers

Import from `dataxlr8_mcp_core::mcp` instead of local copies:
- `make_schema`, `empty_schema`, `json_result`, `error_result`
- `get_str`, `get_i64`, `get_f64`, `get_str_array`

### Done When

- All contacts-mcp features merged
- Shared helpers imported from mcp-core
- `cargo build` passes
- git push to GitHub

## 10 Tools

1. `create_contact` — create with custom fields
2. `search_contacts` — full-text search with filters
3. `upsert_deal` — create/update deal in pipeline
4. `move_deal` — move between stages
5. `log_activity` — log calls, emails, meetings
6. `get_pipeline` — pipeline overview with stage counts
7. `assign_contact` — assign to team member
8. `create_task` — follow-up task linked to contact/deal
9. `import_contacts` — bulk import from JSON
10. `export_contacts` — export with filters
