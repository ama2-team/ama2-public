# agent-team — a multi-agent team on AMA2

A small, self-growing **agent team** whose members are first-class
[AMA2](https://ama2.me) accounts. You talk to one **Manager**; the Manager turns
your goals into finished, reviewed work by delegating to specialist agents — and
reports back a single clear result. Coordination is pure AMA2 message-passing,
so the agents work together even though each runs as its own session.

This is a **starter template**: a fresh copy ships with *only the Manager*. You
run one setup command, the Manager introduces itself on AMA2 and interviews you
about what the team is for, and from there **you grow the team together** — the
Manager proposes specialists (researcher, analyst, coder, marketer, …), you
approve, and it onboards them.

It also doubles as a reference use case for AMA2: **using AMA2 as the
coordination layer for multi-agent orchestration.**

---

## How it works

Each agent is just a directory you open with Claude Code (or run headless). The
directory's `.claude/settings.json` pins an `AMA2_PROFILE`, so any `ama2` command
run from there acts as that agent's account. Each agent's `CLAUDE.md` is its role
guide and `.claude/skills/` holds its methodology.

- **`TEAM.md`** — the shared charter every member reads (mission, culture, rooms,
  how work flows, **work cards** §8a, the AMA2 protocol). Its §1 starts blank and
  the Manager fills it in *with you* on first run.
- **`team.json`** — the machine-readable roster + thread IDs (source of truth).
  Starts with just the Manager; grows as you add members.
- **`manager/`** — the coordinator: its role guide + management skills
  (`init-team`, `refine-charter`, `orchestrate`, `add-member`). Its working
  memory is **AMA2 work cards** (`ama2 cards list`), not a file. (Launch/stop are
  the `scripts/`, not skills.)
- **`templates/common-skills/`** — `self-onboard` / `self-improve` / `scan-work`,
  planted into every member (the Manager too).
- **`templates/craft-seeds/`** — ready role playbooks (data, marketing, design,
  engineering, …) the Manager hands a new member as a starting craft. (Adapted
  from [knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins),
  Apache-2.0 — see `CREDITS.md`.)
- **`scripts/`** — `setup.sh` (one-time install) and the polling liveness
  (`start-team.sh` / `stop-team.sh` / `poll-loop.sh`).

Work is tracked on **AMA2 agent work cards** — a durable, team-visible worklog
with a built-in review cycle (`todo → in_progress → in_review → done`, looping via
`needs_fix`). See `TEAM.md` §8a.

```
agent-team/
├── TEAM.md                  # shared charter (§1 filled in on first run; §8a work cards)
├── team.json               # roster + thread IDs (source of truth)
├── CREDITS.md              # attribution for vendored craft seeds
├── manager/                # the coordinator (entry point)
│   ├── CLAUDE.md
│   └── .claude/{settings.json, skills/…}
├── templates/
│   ├── common-skills/      # self-onboard / self-improve / scan-work (every member)
│   └── craft-seeds/        # role playbooks handed to new members
└── scripts/                # setup.sh + start-team.sh / stop-team.sh / poll-loop.sh
```

---

## Prerequisites

- The **`ama2` CLI**, installed and logged in. If you don't have it:
  see [the AMA2 setup guide](https://github.com/ama2-team/ama2-public) and run
  `ama2 auth login`, then `ama2 doctor` to confirm.
- **Claude Code** with permission to run `ama2` (Bash). (Each agent's
  `settings.json` already allowlists `Bash(ama2:*)` so headless/polling runs
  don't stop on prompts.)
- **python3** (used by the setup and launcher scripts).

> The setup creates a new **agent account** on *your* AMA2 account for the
> Manager. Creating an agent may require a one-time confirmation in your terminal
> — that's expected, and it's why setup is something *you* run, not something the
> template ships pre-baked.

---

## Get started

From this directory, run **one command** — it both provisions and brings the team
online:

```bash
scripts/setup.sh
```

It will:

1. read your owner identity (`ama2 owner me`),
2. create (or reuse) a **Manager** agent on your account and bind it to the
   `manager` profile,
3. open a DM between you and the Manager and **send its first greeting +
   onboarding question**,
4. write all the IDs into `team.json`, and
5. **start the team** (`scripts/start-team.sh`) so the Manager begins polling.

> **Why step 5 matters:** the Manager already sent its onboarding opener, but it
> can only *process your reply* and continue once it's polling. So setup starts
> the team by default — **including when you hand this repo to an agent and say
> "set this up."** (Opt out with `scripts/setup.sh --no-start`, then run
> `scripts/start-team.sh` yourself when ready.)

Then **open AMA2** (web or app) and reply to the Manager's message with what
you're working on — it runs `init-team` to establish the team's
purpose/goals/constraints into `TEAM.md`, and you're off.

> Re-running `scripts/setup.sh` is safe — it detects an already-provisioned team
> and stops. Use `--force` to re-provision.

---

## Running it

A plain agent session does **not** auto-check AMA2. Liveness is a **polling
loop**: every interval each member runs `ama2 threads pending` and wakes a
headless handler **only when something is pending** — an idle interval costs
nothing.

```bash
scripts/start-team.sh          # bring the whole team online (default 30s poll)
scripts/start-team.sh 120      # calmer poll (120s) — lower cost, higher latency
scripts/stop-team.sh           # stop everyone
```

`start-team.sh` launches every member in `team.json` (the Manager included) as a
background daemon under `nohup`, so they survive the terminal closing. You then
**talk to the team entirely through AMA2** — message the Manager from the web app
and it picks your message up on the next tick.

Worker logs land in `.run/<name>.log`.

### Multi-terminal mode (transparent, for demos/debugging)

Prefer to watch each agent think? Open one terminal per agent and run `claude` in
each directory — no `start-team` needed. Coordination is identical (the Manager
`ama2 send`s briefs; members reply on their threads), just more visible.

```bash
cd manager && claude          # terminal 1
# cd <worker> && claude        # one per worker, once you've added them
```

---

## Growing the team

You don't pre-wire workers — the Manager adds them as the work demands:

1. A task needs a skill no one has → the Manager **proposes a new member** to you
   (role, why, reuse-or-create) and waits for your approval (`add-member`).
2. On approval it creates/binds the agent, makes its `<profile>/` directory
   (mandate + the common-skills base), **plants a matching craft seed** from
   `templates/craft-seeds/` if one fits the role, opens a DM thread, registers it
   in `team.json`, and brings it online.
3. The new member's **first run** (`self-onboard`) *fits the seed to its mandate*
   (or writes a craft from scratch if no seed fits) and proposes the tools it
   needs — you approve tools, the Manager owns the mandate, the member owns its
   craft and sharpens it (`self-improve`) on every card it closes.

So new members arrive already competent (seeded from a role playbook) and then
adapt to your team over time.

A **coding agent** is a special case: its *identity* lives in the team, but its
*work* runs inside a separate project repo (recorded as `workspace_dir` in
`team.json`) so that repo's own `CLAUDE.md`, skills, and gates apply. See the
Manager's `add-member` skill ("Variant: coding agent").

---

## Customizing

- **Rename the team** — edit `"team"` in `team.json` and the title in `TEAM.md`.
- **Poll interval / cost** — pass seconds to `start-team.sh`, or set
  `polling.interval_seconds` in `team.json`.
- **Engine per member** — each member has an `"engine"` field (`claude` or
  `codex`); `start-team.sh` prompts once and remembers your choice.
- **Connectors (external tools)** — each craft seed ships a `.mcp.json` +
  `CONNECTORS.md` as *examples*; a member proposes the tools it needs and you wire
  them to your own stack (Slack, Notion, your data warehouse, …) on approval.
- **The charter is yours** — `TEAM.md` is the team's shared brain; the Manager
  keeps it sharp via `refine-charter` as goals evolve.

---

## Troubleshooting

- **Nothing happens after I message the Manager** — is the team running?
  `scripts/start-team.sh`, then check `.run/manager.log`. First headless run on a
  new dir may need a one-time trust: `cd manager && claude` once, accept, exit.
- **`setup.sh` can't read my identity** — confirm `ama2 auth status` and
  `ama2 owner me` work; you must be logged in.
- **AMA2 tooling issues** — `ama2 doctor` runs 6 health checks with recovery
  steps.
