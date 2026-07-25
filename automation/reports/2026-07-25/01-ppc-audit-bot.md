---
agent: 01-ppc-audit
brand: bot
brand_name: BeautyOnTApp
date: 2026-07-25
run_id: ppc-audit-2026-07-25-5c268399
data_sources_used:
  - "Meta Ads MCP · ads_get_ad_accounts — confirmed act 1615943869585748 ACTIVE/queryable, ZAR; act 19511690 CLOSED (ignored per config)"
  - "Meta Ads MCP · ads_get_ad_entities level=campaign, time_range 2026-06-28..2026-07-25 (28d) and 2026-07-19..2026-07-25 (7d)"
  - "Meta Ads MCP · ads_get_ad_entities level=adset, both windows"
  - "Meta Ads MCP · ads_get_ad_entities level=ad, 28d, sort=amount_spent_descending"
  - "Meta Ads MCP · ads_account_get_activity_logs act 1615943869585748, since 2026-07-11 (pre-write baseline)"
  - "Shopify MCP · get-shop-info (BeautyOnTApp / beautyontapp.com / i0ma19-q8.myshopify.com, Advanced, ZAR, SAST)"
  - "Shopify MCP · run-analytics-query (ShopifyQL, FROM sales, 2026-06-28..2026-07-25)"
  - "Repo · automation/config.yaml, automation/agents/01-ppc-audit.md, automation/inbox/"
data_gaps:
  - "GOOGLE ADS (820-452-9325, alias 798-265-1189): no API and no MCP connector in this environment, and automation/inbox/ contains only README.md — no CSV for any brand. ZERO Google Ads account numbers are stated anywhere in this report. Export steps emitted under Recommendations."
  - "SEMRUSH: paid_search_research returned 'active subscription but not enough API units'. No external Google-paid-visibility signal this run. No Semrush-derived figure appears in this report. More units: https://www.semrush.com/mcp-access"
  - "SHOPIFY CONNECTOR NOW REQUIRES RE-AUTHORIZATION. BoT revenue below was captured BEFORE the switch-shop call; the subsequent switch-shop revoked the token and the server disconnected, so the Pastry store could not be reached and BoT cannot be re-queried this run. A human must re-authorize the Shopify connector in claude.ai connector settings before the next run."
  - "MER below is Meta-only (Shopify revenue / Meta spend). True blended MER is NOT computable because Google Ads spend is unknown. The 17.55x figure is an UPPER BOUND, not blended MER."
  - "Creative-fatigue test in the playbook is 'CPA up >40% over a rolling 14d window AND frequency >4'. A rolling-14d series was not pulled; a 7d-vs-28d CPA delta was used as a proxy and is labelled as such at every use."
  - "Audience-overlap percentages were NOT measured via ads_get_custom_audience. Overlap is inferred from reach arithmetic (sum of adset reach / campaign reach) and is tagged NOT VERIFIED where the magnitude matters."
  - "Attribution window behind Meta's purchase/ROAS columns was not surfaced by the tool and is unstated."
  - "Window note: post-Feb-23-2026 only, per playbook. Both windows satisfy this."
---

# 01 · PPC Audit — BeautyOnTApp — 2026-07-25

Currency ZAR (R). Dates dd/mm/yyyy. Windows: **28d = 28/06/2026–25/07/2026**, **7d = 19/07/2026–25/07/2026**.
Conversion metric used throughout: Meta `actions:omni_purchase` + `offsite_conversion_fb_pixel_purchase` (these agreed exactly at campaign level: 646 and 152). "All conversions" was never used.

## Summary

