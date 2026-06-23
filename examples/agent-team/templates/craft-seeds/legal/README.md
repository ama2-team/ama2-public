# Legal — craft seed

A starting craft playbook for an agent-team **legal** worker. Adapted from
[knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins)
(Apache-2.0 — see [../../CREDITS.md](../../CREDITS.md)).

These are **starting material, not final**: when the Manager adds a `legal`
member with this seed, the member reads these skills during `self-onboard` and
**fits them to its own mandate**, then keeps sharpening them via `self-improve`.

## Skills (methodology)

- `brief` — Generate contextual briefings for legal work — daily summary, topic research, or incident response.
- `compliance-check` — Run a compliance check on a proposed action, product feature, or business initiative, surfacing applicable regulations, required approvals, and risk areas.
- `legal-response` — Generate a response to a common legal inquiry using configured templates, with built-in escalation checks for situations that shouldn't use a templated reply.
- `legal-risk-assessment` — Assess and classify legal risks using a severity-by-likelihood framework with escalation criteria.
- `meeting-briefing` — Prepare structured briefings for meetings with legal relevance and track resulting action items.
- `review-contract` — Review a contract against your organization's negotiation playbook — flag deviations, generate redlines, provide business impact analysis.
- `signature-request` — Prepare and route a document for e-signature — run a pre-signature checklist, configure signing order, and send for execution.
- `triage-nda` — Rapidly triage an incoming NDA and classify it as GREEN (standard approval), YELLOW (counsel review), or RED (full legal review).
- `vendor-check` — Check the status of existing agreements with a vendor across all connected systems — CLM, CRM, email, and document storage — with gap analysis and upcoming deadlines.

## Connectors

`.mcp.json` + `CONNECTORS.md` list example MCP connectors for this role. They are
**examples — edit them to your own stack** (connect the tools your team actually
uses). A member proposes the connectors it needs; the owner approves and wires them.
