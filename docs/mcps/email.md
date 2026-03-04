# BRD: dataxlr8-email-mcp

**Phase:** 1
**Status:** NOT STARTED
**PG Schema:** `email`
**Source:** `apps/web/lib/email.ts` (Resend API)
**External Dependency:** Resend API (`RESEND_API_KEY`)

---

## Purpose

Transactional email sending via Resend API. Handles scanner notifications, lead outreach, magic links, and report delivery. Logs all sent emails for audit.

## Current Implementation

Direct Resend API calls from `apps/web/lib/email.ts`:
- 6 email functions, each with inline HTML templates
- Admin email hardcoded: `19pran@gmail.com`
- From addresses: `leads@dataxlr8.ai`, `portal@dataxlr8.ai`, `reports@dataxlr8.ai`, `notifications@dataxlr8.ai`
- Calendar link: `https://cal.com/pran.ai/30min`

## Target: PostgreSQL Schema

```sql
CREATE SCHEMA IF NOT EXISTS email;

CREATE TABLE email.sent_log (
    id          TEXT PRIMARY KEY,
    template    TEXT NOT NULL,
    from_addr   TEXT NOT NULL,
    to_addr     TEXT NOT NULL,
    subject     TEXT NOT NULL,
    status      TEXT NOT NULL DEFAULT 'sent' CHECK (status IN ('sent', 'failed', 'bounced')),
    resend_id   TEXT,
    metadata    JSONB NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE email.templates (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    subject     TEXT NOT NULL,
    html_body   TEXT NOT NULL,
    from_addr   TEXT NOT NULL DEFAULT 'DataXLR8 <info@dataxlr8.ai>',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ON email.sent_log(to_addr);
CREATE INDEX ON email.sent_log(template);
CREATE INDEX ON email.sent_log(created_at);
```

## Tools (6)

| # | Tool | Params | Returns | Source Function |
|---|------|--------|---------|----------------|
| 1 | `send_scan_notification` | `email`, `url` | `{success, resend_id}` | `sendScanRequestedEmail()` |
| 2 | `send_lead_notification` | `leadEmail`, `companyName`, `industry`, `url`, `score`, `quickWins?` | `{success, resend_id}` | `sendLeadNotification()` |
| 3 | `send_lead_warm_email` | `to`, `companyName`, `industry`, `score`, `topOpportunity`, `firstName?`, `estimatedSavings?`, `quickWins?` | `{success, needsApproval}` | `sendLeadWarmEmail()` |
| 4 | `send_magic_link` | `to`, `name`, `magicLinkUrl` | `{success, resend_id}` | `sendClientMagicLink()` |
| 5 | `send_report_email` | `to`, `companyName`, `score`, `topOpportunity`, `pdfPath` | `{success, resend_id}` | `sendProReportEmail()` |
| 6 | `list_sent_emails` | `to?`, `template?`, `limit?` | Array of sent_log entries | NEW |

## Config

| Env Var | Required | Description |
|---------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection |
| `RESEND_API_KEY` | Yes | Resend API key |
| `ADMIN_EMAIL` | No | Default: `19pran@gmail.com` |
| `CALENDAR_LINK` | No | Default: `https://cal.com/pran.ai/30min` |

## Migration Notes

- HTML templates are currently inline in TypeScript — extract to `email.templates` table
- Resend Rust SDK: `resend_rs` crate (official)
- `send_report_email` needs to read PDF file from disk and attach as base64
- All sends should be logged to `email.sent_log`

## Acceptance Criteria

- [ ] `cargo build --release` < 10MB
- [ ] Schema auto-creates on startup
- [ ] `send_scan_notification` calls Resend API and logs
- [ ] `send_lead_notification` renders HTML and sends
- [ ] `send_magic_link` sends with correct template
- [ ] `list_sent_emails` returns log with filters
- [ ] Missing `RESEND_API_KEY` returns error (not panic)
- [ ] Rate limit handling (Resend has limits)
- [ ] Claude Code integration works
