---
name: init-team
description: One-time — establish the team's founding context WITH the owner (north star, owner profile, business/product context, current goals, constraints) and write it into the shared charter. Run once at startup. Skip if already set.
---

# Initialize the team's founding context (run once, with the owner)

You own the team charter, so you set up its founding context — but this context
is **about the owner and their business, so it comes FROM the owner.** You don't
invent it; you **interview the owner**, draft, confirm, and write it down. This
fills TEAM.md §1.

## First, check if it's already set

If `../.team-initialized` exists (or TEAM.md §1 no longer shows "_Not yet set_"),
the team is initialized — **don't redo it.** Use `refine-charter` instead. Only
continue if §1 still has the placeholders.

## What you're establishing (TEAM.md §1)

1. **North star (purpose)** — what this team exists to achieve.
2. **Who we serve (owner profile)** — the owner's role, what they care about most,
   communication preferences (cadence, format, language), decision style.
3. **What we're working on (business/product)** — what we're serving, its stage,
   target users, market position, current strategic priorities.
4. **Current goals & priorities** — the concrete objectives the team drives now.
5. **Constraints & quality bar** — cost sense, off-limits, security, definition of
   "done".

## Steps

1. **See the team's shape first.** Read `../TEAM.md`, `../team.json` (roster), and
   the available role playbooks in `../templates/craft-seeds/` — so your drafts and
   roster suggestions are grounded, not generic.
2. **Greet + interview the owner** in the owner room. This is usually your **first
   message ever** to the owner, so open with a short hello *and* the onboarding
   questions in **one** message — greeting and onboarding are one continuous
   conversation, not two steps. Ask for the five items above (one well-structured
   message). Draft a sensible starting proposal where you can, but present it as a
   draft to confirm. **Never fabricate owner/business facts.** On the owner's
   reply, **continue** the interview — don't re-greet.
3. **Confirm.** Make sure the owner has signed off on at least the **north star,
   goals, and constraints** (the steering parts). Owner profile/business context
   you capture from what they tell you.
4. **Write it into TEAM.md §1** — fill each subsection, replacing its placeholder.
   Keep each tight (a few lines); this is a charter, not a dossier.
5. **Mark initialized.** Write `../.team-initialized` (one line: date + the north
   star).
6. **Propose the starting roster (from the craft-seeds menu).** Based on the goals,
   suggest the first specialists to add and **present `../templates/craft-seeds/`
   as a menu** (data, marketing, design, engineering, customer-support,
   product-management, sales, finance, legal, hr, operations, …). For each role the
   owner wants, ask the **preset-vs-scratch** choice — **(A)** use the ready
   playbook (competent immediately) vs **(B)** build from scratch (custom but
   slower to become useful) — then create each via `add-member` (which carries the
   A/B decision through). Adding agents is owner-approval, so this stays a
   proposal until the owner says go.
7. **Ladder the members up.** As members get added, give each a one-line "ladders
   up to: <part of the purpose>" in its mandate so everyone sees how its role
   serves the goal.
8. **Announce.** Tell every member the founding context is set (Team Room or each
   DM) so the whole team aligns to the same purpose, goals, and constraints.

## Guardrails

- **It comes from the owner.** Purpose, goals, and constraints are owner-confirmed;
  owner/business facts are captured from the owner, never invented.
- **Once.** Startup only. Ongoing changes go through `refine-charter` (current
  goals especially will drift — that's expected).
- **Tight & honest.** A charter the team can steer by, not a wall of text.
