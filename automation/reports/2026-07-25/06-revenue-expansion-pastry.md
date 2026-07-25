---
agent: revenue-expansion
brand: pastry
date: 2026-07-25
run_id: 06-revenue-expansion-2026-07-25
data_sources_used:
  - automation/reports/2026-07-25/01-ppc-audit-pastry.md
  - automation/reports/2026-07-25/02-seo-audit-pastry.md
  - automation/reports/2026-07-25/03-merchant-feed-pastry.md
data_gaps:
  - "Agents 04 (Analyst) and 05 (Keywords+Negatives) did not complete this run — synthesis performed directly by this agent."
  - "No store revenue and no MER for a second consecutive day — Shopify token expired and the Pastry store was never reached."
  - "Unconfirmed whether the Shopify connector can reach pastryskincare.co.za at all; may be a separate org or mid-migration."
  - "Semrush unit-blocked: no organic, keyword or backlink data."
  - "No Google Ads data: no connector, automation/inbox/ empty."
---

## Summary

- **Strong paid performance: 28d Meta R52,423.54 → 499 purchases, ROAS 8.12x, CPA R105.06.** 7d is better still (8.92x, R96.04). Every delivering adset clears the 5.0x scaling trigger and sits under the R167 CAC ceiling.
- **But the measurement underneath it is not trustworthy yet**, and that governs today's decision. `omni_purchase_values` reads exactly 100x low on prospecting entities while retargeting is correct in the same API call — and there is still no store revenue, so platform ROAS remains uncross-checked for a second day.
- **Ruling: instrumentation first, scaling second.** Pastry has the better headline ROAS of the two brands, but BoT's numbers are corroborated against store revenue and Pastry's are not. Scale the brand whose numbers are verified; fix the one whose aren't.
- **Auto-applied: none.** Nothing met the pause or trim gates; Shopify was unauthenticated all run.
- The four zero-purchase Instagram boost adsets were already stopped by a human on 02/07 — correct call, left standing.

## Findings

### [C] `omni_purchase_values` is understated by exactly 100x on prospecting entities (impact 5 / effort 2)
Verified within a single API response: `PASTRY_Main_Revenue` reports R2,022.89 against `purchase_roas` 6.942885 × R29,136.16 = R202,289. Same pattern on `AS1_Hyperpigmentation`, `AS2_Body_Care_Broad`, `main`, `AS2 test.` — all prospecting. All four retargeting entities in the same call are correct to 1.00x, and every equivalent BoT field is correct. Source: `01-ppc-audit-pastry`.

The **inconsistency is verified; the cause is NOT VERIFIED.** Two candidates with very different severity: a benign reporting artifact (value arriving in cents while ROAS is computed on rands), or a genuine pixel/CAPI path sending purchase values 100x too small — in which case **any value-based bidding on `PASTRY_Main_Revenue` is optimising against a corrupted signal.** The prospecting-broken/retargeting-correct split is consistent with two different event-delivery paths.

**Owner: human · Events Manager inspection required.** Agents are barred from pixel/CAPI by `config.yaml` (`never: [change_pixel, change_capi]`). **This is the top priority for the brand** — it gates whether the 8.12x ROAS can be trusted at all.

### [H] No store revenue and no MER for a second consecutive day (impact 4 / effort 1)
Platform-reported ROAS has not been cross-checked against actual store revenue at any point. Source: `01-ppc-audit-pastry`, `03-merchant-feed-pastry`. Combined with the 100x anomaly, **two independent reasons exist to distrust Pastry's revenue figures right now.**
**Owner: Shopify auth · needs T (one click).**

### [H] Pastry sells through at least five indexed storefronts (impact 4 / effort 4)
Its own site, Takealot, Raines, `beautyontapp.com` and `shopbeautyontapp.co.za`. Meanwhile 42.5% of BoT's Meta budget (R36,840.33/28d) runs Pastry creative while this account independently spent R52,423.54 on the same product line. Source: `01-ppc-audit-bot`, `02-seo-audit-pastry`.
**A single Pastry sale can land in at least two owned stores and two third-party retailers.** No Pastry MER is meaningful until the in-scope properties are defined.
**Owner: strategy · needs T's decision.**

### [H] Unfinished WooCommerce → Shopify migration on pastryskincare.co.za (impact 4 / effort 3)
Legacy `/product/…` and `/product-category/…` URLs serve alongside Shopify `/products/…` and `/collections/…`, with the same product indexed at both addresses (niacinamide body lotion is the provable case). Legacy URLs still return titles, which a correctly-301'd URL does not. Source: `02-seo-audit-pastry`.
**Owner: dev · needs T's decision.** Attribute work on those pages should wait for the 301 call, or it is done twice.

### [M] Four Instagram boost adsets spent R1,717.74 for zero purchases — structural, not bad luck (impact 3 / effort 1)
All four ran on a `LINK_CLICKS` objective; a link-click objective cannot optimise for purchases. Already paused by a human on 02/07. Source: `01-ppc-audit-pastry`.
**Decision: no agent action (they are not delivering; a pause write would be a meaningless no-op).** The durable fix is a policy one — stop boosting posts from the Instagram app, since that is what produces the `LINK_CLICKS` pattern.

## Auto-Applied Changes

none

*No delivering adset met the pause gate; none sits below the ROAS floor, so none met the trim gate. The four qualifying-on-paper boost adsets are already campaign-paused, so a write would produce a meaningless "not delivering → not delivering" row. Shopify unauthenticated all run.*

## Recommendations

1. **Inspect Events Manager for the 100x purchase-value discrepancy on Pastry prospecting.** Until resolved, treat Pastry's ROAS as directionally good but not decision-grade, and do not lean on value-based bidding for `PASTRY_Main_Revenue`.
2. **Re-authorize Shopify**, then confirm the connector actually reaches `pastryskincare.co.za` before any write.
3. **Hold Pastry budget flat this cycle.** Not because performance is poor — it is the best in the fleet on paper — but because two independent measurement faults mean an increase would be made on unverified numbers.
4. **Stop app-based post boosting**; run Instagram creative through a sales objective instead.
5. **Decide the 301 map** before investing in Pastry on-page work.

## Handoff

**→ Tomorrow's agent 01:** re-check whether `omni_purchase_values` still reads 100x low; if it has silently corrected, that points to the benign artifact explanation rather than a pixel fault.
**→ Tomorrow's agent 03:** four collection meta titles plus the lowercase `body-wash` title defect are queued — but only after `get-shop-info` confirms the Pastry store.
**→ Strategy:** Pastry is the thinnest-instrumented brand in the fleet. Framing for the next cycle is *instrumentation first, decisions second*.
