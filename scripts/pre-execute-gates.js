/**
 * Gate logic for pre-execute-hook.js
 * Exports: checkFactoryPhase(FACTORY, block), checkL3Token(LEVEL3, TOKEN_DIR, toolName, block),
 *          checkBlueprintReview(SENTINEL, toolName, toolInput, block), blueprintHash(blueprint)
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

function checkFactoryPhase(FACTORY, block) {
  try {
    if (fs.existsSync(FACTORY)) {
      const session = JSON.parse(fs.readFileSync(FACTORY, 'utf8'));
      if (['kickstart', 'bootstrap', 'design'].includes(session.status)) {
        block(
          `Factory session is in the "${session.status}" phase. ` +
          `No Make.com changes until the design is approved and sprint begins.`
        );
      }
    }
  } catch (_) {}
}

function checkL3Token(LEVEL3, TOKEN_DIR, toolName, block) {
  if (!LEVEL3.has(toolName)) return;

  const tokenFile = path.join(TOKEN_DIR, toolName.replace(/[^a-z0-9_-]/gi, '_'));
  let tokenValid = false;
  try {
    if (fs.existsSync(tokenFile)) {
      const ageMs = Date.now() - fs.statSync(tokenFile).mtimeMs;
      if (ageMs < 120000) {
        tokenValid = true;
        fs.unlinkSync(tokenFile); // single-use — consumed on read
      }
    }
  } catch (_) {}

  if (!tokenValid) {
    block(
      `DESTRUCTIVE OPERATION BLOCKED. No approval token found for "${toolName}". ` +
      `Type exactly: DELETE {resource name} — the agent will record your confirmation ` +
      `and retry. Make.com has no recycle bin.`
    );
  }
}

const REVIEW_GATED = new Set([
  'mcp__claude_ai_Make__scenarios_create',
  'mcp__claude_ai_Make__scenarios_update',
]);

const REVIEW_MAX_AGE_MS = 24 * 3600 * 1000;

/**
 * Canonical JSON — key-sorted, no whitespace. Two structurally identical blueprints
 * hash the same regardless of key order or formatting.
 */
function canonicalize(value) {
  if (Array.isArray(value)) return '[' + value.map(canonicalize).join(',') + ']';
  if (value && typeof value === 'object') {
    return '{' + Object.keys(value).sort()
      .map(k => JSON.stringify(k) + ':' + canonicalize(value[k])).join(',') + '}';
  }
  return JSON.stringify(value === undefined ? null : value);
}

function blueprintHash(blueprint) {
  const src = typeof blueprint === 'string' ? blueprint : canonicalize(blueprint);
  return crypto.createHash('sha256').update(src).digest('hex');
}

/**
 * Blocks scenarios_create / scenarios_update unless the blueprint-review skill has
 * reviewed THIS EXACT blueprint. The sentinel is bound to the blueprint's sha256, so a
 * review of a different blueprint cannot open the gate.
 */
function checkBlueprintReview(SENTINEL, toolName, toolInput, block) {
  if (!REVIEW_GATED.has(toolName)) return;

  const fix =
    '\nFix: run the blueprint-review skill on this exact blueprint JSON. It writes ' +
    SENTINEL + ' with the blueprint sha256. Then retry.\nThis gate cannot be bypassed.';

  let raw;
  try { raw = fs.readFileSync(SENTINEL, 'utf8'); }
  catch (_) { block('SCENARIO WRITE BLOCKED — blueprint not reviewed (no sentinel).' + fix); }

  let sentinel;
  try { sentinel = JSON.parse(raw); }
  catch (_) {
    block(
      'SCENARIO WRITE BLOCKED — legacy or corrupt review sentinel.\n' +
      'The old touch-file sentinel is no longer accepted: it could not prove WHICH ' +
      'blueprint was reviewed.' + fix
    );
  }

  const ts = Date.parse(sentinel.ts || '');
  if (!ts || Date.now() - ts > REVIEW_MAX_AGE_MS) {
    block('SCENARIO WRITE BLOCKED — review is missing a timestamp or older than 24h.' + fix);
  }

  if (String(sentinel.verdict || '').toUpperCase().includes('FIX FIRST')) {
    block(
      'SCENARIO WRITE BLOCKED — last review verdict was FIX FIRST.\n' +
      'Resolve the issues the review listed, re-review, then retry.'
    );
  }

  const blueprint = toolInput && toolInput.blueprint;
  if (blueprint === undefined || blueprint === null) {
    block('SCENARIO WRITE BLOCKED — no blueprint in the call; nothing can be verified.' + fix);
  }

  const actual = blueprintHash(blueprint);
  if (sentinel.hash !== actual) {
    block(
      'SCENARIO WRITE BLOCKED — blueprint does not match what was reviewed.\n' +
      `  reviewed: ${String(sentinel.hash).slice(0, 16)}…\n` +
      `  pushing:  ${actual.slice(0, 16)}…` + fix
    );
  }
}

module.exports = { checkFactoryPhase, checkL3Token, checkBlueprintReview, blueprintHash, canonicalize };
