# Phase 3 — Semantic Layer (Smart Connections)

Parent plan: [Obsidian + Local LLM + MCP — Build Plan](obsidian-local-llm-mcp-plan.md)

**Context for this phase:** entirely local, entirely inside Obsidian — Smart Connections is a community plugin that builds a vault-wide embedding index and surfaces semantically related notes as you write, plus semantic (not keyword) search. It needs a model to turn note text into embedding vectors.

**Correction (2026-09-18):** this doc originally said to point Smart Connections at local Ollama running `nomic-embed-text`, per the Phase 2 decision. That's no longer accurate — Smart Connections restructured its plugin tiers, and **choosing a custom embedding provider (including a local Ollama endpoint) is now a Pro/paid feature.** The free core plugin instead ships its own bundled local embedding model (runs on-device via transformers.js, zero setup, no server, no API key) and doesn't expose the provider dropdown to point it elsewhere.

**Decision: use Smart Connections' free bundled embedding model, not Ollama.** It's still fully local and private — same property the Phase 2 decision was protecting — just a different (smaller, plugin-managed) model than `nomic-embed-text`. Don't try to wire up Ollama for this plugin. `nomic-embed-text` in Ollama isn't wasted, though: Copilot for Obsidian (Phase 4, already installed) is a separate free/open-source plugin that does support pointing at a local Ollama endpoint, so that pull carries forward to Phase 4 instead.

**Depends on:** nothing from Phase 2 for this phase specifically — Smart Connections' free embedding model needs no setup at all.

## 1. Install the plugin

1. In Obsidian: **Settings → Community plugins** → make sure "Restricted mode" is off (Community plugins must be enabled).
2. **Browse**, search `Smart Connections`, **Install**, then **Enable**.

## 2. Leave the embedding model on its default

Nothing to configure here, on purpose:

1. In Obsidian: **Settings → Smart Connections** — confirm the embedding model section shows its default local model (name varies by plugin version, e.g. a small bundled transformers.js model) rather than an empty/unset provider.
2. **Do not** try to change the provider to Ollama or any custom endpoint — that option is Pro-gated on the current version, so it either won't be selectable or will prompt an upgrade. That's expected; skip past it.
3. Leave the chat/completion model setting alone for now too — Smart Connections' own chat feature is optional and out of scope here; Phase 4 (Copilot for Obsidian) is what handles vault QA chat, pointed at the cloud API per the Phase 2 decision.

## 3. Build the index

1. Still in Smart Connections settings, find the option to build/refresh the embedding index (wording varies: "Make Connections", "Refresh embeddings", or it may start automatically on enable).
2. **Let it run in the background — don't interrupt it.** It reads every note in the vault, runs each through the bundled local model, and stores the vectors locally (in a `.smart-env` or similar folder inside the vault — this is local storage, nothing leaves your machine).
3. Indexing time scales with vault size and note count, not note length alone. With Phase 1 barely started (a handful of atomic notes) this should be fast — seconds to low minutes.
4. Watch Task Manager during the first full index build the same way Phase 2's reality check did. The bundled model is small, so this is not expected to be a problem, but confirm rather than assume.

## 4. Verify it actually works

Don't just trust "index built" — check the output is sensible:

1. Open two notes you already know are related (same subject, adjacent concepts — if Phase 1's checklist isn't done yet and you don't have 2 related notes yet, this step waits until you do).
2. With one of them open, check Smart Connections' sidebar/pane for "related notes" — the other note should show up, ranked reasonably high.
3. Try Smart Connections' search (semantic search, not Obsidian's built-in keyword search) for a concept phrased differently than how it's worded in your notes (e.g. search "chance of an event" when your note says "probability") — a working semantic index should still surface the right note, since it's matching on meaning, not exact keywords.

If related notes look random or search misses obvious matches, don't move on — re-check that the index actually finished (no error toast, no stuck progress bar), then re-run the index build.

## 5. What this phase does not do yet

- No chat interface — that's Phase 4 (Copilot for Obsidian).
- No MCP/Claude Code access to the vault — that's Phase 5.
- Smart Connections' own optional chat feature is intentionally left unconfigured here, to avoid two different half-configured chat setups before Phase 4 makes the real one.

## Definition of done for Phase 3

- [ ] Smart Connections installed and enabled
- [ ] Embedding model left on its free bundled default (no Ollama wiring attempted — that's Pro-gated)
- [ ] Full vault index built without errors (and without swap-thrashing, per the Task Manager check)
- [ ] Verified: two known-related notes show up as related to each other in the sidebar
- [ ] Verified: a semantic search using different wording than the note's own text still finds the right note

Only move to Phase 4 (Copilot for Obsidian) once this checklist is clean — Copilot's vault QA mode in Phase 4 relies on the same embedding index Smart Connections builds here.
