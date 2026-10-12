# Obsidian + Local LLM + MCP — Build Plan

**Status:** Planning — not yet started

**Scope:** a desktop-based AI layer on top of your existing Obsidian vault, which you already use for note-taking.

**Machine:** 8GB RAM total → every model choice below is picked to leave headroom for Obsidian + everything else you have open while studying.

## The architecture, in one picture

```
                     ┌─────────────────────────────┐
                     │      Obsidian Vault          │
                     │  (your existing notes,        │
                     │   plain Markdown + frontmatter)│
                     └──────────────┬────────────────┘
                                     │
        ┌────────────────────────────┼────────────────────────────┐
        │                            │                             │
┌───────▼────────┐        ┌──────────▼─────────┐        ┌──────────▼──────────┐
│ Smart Connections│       │  Copilot for Obsidian│      │ Local REST API plugin │
│ (embeddings/RAG   │       │  (chat sidebar,       │      │ (coddingtonbear)      │
│  index of vault)  │       │   vault QA mode)       │      │  → exposes MCP server │
└───────┬────────┘        └──────────┬─────────┘        └──────────┬──────────┘
        │                            │                             │
        └──────────┐      ┌──────────┘                             │
                    ▼      ▼                                        ▼
              ┌───────────────┐                          ┌────────────────────┐
              │ Ollama (local) │                          │ Claude Code / Claude │
              │ Phi-4-mini 3.8B│                          │ Desktop (MCP client)  │
              │ nomic-embed-text│                         │ — read/write/search   │
              └───────────────┘                          │   your vault directly  │
                                                            └────────────────────┘
```

Ollama is not an alternative to Smart Connections/Copilot — it sits underneath them. Smart Connections and Copilot are Obsidian plugins: they provide the features (the embedding index, the chat sidebar, vault QA mode) but neither one can generate an embedding or a chat reply by itself. Each needs to send that work to an actual model, and you choose where: point them at Ollama running locally (private, free, but limited by your 8GB of RAM), or point them at a cloud API (Claude, GPT, etc. — better quality, no RAM cost, but needs internet and an API key). Same plugins, same features either way — only the backend doing the inference changes. So "switch to a cloud API instead of Ollama" later in this doc means reconfigure Smart Connections/Copilot's model setting, not replace the plugins.

Two separate connection types, both pointed at the same vault:

- **Plugin → Ollama (or cloud API):** Smart Connections and Copilot talk to a model backend for embeddings and chat, entirely inside Obsidian.
- **Plugin → MCP → Claude:** the Local REST API plugin exposes your vault over the Model Context Protocol, so Claude Code (or Claude Desktop, via a bridge) can read, search, and write notes directly — no copy-pasting markdown.

This second path is what genuinely improves on manual copy-paste workflows: MCP lets an AI agent act on the vault itself.

## Phase 1 — Vault foundations (no new tools yet)

> Detailed plan: [Phase 1 — Vault Foundations](phases/phase-1-vault-foundations.md)

Before installing anything, make the vault worth indexing:

- Confirm one consistent structure: folders like `Projects/`, `Study/`, `MOCs/` (maps of content), `Templates/`.
- Add YAML frontmatter to notes you want the AI layer to reason well about — at minimum `tags`, `created`, and a one-line `summary`. Your existing preference for atomic, single-concept cards carries over directly here — it's exactly what makes embedding-based retrieval work well.
- Pick a tagging convention now (e.g. `#stochastic-processes`, `#brownian-motion`) rather than after the index is built — re-tagging later means re-embedding.

This phase costs nothing but time and pays off in every later phase.

## Phase 2 — Local LLM runtime (Ollama)

Ollama is the model backend Smart Connections and Copilot will call in Phases 3–4 (see the clarification above) — this phase just gets it running.

- Install Ollama (`ollama.com`).
- Pull two models, sized for 8GB total RAM:
  - **Chat:** `phi4-mini` (3.8B, Q4_K_M) — ~3.5GB resident, 15–20 tok/s on CPU. This is close to the practical ceiling for an 8GB machine once you account for Obsidian, the OS, and anything else open.
  - **Embeddings:** `nomic-embed-text` — small (~275MB), fast, the standard pairing with Smart Connections.
- Reality check before committing: run `ollama run phi4-mini` once and just chat with it while Obsidian is open normally. If it feels sluggish or your machine starts swapping, don't fight it — reconfigure Smart Connections/Copilot's model backend to a cloud API (you already have Claude access) instead of Ollama. The plugins themselves don't change; only the "fully local/private" property is lost, nothing else breaks.
- Skip anything larger than ~4B params at Q4 on this machine — it's not worth the swap-thrashing.

