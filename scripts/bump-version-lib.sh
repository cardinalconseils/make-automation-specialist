#!/usr/bin/env bash
# bump-version-lib.sh — helper functions for bump-version.sh
# Sourced by bump-version.sh — do not run directly.

gather_commits() {
  local repo_root="$1"
  local last_tag
  last_tag=$(git -C "$repo_root" describe --tags --abbrev=0 2>/dev/null || echo "")
  if [ -z "$last_tag" ]; then
    git -C "$repo_root" log --pretty=format:"%s" 2>/dev/null || echo ""
  else
    git -C "$repo_root" log "${last_tag}..HEAD" --pretty=format:"%s" 2>/dev/null || echo ""
  fi
}

filter_release_commits() {
  grep -vE "^chore: release v" || true
}

detect_bump_type() {
  local commits="$1"
  if echo "$commits" | grep -qiE "^(feat!|BREAKING CHANGE)"; then
    echo "major"
  elif echo "$commits" | grep -qE "^feat(\([^)]+\))?(\!)?:"; then
    echo "minor"
  else
    echo "patch"
  fi
}

compute_next_version() {
  local current="$1"
  local bump="$2"
  local major minor patch
  IFS='.' read -r major minor patch <<< "$current"
  case "$bump" in
    major) major=$((major+1)); minor=0; patch=0 ;;
    minor) minor=$((minor+1)); patch=0 ;;
    patch) patch=$((patch+1)) ;;
  esac
  echo "${major}.${minor}.${patch}"
}

update_plugin_json() {
  local file="$1"
  local new_version="$2"
  node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('${file}', 'utf8'));
    pkg.version = '${new_version}';
    fs.writeFileSync('${file}', JSON.stringify(pkg, null, 2) + '\n');
  "
}

update_changelog() {
  local changelog="$1"
  local new_version="$2"
  local date="$3"
  local commits="$4"

  local breaks feats fixes chores others entry
  breaks=$(echo "$commits" | grep -iE  "^(feat!|BREAKING CHANGE)" || true)
  feats=$(echo  "$commits" | grep -E   "^feat(\([^)]+\))?:"  | sed -E "s/^feat(\([^)]+\))?: //"  || true)
  fixes=$(echo  "$commits" | grep -E   "^fix(\([^)]+\))?:"   | sed -E "s/^fix(\([^)]+\))?: //"   || true)
  chores=$(echo "$commits" | grep -E   "^chore(\([^)]+\))?:" | sed -E "s/^chore(\([^)]+\))?: //" || true)
  others=$(echo "$commits" | grep -vE  "^(feat|fix|chore|BREAKING CHANGE)(\([^)]+\))?[!:]?" || true)

  entry="## [${new_version}] — ${date}\n\n"
  [ -n "$breaks" ] && entry+="### Breaking Changes\n$(echo "$breaks" | sed 's/^/- /')\n\n"
  [ -n "$feats"  ] && entry+="### Features\n$(echo  "$feats"  | sed 's/^/- /')\n\n"
  [ -n "$fixes"  ] && entry+="### Fixes\n$(echo    "$fixes"   | sed 's/^/- /')\n\n"
  [ -n "$chores" ] && entry+="### Maintenance\n$(echo "$chores" | sed 's/^/- /')\n\n"
  [ -n "$others" ] && entry+="### Other\n$(echo    "$others"  | sed 's/^/- /')\n\n"

  if [ -f "$changelog" ]; then
    local header rest
    header=$(head -1 "$changelog")
    rest=$(tail -n +2 "$changelog")
    printf "%s\n\n%b%s" "$header" "$entry" "$rest" > "$changelog"
  else
    printf "# Changelog\n\n%b" "$entry" > "$changelog"
  fi
}

print_post_release_checklist() {
  echo ""
  echo "── Post-release checklist ──────────────────────────────────────"
  echo "  1. git commit + push + open PR (handled by /cks:ship)"
  echo "  2. Project installs: claude plugin update make-automation-specialist"
  echo "  3. In-project verification: /make:migrate  ← reads this CHANGELOG"
  echo "────────────────────────────────────────────────────────────────"
}
