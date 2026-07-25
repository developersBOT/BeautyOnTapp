---
agent: 01-ppc-audit
brand: pastry
brand_name: Pastry Skincare
date: 2026-07-25
run_id: ppc-audit-2026-07-25-5c268399
data_sources_used:
  - "Meta Ads MCP · ads_get_ad_accounts — confirmed act 2972238613000896 'Pastry ads' ACTIVE/queryable, ZAR, business 'Pastry Skincare'"
  - "Meta Ads MCP · ads_get_ad_entities level=campaign, time_range 2026-06-28..2026-07-25 (28d) and 2026-07-19..2026-07-25 (7d)"
  - "Meta Ads MCP · ads_get_ad_entities level=adset, both windows"
  - "Meta Ads MCP · ads_get_ad_entities level=ad, 28d, sort=amount_spent_descending"
  - "Meta Ads MCP · ads_account_get_activity_logs act 2972238613000896, since 2026-06-28, event_category=status (pre-write baseline)"
  - "Repo · automation/config.yaml, automation/agents/01-ppc-audit.md, automation/inbox/"
data_gaps:
  - "SHOPIFY UNREACHABLE FOR PASTRY — NO MER THIS RUN. config.yaml sets Pastry domain to 'auto' (resolved at runtime via switch-shop + get-shop-info). The switch-shop call revoked the active token and the Shopify MCP server then disconnected requiring re-authorization, which a scheduled run cannot perform. Consequence: Pastry's primary domain is UNRESOLVED, store revenue is UNKNOWN, and blended ROAS / MER vs the 1.82x floor could NOT be computed. No Pastry revenue or MER figure appears anywhere in this report. A human must re-authorize the Shopify connector in claude.ai connector settings."
  - "GOOGLE ADS (851-084-2703): no API and no MCP connector in this environment, and automation/inbox/ contains only README.md — no CSV for any brand. ZERO Google Ads account numbers are stated anywhere in this report. Export steps emitted under Recommendations."
  - "SEMRUSH: paid_search_research returned 'active subscription but not enough API units'. No external Google-paid-visibility signal this run. No Semrush-derived figure appears in this report. More units: https://www.semrush.com/mcp-access"
  - "DATA INTEGRITY — omni_purchase_values is internally inconsistent in this account by a factor of exactly 100 on prospecting entities (see finding [H] below). Every revenue figure in this report is therefore DERIVED as purchase_roas x amount_spent, not read from omni_purchase_values, and is labelled 'derived'."
  - "The 28d window contains a ~3-day blackout: both live campaigns were set Inactive on 02/07/2026 and reactivated on 05/07/2026 (ads_account_get_activity_logs). 28d rate metrics are unaffected but 28d totals understate a full 28 days of delivery."
  - "Creative-fatigue test in the playbook is 'CPA up >40% over a rolling 14d window AND frequency >4'. A rolling-14d series was not pulled; a 7d-vs-28d CPA delta was used as a proxy and is labelled as such at every use."
  - "Audience-overlap percentages were NOT measured via ads_get_custom_audience. Overlap is inferred from reach arithmetic and tagged NOT VERIFIED where the magnitude matters."
  - "Attribution window behind Meta's purchase/ROAS columns was not surfaced by the tool and is unstated."
  - "Window note: post-Feb-23-2026 only, per playbook. Both windows satisfy this."
---

# 01 · PPC Audit — Pastry Skincare — 2026-07-25

Currency ZAR (R). Dates dd/mm/yyyy. Windows: **28d = 28/06/2026–25/07/2026**, **7d = 19/07/2026–25/07/2026**.
Conversion metric used throughout: Meta `actions:omni_purchase` + `offsite_conversion_fb_pixel_purchase` (these agreed exactly at campaign level: 223 and 244). "All conversions" was never used.
**All revenue figures are derived as `purchase_roas x amount_spent`** because the account's `omni_purchase_values` field is unreliable — see finding [H] below.

## Summary

