#!/bin/sh
# Heatwave keep-awake — while a run is active, prevent SYSTEM sleep so the loop
# keeps executing when the screen locks or the display sleeps. The display is
# deliberately allowed to sleep — only system/idle sleep is inhibited.
# The driver calls `start` when a run leaves a terminal state and `stop` when it
# reaches APPROVED / ABANDONED / ESCALATED. A lid close or shutdown still pauses
# the machine — the resume rule (R-88) makes that loss-free.
# Usage: keep-awake.sh start|stop|status <run-dir>

set -eu

CMD=${1:-}; RUN=${2:-}
[ -n "$CMD" ] && [ -n "$RUN" ] && [ -d "$RUN" ] || { echo "usage: $0 start|stop|status <run-dir>" >&2; exit 1; }
PIDFILE="$RUN/.keep-awake.pid"

case "$CMD" in
  start)
    if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      echo "keep-awake already active (pid $(cat "$PIDFILE"))"; exit 0
    fi
    if command -v caffeinate >/dev/null 2>&1; then
      # -i: no idle system sleep (works on battery too); -s: no system sleep on AC
      nohup caffeinate -is >/dev/null 2>&1 &
      echo $! > "$PIDFILE"
      echo "keep-awake on (caffeinate, pid $(cat "$PIDFILE")) — screen may lock and dim; the system will not sleep"
    elif command -v systemd-inhibit >/dev/null 2>&1; then
      nohup systemd-inhibit --what=sleep:idle --who=heatwave --why="Heatwave run active" sleep infinity >/dev/null 2>&1 &
      echo $! > "$PIDFILE"
      echo "keep-awake on (systemd-inhibit, pid $(cat "$PIDFILE"))"
    else
      # ponytail: no Windows/other implementation — state the gap, don't fake it
      echo "keep-awake unavailable on this OS — keep the machine awake manually while the run is active"
    fi
    ;;
  stop)
    if [ -f "$PIDFILE" ]; then
      kill "$(cat "$PIDFILE")" 2>/dev/null || true
      rm -f "$PIDFILE"
      echo "keep-awake off"
    else
      echo "keep-awake not active"
    fi
    ;;
  status)
    if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      echo "active (pid $(cat "$PIDFILE"))"
    else
      echo "inactive"
    fi
    ;;
  *) echo "usage: $0 start|stop|status <run-dir>" >&2; exit 1 ;;
esac
