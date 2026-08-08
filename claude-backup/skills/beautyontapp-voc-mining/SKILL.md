---
name: beautyontapp-voc-mining
description: Voice-of-Customer (VoC) language extraction from Judge.me product reviews, Google store reviews, Trustpilot, App Store, Play Store, and customer service transcripts. Mines for pain points, success phrases, recurring language, objections, and switching triggers. Outputs a per-brand language bank that feeds ad copy, email subject lines, SEO briefs, PDP descriptions, and chatbot scripts. Make sure to invoke whenever T uploads or references review data (Judge.me CSV, Google reviews export, Trustpilot, App Store, Play Store, support transcripts), or asks for "customer language", "VoC", "voice of customer", "review mining", "pain points", "what are customers saying", "review analysis", "customer phrases", "language bank", or wants to extract customer language for ad headlines, subject lines, or product copy. Pairs with copywriting-engine, meta-creative-testing, klaviyo-platform, seo-content, customer-experience.
---

# BeautyOnTApp VoC Mining

## Why this skill exists

The single highest-leverage copy improvement documented in 2025-2026 practitioner literature was Gerhard Engel's homepage rewrite: "Streamline Your Workflow" → "Stop Losing Hours to Broken Handoffs" drove a 34% conversion lift in 30 days. The headline came from review mining, not creative writing.

PNCapital has the data: Judge.me on the Shopify store, 6 sets of Google store reviews (Gateway, Fourways, Mall of Africa, Menlyn, Sandton, Canal Walk), App Store + Play Store reviews on the Flutter app, customer service emails to customer@beautyontapp.co.za. None of it currently feeds the copywriting, ad, email, or SEO workflows.

This skill mines that data and produces a language bank. Every downstream skill that writes customer-facing copy should pull from the language bank instead of inventing phrasing.

## What this skill produces

For each brand (BoT, Pastry, Mzuri) and each major product or service category, the output is a structured language bank:

```
{
  brand: "BeautyOnTApp",
  category: "K-beauty skincare",
  pain_phrases: [
    {phrase: "skin felt tight after washing", count: 8, sources: ["judge.me row 142", "google review gateway row 47", ...]},
    {phrase: "couldn't find this in any other store", count: 12, sources: [...]},
  ],
  success_phrases: [
    {phrase: "scan changed my entire routine", count: 14, sources: [...]},
    {phrase: "finally something that works for melasma", count: 9, sources: [...]},
  ],
  recurring_words_3plus: [
    {word: "hydrating", count: 47, contexts: ["judge.me row 8", ...]},
    {word: "non-greasy", count: 31, ...},
  ],
  objections: [
    {phrase: "expensive but worth it", count: 6, sources: [...]},
    {phrase: "wish you stocked [specific brand]", count: 4, sources: [...]},
  ],
  switching_triggers: [
    {phrase: "switched from Clicks because", count: 11, sources: [...]},
    {phrase: "Dis-Chem ran out so I tried", count: 5, sources: [...]},
  ],
  service_callouts: [
    {phrase: "scan was so helpful", count: 22, sources: [...]},
    {phrase: "rider was so quick", count: 14, sources: [...]},
  ]
}
```

Every entry is sourced. No phrase appears without a source citation.

## When to invoke

Auto-invoke when:
- T uploads `judge_me_export.csv`, `google_reviews_*.csv`, `trustpilot_*.csv`, `app_store_reviews_*.csv`, `play_store_reviews_*.csv`, or any review file.
- T pastes customer service emails or transcripts.
- T asks: "what are customers saying about X?", "find me customer language for Y", "VoC for [brand/category]", "review analysis", "customer pain points", "switching triggers", "objections to [product/category]".
- T is about to brief a new ad, email, SEO page, or product description and the brief invokes `beautyontapp-copywriting-engine` or `beautyontapp-seo-content` — load this skill alongside to feed sourced language.

Pair with `beautyontapp-audit-first` (file must be read first) and `beautyontapp-evidence-citations` (every phrase needs a source).

## Required source files

VoC mining is meaningless without source data. Refuse to proceed if T asks for "customer language" without attaching reviews. Ask once: "I need the review export. Which sources do you have? (Judge.me CSV, Google review export per store, Trustpilot, App Store, Play Store, customer service emails)."

### Judge.me export

Shopify admin → Apps → Judge.me → Reviews → Export CSV. Columns include `review_id`, `product_id`, `product_title`, `rating`, `title`, `body`, `verified`, `created_at`, `reviewer_email`, `reviewer_name`. Body field is the gold seam.

### Google store reviews

Google Business Profile → each location → Reviews → export. One CSV per store. Six stores: Gateway, Fourways, Mall of Africa, Menlyn, Sandton, Canal Walk. Columns include `review_id`, `rating`, `review_text`, `reviewer_name`, `created_at`, `owner_response`. Useful for service-level VoC (skin analysis, delivery, in-store experience).

