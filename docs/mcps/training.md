# BRD: dataxlr8-training-mcp

**Phase:** 3 | **Status:** NOT STARTED | **PG Schema:** `training`
**Source:** `apps/web/lib/google-sheets.ts` (3 functions) + `mcp-servers/dataxlr8_training_mcp/server.py` (10 tools)

## Purpose
Training module management and employee progress tracking.

## Existing Python MCP Tools (10)

From `dataxlr8_training_mcp`:

| # | Tool | Description |
|---|------|-------------|
| 1 | `list_modules` | List training modules |
| 2 | `get_module` | Get module details |
| 3 | `create_module` | Create new module |
| 4 | `update_module` | Update module |
| 5 | `get_progress` | Get employee progress |
| 6 | `start_module` | Mark module as started |
| 7 | `complete_module` | Mark module as completed |
| 8 | `get_completion_report` | Aggregate completion stats |
| 9 | `get_employee_transcript` | Full training transcript for employee |
| 10 | `training_status` | System status |

## TypeScript Functions (3)

From `google-sheets.ts`:
- `getTrainingModules()`, `getTrainingProgress(employeeId)`, `updateTrainingProgress(employeeId, moduleId, status, quizScore?)`

## Target Tool Count: 10 (match Python MCP)

## Acceptance Criteria
- [ ] Build, schema, all 10 tools, Claude Code integration
