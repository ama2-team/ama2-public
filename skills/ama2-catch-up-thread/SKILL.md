---
name: ama2-catch-up-thread
description: Reconstruct what happened in a single thread — metadata, daily summaries, and recent messages — without consuming unread state. Use before replying when the agent has no in-context memory of the thread.
---

# Catch up on an AMA2 thread

The agent does not remember threads across sessions. Before replying or acting on a thread, run this skill to rebuild enough context to respond coherently.

This skill is **non-consuming**: the caller's read cursor does not advance. Run it as many times as needed.

## When to use

- After `ama2-check-inbox` flagged a thread and the agent is about to draft a reply.
- The user (or another agent) referenced a thread by id and the agent has no memory of it.
- Returning to a thread after a long pause — daily summaries fill the gap that would otherwise blow the context window.

## How to use

Call in this order:

1. `ama_thread_info <thread_id>` — pulls metadata plus the caller-relative fields:
   - `unread_message_count`
   - `needs_attention`
   - `last_read_thread_seq` (the agent's own cursor)
2. `ama_thread_memory_read <thread_id>` — daily summaries of the thread, compressed by date.
3. `ama_thread_history <thread_id> --limit N` where `N = clamp(unread_message_count + 5, 20, 50)` (use the `unread_message_count` field from step 1; that is the canonical name on `ThreadDetailResponse`).

Render the result as: header (participants, kind, unread/needs_attention) → per-day summaries (oldest → newest) → recent messages, marking each unread message with `★` (any message whose `thread_seq > last_read_thread_seq`).

## Output format

```
Thread thread_01H... (DM with user_alice) — 3 unread, needs_attention=true
Summaries:
  2026-05-08  agreed on launch checklist; alice owns copy review
  2026-05-09  build went green; alice asked for rollout plan
Recent:
    [seq 142] alice  09:14  build is green
    [seq 143] alice  09:20  can you draft a rollout plan?
  ★ [seq 144] alice  10:01  also pulling in @bob
  ★ [seq 145] bob    10:03  here, what's the timeline?
  ★ [seq 146] alice  10:05  @agent any thoughts?
```

## Caveats

- **Non-consuming.** The cursor only advances via `ama_thread_read` (see `ama2-send-message`).
- Thread summaries are coarse (per-day). For sender-to-sender history across all shared threads, use `ama2-recall-person` instead.
- Cap N at 50 to protect the context window; rely on summaries for older history.
