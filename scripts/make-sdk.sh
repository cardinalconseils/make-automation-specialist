#!/usr/bin/env bash
# Make Apps SDK CLI — pull/push custom apps over the /api/v2/sdk/apps REST API.
# Zed-native replacement for the VS Code "Make Apps Editor" extension, which
# cannot run in Zed. See scripts/make-sdk-lib.sh for the pull/push loops.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./make-sdk-lib.sh
. "$ROOT/scripts/make-sdk-lib.sh"

usage() {
  cat <<'EOF'
Usage: scripts/make-sdk.sh <command> [args]

  apps                        List your Make custom apps.
  pull <app> <version>        Download an app into .make/apps/<app>/.
  push <app> <version> [-n]   Upload changed sections. -n / --dry-run to preview.
  help                        Show this message.

Environment (from .env.local or .env at repo root, or the shell):
  MAKE_API_KEY   Required. Needs the sdk-apps:read and sdk-apps:write scopes.
  MAKE_ZONE      Optional. Defaults to eu1. Use us1/us2 for US-zone accounts.
EOF
}

load_env() {
  # .env.local wins over .env — both are gitignored; .env.example never is.
  for f in "$ROOT/.env" "$ROOT/.env.local"; do
    [ -f "$f" ] || continue
    set -a
    # shellcheck disable=SC1090
    . "$f"
    set +a
  done
  MAKE_ZONE="${MAKE_ZONE:-eu1}"
  BASE_URL="https://${MAKE_ZONE}.make.com/api/v2"
  command -v curl >/dev/null || die "curl is required but not installed."
  command -v jq >/dev/null || die "jq is required but not installed. Try: brew install jq"
  [ -n "${MAKE_API_KEY:-}" ] || die \
    "MAKE_API_KEY is not set. Copy .env.example to .env.local and add your Make API token."
}

main() {
  case "${1:-help}" in
    apps)
      load_env; cmd_apps ;;
    pull)
      [ $# -ge 3 ] || die "Usage: make-sdk.sh pull <app> <version>"
      load_env; cmd_pull "$2" "$3" ;;
    push)
      [ $# -ge 3 ] || die "Usage: make-sdk.sh push <app> <version> [--dry-run]"
      load_env
      case "${4:-}" in -n|--dry-run) DRY_RUN=1 ;; "") DRY_RUN=0 ;; *) die "Unknown flag: $4" ;; esac
      cmd_push "$2" "$3" ;;
    help|-h|--help)
      usage ;;
    *)
      usage; die "Unknown command: $1" ;;
  esac
}

main "$@"
