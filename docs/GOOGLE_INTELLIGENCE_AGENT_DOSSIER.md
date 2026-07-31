# Google Intelligence & Agent Upgrade Dossier — G0–G10 Fleet

**PNCapital · BeautyOnTApp + Pastry Skincare · Compiled 2026-07-31 · Investigation-only (no account, campaign, tracking, Merchant Center, Shopify, GBP, website or scheduler changes were made)**

---

## 0.1 What this is

The definitive, source-backed intelligence baseline for the Google Co fleet (G0–G10) across the entire Google ecommerce ecosystem: Google Ads, the Ads API/automation surface, conversion measurement, GA4, Merchant Center & Merchant API, the Shopify Advanced integration boundary, Search Console & organic search, Google Business Profile, AI Overviews/AI Mode, competitive/auction intelligence, and the policy + South African statutory overlay. Each domain section states what the fleet must **know** (verified current platform facts), **verify live** (account-specific facts documents cannot answer), **decide** (T-level decision points), **execute** (who may act, within what authority), and **never do**.

## 0.2 Research provenance & method

- Produced by a 20-agent research workflow (11 domain researchers → adversarial verification pass → completeness critic → 4 gap-fill researchers; ~1.54M tokens, 477 tool calls), plus main-loop spot-verification of the most load-bearing dates.
- **Method caveat (material, disclosed everywhere it applies):** the research sandbox's egress proxy denied direct fetches of Google documentation hosts (support.google.com, developers.google.com, blog.google, status.search.google.com) throughout the session. The working evidence channels were: server-side web-search retrieval of official page content, Shopify's own docs index (shopify.dev — fully fetchable), Google's machine-readable API discovery documents and package registries (fetchable), and GitHub code search. Several later agents also ran after the workflow's search budget was exhausted; their sections are honestly labeled as training-baseline (knowledge cutoff Jan 2026) and carry explicit re-verification queues.
- Adversarial verification ran on four domains (32 claims): all 8 Shopify-integration claims CONFIRMED against live shopify.dev pages; GBP claims verified against Google's live API discovery endpoints (3 confirmed, 5 refuted-with-corrections — corrections are incorporated); two verifiers were themselves network-blocked (verdicts recorded as environment-blocked, not refutations, and the headline claims were independently re-confirmed by main-loop searches where possible).
- **Standing infrastructure finding:** this fleet's sandbox cannot fetch Google documentation or the Search Status Dashboard directly. G0 must route documentation monitoring through search-based fallbacks, and a fetch failure must never be reported as "no change/no update." Recommendation to T: allowlist support.google.com, developers.google.com, blog.google, status.search.google.com in the egress policy before the next dossier refresh.

## 0.3 Evidence legend (used on every claim)

| Tag | Meaning |
|---|---|
| **P✓** | PRIMARY — official Google/Shopify page or machine-readable endpoint whose content was retrieved this session |
| **P~** | PRIMARY page identified; content corroborated via search-retrieved snippets or consistent secondaries — treat as LIKELY |
| **S** | SECONDARY — trade press, vendor docs, community threads; used only for observed behaviour, bugs, workarounds; never overrides primary sources |
| **NV** | NOT VERIFIED — training-baseline or unconfirmable this session; explicitly queued for re-verification |
| **[AV✓] / [AV✗→corrected] / [AV⊘]** | Adversarial verifier verdict: confirmed / refuted with correction incorporated / verifier network-blocked (not a refutation) |

Volatile account facts (budgets, ceilings, prices, per-campaign metrics, integration states, product states) are **never asserted in this dossier** — they are routed to the "Must verify live" lists, per standing fleet law. Where the account's own history is cited, the source is the PNCapital skill library, marked `[source: skill library]`.

## 0.4 How to use this dossier

1. **G0 first:** run the Critical Deadline Register (§1) — four hard deadlines land within 30 days of compilation.
2. **Each agent:** read your upgrade brief (§14) plus your primary domain sections; fold every "Must verify live" item into your standing checklists.
3. **G9:** nothing in this dossier expands your authority. The Authority & Execution Matrix (§2) restates the boundary; several 2025–2026 platform changes (auto-apply surfaces, Ads Advisor, AI Max enablement prompts) are new ways to accidentally breach it.
4. **Re-verification:** every NV/P~ claim that becomes load-bearing for a decision must be re-verified at point of use. This dossier is a baseline, not a permanent oracle — the Ads API alone now ships monthly.

---

## 1. Critical deadline register (fleet-wide, chronological)

**Four hard external deadlines land within 30 days of compilation (2026-07-31). These outrank all routine work.**

| Date | Event | Evidence | Impact | Owner / action |
|---|---|---|---|---|
| **2026-08-05** | Google Ads API **v21 sunset** — all v21 requests fail (v20 already dead 2026-06-10) | P~ ads-developers blog | Any integration pinned to v21 breaks (Analyzify, Simprosys, connectors, scripts) | G0: complete the API-version census in §B3 BEFORE this date |
| **2026-08-11** | **Internal escalation trigger**: Simprosys Merchant API confirmation deadline (one week before Content API sunset) | Fleet-set | Without written vendor confirmation, T must prepare fallback feed (scheduled fetch/file — unaffected by the sunset) | G3 obtains confirmation; G9 escalates to T if absent |
| **2026-08-17** | **Smart Bidding change**: budget-limited tCPA/tROAS campaigns (Search, Shopping, PMax, Demand Gen) begin delivering AT target instead of overperforming; Bid Target Adjustment Tool live since 2026-07-06. Same day: Smart Bidding Exploration expands to PMax | P✓ answer/17061251 | Every budget-limited campaign currently beating its target regresses to the stated target | G1: inventory + record actuals vs targets NOW; G9: execute T-approved target resets before the date; G0: confirm Exploration not silently enabled |
| **2026-08-18** | **Content API for Shopping hard shutdown** — Merchant API only | P✓ (dossier re-search of developers.google.com + deprecation banner in live discovery doc) | If Simprosys hasn't migrated, the product feed dies; API-submitted products expire ~30 days after last sync → catalog decay from late Aug, gone by mid-Sept; ALL Shopping/PMax serving stops | G3 verify THIS WEEK (§E3); G0 daily feed-freshness watch through September |
| **2026-08-26** | **Shopify non-Plus TY/OSP turn-off**: Additional scripts + ScriptTags on Thank-you/Order-status pages stop executing; unupgraded stores force-upgraded, customizations deleted | P✓ shopify.dev [AV✓] | Any legacy tracking remnant dies; measurement discontinuity window around the migration | T executes upgrade; G0/G7 verify `typOspPagesActive` + capture Additional-scripts contents NOW; G9 freezes bid/budget judgments across the window; G1 annotates |
| **2026-09-01** | Automatically created assets + campaign-level broad-match setting fold into **AI Max** (NOT delayed, unlike DSA) | S searchengineland [P~ blog.google] | Affected Search campaigns get AI Max behaviour silently | G0: inventory exposure in August; T decides deliberately |
| **Sept 2026** | Shopping ads + free-listings policies consolidate into one policy set | S seroundtable | Policy citation URLs churn; no substantive rule changes claimed | G0/G3 refresh links |
| **Q3 2026** (expected, unofficial) | Next Google core update by cadence | S (dashboard record) | Organic volatility | G0 watch via search fallback; G8 annotate |
| **~Oct 2026** | Ads API v22 sunset; v26 release expected (monthly cadence) | P~ | Version churn continues | G0 rolling census |
| **2027-01-31** | Merchant Center **500×500px minimum image** enforcement (warnings live since 2026-04-14); also last month for new-DSA creation | P~ answer/16989427; S | Sub-minimum images disapproved | G3 audit warning list now; T executes replacements |
| **2027-02-01** | DSA auto-migration to AI Max begins (delayed from Sept 2026) | S searchengineland | Only if any DSA exists (expected: none — confirm) | G0 |

