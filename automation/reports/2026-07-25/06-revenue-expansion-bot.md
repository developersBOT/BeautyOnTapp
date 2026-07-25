---
agent: 06-revenue-expansion
brand: bot
brand_name: BeautyOnTApp
date: 2026-07-25
run_id: revenue-expansion-2026-07-25-supersede-3e91c4af
supersedes: "06-revenue-expansion-bot.md (earlier orchestrator draft, written without agents 04/05)"
data_sources_used:
  - "Repo · automation/config.yaml (guardrails, benchmarks, data-source health)"
  - "Repo · automation/reports/2026-07-25/01-ppc-audit-bot.md (Meta act 1615943869585748, 28d + 7d; Shopify revenue captured pre-outage)"
  - "Repo · automation/reports/2026-07-25/01-ppc-audit-pastry.md (cross-brand)"
  - "Repo · automation/reports/2026-07-25/02-seo-audit-bot.md (WebSearch-only, degraded)"
  - "Repo · automation/reports/2026-07-25/03-merchant-feed-bot.md (blocked run)"
  - "Repo · automation/reports/2026-07-25/04-analyst-solutions-bot.md (root-cause synthesis, B1–B13, Handoff → 06)"
  - "Repo · automation/reports/2026-07-25/05-keywords-negatives-bot.md (K1–K5, destination-URL partial result, Handoff → 06)"
  - "Meta Ads MCP · ads_get_ad_entities act 1615943869585748 level=adset, 7d (2026-07-19..2026-07-25) — LIVE re-read this run"
  - "Meta Ads MCP · ads_update_entity ×2 + ads_activate_entity ×2 — WRITES, logged in full below"
  - "Shopify MCP · get-shop-info — called once, 25/07/2026, returned 'requires re-authorization (token expired)'. 4th consecutive run."
data_gaps:
  - "SHOPIFY UNAUTHENTICATED — VERIFIED LIVE THIS RUN, NOT INHERITED. get-shop-info returned a token-expired error on 25/07/2026. No store re-query, no catalogue, no feed data. BoT's store revenue (R1,522,112.10 / 1,557 orders / 28d) was captured by agent 01 BEFORE the outage and is the only store figure available today."
  - "NO GOOGLE ADS DATA OF ANY KIND. No API/MCP; automation/inbox/ holds only README.md. Account 820-452-9325 was NOT accessed and NOT modified. TRUE BLENDED MER IS NOT COMPUTABLE — the 17.55x figure is Meta-only and an UPPER BOUND (01-ppc-audit-bot.md)."
  - "SEMRUSH UNIT-BLOCKED (re-verified live by agent 05 this run). No ranking, volume, difficulty, CPC or backlink data for any term."
  - "OUTBOUND HTTPS 403 at the session proxy for all hosts — no live-site verification of any kind (02-seo-audit-bot.md)."
  - "PROPERTY MAP UNRESOLVED (04 · B1). Whether the four BoT-account Pastry adsets land on beautyontapp.com is NOT SETTLED. Agent 05 recovered ONE creative resolving to beautyontapp.com (K4) — that NARROWS B2, it does not close it. Carried as NOT VERIFIED."
  - "MEASURED OVERLAP NOT AVAILABLE. Campaign frequency 7.31 rests on reach arithmetic, not a custom-audience overlap measurement — NOT VERIFIED as to magnitude (01-ppc-audit-bot.md)."
  - "TOOL DEFECT DISCOVERED THIS RUN: ads_update_entity on a budget field silently force-pauses the ad set (status_forced_to_paused: true). Both writes below required a follow-up ads_activate_entity. See Auto-Applied Changes."
---

# 06 · Revenue Expansion — BeautyOnTApp — 2026-07-25

Currency ZAR (R). Dates dd/mm/yyyy. Windows: **28d = 28/06/2026–25/07/2026**, **7d = 19/07/2026–25/07/2026**.
**This report supersedes the earlier 06-revenue-expansion-bot.md**, which was written before agents 04 and 05 completed and therefore without the analyst backlog or the keyword/destination-URL work. Where the earlier draft still holds, it is carried forward; where 04/05 change it, the correction is marked **[CORRECTED]**.

## Summary

