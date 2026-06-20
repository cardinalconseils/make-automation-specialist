# Taxonomy: HTTP Error Codes in Make Context

**Prefix:** `HTTP-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

### HTTP-400 — Bad Request
- **Symptom:** 400 response from HTTP module or app module; `RuntimeError`
- **Root cause:** Malformed JSON body, missing required parameter, wrong Content-Type header, bad URL
- **Fix:** Use a Set Variable module to validate body before the call. Verify Content-Type. Check API docs for required fields.
- **Make note:** Inspect "Error" output bundle — the error is nested inside Make's wrapper. Look for `error.message` containing the target domain.

### HTTP-401 — Unauthorized
- **Symptom:** `AuthorizationError`; "The connection is not available"; 401 from app
- **Root cause:** OAuth token expired, API key revoked or rotated, wrong credentials in connection
- **Fix:** Reauthorize the connection in Make → Connections. Check token TTL. Rotate API key in the source service then update the Make connection.

### HTTP-403 — Forbidden
- **Symptom:** `AccessDeniedError`; "Insufficient permissions"; 403 despite valid auth
- **Root cause:** OAuth scope missing, IP allowlist blocking Make's IPs, plan tier too low on target app
- **Fix:** Delete and recreate the connection granting all required OAuth scopes. Whitelist Make EU1/US1 IP ranges on the target service. Verify target API plan allows the endpoint being called.

### HTTP-404 — Not Found
- **Symptom:** `DataError`; record or endpoint not found
- **Root cause:** Record deleted between trigger and action ("time gap race"), wrong ID mapped, wrong endpoint path
- **Fix:** Add a "Search" module before "Get by ID". Use error handler → Resume with fallback bundle. Verify URL path against current API docs.

### HTTP-409 — Conflict
- **Symptom:** `DuplicateDataError`; unique key collision
- **Root cause:** Trying to create a record that already exists (Airtable, Stripe idempotency)
- **Fix:** Search first → branch via Router (create vs update path). For Stripe: use idempotency_key consistently.

### HTTP-422 — Unprocessable Entity
- **Symptom:** `ValidationError`; field-level validation fail
- **Root cause:** Enum value not in allowed set, wrong data type for field, format constraint violated
- **Fix:** Map types explicitly. Check allowed enum values. Use parseNumber() / toString() / formatDate() as needed.

### HTTP-429 — Too Many Requests
- **Symptom:** `RateLimitError`; scenario stops mid-execution; 429 from target API
- **Root cause:** Burst exceeds target API quota OR Make's per-connection cap
- **Fix:** Add Sleep module before the failing call. Use error handler → Break (retry with backoff, default 3x at 15min intervals). Reduce scenario run frequency. Throttle with max-cycles setting.

### HTTP-500/502/503/504 — Server Error
- **Symptom:** `ConnectionError` or `RuntimeError`; gateway timeout
- **Root cause:** External service down or internal error. Make's default HTTP timeout is 40 seconds.
- **Fix:** Error handler → Break with retry. Increase HTTP module timeout in advanced settings (max 300s). Check external service status page.
