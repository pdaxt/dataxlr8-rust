# BRD: dataxlr8-notification-mcp

**Phase:** 4 | **Status:** NOT STARTED | **PG Schema:** `notifications`
**External Dependency:** Resend API

## Purpose
Notification management — in-app notifications, email notifications, notification preferences.

## Tools (8)
| # | Tool | Description |
|---|------|-------------|
| 1 | `list_notifications` | List user's notifications |
| 2 | `create_notification` | Create new notification |
| 3 | `mark_read` | Mark notification as read |
| 4 | `mark_all_read` | Mark all as read |
| 5 | `delete_notification` | Remove notification |
| 6 | `get_preferences` | Get user notification preferences |
| 7 | `update_preferences` | Update notification preferences |
| 8 | `send_notification` | Send via appropriate channel (in-app, email, both) |

## Acceptance Criteria
- [ ] Build, schema, email integration, Claude Code integration
