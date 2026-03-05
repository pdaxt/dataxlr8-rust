# DataXLR8 MCP QA Report

**Date:** 2026-03-05
**Auditor:** QA Agent
**Scope:** All 6 production MCP servers

## Summary

| Repo | Build | Tools | Critical | Medium | Low |
|------|-------|-------|----------|--------|-----|
| dataxlr8-enrichment-mcp | PASS (3 warnings) | 12 | 0 | 1 | 2 |
| dataxlr8-crm-mcp | PASS (clean) | 12 | 1 | 2 | 2 |
| dataxlr8-email-mcp | PASS (clean) | 12 | 0 | 2 | 1 |
| dataxlr8-features-mcp | PASS (clean) | 9 | 0 | 0 | 1 |
| dataxlr8-commissions-mcp | PASS (1 warning) | 8 | 0 | 3 | 2 |
| dataxlr8-devtools-mcp | PASS (clean) | 19 | 0 | 1 | 2 |
| **TOTAL** | **6/6 pass** | **72** | **1** | **9** | **10** |

---

## 1. dataxlr8-enrichment-mcp

**Tools (12):** `enrich_person`, `enrich_company`, `verify_email`, `domain_emails`, `search_people`, `reverse_domain`, `bulk_enrich`, `tech_stack`, `hiring_signals`, `social_profiles`, `enrichment_stats`, `cache_lookup`

### Strengths
- Domain validation helper `is_valid_domain()` used consistently across all domain-accepting tools
- Email validation checks for control characters (CRLF injection prevention)
- ILIKE patterns properly escaped with `\\`, `\%`, `\_` in `search_people` (line 420-423)
- All SQL queries use parameterized bindings (`$1`, `$2`, etc.) — no injection risk
- Bulk operations handle per-item errors gracefully

### Issues

| Severity | Location | Issue |
|----------|----------|-------|
| Medium | `tools/mod.rs:260` | `expect("Failed to build HTTP client")` — panics on startup if reqwest client fails. Should return `Result` or use a fallback. |
| Low | `tools/mod.rs:541` | `unwrap_or((0,))` on `total_expired` query — silently swallows DB errors. Should log the error. |
| Low | Build | 3 compiler warnings: unused `set_with_ttl`, `pool` in cache.rs; unused `WhoisProvider` struct |

### Schema (db.rs)
- **Good:** GIN index on `query` JSONB column, index on `lookup_type`
- **Missing:** No index on `expires_at` — cleanup queries scanning expired entries will be slow at scale
- **Missing:** No index on `source` column

---

## 2. dataxlr8-crm-mcp

**Tools (12):** `create_contact`, `search_contacts`, `upsert_deal`, `move_deal`, `log_activity`, `get_pipeline`, `assign_contact`, `create_task`, `import_contacts`, `export_contacts`, `add_interaction`, `tag_contact`

### Strengths
- UUID parsing wrapped in `parse_uuid()` helper with clear error messages
- Stage validation against `VALID_STAGES` constant
- Activity type validation against `VALID_ACTIVITY_TYPES`
- `import_contacts` uses `ON CONFLICT (email) DO NOTHING` for idempotent imports
- `add_interaction` verifies contact exists before insert
- `tag_contact` verifies contact exists before tagging
- `export_contacts` builds dynamic SQL with positional params (no string interpolation)

### Issues

| Severity | Location | Issue |
|----------|----------|-------|
| **CRITICAL** | `tools/mod.rs:440` | **ILIKE wildcard injection** in `search_contacts`: `format!("%{query}%")` — user input containing `%` or `_` will act as SQL wildcards. Searching for `%` returns all rows. Must escape `%` → `\%` and `_` → `\_` before wrapping. Compare with enrichment-mcp line 420-423 which does this correctly. |
| Medium | `tools/mod.rs:514-518` | `upsert_deal` runs `CREATE UNIQUE INDEX IF NOT EXISTS` on **every call**. This DDL should be in `db.rs` schema setup, not per-request. Creates unnecessary lock overhead. |
| Medium | `tools/mod.rs:1052` | `unwrap_or_default()` in `tag_contact` silently swallows DB errors when fetching current tags |
| Low | `tools/mod.rs:396-405` | `create_contact` accepts all fields as optional (no required params in schema). Could insert a completely empty contact. At minimum `email` or `first_name` should be required. |
| Low | `tools/mod.rs:618` | `notes.unwrap_or_default()` in `move_deal` — minor, but auto-log activity body could be empty string instead of None |

