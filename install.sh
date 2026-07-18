#!/bin/sh
# Heatwave installer — copies the protocol runtime into a target project.
# Usage: ./install.sh /path/to/project [claude|codex|gemini|cursor|generic]
# Idempotent: re-running refreshes protocol files but never overwrites your config
# and never duplicates adapter blocks in existing instruction files.

set -eu

SRC=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET=${1:-}
ADAPTER=${2:-generic}

usage() {
  echo "Usage: $0 /path/to/project [claude|codex|gemini|cursor|generic]" >&2
  exit 1
}

[ -n "$TARGET" ] || usage
[ -d "$TARGET" ] || { echo "error: target directory '$TARGET' does not exist" >&2; exit 1; }
case "$ADAPTER" in claude|codex|gemini|cursor|generic) ;; *) usage ;; esac

HW="$TARGET/.heatwave"
mkdir -p "$HW/runs"

# Protocol runtime (refreshed on every run — these are Heatwave's files, not yours;
# runs/ and your config are never touched).
rm -rf "$HW/prompts" "$HW/templates" "$HW/plugins"
cp "$SRC/PROTOCOL.md" "$HW/PROTOCOL.md"
cp -R "$SRC/prompts" "$HW/"
cp -R "$SRC/templates" "$HW/"
mkdir -p "$HW/plugins"
cp -R "$SRC/plugins/ponytail" "$HW/plugins/"
cp "$SRC/adapters/generic/HEATWAVE-AGENT.md" "$HW/HEATWAVE-AGENT.md"

# Project config (created once, never overwritten — it is yours).
if [ ! -f "$TARGET/heatwave.config.yaml" ]; then
  cp "$SRC/heatwave.config.example.yaml" "$TARGET/heatwave.config.yaml"
  echo "created heatwave.config.yaml — edit it for your project"
fi

# Append an adapter block to an instruction file exactly once.
append_once() {
  file=$1; block=$2
  marker="Heatwave protocol (binding)"
  if [ -f "$file" ] && grep -q "$marker" "$file"; then
    echo "skipped $file (Heatwave block already present)"
  else
    [ -f "$file" ] && printf '\n' >> "$file"
    # strip installer-facing HTML comments (single-line AND multi-line) from the
    # block. A range delete /<!--/,/-->/d wipes to EOF on a one-line comment, so
    # use an awk state machine that closes inline comments and spans multi-line ones.
    awk '{ l=$0
      while (match(l,/<!--.*-->/)) { l=substr(l,1,RSTART-1) substr(l,RSTART+RLENGTH) }
      if (c) { if (match(l,/-->/)) { l=substr(l,RSTART+RLENGTH); c=0 } else next }
      if (match(l,/<!--/)) { l=substr(l,1,RSTART-1); c=1 }
      print l }' "$block" >> "$file"
    echo "updated $file"
  fi
}

case "$ADAPTER" in
  claude)
    cp "$SRC/adapters/claude-code/HEATWAVE.md" "$HW/HEATWAVE.md"
    mkdir -p "$TARGET/.claude/agents"
    for a in heatwave-planner heatwave-implementer heatwave-reviewer; do
      cp "$SRC/adapters/claude-code/.claude/agents/$a.md" "$TARGET/.claude/agents/$a.md"
    done
    append_once "$TARGET/CLAUDE.md" "$SRC/adapters/claude-code/HEATWAVE.md"
    ;;
  codex)
    append_once "$TARGET/AGENTS.md" "$SRC/adapters/codex/AGENTS.md"
    ;;
  gemini)
    append_once "$TARGET/GEMINI.md" "$SRC/adapters/gemini/GEMINI.md"
    ;;
  cursor)
    mkdir -p "$TARGET/.cursor/rules"
    cp "$SRC/adapters/cursor/heatwave.mdc" "$TARGET/.cursor/rules/heatwave.mdc"
    echo "installed .cursor/rules/heatwave.mdc"
    ;;
  generic)
    echo "generic adapter: point your tool's standing instructions at .heatwave/HEATWAVE-AGENT.md"
    ;;
esac

echo "Heatwave installed into $TARGET (.heatwave/, adapter: $ADAPTER)"