- **Account is healthy and profitable, not bleeding.** 28d Meta spend R86,731.03 → 798 purchases at ROAS 7.28x and CPA R108.68 (`ads_get_ad_entities` level=campaign, 28d). The 7d window is stronger still: R25,496.00 → 246 purchases, ROAS 7.92x, CPA R103.64. Both sit far above the 5.0x scaling trigger and well under the R167 "excellent" CAC ceiling.
- **Meta-only MER is 17.55x** (Shopify `total_sales` R1,522,112.10 ÷ Meta spend R86,731.03), versus the 1.82x viable floor. This is an upper bound — Google Ads spend is unknown, so it is not true blended MER.
- **Zero adsets qualify for auto-pause and zero qualify for a budget trim.** Every delivering adset produced purchases; the weakest (`AS1_Visitors_7d_NoPurchase`, 28d ROAS 1.77) is *improving* (7d ROAS 2.68) and was restarted by a human 9 days ago, so it fails the "proven loser, not in learning" test. **Auto-applied changes: none.**
- **Top finding — 42.5% of this account's Meta budget is spent on Pastry Skincare creative** (R36,840.33 of R86,731.03 across four `*PastrySkincare*` / `pastry` adsets) while Pastry runs a separate ad account and a separate store. Cross-brand attribution and auction self-competition risk for agent 04.
- **Second finding — audience overlap is inflating frequency.** `BOOST_BeautyOnTApp_Brands` shows 28d campaign frequency 7.31 while none of its six adsets exceeds 4.65; sum-of-adset-reach ÷ campaign-reach = 2.03, i.e. the average reached person sits in ~2 of the 6 prospecting adsets.

## Findings

### [H] 42.5% of BeautyOnTApp Meta spend funds Pastry Skincare creative, inside the BoT account (impact 5 / effort 3)

Four adsets in act 1615943869585748 carry Pastry branding (`ads_get_ad_entities` level=adset, 28d):

| Adset | ID | 28d spend | Purchases | ROAS |
|---|---|---|---|---|
| pastry new testing ads | 120247583433840573 | R11,453.54 | 128 | 9.12x |
| AS2_PastrySkincare - NEW testing 25 June | 120246829531210573 | R10,145.17 | 80 | 5.83x |
| AS1_PastrySkincare - mathebe's hands ad | 120243874233120573 | R9,462.50 | 114 | 9.28x |
| AS1_PastrySkincare - new | 120245178160350573 | R5,779.12 | 68 | 11.12x |
| **Total** | | **R36,840.33** | **390** | — |

That is **42.5% of the account's 28d spend and 48.9% of its purchases**. A fifth brand thread exists too: ad `mzuri scrub` (120244697460350573, R2,588.81, 14 purchases, ROAS 3.62x) and a paused adset `AS5_Mzuri` (120247627747650573) put Mzuri Skin in the same account.

Meanwhile act 2972238613000896 (Pastry Skincare) independently spent R52,423.54 in the same 28d window on the same product line. Combined Pastry-product prospecting across the two accounts is R36,840.33 + R29,136.16 = **R65,976.49 in 28 days**.

Two consequences, both real:
1. **Attribution.** BoT's Shopify revenue (R1,522,112.10) and Pastry's store revenue cannot be cleanly assigned while 42.5% of "BoT" spend sells Pastry products. Whichever store the Pastry adsets land on, one of the two brands' ROAS/MER is misstated.
2. **Self-competition.** Two ad accounts bidding on the same SA beauty audience for the same products compete in the same auction, which raises both accounts' CPMs. *Magnitude NOT VERIFIED* — cross-account audience overlap is not measurable with `ads_get_custom_audience`, and CPM inflation was not isolated.

### [H] Audience overlap inside BOOST_BeautyOnTApp_Brands is driving campaign frequency to 7.31 (impact 4 / effort 2)

`ads_get_ad_entities` level=campaign, 28d: `BOOST_BeautyOnTApp_Brands` (120242091321130573) frequency **7.309333** over reach 188,412 and 1,377,166 impressions. But no constituent adset exceeds frequency 4.654 (`AS6_Mixed_Store`).

