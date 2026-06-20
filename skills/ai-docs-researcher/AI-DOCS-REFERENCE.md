# AI Docs Reference — Models, Fallbacks, Connections, Output Contract

## Current Model Reference (August 2025 baseline — always verify with live lookup)

Use the MCP lookup as the source of truth. This table is a starting point only.

| Provider | Model tier | Make.com module available? | Notes |
|----------|-----------|--------------------------|-------|
| Anthropic | Claude Haiku 3 | Check via lookup | Best for classification, bulk |
| Anthropic | Claude Sonnet 4 | Check via lookup | Best balance quality/cost |
| Anthropic | Claude Opus 4 | Check via lookup | Highest capability |
| OpenAI | gpt-4o-mini | Check via lookup | Cheap, fast |
| OpenAI | gpt-4o | Check via lookup | Strong general purpose |
| OpenAI | o1 / o3 | Check via lookup | Reasoning models |
| Google | gemini-1.5-flash | Check via lookup | Fast, multimodal |
| Google | gemini-1.5-pro | Check via lookup | Large context |
| Mistral | mistral-small | Check via lookup | European data residency |

**Always call `app-module_get` to get the current model enum. Never hardcode model IDs.**

---

## HTTP Module Fallback (when no native module exists)

If a provider has no native Make.com module:

1. Check if the provider has an OpenAI-compatible API (most do)
2. If yes: use OpenAI module with custom `base_url`
3. If no: use HTTP > Make a Request

Document in plan:
```
NO NATIVE MODULE: {provider}
Using HTTP module. Auth via: {API key in Authorization header}
Endpoint: {provider's API base URL}
Compatibility note: {OpenAI-compatible / custom format}
```

---

## Connection Verification

After module lookup, verify the connection exists:

```
mcp__claude_ai_Make__connections_list
  → filter for connections matching the AI app slug
```

If not found:
```
MISSING CONNECTION: {Provider}
You'll need to add your {Provider} API key to Make.com before building.
Step-by-step: Connections → Add → {Provider} → paste your API key.
Where to get your API key: {provider's API key page — plain language direction}
```

---

## Output Contract

Return to calling skill/agent:

```json
{
  "ai_module_spec": {
    "app_slug": "...",
    "module_name": "...",
    "connection_available": true,
    "models_available": ["model-id-1", "model-id-2"],
    "recommended_model": "model-id",
    "required_fields": [],
    "optional_fields": [],
    "tool_use_supported": false,
    "json_mode_supported": true,
    "rate_limits": {},
    "ops_per_call": 1,
    "quirks": []
  }
}
```
