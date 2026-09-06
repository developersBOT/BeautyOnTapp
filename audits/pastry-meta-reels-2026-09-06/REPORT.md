# Pastry Skincare – Meta Ads and Reels investigation

Prepared for PNCapital. Investigation only: **no account, campaign, budget, targeting, placement, Pixel, catalogue, tracking, website or social-profile change was made.** Capture window 2026-09-06 10:26–10:45 UTC (12:26–12:45 Africa/Johannesburg). Reporting periods use complete account days in Africa/Johannesburg; today (2026-09-06) is shown separately as partial.

## 1. Commercial verdict and the three strongest opportunities

**Verdict.** The account is buying purchases efficiently on Meta's own attribution and got more efficient in the last 28 days (CPA ZAR82.84 vs ZAR93.16 in the prior 28 days, attributed ROAS 10.1 vs 9.1), but the growth structure is fragile: the best campaign is three catalogue ads running retargeting copy to cold audiences, the highest-spend video ad points at a product the catalogue marks out of stock, the international test cannot deliver because its geography excludes the only country it includes, and more than half of all pixel purchases are being credited to Meta with no Shopify or incrementality cross-check. Meta ROAS in this report is diagnostic, never profit.

Three strongest evidence-backed opportunities (details in sections 6–8):

1. **Fix availability behind the top video ad (F02/F13, T02).** Ad 120247999501100393 spent ZAR5,023 in 28 days at CPA ZAR139.51 and add-to-cart per landing view 0.145 (account 0.232). Its product, Anti-Pigment Hand Cream SPF30, is `out of stock` in catalogue 2555447634850889. Confirm stock in Shopify; the ad is otherwise the account's best attention-getter (outbound CTR 2.86%).
2. **Expand the efficient routine Reels into broad (F19, T04/T05).** Body-acne POV (CPA ZAR74, 27 purchases), dry brushing (ZAR87, 22) and the stretch-mark recut (ZAR84, 11, outbound CTR 3.74%) sit only in the social-signals ad set. Adding them, unchanged, to the broad A1 ad set is the lowest-risk additive test available.
3. **Make the DPA copy true for cold audiences (F03, T01).** The three catalogue ads (ZAR22,384, 341 purchases, CPA ZAR65.64 in 28 days) still say "Ready to restock?", "Complete your order" and "Come back" while targeting broad South Africa excluding purchasers. An acquisition-true text variant, run alongside, protects the account's best cost per purchase and removes an untrue claim.

Configuration repair with no spend at risk: the INTL ad sets (F01) include ZA and exclude ZA, so they have delivered 0 impressions since 2026-08-28.

## 2. Source, access and coverage register

Full register: `evidence/derived/source_access_register.csv`.

| Source | Result |
|---|---|
| Meta Ads connector, ad account **2972238613000896 "Pastry ads"**, business **3929095220517711 Pastry Skincare**, ZAR, Africa/Johannesburg | Accessible. 21 campaigns, 38 ad sets, 95 ads, 76 creatives; all responses complete (no pagination cursors returned). |
| Page **116534118031737 Pastry Skincare** | Only Page owned by the business. Also promoted under this account: Page 514287578739996 Beauty on TApp (no Pastry ads found using it). |
| Instagram professional account | **Not exposed** to the connector (`ads_get_ig_accounts` returned an empty list). Organic Reel insights, media lists and comments are NOT ACCESSIBLE. |
| Pixel **203047029058550** "Pastry Skincare - Meta Pixel" | Accessible: event volumes (Aug 6–Sep 6), match quality, catalogue match rate. Events Manager event detail (event_id, dedup) NOT ACCESSIBLE. |
| Catalogues **2555447634850889** (used by ads), 875733698715725, 1514822569170254 | Accessible. |
| Change history Jun 1–Sep 6 | 1,205 unique events across three windows. |
| Ad Library, Page 116534118031737 | 28 active ads, all Pastry Page; no partnership ads detectable. |
| Meta Help Center (definitions) | Retrieved via connector: 3-second plays (help/743427195703387), video metric calculation (help/1868286323447328), safe zone (help/980593475366490), learning phase (help/112167992830700, help/269269737396981). |
| Shopify MCP | **Token expired; NOT ACCESSIBLE.** Orders, revenue, stock and checkout are NOT VERIFIED. |
| pastryskincare.co.za, instagram.com, facebook.com, developers.facebook.com, fbcdn video CDN | **Blocked by the environment's network egress policy (CONNECT 403).** No destination page, Reel permalink or video file could be opened. |
| PNCapital/Pastry instructions, Business Facts, prior Pastry Meta audits | NOT IN SOURCE in this repository or synced skills; margins, budgets and affordability are NOT VERIFIED. Skills `beautyontapp-research-mode` and `beautyontapp-anti-fabrication` were read and applied. |

