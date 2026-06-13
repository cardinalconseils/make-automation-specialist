---
name: ai-docs-researcher
description: Fetches exact Make.com AI module specifications before any AI agent blueprint is built. Extends docs-researcher specifically for LLM/AI modules (Anthropic, OpenAI, Google AI, Hugging Face, Make.com AI Agent). Returns precise field names, model enums, token limits, and operation costs.
---

# Skill: ai-docs-researcher

Specialized extension of `docs-researcher` for AI/LLM modules in Make.com.

Never guess AI module parameters. Model IDs, parameter names, and enum values change
frequently — a stale assumption breaks the blueprint silently.

---

## When to Call This Skill

Call this skill before designing any scenario that includes:
- An AI model call (Claude, GPT, Gemini, etc.)
- A Make.com AI Agent module
- A Hugging Face inference call
- Any vector embedding operation

Called by `ai-agent-designer` after blueprint draft. Called by `ai-agent-builder` agent before building.

---

## Lookup Sequence for AI Modules

### Step 1 — Find the AI app in Make.com

```
mcp__claude_ai_Make__apps_recommend
  input: { "search": "[provider name]" }
```

Search terms to use per provider:
| Provider | Search term |
|----------|------------|
| Anthropic / Claude | "anthropic" |
| OpenAI / GPT | "openai" |
| Google AI / Gemini | "google ai" OR "gemini" |
| Hugging Face | "hugging face" |
| Make.com AI Agent | "ai agent" |
| Mistral | "mistral" |
| Cohere | "cohere" |
| Perplexity | "perplexity" |

Record the exact app slug returned.

---

### Step 2 — List all modules for the AI app

```
mcp__claude_ai_Make__app-modules_list
  input: { "appName": "[app slug]" }
```

For AI apps, modules typically include:
- "Send a Message" / "Create a Completion" (main inference module)
- "Create an Embedding" (vector operations)
- "Analyze an Image" / "Vision" (multimodal)
- "Transcribe Audio" (speech-to-text)
- "Generate an Image" (text-to-image)

Identify the module that matches the blueprint's AI task type.

---

### Step 3 — Get the exact module specification

```
mcp__claude_ai_Make__app-module_get
  input: { "appName": "[app slug]", "moduleName": "[module name]" }
```

For AI modules, pay special attention to:
- `model` field — this is an **enum** — record every allowed value exactly
- `max_tokens` / `max_output_tokens` — integer limits
- `temperature` — float range (usually 0.0–2.0)
- `system` vs `messages` structure — varies by provider
- `response_format` — JSON mode availability
- `tools` / `tool_choice` — tool use availability

---

### Step 4 — Get full app documentation

```
mcp__claude_ai_Make__app_documentation_get
  input: { "appName": "[app slug]" }
```

Extract:
- Authentication method (API key vs OAuth)
- Rate limits (requests per minute, tokens per minute)
- Known limitations in Make.com integration
- Any Make.com-specific quirks (e.g., message format differences)

---

### Step 5 — Produce AI Module Spec Card

```
AI MODULE SPEC: {Provider} — {Module label}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
App slug:     {exact slug}
Module name:  {exact module name}
Connection:   {auth type — API key / OAuth}
Cost:         {n} Make.com operations per call

MODEL ENUM (exact values only — do not improvise)
  {model-id-1}    {context window}    ${input_price}/1M in / ${output_price}/1M out
  {model-id-2}    ...

REQUIRED FIELDS
  model           Enum      Must be one of the values above
  messages        Array     [{role: "user", content: "..."}]
  {field}         {type}    {description}

OPTIONAL FIELDS
  system          String    System prompt (if supported)
  max_tokens      Integer   {default} / max {limit}
  temperature     Float     0.0–{max}, default {default}
  response_format Object    {"type": "json_object"} if supported
  {field}         {type}    {description}

TOOL USE SUPPORT
  {Yes / No}
  {If yes: tool definition format}

MULTIMODAL SUPPORT
  {Yes / No — which modalities}

RATE LIMITS (from docs)
  {requests/min}: {n}
  {tokens/min}:   {n}

MAKE.COM QUIRKS
  {Any known issues or non-obvious behavior discovered in docs}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Current Model Reference (August 2025 baseline — always verify with live lookup)

Use the MCP lookup as the source of truth. The table below is a starting point for
the interview, not a substitute for `app-module_get`.

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

**Always call `app-module_get` to get the current model enum.** Never hardcode model IDs.

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
    "required_fields": [...],
    "optional_fields": [...],
    "tool_use_supported": false,
    "json_mode_supported": true,
    "rate_limits": {...},
    "ops_per_call": 1,
    "quirks": [...]
  }
}
```
