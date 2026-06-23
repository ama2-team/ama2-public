#!/usr/bin/env bash
# setup.sh — one-time install for this agent-team starter.
#
# A fresh checkout ships with ONLY the Manager's identity/skills and empty IDs in
# team.json. This script provisions the Manager as a real AMA2 agent on YOUR
# account and wires it up so the Manager can greet you and start onboarding:
#
#   1. reuse-or-create the "Manager" agent       (ama2 agents create)
#   2. bind it to the local `manager` profile    (ama2 profiles add)
#   3. read your (human) owner identity          (ama2 owner me — needs the profile)
#   4. open the owner<->Manager DM thread        (ama2 threads create)
#   5. write all the IDs into team.json
#   6. kick off onboarding — the Manager's FIRST message greets you AND begins
#      init-team in one go (run via `claude -p`; falls back to a basic greeting)
#   7. bring the team online                      (scripts/start-team.sh) — REQUIRED:
#      the Manager must be polling to process your reply & continue onboarding.
#      Done by default (incl. when an agent runs setup); opt out with `--no-start`.
#
# Re-running is safe: if team.json is already provisioned it stops early.
#
# Prereqs: the `ama2` CLI, installed and logged in (`ama2 auth login`).
#
# Usage: scripts/setup.sh [--start | --no-start] [--force]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEAM_JSON="$ROOT/team.json"
PROFILE="manager"
DISPLAY_NAME="Manager"
DESCRIPTION="Coordinator for an agent-team: turns the owner's goals into researched, reviewed, finished work by delegating to specialist agents over AMA2."

START_MODE="ask"      # ask | start | no-start
FORCE=0
for a in "$@"; do
  case "$a" in
    --start)    START_MODE="start" ;;
    --no-start) START_MODE="no-start" ;;
    --force)    FORCE=1 ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done

die() { echo "✗ $*" >&2; exit 1; }
note() { echo "  $*"; }

# --- Python helpers. The program is passed via `python3 -c "$VAR"` (NOT
# `python3 - <<EOF`), so that piped CLI JSON stays on stdin for the helper to
# read — `python3 -` would otherwise consume the heredoc as the program and leave
# stdin at EOF. ------------------------------------------------------------------
read -r -d '' JFIND_PY <<'PY' || true
import sys, json
keys = sys.argv[1].split(",")
try:
    data = json.load(sys.stdin)
except Exception:
    print(""); sys.exit(0)
found = [None]
def walk(o):
    if found[0] is not None: return
    if isinstance(o, dict):
        for k in keys:
            v = o.get(k)
            if isinstance(v, (str, int)) and str(v) != "":
                found[0] = str(v); return
        for v in o.values(): walk(v)
    elif isinstance(o, list):
        for v in o: walk(v)
walk(data)
print(found[0] or "")
PY
# recursively pull the first non-empty value for any of $1 (comma keys) from piped JSON
jfind() { python3 -c "$JFIND_PY" "$1"; }

read -r -d '' FINDAGENT_PY <<'PY' || true
import sys, json
want = sys.argv[1].strip().lower()
try:
    data = json.load(sys.stdin)
except Exception:
    print(""); sys.exit(0)
agents = data.get("agents", data) if isinstance(data, dict) else data
if not isinstance(agents, list): agents = []
for a in agents:
    if not isinstance(a, dict): continue
    # `ama2 agents list --format json` emits agent_display_name / agent_actor_id
    # (cmd/agents.go); keep generic fallbacks.
    name = str(a.get("agent_display_name") or a.get("display_name") or a.get("name") or "").strip().lower()
    if name == want:
        aid = a.get("agent_actor_id") or a.get("actor_id") or a.get("agent_id") or a.get("id")
        if aid: print(aid); break
PY
# find an existing agent whose display name == $1 (case-insensitive); echo its id (or empty)
find_agent_id_by_name() { python3 -c "$FINDAGENT_PY" "$1"; }

read -r -d '' WRITETEAM_PY <<'PY' || true
import sys, json
f, owner_actor, owner_name, owner_user, mgr_actor, owner_thread = sys.argv[1:7]
d = json.load(open(f))
o = d.setdefault("owner", {})
o["actor_id"] = owner_actor
if owner_name: o["display_name"] = owner_name
if owner_user: o["username"] = owner_user
o["owner_dm_thread_id"] = owner_thread
for m in d.get("members", []):
    if m.get("is_orchestrator"):
        m["actor_id"] = mgr_actor
with open(f, "w") as fh:
    json.dump(d, fh, indent=2, ensure_ascii=False); fh.write("\n")
PY
# write the resolved IDs into team.json (in place; reads the file by path, no stdin)
write_team_json() { python3 -c "$WRITETEAM_PY" "$TEAM_JSON" "$1" "$2" "$3" "$4" "$5"; }

echo "agent-team setup — provisioning your Manager on AMA2"
echo

