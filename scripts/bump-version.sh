#!/usr/bin/env bash
# bump-version.sh — automated semantic version bump for make-automation-specialist
#
# Usage:
#   ./scripts/bump-version.sh                        # auto-detect bump from conventional commits
#   ./scripts/bump-version.sh patch|minor|major      # force bump type
#   ./scripts/bump-version.sh --dry-run              # preview, no changes
#   ./scripts/bump-version.sh --no-changelog         # skip CHANGELOG.md (used by pre-commit hook)
#   ./scripts/bump-version.sh --no-tag               # skip git tag (used by pre-commit hook)
#
# Conventional commit bump rules (auto mode):
#   feat!: / BREAKING CHANGE → major
#   feat:                    → minor
#   fix: / chore: / other    → patch
#
# Pre-commit hook uses: bump-version.sh --no-changelog --no-tag
# Ship flow uses:       bump-version.sh (full — changelog + tag)

set -euo pipefail

PLUGIN_JSON="plugin.json"
CHANGELOG="CHANGELOG.md"
DRY_RUN=false
NO_CHANGELOG=false
NO_TAG=false
EXPLICIT_BUMP=""

for arg in "$@"; do
  case "$arg" in
    --dry-run)      DRY_RUN=true ;;
    --no-changelog) NO_CHANGELOG=true ;;
    --no-tag)       NO_TAG=true ;;
    patch|minor|major) EXPLICIT_BUMP="$arg" ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

# Resolve repo root so the script works from any directory
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
PLUGIN_JSON="${REPO_ROOT}/${PLUGIN_JSON}"
CHANGELOG="${REPO_ROOT}/${CHANGELOG}"

if ! command -v node &>/dev/null; then
  echo "Error: node is required" >&2; exit 1
fi

CURRENT=$(node -p "require('${PLUGIN_JSON}').version" 2>/dev/null)
[ -z "$CURRENT" ] && { echo "Error: could not read version from plugin.json" >&2; exit 1; }

# Commits since last tag (or all if no tags)
LAST_TAG=$(git -C "$REPO_ROOT" describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$LAST_TAG" ]; then
  COMMITS=$(git -C "$REPO_ROOT" log --pretty=format:"%s" 2>/dev/null || echo "")
else
  COMMITS=$(git -C "$REPO_ROOT" log "${LAST_TAG}..HEAD" --pretty=format:"%s" 2>/dev/null || echo "")
fi

# In pre-commit context, also include the message of the commit being made
# (passed via COMMIT_MSG_FILE env var if set by the hook)
if [ -n "${COMMIT_MSG_FILE:-}" ] && [ -f "$COMMIT_MSG_FILE" ]; then
  INCOMING=$(cat "$COMMIT_MSG_FILE" | head -1)
  COMMITS=$(printf "%s\n%s" "$INCOMING" "$COMMITS")
fi

if [ -z "$COMMITS" ] && [ -z "$EXPLICIT_BUMP" ]; then
  echo "No commits since last tag (${LAST_TAG:-none}). Nothing to bump."
  exit 0
fi

# Determine bump type
if [ -n "$EXPLICIT_BUMP" ]; then
  BUMP="$EXPLICIT_BUMP"
else
  if echo "$COMMITS" | grep -qiE "^(feat!|BREAKING CHANGE)"; then
    BUMP="major"
  elif echo "$COMMITS" | grep -qE "^feat(\([^)]+\))?(\!)?:"; then
    BUMP="minor"
  else
    BUMP="patch"
  fi
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"
case "$BUMP" in
  major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR+1)); PATCH=0 ;;
  patch) PATCH=$((PATCH+1)) ;;
esac
NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
DATE=$(date +%Y-%m-%d)

echo "Bump: ${CURRENT} → ${NEW_VERSION} (${BUMP})"
$NO_CHANGELOG && echo "Changelog: skipped"
$NO_TAG       && echo "Tag: skipped"

if $DRY_RUN; then
  echo "-- DRY RUN — no changes made --"
  exit 0
fi

# Update plugin.json
node -e "
  const fs = require('fs');
  const pkg = JSON.parse(fs.readFileSync('${PLUGIN_JSON}', 'utf8'));
  pkg.version = '${NEW_VERSION}';
  fs.writeFileSync('${PLUGIN_JSON}', JSON.stringify(pkg, null, 2) + '\n');
"
git -C "$REPO_ROOT" add plugin.json

# Update CHANGELOG.md
if ! $NO_CHANGELOG; then
  BREAKS=$(echo "$COMMITS" | grep -iE  "^(feat!|BREAKING CHANGE)" || true)
  FEATS=$(echo  "$COMMITS" | grep -E   "^feat(\([^)]+\))?:"  | sed -E "s/^feat(\([^)]+\))?: //"  || true)
  FIXES=$(echo  "$COMMITS" | grep -E   "^fix(\([^)]+\))?:"   | sed -E "s/^fix(\([^)]+\))?: //"   || true)
  CHORES=$(echo "$COMMITS" | grep -E   "^chore(\([^)]+\))?:" | sed -E "s/^chore(\([^)]+\))?: //" || true)
  OTHERS=$(echo "$COMMITS" | grep -vE  "^(feat|fix|chore|BREAKING CHANGE)(\([^)]+\))?[!:]?" || true)

  ENTRY="## [${NEW_VERSION}] — ${DATE}\n\n"
  [ -n "$BREAKS" ] && ENTRY+="### Breaking Changes\n$(echo "$BREAKS" | sed 's/^/- /')\n\n"
  [ -n "$FEATS"  ] && ENTRY+="### Features\n$(echo  "$FEATS"  | sed 's/^/- /')\n\n"
  [ -n "$FIXES"  ] && ENTRY+="### Fixes\n$(echo    "$FIXES"   | sed 's/^/- /')\n\n"
  [ -n "$CHORES" ] && ENTRY+="### Maintenance\n$(echo "$CHORES" | sed 's/^/- /')\n\n"
  [ -n "$OTHERS" ] && ENTRY+="### Other\n$(echo    "$OTHERS"  | sed 's/^/- /')\n\n"

  if [ -f "$CHANGELOG" ]; then
    HEADER=$(head -1 "$CHANGELOG")
    REST=$(tail -n +2 "$CHANGELOG")
    printf "%s\n\n%b%s" "$HEADER" "$ENTRY" "$REST" > "$CHANGELOG"
  else
    printf "# Changelog\n\n%b" "$ENTRY" > "$CHANGELOG"
  fi
  git -C "$REPO_ROOT" add CHANGELOG.md
  echo "Updated: CHANGELOG.md"
fi

# Create git tag
if ! $NO_TAG; then
  git -C "$REPO_ROOT" tag "v${NEW_VERSION}" -m "release v${NEW_VERSION}"
  echo "Tagged:  v${NEW_VERSION}"
fi

echo "Updated: plugin.json → ${NEW_VERSION}"
