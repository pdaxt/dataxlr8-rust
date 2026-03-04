# BRD: dataxlr8-recording-mcp

**Phase:** 4 | **Status:** NOT STARTED | **PG Schema:** `recordings`
**External Dependency:** LiveKit Egress + S3/GCS
**Source:** NO EXISTING CODE — greenfield MCP.

## Purpose
Meeting recording management.

## Tools: TBD

**No existing source.** Tool definitions are speculative.

| # | Tool | Description | Confidence |
|---|------|-------------|------------|
| 1 | `start_recording` | Begin recording | SPECULATIVE |
| 2 | `stop_recording` | End recording | SPECULATIVE |
| 3 | `list_recordings` | List by room/date | SPECULATIVE |
| 4 | `get_recording` | Get metadata + URL | SPECULATIVE |

**Action required:** Evaluate LiveKit Egress API before finalizing.

## Acceptance Criteria
- [ ] LiveKit Egress capabilities evaluated
- [ ] Tool list finalized
- [ ] Build, integration, Claude Code
