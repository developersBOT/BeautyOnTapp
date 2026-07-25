---
agent: 06-revenue-expansion
brand: pastry
brand_name: Pastry Skincare
date: 2026-07-25
run_id: revenue-expansion-2026-07-25-supersede-3e91c4af
supersedes: "06-revenue-expansion-pastry.md (earlier orchestrator draft, written without agents 04/05)"
data_sources_used:
  - "Repo · automation/config.yaml (guardrails, benchmarks, data-source health)"
  - "Repo · automation/reports/2026-07-25/01-ppc-audit-pastry.md (Meta act 2972238613000896, 28d + 7d)"
  - "Repo · automation/reports/2026-07-25/01-ppc-audit-bot.md (cross-account Pastry spend)"
  - "Repo · automation/reports/2026-07-25/02-seo-audit-pastry.md (WebSearch-only, degraded)"
  - "Repo · automation/reports/2026-07-25/03-merchant-feed-pastry.md (blocked run)"
  - "Repo · automation/reports/2026-07-25/04-analyst-solutions-pastry.md (root-cause synthesis, P1–P13, Handoff → 06)"
  - "Repo · automation/reports/2026-07-25/05-keywords-negatives-pastry.md (K1–K5, Handoff → 06)"
  - "Meta Ads MCP · ads_get_ad_entities act 1615943869585748 level=adset, 7d — LIVE re-read of the four BoT-account Pastry adsets"
  - "Shopify MCP · get-shop-info — called once, 25/07/2026, returned 'requires re-authorization (token expired)'"
data_gaps:
  - "NO PASTRY STORE REVENUE AND NO MER — 2nd consecutive run. Shopify token expired (re-verified live this run). No MER, blended ROAS or store-revenue figure is stated or inferred anywhere in this report."
  - "ACT 2972238613000896 WAS NOT CALLED THIS RUN. Every Pastry-account figure below is quoted from 01-ppc-audit-pastry.md and cited. Only the four BoT-ACCOUNT Pastry adsets were re-read live. Nothing was written to the Pastry ad account."
  - "REVENUE FIGURES ARE DERIVED. All Pastry revenue is purchase_roas x amount_spent, because omni_purchase_values is wrong by exactly 100x on this account's prospecting entities (01-ppc-audit-pastry.md). The inconsistency is VERIFIED; the cause is NOT VERIFIED."
  - "PASTRY STORE REACHABILITY UNVERIFIED. It is unconfirmed that pastryskincare.co.za is served by the same Shopify org as beautyontapp.com; it may be a separate org or mid-migration (03-merchant-feed-pastry.md)."
  - "DOMAIN RESOLVED BY WEBSEARCH ONLY — pastryskincare.co.za rests on 14 indexed URLs plus customer@pastryskincare.co.za, not a get-shop-info confirmation (02-seo-audit-pastry.md)."
  - "NO GOOGLE ADS DATA. Account 851-084-2703 was NOT accessed and NOT modified; automation/inbox/ holds only README.md."
  - "SEMRUSH UNIT-BLOCKED (re-verified live by agent 05). No ranking, volume, difficulty or CPC data for any term."
  - "3-DAY DELIVERY BLACKOUT 02/07–05/07/2026 inside the 28d window. Rate metrics unaffected; 28d totals understate a full 28 days. Any period-over-period comparison must adjust."
  - "TOOL DEFECT (discovered on the BoT account this run): ads_update_entity force-pauses an ad set on a budget write. Relevant to this brand only as a hazard for any future Pastry budget step."
---

# 06 · Revenue Expansion — Pastry Skincare — 2026-07-25

Currency ZAR (R). Dates dd/mm/yyyy. Windows: **28d = 28/06/2026–25/07/2026**, **7d = 19/07/2026–25/07/2026**.
**This report supersedes the earlier 06-revenue-expansion-pastry.md**, written before agents 04 and 05 completed. Corrections are marked **[CORRECTED]**.

## Summary

