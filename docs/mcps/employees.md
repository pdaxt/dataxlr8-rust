# BRD: dataxlr8-employees-mcp

**Phase:** 3
**Status:** NOT STARTED
**PG Schema:** `employees`
**Source:** `apps/web/lib/google-sheets.ts` (14 functions) + `mcp-servers/dataxlr8_employees_mcp/server.py` (14 tools)

---

## Purpose

Employee management — team members, roles, Google OAuth, sessions, invites. Currently in Google Sheets, migrating to PostgreSQL.

## Existing Python MCP Tools (14)

From `dataxlr8_employees_mcp`:

| # | Tool | Description |
|---|------|-------------|
| 1 | `list_employees` | List all employees |
| 2 | `get_employee` | Get employee by ID |
| 3 | `create_employee` | Create new employee |
| 4 | `update_employee` | Update employee fields |
| 5 | `deactivate_employee` | Deactivate employee |
| 6 | `search_employees` | Search by name/email |
| 7 | `get_employee_stats` | Aggregate stats |
| 8 | `list_invites` | List invite tokens |
| 9 | `create_invite` | Create invite |
| 10 | `validate_invite` | Check if invite is valid |
| 11 | `accept_invite` | Accept invite |
| 12 | `verify_session` | Verify session cookie |
| 13 | `create_session` | Create auth session |
| 14 | `employees_status` | System status |

## TypeScript Functions (14)

From `google-sheets.ts`:
- `getEmployees()`, `getEmployeeByEmail()`, `getEmployeeByGoogleId()`, `createEmployee()`, `updateEmployee()` — 5 employee functions
- `getTrainingModules()`, `getTrainingProgress()`, `updateTrainingProgress()` — 3 training (belongs in training-mcp)
- `getDeals()`, `createDeal()` — 2 deals (belongs in deals-mcp)
- `getInvites()`, `createInvite()`, `getInviteByToken()`, `acceptInvite()` — 4 invite functions

## Key Differences

- Python MCP has `verify_session` and `create_session` — critical for auth flow
- Python MCP has `deactivate_employee` and `search_employees` — missing from TS
- TS has `getEmployeeByGoogleId()` — needed for OAuth callback
- TS has `getEmployeeByEmail()` — Python uses `get_employee` with ID only

## Target Tool Count: 14 (match Python MCP)

## Migration Notes

- Google Sheets `Employees` + `Invites` tabs → PostgreSQL
- Preserve existing employee IDs and google_ids
- Session management is critical for web app auth
- `getEmployeeByGoogleId` must be fast (called on every OAuth callback)

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates
- [ ] All 14 tools ported from Python MCP
- [ ] `get_employee` supports lookup by ID, email, AND google_id
- [ ] Session create/verify works (critical for auth)
- [ ] Invite create → validate → accept flow works
- [ ] Claude Code integration works
