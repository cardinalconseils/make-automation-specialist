---
name: help-docs
description: Live retrieval of Make.com product documentation from help.make.com, with a local cache. Answers conceptual questions — routers, iterators, error-handler directives, operations and billing, AI Agent semantics, plan limits — that the MCP module docs do not cover. Always cites the source URL.
allowed-tools: Read, Write, Bash, Glob, Grep, WebFetch, mcp__firecrawl__firecrawl_search, mcp__firecrawl__firecrawl_scrape
---

# Skill: help-docs

Fetches Make.com product documentation from `help.make.com` on demand and caches it
locally, so conceptual answers come from the current docs instead of from memory.

## Scope boundary — read this first

Two doc sources exist and they do not overlap. Using the wrong one is the failure mode
this skill prevents.

| Question | Source | Why |
|---|---|---|
| Exact module field names, parameter types, required vs optional, enum values | **MCP** `app-module_get`, `app_documentation_get` | Authoritative — reflects the live connector schema |
| Concepts, semantics, limits, billing, behaviour: routers, iterators/aggregators, error-handler directives, operations counting, data stores vs data structures, AI Agents, plan limits, scheduling | **help.make.com** (this skill) | Not exposed by the MCP module API |

**MCP wins on any conflict about a field spec.** Prose on help.make.com is often written
against an older connector version. Never override a live module schema with help text.

## Retrieval sequence

### 1. Cache first
Look in `.make/research/help/` for a matching topic:

```bash
ls .make/research/help/ 2>/dev/null | grep -i "<topic-keyword>"
```

Each cached file carries frontmatter:

```markdown
---
topic: error-handling-overview
source: https://help.make.com/overview-of-error-handling
page_updated: 21 Aug 2026
fetched: 2026-08-24T14:02:00Z
---
```

If `fetched` is **less than 14 days old**, use it and make no network call. Say you
answered from cache and give the `source` URL.

### 2. Cache miss or stale → fetch

Use `includeDomains`, not a `site:` operator — it filters reliably and the operator does not:

```
mcp__firecrawl__firecrawl_search
  query: "<topic in plain words>"
  includeDomains: ["help.make.com"]
  limit: 5
```

Pick **canonical URLs** from the results. help.make.com search results include
query-parameter-polluted duplicates of the same article
(`...?OLSCode=...&kai=...` — hundreds of junk params); strip the query string and keep
the bare path. Some article URLs are opaque ids (`/64Ex54PN88vgyeJrsX10g`) rather than
slugs — that is normal, keep them as given.

Then scrape the 2–3 most relevant hits:
```
mcp__firecrawl__firecrawl_scrape
  url: <canonical url>
  formats: ["markdown"]
  onlyMainContent: true
```

**`onlyMainContent: true` is not enough on this site.** The docs run on Archbee and every
page still returns the full left-hand nav (~80 links), a trailing table of contents, and
"Docs powered by Archbee" boilerplate. Before caching, keep only from the page's first
`#` heading down to the `Updated <date>` line, and drop the rest. Caching the nav wastes
most of the file on links you already know.

Useful fields on the response: `metadata.title`, `metadata.sourceURL`, and the
`Updated <date>` line in the body — the last is Make's own revision date and belongs in
the cache frontmatter as `page_updated`.

### 3. Write the cache
Slugify the topic (`kebab-case`, no dates in the name — the frontmatter carries the date):

```
.make/research/help/{topic-slug}.md
```

Write the frontmatter above, then the scraped markdown. Overwrite a stale file in place;
do not accumulate dated copies.

### 4. Answer
Return the relevant excerpt **with the source URL**. The URL is what makes the answer
checkable — never drop it, never paraphrase a URL you did not fetch.

## When to call this skill

- Any "how does X work in Make" / "what happens if" / "is X allowed on my plan" question
- Before designing a flow that leans on router, iterator, aggregator, or error-handler
  semantics — getting these wrong is the most common source of silent runtime bugs
- Before estimating operations or cost (billing rules change)
- When `ai-agent-designer` needs current AI Agent / tool-calling behaviour
- When `failure-diagnostician` finds **no taxonomy match** — search help.make.com before
  declaring a new failure pattern

## Degradation — never fabricate

1. No `mcp__firecrawl__*` tools in the session → `WebFetch` on
   `https://help.make.com/` (or a specific known article URL).
2. Neither available → say plainly: *"I can't reach help.make.com in this session."*
   Answer from the MCP module docs and label what is unverified.

Never invent a `help.make.com` URL, and never present remembered doc text as fetched.
A cited URL that 404s is worse than no citation.

## The docs are not infallible

Two observed failure modes, both of which mean **verify against behaviour before betting
a blueprint on a sentence**:

- Pages occasionally carry unpublished editorial or draft text left in the body.
- Prose can lag the connectors. On any conflict about a **field spec**, the live MCP
  module schema wins — see the boundary table above.

Quote the docs for semantics; confirm with `validate_blueprint_schema` or a test run
before relying on an edge case.

## Output format

```markdown
**From help.make.com** — {article title}
{source URL} · fetched {date} {· from cache}

{the answer, in plain language}

{caveat, only if the docs contradict what the MCP module schema says}
```
