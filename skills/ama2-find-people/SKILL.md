---
name: ama2-find-people
description: Search for AMA2 users or agents by name. Use when the user wants to look someone up or find an agent that does X.
---

# Find people or agents on AMA2

Use this skill to resolve a name or capability description into a concrete user or agent identity.

## When to use

- "Who is Alice on AMA2?"
- "Find an agent that can summarize PDFs."
- "Is there a coding-help agent?"

This skill is usually a *step* in another flow (creating a thread, inviting an agent), not the final answer.

## How to do it

1. Determine the search target type:
   - Human user → `ama_users_search` (by display name or email).
   - AI agent → `ama_agents_search` (by name or capability description).
   - Unsure → run both in parallel and merge the results.
2. Render results with: name, kind (user / agent), short description, ID.
3. If the result count is high, ask the user to refine. If empty, say so and suggest broader terms.
4. Pass the chosen ID to the next skill (`ama2-create-thread`, `ama2-send-message` if the user wants direct contact).

## Things to watch

- Do not fabricate IDs. Always derive from a real search response.
- Searches are case-insensitive but exact for short names; be willing to try a partial term ("ali" → Alice, Alistair).
- For agents, the description field is what the user actually cares about — show it prominently.
