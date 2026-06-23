---
name: self-onboard
description: One-time — set up your own expertise. On your first run as a new team member, adapt your starting craft skill to your mandate (or write one if you have no seed) and propose the tools you need. Skip if you're already set up.
---

# Set up your own expertise (run once)

You've just joined agent-team. The Manager gave you your **mandate** — your role,
responsibilities, and boundaries — in your `CLAUDE.md`, and the shared norms are
in `../TEAM.md`. Your job now is to set up **how you do your expert work**: the
Manager owns *what* you're responsible for; **you own your craft.**

You're not starting from blank. The Manager usually plants a **craft seed** in
your `.claude/skills/` — a ready, comprehensive methodology for your kind of role
(adapted from a library of role playbooks). Think of it as joining already
experienced; your job here is to **fit that experience to *this* team and *your*
mandate**, then keep sharpening it over time with `self-improve`.

## First, check if you even need this

If you already have a craft/methodology skill (any skill in `.claude/skills/`
other than `self-onboard`/`self-improve`/`scan-work`) **that you've already fitted
to your mandate**, you're set up — **don't redo it.** Run `self-improve` instead.
A freshly-planted seed that you haven't fitted yet → continue below.

## Steps

1. **Understand your mandate.** Read your `CLAUDE.md` (role, mission, boundaries)
   and `../TEAM.md` (culture, where you fit, how the team works). Be clear on
   what you're responsible for — you will *not* redefine that here.
2. **Fit your craft skill to your mandate.**
   - **If a seed was planted** (a craft skill already sits in `.claude/skills/`):
     read it, then *trim and tune* it to your mandate — cut sections irrelevant
     to what you're actually responsible for, and adjust the rest to this team's
     context (your owner, your product, how this team really works). Keep it
     yours: rewrite in your own words where it helps. Don't keep a generic manual
     you won't use.
   - **If no seed was planted**: write `.claude/skills/<your-craft>/SKILL.md` from
     scratch — a concrete methodology for your role: process, quality bar, output
     format, pitfalls. Specific to your domain, not generic.
3. **Inventory your tools.** Look at what you currently have
   (`.claude/settings.json` `permissions.allow`) and any connectors the seed
   suggests (its `.mcp.json` / `CONNECTORS.md` are *examples to edit to your
   stack*). Identify what your role genuinely **needs that you don't have**.
4. **Propose tools — don't grant them.** Message the Manager on your DM thread:
   the tools/connectors you need and *why*. Tool/permission changes need
   Manager + owner approval (`../TEAM.md` §7); you propose, they apply.
5. **Mark yourself onboarded.** Write a marker so you don't redo this: create the
   file `.claude/.onboarded` (one line: what craft skill you fitted/created).
6. **Report.** Tell the Manager: "Onboarded — fitted craft skill `<x>` to my
   mandate; proposing tools `<y>` (why)."

## Guardrails

- **Craft is yours; mandate and scope are not.** Set *how* you work, not *what
  you're responsible for* — scope changes go to the Manager + owner.
- **Fit, don't hoard.** A tight craft tuned to your mandate beats a giant generic
  one. Cut what you won't use.
- **Propose tools, never self-grant.** Approval gate stays.
- **Be honest.** Set up for what you can actually do; flag what you can't.
- **Run once.** This is onboarding, not a per-task step.
