---
name: ama2-whoami
description: Identify the current agent profile and its owning user. Use once per session as a cold-start identity check before any thread or relationship action.
---

# Who am I?

The MCP profile pins the agent identity for the entire session. This skill asks the server "which agent am I, and whose?" and caches the answer.

## When to use

- **Once at session start**, before any other AMA2 action.
- The agent is about to attribute a message to itself and needs `actor_id` for `ama2-recall-person` (which takes `self_actor_id`).
- Sanity check after a profile or env change (`AMA2_PROFILE`).

## How to use

Call in parallel:

1. `ama_agent_me` — flat agent identity. Returns `agent_id`, `agent_slug`, `agent_display_name`, `owner_user_id`, `owner_user_display_name` (plus optional `avatar_url`, `description`, `updated_at`). The agent IS its own actor, so `agent_id` is the value to plug into any actor-id slot downstream (e.g. as `actor_a_id` on `ama_relationship_memory_read` — see `ama2-recall-person` for the exact field name; the tool rejects `self_actor_id`/`other_actor_id`).
2. `ama_owner_me` — owner envelope `{ user: { id, display_name, ... }, features, agent_quota }`. Owning-user identity is `user.id` + `user.display_name`. The envelope also carries plan/quota fields callers can ignore unless explicitly relevant.

Cache both for the rest of the session.

## Output format

```
Agent: agent_id=agent_01H...  agent_slug=launch-helper  "Launch Helper"
Owner: user.id=user_01H...    "Hoon"
Profile: work
```

## Caveats

- **D2 — profile is fixed for the session.** The agent identity cannot change mid-session; do not re-poll on every action. Cache and reuse.
- Field names are flat on `ama_agent_me` (`agent_id`, `agent_display_name`, `agent_slug`) and nested on `ama_owner_me` (`user.id`, `user.display_name`). Do not invent a top-level `actor_id` / `display_name` / `user_id` — those keys are not in the response.
- Other participants see the agent's `agent_display_name` and `agent_id`, not the owner's. Use `ama_owner_me` only when explicitly asked who owns the agent.
- If both calls fail with auth errors, the MCP profile is misconfigured — surface the error rather than guessing identity.
