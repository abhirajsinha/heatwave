#!/bin/sh
# heatwave-report-check.sh — deterministic completeness gates for Heatwave v5 (R-133/R-138/R-142).
# POSIX sh + grep/sed only. No eval, no path is ever executed; every input file is read as text.
#
# Subcommands:
#   plain-language      <report>
#   runtime-evidence    <plan> <acceptance-table>
#   knowledge-regression <knowledge-dir> <diff-file> <review-report>
#
# Exit: 0 = GREEN (gate satisfied), 1 = RED (gate not satisfied), 2 = usage/IO error.
# A RED result converts to a machine finding (R-111), default Major.
set -eu

usage() {
  echo "usage: heatwave-report-check.sh <plain-language|runtime-evidence|knowledge-regression> ..." >&2
  exit 2
}

# ---- pinned contracts (mirror the protocol; change here == change the gate) ----
# Runtime evidence classes — EXACTLY the seven verification_matrix classes (R-133, FR-1).
# A runtime AC signed off by a class OUTSIDE this allowlist (unit/sast/drift/grep/lint) goes RED.
RUNTIME_CLASSES='web-ui|chrome-extension|api|db-migration|mobile|deploy|real-input'
# Plain-section banned tokens (R-142): rule IDs, AC IDs, finding IDs, file paths, file:line, code fences.
#   file path = a token with a "/" AND a dotted filename component (so "pass/fail", "and/or", "24/57" pass;
#               "src/x.ts", "protocol/core.md" are banned). Bare version numbers ("v5.0") are NOT paths.
BANNED_RULE='R-[0-9]'
BANNED_AC='AC-[FN]-'
BANNED_FINDING='F-[A-Za-z0-9_-]+-[0-9][0-9][0-9]'
BANNED_PATH='[A-Za-z0-9_.-]+/[A-Za-z0-9_./-]*\.[A-Za-z0-9]+'
BANNED_FILELINE='\.[A-Za-z0-9]+:[0-9]+'
# Citation token for knowledge-regression (R-138, pinned per plan-review engineer note):
#   an intersecting entry's regression scenario counts as "cited" iff the entry's SLUG
#   (its filename without .md) appears verbatim in the review report. Nothing looser.

need_file() { [ -f "$1" ] || { echo "error: file not found: $1" >&2; exit 2; }; }
need_dir()  { [ -d "$1" ] || { echo "error: dir not found: $1" >&2; exit 2; }; }

