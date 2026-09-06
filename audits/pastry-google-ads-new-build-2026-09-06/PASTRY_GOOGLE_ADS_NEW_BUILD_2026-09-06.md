# Pastry Skincare: new Google Ads build (investigation and report)

Account: customers/8510842703 (Pastry Skincare, ZAR, Africa/Johannesburg). Data read on 2026-09-06 through the read-only "Pastry Google Ads" connector, the Merchant feed copy in the account, and Semrush (ZA database). Nothing in this package has been applied to the account: the connector used here is read-only, so execution is handed to an authorised operator ("Code X") with the runbook in 00_HANDOFF_FOR_EXECUTOR.md and the machine-readable spec in 08_build_spec.json.

## 1. Why a new build, and what "accurate data" means here

The audit in ../pastry-google-ads-2026-09-06 established that every conversion figure before about 10 Aug 2026 was inflated by a GA4 custom event that counted as primary; since 10 Aug the only primary action is the GA4 purchase import (7514901304), and the numbers are usable. This build uses only that clean window (2026-08-09 to 2026-09-05, 28 complete days), the feed as it stood on 2026-09-06, and live first-page bid estimates from the account.

What the clean window says:

| Signal (28 days, 9 Aug to 5 Sep) | Value | Source |
|---|---|---|
| Existing product campaign spend | R1,019 | keyword_metrics_active_2026-08-09_to_2026-09-05.csv (keyword-level sums) |
| Clicks / impressions | 358 / 3,028 | same |
| GA4 purchases / value | 9 / R6,430 | same |
| CPA / ROAS / click CVR / avg CPC | R113 / 6.3 / 2.5% / R2.85 | derived |
| Keywords below first-page bid | 33 of 47 (all bids fixed at R3.00) | keywords_active_campaigns.csv |
| Brand Search (30 Aug to 5 Sep) | R2,565 spend, 49.8 purchases, R44,871 | audit baseline |
| Merchant offers | 47 total, 43 IN_STOCK, all "not eligible in any campaign" | shopping_product query 2026-09-06 |

Three things follow. The product route converts at an acceptable CPA but is bid-starved: a flat R3.00 bid sits under the first-page estimate on most terms (glycolic exact R4.08, niacinamide lotion exact R6.47, salicylic exact R6.47, deodorant R9.09). Second, the campaign is doing brand work by accident: 20 of its 60 most-clicked queries start with "pastry", which Pastry_Brand_Search already buys more cheaply. Third, the whole catalogue is invisible on Shopping because every Shopping and PMax campaign has been paused since 12 Aug.

## 2. What was built

Five campaigns, 19 ad groups, 88 keywords, 19 responsive search ads, 5 shared negative lists, 10 assets, and one Standard Shopping campaign with 14 product groups. Every keyword row in 02_ad_groups_keywords.csv carries its demand evidence (Semrush ZA), live bid evidence (first-page and top-of-page estimates, Quality Score), and 28-day serving evidence where the keyword already exists.

| Build id | Campaign | Daily budget | Ad groups | Keywords | Destination logic |
|---|---|---|---|---|---|
| C1 | Pastry / Search / Body Wash / ZA / 2026-09 | R150 | 5 | 26 | one ad group per acid body wash plus a concern group ("body wash for dark marks") to the glycolic page |
| C2 | Pastry / Search / Body Lotion & Treatment / ZA / 2026-09 | R120 | 8 | 26 | niacinamide lotion (proven), brightening-lotion concern group, vitamin C cream, body butter, hyaluronic lotion, BHA balm, BHA gel, body oil |
| C3 | Pastry / Search / Concern Intent / ZA / 2026-09 | R120 | 2 | 20 | dark underarms to the deodorant page; hyperpigmentation body-care terms to the hyperpigmentation collection |
| C4 | Pastry / Search / Face Serums / ZA / 2026-09 | R80 | 4 | 16 | niacinamide serum (6,600 ZA searches/month), dark spot corrector (1,600), ceramide serum, SPF50 |
| C5 | Pastry / Shopping / All In-Stock / ZA / 2026-09 | R150 | 14 product groups | n/a | Standard Shopping on feed ZAR_29152772337, manual CPC by product type, "Everything else" excluded |

Total new daily budget: R470 Search plus R150 Shopping. With the existing Brand campaign restored to R200/day (audit change CS-01) the account would run about R820/day.

