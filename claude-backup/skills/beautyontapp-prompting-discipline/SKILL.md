---
name: beautyontapp-prompting-discipline
description: Prompting discipline for Google Ads, Meta Ads, and SEO/content marketing tasks at PNCapital — BeautyOnTApp, Pastry Skincare, Mzuri Skin. Make sure to invoke whenever T or any agent is about to write, rewrite, dispatch, or evaluate a marketing prompt or audit (PMax, ASC, EMQ, technical SEO, programmatic SEO, GEO/AEO, schema, Google Ads Scripts, Meta rules). Auto-invoke on "write a prompt", "prompt for", "dispatch", "rewrite this prompt", "audit", "brief", "PMax", "ASC", "Andromeda", "EMQ", "Screaming Frog", "Semrush export", "content brief", "programmatic SEO", "SERP analysis", "schema markup", "GEO", "AEO", "AI Overview", "AI Mode", "query fan-out". Forces XML-tag structure, refuse-the-field defaults, anti-training-memory clauses, tier-based model routing (Opus/Sonnet/Haiku) and the current-model execution levers. Pairs with audit-first, evidence-citations, execute-dont-ask.
---

# BeautyOnTApp Prompting Discipline

## Why this skill exists

Current Claude models follow instructions literally and have stopped generalising the way Sonnet 3.5 / Opus 3 used to. Opus 4.8 (the top tier as of writing; Opus 4.7, Sonnet 4.6, Haiku 4.5 also in use) does not infer a request you did not make, and does not extend an instruction from one item to all items unless you state the scope explicitly. Vague prompts stall. The old 2024 playbook — prefill the assistant message, set temperature=0, write "YOU MUST" in caps — is broken: prefilling returns HTTP 400, non-default temperature/top_p/top_k returns HTTP 400, and aggressive language now overtriggers and produces worse output.

The cost of bad prompts at PNCapital is measurable: fabricated brand descriptions on 17 May 2026 (Lele Feminine, Uso Skincare, Nilotiqa, Anasa, Torriden, Manetain, Ndanaka), 45+ conversations where Screaming Frog was never recommended, generic "test more creatives" Meta advice, and PMax audits that hallucinate campaigns not in the export.

This skill prevents that.

## The seven non-negotiable rules

