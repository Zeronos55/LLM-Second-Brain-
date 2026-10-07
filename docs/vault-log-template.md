# `log.md` — seed template

> Copy the block below to `log.md` at the vault root. Spec: see "`log.md`" in [vault-CLAUDE.md](vault-CLAUDE.md).

```markdown
---
tags: [log]
created: DD/MM/YYYY
summary: Append-only chronological record of ingests, filed-back queries and lint passes.
---

# Log

Append-only; newest at the bottom; never edit past entries.
Prefix every entry `## [DD/MM/YYYY] ingest|query|lint | <title>` so `grep "^## \[" log.md | tail -5` works.

## [DD/MM/YYYY] ingest | Vault created
Seeded `CLAUDE.md`, `index.md`, `log.md`.
```
