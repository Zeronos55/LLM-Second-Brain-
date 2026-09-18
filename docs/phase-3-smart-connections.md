# Phase 3 — Semantic Layer (Smart Connections)

Parent plan: [Obsidian + Local LLM + MCP — Build Plan](obsidian-local-llm-mcp-plan.md)

**Context for this phase:** entirely local, entirely inside Obsidian — Smart Connections is a community plugin that builds a vault-wide embedding index and surfaces semantically related notes as you write, plus semantic (not keyword) search. It needs a model to turn note text into embedding vectors; per the [Phase 2 decision](phase-2-local-llm-runtime.md#reality-check-result-2026-09-17-fallback-to-cloud-api--decided), that model is **local Ollama running `nomic-embed-text`** — the one part of the local stack that held up fine on this 8GB machine, unlike the chat model.

**Depends on:** Phase 2 complete (Ollama installed, `nomic-embed-text` pulled — confirm with `ollama list`). Smart Connections does not need `phi4-mini` at all; embeddings-only, so the chat-model swap-thrashing problem from Phase 2 doesn't apply here.

## 1. Install the plugin

1. In Obsidian: **Settings → Community plugins** → make sure "Restricted mode" is off (Community plugins must be enabled).
2. **Browse**, search `Smart Connections`, **Install**, then **Enable**.

## 2. Point it at local Ollama

Smart Connections needs Ollama's server actually running to reach it — same server Phase 2 set up.

1. Make sure Ollama is running: it's installed as a Windows background service, so it should already be up. Confirm with `ollama list` in a terminal (this only lists models; it doesn't itself prove the server is serving, but if `ollama run` worked during Phase 2's reality check, the service is fine).
2. In Obsidian: **Settings → Smart Connections**.
3. Under the embedding model setting, choose **Ollama** (or "Custom/local" — the plugin's wording varies by version) as the provider.
4. Model name: `nomic-embed-text`
5. API/base URL: `http://localhost:11434` (Ollama's default port — the same one from the Phase 2 troubleshooting section).
6. Leave the chat/completion model setting alone for now — Smart Connections' own chat feature is optional and out of scope here; Phase 4 (Copilot for Obsidian) is what handles vault QA chat, pointed at the cloud API per the Phase 2 decision.

## 3. Build the index

1. Still in Smart Connections settings, find the option to build/refresh the embedding index (wording varies: "Make Connections", "Refresh embeddings", or it may start automatically on enable).
2. **Let it run in the background — don't interrupt it.** It reads every note in the vault, sends each to Ollama for an embedding, and stores the vectors locally (in a `.smart-env` or similar folder inside the vault — this is local storage, nothing leaves your machine).
3. Indexing time scales with vault size and note count, not note length alone. With Phase 1 barely started (a handful of atomic notes) this should be fast — seconds to low minutes. It'll get slower as the vault grows, which is expected and fine on an embeddings-only model this small.
4. Watch for the same swap-thrashing signal from Phase 2's reality check (Task Manager → Performance tab) during the first full index build, since that's the heaviest one-time load Ollama will see in this phase. `nomic-embed-text` is small (~275MB resident) so this is not expected to be a problem, but confirm rather than assume.

## 4. Verify it actually works

Don't just trust "index built" — check the output is sensible:

1. Open two notes you already know are related (same subject, adjacent concepts — if Phase 1's checklist isn't done yet and you don't have 2 related notes yet, this step waits until you do).
2. With one of them open, check Smart Connections' sidebar/pane for "related notes" — the other note should show up, ranked reasonably high.
3. Try Smart Connections' search (semantic search, not Obsidian's built-in keyword search) for a concept phrased differently than how it's worded in your notes (e.g. search "chance of an event" when your note says "probability") — a working semantic index should still surface the right note, since it's matching on meaning, not exact keywords.

If related notes look random or search misses obvious matches, don't move on — re-check the base URL/model name in step 2 first (the most common cause is the plugin silently falling back to a different provider or failing to reach Ollama), then re-run the index build.

## 5. What this phase does not do yet

- No chat interface — that's Phase 4 (Copilot for Obsidian).
- No MCP/Claude Code access to the vault — that's Phase 5.
- Smart Connections' own optional chat feature is intentionally left unconfigured here, to avoid two different half-configured chat setups before Phase 4 makes the real one.

## Definition of done for Phase 3

- [ ] Smart Connections installed and enabled
- [ ] Embedding provider set to local Ollama, model `nomic-embed-text`, reachable at `http://localhost:11434`
- [ ] Full vault index built without errors (and without swap-thrashing, per the Task Manager check)
- [ ] Verified: two known-related notes show up as related to each other in the sidebar
- [ ] Verified: a semantic search using different wording than the note's own text still finds the right note

Only move to Phase 4 (Copilot for Obsidian) once this checklist is clean — Copilot's vault QA mode in Phase 4 relies on the same embedding index Smart Connections builds here.
