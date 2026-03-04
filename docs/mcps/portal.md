# BRD: dataxlr8-portal-mcp

**Phase:** 2
**Status:** NOT STARTED
**PG Schema:** `portal`
**Source:** `apps/web/lib/portal-client.ts` (SQLite)

---

## Purpose

Client portal — project tracking, deliverable management, comments, activity feed. External-facing for clients to view progress.

## Tools (8)

| # | Tool | Params | Returns | Source Function |
|---|------|--------|---------|----------------|
| 1 | `list_projects` | `manager_id?` | Array of PortalProject | `getProjects()` |
| 2 | `get_project` | `id` (required) | PortalProject | `getProjectById()` |
| 3 | `list_deliverables` | `project_id` (required) | Array of PortalDeliverable | `getDeliverables()` |
| 4 | `list_comments` | `project_id` (required) | Array of PortalComment | `getComments()` |
| 5 | `get_pending_comments` | none | Array of unapproved comments | `getPendingComments()` |
| 6 | `get_activity_feed` | `project_id` (required), `limit?` | Array of PortalActivity | `getActivityFeed()` |
| 7 | `get_portal_stats` | none | Dashboard stats | `getPortalStats()` |
| 8 | `create_project` | `name`, `client_id`, `manager_id` | Created project | NEW |

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates
- [ ] Full CRUD on projects and deliverables
- [ ] Activity feed ordered by date
- [ ] Pending comments filter works
- [ ] Claude Code integration works
