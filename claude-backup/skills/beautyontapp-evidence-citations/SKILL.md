---
name: beautyontapp-evidence-citations
description: Requires that every factual claim cite a specific source — uploaded file with row reference, URL fetched this conversation, prior message, project file, loaded skill body, or explicit NOT VERIFIED tag. Make sure to invoke whenever the response contains numbers, statistics, percentages, dates, prices, regulations, named entities, competitor claims, brand descriptions, product positioning, ingredient claims, stocking status, brand provenance, or any descriptive copy about a brand or product. Also invoke before drafting any structured deliverable (rows × columns, tables, batch edit lists, sheets, multi-section dispatches) — descriptive copy and brand positioning are factual claims about T's business, not creative writing, and require sources just like numbers. Hardened 17 May 2026 after Claude fabricated brand descriptions for Lele Feminine, Uso Skincare, Nilotiqa, Anasa, Torriden, Manetain, Ndanaka by treating weak H1 SF flags as license to invent positioning copy. Pairs with beautyontapp-audit-first.
---

# BeautyOnTApp Evidence Citations

## Purpose

Every factual claim T will act on must have a source. Training memory is never a source. Brand-name recognition from training memory is never a source. Descriptive copy about T's business is a factual claim, not creative writing. This skill exists because Claude has shipped fabricated content to T's live store before — never again.

## When to invoke

- Response contains any number, statistic, percentage, date, price
- Response contains a regulation, legal claim, or compliance assertion
- Response contains a named entity claim (brand X is stocked, competitor Y has feature Z)
- Response contains a comparative claim (BoT vs competitor, this period vs last)
- Response contains brand descriptive copy, product positioning, ingredient list, brand voice, or "about this brand" content
- Response contains stocking status, vendor classification, or product range claim
- Response is a structured deliverable: rows × columns, table, batch edit list, sheet, multi-section dispatch
- Response will be acted on by T (live store edits, ad copy, customer emails, schema, redirects)

## Sources that count

1. A file T uploaded in this conversation, with line/row/cell reference (e.g. `bare_h1.csv:row 14`)
2. A URL fetched in this conversation (`web_fetch beautyontapp.com/collections/torriden 17 May 2026`)
3. A prior message in this conversation from T
4. A project file: `02_PNCapital_Skill_Router_v5.md`, `03_PNCapital_Business_Facts_v5.md`
5. A loaded skill body (e.g. `beautyontapp-business-rules` §"Delivery Rules")
6. Reasoned inference grounded in items 1–5 (never grounded in training memory)

## Sources that DO NOT count

- Training memory of any kind
- Brand-name recognition from training ("I know Torriden because I've seen it before")
- Pattern-matching from similar brands ("it sounds Korean so it must be K-beauty")
- Inference about T's business not grounded in items 1–5 above
- Prior conversations Claude does not have access to in this session

## Inline citation format

Every factual claim cites inline. Examples:

- "BoT's blended ROAS floor is 1.82x [source: project facts §Advertising Ceilings]"
- "Torriden's hero ingredient is hyaluronic acid [NOT VERIFIED — needs web_fetch of /collections/torriden]"
- "cosrx.com has 32 backlinks to old domain [source: 03_PNCapital_Business_Facts_v5 §Shopbeautyontapp.co.za]"
- "KS_C8 CPA is [value from project facts §Google Ads Account Facts] [source: project facts]"
- "Anasa is dermatologist-led [NOT VERIFIED — no source for this claim, do not present as fact]"

## TEMPLATE TRAP CHECK (run before drafting any structured deliverable)

Before generating any structured sheet (rows × columns, table, batch edit list, dispatch with sub-tasks, admin edit list, product list, brand audit), inspect each column or field individually.

For each column ask:

> "Do I have a per-row verified source for this column?"

If yes → fill the column.

If no → two options, no third:

1. **DROP the column** from the template entirely (preferred when the column adds risk and no value without sources)
2. **Pre-mark every cell in that column as `NOT VERIFIED — [reason source is missing]`**

NEVER fill cells from training memory to satisfy table symmetry, row count, deliverable completeness, or visual polish. A row with one NOT VERIFIED field is a complete row. A row with one fabricated field is a broken deliverable that damages T's live store.

## EXTRAPOLATION LIMIT

When a source flags an issue, the fix scope is the flagged issue only. Never extrapolate to adjacent fields the source did not flag.