# --- 0. prereqs ----------------------------------------------------------------
command -v ama2 >/dev/null 2>&1 || die "the 'ama2' CLI is not installed. See https://github.com/ama2-team/ama2-public"
command -v python3 >/dev/null 2>&1 || die "python3 is required by this script."
if ! ama2 auth status >/dev/null 2>&1; then
  die "not logged in. Run 'ama2 auth login' first, then re-run this script."
fi

# --- guard: already provisioned? -----------------------------------------------
EXISTING_MGR="$(python3 -c 'import json,sys;d=json.load(open(sys.argv[1]));print(next((m.get("actor_id","") for m in d.get("members",[]) if m.get("is_orchestrator")),""))' "$TEAM_JSON")"
if [ -n "$EXISTING_MGR" ] && [ "$FORCE" -ne 1 ]; then
  echo "✓ Already provisioned — Manager actor_id is set in team.json."
  note "To bring the team online:  scripts/start-team.sh"
  note "To re-provision anyway:    scripts/setup.sh --force"
  exit 0
fi

# --- 1. reuse-or-create the Manager agent --------------------------------------
# `ama2 agents list/create` use the account session (only `ama2 auth login` is
# needed) — NOT a profile — so this runs before any profile exists.
echo "1/6  Finding or creating the Manager agent…"
MGR_ACTOR=""
AGENTS_JSON="$(ama2 agents list --format json 2>/dev/null || true)"
REUSE_ID="$(printf '%s' "$AGENTS_JSON" | find_agent_id_by_name "$DISPLAY_NAME")"
if [ -n "$REUSE_ID" ]; then
  if [ -c /dev/tty ]; then
    printf "  An agent named '%s' already exists (id %s).\n" "$DISPLAY_NAME" "$REUSE_ID" >&2
    printf "  Reuse it instead of creating a new one? [Y/n]: " >&2
    read -r ans < /dev/tty || ans=""
    case "$ans" in [Nn]*) REUSE_ID="" ;; esac
  fi
fi
if [ -n "$REUSE_ID" ]; then
  MGR_ACTOR="$REUSE_ID"
  note "reusing existing agent: $MGR_ACTOR"
else
  CREATE_JSON="$(ama2 agents create --name "$DISPLAY_NAME" --description "$DESCRIPTION" --format json 2>/dev/null || true)"
  MGR_ACTOR="$(printf '%s' "$CREATE_JSON" | jfind actor_id,agent_id,id)"
  [ -n "$MGR_ACTOR" ] || die "agent creation failed — could not read the new actor_id. Try 'ama2 agents create --name \"$DISPLAY_NAME\"' manually."
  note "created agent: $MGR_ACTOR"
fi

# --- 2. bind the local profile -------------------------------------------------
# Bind BEFORE reading owner identity: `ama2 owner me` uses runtimeClient() and
# fails when no profile is resolvable (fresh machine has only `auth login`).
echo "2/6  Binding the '$PROFILE' profile to the Manager…"
if ama2 profiles add "$MGR_ACTOR" --as "$PROFILE" >/dev/null 2>&1; then
  note "bound: $PROFILE -> $MGR_ACTOR"
else
  # Non-zero can be a benign re-bind, but it can also be a real failure that would
  # leave the '$PROFILE' profile pointing at a DIFFERENT (stale) agent — then every
  # later AMA2_PROFILE=$PROFILE call would act as the wrong agent while team.json
  # records MGR_ACTOR. So VERIFY the profile actually resolves to MGR_ACTOR; abort if not.
  ACTIVE="$(AMA2_PROFILE="$PROFILE" ama2 agents me --format json 2>/dev/null | jfind agent_id,agent_actor_id,actor_id,id)"
  if [ "$ACTIVE" = "$MGR_ACTOR" ]; then
    note "profile already bound to this Manager — continuing."
  else
    die "could not bind profile '$PROFILE' to $MGR_ACTOR (it currently resolves to '${ACTIVE:-none}'). Run 'ama2 profiles add $MGR_ACTOR --as $PROFILE' manually, then re-run setup."
  fi
fi

# --- 3. owner identity (now that a profile is bound) ---------------------------
echo "3/6  Reading your owner identity (ama2 owner me)…"
OWNER_JSON="$(AMA2_PROFILE="$PROFILE" ama2 owner me --format json 2>/dev/null || true)"
# `ama2 owner me --format json` emits owner_actor_id / owner_display_name
# (see public/cli/ama2-cli/cmd/owner.go); keep generic fallbacks too.
OWNER_ACTOR="$(printf '%s' "$OWNER_JSON" | jfind owner_actor_id,actor_id,id,user_actor_id)"
OWNER_NAME="$(printf '%s' "$OWNER_JSON" | jfind owner_display_name,display_name,name)"
OWNER_USER="$(printf '%s' "$OWNER_JSON" | jfind username,user_slug,slug,handle)"
[ -n "$OWNER_ACTOR" ] || die "could not read your owner actor_id from 'AMA2_PROFILE=$PROFILE ama2 owner me --format json'. Run 'AMA2_PROFILE=$PROFILE ama2 owner me' to debug."
note "owner: ${OWNER_NAME:-?} (@${OWNER_USER:-?})  actor_id=$OWNER_ACTOR"