**Videos watched: 0 of 62 video creatives.** Nine ads were inspected as a single static preview frame each (Instagram Reels format) via the connector; two catalogue-ad previews returned no image. Every creative judgement below that goes beyond caption text, the preview frame and delivery metrics is marked as such. Timestamped hook/demonstration/audio reviews were not possible and are not claimed.

## 3. Account baseline (Meta attribution)

Purchase definition used everywhere: `offsite_conversion.fb_pixel_purchase` (website purchases). In every window checked it equals `omni_purchase`; `onsite_conversion.purchase` is null, so nothing is summed across purchase types. Ad-set attribution setting is 7-day click / 1-day view (older sets also 1-day engaged view). Reported by impression date; the L7 and L28 windows end within 7 days of capture, so late conversions can still accrue. Ratios are recomputed from matching numerators and denominators. Source: `evidence/derived/account_baseline_periods.csv`.

| Period (inclusive, Johannesburg) | Spend ZAR | Impr. | Reach | Freq. | CPM | Outbound CTR | Cost/outbound click | LPV | ATC | IC | Purchases | Value ZAR | CPA | Attr. ROAS |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| L7 Aug 30–Sep 5 | 15,725 | 328,400 | 102,587 | 3.20 | 47.88 | 2.10% | 2.28 | 6,133 | 1,443 | 638 | 175 | 143,237 | 89.86 | 9.11 |
| P7 Aug 23–29 | 11,657 | 234,556 | 70,077 | 3.35 | 49.70 | 2.60% | 1.91 | 5,534 | 1,264 | 587 | 157 | 133,533 | 74.25 | 11.46 |
| L28 Aug 9–Sep 5 | 47,054 | 1,011,709 | 169,593 | 5.97 | 46.51 | 2.36% | 1.97 | 21,479 | 4,989 | 2,249 | 568 | 475,891 | 82.84 | 10.11 |
| P28 Jul 12–Aug 8 | 54,590 | 1,180,512 | 154,808 | 7.63 | 46.24 | 1.90% | 2.44 | 19,321 | 4,707 | 2,415 | 586 | 494,150 | 93.16 | 9.05 |
| L90 Jun 8–Sep 5 | 192,591 | 4,050,814 | 468,855 | 8.64 | 47.54 | 1.82% | 2.61 | 64,692 | 18,293 | 8,008 | 2,085 | 1,780,392 | 92.37 | 9.24 |
| P90 Mar 10–Jun 7 | 85,491 | 2,527,816 | 359,942 | 7.02 | 33.82 | 1.85% | 1.83 | 41,236 | 8,236 | 2,708 | 1,066 | 982,116 | 80.20 | 11.49 |
| Today partial Sep 6 | 686 | 13,750 | 10,050 | n/a | 49.90 | 2.07% | 2.42 | 233 | 61 | 26 | 4 | 2,260 | 171.52 | 3.29 |

Definitions: outbound CTR = outbound clicks ÷ impressions; cost per outbound click = spend ÷ outbound clicks; LPV = website landing page views; ATC/IC = adds to cart / checkouts initiated (omni). Reach and frequency are the API's own period values, never summed from daily rows.

Funnel ratios (diagnostic only, not a proven journey): L28 LPV per outbound click 0.90; ATC per LPV 0.232; IC per ATC 0.451; purchases per IC 0.253; purchases per LPV 2.6%. P28: 0.86 / 0.244 / 0.513 / 0.243 / 3.0%.

**Reconciliation.** Ad-level rows for L28 sum exactly to the account row (spend 47,054.41; purchases 568; value 475,891.25). Campaign rows: DPA 22,384 / 341 purchases (CPA 65.64, ROAS 12.44); WINNERS 15,845 / 155 (102.22, 8.69); TEST_REELS_ZA 6,405 / 53 (120.85, 6.81); Main_Revenue residual 1,677 / 13; TEST_Creative_Broad 744 / 6. Only the ZA country row exists for L28; device: mobile app 99.4% of spend.