Reach arithmetic (level=adset, 28d): the six prospecting adsets sum to 382,741 reach against a campaign reach of 188,412 → **ratio 2.03**. The average reached person is being served by roughly two of the six adsets. Same pattern, milder, in `RTG_Website_Visitors`: adset reach 122,636 vs campaign reach 80,611 → ratio 1.52.

Per-adset frequency vs the >3.5 prospecting flag (28d): `AS6_Mixed_Store` 4.654, `pastry new testing ads` 4.357, `AS5_KoreanBrands` 3.953 — all three over the line. Retargeting adsets are all under the >6 flag: `AS2_Visitors_8_30d_NoPurchase` 5.259, `AS_Cart_Abandoners_7d` 4.425, `AS1_Visitors_7d_NoPurchase` 4.047.

*Overlap percentage NOT VERIFIED* — derived from reach arithmetic, not from a custom-audience overlap measurement.

### [M] AS1_Visitors_7d_NoPurchase is the account's only sub-floor performer — improving, so flagged not actioned (impact 3 / effort 1)

`ads_get_ad_entities` level=adset:
- **28d**: spend R3,449.75, 10 purchases, ROAS **1.766**, CPA **R344.98**, frequency 4.047, daily budget R300.00
- **7d**: spend R1,904.49, 8 purchases, ROAS **2.682**, CPA **R238.06**, frequency 3.163

28d ROAS 1.766 is below the 1.82x floor and 28d CPA R344.98 breaches the >R300 "stop" ceiling. **But it does not qualify for any auto-action**, and deliberately so:
- It has conversions, so the zero-conversion pause gate does not apply.
- 55% of its 28d spend (R1,904.49 of R3,449.75) occurred in the last 7 days, and `ads_account_get_activity_logs` shows its only ad, `DPA_Viewed_Products` (120242075825130573), was flipped Inactive → Active by Mathebe Molise on **16/07/2026 at 07:11** via "ads MCP server". It was restarted 9 days ago and may still be in/near learning — the budget-trim guardrail excludes entities in learning.
- The 7d trend is *improving on both axes* (ROAS 1.77 → 2.68, CPA R344.98 → R238.06), and 7d CPA is back inside the R167–R300 acceptable band.

Trimming an entity that a human restarted 9 days ago and that is recovering would be acting against the data. Per `config.yaml` `on_uncertainty: escalate`, this is escalated, not actioned. The ad-level figures match exactly (`DPA_Viewed_Products` 28d: R3,450.34, 10 purchases, ROAS 1.766, CPA R345.03).

### [M] AS5_KoreanBrands is the weakest scaled prospecting adset — below the 5.0x trigger (impact 3 / effort 2)

`ads_get_ad_entities` level=adset: 28d spend **R14,038.52** (2nd-largest adset in the account), 82 purchases, ROAS **3.986**, CPA **R171.20**, frequency 3.953. 7d: R4,172.26, 32 purchases, ROAS 4.753, CPA R130.38.

It is not a bleeder by any config test (ROAS well above 1.0; CPA under R500; conversions present) and it is improving. But 28d CPA R171.20 sits just above the R167 "excellent" ceiling and both windows sit under the 5.0x scaling trigger, making it the clear last-place candidate for any budget reallocated from elsewhere. Its dominant ad is `KBEAUTY_Slot_5` (120242091606590573): R10,602.89, 65 purchases, ROAS 4.183, CPA R163.12, frequency 3.267.

Note a human already acted here: `ads_account_get_activity_logs` shows ad `Besties, here's is why Korean skincare works.` (120243564608560573) set Active → Inactive on 16/07/2026 at 07:11. Its 28d record was R849.05 / 3 purchases / ROAS 2.628 / CPA R283.02 — the correct call, already taken.

### [M] Three adsets exceed the R500/day escalation line — all are performers, none auto-actionable (impact 3 / effort 1)

