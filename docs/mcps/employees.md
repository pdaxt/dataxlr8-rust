# BRD: dataxlr8-employees-mcp

**Phase:** 3
**Status:** NOT STARTED
**PG Schema:** `employees`
**Source:** `apps/web/lib/google-sheets.ts` (Google Sheets spreadsheet `1FvC4-9Y1Z3dyQoIJ_N3JCpI5cbM3_WJ0oyZQRxrbPT4`)

---

## Purpose

Employee management — team members, roles, Google OAuth integration, invite system. Currently stored in Google Sheets, migrating to PostgreSQL for proper CRUD and faster access.

## Current Data Store

Google Sheets `Employees` tab with columns: id, full_name, email, role, google_id, status, commission_rate, created_at, updated_at.
Google Sheets `Invites` tab with columns: id, email, full_name, role, commission_rate, token, status, created_at, accepted_at.

## Tools (9)

| # | Tool | Params | Returns | Source Function |
|---|------|--------|---------|----------------|
| 1 | `list_employees` | `status?`, `role?` | Array of Employee | `getEmployees()` |
| 2 | `get_employee_by_email` | `email` (required) | Employee or null | `getEmployeeByEmail()` |
| 3 | `get_employee_by_google_id` | `google_id` (required) | Employee or null | `getEmployeeByGoogleId()` |
| 4 | `create_employee` | `full_name`, `email`, `role` | Created employee (returns id) | `createEmployee()` |
| 5 | `update_employee` | `id` (required), partial fields | Updated employee | `updateEmployee()` |
| 6 | `list_invites` | `status?` | Array of Invite | `getInvites()` |
| 7 | `create_invite` | `email`, `full_name`, `role`, `commission_rate` | Invite with token | `createInvite()` |
| 8 | `get_invite_by_token` | `token` (required) | Invite or null | `getInviteByToken()` |
| 9 | `accept_invite` | `token` (required) | `{success}` | `acceptInvite()` |

## Migration Notes

- Google Sheets → PostgreSQL one-time migration
- Must preserve all existing employee IDs and google_ids
- Invite tokens need to remain valid through migration
- Web app auth flow (`/api/auth/google/callback`) needs to switch from Sheets to PG

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates
- [ ] `get_employee_by_google_id` works (critical for OAuth flow)
- [ ] Invite create → accept flow works end-to-end
- [ ] Claude Code integration works
