# DataXLR8 Tmux Multi-Agent Layout

_48 agents building in parallel across 4 screens._

_Updated: 2026-03-04_

---

## Overview

```
4 screens × 4 windows × 3 panes = 48 concurrent agents

Screen 1 (claude6):         MCP Development
Screen 2 (claude6-screen2): Web + Portals
Screen 3 (claude6-screen3): Testing + CI/CD
Screen 4 (claude6-screen4): Infrastructure + Ops
```

---

## Screen 1: `claude6` — MCP Development

Build the Rust MCP servers. Each window focuses on one MCP. Pane 0 builds, Pane 1 tests, Pane 2 handles supporting work.

### Window 0: enrichment-mcp (P0 — THE WEDGE)

| Pane | Agent ID | Task | Repo |
|------|----------|------|------|
| 0.0 | `claude6:0.0` | Build enrichment-mcp tools (12 tools) | `dataxlr8-enrichment-mcp` |
| 0.1 | `claude6:0.1` | Test enrichment-mcp + write unit tests | `dataxlr8-enrichment-mcp` |
| 0.2 | `claude6:0.2` | Build data source adapters (LinkedIn, DNS, SMTP) | `dataxlr8-enrichment-mcp` |

### Window 1: crm-mcp (P0)

| Pane | Agent ID | Task | Repo |
|------|----------|------|------|
| 1.0 | `claude6:1.0` | Build crm-mcp tools (10 tools) | `dataxlr8-crm-mcp` |
| 1.1 | `claude6:1.1` | Test crm-mcp + pipeline logic | `dataxlr8-crm-mcp` |
| 1.2 | `claude6:1.2` | CRM schema design + migrations | `dataxlr8-crm-mcp` |

### Window 2: gateway-mcp (P0)

| Pane | Agent ID | Task | Repo |
|------|----------|------|------|
| 2.0 | `claude6:2.0` | Build gateway (process mgr + HTTP server) | `dataxlr8-gateway-mcp` |
| 2.1 | `claude6:2.1` | Test gateway routing + tool aggregation | `dataxlr8-gateway-mcp` |
| 2.2 | `claude6:2.2` | Gateway config (dataxlr8.toml) + auth | `dataxlr8-gateway-mcp` |

### Window 3: Wave 2 MCPs (P1)

| Pane | Agent ID | Task | Repo |
|------|----------|------|------|
| 3.0 | `claude6:3.0` | Build sales-mcp (10 tools) | `dataxlr8-sales-mcp` |
| 3.1 | `claude6:3.1` | Build finance-mcp (8 tools, GST) | `dataxlr8-finance-mcp` |
| 3.2 | `claude6:3.2` | Build scraper-mcp (6 tools) | `dataxlr8-scraper-mcp` |

---

## Screen 2: `claude6-screen2` — Web + Portals

Build the Rust Axum web application. All panes work on `dataxlr8-web` repo.

### Window 0: Public Website

| Pane | Agent ID | Task | Branch |
|------|----------|------|--------|
| 0.0 | `screen2:0.0` | Public routes (/, /pricing, /about) | `feature/public-site` |
| 0.1 | `screen2:0.1` | Askama templates + TailwindCSS | `feature/public-site` |
| 0.2 | `screen2:0.2` | Static assets (CSS, JS, images) | `feature/public-site` |

### Window 1: Employee Portal

| Pane | Agent ID | Task | Branch |
|------|----------|------|--------|
| 1.0 | `screen2:1.0` | New team routes (deals, training, resources) | `feature/employee-portal` |
| 1.1 | `screen2:1.1` | Team templates (deals Kanban, training UI) | `feature/employee-portal` |
| 1.2 | `screen2:1.2` | Test employee portal (Playwright) | `feature/employee-portal` |

### Window 2: Client Portal

| Pane | Agent ID | Task | Branch |
|------|----------|------|--------|
| 2.0 | `screen2:2.0` | Client routes (login, dashboard, projects) | `feature/client-portal` |
| 2.1 | `screen2:2.1` | Client templates + client auth | `feature/client-portal` |
| 2.2 | `screen2:2.2` | Test client portal (Playwright) | `feature/client-portal` |

### Window 3: Training + Docs

| Pane | Agent ID | Task | Branch |
|------|----------|------|--------|
| 3.0 | `screen2:3.0` | Training module routes + quiz engine | `feature/training` |
| 3.1 | `screen2:3.1` | Documentation site (/docs) | `feature/docs` |
| 3.2 | `screen2:3.2` | Blog engine (/blog) | `feature/blog` |

---

## Screen 3: `claude6-screen3` — Testing + CI/CD

Quality assurance and automation.

### Window 0: MCP Integration Tests

| Pane | Agent ID | Task |
|------|----------|------|
| 0.0 | `screen3:0.0` | Write integration tests (MCP ↔ PostgreSQL) |
| 0.1 | `screen3:0.1` | Cross-MCP workflow tests (enrichment → crm → email) |
| 0.2 | `screen3:0.2` | Test database management (create/drop test schemas) |