Per `config.yaml` `escalate_if_adset_daily_spend_above_zar: 500`, these are flagged for a human and are never auto-actioned regardless of performance. 7d average daily spend (7d spend ÷ 7, `ads_get_ad_entities` level=adset):

| Adset | ID | 7d avg/day | 7d ROAS | 7d CPA |
|---|---|---|---|---|
| AS5_KoreanBrands | 120242091606450573 | R596.04 | 4.75x | R130.38 |
| AS6_Mixed_Store | 120242091606640573 | R535.06 | 8.75x | R83.23 |
| pastry new testing ads | 120247583433840573 | R525.02 | 12.41x | R73.50 |

All three are healthy. Listed so agent 06 knows they are in the escalate-only class.

### [L] No creative fatigue detected on the playbook's own test (impact 2 / effort 1)

The playbook test is CPA up >40% over a rolling 14d window **AND** frequency >4. Using a 7d-vs-28d CPA delta as a **proxy** (rolling-14d series not pulled — see data_gaps), the largest CPA increase in the account is `AS_Cart_Abandoners_7d` at **+21.0%** (R114.27 → R138.24), followed by `AS2_Visitors_8_30d_NoPurchase` at +10.7% (R134.63 → R149.01). Five of nine adsets show CPA *decreasing*. Nothing approaches +40%, so no adset satisfies both legs of the test. Recording the null result explicitly rather than inventing a fatigue flag.

### [L] RTG_Website_Visitors runs with no campaign-level budget cap (impact 2 / effort 1)

`ads_get_ad_entities` level=campaign returns no `daily_budget` or `lifetime_budget` for `RTG_Website_Visitors` (120242075825140573); control sits at adset level (R350 + R350 + R300 = R1,000/day). 28d spend was R21,040.72 (≈R751/day) so nothing is running away, but the campaign has no ceiling of its own. Observation for the human, not a defect.

## Auto-Applied Changes

**none**

No entity in act 1615943869585748 satisfied any auto-apply guardrail this run:

| Guardrail | Result |
|---|---|
| Pause adset: ≥7d old AND ≥R300 spend AND **0 conversions** | **No candidate.** All nine delivering adsets produced purchases in the 28d window (minimum 10, `AS1_Visitors_7d_NoPurchase`). |
| Budget trim ≤20% on a proven loser (ROAS below floor, NOT in learning) | **No candidate.** The only sub-1.82x 28d entity, `AS1_Visitors_7d_NoPurchase`, is at 7d ROAS 2.68 and was restarted by a human on 16/07/2026 — improving and plausibly in learning, so it fails "proven loser" and "not in learning". Escalated instead. |
| Negative keyword / placement / audience exclusion | **No candidate.** No placement, term or audience segment showed spend with zero conversions. Cross-account overlap (the one real exclusion case) is not measurable with the available tools and would touch a second account. |
| Brand-defense adsets | None present in this account; exemption not triggered. |

Baseline captured for revert purposes even though nothing was written — current state per `ads_get_ad_entities` at 25/07/2026: `BOOST_BeautyOnTApp_Brands` ACTIVE @ R3,060.00/day; `RTG_Website_Visitors` ACTIVE, no campaign budget; `AS_Cart_Abandoners_7d` ACTIVE @ R350.00/day; `AS2_Visitors_8_30d_NoPurchase` ACTIVE @ R350.00/day; `AS1_Visitors_7d_NoPurchase` ACTIVE @ R300.00/day; `BOOST_BeautyOnTApp_Brands - test` PAUSED @ R2,000.00/day.

Relevant recent human change, from `ads_account_get_activity_logs` — **16/07/2026 07:11, Mathebe Molise via "ads MCP server": `BOOST_BeautyOnTApp_Brands` daily budget 255000 → 306000 cents (R2,550.00 → R3,060.00/day)**, a +20.0% increase. Noted so no downstream agent double-counts it as headroom.

## Recommendations

