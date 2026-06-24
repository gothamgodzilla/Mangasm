#!/usr/bin/env node
/**
 * Mangasm outreach MCP — personalized invites vs popular apps (safer, not ads spam).
 * Skip prototype banners; produce 1:1 style pitches for real outreach.
 */
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const COMPETITORS = {
  grindr: {
    name: "Grindr",
    pains: ["blank profiles", "spam bots", "no real safety layer", "hookup-only vibe"],
    mangasmWins: ["reputation gate", "event consent model", "18+ logged consent", "block/report wired"],
  },
  scruff: {
    name: "Scruff",
    pains: ["paywall for basics", "dated UX", "weak event safety"],
    mangasmWins: ["luxury UX", "community events with approval flow", "M+ via StoreKit"],
  },
  sniffies: {
    name: "Sniffies",
    pains: ["anonymous map anxiety", "location overshare", "no reputation"],
    mangasmWins: ["privacy zones", "no raw location display", "vouch system"],
  },
  adam4adam: {
    name: "Adam4Adam",
    pains: ["desktop-era clutter", "low trust signals"],
    mangasmWins: ["mobile-native", "invitation-only positioning", "encrypted transit path"],
  },
};

function pitch({ app = "grindr", name = "there", city = "", pain = "" }) {
  const c = COMPETITORS[app.toLowerCase()] ?? COMPETITORS.grindr;
  const extra = pain ? ` You mentioned ${pain} — that's exactly what we designed around.` : "";
  const place = city ? ` in ${city}` : "";
  return {
    subject: `${name}, safer than ${c.name}${place}`,
    message:
      `Hey ${name} — if ${c.name} has been wearing thin (${c.pains.slice(0, 2).join(", ")}), ` +
      `Mangasm is built different: ${c.mangasmWins.join(", ")}.${extra} ` +
      `Invitation-only on iOS — not another spam grid. Worth a look: https://apps.apple.com/app/mangasm/id6776317775`,
    competitor: c.name,
    safetyPoints: c.mangasmWins,
  };
}

function compare(apps = ["grindr", "scruff"]) {
  return apps.map((key) => {
    const c = COMPETITORS[key.toLowerCase()];
    if (!c) return { app: key, error: "unknown competitor" };
    return { app: c.name, theirWeaknesses: c.pains, mangasmAdvantages: c.mangasmWins };
  });
}

const server = new Server(
  { name: "mangasm-outreach", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "mg_outreach_pitch",
      description:
        "Personalized invite vs a popular app (Grindr, Scruff, Sniffies, Adam4Adam). Safer positioning — not generic ads.",
      inputSchema: {
        type: "object",
        properties: {
          competitor: { type: "string", enum: ["grindr", "scruff", "sniffies", "adam4adam"] },
          recipient_name: { type: "string" },
          city: { type: "string" },
          personal_pain: { type: "string", description: "What they dislike about the other app" },
        },
        required: ["competitor"],
      },
    },
    {
      name: "mg_competitor_compare",
      description: "Matrix: Mangasm safety advantages vs named competitors",
      inputSchema: {
        type: "object",
        properties: {
          apps: {
            type: "array",
            items: { type: "string" },
            description: "e.g. ['grindr','sniffies']",
          },
        },
      },
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (req) => {
  const { name, arguments: args } = req.params;
  if (name === "mg_outreach_pitch") {
    const result = pitch({
      app: args?.competitor,
      name: args?.recipient_name ?? "friend",
      city: args?.city ?? "",
      pain: args?.personal_pain ?? "",
    });
    return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
  }
  if (name === "mg_competitor_compare") {
    const result = compare(args?.apps ?? ["grindr", "scruff", "sniffies"]);
    return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
  }
  throw new Error(`Unknown tool: ${name}`);
});

const transport = new StdioServerTransport();
await server.connect(transport);