- **Account is performing strongly.** 28d Meta spend R52,423.54 → 499 purchases, derived ROAS **8.12x**, CPA **R105.06** (`ads_get_ad_entities` level=campaign, 28d). 7d is better: R12,197.68 → 127 purchases, derived ROAS **8.92x**, CPA **R96.04**. Every delivering adset clears the 5.0x scaling trigger and sits under the R167 "excellent" CAC ceiling.
- **MER could not be computed** — the Shopify connector disconnected mid-run and Pastry's store was never reached (see data_gaps). Platform ROAS is therefore uncross-checked against store revenue this run, and nothing here should be read as blended MER vs the 1.82x floor.
- **Top finding — the `omni_purchase_values` field is wrong by exactly 100x on this account's prospecting entities** while `purchase_roas` is correct. Verified internally: `PASTRY_Main_Revenue` reports R2,022.89 of purchase value against ROAS 6.942885 x R29,136.16 = R202,289. Retargeting entities are unaffected. Any downstream tool reading that field will understate Pastry prospecting revenue by 99%.
- **Second finding — four Instagram boost adsets spent R1,717.74 for zero purchases.** A human already paused them on 02/07/2026, which was the correct call; no agent action is needed or taken.
- **Auto-applied changes: none.** No adset met the zero-conversion pause gate while delivering, and no delivering adset is below the ROAS floor, so nothing qualified for a trim either.

## Findings

### [H] `omni_purchase_values` is understated by exactly 100x on prospecting entities — corrupts any downstream revenue read (impact 5 / effort 2)

Within a single `ads_get_ad_entities` response, `omni_purchase_values` contradicts `purchase_roas x amount_spent` by a factor of exactly 100 — but only on prospecting entities. Verified rows, 28d:

| Entity | ID | Spend | `purchase_roas` | Reported `omni_purchase_values` | Implied (roas x spend) | Ratio |
|---|---|---|---|---|---|---|
| PASTRY_Main_Revenue (campaign) | 120239422422250393 | R29,136.16 | 6.942885 | **R2,022.89** | R202,289 | 100x |
| AS1_Hyperpigmentation (adset) | 120239422422230393 | R14,451.38 | 8.132857 | **R1,175.31** | R117,531 | 100x |
| AS2_Body_Care_Broad (adset) | 120239422623010393 | R14,684.78 | 5.771826 | **R847.58** | R84,758 | 100x |
| main (campaign) | 120243641897420393 | R3,788.36 | 7.131054 | **R270.15** | R27,015 | 100x |
| AS2 test. (adset) | 120246229373450393 | R3,449.69 | 6.528413 | **R225.21** | R22,521 | 100x |

Retargeting entities in the **same account and same API call** are correct:

| Entity | ID | Spend | `purchase_roas` | Reported | Implied | Ratio |
|---|---|---|---|---|---|---|
| PASTRY_Retargeting_DPA (campaign) | 120239423593780393 | R17,781.28 | 11.053132 | R196,538.84 | R196,539 | 1.00x |
| RT_Past_Purchasers (adset) | 120239424374900393 | R6,223.21 | 13.066448 | R81,315.25 | R81,315 | 1.00x |
| RT_Product_Viewers (adset) | 120239424374890393 | R6,625.03 | 10.11995 | R67,044.97 | R67,045 | 1.00x |
| RT_Cart_Abandoners (adset) | 120239423593800393 | R4,933.04 | 9.766517 | R48,178.62 | R48,179 | 1.00x |

Every equivalent field in the BeautyOnTApp account (act 1615943869585748) checked correct, so this is specific to Pastry prospecting.

The **inconsistency is verified** — both numbers came from the same tool response. The **cause is inference and is NOT VERIFIED**. Two candidate explanations, which have very different severity:
- *Benign:* a reporting-field artifact where purchase value for those adsets arrives in cents (minor units) while ROAS is computed on the correct rand figure. Reporting is wrong; bidding is fine.
- *Serious:* the pixel/CAPI path feeding those prospecting adsets genuinely sends purchase values 100x too small, in which case any value-based bid strategy on `PASTRY_Main_Revenue` is optimising against a corrupted signal.

The split — prospecting broken, retargeting correct, within one account — is consistent with two different event-delivery paths. Distinguishing the two requires Events Manager inspection, which this agent must not touch (`config.yaml` `never: [change_pixel, change_capi]`). **Escalated to a human as a tracking anomaly, per the playbook's rule that tracking corrupts every downstream decision.**

### [H] Four Instagram boost adsets spent R1,717.74 for zero purchases — already stopped by a human (impact 4 / effort 1)

`ads_get_ad_entities` level=adset, 28d. All four created 16/06/2026, objective `LINK_CLICKS`:

