# Agent Prompt: dataxlr8-devtools-mcp

## What This Is

Development intelligence MCP. Every agent should use this to start sessions, log iterations, check progress, and pass quality gates.

**Repo:** pdaxt/dataxlr8-devtools-mcp
**Path:** /Users/pran/Projects/dataxlr8-devtools-mcp
**Status:** Compiles (20 tools).

## Agent Workflow

```
1. start_session(project, task)     → Get context, prompt, last iteration
2. ... do work ...
3. log_iteration(project, title, description)  → Document what was done
4. qa_gate(project_path)            → Verify quality before pushing
5. commit_and_push(message, path)   → Push to GitHub
6. end_session(session_id, summary) → Close session
```

## 20 Tools

### Session Management
1. `start_session` — Register session, read prompt + build status + last iteration
2. `end_session` — Log summary, close session

### Context
3. `get_prompt` — Read agent prompt from docs/prompts/{name}.md
4. `update_prompt` — Update prompt file (mark items done, add specs)

### Code Analysis
5. `get_build_status` — All repos: compiles?, LOC, tool count, last commit
6. `code_stats` — Single repo: LOC by file, fn count, struct count
7. `diff_summary` — Since ref: files changed, lines +/-, new files
8. `pattern_check` — Verify repo follows lego pattern

### Progress Tracking
9. `log_iteration` — Write iteration log to DB + GitHub
10. `progress_check` — Parse BUILD-PLAN.md vs reality
11. `update_progress` — Auto-update checkboxes based on actual state

### Git Operations
12. `repo_info` — Git status, branch, ahead/behind
13. `commit_and_push` — Stage + commit + push with branch safety
14. `create_issue` — Create GitHub issue
15. `comment_issue` — Comment on issue/PR
16. `create_pr` — Create pull request
17. `share` — Create private gist

### Meta
18. `list_repos` — All dataxlr8 repos with basic info
19. `repo_health` — Cross-repo health: compile status, pattern compliance
20. `qa_gate` — Pre-push quality gate

## Schema

```sql
devtools.sessions    — Track agent sessions (project, task, start/end, summary)
devtools.iterations  — Track iterations (project, title, description, stats, decisions)
```
