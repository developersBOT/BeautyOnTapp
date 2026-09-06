# Validation results, executed changes, unresolved limits, what to measure next

## Executed changes
None. The connector is read-only. No proposal in this package is applied, previewed or scheduled.

## Validation performed on the investigation
- Identity re-confirmed live: customers/8510842703, "Pastry Skincare", ENABLED, ZAR, Africa/Johannesburg (2026-09-06 10:16:56Z).
- Search-term coverage reconciled to campaign spend for every campaign and window (06_search_term_coverage_ledger.csv). Shopping 90-day export re-partitioned until every partition was under the 10,000-row cap; consolidated file deduplicated on campaign + search term (94,543 distinct).
- Conversion reconciliation: primary "conversions" reconciled to per-action all_conversions by week (raw/35, raw/46) and per period (customer by-action queries); the 10-Aug primary switch is visible in both.
- Arithmetic audit (second pass) of the period tables: account L7 cost R2,857.79 = Brand R2,565.04 + PHI R292.75; L28 cost R9,381.31 = Brand R6,663.75 + PHI R1,019.31 + Pastry_Shopping R899.70 + Pastry_PMax R798.55 (9-12 Aug); brand weekly CPC figures recomputed from daily rows.
- Identifier/URL audit: every campaign, budget, ad group, criterion, conversion action and Merchant item ID in the change sheet was copied from the evidence files, not typed from memory; URLs are the exact final URLs held in the account (no live fetch possible).

## Unresolved limits
- Storefront pastryskincare.co.za and support.google.com are blocked by the session egress proxy: no live page, redirect, buy-path or policy-doc verification. Negative-keyword match statements rely on general knowledge and are marked NOT VERIFIED against the current Google document.
- Shopify connector token expired: no order/revenue reconciliation. GA4 not connected. Merchant Center only visible as the Ads-side feed copy.
- change_event covers 2026-08-08 onward and does not log conversion-action edits; campaign.start_date/end_date and url_expansion_opt_out fields errored on this connector.
- Conversion lag: GA4 purchase import uses a 90-day click window; the last 7 days are materially incomplete and were not extrapolated.
- Shopping prev-90 search-term export remains capped (10,000 rows) and is not exhaustive.
- Partial day 2026-09-06 was excluded from all period arithmetic.

## What to measure next (purchase and contribution impact)
1. After CS-01: 7 and 14 complete days of Pastry_Brand_Search daily cost, clicks, avg CPC, search IS, budget-lost IS, GA4 purchases (click-date and conversion-date) against 2026-08-24..2026-08-30. Success = CPC back near R1.0-1.1 with purchases within normal weekly variance (36-78/week observed).
2. After CS-03/CS-04: keyword-level impressions, IS, clicks, cost and GA4 purchases per keyword over 14 days; stop rules in the change sheet.
3. Contribution: cannot be computed without Shopify orders and product margins (NOT IN SOURCE). Once Shopify access is restored: match GA4 purchase counts by day to Shopify orders with utm_source=google, then apply margins supplied by PNCapital. Do not add the GA4 and Google Shopping App purchase series.
4. Before CS-05: confirm F-06 image fixes, stock on the 4 OUT_OF_STOCK offers, and decide brand handling; then judge the re-enabled route on GA4 purchases only.