Settings shared by C1 to C4: Google Search only (no partners, no Display), South Africa presence-only with the same country exclusions as Pastry_Brand_Search, English, Manual CPC with the keyword bids in the sheet, campaign-level conversion goal = GA4 purchase only, final URL suffix carrying UTM values (auto-tagging is on; gclid remains the primary key). All campaigns are imported PAUSED and enabled only at step 6 of the runbook.

## 3. Bidding logic

Bids are set from the account's own first-page estimates, stepped rather than matched where a term has spend without purchases:

- Proven terms are bid at or near first page: glycolic acid body wash exact R4.50 (est R4.08, 1 purchase plus Shopping purchases), niacinamide body lotion exact/phrase R6.50 (est R6.47; phrase drove 4 purchases at 18% impression share), lactic acid body wash R4.00 (1 purchase).
- Unproven high-volume terms are stepped: salicylic acid body wash exact R5.00 (est R6.47; 15 clicks, 0 purchases at R3), anti pigmentation deodorant R5.00 (est R9.09), niacinamide serum R4.00 (Semrush CPC about R6 equivalent; 6,600/month means this could absorb the C4 budget in hours at first-page bids).
- Low-evidence tests are capped at R3.00 to R3.50 with the stop rule in the runbook.
- Mandelic stays at R3.00: 40 clicks and no purchase in 28 days, and only the R545 fragrance-free variant is in stock.

Switch to Maximise conversions (no target) per campaign once it has 15 or more purchases in a 30-day window; add a target CPA of R130 only after 30 purchases.

## 4. Ad copy

Each ad group has one responsive search ad with 14 or 15 headlines (all 30 characters or fewer) and 4 descriptions (90 or fewer), validated by script. Copy is built from three verified sources: feed titles and prices (sizes, variants, ingredients, R-prices), existing approved ad text in the account (for example "No Bleaching. No Burning." and "Made For Melanin-Rich Skin" from approved ad 798619932669), and the product-campaign descriptions already serving. Rules applied by the validator: no delivery, shipping, courier or pickup claims; no "treat", "cure", "clinically", "dermatologist" or "guarantee"; no whitening, lightening or bleaching language; no "best" or "#1". Prices are feed prices and must match the live page at launch (live pages could not be fetched from this session).

The existing Brand Search ad carries "Nationwide Delivery 24-72hrs" and "dermatologist.-tested" (with the typo). Neither claim is verified in any source available here; the executor should confirm both with the client or remove them.

## 5. Negatives

Five shared lists (03_negative_keywords.csv, import file 06b): brand routing ("pastry" variants, applied to C1 to C4 only, never to Brand Search or Shopping), competitor brands seen in search terms and Semrush lists, retailers, informational and off-target modifiers (recipe, cake, bakery, meaning, causes, how to make, laser, chemical peel, wholesale, jobs, men, kids, pregnancy), and positioning/stock (whitening, lightening, bleach, and "hand cream" while the Anti-Pigment Hand Cream SPF30 is out of stock). Campaign-level negatives keep face intent in C4 and body intent in C1 to C3. The old 257-term shared list in the account stays unattached, as the audit recommended, because it contains converting terms.

## 6. Shopping

Standard Shopping rather than Performance Max: the audit showed about 40% of Pastry_PMax's reportable search clicks were brand queries that Brand Search now captures at lower CPC, and PMax offers no query-level control. Product groups are by product_type with bids of R3.00 (body wash, body lotion), R2.50 (gift set, deodorant, body cream), R2.00 and R1.50 for the rest; "Everything else" excluded. Two feed fixes are prerequisites (image overlays on the body oil and the hand cream).

## 7. What to expect and how to judge it

At the observed R2.85 average CPC the Search budgets buy roughly 165 clicks/day; at the observed 2.5% click-to-purchase rate that is about 4 purchases/day, R113 CPA, before any lift from first-page positions and dedicated ads. These are extrapolations from 358 clicks and 9 purchases, so the first 14 days are a measurement period, not a forecast. Decision rules, stop rules and the weekly review are in the runbook.

## 8. Limits

Live pages, prices and the hyperpigmentation collection URL could not be fetched (session egress blocked); Semrush credits ran out after five keyword reports, so demand for some test terms is marked "no Semrush ZA row"; the connector is read-only, so nothing was created; Google policy review of copy happens at upload. Full list in 09_validation_and_limits.md.
