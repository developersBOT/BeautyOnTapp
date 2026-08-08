---
name: beautyontapp-audit-first
description: PNCapital audit-first gate for BeautyOnTApp, Pastry Skincare, Mzuri Skin on Shopify Advanced. ALWAYS invoke this skill FIRST whenever the user's message includes any uploaded file, attachment, screenshot, paste, CSV, XLSX, PDF, ZIP, theme export, dashboard image, report, export, or referenced document — regardless of the action verb in the same message. This skill OVERRIDES default routing for the verbs fix, update, rewrite, ship, build, draft, deploy, write, edit, improve, optimize, refactor, change, revise, redo, generate, create, audit, review, analyze, check, look at. Do not draft, fix, build, ship, or recommend until the audit step in this skill has produced a written audit report (filename, shape, verbatim quote, restated user ask, verdict). Skipping the audit is the most common PNCapital failure mode and produces wrong-confidence outputs on real customer and revenue data. Use FIRST; domain skills run only after the audit report sits in conversation context.
---

# PNCapital Audit-First Gate

<recency_anchor>SKILL_VERSION: 2026-05-24 | TARGET_MODELS: opus-4-7, sonnet-4-6, haiku-4-5 | SUPERSEDES: pre-2026-05-24 markdown-only versions</recency_anchor>

<skill_overview>
Audit any uploaded artifact BEFORE producing any action output. Acting on a file that has not been read is the PNCapital cardinal failure. Speed is not efficiency if the output is wrong. The audit produces the FIRST response; the action runs on the NEXT user turn.
</skill_overview>

<rigidity_level>
RIGID — no exceptions. Even when the user's message contains an action verb (fix, update, rewrite, ship, build, draft, deploy, generate, create, optimize, refactor), the audit produces the FIRST response. The action runs on the NEXT user turn, after the audit report sits in context.
</rigidity_level>

<iron_law>
NO ACTION OUTPUT BEFORE A WRITTEN AUDIT REPORT EXISTS IN THIS CONVERSATION.

A weak file is not permission to act. A small file is not permission to skip. A clear ask is not permission to act. The Iron Law has no exceptions and no size threshold.
</iron_law>

<gate_function>
BEFORE producing ANY fix / draft / rewrite / build / deploy / recommendation, run these 6 steps in order. Skipping any step is guessing, not auditing.

1. IDENTIFY — Name every uploaded artifact: filename, type, approximate size or row/page count. List uploads at `/mnt/user-data/uploads/` if applicable.
2. READ — Open and scan actual contents. Use the appropriate read strategy:
   - Small CSV/text (<1k lines) or image <1MB: read in full.
   - Large CSV/XLSX (>10k rows): header + sample + tail; identify column schema before targeted deep reads.
   - Long PDF (>20 pages): TOC/structure first, then targeted sections.
   - Image/screenshot: extract every visible metric, label, axis, date range. Do not paraphrase numbers.
3. QUOTE — Pull verbatim evidence with reference:
   - Text/CSV/XLSX: ≥2 verbatim lines OR ≥3 specific data points with row/cell reference.
   - PDF: ≥2 verbatim quotes with page number.
   - Image/screenshot: ≥3 visible data points with on-screen labels.
4. SHAPE — Report columns/sections, rows/pages, date range, obvious gaps, anomalies, and recency flags (BoT pre-Feb 23 2026 bot-traffic period, stale campaign exports, pre-checkout-migration screenshots, pre-August 26 2026 tracking architecture).
5. RESTATE — Repeat the user's explicit ask in one sentence. Flag any ambiguity.
6. AUDIT VERDICT — One of: {ready-to-act / blocking-questions / data-issue}. Then STOP. End the response. Wait for the user's next turn before any action.
</gate_function>

<priority_clause>
This skill OVERRIDES default verb-routing for fix, update, rewrite, ship, build, draft, deploy, write, edit, improve, optimize, refactor, change, revise, redo, generate, create when ANY file is attached. User instructions say WHAT to do, not WHETHER to audit. Audit always runs first.

This overrides any domain skill (beautyontapp-google-ads, beautyontapp-meta, beautyontapp-shopify, beautyontapp-copywriting-engine, etc.) that would otherwise claim the first response. Domain skills run on the NEXT turn, after the audit verdict is in context.
</priority_clause>