| Adset | ID | Spend | Purchases | CTR | Freq |
|---|---|---|---|---|---|
| Instagram post: We are turning 5 this year and we... | 120245548921590393 | R430.62 | **0** | 2.35% | 1.057 |
| Instagram post: A power ingredient combo that... | 120245548840520393 | R429.47 | **0** | 2.61% | 1.016 |
| Instagram post: She said it best, Lightweight,... | 120245548998560393 | R429.55 | **0** | 3.10% | 1.044 |
| Instagram post: The Pastry Premium Body Wash has... | 120245549305940393 | R428.10 | **0** | 1.71% | 1.728 |
| **Total** | | **R1,717.74** | **0** | | |

Each is ≥7 days old with ≥R300 spend and zero conversions — the literal auto-pause gate. **No pause was applied, and deliberately so:** `effective_status` is `CAMPAIGN_PAUSED` on all four, and `ads_account_get_activity_logs` confirms Mathebe Molise set the parent campaigns Active → Inactive on **02/07/2026 at 10:08** via Power Editor. They are not delivering. Writing `status=PAUSED` would change nothing about today's spend and would produce a meaningless "not delivering → not delivering" before/after row. The human's call was correct and is left standing.

Root cause worth stating plainly: these were boosted Instagram posts on a `LINK_CLICKS` objective. A link-click objective cannot optimise for purchases, so R1,717.74 bought traffic with no purchase signal attached. That is a structural mistake, not bad luck — the anti-conservative rule applies: this money did not need "more time", it needed a sales objective. Boosting from the app (`Boosted Instagram Media Mobile` appears as the source in the activity log) is what produces this pattern.

### [M] AS1_Hyperpigmentation frequency 5.538 on prospecting — the account's clearest saturation signal (impact 3 / effort 2)

`ads_get_ad_entities` level=adset, 28d: `AS1_Hyperpigmentation` (120239422422230393) frequency **5.538** against the >3.5 prospecting flag — 58% over the line, and the highest prospecting frequency across both brands audited today. `AS2_Body_Care_Broad` (120239422623010393) is also over at **4.321**. Campaign `PASTRY_Main_Revenue` sits at **6.107**.

Its dominant ad concentrates the problem: `new... Pastry Premium` (120239422422240393), R12,163.81 spend (the largest single ad in the account), 119 purchases, ROAS 8.017x, CPA R102.22, **frequency 5.464** on reach 46,627.

Performance has *not* yet degraded — 7d ROAS 8.335x and CPA R103.42 are essentially flat against 28d (8.133x / R101.77). So this is a leading indicator, not a live problem: a single creative is carrying a broad prospecting adset and audience saturation is building ahead of any CPA response. Retargeting is clean by comparison — `RT_Past_Purchasers` 3.151, `RT_Product_Viewers` 3.283, `RT_Cart_Abandoners` 2.714, all well under the >6 retargeting flag.

Reach arithmetic (level=adset vs level=campaign, 28d): `PASTRY_Main_Revenue` adsets sum to 140,534 reach against campaign reach 109,778 → ratio **1.28**; `PASTRY_Retargeting_DPA` adsets sum to 123,150 against 78,740 → ratio **1.56**. Cross-adset overlap is mild in both — the frequency is coming from repeat exposure inside the adsets, not from adsets colliding. *Overlap magnitude NOT VERIFIED* — derived from reach arithmetic, not a custom-audience overlap measurement.

### [M] Ad `Not a single lie ad` is the only live entity breaching a CPA ceiling (impact 3 / effort 1)

`ads_get_ad_entities` level=ad, 28d: `Not a single lie ad` (120239422780760393), ACTIVE, spend **R1,161.79**, **3 purchases**, ROAS **1.330**, CPA **R387.26**, frequency 2.915, CTR 3.88%, CPC R0.98.

CPA R387.26 breaches the >R300 "stop" ceiling and ROAS 1.330 falls in the 1.0–2.0 WATCH band after R300+ spend. It sits inside `AS2_Body_Care_Broad`, whose adset-level numbers are healthy (ROAS 5.772x) — so this one creative is being carried by its siblings.

**Not auto-actioned:** the auto-pause guardrail in `config.yaml` is `pause_zero_conversion_adset` — adset-level and zero-conversion only. This is an ad, and it has 3 conversions. Pausing it is a human call. Note the CTR is healthy (3.88%) and clicks are cheap (R0.98) — the creative attracts clicks that do not buy, which is a landing-page/offer-match problem more than a creative-hook problem.

