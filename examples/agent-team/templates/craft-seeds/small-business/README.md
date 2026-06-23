# Small Business — craft seed

A starting craft playbook for an agent-team **small-business** worker. Adapted from
[knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins)
(Apache-2.0 — see [../../CREDITS.md](../../CREDITS.md)).

These are **starting material, not final**: when the Manager adds a `small-business`
member with this seed, the member reads these skills during `self-onboard` and
**fits them to its own mandate**, then keeps sharpening them via `self-improve`.

## Skills (methodology)

- `business-pulse` — Produces a one-page cross-functional business snapshot for SMB owners — cash position (QuickBooks), sales trend (PayPal/Square), pipeline movement (HubSpot), this week's commitments (Calendar), urgent watch-list items (Gmail/Slack), and the single most important thing needing attention today.
- `call-list` — Ranks the top-5 leads most worth calling today, supplies talking points from email history, blocks time on the calendar, and drafts follow-up messages.
- `canva-creator` — Takes an approved content brief and executes a campaign end-to-end: builds the posting calendar, generates Canva designs for social posts, drafts caption and email copy, and stages social sends in HubSpot.
- `cash-flow-snapshot` — Reads AR/AP, historical cash timing, and known fixed costs from QuickBooks, PayPal, Stripe, or Square — or a CSV upload — and produces a 30/60/90-day cash flow forecast with percentage-variance confidence bands and named risk flags.
- `close-month` — Closes the month — reconciles QB vs payment processors, flags gaps, writes P&L narrative, exports close packet.
- `content-strategy` — Analyzes sales data from PayPal and QuickBooks to find top performers and slow movers, layers in seasonality, and produces a prioritized 30-day content brief: what to push, what offers to run, what to hold.
- `contract-review` — Lightweight NDA, MSA, and vendor contract review for SMBs without legal on staff.
- `crm-cleanup` — Scans HubSpot for stale deals, duplicate contacts, and missing fields, then fixes what the owner approves.
- `crm-maintenance` — Keeps HubSpot current without the owner opening it: creates and updates contacts and deals from email and calendar context, logs notes and calls, and flags stale records.
- `customer-pulse-check` — Synthesizes themes from PayPal disputes, HubSpot tickets, and review exports into a top-3 fixable issues list with drafted response templates.
- `customer-pulse` — Aggregates PayPal disputes, HubSpot feedback and tickets, and email sentiment (plus pasted or exported Google/Yelp reviews) into a themes report with verbatim evidence and a "do these three things this week" list.
- `friday-brief` — Delivers the Friday end-of-week pulse — revenue vs prior week, top sellers, wins and watches.
- `handle-complaint` — Handles an incoming customer complaint end-to-end — pulls context, drafts a response, and suggests an operational fix.
- `invoice-chase` — Drafts overdue-invoice reminder emails from QuickBooks and PayPal data, matched to each customer's payment history and tone (gentle for good customers, firm for repeat late payers).
- `job-post-builder` — Builds end-to-end hiring packets — job post, structured interview guide with scoring rubric, and offer letter template — from a hiring brief.
- `lead-triage` — Scores inbound HubSpot leads by engagement signals, company fit, and urgency markers to produce a "call these 5 today" list with talking points, drafts the follow-ups, and blocks Calendar time.
- `margin-analyzer` — Analyzes unit economics by product or service using PayPal merchant insights and QuickBooks cost data, benchmarks against inflation and cost changes, and shows pricing-scenario data (e.g.
- `monday-brief` — Generates a one-page Monday morning briefing — cash, sales, pipeline, week ahead, top three to-dos.
- `month-end-prep` — Walks an SMB owner through month-end close: reconciles QuickBooks against PayPal (and Square/Stripe) settlements, flags uncategorized transactions, suspicious duplicates, and missing receipts, then writes a plain-English P&L narrative and exports a close packet (xlsx + one-page PDF).
- `month-heads-up` — Runs on the 25th — shows the next 30-day cash-flow outlook and flags anything that needs attention before month-end.
- `plan-payroll` — Forecasts cash, ranks overdue invoices, and stages PayPal reminders so the owner can confidently run payroll.
- `price-check` — Produces a margin-by-product table and three pricing-scenario data views so the owner can see the full financial picture before making a pricing decision.
- `quarterly-review` — Generates a full QBR narrative — revenue trend, margin trend, customer health, top opportunities and risks — as a presentation-ready PDF or deck.
- `review-contract` — Reviews a contract in plain English, surfaces red flags with severity ratings, and produces a marked-up docx/PDF with suggested redlines.
- `run-campaign` — Runs an end-to-end marketing campaign — sales analysis, content brief, Canva assets, HubSpot send.
- `sales-brief` — Surfaces top and bottom sellers, identifies seasonality patterns, and produces a 2-week content brief to push winners and clear slow movers.
- `smb-onboard` — Claude as the trainer.
- `smb-router` — The front door to the Small Business plugin.
- `tax-prep` — Prepares tax-season materials — quarterly estimated tax calculation or year-end 1099 prep — and produces an accountant handoff packet.
- `tax-season-organizer` — Prepares tax-season materials for small business owners — framed as deliverables for their accountant, not tax advice.
- `ticket-deflector` — Reads a forwarded customer email or ticket, pulls order/refund status from PayPal and account history from HubSpot, drafts a tone-matched reply in the owner's writing voice, and can issue a PayPal refund with explicit owner approval.

## Connectors

`.mcp.json` + `CONNECTORS.md` list example MCP connectors for this role. They are
**examples — edit them to your own stack** (connect the tools your team actually
uses). A member proposes the connectors it needs; the owner approves and wires them.
