# Taxonomy: Google App-Specific Errors

**Prefixes:** `APP-GSHEETS-`, `APP-GMAIL-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

## Google Sheets

### APP-GSHEETS-001 — `Unable to parse range`
- **Symptom:** Google Sheets module fails; "Unable to parse range [name]"
- **Root cause:** Sheet tab renamed, deleted, or column structure changed after scenario was built
- **Fix:** Update the sheet/tab name in the module. Use "Search Rows" with dynamic criteria instead of hardcoded ranges.

### APP-GSHEETS-002 — Empty Cell Returns `__EMPTY__`
- **Symptom:** Unexpected `__EMPTY__` value instead of blank or null
- **Root cause:** Make's Google Sheets module returns `__EMPTY__` for empty cells (not null or "")
- **Fix:** Filter: `ifempty({{cell}}; if({{cell}} = "__EMPTY__"; ""; {{cell}}))`. Or use `replace({{cell}}; "__EMPTY__"; "")`.

---

## Gmail

### APP-GMAIL-001 — OAuth Scope Forced Re-Consent
- **Symptom:** Gmail connection works then randomly fails with 403
- **Root cause:** Google forces re-consent ~6 months for unverified OAuth apps with sensitive scopes
- **Fix:** Reauthorize the connection when prompted. For production: verify the OAuth app in Google Console to avoid forced re-consent.

### APP-GMAIL-002 — Daily Sending Quota Exceeded
- **Symptom:** Gmail send module fails; "Daily user sending quota exceeded"
- **Root cause:** Free Gmail: 500 emails/day. Google Workspace: 2000/day.
- **Fix:** Use Google Workspace account. Switch to SendGrid/Mailgun for high-volume sends via HTTP module. Use Gmail API with service account for higher limits.
