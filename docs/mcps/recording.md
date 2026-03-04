# BRD: dataxlr8-recording-mcp

**Phase:** 4 | **Status:** NOT STARTED | **PG Schema:** `recordings`
**External Dependency:** LiveKit Egress + S3/GCS

## Purpose
Meeting recording management — start/stop recordings, store files, track recording metadata.

## Tools (6)
| # | Tool | Description |
|---|------|-------------|
| 1 | `start_recording` | Begin recording a room |
| 2 | `stop_recording` | End recording |
| 3 | `list_recordings` | List recordings by room/date |
| 4 | `get_recording` | Get recording metadata + download URL |
| 5 | `delete_recording` | Remove recording |
| 6 | `get_recording_stats` | Storage usage and counts |

## Acceptance Criteria
- [ ] Build, schema, LiveKit + storage integration, Claude Code integration
