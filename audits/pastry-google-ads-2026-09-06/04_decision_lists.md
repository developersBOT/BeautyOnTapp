# Decision lists (Pastry Skincare, Google Ads 8510842703, evidence as of 2026-09-06)

Every item cites a finding ID (03_findings_register.csv) or candidate ID (08_product_keyword_destination_candidates.csv).

## Preserve (no change)
- Pastry_Brand_Search keyword set incl. BROAD "pastry skincare" / "pastry skin care" and all location/retailer brand exacts. Brand misspellings and retailer-navigation queries convert (F-16, F-07). Source: raw/40, raw/53.
- Cross-campaign routing of brand+product queries into the Product High Intent campaign (F-07 ledger row "Cross-campaign routing"): cheaper CPC and product-page destinations, with purchases.
- All current negatives at customer, campaign and ad-group scope on the two active campaigns (07_negative_conflict_ledger.csv). No conflict found. No removals needed.
- Non-attachment of the shared list "Master Negatives - Pastry Skincare" (11990873152) to active campaigns (F-07).
- Rarely-served product keywords (F-13): zero cost, no action.
- Language, geo, network settings on active campaigns (F-14): leads only.
- Low-click, zero-purchase brand variants such as "pantry body wash" (22 clicks, R24) are NOT labelled waste (F-16).
- Competitor-brand product queries inside PHI ("aplb glutathione niacinamide body lotion" 1 click, "standard beauty salicylic acid body wash" 2 clicks): watch, no exclusion. Competitor wording alone is not proof of waste.

## Repair (evidenced defects)
- CS-01 (or CS-01-ALT, not both): Brand budget R400 -> R200/day, restoring the pre-30-Aug state (F-02). Authority required.
- CS-02: pause ad group 197968132526 (Anti-Pigment Hand Cream) while the feed variant is OUT_OF_STOCK; re-enable on restock (F-05). Stock confirmation required first.
- CS-06: store-side image fixes for the two offers with image_unwanted_overlays (F-06). Not a Google Ads change.

## Test / grow (verified destinations, in-stock per feed copy)
- CS-03a..d: keyword-level bid raises on four PHI exact keywords with purchase evidence or top demand (F-04, B-01..B-04). Authority required; stop rules defined.
- CS-04a..f: six exact keyword additions to existing PHI ad groups whose destination is an in-stock product (K-01..K-06). Authority required.
- CS-05: decision on re-enabling one product route (Shopping or PMax) on the corrected purchase signal (F-03). Decision + authority required; pre-conditions listed in the change sheet.
- CS-07: end the stale Shopping experiment (F-10). Optional.

## Evidence needed (no change proposed)
- Canonical GA4 property and whether actions 7412046457 / 7453310793 should be hidden (F-08, CS-08).
- Shopify order reconciliation for the GA4 purchase and Google Shopping App Purchase series (F-19). Shopify connector token expired in this session.
- Live checks of every destination URL (redirects, buy button, variants): storefront domain blocked by the egress proxy; only the Merchant feed copy was readable.
- Whether Pastry is stocked at Clicks, Dis-Chem, Woolworths, Takealot (affects retailer negatives on any re-enabled Shopping campaign; F-07 ledger).
- Delivery-time claims in live ad copy vs current store policy (F-09).
- Pastry brand entity for a PMax brand exclusion (F-03).
- Merchant Center account-level issues, data sources, sync ownership, overlapping writers (no Merchant Center access; only the Ads-side feed copy).