- **Pastry has the better headline numbers and gets no budget. That is the whole decision.** 28d Meta R52,423.54 → 499 purchases, derived ROAS **8.12x**, CPA **R105.06**; 7d better still at 8.92x / R96.04 (`01-ppc-audit-pastry.md`). Every delivering adset clears the 5.0x trigger and sits under the R167 ceiling. **There is still no store revenue and no MER, for a second run** — so not one of those figures is corroborated by anything outside Meta's own reporting.
- **[CORRECTED] Agent 04 authorized one bounded step on the three `RT_*` adsets (R250 → R300/day). I decline it, and I am overruling agent 04 on this point.** Its "for" case is real and I state it in full below — the 100x defect genuinely does not touch those adsets, which check exact at 1.00x. But **internal consistency between two Meta fields is not corroboration**; it proves Meta agrees with itself, not that the revenue landed, nor on which of five storefronts. With zero external cross-check on the entire account, the brief's rule governs: **hold flat on unverified measurement.**
- **Two independent measurement faults, not one.** The 100x `omni_purchase_values` defect on prospecting (verified inconsistency, unverified cause) **and** two consecutive runs with no store revenue. Either alone would justify caution; together they settle it.
- **Auto-applied for this brand: none.** Nothing was written to act 2972238613000896 — the account was not called at all this run. Nothing qualified, and nothing was manufactured.
- **[CORRECTED] One genuine win the earlier draft could not know, and one it got wrong.** Agent 05 recovered a Pastry-product creative in the *BoT* account landing on `beautyontapp.com`, which under P1's own logic leans **against** a shared-catalogue origin for the 100x defect and points it at act 2972238613000896's own event path. And `config.yaml` **no longer reads `domain: auto`** — the Pastry domain is now pinned to `pastryskincare.co.za` with a do-not-revert note, so the `switch-shop` revocation trap that agents 01/04 flagged is already closed.

## Findings

Severity `[C]/[H]/[M]/[L]` · impact 1-5 / effort 1-5 · owner · **my decision**.

---

### P-D1 · [C] Hold all Pastry budget flat — overruling agent 04's authorized `RT_*` step — impact 5 / effort 1 · Meta · **DECISION: DECLINED**

Agent 04 authorized "one bounded step, not a programme": a single ≤20% increase on each of `RT_Past_Purchasers` (7d ROAS 13.49x, CPA R65.14), `RT_Product_Viewers` (10.20x, R78.80) and `RT_Cart_Abandoners` (9.44x, R112.53), R250 → R300/day (`04-analyst-solutions-pastry.md`).

**Agent 04's case for it, stated fairly and not strawmanned:** the 100x defect provably does not touch these three — all four retargeting entities check exact at ratio **1.00x** in the very API call that exposed the defect on prospecting. They clear the 5.0x trigger by 4–9x, sit far under the R167 CPA ceiling, are capped at only R250/day, and R50/day each is a bounded probe with an obvious revert.

**Why I decline it anyway:**
1. **1.00x is internal consistency, not corroboration.** It proves `omni_purchase_values` and `purchase_roas` agree with each other inside one platform. It says nothing about whether the revenue reached a store, or **which** store — and a Pastry sale can land on five indexed storefronts, two of them BoT-owned (`02-seo-audit-pastry.md`). The account has had **zero external cross-check at any point**, ever.
2. **The brief's rule is explicit and this is exactly the case it was written for.** A better headline ROAS does not outrank unverified measurement. Pastry has the fleet's best ROAS and the fleet's worst instrumentation; those two facts are not independent.
3. **Retargeting is the least incremental spend in the account** — agent 04 makes this point itself. It converts people who were already going to buy, and it is the segment most likely to be attribution-inflated. Scaling it first, on uncorroborated numbers, is the weakest available scaling case dressed in the best available ROAS.
4. **The cost of waiting is genuinely small.** R150/day across three adsets, against an unblock that is one click away.

**This is a deferral with a named unblock, not an indefinite hold.** The moment Shopify auth returns **and** `get-shop-info` confirms the connector reaches the Pastry store, this step becomes the first thing to authorize — see Recommendations 1 and 3. Owner: human (or agent 06 next run, once MER exists).

---

### P-D2 · [C] The 100x purchase-value defect — narrowed by agent 05, still open — impact 5 / effort 2 · Meta/tracking · **DECISION: ESCALATED; value-based prospecting scaling FROZEN**

