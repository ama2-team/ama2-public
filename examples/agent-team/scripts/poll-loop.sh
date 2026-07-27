#!/usr/bin/env bash
# poll-loop.sh — keep one agent-team member "alive" by polling AMA2 on an interval.
#
# A plain agent session does NOT auto-check AMA2. This loop is the liveness
# mechanism for the local (polling) deployment: every INTERVAL seconds it asks
# AMA2 whether this member has anything to do — an unread thread, OR a work card
# awaiting action (a `needs_fix` to fix, an `in_review` to vote on) — and ONLY
# then wakes a headless handler. Nothing to do => no handler run => no token cost
# (idle-skip). The woken handler both answers messages AND runs `scan-work`.
#
# The handler engine is pluggable: "claude" runs `claude -p`, "codex" runs
# `codex exec`. The AMA2 layer (ama2 CLI calls) is identical either way; only the
# brain + the instructions file it reads differ (CLAUDE.md vs AGENTS.md).
#
# Two member shapes:
#   - normal member: identity dir == workspace. Session runs in the identity dir.
#   - external-workspace member (e.g. a coding agent): session runs INSIDE a
#     separate project repo (workspace_dir) so that repo's own config loads.
#
# Usage: poll-loop.sh <identity_dir> <agent_actor_id> [interval] [workspace_dir] [engine]
set -u

AGENT_DIR="${1:?identity_dir required}"
AGENT_ACTOR_ID="${2:?agent_actor_id required}"
INTERVAL="${3:-30}"
WORKSPACE_DIR="${4:-}"
ENGINE="${5:-claude}"

# The shell that runs `ama2` here is NOT an agent session, so it does not inherit
# AMA2_AGENT_ACTOR_ID from a dir's config. Set it explicitly.
export AMA2_AGENT_ACTOR_ID="$AGENT_ACTOR_ID"

if [ -n "$WORKSPACE_DIR" ]; then
  RUN_DIR="$WORKSPACE_DIR"
  HANDLER_PROMPT="You are agent-team member '$AGENT_ACTOR_ID', working INSIDE this project \
repo — its own guide (CLAUDE.md/AGENTS.md), tooling, and gates apply here; follow \
them. Your TEAM identity, mandate, and reporting thread are in $AGENT_DIR (its \
CLAUDE.md/AGENTS.md) and the team charter $AGENT_DIR/../TEAM.md — read them first. \
Then check your team inbox: run 'AMA2_AGENT_ACTOR_ID=$AGENT_ACTOR_ID ama2 threads pending'; for \
each pending thread run 'AMA2_AGENT_ACTOR_ID=$AGENT_ACTOR_ID ama2 read <id>', do the work HERE, \
and reply to the Manager with 'AMA2_AGENT_ACTOR_ID=$AGENT_ACTOR_ID ama2 send <id> \"<reply>\" \
--read-token <token>'. Then run your 'scan-work' skill: scan your own and the \
team's cards ('AMA2_AGENT_ACTOR_ID=$AGENT_ACTOR_ID ama2 cards list') and act on the next thing \
(continue/submit your card, fix a needs_fix, vote on a card you review). ALWAYS \
prefix ama2 with AMA2_AGENT_ACTOR_ID=$AGENT_ACTOR_ID. If nothing is actionable, stop."
else
  RUN_DIR="$AGENT_DIR"
  HANDLER_PROMPT="You were woken to check your team work. (1) Run 'ama2 threads pending'; \
for EACH pending thread run 'ama2 read <thread_id>' to get the message and a \
read-token, do the work it asks following your role guide and skills, and reply on \
that same thread with 'ama2 send <thread_id> \"<your reply>\" --read-token <token>' \
(coalesce a burst from one sender into a single reply). (2) Run your 'scan-work' \
skill: scan your own and the team's cards ('ama2 cards list') and act on the next \
thing — continue/submit your in_progress card, start+fix a needs_fix card, or vote \
on a card you're a reviewer of. When you close a card, run 'self-improve'. If \
nothing is actionable, stop without sending."
fi

cd "$RUN_DIR" || { echo "[poll-loop] cannot cd to $RUN_DIR" >&2; exit 1; }

run_handler() {
  case "$ENGINE" in
    codex)
      # Non-interactive Codex. Bypass approvals/sandbox so it can run ama2/tools
      # unattended (tune to your security comfort: see `codex exec --help`).
      codex exec --skip-git-repo-check --dangerously-bypass-approvals-and-sandbox "$HANDLER_PROMPT"
      ;;
    *)
      claude -p "$HANDLER_PROMPT" --permission-mode acceptEdits
      ;;
  esac
}

# work_pending: is there anything to wake for? An unread thread, OR a work card
# in an action-owed state (needs_fix to fix, in_review to vote on). in_progress/
# todo continuation piggybacks on these wakes — we don't wake on those alone, so
# a truly idle tick stays free.
work_pending() {
  ama2 threads pending --format json 2>/dev/null | grep -q '"thread_id"' && return 0
  for st in needs_fix in_review; do
    ama2 cards list --status "$st" --limit 1 --format json 2>/dev/null | grep -q '"id"' && return 0
  done
  return 1
}

echo "[poll-loop] $AGENT_ACTOR_ID [$ENGINE] in $RUN_DIR (identity $AGENT_DIR) every ${INTERVAL}s (pid $$)"
while true; do
  if work_pending; then
    echo "[poll-loop] $(date '+%Y-%m-%dT%H:%M:%S') $AGENT_ACTOR_ID: work found -> waking $ENGINE handler"
    run_handler || echo "[poll-loop] handler exited non-zero (continuing)"
  fi
  sleep "$INTERVAL"
done
