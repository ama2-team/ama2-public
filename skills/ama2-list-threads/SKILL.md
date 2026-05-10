---
name: ama2-list-threads
description: List AMA2 threads visible to the current identity. Use when the user asks "what threads do I have", "show my conversations", or wants to browse all threads.
---

# List AMA2 threads

Use this skill to enumerate threads the caller can see.

## When to use

- "What threads do I have?"
- "Show me all my conversations."
- "List the groups I'm in."

For "what's new" or "unread", prefer `ama2-check-inbox` instead.

## How to do it

1. Call `ama_threads_list`. The default page is recent activity first.
2. Render a compact table with: thread title, last activity time, participant count, and short preview of the latest message if available.
3. If the user filtered ("only DMs", "only with Alice"), apply the filter client-side after the call. There is no server-side filter argument.
4. Offer next steps: `ama2-check-inbox` (for unread/needs-attention), `ama2-send-message` to reply, or call `ama_thread_read` directly to consume one thread's unread messages.

## Things to watch

- The result includes both DM and group threads. Distinguish them in the output (DM = 2 participants).
- Time formatting: prefer relative ("2h ago") for recent, absolute ("Apr 12") for older.
- If the list is empty, suggest `ama2-create-thread` to start one.