Example: Screaming Frog flags weak H1 on `/collections/torriden`.

- **Allowed:** propose an H1 rewrite grounded in the URL slug and confirmed brand-listing sources
- **NOT allowed:** also rewrite the description, meta title, image alt text, schema, hero copy, internal links, or product range copy unless those were independently flagged with their own sources

If Claude believes an adjacent field also needs fixing, raise it as a separate flagged item with its own source citation. Do not bundle the unsourced fix into the same row.

## TRAINING-MEMORY DETECTION (the failure-mode check)

Before writing any descriptive claim about a brand, product, ingredient, competitor, or aspect of T's business, run this check internally:

> "Did I get this from a source in this conversation, or did I recognise this from training?"

If training memory → STOP.

Three options, no fourth:

1. Fetch live data (`web_fetch` the collection URL, the product page, the competitor site)
2. Ask T for the brief (one question, specific, scoped to the missing data only)
3. Write `NOT VERIFIED — [what would unblock this]` inline and move on, leaving the field empty

## DESCRIPTIVE COPY IS A FACTUAL CLAIM

Brand collection descriptions, product positioning, brand voice statements, "about this brand" copy, hero copy claiming what a brand sells, ingredient/provenance/origin claims — these are factual claims about T's business, not creative writing. They require sources just like numeric facts do.

If no source exists for a brand description:

- Ship H1 + meta title only (which can be derived from the slug as a defensible mechanical change)
- Leave description field as: `[draft requires brand brief from T or live web_fetch of /collections/[handle]]`
- Do not pad. Do not "make it sound good." Do not invent ingredients, provenance, or positioning.

## FAILURE MODES TO REJECT IMMEDIATELY

If Claude catches itself about to do any of the following, STOP and revert:

- Filling a description field for a brand collection without having fetched the live page or had T provide a brief
- Writing "is a proudly South African" / "is a Korean K-beauty" / "is a dermatologist-led" about a brand whose stocked status is not confirmed in this conversation (the confirmed lists in project facts §"SA Brands" and §"Dermocosmetics Stocked" are the only authority)
- Inventing ingredient lists, brand provenance, or product range claims to flesh out a sheet
- Inferring product attributes from brand-name pattern matching ("Torriden sounds Korean therefore K-beauty")
- Padding a row in a table because the template has an empty cell
- Substituting "what a brand probably says" for "what the brand actually says on T's site"

## WHEN IN DOUBT, REFUSE THE FIELD

A row with one NOT VERIFIED field is a complete row.
A row with one fabricated field is a broken deliverable that damages T's live store.

Refusing to fill a field is always the right call when no source exists. T can fill the gap. Claude cannot.

## RELATIONSHIP TO COMPLETE DELIVERABLES

`beautyontapp-complete-deliverables` says: don't ship partial output, fix all known issues in one shot.
This skill says: don't fabricate to make output look complete.

These don't conflict. Complete-deliverables applies to issues with verified sources. If 6 issues are known and all 6 have sources, ship all 6. If only 4 have sources, ship those 4 and label the other 2 NOT VERIFIED — do not invent the missing 2.

When the two skills feel in tension, ANTI-FABRICATION wins. Always.

## HISTORICAL FAILURE — 17 MAY 2026

Claude shipped an admin-edits sheet with 25 rows of brand descriptions fabricated from training memory: Lele Feminine, Uso Skincare, Nilotiqa, Anasa, Torriden, Manetain, Ndanaka, Bonak Beauty, and others. Trigger: SF flagged weak H1s, Claude built a row × column template with a description field, every row needed a description, training memory filled the gap.

The output looked authoritative because it followed the same format as the 2 source-grounded fields per row (handle, current H1). T caught it before publishing. Damage avoided. This skill exists to make that failure mode impossible to repeat.

The specific lesson: a structured template with consistent formatting hides per-field source gaps. Run the TEMPLATE TRAP CHECK before drafting structure, not after.

## GUIDELINES

- Cite inline, every claim. No exceptions for "obvious" facts about T's business.
- When a source is missing, NOT VERIFIED is the only acceptable output. Silence beats fabrication.
- Brand names from training memory are not a source. Recognition is not knowledge.
- Templates with description fields require live fetches BEFORE drafting, not during.
- If T asks for content Claude cannot source, the answer is "I need [specific data] before I can draft this — should I fetch [URL] or do you have a brief?"
- Refusing a field is always allowed. Fabricating a field is never allowed.
