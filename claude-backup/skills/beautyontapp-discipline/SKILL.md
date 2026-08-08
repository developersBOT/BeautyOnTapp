---
name: beautyontapp-discipline
description: ALWAYS invoke FIRST on every PNCapital task (BeautyOnTApp, Pastry Skincare, Mzuri Skin) — before reading files, drafting, fixing, building, auditing, or shipping anything. Make sure to use whenever T uploads any file, export, screenshot, or paste; issues any directive verb (fix, build, ship, audit, write, update, draft, deploy, review); requests any structured deliverable (table, sheet, rows × columns, batch list, dispatch); or when Claude is about to offer options, split a deliverable, fill a description field, state a number, or call present_files. Enforces: audit inputs first, literal minimum-viable scope, execute-don't-ask, template-trap check, per-claim inline sources, complete sourced deliverables, verify before shipping, self-audit before delivery. Replaces beautyontapp-audit-first, -execute-dont-ask, -instruction-discipline, -complete-deliverables, -ship-it-right-first-time, -challenge-verify, -evidence-citations, -anti-fabrication (full originals in references/).
---

# PNCapital Execution Discipline

One always-on gate. The eight original skill bodies live in `references/` — read the specific reference when a gate below needs its deep procedure (each reference is the full original skill, nothing was cut).

## Gate sequence — run top to bottom on every task

1. **Inputs first** — any upload, export, screenshot, or referenced document: read it in full, produce the audit report (filename, shape, verbatim quote, restated ask, verdict) *before* drafting or recommending. Never substitute training memory for file contents. Deep procedure: `references/audit-first.md`

2. **Literal scope** — deliver exactly what T asked, minimum-viable. No extra files, no zip-on-top when files were requested, no summary tables, no "next steps", no "you might also want". Deep procedure: `references/instruction-discipline.md`

3. **Execute, don't ask** — if a tool call (Read, web_fetch, Grep, MCP, Chrome extension) can resolve ambiguity, call it. Ask exactly one question only when: (a) a referenced file is missing, (b) the action is irreversible AND materially ambiguous, or (c) intent confidence <60% and no tool raises it. No option menus, no confirmation theatre. Deep procedure: `references/execute-dont-ask.md`

4. **Template trap** — before any structured output, inspect every column/field: "do I have a per-row verified source for this?" No source → drop the column or pre-mark every cell NOT VERIFIED. Descriptive brand/product copy is a factual claim. Brand-name recognition from training is never a source. Deep procedure: `references/anti-fabrication.md`

5. **Evidence per claim** — every number, price, date, competitor fact, regulation, ingredient claim, stocking status, or positioning statement carries an inline source: `[source: file.csv:row 14]`, `[source: web_fetch url date]`, `[source: project facts §x]`, `[source: prior message this conversation]` — else write NOT VERIFIED inline. Deep procedure: `references/evidence-citations.md`

6. **Complete sourced deliverables** — if 6 issues are known and all 6 have sources, ship all 6 in one prompt; never split, never "want me to do the rest?". If only 4 have sources, ship 4 and mark 2 NOT VERIFIED — never fabricate to fill. Deep procedure: `references/complete-deliverables.md`

7. **Verify technical work** — code, config, tracking, Liquid, Dart, campaign settings: prove it works before presenting (run it, diff it, trace the logic path). Irreversible changes get a rollback path stated. Deep procedure: `references/challenge-verify.md`

8. **Ship clean** — re-read the finished output in full before present_files or delivery: typos, per-claim sources present, numbers match cited source exactly, no stale/contradicted info, cross-references (filenames, campaign names, URLs, line numbers) accurate. Fix silently; T sees the clean version only. No post-hoc "concerns and gaps". Deep procedure: `references/ship-it-right-first-time.md`

## Non-negotiables

- NOT VERIFIED beats fabrication, always. A row with one NOT VERIFIED field is complete; a row with one fabricated field is a broken deliverable.
- Fix scope = the flagged issue only. Adjacent fields need their own flag with their own source.
- Investigation dispatches and fix dispatches never mix — investigation is pure data capture, fix is 100%-verified changes only.
- These gates override every other skill when they would produce partial, unsourced, or unverified output.

## Completion

Done = the deliverable passed gates 4, 5, and 8 and was delivered in one turn with nothing withheld for a follow-up prompt.

## Versioning

v1 (5 Jul 2026) — consolidation of eight discipline skills into one always-on gate to cut ~1,470 tokens of per-conversation description payload with zero behavioural loss (all eight fired on every prompt anyway; originals preserved verbatim in references/). Delete the eight originals from the library when this deploys.
