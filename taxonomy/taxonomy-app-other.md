# Taxonomy: Stripe and Vertex AI App-Specific Errors

**Prefixes:** `APP-STRIPE-`, `APP-VERTEXAI-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

## Stripe

### APP-STRIPE-001 — Webhook Signature Mismatch
- **Symptom:** Stripe webhook received but scenario rejects it immediately
- **Root cause:** Endpoint secret in Make doesn't match the secret from Stripe Dashboard → Webhooks
- **Fix:** Match Live vs Test environment endpoint secrets exactly. Never mix Live and Test secrets.

### APP-STRIPE-002 — `idempotency_key already used with different params`
- **Symptom:** Stripe API rejects retry attempt
- **Root cause:** Same idempotency key reused with different request parameters
- **Fix:** Generate unique idempotency key per logical operation. Use a combination of record ID + operation type + timestamp.

---

## Google Vertex AI

### APP-VERTEXAI-001 — Wrong Connection Type
- **Symptom:** Vertex AI module returns 403 despite valid Google account connection
- **Root cause:** Generic "My Google connection" lacks Vertex AI API scopes
- **Fix:** Create a dedicated "Google Vertex AI" connection in Make → Connections. Authorize with the same Google account — Vertex AI requires specific OAuth scopes that the generic connection doesn't have.

### APP-VERTEXAI-002 — GCS URI Required for Video Output
- **Symptom:** Video generation module fails or doesn't return downloadable URL
- **Root cause:** Veo model outputs to Google Cloud Storage — a `storageUri` parameter (`gs://bucket/path/`) is required. Output is a GCS URI, not a public URL.
- **Fix:** Create a GCS bucket. Pass `storageUri: gs://your-bucket/videos/`. To deliver via Telegram: either make the GCS object public-read (build URL: `https://storage.googleapis.com/bucket/filename`) or generate a signed URL.