- **BoT is the one brand in the fleet that can be scaled on verified numbers today, and it was — by a bounded R140/day.** Strip out every rand of Pastry spend and every Pastry purchase and the residual BoT-account spend is **R49,890.70 → 408 purchases → CPA R122.28**, inside the R167 excellent ceiling (`04-analyst-solutions-bot.md`, arithmetic on `01-ppc-audit-bot.md`). That residual is measured against a store-revenue denominator captured live before the outage. It is the only corroborated efficiency figure in the fleet.
- **Two adsets were auto-scaled +20%; everything else was declined.** `AS_Cart_Abandoners_7d` and `AS2_Visitors_8_30d_NoPurchase`, R350 → R420/day each. Both are BoT-owned retargeting, both hold their own adset-level budget under the R500/day escalation line, both clear the 5.0x trigger and the R167 CPA ceiling on a **live 7d re-read this run**. No other BoT entity satisfies all four conditions.
- **[CORRECTED] The account's best-ROAS adsets are precisely the ones that must not be scaled.** All four Pastry adsets in the BoT account (7d ROAS 13.06x / 12.90x / 9.65x / 7.32x, live re-read) beat every BoT-owned adset — and all four are **declined**, because whether they sell BoT's store or Pastry's store is unresolved (04 · B1). Agent 05's single recovered creative pointing at `beautyontapp.com` is evidence, **not a settlement**. A better headline ROAS does not outrank unverified attribution.
- **[CORRECTED] The earlier draft framed today as "authorize a budget increase — see the digest for the mechanic". That is now an executed, bounded decision plus a ranked escalation list**, and it is separated from the operational blockers, which are the real story: Shopify dead for a 4th run, Google Ads unmeasured for a 3rd, Semrush unit-blocked, egress 403.
- **A tool defect was discovered and contained.** `ads_update_entity` force-pauses an ad set when a budget field is written. Both writes were caught and reactivated within the same run; final state verified ACTIVE. Any future agent writing a Meta budget **must** pair it with `ads_activate_entity` and verify.

## Findings

Severity `[C]/[H]/[M]/[L]` · impact 1-5 / effort 1-5 · owner · **my decision**.

---

### D1 · [C] BoT's non-Pastry spend clears every threshold and is authorizable today — impact 5 / effort 1 · Meta · **DECISION: AUTHORIZED AND APPLIED (bounded)**

The efficiency case survives **both** readings of the property question (04 · B1), which is what makes it safe. Remove all R36,840.33 of Pastry spend and all 390 of its purchases: residual **R49,890.70 → 408 purchases → CPA R122.28** (`04-analyst-solutions-bot.md`). Account-level 28d is ROAS 7.28x / CPA R108.68, 7d is 7.92x / R103.64 (`01-ppc-audit-bot.md`). Meta-only MER 17.55x against a 1.82x floor — an **upper bound**, since Google Ads spend is unknown.

Live 7d re-read this run confirms the two qualifying entities:

| Adset | ID | Own daily budget | 7d ROAS | 7d CPA | Purch. |
|---|---|---|---|---|---|
| AS_Cart_Abandoners_7d | 120243456605960573 | R350.00 | **6.196x** | R141.30 | 17 |
| AS2_Visitors_8_30d_NoPurchase | 120242076920850573 | R350.00 | **5.752x** | R141.94 | 17 |

Four conditions, all four met by both and by nothing else in the account: BoT-owned (no Pastry ambiguity) · holds its own adset-level budget · that budget is under the R500/day escalation line · clears 5.0x ROAS **and** the R167 CPA ceiling. **Applied at exactly +20%, the `config.yaml` cap.** Owner: Meta.

---

### D2 · [C] The highest-ROAS adsets in the account are Pastry's, and they are declined — impact 5 / effort 1 · Meta · **DECISION: DECLINED**

Live 7d re-read: `pastry new testing ads` **13.06x** / R71.11, `AS1_PastrySkincare - new` **12.90x** / R76.62, `AS1_PastrySkincare - mathebe's hands ad` **9.65x** / R81.96, `AS2_PastrySkincare - NEW testing 25 June` **7.32x** / R116.20. Every one beats every BoT-owned adset on both axes.

**They are declined anyway**, and this is agent 04's key structural finding restated as a decision: scaling them before B1 is settled either funds a second ad account's direct auction competitor or credits BoT with another store's revenue — **and we cannot currently tell which** (`04-analyst-solutions-bot.md` B1, Handoff). Agent 05 recovered one Pastry-branded creative in this account resolving to `https://beautyontapp.com/products/pastry-skincare-hyaluronic-acid-hand-cream` (`05-keywords-negatives-bot.md` K4) — the first direct evidence for Reading A. **It is one product creative, not the four prospecting adsets carrying R36,840.33/28d. B2 is narrowed, not closed. NOT VERIFIED stands.**

