#!/usr/bin/env node
/**
 * Writes the blueprint-review sentinel that pre-execute-hook.js and pre-push-guard.js read.
 *
 *   node scripts/blueprint-sentinel.js <blueprint.json> "<VERDICT>" [scenario-name-or-id]
 *
 * VERDICT is the blueprint-review skill's verdict: PUSH | FIX FIRST | NEEDS HUMAN REVIEW.
 * The hash is computed here with the SAME canonicalizer the gate uses, so the review and
 * the gate can never disagree about which blueprint was reviewed.
 */

const fs   = require('fs');
const path = require('path');
const { blueprintHash } = require('./pre-execute-gates');

const [file, verdict, scenario] = process.argv.slice(2);

if (!file || !verdict) {
  console.error('usage: blueprint-sentinel.js <blueprint.json> "<VERDICT>" [scenario]');
  process.exit(1);
}

let blueprint;
try {
  blueprint = JSON.parse(fs.readFileSync(file, 'utf8'));
} catch (e) {
  console.error(`Cannot read/parse blueprint at ${file}: ${e.message}`);
  process.exit(1);
}

// The gate hashes tool_input.blueprint. If the reviewed file is a full scenario payload,
// hash its .blueprint so both sides see the same object.
const target = (blueprint && typeof blueprint === 'object' && blueprint.blueprint)
  ? blueprint.blueprint
  : blueprint;

const LOG_DIR  = path.join(process.cwd(), '.make', 'logs');
const SENTINEL = path.join(LOG_DIR, '.blueprint-reviewed');

fs.mkdirSync(LOG_DIR, { recursive: true });
fs.writeFileSync(SENTINEL, JSON.stringify({
  ts: new Date().toISOString(),
  hash: blueprintHash(target),
  verdict,
  scenario: scenario || null,
  source: path.resolve(file),
}, null, 2) + '\n');

console.log(`[blueprint-sentinel] ${verdict} · ${blueprintHash(target).slice(0, 16)}… · ${SENTINEL}`);