**Trend reading.** L28 improved on P28 on every efficiency measure while spend fell 14% and frequency fell from 7.6 to 6.0. The 90-day scale-up (spend +125% vs P90) came with CPM rising from ZAR33.82 to ZAR47.54 and CPA from ZAR80 to ZAR92; that is auction cost at scale, not evidence of creative fatigue. Weekly series (`evidence/raw/account_daily.json`) shows one anomaly: ZAR0 spend on 2026-08-12 between a manual pause on 08-11 and re-enable on 08-13 of the DPA campaign.

**Attribution share.** Pixel Purchase events in the same span number roughly 1,025 (Pacific-bucketed daily stats), so Meta claims about 55% of all store purchases. Without Shopify, MER and incrementality are NOT VERIFIED (F04).

## 4. Current account structure

Full inventories: `campaign_inventory.csv`, `adset_inventory.csv`, `ad_inventory.csv`, `adsets_table.txt`.

Delivering (ACTIVE, active delivery):

| Campaign | Ad sets (daily budget) | Optimisation | Audience | Placements | Learning |
|---|---|---|---|---|---|
| PASTRY_DPA_Broad_Acquisition 120239423593780393 (renamed 2026-08-05 from PASTRY_Retargeting_DPA) | Acq_1 120239423593800393 (ZAR250), Acq_2 120239424374890393 (ZAR250), Acq_3 120239424374900393 (ZAR300) | Purchase, pixel 203047029058550, product set 1689686838523869 "All Products" | ZA 18–65, Advantage+ audience, exclude "Pastry \| Purchasers \| 180d \| REBUILD_20260805"; CN excluded | Acq_1 manual Instagram-only mobile; Acq_2/3 Advantage+ | SUCCESS |
| PASTRY_WINNERS_2AUD_APR_TO_DATE_20260814 120247983147880393 | A1 broad excl. engagers+purchasers 120247983149820393 (ZAR350); A2 IG/FB engagers 30d excl. purchasers 120247983150600393 (ZAR350) | Purchase | ZA 18–65, interest stack on A1 | Advantage+ | SUCCESS |
| PASTRY_TEST_REELS_ZA_W1_W3_ABO_20260828 120248284911800393 | W1 full-signal 120248284913190393, W2 social30 120248284914700393, W3 shopping-intent 120248284917990393 (ZAR250 each, 5 ads each) | Purchase | ZA 18–65 | Advantage+ | LEARNING (14–23 conversions in 9 days) |
| PASTRY_TEST_REELS_INTL_W4_W6_WORLDWIDE_EXCL_ZA_ABO_20260828 120248284912210393 | W4/W5/W6 (ZAR250 each, 5 ads each) | Purchase | **Included ZA, excluded ZA+CN → empty** | Advantage+ | FAIL, 0 impressions |

Paused with history in the audited periods: PASTRY_Main_Revenue (ZAR101,008 lifetime window; ad set AS1_Hyperpigmentation now `error: all_ads_in_error`), main (ZAR40,897), PASTRY_TEST_Creative_Broad_20260805 (ZAR1,670), PASTRY_Creative_Testing (ZAR4,899), four Instagram boosts Jun 16–30 (ZAR10,629, profile-visit optimisation), six PASTRY_JTD_REELS_ZA_2AUD_20260821 campaigns (created and paused the same day, no spend).

Delivery errors (`ads_get_errors`, verbatim): ad 120239422780760393 "Instagram media not found: The Instagram media 17947556741721787 does not correspond to any existing media"; ad 120239422422240393 same for 18435405853187644; ad 120239422499600393 "No Valid Formats: Your ad's creative is incompatible with the selected placements."

Bid strategy is "Highest volume" (lowest cost, no cap) everywhere a value is exposed; no cost caps, no schedules, no spend caps, no custom conversions, no pixel event rules. 73 custom audiences exist; 39 lookalikes are INACTIVE.

## 5. Measurement and catalogue verification

