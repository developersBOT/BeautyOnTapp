---
name: beautyontapp-skill-authoring
description: How to AUTHOR a Claude skill that triggers and executes reliably, for PNCapital (BeautyOnTApp, Pastry Skincare, Mzuri Skin). Make sure to invoke whenever T wants to write, create, draft, or restructure a skill, or asks why a skill is not firing — triggers include "write a skill", "create a skill", "author a skill", "new skill", "skill description", "skill triggers", "skill not firing", "skill won't trigger", "freedom calibration", "progressive disclosure", "split this skill", "SKILL.md". Encodes the selection-first rule, the description trap, narrow-bridge vs open-field freedom calibration, progressive disclosure, explicit-scope literalism, coverage-first for finding skills, completion marking, and per-tier testing. NOT for scoring or maintaining existing skills or trigger-collision scans (use beautyontapp-skill-health). NOT for writing marketing PROMPTS or dispatches (use beautyontapp-prompting-discipline). NOT for the canonical skill count or routing (use 02_PNCapital_Skill_Router).
---

# BeautyOnTApp Skill Authoring

Companion to `beautyontapp-skill-health`. Health *scores and maintains* existing skills; this skill *writes new ones that execute*. Built from Anthropic's official Agent Skills engineering guidance and skill-creator, the prompting best-practices guide (Opus 4.8, May 2026), and the obra/superpowers + langgptai community skill repos.

## Core formula

**Good skill = expert-only procedural knowledge − what the base model already knows.** If the model produces the same output without the skill loaded, the content is wasted context. Every line competes with conversation history and other skills' metadata once loaded.

## The eight rules

1. **Selection is the whole game — the description is the highest-leverage field.** At startup only each skill's `name` + `description` is pre-loaded; the body is read on demand only if the description wins selection. A perfect body behind a weak description never runs. Spend the most effort here.

2. **Write the description "pushy", third person, what + when + triggers + exclusions.** Claude under-triggers by default, so Anthropic's own skill-creator pads descriptions: "Make sure to use this skill whenever the user mentions dashboards, data visualization, or internal metrics, even if they don't explicitly ask for a dashboard." Pattern: what it does, the exact trigger phrases T uses, and `NOT for X (use other-skill)` exclusions for every adjacent skill. Third person only — first/second person ("I can…", "You can…") degrades discovery because the description is injected into the system prompt.

3. **The description trap: triggers ONLY, never a workflow summary.** A description that summarises the procedure becomes a shortcut the model takes *instead of* reading the body — so a body that says "do two reviews" runs once. Keep the procedure in the body; keep only firing conditions in the description.
   - ❌ "Runs a 16-step audit checking search terms, placements, and Quality Score"
   - ✅ "Auto-invoke when T says audit, check account, how are campaigns doing, find waste"

4. **Description length cap is 1024 characters (Anthropic spec), 1536 combined with `when_to_use` in the Claude Code listing.** Not 250. Every sentence competes for that budget, so each trigger phrase and exclusion must earn its place. (Body cap: 500 lines — see rule 5.)

5. **Progressive disclosure: SKILL.md is a map, not the territory.** Keep the body under 500 lines; when it approaches that, split detail into `references/*.md` and link them explicitly from the body. An orphan reference file the body never tells the model to read is dead weight. Use a Mermaid diagram in the body to compress a multi-step process into hundreds of tokens instead of thousands.

6. **Calibrate freedom to risk — narrow bridge vs open field.**
   - **Narrow bridge** (high-risk, irreversible, deterministic, or money/data-touching): give an exact procedure, name the script, forbid deviation, define the halt condition. e.g. "Run the redirect on a duplicate theme only. Do not modify the script. If a 404 appears, halt and report." Maps to PNCapital theme edits, tracking, redirects, financial actions, anything touching Analyzify/Simprosys/BookX.
   - **Open field** (heuristic, judgement-led): state the goal and the constraints, let the model reason. Maps to strategy, creative, positioning analysis.
   - The mismatch failure mode: creative work locked into a checklist, or a fragile irreversible operation left wide open. Match the freedom to the task.

7. **Write for current-model literalism and effort.** Opus 4.8 follows instructions literally and will not generalise an instruction from one item to all items — so state scope explicitly in the body ("apply to every section, not just the first"). Examples in `<example>` tags steer behaviour better than adjectives; include 3–5 for any non-obvious output shape. Assume agentic skills run at `high`/`xhigh` effort; do not bake in "think harder" or "summarise progress every N steps" scaffolding the current model handles itself.

