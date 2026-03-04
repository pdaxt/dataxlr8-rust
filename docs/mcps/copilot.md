# BRD: dataxlr8-copilot-mcp

**Phase:** 5 | **Status:** NOT STARTED | **PG Schema:** `copilot`
**External Dependency:** Anthropic Claude API
**Source:** NO EXISTING CODE — greenfield MCP.

## Purpose
AI copilot for meetings — real-time suggestions during live meetings.

## Tools: TBD (SPECULATIVE)

**No existing source.** This MCP requires:
1. LiveKit integration (to receive meeting audio/transcripts)
2. Anthropic API integration (to generate suggestions)
3. Streaming responses

All tool definitions are speculative until the meeting infrastructure (meet-mcp, recording-mcp, transcript-mcp) is built.

## Acceptance Criteria
- [ ] Depends on meet-mcp + transcript-mcp being VERIFIED first
- [ ] Tool list designed from actual meeting infrastructure
- [ ] Build, streaming works, Claude Code
