# Phase 5 — MCP Bridge (Local REST API plugin)

Parent plan: [Obsidian + Local LLM + MCP — Build Plan](obsidian-local-llm-mcp-plan.md)

**Context for this phase:** this is the part that actually improves on the current React-app workflow (copy-pasting markdown by hand). It's a single Obsidian plugin — **Local REST API with MCP** by coddingtonbear — that bundles both a REST API and an MCP server running inside Obsidian. Once connected, Claude Code can read, search, and write notes in your vault directly, rather than you pasting content back and forth.

**Not related to Phase 4's chat setup.** Phase 4 configured Copilot's in-app chat (Gemini) and vault-aware Agent Chat (opencode). This phase is a completely separate integration: it connects **Claude Code** (this tool, running outside Obsidian) to your vault's files. Nothing from Phase 4 needs to change or gets reused here.

**Depends on:** nothing from Phases 2–4 — this only needs Obsidian itself and Claude Code installed on the same machine (Claude Code CLI, separate from the browser/web version of Claude).

## Two things that are easy to conflate (read this first)

If any of this plan (including this doc) was written or discussed with a cloud-based Claude Code session — one you reach through a browser, connected only to this GitHub repo — that session has **no access whatsoever** to your Windows machine, your actual Obsidian vault, Ollama, or anything local. It can only read/write files in this git repo and push them to GitHub. Nothing below in this doc can be done by that kind of session. It has to be done by a **separate, local** Claude Code session — opened by typing `claude` in a terminal (cmd, PowerShell, etc.) on your own computer.

Second, once you have that local session, there are **two independent ways** it can touch your vault, and this doc is really about the second one:

1. **Plain file access.** An Obsidian vault is just a folder of `.md` files on disk. If you open a terminal, `cd` into that folder, and run `claude` there, Claude Code can read and write those files directly with its normal built-in file tools — no plugin, no API, no setup at all. If Obsidian is open at the same time, it notices the file changes automatically. This alone is enough for "ask Claude Code to read/edit a note."
2. **MCP via the Local REST API plugin** (what the rest of this doc sets up). Instead of touching files directly, Claude Code talks to a small web server that the Obsidian plugin runs, which exposes Obsidian-specific capabilities (its own search, tag listing, "what note is currently open," etc.) — genuinely more than plain file editing gives you, but more moving parts to set up (a plugin, an API key, a network connection). Unlike path 1, this does **not** require Claude Code's terminal to be `cd`'d into the vault folder at all — the connection is over the network (`127.0.0.1`), not through the filesystem, so the terminal can be anywhere.

Both are legitimate; this doc sets up path 2 because it's the more capable long-term option, but if you just want something working immediately, path 1 needs nothing below this point — just `cd` into your vault and run `claude`.

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

Claude Code has native HTTP MCP support — no separate bridge process needed (that's only required for Claude Desktop, which this plan doesn't cover). **This command is run inside a local Claude Code session** (i.e. you've already typed `claude` in a terminal and are now chatting with it — not a raw `cmd.exe` prompt, and not this planning session):

```
claude mcp add --transport http --scope user obsidian http://127.0.0.1:27123/mcp/ --header "Authorization: Bearer <your-api-key>"
```

(swap in the HTTPS URL from Option A if you went that route instead, and the API key from step 2). This registers the server immediately — no restart needed.

**About `--scope user`:** without it, the default scope ties this connection to whatever project folder you happen to be in when you run the command — meaning the obsidian tools would only show up in Claude Code sessions started from that exact folder later on. `--scope user` makes it available from *any* folder, any time you run `claude` on this machine, which is simpler to reason about while you're still learning the tool.

**When copy-pasting this command**, double check the pasted text for stray characters right after `Bearer` — a leading `>` or similar can sneak in depending on how the command was displayed to you, and the server will silently reject the header if it's there.

## 5. Verify it works

1. **First, run `claude mcp list`** (a plain command, not `/mcp`) in that same local session, and confirm `obsidian` appears in the output. Note: the `/mcp` slash command's "Manage MCP servers" panel shows something different — connectors tied to your claude.ai account (Google Drive, Canva, etc.) — and won't necessarily list this one, so don't use it to check.
2. In that same local Claude Code session, ask it (as a normal chat message, not a slash command) to read a note you know exists — e.g. "read my Stationary Process note." Being explicit that you mean the vault ("check my Obsidian vault for...") helps it pick the right tool instead of defaulting to searching whatever local folder it's running in.
3. Ask it to create a new, clearly-labeled test note (e.g. "MCP Test Note") with some placeholder content.
4. **Switch to Obsidian and confirm the new note actually appears** — this is the real test; Claude Code reporting success isn't enough on its own, since the point is verifying the write actually landed in the vault.
5. Delete the test note once confirmed (either from Obsidian directly, or by asking Claude Code to delete it — that's also a useful check that deletes work too).

## 6. Security check (don't skip)

The plan's own security note is worth actually confirming, not just reading: this opens a local server with read/write access to your entire vault. Confirm it's not reachable from outside your machine:

1. From a **different device** on the same network (phone, another laptop), try to open `http://<this-machine's-LAN-IP>:27123` or the HTTPS equivalent on 27124 in a browser.
2. It should fail to connect. If it doesn't, the plugin (or a firewall rule) is bound to `0.0.0.0` instead of `127.0.0.1` — worth investigating before leaving this running, since it's real read/write access to your notes.

## Definition of done for Phase 5

- [ ] Local REST API with MCP plugin installed and enabled
- [ ] API key retrieved and stored somewhere safe (not in the vault)
- [ ] Endpoint chosen (plain HTTP on 27123, or HTTPS on 27124 with the cert trusted) and Claude Code connected via `claude mcp add --transport http --scope user`, run inside a local Claude Code session (not this planning session, not a raw `cmd.exe` prompt)
- [ ] Verified via `claude mcp list` (not the `/mcp` panel) that `obsidian` is actually registered
- [ ] Verified: Claude Code can read an existing note's actual content
- [ ] Verified: a note Claude Code creates actually appears in Obsidian (checked in Obsidian itself, not just taken on Claude Code's word)
- [ ] Verified: the port is unreachable from another device on the same network

Once this is clean, Phases 1–5 of the original plan are all complete: a structured vault (Phase 1), local embeddings backup path via Ollama (Phase 2, though ended up mostly unused directly — see Phase 3/4 notes), Smart Connections' free semantic layer (Phase 3), free cloud chat + vault-aware Agent Chat via Copilot (Phase 4), and now Claude Code with direct vault access (Phase 5). [Phase 6](obsidian-local-llm-mcp-plan.md#phase-6--where-to-improve-on-what-the-articles-showed) in the parent plan covers where to take this further (closing the loop with the React app, template-driven study workflows, a tagging-taxonomy MOC, formula handling) — worth revisiting once this phase is settled and lived-in for a bit, rather than rushing straight into it.
