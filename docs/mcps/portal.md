# BRD: dataxlr8-portal-mcp

**Phase:** 2
**Status:** NOT STARTED
**PG Schema:** `portal`
**Source:** `apps/web/lib/portal-client.ts` (7 read functions) + `apps/web/lib/portal-write.ts` (19 write functions)

---

## Purpose

Client portal — project tracking, deliverables, approvals, comments, activity feed. Has both internal (employee) and external (client) views.

## TypeScript Functions (26 total)

### Read functions (portal-client.ts — 7):
- `getProjects(managerId?)` — list projects
- `getProjectById(id)` — get project
- `getDeliverables(projectId)` — list deliverables
- `getComments(projectId)` — list comments
- `getPendingComments()` — unapproved comments
- `getActivityFeed(projectId, limit)` — activity log
- `getPortalStats()` — dashboard stats

### Write functions (portal-write.ts — 19):
- `getClientByEmail(email)` — lookup client
- `getOrCreateClient(email, name)` — upsert client
- `getClientProjects(clientId)` — client's projects
- `getClientProjectById(clientId, projectId)` — single project for client
- `getProjectDeliverables(projectId)` — deliverables
- `approveDeliverable(id)` — client approves
- `rejectDeliverable(id, reason)` — client rejects
- `getProjectComments(projectId)` — comments
- `addComment(projectId, author, text)` — add comment
- `getProjectActivities(projectId)` — activity log
- `ensureEmployeeInPortal(employee)` — sync employee
- `createProject(data)` — create project
- `updateProject(id, data)` — update project
- `createDeliverable(data)` — create deliverable
- `updateDeliverable(id, data)` — update deliverable
- `submitDeliverableForReview(id)` — submit for client review
- `addEmployeeComment(projectId, employeeId, text)` — internal comment
- `resolveComment(id)` — mark comment resolved
- `getClientStats(clientId)` — per-client stats

## Target Tools

Deduplicated into ~18 tools:

| # | Tool | Source |
|---|------|--------|
| 1 | `list_projects` | `getProjects` + `getClientProjects` |
| 2 | `get_project` | `getProjectById` + `getClientProjectById` |
| 3 | `create_project` | `createProject` |
| 4 | `update_project` | `updateProject` |
| 5 | `list_deliverables` | `getDeliverables` + `getProjectDeliverables` |
| 6 | `create_deliverable` | `createDeliverable` |
| 7 | `update_deliverable` | `updateDeliverable` |
| 8 | `submit_for_review` | `submitDeliverableForReview` |
| 9 | `approve_deliverable` | `approveDeliverable` |
| 10 | `reject_deliverable` | `rejectDeliverable` |
| 11 | `list_comments` | `getComments` + `getProjectComments` |
| 12 | `add_comment` | `addComment` + `addEmployeeComment` |
| 13 | `resolve_comment` | `resolveComment` |
| 14 | `get_pending_comments` | `getPendingComments` |
| 15 | `get_activity_feed` | `getActivityFeed` + `getProjectActivities` |
| 16 | `get_or_create_client` | `getOrCreateClient` |
| 17 | `get_portal_stats` | `getPortalStats` + `getClientStats` |
| 18 | `ensure_employee` | `ensureEmployeeInPortal` |

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates
- [ ] All 18 tools work
- [ ] Deliverable approve/reject flow works
- [ ] Comment add/resolve flow works
- [ ] Client vs employee access separation
- [ ] Claude Code integration works
