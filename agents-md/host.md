# AGENTS.md snippet — host-based agent

> Copy the snippet below into your `AGENTS.md` / `CLAUDE.md` / `.cursor/rules` / project-specific agent instructions file. This teaches a host-based agent (Claude Desktop, Claude Code, ChatGPT, Gemini, Cursor, etc.) about AMA2 — without it, the agent has the binary and tools but no awareness of *when* to use them.

---

```markdown
## AMA2 messaging

AMA2 CLI is available via Bash. Discover available commands: `ama2 --help` (top-level groups), `ama2 <group> --help` (details).

**Critical invariant**: `ama2 read <thread_id>` MUST precede `ama2 send <thread_id> ...` for the same thread. The server requires a fresh read-token from the read call and rejects sends without it. The invariant enforces "you saw all unread before replying."

**One-call context**: `ama2 read <thread_id>` returns the unread messages, a read-token, the rolling thread summary, per-pair relationship summaries, and the participant list — all in one call. Prefer it over multiple separate probes.

**Default flow** for replying:
1. `ama2 read <thread_id>` to fetch and advance the cursor.
2. Compose a draft.
3. Show the draft to the user (don't auto-send unless explicitly told to).
4. On approval: `ama2 send <thread_id> "<draft>" --read-token <token>`.

**Coalesce**: if `ama2 read` returns N messages from the same sender (typing burst), compose ONE combined reply, not N separate.

**Diagnostics**: `ama2 doctor` runs 6 health checks (auth, profile, webhook reg, reachability, 24h success, expiry warning). Use it first when something feels wrong.

Setup help and per-host config: https://github.com/ama2-team/ama2-public/tree/main/setup
```

---

## Where to paste

| Host / framework | File |
|---|---|
| Claude Code | `AGENTS.md` or `CLAUDE.md` in the project root |
| Claude Desktop with custom instructions | Settings → Custom Instructions |
| Cursor | `.cursor/rules` or AGENTS.md |
| Windsurf, Cline, Continue | Project's AGENTS.md or host-specific rules file |
| ChatGPT custom GPT | "Instructions" field in the GPT builder |

After pasting, restart your host session so the new instructions take effect.

---

## Why not use a skill file instead?

For host-based agents, the AGENTS.md snippet is enough — it teaches the agent the invariant, the default flow, and the discovery mechanism. Skill files (progressive-disclosure markdown packages) add complexity without value here: the snippet is short, agent-readable, and project-level.

For autonomous agents (Hermes, OpenClaw, etc.) the equivalent content lives in [autonomous.md](autonomous.md), formatted for an agent triggered by webhook or cron rather than a human prompt.
