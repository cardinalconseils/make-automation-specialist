#!/bin/bash
# scripts/smoke-test.sh — Plugin structure validation
# Run standalone (no Claude Code needed). Exit 0 = all pass, Exit 1 = failures.

set -uo pipefail
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

fail() { echo "  ❌ $1"; FAIL=1; }
pass() { echo "  ✅ $1"; }

# shellcheck source=scripts/smoke-test-checks.sh
source "$(dirname "$0")/smoke-test-checks.sh"

check_manifest
check_commands
check_agents
check_skills
check_hooks
check_agent_registration
check_output_dirs
check_json_files

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  ✅ All smoke tests passed"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  ❌ Smoke tests failed — see above"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi
