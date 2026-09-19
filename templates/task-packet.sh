#!/bin/sh
# task-packet.sh — deterministic, LLM-free task-scoped retrieval packet (R-148, v5-retrieval).
# POSIX sh + git + grep/awk/sed. NO model is ever invoked. Paths, counts and line hints only —
# never a file-body excerpt (R-131 discipline). The packet is a STARTING POINT, never a gate:
# out-of-packet reads stay legal and are recorded via R-49.
#
# Usage:
#   sh task-packet.sh <run-dir> --role <role> --terms "t1 t2 ..." [--module <path>]
#                     [--repo-root <dir>] [--budget <n>] [--config <file>]
#   sh task-packet.sh --check          # self-test on a synthetic tree (ponytail one-check)
#
# Output: <run-dir>/00-task-packet.md
# Budget: --budget N, else config `context_budgets.<role>` (integer), else default 12.
set -eu

DEFAULT_BUDGET=12

die() { echo "task-packet: $1" >&2; exit "${2:-2}"; }

# ---- config: context_budgets.<role> (block form), integer-only, else default ----
read_budget() {
  role=$1; cfg=$2
  [ -f "$cfg" ] || { echo "$DEFAULT_BUDGET"; return; }
  val=$(awk -v r="$role" '
    /^context_budgets:[[:space:]]*$/ { inblk=1; next }
    inblk && /^[^[:space:]#]/       { inblk=0 }
    inblk && $0 ~ ("^[[:space:]]+" r "[[:space:]]*:") {
      v=$0; sub(/.*:[[:space:]]*/,"",v); sub(/[[:space:]].*$/,"",v); print v; exit }
  ' "$cfg" 2>/dev/null || true)
  case "$val" in
    ''|*[!0-9]*) echo "$DEFAULT_BUDGET" ;;
    *) if [ "$val" -ge 1 ] 2>/dev/null; then echo "$val"; else echo "$DEFAULT_BUDGET"; fi ;;
  esac
}

