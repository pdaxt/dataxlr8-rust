# BRD: dataxlr8-analytics-mcp

**Phase:** 4 | **Status:** NOT STARTED | **PG Schema:** `analytics`
**Source:** NO EXISTING CODE — greenfield MCP. However `mcp-servers/dataxlr8_metrics_mcp` (10 tools) covers some of this domain.

## Existing Related: dataxlr8_metrics_mcp (Python, 10 tools)

| # | Tool | Description |
|---|------|-------------|
| 1 | `metrics_status` | System status |
| 2 | `define_kpi` | Define a KPI |
| 3 | `record_kpi` | Record KPI value |
| 4 | `get_kpi` | Get KPI data |
| 5 | `get_dashboard` | Dashboard view |
| 6 | `record_health_check` | Record health check |
| 7 | `get_health_report` | Health report |
| 8 | `get_alerts` | List alerts |
| 9 | `acknowledge_alert` | Acknowledge alert |
| 10 | `get_trends` | Trend analysis |

## Decision Required

Should this MCP:
- (A) Replace `dataxlr8_metrics_mcp` (port its 10 tools to Rust), or
- (B) Be a new cross-domain analytics layer on top of all other MCP schemas

**Action required:** Decide scope before implementation.

## Acceptance Criteria
- [ ] Scope decided
- [ ] Tool list finalized from actual requirements
- [ ] Build, aggregation queries, Claude Code
