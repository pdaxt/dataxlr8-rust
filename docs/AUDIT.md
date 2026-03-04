# Code Quality Audit — DataXLR8 Rust MCPs

**Audited:** 2026-03-04
**Scope:** `dataxlr8-mcp-core` + `dataxlr8-features-mcp`
**Auditor:** Production readiness review

---

## Summary

| Category | Rating | Issues |
|----------|--------|--------|
| **Architecture** | GOOD | Clean separation, schema isolation works |
| **Error Handling** | GOOD | Structured errors, fail-closed on unknowns |
| **Database** | NEEDS WORK | Fragile SQL splitting, no health check, N+1 in bulk |
| **Completeness** | NEEDS WORK | 8/9 tools (missing `remove_override`) |
| **Observability** | OK | tracing to stderr, but no metrics |
| **Testing** | MISSING | Zero tests in either crate |
| **CI/CD** | MISSING | No pipeline |
| **Shutdown** | NEEDS WORK | No signal handling |

---

## CRITICAL Issues (Must Fix Before Phase 1)

### 1. Missing `remove_override` tool
**File:** `features-mcp/src/tools/mod.rs`
**Impact:** Features-mcp claims 8 tools, TS source has 9. Missing `remove_override`.
**Fix:** Add `remove_override(flag_name, override_type, target)` tool.

### 2. N+1 Query in `check_flags_bulk`
**File:** `features-mcp/src/tools/mod.rs:408-437`
**Impact:** Queries each flag individually in a loop. With 50 flags, that's 50+ DB queries.
**Fix:** Use `WHERE name = ANY($1)` to batch-fetch all flags, then resolve overrides in bulk.

### 3. Fragile SQL Splitting in `execute_raw()`
**File:** `mcp-core/src/db.rs:56`
**Impact:** `sql.split(';')` breaks if SQL contains semicolons inside string literals (e.g., JSON defaults, CHECK constraints with semicolons in text).
**Note:** `features-mcp/src/db.rs` uses `sqlx::raw_sql()` directly which works correctly — PostgreSQL handles multi-statement natively.
**Fix:** Use `sqlx::raw_sql()` in core or document that `execute_raw()` must only be used with DDL statements.

### 4. No Graceful Shutdown Signal Handling
**File:** `features-mcp/src/main.rs`
**Impact:** SIGTERM (from gateway restarting a crashed MCP) won't trigger cleanup. DB connections may leak.
**Fix:** Add `tokio::signal::ctrl_c()` or `tokio::select!` with signal handler.

---

## IMPORTANT Issues (Fix Before Scale)

### 5. No `.env.example` File
**Impact:** New developers (or agents) won't know required env vars.
**Fix:** Add `.env.example` with `DATABASE_URL=postgres://...` and `RUST_LOG=info`.

### 6. No Database Health Check
**File:** `mcp-core/src/db.rs`
**Impact:** No way to verify DB is alive after connecting (for gateway health monitoring).
**Fix:** Add `Database::health_check()` → `SELECT 1`.

### 7. Inconsistent Schema Setup Pattern
**Impact:** Core has `Database::execute_raw()` (fragile), features-mcp uses `sqlx::raw_sql()` (correct). New MCPs won't know which to use.
**Fix:** Document the canonical pattern. Each MCP should use `sqlx::raw_sql()` in its own `db.rs`.

### 8. Tool Definition Boilerplate
**File:** `features-mcp/src/tools/mod.rs:67-206`
**Impact:** 140 lines of repetitive Tool struct construction for 8 tools. 22 MCPs × ~20 tools = massive boilerplate.
**Note:** Not critical. Can optimize later with macros or a builder.

---

## Code Quality Highlights (What's Good)

1. **Fail-closed security** — unknown flags return `{"enabled": false}` (line 398)
2. **RETURNING clause** — creates/updates use RETURNING to avoid read-back N+1 (lines 457, 503, 580)
3. **Batch override fetch** — `get_all_flags` uses `ANY($1)` to avoid N+1 on overrides (line 319)
4. **Database URL redaction** — Config Debug impl hides credentials (line 27)
5. **Schema isolation** — `features.*` namespace keeps tables separate
6. **UPSERT for overrides** — `ON CONFLICT DO UPDATE` handles idempotent sets (line 583)
7. **Structured errors** — McpError with codes maps to MCP protocol errors
8. **Proper tracing** — All operations logged with structured fields

---

## Dependency Audit

### mcp-core Cargo.toml
| Dep | Version | Status |
|-----|---------|--------|
| sqlx | 0.8 | OK — latest stable |
| serde | 1 | OK |
| thiserror | 2 | OK — latest |
| tracing | 0.1 | OK (0.1.x is current) |
| tracing-subscriber | 0.3 | OK |
| dotenvy | 0.15 | OK |
| chrono | 0.4 | OK |
| uuid | 1 | OK |

### features-mcp Cargo.toml
| Dep | Version | Status |
|-----|---------|--------|
| rmcp | 0.17 | OK — pinned to known good |
| dataxlr8-mcp-core | path | OK — local dep |
| sqlx | 0.8 | DUPLICATE — already in core |
| tokio | 1 (full) | OK |
| serde | 1 | DUPLICATE — already in core |
| anyhow | 1 | OK |
| tracing | 0.1 | DUPLICATE — already in core |
| chrono | 0.4 | DUPLICATE — already in core |
| uuid | 1 | DUPLICATE — already in core |

**Note:** 5 duplicate dependencies. Core should re-export commonly needed types so MCPs don't duplicate deps. Not blocking (Cargo deduplicates at compile time) but adds Cargo.toml noise.

---

## Test Coverage

**Unit tests:** 0
**Integration tests:** 0
**E2E tests:** Manual FIFO script only (`scripts/test-mcp.sh`)

---

## Action Items

| Priority | Item | Owner | Status |
|----------|------|-------|--------|
| P0 | Add `remove_override` tool | This audit | TODO |
| P0 | Fix `check_flags_bulk` N+1 | This audit | TODO |
| P0 | Add graceful shutdown signals | This audit | TODO |
| P1 | Add `.env.example` files | This audit | TODO |
| P1 | Add `Database::health_check()` | This audit | TODO |
| P1 | Document canonical schema setup pattern | This audit | TODO |
| P1 | Create MCP scaffold template | This audit | TODO |
| P2 | Re-export common types from core | Future | — |
| P2 | Tool definition macros | Future | — |
| P2 | CI/CD pipeline | Future | — |
| P2 | Unit + integration tests | Future | — |