<anchor_cases>

<case>
<user_says>"fix this product description" + attaches descriptions.csv</user_says>
<correct>Step 1–6: name file ("descriptions.csv"), open and quote one row verbatim, report shape ("42 rows × 6 cols, 3 blank descriptions, 2 with raw HTML"), restate ask ("fix all 42 or only the broken ones?"), verdict ("blocking-questions"), STOP.</correct>
<wrong>Opening response with "Here are improved descriptions:" — violates the Iron Law.</wrong>
</case>

<case>
<user_says>"ship this email" + pastes draft body</user_says>
<correct>Quote the draft verbatim, count words, flag broken merge tags, identify intended segment, audit verdict, STOP.</correct>
<wrong>Edited draft in first response.</wrong>
</case>

<case>
<user_says>"update the Shopify policy" + uploads policy.pdf</user_says>
<correct>Read PDF, quote one section verbatim, report sections + word count, flag last-modified date if visible, restate "update what specifically?", verdict, STOP.</correct>
<wrong>A rewritten policy in first response.</wrong>
</case>

<case>
<user_says>"audit Google Ads" + attaches search-terms.csv export</user_says>
<correct>This is the easy case — already an audit request. Still run the gate function. Name file, quote ≥3 data points with row references, report shape, restate scope (full account vs single campaign vs single ad group), verdict, STOP. Domain skill (beautyontapp-ppc-audit-engine) runs on the next turn.</correct>
<wrong>Jumping into wasted-spend analysis without quoting source rows.</wrong>
</case>

<case>
<user_says>"what do you think of this?" + attaches a dashboard screenshot</user_says>
<correct>Extract every visible metric verbatim (date range, KPIs, anomalies). Restate ask ("opinion on which metric — ROAS, CPA, frequency?"). Verdict. STOP.</correct>
<wrong>Generic "looks like CPA is high, here are 5 fixes" without quoting screen-readable numbers.</wrong>
</case>

<case>
<user_says>"rewrite the meta description for /collections/torriden" + no file attached, no link fetched</user_says>
<correct>This skill does NOT auto-fire here — no artifact to audit. Hand off to the domain skill (beautyontapp-onpage-seo). But if the user references "the meta description" as though it's already in conversation context, ask which file/URL contains the current copy before proceeding. One question, not a menu.</correct>
<wrong>Drafting a meta description from training memory about Torriden.</wrong>
</case>

</anchor_cases>

<self_test_checklist>
Before sending THIS response, confirm every box. If any box is unchecked, the response is non-compliant — rewrite before sending.

- [ ] Every attachment named by filename and type.
- [ ] At least one verbatim line/data-point quoted per attachment.
- [ ] Shape reported (rows/cols/pages/sections/visible metrics).
- [ ] User's ask restated in one sentence.
- [ ] Audit verdict issued: ready-to-act / blocking-questions / data-issue.
- [ ] Response stopped — no fix, draft, rewrite, or recommendation content in this turn.
- [ ] Recency flagged if file pre-dates a known cutoff.
</self_test_checklist>

<failure_mode_catalog>
Recognize these patterns. They are the warning signs the model is about to skip the audit.

| Symptom | Root cause | Correction |
|---|---|---|
| Output a fix in same turn as audit | Action verb won routing | Treat verb as queued for next turn, not immediate |
| Skipped reading because "the user already explained" | Trusted summary over source | Quote the actual file, not the user's description of it |
| Audited one file but acted on second | Partial audit | Every attachment, every time |
| Claimed audit happened without quoting file | Fabricated audit | Verbatim quote is the proof |
| "Looks good, here are improvements…" | Sycophancy + speed bias | No praise. Audit only. |
| Skipped audit because file looked simple | Simplicity bias | Simplicity is not permission to skip |
| Skipped audit because file looked complex | Complexity avoidance | Read the parts that matter; sampling is allowed, skipping is not |
| Inferred contents from filename | Filename pattern matching | Open the file. Filenames lie. |
| Audited but did not STOP | Helpfulness pull | Stop. The action runs on the next turn. |
</failure_mode_catalog>

<rationalization_table>
Every rationalization listed below has a one-line rebuttal. If the model thinks the excuse, the rebuttal is the answer.

