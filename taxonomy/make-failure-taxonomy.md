# Make.com Failure Taxonomy
**Version:** 1.0 — 2026-06-15
**Status:** Living document — update via `/make-taxonomy-update` skill
**Source:** Make.com docs + community forum + r/integromat + Academy + research corpus

---

## How to Use This Taxonomy

When diagnosing a failure:
1. Match symptom to a category header
2. Find the specific pattern code (e.g., `HTTP-429`)
3. Confirm root cause matches
4. Apply the fix
5. If pattern is new → add it here via `make-taxonomy-update` skill

---

## Category Index

| Code Prefix | Category |
|-------------|----------|
| `HTTP-` | HTTP Error Codes |
| `MAKE-` | Make Engine Errors |
| `CONN-` | Connection / OAuth Failures |
| `DATA-` | Data Mapping / Bundle Errors |
| `TRIG-` | Trigger / Scheduling Failures |
| `RATE-` | Rate Limit / Quota |
| `EXEC-` | Execution Limits |
| `ROUTER-` | Router / Filter Logic |
| `ITER-` | Iterator / Aggregator |
| `BLUEPRINT-` | Blueprint / Schema |
| `APP-` | App-Specific Errors |
| `PATTERN-` | Cross-Cutting Failure Patterns |

---

## HTTP-xxx — HTTP Error Codes in Make Context

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

---

## MAKE-xxx — Make Engine Error Types

### MAKE-DATA — DataError
- **Symptom:** "DataError" in execution log; module stops; missing required field
- **Root cause:** Required field in bundle is null/empty, field path wrong
- **Fix:** Add Set Variable defaults upstream. Filter null bundles with filter (`exists` operator). Use `ifempty({{x}}; "default")`.

### MAKE-INCONSIST — InconsistencyError
- **Symptom:** "InconsistencyError"; bundle shape changed mid-scenario
- **Root cause:** Source API changed its response schema; array became object or vice versa
- **Fix:** Re-run "Determine data structure" on the trigger/source module. Re-map all downstream field references.

### MAKE-DUP — DuplicateDataError
- **Symptom:** Records created twice; "DuplicateDataError"
- **Root cause:** Webhook replay, duplicate trigger fire, scenario retried after partial success
- **Fix:** Implement data store dedupe: store processed ID, check on each run, skip if seen.

### MAKE-RUNTIME — RuntimeError
- **Symptom:** Generic "RuntimeError" with no specific app error nested
- **Root cause:** Various — check the execution detail log for the nested message
- **Fix:** Expand the error in scenario history → inspect full error object. Often reveals the real cause (usually a specific HTTP or data error underneath).

### MAKE-INCOMPLETE — IncompleteDataError
- **Symptom:** Trigger ran but bundle is partial; downstream module sees missing fields
- **Root cause:** Source record not fully written when trigger fired (eventual consistency)
- **Fix:** Add Sleep 2-5 seconds after trigger. Then re-fetch the record by ID.

### MAKE-MAXRESULTS — MaxResultsExceededError
- **Symptom:** Search module returns partial results or errors on large datasets
- **Root cause:** Query returns more records than module limit
- **Fix:** Paginate with iterator and cursor. Use "Limit" and "Offset" parameters iteratively.

### MAKE-FILESIZE — MaxFileSizeExceededError
- **Symptom:** File processing fails; "file too large"
- **Root cause:** File exceeds 100 MB (Core plan) or plan-specific limit
- **Fix:** Stream/split the file, or pass a cloud storage URL (GCS, S3, Drive) instead of the binary content.

---

## CONN-xxx — Connection / OAuth Failures

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

---

## DATA-xxx — Data Mapping / Bundle Errors

### DATA-001 — Type Mismatch
- **Symptom:** "Expected number but got string" (or similar); downstream module rejects input
- **Root cause:** Field is text where number expected (or vice versa). Implicit coercion failed.
- **Fix:** `parseNumber({{x}})` for text→number. `toString({{x}})` for number→text. `parseDate({{x}}; "YYYY-MM-DD")` for dates.

