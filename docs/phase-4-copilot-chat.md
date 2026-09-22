# Phase 4 — Chat Layer (Copilot for Obsidian)

Parent plan: [Obsidian + Local LLM + MCP — Build Plan](obsidian-local-llm-mcp-plan.md)

**Context for this phase:** Copilot for Obsidian is the chat sidebar and vault-QA layer — the closest thing to a "Recall" tab, but scoped to the whole vault. Two separate model slots need configuring, and per the decisions from [Phase 2](phase-2-local-llm-runtime.md#reality-check-result-2026-09-17-fallback-to-cloud-api--decided) and [Phase 3](phase-3-smart-connections.md), they point at different places:

- **Chat model → cloud API (Claude).** The Phase 2 reality check showed this 8GB machine can't run a local chat model (`phi4-mini`) without maxing the CPU and producing hallucinated output. Copilot's chat backend gets configured with your own Claude API key instead (BYOK — bring your own key), same as the plan always intended as the fallback.
- **Embedding model (for Vault QA's index) → local Ollama, `nomic-embed-text`.** Unlike Smart Connections (Phase 3), which gates custom embedding providers behind Pro, Copilot for Obsidian is free/open-source and supports pointing its embedding model at any OpenAI-compatible endpoint — which includes a local Ollama server, no paid tier required.

**Depends on:** Copilot for Obsidian already installed (done). An Anthropic API key from `console.anthropic.com` — separate from any claude.ai subscription; this is metered/pay-as-you-go API usage, billed per token, not the same account as a Claude Pro chat subscription. Ollama running with `nomic-embed-text` pulled (carried over from Phase 2/3 — confirm with `ollama list`).

## 1. Get a Claude API key

1. Go to `console.anthropic.com` → **Settings → API keys**.
2. Create a new key. **Copy it immediately and save it somewhere safe** — the full key is only shown once; if you lose it you'll need to generate a new one.
3. This is a different thing from a claude.ai subscription: API usage is billed separately, per token, based on how much you actually chat. Worth keeping an eye on usage/limits in the console, especially early on, since Vault QA indexing (step 3 below) can use the embedding model a lot on a big vault — though that cost lands on Ollama (free, local), not the Claude API, since only chat goes through Claude.

## 2. Add Claude as the chat provider (BYOK)

1. In Obsidian: **Settings → Copilot → BYOK** (or "Providers," depending on plugin version).
2. **Add a provider** → choose **Anthropic**.
3. Paste in the API key from step 1.
4. Model ID: `claude-sonnet-5` is the sensible default for normal chat/vault-QA use. If Copilot's model list offers a faster/cheaper option for quick lookups later (e.g. a Haiku-family model), that's worth trying for short answers, but start with Sonnet.
5. **Test**, then **Save**. Keys are stored in Obsidian's local keychain on this device, not written into the vault itself — so they won't end up committed to git or synced anywhere unexpected.
6. In Copilot's main chat settings, confirm the **default chat model** is now set to the Anthropic/Claude model you just added — adding a provider doesn't always auto-select it as the active default.

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

1. **Plain chat check:** ask Copilot's chat (not Vault QA mode) a simple question unrelated to your vault. Confirm the response is fast (cloud API, not local CPU) and actually correct — this is the exact failure mode Phase 2 hit with `phi4-mini` (slow *and* hallucinated), so it's worth explicitly noticing that neither problem shows up here.
2. **Vault QA check:** switch to Vault QA (Basic) mode, and ask a question whose answer spans two or more notes (not something answerable from a single note — that would only test single-note recall, not retrieval across the index). Confirm the answer draws on the right notes and cites sources.
3. If Vault QA gives an empty or generic answer, re-check step 3's base URL/model name first — the most common cause is the embedding endpoint silently failing and the index building on nothing.

## 6. Try a custom prompt template (optional, worth doing)

Copilot supports saved custom prompts for recurring actions. Worth trying at least one now to see the shape of it:

- "Generate 5 practice questions from this note"
- "Summarize this chapter into an atomic card" (ties back to the atomic-note discipline from [Phase 1](phase-1-vault-foundations.md))

## Definition of done for Phase 4

- [ ] Anthropic API key created and saved outside the vault (password manager, etc.)
- [ ] Claude added as the chat provider in Copilot BYOK settings, model `claude-sonnet-5`, set as default chat model
- [ ] Embedding model set to local Ollama (`nomic-embed-text` via `http://localhost:11434/v1`) under Copilot's QA settings
- [ ] Vault QA index built without errors
- [ ] Verified: plain chat gives a fast, correct answer (no CPU-maxing, no hallucination — the two problems local `phi4-mini` had)
- [ ] Verified: a Vault QA question spanning 2+ notes gets answered correctly with source citations

Only move to Phase 5 (MCP bridge) once this checklist is clean. At that point Phases 2–4 are all wired the way the plan settled on: cloud Claude for chat, local Ollama for embeddings, two separate plugin-managed indexes (Smart Connections' free bundled model, Copilot's Ollama-backed one) coexisting in the same vault.
