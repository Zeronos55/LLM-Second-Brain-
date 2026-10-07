---
name: refile-inbox
description: Clears the Obsidian vault's Inbox/ — turns each quick-capture note into a proper atomic note with schema-conformant frontmatter, moves it into the right Study/<Subject>/ folder, and adds it to the subject MOC, Tags MOC and index.md. Splits multi-concept captures and flags what it cannot place. Invoke by name when the user wants the Inbox processed — e.g. "refile my inbox" or "run refile-inbox."
---

You implement the vault's capture routine: quick notes land in `Inbox/` with no structure, and you refile them. Move and structure notes; do not change what they say.

Read `CLAUDE.md` at the vault root in full first — folder rules, frontmatter schema, tags and anti-drift rule, naming, Atomic Card template, append-only rule, `index.md` / `log.md` formats. If it is absent, stop and tell the user (template: `docs/vault-CLAUDE.md` in the planning repo).

## What you need access to

The vault, via filesystem (session inside the vault) or the Local REST API/MCP. Check which; if neither is reachable, stop and tell the user.

## Procedure

1. **Inventory.** List every note in `Inbox/` with its size and last-modified date. If it's empty, say so and stop. If the user named specific notes, do only those.

2. **Classify each note** by reading it:
   - *Single concept, clear subject* → refile.
   - *Several concepts* → split into one note per concept (the original text is preserved across the pieces, not rewritten); the original Inbox file is removed only after every part is filed.
   - *Unclear subject or concept, or too fragmentary to stand alone* → leave in `Inbox/` and list it with the question you need answered. Never guess a subject.
   - *Not study material* (a project, a to-do) → propose `Projects/` instead of filing.

3. **Show the plan, then act.** Present a table: Inbox note → new title, target folder, tags, split or not. Proceed without waiting only if the user said to; otherwise wait for approval or edits. A subject folder that doesn't exist yet is created only if it will hold ~5+ notes; otherwise file into the closest existing folder and say so.

4. **Refile.** For each approved note:
   - Rename to a Title Case, stand-alone filename (no IDs/dates); check the vault for a note on the same concept first — if one exists, don't duplicate: append the content as a clearly-marked addition to it, or link the two, and tell the user.
   - Add frontmatter: `tags` (topic tags checked against `MOCs/Tags MOC.md`; fixed `#type/*` where obvious), `created` (the note's original creation date if known, else today, `DD/MM/YYYY`), `summary` (one sentence, <160 chars). No extra fields.
   - Shape the body into the Atomic Card sections *without altering the user's content*: place text under Definition / Statement, Intuition, Example, Related as it fits; leave empty sections as headings. Don't invent content. If an Example is missing, leave it and list the note so the user can request one via `ingest-source` or by asking.
   - Move into `Study/<Subject>/`.

5. **Bookkeeping.** Add each note to its subject MOC (create from the MOC template if the subject is new), new tags to `MOCs/Tags MOC.md`, and one line each to `index.md`. Append `## [DD/MM/YYYY] ingest | Inbox refile (N notes)` with 1–3 lines to `log.md`.

## Report

List: notes refiled (old → new path), notes split, notes left in `Inbox/` with the question for each, merges with existing notes, tags reused vs new, and the Inbox count before and after. Note that `Inbox/` near-empty between sessions is the goal.