### DATA-002 — Null / Empty Value
- **Symptom:** Module fails on empty input; "DataError" with missing field
- **Root cause:** Optional field not populated by source; upstream module returned no data for that field
- **Fix:** `ifempty({{x}}; "default")`. Add filter with `exists` operator before the failing module. Set defaults with Set Variable.

### DATA-003 — Array vs Single Value
- **Symptom:** Module expects single value but receives array (`[object Object]` in output); or expects array but gets single item
- **Root cause:** Source returns collection; no iterator used. Or `{{x}}` maps entire array object instead of `{{x.field}}`.
- **Fix:** Add Iterator module to normalize. Use `first({{array}})` or `last({{array}})` to extract one item. Add Array Aggregator to re-collect after iteration.

### DATA-004 — Date/Time Format Mismatch
- **Symptom:** "Invalid date" error; date filter fails; wrong date stored
- **Root cause:** Different services use different formats (ISO 8601, Unix timestamp, "YYYY-MM-DD", "MM/DD/YYYY"). Timezone not specified.
- **Fix:** `formatDate({{x}}; "YYYY-MM-DD"; "UTC")` — always specify format and timezone. Make uses UTC internally.

### DATA-005 — `[object Object]` in String Field
- **Symptom:** Output shows "[object Object]" literally
- **Root cause:** Mapping a collection/object where a string is expected (mapped `{{item}}` instead of `{{item.field}}`)
- **Fix:** Drill into the specific field: `{{item.field.subfield}}`. Use `toString({{item}})` only for debugging.

### DATA-006 — Null vs Empty String vs Missing Field
- **Symptom:** Filter comparing to "" passes when it shouldn't; `exists` check behaves unexpectedly
- **Root cause:** Make distinguishes three states: `null` (field exists, value is null), `""` (empty string), and missing (field not in bundle at all)
- **Fix:** Use `exists` operator in filters for "field is present". Use `!= ""` for non-empty string. Use `ifempty` to collapse null and "" into a default.

### DATA-007 — Schema Drift (Silent Break)
- **Symptom:** Mappings show empty pills (no error, but field is blank in output); downstream modules produce wrong results silently
- **Root cause:** Source API added, removed, or renamed a field after scenario was built. Old field path now returns nothing.
- **Fix:** Re-run "Determine data structure" on the source module. Re-map all affected downstream fields. Check for empty pills throughout.

---

## TRIG-xxx — Trigger / Scheduling Failures

### TRIG-001 — Webhook Not Receiving Data
- **Symptom:** Scenario never triggers; no incoming data in webhook history
- **Root cause:** Wrong webhook URL pasted into external service; webhook not saved; Make scenario inactive
- **Fix:** Copy webhook URL fresh from Make module. Paste into external service and save. Verify scenario is active. Test with a manual trigger/test call.

### TRIG-002 — Scheduled Run Missed
- **Symptom:** Scenario didn't run at expected time
- **Root cause:** Scenario was paused; Make maintenance window; timezone mismatch in schedule config; previous run still executing when next slot hit
- **Fix:** Verify scenario is active (not paused). Use UTC in scheduling. Enable "Sequential processing" only if runs must not overlap. Check if scenario auto-disabled after consecutive failures.

### TRIG-003 — Polling Trigger Set to "Scheduled" Instead of "Immediately"
- **Symptom:** Webhook data piles up; processing delayed; queue grows
- **Root cause:** Scenario scheduling set to "Run on schedule" instead of "Run immediately as data arrives"
- **Fix:** Scenario settings → Scheduling → set to "Run immediately as data arrives" (instant trigger mode).

