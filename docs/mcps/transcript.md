# BRD: dataxlr8-transcript-mcp

**Phase:** 4 | **Status:** NOT STARTED | **PG Schema:** `transcripts`

## Purpose
Meeting transcript storage, search, and retrieval. Full-text search over transcribed meeting content.

## Tools (9)
| # | Tool | Description |
|---|------|-------------|
| 1 | `create_transcript` | Store a new transcript |
| 2 | `get_transcript` | Get transcript by meeting ID |
| 3 | `search_transcripts` | Full-text search across all transcripts |
| 4 | `list_transcripts` | List by date/participant |
| 5 | `add_speaker_label` | Label speakers in transcript |
| 6 | `get_highlights` | Extract key moments |
| 7 | `get_action_items` | Extract action items from transcript |
| 8 | `export_transcript` | Export as text/SRT/VTT |
| 9 | `delete_transcript` | Remove transcript |

## Acceptance Criteria
- [ ] Build, schema, full-text search works, Claude Code integration
