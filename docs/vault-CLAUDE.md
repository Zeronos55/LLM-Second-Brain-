# Vault `CLAUDE.md` — template

> **How to use this file:** copy everything below the line into `CLAUDE.md` at the **root of your Obsidian vault**. Claude Code loads it automatically when launched from inside the vault (`cd` into the vault, run `claude`). A session connected only through the Local REST API / MCP bridge does *not* auto-load it — tell that session to read `CLAUDE.md` at the vault root first.
>
> This repo copy is the source of truth for the template. When Phase 1 conventions change, update this file and re-copy it. Rationale for each rule lives in [Phase 1 — Vault Foundations](phase-1-vault-foundations.md) and [Importing Legacy Annotated Notes](phase-1-import-legacy-notes.md); the vault copy is deliberately self-contained and does not depend on them.

---

# Vault schema

This vault is a personal knowledge base maintained by an LLM and read by me. I curate sources and ask questions; you do the bookkeeping — summarising, cross-referencing, filing, keeping everything consistent. Follow this file exactly, not loosely.

## Layers

| Layer | Where | Rule |
|---|---|---|
| Raw sources | `Attachments/` (incl. `Attachments/Legacy/<Code>/`) | **Immutable.** Read from it, never edit, rename or delete. |
| Wiki | `Study/`, `MOCs/`, `Projects/`, `index.md`, `log.md` | You own and maintain this layer. |
| Schema | this file | Co-evolved with me; propose changes, don't silently deviate. |

## Folder structure

```
Inbox/         quick capture, unfiled; cleared on a regular review
Study/YEAR <N>/<Subject>/   atomic notes; year = first digit after the course-code letters (MAT1054 → YEAR 1); one folder per subject, created once it has ~5+ notes
Projects/      active work with a deliverable — not study notes
MOCs/          one "<Subject> MOC.md" per subject, "Tags MOC.md", and Legacy/ catalogs
Templates/     Atomic Card, MOC
Attachments/   non-markdown files; Legacy/<Code>/ holds archived source PDFs
Archive/       retired notes, kept out of active search
index.md       vault-wide catalog (see below)
log.md         append-only chronological record (see below)
```

Don't pre-create empty subject folders. Keep `Study/` pure markdown.

## Notes

**Frontmatter** — every note under `Study/` and `MOCs/`:

| Field | Required | Rule |
|---|---|---|
| `tags` | yes | array, kebab-case, lowercase |
| `created` | yes | `DD/MM/YYYY`, set once, never edited |
| `summary` | yes | one sentence, <160 chars, stands alone in a search result |
| `updated` | no | `DD/MM/YYYY`, bump on material content change |
| `status` | no | `seedling` / `growing` / `evergreen` |
| `aliases` | no | alternate names/notation |
| `related` | no | `[[wikilinks]]` not already in the body |
| `source` | no | `[[wikilink]]` or text citing where the content came from |

Those eight fields only — **do not invent more.** Dates are always `DD/MM/YYYY` (e.g. `07/10/2026`): never hyphens, never ISO order, even if an existing file drifted.

**Naming** — filename = title, Title Case, descriptive enough to stand alone as link text. No IDs or dates in filenames. One concept per note; if the title needs an "and", it is probably two notes.

**Tags** — flat kebab-case, two kinds:
- *Topic tags* (`#martingale`, `#poisson-process`) — grow organically.
- *Fixed type/status set*: `#type/definition`, `#type/theorem`, `#type/formula`, `#type/example`; `#status/review-needed`, `#status/mastered`, `#status/unverified`, `#status/source-erratum`.

**Anti-drift rule:** before adding a topic tag, check `MOCs/Tags MOC.md`. Reuse a close synonym if one exists. If genuinely new, add it to the Tags MOC in the same change. Never invent variants of the fixed set (`#wrong`, `#check`, …).

**Atomic Card body:** `# Title` → `## Definition / Statement` → `## Intuition` → `## Example` → `## Related`. Every Example is a fully worked, solved example; never a bare restated problem.

**Verification flags:** a note with a value you could not confirm gets a `> [!question] Unverified — <why>` callout *and* `#status/unverified`; a note correcting a source mistake gets `> [!warning] Source erratum — …` *and* `#status/source-erratum`. Never a callout without its tag or a tag without its callout.

## Editing rules

- **Existing notes are append-only** unless I ask otherwise: add tags, callouts, a Related link, a solved example, or normalise a non-conforming `created` date. Never rewrite, reflow, retitle or delete a body.
- Don't silently overwrite a source's number; show the discrepancy in a callout.
- Check for an existing note on a concept before creating one — extend by link, don't duplicate.
- Content you solved or wrote yourself is labelled (*Solved by AI*, *Illustrative*).

## `index.md`

Vault-root catalog of every note under `Study/` (and notable `Projects/`), grouped by subject then subtopic. One line per note: `- [[Note Title]] — <its summary>`. Update it on every ingest. **When answering a question, read `index.md` first**, then open the relevant notes. It coexists with subject MOCs (navigation within a subject) and `MOCs/Legacy/` catalogs (per-source-file status); it does not replace them.

## `log.md`

Append-only, newest at the bottom. Every entry starts with a consistent prefix so it is greppable (`grep "^## \[" log.md | tail -5`):

```
## [DD/MM/YYYY] ingest | <what was ingested>
## [DD/MM/YYYY] query | <question whose answer was filed back>
## [DD/MM/YYYY] lint | <scope of the pass>
```

Follow with 1–3 lines: notes created/changed, anything flagged. Never edit past entries.

## Workflows

**Ingest** — a new source arrives.
1. Read it; tell me the key takeaways and what you plan to create.
2. Create atomic notes per the rules above (course PDFs from Drive: delegate to the `atomize-subject` agent, which also tops up subjects already in the vault; any other source: the `ingest-source` agent).
3. Update the subject MOC, `MOCs/Tags MOC.md` (new tags only) and `index.md`.
4. Where an existing note is affected, apply only the append-only edits, or list suggested changes for me to approve.
5. Append a `log.md` entry.

**Query** — I ask a question.
1. Read `index.md`, then drill into relevant notes. Don't answer from memory when the vault covers it.
2. Answer with `[[note]]` citations; say plainly when the vault doesn't cover something.
3. If the answer is valuable (a comparison, an analysis, a connection), offer to file it back as a new note — `Study/` for reusable knowledge, `Projects/` for deliverables — with `source` stating it is a synthesis and which notes it draws on. File it only after I agree, then update `index.md` and `log.md`.

**Lint** — periodic health check (the `lint-vault` agent). Report first; fix only what I approve. Looks for: orphan notes, concepts mentioned with no note, contradictions between notes, stale `#status/unverified` / `#status/review-needed`, tag synonyms vs the Tags MOC, missing/blank frontmatter, non-`DD/MM/YYYY` dates, notes absent from `index.md` or a MOC, and an `Inbox/` backlog.

**Inbox refile** (the `refile-inbox` agent) — move each `Inbox/` note into `Study/YEAR <N>/<Subject>/`, apply Atomic Card frontmatter, add it to the subject MOC and `index.md`.

## Guardrails

- Stay inside the vault. Never edit `Attachments/`.
- Don't expose or reconfigure the Local REST API port beyond `127.0.0.1`.
- When unsure whether something belongs in a note, ask rather than guess.
- Unverified, handwriting-derived or AI-solved content still needs my own check before I rely on it for exams.