### TRIG-004 — Webhook Queue Overflow
- **Symptom:** Webhooks start dropping after >10,000 pending
- **Root cause:** Scenario processing too slow for incoming webhook rate; queue maxes out
- **Fix:** Simplify scenario to reduce execution time. Add a "Router + immediate ack" pattern: webhook → immediately return 200, push to queue/datastore → separate scenario processes async.

### TRIG-005 — Wrong Epoch on First Activation
- **Symptom:** Scenario reprocesses old records on first run, or misses recent ones
- **Root cause:** "Choose where to start" epoch set incorrectly on polling trigger activation
- **Fix:** On first activation, use "Choose where to start" and set to "From now on" (or specific timestamp) to avoid reprocessing history.

### TRIG-006 — Scenario Auto-Disabled After Consecutive Failures
- **Symptom:** Scenario shows as "inactive"; was working before
- **Root cause:** Make auto-disables a scenario after N consecutive full-failure cycles (default threshold ~3)
- **Fix:** Fix the root cause of failures. Re-enable scenario. Optionally raise failure tolerance in scenario settings or add error handlers to prevent full-cycle failures.

### TRIG-007 — Daylight Saving Time Drift
- **Symptom:** Scheduled scenario runs 1 hour early or late after clocks change
- **Root cause:** Cron schedule set in local time; DST shift not accounted for
- **Fix:** Always set schedules in UTC. UTC does not observe DST.

---

## RATE-xxx — Rate Limit / Quota

### RATE-001 — App-Side 429 (Target API)
- **Symptom:** `RateLimitError`; 429 from Google, Slack, Airtable, etc.
- **Root cause:** Scenario hitting target API faster than allowed quota
- **App-specific limits:**
  - Google Sheets: 60 reads/min per user; 300 reads/min per project
  - Airtable: 5 requests/sec per base
  - Slack: Tier 1 (1/min), Tier 2 (20/min), Tier 3 (50/min), Tier 4 (100+/min) per method
  - Telegram Bot API: 30 messages/sec overall; 1 msg/sec to same chat
- **Fix:** Add Sleep module between iterations. Use error handler → Break (retry with backoff). Batch operations where API supports bulk endpoints.

### RATE-002 — Make Operations Quota
- **Symptom:** "Your plan's operations limit has been reached"; scenario disabled
- **Root cause:** Monthly operation count exceeded for the Make plan
- **Plan limits (verify on Make pricing page — changes frequently):**
  - Core: ~10,000 ops/month
  - Pro: ~10,000 + add-ons
  - Teams: ~10,000 + add-ons
- **Fix:** Upgrade plan. Audit scenario for unnecessary operations (each module execution = 1 operation). Combine steps where possible. Wait for monthly reset.

### RATE-003 — Make Data Transfer Quota
- **Symptom:** Scenario soft-warns then hard-stops on data transfer
- **Root cause:** Monthly data transfer limit exceeded
- **Approximate limits:** Core ~5 GB, Pro ~20 GB, Teams ~70 GB
- **Fix:** Upgrade plan. Reduce payload sizes (pass IDs/URLs instead of binary content). Use streaming patterns.

### RATE-004 — Make Per-Connection Rate Cap
- **Symptom:** 429 or throttle from Make itself (not the target app), intermittent
- **Root cause:** Make's internal per-connection rate limiting
- **Fix:** Spread load across multiple connections to the same service. Reduce scenario frequency.

---

## EXEC-xxx — Execution Limits

### EXEC-001 — 40-Second HTTP Timeout
- **Symptom:** HTTP module times out; long-running API calls fail
- **Root cause:** Make's default HTTP module timeout is 40 seconds. Long operations (video generation, large file processing) exceed this.
- **Fix:** Raise HTTP module timeout in advanced settings (max 300s). For operations >300s: use async pattern — fire-and-forget HTTP POST to a separate webhook scenario, return immediately, let the separate scenario handle the long operation and notify when done.