8. **For any finding/review/audit skill, instruct coverage, not conservatism.** Current models obey "be conservative / only high-severity / don't nitpick" faithfully and silently drop real findings. In the finding stage, instruct: "report every finding including uncertain and low-severity ones, each tagged with confidence and severity; a later step ranks and filters." Push the filtering to a downstream phase. (This is why the read-only auditors carry a coverage-first block.)

## Two more decisions

- **Mark completion explicitly.** End the procedure with what "done" looks like and what to return, so the model stops cleanly instead of trailing off or over-running.
- **Test across the tiers you'll run it on.** A skill's effectiveness depends on the underlying model; what Opus follows from a terse instruction, Haiku may need spelled out. PNCapital runs Opus / Sonnet / Haiku, so any skill used in Haiku fan-out needs more explicit, step-by-step detail than an Opus-only skill.

## Naming

Anthropic recommends gerund form (verb + -ing: "processing-pdfs", "writing-skills") because it names the activity. The PNCapital convention is `beautyontapp-{domain}-{specifier}` (domain noun). Keep the PNCapital convention for consistency with the existing 84 skills — do not refactor names — but know the divergence exists if you read Anthropic examples.

## Authoring sequence

1. **Confirm the gap.** Ask: can the base model already do this well? If yes, do not write the skill (it will just add context cost). If the value is business-specific data or a strict procedure, proceed.
2. **Classify the type** (per skill-health): capability-uplift, encoded-preference, domain-knowledge, or process-workflow. This sets the maintenance burden and the freedom level.
3. **Draft the description first** — pushy, third person, triggers only, exclusions for every adjacent skill, ≤1024 chars. This is the part most likely to fail, so write and pressure-test it before the body.
4. **Draft the body** — under 500 lines, expert-only knowledge, explicit scope, reasons instead of MUSTs, freedom calibrated to risk, examples in tags, references linked, completion marked.
5. **Split if long** — move detail to `references/*.md` and link from the body.
6. **Hand to skill-health** for the 120-point score and a trigger-collision check against the rest of the library.

## No volatile data in skill bodies

Do not hardcode budget ceilings, daily/monthly caps, per-campaign CPA/ROAS/spend, or competitor Semrush stats into a new skill — these go stale and get cited as current. Reference `03_PNCapital_Business_Facts §[section]` (current version) instead. Policy benchmarks that hold until T changes them (1.82x MER floor, R167/R300 CAC, scaling cadences, EMQ floors, Content ID = Shopify ID) may be stated.

## Self-check before shipping a skill

1. Description is third person, pushy, triggers-only (no workflow summary), ≤1024 chars, with NOT-for exclusions for adjacent skills.
2. Body is under 500 lines; long detail lives in linked `references/*.md`; no orphan references.
3. Freedom level matches risk (narrow bridge for irreversible/data-touching, open field for heuristic).
4. Scope is stated explicitly wherever an instruction applies to all items.
5. Reasons replace ALL-CAPS / "YOU MUST"; examples are in `<example>` tags.
6. Finding/audit skills carry a coverage-first instruction.
7. Completion is marked; expected output shape is defined.
8. No hardcoded volatile figures; volatile data points to Business Facts.
9. Naming follows the `beautyontapp-{domain}-{specifier}` convention.
10. Tested in a fresh conversation on every tier it will run on.

## Pairs with

- `beautyontapp-skill-health` — scores and maintains the skill after you write it; runs trigger-collision and eval checks.
- `beautyontapp-prompting-discipline` — the prompt-writing counterpart (same XML/refuse-the-field/anti-fabrication DNA).
- `beautyontapp-evidence-citations` + `beautyontapp-anti-fabrication` — every business claim in a skill body needs a source.
- `02_PNCapital_Skill_Router` — register the new skill and its routing once shipped.

## What this skill does NOT do

- Does not score, grade, or run the 120-point rubric on existing skills — that's `beautyontapp-skill-health`.
- Does not run trigger-collision scans or quarterly maintenance — `beautyontapp-skill-health`.
- Does not write marketing prompts or Sonnet dispatches — `beautyontapp-prompting-discipline`.
- Does not decide the canonical skill count or routing table — `02_PNCapital_Skill_Router`.

## Versioning

v1 (29 May 2026) — First deployed to fill the authoring gap (skill-health covered scoring/maintenance but not how to write a skill that executes). Sources: Anthropic "Equipping agents for the real world with Agent Skills" + skill authoring best practices, skill-creator SKILL.md, Anthropic prompting best-practices guide (Opus 4.8), obra/superpowers and langgptai/awesome-claude-prompts repos, generativeprogrammer.com skill-authoring synthesis (Apr 2026).
