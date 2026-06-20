#!/usr/bin/env bash
# bump-version.sh — semantic version bump for make-automation-specialist
#
# Usage:
#   ./scripts/bump-version.sh                  # auto-detect from conventional commits
#   ./scripts/bump-version.sh patch|minor|major # force bump type
#   ./scripts/bump-version.sh --dry-run         # preview, no changes
#
# Conventional commit bump rules:
#   feat!: / BREAKING CHANGE → major
#   feat:                    → minor
#   fix: / chore: / other    → patch
#
# Always updates both plugin.json and .claude-plugin/plugin.json.

set -euo pipefail

# shellcheck source=scripts/bump-version-lib.sh
source "$(dirname "$0")/bump-version-lib.sh"

DRY_RUN=false
EXPLICIT_BUMP=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    patch|minor|major) EXPLICIT_BUMP="$arg" ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
PLUGIN_JSON="${REPO_ROOT}/plugin.json"
PLUGIN_META="${REPO_ROOT}/.claude-plugin/plugin.json"
CHANGELOG="${REPO_ROOT}/CHANGELOG.md"

if ! command -v node &>/dev/null; then
  echo "Error: node is required" >&2; exit 1
fi

CURRENT=$(node -p "require('${PLUGIN_JSON}').version" 2>/dev/null)
[ -z "$CURRENT" ] && { echo "Error: could not read version from plugin.json" >&2; exit 1; }

COMMITS=$(gather_commits "$REPO_ROOT" | filter_release_commits)

if [ -z "$COMMITS" ] && [ -z "$EXPLICIT_BUMP" ]; then
  LAST_TAG=$(git -C "$REPO_ROOT" describe --tags --abbrev=0 2>/dev/null || echo "initial")
  echo "No new commits since ${LAST_TAG}. Nothing to bump."
  exit 0
fi

if [ -n "$EXPLICIT_BUMP" ]; then
  BUMP="$EXPLICIT_BUMP"
else
  BUMP=$(detect_bump_type "$COMMITS")
fi

NEW_VERSION=$(compute_next_version "$CURRENT" "$BUMP")
DATE=$(date +%Y-%m-%d)

echo "Bump: ${CURRENT} → ${NEW_VERSION} (${BUMP})"

if $DRY_RUN; then
  echo "-- DRY RUN — no changes made --"
  exit 0
fi

update_plugin_json "$PLUGIN_JSON" "$NEW_VERSION"
update_plugin_json "$PLUGIN_META" "$NEW_VERSION"
update_changelog "$CHANGELOG" "$NEW_VERSION" "$DATE" "$COMMITS"

git -C "$REPO_ROOT" tag "v${NEW_VERSION}" -m "release v${NEW_VERSION}"
git -C "$REPO_ROOT" add plugin.json .claude-plugin/plugin.json CHANGELOG.md

echo "Updated: plugin.json + .claude-plugin/plugin.json → ${NEW_VERSION}"
echo "Updated: CHANGELOG.md"
echo "Tagged:  v${NEW_VERSION}"

print_post_release_checklist
