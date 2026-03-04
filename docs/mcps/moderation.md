# BRD: dataxlr8-moderation-mcp

**Phase:** 1 | **Status:** NOT STARTED | **PG Schema:** `moderation`
**Source:** NO EXISTING CODE — greenfield MCP. No TypeScript or Python equivalent exists.

## Purpose
Content moderation and safety controls.

## Tools: TBD (SPECULATIVE)

**No existing source.** The original PLAN.md lists this as Phase 1, but there is no TypeScript or Python moderation code to port. All tool definitions below are speculative:

| # | Tool | Description | Confidence |
|---|------|-------------|------------|
| 1 | `list_rules` | List moderation rules | SPECULATIVE |
| 2 | `create_rule` | Add rule | SPECULATIVE |
| 3 | `check_content` | Check content against rules | SPECULATIVE |
| 4 | `add_to_blocklist` | Add to blocklist | SPECULATIVE |
| 5 | `check_blocklist` | Check blocklist | SPECULATIVE |

## Decision Required

Is moderation actually needed in Phase 1? Since there's no existing code to port, this could be deferred to a later phase when the need is clearer.

## Acceptance Criteria
- [ ] Need confirmed
- [ ] Tool list designed from actual requirements
- [ ] Build, schema, Claude Code
