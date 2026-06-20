# Taxonomy: Connection / OAuth Failures

**Prefix:** `CONN-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

### CONN-001 — OAuth Token Refresh Failure
- **Symptom:** `invalid_grant`; "The connection is not available" appearing intermittently
- **Root cause:** Refresh token revoked (user changed password, app uninstalled, or inactive >6 months)
- **Fix:** Full reauthorization — delete connection, create new one, reauthorize with the account.

### CONN-002 — Scope Mismatch (Generic vs Specific Connection)
- **Symptom:** 403 "access denied" for specific API call despite OAuth appearing valid
- **Root cause:** Generic OAuth connection lacks scopes for a specific API (e.g., generic Google connection lacks Vertex AI scopes)
- **Fix:** Create a service-specific connection (e.g., "Google Vertex AI" is a separate connection type from "Google Sheets"). Different Make modules require different connection types even for the same account.
- **Example:** `google-vertex-ai:generateImage` requires a "Google Vertex AI" connection — "My Google connection" (generic) will fail with 403.

### CONN-003 — Multi-Account Confusion
- **Symptom:** Actions applied to wrong account/workspace
- **Root cause:** Connection named ambiguously, multiple connections to same service
- **Fix:** Rename connections descriptively (e.g., "Google — info@pmcardinal.com — Sheets" vs "Google — info@pmcardinal.com — Vertex AI").

### CONN-004 — Shared OAuth App Quota Hit
- **Symptom:** Intermittent 429 or 403 on Google/Microsoft modules despite low personal usage
- **Root cause:** Make's shared OAuth app hits global rate caps across all Make users
- **Fix:** Use "Custom App" / Bring-Your-Own-OAuth-App. Register your own OAuth client in Google Console / Azure and configure it in Make's custom connection.

### CONN-005 — Webhook Secret Validation Failure
- **Symptom:** Webhook receives data, scenario triggered, but module rejects payload immediately
- **Root cause:** HMAC signature mismatch — wrong secret configured on one side
- **Fix:** Verify webhook secret matches exactly between the sending service and Make's webhook module. Check for trailing whitespace or encoding differences.

### CONN-006 — Service Account Key Rotated
- **Symptom:** Service account connection fails after working for months
- **Root cause:** GCP service account key expired or was rotated/deleted
- **Fix:** Generate new service account key in GCP Console, re-upload JSON to Make connection.
