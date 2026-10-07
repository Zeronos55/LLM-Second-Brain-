---
name: ingest-source
description: Ingests one non-course source — an article, paper, textbook chapter, web clipping, transcript or the user's own raw notes — into the Obsidian vault as atomic notes. Discusses key takeaways with the user first, writes notes per the vault schema, links them into existing notes, and updates the subject MOC, Tags MOC, index.md and log.md. For course PDFs from Google Drive use atomize-subject / update-subject instead. Invoke by name when the user hands over a source to file — e.g. "ingest this paper" or "run ingest-source on this article."
---

You turn one source into well-linked atomic notes and keep the vault's bookkeeping current. One source per invocation, so the user can review what you did.

Read `CLAUDE.md` at the vault root in full first — frontmatter schema, tag taxonomy and anti-drift rule, naming, Atomic Card template, append-only rule, `index.md` / `log.md` formats. Follow it exactly. If it is absent, stop and tell the user (the template is `docs/vault-CLAUDE.md` in the planning repo).

## What you need access to

- **The source itself**: a file in the vault (`Inbox/`, `Attachments/`), a pasted text, a URL you can fetch, or a Drive file. If you can't read it, stop and say so — never write notes from a title alone.
- **The vault**, via filesystem (session inside the vault) or the Local REST API/MCP. Check which; if neither, stop.
- If the source holds formulas or worked numbers, a way to run code (Python) to verify them.

## Procedure

1. **Identify and place the source.** Ask for the subject if unclear. If it isn't already under `Attachments/`, offer to save a copy there (raw sources are immutable once placed; never edit it). Course material from Drive is out of scope: point to `atomize-subject`.

2. **Read it fully, then brief the user.** Give 3–7 key takeaways and the list of notes you plan to create (titles + one-line scope) and existing notes you expect to link or touch. Ask for emphasis or exclusions. Skip the wait only if the user said to proceed unsupervised.

3. **Check what exists.** Read `index.md` and Grep `Study/` for each concept. Extend an existing note by link rather than duplicating.

4. **Write atomic notes** into `Study/<Subject>/`: one concept per note, Title Case filename, Atomic Card body, frontmatter `tags`/`created` (`DD/MM/YYYY`)/`summary`, and `source` citing the source (`[[wikilink]]` to the archived file or a plain citation). Reuse tags from `MOCs/Tags MOC.md`; check it before adding any new one. Examples are fully worked; label your own with *Solved by AI* / *Illustrative*.

5. **Verify checkable items.** Recompute formulas and numeric examples from their inputs before comparing to the source's stated answers. Mismatch → `> [!warning] Source erratum` + `#status/source-erratum`; unresolvable → `> [!question] Unverified` + `#status/unverified`. Never echo a number you haven't checked, and never present a claim from a source you only partly read as verified.

6. **Connect to existing notes.** For notes the source affects, apply only append-only edits: add a Related link, a tag/callout pair, or a clearly-marked addition. If the new source *contradicts* an existing note, don't edit it — add a `> [!warning]` callout on the **new** note naming the conflicting note and values, and list the conflict in your report for the user to resolve.

7. **Bookkeeping.** Update the subject MOC (`MOCs/<Subject> MOC.md`, create from the MOC template if absent), `MOCs/Tags MOC.md` (new tags only), and `index.md` (one line per new note). Append `## [DD/MM/YYYY] ingest | <source title>` with 1–3 lines to `log.md`.

## Report

End with: notes created (list), existing notes touched and exactly what was appended, tags reused vs new, errata/unverified items, any contradictions with existing notes, and anything in the source you deliberately skipped and why. Remind the user that AI-written examples and unverified items need their own check before exam use.
