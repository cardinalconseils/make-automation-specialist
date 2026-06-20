#!/usr/bin/env node
/**
 * PostToolUse hook — Make.com / Telnyx execution logger (deterministic)
 *
 * Appends every completed MCP call (success or failure) to:
 *   .make/logs/tool-audit.log
 *
 * Also checks Make.com operation usage and writes a warning marker
 * if usage exceeds 80% so the next agent response can surface it.
 */

const fs   = require('fs');
const path = require('path');

let raw = '';
process.stdin.on('data', c => { raw += c; });
process.stdin.on('end', () => {
  let data = {};
  try { data = JSON.parse(raw); } catch (_) {}

  const toolName = data.tool_name || data.tool || '';
  const isMake   = toolName.startsWith('mcp__claude_ai_Make__');
  const isTelnyx = toolName.startsWith('mcp__telnyx__');

  if (!isMake && !isTelnyx) process.exit(0);

  const CWD     = process.cwd();
  const LOG_DIR = path.join(CWD, '.make', 'logs');

  try { fs.mkdirSync(LOG_DIR, { recursive: true }); } catch (_) {}

  // Append call record
  const success = !data.error && data.output !== undefined;
  const entry = JSON.stringify({
    ts:      new Date().toISOString(),
    tool:    toolName,
    success,
    error:   data.error || null,
    snippet: typeof data.output === 'string'
      ? data.output.slice(0, 300)
      : (data.output ? JSON.stringify(data.output).slice(0, 300) : null),
  }) + '\n';

  try {
    fs.appendFileSync(path.join(LOG_DIR, 'tool-audit.log'), entry);
  } catch (_) {}

  // Usage warning marker — agent reads this on next response
  if (isMake && success) {
    try {
      const wsFile = path.join(CWD, '.make', 'workspace.json');
      if (fs.existsSync(wsFile)) {
        const ws = JSON.parse(fs.readFileSync(wsFile, 'utf8'));
        const used  = ws.operations_used_this_month || 0;
        const limit = ws.operations_limit || 10000;
        const pct   = used / limit;
        if (pct >= 0.80) {
          const marker = path.join(LOG_DIR, '.usage-warning');
          fs.writeFileSync(marker, JSON.stringify({ used, limit, pct: Math.round(pct * 100) }));
        }
      }
    } catch (_) {}
  }

  process.exit(0);
});