### EXEC-002 — 40-Minute Scenario Execution Limit
- **Symptom:** Scenario times out mid-execution on large iterators
- **Root cause:** Scenario has run for 40 minutes total
- **Fix:** Split into "mini scenarios" chained via webhooks. Use pagination with state stored in a data store.

### EXEC-003 — No Error Handler — Cascade Failure
- **Symptom:** One module failure stops the entire scenario
- **Root cause:** No error handler on the failing module; default behavior is halt
- **Fix:** Right-click the module → "Add error handler" → choose: Resume (continue with fallback), Ignore (skip and continue), Break (retry later), Rollback (undo), Commit (force commit partial state).

### EXEC-004 — Incomplete Executions Queue
- **Symptom:** Operations consumed faster than expected; "Incomplete executions" count growing
- **Root cause:** Scenarios failing but not erroring cleanly — each incomplete execution consumes ops toward quota
- **Fix:** Add error handlers to fail fast cleanly. Clear the incomplete executions queue. Fix root cause to prevent accumulation.

### EXEC-005 — Parallel Execution Race Condition
- **Symptom:** Duplicate records, wrong order, state corruption in data store
- **Root cause:** "Allow parallel executions" enabled with non-idempotent operations
- **Fix:** Disable parallel executions for scenarios that write to shared state. Or make all writes idempotent (upsert by key, not create).

---

## ROUTER-xxx — Router / Filter Logic

### ROUTER-001 — First-Match Route Order
- **Symptom:** Wrong route taken; more specific condition should win but doesn't
- **Root cause:** Make router takes the **first matching route** — order matters. A broad condition before a specific one catches everything.
- **Fix:** Reorder routes — most specific conditions first, fallback/catch-all last.

### ROUTER-002 — No Fallback Route
- **Symptom:** Bundles silently lost when no route condition matches; no error raised
- **Root cause:** Router has no "else"/fallback route
- **Fix:** Add a final route with no filter condition as catch-all. Log or alert in this route for unexpected cases.

### ROUTER-003 — Filter Always False
- **Symptom:** Nothing passes through a filter; scenario ends early with no output
- **Root cause:** Filter condition never true — wrong field reference, type mismatch in comparison, blank operand
- **Fix:** Temporarily disable the filter to confirm data flows. Enable "Dev Tools" in Make to inspect bundle values. Check comparison types (string "5" vs number 5).

### ROUTER-004 — AND/OR Logic Grouping Confusion
- **Symptom:** Filter passes cases it shouldn't, or blocks cases it should pass
- **Root cause:** Make filter groups: OR conditions on same row, AND between rows. Easy to misconfigure.
- **Fix:** Re-read filter as: `(row1_cond1 OR row1_cond2) AND (row2_cond1 OR row2_cond2)`. Restructure rows to match intended logic.

### ROUTER-005 — Type Coercion in Filter
- **Symptom:** `"05" == 5` unexpectedly false; `"5" == 5` true — inconsistent behavior
- **Root cause:** Make does some implicit coercions but not all
- **Fix:** Normalize values before comparison. Use `parseNumber()` or `toString()` to make types explicit in filter operands.

---

## ITER-xxx — Iterator / Aggregator

### ITER-001 — Iterator Over Empty Array
- **Symptom:** Iterator produces zero cycles; aggregator emits empty; downstream skipped silently
- **Root cause:** Source array is empty (zero records from search, empty API response)
- **Fix:** Add a filter after the source module checking `length({{array}}) > 0` before the iterator. Or handle empty output downstream with a fallback.

### ITER-002 — Wrong Aggregator Source Module
- **Symptom:** Aggregator outputs only 1 bundle regardless of iterator cycles
- **Root cause:** Aggregator's "Source Module" is set to the wrong module (not the iterator)
- **Fix:** Open aggregator settings → set "Source Module" to the iterator (or the trigger if iterating bundles).

