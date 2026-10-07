# CLAUDE.md — LLM-Second-Brain- (planning repo)

This repo holds **planning docs and subagent definitions** for an Obsidian + local LLM + MCP second brain. It does **not** contain the vault. Sessions here (especially cloud sessions) cannot see the user's vault, Ollama, or anything local — they can only read/write files in this repo.

- `docs/` is the source of truth for design decisions. Keep `README.md` links current when adding or renaming docs. Phase docs live in `docs/phases/`; the parent plan, vault templates and `legacy-catalog/` stay at the `docs/` level.
- `docs/vault-CLAUDE.md` is the **template for the vault's own `CLAUDE.md`** (plus `vault-index-template.md` and `vault-log-template.md`). When a Phase 1 convention changes (frontmatter, tags, naming, workflows), update the template in the same change and tell the user to re-copy it into the vault.
- `.claude/agents/` holds `atomize-subject` (which now also tops up already-atomized subjects), `ingest-source`, `refile-inbox` and `lint-vault`. They run against the vault, follow the vault `CLAUDE.md`, and fall back to the Phase 1 docs here only if it is unreachable. Don't restate vault conventions inside agent files — point to `CLAUDE.md`.
- Dates in `created` fields and `log.md` entries are `DD/MM/YYYY`.
- Always ask the user before committing or pushing — never commit or push on your own.

## Working agreement for Claude sessions

This repo is worked on from a **local** Claude session and a **cloud** Claude session, one at a time.
Neither session sees the other's changes unless they go through git, so git is the handoff.

### Branches
- Local sessions: `local/<topic>`. Cloud sessions: the assigned `claude/<id>` branch.
- Never commit directly to `main`; merge via PR. Never force-push.

### Naming (branches and PRs)
- Branches Claude creates itself: `<prefix>/<short-kebab-topic>`, e.g. `claude/phase-docs-reorg`, `local/vault-lint` — never a random slug.
- Cloud sessions are often handed a random `claude/<adjective-name-id>` branch. Keep working on it (don't push to another branch without asking), but make the PR title carry the meaning.
- PR titles: an imperative, specific summary of the change, e.g. "Move phase docs into docs/phases/". Never a branch name, a slug, or a generic "Update docs". If a PR was opened with a placeholder or branch-derived title, rename it.
- PR descriptions: say what changed and why; one PR per finished unit of work, targeting `main`.

### Session start
- A hook prints a "Git sync report" if the remote has commits this branch lacks.
  If it does, merge the named branch before editing.

### After significant work
- When you finish a significant change (new/edited doc, new file, restructure), say so and
  offer to commit and push. A hook also reminds the user about uncommitted or unpushed work.

### Handoff
- Leaving a side: "commit and push everything", then confirm no unpushed-work reminder remains.
- Cloud -> local: `claude --teleport <session-id>`, or fetch and merge the cloud branch.
- Local -> cloud: push the branch, then start the cloud session from it (or have it fetch and merge first).
