#!/bin/sh
# Heatwave credibility benchmark harness. POSIX sh. See METHODOLOGY.md.
# Usage: sh benchmark/run.sh --arm <raw|heatwave|fixture-good|fixture-bad>
#                            [--tasks N] [--trials K] [--only t01-x,t02-y]
set -eu

BENCH=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
REPO=$(dirname "$BENCH")
ARM= TASKS=8 TRIALS=1 ONLY=
RAW_DEADLINE=900 HW_DEADLINE=2700              # seconds; NFR-2
CUM_COST_CAP=60 CUM_WALL_CAP=14400             # sweep-cumulative breaker (F-003)

# Verbatim arm prompts (reproduced in METHODOLOGY.md — do not edit one without the other).
RAW_PROMPT="Implement the task described in SPEC.md by editing the files in this directory. Make the visible tests pass and satisfy the SPEC completely. When done, stop."
HW_PROMPT="Implement the task described in SPEC.md. This project uses the Heatwave protocol (CLAUDE.md); follow it, driving the run to a terminal state. Make the visible tests pass and satisfy the SPEC completely."

while [ $# -gt 0 ]; do
  case "$1" in
    --arm) ARM=$2; shift 2 ;;
    --tasks) TASKS=$2; shift 2 ;;
    --trials) TRIALS=$2; shift 2 ;;
    --only) ONLY=$2; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done
case "$ARM" in raw|heatwave|fixture-good|fixture-bad) ;; *) echo "bad --arm (raw|heatwave|fixture-good|fixture-bad)" >&2; exit 1 ;; esac

meta() { sed -n "s/^$1: //p" "$2/TASK.yaml"; }
manifest() { (cd "$BENCH/corpus" && find . -type f | LC_ALL=C sort | xargs shasum -a 256); }

with_deadline() {  # $1=secs, rest=cmd. No timeout(1) on macOS. Kills the PROCESS GROUP (F-004).
  secs=$1; shift
  set -m                                        # job control: background job = own process group
  "$@" & pid=$!
  set +m
  ( t=0; while [ "$t" -lt "$secs" ]; do kill -0 "$pid" 2>/dev/null || exit 0; sleep 5; t=$((t+5)); done
    kill -TERM -- -"$pid" 2>/dev/null; sleep 10; kill -KILL -- -"$pid" 2>/dev/null ) & wd=$!
  st=0; wait "$pid" || st=$?
  kill "$wd" 2>/dev/null || true
  return "$st"
}

run_agent() {  # $1=scratch $2=deadline-secs $3=prompt. Sets COST. Returns arm exit status.
  _scratch=$1; _deadline=$2; _prompt=$3
  _st=0
  ( cd "$_scratch" && with_deadline "$_deadline" \
      claude -p --setting-sources project --dangerously-skip-permissions \
        --output-format json "$_prompt" > agent.json 2> agent.err ) || _st=$?
  COST=$(python3 -c 'import json,sys
try:
    v = json.load(open(sys.argv[1])).get("total_cost_usd", "")
    print("" if v is None else v)
except Exception:
    print("")' "$_scratch/agent.json" 2>/dev/null || echo "")
  return "$_st"
}

break_tripped() {  # F-003: cumulative sweep breaker. Returns 0 (trip) or 1 (continue).
  [ "$CUM_WALL" -gt "$CUM_WALL_CAP" ] && return 0
  if python3 -c "import sys; sys.exit(0 if $CUM_COST > $CUM_COST_CAP else 1)"; then return 0; fi
  if [ "$ARM" = heatwave ] && [ -n "$CANARY_COST" ]; then
    if python3 -c "import sys; sys.exit(0 if $CUM_COST > 3 * $CANARY_COST else 1)"; then return 0; fi
  fi
  return 1
}

RUN_ID=$(date -u +%Y%m%dT%H%M%SZ)-$ARM
CSV="$BENCH/results/$RUN_ID.csv"
TRANSCRIPTS="$BENCH/results/transcripts/$RUN_ID"
mkdir -p "$BENCH/results" "$TRANSCRIPTS"
echo "run_id,task,arm,trial,visible_pass,oracle_pass,escaped_defect,wall_secs,cost_usd,notes" > "$CSV"

# F-001: arms run OUTSIDE the repo tree — the corpus/oracle is not discoverable from cwd.
SWEEP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/hw-bench.XXXXXX")
case "$SWEEP_ROOT" in "$REPO"*) echo "FATAL: scratch root inside repo" >&2; exit 1 ;; esac
echo "scratch_root: $SWEEP_ROOT (outside $REPO)" | tee "$TRANSCRIPTS/scratch-root.txt"
trap 'rm -rf "$SWEEP_ROOT"' EXIT

BEFORE=$(manifest)
CUM_COST=0 CUM_WALL=0 CANARY_COST=

