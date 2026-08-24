# Make.com Agent Tool Gotchas

Traps specific to `ai-local-agent:RunLocalAIAgent` and the tools attached to it.
Split from `make-api-gotchas.md`, which holds the general blueprint traps — the
unifying lesson is the same: **a 200 from the Make API is not evidence.**

---

## Agent tools (`ai-local-agent:RunLocalAIAgent`)

- **`tools` is a SIBLING of `mapper`, never inside it.** Writing `mapper.tools`
  adds an unknown field and leaves the real array untouched: the PATCH returns
  `isinvalid: false`, then Make **deactivates the live scenario** at init.
- **A nested agent needs the parent's full `metadata`** (`expect` + `restore` +
  `parameters`), not just `designer`, or init fails with "1 problem(s) found".
- Output field is **`response`**, not `result`.
- **`iterationsFromHistoryCount` must be 1 for a dispatcher.** At 10 it carries
  prior decisions; having seen a tool refuse a few times it stops calling that
  tool at all — no tool call, successful execution, green log, nothing sent.
- A tool that can succeed while writing nothing becomes the model's escape
  hatch. Every tool should leave a trace when it runs.

### Module bodies that call PostgREST

- **PostgREST maps body keys to function ARGUMENTS.** A function taking one
  `jsonb p` needs `{"p":{…}}`, not the fields at top level.
- …but that nesting ends in `}}`, which **Make's IML parser reads as the end of
  a `{{ }}` expression**, silently making the tool uncallable. Use flat `p_*`
  scalars instead, and assert no stray braces before pushing.
- **Never use a temp table in an RPC.** plpgsql caches plans against its OID and
  PostgREST reuses pooled connections: the first call in a session works, every
  later one raises. Looks like "works by hand, fails from Make", and the raise
  rolls back any log line meant to catch it.

### Pushing and diagnosing

- Use **`curl`**. Python `urllib` is blocked by Cloudflare (403, code 1010).
- When a tool "is not being called", read the Supabase `edge_logs` before
  blaming the model — it names the RPC actually hit. Operation counts cannot
  tell a one-module tool succeeding from a two-module tool refusing at step one.
