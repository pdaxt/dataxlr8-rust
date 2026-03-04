# DataXLR8 Complete Feature Blueprint

_Research date: 2026-03-04_

Features organized by tier (must-have → competitive advantage → enterprise → platform play), with MCP tool mappings for the Rust migration.

---

## TIER 1: MUST-HAVE (Revenue-generating, competitive table stakes)

### 1A. Travel Operations Core
_Competitors: Tourwriter ($149/user/mo), Softrip, TOOGO, Lemax, Tourplan_

| Feature | MCP Tool | Description |
|---------|----------|-------------|
| Itinerary Builder | `quotation.build_itinerary` | Drag-drop, day-by-day, auto-pricing from supplier rates |
| Supplier Contract Loading | `supplier.load_contract` | Season-wise rates, room types, meal plans, child policies, cancellation |
| Multi-Currency Pricing | `quotation.calculate_pricing` | Live FX rates, markup per currency, display in client's currency |
| Group Manifest Management | `rooming.generate_manifest` | Passenger list, passport details, dietary prefs, accessibility |
| Hotel Allocation/Stop-Sale | `supplier.manage_allotment` | Room allotments, release dates, overbooking alerts |
| Transfer & Activity Scheduling | `booking.schedule_transfers` | Multi-leg transfers, activity timing, vehicle assignment |
| Proposal PDF Generation | `pdf.generate_proposal` | White-labeled per client, itineraries with photos, e-signature |
| Booking Confirmation Workflow | `booking.confirm` | Supplier emails, voucher generation, payment tracking |
| GST/Tax Compliance | `quotation.calculate_gst` | Indian GST, TCS on overseas tours, export invoicing |
| WhatsApp Integration | `notification.send_whatsapp` | Quotation sharing, booking updates, guest comms |

### 1B. CRM & Sales Pipeline
_Competitors: Salesforce ($25-300/user), HubSpot ($15-234/user), Pipedrive ($14-99/user)_

| Feature | MCP Tool | Description |
|---------|----------|-------------|
| Lead Capture & Scoring | `contacts.score_lead` | Rule-based + intent signals |
| Multi-Pipeline Deals | `deals.create_pipeline` | FIT, Groups, MICE, Corporate pipelines |
| Weighted Forecasting | `deals.forecast` | Win probability x deal value, projections |
| Email Sequences | `email.create_sequence` | Automated follow-up drips with personalization |
| Activity Timeline | `contacts.get_timeline` | Unified view: emails, calls, meetings, quotes per contact |
| Duplicate Detection | `contacts.find_duplicates` | Fuzzy matching on name, email, phone |
| Custom Fields | `portal.add_custom_field` | User-defined fields on any entity |
| Territory Assignment | `deals.assign_territory` | Geo or account-based rules |

### 1C. Client Portal
_Most travel software has NO client portal — killer differentiator_

| Feature | MCP Tool | Description |
|---------|----------|-------------|
| Project Dashboard | `portal.get_dashboard` | Client sees trip/project status, deliverables, timeline |
| Deliverable Review | `portal.submit_deliverable` | Approve/reject with comments, version history |
| Document Sharing | `portal.share_documents` | Proposals, contracts, vouchers, invoices |
| Real-time Chat | `portal.send_message` | Threaded conversations per project |
| Payment Status | `portal.payment_status` | Outstanding amounts, history, receipts |
| Guest Self-Service | `portal.guest_form` | Passport details, dietary prefs, room preferences |

---

## TIER 2: COMPETITIVE ADVANTAGE (Differentiates from incumbents)

### 2A. AI Agent Layer (The MCP Superpower)
_Nobody else has this natively. This is the pitch._

| Feature | MCP Tool | Why Game-Changing |
|---------|----------|-------------------|
| AI Sales Agent | `ai.sales_agent` | Autonomously qualifies leads, drafts proposals, follows up |
| AI Quotation Generator | `ai.generate_quotation` | Natural language → complete costed itinerary in seconds |
| AI Meeting Copilot | `copilot.assist` | Real-time suggestions, auto-extracts action items |
| AI Email Writer | `ai.draft_email` | Context-aware, uses deal history + contact preferences |
| AI Supplier Negotiator | `ai.negotiate_rate` | Analyzes historical rates, drafts counter-offers |
| Natural Language Reports | `analytics.nl_query` | "Conversion rate for MICE leads from UK in Q4" → instant |
| AI Trip Recommender | `ai.recommend_trip` | Based on client history, preferences, budget, season |

### 2B. Analytics & Dashboards
_What Salesforce charges $300/user for_

