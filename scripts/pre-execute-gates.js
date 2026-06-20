/**
 * Gate logic for pre-execute-hook.js
 * Exports: checkFactoryPhase(FACTORY, block), checkL3Token(LEVEL3, TOKEN_DIR, toolName, block)
 */

const fs = require('fs');
const path = require('path');

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

module.exports = { checkFactoryPhase, checkL3Token };
