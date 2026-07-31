# Google Intelligence and Agent Upgrade Dossier — PNCapital G0–G10 Fleet

**Prepared:** 2026-07-31 (SAST) · **Scope:** BeautyOnTApp + Pastry Skincare across Google Ads, Merchant Center, Shopify Advanced, GA4, Search Console, Google Business Profile, Google AI-search surfaces.
**Mode:** Investigation only. No account, campaign, tracking, Merchant Center, Shopify, GBP, website or scheduler changes were made.

**Evidence method note (read first):** Every platform claim below cites an official URL retrieved 2026-07-31. Because this session's egress proxy blocks direct fetches of Google/Shopify documentation hosts, official-page content was retrieved via search-engine retrieval of the cited pages (domain-restricted to official domains) rather than raw fetches; two artifact-level verifications used Google's own published packages (google-ads 31.2.0 client, googleads GitHub repos). Claims whose falsehood would trigger a damaging action are flagged **[RE-FETCH BEFORE ACTING]** and listed in §11 — re-read the cited URL from an unblocked browser before executing anything deadline-driven. Account-specific facts are labelled **LIVE ACCOUNT FACT** (verified via authenticated Shopify Admin API this session) or **NOT VERIFIED** with the exact tool needed. No volatile PNCapital figure in this dossier comes from memory.

---

# 1. Executive Verdict

- **A four-deadline August–September 2026 cluster is the top risk, and none of it is in current fleet rules:** (1) 17 Aug 2026 — budget-limited tCPA/tROAS campaigns start spending *to* their targets instead of overperforming them; (2) 18 Aug 2026 — Content API for Shopping sunset; (3) 26 Aug 2026 — Shopify non-Plus Thank-you/Order-status legacy scripts die (auto-upgrades already running since Jan 2026); (4) Sept 2026 — Search campaigns with ACA or campaign-level broad match auto-upgrade to AI Max. G0 owns the calendar; G9 owns the pre-deadline repairs.
- The **"Purchase is the only Primary" rule has a verified loophole**: a Secondary action inside a *custom goal* still feeds bidding. G0 must audit custom-goal membership per campaign, not just Primary/Secondary flags.
- The fleet's **"measurement corruption blocks execution" rule over-blocks G9**: Google's own docs separate tag-level defects from expected model/lag differences. Corruption must be classed COUNT / VALUE / ATTRIBUTION, and CONFIGURATION repairs stay eligible under all of them.
- **Auction Insights is no longer cleanly "browser-only"**: the six `auction_insight_*` metrics exist in Ads API v25, but access is allowlist-gated — G6's intake remains scheduled UI exports until an allowlist grant is confirmed live.
- **Official Google MCPs exist and are read-only** (Ads MCP: experimental, 2–3 read tools; Analytics MCP `analytics-mcp`): G9's writes must go through the Ads API; any design that routes writes via MCP silently fails.
- **The Ads API is at v25** (client 31.2.0, only v21–v25 supported). Fleet tooling referencing v20-or-earlier is dead code.
- **PMax is controllable now**: 10,000 campaign-level negatives, negative keyword *lists* attachable (Aug 2025), account-level negatives apply, brand exclusions/inclusions GA, full search-terms rows, channel-level reporting — G5/G9's negative architecture should be rebuilt on this, replacing any "PMax is a black box" assumption.
- **PMax no longer auto-beats Standard Shopping** (highest Ad Rank wins since Oct 2024); any priority-sculpting structure designed before that is behaving differently than designed.
- **LIVE ACCOUNT FACT:** five ACTIVE Medicube products currently have zero inventory (MDC005/007/008/009/011) while remaining ACTIVE in Shopify — the stock-to-bid/feed-parity loop (G3→G1/G9) is a live gap today, not a hypothetical.
- **Negatives now block misspellings** (since 26 Jun 2024) and search terms report under canonical spellings — the Medicube guard must cover the misspelling blast radius, and G5's conflict simulation must model it.
- **South Africa scoping corrections:** Merchant Center Promotions add-on is NOT available for ZA offers; ads in AI Overviews serve in 12 countries not including ZA; AI Mode IS live in ZA (Africa launch 21 Aug 2025). Free listings ARE available in ZA. Consent Mode v2 is an EEA obligation, not a ZA one; POPIA is the binding local regime.
- **Search Console now has an owner-level "Search generative AI control"** that can silently exclude the site from all AI surfaces, plus a new Generative AI performance report (3 Jun 2026, impressions-only, rollout-gated): G0 must verify the toggle reads *Include*; G10 finally has first-party AI-impression data but no clicks/queries.
- **Auto-apply is still the top silent-change vector**: ad suggestions auto-apply 14 days after creation *by default*, and the "remove conflicting negatives" recommendation can auto-delete deliberate scoping negatives (including Medicube routing negatives) if left eligible.
- **Duplicate work and missing handoffs found:** G8 re-pulling Ads metrics, G10 re-running G6's SERPs, G2/G10 double GSC pulls, G0/G7 both auditing conversion actions; missing: live stocked-vendor list G3→G5, advertised-OOS list G3→G1/G9, unsettled-window boundary G7→G1, executed-change verification loop G9→G0.
- **G9 is currently under-specified as an executor**: it needs the COUNT/VALUE/CONFIG eligibility split, a pre-read→mutate→post-read→change_event evidence chain with a defined `EXECUTED_PENDING_CHANGE_HISTORY` state (change_event propagation ≤ ~3 minutes, 30-day lookback), a pause-not-remove rule (REMOVED is unrecoverable), and an explicit list of additional authorities it can safely receive (§6).

---

# 2. Current Google Change Ledger

| area | old/stale belief | current verified truth | effective date | affected agents | required change | official source |
|---|---|---|---|---|---|---|
| Ads API | "current version ~v20/v21" | Latest is **v25**; official client 31.2.0 (2026-07-22) supports only v21–v25 | between 2026-06-24 and 2026-07-22 | G0,G1,G5,G9 | Retarget all GAQL/tooling to v25; treat ≤v20 integrations as sunset | pypi.org/pypi/google-ads/json (artifact-verified) |
| Auction Insights | "not available via API at all" | Six `auction_insight_search_*` metrics exist in v25, but are **allowlist-gated** (not publicly served) | in v25 schema; allowlist status as of 2026-07-31 | G6 | Keep scheduled UI exports as intake; request allowlist; do not build API-dependent pipeline yet | pypi.org/pypi/google-ads/json + groups.google.com/g/adwords-api/c/30s21wGZkOU (SECONDARY for allowlist) |
| MCP | "no official Google Ads MCP" | Official **googleads/google-ads-mcp** exists — Experimental, read-only (search, list_accessible_customers, +get_resource_metadata at HEAD) | repo 2025-10-03; PyPI 0.0.1 2025-10-22 | G1,G9 | Reads may use official MCP; **all writes via Ads API**; never install look-alike community packages | github.com/googleads/google-ads-mcp |
| GA4 MCP | — | Official **analytics-mcp** (googleanalytics org) read-only; PyPI `google-analytics-mcp` is a *community* package | 0.1.0 2025-08-22; 0.7.0 2026-07-29 | G7,G8 | Pin `analytics-mcp` only; treat name-collision package as untrusted | pypi.org/pypi/analytics-mcp/json |
| Content API | "long migration runway" | Deprecated; **sunset 18 Aug 2026**; Merchant API v1 GA; v1beta shut down 2026-02-28; Ads scripts switched to Merchant API 2026-04-22 | 2026-08-18 | G0,G3,G7,G9 | Audit every integration (Simprosys, custom scripts) for Merchant API readiness this week | developers.google.com/merchant/api (+ googleads/googleads-shopping-samples README, artifact-verified) [RE-FETCH BEFORE ACTING] |
| Merchant API IDs | "product name = channel~lang~label~offerId" | v1 name is **{contentLanguage}~{feedLabel}~{offerId}** (3 segments); 4-segment form was beta-only | current v1 | G3,G7 | Fix any lookup keyed to the 4-part name (it 404s); e.g. `en~ZA~{offerId}` | developers.google.com/merchant/api/guides/products/add-manage |
| Merchant Center | "MC Next is rolling out" | Classic MC retired **30 Sep 2024**; "Next" branding dropped; feeds→"data sources", feed rules→"attribute rules" | 2024-09-30 | G3,G0 | Update all playbook navigation/terminology | support.google.com/merchants/answer/15285007 |
| PMax negatives | "PMax takes ~100 negatives, no lists" | Campaign-level negatives GA with **10,000/campaign** (raised Mar–Apr 2025); negative keyword **lists** attachable to PMax (7 Aug 2025); account-level negatives (limit 1,000) apply to PMax + Shopping | 2025 | G5,G9,G0 | Rebuild negative architecture: shared junk list on all campaigns incl. PMax; scoped lists for brand routing | support.google.com/google-ads/answer/16127398 · answer/16451273 · answer/11396330 |
| Negative matching | "negatives never cover variants" | Since **26 Jun 2024** negatives block misspellings (all match types); still NOT synonyms/plurals; search terms aggregate under canonical spellings (~9% more visible data) | 2024-06-26 | G5,G0,G1 | Conflict simulation must include misspelling blast radius; one canonical-spelling negative covers its cluster | support.google.com/google-ads/answer/15070437 |
| PMax vs Shopping | "PMax always outranks Standard Shopping on same products" | **Highest Ad Rank wins** between PMax and Standard Shopping (announced Oct 2024); Search exact-match keyword still beats PMax; priority settings arbitrate only among Standard Shopping | Oct 2024 | G1,G6,G9 | Re-validate any priority-sculpting structure; a well-bid Standard Shopping campaign can now win Medicube SKU auctions | support.google.com/google-ads/answer/13810170 |
| AI Max | "AI Max is a small beta" | **GA globally 15 Apr 2026** (opt-in suite: keywordless matching + text customization + Final URL expansion, individually toggleable; brand inclusion/exclusion controls); AI Max for Shopping in beta (AI can rewrite served titles) | 2026-04-15 | G0,G1,G3,G5,G9 | Treat enabling as a three-lever change needing G9 sign-off with brand controls preset | business.google.com/us/accelerate/announcements/ai-max-for-search-campaigns/ · support.google.com/google-ads/answer/15910187 · answer/17091277 |
| Auto-upgrades | "no forced AI Max migration" | **Sept 2026**: Search campaigns using ACA or campaign-level broad match auto-upgrade to AI Max; **DSA migration delayed to Feb 2027** (DSA creation restored 15 Jun 2026) | announced 2026-06-11 | G0,G1,G5,G9 | Inventory ACA/broad-match/DSA campaigns now; decide opt-in vs opt-out before Sept | ads-developers.googleblog.com/2026/06/dynamic-search-ads-dsa-automigration.html [RE-FETCH BEFORE ACTING] |
| Bidding | "budget-limited tCPA/tROAS campaigns overdeliver vs target" | From **17 Aug 2026** budget-limited target-based campaigns deliver ~at target; Bid Target Adjustment Tool live since 6 Jul 2026; strategy labels renamed from Jun 2026 (e.g. "Maximize conv. value with target ROAS" → "Target ROAS") | 2026-08-17 | G0,G1,G9 | Audit every Limited-by-budget campaign's target vs recent actuals **before 17 Aug** | support.google.com/google-ads/answer/17061251 [RE-FETCH BEFORE ACTING] |
| Campaign types | "Video Action/Discovery/Smart Shopping still exist" | VAC→Demand Gen complete (May 2026); Discovery→Demand Gen (Mar 2024); Smart Shopping/Local→PMax (2022); Display folding into Demand Gen (voluntary tool Jun 2026, forced date not stated) | see row | G1,G9 | Use current type vocabulary; build no new standalone Display | support.google.com/google-ads/answer/15110871 · answer/17051545 |
| Search partners | "SPN is an opaque blanket toggle" | Site-level SPN placement reporting exists (Search/Shopping/App); parked domains removed from SPN **10 Feb 2026** | 2026-02-10 | G1,G7 | Judge SPN on placement data, not blanket opt-out | support.google.com/google-ads/answer/16286960 |
| Conversion goals | "Primary/Secondary flags fully determine bidding" | Secondary action **inside a custom goal** is used for bidding by campaigns on that goal; campaigns on account-default goals bid to ALL default-goal primaries; one custom goal per campaign | current | G0,G9 | Audit = Primary flags + custom-goal membership + per-campaign goal mode | support.google.com/google-ads/answer/11461796 · answer/9143218 |
| GA4 terms | "GA4 conversions" | GA4 renamed conversions → **key events** (2024); "conversion" = Ads-side; GA4-created Ads conversions default **Secondary** by design | 2024 | G0,G7,G9 | Fleet vocabulary: key event (GA4) vs conversion (Ads); GA4 purchase import must stay Secondary | support.google.com/analytics/answer/13965727 · support.google.com/google-ads/answer/10632359 |
| Conversion adjustments | "refunds can be pushed anytime" | Retract/Restate allowed ≤**55 days** after conversion; only adjustments within **7 days** feed automated bidding | current | G0,G8,G9 | Refund hygiene must run on sub-7-day cadence | support.google.com/google-ads/answer/7686449 [RE-FETCH BEFORE ACTING] |
| Shopify checkout | "additional scripts keep working" | Non-Plus: additional scripts **view-only since 28 Aug 2025**; Thank-you/Order-status legacy scripts must be on Checkout Extensibility by **26 Aug 2026**; auto-upgrades began Jan 2026 | 2026-08-26 | G0,G3,G7,G9 | Confirm all purchase tracking is Web Pixels-based before deadline | help.shopify.com/…/upgrade-thank-you-order-status/upgrade-guide + shopify.dev changelog (artifact-verified) |
| GSC | "no AI reporting in GSC" | AI Overviews + AI Mode data blended into Performance totals (AI Mode ~16 Jun 2025, date SECONDARY); dedicated **Generative AI performance report 3 Jun 2026** (impressions/pages/countries/devices only; rollout-gated; no API); owner-level **Search generative AI control** (Include/Exclude) exists | 2025–2026 | G2,G7,G10,G0 | G0 verifies control = Include; G10 consumes new report where present; never compute "AI click share" from the standard report | developers.google.com/search/blog/2026/06/gen-ai-performance-reports · support.google.com/webmasters/answer/16908024 |
| GSC data | "daily data only" | Hourly dimension in Search Analytics API since Apr 2025 (~10 days back); 25k rows/request; 16-month retention; anonymized queries excluded | 2025-04 | G2,G7 | Use hourly view for deploy-incident detection; start BigQuery bulk export for history | developers.google.com/search/blog/2025/04/san-hourly-data |
| GBP | "GBP chat is a channel" | GBP chat/messaging + call history **retired 31 Jul 2024**; profiles managed in Search/Maps; GBP APIs quota-0 until access request approved; no reviews methods in v1 API family | 2024-07-31 | G4,G0 | Remove chat from all workflows; file GBP API access request before building automation | support.google.com/business/answer/14919056 |
| AI surfaces | "AI Mode not in SA / ads in AIO everywhere" | **AI Mode live in Africa incl. ZA since 21 Aug 2025** (now 200+ countries); AI Overviews 100+ countries Oct 2024 → 200+ May 2025; **ads in AIO: 12 countries, ZA NOT included**; ads in AI Mode: US test | see row | G10,G1,G6 | G10 measures AI Mode/AIO presence for ZA; G1 expects no AIO ad serving in ZA | blog.google/intl/en-africa/products/explore-get-answers/google-search-introducing-ai-mode-in-africa/ · support.google.com/google-ads/answer/16297775 |
| GEO | "llms.txt might help Google visibility" | Google's AI-optimization guide: machine-readable AI files (llms.txt etc.) are **not used** by Google Search incl. generative features; Google-Extended controls Gemini training/grounding only, does NOT affect Search/AIO inclusion | guide published 2026-05 | G10,G2 | Zero effort on llms.txt for Google; never block Google-Extended expecting AIO removal (and vice versa) | developers.google.com/search/docs/fundamentals/ai-optimization-guide |
| MC promotions | "promotions available everywhere" | Promotions add-on limited to AU,BR,CA,FR,DE,IN,IT,JP,KR,NL,ES,UK,US — **ZA not eligible** | current | G1,G3,G9 | No promotion data sources for ZA; discounts run through price attribute + on-site pricing (no free-delivery ads per fleet rule) | support.google.com/merchants/answer/13422697 [RE-FETCH BEFORE ACTING] |
| Enhanced conversions | "one implementation method only" | Since **Apr 2026** Ads accepts user-provided data from tags + Data Manager + API simultaneously; EC diagnostics (coverage/match rate/uplift) ~48h after implementation | 2026-04 | G0,G7 | Keep Analyzify gtag path primary; monitor diagnostics weekly | support.google.com/google-ads/answer/15712870 · answer/11956168 |

