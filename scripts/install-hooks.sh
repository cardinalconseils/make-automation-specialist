#!/usr/bin/env bash
# install-hooks.sh — symlinks scripts/hooks/ into .git/hooks/
# Run once after cloning: ./scripts/install-hooks.sh

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
HOOKS_SRC="${REPO_ROOT}/scripts/hooks"
HOOKS_DST="${REPO_ROOT}/.git/hooks"

for hook in "$HOOKS_SRC"/*; do
  name=$(basename "$hook")
  target="${HOOKS_DST}/${name}"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Skipped $name — existing non-symlink hook found at ${target}"
    continue
  fi

  chmod +x "$hook"
  ln -sf "$hook" "$target"
  echo "Installed: .git/hooks/${name} → scripts/hooks/${name}"
done

echo "Done. Git hooks installed. Run /cks:ship to bump version and release."
