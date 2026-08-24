#!/usr/bin/env node
/**
 * PreToolUse hook — Local blueprint push guard (deterministic)
 *
 * Fires on Bash tool calls. Blocks any curl PUT to the Make.com scenarios
 * endpoint unless BOTH conditions are met:
 *   1. A plan file exists in .make/plans/
 *   2. .make/logs/.blueprint-reviewed sentinel is present, < 24h old, and its verdict
 *      is not "FIX FIRST" (same JSON sentinel the MCP-path review gate reads)
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

  // Check 2 — blueprint reviewed (JSON sentinel, < 24h, verdict not FIX FIRST)
  //
  // Note: this path is a raw curl, so there is no blueprint in the tool input to hash
  // against. Freshness + verdict is all that can be verified here. The MCP path
  // (pre-execute-hook.js) additionally binds the sentinel to the blueprint's sha256.
  let sentinel = null;
  try { sentinel = JSON.parse(fs.readFileSync(SENTINEL, 'utf8')); } catch (_) {}

  if (!sentinel) {
    block(
      'PUSH BLOCKED — Blueprint not reviewed (missing, legacy, or corrupt sentinel).\n' +
      'The old touch-file sentinel is no longer accepted — it could not prove WHICH ' +
      'blueprint was reviewed.\n' +
      'Run /blueprint-review on this scenario JSON first, then retry the push.\n' +
      'This gate cannot be bypassed.'
    );
  }

  const ts = Date.parse(sentinel.ts || '');
  if (!ts || Date.now() - ts > 24 * 3600 * 1000) {
    block(
      'PUSH BLOCKED — Review is missing a timestamp or older than 24h.\n' +
      'Re-run /blueprint-review, then retry the push.'
    );
  }

  if (String(sentinel.verdict || '').toUpperCase().includes('FIX FIRST')) {
    block(
      'PUSH BLOCKED — Last review verdict was FIX FIRST.\n' +
      'Resolve the issues the review listed, re-review, then retry.'
    );
  }

  process.stderr.write('[pre-push-guard] ✅ Plan confirmed · Blueprint reviewed · Proceeding\n');
  process.exit(0);
});