### ITER-003 — Nested Iterators Cross-Linked
- **Symptom:** Inner aggregator consuming outer iterator's bundles, or vice versa
- **Root cause:** Inner aggregator "Source Module" pointing to outer iterator
- **Fix:** Inner aggregator must target inner iterator. Outer aggregator must target outer iterator. Draw the nesting explicitly before building.

### ITER-004 — Wrong Aggregator Type
- **Symptom:** Type errors in aggregator; coerce errors
- **Root cause:** Array Aggregator used where Text Aggregator needed (or vice versa)
- **Fix:** Array Aggregator → for collecting items into an array. Text Aggregator → for joining strings. Numeric Aggregator → for sum/min/max/average.

### ITER-005 — Bundle Order Not Guaranteed
- **Symptom:** Output order inconsistent across runs
- **Root cause:** Make does not guarantee bundle order when coming from parallel paths
- **Fix:** Sort output after aggregation if order matters.

---

## BLUEPRINT-xxx — Blueprint / Schema Errors

### BLUEPRINT-001 — `isinvalid: true` on API Push
- **Symptom:** Make API returns `"isinvalid": true` on scenario update; scenario broken after push
- **Root cause:** Blueprint JSON has structural errors: invalid module IDs in flow/route references, missing connection IDs, bad field references, malformed mapper expressions
- **Fix:** Check all `"id"` references in `flow` and `routes` arrays match actual module IDs. Verify all connection IDs exist (`GET /api/v2/connections`). Validate JSON structure. Push incrementally — one change at a time to isolate.

### BLUEPRINT-002 — Connection ID Not Found in Target Account
- **Symptom:** Module shows as "disconnected" or red after blueprint push; connection picker empty
- **Root cause:** Blueprint references a connection ID that belongs to a different Make account or has been deleted
- **Fix:** Get valid connection IDs: `GET /api/v2/connections?teamId={teamId}`. Replace all old connection IDs in blueprint with the correct ones for the target account.

### BLUEPRINT-003 — Broken Field Reference After Module ID Change
- **Symptom:** Fields show `{{undefined}}` or mapping lost; downstream modules have empty pills after push
- **Root cause:** Blueprint edit changed a module's `id`; all mapper expressions referencing `{{oldId.field}}` are now broken
- **Fix:** Before changing any module ID, grep the entire blueprint JSON for the old ID and update all references. Pattern: `{{moduleId.field}}` where `moduleId` is the integer or string ID.

### BLUEPRINT-004 — Mapper Expression Syntax Error
- **Symptom:** Module shows error in visual editor; expression not evaluated
- **Root cause:** Invalid Make formula syntax in mapper field
- **Fix:** Test expressions in Make's formula builder. Common issues: unclosed parentheses, wrong function name, using JS syntax instead of Make functions (`if()` not `? :`).

---

## APP-xxx — App-Specific Error Patterns

### APP-GSHEETS-001 — `Unable to parse range`
- **Symptom:** Google Sheets module fails; "Unable to parse range [name]"
- **Root cause:** Sheet tab renamed, deleted, or column structure changed after scenario was built
- **Fix:** Update the sheet/tab name in the module. Use "Search Rows" with dynamic criteria instead of hardcoded ranges.

### APP-GSHEETS-002 — Empty Cell Returns `__EMPTY__`
- **Symptom:** Unexpected `__EMPTY__` value instead of blank or null
- **Root cause:** Make's Google Sheets module returns `__EMPTY__` for empty cells (not null or "")
- **Fix:** Filter: `ifempty({{cell}}; if({{cell}} = "__EMPTY__"; ""; {{cell}}))`. Or use `replace({{cell}}; "__EMPTY__"; "")`.

### APP-TELEGRAM-001 — Bot Token Invalid
- **Symptom:** Telegram module returns 401 "Unauthorized"
- **Root cause:** Bot token regenerated in BotFather; old token revoked
- **Fix:** Get new token from BotFather. Update the Telegram connection in Make with the new token.

