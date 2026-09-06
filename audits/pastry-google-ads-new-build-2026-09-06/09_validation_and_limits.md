# Validation and limits

## Checks run by gen_build.py (all passed)
- Every final URL appears in the account already (existing keyword or ad final URL): 20 destinations verified against keywords_active_campaigns.csv and ads_all_campaigns.json.
- No duplicate keyword/match-type pairs across the 88 keywords.
- Headlines 30 characters or fewer (274 headlines), descriptions 90 or fewer (76), paths 15 or fewer, sitelink text 25 / lines 35, callouts 25.
- Banned-phrase scan on all ad and asset text: delivery, shipping, courier, pickup, cure, treat, treatment, bleach, whitening, lightening, dermatologist, clinically, guarantee, best, #1. Zero hits.
- Prices in copy equal feed prices for the lowest in-stock variant (merchant_products_feed_copy.csv, 2026-09-06).
- Editor import: 170 rows, one campaign row per campaign, one ad group row per ad group, keyword rows with bids, one RSA row per ad group, campaign-level negatives.

## Evidence used
- Google Ads (read-only, 2026-09-06): keyword bids and first-page/top-of-page estimates, 28-day keyword metrics, search terms, RSA asset performance labels (ad_group_ad_asset_view), shopping_product feed state, customer settings (auto-tagging on).
- Merchant feed copy (47 offers) from the audit evidence folder.
- Semrush ZA: phrase_these for 50 seed terms (25 returned) and phrase_fullsearch for body wash, hyperpigmentation, dark underarms, stretch marks, body lotion. Consolidated in evidence/semrush_za_demand_consolidated.csv.

## Limits
- Read-only connector: nothing was created; execution is by the operator.
- Live pages, prices, stock and the hyperpigmentation collection URL: NOT VERIFIED (session egress blocked). Pre-flight step 2 covers this.
- Semrush credits ran out after five fullsearch reports; niacinamide, glycolic, salicylic, body acne, deodorant, sunscreen, hand cream, body oil, inner thighs, knees and brand seed reports were not retrieved. Keywords marked "no Semrush ZA row" rely on account search-term evidence or are labelled tests.
- Stretch-mark terms (ZA 3,600/month head term) were left out: no product page claim about stretch marks could be verified, and the copy rules exclude unverified claims.
- Hand cream terms excluded while the Anti-Pigment Hand Cream SPF30 is OUT_OF_STOCK; add back with the audit's K-07 hold lifted.
- Forecast figures are extrapolated from 358 clicks and 9 purchases; treat the first 14 days as measurement.
- Google policy review occurs at upload; personal-attribute and health-claim policies may flag "dark underarms" or "hyperpigmentation" wording. If an ad is disapproved, remove the flagged asset rather than the ad group.