## Phase 3 — Semantic layer (Smart Connections)

- Install Smart Connections from the Obsidian community plugin browser.
- Point it at your local Ollama embedding endpoint (`nomic-embed-text`).
- Let it build the vault-wide embedding index (this can take a while depending on vault size — let it run in the background, don't interrupt it).
- Once built, it surfaces "related notes" as you write and enables semantic (not keyword) search across the vault — semantic LLM retrieval tends to outperform keyword scoring for this use case, and here it runs locally over the whole vault.

## Phase 4 — Chat layer (Copilot for Obsidian)

- Install Copilot for Obsidian, point it at Ollama (or a cloud key) for chat.
- Use Vault QA mode to ask questions against the whole indexed vault — a recall layer scoped to everything in Obsidian.
- Try its custom prompt templates for recurring actuarial-study tasks (e.g. "generate 5 practice questions from this note," "summarize this chapter into an atomic card").

At this point you've replicated what both articles describe. The rest is the MCP layer, which neither Obsidian-plugin article actually covered — only the second one mentioned it, and only in outline.

## Phase 5 — MCP bridge (the part worth doing carefully)

This is a single plugin, not a separate MCP server to build yourself:

- Install Local REST API by coddingtonbear (`obsidian-local-rest-api` — this is the actively maintained one; it bundles both a REST API and an MCP server, running inside Obsidian on `https://127.0.0.1:27124`).
- In plugin settings, copy your API key.
- Trust the plugin's self-signed cert (download it from `https://127.0.0.1:27124/obsidian-local-rest-api.crt`), or use its plain-HTTP fallback on port 27123 if cert trust is annoying — fine for a strictly local, single-user setup.
- Connect Claude Code (native HTTP MCP support):

  ```
  claude mcp add --transport http obsidian https://127.0.0.1:27124/mcp/ \
    --header "Authorization: Bearer <your-api-key>"
  ```

- If you also want Claude Desktop, it needs a small bridge (`mcp-remote`) in `claude_desktop_config.json`, since Desktop doesn't speak remote HTTP MCP natively — start with Claude Code first since it's the simpler path, add Desktop later only if you want it.
- Once connected, Claude can call tools like `vault_read`, `vault_write`, `vault_patch`, `search_query`, `search_simple`, `tag_list`, and `vault_get_document_map` directly against your notes — meaning you can ask an agent to, say, "read my last 3 stochastic-processes notes, find gaps, and draft a new atomic card filling them in, tagged consistently with the rest," and it can actually do that, not just describe it.

**Security note worth internalizing, not just skipping past:** this opens a local HTTP server with read/write access to your entire vault. Keeping it bound to `127.0.0.1` (the default) means only processes on your own machine can reach it — don't expose the port beyond localhost.

## Phase 6 — Where to improve on what the articles showed

Both source articles stop at "plug it in and chat." Given your actual use case, the higher-leverage moves are:

1. **Template-driven study workflows**, using Text Generator or Copilot's custom prompts: a "chapter → atomic cards" pipeline that takes a longer note and splits it into the single-concept cards you've already found work best for recall.
2. **A standing tagging taxonomy note (a MOC)** that Claude reads via MCP before filing new notes, so machine-filed notes stay consistent with your existing tags instead of drifting into synonyms.
3. **Formula handling:** keep handwritten-LaTeX captures in `Attachments/` and have MCP-driven note generation reference/link to them rather than re-deriving LaTeX from scratch.

## Testing / verification checklist

- [ ] Ollama runs a chat model without visibly degrading normal study-session performance (test with Obsidian + browser open, not idle)
- [ ] Smart Connections index completes and surfaces sensible related notes on a known pair of linked topics
- [ ] Copilot vault QA correctly answers a question whose answer spans 2+ notes (tests retrieval, not just single-note recall)
- [ ] MCP connection from Claude Code can read a note, then write a new one, then confirm it appears in Obsidian
- [ ] Confirm the REST API port is not reachable from outside localhost (sanity check, e.g. `curl` from another device on the same network should fail)

## Open question to revisit later

**Cross-device access:** this whole stack is desktop-only by nature (Ollama and the MCP plugin both run on one machine). If down the line you want the Obsidian side itself synced to iPad/phone (separately from the AI layer), that's a vault-sync problem — Obsidian Sync (paid), iCloud, or Syncthing — not something MCP or these plugins solve. Not needed for this plan, but worth remembering it's a separate concern if priorities shift.
