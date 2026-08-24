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

echo "▸ Hook registration (a gate that never fires is not a gate)"
HJ="$PLUGIN_ROOT/hooks/hooks.json"
PJ="$PLUGIN_ROOT/plugin.json"
VALID=$(python3 -c "import json,sys;json.load(open(sys.argv[1]));print(0)" "$HJ" 2>/dev/null || echo 1)
chk "hooks/hooks.json exists and parses"        "$VALID" 0

# Every script a hook points at must exist, or the hook silently never runs.
CHECK_PATHS='import json,sys,os,re
bad=0
for arr in json.load(open(sys.argv[1]))["hooks"].values():
    for e in arr:
        for h in e["hooks"]:
            m=re.search(r"\$\{CLAUDE_PLUGIN_ROOT\}(/[^\"\s]+)",h["command"])
            if not m or not os.path.isfile(sys.argv[2]+m.group(1)): bad+=1
print(bad)'
RESOLVE=$(python3 -c "$CHECK_PATHS" "$HJ" "$PLUGIN_ROOT" 2>/dev/null || echo 1)
chk "every hook command resolves to a script"   "$RESOLVE" 0

# Every hook plugin.json declares must actually be registered. kickstart-plan-guard
# was declared but registered nowhere for four releases; this is how that gets caught.
CHECK_REG='import json,sys
reg=json.dumps(json.load(open(sys.argv[1])))
d=json.load(open(sys.argv[2]))
print(sum(1 for h in d.get("hooks",[]) if h.get("script") and h["script"].split("/")[-1] not in reg))'
UNREG=$(python3 -c "$CHECK_REG" "$HJ" "$PJ" 2>/dev/null || echo 1)
chk "every declared hook script is registered"  "$UNREG" 0

echo ""
if [ "$FAIL" -eq 0 ]; then echo "  ✅ Review gate: $PASS/$PASS passed"; exit 0
else echo "  ❌ Review gate: $FAIL of $((PASS+FAIL)) failed"; exit 1; fi