### [M] Two adsets exceed the R500/day escalation line — both are performers (impact 3 / effort 1)

Per `config.yaml` `escalate_if_adset_daily_spend_above_zar: 500`, flagged for a human, never auto-actioned. 7d average daily spend (7d spend ÷ 7):

| Adset | ID | 7d avg/day | 7d ROAS | 7d CPA |
|---|---|---|---|---|
| AS2_Body_Care_Broad | 120239422623010393 | R537.60 | 6.74x | R117.60 |
| AS1_Hyperpigmentation | 120239422422230393 | R531.87 | 8.34x | R103.42 |

Both healthy. Listed so agent 06 knows they are in the escalate-only class.

### [L] No creative fatigue detected on the playbook's own test (impact 2 / effort 1)

The playbook test is CPA up >40% over a rolling 14d window **AND** frequency >4. Using a 7d-vs-28d CPA delta as a **proxy** (rolling-14d series not pulled — see data_gaps), the largest CPA increase is `RT_Cart_Abandoners` at **+18.6%** (R94.87 → R112.53), then `RT_Past_Purchasers` at +2.6% and `AS1_Hyperpigmentation` at +1.6%. `AS2_Body_Care_Broad` and `RT_Product_Viewers` both improved (−18.3%, −13.2%). Nothing approaches +40%, so no adset satisfies both legs. Recording the null result explicitly rather than inventing a fatigue flag. The frequency concern in the [M] finding above stands on its own as a leading indicator.

### [L] Account carries 9 paused duplicate campaigns and a 3-day live blackout (impact 2 / effort 2)

`ads_get_ad_entities` level=campaign, 28d returns 11 campaigns, only 2 delivering. The paused set includes three near-identical copies (`PASTRY_Main_Revenue - Copy` x2 at 120243587895050393 / 120242903364050393, `PASTRY_Creative_Testing - Copy` at 120243915657570393) plus `main` (120243641897420393) which duplicates `PASTRY_Main_Revenue`'s structure and still holds a R1,000/day budget. Adset level shows the same duplication (three separate paused `AS1_Hyperpigmentation` and two paused `AS2_Body_Care_Broad` shells). This is clutter, not spend — but it makes the account hard to read and invites accidental reactivation of a stale R1,000/day campaign.

Separately, `ads_account_get_activity_logs` shows both live campaigns were set Inactive on **02/07/2026 10:08** and reactivated on **05/07/2026 16:31–16:32** by Mathebe Molise — a ~3-day blackout inside the 28d window. Rate metrics (ROAS, CPA, frequency) are unaffected; 28d spend and purchase *totals* understate a full 28 days of delivery. Anyone comparing this window to a prior 28d period must account for it.

## Auto-Applied Changes

**none**

No entity in act 2972238613000896 satisfied any auto-apply guardrail this run:

| Guardrail | Result |
|---|---|
| Pause adset: ≥7d old AND ≥R300 spend AND **0 conversions** | **No actionable candidate.** All five delivering adsets produced purchases (minimum 52). The four Instagram boost adsets do meet the criteria on paper, but `effective_status = CAMPAIGN_PAUSED` — a human stopped them on 02/07/2026 and they have zero current delivery, so a pause write would be a no-op with a meaningless before/after. Reported as a finding instead. |
| Budget trim ≤20% on a proven loser (ROAS below floor, NOT in learning) | **No candidate.** The lowest delivering adset ROAS is `AS2_Body_Care_Broad` at 5.772x (28d) / 6.739x (7d) — more than triple the 1.82x floor. Nothing in this account is a proven loser. |
| Negative keyword / placement / audience exclusion | **No candidate.** No placement, term or audience segment showed spend with zero conversions among delivering entities. Cross-adset overlap ratios (1.28 / 1.56) do not support an exclusion. |
| Brand-defense adsets | None present in this account; exemption not triggered. |

Baseline captured for revert purposes even though nothing was written — current state per `ads_get_ad_entities` at 25/07/2026: `PASTRY_Main_Revenue` ACTIVE @ R1,200.00/day; `PASTRY_Retargeting_DPA` ACTIVE, no campaign budget; `RT_Past_Purchasers` ACTIVE @ R250.00/day; `RT_Product_Viewers` ACTIVE @ R250.00/day; `RT_Cart_Abandoners` ACTIVE @ R250.00/day; `AS1_Hyperpigmentation` and `AS2_Body_Care_Broad` ACTIVE under campaign budget; `main` PAUSED @ R1,000.00/day; four Instagram boost campaigns PAUSED @ R190.00/day each.