Within one API response, `omni_purchase_values` contradicts `purchase_roas × amount_spent` by exactly 100x on five prospecting entities (`PASTRY_Main_Revenue` reports R2,022.89 against an implied R202,289) while four retargeting entities in the same call are exact (`01-ppc-audit-pastry.md`). **The inconsistency is VERIFIED. The cause is NOT VERIFIED** — benign cents/rands reporting artifact, or genuine pixel/CAPI values 100x too small, in which case value-based bidding on `PASTRY_Main_Revenue` is optimising against a corrupted signal.

**[CORRECTED] What agent 05 added:** a Pastry-product creative inside the *BoT* account resolves to `https://beautyontapp.com/products/pastry-skincare-hyaluronic-acid-hand-cream` (`05-keywords-negatives-pastry.md` K4). Under P1's own logic, if the BoT-side Pastry ads drive the same store and catalogue, a shared catalogue would have corrupted both accounts — it did not — which leans **against** a catalogue price-field origin and toward act 2972238613000896's own event path. **Do not upgrade this to a conclusion:** it is one product creative, not the four prospecting adsets. It narrows the diagnosis; it does not close it.

**Frozen until resolved:** any value-based bid scaling on `PASTRY_Main_Revenue` or its prospecting adsets. Agent 04's freeze stands unchanged. Agents are barred from Events Manager (`config.yaml` `never: [change_pixel, change_capi]`) — **human only**. Owner: human.

---

### P-D3 · [C] The four BoT-account Pastry adsets are the fleet's best ROAS and are declined — impact 5 / effort 1 · Meta · **DECISION: DECLINED (both brands)**

Live 7d re-read this run, act 1615943869585748: `pastry new testing ads` **13.06x** / CPA R71.11 · `AS1_PastrySkincare - new` **12.90x** / R76.62 · `AS1_PastrySkincare - mathebe's hands ad` **9.65x** / R81.96 · `AS2_PastrySkincare - NEW testing 25 June` **7.32x** / R116.20. R36,840.33/28d, 390 purchases.

Declined for both brands simultaneously, which is the point: scaling them before the property map is decided either funds this account's **direct auction competitor** or credits BoT with Pastry's revenue — and nobody can currently tell which (`04-analyst-solutions-pastry.md` P4). Combined Pastry-product prospecting across the two accounts is **R65,976.49/28d**. Live read also confirms three of the four carry **no adset-level budget** (they sit under a R3,060/day campaign), so any step is escalate-only regardless.

---

### P-D4 · [H] No store revenue, no MER, second consecutive run — impact 5 / effort 1 · Ops · **DECISION: ESCALATED, ranked #1**

This is an **operational blocker, not a marketing decision**, and it is the single thing standing between this brand and a defensible scaling call. Shopify token expired — re-verified live this run, 4th consecutive run fleet-wide.

**What would unblock it, exactly:** (1) T re-authorizes the Shopify connector in claude.ai connector settings — one click. (2) Next run calls `get-shop-info` **before any write** and **stops if it does not return the Pastry store** — reachability is genuinely unverified and it may be a separate Shopify org. (3) Then, and only then, MER can be computed — *provided* P4 has defined which of the five storefronts count as "Pastry revenue".

**Two independent blockers, and clearing only one is not enough.** Do not infer a MER from a partial clear.

---

### P-D5 · [H] A Pastry sale can land in five places; two are BoT-owned — impact 5 / effort 3 · Strategy · **DECISION: ESCALATED — cannot be decided today**

The glycolic acid body wash alone is indexed on `pastryskincare.co.za`, takealot.com, `beautyontapp.com`, `shopbeautyontapp.co.za` and raines.africa (`02-seo-audit-pastry.md`). Retail syndication to Takealot and Raines is normal and healthy; **two owned storefronts plus two ad accounts chasing one audience is not.**

Consequence stated precisely: **no Pastry MER is computable even after Shopify returns**, because "Pastry revenue" is not yet defined. Human decision, and it is the same decision as B1 asked from the other side. Also note the retailer currently out-optimises the brand for its own name — `beautyontapp.com/collections/pastry-skincare` is titled "Pastry Skincare | SA Body Care for Melanin-Rich Skin" while Pastry's own listing pages read "Products – Pastry Skincare".

