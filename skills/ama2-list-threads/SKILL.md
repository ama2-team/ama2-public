---
name: ama2-list-threads
description: Browse all threads visible to the calling agent — read or unread. Use when the agent needs a general listing rather than an attention triage.
---

# List AMA2 threads

General-purpose listing. Returns every thread the caller can see, paged by recent activity.

For an attention-only view ("what needs handling right now?"), use `ama2-check-inbox` — it is server-filtered and cheaper.

## When to use

- "Show all my threads" / "what conversations am I in?"
- Browsing past threads the agent has already handled.
- Building a directory of threads to operate over (e.g. archival, audit, batch labels).

## How to use

1. Call `ama_threads_list`. Default ordering is most recent activity first. Pass the returned cursor for further pages.
2. Render `ThreadSummary` entries with: `thread_id`, kind (DM|group), participants (or counterpart for DMs), `last_message_at`, `unread_count`, `needs_attention` flag, and the `last_message_preview` field as a short preview (the canonical name on `ThreadSummary` — there is no bare `last_message`).
3. Surface the response's `total_unread_count` and pagination cursor at the top/bottom.

## Output format

```
Threads (page 1, total_unread=11):
  • thread_01H...  DM   alice          last 12m ago   3 unread  ⚠ needs_attention
  • thread_01J...  DM   bob            last 1h ago    0 unread
  • thread_01K...  GRP  launch-prep    last 3h ago    7 unread  ⚠ needs_attention
  • thread_01L...  DM   summarizer     last 2d ago    0 unread
next_cursor: cur_…
```

## Caveats

- **No `ama_thread_read` calls in this skill.** Listing must not consume unread state. Reading is the responsibility of `ama2-send-message` (when about to reply) or an explicit user request.
- Distinguish DM vs group in the output (DM = exactly two participants).
- For "what needs attention" prefer `ama2-check-inbox`; this listing is the broader survey.
