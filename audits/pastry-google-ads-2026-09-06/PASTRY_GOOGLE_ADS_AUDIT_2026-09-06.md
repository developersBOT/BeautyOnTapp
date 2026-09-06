# Pastry Skincare Google Ads audit and repair package

Account: customers/8510842703, Pastry Skincare, ENABLED, ZAR, Africa/Johannesburg. Read via the read-only "Pastry Google Ads" connector on 2026-09-06 between 10:16 and 10:35 UTC. Nothing in this package has been applied.

## Commercial verdict

Current serving is two Search campaigns only. Pastry_Brand_Search does the commercial work: last 7 complete days (30 Aug to 5 Sep) R2,565 spend, 49.8 GA4 purchases, R44,871 attributed value. The product campaign created on 14 Aug spent R293 for 2 purchases in the same week and is bid-starved rather than demand-starved. Every Shopping and Performance Max route has been off since 12 Aug, so all 47 Merchant offers are unadvertised. The pause decision, and every conversion figure before about 10 Aug, rested on a polluted primary conversion set: a GA4 custom event fired 870 to 1,670 "conversions" a week at about R16 each while real purchases were counted in single digits. Since 10 Aug the only primary action is the GA4 purchase import and the numbers are usable. The most recent change in the account (budget doubled on 30 Aug) has so far bought higher brand CPCs, not more purchases.

## Three highest-priority actions

1. Restore the Brand Search budget to R200/day (CS-01), or set a target CPA if the R400 budget must stay. Evidence: budget change 2026-08-30 09:53; weekly average CPC R0.93 then R1.09 then R2.04; clicks fell 1,440 to 1,132 while spend rose R1,565 to R2,311 (6 days). Search impression share was already above 80%. Requires budget authority.
2. Fix the product route before spending more on it: pause the Anti-Pigment Hand Cream ad group while the feed variant is OUT_OF_STOCK (CS-02), fix the two offers with image overlays in Shopify (CS-06), then raise bids on the four exact product keywords with purchase evidence (CS-03) and add six exact keywords for in-stock products with measurable South African demand (CS-04). Requires bidding/keyword authority.
3. Decide, on the corrected purchase signal, whether to re-enable one Shopping or PMax route (CS-05). On the secondary Google Shopping App purchase action, Pastry_PMax attributed 305.9 purchases (R236k) on R12,736 in the last 90 days, but roughly 40% of its reportable search clicks were brand queries that Brand Search now captures. This is a decision, not a dispatch item.

## Source and access register

See 01_source_access_register.csv. Key limits: storefront and Google Help domains blocked by the egress proxy (no live URL checks); Shopify token expired (no order reconciliation); no GA4 or Merchant Center access beyond the Ads-side feed copy; change_event covers 2026-08-08 onward and does not log conversion-action edits; two campaign fields errored on the connector. Reporting periods (complete account days): L7 2026-08-30..09-05, P7 08-23..08-29, L28 08-09..09-05, P28 07-12..08-08, L90 06-08..09-05, P90 03-10..06-07. Partial day 2026-09-06 held separately (Brand 48 clicks R132.55; product 5 clicks R14.35; not extrapolated).

## Baseline (account, purchases only where the primary set is clean)

| Period | Cost ZAR | Clicks | Primary conv (basis) | GA4 purchase 7514901304 | Google Shopping App purchase 7411495331 |
|---|---|---|---|---|---|
| L7 30 Aug..5 Sep | 2,857.79 | 1,435 | 51.8 (GA4 purchase) | = primary, R46,696 | not queried |
| P7 23..29 Aug | 1,947.03 | 1,578 | 76.0 (GA4 purchase) | = primary, R56,179 | not queried |
| L28 9 Aug..5 Sep | 9,381.31 | 6,430 | 347.5 (mixed: ~127 legacy on 9..10 Aug clicks) | 220.8, R177,042 | 320.9, R281,583 |
| P28 12 Jul..8 Aug | 20,103.54 | 13,213 | 3,434 (polluted) | 31.1, R23,921 | 450.7, R357,935 |
| L90 8 Jun..5 Sep | 57,275.08 | 37,400 | 8,802 (polluted before 10 Aug) | 268.0, R214,671 | 1,334.3, R1,098,321 |
| P90 10 Mar..7 Jun | 27,115.67 | 18,679 | 3,821 (polluted) | 10.0, R6,882 | 476.7, R427,644 |

