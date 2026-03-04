# BRD: dataxlr8-training-mcp

**Phase:** 3 | **Status:** NOT STARTED | **PG Schema:** `training`
**Source:** `apps/web/lib/google-sheets.ts` (Google Sheets `Training_Modules` + `Training_Progress` tabs)

## Purpose
Training module management and employee progress tracking. Migrate from Google Sheets.

## Tools (4)
| # | Tool | Params | Source Function |
|---|------|--------|----------------|
| 1 | `list_modules` | none | `getTrainingModules()` |
| 2 | `get_progress` | `employee_id` | `getTrainingProgress()` |
| 3 | `update_progress` | `employee_id`, `module_id`, `status`, `quiz_score?` | `updateTrainingProgress()` |
| 4 | `get_completion_report` | none | NEW (aggregate stats) |

## Acceptance Criteria
- [ ] Build, schema, all tools, Claude Code integration