**Standing clocks (no single date):**
- **6-month policy-appeal window** (since 2026-07-21): in-account appeals impossible for decisions older than 6 months — G0 flags every disapproval at ~5 months (S ppc.land/seroundtable).
- **Merchant Center ToS acceptance prompt** (rolling since 2026-06-15, expanded AI data usage): surface to T; never agent-accepted (S — NV single-source).
- **Monthly:** G0 reads the Google Ads policy change log (via search fallback — the 2025–26 log was unreadable this session, so the fleet's policy baseline is stale until pulled).
- **Quarterly:** G10/G1 recheck the ads-in-AI-Overviews country list for ZA addition (Kenya + Nigeria already live) (P✓ answer/16297775).
- **Already in force, verify state once:** enhanced-conversions ECW+ECL merged into one toggle (Jun 2026); ad_storage = sole GA4→Ads consent authority (2026-06-15); Customer Match & offline-conversion uploads blocked for new tokens (Apr/Jun 2026 — Data Manager API is the only path, T-reserved); Editor ≤2.9 unsupported (2026-03-30); Merchant API v1beta dead (2026-02-28); member-price ban (2025-07-01); Misrepresentation pricing-transparency update (2025-10-28); Shopify Scripts sunset (2026-06-30); merchant-owned delivery-profile APIs deprecated for market-driven shipping (2026-07-01).

---

## 2. Stable fleet constraints and the Authority & Execution Matrix

### 2.1 Stable constraints (restated from fleet law; this dossier's research confirms or sharpens each)

| # | Constraint | 2026 sharpening from this dossier |
|---|---|---|
| 1 | Judge on **Conversions**, never All conversions | Matches Google's documented semantics exactly (§C1). Three drift vectors now guarded: custom goals can pull SECONDARY actions into the column; engaged-view conversions sit INSIDE it on video inventory; the VTC-optimized-bidding checkbox (2026 beta) changes its meaning — never enable. |
| 2 | **Purchase is the only Primary** conversion | Necessary but not sufficient — no campaign may carry a custom goal containing a secondary action; GA4 imports stay Secondary forever; Google-hosted GBP local actions must show 0 campaigns / 0 Conversions-column counts every audit (§C). |
| 3 | Campaign goals **campaign-specific and Purchase-only** | Campaign-specific goals override account defaults and stop inheriting account-level changes — audits must be per-campaign, account-level checks prove nothing (§C1). |
| 4 | **KS_C8_Brand_Protection stays enabled** | Unchanged. Note 2026-08-17 bidding change applies if it is budget-limited on tCPA (§A2). |
| 5 | BoT stocks Medicube → **never account-wide Medicube negative** | Unchanged; G5's PMax negatives expansion (10,000 cap) must respect it. |
| 6 | **No free-delivery advertising** | Policy-grounded (Misrepresentation/unavailable-offers + CPA s41). Now also enforceable against Google-GENERATED text via text-guidelines term exclusions (global beta since 2026-02-26) — recommend T configures them (§A). Free-over-threshold belongs ONLY in MC shipping settings. Applies to GBP posts, Q&A, feed text, AI-citation content. |
| 7 | **Analyzify v4 owns tracking; Simprosys is feed-only** | Simprosys ships optional conversion-tracking/remarketing modules — recurring audit confirms OFF. The Google & YouTube channel remains uninstalled; Google actively pushes reinstall via tag-migration prompts quoting the 2026-08-26 deadline — every prompt is reported to T, never accepted (§F). |
| 8 | **Shopify Advanced, not Plus** | Hard ceiling verified: no in-checkout customization, no custom Function apps, no Scripts; TY/OSP blocks + web pixels + checkout editor are the surface (§F1). |
| 9 | Volatile figures from **Business Facts / live evidence only** | This dossier asserts zero volatile account figures; all are routed to Must-verify-live lists. |

### 2.2 Authority & Execution Matrix

**G9 — sole executor, scope = verified, reversible Google Ads changes:**
- "Reversible" now has a hard technical definition: undoable within the 30-day change-history undo window; **no undo exists via API, and some changes are never undoable** — anything G9 cannot undo within 30 days is outside its authority (§B1). G9 logs its own change_event fingerprint after every executed change.
- In scope (with T-approved recommendation packs where flagged): budget moves ≤20% per step on 5–7-day cadence, pause/enable of non-protected campaigns, bid-target adjustments (incl. the pre-2026-08-17 reset wave), negatives/negative lists (respecting constraints 5 and the no-broad-product-type-negatives rule), reversible campaign-setting corrections.
- Explicitly OUT of scope even though the UI offers them: enabling AI Max / Smart Bidding Exploration / promotion mode / VTC-optimized bidding / NCA goals; starting experiments (they lock asset groups); accepting ANY auto-apply recommendation or Ads Advisor conversational apply; conversion/goal/attribution/window changes; brand-database requests; trademark complaints; MC ToS acceptance.

**T-reserved (unchanged, and expanded by 2025–26 platform shifts):** tracking, GA4, Analyzify, conversion actions, consent mode, billing, policy appeals, new campaign structures (incl. any Demand Gen launch), Merchant Center writes (feed methods, supplemental sources, automations toggles, ToS), Shopify writes (TY/OSP upgrade, pixels, theme, robots.txt), GBP writes, non-Ads platforms, Customer Match / Data Manager API uploads, Google tag gateway / sGTM, brand requests, trademark/ARB actions, agentic-commerce opt-ins (UCP/AP2/buy-for-me), GCR survey snippet (it's a tracking tag).

**All other agents (G0–G8, G10): read-only + spec/propose.** The recommended standard read path is Google's official read-only Ads MCP server (GAQL-only, structurally cannot mutate — §B1); token tier likely needs Basic for fleet volume.

**New 2025–26 bypass hazards the matrix must police (all documented in §B):**
1. Auto-apply recommendations — no master off-switch; G0 audits subscriptions + change_event(GOOGLE_ADS_RECOMMENDATIONS_SUBSCRIPTION) monthly, expects zero.
2. Ads Advisor / Ask Advisor — live in all English-language accounts since Dec 2025; conversational applies bypass change control; observation only.
3. AI Max enablement prompts on Search (GA since 2026-04-15) and Standard Shopping (rolling out since 2026-07-24) — structural changes behind a one-click UI.
4. "Missed Opportunities" tab (promoted to main Recommendations tab ~2026-07-21) — upsell surface, not a performance signal; optimization score measures alignment with Google's suggestions, not business results.
5. Google & YouTube app tag-migration prompts in Ads/MC UIs — reinstall trap (§F).

---

## A. Google Ads campaign platform — current state (G1, G5, G6, G9 primary; G0 sentinel)

### A1. Must know — verified platform facts

**Performance Max controls (transparency era is over — PMax is now auditable):**
- Campaign-level negative keywords are GA on all PMax campaigns; the cap was raised from 100 to 10,000 per campaign during the 2025 rollout. They suppress **Search and Shopping inventory only** — never YouTube, Display, Gmail, Discover or Maps inventory inside PMax (P✓ support.google.com/google-ads/answer/15726455) [AV⊘].
- Shared **negative keyword lists** can now be attached to PMax campaigns (2025), and device targeting + age-based demographic controls are fully available in PMax (P✓ support.google.com/google-ads/answer/16451273) [AV⊘].
- Account-level negative keywords (cap 1,000, Admin → Account settings) auto-apply to Search and Shopping inventory across Search, PMax, Shopping, App, Smart and Local campaigns — a separate budget from the 10,000 per-PMax cap (P✓ support.google.com/google-ads/answer/11396330).
- PMax **brand exclusions** run on brand lists and cover Search, Shopping and YouTube Search inventory only; exclusions beat inclusions when both are applied; a retail-specific exception can keep Shopping ads serving on excluded-brand queries while blocking text ads. Brand lists auto-cover misspellings and variants — do not enumerate them as negatives (P✓ support.google.com/google-ads/answer/14505308; see also answer/13721847).
- The **channel performance report** is live for all PMax campaigns: per-channel drill-down (Search, YouTube, Display, Gmail, Discover, Maps), format breakdowns, per-channel diagnostics, downloads; beta at GML 2025 then GA (P✓ support.google.com/google-ads/answer/16260130) [AV⊘]. It is reporting only — no channel opt-outs exist in PMax (consistent across sources but not verbatim on the retrieved page — LIKELY).
- The **PMax search terms report** now has full Search/Shopping-grade granularity, in UI and API, including non-converting terms (P✓ support.google.com/google-ads/answer/16327396) [AV⊘]. Combined with 10,000 negatives, a full SQR→negatives pipeline on PMax is now possible.
- **Asset-group reporting** now carries conversions and conversion value (asset group, asset, and asset-association reports), plus Ad Strength and audience per group; "Network (with search partners)" segmentation is available. Counting trap: **every asset in a converting ad receives full credit** — asset-level conversions structurally overcount vs asset-group/campaign level (P✓ support.google.com/google-ads/answer/15235796) [AV⊘].
- **Customer lifecycle goals** matured: new-customer acquisition (bid-higher vs new-customers-only; New Customer Value mode recommended for purchase-goal advertisers; "New Customers (High Value)" mode reportedly out of whitelist beta — that sub-claim is S/LIKELY — requiring purchase goals + Customer Match ≥1,000 active users + defined incremental value) (P✓ support.google.com/google-ads/answer/12080169) [AV⊘]; customer **retention goal** with Re-engagement and High Value Re-engagement modes plus image controls and a CAC reporting column (P✓ support.google.com/google-ads/answer/16127398; answer/14792043) [AV⊘ — out-of-beta status unproven, verify in account].
- **URL controls:** Final URL expansion now sits under "asset optimization"; URL exclusions and "contains" rules scope it. Page-feed behaviour: FUE ON → page feed does NOT restrict serving; FUE OFF → PMax serves ONLY page-feed/asset-group URLs (P✓ support.google.com/google-ads/answer/14337539; answer/14337773; answer/13568488).
- **PMax experiments** available: asset testing; A/B asset tests (beta); performance-uplift (PMax alongside existing campaigns); Standard Shopping vs PMax head-to-head (P✓ support.google.com/google-ads/answer/12997711; answer/13825980).
- Google now maintains official PMax evaluation guidance pages (answer/16279166 "Evaluate Performance Max Results"; answer/14587068 FAQ) — reference targets for G1/G8 (NV — titles surfaced, bodies not retrieved).

**PMax vs Standard Shopping serving:**
- PMax **no longer automatically outranks** Standard Shopping for the same products in the same account — the higher Ad Rank wins; Standard Shopping High/Medium/Low priority arbitrates only BETWEEN Standard Shopping campaigns (S producthero.com + multiple agencies, rolled out Q4 2024→2025; no Google page retrieved — LIKELY). Any playbook line assuming "PMax eats Shopping" is stale; overlap is now auction competition.

**AI Max — the biggest structural shift on Search/Shopping:**
- AI Max for Search = a feature suite ON existing Search campaigns (not a campaign type): Gemini-driven search-term matching beyond keywords, AI text customization, final-URL expansion. Enablement can run as a built-in one-click 50/50 experiment (P~ support.google.com/google-ads/answer/15910187; beta May 2025). Google's uplift claims (~14%; 27% for exact/phrase-heavy) are marketing claims.
- AI Max for Search hit **GA globally on 2026-04-15** — all advertisers, all languages, ZA included, no spend minimums (S ppcnewsfeed.com + corroborating secondaries — LIKELY).
- **Brand controls folded into AI Max from 2025-05-27** [AV⊘ — exact date unre-verified]: existing brand lists keep working, but creating a NEW brand list on a Search campaign now requires enabling AI Max. In AI Max: brand inclusions = campaign/ad-group level; brand exclusions = campaign level; a 3-option "Branded Searches" panel is in test (S — LIKELY) (P✓ support.google.com/google-ads/answer/14453047; setup answer/15909989).
- **Text guidelines / term exclusions** for AI-generated ad text: global beta since 2026-02-26 across AI Max and PMax (S ppc.land — LIKELY). This is the enforcement mechanism for the fleet's no-free-delivery rule against Google-generated copy.
- **AI Max for Shopping** announced 2026-04-30 (closed beta); broader rollout to Standard Shopping campaigns **began 2026-07-24 — active right now** (S ppc.land; Google announcement page identified but not fetched — LIKELY). Watch every Standard Shopping campaign for enablement prompts.
- **DSA sunset into AI Max — delayed:** auto-migration moved from Sept 2026 to **Feb 2027**; new DSA creation ends Jan 2027; voluntary migration window Jun 2026–Jan 2027. EXCEPTION: automatically created assets (ACA) and the campaign-level broad-match setting still fold into AI Max **Sept 2026** (S searchengineland.com 480049 — LIKELY; Google pages identified not fetched).

**Search fundamentals:**
- **Broad match defaults ON** for new Search campaigns using conversion-based Smart Bidding (since Jul 2024, S/LIKELY for the date): the campaign-level "broad match keywords" setting converts ALL keywords in the campaign to broad regardless of entered match type (P✓ support.google.com/google-ads/answer/13389795). This setting transitions into AI Max Sept 2026.
- RSA: 15 headlines / 4 descriptions; Ad Strength = headline count, headline uniqueness, keyword relevance, description uniqueness; best practice ≥2 Good/Excellent RSAs per ad group. Business name + logo require advertiser verification; logo 1:1, ≤5,120KB, min 128×128; name must match domain or legal name (P✓ support.google.com/google-ads/answer/7684791; answer/12497613; answer/9142254).

**Smart Bidding — one urgent change, three new levers:**
- **URGENT — effective 2026-08-17:** budget-limited campaigns on tCPA/tROAS (Search, Shopping, PMax, Demand Gen, Travel) will deliver **AT the stated target instead of overperforming it**. A Bid Target Adjustment Tool (live since 2026-07-06) lets you keep, match-to-recent-performance, or customize targets. Google will not auto-adjust budgets or targets (P✓ support.google.com/google-ads/answer/17061251; FAQ answer/17125145).
- **Smart Bidding Exploration** (opt-in, beta): ROAS-tolerance slider 5–30% letting the bidder chase less-certain queries; live for tROAS Search since ~Jul 2025; expands 2026-08-17 to all PMax without feeds (GA) and Shopping/PMax with feeds (beta) (P✓ support.google.com/google-ads/answer/15489627; expansion detail S — LIKELY). Deliberately loosens ROAS discipline — a bidding-policy decision, never a routine tweak.
- **Promotion mode** (beta since 2026-06-16, Search + PMax): scheduled ROAS-tolerance loosening + extra budget for a promo window, auto-reverting at end date. Distinct from seasonality adjustments (which only pre-signal a conversion-rate spike). ZA availability unstated — check in account (S seroundtable.com 41501 — LIKELY; NV for ZA).
- Seasonality adjustments (1–7 day events, ≤14 days) and data exclusions (for tracking outages) remain under Tools → Bid strategies → Advanced controls; Google warns overuse degrades bidding (P~ support.google.com/google-ads/answer/9352512).
- **Profit stack:** cost_of_goods_sold [cogs] in Merchant Center + Conversions with Cart Data → profit reporting in Ads (P✓ support.google.com/google-ads/answer/14943482). Gross-profit BIDDING betas (2025) and the GML 2026 Product Value Adjustments pilot are S/LIKELY, and almost certainly not ZA self-serve yet.

**Demand Gen & video commerce (gap-fill domain — mostly NV training baseline, network-blocked; re-verify before acting):**
- Demand Gen serves YouTube (incl. Shorts), Discover, Gmail, and (since Apr 2025) Google Display Network; ad-group-level channel controls (since Mar 2025) allow e.g. Shorts-only (P✓ support.google.com/google-ads/answer/15973205 — this one retrieved by the ads-platform researcher).
- Video Action Campaigns are gone: creation blocked ~Mar 2025, auto-upgraded to Demand Gen through Q2–Q3 2025 (NV dates). Any auto-upgraded campaign carries settings nobody chose — audit if found.
- Display campaigns migrate into Demand Gen: voluntary tool from Jun 2026, auto-migration into 2027 (P✓ support.google.com/google-ads/answer/17051545).
- Demand Gen has **no keywords, no search terms report, no negatives, no auction insights** — G5/G6 pipelines have no Demand Gen equivalent; brand safety = content suitability + placement exclusions (NV).
- Demand Gen and PMax **compete by Ad Rank** on overlapping YouTube/Display/Discover/Gmail auctions off the same Merchant Center feed — adding Demand Gen does not partition inventory; judge incrementality at account level (NV).
- **Measurement trap:** engaged-view conversions (≥10s watch then convert) sit INSIDE the "Conversions" column on video inventory — "Conversions-column-only" doctrine is not click-only once video serves (NV; G7 must characterize before any video spend).
- Lookalike segments are Demand-Gen-exclusive (seed minimums ~100–1,000); optimized targeting default-ON (NV).
- Feed-based Demand Gen needs only the existing Simprosys→Merchant Center feed — NOT the Google & YouTube channel (architecture confirmed via P✓ shopify.dev/docs/apps/build/sales-channels/contextual-product-feeds + channel-config-extension: Google channels are merchant-of-record=merchant, checkout stays on Shopify, so Analyzify reconciliation is unchanged).
- YouTube Shopping affiliate/creator commerce: assume **unavailable in ZA** (NV country lists); the ZA-realistic creator path is partnership ads (creator video as paid creative) pending a live check.

**Availability map (ZA):**
- Ads in AI Overviews: live in English in 12 countries (US, AU, CA, IN, ID, KE, MY, NZ, NG, PK, PH, SG) — **South Africa NOT included** (Dec 2025 expansion). Ads in AI Mode: US-only testing, CA/AU next, no ZA timeline (P✓ support.google.com/google-ads/answer/16297775). ZA SERPs show AI Overviews without ad slots. Kenya + Nigeria inclusion makes African expansion plausible — recheck quarterly.
- Local Services Ads: not available in ZA (LIKELY; non-US transition into Google Ads platform runs 2027). PMax Waze inventory: US-only (P✓ support.google.com/google-ads/answer/16710258). Direct Offers, Universal Cart, PVA: US-centric pilots, no ZA (NV).
- Current creatable campaign types (mid-2026): Search, PMax, Standard Shopping, Demand Gen, Display (until migration completes), Video, App, Smart (legacy), Travel/Hotel (P~ assembled list — no single official page retrieved).

**GML context:** GML 2025 delivered AI Max beta, Smart Bidding Exploration, ads in AI Overviews (US), PMax channel report, $5k incrementality-test threshold (P✓ support.google.com/google-ads/answer/16290177; 2025 recap answer/16756291). GML 2026 (May 2026): Gemini as the ads OS, ad formats for AI Mode, Direct Offers upgrades, Universal Commerce Protocol + Universal Cart, PVA pilot, Commerce Media Suite, Asset Studio Gemini Omni, AI Max GA, demand-led pacing, campaign total budgets (P~ blog.google GML 2026 collection page identified; details assembled from consistent secondaries).

### A2. Deadlines
| Date | What | Action owner |
|---|---|---|
| **2026-08-17** | Budget-limited tCPA/tROAS campaigns start delivering AT target (not above it) | G1 inventory + G9 execute target resets via Bid Target Adjustment Tool BEFORE this date |
| **2026-08-17** | Smart Bidding Exploration expands to PMax (no-feed GA; with-feed beta) | G0 confirm not silently enabled |
| **2026-09-01** | ACAs + campaign-level broad-match setting fold into AI Max | G0 audit which campaigns carry either |
| **2027-01-31** | Last new-DSA creation; voluntary DSA→AI Max window closes | G0 (account has no DSA — confirm) |
| **2027-02-01** | DSA auto-migration to AI Max begins | — |
| Jun 2026→2027 | Display→Demand Gen migration (tool live; auto later) | G0 confirm no Display campaigns exist |

### A3. Must verify live (docs cannot answer these)
- Every campaign flagged "Limited by budget" on tCPA/tROAS: record 30-day actual vs target; run Bid Target Adjustment Tool before 2026-08-17.
- "Broad match keywords" setting per Search campaign; AI Max enablement prompts on Search AND Standard Shopping (rollout active since 2026-07-24).
- Recommendations → auto-apply: confirm nothing in ads&assets / keywords&targeting families is auto-applied (broad match, AI Max, ACA, Exploration).
- PMax: attached negatives + shared lists vs the fleet negatives source of truth; account-level list (≤1,000) contents; Final URL expansion state + URL exclusions + page feed; brand lists incl. the Shopping-ads-on-excluded-brand retail exception for BeautyOnTApp/Pastry terms; channel performance split; search terms report reconciled into G5's pipeline.
- Presence of any Demand Gen (auto-upgraded ex-VAC), Video, Display, Smart or DSA entities the fleet doesn't currently model (check Change History Q2–Q3 2025 for "upgraded" events).
- ZA in-account availability of: Exploration toggle, promotion mode, text guidelines/term exclusions UI, AI Max for Shopping toggle, PMax retention goal + New Customers (High Value) mode.
- Customer Match list sizes (≥1,000 active users needed for lifecycle modes); advertiser verification + business name/logo approval status.
- Quarterly: has ZA been added to ads-in-AI-Overviews countries (answer/16297775)?

### A4. Decide (recommendation packs for T; agents never self-execute these)
- Whether to lock in overperformance before 2026-08-17 by tightening targets to recent actuals (G9 executes only with T-approved pack).
- Whether to trial AI Max via the built-in 50/50 experiment on one Search campaign — structural change, T sign-off; never plain-enable.
- Whether to configure text-guideline term exclusions ("free delivery", "free shipping") on every campaign where Google-generated text can serve — recommended strongly.
- Whether COGS + Conversions with Cart Data (profit reporting) is worth the Merchant Center write (T-reserved; enables margin-based judging by G8).
- Whether a Demand Gen test is ever warranted — new campaign structure, T-reserved; requires G7 EVC characterization + G8 account-level incrementality design first.

### A5. Never do
- Never sum PMax asset-level conversions into totals (full-credit-per-asset overcounts by design).
- Never assume PMax negatives or brand exclusions suppress YouTube-instream/Display/Gmail/Discover/Maps (negatives: Search+Shopping only; brand exclusions: Search/Shopping/YouTube-Search only).
- Never enable AI Max, Smart Bidding Exploration, or promotion mode as routine optimization — bidding-policy/structural decisions, T-approval only, AI Max only behind the one-click experiment.
- Never leave a stale loose target on a budget-limited tROAS/tCPA campaign after 2026-08-17 — Smart Bidding will spend TO it.
- Never create a Search campaign without checking the broad-match campaign setting.
- Never assume US-announced features exist in ZA (AI Overviews ads, AI Mode ads, Direct Offers, Universal Cart, Waze, PVA, LSA — all not ZA).
- Never use data exclusions/seasonality adjustments casually (Google warns overuse degrades bidding; seasonality = 1–7 day events).
- Never rely on Shopping priority settings to control traffic vs PMax — Ad Rank decides since Q4 2024/2025.
- Never let AI-generated text run without term exclusions for banned claims (no-free-delivery rule).
- Never build on DSA; never create/enable Demand Gen via any agent (new structure = T only); never reinstall Google & YouTube channel for feed/YouTube features; never let Simprosys touch tracking.

---

## B. Google Ads API, Scripts, Editor and the automation surface (G0, G9 primary; all read-agents)

### B1. Must know
**API versions — facts now rot in weeks:**
- The API moved to a **monthly release cadence in January 2026**: majors Jan/Apr/Jul/Oct (v23/v24/v25/v26-expected), minors non-breaking. Current version: **v25, released 2026-07-22** (P~ ads-developers.googleblog.com/2026/07/announcing-v25; corroborated by this dossier's own re-search of seroundtable/ppc.land — treat as confirmed).
- Sunset ladder: v20 died 2026-06-10; **v21 dies 2026-08-05** (confirmed via Google's own sunset-reminder post surfaced this session); v22 ~Oct 2026; v23 ~Feb 2027; v24 ~May 2027; v25 into ~Jul 2027 (P~ developers.google.com/google-ads/api/docs/sunset-dates — exact v22+ days need re-check).
- v25 breaking change: CustomerLifecycleGoal + CampaignLifecycleGoal resources removed with no grace period; adds loyalty retention goal, Shorts engagement metrics, non-skippable duration breakdowns (S ppc.land, confirmed by re-search).
- v24.2 (2026-06-24): SyntheticContentInfo/Attestation for AI-generated creative labeling (EU AI Act–aligned; not ZA-binding but global structures); **multi-party approval** for sensitive account ops; performance_max_placement_view segmentable by ad_network_type (P~ blog + S).
- v24 (2026-04-22): **CartDataSalesView** (item-level cart-data reporting); v24.1: API Experiments expanded to AI Max/Video/Demand Gen/PMax (P~/S).
- v23 (Jan 2026): PMax channel-level reporting in API, natural-language audience definition, minute-level scheduling (S searchengineland 468104).
- v20 (Jun 2025) brought PMax campaign-level negatives to the API; v22 (Oct 2025) added GenerateText asset generation and Demand Gen tCPC (S).
- PMax **brand guidelines**: auto-enabled on new PMax since 2025-01-20; existing-campaign migration completed ~Oct 2025; business name/logo now campaign-level CampaignAssets (P~ ads-developers blog Mar 2025).

**Developer access & quotas:**
- Token tiers (2026): **Explorer** (new default since ~Feb 2026 — instant production access, 2,880 ops/day, Keyword Planner endpoints blocked); **Basic** (application required, 15,000 ops/day incl. reads); **Standard** (uncapped). Application backlog acknowledged Feb 2026 (P~ access-levels page). Daily quota counts get/search AND mutates; ≤10,000 operations per mutate request (P~ quotas page). A read-heavy multi-agent fleet can exhaust Basic on GAQL reporting alone — budget reads across G0–G10.

**Conversion-upload surface has left the Ads API (governance-critical):**
- Since **2026-04-01**: Customer Match uploads via OfflineUserDataJobService/UserDataService fail (CUSTOMER_NOT_ALLOWLISTED) for tokens without prior-180-day usage (S ppc.land).
- Since **2026-06-15**: offline click conversions + enhanced-conversions-for-leads uploads blocked for tokens without demonstrated Dec 2025–mid-2026 use (P~ ads-developers blog May 2026). Replacement for both: **Data Manager API** (launched 2025-12-09). Any future offline/Customer Match project = T-reserved Data Manager work.
- Enhanced conversions consolidation: from Apr 2026 tags+Data Manager+API accepted simultaneously; from **Jun 2026 ECW and ECL merged into a single on/off setting** with auto-migration (P~ support.google.com/google-ads/answer/16884284). G7 must confirm the merge didn't disturb the Analyzify-owned setup.

**Automation & agentic surfaces:**
- **Auto-apply recommendations have no master off-switch** — each type must be unticked per account (bundles "Maintain your ads" / "Grow your business"). RecommendationSubscriptionService allows programmatic audit; Google-auto-applied changes are detectable via change_event WHERE client_type = GOOGLE_ADS_RECOMMENDATIONS_SUBSCRIPTION (P~ answer/10279006 + developers docs). Optimization score measures alignment with Google's suggestions, not business results.
- Since **2026-01-26** the "Add responsive search ads" recommendation no longer auto-suggests/auto-applies RSAs (P~ answer/10276359) — the riskiest Google-writes-copy category is retired.
- "Missed Opportunities" report (beta) moved from Labs into the main Recommendations tab ~2026-07-21 — expect new upsell prompts; do not chase (S).
- **Policy appeals cap since 2026-07-21:** in-account appeals impossible for decisions older than 6 months (S ppc.land + seroundtable). G0 must surface disapprovals with decision dates and flag at ~5 months.
- **Experiments:** drafts retired (2022); custom experiments direct-from-campaign; PMax native asset A/B experiments since **2026-06-08** — one per campaign, **asset groups locked view-only during the test** (P~ answer/12997711).
- **Change history / undo:** 2-year history; UI undo only for changes ≤30 days old and not always; **no undo via API**; change_event queries require a ≤30-day window and LIMIT ≤10,000 (P~ developers docs). The 30-day undo window is the hard technical boundary of G9's "reversible."
- **Official Google Ads MCP server** (github.com/googleads/google-ads-mcp): open-sourced 2025-10-07, official release 2026-04-28; read-only by design — GAQL search + metadata only, cannot mutate (P~ repo not fetchable; corroborated). Structurally safe read path for G1/G5/G6/G8/G10.
- **Ads Advisor** (in-product Gemini agent) live for ALL English-language accounts since Dec 2025 — language-gated, not country-gated, so the ZA account has it. GML 2026 added Ask Advisor + Marketing Advisor + agentic safety features (P~ blog.google). It can propose/apply changes conversationally — a change-control bypass the fleet must never use for writes.
- **Scripts limits:** 30-min runtime (60 for MCC executeInParallel, ≤50 accounts), max 250 scripts/account, hourly minimum frequency with nondeterministic minute, ~250k entity fetch cap (some numbers from community threads — re-verify); PMax creation only via raw mutate, asset groups not creatable via typed builders (P~ scripts docs).
- **Automated rules:** hourly/daily/weekly/monthly; can pause/enable, change budgets/bids/URLs/labels, email alerts. No official per-account rule-count limit found — do not assert one (NV) (P~ answer/2472779).
- **Editor:** current 2.13 (~Jun–Jul 2026: AI Max for Shopping controls, PMax retention goals); versions ≤2.9 unsupported since 2026-03-30 (S).
- ZA gating: none found on any automation surface (API, Scripts, Editor, MCP, Data Manager, rules, experiments) — strong inference, not proven (NV-negative).

### B2. Deadlines
| Date | What | Owner |
|---|---|---|
| **2026-08-05** | Ads API v21 sunset — v21 requests fail | G0 verify no integration is on v21 (Analyzify, Simprosys, connectors) |
| **2026-09-01** | DSA/ACA/broad-match-setting campaigns begin auto-upgrading to AI Max | G0 inventory; T decides |
| ~2026-10 | v22 sunset (day unconfirmed) | G0 |
| In force since 2026-04-01 / 2026-06-15 | Customer Match / offline-conversion uploads blocked for new tokens — Data Manager API is the only path | T only |
| In force since 2026-07-21 | 6-month appeal window on policy decisions | G0 flag at ~5 months |
| In force since 2026-03-30 | Editor ≤2.9 unsupported | T machine ≥2.12 |

### B3. Must verify live
- Auto-apply: Account Settings → Auto-apply + GAQL recommendation_subscription (expect zero ENABLED); change_event last-30-days filtered to GOOGLE_ADS_RECOMMENDATIONS_SUBSCRIPTION (expect zero rows); enumerate all client_type values to fingerprint every actor writing to the account.
- API Center: token tier (Explorer/Basic/Standard), daily ops consumption, and every app holding OAuth access + the API version each uses (v21 = breaks 2026-08-05).
- Rules & scripts inventory (Tools → Bulk actions): confirm read/alert-only; nothing mutates outside G9.
- Search campaigns using DSA / ACA / broad-match setting (Sept 2026 exposure).
- Enhanced-conversions unified toggle state post-June-2026 merge vs Analyzify design; conversion upload history (expect none).
- PMax brand guidelines: business name + logo assets correct on every PMax campaign (both brands) post-auto-migration.
- Experiments page: any running/scheduled experiments (asset-group locks) before G1/G3 propose asset changes.
- Ads Advisor: presence, and change history attributed to advisor surfaces (expect none).
- Rolling 30-day change_event baseline pull as G0's attribution ledger.

### B4. Decide
- Whether to adopt the official read-only Ads MCP server as the fleet's standard read path (recommended — structurally enforces G9-only writes); if yes, token tier likely needs Basic (Explorer blocks Keyword Planner for G5; 2,880 ops/day is tight for 11 agents).
- Whether any Scripts-based G0 sentinel alerts are worth building (read/alert-only) given hourly minimum + nondeterministic minute.

### B5. Never do
- Never enable or leave enabled any auto-apply recommendation subscription; never accept Ads Advisor/Ask Advisor conversational applies — both bypass G9 change control.
- Never build on API v21 or older; never start new work on a version with <6 months runway.
- Never attempt Customer Match / offline conversion / ECL uploads through the Ads API (blocked; Data Manager is T-reserved — consistent with Analyzify tracking ownership).
- Never create rules or scripts that mutate bids/budgets/statuses — read/alert-only; G9 is the sole executor.
- Never touch PMax asset groups while an asset experiment runs (view-only lock); never start experiments without T.
- Never treat optimization score or "Missed Opportunities" as performance signals.
- Never assume undo exists past 30 days — outside that window a change is not "reversible" and therefore outside G9's authority.
- Never let GenerateText/AI-generated copy ship unreviewed (free-delivery-claim risk).
- Never trust training memory for version facts — monthly cadence; re-verify at point of use.

---

## C. Conversion measurement, goals and attribution (G7, G0 primary; G9 constrained by it)

*(Domain evidence note: the researcher's fetches were proxy-blocked; every claim below is official-page content retrieved via search snippets — confidence capped at P~ LIKELY even for Google pages. Re-verify load-bearing items from an unblocked session.)*

### C1. Must know — the documented semantics behind fleet doctrine
- **"Conversions" column** = conversions from PRIMARY actions in goals applied to the campaign; it is what Smart Bidding optimizes (P~ support.google.com/google-ads/answer/6270625). **"All conversions"** = Conversions + secondary/observation actions + cross-device + store visits + certain calls — observation only (P~ answer/3419678). The fleet's judge-on-Conversions doctrine matches Google's documented semantics exactly.
- **The custom-goal trap:** a SECONDARY action included in a CUSTOM goal applied to a campaign IS used for bidding and lands in that campaign's Conversions column (P~ answer/11461796). "Purchase is the only Primary" is therefore necessary but not sufficient — no campaign may carry a custom goal containing a secondary action.
- **Account-default vs campaign-specific goals:** campaign-specific goals OVERRIDE account defaults; only the selected goals feed that campaign's Conversions/Conversion-value and bidding; account-level goal changes no longer propagate to such campaigns (P~ answer/9143218, answer/4677036). Fleet constraint "campaign goals must be campaign-specific and Purchase-only" means every campaign must be audited individually — account-level checks prove nothing.
- **Google-hosted local actions:** once location assets from a linked GBP are active, Google AUTO-CREATES Google-hosted goals (Clicks to call, Directions, Website visits, Other engagements…) with no tracking code (P~ answer/9013908). Community threads document them as LOCKED — not removable, sometimes displaying "Primary" while behaving as secondary (S support.google.com/thread/253539166 — SECONDARY, matches this account's lived experience of 194 phantom conversions in "All conversions" [source: skill library, beautyontapp-google-ads]). The real control: they must show **0 campaigns assigned and 0 counts inside "Conversions"** — check every audit.
- **Date semantics:** standard Conversions columns are **click-dated** — recent periods restate upward for up to the full click-through window (default 30 days, max 90). Reconciliation against Shopify/Analyzify must use **"(by conv. time)"** columns (P~ answer/6270625; answer/6239119 "days to conversion").
- **Counting & windows:** "Every" (recommended for purchases) vs "One"; click-through window 1–90 days (default 30); view-through default 1 day; EVC window separately configurable (P~ answer/3438531, answer/3123169).
- **Attribution:** only **Data-driven (default) and Last click** exist since Nov 2023; first-click/linear/time-decay/position-based were removed and migrated to DDA (P~ answer/6259715). Any memo referencing removed models is stale.
- **View-based conversions inside "Conversions":** engaged-view conversions (non-skip/rewarded watched, or ≥5s of skippable, then convert, no click) ARE included in Conversions AND All conversions (P~ answer/10048752). Classic view-through conversions are NOT — EXCEPT campaigns opted into **view-through-conversion optimized bidding** (Demand Gen open beta Apr 2026, YouTube inventory; also App), where biddable VTCs enter the Conversions column (P~ answer/16399666, answer/16542520). The opt-in checkbox changes the meaning of the column — never enable.
- **New-customer acquisition goal** (PMax, Search, Demand Gen): "new customer value" mode ADDS a synthetic bonus value on top of actual purchase value (inflates Conversion value vs Shopify revenue); "new customers only" mode still leaks returning-customer conversions into bidding (P~ answer/12080169). Default new/existing detection: 540-day lookback; better accuracy needs Customer Match lists or the new_customer tag parameter (tag work = Analyzify/T only) (P~ answer/12077475).
- **Enhanced conversions for web:** SHA-256-hashed first-party data on top of the conversion tag; requires accepting customer data terms — EC silently fails without acceptance; dedicated tag/API diagnostics reports exist (P~ answer/9888656, answer/11956168; policy answer/7475709).
- **Consent scope for a ZA advertiser:** Google's consent-mode-v2 mandate attaches to **EEA/UK/Switzerland END USERS**, regardless of advertiser location — ZA-only targeting carries no Google consent-mode obligation; POPIA is separate law Google does not enforce (P~ google.com user-consent-policy-help; S usercentrics). But never assert zero EEA exposure without checking geo-targeting ("Presence or interest" leakage) and GA4 EEA session share.
- **2026-06-15 consent authority change:** consent-mode **ad_storage is now the SOLE authority** for advertising data flowing from linked GA4 to Ads; Google Signals demoted to Analytics-only — no fallback; a broken banner silently blacks out GA4-side conversions/audiences (S onetrust/uniconsent/didomi — consistent; official page not fetched). Google has promised further Ads-side consolidation "later in 2026" — G0 watch.
- **GA4 imports:** GA4-key-event-based Ads conversion actions are created SECONDARY by design to prevent double counting; promoting a GA4 purchase import to primary alongside Analyzify's native action = documented double-counting path (P~ support.google.com/analytics/answer/10632359). GA4 renamed conversions → **key events** (Mar 2024) — translate terminology when reading GA4 docs/UIs.
- **Tag health surfaces to poll (read-only):** Tag Diagnostics (Excellent→Urgent; checks conversion linker, missing tags, command order, EEA consent, UA leftovers) (P~ answer/14681508); EC diagnostics; **Google tag gateway for advertisers** (renamed from "first-party mode", launched May 2025 — serve the Google tag from your own domain/CDN, Cloudflare one-click) is an available infrastructure upgrade — T/Analyzify decision only (P~ answer/16061641).
- Shopify Google & YouTube channel double-tag pattern is community-documented (S community.shopify.com thread 414650) — matches this account's rogue-tag incident; reinforces never-reinstall.

### C2. Deadlines / standing obligations
| Date | What | Owner |
|---|---|---|
| In force 2026-06-15 | ad_storage = sole GA4→Ads consent authority (no Signals fallback) | G7 verify consent state if any EEA/UK/CH exposure |
| Later 2026 (unannounced) | Further consolidation of Ads-data controls promised | G0 watch |
| Standing since Mar 2024 | Consent mode v2 for EEA/UK end users (not ZA-only) | G7 monitor exposure |

### C3. Must verify live
- Full conversion-action census: Purchase (Analyzify - Purchase 657) the ONLY primary; its counting = Every, click window, EVC/VTC windows, attribution model recorded.
- Google-hosted actions: 0 campaigns assigned, 0 counts inside "Conversions" (every audit — matches standing account rule).
- EVERY campaign's goal config: campaign-specific, Purchase-only, no custom goals containing secondary actions.
- 30-day Conversions vs All-conversions delta per campaign; any non-Purchase count inside "Conversions" = red alert.
- Conversion-lag distribution → publish how many trailing days G1/G8 must treat as provisional.
- EC state (enabled? terms accepted? diagnostics green?); GA4 imports all SECONDARY; GA4-Ads link state.
- Geo-targeting EEA/UK/CH exposure + actual EEA session share (consent-mode obligation test).
- NCA goal state on every campaign (if any mode is on, G8 must strip synthetic value before revenue comparison).
- GBP link + location-asset state in Ads (the trigger for Google-hosted goal creation — G4 must report GBP changes to G0).

### C4. Never do
- Never judge on "All conversions" (documented to include observation actions, Google-hosted locals, cross-device, store visits, calls).
- Never create/remove/promote/demote/re-window any conversion action, goal, attribution model or counting setting from an agent — T-reserved. Don't waste cycles trying to delete Google-hosted local actions (locked).
- Never promote a GA4 purchase import to primary while the Analyzify native action is primary.
- Never reinstall the Google & YouTube channel to "fix" conversions.
- Never reconcile Shopify orders against click-dated columns — "(by conv. time)" only; never treat trailing-window Conversions data as final.
- Never enable "Include view-through conversions" bidding or alter EVC/VTC windows — changes the Conversions column's meaning mid-series.
- Never assume account-default goals apply to a campaign with campaign-specific goals; never let a custom goal smuggle a secondary action into bidding.
- Never implement consent-mode/tag-gateway/sGTM changes agent-side; never send unhashed customer data.

---

## D. GA4 and transaction reconciliation (G7, G8 primary; G2, G4, G10 consumers)

*(Domain evidence note: researcher fetches proxy-blocked; claims are official-page content via search retrieval — P~ ceiling. Analyzify claims are vendor docs = SECONDARY.)*

### D1. Must know
**Terminology & attribution baseline:**
- GA4 "conversions" → **"key events"** since Mar 2024; "conversions" is now Ads-side vocabulary (P~ support.google.com/analytics/answer/13927521).
- GA4 reporting attribution: Data-driven (default) + last-click variants only; rules-based models removed late 2023. Lookback: 30d acquisition / 90d other key events; **model/lookback changes apply retroactively** — snapshot settings before comparisons (P~ answer/10596866). A 2025 settings relocation / 2026 per-conversion attribution restructure is reported but unconfirmed (NV — check Admin).
- Reporting identity (Blended/Observed/Device-based) + non-adjustable **data thresholding** mean signal-enabled reports won't sum to backend totals; BigQuery export is unthresholded (P~ answer/10976610, answer/9383630). Google signals was removed from reporting identity 2024-02-12 (P~ answer/9445345).

**Channels & new 2026 surfaces:**
- **"AI Assistant" default channel** live ~2026-05-20: AI-assistant referrals (ChatGPT, Gemini, Perplexity…) auto-assigned medium `ai-assistant` — G10's native first-party AI-citation traffic measure (P~ answer/9756891). "Source Group" dimension announced ~2026-06-11 (S — verify in property).
- Custom channel groups: max 2 per standard property, 25 channels each; default group uneditable (P~ answer/13051316).
- **GA4 × Google Business Profile native integration** rolling out ~Jun 2026: local metrics (calls, directions, bookings) inside GA4; ~6-month history, no per-location filtering (S gaoptimizer — NV; linking = property write, T only).
- Analytics Advisor / Ask Advisor (Gemini) + expanded generated insights + Benchmarking (~20 unnormalized metrics, needs data-sharing opt-in) rolled out 2025–2026 (P~/NV mixed — verify in UI).

**Quotas, retention, export:**
- Data retention: default **2 months** (trap); standard max 14 months; affects Explorations only (P~ answer/7667196). YoY event-level work needs BigQuery.
- BigQuery free daily export: 1M events/day cap (auto-pause if consistently exceeded, no backfill; email warnings) — far above this store's volume; the correct unsampled reconciliation substrate (P~ answer/9358801).
- Data API v1: 200k core tokens/property/day, 40k/hour (P~ developers quota page) — agents should batch and request returnPropertyQuota.

**Reconciliation physics (G7's core doctrine):**
- Google's documented GA4-vs-Ads discrepancy taxonomy: click-date vs conversion-date; clicks vs sessions; retroactive invalid-click removal; attribution/counting differences; view-through/EVC in Ads only (P~ answer/7457111, analytics answer/1034383). Run this checklist BEFORE declaring tracking breakage.
- Shopify's official discrepancies doc: server-side orders vs browser events (ad blockers, blocked tags, early closes), timezone mismatches, ≥24–48h processing lag, different attribution logic (P~ help.shopify.com/…/discrepancies). A structural GA4 undercount vs Shopify (~10–30% per secondary norms) is NORMAL in healthy setups — alert on deviation from the property's own baseline gap, not on the gap existing.
- **Google officially documents Shopify custom-pixel sandbox limitations** (tagmanager/answer/16000892): cookie access can throw, wrong URL context, no auto-events, attribution signal loss — first-party validation that pixel-sandbox GA4 setups (incl. Analyzify's checkout leg) structurally undercount (P~).
- Transaction dedup: unique transaction_id per purchase; same-user web-stream dedup only; empty-string transaction_id collapses ALL such purchases into one; dedup is best-effort — **single source per event remains the law** (P~ answer/12313109). GA4 has no Meta-style event_id dedup.
- Refunds: GA4 subtracts only on a matching `refund` event; Shopify does not natively push refunds → **GA4 revenue is gross-of-refunds**; reconcile refunds from Shopify only (P~ answer/14143583).
- Referral exclusions ("List unwanted referrals") for ZA gateways — likely offenders: payfast.*, ozow.com, peachpayments.com, payflex.co.za, paygate.co.za, yoco.com, bank 3DS/ACS domains; not retroactive (P~ answer/10327750; exact list must come from the live Traffic acquisition report).
- Currency: GA4 converts to property currency at ~prior-day rates; both sides ZAR + correct payload currency = zero conversion noise; Shopify Markets/multi-currency would create systematic mismatch (S — verify payload).

**Integration architecture:**
- Shopify's official GA4 paths: Google & YouTube channel (auto-fires full ecommerce suite via web pixel) or custom pixel/GTM (P~ help.shopify.com google-analytics-setup). For this fleet the channel is **permanently uninstalled** — reinstalling/relinking would duplicate every Analyzify event including purchase.
- Analyzify v4 (S vendor docs): app embed manages storefront dataLayer; manually-installed custom pixel handles checkout events → purchase; optional sGTM add-on moves purchase server-side ("hybrid"). Enabling sGTM purchase while the client purchase fires = double-count (vendor's own guidance: pick ONE source per event).
- Audience export to Ads: link + "Enable personalized advertising"; ≤2 days to appear, ~30-day backfill max, 100 audiences/property, 540-day max duration; editable only in Analytics (P~ answer/12800258). Creation = property write (T only); agents read-only.
- Consent: June 15, 2026 unification — ad_storage consent signal is now the sole control for GA4→Ads advertising data (see Section C); EEA/UK/CH-user-scoped, not ZA (P~/S). POPIA: s69 direct-marketing consent + Info Regulator Guidance Note (late 2024), national opt-out registry flagged 2025/26; no POPIA-specific Google setting — controls are redaction, retention, data-sharing, deletion (S Michalsons/DLA Piper — SECONDARY legal). GA4 **data redaction** (email + query params; on by default only for NEW properties) is the POPIA-hygiene toggle to check (P~ answer/13544947).

### D2. Deadlines
| Date | What | Owner |
|---|---|---|
| **2026-08-26** | Shopify auto-upgrades non-Plus (incl. Advanced) Thank-you/Order-status pages — additional scripts, ScriptTags, checkout.liquid on those pages STOP executing | T confirms upgrade status + Analyzify pixel continuity; G0 counts down; ~4 weeks away |
| In force 2026-06-15 | ad_storage = sole GA4→Ads data control | G7 commission consent check (T executes) |
| Ongoing | BigQuery export auto-pause >1M events/day | G0 watch admin emails if enabled |

### D3. Must verify live
- Retention = 14 months (not the 2-month default); reporting identity; attribution settings snapshot; redaction state.
- Referral-exclusion list vs live gateway referrals in Traffic acquisition (any converting gateway referral = misattribution).
- Test/observed order: exactly ONE purchase event, correct transaction_id (order number), currency ZAR, value = Shopify; no residual channel/theme tags firing beside Analyzify.
- 30-day GA4-vs-Shopify baseline undercount % (timezone-aligned, ≥48h lag) → G7's alert threshold; refund-event census (expect zero → document gross-revenue wedge).
- Ads link state; NO GA4-sourced purchase action Primary in Ads; audience population status.
- EEA/UK session share (consent obligation test); consent settings diagnostic post-2026-06-15.
- Shopify checkout upgrade status + inventory of anything still in view-only additional scripts BEFORE 2026-08-26.
- Property timezone/currency vs Shopify store (both brands); Pastry property topology (shared property → assess cross-domain config; separate → none needed).
- Baseline the AI Assistant channel row (sessions/key events/revenue) for G10; check Source Group dimension presence.
- BigQuery link state — if absent, log as T recommendation (free tier suffices).

### D4. Never do
- Never reinstall/relink the Google & YouTube channel; never enable Simprosys tracking; never run two purchase sources (incl. Analyzify sGTM purchase + client purchase together).
- Never send empty-string or reused transaction_ids.
- Never equate GA4 key events with the Ads Conversions column or reconcile conversion-date vs click-date 1:1.
- Never expect GA4 revenue = Shopify revenue; never "fix" the structural gap by adding tags (creates duplicates).
- Never change GA4 property config agent-side (retention, attribution, identity, consent, referral exclusions, audiences, product links) — all T-reserved.
- Never treat referral-exclusion edits as retroactive.
- Never set a GA4-imported key event Primary in Ads.
- Never use stale GA4 vocabulary/limits in fleet output (pre-2024 conversions terminology, removed models, pre-2024 signals behavior).

---

## E. Merchant Center, Merchant API and product data (G3 primary; G0 sentinel; G9/T execution split)

### E1. Must know
**The API cutover — the fleet's single biggest live risk:**
- **Content API for Shopping hard shutdown: 2026-08-18** (18 days from dossier date). All Content API calls fail: product uploads/updates, inventory, data-source management, promotions, reports. Manual file uploads / Google Sheets / scheduled fetches are NOT affected (S xictron + corroborated by Google's own migration pages surfaced in search; confirmed independently by this dossier's own re-search of developers.google.com/merchant/api pages — extended access can be applied for). **API-submitted product data expires ~30 days after last sync** — a dead integration means silent catalog decay from late August, near-total disappearance by mid-September (S seroundtable + help.shopify.com syncing docs).
- Merchant API v1 = GA since Aug 2025 (modular sub-APIs: Accounts, Products, Data Sources, Inventories, Promotions, Reports, Reviews, Notifications, Product Studio) (S searchenginejournal; P~ support.google.com/merchants/answer/16493611). **v1beta already sunset 2026-02-28**; v1 requires one-time registerGcp developer registration (P~ developers.google.com migrate-v1beta-v1; confirmed by dossier re-search).
- Breaking semantics: resource-name IDs (`accounts/{id}/products/en~ZA~SKU42`) replace numeric IDs; prices are amountMicros int64 + currencyCode — all parsing logic must be rewritten (S digitalapplied/ekamoira).
- Merchant API became available in **Google Ads Scripts** as Advanced API 2026-04-22; Content API works in Scripts only until 2026-08-18 (P~ ads-developers blog Apr 2026).
- **Simprosys migration status = UNCONFIRMED** (NV): vendor marketing still described "Content API method" submission. This must be verified with the vendor and in Merchant Center → Data sources THIS WEEK. If Simprosys misses the migration, the feed dies on Aug 18.
- Community-reported risk (S seroundtable): Shopify Google & YouTube channel product-ID rewrites around the Aug 18 cutover can reset Shopping performance history — one more reason never to reinstall it.

**Merchant Center product state:**
- Classic MC retired 2024-09-30; in **July 2026 Google dropped the "Next" name** — it's just "Google Merchant Center" again. Permanent renames: Feeds→Data sources, Diagnostics→Needs attention, Destinations→Marketing methods, Feed rules→**Attribute rules** (S ppc.land).
- Attribute rules + supplemental data sources require the free **"Advanced data source management" add-on** (Settings → Add-ons) before they appear (S zato + P~ answer/14994083).
- Automatic improvements: auto item updates (price/availability/condition) ON by default; image improvements + shipping updates opt-in; all under Products → Automations (P~ answer/12157888). Auto-updates verify against PDP structured data — theme schema must match the feed.
- Product spec 2025 (Apr 2025): installment down_payment change; certification replaces energy-efficiency (EU); offer-level shipping sub-attributes (S ppc.land). **Since 2025-07-01 member/loyalty prices are globally banned from price/sale_price** — loyalty_program attribute only, and only in supported countries (S).
- Product spec 2026: **video_link attribute live** (serving + policy validation since 2026-06-30) — free enrichment for beauty tutorial/texture video; **500×500px minimum image resolution** — warnings since 2026-04-14, disapproval enforcement **2027-01-31** (P~ support.google.com/merchants/answer/16989427).
- Shipping/returns declarations now have THREE parallel paths since 2025-11-12: Merchant Center settings, Search Console settings, org-level structured data — they must never contradict (S pemavor + P~).
- New **Merchant Center Terms of Service** rolling out since 2026-06-15 with expanded AI data usage — in-account acceptance prompt is a T decision only (S searchen — NV single-source).
- Shopping ads + free listings policies consolidate into one policy set **September 2026** (no substantive changes claimed; expect URL churn in citations) (S seroundtable, announced 2026-07-15).
- Manufacturer Center is NOT sunset; manual UI add/edit removed 2026-07-09 (API/file only) (S seroundtable).

**ZA availability matrix (load-bearing for G3):**
| Feature | ZA? | Source |
|---|---|---|
| Free product listings (Search, Shopping tab, Images, Lens, YouTube, Gemini, GBP module) | **YES** | S gnuworld + P~ answer/13889434 |
| Regional availability & pricing overrides | **YES** | P~ answer/14644124 |
| Local inventory ads / free local listings | **CONFLICTED** — one 2026 source (S seroundtable summarizing answer/3271956) says ZA is in the list; two other researchers' baselines say ZA has never been supported. Resolve in the live MC UI (Manage programs) before any local-feed work; moot without physical stores | S seroundtable vs NV baseline |
| Merchant Center Promotions | **NO** (13 countries as of 2026-06-30) | S litcommerce |
| Loyalty program features / loyalty_program attribute | **NO** (14 countries) | S searchengineland 473122 |
| Checkout links (checkout_link_template) | **NO** (15 countries after Jul 2026 expansion) | P~ answer/13945960 |
| UCP / agentic checkout / Universal Cart | **NO** (US-first; CA/AU/UK by end-2026) | S searchengineland 478113 |
| CSS obligation | **N/A** (EEA/UK/CH only) | P~ answer/12653197 |
| Product Ratings program | **UNCONFIRMED** (~104 countries; check if add-on offered in account) | NV — P~ answer/14549080 country table not retrievable |
| Buy on Google | **DEAD** everywhere (checkout closed 2023-09-26) | S zenventory |

**Policy & enforcement machinery:**
- Enforcement: most violations → 7- or 28-day warning email before suspension; **misrepresentation = egregious → immediate suspension, NO warning**; reviews ~3–7 business days; failed re-reviews trigger escalating cool-downs (P~ answer/13693195).
- Misrepresentation pricing-transparency update effective **2025-10-28**: bait-and-switch, hidden checkout fees, undisclosed auto-billing named as violations; video identity verification reported in suspension reviews (S — video part NV).
- Price/availability **mismatch disapprovals fire with zero grace** ("Mismatched value (page crawl)"); re-crawl auto-reapproves once PDP exactly matches feed. Shopify price edits + Simprosys sync latency is the classic trigger (S adnabu).
- **"Inaccurate shipping costs"** disapproval fires when MC rates are LOWER than checkout reality; Google's guidance: overestimate when in doubt (P~ answer/10248678). Aligns with the no-free-delivery rule: MC must never show R0/free unless checkout genuinely charges nothing.
- Beauty claims: policed under Healthcare & medicines (P~ answer/6150151) + Misrepresentation unproven-claims. Prohibited: definitive treat/cure claims (acne, eczema, scarring), miracle language. Known recurring account offenders: CBD/hemp-suspect items and clinical-language items [source: skill library, beautyontapp-google-ads §Merchant Center Health]. Safe pattern: cosmetic-benefit language only.

**AI-surface coupling (G3 ↔ G10):**
- Feed data now powers AI Mode / AI Overviews / Gemini shopping and **Conversational Attributes** (AI reads material, fit, pattern, product_highlight beyond title/description); **AI Performance Insights** pilot in MC shows AI-surface discovery + share-of-voice (GML 2026; ZA availability unknown — watch for the add-on) (S searchengineland 478108; P~ answer/17117204 teaser). Feed completeness is now an AI-visibility lever.

### E2. Deadlines
| Date | What | Owner |
|---|---|---|
| **2026-08-18** | Content API hard shutdown; catalog decays ~30 days after last successful sync | G3 verify Simprosys THIS WEEK; G0 daily feed-freshness watch; T executes any feed-method change |
| **2026-09** (month) | Shopping policies consolidation — citation URL churn | G0/G3 refresh policy links |
| **2027-01-31** | 500×500px image enforcement (warnings live now) | G3 audit + T executes replacements |
| Rolling since 2026-06-15 | New MC ToS acceptance prompt | T only — never agent-accepted |
| Past, enforced | Member-price ban (2025-07-01); pricing-transparency update (2025-10-28); v1beta dead (2026-02-28); video_link live (2026-06-30) | — |

### E3. Must verify live
- **Simprosys API status** (vendor + Data sources view) — before 2026-08-18; registerGcp registration state for any owned GCP project.
- No orphaned data sources or leftover Google & YouTube channel link (Settings → Linked accounts).
- Automations tab: current ON/OFF of auto price/availability/condition, image improvements, shipping updates — per brand target country.
- Add-ons: Advanced data source management enabled? Product Ratings offered to this ZA account? AI Performance Insights visible?
- MC ToS banner present? → escalate to T.
- MC shipping settings vs live Shopify checkout rates for every scenario; Search Console shipping/returns panel for contradictions.
- Needs attention: disapproval census by reason — price mismatch, inaccurate shipping, healthcare/misrepresentation flags (Pastry SKUs especially).
- Sub-500×500 image warning list (already visible in MC).
- Notification email routing — 7/28-day windows only help if warnings are read same-day.
- PDP structured data (price/priceCurrency/availability) exactly matches feed on both storefronts.

### E4. Never do
- Never submit member/loyalty prices in price/sale_price; never use loyalty_program, promotions feeds, checkout_link_template, or UCP config for ZA offers — unsupported, and member-pricing misuse is a disapproval offense.
- Never write medical/treatment claims in product data or landing copy — immediate-suspension class, no warning window.
- Never let MC shipping settings understate checkout reality; never configure free shipping in MC (no-free-delivery rule; overestimate when rates vary).
- Never reinstall the Google & YouTube channel (rogue tags + ID-rewrite risk at the cutover).
- Never leave anything calling Content API (or v1beta) past 2026-08-18.
- Never buy CSS services for ZA (EEA/UK/CH-only concept).
- Never execute Merchant Center writes from the fleet (feed settings, automations toggles, ToS acceptance, add-ons, data-source changes) — G3 specs, T executes.
- Never assume a mismatch disapproval will be forgiven — zero grace; fix source-of-truth first, then rely on re-crawl.

### E5. Merchant API migration deep-dive (gap-fill — schema-verified against Google's LIVE discovery documents on 2026-07-30/31)
- Content API v2.1 is still fully serving (revision 2026-07-30) but its own discovery doc opens with "This API is deprecated. Please use Merchant API instead" — no partial shutdown yet (P✓ googleapis.com discovery doc, fetched this session).
- Merchant API v1 is GA across 12 sub-API surfaces (accounts, products, datasources, inventories, promotions, reports, conversions, ordertracking, notifications, lfp, quota, issueresolution; reviews still v1beta-only) — build on v1, never v1beta (P✓ discovery directory). Official clients GA since 2025-09; rapid major-version churn (Node v16→v18 in ~6 months) — pin client versions (P✓ pypi/npm metadata).
- **Field-mapping break (schema-verified):** Content API's singular `gtin` does NOT exist in Merchant API products_v1 — replaced by `gtins` (array, ≤10). A 1:1 field-name migration silently drops GTIN data. `identifierExists` defaults true — must be set false for barcode-less own-brand Pastry SKUs (P✓ products_v1 discovery).
- **Merchant-API-only enrichment attributes** (no Content API equivalent, no native Shopify field): `videoLinks`, `lifestyleImageLinks`, `virtualModelLink`, `productHighlights`, `productDetails`, `structuredTitle`/`structuredDescription` (AI-text disclosure). High-value for beauty PDPs; the sanctioned overlay is a SUPPLEMENTAL data source linked to the Simprosys primary — never a second primary (P✓ products_v1 + datasources_v1).
- **Schema-verified footgun:** patching a PrimaryProductDataSource `defaultRule` REPLACES the entire linked-supplemental-sources list (the schema warns "the linked data sources will be replaced") — always submit the complete list or silently unlink everything (P✓ datasources_v1).
- Product insertion is data-source-scoped (insert requires an explicit dataSource; inserting an existing product under a different source MOVES it) — the architectural reason app reinstalls rewrite offer identity (P✓ products_v1).
- Per-item surgical controls exist without touching the feed app: `excludedDestinations`/`includedDestinations`, `pause`, `shoppingAdsExcludedCountries` (P✓ products_v1).
- conversions_v1 defines MerchantCenterDestination + GoogleAnalyticsLink conversion sources (≤200/account; 7/30/40-day lookbacks; auto-created "purchase" type) — the object class to audit for Google & YouTube app leftovers (P✓ conversions_v1).
- **G&Y channel migration state: UNCONFIRMED** — no shopify.dev changelog entry announces a Merchant API migration of the app; a mid-2026 secondary report says reinstalling near the cutover rewrites every product ID (offer convention `shopify_{feedLabel}_{productId}_{variantId}` — ID churn resets item-level Shopping history; mechanism consistent with the verified data-source architecture) (NV/S). One more reason the reinstall door stays shut.
- Shopify-side: channel apps sync via contextual product feeds (async, webhook-driven — explains multi-hour MC propagation lag) (P✓ shopify.dev); **since 2026-07-01 merchant-owned delivery-profile APIs are deprecated for market-driven-shipping shops** — if the store ever adopts market-driven shipping, verify Simprosys still reads live rates or MC shipping mismatches (suspension-class) appear silently (P✓ shopify.dev changelog).
- **Escalation trigger: 2026-08-11** — if Simprosys' written Merchant API confirmation is not in hand one week before sunset, G9 escalates to T to prepare the fallback (scheduled-fetch/file feed, which the sunset does NOT affect, or an operator-executed direct Merchant API data source).

---

## F. Shopify Advanced ↔ Google integration surface (G3, G7, G0 primary)

*(Best-verified domain in this dossier: 8 claims adversarially CONFIRMED against live shopify.dev pages [AV✓].)*

### F1. Must know
**Checkout extensibility — the imminent cliff:**
- checkout.liquid is dead for in-checkout steps since 2024-08-13 (was Plus-only anyway); Plus TY/OSP scripts died 2025-08-28 (P✓ shopify.dev checkout-liquid) [AV✓].
- **Non-Plus (Advanced) deadline 2026-08-26:** ScriptTags and Additional scripts on Thank-you/Order-status pages turn OFF; unupgraded shops are **force-upgraded to un-customized pages, deleting those customizations** (P✓ shopify.dev blocking-script-tags; changelog) [AV✓ both]. This is ~4 weeks from the dossier date.
- Since **2025-02-01** no app can create new ScriptTags on TY/OSP pages — legacy script tracking is unreinstallable, period (P✓) [AV✓].
- Since 2024-05-21 Advanced stores have UI extensions + web pixels on TY/OSP + the checkout editor — the upgrade is fully executable today (P✓ changelog) [AV✓].
- Upgrade-status check: Admin GraphQL `checkoutProfiles.typOspPagesActive` (the old webhook was removed 2026-01-01) (P✓ changelog).
- **Web pixels are the only sanctioned tracking path** on upgraded TY/OSP pages; web pixel extensions work on both legacy AND upgraded pages — the safe cross-deadline mechanism (P✓ blocking-script-tags).
- Plan ceiling (Advanced): in-checkout (info/shipping/payment) UI extensions and Admin-API checkout branding are **Plus-only**; Advanced gets TY/OSP blocks, web pixels, checkout-editor styling, and market-level checkout overrides (P✓ checkout technologies). Shopify Scripts (Plus-only) fully sunset 2026-06-30 [AV✓]. Shopify Functions via public apps only on Advanced (custom Function apps = Plus) (P✓). Flow available on any paid plan (custom-app Flow triggers Plus-only) (P✓).

**Web pixel physics (G7's reconciliation substrate):**
- App pixels run in a STRICT sandbox (web worker — no DOM, only self/console/timers/fetch); custom pixels in a LAX sandbox (iframe; `window.href` returns the SANDBOX URL, not the page URL — documented cause of wrong page_location in pasted legacy pixels) (P✓ shopify.dev pixels) [AV✓].
- `checkout_completed` fires ONCE — on the Thank-you page, OR on the FIRST post-purchase upsell page if upsell apps exist, and **never fires if that page fails to load** (P✓ standard-events doc). Browser-side purchase undercount vs Shopify server orders is structural physics, not a bug.
- **Consent gating:** Shopify only loads app pixels whose declared customer_privacy requirements are satisfied; consent-required region config suppresses non-essential pixels by default (P✓ pixel-privacy) [AV✓]. A mis-set consent region = silent purchase-tracking killer surfacing as an unexplained Conversions drop.

**The Google & YouTube channel — documented hazard:**
- The app by design auto-installs a Google tag, auto-creates purchase/add-to-cart/begin-checkout conversion actions, links/creates GA4 with auto ecommerce tagging, and syncs the catalog to MC (P~ support.google.com/merchants/answer/13494537). Google's own docs acknowledge duplicate-conversion risk when other tags exist, and its remediation direction (make the app primary, remove other tags) is the OPPOSITE of this fleet's Analyzify-primary architecture (P~ answer/15458661, answer/16424072).
- **Google is actively pushing a tag-migration flow** ("Migrate your Google tags with the Google & YouTube app", answer/15642481) that auto-detects existing tags and quotes the Aug 26, 2026 deadline — expect recurring in-UI reinstall nudges in Ads/MC. These prompts are a trap for this fleet: report to T, never accept (P~).
- Community threads document the app double-firing Ads purchase conversions (S community.shopify.com 414650 — matches the account's lived rogue-tag incident).
- With the channel uninstalled, ALL Google surface presence (Shopping, free listings) rides on the Simprosys feed — there is no Shopify-native sync.

**Vendors (SECONDARY - vendor docs):**
- **Simprosys**: feed sync (~15–30 min to MC, ~2h to Ads), free listings, LIA, in-app title/attribute optimization, PMax creation from app — AND an optional conversion-tracking + dynamic-remarketing module that must remain OFF (S simprosys.com). Feed stops updating if the subscription lapses. App health ~4.9★/4,285 reviews mid-2026 (NV aggregator).
- **Analyzify v4**: data-layer/GTM foundation, GA4 + Ads conversions + EC + remarketing, optional **server-side purchase add-on** (order data direct to GA4, vendor claims 98%+ accuracy) (S docs.analyzify.com). G7 must confirm which purchase path (browser vs server-side) is active — it sets the expected loss-rate baseline.

**SEO control surface on Advanced (G2):**
- robots.txt customizable via robots.txt.liquid (extend Liquid default groups, don't replace with plain text) (P✓ shopify.dev robots-txt); **sitemap.xml auto-generated, cannot be edited** — fix underlying resources instead (P~ help.shopify.com). No native structured-data control exists — JSON-LD is theme/app-owned; audit and dedupe (NV-negative from docs search).
- Shopify Markets on all plans (50 markets; geolocation pre-selection is Plus); international domains get per-domain sitemaps (P✓ themes/markets).
- Shopify Analytics vs GA4 mismatch is by design (server vs browser, timezones, session logic) — Shopify orders = revenue truth (P~ discrepancies page; ranges 5–10%/10–30% are SECONDARY).

### F2. Deadlines
| Date | What | Owner |
|---|---|---|
| **2026-08-26** | Advanced TY/OSP scripts turn-off + force-upgrade | T executes upgrade/migration; G0/G7 detect + escalate with evidence NOW; G9 freezes bid/budget judgments across the migration window |

### F3. Must verify live
- `checkoutProfiles.typOspPagesActive` on BOTH stores — the single most urgent check.
- Settings → Checkout: capture Additional-scripts contents + customizations report BEFORE auto-upgrade deletes them.
- Admin API scriptTags census (orphans from uninstalled apps incl. G&Y remnants).
- Settings → Customer events: pixel inventory — Analyzify present/connected; no leftover G&Y/Simprosys pixels.
- Analyzify purchase path (browser vs server-side add-on) on both stores.
- Ads conversion-action census: no surviving Shopify/G&Y-sourced actions; Purchase sole Primary.
- GA4: no lingering Shopify-created streams/tag links.
- Simprosys: tracking/remarketing toggles OFF (screenshot), feed country/currency ZA/ZAR, refresh recency, subscription active.
- Post-purchase upsell app presence (changes where checkout_completed fires).
- Settings → Customer privacy: ZA + sold-to regions not consent-required in a way that suppresses the Analyzify pixel.
- 28-day Shopify-vs-GA4-vs-Ads-Conversions baseline ratio BEFORE the TY/OSP migration.

### F4. Never do
- Never reinstall the G&Y channel or accept Google's tag-migration prompts — T decision only.
- Never enable Simprosys tracking/remarketing.
- Never recreate tracking via Additional scripts/ScriptTags/checkout.liquid (blocked since 2025-02-01; dead 2026-08-26); web pixels only.
- Never treat browser-pixel/GA4 purchase counts as truth against Shopify server orders.
- Never edit sitemap.xml (impossible); only robots.txt.liquid is controllable.
- Never have agents execute checkout-profile changes, TY/OSP upgrades, or pixel edits — tracking-continuity-critical, T-reserved.
- Never promise in-checkout customizations on Advanced (Plus-only surface).

---

## G. Search Console and organic search (G2 primary; G0, G7, G8, G10 consumers)

### G1. Must know
**Search Console 2024–2026 feature wave:**
- **Generative AI performance reports launched 2026-06-03** (expanded access 2026-06-23): dedicated views of impressions in AI features (AI Overviews + AI Mode combined in Search; gen-AI in Discover) broken down by page/country/device/date — **impressions only: no clicks, no CTR, no query data**; UK-first gradual rollout (P✓ developers.google.com/search/blog/2026/06/gen-ai-performance-reports — independently re-confirmed by this dossier's own search; help doc support.google.com/webmasters/answer/16984139) [AV⊘ env-blocked; dossier re-search CONFIRMS].
- Google confirmed at that launch that **AI-feature impressions were ALWAYS inside overall Performance totals** — the report is a breakdown, not new inventory; never add gen-AI impressions on top of totals [dossier re-search CONFIRMS].
- **AI Mode data has counted in the Performance report "Web" type since 2025-06-17, with no separate filter** — a structural break in organic CTR/position series at that date (S searchengineland 457076). Click/impression/position counting rules for AI Mode are secondary paraphrase (S) — don't build precision logic on AI-surface position.
- **No query-level AI-surface data exists anywhere in GSC** as of 2026-07 (S ppc.land); AI citation intelligence must come from controlled SERP sampling (G6/G10). No Search Analytics API exposure of gen-AI report data announced (NV-negative).
- 24-hours view (Dec 2024) + **Search Analytics API hourly data since 2025-04-09** (HOUR granularity, 10-day window — better than the UI) (P~ search blog). Quotas: 1,200 QPM/site/user; URL Inspection 2,000/day + 600 QPM per property (P~ webmaster-tools/limits).
- Recommendations (experimental, 2024-08-05), Achievements (2025-09-15 — explicitly NOT ranking signals), Insights merged into main UI (2025-06-30), and **platform properties (2026-07-07)**: verify Instagram/TikTok/X/YouTube accounts for their Search+Discover visibility reporting (S ppc.land — setup needs platform logins = T). All are gradual rollouts — absence on a property is not an error (P~).

**Ranking updates 2025→today (annotation calendar for G8/G2):**
- 2025: core Mar 13–27; core Jun 30–Jul 17; spam Aug 26–Sep 22; core Dec 11–29 (S searchengineland citing the Search Status Dashboard).
- 2026: core Mar 27–Apr 8; core May 21–Jun 2; spam Jun 24–26. No confirmed July 2026 update as of the 31st. Next core expected Q3 2026 by cadence (expectation, not announcement). A short Mar 24–25 2026 spam update is reported but unconfirmed (NV).
- The **Search Status Dashboard** (status.search.google.com) is the authoritative record — but it and all Google doc hosts are 403-blocked from this sandbox; update monitoring must route via search/trade press, and a fetch failure must never be reported as "no update" (P✓ — directly observed this session).

**Structured data & policies:**
- June 2025 "Simplifying the search results page": 7 types deprecated (Book Actions later reversed) — **no core ecommerce types touched**: Product snippets, merchant listings, review snippets, breadcrumb, Organization, LocalBusiness all remain (P~ search blog Jun 2025). FAQ/HowTo rich results effectively dead since Aug 2023. Practice-problem/dataset support ended Jan 2026 (S).
- **Loyalty program (MemberProgram) markup** (launched 2025-06-10): country-gated to 8 countries — **ZA excluded**; no SERP benefit for the loyalty redesign until the list expands (P~ loyalty-program doc).
- Product markup: product-snippets vs merchant-listings split; ProductGroup variant markup — current requirements NOT re-verified this session (NV); G2/G3 must validate against the live doc + Rich Results Test before markup changes.
- Site reputation abuse policy (updated 2024-11-19): first-party oversight no longer exempts third-party content; enforcement = manual actions; claims of algorithmic enforcement are NOT Google-confirmed (P~ search blog).
- Core Web Vitals: **LCP ≤2.5s / INP ≤200ms / CLS ≤0.1** at p75; INP replaced FID Mar 2024; tie-breaker-class signal (S almanac + baseline).
- Ecommerce crawl guidance: faceted nav is "by far the most common source of overcrawl" (Dec 2024 crawling docs); pagination = consistent URLs + real `<a href>` (Google doesn't click buttons); variants → canonical to parent product URL (P~ ecommerce docs). Shopify defaults usually comply; theme customizations break it — audit.
- **Indexing API remains JobPosting + BroadcastEvent only** — never submit product/collection URLs; 200-OK ≠ endorsement; spam policies apply (P~ indexing-api docs). Sitemap lastmod is what Google reads (ping endpoint dead).

**AI-search optimization doctrine (canonical for G2/G10):**
- Google's first official AI-optimization guide (2026-05-15): AI Overviews/AI Mode are "rooted in core Search ranking and quality systems", use RAG + query fan-out over the Search index; "optimizing for generative AI search… is still SEO". Mythbusting: **llms.txt, chunking, special AI schema, AI-specific rewriting are NOT needed** (P~ developers.google.com/search/docs/fundamentals/ai-optimization-guide). This overrides any conflicting GEO/AEO vendor claim.
- **Google-Extended is a robots token, not a crawler**: disallowing it opts out of Gemini/Vertex training+grounding only — it does NOT remove a site from AI Overviews/AI Mode (which draw from the Search index). AI-surface exclusion = noindex/snippet controls, which also gut normal snippets — a T-level revenue decision (S trakkr + P~ crawler list; snippet-control mechanics NV — ai-features doc not fetched).
- AI Overviews: 200+ countries/40+ languages since May 2025 (100+ countries Oct 2024) — ZA English SERPs show AIOs for informational queries (P~ blog.google; ZA-specific = S local agencies, LIKELY). AI Mode: ~180-country English expansion mid-2025 + 35 languages/40 countries 2025-10-07 — **ZA-specific presence unconfirmed; test empirically from ZA IPs** (NV for ZA).

### G2. Deadlines
| Date | What | Owner |
|---|---|---|
| Q3 2026 (expected) | Next core update by cadence — unofficial | G0 watch via search fallback; G8 annotate |
| Passed | Practice-problem markup support ended Jan 2026 | none — ignore stale vendor advice |

### G3. Must verify live
- Gen-AI report presence on both properties (absence expected — UK-first).
- Recommendations/Achievements presence; harvest recommendation cards.
- Hourly Search Analytics API call works; which Cloud projects hold GSC API access.
- Manual actions + Security issues panels EMPTY on both properties.
- Rich Results Test on key PDPs + Merchant listings/Product snippets enhancement reports; which product experience the theme markup qualifies for.
- Theme canonicals on ?variant= URLs; faceted/filtered collection URL handling; Shopify robots.txt diff vs faceted-nav guidance (propose-only).
- ZA-IP empirical AI Overviews/AI Mode trigger testing on money queries (docs can't answer).
- CWV report per URL group (mobile INP first — app-heavy Shopify themes commonly fail).
- robots.txt for inherited AI-token blocks; nothing blocking /products/ or /collections/.
- Sitemap submitted/processed clean; plausible lastmod.
- Organic-clicks overlay on Dec 2025 / Mar 2026 / May 2026 core windows → update-sensitivity profile.
- From an unrestricted context: fetch answer/16984139 + the ai-features doc (snippet controls) — several counting rules above rest on secondary paraphrase.

### G4. Never do
- Never submit ecommerce URLs via the Indexing API.
- Never block Google-Extended expecting AI Overviews/AI Mode removal.
- Never add gen-AI report impressions on top of Performance totals.
- Never compare organic CTR/position across 2025-06-17 without the AI-Mode-fold-in caveat.
- Never implement deprecated structured-data types or FAQ/HowTo plays expecting rich results; never add MemberProgram markup expecting ZA surfacing.
- Never state update dates from memory — confirm against the dashboard record every time.
- Never let an agent edit robots.txt/canonicals/noindex autonomously — deindexing blast radius; propose-only.
- Never present "algorithmic site reputation abuse enforcement" as Google-confirmed.

---

## H. Google Business Profile and local visibility (G4 primary; G0 sentinel; G7 measurement guard)

*(Evidence note: Google help pages were egress-blocked, but this domain got the dossier's strongest independent verification — the verifier downloaded Google's own API client (google-api-python-client 2.198.0, published 2026-06-25) and probed live discovery/API endpoints on 2026-07-31. API-level claims below are P✓ primary-verified; help-page claims are LIKELY from training baseline and flagged.)*

### H1. Must know
**The API surface (verified against Google's own discovery documents + live endpoints):**
- **Eight live GBP v1 API surfaces** as of 2026-07-31: Business Information (rev 20260426), Account Management (20260512), Verifications (20260527), Performance (20260415), Place Actions (20251022), Q&A (20240707), Notifications (20240707), Lodging (20241002). The **Business Calls API is fully turned down** — discovery + endpoints 404 [AV✗→corrected] (P✓ discovery docs + live probes).
- **Default quota after enabling is 0** — a separate GBP API access request is required (warning verbatim in 8 of 9 discovery descriptions; Verifications lacks the text but the requirement stands) [AV✗→corrected] (P✓).
- Performance API v1: exactly 3 methods — fetchMultiDailyMetricsTimeSeries, getDailyMetricsTimeSeries, **searchkeywords.impressions.monthly.list** (the programmatic "what queries found the profile" feed); 11 usable DailyMetric values (+UNKNOWN sentinel); BUSINESS_CONVERSATIONS is orphaned post-chat-removal; CALL_CLICKS is the only living call metric [AV✓/AV✗-minor] (P✓).
- **No reviews resource exists in any v1 surface** — review read/reply remains on legacy v4, and the v4 reviews endpoint is LIVE (401 auth-required vs 404 on sunset paths, verified 2026-07-31) [AV✓]. v1 touchpoints: NEW_REVIEW/UPDATED_REVIEW pubsub + Location.metadata.**newReviewUri** (ready-made review-solicitation link) (P✓).
- **Correction to the UI-only assumption: legacy v4 localPosts (Google Posts) and v4 media (photos) endpoints are STILL LIVE** (401 auth-required, calibrated against five 404-ing sunset v4 paths) — posts and photos remain automatable via v4; canOperateLocalPost field is deprecated but the posting surface is not [AV✗→corrected] (P✓ live probes). Products, social links, and contact fields appear UI-only (social-links-as-attributes unverified — run attributes.list to settle).
- Place Actions enum: APPOINTMENT, ONLINE_APPOINTMENT, DINING_RESERVATION, FOOD_ORDERING, FOOD_DELIVERY, FOOD_TAKEOUT, **SHOP_ONLINE** (the retail one), SOLOPRENEUR_APPOINTMENT — **no WhatsApp/SMS/chat type exists** [AV✓] (P✓).
- Health sentinel fields: Verifications.getVoiceOfMerchantState + Location.metadata.{hasVoiceOfMerchant, hasPendingEdits, hasGoogleUpdated, duplicateLocation} — the programmatic suspension/silent-edit watch (P✓ discovery docs).

**Feature state (training-baseline LIKELY — re-fetch before hardcoding):**
- GBP **chat/messaging AND call history removed July 2024** (new chats stopped ~Jul 15; gone Jul 31) — any chat CTA playbook is obsolete; contact stack = phone, website link, social links; wa.me deep-links are an unofficial workaround (T decision) (P~ answer/14591237).
- Website builder sunset Mar 2024; redirects died 2024-06-10 (P~).
- Local ranking factors remain exactly three: **Relevance, Distance, Prominence** (reviews count/score/recency + web presence; SEO feeds Prominence); "can't request or pay for better local ranking" (P~ answer/7091 — stable doc).
- Review policy: **no gating** (no selective solicitation, no discouraging negatives), **no incentives** (money/discounts/gifts = conflict-of-interest violation); removal only for genuine policy violations via flag + Reviews Management Tool (one appeal per review) (P~ answer/3474122 + contributionpolicy).
- Business name must match real-world name — keyword stuffing risks suspension (relevant if anyone proposes "BeautyOnTApp – Korean Skincare South Africa") (P~ answer/3038177).
- GBP eligibility requires in-person customer contact — an online-first retailer sits close to the line; never expand the profile in ways that misrepresent physical presence (P~ guidelines).
- GBP→Ads linking enables location assets and **auto-creates Google-hosted "Local actions" conversion actions** without operator action (see Section C — this account's 194 phantom-conversion experience) (P~ answer/9013531).
- Product editor ("Edit products") availability for ZA retail profiles: UNCONFIRMED — check the live UI (NV). SWIS/Pointy + local inventory programs: ZA support NOT confirmed (Section E's seroundtable source says LIA lists ZA; this domain's baseline says it didn't — **conflict, resolve in the live MC UI before anyone touches local feeds**) (NV).
- Gemini-in-Maps ("Ask Maps", AI review summaries) launched US-first Nov 2024; ZA state unknown (NV). AI surfaces synthesize GBP data + reviews — G4's data completeness feeds G10's citation visibility.
- UTM tagging on the GBP website link: untagged clicks land as google/organic; convention ?utm_source=google&utm_medium=organic&utm_campaign=gbp_listing preserves channel grouping (S industry practice) — **G7 sign-off + T execution required** (measurement change).

### H2. Must verify live
- Ads conversion actions: no Local-actions row Primary or inside "Conversions" (standing check); GBP link + location-asset + auto-create setting state.
- GBP API access quota non-zero (else file the access request before any G4 automation).
- v4 reviews endpoint functional test with current OAuth; v4 localPosts/media test if post/photo automation is wanted.
- attributes.list for the ZA category → definitive url_* (social/WhatsApp) answer; placeActionTypeMetadata.list → SHOP_ONLINE eligibility.
- Product editor presence in the ZA profile UI; existing products compliance (no free-delivery claims).
- Q&A visible on the live ZA profile; seed brand FAQs if empty.
- VoiceOfMerchant baseline + Notifications Pub/Sub subscription (GOOGLE_UPDATE, LOSS_OF_VOICE_OF_MERCHANT, NEW_REVIEW, NEW_QUESTION).
- GBP website-link UTM state + how GBP sessions classify in GA4 today.
- MC UI: is any local program offered to the ZA account? (settles the LIA-in-ZA source conflict).
- ZA-context SERP: profile renders, local-pack presence for category terms, AI Overviews/review-summaries on local results (G10 baseline).
- Profile type (storefront vs service-area; address shown/hidden) matches physical reality.

### H3. Never do
- Never gate or incentivize reviews (policy violations; takedown + restriction risk) — solicit uniformly via newReviewUri only.
- Never let Local-actions conversions become Primary or enter "Conversions"; never "fix" them agent-side (T-only; they're locked anyway).
- Never keyword-stuff the business name or misrepresent physical presence (Voice-of-Merchant suspension risk).
- Never attempt local inventory/SWIS/Pointy setup before the ZA-support conflict is resolved in the live UI (and MC writes are T-only regardless).
- Never make free-delivery claims in GBP posts, offers, products, or Q&A answers.
- Never build on GBP chat, call history, the website builder, or v4 location-management — all dead.
- Never change the GBP website link URL/UTMs without G7 sign-off + T execution.
- Never mass-flag competitor reviews or file removal requests for merely-negative reviews.

---

## I. AI Overviews, AI Mode and citation visibility (G10 primary; G2, G3, G6 feeders)

*(Evidence note: the dedicated researcher for this domain was fully network-blocked and returned honest training-baseline hypotheses (cutoff Jan 2026, all NV). This section therefore synthesizes those hypotheses WITH cross-domain verified facts from Sections A/E/G and this dossier's own verification searches. The Jan–Jul 2026 window remains a partial blind spot — G10's first task is the re-verification pass in I3.)*

### I1. Must know
**Availability (the ZA matrix):**
- AI Overviews: expanded to 100+ countries Oct 2024, 200+ countries/40+ languages by May 2025 — **ZA English inclusion is high-confidence but SECONDARY-sourced** (SA agency observation + the Oct 2024 expansion); AIOs are observed on ZA SERPs for informational queries (S — LIKELY; empirical ZA-IP confirmation required).
- AI Mode: US Labs 2025-03-05 → all-US May 2025 → UK/India → **180 additional countries in English announced 2025-08-21/22** (confirmed by this dossier's re-search: pre-expansion coverage was only US/UK/India, so the 180-country wave almost certainly included ZA) → 35+ languages/40+ more countries 2025-10-07. An SA-local source reports AI Mode rolling out for South African users (S lerouxdigital.co.za, found via this dossier's search). **Working status: AI Mode LIKELY live in ZA (English) since ~Aug/Sept 2025 — confirm from a ZA IP before any strategy assumes it** (S/NV).
- **Ads in AI Overviews: NOT in ZA** — live in exactly 12 countries in English (US, AU, CA, IN, ID, KE, MY, NZ, NG, PK, PH, SG) as of the Dec 2025 expansion; ads in AI Mode: US-only testing (P✓ support.google.com/google-ads/answer/16297775 — from Section A). ZA SERPs show AI surfaces WITHOUT ad slots; Kenya/Nigeria inclusion makes African expansion plausible — recheck quarterly.
- US-first features with no ZA path yet: Search Live, personal context, agentic checkout/"buy for me", virtual try-on (apparel-only anyway), Direct Offers, Universal Cart, UCP (US-first; CA/AU/UK by end-2026 per Section E) (NV/S).

**Mechanics & doctrine (validated by Google's 2026-05-15 AI-optimization guide, Section G):**
- AI Overviews/AI Mode run on **core Search ranking systems via RAG + query fan-out** over the Search index; citation comes from being indexed, ranked, snippet-eligible; **no opt-in, no payment, no special markup exists** — "optimizing for generative AI search is still SEO" (P~ ai-optimization-guide + ai-features doc). llms.txt, chunking, AI schema: explicitly unnecessary.
- Fan-out retrieves **passages**, not pages — self-contained, extractable sections (the fleet's 40–60-word answer-passage discipline) are the correct authoring shape (NV mechanics + P~ guide).
- **Google-Extended does NOT control AI search surfaces** (Gemini training/grounding only); exclusion runs through noindex/nosnippet controls which also destroy normal snippets — T-level revenue decision (see Section G).
- **Measurement:** AI-surface data sits inside Performance-report Web totals since 2025-06-17 (no filter); the June 2026 gen-AI report adds an impressions-only breakdown (no clicks/CTR/queries; UK-first) — any "AI traffic" number is otherwise a third-party estimate and must be labeled as such (Section G, confirmed). GA4's new **"AI Assistant" channel** (May 2026) captures AI-assistant referrals (ChatGPT, Gemini, Perplexity) as first-party data — baseline it now (Section D).
- **Shopping in AI surfaces:** panels are built from the Shopping Graph — **Merchant Center feed quality is the only merchant-side lever**; Conversational Attributes (GML 2026) mean AI reads feed fields beyond title/description; AI Performance Insights pilot in MC shows AI-surface discovery when it reaches the account (Section E). Simprosys feed completeness = AI-shopping optimization.
- Agentic-commerce infrastructure: AP2 (Agent Payments Protocol, announced 2025-09-16 with 60+ partners — signed Intent/Cart mandates) and Google's UCP are real but **nothing is implementable for a ZA merchant today**; if agentic checkout ever reaches ZA/Shopify, orders would land as normal Shopify orders with anomalous session signatures — G7 has this in its anomaly taxonomy as documentation only (NV).

**Observed impact (SECONDARY — never quote as Google-confirmed):**
- Pew (2025-07-22, US panel): result-link clicks ~8% of visits with an AI summary vs ~15% without; ~1% clicked a source inside the summary; sessions ended more often (S — figures from training memory, re-verify before client-facing use).
- Ahrefs (Mar 2025): ~34.5% lower CTR for top organic result when an AIO is present; direction corroborated by multiple 2025 studies (S).
- Trigger pattern: AIOs fire overwhelmingly on informational/how-to/ingredient-education queries; branded/transactional queries stay comparatively AI-free — but AI Mode shopping panels erode that boundary (S). Organic informational-traffic decline is a secular headwind, not automatically a fleet failure; G9 must not approve "recover AI-lost clicks" spend without a specific G10 citation thesis.

### I2. Never do
- Never apply noindex/nosnippet/max-snippet as an "AI opt-out" (kills normal search too; T decision only); never block Google-Extended expecting AI-surface removal.
- Never report a separate "AI Overviews traffic" metric from GSC (doesn't exist); label all AI-traffic figures as estimates with methodology; never add gen-AI-report impressions on top of totals.
- Never assume US-announced AI features are live in ZA without a same-week ZA-geo check.
- Never add invented AI-optimization markup or llms.txt on citation promises.
- Never let AI-citation-chasing content carry free-delivery claims or policy-violating copy — content written to be quoted by AI is still brand copy under standing rules.
- Never let any agent act on agentic-commerce opt-ins (buy-for-me, AP2/UCP, MC checkout features) — T-reserved.
- Never present this domain's training-baseline claims as current without the I3 re-verification.

### I3. Must verify live (G10's standing re-verification pass)
- **ZA-IP empirical check (highest priority):** AI Mode tab presence on google.com/google.co.za (signed-in/out, browser + app); AIO trigger log for the tracked beauty keyword set; citation log (is beautyontapp.com / Pastry cited, for which queries).
- Fetch and diff the four canonical docs from an unblocked context: ai-features doc, AI Overviews help (websearch/answer/14901683), AI Mode availability article, performance-report help (webmasters/answer/7576553) — specifically any post-Jan-2026 new controls or reporting.
- Both storefronts' rendered HTML + robots.txt for stray nosnippet/data-nosnippet/max-snippet/noindex/Google-Extended directives (theme- or app-injected) — report, don't edit.
- Ads account: any impressions serving into AI surfaces for ZA (new segments/indicators); quarterly recheck of the ads-in-AIO country list.
- Merchant Center: any agentic-checkout/price-tracking/AI-insights surfaces visible to the ZA account — screenshot, escalate, no writes.
- GSC informational-page cohort monthly CTR series since 2024 (the observational substitute for the missing AI breakdown); GA4 AI Assistant channel baseline.
- Gemini app from a ZA device with shopping-intent beauty prompts: recommendations? citations? checkout capability?
- Whether Shopify has announced AP2/agentic-checkout participation applicable to Advanced ZA stores (shopify.dev/editions — determines if agentic orders are even possible on this stack).

---

## J. Auction insights, competitors and controlled SERPs (G6 primary; G1, G5, G9 consumers)

*(Evidence note: this researcher was fully network-blocked — claims are training-baseline (mostly stable, multi-year definitional facts) marked LIKELY, with volatile items flagged. G6 must run the J3 re-verification before hardening any of this into procedure.)*

### J1. Must know
**Auction Insights mechanics:**
- Available for Search and Shopping only (not Display/Video; PMax had no classic auction insights as of Jan 2026 — **whether it shipped since is a live check**, given 2025–26 PMax reporting expansion) (P~ answer/2579754).
- Search = six metrics (IS, overlap rate, position-above rate, top-of-page rate, abs-top-of-page rate, outranking share); **Shopping = three only** (IS, overlap, outranking) — Shopping pressure tracking must lean on overlap + outranking (P~).
- Domain-level rows; only competitors above an unpublished minimum-activity threshold in auctions YOU entered appear — **absence ≠ inactivity** in a low-volume ZA niche; data lags ~1 day and restates (P~/NV).
- **Not exposed in the Google Ads API or Looker Studio connectors as of Jan 2026** — UI/Report-Editor/scheduled-download only. Any agent quoting auction-insights numbers without a UI export attached is fabricating (NV — re-verify against current API notes; the account's audit protocol already requires the CSV [source: skill library]).
- IS definitions: IS = impressions ÷ estimated eligible; top IS / abs-top IS are location-based (not rank); **lost IS (budget) = spend decision (G9-actionable, reversible); lost IS (rank) = quality/bid problem** (creative/QS work); <10% reported only as "<10%"; click share = clicks ÷ estimated max (P~ answer/2497703).

**Controlled SERP discipline (the whole fleet's law):**
- Google explicitly warns against live-searching your own ads: fruitless impressions depress CTR (a QS input) and personalization can suppress your ad from your own results → false "ad not serving" alarms. **Ad Preview & Diagnosis** (any geo/device/language, zero impression cost) is the only safe self-check (P~ answer/2564584).
- Google's spam policies prohibit **machine-generated traffic** — automated queries/scraping of Google SERPs (rank checkers, headless screenshots, curl) violates TOS and risks IP-level flags (P~ spam-policies).
- Compliant SERP-intelligence stack: (1) Ad Preview (own ads); (2) Ads reports — auction insights/IS/search terms; (3) Search Console (organic, G2); (4) **Ads Transparency Center** (competitor creatives, region=ZA filterable; non-political ads show creatives/format/region/dates — **NO spend, impressions, targeting or keyword data**; EU-DSA detail is EU-only; Shopping-format coverage historically incomplete — test live); (5) Merchant Center price competitiveness (competitor price benchmarks — ZA coverage UNCONFIRMED, check if it populates); (6) licensed third-party APIs (the Semrush MCP in this stack) — modeled ESTIMATES, always labeled, never mixed with Conversions-column actuals (P~/S/NV as marked).

**Trademark & brand controls:**
- Trademark policy is complaint-based; restrictions apply to AD TEXT, not keywords — **competitor-brand bidding is policy-legal in both directions and cannot be blocked**. Reseller/informational exceptions let BeautyOnTApp name the third-party brands it genuinely resells (P~ adspolicy/answer/6118).
- **2024 change (NV — verify):** complaints must now name specific advertisers + ads; industry-wide blanket blocks discontinued and legacy ones phasing out — any assumed blanket protection on "Beauty On Tapp"/"Pastry Skincare" may already be gone; trademark defense is per-offender whack-a-mole (T legal action only).
- Brand lists are shared-library assets drawn from Google's brand database; missing brands need a brand request (T action). Brand inclusions constrain broad match to brand traffic (now inside AI Max brand controls — Section A); **PMax brand exclusions** serve defense: exclude OWN brands from PMax so brand traffic routes to the controlled brand campaign, and exclude competitor brands PMax shouldn't chase (P~ — the account already runs The Body Shop + Standard Beauty exclusions [source: skill library]).
- Misrepresentation (impersonation/implied affiliation) IS proactively enforced — the symmetric constraint: no competitor names in the fleet's ad copy, ever.

### J2. Decide
- Whether to ask T to (1) confirm/request both brands in Google's brand database, (2) apply own-brand PMax exclusions to formalize brand-traffic routing (reversible but traffic-shifting — flag before executing), (3) re-assess trademark defense posture post-2024 scoping change (CIPC registration status is the prerequisite).

### J3. Must verify live
- PMax auction insights / IS columns: did they ship post-Jan-2026? (Live UI check.)
- 30-day auction insights baseline: Search brand campaign + Shopping, by device — competitor domains present (Secret Skin?), overlap/outranking trends; whether Shopping auction insights renders at all at ZA volume (empty = itself a data point).
- Ad Preview: brand + category queries, location=ZA (+ city-level), mobile & desktop — serving status + diagnosis messages.
- Transparency Center: own entities + competitors, region=ZA — which formats surface (do Shopping ads appear?), creative themes, last-shown dates.
- MC price competitiveness / best sellers: locate in current UI; market-insights opt-in state; does ANY benchmark data populate for the ZA feed?
- Shared library: existing brand lists; are both own brands in Google's brand database; current PMax brand-exclusion state.
- Semrush MCP: ZA-database position-tracking project exists with competitor domains configured.
- Re-fetch all cited policy/help pages from an unblocked context (everything in this section is currently unfetched).

### J4. Never do
- Never live-search Google to check own ads (Ad Preview only); never click competitor ads; never scrape/automate queries to Google SERPs.
- Never put competitor brand names in ad text, paths, or assets, or imply affiliation.
- Never build automation assuming auction insights exists in the API/Looker Studio (unverified); never report auction-insights numbers without a UI export.
- Never file trademark complaints, brand-database requests, or MC writes agent-side (T only).
- Never treat auction-insights absence as competitor inactivity; never quote Transparency-Center or Semrush figures as verified spend; never let estimated competitor spend enter G8's revenue models as fact.
- Never judge competitive defense on "All conversions".

---

## K. Ads policy, beauty-claims compliance and South African law (all agents; G3/G5/G9 sharpest exposure)

*(Evidence note: both researchers for this domain were fully network-blocked. Everything below is training-baseline legal/policy knowledge (cutoff Jan 2026), honestly labeled NV/LIKELY. It is structurally sound as a risk map but MUST NOT drive any enforcement action until G0's re-verification pass fetches the live pages. The one verified fact: this sandbox cannot reach any Google policy page — policy monitoring needs a search-based or out-of-sandbox fallback.)*

### K1. Google Ads policy map for a ZA beauty retailer (NV/LIKELY — re-fetch before acting)
- **Healthcare & medicines** (adspolicy/answer/176031) governs health-adjacent cosmetic claims. The line: appearance-based framing ("reduces the appearance of wrinkles", "for blemish-prone skin") is compliant; treat/cure/prevent/heal a named condition (eczema, psoriasis, dermatitis, rosacea, acne-as-medical-condition), "repairs skin damage", "clinically proven to cure" converts the ad into a restricted health ad. Prescription-drug terms (tretinoin, Retin-A, hydroquinone, isotretinoin, corticosteroids) in keywords/copy/landing pages trigger restrictions no retailer certification can clear. An "unapproved pharmaceuticals and supplements" list bans products by ingredient regardless of claims. **CBD: ZA is believed NOT an allowed location** (2023 relaxation was US-state-scoped with LegitScript certification; expansion unconfirmed) — any CBD/hemp SKU's advertisability must be checked live, never assumed. This maps directly onto the account's known "Illegal drugs / Misleading claims" disapproval history [source: skill library §Merchant Center Health].
- **Misrepresentation** (answer/6020955): unavailable offers / dishonest pricing (checkout must match ad promise — the policy basis for the no-free-delivery rule), unacceptable business practices (egregious → suspension without warning), unclear relevance, unreliable claims (the before/after and miracle-claims hook). Before/after transformation imagery in any asset feed = disapproval-risk pending live confirmation of current rule placement.
- **Personalized ads** (answer/143465): health conditions and weight loss are prohibited personalization bases; slimming/cellulite/body-sculpting framing can strip audience eligibility; cosmetic-procedures is a restricted category; minors get no personalization.
- **Shopping ads policies + MC requirements**: mirror Ads restrictions plus data/image rules (no promo text/watermarks/overlays in product data or images; GTIN where assigned; price/availability parity). Free-shipping-over-threshold belongs ONLY in MC shipping settings — never in titles/descriptions or ad copy.
- **Enforcement machinery**: egregious violations = immediate suspension, no warning; most others = 7-day warning email; strikes program (3-day/7-day holds → suspension; 90-day expiry) applies to a policy subset incl. unapproved substances; **new since 2026-07-21: in-account appeals impossible for decisions older than 6 months** (Section B — confirmed). Circumventing suspension with a new account = egregious + permanent + contaminates related accounts. Appeal only after root cause is fixed.
- **Advertiser identity verification**: rolling global requirement; if prompted, ~30 days or ads pause — G0 must watch for the prompt (NV).
- **Limited ad serving** ("getting to know you" impression limits for less-established advertisers on brand queries they're not associated with): relevant to any Secret Skin conquesting and to Pastry's account maturity (NV).
- **Unfair Advantage rewrite (~2025-04-14, NV):** one-ad-per-advertiser now reportedly per ad LOCATION, not per page — competitor double-appearances on one SERP are no longer per-se abuse; G6 must confirm before using in competitor narratives.
- **AI-content disclosure**: election ads only as of Jan 2026; retail unaffected; MC guidance says retain IPTC AI-generated metadata on AI product imagery (NV).
- **Billing (ZA)**: 15% VAT charged under SA electronic-services rules since ~2019; contracting entity and the ACTUAL VAT rate must be read off the latest live invoice, never hardcoded (NV; 2025 VAT-rate politics make this volatile).
- **Consent**: Google's consent-mode mandate covers EEA/UK/CH end users only — **ZA-only targeting carries no Google consent-mode obligation**; POPIA is separate law (cross-ref Section C/D).
- **Policy change log** (adspolicy topic page): Google pre-announces most changes 4–6 weeks out — G0's monthly read; the 2025–2026 log could not be retrieved this session, so the fleet's policy baseline is stale until pulled.

### K2. South African statutory overlay (NV — legal analysis from the Acts' known text; operator legal sign-off required before enforcement-grade use)
**POPIA (direct marketing & data-to-Google):**
- s69: electronic direct marketing = opt-in consent OR existing-customer soft opt-in (own similar products; free objection at collection and in every message); non-customers may be approached for consent ONCE (Form 4). The Information Regulator's Guidance Note (~Nov 2023) reads ALL electronic direct marketing as POPIA-opt-in territory.
- **Cross-brand trap:** the soft opt-in covers the responsible party's OWN similar products — BoT customer lists cannot market Pastry (or vice versa) without operator legal sign-off.
- Customer Match / enhanced conversions = processing + disclosure to Google requiring a s11 lawful basis, s18 privacy-policy disclosure naming Google, and a s72 cross-border mechanism (Google's data terms accepted in-account). **Hashed emails remain personal information — never describe uploads as "anonymized."**
- Skin-condition data (acne/eczema quiz answers, condition-tagged purchases) = special personal information (s26 health) — must never flow into GA4 audiences, Ads audiences, or Customer Match. Minors (<18): competent-person consent required — exclude known minors from all lists.
- Exposure: enforcement notices, fines to R10M, active direct-marketing enforcement since 2023–24.
**Medicines Act + FCD Act (the claim line that reclassifies products):**
- A "medicine" is defined BY CLAIMED PURPOSE — "treats acne", "heals eczema", "anti-fungal", "anti-inflammatory", "prevents infection" makes a cosmetic an unregistered medicine (s14(1) criminal exposure) regardless of Google approval. **The fleet's ad copy can literally reclassify a product.** "Cosmeceutical" has no legal status.
- Scheduled/banned actives in resold products: tretinoin/retinoic acid, adapalene, topical corticosteroids, minoxidil, hydroquinone (banned in cosmetics) — catalogue vetting is a statutory necessity (G3).
- Sunscreens: cosmetics if claims follow SANS 1557/CTFA rules — max label "SPF 50+"; "sunblock", "100% protection", "all-day protection", "waterproof", "prevents skin cancer" prohibited.
- Ingestible beauty (collagen etc.) with health claims = Category D complementary medicines with prescribed claims + mandatory SAHPRA disclaimer.
**ARB Code:** substantiation held BEFORE publication from an independent expert for every objective claim ("clinically proven", percentage claims); misleading-by-implication banned; genuine unretouched before/afters only; Appendix A bars cure/treat/prevent claims for cosmetics. ARB binds member media (not Google), but competitor complaints (Secret Skin direction — or ours against them, logged by G6 for T) force multi-channel copy withdrawal.
**CPA:** s23 lower-displayed-price rule (a stale lower feed price is arguably binding — one more reason for exact parity); s29/s41 misleading representations (fake was/now pricing — keep a dated prior-price ledger; no "SAHPRA approved" claims; no incentivized reviews presented as organic); s30 bait marketing (out-of-stock items still advertised = exposure, state "while stocks last" limitations IN the ad); s36 promotional competitions (written rules + disclosures before entry — applies to GBP/YouTube giveaways); s16 + ECTA s44 cooling-off rights (never understate them in returns copy).
**ECTA s43:** site must display legal name, registration number, address, VAT-inclusive prices incl. delivery, returns policy, payment security. All consumer prices VAT-inclusive (CPA s23 + VAT Act s65).

### K3. Must verify live
- Re-fetch every cited policy page from an unblocked context (the full list is in the domain files) — upgrade or correct each NV finding; pull the 2025–2026 policy change log.
- Policy Manager: current disapprovals/warnings/strikes/certification requests with DECISION DATES (6-month appeal clock); any identity-verification prompt.
- Billing: contracting entity + actual VAT rate off the latest invoice; payment methods offered.
- Customer Match / uploaded audiences / EC state: if any exist, freeze expansion → T for POPIA basis review; Google data terms acceptance state in account settings.
- Full-copy audit (both brands): RSAs, PMax/Demand Gen assets, sitelinks, callouts, MC titles/descriptions, landing pages — against the medicine-claim blocklist, SPF rules, free-delivery rule, before/after imagery.
- Catalogue ingredient scan: hydroquinone, retinoic acid, adapalene, corticosteroids, minoxidil, CBD/hemp; supplier SPF substantiation on file per sunscreen SKU.
- Klaviyo flows: opt-in records, opt-out in every message, one-shot consent requests, NO cross-brand list use without sign-off.
- Site: privacy policy names Google + cross-border transfer; PAIA manual; ECTA s43 disclosures; Information Officer registered with the IR.
- Prior-price ledger exists for every live strike-through/sale representation; price-parity sweep (feed vs PDP vs checkout, VAT-inclusive).
- GA4/Analyzify/audiences: no skin-condition attributes flowing to Google; skin quiz (if live) consent + storage + isolation from ad platforms.

### K4. Never do (consolidated policy + statutory)
- Never publish treat/cure/heal/prevent/anti-fungal/anti-inflammatory claims or named-disease framing in ANY surface (ads, feed, PDP, blog, GBP, AI-citation content) — Google disapproval AND unregistered-medicine exposure.
- Never put free-delivery claims (or any conditional offer stated unconditionally) in any ad asset, feed text, or GBP post; model free-over-threshold in MC shipping settings only.
- Never advertise CBD/hemp SKUs to ZA without live policy confirmation; never bid on or write Rx-drug terms; G5 maintains the standing Rx/disease negative list.
- Never use before/after transformation imagery in asset feeds or MC images pending live rule confirmation.
- Never build personalization on weight-loss/slimming/health/body-sculpting angles; never let skin-condition data reach any ad platform.
- Never upload Customer Match lists or expand EC data agent-side; never call hashed data "anonymized"; never cross-market BoT↔Pastry lists without operator legal sign-off.
- Never show a sale/was-now price without dated prior-price evidence; never advertise out-of-stock items without stated limitations; never run competitions without CPA s36 rules; never claim SAHPRA approval; never present incentivized reviews as organic.
- Never display VAT-exclusive consumer prices anywhere.
- Never create a new Ads/MC account to route around enforcement; never appeal before the root cause is fixed; never miss the 6-month appeal window (G0 flags at ~5 months).
- Never hardcode the VAT rate or Google contracting entity; read from the live invoice.
- Never treat this section as verified — it is the re-verification queue's highest-priority customer.

---

## 14. Per-agent upgrade briefs (G0–G10)

Each brief: what changed under your feet → new instruments → standing checks to add → hard limits. Section letters refer to this dossier.

### G0 — Delivery, conversion-config and account-health sentinel
- **Changed:** four hard deadlines inside 30 days (§1); auto-apply/Advisor/AI Max prompts are new config-drift vectors (§2.2); policy appeals now expire at 6 months (2026-07-21); Google doc hosts are unreachable from this sandbox — fetch failure ≠ "no change".
- **New instruments:** change_event audit query for Google-auto-applied changes; recommendation_subscription GAQL; Tag Diagnostics (Excellent→Urgent); EC diagnostics; GSC hourly API (10-day window) for intraday organic anomalies; GBP VoiceOfMerchant state + Notifications Pub/Sub; MC Needs-attention + feed-freshness watch.
- **Add to checklist:** daily — feed freshness (through Sept), MC/Ads disapprovals with decision dates; weekly — auto-apply state, change_event actor census, deadline countdowns; monthly — policy change log (search fallback), API-version census; every audit — Google-hosted actions 0-campaigns/0-Conversions check.
- **Never:** interpret a blocked fetch as "no update"; accept any ToS/verification/migration prompt (report to T); let a disapproval age past ~5 months unflagged.

### G1 — Daily Search, Shopping and PMax performance
- **Changed:** PMax is now auditable (channel report GA, full search-terms report, asset-group conversion metrics); PMax no longer auto-outranks Standard Shopping (Ad Rank decides); AI Max for Shopping is actively rolling onto Standard Shopping since 2026-07-24; the 2026-08-17 bidding change re-prices every budget-limited target campaign (§A).
- **New instruments:** PMax channel performance report (daily read); PMax search terms (feed G5); lost-IS(budget) vs lost-IS(rank) triage; official PMax evaluation pages.
- **Add:** pre-2026-08-17 inventory of budget-limited target campaigns with 30-day actuals; annotation discipline for the TY/OSP migration window and core-update windows; healthcare-policy disapproval codes = immediate escalation, never retry.
- **Never:** sum asset-level conversions (full-credit overcount); treat trailing click-dated Conversions as final (lag profile from G7); attribute ZA anomalies to AI-surface ad inventory (not live in ZA); flag EVC-inclusive video conversions as tracking corruption.

### G2 — SEO and Search Console
- **Changed:** AI Mode folded into Web totals since 2025-06-17 (CTR series break); gen-AI performance report live (impressions-only, UK-first); Google's 2026-05-15 AI-optimization guide is canon ("still SEO"; no llms.txt/AI schema); hourly API data; 7 structured-data types deprecated Jun 2025 (no ecommerce types); loyalty markup excludes ZA; GA4 channel-definition changes (AI Assistant channel) reshuffle Organic/Referral rows (§G, §D).
- **New instruments:** hourly Search Analytics API; Recommendations cards; platform properties (social visibility — T sets up); Merchant-listings/Product-snippets enhancement reports (the ZA-available ratings surface).
- **Add:** update-window annotation calendar (§G1); faceted-nav/variant-canonical audit (propose-only); nosnippet/AI-directive audit; CWV mobile INP watch.
- **Never:** edit robots.txt/canonicals/noindex autonomously; use the Indexing API for products; state update dates from memory; add gen-AI impressions on top of totals.

### G3 — Merchant Center, feeds and Shopify product data
- **Changed:** Merchant API era (Content API dies 2026-08-18); "Next" renames are permanent (attribute rules, data sources, Needs attention); 2026 spec = video_link live + 500×500 images by 2027-01-31; three parallel shipping-declaration surfaces; ToS + policy consolidation churn; feed data now powers AI surfaces (Conversational Attributes) (§E).
- **New instruments:** ZA availability matrix (§E1 — promotions/loyalty/checkout-links NO; free listings/regional pricing YES; LIA conflicted → resolve in UI); supplemental-data-source overlay pattern for enrichment (videoLinks, productHighlights, lifestyleImageLinks — Merchant-API-only); per-item pause/destination exclusions; price-competitiveness report (if ZA populates).
- **Add:** Simprosys Merchant API confirmation (NOW — §1); Simprosys tracking-toggles-OFF screenshot audit; PDP-schema-vs-feed parity check paired with G7's reconciliation; sub-500×500 image warning list; claims lint (medicine-claim blocklist §K) on every title/description before T pushes.
- **Never:** execute MC writes (spec → T); submit member prices/promotions/loyalty/checkout-links for ZA; let shipping settings understate checkout; use Content API field names in Merchant API payloads (gtin→gtins); patch a defaultRule without the complete supplemental-source list.

### G4 — Google Business Profile and local visibility
- **Changed:** chat/call-history dead (Jul 2024); Business Calls API fully turned down; 8 live v1 API surfaces + still-live v4 reviews/localPosts/media endpoints (posts/photos ARE automatable via v4, contra prior assumption); GBP quota defaults to 0 until access is requested; GA4×GBP integration rolling out (~Jun 2026, T links) (§H, §D).
- **New instruments:** Performance API searchkeywords.impressions.monthly (query-level profile data); newReviewUri (compliant solicitation link); VoiceOfMerchant sentinel; placeActionTypeMetadata (SHOP_ONLINE eligibility); attributes.list (settles social/WhatsApp link availability).
- **Add:** GBP→Ads link + location-asset state reported to G0 (auto-created local-actions trigger); product-editor ZA presence check; Q&A seeding; profile-completeness/review-velocity shared KPI with G2 (Prominence) and G10 (AI answers synthesize GBP data).
- **Never:** gate or incentivize reviews; keyword-stuff the business name; misrepresent physical presence; free-delivery claims in posts/offers/Q&A; change the website link UTMs without G7 sign-off + T execution.

### G5 — Search terms, keywords and negatives
- **Changed:** the SQR→negatives pipeline now extends to PMax (full search-terms report + 10,000 negatives + shared lists; account-level list caps at 1,000 and covers Search+Shopping inventory only); broad match defaults ON for new Search campaigns; AI Max search-term matching changes the query surface where enabled; brand-list creation now requires AI Max on Search (§A).
- **New instruments:** PMax search-terms report (UI + API); brand lists (via T); text-guidelines term exclusions (via T) as copy-level negative enforcement.
- **Add:** standing Rx/disease-term negative list (§K — tretinoin, hydroquinone, named conditions); medicinal-intent query classification (lawful to bid, unlawful to mirror in copy); Demand Gen has NO search terms/negatives — no pipeline extension there.
- **Never:** account-wide Medicube negative; broad product-type negatives ("face wash" class); negatives premised on suppressing PMax video/Display inventory (they only touch Search+Shopping).

### G6 — Auction insights, competitors and controlled SERPs
- **Changed:** Shopping auction insights = 3 metrics only; PMax auction insights existence = live check; Unfair-Advantage rewrite (~Apr 2025, NV) may legitimize competitor double-serving; trademark complaints now per-advertiser (2024 change, NV); Transparency Center = creatives only, no spend (§J).
- **New instruments:** Ad Preview & Diagnosis (only lawful own-ad check, geo=ZA); Transparency Center region=ZA; PMax channel report for indirect competitive reads; Semrush MCP (estimates, labeled); MC price competitiveness (if ZA populates); ZA-availability falsification watch (competitor promotion badges/stars sighting = escalate).
- **Add:** Secret Skin pressure baseline (overlap/outranking, weekly trend); empirical ZA SERP matrix (Shopping tab? seller stars? AIO frequency? AI Mode tab? ads in AIO?) via Ad Preview + occasional human checks.
- **Never:** scrape SERPs or automate Google queries; click competitor ads; report auction-insights numbers without a UI export; treat absence-from-report as inactivity; convert estimates into rand-spend claims.

### G7 — Measurement integrity and transaction reconciliation
- **Changed:** "(by conv. time)" columns are the only valid reconciliation basis (click-dated columns restate); EVCs live inside Conversions on video; ECW+ECL merged into one toggle (Jun 2026); ad_storage is now the sole GA4→Ads consent authority (2026-06-15); Google officially documents Shopify pixel-sandbox undercount; the TY/OSP migration (by 2026-08-26) will create a measurement discontinuity (§C, §D, §F).
- **New instruments:** Google's discrepancy taxonomy (triage checklist before "tracking is broken"); Tag Diagnostics + EC diagnostics (read-only); CartDataSalesView (API v24+) if cart data flows; conversion-lag profile publication; BigQuery free export as the unsampled substrate (T links).
- **Add:** pre-migration 28-day Shopify-vs-GA4-vs-Conversions baseline (NOW); single-source-per-event enforcement (no dual purchase paths incl. Analyzify sGTM + client); Google-hosted actions audit; EEA-exposure quantification; POPIA special-PI leak check (skin-condition attributes must never reach Google); MC conversion-sources snapshot (app-resurrection detection).
- **Never:** reconcile against click-dated columns; equate GA4 key events with Ads Conversions; "fix" the structural GA4 undercount by adding tags; execute any tracking/consent/property change (commission → T).

### G8 — Revenue analysis and recommendations
- **Changed:** Shopify = revenue truth, GA4 = gross-of-refunds behavioral lens (no native refund flow); NCA "new customer value" mode would inject synthetic value into Conversion value (strip before revenue comparison if ever enabled); profit stack (COGS + cart data) is available if T makes the MC write; AI-driven CTR erosion on informational content is a secular headwind, not a fleet failure (§C, §D, §I).
- **Add:** annotation calendar — core updates (§G1), 2026-08-17 bidding change, 2026-08-18 ecosystem turbulence window (Aug 15–25: unmigrated competitor feeds lapse, MC backlogs), 2026-08-26 TY/OSP migration; prior-price ledger oversight for every sale representation (CPA s41); VAT line reconciliation off the live invoice (never hardcode 15%).
- **Never:** let estimated competitor spend enter models as fact; read the Aug 15–26 windows as structural; exclude ZA-unavailable levers (promotion badges, seller stars, LIA, loyalty annotations) from forecasts as if they existed.

### G9 — Executive decision-maker and controlled executor
- **Changed:** "reversible" = 30-day undo window, technically bounded (§B); an urgent execution wave is due before 2026-08-17 (bid-target resets on T-approved packs); new one-click traps surround you (AI Max, Exploration, promotion mode, VTC checkbox, auto-apply, Advisor applies) — all outside authority; PMax experiments lock asset groups (check before touching); Editor ≥2.12 for T (§A, §B, §2.2).
- **Add:** change_event self-fingerprinting after every change; freeze windows around the TY/OSP migration; escalation duty on 2026-08-11 (Simprosys) and any ToS/verification prompt.
- **Never:** execute anything you cannot undo in 30 days; act on this dossier's NV items without point-of-use verification; approve "recover AI-lost clicks" spend without a G10 citation thesis; touch protected campaigns (KS_C8) or resurrect Killswitch/bleeder structures [source: skill library].

### G10 — AI Overviews, AI Mode and citation visibility
- **Changed:** AI Overviews live in ZA (LIKELY); AI Mode LIKELY live in ZA since ~Aug/Sep 2025 (confirm empirically); ads in AIO NOT in ZA (12-country list); gen-AI impressions report exists (Jun 2026, UK-first); GA4 "AI Assistant" channel gives first-party AI-referral data; Google's AI-optimization guide is canon — standard SEO, passage-level content, no special markup (§I, §G, §D).
- **New instruments:** gen-AI performance report (when it reaches the properties); GA4 AI Assistant channel baseline; MC AI Performance Insights pilot (watch for it); Conversational-Attributes feed lever (with G3); GSC informational-cohort CTR series (the observational AI-impact substitute).
- **Add:** the §I3 re-verification pass (your domain baseline is 7 months stale); ZA-IP observation log (AIO triggers, citations, AI Mode presence) as the only ground truth; claims discipline — AI-quotable content is still governed by the medicine-claim blocklist and no-free-delivery rule.
- **Never:** promise AI-query reporting (doesn't exist); report AI traffic without labeling estimates; recommend snippet/robots changes as AI opt-outs; treat US-announced AI features as ZA-live without a same-week check.

---

## 15. Master never-do list (fleet-wide, cross-domain)

The per-section never-do lists are binding in full. These fifteen are the cross-domain absolutes every agent carries:

1. **Never judge on "All conversions"** — Conversions column only, with its composition guarded (custom-goal trap, EVC inclusion, VTC checkbox) (§C).
2. **Never touch conversion actions, goals, attribution, windows, tracking, GA4 config, consent, or pixels from any agent** — T-reserved; Analyzify owns tracking (§C, §D, §F).
3. **Never reinstall the Google & YouTube channel or accept Google's tag-migration/reinstall prompts** — documented double-tagging + product-ID-rewrite risk (§F, §E5).
4. **Never enable Simprosys tracking/remarketing** — feed-only, forever (§F).
5. **Never enable AI Max, Smart Bidding Exploration, promotion mode, VTC-optimized bidding, NCA modes, or experiments agent-side** — structural/bidding-policy decisions for T; AI Max only ever behind the built-in experiment (§A).
6. **Never leave, or create, any auto-apply recommendation subscription; never let Ads Advisor apply anything** (§B).
7. **Never execute Merchant Center, Shopify, GBP, or billing writes from the fleet** — spec and hand off (§E, §F, §H, §K).
8. **Never make free-delivery claims on any surface** — ads, assets, feed text, GBP, Q&A, AI-quotable content; free-over-threshold lives in MC shipping settings only (§K, §E).
9. **Never publish treat/cure/heal/prevent or named-disease claims anywhere** — Google disapproval AND Medicines Act reclassification; appearance-framing only (§K).
10. **Never scrape Google SERPs, live-search own ads, or click competitor ads** — Ad Preview & official reports only (§J).
11. **Never assume a US-announced feature is live in ZA** — check the availability matrices (§E1, §I1) or verify same-week; and never diagnose ZA-absent surfaces (stars, badges, Shopping tab, AIO ads) as bugs.
12. **Never upload customer data (Customer Match, EC expansion) agent-side; never call hashed data "anonymized"; never let skin-condition data reach any ad platform** (§K).
13. **Never state platform facts (versions, dates, availability, policies) from training memory in decision-grade output** — cite this dossier's verified items or re-verify at point of use; the Ads API ships monthly.
14. **Never execute what cannot be undone within the 30-day change-history window** — the technical boundary of G9's mandate (§B).
15. **Never fabricate: NOT VERIFIED beats a filled cell, every time** [source: fleet discipline gates].

## 16. Source register and verification record

### 16.1 Primary sources retrieved this session (P✓ — content obtained via search-retrieval, docs index, or machine-readable endpoint)
Google Ads Help: answers 15726455, 16451273, 11396330, 14505308, 16260130, 16327396, 15235796, 12080169, 16127398, 14337539, 12997711, 13389795, 7684791, 17061251 (Aug-17 bidding change), 15489627, 14943482, 16290177, 16297775 (ads-in-AIO country list), 16710258, 15973205, 17051545. Google Search Central blog: 2026/06 gen-AI performance reports (independently re-confirmed), 2024/12 + 2025/04 hourly data, 2024/11 site-reputation-abuse, 2025/06 simplifying-search, 2024/12 crawling series; ai-optimization-guide (2026-05-15). Ads Developer Blog: v25 announcement 2026-07-22 (re-confirmed), v21 sunset reminder, v24/v24.1/v24.2, Merchant-API-in-Scripts (2026-04-22), offline-conversion migration (2026-05). Merchant API/Content API: live discovery documents (products_v1, datasources_v1, conversions_v1, content v2.1 rev 2026-07-30) — schema-verified. developers.google.com/merchant migration pages (re-confirmed: sunset 2026-08-18, v1beta 2026-02-28). GBP: google-api-python-client 2.198.0 discovery documents + live endpoint probes (8 live v1 surfaces; v4 reviews/localPosts/media live; Business Calls dead). Shopify: shopify.dev pages fetched in full via docs index — checkout-liquid, blocking-script-tags (2026-08-26 [AV✓]), pixels + pixel-privacy, checkout technologies, functions, flow, markets, robots-txt, product-sync, contextual-product-feeds, changelogs (Scripts sunset, delivery-profile deprecation 2026-07-01).

### 16.2 Primary pages identified but content only partially corroborated (P~ — LIKELY; re-fetch queue)
All support.google.com policy pages (§K list), measurement/GA4 help pages (§C/§D citations), Merchant Center program pages and country tables, GSC limits/report pages, consent-policy pages, GBP help pages, blog.google GML 2025/2026 collections. **The full re-fetch queue lives in each section's "Must verify live" list.**

### 16.3 SECONDARY sources (S — observed behaviour/workarounds only)
Search Engine Land, Search Engine Roundtable, ppc.land, PPC News Feed, Producthero, Swipe Insight, digitalapplied, almcorp, stape-io README, adnabu, litcommerce, gnuworld, zenventory, seroundtable, OneTrust/Didomi/Usercentrics/uniconsent (consent), Michalsons/DLA Piper (POPIA), Pew Research + Ahrefs (AI CTR studies), Shopify community threads, vendor docs (Simprosys, Analyzify), one SA-local source (Le Roux Digital — AI Mode ZA rollout). Community/vendor claims were never allowed to override primary sources; where they conflict (LIA-in-ZA), the conflict is labeled and routed to a live check.

### 16.4 Explicitly NOT VERIFIED (NV) domains
AI-search (7-month training-baseline gap — §I3 re-verification pass is G10's first task), competitive-auction volatile items, all policy/statutory claims (§K — highest-priority re-verification), Demand Gen details, ZA program-availability rows not confirmed in-account, Simprosys Merchant API migration state (THE live risk), GCR program existence, product-ratings ZA eligibility.

### 16.5 Verification record
- Adversarial pass: 32 claims across 4 domains → 11 CONFIRMED [AV✓], 5 REFUTED with corrections incorporated [AV✗], 16 environment-blocked [AV⊘] (of which the 2 most load-bearing — gen-AI reports, AI-impressions-in-totals — were independently re-confirmed by main-loop searches).
- Main-loop spot-verifications (2026-07-31): Content API sunset 2026-08-18 ✓; Ads API v21 sunset 2026-08-05 ✓; current Ads API = v25 (2026-07-22) ✓; GSC gen-AI reports (2026-06-03, impressions-only) ✓; AI Mode 180-country English expansion (Aug 2025) ✓; AI Mode ZA = SECONDARY-only (unresolved, routed to G10).

---

*Dossier ends. Next scheduled refresh: on or before 2026-10-31, or immediately upon (a) egress allowlisting of Google documentation hosts, (b) any deadline-register event completing, or (c) any AV⊘/NV item becoming decision-load-bearing.*
