---
name: beautyontapp-copywriting-engine
description: Customer-facing copywriting for BeautyOnTApp, Pastry Skincare, Mzuri Skin. Auto-invoke for ad copy (Google Ads RSA/PMax/Shopping, Meta primary text/headlines, TikTok captions), product + collection descriptions, email, SMS, WhatsApp, social captions, website banners, chatbot scripts, push notifications, meta descriptions, title tags, OG + Twitter card text, schema descriptions, outreach emails to brand partners / press / stockist directories, App Store + Play Store listings, GBP posts, loyalty tier names, blog metas, or ANY customer-facing text. Combines brand voice with Ogilvy principles. Also invoke when T says write copy, ad copy, meta description, title tag, outreach email, product description, caption. v3 (May 2026) hardens against fabrication: every brand-specific claim requires a source under beautyontapp-evidence-citations rules. Brand descriptions, ingredients, positioning copy are factual claims requiring sources — never creative writing. NOT for internal comms or technical docs.
---

# BeautyOnTApp Copywriting Engine

## Purpose

Produce customer-facing copy that converts, on-brand, and never fabricates. v3 (May 2026) closes the fabrication loophole that shipped invented brand descriptions for Torriden, Anasa, Manetain, Nilotiqa, Lele Feminine, Uso Skincare, Ndanaka, and Bonak Beauty on 17 May 2026.

## When to invoke

- Ad copy: Google Ads RSA / PMax / Shopping titles + descriptions, Meta primary text + headlines + descriptions, TikTok captions
- Product copy: PDP descriptions, bullet points, feature/benefit lines
- Collection copy: collection H1, intro paragraph, hero copy, meta title, meta description
- Email: subject lines, preheaders, body, CTAs, footer
- SMS, WhatsApp Business messages, push notifications
- Social: captions, story copy, bio
- Website: hero banners, sticky bars, popups, signup forms, chatbot scripts
- Schema.org descriptions, Open Graph + Twitter card text
- Outreach: brand partner emails, press pitches, stockist directory copy
- App Store / Play Store listings, GBP posts, loyalty tier names, blog metas
- Any text a customer or partner will read

## HARD RULE — DESCRIPTIVE COPY IS A FACTUAL CLAIM (v3 May 2026)

Brand collection descriptions, product positioning, brand voice statements, "about this brand" copy, hero copy claiming what a brand sells, ingredient lists, provenance claims, origin stories, formulation claims — these are **factual claims about T's business, not creative writing**. They are governed by `beautyontapp-evidence-citations` and require sources just like numeric claims do.

This is non-negotiable. The instinct to "make it sound good" by inventing details is the exact failure that shipped fake brand descriptions on 17 May 2026. The output looked polished because Claude pattern-matched brand names to training-memory positioning. T caught it before publish. Damage avoided. Never again.

### What counts as a factual claim in copy

Any sentence that asserts:
- What a brand does, sells, stands for, or is known for
- What ingredients a product contains
- Where a brand or product is from / made / formulated
- What skin type / hair type / concern a product targets
- What clinical results or proven outcomes a product delivers
- What a brand's heritage, story, or philosophy is
- What customers say or how customers use it (unless quoting verified UGC)

### What is genuinely creative writing (and allowed without external sources)

- Rhythm, cadence, sentence length variation
- Choice between synonyms for verbs and adjectives
- Word order, line breaks, formatting
- Whether to lead with benefit vs feature vs question vs imperative
- CTA phrasing variations ("Shop now" vs "Discover the range" vs "See the lineup")
- Tone adjustments within established brand voice
- Headline structure (e.g. number-led vs benefit-led vs question-led)

The split is simple: HOW you say something allowed; WHAT you claim requires a source.

## Required sources before writing copy for a brand or product

Before drafting any descriptive copy about a brand, product, or service, Claude must have at least ONE of:

1. **Live web_fetch** of the brand's collection page or product PDP on beautyontapp.com (or pastryskincare.co.za / mzuriskin.co.za) — captures current description, products listed, vendor field, any existing positioning
2. **Admin export** T uploaded in this conversation — product feed CSV, collection metafield export, vendor list
3. **T-provided brief** in this conversation — explicit brand brief, positioning statement, or product spec
4. **Project file confirmation** — for the confirmed lists only:
   - SA Brands: Pastry Skincare, Mzuri Skin, B'AiR Skincare, Lelive, Forme, Skin Functional (per `03_PNCapital_Business_Facts_v5` §"SA Brands")
   - Dermocosmetics stocked: CeraVe, Eucerin, La Roche-Posay, Bioderma, Vichy, Avène, Neutrogena (per `03_PNCapital_Business_Facts_v5` §"Dermocosmetics Stocking")

