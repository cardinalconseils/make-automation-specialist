# Approval Token Protocol

**Purpose:** Bridge between agent-side approval display and deterministic hook enforcement for Level 3 (destructive) operations.

---

## How it works

The `pre-execute-hook.js` (deterministic) blocks all LEVEL 3 calls unless it finds a valid approval token. The agent (indeterministic) is responsible for displaying the gate, collecting the typed confirmation, and writing the token.

```
User types: DELETE {resource name}
        ↓
Agent shows L3 gate → user types confirmation
        ↓
Agent writes approval token (Bash or Write tool call)
        ↓
Agent calls the destructive Make MCP tool
        ↓
Hook reads and deletes token → exits 0 (allows)
        ↓
Destructive operation proceeds
```

If the agent skips the token write, the hook exits 2 and blocks the call.

---

## Token write (agent responsibility)

After the user types the exact confirmation phrase, write the token:

```bash
mkdir -p .make/logs/.approval-tokens && \
  echo "approved:$(date -u +%Y-%m-%dT%H:%M:%SZ)" > \
  .make/logs/.approval-tokens/{tool_name_sanitized}
```

Where `{tool_name_sanitized}` = tool name with all non-alphanumeric chars replaced by `_`.

Example for `mcp__claude_ai_Make__scenarios_delete`:
```bash
mkdir -p .make/logs/.approval-tokens && \
  echo "approved:$(date -u +%Y-%m-%dT%H:%M:%SZ)" > \
  .make/logs/.approval-tokens/mcp__claude_ai_Make__scenarios_delete
```

---

## Token properties

- **Single-use:** hook deletes the file immediately after reading it
- **TTL:** 120 seconds — stale tokens are ignored and block the call
- **Scope:** per tool name, not per resource — one token per destructive tool call
- **No bypass:** if the user did NOT type the exact confirmation, do NOT write the token

---

## Valid L3 confirmation phrases

| Tool | Required phrase |
|------|----------------|
| `scenarios_delete` | `DELETE {scenario name}` |
| `hooks_delete` | `DELETE {hook name}` |
| `data-stores_delete` | `DELETE {store name}` |
| `data-store-records_delete` | `DELETE {record id}` |
| `data-structures_delete` | `DELETE {structure name}` |
| All other L3 tools | `DELETE {resource name}` |

Any variation → do not write token → hook blocks → start over.