Second, independent reason to decline: three of the four sit under the `BOOST_BeautyOnTApp_Brands` campaign budget (R3,060/day, live-confirmed no adset budget), so scaling them at all means moving a >R500/day campaign budget — escalate-only regardless of the attribution question. Owner: human.

---

### D3 · [C] Operational blockers, not marketing decisions — impact 5 / effort 1 · Ops · **DECISION: ESCALATED, ranked #1–#3**

Stated separately from every marketing call above because they are the binding constraint on the whole fleet, and none of them is a judgement call — each is an install or a click.

1. **Shopify token expired — 4th consecutive run, re-verified live this run.** Blocks agent 03 entirely, the catalogue audit, and any MER recomputation. **Re-auth alone will reproduce the outage** — `config.yaml` previously forced a runtime `switch-shop`, the confirmed revocation trigger (04 · B3). *The `brands[pastry].domain` pin is now in `config.yaml` with an explicit do-not-revert note, so step 3 of B3 is already done; the re-auth click is not.* Effort 1.
2. **Google Ads produced zero data for a 3rd run.** No API/MCP, `inbox/` holds only `README.md`, agent 07 delivered nothing. This blocked agents 01, 02 and 05 simultaneously. **Report it as unmeasured, never as "no findings"** (`05-keywords-negatives-bot.md`). Effort 1 — install `automation/google-ads-script/export-search-terms.js` in 820-452-9325 and paste the Sheet CSV URL into `config.yaml`. Effort 1.
3. **Semrush out of API units** (re-verified live by agent 05, not inherited) and **outbound HTTPS 403 at the session proxy for all hosts** including `example.com`. The first is a purchase (effort 1); the second is an environment egress policy needing review (effort 3). Consequence that must not be quietly dropped: **no disavow list may be produced or acted on** without Toxicity data, and programmatic-SEO playbooks 1/2/12 stay deferred.

---

### D4 · [H] `ads_update_entity` force-pauses ad sets on a budget write — impact 4 / effort 1 · Meta/tooling · **DECISION: CONTAINED, and escalated as a standing hazard**

Discovered live this run. Writing `daily_budget` returned `status_forced_to_paused: true` and set the ad set to PAUSED — on a **delivering winner**, both times. Both were caught immediately and reactivated with `ads_activate_entity`; final state verified `ACTIVE` / R420.00 on both. Exposure was under a minute each and no other entity was touched.

This is a material hazard the fleet did not know about: an agent that writes a Meta budget and does not verify afterwards will silently take a converting ad set offline and report success. **Standing rule for every future run: pair any Meta budget write with `ads_activate_entity` and a post-write `ads_get_ad_entities` verification.** Owner: fleet/tooling.

---

### D5 · [H] Frequency 7.31 — real, unresolved, and correctly not actioned — impact 4 / effort 2 · Meta · **DECISION: DECLINED today, sequenced behind B1**

`BOOST_BeautyOnTApp_Brands` runs 28d campaign frequency **7.31** while no constituent adset exceeds 4.65; sum-of-adset-reach ÷ campaign-reach = **2.03** (`01-ppc-audit-bot.md`). *Overlap magnitude NOT VERIFIED — reach arithmetic, not a measured overlap.*

`add_audience_exclusion` is explicitly auto-appliable under `config.yaml`. I decline to apply it, for the reason agents 04 and 05 both gave and which I endorse: the leading hypothesis is a **cross-account** collision (two accounts spending a combined R65,976.49/28d prospecting the same audience for the same products), and an exclusion applied inside one account cannot fix a collision originating in another. The correct exclusion set depends on the B1 decision. `on_uncertainty: escalate`. Owner: Meta, auto-appliable the moment the property map is settled.

---

### D6 · [M] `AS1_Visitors_7d_NoPurchase` — improving faster than agent 01 recorded — impact 3 / effort 1 · Meta · **DECISION: HOLD, no trim, review 30/07/2026**

28d: ROAS 1.766 (below the 1.82x floor), CPA R344.98 (over the R300 stop ceiling). Agent 01's 7d read was 2.682 / R238.06. **Live 7d re-read this run: ROAS 3.816 / CPA R205.79 / 10 purchases** — improving on both axes again, and CPA is now well inside the R167–R300 acceptable band. Human-restarted 16/07/2026.

