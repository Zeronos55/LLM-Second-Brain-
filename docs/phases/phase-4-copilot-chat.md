# Phase 4 — Chat Layer (Copilot for Obsidian)

Parent plan: [Obsidian + Local LLM + MCP — Build Plan](../obsidian-local-llm-mcp-plan.md)

**Context for this phase:** Copilot for Obsidian is the chat sidebar and vault-QA layer — the closest thing to a "Recall" tab, but scoped to the whole vault.

**Correction (2026-09-28), important structural point:** Copilot V4 splits chat into two separate surfaces, and this isn't obvious from the settings screen alone:

- **Quick Chat** — a plain chat window, no vault access at all. Confirmed by testing: asking it a cross-note question gets a generic "I don't have context on that" answer, even with notes actually in the vault. It's chat-only, by design.
- **Agent Chat** — the vault-aware surface, with tools to read/search notes. This is what "Vault QA" actually turned into in this version — there's no separate "Vault QA mode" toggle to switch into; vault access lives in Agent Chat instead.

Agent Chat needs a backend, chosen from a "Select your agent" screen: **opencode**, **Claude** (needs an existing Claude Code CLI + Anthropic subscription), or **Codex** (needs an existing ChatGPT/ChatGPT subscription). Since the goal was free, **opencode** is the one that matters here — it supports your own provider key (BYOK), so it can run on the same free Gemini key used for Quick Chat, no separate subscription.

Two separate model slots need configuring, and per the decisions from [Phase 2](phase-2-local-llm-runtime.md#reality-check-result-2026-09-17-fallback-to-cloud-api--decided) and [Phase 3](phase-3-smart-connections.md), they point at different places:

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
6. Under **Settings → Copilot → Basic → Quick Chat models**, confirm the Gemini model is toggled on and set as the **Default model**.

This covers Quick Chat only — a fast, simple chat window with no vault access (confirmed by testing: it can't answer questions about note content, even when the notes exist). For vault-aware chat/QA, continue to step 3 below.

## 3. Set up Agent Chat (opencode + Gemini) for vault-aware QA

This is the part that replaces "build the Vault QA index" from the original plan — Agent Chat's tools search the vault directly rather than requiring a separate pre-built embedding index.

1. Open **Agent Chat** (ribbon icon, or command palette → "Open Copilot Agent Chat Window"). If no default agent is set yet, you'll see a **"Select your agent"** screen.
2. Select **opencode** (marked "Recommended" — supports any provider key, unlike Claude/Codex which need their own paid CLI subscriptions).
3. Click **Configure** → **Managed by Copilot** (lets Copilot download/manage the opencode binary itself) → **Download & install**.
   - **Known Windows issue:** this can fail with `EPERM: operation not permitted, rename ...` — a transient file lock from Windows Defender/an indexer scanning the freshly-downloaded binary during the install's rename step. Just retry (often succeeds on the 2nd attempt); if it keeps failing, temporarily add a Windows Security exclusion for the `~\.obsidian-copilot\opencode` folder, retry, then remove the exclusion.
4. Once installed, configure opencode's model/provider: choose **your own provider key** (not "Copilot-hosted models") and point it at the same Gemini key added in step 2 — no need for a second key.
5. Click **Done**.

Local Ollama (`nomic-embed-text`) never ended up needed for this phase — Agent Chat's vault tools work off opencode+Gemini directly, without a separate embedding-based index the way Smart Connections (Phase 3) works. Ollama stays installed for Phase 3's use, just not consumed here.

## 4. Verify Quick Chat and Agent Chat both work

1. **Quick Chat check:** ask a simple question unrelated to your vault. Confirm the response is fast (cloud API, not local CPU) and actually correct — this is the exact failure mode Phase 2 hit with `phi4-mini` (slow *and* hallucinated), so it's worth explicitly noticing neither problem shows up here on the free Gemini tier either.
2. **Agent Chat check:** ask a question whose answer spans two or more notes (not something answerable from a single note — that tests single-note recall, not real retrieval). Confirmed working example from testing: asking it what's been written about stochastic/stationary processes correctly pulled from vault notes, where the same question in Quick Chat got a generic "I don't have that context" answer.
3. If Agent Chat still doesn't reference vault content, re-check step 3 — most likely opencode wasn't actually pointed at the Gemini key (defaulted to a Copilot-hosted model instead), or the install didn't fully complete.

## 5. Try a custom prompt template (optional, worth doing)

Copilot supports saved custom prompts for recurring actions. Worth trying at least one now to see the shape of it:

- "Generate 5 practice questions from this note"
- "Summarize this chapter into an atomic card" (ties back to the atomic-note discipline from [Phase 1](phase-1-vault-foundations.md))

## Definition of done for Phase 4

- [x] Free Gemini API key created (`aistudio.google.com/apikey`) and saved outside the vault
- [x] Gemini added as the chat provider in Copilot BYOK settings, set as default Quick Chat model
- [x] opencode installed and configured as the Agent Chat backend, pointed at the same free Gemini key (not a Copilot-hosted model)
- [x] Verified: Quick Chat gives a fast, correct answer to a non-vault question (no CPU-maxing, no hallucination — the two problems local `phi4-mini` had)
- [x] Verified: Agent Chat correctly answers a question spanning 2+ notes, where the same question in Quick Chat gets a generic "no context" answer — confirming vault access is real and scoped to Agent Chat specifically

**Phase 4 complete (2026-09-28).** Chat is fully cloud-free-tier (Gemini) and fully free — no paid API credits, no paid Copilot license, no paid Claude/Codex CLI subscription. Local Ollama's `nomic-embed-text` ended up not needed for this phase specifically (Agent Chat's vault tools don't use a separate embedding index the way Smart Connections does), but stays installed for Phase 3.

Move to Phase 5 (MCP bridge) next. That phase connects **Claude Code** (not Gemini, not opencode) to read/write the vault directly via the Local REST API plugin — a separate integration from anything configured here.
