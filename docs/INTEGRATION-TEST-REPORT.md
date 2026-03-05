# DataXLR8 MCP Integration Test Report

**Date:** 2026-03-05 10:43 UTC
**Duration:** 7s
**Database:** PostgreSQL (local)

## Summary

| Metric | Count |
|--------|-------|
| Passed | 46 |
| Failed | 2 |
| Skipped | 2 |
| **Total** | **50** |

## Detailed Results

### 1. dataxlr8-features-mcp
- **Purpose:** Feature flags with role/user overrides
- **Binary size:** 7.1 MB
- **Tools:** 9 (get_all_flags, get_flag, check_flag, check_flags_bulk, create_flag, update_flag, delete_flag, set_override, remove_override)

| Test | Status | Detail |
|------|--------|--------|
| initialize | PASS | protocol 2024-11-05 |
| tools/list (9 tools) | PASS | get_all_flags, get_flag, check_flag, check_flags_bulk, create_flag, update_flag, delete_flag, set_ov |
| all tools have JSON Schema | PASS |  |
| create_flag | PASS | {   "id": "a0118c9b-d801-42e2-9434-c4b066317dbf",   "name": "integration_test_fl |
| get_flag | PASS | {   "id": "a0118c9b-d801-42e2-9434-c4b066317dbf",   "name": "integration_test_fl |
| get_flag returns correct name | PASS |  |
| check_flag (enabled) | PASS | {   "enabled": true,   "reason": "global setting" } |
| check_flag returns enabled=true | PASS |  |
| check_flag (with employee_id + role) | PASS | {   "enabled": true,   "reason": "global setting" } |
| check_flag (nonexistent → fail-closed) | PASS | {   "enabled": false,   "reason": "unknown flag defaults to disabled" } |
| fail-closed: nonexistent flag → enabled=false | PASS |  |
| update_flag | PASS | {   "id": "a0118c9b-d801-42e2-9434-c4b066317dbf",   "name": "integration_test_fl |
| update_flag took effect (enabled=false) | PASS |  |
| check_flags_bulk | PASS | {   "integration_test_flag": {     "enabled": false,     "reason": "global setti |
| delete_flag | PASS | {   "deleted": true,   "name": "integration_test_flag" } |
| delete_flag returns deleted=true | PASS |  |
| get_flag after delete (should error) | PASS | expected error: Flag 'integration_test_flag' not found |
| unknown tool returns error | PASS | expected error: Unknown tool: nonexistent_tool |

### 2. dataxlr8-crm-mcp
- **Purpose:** Contact & deal management
- **Binary size:** 7.2 MB
- **Tools:** 12 (create_contact, search_contacts, upsert_deal, move_deal, log_activity, get_pipeline, assign_contact, create_task, import_contacts, export_contacts, add_interaction, tag_contact)

| Test | Status | Detail |
|------|--------|--------|
| initialize | PASS |  |
| tools/list (12 tools) | PASS | create_contact, search_contacts, upsert_deal, move_deal, log_activity, get_pipeline, assign_contact, |
| create_contact | PASS | {   "id": "66d08e28-336f-45a7-9d29-d5e72c3ff156",   "email": "inttest@dataxlr8.c |
| search_contacts | PASS | [   {     "id": "66d08e28-336f-45a7-9d29-d5e72c3ff156",     "email": "inttest@da |
| upsert_deal | FAIL | tool error: Failed to upsert deal: error occurred while decoding column "value": mismatched types; R |
| upsert_deal (known bug: NUMERIC decode) | SKIP | Rust type mismatch for NUMERIC column — needs rust_decimal or f64 fix |
| get_pipeline | FAIL | tool error: Pipeline query failed: error occurred while decoding column "total_value": mismatched ty |
| get_pipeline (known bug: SUM type) | SKIP | total_value type mismatch — SUM returns NUMERIC, struct expects String |
| log_activity | PASS | {   "id": "b731d5ad-7eff-4615-9035-91c81f0d969c",   "contact_id": null,   "deal_ |
| tag_contact | PASS | {   "added": [],   "contact_id": "66d08e28-336f-45a7-9d29-d5e72c3ff156",   "remo |
| add_interaction | PASS | {   "id": "1d1bd343-37ea-4f95-9864-f6690853cdb1",   "contact_id": "66d08e28-336f |

### 3. dataxlr8-enrichment-mcp
- **Purpose:** Email/company/person enrichment
- **Binary size:** 12.0 MB
- **Tools:** 12 (enrich_person, enrich_company, verify_email, domain_emails, search_people, reverse_domain, bulk_enrich, tech_stack, hiring_signals, social_profiles, enrichment_stats, cache_lookup)

| Test | Status | Detail |
|------|--------|--------|
| initialize | PASS |  |
| tools/list (12 tools) | PASS | enrich_person, enrich_company, verify_email, domain_emails, search_people, reverse_domain, bulk_enri |
| verify_email (test@gmail.com) | PASS | {   "email": "test@gmail.com",   "deliverable": false,   "catch_all": false,   " |
| verify_email (fake@nonexistent.xyz) | PASS | {   "email": "fake@nonexistent.xyz",   "deliverable": false,   "catch_all": fals |
| enrichment_stats | PASS | {   "by_type": [     {       "count": 4,       "type": "email"     },     {      |
| cache_lookup | PASS | {   "found": false,   "lookup_type": "person",   "query": {     "email": "test@g |

### 4. dataxlr8-email-mcp
- **Purpose:** Email sending, templates & sequences
- **Binary size:** 8.8 MB
- **Tools:** 12 (send_email, send_template_email, create_template, list_templates, list_sent_emails, email_stats, create_sequence, enroll_contact, get_sequence_status, advance_sequence, pause_enrollment, list_sequences)

| Test | Status | Detail |
|------|--------|--------|
| initialize | PASS |  |
| tools/list (12 tools) | PASS | send_email, send_template_email, create_template, list_templates, list_sent_emails, email_stats, cre |
| create_template | PASS | {   "id": "f0b0f8e3-e704-4862-8f61-fc5712a227e7",   "name": "inttest_template",  |
| list_templates | PASS | [   {     "id": "7beda3f0-988e-4e3c-97a5-411ec81d4f11",     "name": "client_welc |
| email_stats | PASS | {   "total_sent": 0,   "total_failed": 0,   "total_dry_run": 3,   "recent": [    |
| list_sent_emails | PASS | [   {     "id": "7a5b7093-850d-46f6-9d54-f6c98e78b5b3",     "from_addr": "DataXL |
| list_sequences | PASS | [] |

### 5. dataxlr8-commissions-mcp
- **Purpose:** Commission tracking & leaderboards
- **Binary size:** 7.0 MB
- **Tools:** 8 (list_managers, get_manager, create_manager, record_commission, update_commission_status, get_commissions, commission_stats, leaderboard)

| Test | Status | Detail |
|------|--------|--------|
| initialize | PASS |  |
| tools/list (8 tools) | PASS | list_managers, get_manager, create_manager, record_commission, update_commission_status, get_commiss |
| create_manager | PASS | {   "id": "8d063fca-8bf5-4f95-9484-85b8c92628f7",   "name": "IntTest Manager",   |
| list_managers | PASS | [   {     "id": "794c68ae-4ee1-4cb5-8db9-ab92cf4415de",     "name": "Ananya Desa |
| record_commission | PASS | {   "id": "36824fa2-1d55-4f30-a244-7c60175953c2",   "manager_id": "8d063fca-8bf5 |
| commission_stats | PASS | {   "total_earned": 33000.0,   "total_pending": 10000.0,   "total_paid": 15000.0 |
| get_commissions | PASS | [   {     "id": "36824fa2-1d55-4f30-a244-7c60175953c2",     "manager_id": "8d063 |
| leaderboard | PASS | [   {     "name": "Ananya Desai",     "email": "ananya@dataxlr8.com",     "total |

## Test Protocol

Each MCP was tested using the MCP JSON-RPC 2.0 protocol over stdio:

1. **Build** — `cargo build --release` for each MCP binary
2. **Start** — Launch binary as subprocess with DATABASE_URL set
3. **Initialize** — Send `initialize` request, verify protocol version `2024-11-05`
4. **tools/list** — Verify all tools register with proper JSON Schema (`inputSchema.type = object`)
5. **CRUD roundtrip** — Create → Read → Update → Delete with data verification at each step
6. **Edge cases** — Unknown tools, nonexistent records, fail-closed behavior
7. **Cleanup** — Delete test data from PostgreSQL after each MCP test

## Architecture Notes

- All MCPs use `dataxlr8-mcp-core` shared library (DB connection, logging, MCP helpers)
- Each MCP auto-creates its PostgreSQL schema on startup (features.*, crm.*, etc.)
- All SQL queries use parameterized bindings (`$1`, `$2`, ...) — no SQL injection risk
- Fail-closed design: unknown feature flags default to `enabled: false`
- Binary sizes: 7-12 MB (Rust + sqlx + tokio + rmcp)
