#!/bin/bash
# scripts/smoke-test.sh — Plugin structure validation
# Run standalone (no Claude Code needed). Exit 0 = all pass, Exit 1 = failures.

set -uo pipefail
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

fail() { echo "  ❌ $1"; FAIL=1; }
pass() { echo "  ✅ $1"; }

# ── 1. Plugin manifest ──
echo "▸ Plugin manifest"
if python3 -c "import json; f=open('$PLUGIN_ROOT/plugin.json'); d=json.load(f); assert 'name' in d and 'version' in d" 2>/dev/null; then
  VER=$(python3 -c "import json; print(json.load(open('$PLUGIN_ROOT/plugin.json'))['version'])" 2>/dev/null)
  pass "plugin.json valid (v$VER)"
else
  fail "plugin.json missing or invalid"
fi

# ── 2. Commands have frontmatter ──
echo "▸ Commands"
for cmd in "$PLUGIN_ROOT"/commands/*.md; do
  [ "$(basename "$cmd")" = "README.md" ] && continue
  if grep -q "^---" "$cmd" && grep -q "^description:" "$cmd"; then
    pass "$(basename "$cmd") — frontmatter OK"
  else
    fail "$(basename "$cmd") — missing frontmatter"
  fi
done

# ── 3. Agents have frontmatter ──
echo "▸ Agents"
for agent in "$PLUGIN_ROOT"/agents/*.md; do
  [ "$(basename "$agent")" = "README.md" ] && continue
  if grep -q "^name:" "$agent" && grep -q "^description:" "$agent"; then
    pass "$(basename "$agent") — frontmatter OK"
  else
    fail "$(basename "$agent") — missing frontmatter"
  fi
done

# ── 4. Skills have SKILL.md with frontmatter ──
echo "▸ Skills"
for skill_dir in "$PLUGIN_ROOT"/skills/*/; do
  [ ! -d "$skill_dir" ] && continue
  SKILL_NAME=$(basename "$skill_dir")
  [ "$SKILL_NAME" = "personas" ] && continue
  SKILL_FILE="${skill_dir}SKILL.md"
  if [ ! -f "$SKILL_FILE" ]; then
    fail "skills/$SKILL_NAME/ missing SKILL.md"
  elif grep -q "^name:" "$SKILL_FILE" && grep -q "^description:" "$SKILL_FILE"; then
    pass "skills/$SKILL_NAME/SKILL.md — OK"
  else
    fail "skills/$SKILL_NAME/SKILL.md — missing frontmatter"
  fi
done

# ── 5. Hooks registered in plugin.json ──
echo "▸ Hooks"
HOOK_FILES=$(python3 -c "
import json
d=json.load(open('$PLUGIN_ROOT/plugin.json'))
for h in d.get('hooks',[]):
  print(h.get('file',''))
" 2>/dev/null)
for hf in $HOOK_FILES; do
  if [ -f "$PLUGIN_ROOT/$hf" ]; then
    pass "$hf — exists"
  else
    fail "$hf — registered in plugin.json but file missing"
  fi
done

# ── 6. Agents registered in plugin.json ──
echo "▸ Agent registration"
AGENT_FILES=$(python3 -c "
import json
d=json.load(open('$PLUGIN_ROOT/plugin.json'))
for a in d.get('agents',[]):
  print(a.get('file',''))
" 2>/dev/null)
for af in $AGENT_FILES; do
  if [ -f "$PLUGIN_ROOT/$af" ]; then
    pass "$af — exists"
  else
    fail "$af — registered but file missing"
  fi
done

# ── 7. .make/ output dirs scaffolded ──
echo "▸ Output directories"
OUTPUT_DIRS=$(python3 -c "
import json
d=json.load(open('$PLUGIN_ROOT/plugin.json'))
root=d.get('output',{}).get('root','.make')
for dir in d.get('output',{}).get('directories',[]):
  print(root+'/'+dir)
" 2>/dev/null)
for od in $OUTPUT_DIRS; do
  if [ -d "$PLUGIN_ROOT/$od" ] || [ -f "$PLUGIN_ROOT/$od/.gitkeep" ]; then
    pass "$od — scaffolded"
  else
    fail "$od — missing (run: mkdir -p $PLUGIN_ROOT/$od)"
  fi
done

# ── 8. JSON files valid ──
echo "▸ JSON files"
while IFS= read -r -d '' f; do
  if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
    pass "$(echo "$f" | sed "s|$PLUGIN_ROOT/||") — valid"
  else
    fail "$(echo "$f" | sed "s|$PLUGIN_ROOT/||") — invalid JSON"
  fi
done < <(find "$PLUGIN_ROOT" -name "*.json" -not -path "*/.git/*" -print0 2>/dev/null)

# ── Summary ──
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
