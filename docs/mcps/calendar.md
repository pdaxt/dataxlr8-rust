# BRD: dataxlr8-calendar-mcp

**Phase:** 4 | **Status:** NOT STARTED | **PG Schema:** `calendar`
**External Dependency:** Google Calendar API
**Source:** NO EXISTING CODE beyond `google-calendar.ts` (3 functions, already covered by booking-mcp).

## Purpose
Org-wide calendar management — broader than booking-mcp.

## Overlap Warning

`booking-mcp` (Phase 3) already covers the 3 functions in `google-calendar.ts`. This MCP would add org-wide features like:
- Cross-employee availability checking
- Scheduling across multiple calendars
- Calendar sync

## Decision Required

Should this MCP exist separately, or should `booking-mcp` be expanded to cover org-wide calendaring?

**Action required:** Decide before Phase 4.

## Tools: TBD (SPECULATIVE)
## Acceptance Criteria
- [ ] Scope vs booking-mcp decided
- [ ] Tool list finalized
- [ ] Build, Google Calendar API, Claude Code
