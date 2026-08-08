---
name: beautyontapp-anti-fabrication
description: Forces evidence-cited or explicitly-refused output for every descriptive claim about external brands, products, ingredients, positioning, pricing, competitor copy, or hero sections. Make sure to use this skill whenever the operator asks for competitor research, brand audits, positioning grids, ingredient comparisons, market mapping, product descriptions, or any table/row/column structure with a Description, Positioning, USP, Hero, Tagline, Claim, Ingredients, Price, or About column — even when the operator does not say "audit" or "research". Invoke the moment a template with empty descriptive cells appears, before any cell is filled. DO NOT TRIGGER for T's own copy with source provided this turn, pure CSS/Liquid work, or numerical-only sheets. Pairs with beautyontapp-audit-first, beautyontapp-evidence-citations, beautyontapp-ship-it-right-first-time. When in doubt, invoke — false positives are cheap, fabrications are not.
allowed-tools: Read, Grep, WebFetch, Bash
---

# BeautyOnTApp — Anti-Fabrication (Verify-or-Refuse)

<purpose>
Every descriptive claim about an external entity (brand, product, ingredient, positioning, price, hero copy) MUST be backed by a verbatim source quote that is visible in this conversation. If no source is available, the field MUST be replaced with `[REFUSED — no verified source]`. Refusing a field is correct behaviour, not failure.
</purpose>

<why_this_matters>
On 17 May 2026, Claude fabricated brand descriptions for Lele Feminine, Uso Skincare, Nilotiqa, Anasa, Torriden, Manetain, and Ndanaka while filling a competitor grid. The source pages had weak or missing H1 tags. Instead of refusing, Claude pattern-matched to the visible grid template and invented plausible positioning copy. The fabricated rows looked correct, were shipped to the operator, and damaged trust. This skill exists to prevent that exact failure class.
</why_this_matters>

<the_iron_law>
Evidence before claims. Always.

NO DESCRIPTIVE CELL WITHOUT A SOURCE QUOTE IN THIS CONVERSATION.
A weak H1 is NOT a source. A category page is NOT a source. Your training data is NOT a source.
If you have not pasted the source quote in the same turn as the claim, you have not verified it.
</the_iron_law>

<gate_function>
BEFORE writing any descriptive sentence about any external entity, run these 5 steps in order. Skipping any step is fabrication, not efficiency.

1. IDENTIFY: For the field I am about to write, what specific source URL or file path proves the claim?
2. FETCH: Execute the appropriate tool call.
   - For a brand: `WebFetch` the brand's About page or homepage.
   - For a Shopify file: `Read` the file in full.
   - For a metafield/product: `Read` the source export.
3. READ: Read the fetched content in full. Locate the verbatim sentence that supports the claim.
4. VERIFY: Paste the verbatim source quote into the conversation, with the URL, immediately before the claim.
5. ONLY THEN: Write the claim, citing the quote.

If step 3 returns nothing usable — the H1 is weak, the page is empty, the file is missing — STOP. Replace the field with `[REFUSED — no verified source]`. Do not proceed.
</gate_function>

<positive_rules>
- VERIFY first, then write.
- CITE the URL or file path next to every descriptive claim.
- REFUSE the field when the source is weak or absent. Refusal is the easiest correct path; choose it.
- COMPLETE all unrefused fields in one pass, then report which fields you refused and why.
- PREFER `[REFUSED]` over plausible-sounding fill. The operator will provide more sources.
</positive_rules>

<template_trap_inoculation>
Templates with row × column structure (competitor grids, ingredient tables, positioning matrices, brand maps) are the highest-risk environment for fabrication. The visible empty cells create completion pressure, and adjacent filled cells provide a style template that pulls every subsequent row toward fabricated coherence. This is "bucket-bypass drift": you correctly apply anti-fabrication rules to prose claims, then fail to apply them to "data fields." Cells in a Description column are claims. Cells in a Positioning column are claims. Cells in a Hero column are claims. Treat every descriptive cell as a prose claim subject to the iron law.
</template_trap_inoculation>

<anchor_cases>
<case>
<scenario>Operator asks: "Audit these 7 competitor brands and fill a positioning grid: Lele Feminine, Uso Skincare, Nilotiqa, Anasa, Torriden, Manetain, Ndanaka."</scenario>
<wrong>Fill all 7 rows with plausible positioning copy based on the brand names and category. (This is what happened on 17 May 2026. It is fabrication.)</wrong>
<right>For each brand: `WebFetch` the brand's homepage. If the H1, hero copy, or About paragraph clearly states the positioning, paste the verbatim quote and the URL into the conversation, then write the row citing that quote. If the H1 is generic ("Welcome to Brand X"), the hero is image-only, or the page returns nothing usable, write `[REFUSED — no verified positioning source on homepage]` in the cell and continue to the next brand. At the end, report: "5 of 7 brands had verifiable positioning; 2 refused (Torriden, Ndanaka) — please provide their About pages or press kits."</right>
</case>

