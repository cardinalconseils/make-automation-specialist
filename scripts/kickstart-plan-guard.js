#!/usr/bin/env node
/**
 * PreToolUse:Write hook — Kickstart artifact gate (deterministic)
 *
 * Blocks writes to .make/context/ and .make/prd.md unless a kickstart
 * plan file exists for today in .claude/plans/.
 *
 * This gate cannot be bypassed by agent reasoning — it is enforced in code.
 * Purpose: ensure plan mode was entered and approved before artifact generation.
 */

const fs   = require('fs');
const path = require('path');

const ARTIFACT_PATHS = [
  path.join('.make', 'context') + path.sep,
  path.join('.make', 'prd.md'),
];

function block(reason) {
  process.stdout.write(JSON.stringify({ decision: 'block', reason }));
  process.exit(2);
}

function todayPlanExists(cwd) {
  const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD
  const plansDir = path.join(cwd, '.claude', 'plans');
  try {
    return fs.readdirSync(plansDir).some(f => f.startsWith(`make-kickstart-${today}`));
  } catch (_) {
    return false;
  }
}

let raw = '';
process.stdin.on('data', c => { raw += c; });
process.stdin.on('end', () => {
  let data = {};
  try { data = JSON.parse(raw); } catch (_) {}

  const toolName  = data.tool_name || '';
  const filePath  = (data.tool_input && data.tool_input.file_path) || '';

  if (toolName !== 'Write') process.exit(0);

  // Normalize to relative path for matching
  const CWD     = process.cwd();
  const relPath = filePath.startsWith(CWD)
    ? filePath.slice(CWD.length + 1)
    : filePath;

  const isArtifact = ARTIFACT_PATHS.some(p => relPath.startsWith(p) || relPath === p);
  if (!isArtifact) process.exit(0);

  if (!todayPlanExists(CWD)) {
    block(
      `BLOCKED — Cannot write ${relPath} without an approved kickstart plan.\n` +
      `Run /kickstart to enter plan mode, complete the discovery interview,\n` +
      `then approve the plan before artifact generation begins.\n` +
      `Plan must exist at: .claude/plans/make-kickstart-${new Date().toISOString().slice(0, 10)}*.md`
    );
  }

  process.exit(0);
});