### APP-TELEGRAM-002 — Message to Bot in Group Without Admin Rights
- **Symptom:** Telegram module fails sending to group chat
- **Root cause:** Bot is not a member or lacks send permissions in the group
- **Fix:** Add bot to the group, grant admin rights if needed.

### APP-AIRTABLE-001 — `INVALID_VALUE_FOR_COLUMN`
- **Symptom:** Airtable create/update fails with type validation error
- **Root cause:** String passed to number field, invalid select option, wrong linked record format
- **Fix:** Map types explicitly. For linked records: pass an array of record IDs `["recXXX"]`, not names. Pre-create select options in Airtable base.

### APP-AIRTABLE-002 — Attachment URL Expired
- **Symptom:** Airtable attachment URL works immediately but fails hours later
- **Root cause:** Airtable attachment URLs expire in ~2 hours
- **Fix:** Re-fetch the record when you need the attachment URL. Do not store URLs long-term — store record IDs and re-fetch.

### APP-SLACK-001 — `channel_not_found` / `not_in_channel`
- **Symptom:** Slack module fails; channel not found despite correct channel name
- **Root cause:** Bot is not a member of the channel
- **Fix:** In Slack: `/invite @YourMakeBot` in the target channel. Or use `channel ID` (starts with `C`) instead of name — more stable.

### APP-SLACK-002 — `invalid_blocks`
- **Symptom:** Slack Block Kit message fails
- **Root cause:** Block Kit JSON is malformed
- **Fix:** Validate JSON in Slack's Block Kit Builder before pasting into Make. Common issues: missing `type` field, wrong block structure.

### APP-GMAIL-001 — OAuth Scope Forced Re-Consent
- **Symptom:** Gmail connection works then randomly fails with 403
- **Root cause:** Google forces re-consent ~6 months for unverified OAuth apps with sensitive scopes
- **Fix:** Reauthorize the connection when prompted. For production: verify the OAuth app in Google Console to avoid forced re-consent.

### APP-GMAIL-002 — Daily Sending Quota Exceeded
- **Symptom:** Gmail send module fails; "Daily user sending quota exceeded"
- **Root cause:** Free Gmail: 500 emails/day. Google Workspace: 2000/day.
- **Fix:** Use Google Workspace account. Switch to SendGrid/Mailgun for high-volume sends via HTTP module. Use Gmail API with service account for higher limits.

### APP-STRIPE-001 — Webhook Signature Mismatch
- **Symptom:** Stripe webhook received but scenario rejects it immediately
- **Root cause:** Endpoint secret in Make doesn't match the secret from Stripe Dashboard → Webhooks
- **Fix:** Match Live vs Test environment endpoint secrets exactly. Never mix Live and Test secrets.

### APP-STRIPE-002 — `idempotency_key already used with different params`
- **Symptom:** Stripe API rejects retry attempt
- **Root cause:** Same idempotency key reused with different request parameters
- **Fix:** Generate unique idempotency key per logical operation. Use a combination of record ID + operation type + timestamp.

### APP-VERTEXAI-001 — Wrong Connection Type
- **Symptom:** Vertex AI module returns 403 despite valid Google account connection
- **Root cause:** Generic "My Google connection" lacks Vertex AI API scopes
- **Fix:** Create a dedicated "Google Vertex AI" connection in Make → Connections. Authorize with the same Google account — Vertex AI requires specific OAuth scopes that the generic connection doesn't have.

### APP-VERTEXAI-002 — GCS URI Required for Video Output
- **Symptom:** Video generation module fails or doesn't return downloadable URL
- **Root cause:** Veo model outputs to Google Cloud Storage — a `storageUri` parameter (`gs://bucket/path/`) is required. Output is a GCS URI, not a public URL.
- **Fix:** Create a GCS bucket. Pass `storageUri: gs://your-bucket/videos/`. To deliver via Telegram: either make the GCS object public-read (build URL: `https://storage.googleapis.com/bucket/filename`) or generate a signed URL.