- **Pixel 203047029058550** is active, first-party cookies enabled, browser last fired 2026-09-06 03:19 PDT, server 03:10 PDT. Aug 6–Sep 6 volumes: PageView 238,961; ViewContent 102,373; AddToCart 29,265; InitiateCheckout 12,945; Purchase 1,104; NewCustomerPurchase 796; ReturningCustomerPurchase 306; Lead 95; Contact 143. Source split: browser 283,403 vs server 178,276 (all events). Purchase EMQ 9.1 (phone, name, zip 100% coverage; fbc 61%). Match quality for AddToCart/ViewContent 6.7–6.8. Event ID deduplication, value/currency payloads and the app writing the events (Analyzify per current instructions) are **NOT VERIFIED**: the connector exposes no event-level detail.
- **Catalogue 2555447634850889** (47 items, 50 sets) is the one linked to the pixel and used by the DPA ads. Data source: `batch_api` "App 2125102444404598" (identity NOT VERIFIED; no partner-integration record, no file/URL feeds). `retailer_id` is the Shopify **variant** ID and `retailer_product_group_id` the Shopify **product** ID; pixel content IDs match this catalogue at 100% for AddToCart, Purchase and ViewContent over 28 days. This is internally consistent but deviates from the stated governance (product ID). Two other catalogues exist in the business (26 and 52 products) and are unused by ads.
- **Item eligibility:** 4 items out of stock (Anti-Pigment Hand Cream SPF30, Mandelic Body Wash Blackcurrant, HA Body Lotion Vanilla, HA Hand Cream coconut) are excluded from dynamic ads; 47 items have a single image. Prices ZAR205–999, no sale prices, all `published`.
- **Destinations:** catalogue URLs use `?variant=<id>&utm_medium=cpc&utm_source=facebook&utm_campaign=Facebook%20Shopping&country=ZA`. Video ads are "use existing post" Reels; their link, redirects, mobile buying path and offer consistency are **NOT VERIFIED** (storefront blocked). Conversion domain on the August ads is `pastryskincare.co.za`.

Tracking does not lead the action list: no proven defect materially changes the decisions above.

## 6. Findings register

24 findings with severity and confidence: `evidence/derived/findings_register.csv` / `.json`. Ranked summary (after full coverage):

| ID | Finding | Severity | Confidence |
|---|---|---|---|
| F01 | INTL ad sets include and exclude ZA; 0 delivery, learning FAIL | High (test) / Low (spend) | High |
| F02 | Top video ad promotes out-of-stock hero product; ATC/LPV 0.145; CPA ZAR139.51 | High | Medium-High |
| F03 | DPA ads run retargeting copy to broad audiences | Medium | High |
| F04 | Meta claims ~55% of pixel purchases; no Shopify/incrementality check | Medium | High/Low |
| F05 | Historic top ad set broken by deleted Instagram media | Medium | High |
| F07 | Burn-mark before/after + "bleach" screenshot in best acquisition recut | Medium | Medium |
| F09 | Reels placements convert worse per rand than feed (mix-confounded) | Medium | Medium |
| F13 | 4 out-of-stock items, 47 single-image items in the DPA set | Medium | High |
| F15 | W1–W3 tests unlikely to exit learning at current volumes | Low-Medium | High |
| F16 | Overlapping automation and manual edits; Aug 11–13 pause gap | Low-Medium | High |
| F11 | Three catalogues, unidentified feed app | Low-Medium | High/Low |
| F08 | Time-bound before/after claims in non-delivering creatives | Low-Medium | Medium |
| F06 | Boosts optimised for profile visits, no purchase evidence | Low | High |
| F10 | DPA Acq_1 manual IG-only placements, highest CPM/CPA of the three | Low | Medium |
| F12 | Variant-ID keyed pixel vs product-ID governance | Low | High |
| F14 | Pixel quality strong; dedup unverified | Low | Medium |
| F17 | Reels text overlays in lower third of frame | Low | Low-Medium |
| F20 | Underarm/sweat ad clicks well, converts poorly (n=9) | Low | Low-Medium |
| F23 | INTL copy states DHL delivery terms, unverified | Low | Medium |
| F18, F19, F24 | Opportunities and trend context (info) | Info | Medium/High |
| F21, F22 | Coverage gaps: organic Instagram, Shopify/website | Gap | High |

## 7. Reels and creative inventory and scorecard

Inventory of all 76 creatives with post, video and Instagram media IDs and coverage: `evidence/derived/reels_creative_asset_inventory.csv`. Per-ad scorecards for L7/L28/P28/L90 with hook, hold and funnel ratios: `ad_scorecard_periods.csv`. Concept aggregation (same Instagram media reused across ads counted once): `concept_aggregation_L90.csv`. Ad-set hook rates from 3-second plays: `adset_video_hook_hold_L28.csv`.

