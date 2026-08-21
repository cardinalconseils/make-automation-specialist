# Make.com API Gotchas

Facts learned the hard way building blueprints through the API. Each one cost at
least an hour. Read before writing blueprint JSON.

The unifying lesson: **a 200 from the Make API is not evidence.** Make accepts
many wrong things, reports `isinvalid: false`, then silently does nothing.

---

## Filters — the operator is singular

`text:contain` and `text:notcontain`. **Not** `contains`/`notcontains`.

The plural is accepted on write, leaves the scenario valid, and matches nothing —
every route silently skipped, no error anywhere.

## `metadata.expect` is mandatory on some modules

| Module | Needs the `expect` array? |
|---|---|
| `http:ActionSendData` | **Yes.** Without it Make ignores `bodyType`, `contentType` and `data` while reporting success — the module "runs" and sends nothing |
| `*:makeAnApiCall` (open-router, github) | No |
| `telegram:*`, `util:*`, `datastore:*` | No |
| `scenario-service:ReturnData` | Yes, and entries must be `{name, type}` only — a stray `label` breaks the outputs |

When cloning a module, copy the whole `metadata` object verbatim, including
`restore.parameters.__IMTCONN__`.

## Where errors actually live

```
GET /api/v2/dlqs?teamId=&scenarioId=      the real error message
GET /api/v2/dlqs/{id}/bundle              which modules completed, and their values
```

The execution log frequently reports only `"status": "WARNING"` with no detail.
`causeModule` in the log names the failing app when present.

Note a scenario with **no error handler** hard-fails (`status 3`) and writes
**nothing** to the DLQ — the error exists only in the execution log.

## Auth failures — first move, not last

```
POST /api/v2/connections/{id}/test
```

`verified: true` means the credential **authenticates**, not that it has the
permissions you need. A GitHub OAuth connection verified cleanly and still could
not write a byte. Only the observable side effect proves access.

Personal access tokens report `expire: null` because Make stores them opaquely —
that is uninformative, not reassuring. It discovers expiry via a 401 at call time.

## Expression traps

- **`&` concat returns empty inside a function argument.** `replace(x; "A"; "p/" & 301.slug & "/")` yields `/`. Put the string in a `util:SetVariable2` template and reference the variable.
- **No regex literals in mappers** — causes `BlueprintValidationError — N problem(s) found` with no module named. Use plain string `replace`.
- **Arrays are 1-indexed**: `choices[1]`, `images[1]`, `unsigned_urls[1]`.
- **`util:SetVariables` (plural) values are not readable as `{{id.name}}`.** Use `util:SetVariable2`, one per value.

## Writing scenarios

- `parameters: null` reads back fine but is **rejected on write** — use `{}`.
- Scheduling must be sent as a JSON **string**: `{"scheduling":"{\"type\":\"on-demand\"}"}`. Required interface inputs force `on-demand`.
- Activate with `POST /scenarios/{id}/start`. `PATCH {"isActive":true}` is rejected.
- `POST /scenarios/{id}/interface` returns `Not found` — use the MCP `scenarios_set-interface`, **and** update `flow[0].metadata.interface`. Both, or the agent sees a stale tool schema.
- `hooks` creation requires `headers`, `method` and `stringify` in the payload.
- **UI saves clobber API pushes.** Close the scenario in the browser first.

## Architecture constraints

- **Module timeout is a hard 40 seconds.** Anything slower must be asynchronous.
- **`scenario-service:CallSubscenario` never binds its inputs when built via the API.** Use a webhook plus HTTP, or attach the scenario as a cloud-agent tool.
- **`parseResponse: true` needs a manual UI run** before `N.data.field` resolves. With `parseResponse: false` the raw body is `{{N.data}}`.
- `gateway:WebhookRespond` **allows execution to continue** — put it first to make a webhook scenario fire-and-forget.
- **`builtin:Ignore` hides the failure from the execution log.** The run then reports `status 1` while doing nothing. If you use it, something else must become the source of truth.
