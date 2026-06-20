#!/usr/bin/env node
/**
 * PreToolUse hook — Make.com write operation guard (deterministic)
 *
 * HARD GATES (exit 2 = blocked, never negotiable):
 *   1. Phase gate — blocks writes during kickstart/bootstrap/design phases
 *   2. L3 gate  — blocks destructive ops unless approval token present
 *
 * AUDIT (always):
 *   Appends every write attempt to .make/logs/tool-audit.log
 */

const fs = require('fs');
const path = require('path');
const { checkFactoryPhase, checkL3Token } = require('./pre-execute-gates');

const CWD = process.cwd();
const LOG_DIR   = path.join(CWD, '.make', 'logs');
const FACTORY   = path.join(CWD, '.make', 'factory', 'current-session.json');
const TOKEN_DIR = path.join(CWD, '.make', 'logs', '.approval-tokens');

const LEVEL3 = new Set([
  'mcp__claude_ai_Make__scenarios_delete',
  'mcp__claude_ai_Make__hooks_delete',
  'mcp__claude_ai_Make__data-stores_delete',
  'mcp__claude_ai_Make__data-store-records_delete',
  'mcp__claude_ai_Make__data-structures_delete',
  'mcp__claude_ai_Make__folders_delete',
  'mcp__claude_ai_Make__keys_delete',
  'mcp__claude_ai_Make__credential-requests_delete',
  'mcp__claude_ai_Make__credential-requests_credential-delete',
  'mcp__claude_ai_Make__credential-requests_credential-decline',
  'mcp__claude_ai_Make__teams_delete',
  'mcp__claude_ai_Make__organizations_delete',
]);

const LEVEL2 = new Set([
  'mcp__claude_ai_Make__scenarios_run',
  'mcp__claude_ai_Make__rpc_execute',
]);

function block(reason) {
  process.stdout.write(JSON.stringify({ decision: 'block', reason }));
  process.exit(2);
}

function audit(toolName, input) {
  try {
    fs.mkdirSync(LOG_DIR, { recursive: true });
    const entry = JSON.stringify({ ts: new Date().toISOString(), tool: toolName, input }) + '\n';
    fs.appendFileSync(path.join(LOG_DIR, 'tool-audit.log'), entry);
  } catch (_) {}
}

let raw = '';
process.stdin.on('data', c => { raw += c; });
process.stdin.on('end', () => {
  let data = {};
  try { data = JSON.parse(raw); } catch (_) {}

  const toolName  = data.tool_name || data.tool || '';
  const toolInput = data.tool_input || {};

  const isMakeWrite = toolName.startsWith('mcp__claude_ai_Make__') &&
    /create|update|delete|activate|deactivate|run|set-interface|generate|replace|execute/.test(toolName);

  if (!isMakeWrite) process.exit(0);

  checkFactoryPhase(FACTORY, block);
  checkL3Token(LEVEL3, TOKEN_DIR, toolName, block);

  if (LEVEL2.has(toolName)) {
    process.stderr.write(
      `⚠️  HIGH-RISK: ${toolName} — executes a live scenario with real-world effects.\n` +
      `Ensure user typed "run it" before this call.\n`
    );
  }

  audit(toolName, toolInput);
  process.exit(0);
});
