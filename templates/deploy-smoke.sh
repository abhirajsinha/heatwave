#!/bin/sh
# deploy-smoke.sh — generic post-deploy verification primitive (R-137, Heatwave v5).
# Contract: after a deploy, confirm HEALTH + VERSION + SCHEMA/MIGRATION status + ONE real request.
# Generic across hosts — the PROJECT supplies host/endpoints via env; no Railway/Vaani specifics here.
# Zero dependencies beyond curl (runtime-probed, fail-closed per R-64). POSIX sh + curl only.
#
# Env (project-supplied):
#   HEALTH_URL   (required)  URL expected to return HTTP 200 — liveness.
#   REQUEST_URL  (required)  one real end-to-end request expected to return HTTP 200.
#   VERSION_URL  (optional)  URL expected to return HTTP 200; its body is the deployed version.
#   SCHEMA_CMD   (required)  a command that EXITS 0 when migrations are applied/current
#                            (e.g. "prisma migrate status", "alembic current | grep -q head").
#   CURL_TIMEOUT (optional)  per-request timeout seconds (default 10).
#
# Exit: 0 = GREEN (deploy healthy), 1 = RED (a leg failed — Blocker per R-137), 3 = NOT AVAILABLE (R-64).
set -eu

if ! command -v curl >/dev/null 2>&1; then
  echo "NOT AVAILABLE deploy-smoke: curl is not on PATH — cannot verify the deploy (R-64)" >&2
  exit 3
fi
: "${HEALTH_URL:?set HEALTH_URL}" "${REQUEST_URL:?set REQUEST_URL}" "${SCHEMA_CMD:?set SCHEMA_CMD}"
TIMEOUT=${CURL_TIMEOUT:-10}

# http_ok <url> -> prints the status code; returns 0 iff 200.
http_ok() {
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time "$TIMEOUT" "$1" 2>/dev/null) || true
  [ -n "$code" ] || code=000
  echo "$code"
  [ "$code" = "200" ]
}

rc=0

code=$(http_ok "$HEALTH_URL") && echo "GREEN health:  $HEALTH_URL -> $code" \
  || { echo "RED health:  $HEALTH_URL -> $code"; rc=1; }

if [ -n "${VERSION_URL:-}" ]; then
  code=$(http_ok "$VERSION_URL") && echo "GREEN version: $VERSION_URL -> $code ($(curl -s --max-time "$TIMEOUT" "$VERSION_URL" 2>/dev/null | head -1))" \
    || { echo "RED version: $VERSION_URL -> $code"; rc=1; }
fi

if sh -c "$SCHEMA_CMD" >/dev/null 2>&1; then
  echo "GREEN schema:  '$SCHEMA_CMD' -> migrations current"
else
  echo "RED schema:  '$SCHEMA_CMD' -> non-zero exit (migrations NOT current)"; rc=1
fi

code=$(http_ok "$REQUEST_URL") && echo "GREEN request: $REQUEST_URL -> $code" \
  || { echo "RED request: $REQUEST_URL -> $code"; rc=1; }

if [ "$rc" -eq 0 ]; then
  echo "GREEN deploy-smoke: health + version + schema + one real request all passed"
else
  echo "RED deploy-smoke: a required leg failed — deploy is NOT verified (Blocker, R-137)"
fi
exit $rc
