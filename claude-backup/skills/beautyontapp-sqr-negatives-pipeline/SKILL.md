---
name: beautyontapp-sqr-negatives-pipeline
description: Weekly Search Query Report (SQR) to negative-keyword pipeline for BeautyOnTApp (Google Ads account 820-452-9325) and Pastry Skincare (851-084-2703). Takes a search-term CSV export from Google Ads, identifies wasted-spend terms (high spend, zero conversions, wrong intent), classifies each into one of four buckets (irrelevant, wrong intent, competitor, ambiguous), and outputs Google Ads Editor bulk-upload CSV of themed exact-match negative keyword lists ready for upload. Make sure to invoke whenever T uploads a Google Ads search-term report, asks for "negatives", "wasted spend", "SQR mining", "search query review", "negative keywords", "search terms cleanup", "weekly ops", "find waste in Google Ads", or runs the weekly Google Ads housekeeping cadence. Pairs with bleeder-detection, google-ads, ppc-audit-engine, evidence-citations.
---

# SQR Negatives Pipeline

## Why this skill exists

Search-term cleanup is the highest-frequency, lowest-glamour Google Ads ops loop. Most accounts bleed 15-30% of spend on terms with zero purchase intent — beauty queries in particular collect a long tail of "how to" / "DIY" / "free" / informational queries that have no conversion intent at PNCapital's price points.

The canonical pattern is from Frederick Vallaeys (Optmyzr CEO) via Search Engine Land "You can now build PPC tools in minutes with vibe coding": pull the search term report for the last 7 days via the MCP, identify terms with high spend and no conversions, and apply them as exact match negatives to the appropriate campaign.

BoT's account already has account-wide negative `medicube` and PMax brand exclusions for The Body Shop and Standard Beauty. This skill operationalises the weekly cleanup that adds new exclusions as the long tail accumulates.

The cost of skipping this loop: every R200-300 spent on "how to get rid of acne at home" / "free skin samples" / "tiktok shop beauty" is direct CPA inflation on KS_C8 and the other active campaigns.

## When to invoke

Auto-invoke when T:

- Uploads a Google Ads search-term report CSV.
- Says "find waste in Google Ads", "SQR", "search query review", "negatives", "negative keywords", "wasted spend", "search terms cleanup", "weekly ops".
- Runs the weekly Friday housekeeping cadence.
- Mentions specific terms appearing in PMax search categories or Search campaign search-terms that don't match intent.

Pair with `beautyontapp-bleeder-detection` (loaded first per Rule 1), `beautyontapp-google-ads` (account constraints), `beautyontapp-ppc-audit-engine` (when SQR is part of a larger audit).

## Required source data

This skill is data-bound. Refuse to run without:

1. **Search-term CSV export** from Google Ads. Path: Campaigns → Insights & Reports → Search Terms → Download CSV. Columns must include: `Search term`, `Match type`, `Added/Excluded`, `Campaign`, `Ad group`, `Clicks`, `Impressions`, `Cost`, `Conversions`, `Cost / conv.`, `Conv. rate`.

2. **Date range**: minimum 7 days, maximum 30 days. Beyond 30 days the cleanup is too late to matter — those terms have already drained spend.

3. **Account ID**: BoT 820-452-9325 OR Pastry 851-084-2703. Different accounts get different output files.

4. **Existing account-wide negatives list**: so this skill does not propose negatives already excluded. T pastes the current account-wide negative list, or this skill reads it from a referenced file.

5. **Campaign-level negative lists**: if available, prevents proposing PMax negatives that are already in the PMax negative list (17 total per business facts).

If any of items 1-3 are missing, refuse the run and ask ONE question naming the missing input.

If items 4-5 are missing, proceed but flag in the output: "Could not de-duplicate against existing negatives — verify before bulk upload."

## Classification methodology

Every wasted-spend term gets classified into one of four buckets. The bucket determines the negative match type and the target level (account-wide, campaign, or ad-group).

### Bucket 1 — Irrelevant

Terms that have no plausible relationship to BoT's product range or stocked brands.

Examples (illustrative, not from actual data):
- "free samples beauty"
- "how to make homemade face mask"
- "salary beauty advisor"
- "beauty salon jobs cape town"

Match type: **exact match**.
Target level: **account-wide negative list**.
Reason: irrelevance does not vary by campaign — these will waste spend in any context.

### Bucket 2 — Wrong intent

Terms that name a relevant product/brand/category but with informational, navigational, or non-purchase intent.

Examples (illustrative):
- "how often should I exfoliate"
- "cosrx review reddit"
- "is hyaluronic acid safe"
- "what does niacinamide do"

Match type: **exact match** if the term is specific, **phrase match** if it's a pattern.
Target level: **campaign-level** if the campaign targets purchase intent, **ad-group-level** if intent varies within the campaign.
Reason: same query phrased commercially could still be valuable elsewhere (e.g. SEO/AEO content). Negate only at the campaign level that pays for the click.

### Bucket 3 — Competitor

Terms that name a competitor's brand or store.

Examples (illustrative):
- "clicks beauty"
- "dis-chem skincare"
- "bash beauty"
- "secret skin south africa"
- "glow theory k-beauty"