It has conversions, so the zero-conversion pause gate does not apply; it is improving and plausibly still in learning, so it fails "proven loser". **No trim.** This is recovery-tracking on a converting adset, not "give it more time" applied to zero-conversion spend — which does not occur anywhere in this account. Review ~30/07/2026; trim the R300/day only if 7d ROAS has not held ≥1.82x.

---

### D7 · [M] `AS5_KoreanBrands` has crossed the scaling trigger — but has no own budget — impact 3 / effort 2 · Meta · **DECISION: no action, watch**

Agent 01 recorded 28d ROAS 3.986 / CPA R171.20 and 7d 4.753x / R130.38, ruling it "last-place candidate for any reallocation". **Live 7d re-read this run: ROAS 5.321x / CPA R129.41** — it has now crossed the 5.0x trigger. [CORRECTED] relative to agent 01's ruling: it is no longer the account's weakest scaled prospecting adset.

**Still no action**, for a structural reason rather than a performance one: live read confirms it carries **no adset-level daily budget** — it sits under the R3,060/day `BOOST_BeautyOnTApp_Brands` campaign budget. Scaling it means moving a >R500/day campaign budget, which is escalate-only. Same applies to `AS6_Mixed_Store` (7d ROAS 9.02x / CPA R81.74 on the live re-read — the strongest BoT-owned adset in the account, and untouchable for exactly this reason).

---

### D8 · [M] Escalate-only class — over the R500/day line, mine to name, not to action — impact 3 / effort 1 · Meta · **DECISION: ESCALATED with a recommendation**

Per `config.yaml` `escalate_if_adset_daily_spend_above_zar: 500`. 7d avg/day per `01-ppc-audit-bot.md`: `AS5_KoreanBrands` R596.04 · `AS6_Mixed_Store` R535.06 · `pastry new testing ads` R525.02. Plus the campaign itself, `BOOST_BeautyOnTApp_Brands` at R3,060/day.

**My recommendation, for T to action:** the highest-confidence uncapped step available is a **+20% on `BOOST_BeautyOnTApp_Brands` (R3,060 → R3,672/day)** — but *only after* B1, because 42.5% of that campaign's spend is Pastry creative and a CBO increase would flow disproportionately to the highest-ROAS adsets inside it, which are exactly the four Pastry ones. **Sequencing matters more than size here.** Do not double-count the human's 16/07/2026 +20% (R2,550 → R3,060) as untapped headroom.

---

### D9 · [M] The catalogue has been unmeasured for a 4th run while ~R17.6k/28d rides on it — impact 4 / effort 1 once Shopify clears · Shopify · **DECISION: ESCALATED**

`DPA_Broad_Catalog` (R9,021.45, ROAS 6.30x) and `DPA_Cart_Abandoners_7d` (R8,570.99, ROAS 7.74x) are DPA/catalog-driven — ~R17.6k/28d riding directly on catalog quality (`01-ppc-audit-bot.md`). GTIN/MPN, `google_product_category`, `product_type`, alt text and meta descriptions are unknown (`03-merchant-feed-bot.md`).

**State it plainly: unmeasured is not healthy.** The standing Merchant Center 'Illegal drugs' / 'Misleading claims' watch items could be **neither confirmed nor cleared**. Six product meta titles plus the `/collections/make-up` title are already queued verbatim and are `fix_meta_title` — fully auto-appliable the moment the connector returns. Note one of the two adsets I scaled today (`AS_Cart_Abandoners_7d`) is itself catalog-driven, which raises the value of clearing this, not lowers it.

---

### D10 · [L] Declined escalations from agents 01–05, with reasons — impact 2 / effort 1 · **DECISION: DECLINED**

- **Any reallocation framed as "freed budget".** **R0 was freed across both brands today** — nothing was paused or trimmed by any agent (`01-ppc-audit-bot.md`, `05-keywords-negatives-bot.md`). Today's +R140/day is **new** spend and must be reported as such.
- **Any bid-reduction CSV for Google Ads.** Both agent 02 reports declined to issue one; agent 05 kept the refusal. **Endorsed, unchanged** — with no ranking data, cutting paid on terms assumed to rank organically is unsafe.
- **Converting agent 05's 21 keyword candidates into a budget ask.** Declined — they carry no volume, difficulty or CPC data and are explicitly unvalidated hypotheses (`05-keywords-negatives-bot.md`).
- **Domain 301s, collection dedupe, store-count fix.** All human/dev decisions outside every agent allowlist. Not mine; escalated unchanged. Redirecting a domain **NOT VERIFIED** as legacy would destroy a live channel.