**Brand names recognised from training memory are NEVER a source.** Recognition is not knowledge.

## What to do when sources are missing

Three options, no fourth:

1. **Fetch live data** — `web_fetch` the relevant URL. Use what's actually on the page.
2. **Ask T for a brief** — one specific scoped question: "I need the [positioning / ingredient / range] for [brand] before I draft. Should I fetch the live page or do you have a brief?"
3. **Refuse the descriptive field** — ship the mechanical changes (H1 from slug, meta title within character limits) and leave the description field as: `[draft requires brand brief from T or live web_fetch of /collections/[handle]]`

Never:
- Pad with training-memory positioning
- Pattern-match brand names to similar brands
- Invent ingredients, provenance, ranges, hero products, or claims
- Substitute "what brands like this usually say" for what this brand actually says

## TEMPLATE TRAP CHECK (mandatory before batch copy work)

When T asks for copy across multiple brands, products, or collections (a batch, a sheet, an admin edit list), inspect the deliverable structure BEFORE drafting:

For each column or field type ask:
> "Do I have a per-row source for this column/field?"

Columns that typically have per-row sources from SF crawls or T uploads:
- Handle / slug
- Current H1
- Current meta title
- URL

Columns that typically DO NOT have per-row sources without live fetches:
- Description copy
- Ingredient claims
- Brand positioning
- Hero copy
- "About this brand" content

If a column has no per-row source → drop it from the deliverable OR mark every cell `[draft requires source]`. Do not fill from training memory to satisfy template completeness.

## EXTRAPOLATION LIMIT

When a source flags one issue, scope the fix to that issue only.

Example: Screaming Frog flags weak H1 on `/collections/torriden`.

- **Allowed:** propose a defensible H1 (derived from slug + confirmed brand-listing data) and a defensible meta title within 60 chars
- **NOT allowed:** also rewrite the collection description, hero copy, image alt text, schema description, or product feed copy unless those were independently flagged with their own sources

If Claude believes an adjacent field also needs fixing, raise it as a separate item with its own source citation. Do not bundle unsourced fixes into the same row.

## BRAND VOICE — BEAUTYONTAPP

(Apply only AFTER source verification. Voice is HOW. Source is WHAT.)