### Schema (db.rs)
- **Good:** Foreign keys with referential integrity on deals→contacts, activities→contacts/deals
- **Good:** Comprehensive indexes on email, company, stage, contact_id, owner_id
- **Good:** `ON DELETE CASCADE` on contact_tags and contact_interactions
- **Good:** CHECK constraint on `interaction_type`
- **Missing:** No CHECK constraint on `deals.stage` — relies solely on application-level validation
- **Missing:** No index on `deals.owner_id` for pipeline-by-owner queries

---

## 3. dataxlr8-email-mcp

**Tools (12):** `send_email`, `send_template_email`, `create_template`, `list_templates`, `list_sent_emails`, `email_stats`, `create_sequence`, `enroll_contact`, `get_sequence_status`, `advance_sequence`, `pause_enrollment`, `list_sequences`

### Strengths
- Resend API key handled gracefully — `None` triggers dry_run mode instead of crash
- Template variable substitution is safe (simple string replace, no eval)
- Sequence enrollment uses `UNIQUE (sequence_id, contact_email)` constraint to prevent double-enrollment
- `advance_sequence` handles step-not-found edge case by marking enrollment complete
- Duplicate enrollment detected via DB error message inspection (line 609)

### Issues

| Severity | Location | Issue |
|----------|----------|-------|
| Medium | `tools/mod.rs:371` | `unwrap_or(None)` on template fetch query — silently swallows DB errors. Should return the error. |
| Medium | `tools/mod.rs:745` | `advance_sequence` logs sent emails with `cc_addrs` as literal string `'{}'` instead of empty array `$1`. This is a hardcoded SQL literal, not a bind param. If the column type is `TEXT[]`, this stores the string `{}` literally which could cause issues on read. |
| Low | `tools/mod.rs:384-386` | Template variable substitution does not warn when a variable in the template has no matching key in the provided variables — silently leaves `{{placeholder}}` in the output. |

### Schema (db.rs)
- **Good:** CHECK constraints on `status` columns for sent_emails, sequences, enrollments
- **Good:** Partial index on `enrollments.next_send_at WHERE status = 'active'` — efficient for advance_sequence queries
- **Good:** `ON DELETE CASCADE` from sequences to enrollments
- **Good:** UNIQUE constraint on (sequence_id, contact_email)

---

## 4. dataxlr8-features-mcp

**Tools (9):** `get_all_flags`, `get_flag`, `check_flag`, `check_flags_bulk`, `create_flag`, `update_flag`, `delete_flag`, `set_override`, `remove_override`

### Strengths
- **Fail-closed design:** Unknown flags default to disabled (line 371-374, 410)
- **No N+1 queries:** `get_all_flags` batch-fetches all overrides in single query with `ANY($1)` (line 292)
- **No N+1 queries:** `check_flags_bulk` batch-fetches flags with `ANY($1)` (line 384)
- Override priority clearly documented: user > role > global
- All mutations validate enum values (`flag_type`, `override_type`)
- Uses `RETURNING *` consistently — no separate read-back queries
- `set_override` uses `ON CONFLICT DO UPDATE` for idempotent upsert

### Issues

| Severity | Location | Issue |
|----------|----------|-------|
| Low | `tools/mod.rs:412` | `check_flags_bulk` still does N queries for `resolve_flag_state` per flag (override lookups). Could batch-fetch all overrides upfront like `get_all_flags` does. |

### Schema (db.rs)
- **Good:** CHECK constraints on `flag_type` and `override_type`
- **Good:** UNIQUE constraint on `(flag_id, override_type, target)`
- **Good:** `ON DELETE CASCADE` from flags to overrides
- **Excellent:** Cleanest schema of all repos

---

## 5. dataxlr8-commissions-mcp

**Tools (8):** `list_managers`, `get_manager`, `create_manager`, `record_commission`, `update_commission_status`, `get_commissions`, `commission_stats`, `leaderboard`

### Strengths
- Status transition logic in `update_commission_status` properly handles all transitions (pending→paid, pending→approved, approved→paid, cancelled)
- Manager existence verified before recording commission
- Commission amounts tracked bidirectionally (pending/earned totals on manager row)

### Issues

| Severity | Location | Issue |
|----------|----------|-------|
| Medium | `tools/mod.rs:189,195` | `get_manager` uses `unwrap_or(None)` on DB queries — silently swallows database errors (connection issues, schema mismatch). Should propagate as error_result. |
| Medium | `tools/mod.rs:253-257` | `record_commission` same pattern: `unwrap_or(None)` on manager existence check |
| Medium | `tools/mod.rs:453-459` | **N+1 query** in `leaderboard`: fetches deal_count per manager in a loop. Should use a single query with `LEFT JOIN` or subquery. |
| Low | `tools/mod.rs:329-346` | `update_commission_status` doesn't validate status transitions — allows `paid→pending` (going backwards). Should enforce forward-only transitions. |
| Low | Build | 1 compiler warning: unused `Referral` struct — defined but no tool uses it. The `referrals` table exists in schema but has no tool handlers. |