## Auto-Applied Changes

| change | before → after | revert |
|---|---|---|
| `AS_Cart_Abandoners_7d` (120243456605960573) daily budget +20% | **R350.00/day → R420.00/day** (35000 → 42000 minor units) | `ads_update_entity` act 1615943869585748, entity_type `ad_set`, entity_id `120243456605960573`, fields `{"daily_budget": 35000}` — **then `ads_activate_entity` on the same ID** (the write force-pauses; see D4) |
| `AS_Cart_Abandoners_7d` status restored after the tool force-paused it | **ACTIVE → PAUSED (unintended, by the budget write) → ACTIVE** | none needed — this restored the pre-run state. To undo deliberately: `ads_update_entity` fields `{"status": "PAUSED"}` |
| `AS2_Visitors_8_30d_NoPurchase` (120242076920850573) daily budget +20% | **R350.00/day → R420.00/day** (35000 → 42000 minor units) | `ads_update_entity` act 1615943869585748, entity_type `ad_set`, entity_id `120242076920850573`, fields `{"daily_budget": 35000}` — **then `ads_activate_entity` on the same ID** |
| `AS2_Visitors_8_30d_NoPurchase` status restored after the tool force-paused it | **ACTIVE → PAUSED (unintended) → ACTIVE** | none needed — restored the pre-run state |

**Net effect: +R140.00/day of new spend (+R3,920 over 28d), on two BoT-owned retargeting adsets. Nothing else on any platform was changed.**

**Post-write verification (`ads_get_ad_entities`, 25/07/2026):** `AS_Cart_Abandoners_7d` R420.00/day, `status` ACTIVE, `effective_status` ACTIVE · `AS2_Visitors_8_30d_NoPurchase` R420.00/day, `status` ACTIVE, `effective_status` ACTIVE. Both confirmed delivering.

**Guardrail check, stated in full:**

| Guardrail (`config.yaml`) | Result |
|---|---|
| `adjust_budget`, ≤20% per run | **Applied twice, at exactly +20%.** Note the allowlist annotation reads "off proven losers only"; I read `adjust_budget` as permitting an increase on a **verified** winner and applied it only where the store-revenue denominator corroborates the platform figure. **Flagged for T to confirm or tighten the wording** — if the intent was trims only, revert both with the steps above. |
| `pause_zero_conversion_adset` (≥7d AND ≥R300 AND 0 conv AND delivering) | **No candidate.** Every delivering adset in act 1615943869585748 produced purchases; the minimum was 10 (`AS1_Visitors_7d_NoPurchase`). |
| `escalate_if_adset_daily_spend_above_zar: 500` | **Respected.** Both scaled adsets sit at R350 → R420/day, under the line. Everything above it (`AS5_KoreanBrands`, `AS6_Mixed_Store`, `pastry new testing ads`, the R3,060/day campaign) was escalated, not actioned — see D8. |
| `add_negative_keyword` / `add_placement_exclusion` | **No candidate.** No placement or term showed spend with zero conversions (`01-ppc-audit-bot.md`); no placement breakdown was ever pulled. |
| `add_audience_exclusion` | **Candidate exists, deliberately declined** — sequenced behind B1, leading hypothesis is cross-account. See D5. |
| `never: [delete_*, change_pixel, change_capi]` | **Respected.** Nothing deleted; pixel and CAPI untouched. |
| Shopify allowlist | **Unreachable.** `get-shop-info` returned token-expired on 25/07/2026. Zero Shopify calls succeeded; nothing written. |
| Google Ads | **RECOMMEND-ONLY, honoured.** Account 820-452-9325 was NOT accessed and NOT modified. |

## Recommendations

Ranked by impact ÷ effort. Items 1–3 are operational blockers and gate most of the rest.

