---
name: add-member
description: Add a new member to agent-team when a needed skill is missing. Requires owner approval. Use when a task needs an expertise no current member has. Reuses a fitting existing agent if one exists, else creates one, then onboards it.
---

# Add a team member (runtime onboarding)

When the work needs a skill nobody on the team has, grow the team. **This is an
owner-approval action** (see `../TEAM.md` §7 and the Manager guide §6) — never
create or add an agent on your own.

## Step 0 — Propose to the owner (REQUIRED, wait for approval)

In the owner room, propose:

- the **role** and **why** it's needed (which task is blocked without it),
- what it will be responsible for and what it's good at,
- whether you'll **reuse** an existing agent or **create** a new one.

**If a craft seed fits this role** — check `../templates/craft-seeds/` for a
matching playbook (the library has roles like data, marketing, design,
engineering, customer-support, product-management, sales, finance, legal, hr,
operations, …) — **offer the owner the choice**:

- **(A) Use the `<role>` preset** — start from the ready-made playbook: the member
  is **competent immediately** with proven skills, then tunes them to us.
- **(B) Build from scratch** — fully custom to our team from day one, but the
  member starts with **no craft** and **takes time** to become reliably useful.

(No matching seed → it's (B) by default; say so.) Do nothing further until the
owner approves the role **and** picks A or B. If declined, re-plan with the
current team.

## Step 1 — Reuse or create the agent

Prefer reusing a fitting agent already on the account before creating a new one:

```bash
ama2 agents list          # is there an unused agent that fits (e.g. "Coder")?
```

- **Reuse:** note its `actor_id`.
- **Create:** `ama2 agents create --name "<Display Name>" --description "<role>"`
  → note the returned `agent_id` (= actor_id).

## Step 2 — Connect the agent actor

```bash
ama2 agents connect <agent_actor_id>
```

## Step 3 — Create the member's directory

Make `../<member-dir>/` a sibling of the other members, mirroring their layout:

- `../<member-dir>/.claude/settings.json`:
  ```json
  {
    "env": { "AMA2_AGENT_ACTOR_ID": "<agent_actor_id>" },
    "permissions": { "allow": ["Bash(ama2:*)"] }
  }
  ```
  (add `"WebSearch","WebFetch"` or other tools the role needs.)
- `../<member-dir>/CLAUDE.md`: identity block (`agent_actor_id`), one-line role +
  **mandate** (what it's responsible for, its boundaries), **"Follow the shared
  charter `../TEAM.md`"**, the standard "Working as part of the team" section
  (assignments on your DM thread; track work on cards; flag blockers;
  peer-collaboration norm; reporting recipe), and a **"on your first run, invoke
  `self-onboard`"** line. Copy an existing member's CLAUDE.md as the template and
  adapt the mandate.
- **Plant the common base skills:** copy `self-onboard`, `self-improve`, and
  `scan-work` from `../templates/common-skills/` into
  `../<member-dir>/.claude/skills/`. Every member (you included) carries this base.
- **Plant a craft seed — only if the owner chose (A) in Step 0:** copy
  `../templates/craft-seeds/<role>/skills/` into `../<member-dir>/.claude/skills/` as
  the member's **starting craft**, and copy its `.mcp.json`/`CONNECTORS.md`
  alongside as editable connector examples. The member joins already experienced
  and _fits_ the seed to its mandate via `self-onboard`. If the owner chose **(B)
  from scratch** (or no seed exists), plant **nothing** here — the member authors
  its craft from scratch in `self-onboard`. You set the _mandate_; the member owns
  and tunes its _craft_.

## Step 4 — Open the manager↔member DM thread

```bash
AMA2_AGENT_ACTOR_ID=<manager_agent_actor_id> ama2 threads create <agent_actor_id> --format json   # note thread_id
```

## Step 5 — Register in team.json

Add a member entry (this makes it part of the roster + auto-join on start-team):

```json
{
  "role": "<role>",
  "dir": "<member-dir>",
  "display_name": "<Display Name>",
  "actor_id": "<agent_actor_id>",
  "manager_dm_thread_id": "<thread_id>"
}
```

## Step 5b — Team Room (group thread)

The Team Room is the shared room for all agents (`../TEAM.md` §4). **`ama2 threads
create` makes a DM with one other actor and a _group_ only with two or more.** A
DM is immutable — you cannot `threads invite` into it later. So create the Team
Room only once you have **≥2 workers to put in it together**; never record a
1-participant DM as the Team Room.

- **No Team Room yet AND this is the _second_ worker** (so two workers now exist):
  create the group with **both** workers in one call, then record it:
  ```bash
  AMA2_AGENT_ACTOR_ID=<manager_agent_actor_id> ama2 threads create <worker1_actor_id> <worker2_actor_id> --title "Team Room" --format json
  ```
  Write the returned `thread_id` to `team.json` as `team_room_thread_id`.
- **Team Room already exists:** invite the new worker in:
  ```bash
  AMA2_AGENT_ACTOR_ID=<manager_agent_actor_id> ama2 threads invite <team_room_thread_id> <new_actor_id>
  ```
- **This is the _first_ worker (only one worker total):** **don't create a room
  yet** — leave `team_room_thread_id` empty. You and that worker use your DM until
  a second worker arrives.

## Step 6 — Bring it online

```bash
../scripts/start-team.sh           # idempotent: starts only members not already running
```

It now polls and joins the team. (First headless run may need a one-time trust on
the new dir — if it doesn't wake, open `cd ../<member-dir> && claude` once, accept
trust, exit.)

## Step 7 — Member self-onboards (fit craft + propose tools)

On its first run the new member invokes `self-onboard`: it reads its mandate +
`../TEAM.md`, **fits its planted craft seed to its mandate** (or writes one from
scratch if no seed was planted), and **proposes the tools/connectors** it needs on
its DM thread. Route any tool/permission requests to the **owner for approval**
before applying them to the member's `settings.json`. (Mandate = yours; craft =
theirs; tools = gated.)

## Step 8 — Announce & record

- Introduce the new member to the owner: name, strengths, responsibilities, how to
  reach.
- The new member is now available for the `orchestrate` match (visible to the team
  via `ama2 cards list` once it starts tracking work).

## Variant: coding agent (external workspace)

A coding agent is different from the other members: its **identity** lives in the
team, but its **work** happens inside an actual **project repo** that is managed
**separately** from `agent-team/` (that repo already has its own `CLAUDE.md`,
skills, and hard gates). So you split identity from workspace:

- **Identity dir stays in the team:** `agent-team/<member-dir>/` holds only its
  mandate, reporting thread, the common base skills (`self-onboard`/`self-improve`/
  `scan-work`), and settings — same as any member. The session does **not** run
  here (a coding agent typically gets its craft from the project repo, not a seed).
- **Workspace is the project repo, recorded in `team.json`:** add a
  **`workspace_dir`** field (absolute path to the repo) to the member's entry:
  ```json
  {
    "role": "coder",
    "dir": "coder",
    "workspace_dir": "/abs/path/to/project/repo",
    "display_name": "Coder",
    "actor_id": "<agent_actor_id>",
    "manager_dm_thread_id": "<thread_id>"
  }
  ```
  `start-team.sh` reads `workspace_dir` and `poll-loop.sh` runs the member's
  session **inside that repo**, so the project's own `CLAUDE.md`/skills/gates load
  automatically.
- **Identity carried by always-prefixing the actor UUID:** because the repo's
  ambient AMA2 runtime selector may differ, the member's `CLAUDE.md` must
  instruct it to prefix **every** AMA2 call with
  `AMA2_AGENT_ACTOR_ID=<agent_actor_id> ama2 …`.
- **The project dir is the owner's to designate** — you do **not** create it as
  part of onboarding. Confirm the path with the owner. Per multi-agent safety,
  a coding agent should work in its **own git worktree / branch** so it never
  steps on the owner's or another session's work; **creating worktrees / switching
  branches needs the owner's explicit request** (and follows the repo's own
  rules). The agent itself follows that repo's gates and never commits/pushes
  unless explicitly asked.

So for a coding agent: steps 1-2 and 4-8 are the same; in **step 3** the identity
dir's `CLAUDE.md` points at the workspace and the always-prefix rule, and in
**step 5** you add `workspace_dir`. The "where does it work" answer lives in one
place: `team.json` → `workspace_dir`.

> Removing/disabling a member or changing its tools/guide is **also**
> owner-approval (§7). To stand down a member: stop its loop, optionally
> `AMA2_AGENT_ACTOR_ID=<agent_actor_id> ama2 agents disconnect` and remove it
> from `team.json`.
