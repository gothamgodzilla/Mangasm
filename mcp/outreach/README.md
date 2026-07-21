# Mangasm Outreach MCP

Personalized **safety-first** pitches vs Grindr / Scruff / Sniffies / Adam4Adam — not prototype ad spam.

## Install

```bash
cd mcp/outreach   # from the repo root
npm install
```

## Cursor / Grok MCP config

```json
{
  "mcpServers": {
    "mangasm-outreach": {
      "command": "node",
      "args": ["mcp/outreach/index.mjs"]
    }
  }
}
```

## Tools

- `mg_outreach_pitch` — 1:1 invite copy with competitor context
- `mg_competitor_compare` — safety advantage matrix