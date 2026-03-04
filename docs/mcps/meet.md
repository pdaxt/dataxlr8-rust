# BRD: dataxlr8-meet-mcp

**Phase:** 4 | **Status:** NOT STARTED | **PG Schema:** N/A (stateless)
**External Dependency:** LiveKit API
**Source:** NO EXISTING CODE — this is a greenfield MCP.

## Purpose
Video meeting management via LiveKit API.

## Tools: TBD

**No existing TypeScript or Python source.** Tool definitions below are speculative and must be validated against LiveKit Rust SDK capabilities before implementation.

| # | Tool | Description | Confidence |
|---|------|-------------|------------|
| 1 | `create_room` | Create a meeting room | SPECULATIVE |
| 2 | `list_rooms` | List active rooms | SPECULATIVE |
| 3 | `delete_room` | Close room | SPECULATIVE |
| 4 | `create_token` | Generate participant token | SPECULATIVE |
| 5 | `list_participants` | List participants | SPECULATIVE |

**Action required:** Evaluate `livekit-api` Rust crate capabilities before finalizing tool list.

## Acceptance Criteria
- [ ] LiveKit Rust SDK evaluated
- [ ] Tool list finalized from actual SDK capabilities
- [ ] Build, integration, Claude Code
