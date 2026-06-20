#!/usr/bin/env node
/**
 * PreToolUse hook — Local blueprint push guard (deterministic)
 *
 * Fires on Bash tool calls. Blocks any curl PUT to the Make.com scenarios
 * endpoint unless BOTH conditions are met:
 *   1. A plan file exists in .make/plans/
 *   2. .make/logs/.blueprint-reviewed sentinel is present and < 24h old
 *
 * This gate cannot be bypassed by agent reasoning — it is enforced in code.
 */

const fs   = require('fs');
const path = require('path');

function block(reason) {
  process.stdout.write(JSON.stringify({ decision: 'block', reason }));
  process.exit(2);
}

let raw = '';
process.stdin.on('data', c => { raw += c; });
process.stdin.on('end', () => {
  let data = {};
  try { data = JSON.parse(raw); } catch (_) {}

  const command = (data.tool_input && data.tool_input.command) || '';

  // Only intercept curl PUT to Make scenarios endpoint
  const isPush = /curl[^|&;]*(-X\s+PUT|--request\s+PUT)[^|&;]*\/api\/v2\/scenarios/.test(command) ||
                 /curl[^|&;]*\/api\/v2\/scenarios[^|&;]*(-X\s+PUT|--request\s+PUT)/.test(command);

  if (!isPush) process.exit(0);

  const CWD      = process.cwd();
  const PLANS    = path.join(CWD, '.make', 'plans');
  const SENTINEL = path.join(CWD, '.make', 'logs', '.blueprint-reviewed');

  // Check 1 — plan file exists
  let hasPlan = false;
  try {
    hasPlan = fs.readdirSync(PLANS).some(f => f.endsWith('.md') || f.endsWith('.json'));
  } catch (_) {}

  if (!hasPlan) {
    block(
      'PUSH BLOCKED — No plan on file.\n' +
      'Run /plan to document what this change does and why, then retry the push.\n' +
      'This gate cannot be bypassed.'
    );
  }

  // Check 2 — blueprint reviewed (< 24h)
  let reviewed = false;
  try {
    if (fs.existsSync(SENTINEL)) {
      const ageHours = (Date.now() - fs.statSync(SENTINEL).mtimeMs) / 3600000;
      reviewed = ageHours < 24;
    }
  } catch (_) {}

  if (!reviewed) {
    block(
      'PUSH BLOCKED — Blueprint not reviewed.\n' +
      'Run /blueprint-review on this scenario JSON first, then retry the push.\n' +
      'This gate cannot be bypassed.'
    );
  }

  process.stderr.write('[pre-push-guard] ✅ Plan confirmed · Blueprint reviewed · Proceeding\n');
  process.exit(0);
});
