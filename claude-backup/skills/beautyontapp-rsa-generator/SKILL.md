---
name: beautyontapp-rsa-generator
description: Responsive Search Ad (RSA) headline and description generator for BeautyOnTApp Google Ads (account 820-452-9325) and Pastry Skincare (851-084-2703). Enforces 30-character headline limit, 90-character description limit, brand voice, product accuracy, and Google Ads RSA best practices. Ingests campaign CSV, keyword list, landing page URL, and VoC language bank. Outputs Google Ads Editor bulk-upload CSV with 15 headlines and 4 descriptions per ad group. Logs every variant + hypothesis to a hypothesis log so subsequent variant rounds build on prior tests. Make sure to invoke whenever T asks for "RSA copy", "RSA headlines", "Google Ads headlines", "search ad copy", "responsive search ads", "ad copy for [campaign/ad group]", "RSA variants", "headline generator", "write RSAs", "Google Ads Editor CSV", or wants new search ad assets for any active campaign. Pairs with google-ads, voc-mining, copywriting-engine, brand-context, evidence-citations.
---

# BeautyOnTApp RSA Generator

## Why this skill exists

Source: Anthropic's published case study on Austin Lau, Growth Marketer (Anthropic.com white paper *How the Anthropic Team Uses Claude Code*). The documented results: ad-copy creation reduced from 2 hours to 15 minutes per ad. Creative output increased tenfold. ~100+ hours/month saved across the growth team.

The pattern: a `/rsa` slash command that ingests campaign data, existing copy, keywords, and cross-references three Agent Skills (brand tone, product accuracy, RSA best practices), with sub-agents enforcing hard format limits (30-char headlines, 90-char descriptions), and a memory log of tested hypotheses.

This skill transposes that pattern to PNCapital's claude.ai workflow. The data sources differ — T uses Shopify Advanced + Judge.me + Google Ads Editor CSV exports instead of internal Anthropic ad-server feeds — but the architecture is identical.

The cost of weak RSAs at PNCapital is measurable: KS_C8_Brand_Protection runs at a very low CPA (verify current — figures change); every other active campaign runs higher. Sharp RSA copy is the cheapest CPA lever T has not yet pulled.

## What this skill produces

For each RSA request, the output is a Google Ads Editor bulk-upload CSV:

```
Campaign,Ad group,Ad type,Headline 1,Headline 1 position,Headline 2,Headline 2 position,
Headline 3,Headline 3 position,Headline 4,Headline 4 position,Headline 5,Headline 5 position,
... [15 headlines total] ...,
Description 1,Description 1 position,Description 2,Description 2 position,
Description 3,Description 3 position,Description 4,Description 4 position,
Path 1,Path 2,Final URL
```

Plus a hypothesis log entry capturing:
- What this variant tests (specific angle, specific VoC phrase, specific offer)
- Predicted winner pattern based on prior tested patterns
- Source citations per headline (which VoC row, which brand-context file, which product fact)
- KPI threshold for declaring this variant a winner or a loser

## When to invoke

Auto-invoke when:
- T uploads a Google Ads Editor CSV export and asks for RSAs.
- T pastes a campaign name + ad group + landing page URL and asks for headlines or descriptions.
- T says "RSA copy", "Google Ads headlines", "responsive search ads", "search ad copy", "ad copy for [campaign]", "write RSAs for [collection/product]".
- T runs the PMax audit prompt (Example 1 in `beautyontapp-prompting-discipline/references/examples.md`) and the output flags weak RSA assets — auto-suggest this skill for the fix phase.

Pair with `beautyontapp-voc-mining` (load the language bank first), `beautyontapp-google-ads` (account constraints), `beautyontapp-brand-context` (brand voice), and `beautyontapp-evidence-citations` (per-headline source citations).

## Required source data

Refuse to generate RSAs without:

