---
tags: [legacy, intake-audit]
created: 2026-09-12
summary: Metadata-level review of Sem2, Sem4, Sem5, Sem7 legacy notes in Google Drive — flags oversized/duplicate/gap/ambiguous files ahead of full cataloging.
source: "Google Drive — Sem2, Sem4, Sem5, Sem7 (Unzipped Files) folders"
---

# Sem2 / Sem4 / Sem5 / Sem7 — Intake Audit

**What this is:** a scan of every file now sitting unzipped in Drive across the four semesters uploaded since Sem1 (Sem3 and Sem6 confirmed skipped — MPU electives). This is a **flagging pass**, not a full topic catalog like the Sem1 catalogs — full per-file topic/tag cataloging (with content actually read) happens per-course on demand, same as the Sem1 pipeline, once you're ready to atomize a given course.

**Method:** pulled file listing + exact byte size for all 284 files across 14 course folders directly from Drive metadata. This does **not** include opening/reading file content (unlike Sem1's catalog, which read ambiguous files) — at this volume, doing that for all 284 files isn't practical in one pass. So "corrupted" below is judged only by what metadata can show (near-zero file sizes, missing files) — a truly corrupted-but-normal-sized PDF wouldn't be caught without opening it. Say the word and I'll spot-check specific files by downloading and reading them.

**Result: no near-zero-byte or obviously corrupted files found** by size alone. Smallest file across all 284 is 67,878 bytes (a table image) — not a red flag.

## Summary

| Semester | Courses | Files | Oversized (~>10MB) | Gaps flagged | Dup/ambiguous flagged |
|---|---|---|---|---|---|
| Sem2 | Business Finance, Probability, Theory of Interest, Advanced Calculus | 90 | 8 | 1 (Business Finance) | 2 |
| Sem4 | Life Contingencies I, Introduction to Statistics, Derivative Securities | 55 | 6 | 1 (Derivative Securities) | 2 |
| Sem5 | Mathematical Methods, Life Contingencies 2, Derivative Securities 2 | 70 | 7 | 0 | 2 |
| Sem7 | Stochastic Processes, Simulation and Credibility Theory, Regression Analysis, Ratemaking and Loss Reserving | 69 | 8 | 1 (Simulation and Credibility Theory — significant) | 1 |
| **Total** | **14 courses** | **284** | **29** | **3** | **7** |

29 oversized files is a much bigger backlog than Sem1's 5 — worth knowing before deciding how to handle the "revisit with a plan later" step, since it won't be a quick one-off.

Also: **the original `.zip` files are still sitting in Drive alongside every unzipped folder** (14 zips, several 50–120MB each). Not flagging as a data problem, just a housekeeping note — once you've confirmed the unzipped files are good, those zips are pure dead weight and easy space to reclaim by trashing them (same reversible trash-not-delete approach as before). Say the word if you want me to do that.

---

## Sem2

### Business Finance (30 files)
- **Oversized:** none.
- **Gap flagged:** Tutorials 1–7, 10, 11 present; **Tutorials 8 and 9 are missing.**
- **Naming quirk (not a confirmed duplicate):** `Tutorial 10 ... student 2.pdf`, `Tutorial 4 ... student 2.pdf`, `Lecture 1_updated 2.pdf` carry a stray " 2" in the filename but no un-suffixed counterpart exists alongside them — most likely just how the provider named the file, not a re-upload. No action needed.

### Probability (26 files)
- **Oversized (>10MB):**
  - `Chapter 5 - Functions of Random Variables.pdf` — 13,363,082 bytes (~12.7MB)
  - `Chapter 2 - Lecture class PPT slide.pdf` — 11,118,846 bytes (~10.6MB)
- **Gap flagged:** Tutorials 7–13 present (as `Tutorial_N`) plus `MAT1034 Tutorial 1`/`Tutorial 2` — **Tutorials 3–6 appear missing** under either naming scheme.
- **Duplicates flagged:**
  - Two "Chapter 1" files: `Chapter 1-Intro to Prob.pdf` (6.1MB) and `Chapter 1 - Probability.pdf` (1.0MB) — different sizes, likely two versions/drafts of the same chapter, not confirmed identical.
  - Two "Chapter 3" candidates: `Chapter 3 - Continuous Random Variable.pdf` (4.7MB) and `C3-new.pdf` (6.8MB) — naming ("new") suggests one supersedes the other.

### Theory of Interest (17 files)
- **Oversized (>10MB):**
  - `T1 Interest Rate Measurement.pdf` — 10,700,099 bytes (~10.7MB)
  - `T2 Annuities.pdf` — 10,245,489 bytes (~10.2MB)
- **Duplicate confirmed:** `Formula List.pdf` and `Formula List-1.pdf` — **identical size** (415,721 bytes) — near-certain duplicate.
- **Gap check:** T1–T7 and L1–L7 both complete. No gaps.

### Advanced Calculus (17 files)
- **Oversized (>10MB):**
  - `Lecture_Notes_(Chapter_1)_MAT1044_Advanced_Calculus_Sep2024.pdf` — 17,285,267 bytes (~17.3MB)
  - `Tutorial_1_(Problem)_MAT1044_Advanced_Calculus_Sep2024.pdf` — 20,216,430 bytes (~20.2MB)
  - `Lecture_Notes_(Chapter_2)_MAT1044_Advanced_Calculus_Sep2024.pdf` — 12,036,435 bytes (~12.0MB)
  - `Tutorial_4_(Problem)_MAT1044_Advanced_Calculus_Sep2024.pdf` — 10,622,422 bytes (~10.6MB)
- **Gap check:** Tutorials 1–5 and Chapters 1–5 both complete. No gaps.

---

## Sem4

### Life Contingencies I (27 files)
- **Oversized (>10MB):**
  - `Workshop 5.pdf` — 14,218,722 bytes (~14.2MB)
  - `Extra.pdf` — 13,282,492 bytes (~13.3MB)
  - `Workshop 3.pdf` — 11,834,019 bytes (~11.8MB)
  - `Workshop 4.pdf` — 10,484,633 bytes — **borderline**: just 1,127 bytes under the binary 10MiB mark (10,485,760), so it's right at the edge of the connector's cap either way. Flagging it as oversized to be safe.
- **Ambiguous filename:** `16492916.pdf` — numeric-only name, content unknown from metadata. Same pattern as the ambiguous files Sem1 had to actually open to identify.
- **Gap check:** Workshops 1–5, Tutorials 1–5, Chapters 1–5, Answers 1–5 all complete.

### Introduction to Statistics (20 files)
- **Oversized (>10MB):**
  - `Tutorial.pdf` — 20,696,857 bytes (~20.7MB)
  - `Chap 2 examples.pdf` — 10,790,977 bytes (~10.8MB)
- **Duplicate flagged:** `16396928.pdf` (450,257 bytes) is **byte-identical in size** to `Max Likelihood Estimation and Sufficiency Week 3.pdf` (450,257 bytes) — looks like the same file saved twice under a generic export name.
- **Ambiguous filenames:** `16418289.pdf` (3.5MB) — another numeric-only name, unclear content.
- **Gap check:** Weeks 1–8 and Edited Chapters 1–3 present, no obvious gaps.

### Derivative Securities (8 files)
- **Oversized:** none (largest is 9.9MB, under the line).
- **Gap flagged:** Seminar Exercises only present for Weeks 4, 5, 6 — **Weeks 1–3 seminar exercises appear missing** (may simply not have been assigned that early in the course — worth a mental check rather than assuming an upload gap).
- **Naming quirk (not confirmed duplicate):** `MAT2084 APR2025 Week 5 Seminar Exercises 2.pdf` — same stray "2" pattern as Business Finance, no un-suffixed counterpart.

---

## Sem5

### Mathematical Methods (24 files)
- **Oversized (>10MB):**
  - `MAT2034 Tutorial_2 Questions.pdf` — 11,954,758 bytes (~12.0MB)
  - `CH02 Ordinary Differential Equations (ODEs).pdf` — 10,435,833 bytes (~10.4MB)
- **Ambiguous numbering:** two files both labeled "Tutorial 7" (`Tutorial 7 Nonlinear problems QUESTIONS.pdf` and `Tutorial 7 NLP SGD QUESTIONS.pdf`) — different topics under the same tutorial number, likely two separate hand-outs rather than a duplicate. Flagging so it isn't mistaken for one when atomized later.
- **Gap check:** Chapters 1–8 and Tutorials 1–8 (+ Tutorials A/B) all present when both naming schemes are combined.

### Life Contingencies 2 (25 files)
- **Oversized (>10MB):**
  - `Tutorial_3_ASC2024_Life_Contingencies_II.pdf` — 15,765,270 bytes (~15.8MB)
  - `Mock Exam_Set 2.pdf` — 11,957,161 bytes (~12.0MB)
  - `Tutorial_5_ASC2024_Life_Contingencies_II.pdf` — 11,171,097 bytes (~11.2MB)
  - `Practice 1.pdf` — 10,580,471 bytes (~10.6MB)
- **Flagged for confirmation (possible misfile):** `LIFE CONTINGENCIES I FORMULA LIST_ANSWER.pdf` and `LIFE CONTINGENCIES I FORMULA LIST_ACTIVITY SHEET.pdf` are both filed inside the **Life Contingencies 2** folder despite their filenames saying "LIFE CONTINGENCIES I" — could be intentional reference carry-over material, or could be misfiled from the LC1 folder. Worth a quick confirm from you.
- **Gap check:** Tutorials 1–6 and Chapters 1–6 both complete.

### Derivative Securities 2 (21 files)
- **Oversized (>10MB):**
  - `Sample Finals.pdf` — 14,450,725 bytes (~14.5MB)
- **Flagged (possible duplicate, unconfirmed):** `Sample Finals.pdf` (14.5MB) vs `1_Sample Finals.pdf` (9.7MB) — different sizes, so not confirmed identical, but similar enough names to be worth checking whether one is questions and the other solutions, or an old vs. new version.
- **Gap check:** Chapters 1.0–8.0 and Tutorials 1–8 both complete.

---

## Sem7

### Stochastic Processes (24 files)
- **Oversized (>10MB):**
  - `MAT3034 APR2026 Sample Past Year Questions.pdf` — 11,792,511 bytes (~11.8MB)
- **Naming note (not a gap):** this course mixes two term labels — `MAT3034 MAY2026` (Course Overview, Tutorials 1–2, Chapters 1–2) and `MAT3034 APR2026` (Tutorials 3–8, Chapters 3–8, workshops, assignment). Combined, the numbering is complete (Chapters 1–8, Tutorials 1–8) — but worth confirming with you whether this reflects one course split across two terms, or two separate course instances that got merged into one folder.
- **Gap check:** none once both term labels are combined.

### Simulation and Credibility Theory (20 files) — heaviest flag load
- **Oversized (>10MB), 6 files — by far the densest oversized cluster of any course so far:**
  - `ASC3014 Tutorial 2 - Simulating Random Variables.pdf` — 20,329,412 bytes (~20.3MB)
  - `ASC3014 Tutorial 8 - Bayesian Methodology.pdf` — 15,554,323 bytes (~15.6MB)
  - `ASC3014 Tutorial 9 - Greatest Accuracy Credibility.pdf` — 15,177,335 bytes (~15.2MB)
  - `ASC3014 Tutorial 3 - Techniques for Simulating Distributions and Processes.pdf` — 13,731,091 bytes (~13.7MB)
  - `ASC3014 Tutorial 7 - Limited Fluctuation Credibility.pdf` — 11,121,355 bytes (~11.1MB)
  - `ASC3014 Tutorial 5 - Simulation in Actuarial Modelling.pdf` — 11,005,029 bytes (~11.0MB)
- **Gap flagged — significant:** Chapters present are only 1, 6, 7, 8, 9 — **Chapters 2, 3, 4, 5 appear missing entirely.** Tutorial 4 is also missing (Tutorials 1, 2, 3, 5, 6, 7, 8, 9 present). This is the clearest "did I actually upload everything" flag in the whole audit — worth double-checking your GoodNotes export for this course specifically.

### Regression Analysis (15 files)
- **Oversized (>10MB):**
  - `REVISION.pdf` — 14,317,091 bytes (~14.3MB)
- **Naming quirk (not confirmed duplicate):** `Chapter 4(1).pdf` — the only chapter file using the bare "Chapter N" pattern instead of the course's usual `MAT3024_Chapter N` naming; no un-suffixed "Chapter 4" exists elsewhere, so likely just this file's original name.
- **Gap check:** Chapters 1–6 and Tutorials 1–6 both complete.

### Ratemaking and Loss Reserving for General Insurance (10 files)
- **Oversized:** none (largest is 6.7MB).
- **Gap check:** Chapters 1–6 complete. Two textbook references present (Friedland, CAS Basic Ratemaking) — not duplicates, just supplementary reading.

---

## What I'd suggest next

1. **Confirm or dismiss the flags above** — especially the Sim & Credibility Theory Chapter 2–5 gap (looks like a real missing upload) and the two Life Contingencies I/II filename mismatches.
2. **Oversized files (29 total):** same deferred-for-later treatment as Sem1's 5 — not reading them now, but 29 is enough that when you're ready to tackle them, compressing/splitting on your end before re-upload will probably be faster than working around the connector one file at a time.
3. **Full topic cataloging** (like the Sem1 Economics/Calculus/Linear Algebra catalogs) can follow per-course whenever you're ready to atomize a specific one — this audit was just the intake check.
4. **Optional housekeeping:** trash the 14 leftover zip files once you're happy the unzipped versions are good (reversible, same as before).