### App Store / Play Store

App Store Connect / Google Play Console → Ratings & Reviews → export. Useful for app-specific VoC (Ask Bestie, navigation, checkout).

### Trustpilot

Trustpilot dashboard → Reviews → export. Less common for BoT but worth checking.

### Customer service transcripts

customer@beautyontapp.co.za inbox export, or Bestie chatbot transcripts if logged. Highest objection density.

## Mining methodology

For each review file:

### Step 1 — Verbatim extraction

Read every review body. Quote verbatim into a per-row table. No paraphrasing. Source = file name + row number.

### Step 2 — Categorisation per review

Each review gets tagged with one or more categories:
- `pain_pre_purchase` — what the customer was suffering with before
- `success_post_purchase` — what changed after using the product/service
- `objection` — concerns, complaints, hesitation
- `switching_trigger` — why they left a competitor for BoT
- `service_callout` — specific praise for skin scan, delivery, staff, store experience
- `product_callout` — specific praise for a product
- `brand_callout` — comment on a stocked brand (CeraVe, Pastry Skincare, etc.)
- `competitor_mention` — explicit naming of Clicks, Dis-Chem, Bash, Woolworths, etc.

Categories are not exclusive — one review can carry multiple tags.

### Step 3 — Phrase extraction per category

Within each category, extract the literal phrases (3-12 words) customers used. No rewriting. No "what they meant was." If a customer says "my skin felt tight after washing" that's the phrase — not "concerns about post-cleanse skin tightness."

### Step 4 — Frequency aggregation

Count phrases appearing in ≥3 reviews. These are the language patterns worth surfacing. One-off poetic phrases are noted but not prioritised.

### Step 5 — Recurring word extraction

Compute word frequency across all review bodies, excluding stopwords (the, and, is, my, etc.). Surface words appearing ≥3 times. Pair each with 2-3 surrounding context phrases so the word has meaning.

### Step 6 — Source-trace verification

Before delivering the language bank, verify: every phrase in the bank has ≥1 source citation pointing to a verbatim row in the source file. Any phrase missing a citation gets removed or flagged. Zero exceptions.

## Output formats

### Format A — Language bank JSON

For programmatic downstream use (RSA generator, Klaviyo dynamic content, etc.). Structured as the example above.

### Format B — Per-brand Markdown report

For T to read directly. One section per category, ranked by frequency, with 2-3 representative source quotes per phrase.

```
## Pain phrases — pre-purchase (BoT, K-beauty skincare)

1. "skin felt tight after washing" — 8 mentions
   - Judge.me row 142: "I used to use [cleanser X] and my skin felt tight after washing every single time…"
   - Judge.me row 287: "Skin was tight after washing, this is the first cleanser that hasn't done that"
   - Google review Sandton row 47: "She recommended this because my skin felt tight after washing my old face wash"

2. "couldn't find this in any other store" — 12 mentions
   ...
```

### Format C — Per-product language card

When T wants language for ONE product or ONE collection. Filter the bank to that handle/category, output a one-page card.

### Format D — Headline candidates

Convert top 5-10 pain phrases and top 5-10 success phrases into RSA-length (≤30 char) or Meta primary text candidates. Each candidate cites its source phrase. This is the format that feeds `beautyontapp-rsa-generator` and `beautyontapp-copywriting-engine`.

## Downstream skills this feeds

- `beautyontapp-rsa-generator` — pulls pain + success phrases, converts to 30-char headlines.
- `beautyontapp-copywriting-engine` — PDP descriptions, email subject lines, SMS, WhatsApp open hooks.
- `beautyontapp-meta-creative-testing` — concept angles for new creative tests grounded in real switching triggers.
- `beautyontapp-klaviyo-platform` — subject lines, email body hooks, abandoned-cart copy.
- `beautyontapp-seo-content` — H1, intro paragraph, FAQ questions sourced from customer phrasing.
- `beautyontapp-onpage-seo` — PAA-style FAQs grounded in actual customer questions.
- `beautyontapp-customer-experience` — Bestie chatbot prompt examples, FAQ answer phrasing.
- `beautyontapp-loyalty-redesign` — tier name testing, redemption ladder copy.
- `beautyontapp-retention` — win-back email language, replenishment reminder phrasing.

## Cadence

- **Initial pass per brand**: full mining across all available review sources. Outputs the base language bank.
- **Monthly refresh**: pull last 30 days of new reviews across Judge.me + 6 Google store profiles + App Store + Play Store. Append new phrases. Re-rank.
- **Pre-campaign refresh**: before any major ad push or new collection launch, refresh the relevant category's language bank from the latest reviews.
- **Quarterly competitor-mention deep dive**: filter the entire corpus for explicit mentions of Clicks, Dis-Chem, Bash, Woolworths, Secret Skin, Glow Theory. Output a switching-trigger report.

