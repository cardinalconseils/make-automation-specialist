#!/usr/bin/env bash
# Offline self-check for make-sdk-lib.sh push logic. No network, no credentials.
# Asserts push skips unchanged sections and builds the right URL for changed ones.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$ROOT/scripts/make-sdk-lib.sh"

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
ROOT="$TMP"; MAKE_ZONE=eu1; BASE_URL="https://eu1.make.com/api/v2"; CALLS=""
api() { CALLS="$CALLS$1 $2"$'\n'; API_CODE=200; API_BODY='{}'; }   # stub out the network

app="$TMP/.make/apps/demo"
mkdir -p "$app/modules/getThing" "$app/.orig/modules/getThing" "$app/general" "$app/.orig/general"
for f in api parameters; do
  echo "{\"x\":1}" > "$app/modules/getThing/$f.imljson"
  cp "$app/modules/getThing/$f.imljson" "$app/.orig/modules/getThing/$f.imljson"
done
echo '{"b":1}' > "$app/general/base.imljson"; cp "$app/general/base.imljson" "$app/.orig/general/base.imljson"

# 1. Nothing changed -> no requests.
DRY_RUN=0; CALLS=""; cmd_push demo 1 >/dev/null
[ -z "$CALLS" ] || { echo "FAIL: pushed with no local changes: $CALLS"; exit 1; }

# 2. One changed section -> exactly one PUT, section suffix stripped from the URL.
echo '{"x":2}' > "$app/modules/getThing/parameters.imljson"
DRY_RUN=0; CALLS=""; cmd_push demo 1 >/dev/null
[ "$CALLS" = "PUT /sdk/apps/demo/1/modules/getThing/parameters"$'\n' ] \
  || { echo "FAIL: wrong push calls: $CALLS"; exit 1; }

# 3. Base uses PATCH, not PUT.
echo '{"b":2}' > "$app/general/base.imljson"
DRY_RUN=0; CALLS=""; cmd_push demo 1 >/dev/null
[ "$CALLS" = "PATCH /sdk/apps/demo/1/base"$'\n' ] \
  || { echo "FAIL: base should PATCH: $CALLS"; exit 1; }

# 4. --dry-run sends nothing.
echo '{"x":3}' > "$app/modules/getThing/api.imljson"
DRY_RUN=1; CALLS=""; cmd_push demo 1 >/dev/null
[ -z "$CALLS" ] || { echo "FAIL: dry-run hit the API: $CALLS"; exit 1; }

echo "✅ make-sdk push logic OK (4 checks)"
