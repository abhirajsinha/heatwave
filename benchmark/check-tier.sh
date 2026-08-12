#!/bin/sh
# Structural LIGHT-tier gate for the tiering corpus (plan AC-F-03). POSIX sh.
# Deterministic, NO model spend. Asserts each task is *well-formed for LIGHT*:
# exactly one editable source file, already-implemented (not a stub), a real
# function body, no exported-contract surface, no sensitive-path marker, no
# non-stdlib import, and a SPEC free of the exact R-102 trigger phrases.
# This is a STATIC structural check, NOT a driver re-run: it cannot and does
# not assert "the driver picks LIGHT". Fail-closed; exit 0 only on all-PASS.
# Usage: [CORPUS=<dir>] sh benchmark/check-tier.sh            # sweep a corpus dir
#        sh benchmark/check-tier.sh <task-dir>                # one task
set -eu

BENCH=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
CORPUS=${CORPUS:-corpus-tiering}   # default root for the tiering fixtures
FAIL=0

meta() { sed -n "s/^$1: //p" "$2/TASK.yaml"; }

# Emit non-stdlib top-level imports of a .py file (empty => all stdlib / none).
non_stdlib_imports() {
  python3 - "$1" <<'PY'
import ast, sys
std = sys.stdlib_module_names
tree = ast.parse(open(sys.argv[1]).read())
bad = []
for n in ast.walk(tree):
    if isinstance(n, ast.Import):
        bad += [a.name.split('.')[0] for a in n.names if a.name.split('.')[0] not in std]
    elif isinstance(n, ast.ImportFrom) and n.level == 0 and n.module:
        top = n.module.split('.')[0]
        if top not in std:
            bad.append(top)
print(" ".join(sorted(set(bad))))
PY
}

check_task() {
  TASK_DIR=$1
  ID=$(basename "$TASK_DIR")
  MODULE=$(meta module "$TASK_DIR")
  MODFILE="$TASK_DIR/repo/$MODULE"
  R=PASS; why=

  # 1. Exactly one editable source file in repo/ (excluding test_*), == $MODULE.
  N=$(find "$TASK_DIR/repo" -type f -name '*.py' ! -name 'test_*' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$N" != 1 ] || [ ! -f "$MODFILE" ]; then R=FAIL; why="$why one-source($N,$MODULE);"; fi

  if [ -f "$MODFILE" ]; then
    # 2. Already-implemented, not a stub.
    grep -q 'NotImplementedError' "$MODFILE" && { R=FAIL; why="$why has-NotImplementedError;"; }
    # 3. A real function body (a def and at least one return).
    grep -q '^def \|^    def \|def ' "$MODFILE" || { R=FAIL; why="$why no-def;"; }
    grep -q 'return ' "$MODFILE" || { R=FAIL; why="$why no-body;"; }
    # 4. No exported-contract surface.
    grep -q '__all__' "$MODFILE" && { R=FAIL; why="$why has-__all__;"; }
    # 5. No sensitive-path marker.
    grep -qiE 'auth|token|password|payment|migration|schema' "$MODFILE" \
      && { R=FAIL; why="$why sensitive-marker;"; }
    # 6. No non-stdlib import.
    NS=$(non_stdlib_imports "$MODFILE")
    [ -n "$NS" ] && { R=FAIL; why="$why non-stdlib-import($NS);"; }
  fi

  # 7. SPEC free of the exact R-102 trigger phrases.
  if grep -qiE 'public contract|public API|callers import' "$TASK_DIR/SPEC.md"; then
    R=FAIL; why="$why spec-trigger-phrase;"
  fi

  printf '%-22s %-6s %s\n' "$ID" "$R" "$why"
  [ "$R" = PASS ] || FAIL=1
}

printf '%-22s %-6s %s\n' task tier notes

if [ $# -ge 1 ]; then
  check_task "${1%/}"
else
  for TASK_DIR in "$BENCH/$CORPUS"/*/; do
    [ -d "$TASK_DIR" ] || continue
    check_task "${TASK_DIR%/}"
  done
fi

if [ "$FAIL" -eq 0 ]; then
  echo "check-tier: ALL TASKS PASS (structural LIGHT)"
else
  echo "check-tier: FAILURES PRESENT" >&2
  exit 1
fi
