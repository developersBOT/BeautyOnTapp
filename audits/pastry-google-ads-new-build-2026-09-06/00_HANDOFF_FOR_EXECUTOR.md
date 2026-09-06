# Handoff for the executor ("Code X")

Purpose: create the campaigns in this package in Google Ads customer 8510842703 (Pastry Skincare). The session that prepared this package had read-only access and applied nothing. Everything below is exact and can be executed by hand in the Google Ads UI, by Google Ads Editor import, or by an agent with Google Ads API write access using 08_build_spec.json.

## Authority you need before starting
- Budget authority: R470/day new Search plus R150/day Shopping (and, from the audit, restore Pastry_Brand_Search to R200/day).
- Bidding and keyword authority for the new campaigns.
- Authority to pause the existing campaign "Pastry | Search | Product High Intent | 2026-08-14" (24142894204) once the new campaigns serve.
- Merchant Center access to fix two feed image issues before Shopping goes live.

## Files and what each one is for
| File | Use |
|---|---|
| 08_build_spec.json | Single machine-readable source: campaigns, ad groups, keywords with bids, RSAs, negatives, assets, Shopping product groups |
| 06_google_ads_editor_import_search.csv | Google Ads Editor import for C1 to C4 (campaigns, ad groups, keywords, RSAs, campaign-level negatives) |
| 06b_google_ads_editor_import_negative_lists.csv | Shared negative lists |
| 01_campaign_plan.csv | Campaign settings that Editor does not carry (goal, geo exclusions, suffix) |
| 02_ad_groups_keywords.csv | Every keyword with bid, URL and the evidence behind it |
| 03_negative_keywords.csv | All negatives with scope and rationale |
| 04_rsa_ads.csv | Ads with per-asset text (validated lengths) |
| 05_assets_sitelinks_callouts_snippets.csv | Sitelinks, callouts, structured snippet |
| 07_shopping_product_groups.csv | Shopping campaign partition tree and bids |
| evidence/ | Data used: Semrush ZA demand, asset performance labels, product/URL map, 28-day baseline |

## Pre-flight checks (do all, record results)
1. Confirm the primary conversion set is still only "Pastry Skincare (web) purchase" (7514901304). If anything else is primary, stop and fix that first.
2. Open each final URL in 02_ad_groups_keywords.csv and confirm it resolves to the named product, in stock, at the feed price used in the ad copy (04_rsa_ads.csv). Prices in copy: glycolic R330, salicylic R330, lactic R310, niacinamide lotion R325, body butter R205, hyaluronic lotion R290, vitamin C cream R285, body oil R385, BHA balm R385, BHA gel R210, deodorant R250, SPF50 R465, niacinamide serum R250, evening pigment corrector R295, ceramide serum R280. Edit any headline or description whose price differs.
3. Confirm https://pastryskincare.co.za/collections/hyperpigmentation is live (used by C3 "Hyperpigmentation Body Care"). If not, point that ad group to the glycolic body wash page.
4. Merchant Center: fix image_unwanted_overlays on Brightening Body Oil (shopify_ZZ_9322841997553_46993404330225) and Anti-Pigment Hand Cream SPF30 (shopify_ZZ_8818191630577_46989386907889); confirm 43 offers are IN_STOCK.
5. Confirm no Performance Max campaign is enabled.

## Build order
1. Import 06b (shared negative lists). Attach: Brand routing to C1 to C4 only; Competitor, Retailers, Positioning/stock to C1 to C5; Informational to C1 to C4. Do not attach any list to Pastry_Brand_Search.
2. Import 06 (Search campaigns). Campaigns arrive PAUSED. Then, per campaign, set what Editor did not: location exclusions China, Hong Kong, Singapore (mirror Pastry_Brand_Search); campaign-level conversion goal = Purchase (GA4 web purchase) only; ad rotation Optimise; final URL suffix from 01_campaign_plan.csv; no search partners, no Display.
3. Add assets from 05 at campaign level (sitelinks, callouts, structured snippet); the Niacinamide Serum sitelink only on C4.
4. Create the Shopping campaign C5 from 07: Standard Shopping, Merchant 5692060761, feed label ZAR_29152772337, South Africa, Manual CPC, budget R150, priority Low, product groups by product_type with the listed bids, "Everything else" excluded. Leave PAUSED until step 6.
5. Review ad policy status after import; fix any disapproval before enabling.
6. Enable in this order, one day apart: C1 and C2 (day 1), C3 and C4 (day 2), C5 (after the feed fixes clear, day 3 or later). On the day C1 and C2 go live, pause the old "Product High Intent" campaign (24142894204) so the two builds do not bid against each other.

## Guardrails after launch
- Daily for 7 days: spend vs budget, policy status, search terms. Add negatives for any query outside product or concern intent; do not add negatives for low-conversion queries in the first 14 days.
- Stop rules (per keyword, evaluated weekly): pause a keyword that has spent R300 with no purchase and no add-to-cart signal; halve the bid on any keyword whose average CPC exceeds R8; in C4, cap "niacinamide serum" at 40% of the campaign's daily spend by lowering its bid if it exceeds that.
- Scale rules: raise a keyword bid by 20% (max R9) when it has a purchase and impression share below 50%; raise a campaign budget by 25% when it hits budget on 4 of 7 days with CPA under R130.
- Bid strategy: keep Manual CPC until a campaign records 15 purchases in 30 days, then Maximise conversions with no target; add target CPA R130 after 30 purchases.
- Report weekly with: spend, clicks, purchases (GA4 web purchase only), value, CPA, ROAS, impression share and rank-lost share, per campaign and per ad group; RSA asset labels after 14 days (replace "Low" assets).

## Do not
- Do not run Performance Max alongside C5.
- Do not add delivery, shipping, courier, clinical or comparative claims to any ad.
- Do not attach the old 257-term negative list ("BOT" shared sets) to these campaigns.
- Do not switch the primary conversion action.
