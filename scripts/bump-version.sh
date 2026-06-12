#!/usr/bin/env bash
# bump-version.sh — automated semantic version bump for make-automation-specialist
#
# Usage:
#   ./scripts/bump-version.sh           # auto-detect from conventional commits
#   ./scripts/bump-version.sh patch     # force patch bump
#   ./scripts/bump-version.sh minor     # force minor bump
#   ./scripts/bump-version.sh major     # force major bump
#   ./scripts/bump-version.sh --dry-run # preview only, no changes
#
# Conventional commit rules (auto mode):
#   feat!: or BREAKING CHANGE → major
#   feat:                     → minor
#   fix: / chore: / anything  → patch

set -euo pipefail

PLUGIN_JSON="plugin.json"
CHANGELOG="CHANGELOG.md"
DRY_RUN=false
EXPLICIT_BUMP=""

# Parse args
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    patch|minor|major) EXPLICIT_BUMP="$arg" ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

# Read current version from plugin.json
if ! command -v node &>/dev/null; then
  echo "Error: node is required to parse plugin.json" >&2; exit 1
fi
CURRENT=$(node -p "require('./${PLUGIN_JSON}').version" 2>/dev/null)
if [ -z "$CURRENT" ]; then
  echo "Error: could not read version from ${PLUGIN_JSON}" >&2; exit 1
fi

# Get commits since last tag (or all commits if no tags exist)
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$LAST_TAG" ]; then
  COMMITS=$(git log --pretty=format:"%s" 2>/dev/null || echo "")
else
  COMMITS=$(git log "${LAST_TAG}..HEAD" --pretty=format:"%s" 2>/dev/null || echo "")
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

# Calculate new version
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"
case "$BUMP" in
  major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR+1)); PATCH=0 ;;
  patch) PATCH=$((PATCH+1)) ;;
esac
NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
DATE=$(date +%Y-%m-%d)

echo "Bump type:  ${BUMP}"
echo "Version:    ${CURRENT} → ${NEW_VERSION}"
echo "Tag:        v${NEW_VERSION}"

if $DRY_RUN; then
  echo ""
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

# Build changelog entry from categorized conventional commits
BREAKS=$(echo "$COMMITS" | grep -iE "^(feat!|BREAKING CHANGE)" || true)
FEATS=$(echo  "$COMMITS" | grep -E "^feat(\([^)]+\))?:" | sed -E "s/^feat(\([^)]+\))?: //" || true)
FIXES=$(echo  "$COMMITS" | grep -E "^fix(\([^)]+\))?:"  | sed -E "s/^fix(\([^)]+\))?: //"  || true)
CHORES=$(echo "$COMMITS" | grep -E "^chore(\([^)]+\))?:" | sed -E "s/^chore(\([^)]+\))?: /" || true)
OTHERS=$(echo "$COMMITS" | grep -vE "^(feat|fix|chore|BREAKING CHANGE)(\([^)]+\))?[!:]?" || true)

ENTRY="## [${NEW_VERSION}] — ${DATE}\n\n"
[ -n "$BREAKS" ] && ENTRY+="### Breaking Changes\n$(echo "$BREAKS" | sed 's/^/- /')\n\n"
[ -n "$FEATS"  ] && ENTRY+="### Features\n$(echo "$FEATS"  | sed 's/^/- /')\n\n"
[ -n "$FIXES"  ] && ENTRY+="### Fixes\n$(echo "$FIXES"    | sed 's/^/- /')\n\n"
[ -n "$CHORES" ] && ENTRY+="### Maintenance\n$(echo "$CHORES" | sed 's/^/- /')\n\n"
[ -n "$OTHERS" ] && ENTRY+="### Other\n$(echo "$OTHERS"   | sed 's/^/- /')\n\n"

# Write CHANGELOG.md — prepend new entry after the header line
if [ -f "$CHANGELOG" ]; then
  HEADER=$(head -1 "$CHANGELOG")
  REST=$(tail -n +2 "$CHANGELOG")
  printf "%s\n\n%b%s" "$HEADER" "$ENTRY" "$REST" > "$CHANGELOG"
else
  printf "# Changelog\n\n%b" "$ENTRY" > "$CHANGELOG"
fi

# Create git tag
git tag "v${NEW_VERSION}" -m "release v${NEW_VERSION}"

echo ""
echo "Updated:  ${PLUGIN_JSON}"
echo "Updated:  ${CHANGELOG}"
echo "Tagged:   v${NEW_VERSION}"
echo ""
echo "Stage and commit with:"
echo "  git add ${PLUGIN_JSON} ${CHANGELOG}"
echo "  git commit -m \"chore: release v${NEW_VERSION}\""
echo "  git push && git push --tags"
