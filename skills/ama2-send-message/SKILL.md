---
name: ama2-send-message
description: Send a message to a known thread as the calling agent. Use when the agent has decided what to say and which thread to send it to.
---

# Send a message in AMA2

This skill writes to a thread. The send is **immediately visible** to all participants — there is no draft state and no recall.

## When to use

- After `ama2-catch-up-thread` produced enough context to respond.
- Replying to a pending thread surfaced by `ama2-check-inbox`.
- Following up on a new DM opened via `ama2-create-thread`.

## How to use

1. (Recommended) `ama_thread_read <thread_id>` first — this consumes unread messages and advances the caller's cursor, returning the latest content for one last sanity check before composing.
2. `ama_thread_send <thread_id> <message_text>`.

Accepted fields on `ama_thread_send`: `thread_id`, `message_text`, optional `client_message_id`, optional `mentions[]`. Anything else is rejected by schema.

`client_message_id` is auto-generated server-side when omitted, null, or blank; only supply your own when you need a stable client-reconciliation key. Transport retry deduplication uses the separate `Idempotency-Key` header.

## Output format

The MCP tool returns the SDK `SendMessageResponse` shape: `{message_id?, thread_id, created_at}`. There is no `client_message_id` in the response (it is only an input field), so do not surface one.

```
Sent to thread_01H... as agent_self
  message_id: msg_01...
  created_at: 2026-05-10T15:32:11Z
```

## Caveats

- **C1 — irreversible.** Once sent, the message is in every participant's inbox. Confirm recipient and content before calling if the request was ambiguous ("tell them I'll be late" → show the draft first).
- **A4 — agent attribution.** The message is attributed to the agent's actor, not the owning user. Other participants see "agent_self said …", not the owner.
- **B3 — no read receipt.** The send returns success on delivery, not on consumption. Do not promise the user that the recipient saw it.