## Hard rules

- **No fabrication.** Every phrase must have a verifiable source citation. If you cannot cite the source row, the phrase does not enter the bank. Anchored by `beautyontapp-evidence-citations` and the anti-fabrication clauses in T's user preferences.
- **No paraphrasing.** "What they meant was" is forbidden. Customers said what they said.
- **No assumed demographics.** Do not infer age, skin tone, gender, income from review content unless the reviewer states it.
- **No assumed pain hierarchy.** Frequency = signal. Do not rank "tight skin" above "couldn't find in other stores" because one feels more emotional. The customers' word counts decide.
- **No competitor disparagement in derived copy.** When a switching trigger phrase mentions Clicks or Dis-Chem, it goes into the language bank but cannot be lifted verbatim into customer-facing copy. Strip the competitor name when feeding downstream skills.
- **Service callouts cite the actual store/rider/staff member when known.** Skin scan praise that names a specific consultant goes into the bank with that name attached — but customer-facing testimonial copy uses initials or "our consultant" unless explicit permission is on file.

## What this skill does NOT do

- Does not write the ad / email / page — that's downstream.
- Does not collect more reviews — that's `beautyontapp-ugc-management` and `beautyontapp-retention`.
- Does not respond to negative reviews — that's `beautyontapp-customer-experience`.
- Does not categorise reviews by NPS / CSAT — that's `beautyontapp-customer-experience` and `beautyontapp-analytics`.
- Does not generate new reviews. Ever.

## Common failure modes to refuse

1. T uploads 1 review and asks for a language bank. Refuse — need ≥30 reviews per brand/category for frequency aggregation to be meaningful. State the threshold.
2. T asks for "what would customers say" without uploading reviews. Refuse — that's invention, not mining. Ask for the export.
3. Output includes a phrase with no source row. Re-run step 6. Drop the phrase.
4. Output paraphrases ("customers want hydration"). Reject — the goal is verbatim customer phrasing.
5. Frequency counts include phrases appearing in ≤2 reviews. Drop them or move to a "noted but not prioritised" appendix.
6. Categorisation is sloppy ("pain or success or both"). Re-tag with the explicit category list. Multi-tag is fine; ambiguity is not.

## Example invocation

T uploads `judge_me_export_may_2026.csv` (2,400 rows, BoT brand) and `google_reviews_sandton.csv` (180 rows). Prompt:

```
Mine VoC from the two attached review files for the BoT K-beauty skincare category. 
Use the 6-step methodology in beautyontapp-voc-mining. 
Output Format B (per-brand Markdown report) with all 8 categories. 
Frequency threshold: phrases appearing in ≥3 reviews. 
Source-cite every phrase. 
If a category has <3 phrases meeting threshold, output "INSUFFICIENT DATA" for that category.
```

Expected output: Markdown report with 8 category sections, each with 3-15 ranked phrases, each phrase with ≥1 verbatim source quote and row citation. Estimated 30-50 phrases total in the language bank from those two files.

## Model routing

- Initial corpus mining (2,400 Judge.me rows + 6 Google profile exports + App Store + Play Store): **Opus 4.7 with xhigh effort**. Multi-file synthesis with categorical reasoning. Sonnet 4.6 degrades on the categorisation step past ~150K combined tokens.
- Monthly refresh (last 30 days only): **Sonnet 4.6 default thinking**. Smaller input, append-only against existing bank.
- Single-product language card: **Sonnet 4.6 default thinking**. Single file slice.
- Headline candidate generation from existing bank (Format D): **Sonnet 4.6 high effort**. Bank as input, RSA-length candidates as output.

## Pairs with

- `beautyontapp-audit-first` — read source before analysing.
- `beautyontapp-evidence-citations` — every phrase needs a source.
- `beautyontapp-execute-dont-ask` — call the file, don't ask T what customers say.
- `beautyontapp-prompting-discipline` — XML scaffold + refuse-the-field defaults govern every VoC prompt.
- `beautyontapp-research-mode` — when the question requires verified VoC for a critical decision.

## Versioning

v1 — first deployed. Built from Gerhard Engel's documented review-mining playbook (Foreplay Inc, 2025), the Pixis 150k-session prompt-engineering analysis (creative-QA rubric), and Anthropic's quote-grounding methodology (docs.anthropic.com/en/docs/test-and-evaluate/strengthen-guardrails/reduce-hallucinations).

When PNCapital adds a new review surface (Trustpilot for Pastry, Yelp equivalents in new markets, dedicated customer-experience platform), add the source to the "Required source files" section and update the mining methodology if the column structure differs.
