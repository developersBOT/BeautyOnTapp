# Pastry Skincare Meta Ads and Reels: findings and recommendations

Read-only investigation of ad account 2972238613000896 (Pastry ads, business 3929095220517711, ZAR, Africa/Johannesburg), Pixel 203047029058550, the Pastry catalogue and the Shopify store pastryskincare.co.za. Evidence captured 6 September 2026, 12:26 to 12:59 SAST. No account, campaign, budget, catalogue, Pixel or social change was made. Supporting tables: `evidence/derived/`.

## Verdict

Meta is buying purchases efficiently and got more efficient in the last 28 days, but the structure producing those purchases is fragile. The best campaign is three catalogue ads running retargeting copy to cold audiences. The biggest video ad has been sending clicks to a sold-out product since 25 August. The international test cannot deliver because it excludes the only country it includes. Meta claims 56% of all store orders, which no incrementality test has checked. Blended MER on Shopify net sales was 14.5 in the last 28 days against 11.7 in the prior 28, so the account is not in trouble; the opportunity is to fix three avoidable leaks and expand the Reels that already convert, without adding budget until an incrementality read exists.

| 9 Aug – 5 Sep 2026 | Value |
|---|---|
| Shopify orders / net sales | 1,010 / ZAR819,509 |
| Meta spend / Google Ads spend | ZAR47,054 / ZAR9,381 |
| Meta-attributed purchases (7d click / 1d view) | 568 (56% of orders) |
| Instagram + Facebook last-touch orders (Shopify) | 439 (43%) |
| Meta cost per purchase | ZAR82.84 (prior 28 days ZAR93.16) |
| MER (net sales ÷ Meta + Google spend) | 14.5 (prior 11.7) |

## 1. Account today

| Campaign | Structure | Spend L28 | Purchases | CPA | Attr. ROAS | State |
|---|---|---|---|---|---|---|
| PASTRY_DPA_Broad_Acquisition | 3 ad sets, one catalogue ad each, broad ZA excl. 180-day purchasers | R22,384 | 341 | R65.64 | 12.4 | Delivering |
| PASTRY_WINNERS_2AUD | A1 broad new, A2 social engagers; 9 Reel ads | R15,845 | 155 | R102.22 | 8.7 | Delivering |
| PASTRY_TEST_REELS_ZA W1–W3 | 3 ad sets at R250/day, 5 Reels each, from 28 Aug | R6,405 | 53 | R120.85 | 6.8 | Learning |
| PASTRY_TEST_REELS_INTL W4–W6 | 3 ad sets at R250/day, 15 Reels, from 28 Aug | R0 | 0 | – | – | Cannot deliver |

Spend fell 14% against the prior 28 days while purchases held (568 vs 586); CPA fell 11%; outbound CTR rose from 1.90% to 2.36%; frequency fell from 7.6 to 6.0. Over 90 days spend more than doubled versus March to June and CPM rose from R33.82 to R47.54: auction cost at scale, not creative fatigue. Shopify recorded 492 orders on 26 June (normal day 20 to 70) and Meta attributed 489 purchases to that week; comparisons including 26 June describe an event, not a run rate.

## 2. Shopify vs Meta

| Window | Shopify orders | Net sales | Meta purchases | Meta share | IG+FB last-touch | Meta + Google spend | MER |
|---|---|---|---|---|---|---|---|
| 30 Aug – 5 Sep | 297 | R239,996 | 175 | 59% | 137 (46%) | R18,583 | 12.9 |
| 23 – 29 Aug | 284 | R233,919 | 157 | 55% | – | R13,604 | 17.2 |
| 9 Aug – 5 Sep | 1,010 | R819,509 | 568 | 56% | 439 (43%) | R56,436 | 14.5 |
| 12 Jul – 8 Aug | 1,066 | R874,686 | 586 | 55% | 381 (36%) | R74,693 | 11.7 |
| 8 Jun – 5 Sep | 3,574 | R2,951,435 | 2,085 | 58% | – | R249,866 | 11.8 |

Meta claims about 30% more orders than Shopify last-touch assigns to Instagram and Facebook. Neither is incrementality. Google spend halved between the two 28-day windows, Meta spend fell 14%, net sales fell 6%: consistent with channel overlap, not proof of it. Instagram-referred sessions completed checkout at 2.72%, Facebook-referred at 1.37%, Google at 3.01%; Facebook Feed is the largest placement by spend (R15,434).

## 3. Findings that change a decision