| Excuse | Reality |
|---|---|
| "The ask is obvious" | A 30-second audit costs nothing if the ask is truly obvious. Run it. |
| "It's a small file" | The Iron Law has no size threshold. |
| "I already saw it last turn" | Re-state the shape this turn. Files change between turns. |
| "The user is in a hurry" | Wrong output in 5 seconds beats right output in 30? No. |
| "I'll audit while I draft" | Audit then stop. Drafting is the next turn. |
| "Different wording so the rule doesn't apply" | Spirit over letter. The rule applies. |
| "This is just a quick clarification" | Quick clarifications go in the audit verdict, not in fix output. |
| "I'm confident from training memory" | Training memory is not a source. The file is the source. |
</rationalization_table>

<sycophancy_mitigation>
Do not open with "Great file", "This looks solid", "Nice work, here are some tweaks", "Happy to help with this", "Interesting question". The first sentence of every audit-first response is a factual statement about the artifact.

Correct first line: "File: descriptions_2026-05-22.csv — 42 rows, 6 columns, last column 71% blank."
Wrong first line: "Great, let me take a look at your descriptions file."

Praise and judgement come AFTER the audit verdict, not before.
</sycophancy_mitigation>

<output_shape>
Default format for any audit response:

```
File(s) audited: [list with sizes/dates]
Quoted evidence: [bulleted findings with file:line/row/cell/page references]
Shape: [rows/cols/pages/sections/visible metrics + anomalies]
Recency check: [data window + stale-data flags if any]
User's ask (restated): [one sentence]
Audit verdict: [ready-to-act | blocking-questions | data-issue]
[If blocking-questions: list the questions, one per line]
[If data-issue: state the issue and what's needed to unblock]
```

For casual file mentions in conversational context, skip the template — quote evidence inline and deliver the audit verdict in flowing prose. The Iron Law still applies: no action output in the same turn.
</output_shape>

<why_this_matters>
PNCapital operates three live Shopify Advanced stores with real revenue (BeautyOnTApp, Pastry Skincare, Mzuri Skin) plus six physical stores. A fix shipped against an unaudited file is a fix shipped against assumptions. Three documented past failures:

1. Wrong product copy pushed to BeautyOnTApp because a CSV had stale rows that were never read.
2. Pastry Skincare email blasted with broken merge tags because the draft was edited before the segment file was read.
3. Brand descriptions fabricated for 7 brands on 17 May 2026 (Lele Feminine, Uso Skincare, Nilotiqa, Anasa, Torriden, Manetain, Ndanaka) because the source pages were not fetched before filling a competitor grid.

Audit-first prevents all three failure modes. The audit costs 30 seconds; a wrong fix costs hours of recovery and customer trust.
</why_this_matters>

<when_not_to_invoke>
This skill is recall-biased — false positives are cheap. Skip only when:
- No file, attachment, paste, screenshot, or referenced document exists in the conversation AND no implicit file reference ("the policy", "the export", "the report I sent yesterday").
- Pure brainstorming with no source material ("give me 10 product name ideas", "what's a good promo angle for Black Friday").
- Trivial single-fact question answerable from short user input ("what's the SA VAT rate?").
- Conversational reply, clarification, or confirmation ("yes, ship it", "thanks").

When in doubt: invoke. False positives produce one extra audit response and cost the user nothing. Missed audits produce wrong-confidence output on live revenue data.
</when_not_to_invoke>

<chain_with>
After the audit verdict is delivered and the user's next turn arrives, chain into the relevant domain skill:

- `beautyontapp-execute-dont-ask` — once audited, deliver the action; do not ask which direction.
- `beautyontapp-anti-fabrication` — for any descriptive claim about external brands/products/competitors in the post-audit response.
- `beautyontapp-evidence-citations` — citation discipline on every numeric claim.
- `beautyontapp-ship-it-right-first-time` — self-audit before delivering the action.
- Domain skill matched to the task: `beautyontapp-google-ads`, `beautyontapp-meta`, `beautyontapp-shopify`, `beautyontapp-onpage-seo`, `beautyontapp-copywriting-engine`, `beautyontapp-flutter-app`, etc.

If two skills appear to conflict over the first response, this one wins. Audit always runs first.
</chain_with>