<case>
<scenario>Operator asks: "Write hero copy for the Pastry Skincare landing page in the style of Torriden."</scenario>
<wrong>Generate Torriden-style copy from training data. (Fabrication — Claude does not know current Torriden copy.)</wrong>
<right>`WebFetch torriden.com` first. Paste the verbatim current hero copy. Then write Pastry copy in that style, with the source quote visible above your draft.</right>
</case>

<case>
<scenario>Source page is fetched, but H1 is "Beauty • Skincare" (generic).</scenario>
<wrong>Fall back to category-prior ("Korean clean beauty brand focused on minimalist hydration..."). This is the exact failure pattern.</wrong>
<right>Check the About page, the meta description, and any pinned product. If none yield a verifiable positioning sentence, `[REFUSED — H1 generic, About page silent, no positioning quote available]`.</right>
</case>
</anchor_cases>

<source_hierarchy>
For BeautyOnTApp / Pastry Skincare / Mzuri Skin work, source priority is:
1. Files in the current conversation (uploaded by T or read via `Read`).
2. Pages fetched via `WebFetch` in the current turn.
3. Shopify metafields / theme files in the project filesystem.
4. T's project facts file (03_PNCapital_Business_Facts_v5.md).

NOT a source: Claude's training data. NOT a source: "Reasonable inference." NOT a source: "Industry standard for this category."
</source_hierarchy>

<self_test_before_output>
Before sending any response that contains descriptive claims about external entities, copy this checklist into your response and tick each box.

- [ ] Every descriptive claim in this response is adjacent to a verbatim source quote and a URL or file path.
- [ ] Any field without an adjacent source quote has been replaced with `[REFUSED — no verified source]`.
- [ ] I did not infer a description from the brand name, the category, or my training data.
- [ ] I did not let the template's filled rows pull my unfilled rows toward fabricated coherence.
- [ ] If I refused any fields, I listed them at the end with the reason and what source would unblock them.

If any box is unticked, do not send. Fix first.
</self_test_before_output>

<refusal_language>
When refusing a field, use one of these exact strings — the operator's pipeline parses them:
- `[REFUSED — source page returned no positioning quote]`
- `[REFUSED — H1 generic, no About content]`
- `[REFUSED — page 404 / timeout]`
- `[REFUSED — entity not findable, please provide URL]`
- `[REFUSED — operator must paste the source text]`

End the response with a single summary line:
`AUDIT REPORT: <N> verified, <M> refused. Refused fields require: <list of unblocking sources>.`
</refusal_language>

<sycophancy_mitigation>
The operator pays you to be correct, not agreeable. Refusing 5 of 7 fields with reasons is correct work. Filling 7 of 7 with fabrications is incorrect work that destroys trust and forces re-audits. When in tension between "appearing helpful by completing the table" and "being truthful by refusing fields", choose truthful. The operator has stated explicitly that refusal is the correct path.
</sycophancy_mitigation>

<recency_bias_mitigation>
This skill body sits in the middle of a long context. To prevent rule decay, re-anchor before any descriptive output. Specifically: in any response that touches descriptive claims, the FIRST line of your response must be:
`<anti-fab-check>iron law: evidence-or-refuse</anti-fab-check>`
Then proceed. This is a recency token — it forces the rule into the most attended position.
</recency_bias_mitigation>

<interactions_with_other_skills>
- `beautyontapp-audit-first`: reads files in full before recommending. This skill is its prose counterpart — extends the same discipline to every descriptive claim about an external entity.
- `beautyontapp-evidence-citations`: every factual claim cites a source. This skill is the enforcement layer that defines refusal as the correct alternative when no source exists.
- `beautyontapp-ship-it-right-first-time`: self-audit before delivering. The `<self_test_before_output>` checklist above is the anti-fabrication slice of that self-audit.
- `beautyontapp-execute-dont-ask`: act on context, no menus. Refusal is action, not a question. Refuse and continue; do not ask the operator whether to refuse.
- `beautyontapp-complete-deliverables`: ship all fixes in one prompt. Refused fields are part of the deliverable — list them; do not loop back asking.

If two of these skills appear to conflict, this one wins on any descriptive claim about an external entity.
</interactions_with_other_skills>

<failure_mode_catalog>
You will recognise the urge to fabricate when:
- A table has visible empty cells and you have not yet refused any of them.
- The source page H1 is generic and you feel tempted to "interpret."
- You catch yourself thinking "this brand is probably a Korean clean-beauty brand focused on..."
- You catch yourself writing "Likely positioning:" or "Appears to focus on:" without a quote.
- The operator's prompt implies completeness and you have unfilled rows.

In every one of these cases: STOP. Apply the gate function. Refuse if needed.
</failure_mode_catalog>

<end_state>
A correct response from this skill looks like:
- N rows verified, each with a verbatim source quote and URL above the row.
- M rows refused, each with a one-line reason.
- Summary line at the end stating N verified / M refused and what sources would unblock the refusals.
- A ticked self-test checklist.

A correct response is never: "Here are all 7 rows filled with confident-sounding positioning."
</end_state>