---

### P-D6 · [M] `Not a single lie ad` — the only live entity breaching a CPA ceiling — impact 3 / effort 1 · Meta · **DECISION: ESCALATED, recommend pause**

`Not a single lie ad` (120239422780760393), ACTIVE: R1,161.79 for 3 purchases — CPA **R387.26** (over the R300 stop ceiling), ROAS **1.330**. CTR 3.88% and CPC R0.98 are healthy (`01-ppc-audit-pastry.md`).

**Outside the auto-gate** — `config.yaml` allows `pause_zero_conversion_adset` only; this is an *ad* with 3 conversions. Cheap clicks that do not buy is an offer/landing-page mismatch, not a hook problem. **My recommendation: pause it**, unless its destination turns out to be a legacy `/product/…` URL — in which case the fix is the 301, not the ad (P3 ∩ P10). Owner: human.

---

### P-D7 · [M] Prospecting frequency 5.538 — a leading indicator, correctly unactioned — impact 4 / effort 3 · Meta · **DECISION: no budget action; creative refresh recommended**

`AS1_Hyperpigmentation` runs 28d prospecting frequency **5.538**, 58% over the >3.5 flag and the highest across both brands, with one ad (`new... Pastry Premium`, R12,163.81 — the largest single ad in the account) carrying it at frequency 5.464. **Performance has not degraded** — 7d ROAS 8.335x / CPA R103.42, flat against 28d.

Within-account overlap is mild (1.28 / 1.56), which exonerates the account's own adsets and makes an **external** source the leading explanation — a second ad account prospecting the same audience (P-D5). *Magnitude NOT VERIFIED*; Meta's overlap tooling is per-account. **No audience exclusion applied** — an in-account exclusion cannot fix a cross-account collision, and the correct set depends on P4.

Recommended instead: pre-emptive creative refresh, 2–3 new hooks, **now**, while performance is still strong. One creative carrying R12,163.81 is a single point of failure regardless of how the overlap question resolves.

---

### P-D8 · [M] Escalate-only class and the zero-purchase boosts — impact 3 / effort 1 · Meta · **DECISION: ESCALATED / no action**

- **Over the R500/day line** (`config.yaml`), mine to name not to action: `AS2_Body_Care_Broad` R537.60/day (7d ROAS 6.74x), `AS1_Hyperpigmentation` R531.87/day (8.34x). Both healthy. **No increase authorized** — same measurement reasoning as P-D1, and both are prospecting, which carries the 100x defect.
- **Four Instagram boost adsets spent R1,717.74 for zero purchases** on a `LINK_CLICKS` objective. They meet the auto-pause gate on paper but `effective_status` is `CAMPAIGN_PAUSED` — a human correctly stopped them 02/07/2026. **No pause written: it would be a no-op with a meaningless "not delivering → not delivering" row.** The durable fix is a policy rule — no in-app boosting for a sales goal; rebuild as `OUTCOME_SALES` inside `PASTRY_Main_Revenue`.
- **9 dormant duplicate campaigns**, including a stale `main` still holding a **R1,000/day** budget. **Archive, never delete** (`config.yaml` `never: [delete_campaign…]`). Human action — the risk is accidental reactivation of a R1,000/day shell.

---

### P-D9 · [M] R17.8k/28d of the account's best-ROAS spend rides on an unmeasured catalogue — impact 4 / effort 1 once auth clears · Shopify · **DECISION: ESCALATED**

The entire retargeting engine is DPA/catalog-driven: `DPA_Past_Purchasers` (R6,223.61, ROAS 13.07x), `DPA_Product_Viewers` (R6,625.86, 10.12x), `DPA_Cart_Abandoners` (R4,933.68, 9.77x). GTIN/MPN, `google_product_category`, `product_type`, alt text and meta descriptions are unknown for a 3rd run (`03-merchant-feed-pastry.md`).

**Unmeasured is not healthy** — report it as unmeasured, never as clean. The standing Merchant Center 'Illegal drugs' / 'Misleading claims' watch items could be neither confirmed nor cleared. Note the pointed irony: the three adsets agent 04 wanted to scale are the three riding on the catalogue nobody has been able to measure.

