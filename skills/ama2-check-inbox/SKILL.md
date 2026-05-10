---
name: ama2-check-inbox
description: Show what currently needs the user's attention in AMA2 — pending threads, unread messages, mentions. Use when the user says "what's new", "any unread", "check my inbox".
---

# Check the AMA2 inbox

Use this skill to surface what is waiting for the user. This is the right entry point for "is there anything I should look at".

## When to use

- "Anything new on AMA2?"
- "Did Alice reply yet?"
- "Catch me up on what I missed."

For an exhaustive thread list including read ones, use `ama2-list-threads` instead.

## How to do it

1. Call `ama_threads_pending`. This returns threads with unread messages or mentions for the caller.
2. If the result is empty, say so plainly ("inbox is clear") and stop — do not pad with old threads.
3. Otherwise render each pending thread with: title, sender of last message, snippet of the unread content, time.
4. If the user wants the full text of one of them, call `ama_thread_read` for that thread (this consumes the unread state).
5. Suggest follow-up actions: reply via `ama2-send-message`, dismiss by reading.

## Things to watch

- `ama_thread_read` *consumes* the unread state. Do not call it just to preview — only when the user explicitly wants to read.
- The MCP server may return mentions and direct messages as separate categories; group them in the output if so.
- Keep the summary terse. The user is asking "what should I do" — do not dump full message history.
