# BRD: dataxlr8-copilot-mcp

**Phase:** 5 | **Status:** NOT STARTED | **PG Schema:** `copilot`
**External Dependency:** Anthropic Claude API

## Purpose
AI copilot for meetings — real-time suggestions, agenda tracking, action item generation during live meetings.

## Tools (6)
| # | Tool | Description |
|---|------|-------------|
| 1 | `start_copilot` | Activate copilot for a meeting room |
| 2 | `stop_copilot` | Deactivate copilot |
| 3 | `get_suggestions` | Get current AI suggestions |
| 4 | `track_agenda` | Track agenda progress |
| 5 | `generate_summary` | Generate meeting summary |
| 6 | `extract_action_items` | Extract action items from discussion |

## Notes
- This is one of the few MCPs that calls an external AI API
- Uses Anthropic Claude API for real-time analysis
- Consider streaming responses for live suggestions

## Acceptance Criteria
- [ ] Build, Claude API integration, streaming works, Claude Code integration
