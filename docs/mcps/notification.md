# BRD: dataxlr8-notification-mcp

**Phase:** 4 | **Status:** NOT STARTED | **PG Schema:** `notifications`
**External Dependency:** Resend API
**Source:** NO EXISTING CODE — greenfield MCP. Some overlap with `email-mcp`.

## Purpose
In-app + email notification management.

## Overlap Warning

`email-mcp` (Phase 1) handles transactional emails. This MCP would add:
- In-app notification storage and delivery
- Notification preferences
- Multi-channel (email + in-app)

## Decision Required

Should notifications be a separate MCP, or folded into `email-mcp`?

## Tools: TBD (SPECULATIVE)
## Acceptance Criteria
- [ ] Scope vs email-mcp decided
- [ ] Tool list finalized
- [ ] Build, integration, Claude Code