Match type: **exact match**.
Target level: **account-wide negative list**.
Reason: BoT does not bid on competitor brand searches, and these terms appear most often as broad-match overflow that should be killed everywhere.

Exception: KS_C8_Brand_Protection. If the competitor term appears in KS_C8 results, that's a defensive signal worth surfacing — competitors are bidding on BoT's brand and BoT's brand-protection is catching the reverse query. Flag in output, do not negate, hand to T for decision.

### Bucket 4 — Ambiguous

Terms where the bucket cannot be determined from the search term alone. Either the term is too generic ("beauty"), too short ("face"), or the intent is unclear from context.

Match type: do not negate yet.
Target level: T review.
Action: output as a separate "review list" with first 5 impressions/clicks data and recommend either a one-week monitoring window or a phrase-match negative if the data shows zero conversions across 100+ clicks.

## Severity thresholds

The classification logic only fires when a term hits one or more of these thresholds:

- **High spend, zero conversions**: cost ≥ R200 in the period, 0 conversions. Highest priority bucket.
- **Medium spend, zero conversions**: cost ≥ R100, < R200, 0 conversions. Second priority.
- **Low spend, zero conversions, high impressions**: cost < R100, impressions ≥ 1,000, 0 conversions. Third priority — usually points to a thematic pattern worth pre-emptive negating.
- **CPA above R300 ceiling**: any term with cost / conv > R300. Sometimes the conversion is incidental — review case by case.

Terms below all four thresholds are noise. Skip them.

## Output format

Two CSVs and one Markdown summary per run.

### CSV 1 — Account-wide negatives ready for bulk upload

Google Ads Editor "Account-wide negative keywords" template format:

```
Account,Match type,Negative keyword
BeautyOnTApp,Exact match,clicks beauty
BeautyOnTApp,Exact match,how to make homemade face mask
...
```

One row per term. All Bucket 1 (irrelevant) and Bucket 3 (competitor) terms.

### CSV 2 — Campaign/ad-group negatives ready for bulk upload

Google Ads Editor "Negative keywords" template format:

```
Campaign,Ad group,Match type,Negative keyword
Search_LocalBrands,,Exact match,how often should I exfoliate
PMax_BeautyOnTApp,,Phrase match,review reddit
...
```

One row per term. All Bucket 2 (wrong intent) terms, scoped to their source campaign/ad-group from the CSV.

### Markdown summary

```
SQR Negatives Run — [Account] — [Date range]

Period covered: [start] to [end]
Total search terms reviewed: [N]
Wasted spend identified: R[total]
Terms above severity threshold: [N]

Classification breakdown:
- Bucket 1 (irrelevant): [N] terms, R[spend] wasted
- Bucket 2 (wrong intent): [N] terms, R[spend] wasted
- Bucket 3 (competitor): [N] terms, R[spend] wasted
- Bucket 4 (ambiguous, T review): [N] terms, R[spend] wasted

Top 5 highest-waste terms:
1. [term] — R[spend] — [bucket] — [campaign]
2. ...

Defensive signals (KS_C8 catching competitor reverse queries): [N]
- Term, campaign, count

Estimated weekly savings if all proposed negatives applied: R[total]

Files generated:
- account_wide_negatives_[account]_[date].csv
- campaign_negatives_[account]_[date].csv
- review_list_[account]_[date].csv (Bucket 4 terms for T to assess)
```

## Hard rules