---

### P-D10 · [L] Declined and endorsed items — impact 2 / effort 1 · **DECISION: as marked**

- **[DECLINED] Any reallocation framed as "freed budget".** **R0 was freed across both brands today** (`01-ppc-audit-pastry.md`, `05-keywords-negatives-pastry.md`). Nothing was paused or trimmed anywhere.
- **[DECLINED] Converting agent 05's 16 keyword candidates into a budget ask.** No volume, difficulty or CPC data exists behind any of them — explicitly unvalidated hypotheses, as are the four "blue-ocean" terms.
- **[DECLINED] Pointing any new paid keyword at a legacy `/product/…` URL** — pending the P3 301 decision.
- **[ENDORSED] The standing refusal to issue any bid-reduction CSV.** Both agent 02 reports declined it and agent 05 kept it. Right call, unchanged — with no ranking data, cutting paid on terms assumed to rank organically is unsafe.
- **[ENDORSED] `03-merchant-feed-pastry.md`'s framing: "instrumentation first, decisions second."** That is exactly the ruling this report reaches independently.
- **[OPEN] Whether Pastry sells a kojic acid soap** — a named blue-ocean term whose product could not be verified for this brand. Two-minute catalogue check; resolve it before it is bought.

## Auto-Applied Changes

**none**

| change | before → after | revert |
|---|---|---|
| *(no change was applied to Pastry Skincare on any platform)* | — | — |

**Act 2972238613000896 was not called at all this run** — no read, no write. Nothing was written to Google Ads 851-084-2703 (recommend-only, and unreachable regardless). Nothing was written to Shopify (`get-shop-info` returned token-expired on 25/07/2026).

**Guardrail check, stated in full:**

| Guardrail (`config.yaml`) | Result |
|---|---|
| `adjust_budget`, ≤20% per run | **Candidate existed and was deliberately declined.** The three `RT_*` adsets at R250/day qualify on every performance test. Declined on measurement grounds — see P-D1. This is a judgement call, stated as one, and it overrules agent 04. |
| `pause_zero_conversion_adset` (≥7d AND ≥R300 AND 0 conv AND **delivering**) | **No actionable candidate.** All five delivering adsets produced purchases (minimum 52). The four Instagram boosts meet the criteria on paper but are `CAMPAIGN_PAUSED` and not delivering — a write would be a meaningless no-op. |
| `escalate_if_adset_daily_spend_above_zar: 500` | **Respected.** `AS2_Body_Care_Broad` (R537.60/day) and `AS1_Hyperpigmentation` (R531.87/day) escalated, not actioned. |
| `add_negative_keyword` / `add_placement_exclusion` / `add_audience_exclusion` | **No candidate — an evidenced null.** Within-account overlap ratios are 1.28 / 1.56 and no segment shows spend with zero conversions (`01-ppc-audit-pastry.md`). The frequency hypothesis is cross-account, which an in-account exclusion cannot fix. |
| `never: [delete_*, change_pixel, change_capi]` | **Respected.** The 100x defect diagnosis requires Events Manager and was escalated to a human rather than touched. |
| Shopify allowlist | **Unreachable.** Token expired; zero calls succeeded. |
| Google Ads | **RECOMMEND-ONLY, honoured.** Account 851-084-2703 NOT accessed, NOT modified. |

## Recommendations

Ranked by impact ÷ effort.