# --- 4. open the owner<->Manager DM thread -------------------------------------
echo "4/6  Opening the owner <-> Manager DM…"
THREAD_JSON="$(AMA2_PROFILE="$PROFILE" ama2 threads create "$OWNER_ACTOR" --format json 2>/dev/null || true)"
OWNER_THREAD="$(printf '%s' "$THREAD_JSON" | jfind thread_id,id)"
[ -n "$OWNER_THREAD" ] || die "could not open the owner DM thread. Try 'AMA2_PROFILE=$PROFILE ama2 threads create $OWNER_ACTOR' manually."
note "owner DM thread: $OWNER_THREAD"

# --- 5. record everything in team.json -----------------------------------------
echo "5/6  Writing IDs into team.json…"
write_team_json "$OWNER_ACTOR" "$OWNER_NAME" "$OWNER_USER" "$MGR_ACTOR" "$OWNER_THREAD"
note "team.json updated."

# --- 6. kick off onboarding (Manager's first message = greeting + init-team) ----
# The poll loop is reactive — it can't START a brand-new conversation. So trigger
# the Manager ONCE here to send its opening message (greeting + onboarding), which
# is its init-team skill kicking in. Falls back to a basic greeting if `claude`
# isn't available or the run can't complete (e.g. first-run dir trust).
echo "6/6  Kicking off onboarding (the Manager greets you and starts init-team)…"
KICK="You are the Manager and this is your very FIRST contact with the owner. Run your init-team skill now: send ONE opening message to the owner DM thread $OWNER_THREAD that BOTH greets the owner AND begins onboarding (briefly say who you are, then ask what this team should be for / what they're working on). Read the thread first for a read-token, send, then stop — do not wait for a reply."
KICKED=0
if command -v claude >/dev/null 2>&1; then
  if ( cd "$ROOT/manager" && claude -p "$KICK" --permission-mode acceptEdits ) >/dev/null 2>&1; then
    KICKED=1; note "Manager sent its greeting + onboarding opener."
  fi
fi
if [ "$KICKED" -ne 1 ]; then
  note "(claude kickoff unavailable — posting a basic greeting; the Manager continues init-team once it's polling.)"
  read -r -d '' GREETING <<'EOF' || true
Hi! I'm your Manager on this AMA2 agent team. You bring goals to me; I turn them into finished, reviewed work by coordinating a team of specialist agents — and I report back here with one clear result.

To set us up: in a sentence or two, what are you working on, and what would you like this team to help with? Reply here and I'll take it from there.
EOF
  TOKEN="$(AMA2_PROFILE="$PROFILE" ama2 read "$OWNER_THREAD" --format json 2>/dev/null | jfind read_token,readToken,token || true)"
  [ -n "$TOKEN" ] && AMA2_PROFILE="$PROFILE" ama2 send "$OWNER_THREAD" "$GREETING" --read-token "$TOKEN" >/dev/null 2>&1 || true
fi

echo
echo "✓ Provisioned."
echo "  • Manager agent : $MGR_ACTOR"
echo "  • Owner DM       : $OWNER_THREAD"
echo

# --- 7. bring the team online (REQUIRED) ---------------------------------------
# Setup is not finished until the team is polling: the Manager already sent its
# onboarding opener, but it can only PROCESS the owner's reply (and continue
# init-team) once it's running. So setup starts the team by default — including
# when run non-interactively by an agent ("set this up" ⇒ a running team).
# Opt out with `--no-start` (then run scripts/start-team.sh yourself later).
do_start() { "$ROOT/scripts/start-team.sh"; }
echo "7/7  Bringing the team online (scripts/start-team.sh)…"
case "$START_MODE" in
  no-start)
    echo "  • --no-start given. The Manager is NOT polling yet — onboarding will"
    echo "    only continue once you run:  scripts/start-team.sh"
    ;;
  start)
    do_start ;;
  ask|*)
    if [ -c /dev/tty ]; then
      printf "  Start the team now so the Manager can continue onboarding? [Y/n]: "
      read -r ans < /dev/tty || ans=""
      case "$ans" in [Nn]*) echo "  • Skipped. Start later with:  scripts/start-team.sh (onboarding waits until then)" ;; *) do_start ;; esac
    else
      # non-interactive (e.g. an agent ran setup) — start by default
      do_start
    fi
    ;;
esac
echo
echo "✓ Done. Open AMA2 (web/app) and reply to the Manager's message — onboarding continues from there."
