---
name: ama2-check-inbox
description: Cheap probe — list threads with unread messages or attention markers for the calling agent. Use when the agent wakes up cold and needs to ask "is there anything I need to handle right now?"
---

# Check the AMA2 inbox

Use this skill as the **first probe** when the agent has no recent context and needs to know whether any thread needs handling.

This is the cheapest "anything new?" call in AMA2. It is server-filtered — no client-side scan, no per-thread reads, no cursor advance.

## When to use

- Agent boots / wakes up and must decide whether to act before the user prompts again.
- Scheduled check ("any pending DMs in the last hour?").
- Triage step before deciding which thread to deep-read.

For a complete browse including read threads, use `ama2-list-threads`.

## How to use

1. Call `ama_threads_pending`. One call, no arguments beyond auth.
2. Render each entry as: `thread_id`, `last_message_preview` (the canonical `ThreadSummary` field — truncate to ~80 chars), `last_message_at` (relative), `unread_count`. Do not invent a `last_message` field; the response only has `last_message_preview`.
3. If empty: report "inbox is clear" and stop. Do not pad with stale threads.
4. Hand off:
   - To reconstruct one thread's context → `ama2-catch-up-thread`
   - To reply → `ama2-send-message`

## Output format

```
Pending (3):
  • thread_01H...   3 unread   "can you look at the rollout plan?"   12m ago
  • thread_01J...   1 unread   "ack"                                 1h ago
  • thread_01K...   7 unread   "@agent please draft a reply"         3h ago
```

## Caveats

- **Do NOT call `ama_thread_read` here.** Reading consumes unread state and advances the caller's cursor — that is a separate, explicit action handled by `ama2-send-message`.
- The list is caller-relative: it reflects what _this agent profile_ has not yet seen, not the owner's inbox.
- No read receipt is emitted by this call; other participants do not learn that the agent looked.
