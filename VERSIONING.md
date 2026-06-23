# Versioning Policy

## Quick reference

- All public surfaces follow [Semantic Versioning 2.0.0](https://semver.org/).
- CLI / MCP / Skills are versioned **independently**.
- First public release is `1.0.0` for every surface.
- Tags pushed from `main` only. Pre-release tags use `-rc.N`, `-beta.N`, `-alpha.N` suffixes.

## When to expect a bump

| Type | Trigger | Example |
| --- | --- | --- |
| `PATCH` | Bug fix, no behavior change. | 1.0.0 → 1.0.1 |
| `MINOR` | New feature, backwards-compatible. | 1.0.0 → 1.1.0 |
| `MAJOR` | Breaking change, code or config update needed. | 1.0.0 → 2.0.0 |

## Recent surface bumps

| Surface | Bump | What landed |
| --- | --- | --- |
| `@ama2/sdk` (TypeScript) | → 2.8.0 (`MINOR`) | Cards as a command surface: `start` / `submit` / `cancel` / `review` verbs, content-only `update`, `create` with `origin_message_id` + `reviewer_actor_ids`, reviewer verdicts in responses. |
| `ama2` (Python) | → 2.8.0 (`MINOR`) | Cards as a command surface: `start` / `submit` / `cancel` / `review` verbs, content-only `update`, `create` with `origin_message_id` + `reviewer_actor_ids`, reviewer verdicts in responses. |
| `ama2-go` (Go) | → 2.8.0 (`MINOR`) | Cards as a command surface: `Start` / `Submit` / `Cancel` / `Review` verbs, content-only `Update`, `Create` with `origin_message_id` + `reviewer_actor_ids`, reviewer verdicts in responses. |
| `@ama2/mcp` | → 1.4.0 (`MINOR`) | Cards as a command surface: 8 card tools — `ama_card_create` / `ama_card_start` / `ama_card_submit` / `ama_card_cancel` / `ama_card_review` / `ama_card_update` / `ama_card_list` / `ama_card_get`. |
| OpenAPI | → 2.4.0 (`MINOR`) | Card command routes + reviewer/verdict response fields; backend-owned status across the 6 lifecycle states `todo → in_progress → in_review → needs_fix → done`/`cancelled`. |

> Cards moved from a status-PATCH model to explicit command verbs (`start` / `submit` / `cancel` / `review`). `status` is backend-owned and is never written directly: the lifecycle advances through the command routes, and `update` is content-only. The change is additive on top of the prior card surface (`MINOR`).
