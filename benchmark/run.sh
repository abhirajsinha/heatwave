#!/bin/sh
# Heatwave credibility benchmark harness. POSIX sh. See METHODOLOGY.md.
# Usage: sh benchmark/run.sh --arm <raw|heatwave|fixture-good|fixture-bad>
#                            [--tasks N] [--trials K] [--only t01-x,t02-y]
set -eu

BENCH=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
REPO=$(dirname "$BENCH")
ARM= TASKS=8 TRIALS=1 ONLY=
RAW_DEADLINE=${RAW_DEADLINE:-900} HW_DEADLINE=${HW_DEADLINE:-2700}  # seconds; NFR-2. Env-overridable: stub tests use tiny values.
CLAUDE_BIN=${CLAUDE_BIN:-claude}   # self-test seam: stub binary for zero-cost forced-outcome tests (disclosed in METHODOLOGY)
HW_MODEL=${HW_MODEL:-}             # optional disclosed model for the heatwave arm (FR-6); unset = session model
CUM_COST_CAP=60 CUM_WALL_CAP=14400             # sweep-cumulative breaker (F-003)

# Verbatim arm prompts (reproduced in METHODOLOGY.md — do not edit one without the other).
RAW_PROMPT="Implement the task described in SPEC.md by editing the files in this directory. Make the visible tests pass and satisfy the SPEC completely. When done, stop."
HW_PROMPT="Implement the task described in SPEC.md. This project uses the Heatwave protocol (CLAUDE.md); follow it, driving the run to a terminal state. Make the visible tests pass and satisfy the SPEC completely."
HW_UNATTENDED="UNATTENDED RUN: no human OWNER is available and none will respond, ever. If this run reaches ESCALATED or any blocking OWNER decision (R-95 stopping points 2-3), do NOT wait and do NOT end with an open question: write the Escalation Report artifact, set state: ESCALATED in state.yaml, make your final output line exactly 'ARM_OUTCOME: ESCALATED - <one-line reason>', and end the session. A run reaching APPROVED ends with final line 'ARM_OUTCOME: APPROVED'."

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
                   # On expiry touches "$DL_MARK" (when set) BEFORE TERM — the timeout is
                   # recorded even if the arm dies uncleanly. Grading calls run in subshells
                   # where DL_MARK is unset, so they never pollute the marker.
  secs=$1; shift
  set -m                                        # job control: background job = own process group
  "$@" & pid=$!
  set +m
  ( t0=$(date +%s)                              # monotonic elapsed check (review F-4): no drift from loop overhead
    while kill -0 "$pid" 2>/dev/null; do
      if [ $(( $(date +%s) - t0 )) -ge "$secs" ]; then
        [ -n "${DL_MARK:-}" ] && : > "$DL_MARK"
        kill -TERM -- -"$pid" 2>/dev/null; sleep 10; kill -KILL -- -"$pid" 2>/dev/null; exit 0
      fi
      sleep 5
    done ) & wd=$!
  st=0; wait "$pid" || st=$?
  kill "$wd" 2>/dev/null || true
  return "$st"
}

