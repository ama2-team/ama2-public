# Enterprise Search — craft seed

A starting craft playbook for an agent-team **enterprise-search** worker. Adapted from
[knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins)
(Apache-2.0 — see [../../CREDITS.md](../../CREDITS.md)).

These are **starting material, not final**: when the Manager adds a `enterprise-search`
member with this seed, the member reads these skills during `self-onboard` and
**fits them to its own mandate**, then keeps sharpening them via `self-improve`.

## Skills (methodology)

- `digest` — Generate a daily or weekly digest of activity across all connected sources.
- `knowledge-synthesis` — Combines search results from multiple sources into coherent, deduplicated answers with source attribution.
- `search-strategy` — Query decomposition and multi-source search orchestration.
- `search` — Search across all connected sources in one query.
- `source-management` — Manages connected MCP sources for enterprise search.

## Connectors

`.mcp.json` + `CONNECTORS.md` list example MCP connectors for this role. They are
**examples — edit them to your own stack** (connect the tools your team actually
uses). A member proposes the connectors it needs; the owner approves and wires them.
