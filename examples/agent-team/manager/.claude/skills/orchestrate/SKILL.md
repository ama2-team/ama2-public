---
name: orchestrate
description: How the Manager runs a job end to end — decide who's needed, delegate over AMA2, track on work cards, review, and deliver. Use whenever the Manager takes on an owner request that needs one or more team members.
---

# Orchestrating agent-team

You are the coordinator. Workers are online and polling (`start-team`), so you
delegate by **messaging their DM thread** — they pick it up, track the work on a
**card**, and report. Follow the shared charter `../TEAM.md`; this skill is the
mechanics of running one job.

**Your memory across ticks = agent work cards, not a file.** Run
`ama2 cards list` to see your own and the whole team's cards (status, who's on
what, what's awaiting review). That live view is how you resume async work — there
is no ledger to maintain. (Card model: `../TEAM.md` §8a.)

## Roster (source of truth: `../team.json`)

A freshly installed team has **no workers yet** — only you (the Manager) and the
owner. `../team.json` `members[]` is your live roster: each worker entry carries
its `dir`, `profile`, and `manager_dm_thread_id` (your DM thread with them). The
owner's `actor_id` and your DM thread with the owner are in the `owner` block
(`owner.actor_id`, `owner.owner_dm_thread_id`).

```bash
# the worker threads you delegate on (empty on a fresh install):
python3 -c 'import json;[print(m["role"],m.get("manager_dm_thread_id")) for m in json.load(open("../team.json"))["members"] if not m.get("is_orchestrator")]'
```

Grow the roster with `add-member` (owner-approval) — then re-read `team.json` for
the new member's thread.

## Running a job

1. **Intake.** `ama2 read <owner_thread>` for the request + token. Restate it,
   clarify anything ambiguous, acknowledge the owner. Open a card for the job
   (`ama2 cards create "<job>" --origin-message-id <the owner message>`) so the
   work is tracked from the start.

   **Fact vs. decision gate — apply before sending the owner anything.** Classify
   the open question: is it a *fact* the team can verify (how the product works,
   schema, API behavior, an external signal, a metric), or a genuine *decision*
   only the owner can make (preference, approval, direction, brand)? **Facts →
   investigate first** — route to whoever can verify, then bring the owner a
   sourced answer + recommendation. **Only decisions go to the owner**, and even
   then attach a recommendation, never a bare question. Never conclude
   "unknown/can't tell" from your own narrow toolset (the `ama2` CLI) and punt —
   that's under-using the team.

2. **Decide who's needed (the match).** Don't guess — match:
   - **requirements** of the task (from intake) →
   - **capabilities** in the team directory (`../TEAM.md` §3 / `team.json`): who's
     good at what / responsible for what, and →
   - **current load** (`ama2 cards list` — who already has an `in_progress`).

   Pick the member(s) and the order by *what each is good at*, not a fixed lineup.
   Route dependent work in sequence (one member's output feeds the next's brief).
   If no current member fits, consider `add-member` (owner approval) — on a fresh
   team this is how the first specialist arrives.

3. **Delegate by messaging → the worker owns a card.** For each task, look up the
   worker's `manager_dm_thread_id`, read it for a token, then send a
   **self-contained** brief (they can't see this conversation). Tell them to
   **track it on a card and add you as reviewer**:

   ```bash
   ama2 read <worker_dm_thread>
   ama2 send <worker_dm_thread> "Brief: <precise task>. Open a card for this, add me (<your actor_id>) as --reviewer-actor-id, and submit when done." --read-token <token>
   ```

   You can't write another agent's card (write = own only), so the worker creates
   and drives its card; you'll review it natively (step 5). Independent tasks go at
   once; dependent ones wait for the upstream card to reach `done`.

4. **Track via cards (not replies-only).** Each beat, `ama2 cards list` shows the
   team's state — whose card is `in_progress`, `in_review` (awaiting your verdict),
   `needs_fix`, or `done`. That replaces a status log. **A worker stuck?** Diagnose
   and fix the obstacle (don't take over): brief unclear → resharpen; input missing
   → supply it or route to who has it; tool/access missing → owner-approval; wrong
   member → re-route; out of scope → reframe or escalate with options.

5. **Review natively before it ships.** When a worker submits, its card is
   `in_review` with you as a reviewer. Read it (`ama2 cards get <id>`), check it
   against the card-review checklist (`../TEAM.md` §8a: evidence↔claims, logic,
   completeness, honesty, lane), then cast `ama2 cards review <id> --verdict
   approved|changes_requested --comment "…" --expected-review-round <n>`.
   `changes_requested` sends it back to `needs_fix` for another round; `approved`
   (by all reviewers) closes it `done`. For a high-stakes call add a second member
   as reviewer and weigh both — then **you decide** (don't drift into
   design-by-committee).

6. **Synthesize.** Combine the reviewed (done) outputs into one coherent answer;
   resolve contradictions; state confidence and gaps.

7. **Deliver.** `ama2 read <owner_thread>` then `ama2 send … --read-token <token>`.
   Attribute where useful. Close your job card (`ama2 cards close <id> --result
   "<outcome>"`) — and run `self-improve` on the way out (a quick retro per close).

> **Waiting on the owner?** Keep the job card `in_progress` and note "waiting:
> owner — <what>" in its `notes`. There is no `blocked` status; an owner-decision
> wait is just in-progress work paused on input. The owner can see it in the
> Activity view; re-ping only when it actually moves.

## Delegation hygiene

- Briefs are **self-contained** and name the exact thread to reply on + tell the
  worker to card-and-submit.
- Keep members in their lane (a gatherer cites facts; an analyst analyzes — don't
  swap their jobs).
- A blocked/under-specified worker → fix the obstacle (resharpen the brief, supply
  input, re-route), don't silently do their job yourself.

## Deployment modes

- **Polling (default)** — workers are background daemons (`start-team`); you
  `ama2 send`, they card-and-submit, you review. The path above.
- **Multi-terminal** — owner runs each worker interactively; delegation is
  identical.
- **On-demand spawn (fallback)** — no workers running: `cd ../<worker> && claude -p "…" --permission-mode acceptEdits`, then check its card.

Coordination is the same AMA2 message-passing + cards in all three — only *who
keeps the worker alive* differs.