1. **⭐ [C] Re-authorize the Shopify connector, then confirm reachability with `get-shop-info` before any write.** Impact 5 / effort 1. This is the #1 item for this brand — it is the difference between "best ROAS in the fleet" and "best *reported* ROAS in the fleet". The `brands[pastry].domain` pin is already in `config.yaml`, so the `switch-shop` revocation trap is closed; the re-auth click is not.
2. **⭐ [C] Diagnose the 100x defect in Events Manager.** Impact 5 / effort 2. Human only. Compare `value` and `currency` on Purchase events attributed to `PASTRY_Main_Revenue` / `AS1_Hyperpigmentation` / `AS2_Body_Care_Broad` against the `RT_*` adsets. Agent 05's evidence points at this account's own event path rather than the catalogue — start there.
3. **⭐ [H] The `RT_*` step is pre-approved for the moment measurement exists.** Impact 4 / effort 1. Once Shopify returns **and** `get-shop-info` confirms the Pastry store, authorize `RT_Past_Purchasers` / `RT_Product_Viewers` / `RT_Cart_Abandoners` R250 → R300/day (+20% each). **Warning: `ads_update_entity` force-pauses an ad set on a budget write — pair every step with `ads_activate_entity` and verify.** This defect was confirmed live on the BoT account today.
4. **[C] Decide the property map and define what counts as "Pastry revenue" (P4).** Impact 5 / effort 3. Human. Nothing about MER is computable before this, and it also unlocks the four declined BoT-account Pastry adsets.
5. **[C] Finish the Woo→Shopify migration: confirm the authoritative tree, then 301 page-to-page.** Impact 5 / effort 3. Human + dev. Never blanket-to-homepage. The niacinamide body lotion pair is the confirmed test case.
6. **[H] Install the Google Ads search-term bridge in 851-084-2703.** Impact 5 / effort 1. Human, recommend-only channel. Third consecutive blocked run.
7. **[H] Refresh creative in `AS1_Hyperpigmentation` pre-emptively.** Impact 4 / effort 3. One ad carrying R12,163.81 at frequency 5.464 is a single point of failure.
8. **[H] Ship the four queued collection meta titles plus the lowercase `body wash` casing fix** once auth clears. Impact 4 / effort 2. **Safe ahead of the 301 decision** — the Shopify-side tree survives either outcome. Leave the legacy `/product/…` titles alone.
9. **[H] Adopt a standing no-in-app-boosting-for-sales rule.** Impact 4 / effort 1. Prevents the next R1,717.74.
10. **[M] Pause `Not a single lie ad`, or fix its destination.** Impact 3 / effort 1. Human. Check first whether the destination is a legacy URL.
11. **[M] Restore Semrush units.** Impact 4 / effort 1. Until then the blue-ocean terms stay hypotheses and no competitor gap can be run.
12. **[L] Archive the 9 dormant campaigns, especially `main` (R1,000/day attached); fix the homepage title pipe spacing.** Impact 2 / effort 2. Archive, never delete.

## Handoff

### → Tomorrow's agent 01 (PPC audit)

- **Re-check whether `omni_purchase_values` still reads 100x low.** If it has silently corrected, that points to the benign reporting artifact rather than a pixel fault — a genuinely useful discriminator that costs one call.
- **Nothing was changed in act 2972238613000896 today.** Baseline is unchanged from `01-ppc-audit-pastry.md`: `PASTRY_Main_Revenue` ACTIVE @ R1,200/day; `RT_Past_Purchasers` / `RT_Product_Viewers` / `RT_Cart_Abandoners` ACTIVE @ **R250.00/day each**; `main` PAUSED @ R1,000/day; four Instagram boost campaigns PAUSED @ R190/day.
- **If Shopify has returned and reachability is confirmed, the `RT_*` step is pre-approved** — see Recommendation 3, including the force-pause warning.
- **Adjust for the 3-day blackout (02/07–05/07/2026)** before any period-over-period comparison.

### → Tomorrow's agent 03 (Merchant/Feed)

Re-test Shopify; do not inherit. **BoT first, commit, then attempt Pastry.** Call `get-shop-info` and **stop if it does not return the Pastry store** — do not write. Four collection meta titles plus the casing fix are queued; ship only the Shopify-side tree.

### → Tomorrow's agent 05 (Keywords + Negatives)

`ls automation/inbox/` first. Protected terms unchanged: **never negate** face wash / face serum / face cream / review / vs. The `kojic acid soap` ownership question is still open. Re-test Semrush rather than inheriting.

### → T / strategy

**Confidence for this brand is the lowest in the fleet and should be reported that way.** Pastry's paid performance looks excellent and may well be excellent — but for two runs running, nothing outside Meta's own reporting has confirmed a single rand of it, and one of Meta's own revenue fields is provably wrong by 100x on more than half the account's spend. **Instrumentation first, decisions second.** The one genuine win to report: the domain is resolved and now pinned in `config.yaml` — `pastryskincare.co.za`.
