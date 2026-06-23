#!/usr/bin/env bash
# stop-team.sh — stop the WHOLE agent-team (Manager + all workers) started by
# start-team.sh. Kills each poll-loop daemon and any in-flight `claude -p` handler.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUN_DIR="$ROOT/.run"

shopt -s nullglob 2>/dev/null || true
found=0
for pidf in "$RUN_DIR"/*.pid; do
  found=1
  name="$(basename "$pidf" .pid)"
  pid="$(cat "$pidf" 2>/dev/null)"
  if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
    pkill -P "$pid" 2>/dev/null   # kill child claude -p, if any
    kill "$pid" 2>/dev/null
    echo "✓ stopped $name (pid $pid)"
  else
    echo "• $name not running"
  fi
  rm -f "$pidf"
done

[ "$found" -eq 0 ] && echo "Nothing running (.run/*.pid empty)."
