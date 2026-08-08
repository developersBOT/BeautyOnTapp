---
name: beautyontapp-creative-qa-rubric
description: Pre-launch creative quality assurance scoring rubric for BeautyOnTApp, Pastry Skincare, and Mzuri Skin. Scores ad variants 1-10 against advertising psychology principles (Cialdini influence levers, AIDA mechanics, hook clarity, value-prop placement, mobile-first composition, brand-voice fit, evidence grounding) BEFORE creative ships to Meta, Google Ads, TikTok, or any paid surface. Outputs per-variant scores with justification, identifies the single highest-leverage rewrite per variant, and ranks variants for launch order. Make sure to invoke whenever T asks for "creative QA", "score this creative", "rate these ads", "rubric scoring", "pre-launch review", "creative scoring", "rank these variants", "which creative should I launch", "QA before shipping", or wants to evaluate ad copy / static creative / video creative before paid spend. Pairs with rsa-generator, copywriting-engine, meta-creative-testing, voc-mining, brand-context.
---

# Creative QA Rubric

## Why this skill exists

Pixis published an analysis of 150,000+ Prism user sessions in 2025 identifying the single highest-leverage prompt-engineering pattern for creative work: a pre-launch QA scoring step grounded in named advertising psychology principles, scoring 1-10 with justification, and producing one improved variant per ad with evidence-based reasoning.

PNCapital ships creative across Google Ads (RSAs via `beautyontapp-rsa-generator`), Meta (ASC creatives, primary text, headlines), TikTok, email subject lines, and SMS. The cost of weak creative shipping is direct: at PNCapital's Meta + Google daily ceilings, a single underperforming creative live for several days burns thousands with nothing to show.

This skill catches weakness before paid spend, not after. It is the gate between drafting (rsa-generator, copywriting-engine) and launching (meta-creative-testing, google-ads).

It does NOT replace post-launch creative testing — that's `beautyontapp-meta-creative-testing` (hook rate, hold rate, fatigue diagnosis on live data). This skill scores drafts before they go live.

## When to invoke

Auto-invoke when T:

- Asks for "creative QA", "score this creative", "rate these ads", "rubric scoring", "pre-launch review", "creative scoring"
- Asks "rank these variants" or "which creative should I launch first"
- Uploads ad copy drafts, static creative descriptions, video scripts, or storyboards
- Outputs from `beautyontapp-rsa-generator` arrive and need pre-launch sanity check
- Outputs from `beautyontapp-copywriting-engine` arrive for Meta/TikTok and need pre-launch sanity check

Pair with `beautyontapp-brand-context` (brand voice), `beautyontapp-voc-mining` (verifies VoC grounding), `beautyontapp-evidence-citations` (verifies source claims).

## Required source data

This skill is data-bound. Refuse without:

1. **The variants to score** — minimum 2, maximum 20 per run. Below 2 there's nothing to compare; above 20 the per-variant attention drops and rubric quality degrades.

2. **Surface** — Google RSA (headlines + descriptions), Meta primary text + headline, TikTok caption + video script, email subject line + preview, SMS body. Different surfaces have different rubric weights.

3. **Brand** — BoT, Pastry, or Mzuri. Different brand voices apply.

4. **Target query / audience / use case** — what is each variant trying to do? Different intents weight the rubric differently.

5. **Landing page or destination URL** — message-match is a rubric dimension. Without the destination, can't score it.

If items 1-4 are missing, refuse and ask ONE question. Item 5 is required for paid creative; for organic surfaces (email, SMS), it's optional.

## The 8-dimension rubric

Each variant gets scored 1-10 on every dimension. Total possible = 80. Launch threshold = 56 (70% of total). Below 56 = rewrite before launching.

### Dimension 1 — Hook clarity (weight: 15%)

Does the first 3-5 words / first second of video / subject line / RSA position 1 headline hit the reader's pain or value proposition without preamble?

- 10: Reader knows in 1 second what the creative is about and why they should care.
- 7-9: Hook is clear but needs 2 seconds.
- 4-6: Hook is present but generic ("Discover…", "Introducing…", "We're…").
- 1-3: No hook. Buried lead. Brand-first instead of customer-first.

Anti-pattern: "BeautyOnTApp – Your Beauty Destination" (brand-first, value-prop absent).
Good pattern: "Skin tight after washing? Fix it in 7 days." (pain-first, time-bound).

### Dimension 2 — Value proposition placement (weight: 15%)