1. **Campaign + ad group context**: campaign name, ad group name, target keyword(s), match types, current daily budget. From Google Ads Editor CSV or paste.
2. **Landing page URL**: the actual URL the ad points to. Required for message-match and Path 1 / Path 2 derivation.
3. **VoC language bank for the relevant brand and category**: from `beautyontapp-voc-mining` output. If language bank is missing for this category, invoke voc-mining first or accept a one-off override where T provides 5-10 verbatim customer phrases.
4. **Product / collection facts**: if writing for a product, the PDP scrape or current product copy. If writing for a collection, the collection page H1, current intro, and stocked brands.
5. **Brand voice reference**: from `beautyontapp-brand-context`. Three "is" words, three "is not" words, five example sentences.
6. **Prior tested headlines log** (if any exist for this campaign): the hypothesis-log entries from previous RSA rounds.

If any of items 1-5 are missing, ask exactly one question listing what's missing. Do not generate from training memory.

## Hard constraints — Google Ads RSA spec (verified May 2026)

These are enforced by sub-agents per Austin Lau's pattern:

- **Headlines**: minimum 3, maximum 15. Hard limit 30 characters each, including spaces.
- **Descriptions**: minimum 2, maximum 4. Hard limit 90 characters each, including spaces.
- **No duplicate headlines** within an RSA. Google rejects exact duplicates.
- **No DKI inside headline character count** — Dynamic Keyword Insertion uses the default text length when counting; assume worst case.
- **Path 1 + Path 2**: max 15 characters each. Used for display URL.
- **At least 2 headlines should be pinned** to Position 1 (brand presence) and 1 to Position 2 (offer/value). The rest unpinned for Google's machine learning.
- **Headline character count includes spaces, hyphens, punctuation, and emojis** (each emoji typically counts as 1 character but Google counts visual width — assume 2 chars per emoji to be safe).
- **No exclamation marks in more than 1 headline per RSA** (Google policy).
- **No ALL CAPS words** longer than 1 character (e.g. "SALE!" is allowed once; "FREE SHIPPING" is not).

## Hard constraints — PNCapital business rules

These override anything Google Ads "best practice" would otherwise suggest:

