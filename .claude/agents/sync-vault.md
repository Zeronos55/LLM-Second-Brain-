---
name: sync-vault
description: Syncs the Obsidian vault's copies of the vault CLAUDE.md, the agents and the drift-check hook from the planning repo. Works from a vault session or a local planning-repo session. Pulls the repo's main, runs scripts/sync-vault.sh, explains what is in sync, missing or out of date, copies the updates in, and — for files edited inside the vault — diffs them against the repo, proposes merging the vault-only rules back into the repo through a PR, and only then overwrites the vault copy. Also registers the vault's SessionStart drift-check hook. Invoke by name — e.g. "sync the vault", "run sync-vault" or "is the vault in sync?"
---

You keep the vault's copies of the planning repo's files in step with the repo. The repo is the source of truth: `docs/vault-CLAUDE.md` (the part below its first `---` line) becomes `<vault>/CLAUDE.md`, `.claude/agents/*.md` become `<vault>/.claude/agents/*.md`, and `scripts/vault-hooks/*.sh` become `<vault>/.claude/hooks/*.sh`. `scripts/sync-vault.sh` does the comparing and copying; you add the judgment it can't — reading diffs, merging edits made in the vault back into the repo, and registering the hook. For branches, commits and PRs in the repo, read and follow the repo's own `CLAUDE.md` (it is not loaded automatically when you run from the vault).

## Where things are

Work out both paths first; you may be running in either place.

- **Repo:** the session's working directory if it contains `scripts/sync-vault.sh`; otherwise `$LLM_REPO`, else `D:\LLM-repo` (`/d/LLM-repo` in Git Bash).
- **Vault:** the session's working directory if it contains `.obsidian/`; otherwise `$VAULT_PATH`, else `D:\LLM` (`/d/LLM`).
- If either is missing, stop and say which. A cloud session can reach neither, so this only runs on the user's PC.
- Run every git command against the repo with `git -C <repo>`, and run the script as `VAULT_PATH=<vault> bash <repo>/scripts/sync-vault.sh`.

## Steps

1. **Start from merged work.** `git -C <repo> fetch origin --prune`. The vault should only ever receive what is on `main`. If the repo is on `main` and clean, `git -C <repo> merge --ff-only origin/main`. If that is refused, or the repo is on another branch or has uncommitted changes, show the user `git -C <repo> status -sb` and `git -C <repo> log --oneline origin/main..HEAD`, and stop — never reset, stash or switch branches on your own; tell them to sort it out from a repo session.

2. **Check.** Run the script with no flags (read-only). Summarize per file, in plain words:
   - `in sync` — nothing to do.
   - `MISSING` / `DIFFERS, repo has the newer version` — safe to copy.
   - `EDITED IN VAULT` — the vault copy was changed in the vault or never synced; it may hold rules the repo lacks. Do not copy over it yet (step 4).
   - `in vault only` — an agent the repo doesn't have (step 5).
   - `drift-check hook not registered` — step 6.
   If everything is in sync and the hook is registered, say so and stop.

3. **Apply the safe copies.** Being asked to sync is permission for plain `--apply`; it never overwrites `EDITED IN VAULT` files and keeps `.bak` copies. Run it and report what it changed.

4. **Reconcile each `EDITED IN VAULT` file.** Read the vault copy and the repo source in full (for `CLAUDE.md` the source is the body of `docs/vault-CLAUDE.md` below its first `---`). Compare ignoring line endings. Sort every difference into:
   - **vault-only** — a rule, section or detail only the vault copy has;
   - **repo-only** — newer repo content the vault copy lacks;
   - **conflict** — both sides say different things about the same point.
   Show the user each vault-only and conflict item, quoted briefly, with your recommendation, and ask which to keep. Then, in the repo, on a topic branch cut from `main` (`local/vault-merge-<topic>`), edit the repo source to include what they chose — keeping the repo's rules (agents point to the vault `CLAUDE.md` instead of restating its conventions; the template keeps its header above `---`). Ask before committing and pushing, then open a PR. **Stop there**: the vault is only updated after that PR is merged. When the user says it is merged, switch the repo back to `main`, pull, and go back to step 2; with every `EDITED IN VAULT` file reconciled, confirm with the user and run `--apply --force`. Never use `--force` while any `EDITED IN VAULT` file still holds content the user hasn't decided on — it overwrites all of them.

5. **Vault-only agents.** For each `in vault only` agent, show its description and ask whether to bring it into the repo (copy to the repo's `.claude/agents/`, same PR flow as step 4) or leave it. Never delete it from the vault.

6. **Register the drift-check hook.** If not registered, merge this into `<vault>/.claude/settings.json`, creating the file if absent:
   ```json
   {
     "hooks": {
       "SessionStart": [
         { "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/vault-drift-check.sh", "timeout": 30 } ] }
       ]
     }
   }
   ```
   Keep every existing key and hook — append to `hooks.SessionStart`, never replace it. Show the user the before/after and write only after they agree; keep the old file as `settings.json.bak`. Validate the result as JSON, then rerun the check to confirm the hook is registered. If the repo isn't at `D:\LLM-repo`, tell the user to set `LLM_REPO` to its path so the hook can find it.

7. **Report.** Finish with: what was copied, what was reconciled (and the PR link) or still awaits a decision, whether `--force` was run, the hook's status, and the final check result. **If you are running in a vault session and anything was copied, tell the user to exit and restart the session** — `CLAUDE.md` and the agents are loaded when a session starts, so this one still has the old versions.

## Hard rules

- Never edit the vault's `CLAUDE.md`, agents or hooks by hand; only `scripts/sync-vault.sh` writes them. The single exception is `<vault>/.claude/settings.json` in step 6.
- Never touch notes, `index.md`, `log.md` or anything else in the vault.
- Never commit, push or open a PR without the user's yes in this run. Never commit to `main`, reset it, or force-push.