### Window 1: Web E2E Tests

| Pane | Agent ID | Task |
|------|----------|------|
| 1.0 | `screen3:1.0` | Playwright E2E: employee portal flows |
| 1.1 | `screen3:1.1` | Playwright E2E: client portal flows |
| 1.2 | `screen3:1.2` | API endpoint tests (curl/reqwest) |

### Window 2: CI/CD Pipeline

| Pane | Agent ID | Task |
|------|----------|------|
| 2.0 | `screen3:2.0` | GitHub Actions: per-MCP CI workflow template |
| 2.1 | `screen3:2.1` | Release automation: tag → build → GitHub Release |
| 2.2 | `screen3:2.2` | Binary distribution: crates.io + GitHub Releases |

### Window 3: Performance + Monitoring

| Pane | Agent ID | Task |
|------|----------|------|
| 3.0 | `screen3:3.0` | Benchmark: tool call latency, memory, binary size |
| 3.1 | `screen3:3.1` | Load test: concurrent tool calls through gateway |
| 3.2 | `screen3:3.2` | Monitoring: health checks, alerting, logs |

---

## Screen 4: `claude6-screen4` — Infrastructure + Ops

Database, deployment, and supporting services.

### Window 0: PostgreSQL

| Pane | Agent ID | Task |
|------|----------|------|
| 0.0 | `screen4:0.0` | Schema management + migrations |
| 0.1 | `screen4:0.1` | Data migration: Google Sheets → PostgreSQL |
| 0.2 | `screen4:0.2` | Backup strategy + monitoring |

### Window 1: Gateway + Process Management

| Pane | Agent ID | Task |
|------|----------|------|
| 1.0 | `screen4:1.0` | Gateway configuration (dataxlr8.toml) |
| 1.1 | `screen4:1.1` | Process monitoring (MCP health, auto-restart) |
| 1.2 | `screen4:1.2` | Systemd/launchd service files |

### Window 2: Chrome Extension

| Pane | Agent ID | Task |
|------|----------|------|
| 2.0 | `screen4:2.0` | Chrome Extension: LinkedIn enrichment overlay |
| 2.1 | `screen4:2.1` | Chrome Extension: popup UI + settings |
| 2.2 | `screen4:2.2` | Chrome Web Store: listing + screenshots |

### Window 3: Cloud Hosting

| Pane | Agent ID | Task |
|------|----------|------|
| 3.0 | `screen4:3.0` | GCP deployment: Cloud Run + Cloud SQL |
| 3.1 | `screen4:3.1` | Cloudflare: DNS, CDN, SSL for dataxlr8.com |
| 3.2 | `screen4:3.2` | Deployment scripts + environment management |

---

## Activation Sequence

Not all 48 agents need to run simultaneously. Activate in waves matching the build order:

### Week 1-2 (Wave 1): 16 agents

```
Screen 1: W0 (enrichment), W1 (crm), W2 (gateway) = 9 agents
Screen 2: W0 (public site) = 3 agents
Screen 4: W0 (PostgreSQL setup) = 3 agents
Screen 3: W2.0 (CI template) = 1 agent
```

### Week 3-4 (Wave 2): +16 agents (32 total)

```
Screen 1: W3 (sales, finance, scraper) = 3 agents
Screen 2: W1 (employee portal), W2 (client portal) = 6 agents
Screen 3: W0 (integration tests), W1 (E2E tests) = 6 agents
Screen 4: W0.1 (data migration) = 1 agent
```

### Month 2 (Wave 3): +12 agents (44 total)

```
Screen 2: W3 (training, docs, blog) = 3 agents
Screen 3: W3 (benchmarks, load tests) = 3 agents
Screen 4: W2 (Chrome Extension), W3 (Cloud hosting) = 6 agents
```

### Month 3+ (Wave 4): All 48

All screens fully active for meeting domain MCPs, enterprise features, and scale.

---

## Agent Naming Convention

```
<screen>:<window>.<pane>

Examples:
  claude6:0.0     → Screen 1, Window 0, Pane 0 (enrichment-mcp build)
  screen2:2.1     → Screen 2, Window 2, Pane 1 (client portal templates)
  screen3:1.0     → Screen 3, Window 1, Pane 0 (Playwright E2E)
  screen4:3.2     → Screen 4, Window 3, Pane 2 (deployment scripts)
```

---

## Coordination Checkpoints

Daily at end of session, each screen lead reports:

| Screen | Lead Pane | Reports |
|--------|-----------|---------|
| 1 (MCPs) | `claude6:0.0` | MCPs built, tools working, tests passing |
| 2 (Web) | `screen2:0.0` | Pages live, portals working, auth flows |
| 3 (Test) | `screen3:0.0` | Test coverage, CI status, blockers |
| 4 (Infra) | `screen4:0.0` | DB status, deployments, infrastructure |
