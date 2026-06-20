# Output Contract

Return to calling skill/agent:

```json
{
  "pattern_id": "1|2|3|4|5|6|7",
  "pattern_name": "Classify-and-Route|Single-Shot Generator|Chunk-and-Summarize|Structured Extractor|RAG|ReAct Loop|Batch Processor",
  "module_sequence": ["Trigger", "AI Module", "..."],
  "prompt_template": {
    "system": "...",
    "user": "..."
  },
  "mermaid_diagram": "flowchart ...",
  "ops_per_run_estimate": 5,
  "wiring_notes": ["..."],
  "prerequisites": ["..."]
}
```