---

# 3. Critical Safety Rules

## 3a. Rules that prevent revenue loss
1. **Deadline calendar is a standing G0 input**: 17 Aug 2026 (bid-target behaviour), 18 Aug 2026 (Content API sunset), 26 Aug 2026 (Shopify checkout scripts), Sept 2026 (AI Max auto-upgrade cohort), Feb 2027 (DSA migration). Each has a named owner and a pre-deadline repair task (§10).
2. **Before 17 Aug 2026**: every campaign flagged "Limited by budget" on tCPA/tROAS must have its target reviewed against 30-day actuals (Bid Target Adjustment Tool or API). A loose target becomes real spend behaviour on that date [support.google.com/google-ads/answer/17061251].
3. **Pause, never remove**: REMOVED campaigns/ad groups/keywords cannot be restored — recreation resets history and learning [support.google.com/google-ads/answer/2404259]. G9 hard-blocks REMOVE mutations.
4. **No CPA/ROAS verdict on unsettled days**: Ads reports conversions at click date; recent days under-report until lag completes [support.google.com/google-ads/answer/9520128]. G1/G8/G9 judge only windows older than the campaign's observed conversion-lag envelope.
5. **Bid strategy Learning windows**: target/goal changes trigger relearning (~7 days typical); Google's own guidance caps target moves at ~15–20% per step, one step per conversion cycle [answer/13020501 · answer/10276704]. G9 enforces both caps.
6. **tROAS data floors**: 15 conversions/30 days (Search/Shopping) before pushing a campaign to tROAS; pool low-volume campaigns in portfolio strategies instead [answer/6268637 · answer/6263072].
7. **PMax/Shopping arbitration is Ad Rank**: never assume PMax priority when diagnosing cannibalization [answer/13810170].
8. **Stocked-brand guard (generalized Medicube rule)**: no account-level negative, and no brand-exclusion list entry, may match any vendor in the live Shopify stocked-vendor list (LIVE ACCOUNT FACT: MEDICUBE active with 10+ products). Account-level negatives hit Search+Shopping+PMax fleet-wide [answer/11396330], and brand exclusions also kill misspellings [answer/14505308].
9. **Advertised-OOS loop**: Shopify=0 & feed=in_stock is a sync defect (escalate T + optional Ads-side exclusion); Shopify=0 & feed=out_of_stock needs no Ads action (ads stop serving). LIVE ACCOUNT FACT: five ACTIVE Medicube SKUs at zero inventory today.

## 3b. Rules that prevent tracking corruption
1. **Exactly one purchase pipeline**: Analyzify v4 owns GA4+Ads purchase tracking. The Shopify Google & YouTube channel must never hold an active GA4 connection to the same property, and no leftover gtag/theme snippet may fire purchase — duplicate tracking is Shopify's documented top pixel-migration failure [help.shopify.com/…/pixel-migration].
2. **GA4-imported purchase stays Secondary** — it is set Secondary by design to prevent double-counting into bidding [support.google.com/google-ads/answer/10632359]. Flipping it Primary while the Ads-native purchase is Primary double-feeds Smart Bidding.
3. **Custom-goal membership audit**: a Secondary action inside the campaign's custom goal feeds bidding [answer/11461796]. The Purchase-only custom goal must contain exactly the one Purchase action.
4. **transaction_id discipline**: Shopify order confirmation number as transaction_id; never empty/static (GA4 would dedupe all purchases to one) [support.google.com/analytics/answer/12313109]; Ads dedupes only within one conversion action [answer/6386790].
5. **Value-field mapping is a 15%+ ROAS lever**: Shopify `totalPrice` includes VAT+duties; `subtotalPrice` excludes shipping/taxes [shopify.dev web-pixels checkout_completed]. The Analyzify mapping must be audited and pinned in Business Facts; any change is a VALUE event.
6. **Currency**: ZAR end-to-end; any non-ZAR currency code silently rescales GA4/Ads values by FX [support.google.com/analytics/answer/9796179 · google-ads/answer/3419241].
7. **Conversion outage protocol**: tracking status Unverified/Tag inactive/Needs attention = freeze COUNT/VALUE decisions [answer/12674892]; after repair (T-only), G9 files a Data Exclusion for the broken window — it protects future bidding but does not fix history [answer/10370710].
8. **Checkout Extensibility deadline** (26 Aug 2026): any purchase tag still living in legacy Thank-you/Order-status scripts dies silently — confirm Web Pixels-based firing before Google-side debugging is ever attempted.
9. **Expected-difference literacy**: GA4 fractional key events (DDA), GA4-vs-Ads timing (conversion date vs click date), search-terms privacy residuals, and GSC 2–3-day lag are *design*, not corruption [analytics/answer/12958241 · google-ads/answer/9520128 · answer/11127882 · webmasters/answer/7576553]. G7 must never class them as defects.

## 3c. Rules that prevent policy/account damage
1. **Misrepresentation kills the Merchant Center account without warning**: identity/contact consistency, live shipping/refund/privacy policies, and honoured prices are mandatory [support.google.com/merchants/answer/6150127]. The no-free-delivery-advertising rule also protects here: never advertise delivery/discount terms checkout doesn't honour.
2. **Price/availability mismatch = item disapproval, not suspension** — fix by consistency + recrawl; keep automatic item updates ON [answer/13693497 · answer/12157888].
3. **GTIN integrity**: real manufacturer GTINs only; wrong/borrowed GTINs disapprove items; missing ones limit performance [answer/9545238].
4. **No promotional overlays on product images** ("Text on image" disapproval); automatic image improvements (OFF by default) may be enabled as remedy [answer/12158684 · answer/12724659].
5. **GBP**: address/name/category edits can trigger re-verification (video verification is human-only, live in-flow recording); review gating and incentivized reviews are prohibited; suspension appeals need evidence assembled before opening the 60-minute form [business/answer/3039617 · answer/14271705 · contributionpolicy/answer/7400114 · business/answer/4569145]. All GBP writes remain T-only.
6. **Browser automation of the Ads UI**: Google's ToS position on scripted-browser access is NOT VERIFIED this session (§11) — until verified, no Chrome-profile automation against Ads/Merchant UIs; use API/scripts surfaces only.
7. **GSC "Search generative AI control" is destructive**: Exclude removes the site from AI surfaces + grounding [webmasters/answer/16908024]. Owner-level; T-only; G0 verifies it reads Include.

## 3d. Rules that currently block useful execution unnecessarily
1. **"Measurement corruption blocks G9" is too coarse.** Replace with: COUNT_CORRUPT blocks count-based actions; VALUE_CORRUPT blocks value-based actions; **CONFIGURATION repairs are always eligible** (goal re-pin, auto-apply opt-out, brand-protection re-enable, negative-conflict fixes, network-setting fixes) — none of them read corrupted metrics.
2. **"Never touch negatives when tracking is broken"** (implicit) — wrong: policy/irrelevance-based negatives (competitor-owned brands with zero relevance, clearly off-category terms) are CONFIGURATION-evidence actions and stay eligible; only *performance-based* negatives need COUNT_OK.
3. **"Removing a broad negative = introducing broad targeting"** — wrong by definition: negatives are exclusion-only; match type defines blocking scope only; removal restores previously blocked queries and cannot change positive-keyword matching [support.google.com/google-ads/answer/2453972 · answer/7302703]. Removing a verified-wrong account-level stocked-brand negative is a **repair**, and G9 may execute it.
4. **"Auction Insights has no API"** — partially stale: metrics exist in v25 (allowlist-gated). G6 should file for allowlist while keeping UI-export intake; do not let the old absolute block an upgrade request.
5. **"All conversions is always wrong"** — All conversions remains banned for judging performance, but it is the *correct* column for auditing what Secondary/Google-hosted actions (e.g. GBP local actions) are recording [google-ads/answer/9013908 · answer/3419678]. The ban applies to decisions, not diagnostics.

---

# 4. G0–G10 Agent Scorecards

Field key: 1 Purpose · 2 Exact questions · 3 Required live sources · 4 Optional sources · 5 Hard gates · 6 May inherit · 7 Must independently reverify · 8 Required outputs · 9 Allowed external writes · 10 Forbidden writes · 11 Decisions it can make · 12 Decisions it must escalate · 13 Failure modes · 14 False-positive risks · 15 Runtime priority order · 16 Runtime cap · 17 OK/DEGRADED/BLOCKED · 18 Downstream consumption · 19 Duplicate work to remove · 20 Canary test.

