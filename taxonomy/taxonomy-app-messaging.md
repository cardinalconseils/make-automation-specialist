# Taxonomy: Messaging App-Specific Errors

**Prefixes:** `APP-TELEGRAM-`, `APP-SLACK-`, `APP-AIRTABLE-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

## Telegram

### APP-TELEGRAM-001 — Bot Token Invalid
- **Symptom:** Telegram module returns 401 "Unauthorized"
- **Root cause:** Bot token regenerated in BotFather; old token revoked
- **Fix:** Get new token from BotFather. Update the Telegram connection in Make with the new token.

### APP-TELEGRAM-002 — Message to Bot in Group Without Admin Rights
- **Symptom:** Telegram module fails sending to group chat
- **Root cause:** Bot is not a member or lacks send permissions in the group
- **Fix:** Add bot to the group, grant admin rights if needed.

---

## Slack

### APP-SLACK-001 — `channel_not_found` / `not_in_channel`
- **Symptom:** Slack module fails; channel not found despite correct channel name
- **Root cause:** Bot is not a member of the channel
- **Fix:** In Slack: `/invite @YourMakeBot` in the target channel. Or use `channel ID` (starts with `C`) instead of name — more stable.

### APP-SLACK-002 — `invalid_blocks`
- **Symptom:** Slack Block Kit message fails
- **Root cause:** Block Kit JSON is malformed
- **Fix:** Validate JSON in Slack's Block Kit Builder before pasting into Make. Common issues: missing `type` field, wrong block structure.

---

## Airtable

### APP-AIRTABLE-001 — `INVALID_VALUE_FOR_COLUMN`
- **Symptom:** Airtable create/update fails with type validation error
- **Root cause:** String passed to number field, invalid select option, wrong linked record format
- **Fix:** Map types explicitly. For linked records: pass an array of record IDs `["recXXX"]`, not names. Pre-create select options in Airtable base.

### APP-AIRTABLE-002 — Attachment URL Expired
- **Symptom:** Airtable attachment URL works immediately but fails hours later
- **Root cause:** Airtable attachment URLs expire in ~2 hours
- **Fix:** Re-fetch the record when you need the attachment URL. Do not store URLs long-term — store record IDs and re-fetch.
