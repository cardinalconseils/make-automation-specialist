#!/usr/bin/env bash
# smoke-test-checks.sh — individual check functions for smoke-test.sh
# Sourced by smoke-test.sh — do not run directly.

check_manifest() {
  echo "▸ Plugin manifest"
  if python3 -c "import json; d=json.load(open('$PLUGIN_ROOT/plugin.json')); assert 'name' in d and 'version' in d" 2>/dev/null; then
    VER=$(python3 -c "import json; print(json.load(open('$PLUGIN_ROOT/plugin.json'))['version'])" 2>/dev/null)
    pass "plugin.json valid (v$VER)"
  else
    fail "plugin.json missing or invalid"
  fi
}

check_commands() {
  echo "▸ Commands"
  for cmd in "$PLUGIN_ROOT"/commands/*.md; do
    [ "$(basename "$cmd")" = "README.md" ] && continue
    if grep -q "^---" "$cmd" && grep -q "^description:" "$cmd"; then
      pass "$(basename "$cmd") — frontmatter OK"
    else
      fail "$(basename "$cmd") — missing frontmatter"
    fi
  done
}

check_agents() {
  echo "▸ Agents"
  for agent in "$PLUGIN_ROOT"/agents/*.md; do
    [ "$(basename "$agent")" = "README.md" ] && continue
    if grep -q "^name:" "$agent" && grep -q "^description:" "$agent"; then
      pass "$(basename "$agent") — frontmatter OK"
    else
      fail "$(basename "$agent") — missing frontmatter"
    fi
  done
}

check_skills() {
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
}

check_hooks() {
  echo "▸ Hooks"
  HOOK_FILES=$(python3 -c "import json; d=json.load(open('$PLUGIN_ROOT/plugin.json')); [print(h.get('file','')) for h in d.get('hooks',[])]" 2>/dev/null)
  for hf in $HOOK_FILES; do
    if [ -f "$PLUGIN_ROOT/$hf" ]; then pass "$hf — exists"
    else fail "$hf — registered in plugin.json but file missing"; fi
  done
}

check_agent_registration() {
  echo "▸ Agent registration"
  AGENT_FILES=$(python3 -c "import json; d=json.load(open('$PLUGIN_ROOT/plugin.json')); [print(a.get('file','')) for a in d.get('agents',[])]" 2>/dev/null)
  for af in $AGENT_FILES; do
    if [ -f "$PLUGIN_ROOT/$af" ]; then pass "$af — exists"
    else fail "$af — registered but file missing"; fi
  done
}

check_output_dirs() {
  echo "▸ Output directories"
  OUTPUT_DIRS=$(python3 -c "import json; d=json.load(open('$PLUGIN_ROOT/plugin.json')); root=d.get('output',{}).get('root','.make'); [print(root+'/'+x) for x in d.get('output',{}).get('directories',[])]" 2>/dev/null)
  for od in $OUTPUT_DIRS; do
    if [ -d "$PLUGIN_ROOT/$od" ] || [ -f "$PLUGIN_ROOT/$od/.gitkeep" ]; then
      pass "$od — scaffolded"
    else
      fail "$od — missing (run: mkdir -p $PLUGIN_ROOT/$od)"
    fi
  done
}

check_json_files() {
  echo "▸ JSON files"
  while IFS= read -r -d '' f; do
    if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
      pass "$(echo "$f" | sed "s|$PLUGIN_ROOT/||") — valid"
    else
      fail "$(echo "$f" | sed "s|$PLUGIN_ROOT/||") — invalid JSON"
    fi
  done < <(find "$PLUGIN_ROOT" -name "*.json" -not -path "*/.git/*" -print0 2>/dev/null)
}
