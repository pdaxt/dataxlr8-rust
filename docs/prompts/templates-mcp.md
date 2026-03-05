# Agent Prompt: dataxlr8-templates-mcp

## What This Is

Document and email template rendering. Stores templates with variable placeholders and renders them with context data.

**Repo:** pdaxt/dataxlr8-templates-mcp
**Path:** /Users/pran/Projects/dataxlr8-templates-mcp
**Status:** Not started. Agent building.

## Current State

- Repo not yet created
- Depends on dataxlr8-mcp-core for shared helpers
- Will use handlebars-like syntax for variable substitution (e.g. `{{contact.first_name}}`)

## What Needs Doing

### Initial Build

Follow the lego pattern from `_pattern.md`. Implement 8 tools for template management:

- Template CRUD with categories (email, proposal, invoice, followup)
- Variable substitution with nested object support (`{{deal.contact.company}}`)
- Template versioning (keep previous versions for audit)
- Preview rendering without sending
- Partial/snippet support for reusable blocks (e.g. email footer)

### Schema Design

```
templates.templates      — template definitions with body, subject, category
templates.versions       — version history of template changes
templates.partials       — reusable template snippets (headers, footers, signatures)
```

### Done When

- `cargo build` passes
- All 8 tools implemented
- Follows lego pattern
- git push to GitHub

## 8 Tools

1. `create_template` — create a template with name, category, subject, body, and variables list
2. `list_templates` — list templates filtered by category or search term
3. `get_template` — retrieve a template by id or name with its current body
4. `update_template` — update template body/subject (auto-creates new version)
5. `render_template` — render a template with context data, return the filled output
6. `preview_template` — render with sample data to preview without side effects
7. `create_partial` — create a reusable snippet (e.g. `{{> email_footer}}`)
8. `template_versions` — list version history for a template

## Schema

```sql
templates.templates      — id, name, category, subject, body, variables (text[]), created_at, updated_at
templates.versions       — id, template_id, version_num, subject, body, created_at, created_by
templates.partials       — id, name, body, created_at, updated_at
```
