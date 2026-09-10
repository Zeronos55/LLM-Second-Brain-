# Phase 1 — Vault Foundations (detailed plan)

Parent plan: [Obsidian + Local LLM + MCP — Build Plan](obsidian-local-llm-mcp-plan.md)

**Context for this phase:** vault is starting fresh (little/nothing to migrate). Taxonomy is designed as a general study vault that's actuarial-heavy in practice — the folder/tag structure is topic-based, not tied to SOA/CAS exam codes, so it holds up if the subject mix shifts later.

**No new tools required.** Everything below uses Obsidian's built-in core plugins (Templates, and optionally Daily Notes) — no community plugins, no Ollama, nothing external. The point of Phase 1 is that it's cheap to get right before the AI layer starts depending on it.

## 1. Folder structure

```
Vault/
├── Inbox/            quick capture, unfiled — cleared out on a regular review
├── Study/
│   ├── Probability/
│   ├── Stochastic-Processes/
│   ├── Finance/
│   └── <Subject>/     one folder per subject, created when it earns one (see below)
├── Projects/          active work with a deliverable (not pure study notes)
├── MOCs/              one Map of Content per subject, plus a Tags MOC
├── Templates/         note templates (Atomic Card, MOC)
├── Attachments/        images, PDFs, handwritten-LaTeX captures
└── Archive/            superseded/retired notes, kept out of active search
```

Rules of thumb:

- **Don't pre-create every subject folder.** Start with `Inbox/` and one or two `Study/` folders for whatever you're actively studying now. A subject earns its own folder once it has ~5+ atomic notes; before that, a few loose notes in `Inbox/` or a temporary catch-all are fine. Pre-provisioning empty folders just creates decision fatigue later.
- **`Projects/` is not `Study/`.** Study notes are atomic, reusable concept cards. Projects are things with an end state (e.g. "build the Obsidian→React import bridge" from Phase 6, or "Exam P study schedule"). Don't let study material drift into Projects or vice versa.
- **`MOCs/` is the index layer.** Every `Study/<Subject>/` folder gets exactly one MOC note (`MOCs/<Subject> MOC.md`) that links out to its atomic notes, grouped by subtopic. This is what makes the vault navigable before Smart Connections exists, and it's what Smart Connections' "related notes" will reinforce, not replace.
- **`Attachments/` centralizes non-markdown files** so `Study/` stays pure markdown — keeps future embedding/indexing (Phase 3) clean, and matches Phase 6's note that handwritten-LaTeX captures should be referenced from atomic notes, not re-derived.

## 2. Frontmatter schema

Every note under `Study/` and `MOCs/` gets this frontmatter at minimum:

```yaml
---
tags: [stochastic-processes, martingale]
created: 2026-09-10
summary: A martingale is a stochastic process whose conditional expected future value equals its present value.
---
```

Field rules:

| Field | Required | Rule |
|---|---|---|
| `tags` | yes | array, kebab-case, lowercase — see §3 for the taxonomy discipline |
| `created` | yes | `YYYY-MM-DD`, set once, never edited |
| `summary` | yes | one sentence, <160 chars, written so it stands alone in a search result |
| `updated` | no | `YYYY-MM-DD`, bump when the note's content materially changes (not typo fixes) |
| `status` | no | one of `seedling` / `growing` / `evergreen` — how settled the note's understanding is; useful later for "what needs review" queries |
| `aliases` | no | array — alternate names/notation for the same concept (e.g. `[Wiener process]` on a Brownian Motion note), so links and search catch synonyms |
| `related` | no | array of `[[wikilinks]]` to adjacent atomic notes, when the link doesn't already appear naturally in the note body |

Keep it to these seven fields. Resist adding more — every extra required field is friction against actually writing notes, and Phase 1's whole point is a structure light enough to sustain.

## 3. Tagging taxonomy

Two tag namespaces, both flat kebab-case, no exam-code prefixes:

- **Topic tags** — freeform, one per concept area: `#stochastic-processes`, `#brownian-motion`, `#martingale`, `#markov-chain`, `#poisson-process`, `#probability`. These grow organically as subjects grow.
- **Type/status tags** — a small, fixed, nested set, applied in addition to topic tags:
  - `#type/definition`, `#type/theorem`, `#type/formula`, `#type/example`
  - `#status/review-needed`, `#status/mastered`

**The rule that prevents drift:** before adding a new topic tag, check `MOCs/Tags MOC.md` first. If a close synonym already exists (`#markov-process` vs `#markov-chain`), reuse the existing one. If it's genuinely new, add it to the Tags MOC when you add it to a note. This is the single habit that keeps re-embedding (Phase 3) from being invalidated by tag churn — re-tagging after the index exists means re-indexing, per the parent plan.

Seed `MOCs/Tags MOC.md` with the topic tags you already know you'll need (probability, stochastic-processes, brownian-motion, martingale, markov-chain, poisson-process, finance) plus the fixed type/status set above, so the first notes you write aren't inventing conventions on the fly.

## 4. Naming conventions

- **Note title = filename**, Title Case, descriptive enough to stand alone as a link (`Martingale Property.md`, not `Notes 3.md`).
- **No IDs or dates in filenames.** This isn't a Zettelkasten-ID system — the MOC layer is the index, so filenames should optimize for readability as link text, not for sortability.
- **One concept per note**, carried over directly from the React app's atomic-card discipline: if a note needs an "and" in its title to describe what it covers, it's probably two notes.

## 5. Templates

Two templates, built with Obsidian's core **Templates** plugin (Settings → Core plugins → Templates), stored in `Templates/`.

**`Templates/Atomic Card.md`:**

```markdown
---
tags: []
created: {{date}}
summary: 
---

# {{title}}

## Definition / Statement

## Intuition

## Example

## Related
```

**`Templates/MOC.md`:**

```markdown
---
tags: [moc]
created: {{date}}
summary: 
---

# {{title}}

## Overview

## Notes
```

Set the Templates plugin's template folder to `Templates/` so both are one hotkey away when creating a new note.

## 6. Capture workflow

1. Quick capture goes straight into `Inbox/`, no frontmatter required in the moment — the point is to not break flow while studying.
2. On a regular cadence (end of study session, or weekly), refile each `Inbox/` note: apply the Atomic Card template's frontmatter, move it into the right `Study/<Subject>/` folder, add it to that subject's MOC.
3. `Inbox/` should be empty (or near-empty) between sessions. A growing `Inbox/` backlog is the signal that Phase 1's discipline is slipping before Phase 2 even starts.

## 7. Definition of done for Phase 1

- [ ] `Inbox/`, `Projects/`, `MOCs/`, `Templates/`, `Attachments/`, `Archive/` exist; `Study/` has folders only for subjects you're actively taking notes on right now
- [ ] Both templates created and reachable via the Templates core plugin
- [ ] `MOCs/Tags MOC.md` exists, seeded with the starter topic tags and the fixed type/status tags
- [ ] At least one `Study/<Subject>/` folder has a MOC note linking to its atomic notes
- [ ] First 10–15 notes written (or refiled from Inbox) using the Atomic Card template, to pressure-test the schema before Phase 2 depends on it
- [ ] Spot-check: every note under `Study/` has `tags`, `created`, and `summary` filled in — no template placeholders left blank

Only move to Phase 2 (Ollama) once this checklist is clean. Everything downstream — embeddings, vault QA, MCP-driven note generation — inherits whatever inconsistency is still here.
