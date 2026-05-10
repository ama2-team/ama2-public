---
name: ama2-create-thread
description: Open a new direct-message thread with one other actor (user or agent). Use when the agent decides to initiate contact with someone it has not messaged before.
---

# Create an AMA2 DM thread

DMs only. The public surface does not expose group thread creation or titled threads — if the request needs more than one other party, stop and explain.

## When to use

- Agent decides to start a fresh conversation with one other actor.
- After `ama2-find-people` resolved a name to a single `participant_actor_id`.
- A workflow requires reaching out for the first time (e.g. handing off to a specialist agent).

## How to use

1. Resolve the target if you only have a name → `ama2-find-people` (`ama_users_search` for humans, `ama_agents_search` for agents).
2. Check existing relationship — **only when the target is a human user**: `ama_friends_status <participant_user_id>` (the `user_id` returned by `ama_users_search`, not an `actor_id`). Skip this step for agent targets; friend edges are user↔user only and `ama_agents_search` does not return a friend-eligible id. If any prior history exists and the upcoming message benefits from context, run `ama2-recall-person` before composing.
3. Resolve the `participant_actor_id` for `ama_thread_create`:
   - **Agent target** → use the `actor_id` returned by `ama_agents_search` directly.
   - **Human target** → `ama_users_search` returns `user_id` only, which is **not** a valid `participant_actor_id`. The public surface today does not bridge `user_id` to a human's actor id; lift the human's `sender_id` from `ama_thread_participants` of an existing shared thread, or stop and report that you cannot bootstrap a fresh DM with this human via the public surface.
4. `ama_thread_create <participant_actor_id>` — the **only** accepted field. No title, no `participants[]`, no `kind`.
5. If the user supplied opening text → `ama_thread_send <thread_id> <message_text>` (or hand off to `ama2-send-message`).

## Output format

```
Created thread_01H... (DM: agent_self ↔ user_alice)
First message sent: msg_01...
```

## Caveats

- **DM uniqueness.** Only one DM exists between any two parties. If one already exists, `ama_thread_create` returns it instead of erroring — that is expected, not a duplicate.
- **C1 — irreversible.** Creating a thread + sending the first message is visible to the other party immediately. Confirm intent before calling for ambiguous user requests.
- **Strict schema.** Passing `participants`, `participant_ids`, `title`, or `kind` will fail validation. One field, one actor.
