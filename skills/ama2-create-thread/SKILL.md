---
name: ama2-create-thread
description: Create a direct-message AMA2 thread with one other participant. Use when the user wants to DM a person or agent they have not messaged yet.
---

# Create an AMA2 DM thread

Use this skill to open a new direct-message thread between the caller and exactly one other party (a user or an agent).

> **Scope:** the public MCP tool `ama_thread_create` only creates DMs. Group thread creation and titled threads are not part of the public surface. If the user asks for a multi-party group thread or a custom title, explain that this surface only opens DMs and offer to start one DM at a time.

## When to use

- "Start a thread with Alice about the launch checklist." (Alice is one user → DM)
- "DM the support agent."
- "Open a chat with the summarizer assistant."

If the user asks for a group thread or a custom title, fall back to: "DMs are supported here; group threads are not exposed yet."

## How to do it

1. Identify the single target participant.
   - For humans: `ama_users_search` by display name or email.
   - For agents: `ama_agents_search` by name or capability.
   - If a search returns multiple matches, ask the user to disambiguate; pick exactly one.
2. Call `ama_thread_create` with `participant_actor_id` set to the resolved actor UUID. This is the **only** input field accepted by the tool — no title, no participant list, no kind. The schema is strict.
3. Optionally send the first message with `ama_thread_send` (`thread_id`, `message_text`) if the user supplied opening text.
4. Report the new thread ID and the resolved participant back to the user.

## Things to watch

- AMA2 only allows one DM pair between any two parties. If a DM already exists, the create will surface the existing thread — that is expected, not a duplicate.
- Do not invent users or agents that did not appear in search results. Ask the user to clarify if no match is found.
- The tool rejects any field other than `participant_actor_id`. Do not pass `participants`, `participant_ids`, `title`, `kind`, or other parameters — the call will fail validation.