1. **XML tags, not Markdown headers, for prompt structure.** `<role>`, `<context>`, `<task>`, `<instructions>`, `<output_format>` — Anthropic's official prompting guide confirms this reduces misinterpretation on current models.
2. **One-sentence role max.** "You are a senior Google Ads strategist auditing a Shopify Advanced beauty retail account in ZAR." No "world-class expert with 30 years of experience" padding. (Role framing steers tone, not correctness — the accuracy lift comes from constraints, structure, examples, and effort, not the persona.)
3. **Permit "I don't know" + refuse-the-field default.** Every prompt must include: "If a value is not in the attached source, output `NOT IN SOURCE`. Do not infer from training data."
4. **No prefilling assistant messages.** Returns HTTP 400 on current models. Use `<output_format>` tags instead.
5. **No ALL-CAPS imperatives, no "YOU MUST", no exclamation stacking.** Replace with reasons. (Source: Anthropic's official skill-creator SKILL.md — "explain why things are important in lieu of heavy-handed MUSTs.")
6. **Attach real data, never describe it.** If the user doesn't have the export, fix that first — do not write the prompt yet.
7. **Anti-training-memory clause for business-specific claims.** Every prompt must include: "Treat training data as unreliable for any claim about BeautyOnTApp, Pastry, Mzuri, or competitors. Only use information present in attached files or links."

## Execution levers (current-model behaviour — most important update)

These four levers are what now make a prompt *execute* rather than stall, asking, or under-delivering. They come from Anthropic's current prompting best-practices guide (Opus 4.8, May 2026).

1. **Effort is the primary lever — do not prompt around shallow work.** Set `effort: xhigh` for coding and agentic dispatches, minimum `high` for any intelligence-sensitive task. If output is shallow, *raise effort* — do not add "think harder" wording. `budget_tokens` is deprecated; omit it. At `xhigh`/`max`, set a large max-output budget (start ~64k) so the model has room to act across tool calls.
2. **Tool use must be earned with effort + explicit instruction.** Opus 4.8 favours reasoning over tool calls by default. If a dispatch must actually run Screaming Frog, fetch a live page, or drive the Chrome extension, set `high`/`xhigh` AND state plainly when and how to use the tool ("Before claiming a collection is broken, fetch the live URL"). Do not assume the model will reach for a tool unprompted.
3. **Front-load the whole task in turn 1.** Well-specified, accurate task + intent + constraints in a single first turn maximises autonomy and token efficiency. Ambiguous prompts dripped over multiple turns reduce both performance and efficiency. This is why PNCapital dispatches are one rich turn, not a conversation.
4. **State scope literally — the model will not generalise it.** If an instruction should apply to every row/section/campaign, say so ("apply to every collection, not just the first"). Literalism is the default; unstated scope is treated as the narrow case. This is the model-level enforcement of `complete-deliverables` and the anti-fabrication extrapolation limit.

## Coverage-first rule for audit & investigation prompts

Current models honour conservative instructions faithfully. If a finding-stage prompt says "be conservative", "only report high-severity", or "don't nitpick", Opus 4.8 will investigate just as deeply, then *drop* findings it judges below the bar — measured recall falls even though bug-finding ability improved (Anthropic code-review guidance, May 2026).

For any investigation, audit, or finding stage where you want coverage (bleeder sweeps, SEO crawls, theme audits, search-term mining), instruct the opposite:

```
Report every finding, including low-severity ones and ones you are uncertain about.
Tag each with a confidence (low/med/high) and a severity. Do not filter for importance
or confidence at this stage — a separate ranking step will do that. Coverage is the goal:
a finding that later gets filtered out is cheaper than a real issue silently dropped.
```

Move the filtering/ranking into a later phase (or a downstream prompt). This composes with investigation-vs-fix separation: the investigation prompt demands maximal coverage; the fix prompt acts only on the ranked, verified subset.

## Default prompt scaffold

Use this as the starting structure for every marketing prompt. Adapt sections, never delete the refuse-the-field rule.

```
<role>One sentence. Discipline + seniority + context.</role>

<context>
Brand: BeautyOnTApp / Pastry Skincare / Mzuri Skin (pick one).
Platform: Shopify Advanced. SA market. ZAR. English only.
Attached: [list every file with column structure]
Period covered: [date range]
Account constraints relevant to task: [from 03_PNCapital_Business_Facts]
</context>

<task>One sentence describing the deliverable, not the method.</task>

<instructions>
Numbered steps. Each step has explicit thresholds, not "look for issues".
Each step references which attached file the data comes from.
State scope explicitly where an instruction applies to all rows/sections.
</instructions>

<output_format>
- Markdown table for rows × columns deliverables.
- Top 3 prioritised actions at end with effort (S/M/L) and impact (Low/Med/High).
- Any field missing from source: output "NOT IN SOURCE".
- Any claim that depends on data outside attached files: prefix "[NOT VERIFIED — validate via {named tool}]".
- No generic advice. Every recommendation must cite a specific row, ad ID, URL, or line number from attached files.
</output_format>

<anti_training_memory>
Treat your training data as unreliable for any business-specific claim about
BeautyOnTApp, Pastry Skincare, Mzuri Skin, or named competitors (Bash, Woolworths,
Clicks, Dis-Chem, Secret Skin, Glow Theory, Seoul of Tokyo). Only use information
present in the attached files or in 03_PNCapital_Business_Facts (current version).
</anti_training_memory>
```

## Model routing — by tier, not version

Route by tier. Anthropic ships new models frequently, so a pinned version goes stale fast — Opus 4.8 is the current top tier; treat the names below as tiers. Re-verify API constraints (sampling params, prefill, effort) on every major release.

| Use | Tier | Effort |
|---|---|---|
| Designing the prompt itself | Opus | xhigh |
| Multi-step audit synthesis (PMax full audit, ASC root-cause, full SEO audit) | Opus | high or xhigh |
| Single-file extraction, format conversion, simple rewrite | Sonnet | default |
| Execution dispatch (theme edits, Screaming Frog runs, redirect creation) | Sonnet | default/high |
| Sub-agent fan-out, classification, log triage | Haiku | default |
| Programmatic SEO uniqueness check across >50 pages | Opus | xhigh |
| Schema markup authoring + validation | Sonnet | high |

Codex CUT from PNCapital workflow as of 15 May 2026. Never route dispatches to Codex.

## Adaptive thinking — when to engage

Current Opus uses adaptive thinking with the `effort` parameter (standard / high / xhigh / max). `budget_tokens` is deprecated — omit it. The first lever for shallow reasoning is raising effort (see Execution levers above), not prompt wording. Use natural language only for fine control on top of the right effort level:

- **Engage more thinking**: "Think carefully and step-by-step before answering." Use for: root-cause diagnosis, multi-file reconciliation, programmatic uniqueness checks, schema design.
- **Engage less**: "Prioritise responding quickly rather than thinking deeply." Use for: format conversion, single-field extraction, table reformatting.

For Sonnet, extended thinking is off by default. Engage only for multi-step audits.

Note: Opus 4.8 self-calibrates progress updates and needs less anti-"AI slop" frontend scaffolding than prior models — strip legacy scaffolding like "summarise progress after every 3 tool calls" from older dispatch templates.

## Context-rot discipline

Per Chroma's *Context Rot* research (July 2025): performance degrades as input length grows, often non-uniformly. Capacity is the wrong metric — signal-to-noise matters more.

- **Single-file marketing exports** (Screaming Frog CSV ≤5K rows, GA4 30-day export, Google Ads search-term report): well under 200K tokens, Sonnet handles cleanly.
- **Multi-file audits** combining Semrush + GSC + Shopify + Meta exports: split into focused sessions. Route to Opus. Sonnet degrades past ~400K.
- **Long conversations** that accumulate audit history: start a fresh session with `beautyontapp-chat-handoff` summary. Do not keep loading more.

Anti-pattern: pasting an entire 200K-token Shopify theme export to ask one question. Excerpt the relevant file, attach it cleanly.

## Anti-patterns — remove from current prompting

| ❌ Stop doing | ✅ Do this instead |
|---|---|
| "You are a world-class expert with 30 years…" | One-line role in `<role>` tag. |
| "Be comprehensive / thorough / detailed" | Explicit structural scaffolding: row count, section count, bullet count. |
| "YOU MUST!!!", "NEVER EVER", "CRITICAL!!!" | Calm, direct instructions with reasons. |
| "Be conservative / only flag high-severity" in a finding stage | Coverage-first instruction; rank in a later step. |
| Adding "think harder" to fix shallow output | Raise the `effort` level. |
| Multi-task in one prompt (audit + RSAs + script) | Split into sequential prompts. |
| "Be creative with brand copy" | Load brand-voice reference file. Do not invent. |
| Prefilling assistant messages | `<output_format>` tags in user message. |
| Asking Claude to estimate metrics not in source | "If not in source, output NOT IN SOURCE." |
| Implicit assumption Claude knows 2025+ Google Ads / Meta features | Attach the current docs page. |
| "Audit my account" with no files attached | Refuse to write the prompt. Ask for the export first. |

## Domain quickstart — Google Ads

For PMax audits, Search audits, Shopping audits, conversion debugging, Scripts, negatives mining → see `references/google-ads-patterns.md`.

Critical rules:
- Always require attached CSV/Editor export (search-term report, asset-group performance, GMC feed sample).
- Always specify thresholds in numbers, not "find waste" / "look for issues".
- Always require per-row source citation in the output table.
- Conversion-tracking debugging: require both GA4 events list AND Google Ads conversions list. Refuse to proceed with only one.
- Scripts: paste the current Google Ads Scripts docs page. Do not let Claude rely on memory of the API.
- KS_C8_Brand_Protection is sole survivor and must always stay ENABLED in any output recommendation.
- Do not hardcode the daily/monthly budget ceiling into the prompt — reference `03_PNCapital_Business_Facts §Advertising Ceilings` (current values) instead.

## Domain quickstart — Meta Ads (Andromeda / GEM / Lattice era)

For ASC audits, creative diversity scoring, fatigue diagnosis, EMQ optimisation, scaling protocols → see `references/meta-ads-patterns.md`.

Critical rules:
- ASC audit is fundamentally a creative-diversity audit, not a settings audit. Andromeda penalises narrow targeting + many ad-set splits.
- Score conceptual distinctness 1–5 across four axes: hook framing, format, emotional trigger, visual style. Flag Entity ID clustering risk.
- EMQ Purchase target ≥ 8.0, AddToCart ≥ 6.5. Fix hierarchy: Pixel + Advanced Matching → CAPI → 8 hashed identifiers → dedup via shared `event_id`.
- Scaling cadence: 20% every 3-5 days, only when CPA has been below target for 5 straight days. Pause if CPA rises >20%.
- Never propose new Meta Pixels. Never start campaigns on Maximise Conversions.
- Content ID = Shopify ID (NOT Variant ID) on Pixel + CAPI for both BoT and Pastry.

## Domain quickstart — SEO / Content / GEO-AEO

For technical SEO audits, on-page briefs, programmatic SEO, SERP competitive analysis, GEO-AEO authoring, schema markup → see `references/seo-geo-patterns.md`.

Critical rules:
- Technical SEO audit: attach the Screaming Frog CSV. Refuse to estimate Core Web Vitals, backlinks, or rankings — flag "needs validation via {tool}".
- On-page brief: include a 40-60 word AI Overview answer paragraph extractable verbatim by Perplexity / AI Overviews / AI Mode.
- Programmatic SEO: separate structural template from generative blocks. Per-row uniqueness check (cosine similarity intros >0.85 = regenerate). Output `PRODUCTS_PENDING` if SKU column empty — do not invent products.
- SERP competitive: paste actual top-3 ranking URLs' HTML or excerpted content. Do not ask Claude to "analyse competitors" from memory.
- GEO-AEO interventions with verified lift (Princeton/Georgia Tech/IIT Delhi/Allen AI paper, ACM KDD 2024): statistics addition (+41%), quotation addition (+28%), opening-paragraph answer structure (~+40%). Cite-Sources strategy on rank-5 pages drove the often-misattributed 115% figure.
- 83% of BoT current organic traffic is brand search. Category capture is broken — every new brief must target a non-brand intent.

## Evidence-grounding techniques — fabrication kill list

1. **Refuse the field**: "If not in source, output `NOT IN SOURCE`."
2. **Quote-first grounding** (Anthropic's official anti-hallucination technique): "Before answering, extract verbatim the 3–5 lines from the attached source that support your answer. Place them in `<quotes>` tags. Only then answer in `<answer>` tags."
3. **NOT VERIFIED labelling**: "Any claim depending on data outside attached files: prefix `[NOT VERIFIED — check via {tool}]`."
4. **Source-line trace for tables**: "Every row must cite the source line number from the input file."
5. **Permit "I don't know"** as a first-class output, explicitly.
6. **Template-trap defence**: "If a row has insufficient source data for ≥2 columns, output `INSUFFICIENT DATA` for the row instead of completing it from training memory."
7. **Anti-training-memory clause** (rule #7 above) — applies to every business-specific prompt.
8. **Brand-description gate**: For any brand outside the confirmed SA-brand list (Pastry, Mzuri, B'AiR, Lelive, Forme, Skin Functional) and confirmed dermocosmetic stocked list (CeraVe, Eucerin, La Roche-Posay, Bioderma, Vichy, Avène, Neutrogena), the prompt must require web_fetch of the live collection page before any descriptive copy. Brand-name recognition from training memory is never sufficient.

## Output-format defaults

- **Rows × columns deliverables** → Markdown table. Header row + data rows. No prose.
- **Audits** → table per step, then top 3 prioritised actions with effort/impact at end. Finding stage uses the coverage-first rule above.
- **Scripts / JSON-LD / regex** → fenced code blocks with language tag.
- **Dispatches to Sonnet** → persona top, hard constraints first, phases separated (investigate → fix → confirm), escalation list at end.
- **Briefs** → numbered sections. Missing inputs listed under explicit `MISSING INPUTS` heading rather than filled from memory.
- **Investigation prompts** → zero edits, pure data capture, maximal coverage, output CSV or table.
- **Fix prompts** → only 100%-verified changes. Never bolt data-capture onto a fix.

## When to refuse to write the prompt

Refuse and ask exactly one question when:
- Required source file not attached (e.g. PMax audit requested without Google Ads export).
- Action is irreversible AND has materially different interpretations (e.g. "redirect all -1 collections" without confirming canonical target).
- Confidence in intent is below 60% AND no tool call can raise it.

Otherwise, act.

## Self-check before delivering the prompt

Before outputting the drafted prompt, verify:

1. `<role>` is one sentence.
2. `<context>` lists every attached file with column structure.
3. `<task>` describes deliverable, not method.
4. `<instructions>` has numbered steps with numeric thresholds, not "look for issues", and states scope explicitly where it applies to all items.
5. `<output_format>` specifies table structure, action count, effort/impact scoring.
6. Refuse-the-field rule is present (rule #3).
7. Anti-training-memory clause is present (rule #7).
8. No ALL-CAPS imperatives anywhere.
9. No "be comprehensive", "be thorough", "be creative" without scaffolding; no "be conservative" in a finding stage.
10. No prefilling. No temperature/top_p/top_k instructions. Effort level set appropriately for the task.
11. Model routing matches task type by tier (Opus for design/audit synthesis, Sonnet for execution, Haiku for fan-out).
12. If task requires both investigation and fix: two separate prompts, not one.

If any check fails, rewrite before delivering.

## How to invoke

This skill auto-loads on the trigger keywords in the description. When T pastes a marketing data file or asks for a prompt for a marketing task:

1. Confirm required source files are attached. If missing, ask exactly one question.
2. Pick the domain quickstart (Google Ads / Meta Ads / SEO).
3. Build the prompt using the default scaffold.
4. Set the effort level and tier per the routing table.
5. Run the self-check (12 items above).
6. Deliver the prompt as a fenced code block, ready to paste into a new session or dispatch to Sonnet.

For prompts T writes himself and pastes for review, output a Markdown diff or a rewritten version — never a generic "here are some improvements" list.

## References (load on demand)

- `references/google-ads-patterns.md` — PMax audit, Search audit, Shopping audit, conversion debug, Scripts, negatives mining. 5 worked examples.
- `references/meta-ads-patterns.md` — ASC audit, Andromeda creative diversity, EMQ fix hierarchy, scaling protocol, fatigue diagnosis. 5 worked examples.
- `references/seo-geo-patterns.md` — Technical audit, on-page brief, programmatic SEO, SERP competitive, GEO-AEO authoring, schema. 5 worked examples.
- `references/anti-patterns.md` — Anti-patterns with one-line "use this instead" replacements.
- `references/examples.md` — 5 full before/after prompt rewrites: PMax audit, ASC audit, collection-page brief, programmatic SEO template, SERP competitive analysis.

## Pairs with

- `beautyontapp-audit-first` — read source before recommending.
- `beautyontapp-evidence-citations` — every claim cites a source.
- `beautyontapp-execute-dont-ask` — call the tool instead of asking.
- `beautyontapp-ship-it-right-first-time` — self-audit before shipping.
- `beautyontapp-complete-deliverables` — ship all known-sourced fixes in one pass.
- `beautyontapp-challenge-verify` — self-verify on irreversible changes.
- `beautyontapp-research-mode` — when prompt requires factual claims.
- `beautyontapp-subagent-orchestrator` — investigation + execution separation.
- `beautyontapp-skill-authoring` — when the deliverable is a skill rather than a prompt.

## What this skill does NOT do

- Does not write ad copy, briefs, or content — that's `beautyontapp-copywriting-engine` and the SEO/content skills.
- Does not execute audits — that's `beautyontapp-ppc-audit-engine` / `beautyontapp-meta-audit-engine`.
- Does not configure platforms — that's the domain skills (`beautyontapp-google-ads`, `beautyontapp-meta`, `beautyontapp-shopify`).
- Does not select competitors — that's the competitive intel skills.
- Does not score or maintain skills — that's `beautyontapp-skill-health`; does not author skills — that's `beautyontapp-skill-authoring`.

This skill governs HOW prompts are written. The execution skills do the work.

## Versioning

v2 (29 May 2026) — Repointed model references from pinned Opus 4.7 / Sonnet 4.6 to tier-based routing (Opus 4.8 is current top tier); fixed Business_Facts_v5 → current-version reference in the anti-training-memory scaffold; added the four current-model execution levers (effort as primary lever, tool-use-needs-effort, front-load turn 1, explicit-scope literalism) and the coverage-first rule for audit/investigation prompts; added "be conservative in a finding stage" and "think harder vs raise effort" to the anti-patterns table; noted Opus 4.8 needs less progress/anti-slop scaffolding. Sources: Anthropic prompting best-practices guide (Opus 4.8, May 2026), Anthropic code-review-harness guidance, PNCapital 29 May 2026 reconcile, project instructions §Claude Platform State.

v1 — first deployed. Built from Anthropic's official prompting docs (May 2026), Opus 4.7 release notes, Chroma's *Context Rot* research, Confect's 2026 Andromeda study, Foxwell on GEM, Princeton GEO paper (KDD 2024), Anthropic's official skills repo, and PNCapital's documented failure modes (17 May 2026 brand fabrication incident).

When Anthropic ships a successor model, re-verify: prefill behaviour, temperature controls, adaptive thinking / effort parameter, context-rot thresholds. Update the routing table (tiers stay; re-confirm constraints).
