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

# Commits since last tag (or all if no tags exist yet)
LAST_TAG=$(git -C "$REPO_ROOT" describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$LAST_TAG" ]; then
  COMMITS=$(git -C "$REPO_ROOT" log --pretty=format:"%s" 2>/dev/null || echo "")
else
  COMMITS=$(git -C "$REPO_ROOT" log "${LAST_TAG}..HEAD" --pretty=format:"%s" 2>/dev/null || echo "")
fi

# Filter out release commits — they don't contribute to the next bump
COMMITS=$(echo "$COMMITS" | grep -vE "^chore: release v" || true)

if [ -z "$COMMITS" ] && [ -z "$EXPLICIT_BUMP" ]; then
  echo "No new commits since ${LAST_TAG:-initial}. Nothing to bump."
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

if $DRY_RUN; then
  echo "-- DRY RUN — no changes made --"
  exit 0
fi

# Update plugin.json (root — source of truth for build)
node -e "
  const fs = require('fs');
  const pkg = JSON.parse(fs.readFileSync('${PLUGIN_JSON}', 'utf8'));
  pkg.version = '${NEW_VERSION}';
  fs.writeFileSync('${PLUGIN_JSON}', JSON.stringify(pkg, null, 2) + '\n');
"

# Update .claude-plugin/plugin.json (read by Claude Code for install/update checks)
node -e "
  const fs = require('fs');
  const pkg = JSON.parse(fs.readFileSync('${PLUGIN_META}', 'utf8'));
  pkg.version = '${NEW_VERSION}';
  fs.writeFileSync('${PLUGIN_META}', JSON.stringify(pkg, null, 2) + '\n');
"

# Update CHANGELOG.md
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

# Create git tag
git -C "$REPO_ROOT" tag "v${NEW_VERSION}" -m "release v${NEW_VERSION}"

git -C "$REPO_ROOT" add plugin.json .claude-plugin/plugin.json CHANGELOG.md
echo "Updated: plugin.json + .claude-plugin/plugin.json → ${NEW_VERSION}"
echo "Updated: CHANGELOG.md"
echo "Tagged:  v${NEW_VERSION}"
echo ""
echo "── Post-release checklist ──────────────────────────────────────"
echo "  1. git commit + push + open PR (handled by /cks:ship)"
echo "  2. Project installs: claude plugin update make-automation-specialist"
echo "  3. In-project verification: /make:migrate  ← reads this CHANGELOG"
echo "────────────────────────────────────────────────────────────────"
