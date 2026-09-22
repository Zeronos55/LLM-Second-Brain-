# Phase 4 — Chat Layer (Copilot for Obsidian)

Parent plan: [Obsidian + Local LLM + MCP — Build Plan](obsidian-local-llm-mcp-plan.md)

**Context for this phase:** Copilot for Obsidian is the chat sidebar and vault-QA layer — the closest thing to a "Recall" tab, but scoped to the whole vault. Two separate model slots need configuring, and per the decisions from [Phase 2](phase-2-local-llm-runtime.md#reality-check-result-2026-09-17-fallback-to-cloud-api--decided) and [Phase 3](phase-3-smart-connections.md), they point at different places:

- **Chat model → cloud API, free tier (Google Gemini).** The Phase 2 reality check showed this 8GB machine can't run a local chat model (`phi4-mini`) without maxing the CPU and producing hallucinated output, so chat needs a cloud model. **Decision (2026-09-22): use Google's Gemini API free tier rather than a paid Claude API key**, since you don't want to pay for API credits. Gemini's free tier requires no credit card and is a real cloud-scale model, so the same CPU-maxing/hallucination problem shouldn't recur. One tradeoff worth knowing: on the free tier, Google may use your prompts/vault content to improve their models — this is off by default on their paid tier. For actuarial study notes this is low-stakes, but worth knowing rather than assuming.
- **Embedding model (for Vault QA's index) → local Ollama, `nomic-embed-text`.** Unlike Smart Connections (Phase 3), which gates custom embedding providers behind Pro, Copilot for Obsidian is free/open-source and supports pointing its embedding model at any OpenAI-compatible endpoint — which includes a local Ollama server, no paid tier required.

**Depends on:** Copilot for Obsidian already installed (done). A free Gemini API key from `aistudio.google.com/apikey` (just a Google account, no billing setup). Ollama running with `nomic-embed-text` pulled (carried over from Phase 2/3 — confirm with `ollama list`).

## 1. Get a free Gemini API key

1. Go to `aistudio.google.com/apikey` and sign in with a Google account.
2. **Create API key.** No credit card or billing setup needed — this puts you straight on the free tier.
3. Copy the key and save it somewhere safe.
4. Free tier limits are generous for one person studying (roughly 10 requests/minute, ~1,500 requests/day on the Flash-tier models as of writing) — plenty for chat + Vault QA use, but if you ever see rate-limit errors, that's what's happening; it resets, no charge involved.

## 2. Add Gemini as the chat provider (BYOK)

1. In Obsidian: **Settings → Copilot → BYOK** (or "Providers," depending on plugin version).
2. **Add a provider** → choose **Gemini** (Google).
3. Paste in the API key from step 1.
4. Model ID: pick a current Flash-tier model (fast, and what the free tier is sized around) — check Copilot's model dropdown for the latest available Gemini Flash model name, since these version numbers change.
5. **Test**, then **Save**. Keys are stored in Obsidian's local keychain on this device, not written into the vault itself — so they won't end up committed to git or synced anywhere unexpected.
6. In Copilot's main chat settings, confirm the **default chat model** is now set to the Gemini model you just added — adding a provider doesn't always auto-select it as the active default.

## 3. Point the embedding model at local Ollama

This is a **separate** setting from the chat model — Copilot uses an embedding model specifically for Vault QA's retrieval index, distinct from whatever generates the chat reply.

1. **Settings → Copilot → QA** (embedding model section, wording may vary by version).
2. Add/select an embedding provider — choose **OpenAI-compatible endpoint** (this is how Copilot reaches Ollama; Ollama exposes an OpenAI-compatible API, it isn't a distinct "Ollama" option in every version).
3. Base URL: `http://localhost:11434/v1`
4. Model name: `nomic-embed-text`
5. API key field: leave blank, or put any placeholder string — Ollama doesn't check it, but some forms require the field to be non-empty.
6. Save.

## 4. Build the Vault QA index

1. In the Copilot chat pane, switch mode to **Vault QA (Basic)**.
2. This triggers indexing — every note gets embedded via the Ollama endpoint from step 3, same idea as Smart Connections' index in Phase 3, but this is Copilot's own separate index.
3. Let it finish without interrupting. Watch Task Manager the first time, same as prior phases — `nomic-embed-text` is small, so this shouldn't be heavy, but confirm rather than assume, especially since this is a second embedding pass on top of Smart Connections' (they don't share an index).

## 5. Verify chat and Vault QA both work

1. **Plain chat check:** ask Copilot's chat (not Vault QA mode) a simple question unrelated to your vault. Confirm the response is fast (cloud API, not local CPU) and actually correct — this is the exact failure mode Phase 2 hit with `phi4-mini` (slow *and* hallucinated), so it's worth explicitly noticing that neither problem shows up here on the free Gemini tier either.
2. **Vault QA check:** switch to Vault QA (Basic) mode, and ask a question whose answer spans two or more notes (not something answerable from a single note — that would only test single-note recall, not retrieval across the index). Confirm the answer draws on the right notes and cites sources.
3. If Vault QA gives an empty or generic answer, re-check step 3's base URL/model name first — the most common cause is the embedding endpoint silently failing and the index building on nothing.

## 6. Try a custom prompt template (optional, worth doing)

Copilot supports saved custom prompts for recurring actions. Worth trying at least one now to see the shape of it:

- "Generate 5 practice questions from this note"
- "Summarize this chapter into an atomic card" (ties back to the atomic-note discipline from [Phase 1](phase-1-vault-foundations.md))

## Definition of done for Phase 4

- [ ] Free Gemini API key created (`aistudio.google.com/apikey`) and saved outside the vault (password manager, etc.)
- [ ] Gemini added as the chat provider in Copilot BYOK settings, a Flash-tier model selected, set as default chat model
- [ ] Embedding model set to local Ollama (`nomic-embed-text` via `http://localhost:11434/v1`) under Copilot's QA settings
- [ ] Vault QA index built without errors
- [ ] Verified: plain chat gives a fast, correct answer (no CPU-maxing, no hallucination — the two problems local `phi4-mini` had)
- [ ] Verified: a Vault QA question spanning 2+ notes gets answered correctly with source citations

Only move to Phase 5 (MCP bridge) once this checklist is clean. At that point Phases 2–4 are all wired the way the plan settled on: free cloud Gemini for chat, local Ollama for embeddings, two separate plugin-managed indexes (Smart Connections' free bundled model, Copilot's Ollama-backed one) coexisting in the same vault.

**Note:** MCP in Phase 5 connects Claude Code specifically (not Gemini) to read/write the vault directly — that's a separate integration from Copilot's in-app chat model, so this free-tier choice for Copilot doesn't affect or replace Phase 5's Claude Code connection.