### Schema (db.rs)
- **Good:** CHECK constraints on `status` columns
- **Good:** `ON DELETE CASCADE` from commission_records and referrals to managers
- **Good:** Indexes on manager_id, status, email
- **Missing:** `referrals` table defined but unused by any tool — dead schema

---

## 6. dataxlr8-devtools-mcp

**Tools (19):** `start_session`, `end_session`, `get_prompt`, `update_prompt`, `get_build_status`, `code_stats`, `diff_summary`, `pattern_check`, `log_iteration`, `progress_check`, `update_progress`, `repo_info`, `commit_and_push`, `create_issue`, `comment_issue`, `create_pr`, `share`, `list_repos`, `repo_health`, `qa_gate`

### Strengths
- Session UUID validated before use in `end_session` (line 403)
- `commit_and_push` refuses main/master unless `allow_main=true`
- `qa_gate` comprehensive: checks pattern, compilation, uncommitted changes, pushed to remote
- `log_iteration` auto-captures code stats and diff summary
- `progress_check` cross-references BUILD-PLAN.md against actual build status
- All tool handlers properly validate required params

### Issues

| Severity | Location | Issue |
|----------|----------|-------|
| Medium | `tools/mod.rs:358` | `unwrap_or(None)` on last iteration fetch — silently swallows DB errors |
| Low | `tools/mod.rs:829-834` | `repo_health` has a hardcoded repo list that doesn't include `dataxlr8-devtools-mcp` itself — misses self-check |
| Low | `tools/mod.rs:346-349` | Prompt file path constructed from user input via `project.replace("dataxlr8-", "")` — no path traversal validation. Input like `../../etc/passwd` would construct an unexpected path. Low risk since it only reads a file. |

### Schema (db.rs)
- **Good:** UUID primary keys with `gen_random_uuid()`
- **Good:** Foreign key from iterations to sessions
- **Good:** Indexes on project and session_id
- **Missing:** No index on `iterations.created_at` — "last iteration" queries (`ORDER BY created_at DESC LIMIT 1`) could be slow at scale

---

## Cross-Cutting Observations

### Patterns Used Well Across All Repos
1. **Parameterized SQL everywhere** — no string interpolation in queries (except CRM's ILIKE issue)
2. **Consistent `error_result()`/`json_result()` response pattern** from shared `dataxlr8-mcp-core`
3. **Schema-per-service isolation** — each MCP gets its own Postgres schema (`crm.`, `email.`, `features.`, etc.)
4. **Consistent tool definition pattern** — all use `build_tools()` + `ServerHandler` trait

### Recurring Anti-Patterns
1. **`unwrap_or(None)` / `unwrap_or_default()` on DB queries** — appears in 4/6 repos. This silently swallows connection errors, schema mismatches, and constraint violations. Should use `match` with `Err(e) => error_result(...)`.
2. **Missing schema CHECK constraints** — CRM deals.stage relies on app validation only. If another client writes directly to DB, invalid stages could be inserted.

### Recommendations (Priority Order)
1. **FIX** CRM `search_contacts` ILIKE wildcard injection (critical)
2. **FIX** Move CRM's inline `CREATE UNIQUE INDEX` from `upsert_deal` to `db.rs`
3. **REPLACE** all `unwrap_or(None)` on DB queries with proper error propagation
4. **ADD** missing schema CHECK constraints (CRM deals.stage, CRM activities.activity_type)
5. **ADD** missing indexes (enrichment.expires_at, CRM deals.owner_id, devtools iterations.created_at)
6. **FIX** Commissions leaderboard N+1 query
7. **IMPLEMENT** referral tools in commissions-mcp (schema exists, no tools)
8. **CLEAN** compiler warnings (enrichment: 3, commissions: 1)

---

## Tool Count Verification

| Repo | Declared in `build_tools()` | Handled in `call_tool()` | Match |
|------|----------------------------|-------------------------|-------|
| enrichment-mcp | 12 | 12 | YES |
| crm-mcp | 12 | 12 | YES |
| email-mcp | 12 | 12 | YES |
| features-mcp | 9 | 9 | YES |
| commissions-mcp | 8 | 8 | YES |
| devtools-mcp | 19 | 19 | YES |
| **Total** | **72** | **72** | **YES** |
