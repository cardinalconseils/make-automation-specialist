#!/usr/bin/env node
/**
 * PreToolUse hook — Make.com write operation guard
 *
 * Runs before every Make.com MCP write call.
 * - Logs all write operations to .make/logs/tool-audit.log
 * - Emits a strong stderr warning for DESTRUCTIVE ops (delete, run)
 * - Exit 0 always: approval gate is enforced by agent behavior, not this hook.
 *   This hook provides the audit trail and escalation signal.
 */

const fs = require('fs');
const path = require('path');

let raw = '';
process.stdin.on('data', chunk => { raw += chunk; });
process.stdin.on('end', () => {
  let data = {};
  try { data = JSON.parse(raw); } catch (_) {}

  const toolName = data.tool_name || data.tool || '';

  const DESTRUCTIVE = new Set([
    'mcp__claude_ai_Make__scenarios_delete',
    'mcp__claude_ai_Make__hooks_delete',
    'mcp__claude_ai_Make__data-stores_delete',
    'mcp__claude_ai_Make__data-store-records_delete',
    'mcp__claude_ai_Make__data-structures_delete',
    'mcp__claude_ai_Make__folders_delete',
    'mcp__claude_ai_Make__keys_delete',
    'mcp__claude_ai_Make__credential-requests_delete',
    'mcp__claude_ai_Make__credential-requests_credential-delete',
    'mcp__claude_ai_Make__teams_delete',
    'mcp__claude_ai_Make__organizations_delete',
  ]);

  const HIGH_RISK = new Set([
    'mcp__claude_ai_Make__scenarios_run',
    'mcp__claude_ai_Make__rpc_execute',
  ]);

  const isMake = toolName.startsWith('mcp__claude_ai_Make__');
  const isWrite = isMake && /create|update|delete|activate|deactivate|run|set-interface|generate|replace|execute/.test(toolName);

  if (!isWrite) process.exit(0);

  // Write audit log
  const logDir = path.join(process.cwd(), '.make', 'logs');
  try {
    fs.mkdirSync(logDir, { recursive: true });
    const entry = JSON.stringify({
      ts: new Date().toISOString(),
      tool: toolName,
      input: data.tool_input || {},
    }) + '\n';
    fs.appendFileSync(path.join(logDir, 'tool-audit.log'), entry);
  } catch (_) {}

  // Warn for destructive / high-risk ops — Claude sees stderr before proceeding
  if (DESTRUCTIVE.has(toolName)) {
    process.stderr.write(
      `\n⚠️  DESTRUCTIVE OPERATION DETECTED: ${toolName}\n` +
      `This action is IRREVERSIBLE. Make.com has no recycle bin.\n` +
      `Ensure the user typed an explicit delete confirmation before this call.\n\n`
    );
  } else if (HIGH_RISK.has(toolName)) {
    process.stderr.write(
      `\n⚠️  HIGH-RISK OPERATION: ${toolName}\n` +
      `This will execute a live scenario and may trigger real-world side effects.\n` +
      `Confirm the user approved this specific execution.\n\n`
    );
  }

  process.exit(0);
});
