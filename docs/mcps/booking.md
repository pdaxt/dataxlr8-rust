# BRD: dataxlr8-booking-mcp

**Phase:** 3 | **Status:** NOT STARTED | **PG Schema:** `booking`
**Source:** `apps/web/lib/google-calendar.ts` (3 functions)
**External Dependency:** Google Calendar API

## Purpose
Booking management — Google Calendar integration for scheduling.

## TypeScript Functions (3)

From `google-calendar.ts`:
- `getAvailableSlots(date)` — get available time slots
- `createBooking(title, start, end, attendees)` — create calendar event
- `getAvailableDates(month)` — get available dates in a month

## Target Tools: 3 (matching TS source)

| # | Tool | Source Function |
|---|------|----------------|
| 1 | `get_available_slots` | `getAvailableSlots()` |
| 2 | `create_booking` | `createBooking()` |
| 3 | `get_available_dates` | `getAvailableDates()` |

## Acceptance Criteria
- [ ] Build, Google Calendar API integration, all 3 tools, Claude Code integration
