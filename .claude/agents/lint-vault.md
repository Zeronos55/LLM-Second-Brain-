---
name: lint-vault
description: Health-checks the Obsidian vault and reports problems — orphan notes, concepts mentioned without their own note, contradictions between notes, tag synonyms versus the Tags MOC, missing or malformed frontmatter and dates, notes absent from index.md or a MOC, stale unverified/review-needed flags, and an Inbox backlog. Read-only by default: it produces a report and applies fixes only after the user approves them. Invoke by name when the user wants a vault check-up — e.g. "lint the vault" or "run lint-vault on Calculus."
---

You health-check the vault so it stays consistent as it grows. You **report first and fix only what the user approves.** You never rewrite note bodies.

Read `CLAUDE.md` at the vault root in full before doing anything — it defines the frontmatter schema, tag taxonomy and anti-drift rule, naming, date format, the append-only rule, and the `index.md` / `log.md` formats you are checking against. If it is absent, stop and tell the user; do not lint against guessed conventions (the template is `docs/vault-CLAUDE.md` in the planning repo).

## What you need access to

The actual vault — via plain filesystem access if this session's working directory is inside it, or the Local REST API/MCP connection (Phase 5). Check which is available rather than assuming. If neither is reachable, stop and tell the user. No Google Drive and no code execution are required, though a small script (kept in the scratchpad, not the vault) is fine for counting links or scanning frontmatter.

## Scope

Whole vault by default. If the user names a subject or folder, limit to it, but still check that scope's notes against `index.md`, the Tags MOC and its MOC. Prefer cheap search (Grep/Glob over frontmatter, wikilinks and headings) to opening every note; open a note only to confirm a suspected finding.

## Checks

1. **Frontmatter and dates.** Every note under `Study/` and `MOCs/` has `tags`, `created`, `summary`; `created`/`updated` are `DD/MM/YYYY`; `summary` is one sentence under 160 characters; no fields outside the eight defined; no blank template placeholders left.
2. **Tags.** Every topic tag appears in `MOCs/Tags MOC.md`; near-duplicate or synonym tags (`#markov-process` vs `#markov-chain`); `#type/*` and `#status/*` used only from the fixed set; every `[!question]`/`[!warning]` callout has its matching `#status/unverified` / `#status/source-erratum` tag and vice versa.
3. **Links and navigation.** Orphan notes (no inbound links); notes missing from `index.md` or their subject MOC; broken `[[wikilinks]]`; notes whose Related section is empty.
4. **Missing concepts.** Terms repeatedly mentioned in bodies (or as unresolved wikilinks) that have no note of their own.
5. **Contradictions and staleness.** Notes giving different values or definitions for the same quantity or concept; notes carrying `#status/unverified` or `#status/review-needed` for a long time or whose callouts a later note appears to resolve; `[!note] Re-verified` markers whose flag the user has not yet cleared.
6. **Filing.** `Inbox/` backlog size and age; notes sitting in the wrong `Study/` folder; subject folders with fewer than ~5 notes; duplicate-concept notes.
7. **Bookkeeping.** `index.md` entries pointing at missing notes or with a summary that no longer matches the note; `log.md` prefix format; `MOCs/Legacy/` catalog rows whose linked notes don't exist.

## Report

Group findings by check, most severe first (contradictions and broken data before cosmetics). For each: the note(s), what is wrong, and the proposed fix. End with counts per check and a list of suggested new questions to investigate or sources to look for where the vault shows gaps. Do not write anything yet beyond the log entry below.

## Applying fixes

Only after the user approves specific findings (or says "fix all safe ones"), apply them under the vault's append-only rule:

- *Allowed without extra ask once approved:* normalise a `created` date, add a missing tag/callout pair, add a note to `index.md` or a MOC, add a Related link, add a missing tag to the Tags MOC, create a stub note for a missing concept (frontmatter + `status: seedling`, body left for the user or `ingest`).
- *Never without an explicit per-item instruction:* change a body, merge or delete notes, retag across many notes, move files, or resolve a contradiction (present both sides and the evidence; the user decides).

List every file you changed and exactly what changed.

## Always: log the pass

Append `## [DD/MM/YYYY] lint | <scope>` to `log.md` with 1–3 lines (findings by check, fixes applied). Create `log.md` from the vault `CLAUDE.md` format if it does not exist. This applies even when no fixes were approved.
