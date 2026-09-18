# Phase 2 — Local LLM Runtime (Ollama)

Parent plan: [Obsidian + Local LLM + MCP — Build Plan](obsidian-local-llm-mcp-plan.md)

**Context for this phase:** entirely local — nothing in this phase can run from a cloud session, it happens directly on your machine. Ollama isn't a feature by itself; it's the model backend that Smart Connections (Phase 3) and Copilot for Obsidian (Phase 4) will call for embeddings and chat. This phase's only job is getting it installed, getting two right-sized models pulled, and proving your 8GB machine can actually run one without becoming unusable.

**Machine constraint driving every choice below:** 8GB RAM total. Every model pick here leaves headroom for Obsidian, the OS, and a browser open at the same time — this is not a "pick the best model" exercise, it's "pick the largest model that doesn't make your machine swap."

## 1. Install Ollama

Windows (your setup):
- Simplest path: download the installer from `https://ollama.com/download/windows` and run `OllamaSetup.exe`. It installs Ollama as a background service — no separate "start the server" step.
- Alternative via winget: `winget install Ollama.Ollama`

macOS / Linux (for reference, if this ever runs on a different machine):
- macOS: download from `https://ollama.com/download/mac`, or `brew install ollama`
- Linux: `curl -fsSL https://ollama.com/install.sh | sh`

Confirm the install worked in a **new** terminal window (so it picks up the updated PATH):

```
ollama --version
```

## 2. Pull the two models

- **Chat model:** `phi4-mini` (3.8B, Q4_K_M quantization) — ~3.5GB resident, roughly 15–20 tokens/sec on CPU. This is close to the practical ceiling for an 8GB machine once Obsidian and everything else you keep open is accounted for.
- **Embedding model:** `nomic-embed-text` — small (~275MB), fast, the standard pairing with Smart Connections in Phase 3.

```
ollama pull phi4-mini
ollama pull nomic-embed-text
ollama list
```

`ollama list` should show both models when done.

### Troubleshooting: CUDA/GPU crash on `ollama run`

If `ollama run phi4-mini` fails with something like:

```
500 Internal Server Error: llama-server process has terminated: exit status 0xc0000409 ...
CUDA error: the provided PTX was compiled with an unsupported toolchain
```

this is a known Ollama/NVIDIA driver compatibility bug on Windows (not something you did wrong) — the CUDA toolchain bundled in Ollama's build doesn't match the installed GPU driver (confirmed on this machine: an NVIDIA GeForce MX150, driver 12.7). Since this plan was already sized around CPU inference (`phi4-mini` was picked for ~15-20 tok/s on CPU, not GPU), the fix is to force Ollama onto its CPU runner rather than chase a driver update:

```
:: Ollama runs as an auto-starting background service, so stop it first —
:: if taskkill says "not found," find what's actually holding the port instead:
::   netstat -ano | findstr :11434
::   taskkill /F /PID <pid from that output>
:: also check the system tray for an Ollama icon and Quit it, since the tray
:: app will otherwise auto-relaunch the server the moment you kill it.
taskkill /F /IM ollama.exe

:: Then start it fresh with GPU discovery disabled, in the same window.
:: CUDA_VISIBLE_DEVICES="" alone was NOT sufficient on this setup (Ollama
:: 0.34.0 still selected the CUDA device during discovery and crashed on
:: load) - OLLAMA_LLM_LIBRARY=cpu is the one that actually worked, forcing
:: the CPU runner directly instead of relying on GPU auto-detection:
set CUDA_VISIBLE_DEVICES=
set OLLAMA_LLM_LIBRARY=cpu
ollama serve
```

Leave that window open, then in a **second** terminal run `ollama run phi4-mini` as normal — confirmed working: model loads (~15s) and responds with a 200, no crash.

