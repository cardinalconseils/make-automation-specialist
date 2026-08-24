#!/usr/bin/env bash
# test-review-gate.sh — behavioural test for the deterministic write gates.
#
# The gates are the only thing standing between an agent and an unreviewed scenario
# write, so they get a real test rather than a structure check. Runs in a temp dir;
# touches nothing real. Exit 0 = all pass.

set -uo pipefail
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$PLUGIN_ROOT/scripts/pre-execute-hook.js"
PUSH="$PLUGIN_ROOT/scripts/pre-push-guard.js"
SENT="$PLUGIN_ROOT/scripts/blueprint-sentinel.js"

PASS=0; FAIL=0
chk() { # chk <name> <actual> <expected>
  if [ "$2" = "$3" ]; then echo "  ✅ $1"; PASS=$((PASS+1));
  else echo "  ❌ $1 (exit $2, expected $3)"; FAIL=$((FAIL+1)); fi
}
run()  { echo "$1" | node "$HOOK" >/dev/null 2>&1; echo $?; }
runp() { echo "$1" | node "$PUSH" >/dev/null 2>&1; echo $?; }

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT; cd "$TMP" || exit 1
mkdir -p .make/logs
echo '{"name":"t","flow":[{"id":1}]}' > bp.json
BP='{"tool_name":"mcp__claude_ai_Make__scenarios_create","tool_input":{"blueprint":{"name":"t","flow":[{"id":1}]}}}'

echo "▸ Review gate — scenario writes"
chk "unreviewed create blocked"        "$(run "$BP")" 2
node "$SENT" bp.json "PUSH" t >/dev/null
chk "reviewed create allowed"          "$(run "$BP")" 0
chk "key-order shuffle still matches"  "$(run '{"tool_name":"mcp__claude_ai_Make__scenarios_create","tool_input":{"blueprint":{"flow":[{"id":1}],"name":"t"}}}')" 0
chk "mutated blueprint blocked"        "$(run '{"tool_name":"mcp__claude_ai_Make__scenarios_create","tool_input":{"blueprint":{"name":"t","flow":[{"id":2}]}}}')" 2
chk "scenarios_update also gated"      "$(run '{"tool_name":"mcp__claude_ai_Make__scenarios_update","tool_input":{"blueprint":{"name":"x"}}}')" 2
node "$SENT" bp.json "FIX FIRST" t >/dev/null
chk "FIX FIRST verdict blocked"        "$(run "$BP")" 2
rm -f .make/logs/.blueprint-reviewed && touch .make/logs/.blueprint-reviewed
chk "legacy touch sentinel rejected"   "$(run "$BP")" 2

echo "▸ Pre-existing gates unregressed"
chk "delete without token blocked"     "$(run '{"tool_name":"mcp__claude_ai_Make__scenarios_delete","tool_input":{}}')" 2
chk "read call allowed"                "$(run '{"tool_name":"mcp__claude_ai_Make__data-stores_list","tool_input":{}}')" 0
chk "non-scenario write ungated"       "$(run '{"tool_name":"mcp__claude_ai_Make__data-stores_create","tool_input":{}}')" 0
mkdir -p .make/factory && echo '{"status":"design"}' > .make/factory/current-session.json
chk "factory phase gate blocks"        "$(run "$BP")" 2
rm -rf .make/factory

echo "▸ Push guard — curl path"
rm -f .make/logs/.blueprint-reviewed
chk "curl PUT without plan blocked"    "$(runp '{"tool_name":"Bash","tool_input":{"command":"curl -X PUT https://eu2.make.com/api/v2/scenarios/1"}}')" 2
chk "unrelated bash allowed"           "$(runp '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}')" 0
mkdir -p .make/plans && echo x > .make/plans/p.md
node "$SENT" bp.json "PUSH" t >/dev/null
chk "curl PUT with plan+review ok"     "$(runp '{"tool_name":"Bash","tool_input":{"command":"curl -X PUT https://eu2.make.com/api/v2/scenarios/1"}}')" 0

echo ""
if [ "$FAIL" -eq 0 ]; then echo "  ✅ Review gate: $PASS/$PASS passed"; exit 0
else echo "  ❌ Review gate: $FAIL of $((PASS+FAIL)) failed"; exit 1; fi