- **No "Free Delivery" claims ever.** PNCapital does not offer free delivery. R30 store pickup, R60 locker, R120 door-to-door, R75 same-day. If the campaign benefits from a delivery hook, use "Same-Day Delivery Sandton & MoA" or "R30 Store Pickup".
- **Customer-facing term: "same-day delivery"** — never "1-hour delivery".
- **Domain shown is beautyontapp.com** — NOT .co.za.
- **Chatbot name: Bestie** — never Timmy.
- **No competitor name-checking** even when VoC language bank surfaces "switched from Clicks because…". Strip the competitor name when feeding into RSA copy.
- **No ALL-CAPS imperatives.** Replace with reasons.
- **Brand emoji: 🖤** only. Use sparingly — Google counts emoji width as 2 chars; one per RSA max.
- **Skin analysis price: R285. Hair analysis: R199.** If price is used in a headline, these are the only correct values.
- **Loyalty hero redemption: R1,200 free scan.** If loyalty is used in a headline, this is the lock.
- **English only.** Never Afrikaans.
- **No claims about brands outside the confirmed SA-brand list** (Pastry, Mzuri, B'AiR, Lelive, Forme, Skin Functional) **or confirmed dermocosmetic stocked list** (CeraVe, Eucerin, La Roche-Posay, Bioderma, Vichy, Avène, Neutrogena). If RSA is for a different brand's campaign, refer to it by name only — do not write positioning copy.

## Generation methodology

### Step 1 — Context assembly

Read all required source data. Confirm landing page URL is accessible. Pull the VoC language bank slice for the target brand/category. Pull brand voice from brand-context. Pull prior hypothesis log if it exists.

### Step 2 — Angle selection (5-7 angles per RSA)

Each RSA gets a deliberate mix of angle types. Do not generate 15 headlines from one angle.

| Angle | Source | Example pattern |
|---|---|---|
| Brand presence | brand-context | "BeautyOnTApp – K-Beauty SA" |
| Product/category fact | PDP scrape / collection | "Hyaluronic Acid Serums" |
| Pain phrase from VoC | voc-mining bank | "Skin Felt Tight? Fix It" |
| Success phrase from VoC | voc-mining bank | "Hydration in 7 Days" |
| Switching trigger from VoC | voc-mining bank | "Better Than Drugstore" |
| Service callout | voc-mining bank | "Free Skin Scan with Order" (only if true) |
| Offer / urgency | campaign context | "Same-Day Sandton & MoA" |
| Trust / proof | judge.me ratings | "4.8★ from 2,400 Reviews" |
| Local relevance | SA market context | "Made for SA Skin" / "Built for SA Climate" |
| Stock callout | inventory feed | "In Stock – Ships Today" |
| Question hook | PAA / VoC questions | "Which Serum Suits Oily Skin?" |
| Comparison | PNCapital differentiation | "K-Beauty Without The Markup" |

Mix: 2-3 brand presence (one pinned to P1), 3-4 VoC-grounded (pain/success/switching), 2-3 product-category, 2 offer/service, 2-3 trust/local/stock. Total 15.

### Step 3 — Headline drafting per angle

For each angle, draft 2-3 headline candidates ≤30 chars. Use VoC verbatim where it fits the character budget; otherwise paraphrase from the VoC phrase with minimum semantic drift.

Every headline carries a source citation in the hypothesis log:
- VoC-grounded: cites the language bank phrase + source row
- Brand presence: cites the brand-context file section
- Product fact: cites PDP URL or collection H1
- Trust: cites Judge.me aggregate rating + review count
- Offer: cites the campaign context (always-on offer vs promotional)

### Step 4 — Character-count sub-agent validation

Pass every headline candidate through a strict character counter. Reject any candidate exceeding 30 chars (headlines) or 90 chars (descriptions). Re-draft until all 15 headlines + 4 descriptions are within limits.

This step is non-negotiable. The single highest-frequency failure mode in 2024-2025 RSA prompts was Claude returning a 31-character "headline" because it counted approximately. The Austin Lau pattern's sub-agent enforces this.

### Step 5 — Description drafting

4 descriptions, each ≤90 chars. Pattern:
1. **Description 1**: primary value + offer ("Korean skincare ranges with same-day delivery in Sandton & Mall of Africa.")
2. **Description 2**: trust / proof ("Trusted by 2,400+ South Africans. 4.8★ on Judge.me.")
3. **Description 3**: differentiation / VoC switching trigger ("Skip the queue. Free skin scan with R1,200 redemption.")
4. **Description 4**: service / convenience ("R30 store pickup at 6 SA locations. English chat with Bestie.")

Each description cites its source(s) in the hypothesis log.

### Step 6 — Path 1 + Path 2

Derive from the landing page URL or campaign theme. ≤15 chars each. Examples:
- Final URL: beautyontapp.com/collections/hyaluronic-acid-serums
- Path 1: "Hyaluronic-Acid"
- Path 2: "Serums-SA"

If the campaign is brand-protection, Path 1 = "Official-Store", Path 2 = "South-Africa".

### Step 7 — Pin positions

By default, pin 2 headlines to Position 1 (brand presence) and 1 to Position 2 (primary offer/value). Leave the other 12 unpinned for Google's ML to test.

For brand-protection campaigns (KS_C8_Brand_Protection): pin 3 headlines to P1, all brand-presence variants. This prevents Google rotating off-brand headlines into the most visible slot when competitors bid on the brand term.

### Step 8 — CSV assembly

Output the Google Ads Editor bulk-upload CSV row(s). One row per RSA. Validate column order matches current Editor schema (Google updates this annually — always verify against the latest Editor template before bulk upload).

### Step 9 — Hypothesis log entry

For every RSA generated, append to the hypothesis log:

```
RSA ID: [campaign]/[ad group]/[YYYY-MM-DD]-v[N]
Test: [one-sentence description of what this RSA tests]
Source citations:
  - Headline 1: [source]
  - Headline 2: [source]
  - ... [all 15]
  - Description 1: [source]
  - ... [all 4]
Predicted winner: [hypothesis about which angle will outperform]
Decision threshold: [CTR delta vs control, sample size, days]
Compared against: [prior RSA IDs in the same ad group]
```

This log is what makes Austin Lau's pattern compound. Without it, every RSA round starts from scratch.

## Output format

### Format A — Single RSA, ready for Editor

CSV row + hypothesis log entry. Default output.

### Format B — Bulk batch

For T uploading a campaign CSV with 10+ ad groups, generate one RSA per ad group, output a single CSV file. Hypothesis log gets one entry per RSA.

### Format C — Variant scaling from a winner

T provides the winning RSA + the metric it won on. Generate 5-10 variants that hold the winning angle constant and vary the other angles. Append to hypothesis log with the winner cited as compared-against.

### Format D — Headline-only refresh

T already has a strong RSA but wants fresh headlines to test. Generate 5 new headline candidates with source citations. Do not touch descriptions or paths.

## Downstream usage

Once CSV is generated:

1. Open Google Ads Editor.
2. Account → Bulk operations → Make multiple changes.
3. Paste CSV. Editor validates against current account structure.
4. Review character counts (Editor will flag any breaches — should be zero if step 4 sub-agent worked).
5. Post changes to account.
6. Tag the new RSAs with a label matching the hypothesis log RSA ID for tracking.
7. Wait for decision threshold (typically 7-14 days at PNCapital's volume) before evaluating winner.

## Hypothesis log location

The log is a single Markdown file per campaign at the campaign level. Suggested path when T deploys: `/PNCapital_Marketing/RSA_Hypothesis_Logs/[account]_[campaign].md`. Append-only. Never delete entries. Failed RSAs are as valuable as winners.

## Quarterly hypothesis log review

Every quarter, T (or this skill on request) reads the full hypothesis log for an account and produces:
- Top 5 winning angles by aggregate CTR/CPA lift
- Top 5 losing angles
- Untested combinations worth running
- Suggested next-quarter RSA themes

This is the compounding loop. After 4-6 quarters, the log becomes the single best PNCapital-specific RSA playbook in existence.

## Model routing

- **Initial bulk generation** (10+ ad groups in one batch): Opus 4.7 with xhigh effort. Multi-file synthesis (campaign CSV + VoC bank + brand context + landing page scrapes) is exactly where Opus 4.7 outperforms Sonnet 4.6.
- **Single RSA**: Sonnet 4.6 with high effort. The reasoning is bounded enough that Sonnet handles it.
- **Variant scaling from a winner**: Sonnet 4.6 default thinking. Smaller input, deliberate variation.
- **Character-count sub-agent validation**: Haiku 4.5. Pure mechanical check.
- **Quarterly hypothesis log review**: Opus 4.7 xhigh. Cross-document pattern recognition across 50+ logged RSAs.

## Hard rules

- **Never exceed 30 characters per headline or 90 per description.** Sub-agent validation is non-negotiable.
- **Never invent customer phrases.** Every VoC-grounded headline must cite the voc-mining language bank with source row.
- **Never claim free delivery, free shipping, or "free" anything PNCapital does not actually offer free.**
- **Never use competitor names in RSA copy.** Switching-trigger VoC phrases get the competitor name stripped.
- **Never bid generics without brand/ingredient/concern qualifier** — but this is a campaign-level rule from `beautyontapp-google-ads`, not RSA copy. Flag if RSA is for a campaign that violates this.
- **Never re-enable KS_C1-C7 or KS_C9-C10** — permanently dead per business rules. If T asks for RSAs for a dead campaign, refuse.
- **KS_C8_Brand_Protection RSAs** always pin 3 headlines to P1, all brand presence. Never rotate off-brand creative into the brand-protection campaign.
- **Pastry RSAs use account 851-084-2703.** Output must specify which account the CSV belongs to.
- **Skin analysis price R285. Hair analysis R199. Loyalty redemption R1,200.** These are the only correct numeric values for these claims.

## What this skill does NOT do

- Does not write display, YouTube, PMax assets, or Meta ads — separate skills.
- Does not write landing-page copy — that's `beautyontapp-copywriting-engine` + `beautyontapp-cro-engine`.
- Does not decide which campaign to scale or pause — that's `beautyontapp-bleeder-detection` + `beautyontapp-ppc-audit-engine`.
- Does not configure bidding, negatives, or audiences — that's `beautyontapp-google-ads`.
- Does not run the campaign — execution via Google Ads Editor remains T's job after CSV is generated.

## Common failure modes to refuse

1. T asks for RSAs without a landing page URL. Refuse — message-match is impossible to verify.
2. T asks for RSAs for a brand outside the confirmed SA + dermocosmetic lists without providing a brand brief. Refuse the descriptive copy portion. Output brand-presence + product-category + service-callout headlines only.
3. T asks for RSAs with "free shipping" or "free delivery" anywhere. Refuse — this violates PNCapital business rules.
4. Sub-agent reports any headline >30 chars. Re-draft. Never ship over-limit.
5. Output uses a VoC phrase without a source citation. Re-run step 3 with explicit citations or remove the headline.
6. Hypothesis log entry is missing or skipped. Re-run step 9. The log is the entire point.
7. T asks for RSAs in Afrikaans. Refuse — English only per business rules.

## Pairs with

- `beautyontapp-voc-mining` — language bank is upstream. Without it, RSAs go generic.
- `beautyontapp-google-ads` — account-level constraints (negatives, bidding, structure).
- `beautyontapp-brand-context` — brand voice, IS/IS-NOT, example sentences.
- `beautyontapp-copywriting-engine` — for non-Google-Ads surfaces (Meta, email, SMS, PDP).
- `beautyontapp-evidence-citations` — every claim cites a source.
- `beautyontapp-prompting-discipline` — XML scaffold + refuse-the-field defaults.
- `beautyontapp-audit-first` — read source files before drafting.
- `beautyontapp-ship-it-right-first-time` — self-audit CSV before delivery.

## Example invocation

T uploads `bot_active_campaigns_may_2026.csv` (12 ad groups across 6 campaigns) and asks: "Generate fresh RSAs for all 12 ad groups."

Required prerequisites:
- VoC language bank exists for BoT K-beauty category → load via voc-mining.
- Each ad group has a target keyword + landing page URL in the CSV → confirm.
- Brand context loaded → confirm.

Output:
- One CSV with 12 RSA rows ready for Google Ads Editor bulk upload.
- 12 hypothesis log entries appended.
- A summary table: per ad group, 15 headlines + 4 descriptions, character counts, source citation count.
- Top 3 angles tested across the batch, with rationale.

Estimated time at Opus 4.7 xhigh: ~12-18 minutes for the full batch. Compare to manual at ~2 hours per RSA = 24 hours for 12. Austin Lau's documented 10× output multiplier holds.

## Versioning

v1 — first deployed. Built on:
- Anthropic's published Austin Lau case study (the `/rsa` slash command pattern, sub-agent enforcement of character limits, hypothesis logging).
- Bob Meijer's RSA prompt pattern (PPC Mastery): table format with character count column.
- T's documented PNCapital business rules: no free delivery, brand emoji 🖤, Bestie not Timmy, confirmed SA + dermocosmetic brand lists, English only.
- `beautyontapp-voc-mining` as the upstream language source.

When Google updates the RSA spec (currently 15 headlines × 30 chars, 4 descriptions × 90 chars), update steps 4 and 5 character thresholds. When Google updates the Editor CSV schema, update step 8 column order. Check both annually.
