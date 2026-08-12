#!/bin/sh
# Corpus integrity + oracle-discrimination gate (FR-8). POSIX sh.
# Per task: layout complete, copy surface isolated from the withheld set,
# SPEC-traceability comments present, good passes oracle, bad fails oracle,
# bad passes visible. Exit 0 only on 8/8 PASS.
set -eu

BENCH=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
CORPUS=${CORPUS:-corpus}           # corpus root under $BENCH; unset => legacy "corpus" (byte-identical default)
FAIL=0

meta() { sed -n "s/^$1: //p" "$2/TASK.yaml"; }

printf '%-22s %-8s %-12s %-12s %-12s %-7s\n' task layout good-oracle bad-oracle bad-visible trace

for TASK_DIR in "$BENCH/$CORPUS"/*/; do
  ID=$(basename "$TASK_DIR")

  # 1. Layout completeness.
  LAYOUT=PASS
  for p in repo SPEC.md oracle/test_oracle.py solutions/good.py solutions/bad.py TASK.yaml; do
    [ -e "$TASK_DIR/$p" ] || LAYOUT=FAIL
  done
  # Copy-surface isolation: nothing withheld may live inside repo/ (the only
  # dir copied to the agent besides SPEC.md).
  if find "$TASK_DIR/repo" \( -name 'test_oracle*' -o -name 'good.py' -o -name 'bad.py' -o -name 'TASK.yaml' \) 2>/dev/null | grep -q .; then
    LAYOUT=FAIL
  fi

  # 2. SPEC-traceability: every oracle test method carries a "# SPEC:" comment.
  METHODS=$(grep -c 'def test_' "$TASK_DIR/oracle/test_oracle.py" || true)
  CITES=$(grep -c '# SPEC:' "$TASK_DIR/oracle/test_oracle.py" || true)
  TRACE=PASS
  [ "$METHODS" -ge 1 ] && [ "$CITES" -ge "$METHODS" ] || TRACE=FAIL

  # 3. Discrimination: good passes oracle; bad fails oracle; bad passes visible.
  MODULE=$(meta module "$TASK_DIR")
  VISIBLE=$(meta visible_check "$TASK_DIR")
  ORACLE=$(meta oracle_cmd "$TASK_DIR")

  W=$(mktemp -d "${TMPDIR:-/tmp}/hw-corpus.XXXXXX")
  cp -R "$TASK_DIR/repo/." "$W/"
  cp "$TASK_DIR/oracle/test_oracle.py" "$W/"

  cp "$TASK_DIR/solutions/good.py" "$W/$MODULE"
  GOOD_ORA=FAIL
  if (cd "$W" && sh -c "$ORACLE" >/dev/null 2>&1); then GOOD_ORA=PASS; fi

  cp "$TASK_DIR/solutions/bad.py" "$W/$MODULE"
  BAD_ORA=FAIL   # PASS here means the oracle correctly REJECTS bad.py
  if (cd "$W" && sh -c "$ORACLE" >/dev/null 2>&1); then :; else BAD_ORA=PASS; fi
  BAD_VIS=FAIL
  if (cd "$W" && sh -c "$VISIBLE" >/dev/null 2>&1); then BAD_VIS=PASS; fi

  rm -rf "$W"

  printf '%-22s %-8s %-12s %-12s %-12s %-7s\n' "$ID" "$LAYOUT" "$GOOD_ORA" "$BAD_ORA" "$BAD_VIS" "$TRACE"
  for v in "$LAYOUT" "$GOOD_ORA" "$BAD_ORA" "$BAD_VIS" "$TRACE"; do
    [ "$v" = PASS ] || FAIL=1
  done
done

if [ "$FAIL" -eq 0 ]; then
  echo "check-corpus: ALL TASKS PASS"
else
  echo "check-corpus: FAILURES PRESENT" >&2
  exit 1
fi
