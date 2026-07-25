---
agent: revenue-expansion
brand: bot
date: 2026-07-25
run_id: 06-revenue-expansion-2026-07-25
data_sources_used:
  - automation/reports/2026-07-25/01-ppc-audit-bot.md
  - automation/reports/2026-07-25/02-seo-audit-bot.md
  - automation/reports/2026-07-25/03-merchant-feed-bot.md
data_gaps:
  - "Agents 04 (Analyst) and 05 (Keywords+Negatives) did not complete this run — their synthesis and keyword/negative routing were performed directly by this agent from the 01-03 reports."
  - "Semrush unit-blocked: no organic traffic, ranking, keyword-volume or backlink data exists for today."
  - "Shopify token expired: catalogue unmeasured; BoT store revenue was captured by agent 01 before the outage (R1,522,112.10 / 1,557 orders / 28d)."
  - "No Google Ads data of any kind: no API/connector, and automation/inbox/ is empty. Google Ads spend is unknown, so no true blended MER exists."
  - "Outbound HTTPS blocked by environment network policy — no live-site verification."
---

## Summary

- **The account is not bleeding — it is underspent.** 28d Meta: R86,731.03 → 798 purchases, ROAS **7.28x**, CPA **R108.68**. The 7d window is stronger (ROAS 7.92x, CPA R103.64). Both sit far above the 5.0x scaling trigger and well under the R167 "excellent" CAC ceiling.
- **The headline decision today is a scaling decision, not a cutting one.** Nothing qualified for a pause or a trim, and the guardrails deliberately do not auto-apply budget *increases* — so the upside requires T's authorization.
- **The single biggest structural issue is brand sprawl**, and it shows up identically on the paid and organic sides: 42.5% of this account's Meta budget sells Pastry product, and three separate BoT storefront domains are live and indexed.
- **Auto-applied: none.** Meta had nothing that qualified; Shopify was unauthenticated all run.
- Today's run was degraded — three of four data sources down, and two agents did not complete. Decisions below are scoped to what was actually observed.

## Findings

### [H] The account clears the scaling trigger on every metric and is not being scaled (impact 5 / effort 2)
ROAS 7.28x (28d) and 7.92x (7d) against a 5.0x scaling trigger; CPA R108.68 against a R167 "excellent" ceiling; Meta-only MER 17.55x against a 1.82x floor. Source: `01-ppc-audit-bot`. Every winner test in `config.yaml` is met simultaneously, and the trend is improving rather than decaying.
**Owner: Meta · needs T's authorization** (budget *increases* are excluded from auto-apply by design).

### [H] 42.5% of BoT Meta spend funds Pastry Skincare creative (impact 5 / effort 3)
R36,840.33 of R86,731.03 across four Pastry adsets, driving 48.9% of the account's purchases — while Pastry runs its own ad account (R52,423.54/28d) and its own store. Combined Pastry-product prospecting across both accounts is **R65,976.49/28d**. A fifth thread (Mzuri Skin) sits in the same account. Source: `01-ppc-audit-bot`.
Two real consequences: neither brand's ROAS/MER can be cleanly attributed, and two accounts bidding the same SA beauty audience for the same products inflate each other's CPMs (*magnitude NOT VERIFIED*).
**Owner: Meta + strategy · needs T's decision.**

### [H] Three live, indexed BoT storefront domains — two with byte-identical title tags (impact 5 / effort 4)
`beautyontapp.com`, `shopbeautyontapp.co.za`, `beautyontappcos.co.za`, plus split brand naming ("BeautyOnTApp" vs "Beauty on TApp") and two App Store listings. Source: `02-seo-audit-bot`. This splits ranking authority across owned properties and makes domain→analytics mapping ambiguous, which in turn undermines any MER reconciliation.
**Owner: SEO/dev · needs T's decision.** Every other SEO action compounds on top of this, so it is the gating item.

### [M] Audience overlap is inflating frequency in BOOST_BeautyOnTApp_Brands (impact 4 / effort 2)
Campaign frequency 7.31 while no constituent adset exceeds 4.65; sum-of-adset-reach ÷ campaign-reach = 2.03 — the average person sits in ~2 of the 6 prospecting adsets. Three adsets are over the >3.5 prospecting flag. Source: `01-ppc-audit-bot` (*overlap % NOT VERIFIED* — reach arithmetic, not a measured overlap).
**Owner: Meta · auto-appliable next run** (audience exclusions are inside the guardrails) once the consolidation approach is chosen.

### [M] AS1_Visitors_7d_NoPurchase — sub-floor but recovering; hold, do not trim (impact 3 / effort 1)
28d ROAS 1.766 (below the 1.82x floor) and CPA R344.98 (above the R300 stop ceiling), **but** 7d ROAS 2.68 and CPA R238.06, with 55% of spend in the last 7 days after a human restarted it on 16/07. Source: `01-ppc-audit-bot`.
**Decision: authorize no action. Re-evaluate 01/08/2026.** Trimming a recovering entity a human restarted 9 days ago would be acting against the trend.

### [M] Catalogue unmeasured for a third consecutive day (impact 3 / effort 1)
GTIN/MPN, `google_product_category`, `product_type`, alt text and meta descriptions are all unknown — this gates Shopping/PMax eligibility. Source: `03-merchant-feed-bot`. Unmeasured ≠ healthy.
**Owner: Shopify · auto-appliable the moment auth is restored** (6 product titles + 1 collection title are already queued and ready).

## Auto-Applied Changes

none

*Meta: no entity met the pause gate (≥7d AND ≥R300 AND 0 conversions while delivering) and none met the trim gate (proven loser, not in learning). Shopify: connector unauthenticated all run. No changes were manufactured to appear productive.*

## Recommendations

1. **Authorize a budget increase on the winning prospecting adsets** (see the digest for the specific mechanic). Highest-value action available; the account has cleared every scaling test for 28 days.
2. **Decide the brand-architecture question**: should Pastry creative continue running inside the BoT account, or consolidate into the Pastry account? This is the root cause behind both the attribution mess and the self-competition risk.
3. **Decide the domain-consolidation question** and produce a 301 map — gates all further SEO work.
4. **Re-authorize Shopify** — one click, unblocks three agents and releases the queued title fixes.
5. **Install agent 07** on the local machine so Google Ads finally enters the picture; today the fleet is flying blind on the channel T asked about first.

## Handoff

**→ Tomorrow's agent 01:** re-check `AS1_Visitors_7d_NoPurchase` (hold decision expires 01/08). Watch whether frequency in `BOOST_BeautyOnTApp_Brands` responds if audience exclusions are applied.
**→ Tomorrow's agent 03:** the queued title fixes are ready; execute BoT-first, commit, then attempt Pastry.
**→ Operational:** widen the fleet stagger — two agents failed to complete inside their slots today.