## G0 — Delivery, conversion-configuration and account-health sentinel
1. Prove the account can be trusted before anyone acts: serving, policy, billing, conversion configuration, silent-change detection, deadline calendar.
2. Is the correct customer ID loaded? Any billing/policy/suspension issue? Campaigns serving vs 7-day baseline? Exactly one Primary action and it is Purchase? Every campaign on its campaign-specific Purchase-only custom goal (goal mode + membership, not just flags)? Any new/changed conversion actions or auto-created Google-hosted actions (GBP local actions)? Conversion tracking status column state? EC diagnostics coverage/match-rate trend? Auto-apply subscriptions = none and ad-suggestions preference = manual? Any change_event rows from unexpected sources (RECOMMENDATIONS/RULES/SCRIPTS/WEB_CLIENT)? Any campaign in scope for the Sept 2026 AI Max auto-upgrade (ACA on, or campaign-level broad match)? Any "Limited by budget" tCPA/tROAS campaign with unreviewed target (17 Aug 2026 exposure)? GSC Search-generative-AI control = Include?
3. Google Ads API v25: `customer`, `campaign`, `campaign_budget`, `conversion_action`, `conversion_goal_campaign_config`/custom goal resources, `change_event` (24h window), 48h metrics; Ads UI for diagnostics panels without API parity.
4. G3 feed_state; G7 measurement_state (context only); GSC settings read (shared with G2).
5. Read-only — never mutates. Emits flags; repairs belong to G9/T. change_event must be queried with ≤30-day window + LIMIT ≤10,000 [developers.google.com/google-ads/api/docs/change-event].
6. Nothing — G0 runs first.
7. Everything it reports: conversion config, goal membership, serving status, auto-apply state (never inherited).
8. `fleet_health.json`: {identity, serving, config{primary_actions[], per-campaign goal mode+membership}, tracking_status, ec_diagnostics, autoapply_state, change_summary[by client type], deadline_flags[], drift_flags[], freshness_ts}.
9. None.
10. All mutations, all platforms.
11. Declare CONFIG_OK / CONFIG_DRIFT / SERVING_OUTAGE / ACCOUNT_AT_RISK; order the drift_flags by revenue exposure.
12. Billing, suspension, policy strikes, suspected compromise → T immediately (same alert also to G9 as context, no action).
13. Misses drift because change_event lookback (30d) exceeded between runs; reads Change History absence as proof of no change (docs: some changes not tracked [support.google.com/google-ads/answer/2454137]); misattributes ~3-minute change_event propagation lag as missing data.
14. Overnight SAST zero-traffic hours read as SERVING_OUTAGE; conversion lag read as tag death (must cross-check tracking-status column, not counts); label renames (Jun 2026 bid-strategy names) read as strategy changes.
15. Identity → billing/policy → serving → conversion config (flags+goals+membership) → auto-apply/ad-suggestions → change_event diff → deadline calendar.
16. 10 min.
17. OK: all reads succeed, no drift. DEGRADED: partial reads/quota or stale change window (report what's missing). BLOCKED: auth failure or customer-ID mismatch — no downstream agent may act.
18. Everyone consumes fleet_health; G9 refuses to execute if fleet_health older than 24h or BLOCKED.
19. G7 must stop re-auditing conversion-action *config* (G7 owns data integrity only); G1 must stop re-checking serving.
20. Canary: query conversion_action + custom-goal config; assert count(primary)==1 ∧ primary==Purchase-action-ID (from Business Facts) ∧ every enabled campaign returns goal_mode=campaign-specific with membership=={Purchase}; assert change_event query with 25h window returns without error.

## G1 — Daily Search/Shopping/PMax performance
1. Daily performance readout and bleeder/pacing detection on the Conversions column under verified goals.
2. Spend by campaign vs plan (plan from Business Facts)? CPA/ROAS on settled windows? Zero-conversion spend streaks (spend threshold from Business Facts)? Budget-limited campaigns and their targets? Bid strategies in Learning? PMax channel split + SPN placements anomalies? Impression share collapses (search_impression_share, budget_lost_IS, rank_lost_IS)?
3. Ads API v25 metrics segmented by date/campaign/channel; bidding strategy status; fleet_health (fresh); measurement_state (fresh).
4. G3 advertised_oos list (explains Shopping impression drops); G6 auction_state (context).
5. No verdicts on days inside the conversion-lag envelope [answer/9520128]; no verdicts on campaigns in Learning [answer/13020501]; if COUNT_CORRUPT → spend/serving anomalies only, efficiency metrics marked UNTRUSTED; never uses All conversions for judgment; bleeder candidacy requires full evidence row (scope, window, spend, conversions, basis).
6. measurement_state (G7), config status (G0).
7. Raw spend/impression/conversion numbers (never inherits aggregates from G8).
8. `performance_daily.json`: {per-campaign rows, bleeder_candidates[], pacing_flags[], learning_status[], budget_limited[{campaign, target, 30d_actual}], is_flags[]}.
9. None.
10. Any mutation — G1 proposes, G9 disposes.
11. Bleeder candidacy; pacing anomaly declaration; SPN placement-level concern flags.
12. Whole-account collapse (→T+G0); anything requiring new structure (→T); target changes (→G9).
13. Judging across a goal-change boundary; treating PMax channel mix shifts as failures; missing that an "underperforming" Shopping campaign is actually OOS-driven (needs G3 input).
14. Payday/seasonality dips; conversion lag; Learning-period noise; the 17 Aug 2026 behaviour change making budget-limited campaigns look suddenly "worse" at unchanged targets.
15. Spend anomalies → zero-conversion streaks → budget-limited target review → pacing → efficiency trends → IS decomposition.
16. 15 min.
17. OK: full metrics + fresh G0/G7. DEGRADED: G7 missing/corrupt → spend-only mode. BLOCKED: G0 BLOCKED or metrics unavailable.
18. G8 (full dataset), G9 (bleeders + budget-limited list).
19. G8 must not re-pull Ads metrics — consumes G1's dataset.
20. Canary: pull yesterday+prior-7 for all enabled campaigns; assert row count == enabled count and totals reconcile within 0.5% against an independent aggregate GAQL query.

## G2 — SEO and Search Console
1. Organic + merchant-listing visibility and indexing health for money pages.
2. Are PDPs/collections indexed (sampled via urlInspection within quota)? Query/CTR/position deltas (28d vs prior, settled)? Merchant-listings + product-snippets errors? Manual actions/security issues? CWV status (LCP/INP/CLS)? Sitemap state? Canonical conflicts (apps injecting second canonical)? Structured-data duplication on PDPs?
3. GSC API: searchanalytics.query (25k rows/page [developers.google.com/webmaster-tools/v1/searchanalytics/query]), sitemaps, urlInspection; GSC UI for rich-result detail; live PDP HTML sampling.
4. Semrush (SECONDARY); G3 feed_state; BigQuery bulk export (once enabled).
5. No site writes (website is T's). Quota budgeting for urlInspection. Data older than 16 months is gone — never promise it [support.google.com/analytics/answer/10737381]. Last 2–3 GSC days treated provisional.
6. fleet_health.
7. Manual-action/security state (never inherit).
8. `seo_state.json`: {coverage_summary, query_deltas, rich_result_errors[], manual_actions, cwv_summary, canonical_conflicts[], gsc_pulls{raw files for G10}}.
9. None.
10. Site/theme/robots/sitemap changes; GSC settings (incl. generative-AI control — T only).
11. Indexing-health verdicts; content/schema priorities (as recommendations to T).
12. Manual action or security issue → T same day; canonical/schema defects needing theme edits → T.
13. Mass-alarming on "Crawled - currently not indexed" for variant/filtered URLs (documented benign states [webmasters/answer/7440203]); reading anonymized-query gaps as traffic loss.
14. GSC 2–3-day lag; Sunday dips; AI-surface blending (clicks include AI Mode/AIO — cannot attribute deltas to blue links alone).
15. Manual actions/security → merchant listings errors → index coverage of money pages → performance deltas → CWV → hygiene.
16. 15 min.
17. OK: API reads + no manual actions. DEGRADED: quota exhausted / partial. BLOCKED: property access failure.
18. G10 consumes G2's GSC pulls (never re-pulls); G8 consumes visibility deltas.
19. Remove G10's own GSC querying; remove any Semrush organic pull duplicated with G6's competitive pull.
20. Canary: searchanalytics.query last-28d returns >0 rows; urlInspection(homepage) returns indexed; merchant-listings report reachable (UI check logged).

## G3 — Merchant Center, feeds, Shopify product data
1. Feed integrity and stock/price parity: what may be advertised and what must not.
2. Disapproved/limited items + reasons (productstatuses)? Price/availability mismatches? Automatic item updates ON? Every advertised offerId maps to a live Shopify variant (ID map complete)? Advertised items OOS/inactive in Shopify (LIVE: 5 zero-inventory ACTIVE Medicube SKUs today)? GTIN coverage/validity? Image-policy risks (text-on-image)? Exactly ONE primary submitter (Simprosys) — G&Y channel not publishing? Stocked-vendor list current? Content API dependencies gone before 18 Aug 2026?
3. Merchant API v1: products/productstatuses, datasources, reports (productView incl. clickPotentialRank), issueresolution [developers.google.com/merchant/api/guides/products/list-products-data-issues]; Shopify Admin API: products, variants, inventory (LIVE ACCESS confirmed this session).
4. Simprosys UI state (browser, SECONDARY); GSC merchant-listings (from G2, not re-pulled).
5. **No Merchant Center writes, no Shopify writes** (both T-reserved). OOS decision tree: Shopify=0 ∧ feed=out_of_stock → no action (correct state); Shopify=0 ∧ feed=in_stock → SYNC_DEFECT → T (+ optional G9 Ads-side exclusion proposal); active-in-Shopify ∧ disapproved-in-MC → diagnose → T. Offer IDs are immutable — never propose remapping [support.google.com/merchants/answer/6324405].
6. fleet_health.
7. The ID map and stock states (never inherit — this is its core truth).
8. `feed_state.json`: {stocked_vendor_list[] (from live Shopify vendors), advertised_oos[], disapprovals[{id, reason}], mismatches[], id_map_stats, submitter_check, gtin_coverage, sync_defects[]}.
9. None.
10. productInputs insert/patch/delete, datasource changes, MC settings, Shopify mutations.
11. Feed-health verdicts; advertise/don't-advertise eligibility labels per offer.
12. Any MC write (T); submitter conflicts (T); suspension threat (T + G0).
13. Variant-vs-product inventory confusion; feed-lag misread as defect; missing that the G&Y channel quietly re-enabled publishing (duplicate-offer errors [merchants/answer/16529073]).
14. Transient recrawl mismatches during price changes; MC processing delay after Shopify updates.
15. Account-level threats → disapprovals on advertised items → sync defects (OOS-advertised) → ID-map integrity → GTIN/image hygiene → Content-API dependency audit.
16. 15 min.
17. OK: API reads + no sync defects on advertised items. DEGRADED: partial API (quota) or Simprosys UI unread. BLOCKED: Merchant API auth failure.
18. G5 (stocked_vendor_list — the Medicube guard's data source), G1 (advertised_oos context), G9 (exclusion proposals), G7 (item-ID join samples).
19. G7 must not re-pull Shopify products/inventory (G7 gets orders only); G3 does not pull GSC (G2's).
20. Canary: fetch offerId for SKU MDC001 via Merchant API and its Shopify variant (gid 46900714635523); assert price parity (R570) and availability parity; assert vendor list contains MEDICUBE.

## G4 — Google Business Profile and local visibility
1. Local presence health and review pipeline; drafts, never posts.
2. Profile verified/live/suspended? NAP matches site? New reviews needing response (drafted)? Insights trends (Performance API)? Location assets linked and approved in Ads? Any pending verification (freeze name/address/category edits [business/answer/3039617])? Auto-created local-actions conversions still Secondary/out of 'Conversions'?
3. Business Profile APIs (v1 family + businessprofileperformance.v1 — quota-0 until access request approved [google-api-python-client discovery]); GBP UI in Search/Maps (browser) as fallback; Ads API location-asset state.
4. Review widgets/UI export; G0 fleet_health (for the local-actions conversion check).
5. **All GBP writes are T-only** (non-Ads platform). Never draft anything violating review policies (no gating/incentives [contributionpolicy/answer/7400114]). Reviews have no modern-API path — expect UI workflow.
6. fleet_health.
7. Verification state; review list (never inherit).
8. `gbp_state.json`: {verification, suspension_risk, reviews_pending[{id, rating, draft_reply}], perf_summary, ads_location_asset_status, local_actions_audit}.
9. None.
10. Any GBP edit (posts, hours, photos, attributes, address, category, name), review replies (drafts only), verification actions.
11. Draft prioritization; local-visibility trend verdicts.
12. Everything write-shaped → T; suspension → T with pre-assembled evidence (60-minute appeal-form window [business/answer/4569145]).
13. Performance API multi-day lag read as visibility crash; building automation before API access request approved (calls fail at quota 0).
14. Metric windows moving with Maps UI changes; seasonal foot-traffic patterns.
15. Suspension/verification state → reviews → location-asset status in Ads → performance trends.
16. 10 min.
17. OK: state read + no pending verification. DEGRADED: API not approved (UI-only mode). BLOCKED: profile access lost.
18. G8 (local trends); G0 (local-actions conversion audit input); T (drafts).
19. None currently duplicated — keep it that way (G4 does not pull Ads metrics).
20. Canary: read verification state + last-30d Performance metrics (or UI screenshot if API unapproved); assert non-empty and profile name matches Business Facts.

## G5 — Search terms, keywords and negatives
1. Query-level waste control and coverage without harming stocked brands.
2. Top waste terms on settled windows (COUNT_OK basis; else configuration-evidence only)? Which negatives are missing, at which level, which match type? Does any proposal conflict with converting queries, positive keywords (the official conflict recommendation [answer/3416396]), or the stocked-vendor list — including the misspelling blast radius [answer/15070437]? Any existing negative that is itself wrong (e.g. account-level stocked-brand negative = repair-removal candidate)? PMax search-terms rows + insights mined? Visible-term share reported (privacy threshold residual [answer/11127882])?
3. Ads API v25: search_term_view, campaign_search_term_view (PMax), search-term insights, keyword_view, all negative criteria levels, shared sets + attachments, account-level negatives; G3 stocked_vendor_list; G7 measurement_state.
4. Keyword Planner (KeywordPlanIdeaService — access-level requirement NOT VERIFIED, §11); G6 auction_state for competitor-term context.
5. Every proposal ships {term, match_type, level, campaigns_affected, sample_blocked_queries incl. misspellings, stocked_brand_check=PASS, conflict_check=PASS, evidence_basis}. Account-level proposals additionally require proof of non-match against every stocked vendor. Performance-based negatives require COUNT_OK; policy/irrelevance negatives are CONFIGURATION-evidence and always eligible. Never propose brand-exclusion entries for stocked brands.
6. measurement_state (G7); stocked_vendor_list (G3); config status (G0).
7. Current negative inventory at all levels (pre-read its own truth before proposing).
8. `negative_proposals.json` + `keyword_change_proposals.json` (pause/add within existing ad groups only) + `negative_repairs.json` (wrong existing negatives).
9. None.
10. All mutations (G9 executes); any proposal creating new campaign structure.
11. Proposal ranking; waste quantification.
12. Match-type strategy shifts, brand-inclusion architecture (broad-conversion side effect [answer/14453047]) → G9/T.
13. Proposing on hidden-term extrapolation; missing that account-level negatives now hit PMax; forgetting Shopping has no positive keywords (negatives+titles are the only levers [answer/6275313]).
14. Low-volume terms judged early; canonical-spelling aggregation misread as new query behaviour.
15. Repair candidates (wrong existing negatives) → stocked-brand guard validation → high-spend waste terms → coverage gaps → keyword hygiene.
16. 15 min.
17. OK: full pulls + guard data fresh. DEGRADED: PMax terms unavailable (Search-only mode) or COUNT_CORRUPT (configuration-evidence mode). BLOCKED: G3 vendor list missing/stale >72h — no proposals may ship.
18. G9 (executes verified proposals), G8 (waste totals).
19. G6 should not independently mine search terms for competitor names — G5 provides term-level data; G6 provides auction-level data.
20. Canary: feed a synthetic proposal "medicube" (account level, broad) through the guard → must FAIL with stocked-brand violation; feed "competitorbrandX" campaign-level → must PASS; precedence simulation returns the correct blocking level order (account → shared list → campaign → ad group).

## G6 — Auction insights, competitors and controlled SERPs
1. Competitive-pressure evidence with correct causality limits; produces the SERP evidence bundle G10 consumes.
2. IS/overlap/position-above/outranking deltas vs a comparable prior window (Search: 6 metrics; Shopping: IS/overlap/outranking only [support.google.com/google-ads/answer/2579754])? Who entered/left the auction? Is an IS loss budget-driven or rank-driven (API: search_impression_share, search_budget_lost_impression_share, search_rank_lost_impression_share)? Transparency Center creative changes for named competitors (verified-advertiser hub; region+date filterable; no spend/targeting data [blog.google Ads Transparency Center launch])? Controlled SERP samples for priority ZA queries via Ad Preview & Diagnosis (no impression accrual [answer/148778])? MC price-competitiveness/price-insights position for identical offers (report availability for ZA NOT VERIFIED, §11)?
3. Scheduled Auction Insights UI exports (browser-produced, file intake); Ads API IS metrics; Ads Transparency Center (browser); Ad Preview & Diagnosis (browser).
4. Semrush paid-search data (SECONDARY); G5 term-level data.
5. Comparable windows only (same length, same campaign scope; Auction Insights rows appear only above activity thresholds). Every claim labelled OBSERVATION vs INFERENCE. No bid/budget recommendation without budget-vs-rank IS decomposition. Auction Insights API metrics are allowlist-gated — do NOT build API intake until allowlist confirmed (§11). SERP checks only via Ad Preview (never raw searching — CTR damage [answer/148778]).
6. fleet_health; performance_daily (for spend context).
7. Export period/scope metadata (validate every ingested file before use).
8. `auction_state.json`: {per-competitor deltas, entries/exits, is_decomposition, transparency_notes[]} + `serp_bundle/`: {query, ts, location, device, raw capture, ai_surface_presence, citing_urls} — the single source G10 reads.
9. None.
10. All mutations; any change to scheduled exports (T configures).
11. Competitive-pressure verdicts (OBSERVATION-grade); "eligible evidence" certification for G9 (e.g. "IS loss is budget-driven" unlocks a budget proposal).
12. Any bid/budget action (→G9 via G8); allowlist application (→T).
13. Comparing windows across a query-mix shift; treating outranking-share moves as competitor "bid changes" (Auction Insights cannot prove bids/budgets — only auction outcomes).
14. Seasonal query-mix shifts; new-entrant noise below thresholds; personalization contaminating SERP samples (must use Ad Preview, location-pinned).
15. Ingest+validate exports → IS decomposition → competitor deltas → Transparency sweep → SERP bundle for G10 → price-position (when available).
16. 20 min.
17. OK: fresh export ingested + API IS metrics. DEGRADED: export stale >7d (API-IS-only mode, no per-competitor claims). BLOCKED: no export and no API metrics.
18. G8 (competitive context), G10 (serp_bundle — mandatory dependency), G9 (evidence certifications only via G8).
19. G10's own SERP querying (remove); any Semrush duplication with G2.
20. Canary: ingest latest Auction Insights export; assert period == expected ∧ ≥1 competitor row ∧ IS values in [0,1]; produce one decomposition row for the top campaign from API metrics and confirm budget_lost+rank_lost+IS ≤ 100% sanity.

## G7 — Measurement integrity and transaction reconciliation
1. Decide whether COUNT and VALUE can be trusted; reconcile Shopify ↔ GA4 ↔ Ads on settled windows.
2. Settled-window relationship Shopify orders vs GA4 purchases vs Ads Conversions within expected envelopes (never equality — attribution scope differs)? Duplicate transaction_ids in GA4? Zero-count days contradicted by Shopify orders? Value drift beyond tolerance (VAT/shipping mapping, currency code)? Double-purchase events (Analyzify + G&Y channel simultaneously — Shopify's documented duplicate risk)? EC diagnostics trend? GA4-import delay (≤24h) respected in comparisons? Refund events flowing (or absence documented)?
3. Shopify Admin API orders (count+sum by day — LIVE ACCESS confirmed); GA4 Data API runReport (purchase count/value by day; 250k row cap); Ads API conversion-action-level stats; GA4 DebugView/Realtime for event-level spot checks; official analytics-mcp acceptable (read-only).
4. Analyzify vendor docs (SECONDARY); Tag Assistant sessions (T-assisted).
5. Read-only (tracking is T's). Settled windows only (exclude the conversion-lag envelope). Expected differences are NOT corruption: GA4 fractional credit (DDA), click-date vs conversion-date timing, privacy residuals, Shop Pay pixel undercount (SECONDARY-documented community reports — baseline it, don't chase it). Corruption = tag-level defects only: zero-count days with orders present, duplicate transaction_ids, value inflation/deflation beyond tolerance, currency mismatch.
6. fleet_health (config state); feed_state (item-ID samples).
7. The reconciliation numbers themselves (never inherit).
8. `measurement_state.json`: {state ∈ CLEAN|COUNT_CORRUPT|VALUE_CORRUPT|ATTRIBUTION_DEGRADED, affected_ranges[], duplicate_txn_ids[], value_drift_pct, dual_pipeline_check, evidence_rows[]}.
9. None.
10. Any GA4/tag/Analyzify/Ads conversion change; conversion adjustments upload (T or G9-with-authority only).
11. The measurement-state classification (the fleet's central gate); tolerance thresholds (from Business Facts).
12. Every fix (tracking is T's); adjustment uploads; anything touching the checkout deadline migration.
13. Declaring corruption from model/lag differences (over-blocking G9 — the historical fleet failure); missing dual-pipeline duplication because both pipelines dedupe within themselves but not across.
14. Timezone boundaries (SAST store vs property vs Ads account); GA4 thresholding on low-volume days; refund windows distorting value comparisons.
15. Dual-pipeline check → zero-count-day scan → duplicate txn scan → value-drift scan → currency check → envelope reconciliation → state declaration.
16. 20 min.
17. OK(CLEAN): all scans pass. DEGRADED: one source unreadable (state=UNKNOWN, treated as blocking for COUNT/VALUE actions). BLOCKED: two+ sources unreadable.
18. G1 (mode selection), G8 (basis labelling), G9 (eligibility gate).
19. Stop re-auditing conversion-action config (G0's); stop pulling Shopify product/inventory data (G3's — orders only).
20. Canary: pick one settled-day Shopify order; find its transaction_id in GA4 (count==1) and confirm the Ads Purchase action recorded ≤1 conversion for it; assert value equality within mapping tolerance.

## G8 — Revenue analysis and recommendations
1. Convert fleet outputs into ranked, evidence-labelled recommendations with expected impact.
2. Where is margin-weighted revenue coming from (paid/organic/free-listings split — free listings ARE live for ZA)? Which proposals (G1 bleeders, G5 negatives, G3 exclusions, G6 competitive, target/budget moves) have the highest expected value at current Business-Facts ceilings? What must G9 do first? What is blocked by measurement_state and what remains eligible?
3. G1/G3/G5/G6/G7 outputs + Business Facts (budgets, ceilings, CPA/ROAS floors — volatile, must be current-dated).
4. GA4 Data API (via G7's pulls where possible), Klaviyo/retention context (non-Google, labelled).
5. Every recommendation carries basis ∈ {CONFIGURATION, COUNT, VALUE} + required measurement_state + rollback description. No recommendation may violate the reserved-to-T list. No volatile figure from memory — cite Business Facts version. New-customer/retention-goal modes must be known before interpreting revenue mix [answer/14792043].
6. All upstream outputs (this agent is a pure consumer).
7. Cross-source consistency (it must re-derive totals from G1/G7 rows, not trust summaries).
8. `recommendations.json`: ranked [{action, basis, required_state, expected_impact, risk, rollback, evidence_refs[]}].
9. None.
10. All mutations.
11. Ranking; impact estimation; declaring "no action beats baseline" (allowed for performance actions, never a reason for G9 to skip configuration repairs).
12. Structure/pricing/promo strategy → T.
13. Ranking on corrupted VALUE; double-counting Meta/Google attribution (cross-channel is out of Google scope — label MER-level claims).
14. Recency bias from unsettled windows (must inherit G7's settlement boundary).
15. Consistency re-derivation → eligibility filter (measurement_state) → ranking → rollback annotation.
16. 15 min.
17. OK: all five inputs fresh. DEGRADED: any input stale (rank only what's evidenced). BLOCKED: G1+G7 both missing.
18. G9 (the decision queue).
19. Remove its own Ads/GA4 metric pulls entirely (G1/G7 own them).
20. Canary: synthetic inputs with a planted known-best action → assert it ranks #1 with correct basis label and an executable rollback field.

## G9 — Executive decision-maker and controlled Google Ads executor
1. Reconcile G1–G8, challenge labels, and EXECUTE the single highest-priority eligible Google Ads change with a full evidence chain. G9 is an executor, not a reporter.
2. Is each upstream label internally consistent (recompute basis from attached evidence)? Does measurement_state block this action class — and is that blocking justified (COUNT/VALUE-dependence real)? Is the action in-authority (§6 matrix)? Exact resource IDs, pre-read values, mutate payload, post-read values, revert payload? Did the previous run's change appear in change_event (closing any pending-proof)?
3. All upstream outputs + fresh G0; Ads API v25 mutate services; change_event.
4. Official Ads MCP for reads (never writes — read-only by design); UI screenshots for panels without API parity.
5. Hard gates: (a) COUNT_CORRUPT blocks count-based actions; VALUE_CORRUPT blocks value-based; CONFIGURATION repairs always eligible. (b) Challenge duty: reject and log CHALLENGED for any upstream claim failing recomputation (e.g. bleeder on unsettled days). (c) Execute duty: returning NO_ELIGIBLE_CONTROLLED_CHANGE while a verified CONFIGURATION repair is queued is a failure state. (d) Evidence chain mandatory: pre-read → mutate → post-read → change_event; if change_event not yet visible (≤3-min documented propagation; longer observed) but deterministic post-read matches intent → state=EXECUTED_PENDING_CHANGE_HISTORY; next run MUST close it via change_event (30-day window) or raise ANOMALY. (e) One primary change per run per scope. (f) Caps: budget ±20%/day within Business-Facts ceiling; target ±15% per step, one step per conversion cycle; ≤10 negatives per campaign per run; no REMOVE where PAUSE exists. (g) No mutation without G0 fresh <24h. (h) Stocked-brand guard re-validated at execution time against G3's list, not the proposal's copy.
6. All upstream outputs as decision inputs.
7. Pre-read state of every entity it mutates (never trusts proposals' snapshots); measurement_state basis for the chosen action.
8. `execution_report.json`: {decision_log[incl. CHALLENGED entries], action{resource ids, pre, payload, post}, change_event_ref | pending_proof, revert_procedure, next_run_obligations}.
9. Google Ads API mutations within the §6 authority matrix ONLY.
10. Conversion actions, tracking/GA4/Analyzify, billing, policy appeals, campaign/ad-group creation, Merchant Center, Shopify, GBP, website, GSC settings, audience/consent settings, REMOVE operations, auto-apply enrollment (may only disable).
11. Which eligible action executes now; challenge verdicts; pending-proof state management; deferring an action with written cause.
12. Anything reserved; cap-exceeding changes; conflicting upstream evidence it cannot resolve; novel action types not in the matrix.
13. Acting on stale G0; treating expected differences as corruption (over-blocking itself); missing next-run closure of pending proofs; batching multiple changes (destroys attribution of effect).
14. Change History absence read as failed mutation (post-read is authoritative in the interim); label renames (Jun 2026) read as drift.
15. 1 revenue-protecting config repairs (goal drift, brand-protection re-enable, auto-apply/ad-suggestions off, network-setting leaks, wrong stocked-brand negatives) → 2 deadline-driven repairs (pre-17-Aug target audit execution) → 3 spend-bleed stops (COUNT-gated) → 4 waste negatives (configuration-evidence first) → 5 scaling moves (COUNT+VALUE clean only).
16. 20 min analysis + hard stop after one complete mutate-evidence cycle.
17. OK: executed with full chain (or explicitly zero eligible actions after challenge log proves the queue was empty). DEGRADED: executed with pending proof. BLOCKED: G0 stale/BLOCKED or API mutate access failing.
18. T (execution report), G0 (next-run verification of the change), G8 (outcome feedback).
19. G9 must not re-produce analysis G8 already ranked (challenge ≠ re-analyze everything).
20. Canary: designated always-paused canary ad group (create once via T): G9 runs label-edit pre-read→mutate→post-read→change_event cycle on it; assert all four artifacts produced and revert restores byte-identical state.

## G10 — AI Overviews, AI Mode and citation visibility
1. Measure and improve citation presence for money queries in Google AI surfaces using G6's bundle + G2's data.
2. For each priority ZA query in the serp_bundle: does AIO/AI Mode appear, is BoT/Pastry cited, who is cited instead? Generative AI performance report present on the property (rollout-gated) and what do impressions show? Search-generative-AI control still Include (via G0)? Which content/schema asks (routed to G2/T) does the evidence support? Is every tactic labelled EVIDENCE-BASED (official doc) vs SPECULATIVE?
3. G6 serp_bundle (mandatory — G10 never re-runs the same queries); G2 GSC pulls incl. Generative AI report where present; official guidance docs (ai-optimization guide; "succeeding in AI search" 21 May 2025).
4. Third-party citation trackers (SECONDARY, never decision-grade alone); Semrush (SECONDARY).
5. No AI click-share claims from the standard GSC report (blended by design); no llms.txt work for Google (officially not used); Google-Extended advice must state it does NOT affect Search/AIO; feed+schema+classic SEO are the evidence-based levers (Shopping answers draw on Shopping Graph/feed data). Query-level testing evidence expires 48h (SERPs move).
6. serp_bundle (G6); gsc pulls (G2); fleet_health (G0's control check).
7. Citation extraction from the bundle (its own read of the raw captures).
8. `ai_visibility.json`: {per-query: surface, cited?, citing_url, competitors_cited[], evidence_ts} + `content_asks.json` (routed to G2/T, each labelled EVIDENCE-BASED/SPECULATIVE).
9. None.
10. Site/content/schema changes; GSC settings; crawler-control changes (robots/Google-Extended — T only).
11. Citation-presence verdicts; ask prioritization.
12. Any crawler-control or site change → T; any spend implication (AIO ads not in ZA anyway) → G8/G9.
13. Re-querying SERPs itself (duplicates G6, contaminates evidence); treating third-party tracker deltas as ground truth.
14. Personalization/location contamination in ad-hoc checks; AI-surface volatility misread as won/lost citations.
15. Bundle consumption → citation extraction → GSC generative report read → ask generation → labelling.
16. 15 min.
17. OK: fresh bundle + GSC data. DEGRADED: bundle stale >48h (report presence-only, no deltas). BLOCKED: no bundle.
18. G2 (content asks), G8 (visibility context), T (strategy).
19. Its own SERP querying and its own GSC pulls (both removed — consume G6/G2).
20. Canary: for one priority query with known state in the latest bundle, assert extraction matches a human-read of the stored capture (citation present/absent and citing URL).

---

# 5. Cross-Agent Data Flow

`producer → exact structured output → consumer → decision enabled → expiry/freshness`

| flow | output | consumer | decision enabled | expiry |
|---|---|---|---|---|
| G0 → | `fleet_health.json` | ALL (gate for G9) | any execution at all; drift repairs queue | 24h hard (G9 refuses on stale) |
| G7 → | `measurement_state.json` | G1, G8, G9 | COUNT/VALUE action eligibility; G1 mode selection | 24h |
| G3 → | `feed_state.json` (incl. `stocked_vendor_list`, `advertised_oos`, `sync_defects`) | G5 (guard), G1 (context), G9 (exclusion proposals), G7 (ID-join samples) | negative guard; OOS handling; feed escalations | 24h; vendor list 72h hard for G5 |
| G1 → | `performance_daily.json` | G8, G9 | bleeder/pacing/budget-limited actions | 24h |
| G5 → | `negative_proposals.json`, `negative_repairs.json`, `keyword_change_proposals.json` | G9 (execution), G8 (waste totals) | negative add/remove; keyword pause | 72h (proposals expire — re-verify after) |
| G2 → | `seo_state.json` + raw GSC pulls | G10, G8, T | content/schema priorities; index escalations | 7d (pulls 48h for G10) |
| G6 → | `auction_state.json` + `serp_bundle/` | G8, G10, G9 (certifications via G8) | competitive-response proposals; citation measurement | auction 7d; serp_bundle 48h |
| G4 → | `gbp_state.json` (incl. drafts) | G8, T, G0 (local-actions audit) | T publishes drafts; local trend context | 7d |
| G8 → | `recommendations.json` | G9 | the execution queue | 24h |
| G9 → | `execution_report.json` (incl. pending proofs) | T, G0 (next-run verify), G8 (outcome) | change verification loop; rollback readiness | next run (pending proofs MUST close) |

**Duplicate pulls to remove:** G8's own Ads/GA4 metric pulls (owns none — consumes G1/G7); G10's SERP queries (G6 owns) and GSC pulls (G2 owns); G7's Shopify product/inventory pulls (G3 owns; G7 gets orders only) and conversion-*config* audit (G0 owns; G7 owns data); G1's serving checks (G0 owns); G6's search-term mining (G5 owns).

**Missing handoffs to add (all new):** G3→G5 `stocked_vendor_list` (turns the static Medicube rule into live data covering every stocked vendor); G3→G1/G9 `advertised_oos` (live today: 5 zero-inventory ACTIVE Medicube SKUs); G7→G1 settlement boundary (the exact date before which efficiency judgment is allowed); G6→G10 `serp_bundle` (formalized, with expiry); G9→G0 executed-change list (next-run verification); G0→ALL deadline_flags (the Aug/Sept 2026 calendar).

---

# 6. G9 Authority Matrix

Legend: basis = the evidence class the action depends on. Autonomous = G9 executes without T. All autonomous actions additionally require: G0 fresh <24h, pre-read/post-read/change_event evidence chain, and revert procedure written before mutate.

| action | evidence basis | autonomous/T-only | required gates | maximum scope | pre-read | post-read | rollback | reason |
|---|---|---|---|---|---|---|---|---|
| Re-pin campaign conversion goal to Purchase-only custom goal (drift repair) | CONFIGURATION | Autonomous | G0 drift flag; pre-read shows non-conforming goal mode/membership | per campaign | campaign goal mode + custom-goal membership | same fields | restore pre-read goal config | Protects the bidding objective; the core doctrine repair [answer/9143218] |
| Re-enable KS_C8_Brand_Protection if paused | CONFIGURATION | Autonomous | pre-read status=PAUSED; change_event shows pause was not T-authored (else ask T) | that campaign only | campaign.status | status=ENABLED | re-pause | Mandated always-on brand defence |
| Disable auto-apply recommendation bundles; set ad-suggestions to manual review | CONFIGURATION | Autonomous | enrolled state detected by G0 | account | subscription/preference state | same | re-enable (never exercised without T) | Ad suggestions auto-apply after 14 days by default — top silent-change vector [answer/10279006] |
| Dismiss individual Google recommendations (never apply) | CONFIGURATION | Autonomous | recommendation inspected + logged | per recommendation | recommendation list | list w/o item | n/a (dismissal reversible in UI) | Keeps recommendation surface clean without ceding control (RecommendationService supports dismiss) |
| Remove a verified-wrong negative (incl. account-level stocked-brand negative, e.g. broad "medicube") | CONFIGURATION (repair) | Autonomous | term matches G3 stocked_vendor_list; negative exists at pre-read; G5 repair proposal attached | that criterion only | negative criteria list | list without it | re-add identical criterion | Negatives are exclusion-only — removal restores blocked reach, cannot create broad targeting [answer/2453972 · answer/7302703] |
| Add campaign/ad-group negatives or attach shared list per G5 verified proposal | CONFIGURATION (policy/irrelevance) or COUNT (performance-based) | Autonomous; performance-based requires COUNT_OK | G5 checks PASS (conflict + stocked-brand + misspelling blast radius); ≤10/campaign/run | campaign or ad-group level; account level requires full-vendor-proof + T notification | existing criteria | criteria incl. new | remove added criteria | Waste control at the correct scope [answer/16127398 for PMax] |
| Pause a bleeder campaign/ad group/keyword | COUNT | Autonomous when COUNT_OK; else T | settled-window zero-conversion evidence per Business-Facts thresholds; not in Learning; G3 confirms not OOS-driven | PAUSE only (never REMOVE) | status + metrics row | status | re-enable | Spend protection; REMOVED is unrecoverable [answer/2404259] |
| Budget change | COUNT (+VALUE for ROAS-justified raises) | Autonomous when state supports basis | pacing/bleeder evidence; ±20%/day; within Business-Facts ceiling; one change/campaign/day | ±20%/day per campaign | budget amount | budget amount | restore prior amount | Bounded scaling under evidence |
| tCPA/tROAS target change | VALUE (CPA-only: COUNT) | Autonomous when VALUE_OK (tCPA: COUNT_OK) | not in Learning; ±15%/step; ≥1 conversion cycle since last change; data floors met (15 conv/30d) | ±15% per step | strategy + target | same | restore prior target | Google's own gradual-step guidance [answer/10276704 · answer/6268637] |
| Pre-17-Aug-2026 target audit executions (tighten loose targets on Limited-by-budget campaigns) | CONFIGURATION+COUNT | Autonomous when COUNT_OK; else T decides before deadline | G1 budget_limited list; new target anchored to 30d actuals; same ±15% step cap unless T waives for deadline | affected campaigns | strategy+target+budget status | same | restore prior targets | 17 Aug behaviour change spends to loose targets [answer/17061251] |
| Turn OFF Display Expansion / Search-partners on a Search campaign | CONFIGURATION (off) / COUNT (on) | OFF: Autonomous. ON: T | OFF requires only pre-read showing enabled + no T annotation claiming intent | per campaign | network settings | same | re-enable | Classic silent budget leak [answer/7193800]; SPN judged on placement data [answer/16286960] |
| Turn OFF PMax Final URL expansion / add URL exclusions | CONFIGURATION | Autonomous | pre-read state; G2 consulted if landing-page strategy implicated | per campaign | expansion setting + rules | same | restore | Page feeds alone are not a fence [answer/14337539] |
| Apply existing brand list as PMax brand exclusion (competitor/serving hygiene) | CONFIGURATION | Autonomous for non-stocked brands; stocked brands PROHIBITED | brand list exists; zero overlap with stocked_vendor_list; Shopping carve-out checkbox decision logged | per campaign | brand list attachments | same | detach | Brand exclusions kill misspellings too — catastrophic on stocked brands [answer/14505308] |
| Create Data Exclusion for a verified tag outage window | CONFIGURATION | Autonomous | G7 evidence of outage window + G0 tracking-status corroboration; ≤14 days span; logged to T | account or affected campaigns | exclusion list | list incl. new | remove exclusion | Official post-outage bidding protection [answer/10370710] |
| Seasonality Adjustment for a planned 1–7 day event | VALUE | T-only (G9 drafts) | event documented in Business Facts; 1–7 days (never >14) | per event | adjustment list | same | remove | Misuse degrades bidding [answer/10369906]; promo decisions are T's |
| Enable AI Max (any campaign), opt-in/out of Sept 2026 auto-upgrade cohort | CONFIGURATION (high-blast) | T-only (G9 prepares evidence + toggle audit) | full three-lever audit (matching/text/URL) + brand controls preset | n/a | AI Max settings | n/a | n/a | Three simultaneous levers; strategy decision [answer/15910187] |
| Campaign/ad-group/conversion-action creation; MC/Shopify/GBP/GA4/tag/billing/appeals; REMOVE ops; GSC settings | — | T-only (hard forbidden for G9) | — | — | — | — | — | Reserved list + irreversibility |

**Pending-proof state (defined):** After a mutate, deterministic post-read (same GAQL fields re-queried) is the interim proof of execution; change_event is the audit proof (documented propagation up to ~3 minutes; treat up to 24h as tolerable variance). If post-read passes but change_event has no row: report `EXECUTED_PENDING_CHANGE_HISTORY` with the mutate request-id; **next run**: query change_event filtered to the mutate window (within its 30-day lookback [developers.google.com/google-ads/api/docs/change-event]); if found → close to EXECUTED_VERIFIED; if absent after 24h → ANOMALY to T with post-read evidence attached (change_event omits some change types — absence is not proof of failure [answer/2454137]).

**Additional authorities G9 can safely receive next (in order, each reversible + evidence-chained):** (1) RSA/asset pausing within existing ad groups (pause-only); (2) experiment creation/apply for AI Max and PMax uplift tests (official A/B path [answer/16450159 · answer/12997711]); (3) portfolio bid-strategy creation + campaign attachment for low-volume pooling [answer/6263072]; (4) conversion value rules (location/device/audience multipliers) with T-set bounds [answer/10518330]; (5) sub-7-day conversion adjustment (retract/restate) uploads driven by G7-verified Shopify refunds [answer/7686449]; (6) scheduled Auction Insights export configuration. Not recommended even later: conversion-action edits, tag changes, MC writes, structure creation — the blast radius exceeds any evidence chain G9 can produce.

---

# 7. Tool Capability Matrix

| surface | API | MCP | browser | read capability | write capability | limitation | correct agent |
|---|---|---|---|---|---|---|---|
| Google Ads | Ads API **v25** (client 31.2.0; v21–v25 only) | Official `googleads/google-ads-mcp` — Experimental, READ-ONLY (search, list_accessible_customers, get_resource_metadata) | Ads UI | Full GAQL: metrics, config, change_event/change_status, search terms (incl. PMax views) | Full mutates: campaigns, budgets, keywords, negatives (all levels), shared sets, conversion uploads/adjustments, recommendations apply/dismiss, BatchJob | change_event 30d/10k; change_status 90d; UI Change History 2y; Auction Insights metrics allowlist-gated; MCP cannot write | G0/G1/G5 read; **G9 writes** |
| Google Ads scripts | AdsApp (in-platform) | — | — | reports, entities | pause/enable, budgets, negatives; PMax via AdsApp + mutate | 30-min runtime; hourly max cadence; a mutation source G0 must watch | G0 (watch), G9 (optional guardrail layer) |
| Merchant Center | **Merchant API v1** (accounts, products, datasources, inventories, reports, promotions, notifications, issueresolution, quota…; reviews still v1beta) | none official | MC UI (Product Studio etc.) | productstatuses, productView (clickPotentialRank), issue rendering, quota | productInputs insert/patch/delete; datasources CRUD — **T-reserved for this fleet** | Content API sunset 2026-08-18; promotions not ZA; some visual panels UI-only | G3 (read), T (write) |
| GA4 | Data API v1beta (runReport ≤250k rows); Admin API v1beta (keyEvents, googleAdsLinks) | Official `analytics-mcp` — READ-ONLY | GA4 UI (DebugView) | reports, realtime, funnels, config audit | keyEvents/links CRUD exists in API — **T-reserved** | Data API still beta; quotas unverified (§11); name-collision community package exists | G7/G8 read; T write |
| Search Console | Search Analytics API (25k rows/req, 16-month, hourly since Apr 2025); urlInspection; sitemaps | none official | GSC UI | performance, inspection, sitemaps; BigQuery bulk export | sitemap submit; settings incl. generative-AI control = UI-only, **T-reserved** | anonymized queries; 2–3d lag; Generative AI report UI-only + rollout-gated, no API | G2 (read), G10 (via G2), T (settings) |
| Business Profile | v1 API family + businessprofileperformance.v1 | none official | Search/Maps in-context editing | performance metrics, profile state (after access request; default quota 0) | profile edits via API exist — **T-reserved**; NO reviews methods in v1 | access-request gate; reviews/replies effectively UI-only; verification human-only | G4 (read/draft), T (write) |
| Shopify | Admin API (GraphQL) — LIVE in this session via MCP | Shopify MCP (this session; read+write tools) | Shopify admin | products, variants, inventory, orders, shop info | full writes exist — **T-reserved** | non-Plus checkout restrictions; web-pixel sandbox limits | G3 (products/inventory), G7 (orders), T (write) |
| Auction Insights | v25 metrics exist but allowlist-gated | — | Ads UI report + scheduled email exports | per-competitor IS/overlap/outranking (UI); API IS-decomposition metrics (own account) always available | n/a | no public API serving; Shopping shows only 3 metrics | G6 |
| Ads Transparency Center | none | — | adstransparency.google.com | competitor creatives by region/date, verification status | n/a | no spend/targeting/bid data — observation only | G6 |
| Controlled SERPs / AI surfaces | none | — | Ad Preview & Diagnosis + pinned-location sampling | ad presence without impression accrual; AI-surface captures | n/a | personalization contamination outside Ad Preview; AI answers volatile | G6 (capture), G10 (consume) |

---

# 8. Fleet Policy Patches

Exact replacement wording. **KEEP** = unchanged; **REWRITE** = replace old wording with the text given; **ADD** = new rule; **REMOVE** = delete.

**P1 (REWRITE — was "Judge Google Ads using Conversions, never All conversions."):**
"Judge Google Ads performance only on the Conversions and Conversions value columns, and only when G0's current fleet_health confirms (a) Purchase is the only Primary action, (b) every campaign is on its campaign-specific Purchase-only custom goal, and (c) no non-Purchase action sits inside any custom goal in use. If any check fails, the Conversions column is untrusted until G9 repairs the configuration. All conversions may be used for configuration diagnostics only, never for performance judgment."

**P2 (KEEP + ADD rider — "Purchase is the only Primary conversion."):**
ADD: "The Ads-native (Analyzify-fed) Purchase action is the Primary. Any GA4-imported purchase key event must remain Secondary and outside every custom goal in use. Google-hosted actions (e.g. GBP local actions) must remain Secondary. A Secondary action inside a custom goal feeds bidding — custom-goal membership is audited, not assumed."

**P3 (KEEP — "Campaign goals must be campaign-specific and Purchase-only.")** with cadence rider: "G0 verifies goal mode and membership on every run; G9 repairs drift autonomously."

**P4 (KEEP — "KS_C8_Brand_Protection must remain enabled.")** with executor rider: "If found paused and the pause is not T-authored in Change History, G9 re-enables it autonomously with the standard evidence chain."

**P5 (REWRITE — was "BeautyOnTApp stocks Medicube; never apply an account-wide BoT Medicube negative."):**
"No account-level negative keyword, and no brand-exclusion list entry, may match any vendor present in G3's live stocked_vendor_list (currently including MEDICUBE — verified via Shopify Admin API). This guard covers misspellings (negatives block misspellings since 26 Jun 2024) and applies to Search, Shopping and Performance Max, because account-level negatives and brand exclusions reach all three. Campaign- and ad-group-level negatives on stocked-brand terms are permitted only as routing controls with a written routing rationale. If G3's vendor list is older than 72 hours, no negative proposal ships. An existing account-level negative matching a stocked vendor is a configuration defect that G9 must remove as a repair."

**P6 (REWRITE — G9 authority):**
"G9 has the highest fleet authority and is an executor, not a reporting layer. Measurement corruption gates by class: COUNT_CORRUPT blocks count-based actions, VALUE_CORRUPT blocks value-based actions, and neither blocks CONFIGURATION repairs, which are always eligible. On every run G9 must execute the highest-priority eligible action within its §6 authority matrix, with pre-read, post-read, Change History and revert evidence. Returning NO_ELIGIBLE_CONTROLLED_CHANGE while a verified configuration repair is queued is a failure state. G9 challenges upstream labels by recomputation and logs CHALLENGED verdicts rather than inheriting errors."

**P7 (KEEP + CLARIFY — reserved-to-T list):**
"Tracking, GA4, Analyzify, conversion actions, billing, policy appeals, new campaign structures, Merchant Center writes, Shopify writes, GBP writes, website changes, GSC settings (including the Search generative AI control) and non-Ads platforms remain reserved for T. Carve-outs granted to G9: Data Exclusions for verified tag-outage windows; disabling auto-apply bundles and setting ad-suggestions to manual; dismissing recommendations."

**P8 (KEEP + ADD rider — "Analyzify v4 owns tracking. Simprosys is feed-only."):**
ADD: "Exactly one purchase pipeline: the Shopify Google & YouTube channel must not publish products (duplicate-offer errors) and must not hold a GA4 connection to the production property (duplicate purchase events). G7 verifies the single-pipeline condition on every run. Exactly one primary feed submitter: Simprosys. Supplemental data sources may enrich attributes but never add products."

**P9 (KEEP — "Shopify is Advanced, not Plus.")** with deadline rider: "Non-Plus consequence now active: legacy Thank-you/Order-status scripts die by 26 Aug 2026 (auto-upgrades since Jan 2026). T confirms all tracking is Web-Pixels-based before that date; G7 treats any post-upgrade purchase-count drop as a checkout-migration suspect first."

**P10 (KEEP — "No free-delivery advertising.")** with policy rider: "Also prohibited by Misrepresentation policy exposure: advertising any delivery/discount/promotion term the checkout does not honour. Merchant Center Promotions are unavailable for ZA offers — no promotion feeds."

**P11 (KEEP — volatile figures from Business Facts or live evidence.)**

**P12 (ADD — settlement windows):**
"No CPA/ROAS/pause/budget/target judgment may use days inside the conversion-lag envelope. G7 publishes the settlement boundary date on every run; G1/G8/G9 must cite it. Google Ads reports conversions at click date; recent days are structurally incomplete."

**P13 (ADD — change evidence):**
"Every G9 mutation produces pre-read, post-read, Change History reference (or EXECUTED_PENDING_CHANGE_HISTORY with next-run closure) and a written revert. Pause is used instead of remove wherever pause exists; REMOVE operations are prohibited fleet-wide (REMOVED entities are unrecoverable)."

**P14 (ADD — deadline calendar):**
"G0 maintains the platform deadline calendar as a standing output: 2026-08-17 target-based bidding behaviour change; 2026-08-18 Content API sunset; 2026-08-26 Shopify non-Plus checkout-script deadline; 2026-09 AI Max auto-upgrade (ACA/broad-match cohort); 2027-02 DSA→AI Max migration. Each entry names an owner and a pre-deadline task."

**P15 (ADD — AI feature enrollment):**
"AI Max (Search or Shopping), ACA enablement, brand-inclusion architecture, Final URL expansion enablement, Display expansion enablement, and auto-apply enrollment are T-decisions. G0 inventories exposure (which campaigns would auto-upgrade in Sept 2026); G9 may only disable/opt-out, never enable."

**P16 (ADD — AI-surface scope):**
"AI Mode is live in South Africa (since 21 Aug 2025); ads in AI Overviews do not serve in ZA (12-country list excludes ZA). G10 measures AI-surface citation presence; no fleet spend decision may assume AIO ad inventory in ZA until Google announces it. llms.txt receives zero fleet effort for Google surfaces. Google-Extended blocking is a T-level decision that does not affect Search/AIO inclusion."

**P17 (REMOVE):** any standing instruction that says "Auction Insights is not available via API" as an absolute; replaced by the allowlist-aware wording in §6/§7. Any instruction referencing Discovery, Video Action, Smart Shopping campaigns, "MC Next" as a distinct product, GA4 "conversions", or Ads API versions below v21 — retire the vocabulary.

---

# 9. Per-Agent Prompt Patches

Copy-ready blocks. Only changed or missing instructions — merge into each agent's existing prompt.

```xml
<g0_patch>
  <add id="goal-membership-audit">Audit conversion configuration in three layers every run: (1) exactly one Primary action and it is the Ads-native Purchase; (2) every enabled campaign uses its campaign-specific Purchase-only custom goal; (3) no non-Purchase action is a member of any custom goal in use — a Secondary action inside a custom goal feeds bidding (support.google.com/google-ads/answer/11461796).</add>
  <add id="silent-change-surfaces">Verify every run: auto-apply bundles disabled; ad-suggestions preference = manual review (they auto-apply 14 days after creation by default, answer/10279006); Display Expansion unchecked on Search campaigns; PMax Final URL expansion state matches Business Facts; no campaign silently enrolled in AI Max; "remove conflicting negative keywords" recommendation NOT auto-applied. Read change_event with a ≤30-day window and LIMIT ≤10000, segment by ChangeClientType, and treat GOOGLE_ADS_RECOMMENDATIONS/automated-rule/scripts rows as priority review items.</add>
  <add id="deadline-calendar">Maintain deadline_flags: 2026-08-17 bid-target behaviour change (flag every Limited-by-budget tCPA/tROAS campaign until its target is reviewed); 2026-08-18 Content API sunset; 2026-08-26 Shopify checkout-script deadline; 2026-09 AI Max auto-upgrade cohort (flag every Search campaign with ACA on or campaign-level broad match); 2027-02 DSA migration.</add>
  <add id="gsc-ai-control">Confirm Search Console "Search generative AI control" = Include (owner-level, destructive if Exclude; webmasters/answer/16908024). Report only; changing it is T-only.</add>
  <add id="absence-not-proof">Change History omits some change types and Google-rep changes (answer/2454137). Never report "no changes occurred" — report "no changes recorded".</add>
</g0_patch>

<g1_patch>
  <add id="settlement-discipline">Never issue CPA/ROAS verdicts for dates after G7's published settlement boundary; Ads reports conversions at click date (answer/9520128). Never judge campaigns in Learning (answer/13020501).</add>
  <add id="corruption-mode">When measurement_state != CLEAN: switch to spend/serving-anomaly mode, mark every efficiency metric UNTRUSTED, and keep reporting — do not go silent.</add>
  <add id="budget-limited-watch">List every Limited-by-budget campaign on tCPA/tROAS with target vs 30-day actual — from 2026-08-17 those campaigns spend to target (answer/17061251).</add>
  <add id="modern-surfaces">Use SPN site-level placement reporting instead of recommending blanket search-partner opt-outs (answer/16286960). Use PMax channel-level reporting for spend splits. Remember PMax vs Standard Shopping is decided by Ad Rank, not PMax priority (answer/13810170).</add>
  <add id="oos-check">Before flagging a Shopping/PMax campaign as decaying, join G3.advertised_oos — an out-of-stock hero SKU is a feed event, not a performance event.</add>
</g1_patch>

<g2_patch>
  <add id="benign-states">"Crawled/Discovered - currently not indexed" and "Duplicate without user-selected canonical" on variant/filtered/paginated Shopify URLs are documented benign states (webmasters/answer/7440203) — report counts, never alarm or mass-validate.</add>
  <add id="pull-ownership">You are the sole GSC puller. Deliver raw pulls to G10; paginate searchanalytics at 25k rows; treat the last 2-3 days as provisional; anonymized queries make sum-of-queries < totals by design.</add>
  <add id="bulk-export">Recommend (T decision) enabling the BigQuery bulk export now — 16-month retention is a hard wall and the export is not retroactive (answer/12918484).</add>
  <add id="schema-ownership">Audit rendered PDP HTML for exactly one Product JSON-LD block whose ZAR price/availability match the Simprosys feed; Google recommends feed + on-page markup together (developers.google.com/search/docs/appearance/structured-data/product), and Merchant automatic item updates read that markup.</add>
</g2_patch>

<g3_patch>
  <add id="vendor-list">Publish stocked_vendor_list from live Shopify vendor data every run — it is the fleet's negative/brand-exclusion guard input. Staleness >72h blocks G5 proposals.</add>
  <add id="oos-tree">For every advertised offer: Shopify=0 AND feed=out_of_stock → correct state, no action. Shopify=0 AND feed=in_stock → SYNC_DEFECT → escalate T (+ optional G9 Ads-exclusion proposal). Active in Shopify AND disapproved in MC → diagnose reason → T. Report the advertised_oos list every run.</add>
  <add id="merchant-api">Use Merchant API v1 exclusively (Content API sunsets 2026-08-18). Product names are {contentLanguage}~{feedLabel}~{offerId} — three segments. Offer IDs are immutable; never propose remapping (merchants/answer/6324405). Audit that Simprosys is the only publishing submitter and the Google & YouTube channel is non-publishing (duplicate offers now error; answer/16529073).</add>
  <add id="hygiene">GTINs must be real GS1 allocations (answer/9545238); no promotional text on images (answer/12158684); automatic item updates stay ON (answer/12157888); promotions are unavailable for ZA offers (answer/13422697) — never propose promotion feeds.</add>
</g3_patch>

<g4_patch>
  <add id="write-boundary">Draft, never post. All GBP writes are T-only. Never draft anything that gates reviews or offers incentives (contributionpolicy/answer/7400114).</add>
  <add id="reverification-risk">Name/address/category are re-verification triggers (business/answer/3039617); video verification is a live human-only flow (answer/14271705). Freeze all such edits when any verification is pending.</add>
  <add id="api-gate">GBP APIs ship with quota 0 until an access request is approved; reviews have no modern-API path. Until approved, operate in UI-read/draft mode and say so in your output.</add>
  <add id="local-actions">When location assets exist, Google auto-creates Google-hosted local-actions conversions (answer/9013908). Verify with G0 they stay Secondary and out of the Conversions column.</add>
</g4_patch>

<g5_patch>
  <add id="guard">Run every proposal through: stocked-brand check against G3's live vendor list (covering the misspelling blast radius — negatives block misspellings since 26 Jun 2024, answer/15070437); conflict check against positive keywords and converting queries; level/precedence simulation (account → shared list → campaign → ad group). Account-level proposals require proof of non-match against every stocked vendor; account-level negatives reach Search, Shopping AND PMax (answer/11396330).</add>
  <add id="corruption-mode">When COUNT_CORRUPT: continue proposing policy/irrelevance negatives (CONFIGURATION evidence); suspend performance-based negatives only.</add>
  <add id="pmax-scale">PMax accepts 10,000 campaign-level negatives and (since Aug 2025) negative keyword lists; use lists for scoping. Search themes are steering, not caps. Shopping has no positive keywords — coordinate with G3 on titles.</add>
  <add id="visibility-honesty">Report visible-term share every run; the privacy threshold hides low-volume terms whose spend stays in totals (answer/11127882) — never extrapolate negatives from hidden terms.</add>
  <add id="repairs">Separately report negative_repairs: existing negatives that violate the guard (e.g. an account-level stocked-brand negative). Removing a broad negative restores blocked reach only — it cannot enable broad targeting (answer/2453972) — and is an eligible G9 repair.</add>
</g5_patch>

<g6_patch>
  <add id="intake">Auction Insights intake = scheduled UI exports (validate period/scope before use). The v25 API auction_insight_* metrics are allowlist-gated — do not build API intake until T confirms allowlist. Search reports 6 metrics; Shopping only IS/overlap/outranking (answer/2579754).</add>
  <add id="causality">Auction Insights proves auction outcomes, never competitor bids/budgets. Before any bid/budget implication, decompose IS loss into search_budget_lost_impression_share vs search_rank_lost_impression_share and certify which one dominates. Label every claim OBSERVATION or INFERENCE.</add>
  <add id="serp-hygiene">All SERP checks via Ad Preview & Diagnosis (no impression accrual, no CTR damage; answer/148778), location-pinned to ZA. Produce serp_bundle (query, ts, location, capture, ai_surface_presence, citing_urls) — G10 consumes it and must never re-run your queries. Bundle expires 48h.</add>
  <add id="transparency-limits">Ads Transparency Center shows verified advertisers' creatives by region/date only — no spend, targeting or bids. Use for creative-change observation, never spend claims.</add>
</g6_patch>

<g7_patch>
  <add id="corruption-classes">Output measurement_state ∈ {CLEAN, COUNT_CORRUPT, VALUE_CORRUPT, ATTRIBUTION_DEGRADED} with affected date ranges and evidence rows. Corruption = tag-level defects only (zero-count days with orders present; duplicate transaction_ids; value drift beyond tolerance; wrong currency; dual-pipeline double-fire). Expected differences are NOT corruption: GA4 fractional credit (DDA), click-date vs conversion-date timing, GA4-import ≤24h delay, privacy residuals, baselined Shop Pay undercount (SECONDARY-documented).</add>
  <add id="dual-pipeline">Verify every run that exactly one purchase pipeline fires: Analyzify v4 only; no Google & YouTube channel GA4 connection; no leftover theme gtag. Shopify documents duplicate tracking as the top migration failure (help.shopify.com pixel-migration).</add>
  <add id="value-mapping">The purchase value mapping (totalPrice incl. VAT vs subtotalPrice) and currency=ZAR are pinned in Business Facts; any deviation is VALUE_CORRUPT. A non-ZAR currency code silently rescales revenue via FX (analytics/answer/9796179).</add>
  <add id="settlement-boundary">Publish the settlement boundary date every run (today minus the observed conversion-lag envelope); G1/G8/G9 must cite it.</add>
  <add id="refund-visibility">Report whether refund events flow to GA4 (nothing sends them automatically from Shopify) and whether Ads adjustments are in use; note the 55-day adjustment limit and 7-day bidding-use window (answer/7686449).</add>
</g7_patch>

<g8_patch>
  <add id="basis-labels">Label every recommendation with basis ∈ {CONFIGURATION, COUNT, VALUE} and the measurement_state it requires. Configuration repairs rank above performance actions when both are queued.</add>
  <add id="no-own-pulls">Consume G1/G7/G3/G5/G6 outputs only; you pull no Ads/GA4 metrics yourself. Re-derive totals from their rows as a consistency check and log discrepancies as CHALLENGE items for G9.</add>
  <add id="free-listings">Segment free-listings traffic (available in ZA) from paid Shopping when reading revenue mix.</add>
</g8_patch>

<g9_patch>
  <add id="eligibility">Gate by evidence class: COUNT_CORRUPT blocks count-based actions; VALUE_CORRUPT blocks value-based; CONFIGURATION repairs are always eligible. Returning NO_ELIGIBLE_CONTROLLED_CHANGE while a verified configuration repair is queued is a failure state.</add>
  <add id="challenge-duty">Recompute the basis of every upstream label you act on. Reject with a logged CHALLENGED verdict anything that fails (bleeder on unsettled days, corruption claims built on model differences, negatives without guard proof). Challenge means recompute-and-verify, not re-analyze everything.</add>
  <add id="evidence-chain">Every mutation: pre-read exact fields → mutate → post-read same fields → change_event query. If change_event lacks the row but post-read matches intent: report EXECUTED_PENDING_CHANGE_HISTORY and close it next run via change_event (30-day lookback); if still absent after 24h, raise ANOMALY with post-read evidence (Change History omits some change types — absence ≠ failure).</add>
  <add id="caps">Budget ±20%/day within Business-Facts ceiling; targets ±15%/step, one step per conversion cycle, never during Learning; ≤10 negatives per campaign per run; one primary change per run per scope; PAUSE always, REMOVE never.</add>
  <add id="execution-priority">Priority order: (1) revenue-protecting configuration repairs (goal drift, brand-protection re-enable, auto-apply/ad-suggestions off, network leaks, wrong stocked-brand negatives); (2) deadline-driven repairs (pre-2026-08-17 target audit); (3) COUNT-gated bleed stops; (4) waste negatives (configuration-evidence first); (5) COUNT+VALUE-clean scaling moves.</add>
  <add id="tooling">Writes via Google Ads API v25 only. The official Ads MCP is read-only — never route a write through it. No mutation when fleet_health is stale (>24h) or BLOCKED.</add>
</g9_patch>

<g10_patch>
  <add id="dependency">Consume G6's serp_bundle exclusively for surface evidence; never run your own SERP queries. Consume G2's GSC pulls; never pull GSC yourself. Bundle >48h old → presence reporting only, no deltas.</add>
  <add id="reporting-truth">The standard GSC Performance report blends AI Mode/AIO traffic with no separating filter — never compute "AI click share" from it. Where the Generative AI performance report (2026-06-03) is present it provides impressions/pages/countries/devices only — no clicks, CTR or queries, and no API. Handle its absence gracefully (rollout-gated).</add>
  <add id="evidence-labels">Label every tactic EVIDENCE-BASED (citable official doc: ai-optimization guide; "succeeding in AI search" 2025-05-21; feed + on-page Product markup for shopping surfaces) or SPECULATIVE (everything else, incl. third-party tracker patterns). llms.txt is officially not used by Google — zero effort. Google-Extended controls Gemini training/grounding only — never present it as an AIO lever.</add>
  <add id="za-scope">AI Mode is live in ZA (2025-08-21 Africa launch); ads in AIO do not serve in ZA (12-country list). Measure organic citation presence; make no ad-inventory assumptions.</add>
</g10_patch>
```

---

# 10. Validation and Canary Plan

Deterministic tests. Each returns PASS/FAIL with evidence artifacts; run before trusting the corresponding capability.

1. **Data access** — For each surface: Ads API (`SELECT customer.id FROM customer`), Merchant API (accounts.get), GA4 Data API (1-day runReport), GSC API (28-day searchanalytics), Shopify Admin (shop query), GBP (state read or documented UI fallback). PASS = all return non-error with expected account identifiers; any failure names the exact credential/scope missing.
2. **Account identity** — Assert Ads customer ID, MC account ID, GA4 property ID, GSC property, Shopify domain (beautyontapp.com) all match Business Facts before any other test; login-customer-id set correctly for MCC path. FAIL on any mismatch aborts the entire run (wrong-account mutation is the worst failure class).
3. **Conversion integrity** — (a) config: count(primary)==1 ∧ primary==Purchase ∧ every campaign campaign-specific Purchase-only ∧ custom-goal membership=={Purchase}; (b) data: for one settled day, Shopify orders ≥ GA4 purchases (dedup working, no inflation) ∧ Ads Conversions ≤ Shopify orders ∧ one sampled order traces 1:≤1:≤1 with value within mapping tolerance; (c) tracking-status column ∉ {Unverified, Tag inactive, Needs attention}.
4. **Stock-to-bid matching** — Take G3's advertised_oos list (expected non-empty today: MDC005/007/008/009/011 at zero inventory, LIVE ACCOUNT FACT); for each, assert feed availability=out_of_stock OR a SYNC_DEFECT escalation exists. PASS = no advertised offer is feed-in_stock while Shopify=0.
5. **Negative conflicts** — Feed the guard three synthetic proposals: account-level broad "medicube" (must FAIL: stocked brand), campaign-level "free delivery" (must PASS with policy-evidence label), ad-group negative equal to an active positive keyword (must FAIL: conflict). Also assert the "remove conflicting negatives" recommendation is not auto-apply-enabled.
6. **Merchant defects** — Merchant API productstatuses returns for all advertised offers; one known-good offer (MDC001, R570) shows approved + price parity with Shopify; disapproval reasons map to the taxonomy (price/availability mismatch, text-on-image, GTIN).
7. **G9 execution** — On the designated always-paused canary ad group: pre-read label state → mutate label → post-read equality → change_event row within 24h (else pending-proof path exercised). PASS = all four artifacts + decision log written.
8. **Rollback** — Immediately revert the canary mutation from the stored revert payload; post-read must equal the original pre-read byte-for-byte; both cycles visible in Change History within 24h.
9. **Change History propagation** — Timestamp mutate→first change_event appearance across 5 canary cycles; assert ≤3 min typical (documented), record the observed distribution as the fleet's propagation baseline; assert change_event query with 31-day window correctly errors (proves lookback-guard logic works).
10. **Scheduler serialization** — Trigger two overlapping G9 runs; assert exactly one acquires the execution lock and the other exits with LOCKED (no double mutation); assert a missed scheduled run performs catch-up reads but never batches two runs' mutations into one.
11. **G6→G10 dependency** — Delete/expire the serp_bundle; assert G10 reports BLOCKED (no self-querying occurred: zero SERP fetches in G10's tool log); restore bundle; assert G10's citation extraction matches a human-read of one stored capture.

---

# 11. Unresolved Evidence

| question | why unresolved | exact source/tool needed | affected decision | owner |
|---|---|---|---|---|
| Verbatim confirmation of the 2026-08-17 bidding change scope (campaign types incl. Display/Hotel?) | egress proxy blocked direct fetch; verified via search retrieval only | direct fetch of support.google.com/google-ads/answer/17061251 | G9's pre-deadline bulk target audit | T (unblocked browser) |
| Sept 2026 AI Max auto-upgrade cohort details + DSA Feb 2027 (verbatim) | same | direct fetch of ads-developers.googleblog.com 2026-06 DSA automigration post | opt-in/opt-out decision per campaign | T |
| Content API sunset extended-access terms | confirmed via Google's GitHub samples README; help-page wording unfetched | developers.google.com/merchant/api migration page | G3 migration contingency | T |
| Auction Insights API allowlist: criteria + whether PNCapital can be granted | allowlist status from official forum (SECONDARY) | Google Ads API support / account rep; test GAQL with auction_insight_search_impression_share | G6 intake modernization | T |
| Whether PMax negative keyword lists are visible in the BoT account UI (ZA rollout) | announced Aug 2025; in-account availability unchecked | live Ads UI check on a BoT PMax campaign | G5 list architecture | T |
| Whether the 26 Jun 2024 misspelling behaviour formally covers account-level and PMax negatives | help-page scope wording unfetched | direct fetch of answer/15070437 + answer/11396330 | guard blast-radius model | T |
| ACA default state on new Search campaigns (on vs off) | conflicting secondary sources | direct fetch of answer/12437745 | G0 Sept-2026 exposure inventory | T |
| Local actions conversions land only in All conversions (verbatim) | column detail corroborated but not directly read | direct fetch of answer/9013908 | G0 local-actions audit | T |
| Data exclusions / seasonality adjustments numeric account limits | unfetched | answer/10370710 + answer/9352512 | G9 outage protocol sizing | T |
| Whether conversion adjustments can target GA4-imported actions | unfetched | answer/7686447 supported-sources section | refund-hygiene design (G7/G9 authority #5) | T |
| Google & YouTube channel: publishing state + GA4 connection on THIS store | store-specific | Shopify admin → Sales channels + GA4 realtime dual-event test | dual-pipeline verification (G7) | T (with G7 script) |
| Analyzify v4 field mapping (value field, refund events, transaction_id source) | vendor-specific | GA4 DebugView + Tag Assistant on a test order + Analyzify docs (SECONDARY) | VALUE integrity tolerance | T |
| Ads/GA4/MC/GSC/GBP live account state (goals, negatives, budgets, targets, diagnostics) | NOT VERIFIED — no authenticated Google access in this session | Ads API/UI with PNCapital credentials; GA4 Admin; MC UI; GSC UI; GBP UI | every LIVE-ACCOUNT gate in §4 | T + G0 first run |
| Search Console Generative AI report present on BoT property | rollout-gated | logged-in GSC UI check | G10 pipeline switch | T |
| GSC generative-AI control current setting | owner-level UI only | GSC Settings check | G0 standing check | T |
| LIA country list (ZA?) + price-competitiveness/price-insights ZA eligibility | unfetched | merchants/answer/3057972 + answer/11916926 | future physical-retail play; G6 price evidence | T |
| Business Profile API access-request status for PNCapital | account-specific | Google Cloud console + GBP API access form | G4 automation build | T |
| Google ToS position on scripted-browser automation of Ads/MC UIs | unfetched | policies.google.com/terms + Google Ads ToS | any Chrome-profile automation design | T |
| Keyword Planner API access-level requirement (basic vs standard token) | unfetched | developers.google.com/google-ads/api/docs/access-levels | G5 optional source | T |
| GA4 Data API quotas; GSC urlInspection daily quota; Merchant API numeric quotas | unfetched | respective quota pages | pipeline sizing | T |
| Exact GA dates: Merchant API GA announcement; PMax channel reporting; search-themes 50-limit; GA4 key-events rename | dates only via SECONDARY | official changelogs/blogs | ledger date precision (no action depends on these) | G0 backlog |

---

# 12. Source Register

Retrieval date for all: **2026-07-31**, via search-engine retrieval of official-page content (egress proxy blocked raw fetches; see method note). Artifact-verified = content read from Google's own published packages/repos.

**Google Ads Help (support.google.com/google-ads/answer/…)** — 2567043 campaign types · 11576060 Smart Shopping/Local→PMax (2022) · 13695777 Discovery→Demand Gen · 15110871 VAC→Demand Gen (complete May 2026) · 17051545 Display→Demand Gen (Jun 2026) · 15910187 + 16738708 AI Max features/ACA transition · 17091277 AI Max for Shopping beta · 16286960 Search partners + parked-domain removal (2026-02-10) · 7193800 Display Expansion · 14505308 PMax brand exclusions · 15726455 + 16127398 PMax campaign-level negatives (10k) · 16451273 search themes 50 + PMax negative lists (2025-08-07) · 14337539 Final URL expansion/URL rules · 16260130 PMax channel reporting · 14792043 lifecycle goals · 13810170 PMax vs Shopping Ad Rank (Oct 2024) · 10279006 auto-apply + 14-day ad suggestions · 10537509 optimized targeting · 17061251 bid-target behaviour change (2026-08-17) [RE-FETCH] · 11461796 primary/secondary + custom-goal exception · 9143218 campaign-specific goals · 4677036 account-default goals · 3419678 Conversions vs All conversions · 3438531 Count Every/One · 3123169 conversion windows · 9520128 click-date reporting · 10632359 GA4-created actions default Secondary · 15712870 EC multi-source (Apr 2026) · 11956168 EC diagnostics · 13695607 EC/consent (EEA scope) · 10370710 data exclusions · 10369906 seasonality adjustments · 13020501 learning status · 14571185 conversion-change relearning · 6268637 tROAS data floors · 10276704 gradual target steps · 6263072 portfolio strategies · 10518330 value rules · 19888 Change History + undo (2y/30d) · 2454137 Change History omissions · 2404259 removal permanence [RE-FETCH] · 2472779/2472728 automated rules (100 cap) · 188712 scripts scheduling · 10575537/7457118/12997711/16030588/13826584/16450159 experiments family · 9342105 match types · 15070437 misspelling negatives + search-term aggregation (2024-06-26) · 7302703 negative broad behaviour · 2453972 negative definitions · 11396330 account-level negatives (1,000; applies to PMax) · 2453983 shared lists (20×5,000) · 14453047 brand inclusions (broad-only) · 3416396 conflicting-negative recommendation · 6275313 Shopping negatives · 9701952 negative troubleshooting · 11127882 search-terms privacy threshold · 11386930 search-terms insights · 6386790 transaction-ID dedup · 7686449 conversion adjustments (55d/7d) [RE-FETCH] · 12674892 tracking status · 7457111 GA4-import timing (≤24h) · 3095550 auto-tagging · 3419241 currency conversion · 9013908 local actions conversions · 2404182 location assets · 148778 Ad Preview & Diagnosis · 2579754 Auction Insights · 16297775 ads in AI Overviews (12 countries, no ZA).

**Google Ads developer (developers.google.com/google-ads/…)** — /api/docs/change-event (30d/10k, ~3-min propagation, old/new values) · /api/docs/change-status (90d) · /api/reference/rpc/v21/ChangeClientTypeEnum · /api/performance-max/reporting (search-term views) · /scripts/docs/limits (30 min) · /scripts/docs/campaigns/performance-max/using-ads-app.

**Google Ads Developer Blog (ads-developers.googleblog.com)** — 2026/06 DSA automigration + AI Max Sept-2026 cohort [RE-FETCH] · 2026/04 Merchant API in Ads scripts (2026-04-22).

**Merchant Center Help (support.google.com/merchants/answer/…)** — 15285007 classic MC retirement (2024-09-30) · 13422697 promotions country list (no ZA) [RE-FETCH] · 6324405 ID immutability · 16529073 duplicate offers error · 15624457 supplemental sources · 9545238 GTIN/GS1 · 12157888 automatic item updates · 12724659 automatic image improvements · 13693497 price/availability mismatch · 12158684 text-on-image · 13889434 free listings ZA · 14615117 LIA requirements · 6150127 Misrepresentation · 11916926 price insights.

**Merchant API (developers.google.com/merchant/api)** — sunset 2026-08-18 + migration [RE-FETCH]; /guides/compatibility/migrate-v1beta-v1 (v1beta shutdown 2026-02-28); /reference/rest (sub-APIs); /guides/products/add-manage (3-segment names); /guides/products/list-products-data-issues (diagnostics parity). Corroborated by github.com/googleads/googleads-shopping-samples README (artifact).

**Google Analytics (support.google.com/analytics/answer/…)** — 10596866 attribution models · 12958241 fractional credit · 13965727 key events rename · 10597962 GA4→Ads channel eligibility · 12313109 purchase dedup/transaction_id · 9796179 currency · 9219655 refund event (via devguides ecommerce) · 10737381 16-month GSC retention (GA link).

**Search Central / Search Console (developers.google.com/search…, support.google.com/webmasters/…)** — webmasters/answer/34592 property types · 7687615 permissions · webmaster-tools/v1/searchanalytics/query (25k rows) · 7576553 data freshness · search/blog/2025/04/san-hourly-data · 12918484 BigQuery bulk export · 12917991 anonymized queries · search/docs/appearance/ai-features (AI data in Performance report) · search/blog/2026/06/gen-ai-performance-reports (2026-06-03) · webmasters/answer/16908024 Search generative AI control · 7440203 indexing states · search/docs/crawling-indexing/consolidate-duplicate-urls · search/docs/appearance/structured-data/merchant-listing · /product · /product-variants (Feb 2024) · 9044175 manual actions · search/docs/appearance/core-web-vitals (INP 2024-03-12) · crawling docs robots-txt-spec · search/docs/fundamentals/ai-optimization-guide (llms.txt not used) · search/blog/2025/05/succeeding-in-ai-search (2025-05-21) · webmasters/answer/16984139 GSC limits.

**Business Profile (support.google.com/business/…, contributionpolicy)** — 14919056 chat retirement (2024-07-31) · 11612023 in-Search management · 14271705 video verification · 3039617 address re-verification · 4569145 suspension appeals · contributionpolicy/answer/7400114 review policies · adspolicy/answer/144649 location-asset policy.

**Google blog (blog.google)** — /intl/en-africa/products/explore-get-answers/google-search-introducing-ai-mode-in-africa/ (2025-08-21) · /products/search/ai-overviews-search-october-2024/ (2024-10-28, 100+ countries) · /products-and-platforms/products/search/ai-overview-expansion-may-2025-update/ (200+ countries) · /products-and-platforms/products/search/ai-mode-expands-languages-locations/ · /products/ads-commerce/channel-performance-reporting-coming-to-performance-max/ · Ads Transparency Center launch post · business.google.com AI Max GA announcement (2026-04-15).

**Shopify (help.shopify.com, shopify.dev)** — checkout upgrade guide (non-Plus deadline 2026-08-26; view-only since 2025-08-28; auto-upgrades Jan 2026; artifact-corroborated via shopify.dev changelog) · pixels/pixel-migration (duplicate tracking) · apps/build/marketing-analytics/pixels (sandbox limits) · web-pixels-api/standard-events/checkout_completed (price fields) · marketplaces/google syncing-products.

**Artifacts (Google-published packages/repos)** — pypi.org/pypi/google-ads/json + google_ads-31.2.0 wheel (v25 current; v21–v25 supported; services incl. change_event, auction_insight metrics, KeywordPlanIdeaService, RecommendationService) · github.com/googleads/google-ads-mcp + pypi google-ads-mcp 0.0.1 (read-only tools) · pypi analytics-mcp (official GA4 MCP) vs pypi google-analytics-mcp (community — do not use) · google-api-python-client 2.198.0 discovery documents (Merchant API v1 sub-APIs incl. quota; Content API "deprecated" self-description; GA4 Data/Admin v1beta capabilities; GSC API rowLimit; GBP quota-0 note).

**SECONDARY (labelled; bugs/dates only, never overriding official)** — groups.google.com adwords-api threads (auction-insight allowlist; Editor-changes-missing-from-change_event report) · community.shopify.dev Shop Pay pixel reports · searchengineland.com (PMax negative-limit timeline) · ppc.land (review-policy update wording) · dacgroup.com (re-verification observations) · inforegulator.org.za/popia (POPIA — primary for SA law, non-Google).

---

## Quality-gate verdict

**If PNCapital implements only five changes, implement these:** (1) Before 17 August 2026, audit every Limited-by-budget tCPA/tROAS campaign and tighten loose targets to 30-day actuals — after that date Google spends to the target you left there. (2) Split the corruption rule: COUNT/VALUE corruption blocks only count/value-dependent actions, and G9 executes configuration repairs unconditionally — with the pre-read → mutate → post-read → change_event evidence chain and the EXECUTED_PENDING_CHANGE_HISTORY closure loop defined in §6. (3) Replace the static Medicube rule with G3's live stocked-vendor-list guard feeding G5/G9, and close today's live gap: five ACTIVE zero-inventory Medicube SKUs must be feed-verified out_of_stock or escalated. (4) Confirm before their August 2026 deadlines that nothing in the stack still calls Content API for Shopping and that all purchase tracking is Web-Pixels-based, then have G0 inventory the Sept-2026 AI Max auto-upgrade cohort (ACA/broad-match campaigns) for T's opt-in/opt-out decision. (5) Kill the silent-change vectors G0 found verifiable: auto-apply bundles off, ad-suggestions to manual review, conflicting-negative recommendation never auto-applied, Display/URL-expansion states pinned, and GSC's Search-generative-AI control confirmed Include.