Is the specific value delivered to the customer (not the brand's features) named in the first 25% of the asset?

- 10: First 25% names the customer outcome.
- 7-9: Value-prop present but in the second 25%.
- 4-6: Value-prop in the back half.
- 1-3: Value-prop absent or replaced with brand features.

Map to AIDA mechanics: Attention + Interest must hit before Desire + Action. Most weak creative collapses Attention and Interest into "look at our brand."

### Dimension 3 — Cialdini influence lever (weight: 10%)

Does the creative deploy at least one named Cialdini lever?

- Reciprocity (free skin scan with order)
- Commitment / consistency (Skin IQ Club tier progression)
- Social proof (4.8★ from 2,400 reviews — Judge.me aggregate)
- Authority (skin analysis by trained consultants)
- Liking (Bestie persona, SA proudly local brands)
- Scarcity (limited Korean restocks, stock callouts)

Scoring:
- 10: Two or more levers used, both relevant, both subtle.
- 7-9: One lever, well-deployed.
- 4-6: One lever, generic or forced.
- 1-3: No lever, or worse, anti-lever (vague urgency, fake countdown, invented scarcity).

Forbidden anti-levers:
- "Limited time offer" without a real time bound
- "Selling fast" without stock data
- "Free delivery" — PNCapital does not offer free delivery
- "Exclusive" without a real exclusivity (channel, member tier, geo)

### Dimension 4 — Mobile-first composition (weight: 10%)

Will this read on a phone at scroll speed?

- 10: First 1-2 lines stop the scroll. Text legible at small size. CTA visible without expansion.
- 7-9: Strong above-the-fold but breaks at small screen.
- 4-6: Designed for desktop. Mobile is an afterthought.
- 1-3: Mobile-hostile. Long paragraphs, buried CTA, tiny text.

SA market: 70%+ of beauty traffic is mobile per business facts. This dimension's weight reflects that.

For RSAs (no visual): scoring covers headline impact within 30 chars + description scannability within 90 chars.

### Dimension 5 — Brand-voice fit (weight: 10%)

Does the creative sound like BoT, Pastry, or Mzuri — not a generic e-commerce template?

Reference: `beautyontapp-brand-context` IS / IS-NOT words + 5 example sentences.

- 10: Indistinguishable from BoT's best-performing past assets. Brand voice clear without naming the brand.
- 7-9: On-brand with minor drift.
- 4-6: Generic beauty e-commerce voice. Could be Clicks, Dis-Chem, anyone.
- 1-3: Off-brand. Violates IS-NOT words. Sounds like a competitor.

Forbidden:
- Afrikaans (English only per business rules)
- "Bestie" replaced with "AI assistant" / "chatbot"
- Emoji other than 🖤 (brand emoji rule)
- "Beautyontapp" mis-spelled or capitalised wrong

### Dimension 6 — VoC grounding (weight: 10%)

Does the creative use language from the VoC mining language bank (per `beautyontapp-voc-mining`), or does it use invented copywriter language?

- 10: ≥2 phrases trace directly to VoC language bank with source citations.
- 7-9: 1 phrase from VoC bank, rest is brand-context-aligned.
- 4-6: No VoC phrases but tone matches.
- 1-3: Pure copywriter invention. No customer language. High fabrication risk.

This dimension exists because the Gerhard Engel "Streamline Your Workflow → Stop Losing Hours to Broken Handoffs" 34% conversion lift came from VoC grounding, not copywriting creativity. Pre-launch QA should catch invented language before it ships.

### Dimension 7 — Evidence grounding (weight: 10%)

Does every factual claim in the creative have a verifiable source?

- 10: Every number, brand claim, stocking claim, price, delivery promise, service claim has an inline-traceable source.
- 7-9: One unsourced claim that is verifiable (e.g. price T can confirm).
- 4-6: 2-3 unsourced claims. Some training-memory drift.
- 1-3: Multiple fabricated claims. Brand positioning invented, prices guessed, ingredients claimed without source.

Hard rule: any score below 7 on this dimension is a launch blocker regardless of total. Fabricated claims on a live store damage the business.

Specific things to flag:
- Free delivery / free shipping claims (PNCapital does not offer these — auto-fail)
- Prices not matching R285 skin analysis, R199 hair analysis, R1,200 loyalty redemption
- Brand claims about brands outside the confirmed SA list + dermocosmetic list without web_fetch sourcing
- "Same-day delivery" claimed outside Sandton + MoA (auto-fail)
- "1-hour delivery" in customer-facing copy (auto-fail — internal SLA only)

### Dimension 8 — Distinctness from siblings (weight: 10%)

Within the set of variants being scored, how conceptually distinct is this one?

- 10: Hook, format, emotional trigger, visual style all distinct from every other variant in the set.
- 7-9: 3 of 4 axes distinct.
- 4-6: Variation but ≤2 axes distinct (i.e. mostly the same creative with synonym swaps).
- 1-3: Near-duplicate of another variant in the set. Will share Entity ID on Meta Andromeda, will compete with itself on Google.

This dimension only fires when ≥3 variants are being scored. With 2 variants, skip and re-weight remaining 7 dimensions to total 100%.

## Scoring methodology

For each variant:

1. **Score each of 8 dimensions 1-10** with one-sentence justification per dimension citing the specific evidence (the line of copy, the visual element, the VoC phrase, etc.).
2. **Weight-adjusted total** = sum of (dimension score × dimension weight).
3. **Identify the single highest-leverage rewrite** for this variant — the dimension where moving from current score to 9-10 would lift weight-adjusted total most. Specify what the rewrite would look like.
4. **Launch verdict**: launch / rewrite first / kill.

Across the variant set:

5. **Rank variants** by weight-adjusted total.
6. **Recommend launch order** if T plans to test sequentially or run A/B.
7. **Flag near-duplicates** (Dimension 8 ≤5) for consolidation before launch.
8. **Surface portfolio gaps** — angles missing from the set that VoC bank suggests would test well.

## Output format

```
Creative QA — [Brand] — [Surface] — [N variants] — [Date]

Variant 1: [identifier or first 30 chars]
  D1 Hook: [score]/10 — [justification]
  D2 Value-prop placement: [score]/10 — [justification]
  D3 Cialdini lever: [score]/10 — [justification]
  D4 Mobile composition: [score]/10 — [justification]
  D5 Brand-voice fit: [score]/10 — [justification]
  D6 VoC grounding: [score]/10 — [justification]
  D7 Evidence grounding: [score]/10 — [justification]
  D8 Distinctness: [score]/10 — [justification]
  Weight-adjusted total: [N]/100
  Highest-leverage rewrite: [specific dimension, specific change]
  Launch verdict: [launch / rewrite first / kill]

[Repeat per variant]

---

Variant ranking by weight-adjusted total:
1. [variant id] — [score]
2. [variant id] — [score]
...

Launch recommendations:
- Lead variant (test budget primary): [id], reason
- Secondary variant (test budget secondary): [id], reason
- Kills: [list with reasons]

Near-duplicates flagged (consolidate before launch):
- [variant id] and [variant id] — overlap on [axes]

Portfolio gaps (angles missing):
- [angle] — why it would test well, supporting VoC phrase or competitor signal
```

## Hard rules

- **No variant ships at <56/100 weight-adjusted total.** Rewrite first.
- **Any Dimension 7 (evidence grounding) score <7 blocks launch regardless of total.** Fabricated claims damage the live store.
- **Free delivery claims auto-fail Dimension 7.** PNCapital does not offer free delivery.
- **"1-hour delivery" in customer copy auto-fails Dimension 7.** Internal SLA term only.
- **Afrikaans content auto-fails Dimension 5 (brand voice).** English only.
- **Emoji other than 🖤 in customer-facing copy auto-fails Dimension 5.** Brand emoji rule.
- **Variants below Dimension 8 score 4 (near-duplicates) are consolidated, not launched in parallel.** They will compete with each other on Andromeda Entity ID clustering and Google ad rotation.
- **VoC grounding (Dimension 6) requires source citation per phrase.** Claimed "from the VoC bank" without a row reference fails the dimension.
- **Brand claims about brands outside the confirmed SA list + dermocosmetic list need web_fetch sourcing.** Otherwise Dimension 7 fails.

## Anti-patterns

| Anti-pattern | Why it fails the rubric |
|---|---|
| "BeautyOnTApp – Beauty Destination" | D1 hook fails (brand-first, no value prop), D2 value-prop placement fails |
| "Limited time! Buy now!" | D3 Cialdini scarcity is anti-lever (no real time bound), D7 evidence fails |
| "Trusted by thousands of South Africans" | D7 evidence — "thousands" without a named count fails. Use "4.8★ from 2,400+ Judge.me reviews" instead. |
| "The best Korean skincare in SA" | D7 evidence — "best" is unsubstantiated claim |
| Identical pain phrase in all 5 variants with synonym swaps on the offer | D8 distinctness fails — near-duplicates |
| Generic stock photo of a smiling woman | D4 mobile composition + D5 brand voice both compromised |
| Long-form Meta primary text >150 chars before the line break | D4 mobile fails — mobile cuts the preview at ~125 chars |
| Emoji-heavy headlines | D5 brand voice fails — 🖤 only, and judiciously |
| Headline that doesn't match landing page | D7 evidence + general message-match failure |

## Self-check before delivering the rubric output

Run silently before shipping:

1. Are all 8 dimensions scored for every variant?
2. Does every score have a one-sentence justification citing specific evidence from the variant?
3. Is the weight-adjusted total computed correctly?
4. Is the highest-leverage rewrite for each variant specific (named dimension, named change) — not generic?
5. Are launch verdicts assigned (launch / rewrite / kill)?
6. Is variant ranking transparent?
7. Are near-duplicates surfaced?
8. Are auto-fail conditions (free delivery claim, Afrikaans, prohibited emoji, etc.) checked and triggered where present?

If any check fails, fix silently and re-deliver.

## What this skill does NOT do

- Does not write the variants — that's `beautyontapp-rsa-generator` (Google) or `beautyontapp-copywriting-engine` (everything else).
- Does not test variants on live data — that's `beautyontapp-meta-creative-testing` (post-launch hook/hold/fatigue).
- Does not configure the ad platforms — that's `beautyontapp-google-ads` / `beautyontapp-meta` / `beautyontapp-tiktok`.
- Does not invent variants. Only scores what T provides.

## Cadence

- **Pre-launch gate**: every set of creative ships through this rubric before paid spend. No exceptions on paid surfaces. Optional on organic.
- **Weekly portfolio review**: at the start of each week, score the previous week's launched creative retrospectively to refine rubric weights against actual performance.
- **Quarterly rubric audit**: every 90 days, compare predicted launch verdicts against actual creative performance from `beautyontapp-meta-creative-testing` data. Adjust dimension weights if a dimension's correlation with actual lift has shifted.

## Model routing

- **2-10 variants, single surface**: Sonnet 4.6 with high effort. Bounded reasoning.
- **10-20 variants, single surface**: Opus 4.7 with high effort. Distinctness scoring (D8) gets harder with larger sets.
- **Cross-surface portfolio review** (e.g. Google + Meta + email same campaign): Opus 4.7 with xhigh effort.
- **Quarterly rubric audit**: Opus 4.7 with xhigh effort. Pattern recognition across launched-vs-predicted performance.

## Pairs with

- `beautyontapp-rsa-generator` — upstream for Google RSA variants.
- `beautyontapp-copywriting-engine` — upstream for Meta, TikTok, email, SMS variants.
- `beautyontapp-brand-context` — IS/IS-NOT words and example sentences feed Dimension 5.
- `beautyontapp-voc-mining` — language bank feeds Dimension 6 scoring.
- `beautyontapp-evidence-citations` — Dimension 7 sourcing rules.
- `beautyontapp-meta-creative-testing` — downstream for post-launch evaluation of the variants that pass the gate.
- `beautyontapp-prompting-discipline` — XML scaffold for the QA prompt itself.
- `beautyontapp-ship-it-right-first-time` — final self-audit before shipping the rubric output.

## Example invocation

T pastes 5 RSA headlines + 4 descriptions just generated by `beautyontapp-rsa-generator` for a hyaluronic acid serum campaign:

```
Score these 5 variants on the 8-dimension rubric.
Surface: Google RSA (headlines + descriptions).
Brand: BeautyOnTApp.
Target query: "hyaluronic acid serum south africa".
Landing page: beautyontapp.com/collections/hyaluronic-acid-serums.
Rank for launch order. Flag near-duplicates. Suggest portfolio gaps.
```

Expected output: 5 per-variant scorecards + ranking + launch recommendations + flags. Estimated 5-15 minutes at Sonnet 4.6 high effort. Catches the 1-2 variants that would have wasted spend before they go live.

## Versioning

v1 — first deployed. Built from:

- Pixis 150,000-session Prism analysis: the pre-launch creative QA scoring pattern with named rubric and per-variant justification.
- Cialdini's *Influence: The Psychology of Persuasion* — six named levers (reciprocity, commitment, social proof, authority, liking, scarcity).
- AIDA classical copywriting framework — Attention / Interest / Desire / Action.
- T's PNCapital business rules: free delivery prohibitions, English-only, brand emoji 🖤, R285 / R199 / R1,200 price locks, same-day-delivery scope rules.
- Mobile-first weighting (D4) reflects SA market context: 70%+ mobile beauty traffic.

When new advertising psychology research or platform updates change the relative impact of dimensions (e.g. if Meta Andromeda's Entity ID clustering changes Dimension 8's weight), revisit weights. When new business rules ship (e.g. price changes), update Dimension 7 auto-fail conditions.