Attributed conversions are not unique orders or profit. The two purchase series use different windows and models and must not be added. Full per-campaign rows in 02_campaign_measurement_baseline.csv.

Current campaign state (19 campaigns): 2 serving (Pastry_Brand_Search 23660059123, Max Conversions no target, R400/day; Pastry | Search | Product High Intent 24142894204, manual CPC R3.00, R100/day), 1 ENABLED but ENDED (Shopping tROAS experiment 24003538946), 13 PAUSED, 3 REMOVED. All Search campaigns: Google Search only, South Africa presence, English. Merchant Center 5692060761 linked; feed ZAR_29152772337; 47 offers, 43 in stock, 4 out of stock, 2 image errors, all "not eligible in any campaign".

## Measurement

Primary set today: only "Pastry Skincare (web) purchase" (7514901304, GA4 property 525948625, data-driven, many-per-click, 90-day click window) is included in Conversions; all other 14 actions are secondary. Before clicks of 10 Aug, "pastry skincare (web) ads_conversion_purchase" (7453310793, GA4 custom event from property 515709774) was counted as primary (weekly 460 to 1,669 at about R16) alongside 2 to 13 real purchases; it last converted 2026-08-10. GA4 purchases then rose to 59, 39, 78 and 42 per week. Two GA4 properties remain linked. Fractional attribution and many-per-click counting are not defects. Goal configuration is at campaign level on all non-removed campaigns with only PURCHASE~WEBSITE biddable.

## Findings register (summary; full text in 03_findings_register.csv)

Ranked by severity: F-01 polluted primary set until ~10 Aug (Critical historical, High confidence); F-02 Brand budget doubling raised CPC (High, Medium-High); F-03 all product routes off, 47 offers unadvertised (High, High for state); F-04 product campaign below first-page bids on 33 of 47 keywords, 78..81% rank-lost (Medium, High); F-05 paid clicks to an out-of-stock hand cream page (Medium, Medium); F-06 two image-overlay errors and four out-of-stock offers (Medium latent, High). Ranked by confidence, the High-confidence items are F-01, F-03 state, F-04, F-06, F-07, F-08, F-10, F-11, F-12, F-13, F-15..F-20. Low-severity leads F-07 to F-20 are listed with evidence.

## Decision lists

See 04_decision_lists.md (preserve, repair, test/grow, evidence needed). No low-conversion traffic is labelled waste; no negatives are added or removed.

## Change sheet

05_change_sheet.csv: 18 rows (CS-01 to CS-08 with sub-items), each with current value, proposed value, evidence, mechanism, priority, confidence, dependency, authority status (all BLOCKED by read-only access), validation and exact rollback.

## Search-term coverage and negatives

06_search_term_coverage_ledger.csv: Search 90-day export uncapped, 91.5% of Search spend reportable; Shopping 90-day export uncapped after 35 daily and 5 weekly partitions, 81.8% (Pastry_Shopping) and 89.1% (experiment) reportable; Pastry_PMax insight withholds 34% of its clicks; Shopping prior-90 export remains capped. Withheld spend is not treated as waste.

07_negative_conflict_ledger.csv: no positive/negative conflict and no overblocking on the two active campaigns at any scope. The 257-term shared list is not attached to them and should stay unattached unpruned, because it contains "azelaic acid", "pantry lotion/products" and retailer terms that would block converting queries. Negative-keyword match behaviour (no close variants; broad = all words any order; phrase = same order) could not be re-verified against the live Google document in this session (domain blocked) and is marked NOT VERIFIED.

## Product-keyword and destination candidates, Merchant findings

08_product_keyword_destination_candidates.csv: six exact keyword additions to existing ad groups whose destinations are in stock in the feed copy (largest: "niacinamide serum" 6,600 ZA searches/month, "dark spot corrector" 1,600), four bid tests, one hold (hand cream with SPF, out of stock). Live page content, redirects and buy path: NOT VERIFIED (egress blocked). Merchant: evidence/merchant_products_feed_copy.csv.

## Implementation dispatch, validation, limits

10_implementation_dispatch.md lists the 13 dispatchable targets (all blocked pending authority) with from/to values and receipts required. 11_validation_and_limits.md records the audits run, executed changes (none), unresolved limits and what to measure next.