Prioritised. Items 1–2 are human decisions; item 3 is the Google Ads recommend-only deliverable; items 4–6 are optimisation.

**1. [H] Decide where Pastry spend belongs — one account, not two.** R36,840.33/28d of BoT budget and R52,423.54/28d of Pastry-account budget currently chase the same products and audience. Either consolidate Pastry prospecting into act 2972238613000896, or formally treat the BoT Pastry adsets as BoT-store traffic and stop running duplicate prospecting in the Pastry account. Until this is settled, neither brand's ROAS or MER is trustworthy. Owner: human + agent 04. Impact 5 / effort 3.

**2. [H] Deduplicate the six prospecting adsets in BOOST_BeautyOnTApp_Brands.** Campaign frequency 7.31 against a best-adset frequency of 4.65 and a 2.03 reach-overlap ratio means budget is buying the same eyeballs repeatedly. Add mutual audience exclusions between `AS6_Mixed_Store`, `AS5_KoreanBrands` and the three Pastry prospecting adsets, or consolidate them. Not auto-applied: the correct exclusion set depends on decision 1 above, and `config.yaml` says escalate on uncertainty. Impact 4 / effort 2.

**3. [C-for-visibility] Google Ads (820-452-9325, alias 798-265-1189) — RECOMMEND-ONLY, and this run has no account data at all.** No Google Ads API or MCP connector exists in this environment and `automation/inbox/` holds only `README.md`. **The Google Ads account was NOT accessed and NOT modified, and no Google Ads figure is stated in this report.** To close the gap, either:

  *Option A — one-off CSV (5 minutes):*
  1. Google Ads → select account **820-452-9325** → Campaigns → Insights & Reports → **Search Terms**
  2. Set date range to **last 30 days**
  3. Columns must include: `Search term`, `Match type`, `Added/Excluded`, `Campaign`, `Ad group`, `Clicks`, `Impressions`, `Cost`, `Conversions`, `Cost / conv.`, `Conv. rate`
  4. Download → **CSV**
  5. Save into `automation/inbox/` as **`bot-searchterms-2026-07-25.csv`**
  6. Optional for a deeper audit: repeat for campaign / ad-group / keyword performance over the same window as `bot-campaigns-2026-07-25.csv`
  7. Commit and push to `automation/reports`; agents 01 and 05 will pick it up on the next run

  *Option B — permanent bridge (recommended, removes this gap forever):* install `automation/google-ads-script/export-search-terms.js` in account 820-452-9325 (Tools & Settings → Bulk Actions → Scripts → New script), authorise it, schedule it daily, publish the output Sheet as CSV, then paste the URL into `config.yaml` → `guardrails.google_ads.search_terms_csv_url_bot`. Agents then read it directly with no human in the loop.

  When the CSV lands, apply the ppc-audit-engine 8-step protocol using the **Conversions** column only (never "All conversions"), post-23/02/2026 data only, and carry forward the durable negatives (`medicube` negated everywhere except `Shopping_All_Products_v2`; `beautytap` phrase-match). Impact 5 / effort 1.

**4. [M] Reallocate toward the proven performers, not into AS5_KoreanBrands.** Seven of nine adsets clear the 5.0x scaling trigger on 7d ROAS. Ranked by 7d ROAS: `pastry new testing ads` 12.41x (CPA R73.50), `AS1_PastrySkincare - new` 11.50x (R81.69), `AS1_PastrySkincare - mathebe's hands ad` 10.11x (R82.06), `AS6_Mixed_Store` 8.75x (R83.23), `AS_Cart_Abandoners_7d` 6.62x (R138.24), `AS2_PastrySkincare - NEW testing 25 June` 6.56x (R134.63), `AS2_Visitors_8_30d_NoPurchase` 5.89x (R149.01). **Budget increases are explicitly out of this agent's scope — routed to agent 06 (Revenue Expansion) for the final call.** Impact 4 / effort 2.