| Feature | MCP Tool | Description |
|---------|----------|-------------|
| Custom Dashboards | `analytics.create_dashboard` | Revenue, pipeline, bookings, team performance |
| Sales Leaderboard | `analytics.leaderboard` | Gamified with commission tracking |
| Conversion Funnel | `analytics.funnel` | Inquiry → Quote → Booking → Ops → Post-trip |
| Revenue by Source | `analytics.revenue_by_source` | Which lead sources convert best |
| Supplier Scorecard | `analytics.supplier_scorecard` | On-time delivery, complaint rate, response time |
| Scheduled Reports | `analytics.schedule_export` | Daily/weekly email digests |

### 2C. Workflow Automation
_Built-in Zapier replacement_

| Feature | MCP Tool | Description |
|---------|----------|-------------|
| If-Then Triggers | `automation.create_rule` | "Deal won → generate invoice + confirm supplier" |
| Approval Chains | `automation.approval_flow` | Quote above $10K needs manager approval |
| Auto-Assignment | `automation.assign_lead` | Round-robin or rule-based distribution |
| SLA Alerts | `automation.sla_monitor` | "Quote not sent in 4 hours → alert manager" |
| Recurring Tasks | `automation.schedule_recurring` | Monthly reconciliation, quarterly reviews |

---

## TIER 3: ENTERPRISE READY (For $10M+ companies)

### 3A. Security & Compliance

| Feature | Why | Effort |
|---------|-----|--------|
| SSO/SAML | Enterprise gate requirement | Medium |
| SCIM Provisioning | Automated user management | Medium |
| RBAC | Custom roles, granular permissions | Medium |
| Audit Logs | Immutable trail | Low-Medium |
| SOC 2 Type II | US enterprise gate | High (process) |
| ISO 27001 | International markets | High (process) |
| GDPR | EU data protection | Medium |
| Multi-Tenant | Org-level isolation, per-org billing | High |
| API Keys + Rate Limiting | Developer platform | Medium |
| Data Residency | Region-specific storage | Medium |

### 3B. Integrations Ecosystem

| Integration | Priority | Why |
|-------------|----------|-----|
| Tally/QuickBooks/Xero | High | Accounting sync — every agency needs this |
| Razorpay/Stripe | High | Payment collection, payment links |
| WhatsApp Business API | High | India/Asia communication |
| Google Workspace | Done | Calendar, Drive, Sheets, Docs |
| GDS (Amadeus/Sabre) | Medium-High | Flight/hotel inventory |
| Bedbank APIs (Hotelbeds) | Medium | Hotel inventory aggregation |
| Viator/GetYourGuide | Medium | Activity/tour inventory |
| Zapier/Make.com | Medium | Connect to 5000+ apps |
| Slack/Teams | Low | Team notifications |
| UPI Payment APIs | Medium | India-specific payment |

### 3C. Mobile & PWA

| Feature | Why |
|---------|-----|
| PWA | 52% of OTA bookings on mobile |
| Offline Mode | Agents in field need quotation access |
| Push Notifications | Deal updates, client messages |
| Camera Integration | Scan receipts, passports, business cards |

---

## TIER 4: PLATFORM PLAY (The Odoo Strategy)

### 4A. Open-Source Core + Paid Cloud

| Component | Open Source | Paid |
|-----------|------------|------|
| Core MCP tools (CRUD) | Yes | — |
| PostgreSQL schemas | Yes | — |
| Gateway (basic) | Yes | — |
| AI Agent features | — | Yes |
| Cloud hosting | — | Yes ($39-199/user/mo) |
| Premium integrations (GDS, payments) | — | Yes |
| White-labeling | — | Yes |
| SSO/Audit/Multi-tenant | — | Yes |
| Priority support | — | Yes |

### 4B. MCP Marketplace
_First-mover advantage — nobody has this yet_

| Concept | How It Works |
|---------|-------------|
| Third-Party MCP Plugins | Other devs build MCP servers for the gateway |
| Revenue Share | 70/30 split on marketplace sales |
| Verified MCPs | Security-audited, performance-tested |
| Templates | Pre-built workflow templates per industry |

### 4C. Multi-Vertical Expansion

| Vertical | Modification Needed |
|----------|---------------------|
| Travel/DMC (current) | Core product |
| Real Estate | Swap suppliers→properties, itineraries→viewings |
| Event Management (MICE) | Add venue management, vendor coordination |
| Consulting Firms | Project delivery, billing, client portal |
| Education/Coaching | Course delivery, student tracking |

---

## Feature Count Summary

| Tier | Category | Features | MCP Tools |
|------|----------|----------|-----------|
| T1 | Travel Operations | 10 | 10 |
| T1 | CRM & Sales | 8 | 8 |
| T1 | Client Portal | 6 | 6 |
| T2 | AI Agent Layer | 7 | 7 |
| T2 | Analytics | 6 | 6 |
| T2 | Automation | 5 | 5 |
| T3 | Security/Compliance | 10 | N/A |
| T3 | Integrations | 10 | 10 |
| T3 | Mobile | 4 | N/A |
| T4 | Platform | 8 | N/A |
| **Total** | | **74** | **52** |
