# BRD: dataxlr8-booking-mcp

**Phase:** 3 | **Status:** NOT STARTED | **PG Schema:** `booking`
**Source:** `apps/web/lib/google-calendar.ts` (Google Calendar API)
**External Dependency:** Google Calendar API

## Purpose
Booking management — Google Calendar integration for scheduling site visits, client meetings, supplier inspections.

## Tools (4)
| # | Tool | Params | Description |
|---|------|--------|-------------|
| 1 | `list_bookings` | `from?`, `to?`, `limit?` | List upcoming bookings |
| 2 | `create_booking` | `title`, `start`, `end`, `attendees[]` | Create calendar event |
| 3 | `update_booking` | `id`, `title?`, `start?`, `end?` | Modify booking |
| 4 | `cancel_booking` | `id` | Cancel booking |

## Acceptance Criteria
- [ ] Build, schema, Google Calendar API integration, Claude Code integration
