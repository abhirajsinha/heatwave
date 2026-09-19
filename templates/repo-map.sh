#!/bin/sh
# repo-map.sh — deterministic, LLM-free per-repo map (R-146, v5.1; relationship sections v5-retrieval).
# POSIX sh + git + grep/awk/sed + shasum. NO model is ever invoked. Paths and counts only —
# never a file-body excerpt (R-131 discipline).
#
# Usage: sh repo-map.sh [repo-root]     # default: current directory's git toplevel
# Output: <repo>/.heatwave/cache/repo-map.md   (regenerated only when the cache key changes)
#
# Cache key = HEAD sha + a hash of the WORKING-TREE content of every tracked file
# (git ls-files -z | xargs -0 shasum). Hashing working-tree content — not the index — means an
# UNSTAGED content edit to a tracked file forces regeneration even without a HEAD move or git add
# (closes the stale-map window the index-only `git ls-files -s` key left open; plan-review F-004).
#
# v5-retrieval adds five best-effort relationship sections after Directory roles, each printing
# `NOT DETECTED — <what was sought>` when empty and never fabricating: module/dependency (import)
# graph, test<->source map, API/route files, schema/migration files, deploy/runtime config.
# All are grep/awk over `git ls-files` output — no new tools, cache key unchanged (R-146).
set -eu

ROOT=${1:-.}
cd "$ROOT"
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "repo-map: NOT AVAILABLE — not a git repository ($ROOT)" >&2
  exit 2
fi
TOP=$(git rev-parse --show-toplevel)
cd "$TOP"

CACHE="$TOP/.heatwave/cache/repo-map.md"

# ---- cache key -------------------------------------------------------------
head_sha=$(git rev-parse --verify HEAD 2>/dev/null || echo "no-head")   # --verify: unborn HEAD → clean single-line "no-head" (F-102), never "HEAD\nno-head"
content_hash=$(git ls-files -z | xargs -0 shasum 2>/dev/null | shasum | cut -d' ' -f1)
key="HEAD=$head_sha CONTENT=$content_hash"

# ---- cache hit? (header must parse AND match) ------------------------------
if [ -f "$CACHE" ]; then
  cached=$(sed -n 's/^<!-- repo-map cache key: \(.*\) -->$/\1/p' "$CACHE" | head -1)
  if [ -n "$cached" ] && [ "$cached" = "$key" ]; then
    echo "repo-map: cache hit ($CACHE)"
    exit 0
  fi
fi

# ---- regenerate ------------------------------------------------------------
mkdir -p "$(dirname "$CACHE")"
tstamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
tmp="$CACHE.build.$$"
trap 'rm -f "$tmp"' EXIT

# Manifests / build files present (paths only).
manifests=$(git ls-files \
  'package.json' '*/package.json' 'pyproject.toml' '*/pyproject.toml' \
  'setup.py' '*/setup.py' 'requirements*.txt' '*/requirements*.txt' 'pytest.ini' \
  'go.mod' '*/go.mod' 'Cargo.toml' '*/Cargo.toml' 'pom.xml' '*/pom.xml' \
  'build.gradle*' '*/build.gradle*' 'Gemfile' 'composer.json' \
  'Makefile' '*/Makefile' 'CMakeLists.txt' 2>/dev/null | sort -u || true)

# Entry points (common names; paths only).
entrypoints=$(git ls-files \
  'main.*' '*/main.*' 'index.*' '*/index.*' 'app.*' '*/app.*' \
  'cmd/*' 'bin/*' 'src/main.*' 2>/dev/null | sort -u | head -40 || true)