## Recommendations

Prioritised. Item 1 is a critical human fix; item 4 is the Google Ads recommend-only deliverable.

**1. [C] Diagnose the 100x purchase-value discrepancy before trusting any Pastry prospecting revenue number.** In Events Manager, compare the `value` and `currency` parameters on Purchase events attributed to `PASTRY_Main_Revenue` / `AS1_Hyperpigmentation` / `AS2_Body_Care_Broad` against those attributed to the `RT_*` adsets. If prospecting events genuinely carry cent-denominated values, every value-based bid signal on that campaign is mis-scaled by 100x and must be fixed at source. **This agent must not touch pixel or CAPI** (`config.yaml` `never: [change_pixel, change_capi]`) — human fix only. Until it is resolved, treat `purchase_roas x amount_spent` as the only trustworthy revenue read for this account. Impact 5 / effort 2.

**2. [H] Stop boosting Instagram posts from the app for a sales goal.** R1,717.74 bought zero purchases across four `LINK_CLICKS` boosts. If those posts deserve budget, rebuild them as `OUTCOME_SALES` ads inside `PASTRY_Main_Revenue` where the existing purchase signal and audience work already exists. The four campaigns are correctly paused today; the recommendation is about preventing the next four. Impact 4 / effort 1.

**3. [H] Refresh creative in `AS1_Hyperpigmentation` before frequency 5.538 turns into a CPA problem.** One ad (`new... Pastry Premium`, R12,163.81 of spend) is carrying the adset at frequency 5.464. Performance is still strong, so this is pre-emptive: add 2–3 new hooks to the adset now rather than waiting for the CPA to move. Impact 4 / effort 3.

**4. [C-for-visibility] Google Ads (851-084-2703) — RECOMMEND-ONLY, and this run has no account data at all.** No Google Ads API or MCP connector exists in this environment and `automation/inbox/` holds only `README.md`. **The Google Ads account was NOT accessed and NOT modified, and no Google Ads figure is stated in this report.** To close the gap, either:

  *Option A — one-off CSV (5 minutes):*
  1. Google Ads → select account **851-084-2703** → Campaigns → Insights & Reports → **Search Terms**
  2. Set date range to **last 30 days**
  3. Columns must include: `Search term`, `Match type`, `Added/Excluded`, `Campaign`, `Ad group`, `Clicks`, `Impressions`, `Cost`, `Conversions`, `Cost / conv.`, `Conv. rate`
  4. Download → **CSV**
  5. Save into `automation/inbox/` as **`pastry-searchterms-2026-07-25.csv`**
  6. Optional for a deeper audit: repeat for campaign / ad-group / keyword performance over the same window as `pastry-campaigns-2026-07-25.csv`
  7. Commit and push to `automation/reports`; agents 01 and 05 will pick it up on the next run

  *Option B — permanent bridge (recommended, removes this gap forever):* install `automation/google-ads-script/export-search-terms.js` in account 851-084-2703 (Tools & Settings → Bulk Actions → Scripts → New script), authorise it, schedule it daily, publish the output Sheet as CSV, then paste the URL into `config.yaml` → `guardrails.google_ads.search_terms_csv_url_pastry`. Agents then read it directly with no human in the loop.

  When the CSV lands, apply the ppc-audit-engine 8-step protocol using the **Conversions** column only (never "All conversions"), post-23/02/2026 data only. Impact 5 / effort 1.

**5. [M] Re-authorize the Shopify connector — Pastry has now gone a full run with no MER.** The connector requires re-authorization via claude.ai connector settings. Until then Pastry's domain cannot be resolved, store revenue is unknown, and platform-reported ROAS (8.12x) cannot be cross-checked against actual sales. Given finding [1], that cross-check matters more for this brand than for BoT. Impact 4 / effort 1.