Metric definitions (Meta Help Center, retrieved 2026-09-06): video plays count each start after an impression, excluding replays, and are not unique people; 3-second plays count 3 seconds or 97% of a shorter video; ThruPlay is completion or at least 15 seconds, so for videos under 15 seconds ThruPlay equals completion and for longer videos it does not; 25/50/75/100% are milestone metrics that can include skipping. Formulas used: hook (ad set) = 3-second plays ÷ video plays; hold = ThruPlay ÷ 3-second plays; ad-level hold proxy = ThruPlay ÷ video plays; completion = plays at 100% ÷ video plays. Retention curves and durations are NOT IN SOURCE. Organic results for every Reel: NOT ACCESSIBLE.

Ad-set hook and hold, L28: A1 broad 0.404 / 0.304; A2 social 0.380 / 0.344; W3 shopping 0.375 / 0.425; W1 0.312 / 0.368; W2 0.285 / 0.362; legacy AS2 0.303 / 0.224.

Scorecard of the delivering video concepts (L28 unless stated; measured results first, subjective notes marked *observation*):

| Concept (IG media) | Ads | Spend ZAR | Purch. | CPA | ROAS | Outbound CTR | ATC/LPV | ThruPlay/play | p100/play | Saves | Diagnosis (evidence-qualified) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Anti-Pigment Hand Cream testimonial (17892363399551598) | 120247999501100393 | 5,023 | 36 | 139.51 | 4.50 | 2.86% | 0.145 | 0.121 | 0.035 | 41 | Strong attention and click intent, weak cart conversion; product out of stock in catalogue (F02). *Observation from frame:* creator to camera, product held at face height, bold white text lower-middle. |
| Dark underarm ingredients (18328649092285943) | 120247999503210393 | 3,531 | 33 | 107.00 | 8.77 | 1.77% | 0.287 | 0.111 | 0.067 | 28 | Best p25 hold among top spenders (0.27); average click; converts at account rate. *Frame:* boxed product in hands, on-screen caption. |
| Salicylic + Vitamin C EXACT (18089893955557030) | 120247999500050393 | 1,975 | 24 | 82.29 | 13.49 | 2.06% | 0.206 | 0.105 | 0.033 | 66 | Efficient on 24 purchases; highest saves; claim risk F07. *Frame:* before/after scar image plus DM screenshot. |
| Dry brushing (18007465448764457) | 120247999504000393 | 1,910 | 22 | 86.82 | 11.38 | 2.65% | 0.296 | 0.165 | 0.074 | 32 | Efficient, high ATC/LPV, good hold; under-exposed (A2 only). *Frame:* title card and brush, text top-centre (safe zone). |
| Inner-thigh routine (18362479630212526) | 120248284932400393 | 1,675 | 21 | 79.75 | 10.73 | 2.05% | 0.335 | 0.105 | 0.025 | 22 | Highest ATC/LPV of the tests; in learning. *Frame:* in-store, two products, text lower third. |
| Underarm pigmentation + sweat (18348472762247625) | 120248284925050393 | 1,570 | 9 | 174.41 | 3.73 | 1.90% | 0.192 | 0.111 | 0.041 | 22 | Clicks and page loads fine, cart weak; small n (F20). |
| Body-acne POV (17894570910595157) | 120247999503610393 + W3 | 2,002 (3 ads) | 27 | 74.16 | 10.84 | 2.46% | 0.229 | 0.144 | 0.142 | 23 | Efficient, high completion (short video); under-exposed. *Frame:* three bottles labelled by acid, sound-off readable. |
| Body-specific serum / Overnight Balm (18101142794223347) | 120248284944650393 | 1,353 | 9 | 150.37 | 6.46 | 2.08% | 0.286 | 0.187 | 0.042 | 21 | Best hold of the tests, weak purchase per checkout (0.25); destination NOT VERIFIED. |
| Stretch-mark recut (18111724246804433) | 120247999502800393 | 928 | 11 | 84.39 | 12.40 | 3.74% | 0.237 | 0.139 | 0.044 | 37 | Highest CTR in account; small n; under-exposed. |
| Five-years evergreen (17951195124249902) | 120247999500510393 (paused) | 862 | 6 | 143.63 | 7.15 | 2.43% | 0.185 | 0.152 | 0.147 | 4 | Brand film; low purchase intent; paused. |
| DPA catalogue ads (3) | 3 ads | 22,384 | 341 | 65.64 | 12.44 | 2.49% | 0.245 | n/a | n/a | 68 | Most efficient; retargeting copy to cold audiences (F03); frequency 3.5–3.8 per ad set in 28 days. |