# =====================================================================================
plain_language() {
  [ $# -eq 1 ] || { echo "usage: plain-language <report>" >&2; exit 2; }
  report=$1; need_file "$report"

  # Plain opener = a heading whose text contains "plain" (case-insensitive), e.g. "## In plain English".
  # Engineer section = a heading whose text contains "For the engineer".
  plain_ln=$(grep -niE '^#{1,6}[[:space:]].*plain' "$report" | head -1 | cut -d: -f1 || true)
  eng_ln=$(grep -niE '^#{1,6}[[:space:]].*for the engineer' "$report" | head -1 | cut -d: -f1 || true)

  if [ -z "$plain_ln" ]; then
    echo "RED plain-language: no plain-language opener (a '# ... plain ...' heading) in $report"; exit 1
  fi
  if [ -z "$eng_ln" ]; then
    echo "RED plain-language: no 'For the engineer' section in $report"; exit 1
  fi
  if [ "$eng_ln" -le "$plain_ln" ]; then
    echo "RED plain-language: 'For the engineer' ($eng_ln) does not follow the plain opener ($plain_ln)"; exit 1
  fi

  # Plain section = lines strictly between the plain heading and the engineer heading,
  # with HTML comments (<!-- ... -->) stripped: they are invisible to the reader, so template
  # guidance and authoring notes are not scanned — only reader-facing prose is. Keep HTML
  # comments on their own lines (the delete range is line-based).
  section=$(sed -n "$((plain_ln+1)),$((eng_ln-1))p" "$report" | sed '/<!--/,/-->/d')

  rc=0
  for pair in "rule-id=$BANNED_RULE" "AC-id=$BANNED_AC" "finding-id=$BANNED_FINDING" \
              "file-path=$BANNED_PATH" "file:line=$BANNED_FILELINE"; do
    label=${pair%%=*}; pat=${pair#*=}
    hit=$(printf '%s\n' "$section" | grep -nE "$pat" || true)
    if [ -n "$hit" ]; then
      echo "RED plain-language: banned token ($label) in the plain section of $report:"
      printf '%s\n' "$hit" | head -3
      rc=1
    fi
  done
  # Code fence anywhere in the plain section.
  fence=$(printf '%s\n' "$section" | grep -nE '^[[:space:]]*```' || true)
  if [ -n "$fence" ]; then
    echo "RED plain-language: code fence in the plain section of $report:"
    printf '%s\n' "$fence" | head -3
    rc=1
  fi

  [ "$rc" -eq 0 ] && echo "GREEN plain-language: $report has a clean plain opener and a 'For the engineer' section"
  return $rc
}

# =====================================================================================
# runtime-evidence <plan> <acceptance-table>
#   The plan tags each AC `runtime: yes|no`. The acceptance-table carries one row per AC id
#   whose evidence cell names a verification_matrix class token. For every AC the plan marks
#   `runtime: yes`, the matching acceptance-table row's evidence must name a RUNTIME_CLASSES
#   token; otherwise RED. The discriminator is allowlist membership, NOT cell non-emptiness —
#   a runtime AC "verified" by a unit test or a grep reference goes RED (the audit's escape).
runtime_evidence() {
  [ $# -eq 2 ] || { echo "usage: runtime-evidence <plan> <acceptance-table>" >&2; exit 2; }
  plan=$1; table=$2; need_file "$plan"; need_file "$table"

  allow="(^|[^A-Za-z-])($RUNTIME_CLASSES)([^A-Za-z-]|\$)"
  # AC ids the plan marks runtime: yes (id and tag on the same line).
  ids=$(grep -iE 'runtime:[[:space:]]*yes' "$plan" | grep -oE 'AC-[FN]-[0-9]+' | sort -u || true)
  if [ -z "$ids" ]; then
    echo "GREEN runtime-evidence: plan declares no runtime:yes acceptance criteria"; return 0
  fi

  rc=0
  for id in $ids; do
    row=$(grep -E "(^|[^A-Za-z0-9-])$id([^0-9]|\$)" "$table" | head -1 || true)
    if [ -z "$row" ]; then
      echo "RED runtime-evidence: $id is runtime:yes but has no evidence row in the acceptance table"
      rc=1; continue
    fi
    if printf '%s' "$row" | grep -Eq "$allow"; then
      : # names a runtime class -> green for this row
    else
      echo "RED runtime-evidence: $id is runtime:yes but its evidence names no runtime class (got: $row)"
      rc=1
    fi
  done
  [ "$rc" -eq 0 ] && echo "GREEN runtime-evidence: every runtime:yes AC is signed off by a runtime-class evidence token"
  return $rc
}

# =====================================================================================
# knowledge-regression <knowledge-dir> <diff-file> <review-report>
#   For each entry <slug>.md, read its `trigger_paths`. An entry INTERSECTS the diff when any
#   trigger path and any changed file are prefix-related (either is a string prefix of the other).
#   Every intersecting entry MUST be cited in the review report (its slug appears verbatim), else RED.
#   A non-intersecting entry is neither listed nor required (no false-regression cost).
knowledge_regression() {
  [ $# -eq 3 ] || { echo "usage: knowledge-regression <knowledge-dir> <diff-file> <review-report>" >&2; exit 2; }
  kdir=$1; diff=$2; report=$3; need_dir "$kdir"; need_file "$diff"; need_file "$report"

  # Changed paths: unified diff ("diff --git a/X b/Y") if present, else name-only (one path per line).
  changed=$(sed -n 's#^diff --git .* b/##p' "$diff" || true)
  [ -n "$changed" ] || changed=$(grep -vE '^[[:space:]]*$' "$diff" || true)

  rc=0; ran=0
  for entry in "$kdir"/*.md; do
    [ -f "$entry" ] || continue
    case "$(basename "$entry")" in README.md) continue ;; esac
    tp=$(grep -iE '^[[:space:]]*trigger_paths[[:space:]]*:' "$entry" | sed 's/^[^:]*://; s/,/ /g' || true)
    [ -n "$tp" ] || continue

    intersect=0
    for P in $tp; do
      for F in $changed; do
        case "$F" in "$P"*) intersect=1 ;; esac
        case "$P" in "$F"*) intersect=1 ;; esac
      done
    done
    [ "$intersect" -eq 1 ] || continue

    ran=1
    slug=$(basename "$entry" .md)
    if grep -Fq "$slug" "$report"; then
      echo "  cited: $slug (trigger paths intersect the diff)"
    else
      echo "RED knowledge-regression: entry '$slug' intersects the diff but its regression scenario is not cited in $report"
      rc=1
    fi
  done
  [ "$ran" -eq 0 ] && echo "GREEN knowledge-regression: no knowledge entry's trigger paths intersect this diff"
  [ "$ran" -eq 1 ] && [ "$rc" -eq 0 ] && echo "GREEN knowledge-regression: every intersecting entry is cited in the review report"
  return $rc
}

[ $# -ge 1 ] || usage
cmd=$1; shift
case "$cmd" in
  plain-language)       plain_language "$@" ;;
  runtime-evidence)     runtime_evidence "$@" ;;
  knowledge-regression) knowledge_regression "$@" ;;
  *) usage ;;
esac
