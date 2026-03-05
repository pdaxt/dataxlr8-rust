# Agent Prompt: dataxlr8-webhooks-mcp

## What This Is

Webhook delivery system. Sends outbound webhooks on events and manages subscriptions with retry logic.

**Repo:** pdaxt/dataxlr8-webhooks-mcp
**Path:** /Users/pran/Projects/dataxlr8-webhooks-mcp
**Status:** Not started. Agent building.

## Current State

- Repo not yet created
- Depends on dataxlr8-mcp-core for shared helpers
- Uses reqwest for HTTP delivery
- HMAC-SHA256 signing for payload verification

## What Needs Doing

### Initial Build

Follow the lego pattern from `_pattern.md`. Implement 8 tools for webhooks:

- Subscription management (URL, events, secret for signing)
- Outbound delivery with HMAC-SHA256 signature header
- Exponential backoff retry (1min, 5min, 30min, 2hr, 24hr)
- Delivery log with response status and body
- Dead letter queue for permanently failed deliveries

### Schema Design

```
webhooks.subscriptions   — webhook endpoints with event filters and signing secret
webhooks.deliveries      — delivery attempts with status, response, duration
webhooks.dead_letters    — permanently failed deliveries after max retries
```

### Done When

- `cargo build` passes
- All 8 tools implemented
- Follows lego pattern
- git push to GitHub

## 8 Tools

1. `create_subscription` — register a webhook URL for specific events with signing secret
2. `list_subscriptions` — list all subscriptions with status and event filters
3. `update_subscription` — update URL, events, or enabled status
4. `delete_subscription` — remove a subscription
5. `send_webhook` — deliver a payload to all matching subscriptions for an event
6. `delivery_log` — query delivery history (subscription_id, status, date range)
7. `retry_delivery` — manually retry a failed delivery
8. `dead_letters` — list permanently failed deliveries for investigation

## Schema

```sql
webhooks.subscriptions   — id, url, events (text[]), secret, enabled, created_at, updated_at
webhooks.deliveries      — id, subscription_id, event_name, payload (jsonb), status_code, response_body, duration_ms, attempt, delivered_at
webhooks.dead_letters    — id, subscription_id, event_name, payload (jsonb), last_error, attempts, failed_at
```
