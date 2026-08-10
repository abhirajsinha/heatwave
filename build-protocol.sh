#!/bin/sh
# build-protocol.sh — PROTOCOL.md is GENERATED from the canonical protocol/ shards (R-108).
# Usage: sh build-protocol.sh          regenerate PROTOCOL.md
#        sh build-protocol.sh --check  exit 1 if PROTOCOL.md drifts from the shards
set -eu
cd "$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
ORDER="core planner implementer reviewer fixer final-reviewer orchestrator history"
OUT=PROTOCOL.md
TMP=$OUT.build.$$
trap 'rm -f "$TMP"' EXIT
{
  printf '<!-- GENERATED FILE — do not edit. Canonical source: protocol/*.md. Rebuild: sh build-protocol.sh -->\n\n'
  first=1
  for s in $ORDER; do
    [ -f "protocol/$s.md" ] || { echo "error: missing shard protocol/$s.md" >&2; exit 1; }
    [ "$first" = 1 ] || printf '\n---\n\n'
    first=0
    cat "protocol/$s.md"
  done
} > "$TMP"
if [ "${1:-}" = "--check" ]; then
  if cmp -s "$TMP" "$OUT"; then echo "OK: PROTOCOL.md matches protocol/ shards"; exit 0; fi
  echo "DRIFT: PROTOCOL.md differs from protocol/ shards — run: sh build-protocol.sh" >&2; exit 1
fi
mv "$TMP" "$OUT"; trap - EXIT
echo "generated $OUT from protocol/ shards"