- **Do not propose negatives that violate the "broad product-type negatives" rule.** Business facts: never add broad product-type negatives ("face wash", "face serum", "face cream") — these block high-intent queries containing those terms. If a search-term cleanup proposes one of these, refuse the proposal and flag.
- **Do not propose negatives that conflict with intentional bidding.** Business facts: never bid generics without brand/ingredient/concern qualifier — but qualified generics ("hyaluronic acid serum south africa") are intentional. Distinguish carefully.
- **Account-wide medicube is already excluded.** Do not re-propose it.
- **PMax brand exclusions (The Body Shop, Standard Beauty) are already in place.** Do not re-propose them.
- **KS_C8_Brand_Protection negatives are a separate domain.** If a term appears in KS_C8's search-term report with negative intent, that's a defensive signal, not a wasted-spend signal. Surface to T, do not auto-negate.
- **Use the "Conversions" column, never "All conversions".** Business facts: All conversions includes 194 phantom conversions from 4 Google-hosted local actions.
- **English only.** Afrikaans terms in search-term reports are themselves a negative signal (T's audience is English-only) — propose negation.
- **Pastry Skincare runs on account 851-084-2703.** Output must specify which account each CSV is for. Do not mix.

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| Negating "face wash" because it appeared in a wasted-spend term | Blocks high-intent queries like "best face wash for oily skin south africa" |
| Negating a brand that's actually stocked | If BoT stocks COSRX and "cosrx" appears with low conversion that week, the negative kills future weeks of legitimate traffic |
| Phrase-match negatives that are too broad | "phrase match: skincare" negates everything |
| Negating informational terms account-wide | "what is niacinamide" should be a campaign-level Bucket 2, not account-wide — SEO/AEO content benefits from these queries |
| Running this skill on <7 days of data | Insufficient data, premature classification |
| Skipping the de-duplication check against existing negatives | Duplicate upload errors in Google Ads Editor |
| Not separating Pastry and BoT accounts | Wrong-account negative upload risk |

## Downstream usage

After CSVs are generated:

1. T opens Google Ads Editor.
2. For CSV 1 (account-wide): Account → Negative keyword lists → Account-wide → Make multiple changes → paste CSV.
3. For CSV 2 (campaign/ad-group): Same flow, Campaign-level negative keyword lists.
4. Editor validates against current account structure — flags any campaign/ad-group names that don't match.
5. Review character counts and match types.
6. Post changes to account.
7. Tag the upload batch with a label matching the date for tracking.
8. Re-run this skill weekly. Compounding wasted-spend reduction over 4-6 weeks should be measurable in CPA.

## Cadence

- **Weekly default**: every Friday, last 7 days. Quick run, ~10-20 new negatives per week typically.
- **Monthly catch-up**: first Friday of each month, last 30 days. Larger run, catches slow-burn terms that didn't hit thresholds week-to-week.
- **Post-launch**: 48-72 hours after any new campaign launch, last 3 days. Catches broad-match overflow before it scales.
- **Quarterly review**: every 90 days, full account-wide negative list audit. Some old negatives may no longer be relevant if BoT's range expanded.

## Self-check before delivering

Run silently before shipping CSVs:

1. Are all proposed negatives in one of the four buckets? Ambiguous terms in Bucket 4 review list, not negatives CSVs.
2. Any proposed negative that matches a stocked brand (CeraVe, Eucerin, La Roche-Posay, Bioderma, Vichy, Avène, Neutrogena, plus all confirmed SA brands)? If yes, remove and re-classify.
3. Any broad product-type negatives proposed ("face wash", "face serum", "face cream")? If yes, remove.
4. Are competitor brand negatives in the account-wide CSV (not campaign-level)?
5. Are KS_C8 defensive signals surfaced separately, not in the negatives CSVs?
6. Are Pastry and BoT separated into different output files if both accounts' data was in the input?
7. Does the summary report include estimated weekly savings?

If any check fails, fix silently and re-deliver.

## What this skill does NOT do

- Does not pause campaigns — that's `beautyontapp-bleeder-detection` decision territory.
- Does not change bidding, audiences, or campaign structure — that's `beautyontapp-google-ads`.
- Does not run a full account audit — that's `beautyontapp-ppc-audit-engine`.
- Does not write new RSAs — that's `beautyontapp-rsa-generator`.
- Does not upload to Google Ads — execution via Google Ads Editor is T's job after CSVs are generated.

## Model routing

- **Single-week CSV (typically <500 search terms)**: Sonnet 4.6 with default thinking. Single file, bounded reasoning.
- **30-day catch-up run**: Sonnet 4.6 with high effort. Larger input, more classification work.
- **Quarterly full-account-negative-list audit**: Opus 4.7 with high effort. Cross-campaign reasoning to flag stale negatives.

## Pairs with

- `beautyontapp-bleeder-detection` — loaded first per Rule 1 of the router on any paid-ads question.
- `beautyontapp-google-ads` — account constraints, daily ceilings, campaign-specific rules.
- `beautyontapp-ppc-audit-engine` — when SQR cleanup is one step of a broader audit.
- `beautyontapp-evidence-citations` — every term in output cites its source row in the input CSV.
- `beautyontapp-prompting-discipline` — XML scaffold + refuse-the-field defaults for the SQR prompt.
- `beautyontapp-audit-first` — read the CSV in full before proposing negatives.
- `pastry-skincare-google-ads` — when running on Pastry account 851-084-2703.

## Example invocation

T uploads `search_terms_bot_may_18-21_2026.csv` (1,200 rows, 7 days, BoT account):

```
Run SQR negatives pipeline on the attached file.
Account: 820-452-9325 (BoT).
Date range: 18-21 May 2026 (4 days).
Existing account-wide negatives: [paste current list or reference file].
Classify per the 4-bucket methodology. Output the 2 CSVs + summary.
Severity threshold: high + medium + low (all three categories).
```

Expected output: 2 CSVs ready for Editor + Markdown summary. Estimated 15-30 new negatives proposed for a 7-day window at PNCapital's volume.

## Versioning

v1 — first deployed. Built from:

- Frederick Vallaeys (Optmyzr) via Search Engine Land "You can now build PPC tools in minutes with vibe coding" — the canonical "pull search term report, identify high spend zero conversions, apply as exact match negatives" pattern.
- AgriciDaniel/claude-ads public repo: SQR mining patterns from the 250+ check audit framework.
- T's PNCapital business facts: account-wide negatives, PMax exclusions, the "no broad product-type negatives" rule, the conversion-column rule, the Pastry-account separation rule.

When Google Ads changes its CSV export schema (rare but happens annually), update the column references in "Required source data" and the output CSV templates. When new account-level rules are added (e.g. additional account-wide negatives become standard), update the hard rules section.