---

## PATTERN-xxx — Cross-Cutting Failure Patterns

### PATTERN-001 — Schema Drift (Silent Break)
- **Description:** Source API changes its response schema (field renamed, added, removed). Old mappings silently return empty. No error raised.
- **Detection:** Scenario runs without error but output is blank or wrong. Empty pills in module config.
- **Fix:** Re-run "Determine data structure". Audit all field mappings. Set up monitoring on key output fields.

### PATTERN-002 — Eventual Consistency Race
- **Description:** Trigger fires before the source record is fully written. Follow-up "Get Record" returns 404 or partial data.
- **Example:** Stripe `payment_intent.created` webhook fires → Make immediately fetches customer → customer not yet propagated.
- **Fix:** Add Sleep 2-5 seconds after trigger before fetching. Or add error handler → Break (retry after delay).

### PATTERN-003 — Webhook Replay Without Dedupe
- **Description:** Webhook sent multiple times (retry logic in sender), scenario processes duplicate payload → duplicate records created.
- **Fix:** Implement data store dedupe: store unique event ID (webhook ID, transaction ID), check on each run, skip if already processed.

### PATTERN-004 — Timezone Mismatch
- **Description:** Make uses UTC internally. Source app uses local time. Date filters, comparisons, and schedule triggers drift by timezone offset.
- **Fix:** Always use UTC in Make. Convert source timestamps with `parseDate({{x}}; "YYYY-MM-DDTHH:mm:ssZ")` before comparison. Schedule in UTC.

### PATTERN-005 — Pagination Missing
- **Description:** Search module returns only first page. Subsequent pages silently ignored. Data appears correct but is incomplete.
- **Fix:** Add iterator with cursor/offset. Loop until `next_cursor` is empty or result count < page size.

### PATTERN-006 — Fire-and-Forget for Long Operations
- **Description:** Any operation >40s (video generation, large export, batch processing) will timeout in synchronous execution.
- **Pattern:** Scenario A: receive trigger → validate → HTTP POST to Scenario B webhook (fire-and-forget, `parseResponse: false`) → return immediately. Scenario B: webhook → do the long work → notify user when complete.
- **Used for:** Vertex AI video generation, large file processing, bulk exports.

### PATTERN-007 — Incomplete Execution Queue Leak
- **Description:** Scenarios fail with error handler → Break, queuing incomplete executions. Queue fills → ops consumed toward plan quota → plan cap hit prematurely.
- **Fix:** Monitor incomplete executions count. Clear queue regularly. Fix root cause so Break is not needed long-term.

### PATTERN-008 — Shared OAuth App Throttle
- **Description:** Make's shared OAuth apps for Google/Microsoft hit global rate caps across all Make users. Causes intermittent 429/403 even at low personal usage.
- **Fix:** Register your own OAuth app (Google Console, Azure), configure in Make as "Custom App" connection.

---

## Error Handler Reference

| Directive | Behavior | Use When |
|-----------|----------|----------|
| `Resume` | Continue with fallback bundle | You have a safe default to use when module fails |
| `Ignore` | Skip module, continue scenario | Module failure is acceptable, data loss OK |
| `Break` | Pause execution, retry later | Transient failure (429, 503) — want automatic retry |
| `Rollback` | Undo transactional operations, halt | Must ensure atomicity (financial, data integrity) |
| `Commit` | Force-commit partial state, halt cleanly | Partial progress should be saved even on failure |

**Default (no handler):** Scenario halts, logs error, counts toward auto-disable threshold.

---

## Taxonomy Changelog

| Date | Change | Source |
|------|--------|--------|
| 2026-06-15 | v1.0 — Initial draft | Research corpus + Make docs + community forum |