run_agent() {  # $1=scratch $2=deadline-secs $3=prompt [$4=append-system-prompt].
               # Sets COST SUBTYPE ST_MODEL RESULT_ESC. Returns arm exit status.
  _scratch=$1; _deadline=$2; _prompt=$3; _sys=${4:-}
  _st=0
  ( cd "$_scratch" && DL_MARK="$_scratch/deadline.expired" with_deadline "$_deadline" \
      "$CLAUDE_BIN" -p --setting-sources project --dangerously-skip-permissions \
        --output-format stream-json --verbose \
        ${ARM_MODEL:+--model "$ARM_MODEL"} \
        ${_sys:+--append-system-prompt "$_sys"} \
        "$_prompt" > agent.ndjson 2> agent.err ) || _st=$?
  eval "$(python3 "$BENCH/parse-result.py" "$_scratch/agent.ndjson")"  # single-quoted sanitized KEY='value' only
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
echo "run_id,task,arm,trial,outcome,terminal,tier,stage_model,visible_pass,oracle_pass,escaped_defect,wall_secs,cost_usd,notes" > "$CSV"
echo "binary=$CLAUDE_BIN hw_model=${HW_MODEL:-<session-default>} raw_deadline=${RAW_DEADLINE}s hw_deadline=${HW_DEADLINE}s" \
  | tee "$TRANSCRIPTS/run-header.txt"

# F-001: arms run OUTSIDE the repo tree — the corpus/oracle is not discoverable from cwd.
SWEEP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/hw-bench.XXXXXX")
case "$SWEEP_ROOT" in "$REPO"*) echo "FATAL: scratch root inside repo" >&2; exit 1 ;; esac
echo "scratch_root: $SWEEP_ROOT (outside $REPO)" | tee "$TRANSCRIPTS/scratch-root.txt"
trap 'rm -rf "$SWEEP_ROOT"' EXIT
# Plan-review F-002: an operator interrupt mid-trial still records the started trial.
CUR=
on_int() {
  [ -n "$CUR" ] && echo "$CUR,error,0,,,,,,$(( $(date +%s) - START )),,interrupted" >> "$CSV"
  exit 130
}
trap on_int INT TERM

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
    COST=""; SUBTYPE=""; ST_MODEL=""; RESULT_ESC=0; NOTE=""; SAMPLER=
    START=$(date +%s)
    CUR="$RUN_ID,$ID,$ARM,$trial"
    case "$ARM" in
      fixture-good) cp "$TASK_DIR/solutions/good.py" "$SCRATCH/$MODULE" ;;
      fixture-bad)  cp "$TASK_DIR/solutions/bad.py"  "$SCRATCH/$MODULE" ;;
      raw)      ARM_MODEL= run_agent "$SCRATCH" "$RAW_DEADLINE" "$RAW_PROMPT" || NOTE="agent-nonzero" ;;
      heatwave) mkdir -p "$SCRATCH/.claude/skills/ui-ux-pro-max"     # F-002: no network clone
                sh "$REPO/install.sh" "$SCRATCH" claude > "$SCRATCH/install.log" 2>&1 \
                  || NOTE="install-failed"                           # F-005
                if [ "$NOTE" != "install-failed" ]; then
                  ( while :; do { date -u +%FT%TZ; cat "$SCRATCH"/.heatwave/runs/*/state.yaml 2>/dev/null || :; echo --; } \
                      >> "$SCRATCH/state-timeline.log"; sleep 30; done ) & SAMPLER=$!
                  ARM_MODEL="$HW_MODEL" run_agent "$SCRATCH" "$HW_DEADLINE" "$HW_PROMPT" "$HW_UNATTENDED" \
                    || NOTE="agent-nonzero"
                  kill "$SAMPLER" 2>/dev/null || true
                fi ;;
    esac
    WALL=$(( $(date +%s) - START ))
    # Outcome classification (FR-7; total — every path assigns).
    LAST_STATE=$(sed -n 's/^state:[[:space:]]*//p' "$SCRATCH"/.heatwave/runs/*/state.yaml 2>/dev/null | tail -1)
    TIER=$(sed -n 's/^tier:[[:space:]]*//p' "$SCRATCH"/.heatwave/runs/*/state.yaml 2>/dev/null | tail -1)
    case "$ARM" in fixture-good|fixture-bad) OUTCOME=graded TERMINAL=1 ;; *)
      if [ -f "$SCRATCH/deadline.expired" ]; then
        OUTCOME=timeout TERMINAL=0 NOTE="timeout; last_state=${LAST_STATE:-none}${NOTE:+; $NOTE}"
      elif [ "$ARM" = heatwave ] && [ "${LAST_STATE:-}" != APPROVED ] \
          && { [ "${LAST_STATE:-}" = ESCALATED ] || [ "${LAST_STATE:-}" = ABANDONED ] \
               || [ "${RESULT_ESC:-0}" = 1 ]; }; then   # plan-review F-001: APPROVED wins over a prose marker
        OUTCOME=escalated TERMINAL=1 NOTE="escalated; state=${LAST_STATE:-unrecorded}${NOTE:+; $NOTE}"
      elif [ "${SUBTYPE:-}" = success ] && { [ "$ARM" = raw ] || [ "${LAST_STATE:-}" = APPROVED ]; }; then
        OUTCOME=graded TERMINAL=1
      else
        OUTCOME=error TERMINAL=0 NOTE="error; subtype=${SUBTYPE:-none}; last_state=${LAST_STATE:-none}${NOTE:+; $NOTE}"
      fi ;;
    esac
    STAGE_MODEL=$ST_MODEL
    [ "$ARM" = heatwave ] && STAGE_MODEL=${HW_MODEL:-$ST_MODEL}
    # Grading files re-copied from the corpus AFTER the arm exited — the graded
    # checks are always the corpus's, even if the agent edited or replaced them
    # (review F-3). Grading runs for every outcome; VIS/ORA on non-graded rows
    # are supplementary observations only (METHODOLOGY scoring section).
    cp "$TASK_DIR/oracle/test_oracle.py" "$SCRATCH/"
    cp "$TASK_DIR/repo/test_visible.py" "$SCRATCH/"
    VIS=0
    if (cd "$SCRATCH" && with_deadline 120 sh -c "$(meta visible_check "$TASK_DIR")" \
        > visible.log 2>&1); then VIS=1; fi
    ORA=0
    if (cd "$SCRATCH" && with_deadline 120 sh -c "$(meta oracle_cmd "$TASK_DIR")" \
        > oracle.log 2>&1); then ORA=1; fi
    ESC=0; [ "$VIS" -eq 1 ] && [ "$ORA" -eq 0 ] && ESC=1
    echo "$RUN_ID,$ID,$ARM,$trial,$OUTCOME,$TERMINAL,$TIER,$STAGE_MODEL,$VIS,$ORA,$ESC,$WALL,$COST,$NOTE" >> "$CSV"
    CUR=
    # Evidence copy-back, then the scratch is disposable:
    DEST="$TRANSCRIPTS/$ID-trial$trial"; mkdir -p "$DEST"
    for f in agent.ndjson agent.err visible.log oracle.log install.log state-timeline.log deadline.expired; do
      [ -f "$SCRATCH/$f" ] && cp "$SCRATCH/$f" "$DEST/" || true
    done
    [ -d "$SCRATCH/.heatwave/runs" ] && cp -R "$SCRATCH/.heatwave/runs" "$DEST/heatwave-runs" || true
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
# Detective control: zero oracle/corpus references in any agent evidence (incl. copied run artifacts).
if grep -rl -e 'benchmark/corpus' -e 'oracle' \
    "$TRANSCRIPTS"/*/agent.ndjson "$TRANSCRIPTS"/*/agent.err "$TRANSCRIPTS"/*/heatwave-runs 2>/dev/null; then
  echo "WARNING: possible oracle/corpus reference in agent evidence — investigate before using results" >&2
fi
awk -F, -f "$BENCH/summarize.awk" "$CSV"
echo "results: $CSV"
