# AI Docs Lookup — 5-Step Sequence

## Step 1 — Find the AI app in Make.com

```
mcp__claude_ai_Make__apps_recommend
  input: { "search": "[provider name]" }
```

Search terms per provider:
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

## Step 2 — List all modules for the AI app

```
mcp__claude_ai_Make__app-modules_list
  input: { "appName": "[app slug]" }
```

AI app modules typically include: inference ("Send a Message"), embedding
("Create an Embedding"), vision ("Analyze an Image"), speech-to-text, image generation.

---

## Step 3 — Get the exact module specification

```
mcp__claude_ai_Make__app-module_get
  input: { "appName": "[app slug]", "moduleName": "[module name]" }
```

For AI modules, capture: `model` (enum — every value exactly), `max_tokens`,
`temperature` range, `system` vs `messages` structure, `response_format`,
`tools`/`tool_choice` availability.

---

## Step 4 — Get full app documentation

```
mcp__claude_ai_Make__app_documentation_get
  input: { "appName": "[app slug]" }
```

Extract: auth method, rate limits (RPM/TPM), Make.com-specific quirks.

---

## Step 5 — Produce AI Module Spec Card

```
AI MODULE SPEC: {Provider} — {Module label}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
App slug:     {exact slug}
Module name:  {exact module name}
Connection:   {auth type — API key / OAuth}
Cost:         {n} Make.com operations per call

MODEL ENUM (exact values only — do not improvise)
  {model-id-1}    {context window}    ${input}/1M in / ${output}/1M out

REQUIRED FIELDS
  model           Enum      Must be one of the values above
  messages        Array     [{role: "user", content: "..."}]
  {field}         {type}    {description}

OPTIONAL FIELDS
  system          String    System prompt (if supported)
  max_tokens      Integer   {default} / max {limit}
  temperature     Float     0.0–{max}, default {default}
  response_format Object    {"type": "json_object"} if supported

TOOL USE SUPPORT  {Yes / No}
MULTIMODAL SUPPORT  {Yes / No — which modalities}

RATE LIMITS (from docs)
  requests/min: {n}   tokens/min: {n}

MAKE.COM QUIRKS
  {Any known issues or non-obvious behavior from docs}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