# Test commands — read from manifests/CI, never guessed. Best-effort per stack.
test_cmds=""
add_cmd() { test_cmds="$test_cmds$1
"; }
if git ls-files --error-unmatch package.json >/dev/null 2>&1; then
  tscript=$(sed -n 's/.*"test"[[:space:]]*:[[:space:]]*"\(.*\)".*/npm test -> \1/p' package.json | head -1 || true)
  [ -n "$tscript" ] && add_cmd "$tscript"
fi
{ git ls-files 'pytest.ini' 'pyproject.toml' 'setup.py' 'requirements*.txt' 2>/dev/null | grep -q . ; } && add_cmd "pytest (python project files present)"
git ls-files --error-unmatch go.mod >/dev/null 2>&1 && add_cmd "go test ./..."
git ls-files --error-unmatch Cargo.toml >/dev/null 2>&1 && add_cmd "cargo test"
{ git ls-files 'Makefile' '*/Makefile' 2>/dev/null | grep -q . ; } && \
  grep -hE '^test:' $(git ls-files 'Makefile' '*/Makefile' 2>/dev/null) >/dev/null 2>&1 && add_cmd "make test (Makefile 'test' target)"
ci=$(git ls-files '.github/workflows/*' '.gitlab-ci.yml' 2>/dev/null | sort -u || true)

# Directory roles: top-level tracked dirs + file counts.
dirroles=$(git ls-files | awk -F/ 'NF>1{print $1}' | sort | uniq -c | sort -rn \
  | awk '{printf "%s (%s files)\n", $2, $1}' || true)
toplevel_files=$(git ls-files | awk -F/ 'NF==1' | wc -l | tr -d ' ')

# ---- v5-retrieval relationship sections (best-effort, generic, NOT DETECTED when empty) ----

# Import/dependency edges: one line "<importer path> -> <imported token>". Language-generic import
# forms; token cleaned to module characters only (complement gsub — no literal quote needed). Capped.
srcglobs='*.py *.pyi *.js *.mjs *.cjs *.jsx *.ts *.tsx *.go *.rb *.rs *.java *.kt *.c *.cc *.cpp *.h *.hpp *.php *.swift *.scala'
import_graph=$(git ls-files $srcglobs 2>/dev/null | while IFS= read -r f; do
  [ -f "$f" ] || continue
  awk -v F="$f" '
    { line=$0 }
    line ~ /^[[:space:]]*from[[:space:]]+[A-Za-z0-9_.]+[[:space:]]+import/ { t=$2; gsub(/[^A-Za-z0-9_.@\/-]/,"",t); if(t!="") print F " -> " t; next }
    line ~ /^[[:space:]]*import[[:space:]]+/                             { t=$2; gsub(/[^A-Za-z0-9_.@\/-]/,"",t); if(t!="") print F " -> " t; next }
    line ~ /require\(/ { if (match(line,/require\([^)]*\)/)) { s=substr(line,RSTART,RLENGTH); gsub(/[^A-Za-z0-9_.@\/-]/,"",s); sub(/^require/,"",s); if(s!="") print F " -> " s } next }
    line ~ /^[[:space:]]*#[[:space:]]*include/ { t=$2; gsub(/[^A-Za-z0-9_.@\/-]/,"",t); if(t!="") print F " -> " t; next }
    line ~ /^[[:space:]]*use[[:space:]]+/       { t=$2; gsub(/[^A-Za-z0-9_.@\/-]/,"",t); if(t!="") print F " -> " t; next }
  ' "$f"
done | sort -u | head -400 || true)

# Test <-> source map: pair test files to a source by shared basename stem.
tests=$(git ls-files '*test_*' 'test_*' '*_test.*' '*.spec.*' '*.test.*' 2>/dev/null | sort -u || true)
allsrc=$(git ls-files $srcglobs 2>/dev/null | sort -u || true)
test_map=""
if [ -n "$tests" ]; then
  test_map=$(printf '%s\n' "$tests" | while IFS= read -r t; do
    [ -n "$t" ] || continue
    b=$(basename "$t")
    stem=$(printf '%s' "$b" | sed -E 's/\.[^.]+$//; s/^test_//; s/_test$//; s/\.spec$//; s/\.test$//; s/_spec$//')
    src=$(printf '%s\n' "$allsrc" | awk -v s="$stem" -v tf="$t" '
      { n=$0; sub(/.*\//,"",n); sub(/\.[^.]+$/,"",n) }
      n==s && $0!=tf { print; exit }')
    if [ -n "$src" ]; then printf '%s <-> %s\n' "$t" "$src"; else printf '%s <-> (no basename-matched source)\n' "$t"; fi
  done)
fi

# API/route, schema/migration, deploy/runtime — path/name pattern detection.
routes=$(git ls-files 'routes/*' '*/routes/*' 'controllers/*' '*/controllers/*' \
  '*/api/*' 'api/*' '*/handlers/*' 'handlers/*' 2>/dev/null | sort -u | head -80 || true)
schema=$(git ls-files 'migrations/*' '*/migrations/*' 'schema.*' '*/schema.*' \
  'prisma/schema.prisma' '*/prisma/schema.prisma' '*.sql' '*/*.sql' 2>/dev/null | sort -u | head -80 || true)
deploycfg=$(git ls-files 'Dockerfile' '*/Dockerfile' 'docker-compose*' '*/docker-compose*' \
  '*.railway.json' 'railway.json' 'Procfile' '*/Procfile' '.github/workflows/*' \
  'vercel.json' 'fly.toml' 'render.yaml' 2>/dev/null | sort -u | head -80 || true)

emit_or_none() {  # $1 = content, $2 = "sought" phrase
  if [ -n "$1" ]; then printf '%s\n' "$1"; else echo "NOT DETECTED — $2"; fi
}

{
  echo "<!-- repo-map cache key: $key -->"
  echo "<!-- GENERATED by repo-map.sh (R-146). LLM-free. Paths and counts only. Advisory (verify per R-131). -->"
  echo "# Repo map"
  echo
  echo "repo: $TOP"
  echo "generated: $tstamp"
  echo "head: $head_sha"
  echo
  echo "## Manifests"
  if [ -n "$manifests" ]; then printf '%s\n' "$manifests"; else echo "NOT AVAILABLE — no known manifest tracked"; fi
  echo
  echo "## Entry points"
  if [ -n "$entrypoints" ]; then printf '%s\n' "$entrypoints"; else echo "NOT AVAILABLE — no common entry-point filename tracked"; fi
  echo
  echo "## Test commands (from manifests/CI, advisory)"
  if [ -n "$test_cmds" ]; then printf '%s' "$test_cmds"; else echo "NOT AVAILABLE — no test command derivable from tracked manifests"; fi
  [ -n "$ci" ] && { echo "CI workflow files:"; printf '%s\n' "$ci"; }
  echo
  echo "## Directory roles"
  echo "(top-level, tracked file counts)"
  [ "$toplevel_files" -gt 0 ] && echo "<root> ($toplevel_files files)"
  if [ -n "$dirroles" ]; then printf '%s\n' "$dirroles"; else echo "NOT AVAILABLE — flat tree"; fi
  echo
  echo "## Module dependency graph (imports)"
  echo "(importer -> imported token; language-generic, capped 400)"
  emit_or_none "$import_graph" "no import/require/include/use forms in tracked source"
  echo
  echo "## Test <-> source map"
  echo "(test file <-> basename-matched source)"
  emit_or_none "$test_map" "no test files (test_*, *_test.*, *.spec.*, *.test.*) tracked"
  echo
  echo "## API / route files"
  emit_or_none "$routes" "no routes/ controllers/ api/ handlers/ paths tracked"
  echo
  echo "## Schema / migration files"
  emit_or_none "$schema" "no migrations/ schema.* prisma *.sql tracked"
  echo
  echo "## Deploy / runtime config"
  emit_or_none "$deploycfg" "no Dockerfile/compose/Procfile/CI/fly/vercel/render config tracked"
} > "$tmp"
mv "$tmp" "$CACHE"; trap - EXIT
echo "repo-map: generated $CACHE"