Historic concepts in L90 (`concept_aggregation_L90.csv`): "new… Pastry Premium" 258 purchases at ROAS 10.3 (now broken, F05); festive duo kits 138 at ROAS 6.7; Premium body wash in-store first impressions 113 at ROAS 7.1; Salicylic + Vitamin C original post 64 at ROAS 4.2 (CPA ZAR197, mostly in the retargeting-heavy AS1 set, so not comparable with the recut). Very high ROAS rows in the "AS2 test." ad set (e.g. 48.3 on 13 purchases) came from a union of website and purchaser custom audiences and are not creative evidence.

Comments: counts only (hand cream 20, dark underarm 5, body serum 6 in L28). Comment text, customer questions and objections are NOT ACCESSIBLE and were not reviewed.

Rights and claims: creator attributions (e.g. "@zinzilejiyane") and music are NOT VERIFIED for usage rights or partnership-ad eligibility; no partnership ads were found in the Ad Library query.

## 8. Ranked lists

**Preserve (keep running, do not edit in place):** DPA Acq_1/2/3 catalogue ads; A2 social-signals ad set; A1 broad ad set as the expansion vehicle; the Salicylic + Vitamin C EXACT recut pending compliance review.

**Repair / recut:** Hand cream ad destination and stock (T02); DPA primary text as an additive variant (T01); compliance-safe recut of Salicylic + Vitamin C (T03); INTL geo configuration (P01); re-upload of the deleted "new… Pastry Premium" source video as an account asset if it exists (F05).

**Test / grow:** body-acne POV, dry brushing and stretch-mark recut into A1 broad (T04, T05); Reels-native 9:16 cut with safe-zone subtitles (T08).

**Evidence needed before acting:** organic Reels performance (T06), Shopify order truth and stock (F22), Events Manager dedup detail (F14), comment text review (F02), feed app identity (F11), affordability and contribution inputs (NOT VERIFIED throughout).

No ad is labelled a winner or loser on fewer than 30 purchases.

## 9. Creative test briefs and account proposals

Nine briefs with source asset IDs, hypothesis, audience, product, hook and shot sequence, CTA, single variable, success and guardrail metrics, minimum decision evidence and dependencies: `evidence/derived/test_plan.csv` / `test_plan.json`. All scripts are drafts; every new concept is untested; no test budget is invented and no uplift is promised. Copy drafts are English only, contain no delivery, shipping, pickup or collection wording, and use only the black heart where an emoji is suggested.

Account improvement proposals with current and proposed settings, evidence, validation and rollback: `evidence/derived/account_improvement_proposals.csv` (P01–P09). They are proposals only. None turns an ad-level finding into an ad-set or account-level action: P03 is scoped to the single hand-cream ad and is conditional on a Shopify stock check.

## 10. Validation summary, unresolved limits and next measurement

Audit 1 (evidence, coverage, calculations, scope): every metric in sections 3, 6 and 7 traces to a file in `evidence/` with the query and capture time; ad-level L28 sums reconcile to the account row; reach and frequency are taken from period-level API rows only; purchase type is single and documented; breakdown queries are reported separately and never added together; no Google or Shopify figures are combined with Meta; scope is Pastry only (BeautyOnTApp account 1615943869585748 and its catalogue were not queried beyond discovery).

Audit 2 (identifiers, dates, URLs, formatting): IDs were copied from connector output; dates are inclusive Johannesburg days; pixel daily buckets are the connector's Pacific-time rows and are labelled as such; the only URLs cited are catalogue product URLs and Meta Help Center article IDs; currency is ZAR throughout.

Unresolved limits: no video was played (durations, audio, pacing, subtitles and end cards NOT VERIFIED); organic Reel metrics NOT ACCESSIBLE; destination pages, checkout path and stock NOT VERIFIED; Shopify NOT ACCESSIBLE; event deduplication NOT VERIFIED; affordability, margin and contribution inputs NOT VERIFIED; prior Pastry audits NOT IN SOURCE.

Next measurement to establish purchase and contribution impact: (1) re-authorise Shopify and reconcile L28 orders and revenue against the 568 attributed purchases and ~1,025 pixel purchases; (2) export Instagram insights for Reels published Jun 8–Sep 5 (lifetime and period values kept separate); (3) run T01 and T04 as concurrent single-variable tests to at least 50 and 30 purchases respectively; (4) decide on a holdout or geo-based incrementality read before any budget scaling.

**Record: no live changes were made during this investigation.**
