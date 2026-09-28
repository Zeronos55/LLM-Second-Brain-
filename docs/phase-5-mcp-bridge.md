# Phase 5 — MCP Bridge (Local REST API plugin)

Parent plan: [Obsidian + Local LLM + MCP — Build Plan](obsidian-local-llm-mcp-plan.md)

**Context for this phase:** this is the part that actually improves on the current React-app workflow (copy-pasting markdown by hand). It's a single Obsidian plugin — **Local REST API with MCP** by coddingtonbear — that bundles both a REST API and an MCP server running inside Obsidian. Once connected, Claude Code can read, search, and write notes in your vault directly, rather than you pasting content back and forth.

**Not related to Phase 4's chat setup.** Phase 4 configured Copilot's in-app chat (Gemini) and vault-aware Agent Chat (opencode). This phase is a completely separate integration: it connects **Claude Code** (this tool, running outside Obsidian) to your vault's files. Nothing from Phase 4 needs to change or gets reused here.

**Depends on:** nothing from Phases 2–4 — this only needs Obsidian itself and Claude Code installed on the same machine (Claude Code CLI, separate from the browser/web version of Claude).

## 1. Install the plugin

1. In Obsidian: **Settings → Community plugins → Browse**, search **"Local REST API with MCP"** (by coddingtonbear — this is the actively maintained one that bundles the MCP server; there are older/other "Local REST API" plugins that don't).
2. **Install**, then **Enable**.

## 2. Get your API key

1. **Settings → Local REST API with MCP** (in Obsidian's plugin settings list).
2. Find and copy the **API key** — this is a bearer token the plugin generates, used to authenticate any client connecting to it (including Claude Code).
3. Treat this like a password: don't paste it into notes, don't commit it anywhere. It only grants access to something running on `127.0.0.1` (your own machine), but it's still full read/write access to your vault.

## 3. Choose HTTPS (default) or plain HTTP

The plugin serves over HTTPS by default, with a self-signed certificate it generates itself — which means your OS/browser won't trust it out of the box.

**Option A — trust the certificate (more correct, one extra step):**
1. Download the cert from `https://127.0.0.1:27124/obsidian-local-rest-api.crt`
2. Trust it in Windows (double-click the downloaded file → Install Certificate → Local Machine → Trusted Root Certification Authorities).
3. Use `https://127.0.0.1:27124/mcp/` as the endpoint in step 4.

**Option B — plain HTTP fallback (simpler, skip cert trust entirely):**
1. In the plugin settings, enable the **HTTP server** option (alongside the default HTTPS one) — this opens an unencrypted endpoint on port **27123**.
2. Use `http://127.0.0.1:27123/mcp/` as the endpoint in step 4.
3. This is fine specifically because it's bound to `127.0.0.1` — nothing outside your own machine can reach it either way, encrypted or not. Given this session's track record of Windows-specific friction with certs/CORS/installers, Option B is the pragmatic default; switch to Option A later if you want the extra correctness.

## 4. Connect Claude Code

Claude Code has native HTTP MCP support — no separate bridge process needed (that's only required for Claude Desktop, which this plan doesn't cover). In a terminal:

```
claude mcp add --transport http obsidian http://127.0.0.1:27123/mcp/ --header "Authorization: Bearer <your-api-key>"
```

(swap in the HTTPS URL from Option A if you went that route instead, and the API key from step 2). This registers the server immediately — no restart needed.

## 5. Verify it works

1. In a Claude Code session on this machine, ask it to read a note you know exists (by name or path).
2. Ask it to create a new, clearly-labeled test note (e.g. "MCP Test Note") with some placeholder content.
3. **Switch to Obsidian and confirm the new note actually appears** — this is the real test; Claude Code reporting success isn't enough on its own, since the point is verifying the write actually landed in the vault.
4. Delete the test note once confirmed (either from Obsidian directly, or by asking Claude Code to delete it — that's also a useful check that deletes work too).

## 6. Security check (don't skip)

The plan's own security note is worth actually confirming, not just reading: this opens a local server with read/write access to your entire vault. Confirm it's not reachable from outside your machine:

1. From a **different device** on the same network (phone, another laptop), try to open `http://<this-machine's-LAN-IP>:27123` or the HTTPS equivalent on 27124 in a browser.
2. It should fail to connect. If it doesn't, the plugin (or a firewall rule) is bound to `0.0.0.0` instead of `127.0.0.1` — worth investigating before leaving this running, since it's real read/write access to your notes.

## Definition of done for Phase 5

- [ ] Local REST API with MCP plugin installed and enabled
- [ ] API key retrieved and stored somewhere safe (not in the vault)
- [ ] Endpoint chosen (plain HTTP on 27123, or HTTPS on 27124 with the cert trusted) and Claude Code connected via `claude mcp add --transport http`
- [ ] Verified: Claude Code can read an existing note's actual content
- [ ] Verified: a note Claude Code creates actually appears in Obsidian (checked in Obsidian itself, not just taken on Claude Code's word)
- [ ] Verified: the port is unreachable from another device on the same network

Once this is clean, Phases 1–5 of the original plan are all complete: a structured vault (Phase 1), local embeddings backup path via Ollama (Phase 2, though ended up mostly unused directly — see Phase 3/4 notes), Smart Connections' free semantic layer (Phase 3), free cloud chat + vault-aware Agent Chat via Copilot (Phase 4), and now Claude Code with direct vault access (Phase 5). [Phase 6](obsidian-local-llm-mcp-plan.md#phase-6--where-to-improve-on-what-the-articles-showed) in the parent plan covers where to take this further (closing the loop with the React app, template-driven study workflows, a tagging-taxonomy MOC, formula handling) — worth revisiting once this phase is settled and lived-in for a bit, rather than rushing straight into it.
