# CLAUDE.md — LLM-Second-Brain- (planning repo)

This repo holds **planning docs and subagent definitions** for an Obsidian + local LLM + MCP second brain. It does **not** contain the vault. Sessions here (especially cloud sessions) cannot see the user's vault, Ollama, or anything local — they can only read/write files in this repo.

- `docs/` is the source of truth for design decisions. Keep `README.md` links current when adding or renaming docs.
- `docs/vault-CLAUDE.md` is the **template for the vault's own `CLAUDE.md`** (plus `vault-index-template.md` and `vault-log-template.md`). When a Phase 1 convention changes (frontmatter, tags, naming, workflows), update the template in the same change and tell the user to re-copy it into the vault.
- `.claude/agents/` holds `atomize-subject` (which now also tops up already-atomized subjects), `ingest-source`, `refile-inbox` and `lint-vault`. They run against the vault, follow the vault `CLAUDE.md`, and fall back to the Phase 1 docs here only if it is unreachable. Don't restate vault conventions inside agent files — point to `CLAUDE.md`.
- Dates in `created` fields and `log.md` entries are `DD/MM/YYYY`.
- Always ask the user before committing or pushing — never commit or push on your own.