# ---- import-degree of a path from cached import edges ("a -> b" lines) ----
degree() {
  p=$1; edges=$2
  ps=$(basename "$p"); ps=${ps%.*}
  printf '%s\n' "$edges" | awk -v P="$p" -v S="$ps" '
    NF>=3 { imp=$1; ts=$3; sub(/.*\//,"",ts); sub(/\.[^.]*$/,"",ts); if (imp==P || ts==S) c++ }
    END { print c+0 }'
}

build_packet() {
  RUNDIR=$1; ROLE=$2; TERMS=$3; MODULE=$4; ROOT=$5; BUDGET=$6
  [ -d "$RUNDIR" ] || die "run dir not found: $RUNDIR"
  cd "$ROOT"
  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    { echo "# Task packet"; echo; echo "NOT AVAILABLE — not a git repository ($ROOT)"; } > "$RUNDIR/00-task-packet.md"
    echo "task-packet: NOT AVAILABLE — not a git repository ($ROOT)" >&2; return 0
  fi
  TOP=$(git rev-parse --show-toplevel); cd "$TOP"
  CACHE="$TOP/.heatwave/cache/repo-map.md"
  [ -f "$CACHE" ] || sh "$SELF_DIR/repo-map.sh" "$TOP" >/dev/null 2>&1 || true

  EDGES=$(sed -n '/^## Module dependency graph/,/^## /p' "$CACHE" 2>/dev/null | grep ' -> ' || true)
  TESTMAP=$(sed -n '/^## Test <-> source map/,/^## /p' "$CACHE" 2>/dev/null | grep ' <-> ' || true)

  modstem=""
  [ -n "$MODULE" ] && { modstem=$(basename "$MODULE"); modstem=${modstem%.*}; }

  # ---- rank tracked files by distinct-term match count (fixed-string, injection-safe) ----
  matchgrep="git grep -lF -e <term> over tracked files, one grep per term"
  raw=""
  for t in $TERMS; do
    m=$(git grep -lF -e "$t" -- . 2>/dev/null || true)
    [ -n "$m" ] && raw="$raw$m
"
  done
  counts=$(printf '%s' "$raw" | grep -v '^$' | sort | uniq -c | sort -rn || true)
  total_matched=$(printf '%s\n' "$counts" | grep -c . || true)

  # augment with tie-breaks (module match, import-degree), sort, cap to budget
  ranked=$(printf '%s\n' "$counts" | while read -r n path; do
    [ -n "$path" ] || continue
    ps=$(basename "$path"); ps=${ps%.*}
    mod=0; [ -n "$modstem" ] && [ "$ps" = "$modstem" ] && mod=1
    deg=$(degree "$path" "$EDGES")
    printf '%s\t%s\t%s\t%s\n' "$n" "$mod" "$deg" "$path"
  done | sort -k1,1nr -k2,2nr -k3,3nr -k4,4 | head -n "$BUDGET")

  ranked_paths=$(printf '%s\n' "$ranked" | awk -F'\t' 'NF{print $4}')
  ranked_n=$(printf '%s\n' "$ranked_paths" | grep -c . || true)

  # ---- related tests: cache test-map rows touching a ranked path ----
  rel_tests=""
  if [ -n "$TESTMAP" ] && [ -n "$ranked_paths" ]; then
    rel_tests=$(printf '%s\n' "$ranked_paths" | while IFS= read -r p; do
      [ -n "$p" ] || continue
      printf '%s\n' "$TESTMAP" | grep -F "$p" || true
    done | sort -u)
  fi

  # ---- import neighbours: edges importing FROM or INTO a ranked file ----
  rel_edges=""
  if [ -n "$EDGES" ] && [ -n "$ranked_paths" ]; then
    rel_edges=$(printf '%s\n' "$ranked_paths" | while IFS= read -r p; do
      [ -n "$p" ] || continue
      ps=$(basename "$p"); ps=${ps%.*}
      printf '%s\n' "$EDGES" | awk -v P="$p" -v S="$ps" 'NF>=3 { ts=$3; sub(/.*\//,"",ts); sub(/\.[^.]*$/,"",ts); if ($1==P || ts==S) print }'
    done | sort -u)
  fi

  # ---- matching failure-memory (trigger_paths prefix-intersect ranked files, R-138 class) ----
  KDIR="$TOP/.heatwave/knowledge"
  fmem=""
  if [ -d "$KDIR" ] && [ -n "$ranked_paths" ]; then
    for entry in "$KDIR"/*.md; do
      [ -f "$entry" ] || continue
      case "$(basename "$entry")" in README.md) continue ;; esac
      tp=$(grep -iE '^[[:space:]]*trigger_paths[[:space:]]*:' "$entry" | sed 's/^[^:]*://; s/,/ /g' || true)
      [ -n "$tp" ] || continue
      hit=0
      for P in $tp; do p=${P%/}
        for F in $ranked_paths; do f=${F%/}
          [ "$f" = "$p" ] && hit=1
          case "$f" in "$p"/*) hit=1 ;; esac
          case "$p" in "$f"/*) hit=1 ;; esac
        done
      done
      [ "$hit" -eq 1 ] && fmem="$fmem$(basename "$entry" .md)
"
    done
  fi

  # ---- ACs pointer (plan may not exist at packet time, IN-1) ----
  plan=$(ls "$RUNDIR"/*planning-document*.md 2>/dev/null | tail -1 || true)

  tstamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  out="$RUNDIR/00-task-packet.md"; tmp="$out.build.$$"
  {
    echo "<!-- GENERATED by task-packet.sh (R-148). LLM-free. Paths/counts/line-hints only."
    echo "     ADVISORY starting point, NOT a gate — out-of-packet reads are legal and recorded (R-49). -->"
    echo "# Task packet"
    echo
    echo "role: $ROLE | budget (max files): $BUDGET | generated: $tstamp"
    echo "repo: $TOP"
    echo "terms: $TERMS"
    echo "module (named): ${MODULE:-none}"
    echo
    echo "## Relevant files (ranked, capped)"
    echo "derivation: $matchgrep; ranked by distinct-term match count, tie-break module match then import-degree; capped to budget"
    echo "matched $total_matched file(s); showing $ranked_n (cap $BUDGET)"
    if [ -n "$ranked" ]; then
      printf '%s\n' "$ranked" | awk -F'\t' 'NF{printf "- %s  (%s term(s)", $4, $1; if($2=="1")printf ", named-module"; if($3+0>0)printf ", import-degree %s",$3; printf ")\n"}'
    else
      echo "- (none — 0 files matched the terms)"
    fi
    echo
    echo "## Related tests"
    echo "derivation: repo-map Test <-> source rows touching a ranked file"
    if [ -n "$rel_tests" ]; then printf '%s\n' "$rel_tests" | sed 's/^/- /'; else echo "- NOT DETECTED — no mapped test touches a ranked file"; fi
    echo
    echo "## Import neighbours (imports and importers)"
    echo "derivation: repo-map import edges where a ranked file is importer or imported"
    if [ -n "$rel_edges" ]; then printf '%s\n' "$rel_edges" | sed 's/^/- /'; else echo "- NOT DETECTED — no import edge touches a ranked file"; fi
    echo
    echo "## Acceptance criteria pointer"
    if [ -n "$plan" ]; then echo "- see approved plan: $plan"; else echo "- ACs not yet written (packet precedes PLANNING, IN-1); the planner writes them into the run dir's planning document"; fi
    echo
    echo "## Matching failure-memory"
    echo "derivation: knowledge entries whose trigger_paths prefix-intersect a ranked file (R-138 selection class)"
    if [ -n "$fmem" ]; then printf '%s' "$fmem" | grep -v '^$' | sort -u | sed 's/^/- /'; else echo "- none"; fi
  } > "$tmp"
  mv "$tmp" "$out"
  echo "task-packet: generated $out"
}

# ================================ self-test =================================
selfcheck() {
  work=$(mktemp -d 2>/dev/null || mktemp -d -t twp)
  trap 'rm -rf "$work"' EXIT
  repo="$work/repo"; run="$work/run"; mkdir -p "$repo/pkg" "$run"
  # synthetic tree: edit target, a DISTANT importer with the term via import, a distractor without it
  printf 'def widget():\n    return "gizmo"\n' > "$repo/pkg/target.py"
  printf 'from pkg.target import widget\n\ndef use():\n    return widget()  # gizmo consumer\n' > "$repo/pkg/consumer.py"
  printf 'def unrelated():\n    return 1\n' > "$repo/pkg/distractor.py"
  printf 'from pkg.target import widget\nimport unittest\n' > "$repo/test_target.py"
  ( cd "$repo" && git init -q && git add -A && git -c user.email=t@t -c user.name=t commit -qm init )
  mkdir -p "$repo/.heatwave/knowledge"
  printf 'trigger_paths: pkg/target.py\n' > "$repo/.heatwave/knowledge/gizmo-bug.md"
  sh "$SELF_DIR/repo-map.sh" "$repo" >/dev/null 2>&1

  fail=0
  # (1) ranking: distant importer + target ranked in; distractor ranked out (terms: gizmo widget)
  build_packet "$run" implementer "gizmo widget" "pkg/target.py" "$repo" 12 >/dev/null 2>&1
  sec=$(sed -n '/## Relevant files/,/## Related tests/p' "$run/00-task-packet.md")
  echo "$sec" | grep -q 'pkg/target.py'   || { echo "FAIL: target not ranked"; fail=1; }
  echo "$sec" | grep -q 'pkg/consumer.py' || { echo "FAIL: distant importer not ranked"; fail=1; }
  echo "$sec" | grep -q 'pkg/distractor.py' && { echo "FAIL: distractor was ranked (should be out)"; fail=1; }
  # (2) named-module tie-break annotation present on target
  echo "$sec" | grep 'pkg/target.py' | grep -q 'named-module' || { echo "FAIL: module tie-break not annotated"; fail=1; }
  # (3) failure-memory intersect surfaced by slug
  grep -q 'gizmo-bug' "$run/00-task-packet.md" || { echo "FAIL: intersecting knowledge entry not surfaced"; fail=1; }
  # (4) budget cap honored
  build_packet "$run" implementer "gizmo widget" "pkg/target.py" "$repo" 1 >/dev/null 2>&1
   n=$(sed -n '/## Relevant files/,/## Related tests/p' "$run/00-task-packet.md" | grep -c '^- ')
  [ "$n" -eq 1 ] || { echo "FAIL: budget cap 1 not honored (got $n)"; fail=1; }
  # (5) bad/absent budget -> default 12 (via config with a non-integer value)
  printf 'context_budgets:\n  implementer: notanumber\n' > "$work/bad.yaml"
  b=$(read_budget implementer "$work/bad.yaml")
  [ "$b" -eq 12 ] || { echo "FAIL: bad budget did not fall back to 12 (got $b)"; fail=1; }
  b2=$(read_budget implementer "$work/nope.yaml")
  [ "$b2" -eq 12 ] || { echo "FAIL: absent config did not default to 12 (got $b2)"; fail=1; }
  printf 'context_budgets:\n  implementer: 7\n' > "$work/good.yaml"
  b3=$(read_budget implementer "$work/good.yaml")
  [ "$b3" -eq 7 ] || { echo "FAIL: valid budget 7 not read (got $b3)"; fail=1; }
  # (6) determinism: two runs byte-identical minus the timestamp line
  build_packet "$run" implementer "gizmo widget" "pkg/target.py" "$repo" 12 >/dev/null 2>&1
  grep -v '^role:' "$run/00-task-packet.md" > "$work/a.md"
  build_packet "$run" implementer "gizmo widget" "pkg/target.py" "$repo" 12 >/dev/null 2>&1
  grep -v '^role:' "$run/00-task-packet.md" > "$work/b.md"
  if ! diff "$work/a.md" "$work/b.md" >/dev/null; then
    echo "FAIL: not deterministic across runs"; fail=1; fi

  [ "$fail" -eq 0 ] && { echo "task-packet --check: PASS"; return 0; } || { echo "task-packet --check: FAIL"; return 1; }
}

# ================================ argv =================================
SELF_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

if [ "${1:-}" = "--check" ]; then selfcheck; exit $?; fi

[ $# -ge 1 ] || die "usage: task-packet.sh <run-dir> --role <role> --terms \"...\" [--module m] [--repo-root d] [--budget n] [--config f]"
RUNDIR=$1; shift
ROLE=""; TERMS=""; MODULE=""; ROOT="."; BUDGET=""; CONFIG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --role)      ROLE=$2; shift 2 ;;
    --terms)     TERMS=$2; shift 2 ;;
    --module)    MODULE=$2; shift 2 ;;
    --repo-root) ROOT=$2; shift 2 ;;
    --budget)    BUDGET=$2; shift 2 ;;
    --config)    CONFIG=$2; shift 2 ;;
    *) die "unknown arg: $1" ;;
  esac
done
[ -n "$ROLE" ] || die "missing --role"
RUNDIR=$(cd "$RUNDIR" 2>/dev/null && pwd || echo "$RUNDIR")
absroot=$(cd "$ROOT" 2>/dev/null && pwd || echo "$ROOT")
[ -n "$CONFIG" ] || CONFIG="$absroot/heatwave.config.yaml"
[ -f "$CONFIG" ] || CONFIG="$(git -C "$absroot" rev-parse --show-toplevel 2>/dev/null)/heatwave.config.yaml"
if [ -z "$BUDGET" ]; then BUDGET=$(read_budget "$ROLE" "$CONFIG"); fi
case "$BUDGET" in ''|*[!0-9]*) BUDGET=$DEFAULT_BUDGET ;; esac
build_packet "$RUNDIR" "$ROLE" "$TERMS" "$MODULE" "$absroot" "$BUDGET"