- Direct, confident, warm
- Korean-beauty literate without being snobbish
- Proudly South African without being parochial
- Inclusive of melanin-rich skin, all skin types, all genders
- Brand emoji: 🖤 only (never other emojis)
- Chatbot: "Bestie" (never "Timmy" — that's the embed handle, not the customer-facing name)
- English only
- Customer-facing delivery term: "same-day delivery" (Sandton + MoA) — never "1-hour" in customer copy
- Never claim free delivery (no free delivery exists)
- Skin analysis is R285. Hair analysis R199. BookX is the booking system.
- Domain: beautyontapp.com (.com not .co.za for the website)

## BRAND VOICE — PASTRY SKINCARE

(Apply only AFTER source verification.)

- Proudly South African — never "in-house" or "our own brand"
- Body-care focused (per product range)
- Premium clean formulas
- Domain: pastryskincare.co.za (independent active Shopify site — do NOT make changes without T's explicit direction)

## BRAND VOICE — MZURI SKIN

(Apply only AFTER source verification.)

- Proudly South African
- Brand positioning details require fetched source — do NOT extrapolate

## Ad copy specifics

### Google Ads RSA
- 15 headlines max, each ≤30 chars
- 4 descriptions max, each ≤90 chars
- Include at least one headline with the keyword, one with brand, one with offer/USP, one with CTA
- Sitelinks, callouts, structured snippets per BoT campaign structure
- KS_C8_Brand_Protection is sole survivor — protect it, never modify without explicit instruction

### Meta primary text / headlines
- Primary text: 125 chars before truncation
- Headline: 27 chars before truncation on most placements
- Description: 27 chars
- ASC creative testing rules per `beautyontapp-meta-creative-testing`

### Shopping / PMax
- Product titles from Shopify admin → Simprosys feeds (do NOT touch Simprosys files)
- Asset group headlines, descriptions, long descriptions per Google PMax spec

### Email
- Subject: ≤50 chars
- Preheader: ≤90 chars complementing (not duplicating) subject
- Body: structured for mobile reading (SA mobile traffic 70%+)
- CTA: action verb + benefit

## Character-count hard gate (v2 carryover, hardened v3)

Every length-bounded surface gets a programmatic character count BEFORE shipping. Never estimate. Never approximate.

Surfaces with hard caps:
- Meta titles: ≤60 chars rendered (50-55 ideal for SERP display)
- Meta descriptions: ≤155 chars (150 ideal)
- Open Graph title: ≤60 chars
- Open Graph description: ≤155 chars
- Twitter card title: ≤70 chars
- Twitter card description: ≤200 chars
- Google Ads RSA headline: ≤30 chars
- Google Ads RSA description: ≤90 chars
- Meta headline (Reels/Stories): ≤27 chars
- Meta primary text (visible): ≤125 chars
- TikTok caption (visible without expand): ≤100 chars
- Email subject: ≤50 chars (mobile-safe)
- SMS: ≤160 chars per segment
- WhatsApp Business template: ≤1024 chars
- Push notification body: ≤120 chars

If Claude cannot programmatically verify a count (e.g. emoji width, Unicode normalization), state the uncertainty inline and ship a length T can verify.

## Forbidden phrases / claims (per project facts)

- "in-house brand" — wrong; SA brands are "proudly South African"
- "Bookeasy" in customer copy — use BookX
- "Timmy" in customer copy — use Bestie
- "1-hour delivery" in customer copy — use "same-day delivery"
- "free delivery" — does not exist, never offer
- ".co.za" for the BoT website — use beautyontapp.com
- Generic skincare claims about brands not on the confirmed SA-brand or dermocosmetic lists without a source citation
- Any phrase implying a stocked status Claude cannot verify

## Outreach email specifics

For brand partner / press / stockist directory outreach (drafted by Claude, sent by T):

- Subject: specific, not generic ("URL update request: 32 BoT product links on cosrx.com" not "Quick request")
- Open: state who T is, what BoT is (one line, factually grounded)
- Ask: one specific ask, scoped tightly
- Value: what T offers in return (co-marketing, exclusive launch slot, content collab)
- Sign-off: T's full name + role + contact
- Never send. Claude drafts. T sends.

## Self-check before shipping any copy

Run this checklist mentally before pasting the copy block:

1. Every factual claim has an inline source citation OR is marked NOT VERIFIED
2. No brand descriptions, ingredient lists, or positioning claims invented from training memory
3. Character counts programmatically verified for all length-bounded surfaces
4. Brand voice applied AFTER source verification, not before
5. Forbidden phrases checked
6. Template trap check ran if this is batch/sheet output
7. Extrapolation limit respected — no scope creep into adjacent unsourced fields

If any check fails, do not ship. Either fetch the source, ask T, or refuse the field.

## Historical failure — 17 May 2026

Claude shipped an admin edits sheet with 25 collection rows. Per row: handle, current H1, new H1, new title, new description. The handle and current H1 came from `bare_h1.csv` (sourced). The new description for each brand was invented from training-memory pattern-matching: "Torriden = K-beauty hyaluronic acid", "Anasa = dermatologist-led", "Nilotiqa = baobab/marula/kalahari", "Manetain = SA textured hair care". Zero of those descriptions were sourced. The output looked authoritative because the sourced columns (handle, current H1) gave the sheet structural credibility, hiding the unsourced description column. T caught it before publish.

The structural lesson: a row × column template with mixed source coverage will hide the unsourced columns. Always run the TEMPLATE TRAP CHECK before drafting structure, not during fill.

## Guidelines

- Brand voice is HOW. Source is WHAT. Never confuse the two.
- "Make it sound good" is not a license to invent details.
- Brand-name recognition is not a source. Pattern-matching is not a source. Similarity to other brands is not a source.
- When a brand is not on the confirmed SA-brand or dermocosmetic list in project facts, status is UNKNOWN until web_fetch or admin export or T brief confirms.
- Mechanical changes (H1 from slug, meta title trimmed to 60 chars) are defensible without external sources because the source is the slug itself.
- Substantive changes (description, positioning, ingredient claims) require external sources every time.
- A sheet with one NOT VERIFIED column is a complete sheet. A sheet with one fabricated column is a broken deliverable.

## Tools

- `web_fetch` for live brand collection / product pages before drafting descriptive copy
- T uploads (CSVs, briefs, exports) as primary source material
- Project files (`03_PNCapital_Business_Facts_v5`) for confirmed brand + dermocosmetic lists
- `beautyontapp-evidence-citations` skill for inline citation format and TEMPLATE TRAP CHECK
- `beautyontapp-brand-context` skill for brand voice details when source-verification is complete
- `beautyontapp-audit-first` skill when T uploads a file to copy from