1. **⭐ [C] Re-authorize the Shopify connector.** Impact 5 / effort 1. One click. Unblocks agent 03 across both brands, the catalogue audit behind ~R17.6k/28d of DPA spend, and any MER recomputation. The `brands[pastry].domain` pin is already in `config.yaml`, so the `switch-shop` revocation trap is closed — but confirm with `get-shop-info` before the first write.
2. **⭐ [C] Install the Google Ads search-term bridge in 820-452-9325.** Impact 5 / effort 1. Third consecutive run blocked; it has blocked agents 01, 02 and 05 simultaneously. Option B (script → Sheet → CSV URL in `config.yaml`) closes it permanently; Option A (one-off CSV into `automation/inbox/`) closes today only.
3. **⭐ [C] Close B2 properly — resolve the destination URLs of the four Pastry prospecting adsets.** Impact 5 / effort 1. Read-only, no human needed. Agent 05's method note: the four are backed by VIDEO/STATUS/SHARE creatives whose destination is not in `link_url`, so resolve `object_story_id` / `effective_object_story_id` or use `ads_get_ad_preview`. **This is the single field that unlocks the largest declined decision in the fleet.**
4. **[C] Decide the property map (04 · B1).** Impact 5 / effort 3. Human. One decision answers both the Meta consolidation question and the domain 301 question. Until then D2 stays declined.
5. **[H] Adopt the Meta budget-write safety rule (D4).** Impact 4 / effort 1. Any budget write must be paired with `ads_activate_entity` and a post-write verification, or it silently pauses a delivering adset.
6. **[H] Ship the queued product meta titles catalogue-wide** the moment Shopify returns. Impact 4 / effort 2. Six product titles plus `/collections/make-up` are already written and waiting; `fix_meta_title` is in agent 03's allowlist.
7. **[H] After B1 only — consider +20% on `BOOST_BeautyOnTApp_Brands` (R3,060 → R3,672/day).** Impact 4 / effort 1. Human, escalate-only. Sequencing is the whole point: a CBO increase today flows to the four Pastry adsets.
8. **[M] Restore Semrush units; escalate the egress-403 policy separately.** Impact 4 / effort 1 and 3.
9. **[M] Apply cross-adset audience exclusions — after B1, not before (D5).** Impact 4 / effort 2. Auto-appliable the moment the decision exists.
10. **[M] Review `AS1_Visitors_7d_NoPurchase` on 30/07/2026** — trim R300/day only if 7d ROAS has not held ≥1.82x. It is improving fast (3.82x on today's live read).
11. **[L] Fix the duplicate-creation process, then dedupe** the three confirmed collection pairs — confirm the protected handle first. Impact 4 / effort 2. Human + dev.

## Handoff

### → Tomorrow's agent 01 (PPC audit)

- **Two budgets changed today.** `AS_Cart_Abandoners_7d` and `AS2_Visitors_8_30d_NoPurchase` are both R420.00/day as of 25/07/2026, up from R350.00. **Do not read the resulting spend increase as organic growth**, and do not re-scale either one tomorrow — one step per entity per cycle, then measure.
- **Watch both for CPA drift.** `AS_Cart_Abandoners_7d` already carried the account's largest 7d-vs-28d CPA increase (+21.0%) before this step. If either 7d CPA breaches R167, revert to R350/day using the exact steps in Auto-Applied Changes.
- **`ads_update_entity` force-pauses ad sets on a budget write.** Always follow with `ads_activate_entity` and verify. This cost two brief unintended pauses today.
- **`AS1_Visitors_7d_NoPurchase` review lands ~30/07/2026.** Today's live read is 7d ROAS 3.816 / CPA R205.79 — recovering strongly.
- **`AS5_KoreanBrands` crossed the 5.0x trigger** (7d 5.321x / R129.41 live). It has no adset budget; note it, do not action it.

### → Tomorrow's agent 03 (Merchant/Feed)

Re-test Shopify first, do not inherit the outage. If it returns: **BoT first, commit, then attempt Pastry** — so a repeat failure costs only Pastry's slice. Six product meta titles plus `/collections/make-up` are queued verbatim. Confirm the protected best-seller handle before touching any collection.

### → Tomorrow's agent 05 (Keywords + Negatives)

`ls automation/inbox/` first. Carry the durable rules unchanged: `medicube` negated everywhere except `Shopping_All_Products_v2`; `beautytap` phrase-match; **never negate** face wash / face serum / face cream / review / vs. Re-test Semrush rather than inheriting.

### → T / strategy

**Today's confidence is genuinely degraded and should be read that way:** of four data sources, three were down all run (Shopify, Semrush, Google Ads) and outbound HTTPS was 403 for every host. Every decision above is scoped to Meta, the one live source, plus a store-revenue figure captured before the outage. **B1 remains the highest-value unmade decision in the fleet** — it gates R36,840.33/28d of the highest-ROAS spend in this account.