- **F02 (High). The biggest video ad has been sending clicks to a sold-out product since 25 August.** Ad 120247999501100393 (Anti-Pigment Hand Cream SPF30) spent R5,023 in 28 days. Shopify shows zero inventory and not available for sale since 25 August after 138 orders earlier in the window. Before stock-out: ATC/LPV 0.219, CPA R102. After: ATC/LPV 0.100, CPA R182, R3,090 spent. Evidence: hand_cream_stockout_daily.csv.
- **F01 (High). The international test includes ZA and excludes ZA.** All three INTL ad sets have geo_locations [ZA] and excluded_geo_locations [ZA, CN]; learning FAIL, zero impressions since 28 August; R750/day configured, unspent. DHL delivery wording in the copy is unverified (DHL Express Commerce app is installed).
- **F03 (Medium). The most efficient ads say "restock" and "complete your order" to people who have never visited.** The retargeting ad sets were retargeted to broad ZA on 5 August; the three catalogue creatives were not changed. CPA R61.57 to R72.75 each.
- **F07 and F27 (Medium). Claim exposure.** The Salicylic + Vitamin C recut (CPA R82, 24 purchases) opens on "FADE YOUR BURN MARK WITH THIS COMBO", a before/after scar photo and a screenshot containing "iBleach". The inner-thigh Reel reads "WILL CLEAR YOUR DARK INNER THIGHS"; a shelf card in the Premium body wash Reel reads "Clears hyperpigmentation".
- **F05 (Medium). The historic top ad set (634 purchases lifetime) is broken because its source Instagram posts were deleted.**
- **F25 (Medium). Facebook traffic converts at half the Instagram rate** (1.37% vs 2.72% checkout per session). Reels placements convert worse per rand than feed (FB Reels ROAS 4.8, IG Reels 7.7, IG Feed 11.6), partly because catalogue ads serve mainly in feed and stories.
- **F15 and F16 (Low to medium).** W1 to W3 have 14 to 23 conversions in nine days against about 50 per week needed; spend concentrates in one or two of five ads per set. 1,205 change events since 1 June from an automation app, Power Editor and the iOS app, including a manual pause on 11 August that left spend at R0 on 12 August.
- **F14 and F12 (No action). Tracking is healthy.** Purchase match quality 9.1; catalogue match 100%; Analyzify, Simprosys and the Facebook & Instagram channel present. Content IDs are variant IDs, internally consistent. Dedup not inspectable.

## 4. Reels

All paid video is repurposed organic Reels. 31 ads were inspected as single preview frames; none could be played. Organic metrics are not accessible.

| Concept | Spend L28 | Purch. | CPA | CTR | ATC/LPV | ThruPlay/play | Read |
|---|---|---|---|---|---|---|---|
| Hand cream testimonial | R5,023 | 36 | R139.51 | 2.86% | 0.145 | 0.12 | Best attention, sold-out destination |
| Dark underarm ingredients | R3,531 | 33 | R107.00 | 1.77% | 0.287 | 0.11 | Holds attention, average click |
| Salicylic + Vitamin C recut | R1,975 | 24 | R82.29 | 2.06% | 0.206 | 0.11 | Efficient; claim risk |
| Dry brushing routine | R1,910 | 22 | R86.82 | 2.65% | 0.296 | 0.17 | Efficient; only in A2 |
| Inner-thigh routine | R1,675 | 21 | R79.75 | 2.05% | 0.335 | 0.11 | Highest ATC/LPV; learning |
| Body-acne POV (3 ads) | R2,002 | 27 | R74.16 | 2.46% | 0.229 | 0.14 | Efficient; only in A2 and W3 |
| Stretch-mark recut | R928 | 11 | R84.39 | 3.74% | 0.237 | 0.14 | Highest CTR; small n |
| Underarm pigmentation + sweat | R1,570 | 9 | R174.41 | 1.90% | 0.192 | 0.11 | Clicks, does not cart |
| Catalogue ads (3) | R22,384 | 341 | R65.64 | 2.49% | 0.245 | – | Most efficient; wrong copy |

Text overlays sit in the lower third in about half the Reels, where the Reels caption and CTA can cover them; the concepts with text at the top or centre are also the ones with better hold (frame observation, not a measured effect). Nothing under 30 purchases is labelled a winner or loser.

## 5. Recommendations, in order

1. **Restock the hand cream, or reroute its ad until stock returns.** Pause only ad 120247999501100393 or point it at the in-stock Hyaluronic Acid Hand Cream page. Success signal: ATC/LPV back above 0.20 once stock is live.
2. **Fix or pause the international ad sets** (120248284921000393, 120248284920020393, 120248284918900393). Set the intended countries, keep ZA and CN excluded, verify DHL wording first.
3. **Compliance review before more spend on the before/after creatives.** Keep the testimonial and product-pair destination; drop the scar photo and the "iBleach" screenshot; replace "will clear" and "clears". Run the safe recut against the original in the same ad set to 50 purchases each.
4. **Add acquisition-true copy to the three catalogue ads** as new ads, incumbents live. Draft: "Body care made for melanin-rich skin. Proudly South African. Shop the routine that matches your concern." Judge on purchases per landing view and CPA after 50 purchases each.
5. **Move body-acne POV, dry brushing and the stretch-mark recut into the broad A1 ad set (120247983149820393), unchanged.** Audience is the only variable. Decide at 30 purchases each or 14 days; guardrail A1 frequency under 2.0.
6. **Leave W1 to W3 alone until day 14, then consolidate** the spending ads into one ad set rather than adding budget.
7. **Manage to MER and set up an incrementality read.** Add ad-level placement reporting for two weeks to separate the Facebook conversion gap into creative, placement or browser causes; then run a holdout or geo test before any budget increase, with Shopify net sales as the outcome.

Do not: cut Reels placements on the placement table alone; scale on Meta ROAS; touch Pixel, catalogue or app configuration; turn ad-level findings into ad-set or account-level actions.

## 6. Not verified

Videos were not played (storefront, Instagram, Facebook and the video CDN are blocked by this environment). Organic Reel metrics are not accessible. Also unverified: on-page checkout behaviour, Pixel browser/server dedup, margins and affordability, the app writing the catalogue, prior Pastry audits. Verified this session: Shopify orders, net sales, referrers, sessions, product sales and stock; Google Ads daily cost; all Meta figures.
