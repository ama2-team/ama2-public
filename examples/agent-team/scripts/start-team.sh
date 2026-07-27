#!/usr/bin/env bash
# start-team.sh — bring the WHOLE agent-team online as background polling daemons.
#
# Each member runs on a pluggable engine: "claude" (claude -p) or "codex"
# (codex exec). The engine is remembered per member in team.json ("engine" field).
# If a member has no engine set yet, you're prompted once and the choice is saved.
#
# By default this starts EVERY member from team.json — the Manager included.
# A member may declare "workspace_dir" (external project repo to run inside).
#
# Flags:
#   <interval_seconds>   poll interval (default 30)
#   --workers-only       do NOT start the Manager
#
# Usage: start-team.sh [interval_seconds] [--workers-only]
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUN_DIR="$ROOT/.run"
TEAM_JSON="$ROOT/team.json"
mkdir -p "$RUN_DIR"

# Default poll interval comes from team.json (polling.interval_seconds); fall back
# to 30 if unset/unreadable. A numeric command-line arg overrides it.
INTERVAL="$(python3 -c 'import json,sys
try:
    v=json.load(open(sys.argv[1])).get("polling",{}).get("interval_seconds")
    print(int(v) if v else 30)
except Exception:
    print(30)' "$TEAM_JSON" 2>/dev/null || echo 30)"
INCLUDE_MANAGER=1
for a in "$@"; do
  if [ "$a" = "--workers-only" ]; then INCLUDE_MANAGER=0
  elif printf '%s' "$a" | grep -qE '^[0-9]+$'; then INTERVAL="$a"; fi
done

# roster: "<name>\t<identity_dir>\t<agent_actor_id>\t<workspace_dir>\t<engine>" per member.
roster() {
  python3 - "$TEAM_JSON" "$INCLUDE_MANAGER" <<'PY'
import json, sys
data = json.load(open(sys.argv[1])); include_mgr = sys.argv[2] == "1"
for m in data.get("members", []):
    if m.get("is_orchestrator") and not include_mgr: continue
    d = m.get("dir")
    actor_id = m.get("actor_id")
    name = d or m.get("role") or actor_id
    if d and actor_id:
        # \x1f (unit separator, non-whitespace) so EMPTY fields aren't collapsed
        print(f"{name}\x1f{d}\x1f{actor_id}\x1f{m.get('workspace_dir','')}\x1f{m.get('engine','')}")
PY
}

# persist a member's engine choice back into team.json
save_engine() {
  python3 - "$TEAM_JSON" "$1" "$2" <<'PY'
import json, sys
f, member_dir, eng = sys.argv[1], sys.argv[2], sys.argv[3]
d = json.load(open(f))
for m in d.get("members", []):
    if m.get("dir") == member_dir: m["engine"] = eng
with open(f, "w") as fh:
    json.dump(d, fh, indent=2, ensure_ascii=False); fh.write("\n")
PY
}

resolve_engine() {  # echo engine for $1=member name given $2=current(maybe empty)
  local name="$1" engine="$2"
  [ -n "$engine" ] && { echo "$engine"; return; }
  engine="claude"
  if [ -c /dev/tty ]; then
    # numbered selection menu (menu+prompt go to stderr=terminal; input from tty)
    printf "\nPick engine for '%s' (Enter = claude):\n" "$name" >&2
    local choice PS3="  choose [1=claude / 2=codex]: "
    select choice in claude codex; do
      [ -z "$REPLY" ] && { engine="claude"; break; }       # Enter = default claude
      case "$choice" in
        claude|codex) engine="$choice"; break ;;
        *) printf "  please enter 1 or 2 (or Enter for claude)\n" >&2 ;;
      esac
    done < /dev/tty
  fi
  save_engine "$name" "$engine"
  echo "$engine"
}

start_one() {
  local name="$1" idir="$2" actor_id="$3" workspace="$4" engine="$5"
  local pidf="$RUN_DIR/$name.pid"
  if [ -f "$pidf" ] && kill -0 "$(cat "$pidf" 2>/dev/null)" 2>/dev/null; then
    echo "• $name already running (pid $(cat "$pidf"))"; return
  fi
  if [ ! -d "$idir" ]; then echo "✗ $name: identity dir not found ($idir) — skipping"; return; fi
  if [ -n "$workspace" ] && [ ! -d "$workspace" ]; then
    echo "✗ $name: workspace_dir not found ($workspace) — skipping"; return; fi
  if [ "$engine" = "codex" ]; then
    local doc="$idir/AGENTS.md"; [ -n "$workspace" ] && doc="$workspace/AGENTS.md"
    [ -f "$doc" ] || echo "  ⚠ $name: engine=codex but no AGENTS.md at $doc (Codex reads AGENTS.md, not CLAUDE.md)"
  fi
  # < /dev/null: detach the daemon's stdin so it (and the claude/codex handler it
  # spawns) can't drain this loop's roster stream and cut the loop short.
  nohup "$ROOT/scripts/poll-loop.sh" "$idir" "$actor_id" "$INTERVAL" "$workspace" "$engine" \
    < /dev/null >> "$RUN_DIR/$name.log" 2>&1 &
  echo $! > "$pidf"
  local where=""; [ -n "$workspace" ] && where=" in workspace $workspace"
  echo "✓ started $name [$engine] (pid $!)$where — log: $RUN_DIR/$name.log"
}

if [ "$INCLUDE_MANAGER" = "1" ]; then
  echo "Starting the WHOLE team (Manager + workers) from team.json, poll ${INTERVAL}s…"
else
  echo "Starting workers only (Manager excluded) from team.json, poll ${INTERVAL}s…"
fi
started=0
while IFS=$'\x1f' read -r name dir actor_id workspace engine; do
  [ -n "$name" ] || continue
  engine="$(resolve_engine "$dir" "$engine")"
  start_one "$name" "$ROOT/$dir" "$actor_id" "$workspace" "$engine"
  started=$((started + 1))
done < <(roster)
[ "$started" -eq 0 ] && echo "(no members found in team.json)"

echo "Done. Stop with: $ROOT/scripts/stop-team.sh"
if [ "$INCLUDE_MANAGER" = "1" ]; then
  echo "Talk to the team via AMA2 — message the Manager in the web app; it's headless now."
fi