**6. [M] Pause `Not a single lie ad` (120239422780760393) or fix its landing page.** R1,161.79 for 3 purchases at CPA R387.26 and ROAS 1.330 — the only live entity breaching a CPA ceiling. Its 3.88% CTR and R0.98 CPC say the hook works and the destination does not. Human call: pause it, or match the landing page to the promise. Freed budget goes to `RT_Past_Purchasers` (7d ROAS 13.49x, CPA R65.14), the account's best performer. Impact 3 / effort 1.

**7. [L] Archive the 9 dormant duplicate campaigns, especially `main` (R1,000/day budget attached).** Reduces the chance of someone reactivating a stale campaign. **Not auto-applied** — `config.yaml` forbids deletion outright (`never: [delete_campaign, delete_adset, delete_ad]`), so this is a human action and archival, not deletion, is the safe form of it. Impact 2 / effort 2.

## Handoff

**To 02 (SEO Audit):** Semrush is out of API units, so the paid/organic overlap half of your run is blocked the same way mine was — record it rather than substituting general knowledge. The paid themes carrying real money here are hyperpigmentation / dark marks (`AS1_Hyperpigmentation`, R14,451.38/28d) and body care (`AS2_Body_Care_Broad`, R14,684.78/28d) — both worth organic defence. **Pastry's primary domain is unresolved this run** (Shopify disconnected), so you will need to resolve it yourself before any domain-scoped call.

**To 03 (Merchant/Feed):** the entire retargeting engine here is DPA/catalog-driven — `DPA_Past_Purchasers` (R6,223.61, 98 purchases, ROAS 13.07x), `DPA_Product_Viewers` (R6,625.86, 73, 10.12x), `DPA_Cart_Abandoners` (R4,933.68, 52, 9.77x) — R17.8k/28d riding entirely on Meta catalog quality, at the account's best ROAS. A catalog-health check is high-value here. Also inspect whether the catalog feed is the source of the 100x value discrepancy in finding [H], since catalog price fields are one plausible origin. No Merchant Center disapproval data was reachable this run (no Google Ads/Merchant connector), so the standing 'Illegal drugs'/'Misleading claims' watch items could be neither confirmed nor cleared.

**To 04 (Analyst/Solutions):** four items.
1. **No MER for Pastry this run** — Shopify unreachable, store revenue unknown. Do not infer one; the gap is recorded above.
2. **The 100x `omni_purchase_values` discrepancy is the headline** — if any of your pipelines read that field rather than deriving from ROAS, Pastry prospecting revenue is being understated by 99%. Verified table in finding [H].
3. **Cross-brand contamination from the BoT side:** 42.5% of the BeautyOnTApp Meta account's 28d spend (R36,840.33) runs Pastry-branded creative while this account independently spent R52,423.54 on the same product line. Combined Pastry-product prospecting across both accounts is R65,976.49/28d. Neither brand's ROAS or MER is clean until you resolve which store those BoT-side Pastry sales land on. Full detail in `01-ppc-audit-bot.md`.
4. **3-day blackout (02/07–05/07/2026)** inside the 28d window — adjust any period-over-period comparison.

**To 05 (Keywords + Negatives):** **no Meta negatives, placement exclusions or audience exclusions were auto-applied this run**, so there is nothing of mine to avoid duplicating. The Google Ads negative-keyword candidate list for 851-084-2703 cannot be built until a search-term CSV reaches `automation/inbox/` — export steps in Recommendation 4. Protected product-type terms that must never be negated: face wash / face serum / face cream / review / vs.

**To 06 (Revenue Expansion):** **R0 was freed this run — nothing was paused or trimmed**, so any scaling must come from new budget, not reallocation. **All five delivering adsets clear the 5.0x trigger**, ranked by 7d ROAS: `RT_Past_Purchasers` 13.49x (CPA R65.14), `RT_Product_Viewers` 10.20x (R78.80), `RT_Cart_Abandoners` 9.44x (R112.53), `AS1_Hyperpigmentation` 8.34x (R103.42), `AS2_Body_Care_Broad` 6.74x (R117.60). The three `RT_*` adsets are each capped at R250/day and are the account's most efficient spend — the most obvious scaling headroom in either brand, subject to retargeting-pool size. Two adsets are already over the R500/day escalation line and are yours to decide, not mine: `AS2_Body_Care_Broad` (R537.60/day), `AS1_Hyperpigmentation` (R531.87/day). **Caveat before you scale anything on value-based bidding: resolve finding [H] first** — scaling a campaign whose purchase values may be mis-scaled by 100x would amplify the error.
