---
name: scan-work
description: Per-heartbeat proactive work discovery over agent work cards. On each poll beat, beyond checking messages, scan your own and the team's cards for anything you should act on, and act — idempotently. Every member runs this, the Manager included.
---

# Scan for work (each heartbeat)

You don't only react to messages — you also **look for work to do.** On each poll
beat, after handling any pending threads, run this quick scan over agent work
cards (`../TEAM.md` §8a/§9). If nothing is actionable, do nothing — an idle beat
is free. **Never act twice on the same thing**: the card's status is the source
of truth, so read before you act.

## The scan (read-only first)

```bash
ama2 cards list --agent-id me            # your own cards
ama2 cards list                          # the whole account's cards (team-wide)
```

Walk what you find and pick the ONE most useful next action (you can only have
one card `in_progress` at a time):

- **A card of yours is `needs_fix`** → a reviewer asked for changes. Highest
  priority: `ama2 cards start <id>` → make the fixes → `ama2 cards submit <id>
  --expected-review-round <n>` for the next round.
- **You are a reviewer on a card that is `in_review` and you haven't voted this
  round** → review it: `ama2 cards get <id>`, then `ama2 cards review <id>
  --verdict approved|changes_requested [--comment …] --expected-review-round <n>`.
- **A card of yours is `in_progress`** → continue it; when done,
  `ama2 cards submit` (to reviewers) or it auto-`done`s with no reviewers.
- **A card of yours is `todo` and you have nothing `in_progress`** → `ama2 cards
  start <id>` and begin.
- **A `todo`/`in_progress` card has gone stale** (no movement, blocking the team)
  → nudge: ping the relevant member/owner on their thread, or, if it's yours,
  pick it back up.
- **(Manager) team cards show a worker stuck or a review waiting on you** → route
  it (`orchestrate`) or cast your reviewer verdict.

## After acting

- When you **close** a card (`done`/`cancel`, or a card you reviewed reaches
  `done`), run `self-improve` — a quick retro feeds your craft.
- Leave the rest as-is; you'll see them again next beat.

## Guardrails

- **Idempotent.** Status is truth — a `done` card is done; an already-voted round
  is closed. Re-reading every beat is fine; re-acting is not.
- **One active focus.** At most one card `in_progress` per agent (the backend
  enforces it on `start`). Everything else waits.
- **Idle is free.** Nothing actionable → no action, no noise. Don't manufacture
  busywork just because the beat fired.
- **Stay in your lane.** You write only your own cards; you can read the team's
  and reviewers can vote — but you don't edit another member's card.
