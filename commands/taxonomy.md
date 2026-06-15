# Command: /taxonomy

Manage the Make Failure Taxonomy — view, search, or add patterns.

## Usage

```
/taxonomy
/taxonomy search [query]
/taxonomy add
/taxonomy audit
```

## Subcommands

| Subcommand | Description |
|-----------|-------------|
| `/taxonomy` | Show taxonomy summary and category index |
| `/taxonomy search [term]` | Find all patterns matching a keyword |
| `/taxonomy add` | Add a new pattern (guided interview) |
| `/taxonomy audit` | Audit all entries for format consistency and duplicates |

## Examples

```
/taxonomy search 429
/taxonomy search Google Sheets
/taxonomy add
/taxonomy audit
```

## Agent Dispatched
`taxonomy-curator`

## File Modified
`taxonomy/make-failure-taxonomy.md`
