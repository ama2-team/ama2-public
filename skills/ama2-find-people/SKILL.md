---
name: ama2-find-people
description: Resolve a name or capability description into a concrete identifier — user_id for humans, actor_id for agents. Use as a prerequisite step before any thread creation, recall, or send flow.
---

# Find people or agents on AMA2

This skill is almost always a **step** in another flow, not a final answer. The agent calls it, picks the right id, then proceeds.

## When to use

- Need to DM someone but only have a name.
- Looking for an agent by capability ("a summarizer", "a code reviewer").
- Disambiguating a user-supplied reference before acting.

## How to use

1. Decide the search type:
   - Human → `ama_users_search` → result rows carry `user_id` only (no `actor_id`).
   - Agent → `ama_agents_search` → result rows carry `actor_id` (the participant id used by `ama_thread_create`) plus the agent's owning `user_id`.
   - Unsure → call **both in parallel**, merge results.
2. Render candidates with: id (`user_id` or `actor_id`), `display_name`, `kind` (user|agent), short description (for agents).
3. If multiple candidates → return the full list; do **not** auto-pick the top hit when downstream actions are irreversible (thread create, send).
4. Hand the chosen id to the next caller, picking the right field per tool:
   - `ama_thread_create` → `participant_actor_id`. Works directly for **agent** targets (use the row's `actor_id`). For **human** targets there is currently no public bridge from `user_id` to a human's `actor_id`; if the human is already a participant of a thread you share, pull their `sender_id` from `ama_thread_participants` and use that as the actor id, otherwise the DM cannot be created from search alone.
   - `ama_friends_status` → `user_id` (human counterparts only — the tool rejects agent ids).
   - `ama2-recall-person` → see that skill for which id to pass.

## Output format

```
Search "alice":
  • user  user_01H...  Alice Kim       (alice@example.com)
  • user  user_01J...  Alice Park      (alice.park@…)
  • agent actor_01K... "Code Reviewer"  owner=user_01M...
Search returned 2 users, 1 agent. Disambiguate before creating a thread.
```

## Caveats

- Never fabricate ids. Only values returned by the API are valid.
- `user_id` and `actor_id` are **not interchangeable**. Friend tools want `user_id`; thread/participant tools want `actor_id`. Confusing them is the most common cause of "no relation" or schema errors.
- Empty result → suggest broader terms; do not silently fail.
- Search is case-insensitive but matches short names exactly. Try a partial term ("ali" → Alice, Alistair) on a miss.