**5. [M] Review `AS1_Visitors_7d_NoPurchase` at the 14-day mark post-restart (i.e. ~30/07/2026).** If 7d ROAS has not held ≥1.82x by then, trim its R300/day budget. It is currently improving, so no action today. Note this is a *recovery-tracking* item on an adset that is converting — it is not "give it more time" applied to zero-conversion spend, which the playbook forbids and which does not occur anywhere in this account. Impact 2 / effort 1.

**6. [M] Re-authorize the Shopify connector before the next run.** The connector disconnected mid-run after `switch-shop` and now requires re-authorization via claude.ai connector settings. Until then no store revenue is reachable and MER cannot be computed for either brand. Impact 4 / effort 1.

## Handoff

**To 02 (SEO Audit):** Semrush is out of API units, so the paid/organic overlap half of your run is blocked the same way mine was — record it rather than substituting general knowledge. From this account, the highest-value paid themes worth defending organically are Korean/K-beauty brand terms (`AS5_KoreanBrands`, R14,038.52/28d) and mixed local-brand terms (`AS6_Mixed_Store`, R14,179.55/28d). No landing-page URLs were exposed by the Meta tools, so no page-level handoff is possible this run.

**To 03 (Merchant/Feed):** the account's two retargeting workhorses are DPA/catalog-driven — `DPA_Broad_Catalog` (R9,021.45, 67 purchases, ROAS 6.30x) and `DPA_Cart_Abandoners_7d` (R8,570.99, 75 purchases, ROAS 7.74x) — so Meta catalog quality is directly load-bearing on ~R17.6k/28d of spend. Worth a catalog-health check. No Merchant Center disapproval data was reachable this run (no Google Ads/Merchant connector), so the standing 'Illegal drugs'/'Misleading claims' watch items (Moon Drops, Barrier Support/Combo) could be neither confirmed nor cleared.

**To 04 (Analyst/Solutions):** three items.
1. **Meta-only MER 17.55x** (R1,522,112.10 Shopify `total_sales` ÷ R86,731.03 Meta spend), vs the 1.82x floor. This is an upper bound; add Google Ads spend to get true blended MER.
2. **Double-count risk.** Meta claims 798 purchases and R631,486.38 value against Shopify's 1,557 orders and R1,522,112.10 — 51.3% of orders but only 41.5% of revenue. Implied Meta AOV R791.34 vs store AOV R977.59. Reconcile before anyone treats platform-reported ROAS as incremental.
3. **The cross-brand problem is yours to resolve** — 42.5% of BoT Meta spend sells Pastry products while Pastry runs its own account and store. See the [H] finding above.

**To 05 (Keywords + Negatives):** **no Meta negatives, placement exclusions or audience exclusions were auto-applied this run**, so there is nothing of mine to avoid duplicating. The Google Ads negative-keyword candidate list cannot be built until a search-term CSV reaches `automation/inbox/` — the export steps are in Recommendation 3. The durable rules still stand and should be packaged the moment data arrives: `medicube` negated everywhere except `Shopping_All_Products_v2`; `beautytap` phrase-match; never negate protected product-type terms (face wash / face serum / face cream / review / vs).

**To 06 (Revenue Expansion):** **R0 was freed this run — nothing was paused or trimmed**, so any scaling must come from new budget, not reallocation. Seven adsets clear the 5.0x trigger (ranked in Recommendation 4); `pastry new testing ads` at 7d ROAS 12.41x / CPA R73.50 is the strongest. Three adsets are already over the R500/day escalation line and are yours to decide, not mine: `AS5_KoreanBrands` (R596.04/day), `AS6_Mixed_Store` (R535.06/day), `pastry new testing ads` (R525.02/day). Note the human already took +20% on `BOOST_BeautyOnTApp_Brands` (R2,550 → R3,060/day) on 16/07/2026 — do not count that as untapped headroom.