**Making it permanent:** Windows' system environment variable dialog won't save an empty value, so don't bother with `CUDA_VISIBLE_DEVICES` for the permanent setup — the actual fix is `OLLAMA_LLM_LIBRARY=cpu` alone (confirmed: this is what stopped the crash; the empty `CUDA_VISIBLE_DEVICES` on its own was not sufficient when tried by itself).

1. Search Windows for **"Edit the system environment variables"** → Environment Variables
2. Under **System variables**, click New: name `OLLAMA_LLM_LIBRARY`, value `cpu`
3. OK out of both dialogs, then restart Ollama (quit it from the tray, or `taskkill /F /IM ollama.exe`, then reopen the app or let it relaunch)

After that, the tray app starts in CPU-only mode automatically — no need to keep the manual two-terminal setup around.

## 3. Reality check (don't skip this)

Numbers on paper don't tell you whether *your* machine can actually run this alongside a real study session. Test it directly:

```
ollama run phi4-mini
```

Chat with it for a few exchanges — ask it something short, then something that makes it write a paragraph — **while Obsidian is open normally**, the way you'd actually have it during a study session (plus whatever else you'd normally have open: browser, etc.). Type `/bye` to exit when done.

Watch for:
- Noticeably sluggish responses beyond the expected ~15–20 tok/s
- Your machine starting to swap (Windows: Task Manager → Performance tab, watch memory usage climb toward 100% and disk activity spike)
- Obsidian or other apps becoming unresponsive while `phi4-mini` is generating

**If it swap-thrashes, that's a legitimate outcome, not a failure.** Don't fight an 8GB machine — the fallback is to point Smart Connections/Copilot (Phases 3–4) at a cloud API (you already have Claude access) instead of Ollama for the chat model. The plugins themselves don't change, only the backend does; you lose the "fully local/private" property and nothing else breaks. `nomic-embed-text` is small enough that it's very unlikely to need this fallback — it's specifically `phi4-mini` (or any chat model) that's the risk.

### Reality check result (2026-09-17): fallback to cloud API — decided

Ran the reality check with Obsidian open. Result: CPU pegged at max, response took a long time, **and** the answer itself was low quality — it hallucinated badly on a straightforward prompt about the project (misdefined MCP as "Monitoring, Controlling, and Sensing," invented an unrelated "Microsoft Clarity" integration, and described training a model from scratch on AWS/GCP/Azure instead of the actual local RAG/vault-QA setup this plan describes). Slow-and-wrong is worse than just slow — this machine's combination of running CPU-only (after the CUDA workaround above) plus a genuinely weak chat model at this size isn't producing usable output.

**Decision: chat model = cloud API (Claude), embedding model = local Ollama (`nomic-embed-text`).** Phases 3–4 (Smart Connections, Copilot for Obsidian) will be configured to call Claude for chat/vault-QA, not local `phi4-mini`. Embeddings stay local — `nomic-embed-text` is small enough (~275MB) that it wasn't implicated in the slowdown, and there's no reason to move it to a cloud API. Nothing about the plugins themselves changes, only their chat backend setting.

## 4. What not to install

Skip anything larger than ~4B parameters at Q4 quantization on this machine. It is not worth the swap-thrashing to chase a marginally better model — `phi4-mini` was picked specifically to leave headroom, and going bigger defeats that.

## Definition of done for Phase 2

- [x] Ollama installed; `ollama --version` runs successfully in a terminal
- [x] `ollama list` shows both `phi4-mini` and `nomic-embed-text` pulled
- [x] Reality check performed: chatted with `phi4-mini` via `ollama run phi4-mini` while Obsidian (and normal study-session apps) were open
- [x] A decision made and noted: local didn't hold up (CPU maxed, slow, hallucinated output) — **Phases 3–4 will use a cloud API (Claude) for chat, and local `nomic-embed-text` for embeddings.** See "Reality check result" above.

Only move to Phase 3 (Smart Connections) once this checklist is clean and you know which backend (local Ollama vs. cloud API) Phases 3–4 will actually point at.