count=0
for TASK_DIR in "$BENCH"/corpus/*/; do
  ID=$(basename "$TASK_DIR")
  [ -n "$ONLY" ] && case ",$ONLY," in *,"$ID",*) ;; *) continue ;; esac
  count=$((count+1)); [ "$count" -gt "$TASKS" ] && break
  MODULE=$(meta module "$TASK_DIR")
  trial=1
  while [ "$trial" -le "$TRIALS" ]; do
    SCRATCH="$SWEEP_ROOT/$ARM/$ID/trial-$trial"
    mkdir -p "$SCRATCH"
    cp -R "$TASK_DIR/repo/." "$SCRATCH/"
    cp "$TASK_DIR/SPEC.md" "$SCRATCH/SPEC.md"
    # Withheld set is structural (only repo/ + SPEC.md copied) AND asserted:
    if [ -e "$SCRATCH/oracle" ] || [ -e "$SCRATCH/solutions" ] || [ -e "$SCRATCH/TASK.yaml" ]; then
      echo "FATAL: withheld file leaked into agent surface for $ID" >&2; exit 1
    fi
    (cd "$SCRATCH" && git init -q && git add -A \
      && git -c user.email=bench@local -c user.name=bench commit -qm "benchmark start: $ID")
    COST=""; NOTE=""; START=$(date +%s)
    case "$ARM" in
      fixture-good) cp "$TASK_DIR/solutions/good.py" "$SCRATCH/$MODULE" ;;
      fixture-bad)  cp "$TASK_DIR/solutions/bad.py"  "$SCRATCH/$MODULE" ;;
      raw)      run_agent "$SCRATCH" "$RAW_DEADLINE" "$RAW_PROMPT" || NOTE="agent-nonzero-or-timeout" ;;
      heatwave) mkdir -p "$SCRATCH/.claude/skills/ui-ux-pro-max"     # F-002: no network clone
                sh "$REPO/install.sh" "$SCRATCH" claude > "$SCRATCH/install.log" 2>&1 \
                  || NOTE="install-failed"                           # F-005
                if [ "$NOTE" != "install-failed" ]; then
                  run_agent "$SCRATCH" "$HW_DEADLINE" "$HW_PROMPT" || NOTE="agent-nonzero-or-timeout"
                fi ;;
    esac
    WALL=$(( $(date +%s) - START ))
    cp "$TASK_DIR/oracle/test_oracle.py" "$SCRATCH/"      # grading only — AFTER the arm exited
    VIS=0
    if (cd "$SCRATCH" && with_deadline 120 sh -c "$(meta visible_check "$TASK_DIR")" \
        > visible.log 2>&1); then VIS=1; fi
    ORA=0
    if (cd "$SCRATCH" && with_deadline 120 sh -c "$(meta oracle_cmd "$TASK_DIR")" \
        > oracle.log 2>&1); then ORA=1; fi
    ESC=0; [ "$VIS" -eq 1 ] && [ "$ORA" -eq 0 ] && ESC=1
    echo "$RUN_ID,$ID,$ARM,$trial,$VIS,$ORA,$ESC,$WALL,$COST,$NOTE" >> "$CSV"
    # Evidence copy-back (AC-F-05/AC-F-10), then the scratch is disposable:
    DEST="$TRANSCRIPTS/$ID-trial$trial"; mkdir -p "$DEST"
    for f in agent.json agent.err visible.log oracle.log install.log; do
      [ -f "$SCRATCH/$f" ] && cp "$SCRATCH/$f" "$DEST/" || true
    done
    # F-003: sweep-cumulative circuit breaker (wall always; cost when reported).
    CUM_WALL=$((CUM_WALL + WALL))
    [ -n "$COST" ] && CUM_COST=$(python3 -c "print($CUM_COST + $COST)") || true
    if [ "$ARM" = heatwave ] && [ "$count" -eq 1 ] && [ -n "$COST" ]; then CANARY_COST=$COST; fi
    if break_tripped; then
      echo "COST-BOUND: cumulative cap hit after $ID (cum_cost=$CUM_COST cum_wall=${CUM_WALL}s); remaining tasks NOT RUN" | tee -a "$TRANSCRIPTS/escape.txt"
      break 2
    fi
    trial=$((trial+1))
  done
done

AFTER=$(manifest)
[ "$BEFORE" = "$AFTER" ] || { echo "FATAL: corpus originals mutated during run" >&2; exit 1; }
# AC-F-10(b): transcript grep — zero oracle/corpus references in any agent transcript.
if grep -rl -e 'benchmark/corpus' -e 'oracle' "$TRANSCRIPTS"/*/agent.json "$TRANSCRIPTS"/*/agent.err 2>/dev/null; then
  echo "WARNING: possible oracle/corpus reference in agent transcript — investigate before using results" >&2
fi
awk -F, -f "$BENCH/summarize.awk" "$CSV"
echo "results: $CSV"
