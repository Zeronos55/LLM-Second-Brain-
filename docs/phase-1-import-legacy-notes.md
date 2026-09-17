# Importing Legacy Annotated Notes (Option A: archive now, atomize on demand)

Parent plan: [Obsidian + Local LLM + MCP — Build Plan](obsidian-local-llm-mcp-plan.md)
Builds on: [Phase 1 — Vault Foundations](phase-1-vault-foundations.md)

**Scope:** previous-semester notes, tutorials, and workshop material annotated on iPad in **GoodNotes**. GoodNotes has no separate "annotation layer" on export — a notebook exports as a single flattened PDF with the handwriting baked into the page images. That constraint drives everything below: these PDFs are opaque to Smart Connections' embedding index (Phase 3) until content is pulled out of them into markdown, so the plan is archive first, atomize only when a topic is actually being restudied.

## 1. Export from GoodNotes

Per notebook: open it → **Share/Export → PDF**. Use the highest quality export setting ("Best for printing" or equivalent) — legibility now saves re-scanning later if a page needs re-transcribing.

For a large backlog, GoodNotes lets you select multiple notebooks within a folder and export them together rather than one at a time — do that per course/folder rather than per notebook to cut down the manual steps.

**Rename on export** to a consistent pattern before filing:

```
<Course-Code>_<Short-Title>.pdf
STAT-431_Stochastic-Processes-Lecture-Notes.pdf
STAT-431_Tutorial-03-Martingales.pdf
```

## 2. Get the PDFs onto the machine running Obsidian

Export target in GoodNotes should be the **Files app**, saved into an iCloud Drive folder (or whatever sync service reaches your desktop). From there:

- **iCloud Drive:** the folder just appears in Finder/Explorer on the desktop — no extra step.
- **No iCloud on desktop:** AirDrop the exported PDFs to the desktop machine instead, or plug in and copy via the Files app's "On My iPad" location.

Either way, land everything in one staging folder first (e.g. `~/Downloads/goodnotes-export/`) before moving into the vault — don't drag directly from Files into Obsidian's vault folder, so a bad export doesn't get buried inside vault structure before you've checked it opened correctly.

## 3. Where they land in the vault

```
Attachments/
└── Legacy/
    └── <Course-Code>/
        ├── STAT-431_Stochastic-Processes-Lecture-Notes.pdf
        ├── STAT-431_Tutorial-03-Martingales.pdf
        └── ...

MOCs/
└── Legacy/
    └── STAT-431 Catalog.md
```

`Attachments/Legacy/<Course-Code>/` is pure storage — original PDFs, never edited, treated as the source of truth once atomized notes start referencing them.

## 4. One catalog note per course, not one note per PDF

With "a lot" of notebooks, a full frontmatter note per PDF is too much overhead for material you haven't studied from yet. Instead, one **catalog note per course** as a table — still plain markdown, so Smart Connections can embed and search it even though the PDFs themselves can't be:

**`MOCs/Legacy/STAT-431 Catalog.md`:**

```markdown
---
tags: [legacy, stochastic-processes]
created: 2026-09-17
summary: Catalog of imported STAT-431 GoodNotes material, pending atomization.
---

# STAT-431 — Legacy Catalog

| File | Topics covered | Tags | Status |
|---|---|---|---|
| [[Attachments/Legacy/STAT-431/STAT-431_Stochastic-Processes-Lecture-Notes.pdf]] | Markov chains, transition matrices | #markov-chain | unprocessed |
| [[Attachments/Legacy/STAT-431/STAT-431_Tutorial-03-Martingales.pdf]] | Martingale property, stopping times | #martingale | unprocessed |
```

Fill in "Topics covered" and "Tags" from a quick skim (title page, table of contents, section headers) — this doesn't need to be exhaustive, just enough that the catalog note is a useful search hit later. Check candidate tags against `MOCs/Tags MOC.md` per the Phase 1 taxonomy rule before inventing new ones.

**Speeding up the skim:** you don't need Phase 5's MCP setup to get help here — Claude (in a normal chat, or Claude Code with local file access) can already read PDFs directly. Hand it a batch of exported PDFs and ask it to draft the "Topics covered" and "Tags" columns for the catalog table; you review and correct before committing, since GoodNotes handwriting-to-text reading isn't perfect. This is a one-off drafting aid, not a dependency on anything later in the plan.

## 5. Atomize on demand — the actual conversion path

This is where the backlog turns into real Phase 3/4-searchable atomic notes, but only for what you're actively using:

1. **Trigger:** you're restudying or referencing a topic and the catalog (or memory) points at a legacy PDF that covers it.
2. **Extract:** once Phase 5 (MCP) is live, ask Claude to open that PDF via the vault connection and draft Atomic Card notes for the concepts on the relevant pages, using the Phase 1 template and checking `Tags MOC.md` before proposing new tags. Before Phase 5 exists, do the same thing manually in a Claude chat with the PDF attached — the workflow doesn't require MCP, MCP just makes it "ask in Obsidian" instead of "paste into a chat."
3. **Review:** treat every draft as needing a human pass, same discipline as the React app's handwritten-LaTeX capture — annotated handwriting and formulas are exactly where transcription errors hide.
4. **File:** save the accepted notes into `Study/<Subject>/`, add them to that subject's MOC, and set `source: "[[Attachments/Legacy/STAT-431/STAT-431_Tutorial-03-Martingales.pdf]]"` in the new note's frontmatter so it stays traceable back to the original scan. (`source` is a useful optional field beyond just legacy import — e.g. citing a textbook chapter — so it's worth adding to the general frontmatter schema, not only legacy-derived notes.)
5. **Update the catalog:** flip that row's Status from `unprocessed` to `atomized → [[Martingale Property]], [[Stopping Time]]`, so the catalog stays an accurate map of what's still raw versus what's already in the atomic system.

Nothing forces full atomization before moving on — a course's catalog can sit at `unprocessed` indefinitely and still be a functional, searchable archive.

## 6. Pacing

- Do the mechanical part (export → rename → file → catalog) in one or two bulk sessions per course — it's cheap, don't drag it out.
- Do **not** pre-atomize everything up front (that's Option B, and it front-loads a huge transcription task against a schema you haven't pressure-tested yet — see the Phase 1 doc's definition-of-done, which explicitly wants the schema validated on ~10–15 notes first).
- The exception worth considering: if one course is foundational and you know you'll reference it constantly (a prerequisite you'll keep coming back to), it's fine to prioritize atomizing it earlier than "on demand" would otherwise trigger — but make that call per-course, not as a blanket rule.

## 7. Definition of done for the import

- [ ] All legacy GoodNotes notebooks exported as PDF, consistently named, staged before filing
- [ ] Filed under `Attachments/Legacy/<Course-Code>/`
- [ ] One catalog note per course under `MOCs/Legacy/`, every PDF listed with topics/tags/status
- [ ] Catalog tags checked against `MOCs/Tags MOC.md`, new tags added there when genuinely new
- [ ] Catalog notes show up in normal Obsidian search (sanity check before relying on Smart Connections in Phase 3)
- [ ] No atomization required to close this out — atomization continues indefinitely, pulled by what you're actually studying
