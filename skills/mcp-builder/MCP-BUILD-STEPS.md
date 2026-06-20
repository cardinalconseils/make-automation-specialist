# mcp-builder — Scaffold Steps and File Templates

Reference file for `skills/mcp-builder/SKILL.md`.

## Scaffold Steps

1. Fetch the service's API documentation (ask user for URL if needed)
2. Identify the 3–5 most useful API operations for the automation use case
3. Generate minimal MCP server code

Generated structure:
```
.make/mcp-servers/{service-slug}/
  package.json
  tsconfig.json
  src/
    index.ts       ← MCP server entry point
    tools.ts       ← tool definitions
    client.ts      ← API client wrapper
  README.md        ← setup and registration instructions
  .env.example     ← required environment variables
```

## Template: `src/index.ts`

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { tools, handleToolCall } from "./tools.js";

const server = new Server(
  { name: "{service-slug}-mcp", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler("tools/list", async () => ({ tools }));
server.setRequestHandler("tools/call", handleToolCall);

const transport = new StdioServerTransport();
await server.connect(transport);
```

## Template: `src/tools.ts`

```typescript
export const tools = [
  {
    name: "{service}_{operation}",
    description: "{plain-language description}",
    inputSchema: {
      type: "object",
      properties: { /* { field }: { type, description } */ },
      required: []
    }
  }
];

export async function handleToolCall(request: any) {
  const { name, arguments: args } = request.params;
  // Route to handler by tool name
}
```

## Template: `README.md`

```markdown
# {Service} MCP Server — Generated {date}

## Setup

1. `cd .make/mcp-servers/{service-slug} && npm install && npm run build`

2. Add to `.claude/settings.json`:
   \`\`\`json
   { "mcpServers": { "{service-slug}": {
     "command": "node",
     "args": [".make/mcp-servers/{service-slug}/dist/index.js"],
     "env": { "{SERVICE}_API_KEY": "${SERVICE_API_KEY}" }
   }}}
   \`\`\`

3. Add to `.env`: `{SERVICE}_API_KEY=your_api_key_here`
4. Restart Claude Code.

## Tools Available

| Tool | Description |
|------|-------------|
{tool-table}
```

Common MCP setup snippets: see `skills/mcp-builder/MCP-COMMON-CONFIGS.md`
