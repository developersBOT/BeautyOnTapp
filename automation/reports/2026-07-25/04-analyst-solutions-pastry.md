---
agent: 04-analyst-solutions
brand: pastry
brand_name: Pastry Skincare
date: 2026-07-25
run_id: analyst-solutions-2026-07-25-7b4e2a1d
data_sources_used:
  - "Repo · automation/reports/2026-07-25/01-ppc-audit-pastry.md (Meta act 2972238613000896, 28d + 7d)"
  - "Repo · automation/reports/2026-07-25/01-ppc-audit-bot.md (Meta act 1615943869585748 — cross-brand evidence)"
  - "Repo · automation/reports/2026-07-25/02-seo-audit-pastry.md (WebSearch-only, degraded)"
  - "Repo · automation/reports/2026-07-25/02-seo-audit-bot.md (WebSearch-only, degraded)"
  - "Repo · automation/reports/2026-07-25/03-merchant-feed-pastry.md (blocked run)"
  - "Repo · automation/reports/2026-07-25/03-merchant-feed-bot.md (blocked run)"
  - "Repo · automation/config.yaml (guardrails, benchmarks, data-source health)"
data_gaps:
  - "SYNTHESIS AGENT — NO NEW DATA PULLED. Zero connector calls this run (no Meta, no Shopify, no Semrush, no Google Ads). Every figure is quoted from the reports above and cited."
  - "NO PASTRY STORE REVENUE AND NO MER — second consecutive run. Shopify token expired; the Pastry store was never reached (01-ppc-audit-pastry.md). No MER, blended ROAS or store-revenue figure is stated or inferred anywhere in this report."
  - "REVENUE FIGURES ARE DERIVED. All Pastry revenue is purchase_roas x amount_spent, because omni_purchase_values is wrong by exactly 100x on this account's prospecting entities (01-ppc-audit-pastry.md)."
  - "PASTRY STORE REACHABILITY UNVERIFIED. It is unconfirmed that pastryskincare.co.za is served by the same Shopify org as beautyontapp.com; it may be a separate org or mid-migration (03-merchant-feed-pastry.md)."
  - "DOMAIN RESOLVED BY WEBSEARCH ONLY. pastryskincare.co.za rests on 14 indexed URLs plus customer@pastryskincare.co.za — not a get-shop-info confirmation (02-seo-audit-pastry.md). config.yaml still reads domain: auto."
  - "INHERITED GAP · Semrush out of API units — zero rankings, traffic, backlinks, Authority Score, CWV (02-seo-audit-pastry.md)."
  - "INHERITED GAP · Outbound HTTPS 403 at the session proxy for all hosts — no robots.txt, sitemap, canonical, schema or H1 checks."
  - "INHERITED GAP · No Google Ads API/MCP; automation/inbox/ holds only README.md. ZERO Google Ads figures appear in this report. Account 851-084-2703 was not accessed and not modified."
  - "3-DAY DELIVERY BLACKOUT 02/07–05/07/2026 inside the 28d window. Rate metrics unaffected; 28d totals understate a full 28 days (01-ppc-audit-pastry.md). Any period-over-period comparison must adjust."
  - "The WooCommerce/Shopify platform split on pastryskincare.co.za is inferred from URL patterns and is NOT VERIFIED; the duplication itself is directly evidenced by indexed URLs."
---

# 04 · Analyst / Solutions — Pastry Skincare — 2026-07-25

Currency ZAR (R). Windows per agent 01: **28d = 28/06/2026–25/07/2026**, **7d = 19/07/2026–25/07/2026**.
Synthesis run. No channel data pulled, no account touched.

## Summary

- **Pastry's #1 problem is measurement integrity, and it is worse than any single report shows.** Purchase values are wrong by exactly 100x on prospecting entities (`01-ppc-audit-pastry.md`), there has been no store revenue or MER for two runs, the store connection itself is unverified (`03-merchant-feed-pastry.md`), and the product line sells through **at least five indexed storefronts** (`02-seo-audit-pastry.md`). The account reports ROAS 8.12x and CPA R105.06 — figures nothing can currently corroborate.
- **Cross-report narrowing of the 100x defect:** the BoT ad account sells the *same Pastry products* through four prospecting adsets and every equivalent field there checks **correct** (`01-ppc-audit-bot.md`). So if both accounts drive the same store/catalogue/pixel, a catalogue price-field origin is ruled out and the fault sits in act 2972238613000896's own event path. If they drive different stores, the catalogue hypothesis survives. **Either way the diagnosis is gated on one read-only question: where do the BoT-side Pastry adsets land?**
- **The instrumentation gap and the sprawl gap are the same gap seen twice.** A Pastry sale can land on its own site, `beautyontapp.com`, `shopbeautyontapp.co.za`, Takealot or Raines (`02-seo-audit-pastry.md`), while R65,976.49/28d of Pastry-product prospecting runs across two ad accounts (`01-ppc-audit-bot.md`). No MER is computable until someone says which properties count.
- **The domain is now resolved — `pastryskincare.co.za`** — closing agent 01's blocker (`02-seo-audit-pastry.md`). Pinning it in `config.yaml` also removes the `switch-shop` call that caused the three-run Shopify outage. One edit, two problems.
- **Not everything is blocked.** The three `RT_*` retargeting adsets have **internally consistent** purchase values (ratio 1.00x) and are the fleet's most efficient spend at R250/day caps. A bounded scaling step there is defensible today; prospecting is not.

## Findings

Format: **problem → root cause → solution**. Severity `[C]/[H]/[M]/[L]`, impact 1-5 / effort 1-5, owning channel, disposition (**auto-appliable** within `config.yaml` · **needs a human** · **Google-Ads recommend-only**).

Root-cause clusters: **RC-1 property & spend ownership sprawl** · **RC-2 measurement integrity** · **RC-3 duplicate-instead-of-edit process** · **OB operational blockers**.

---

### P1 · [C] Purchase values are 100x wrong on prospecting, and the diagnosis is gated on a property question — RC-2 (impact 5 / effort 2) · Meta/tracking · **needs a human** (`config.yaml` `never: [change_pixel, change_capi]`)

**Problem.** Within a single API response, `omni_purchase_values` contradicts `purchase_roas × amount_spent` by exactly 100x on five prospecting entities — `PASTRY_Main_Revenue` reports R2,022.89 against an implied R202,289 — while four retargeting entities in the same account and same call are exact at 1.00x (`01-ppc-audit-pastry.md`). The **inconsistency is verified**; the **cause is inference and is NOT VERIFIED**.

**Root cause — two candidates with very different severity, per agent 01.** *Benign:* a reporting artifact where value arrives in cents while ROAS is computed on rands. Reporting wrong, bidding fine. *Serious:* the pixel/CAPI path feeding those prospecting adsets genuinely sends values 100x too small, in which case any value-based bid strategy on `PASTRY_Main_Revenue` is optimising against a corrupted signal.

**What synthesis adds — a third discriminator neither report could use alone.** The BoT account runs four adsets selling the **same Pastry product line**, and `01-ppc-audit-bot.md` states every equivalent field there checked correct. Therefore:
- *If the BoT-side Pastry adsets drive to the same store, catalogue and pixel as Pastry's prospecting*, the same catalogue would have corrupted both accounts. It did not. **A catalogue price-field origin is ruled out** — which contradicts the plausible-origin hint passed to agent 03 in `01-ppc-audit-pastry.md`, and points the diagnosis at act 2972238613000896's own dataset/event configuration.
- *If they drive to a different store*, the catalogue hypothesis survives and must still be checked.

**Solution.** (1) Read the destination URLs of the four BoT-account Pastry adsets — read-only, one call, no human (see B2 in `04-analyst-solutions-bot.md`). (2) In Events Manager, compare `value` and `currency` on Purchase events attributed to `PASTRY_Main_Revenue` / `AS1_Hyperpigmentation` / `AS2_Body_Care_Broad` against the `RT_*` adsets (`01-ppc-audit-pastry.md` Rec 1). (3) Until resolved, treat `purchase_roas × amount_spent` as the only trustworthy revenue read and **freeze value-based bid scaling on prospecting**. Step 1 costs nothing and sharply narrows step 2.

---

### P2 · [C] Pastry has no store economics at all — and the outage is caused by config — OB → RC-2 (impact 5 / effort 1) · Ops + Shopify · **needs a human** ⭐ HIGH IMPACT / LOW EFFORT

**Problem.** Two consecutive runs with no store revenue and no MER; three runs with no feed data; and it is unconfirmed that the connector can reach `pastryskincare.co.za` at all (`01-ppc-audit-pastry.md`, `03-merchant-feed-pastry.md`).

**Root cause.** `config.yaml` sets `brands[pastry].domain: auto`, "resolved at runtime via `switch-shop` + `get-shop-info`". Agent 01 was therefore obliged to call `switch-shop` — the confirmed trigger of the token revocation (`03-merchant-feed-bot.md`). **The config makes this outage a scheduled event.** Agent 02 then resolved the domain by WebSearch anyway, proving the runtime call was never necessary.

**Solution, in order.** (1) Human re-authorizes Shopify — one action, unblocks three agents across both brands. (2) Complete and commit **all** BoT writes first, then attempt Pastry, so a repeat failure costs only Pastry's slice (`02-seo-audit-pastry.md`, `03-merchant-feed-bot.md`). (3) After `switch-shop`, call `get-shop-info` and **stop if it does not return the Pastry store** — do not write. (4) Once confirmed, pin `brands[pastry].domain: pastryskincare.co.za` so no future run needs the switch. **Step 4 is the fix; steps 1-3 only clear today.**

---

### P3 · [C] An unfinished Woo→Shopify migration is serving the same product at two addresses — RC-1 (impact 5 / effort 3) · SEO/dev · **needs a human**

**Problem.** Fourteen indexed `pastryskincare.co.za` URLs split across two mutually inconsistent structures — legacy `/product/…` + `/product-category/…` alongside Shopify `/products/…` + `/collections/…`. The niacinamide body lotion is indexed at **both** addresses; `/contact/` follows the WooCommerce convention while `/pages/locations` follows Shopify's (`02-seo-audit-pastry.md`).

**Root cause.** A platform migration was started and not finished, and the legacy URLs are still indexed and serving titles — which is not what a correctly-301'd URL does. **Cross-brand:** `shopbeautyontapp.co.za` is WooCommerce-shaped too (`02-seo-audit-bot.md`). This is **one half-finished migration across the estate**, not two site problems — which is why it should be scoped and budgeted once, not twice.

**Solution.** (1) Confirm which platform is authoritative — the Shopify tree looks current (optimised product titles, Shopify-convention pages) but that is inference, **verify first**. (2) Map every legacy URL to its equivalent. (3) 301 page-to-page, never blanket-to-homepage. (4) Verify the legacy URLs leave the index. The niacinamide body lotion pair is the confirmed test case (`02-seo-audit-pastry.md` T1).

**Sequencing consequence that saves real work:** agent 03's Pastry attribute writes must wait for this decision, or titles get optimised on pages scheduled for redirect (`03-merchant-feed-pastry.md`). Exception: the four *Shopify-side* collection titles in P5 are safe to ship now — they are on the surviving tree under any outcome.

---

### P4 · [H] A Pastry sale can land in five places; two are BoT-owned — RC-1 (impact 5 / effort 3) · Cross-channel · **needs a human**

**Problem.** The glycolic acid body wash alone is indexed on `pastryskincare.co.za`, takealot.com, `beautyontapp.com`, `shopbeautyontapp.co.za` and raines.africa (`02-seo-audit-pastry.md`). Simultaneously, 42.5% of BoT's Meta spend (R36,840.33/28d, 390 purchases) runs Pastry creative while this account independently spent R52,423.54/28d on the same line — **R65,976.49/28d of combined Pastry-product prospecting across two accounts** (`01-ppc-audit-bot.md`).

**Root cause.** No canonical register of which property owns the product line and which ad account funds it. Retail syndication to Takealot and Raines is normal and healthy; **two owned storefronts plus two ad accounts chasing one audience is not.**

**Consequences.** (a) No Pastry MER is computable even after Shopify returns, because "Pastry revenue" is not yet defined. (b) Two accounts bid in the same auction for the same SA beauty audience, raising both accounts' CPMs — *magnitude NOT VERIFIED* (`01-ppc-audit-bot.md`). (c) The retailer is currently better optimised for the brand's own name than the brand's own site is: `beautyontapp.com/collections/pastry-skincare` is titled "Pastry Skincare | SA Body Care for Melanin-Rich Skin" while Pastry's own listing pages read "Products – Pastry Skincare" (`02-seo-audit-pastry.md`).

**Solution.** Human decides the property map — consolidate Pastry prospecting into act 2972238613000896, or formally treat the BoT-side Pastry adsets as BoT-store traffic and stop duplicate prospecting here (`01-ppc-audit-pastry.md`, `01-ppc-audit-bot.md` Rec 1). Then define which properties count as "Pastry revenue" **before** any MER is computed. Then fix P5 so the brand outranks its own retailer for its own name.

---

### P5 · [H] Prospecting frequency is building, and the collision may be external — RC-1 (impact 4 / effort 3) · Meta · **needs a human** (creative) / **auto-appliable** (exclusions, after P4)

**Problem.** `AS1_Hyperpigmentation` runs 28d prospecting frequency **5.538** — 58% over the >3.5 flag and the highest across both brands — with one ad (`new... Pastry Premium`, R12,163.81, the largest single ad in the account) carrying it at frequency 5.464. `AS2_Body_Care_Broad` is also over at 4.321. Performance has **not** degraded: 7d ROAS 8.335x and CPA R103.42 are flat against 28d (`01-ppc-audit-pastry.md`).

**Root cause — with a cross-report twist.** Agent 01 established that the account's own overlap arithmetic is mild (1.28 / 1.56) and concluded the frequency comes from repeat exposure *inside* the adsets. That within-account exoneration makes an **external** source the leading remaining explanation: a second ad account prospecting the same audience for the same products (P4). Meta's overlap tooling is per-account, so neither audit could see across. **NOT VERIFIED** as to magnitude.

**Solution.** (1) Pre-emptive creative refresh — add 2-3 new hooks to `AS1_Hyperpigmentation` now, while performance is still strong (`01-ppc-audit-pastry.md` Rec 3). One creative carrying R12,163.81 of spend is a single point of failure regardless of the overlap question. (2) After P4, apply cross-account audience exclusions — `add_audience_exclusion` is auto-appliable under `config.yaml`, but applying it inside one account cannot fix collision originating in another, so it is sequenced, not deferred indefinitely.

---

### P6 · [H] Collection meta titles are bare defaults on the theme carrying R14,451.38/28d — RC-2/on-page (impact 4 / effort 2) · Shopify · **auto-appliable once P2 clears**

**Problem.** Four Shopify-side collection titles run the untouched `{{ collection.title }} – {{ shop.name }}` default: "Products", "body wash" (**lowercase**), "Hyperpigmentation" (one word), "Collections". Meanwhile the *product* titles on the same tree are genuinely well-built — "Niacinamide Body Lotion | Brighten & Even Body Tone" (`02-seo-audit-pastry.md`).

**Root cause.** Product titles were hand-written; collection titles were never touched. The lowercase "body wash" also exposes a **store-data defect**, not merely a template one — the collection title field itself is lowercase.

**Why it matters.** `/collections/hyperpigmentation` carries a one-word title on the playbook's #1 SA skin concern — the exact theme `AS1_Hyperpigmentation` spends R14,451.38/28d defending (`01-ppc-audit-pastry.md`).

**Solution.** Ship the four rewrites already queued verbatim in `03-merchant-feed-pastry.md`, plus the casing fix, using the brand's own existing pattern `[Concern/Category] [Qualifier] | Pastry Skincare` — do not invent a convention. `fix_meta_title` is in agent 03's allowlist. **Safe to ship ahead of the P3 redirect decision** (Shopify-side tree survives either outcome); the legacy `/product/…` titles are **not** — leave them alone.

---

### P7 · [H] Zero editorial on an uncontested vertical — RC-2/content (impact 5 / effort 3) · Content · **needs a human**

**Problem.** Three queries, including one explicitly seeking blog content, returned **no** editorial URL on `pastryskincare.co.za` — every result was a product, collection, contact or locations page (`02-seo-audit-pastry.md`). Six SA competitors hold hyperpigmentation editorial (`02-seo-audit-bot.md`). *Absence from a US-region result set is not proof no blog exists — **NOT VERIFIED** as to completeness.*

**Root cause.** No editorial programme, on the one vertical the playbook calls uncontested: SA-brand body care (glycolic acid body wash, kojic acid soap, niacinamide body lotion) where Secret Skin cannot compete.

**Solution.** Launch the cluster led by hyperpigmentation, GEO/AEO-structured (40-60 word opening answer, passage-level H2s, named statistics, FAQPage + Article schema), internal-linking into `/collections/hyperpigmentation` (`02-seo-audit-pastry.md` C1/C3). **Ruling on placement:** publish here, not on BoT. An SA-made, dermatologist-positioned brand has the strongest topical right, and duplicating the same article across two owned domains would compound P3/P4. Syndicate a distinct retailer-angle version on BoT instead. Blue-ocean terms remain **hypotheses, not verified opportunities** — `keyword_research` is unit-blocked.

---

### P8 · [H] R1,717.74 bought zero purchases because the objective could not buy purchases — RC-3/process (impact 4 / effort 1) · Meta · **needs a human (process rule)**

**Problem.** Four Instagram boost adsets, all created 16/06/2026 on a `LINK_CLICKS` objective, spent R1,717.74 for **zero** purchases (`01-ppc-audit-pastry.md`).

**Root cause.** Structural, not bad luck: a link-click objective cannot optimise for purchases. The activity log shows the source as "Boosted Instagram Media Mobile" — boosting from the app is what produces this pattern.

**Solution.** A standing rule: no in-app boosting for a sales goal. If a post deserves budget, rebuild it as `OUTCOME_SALES` inside `PASTRY_Main_Revenue` where the purchase signal and audience already work (`01-ppc-audit-pastry.md` Rec 2). **No pause action is needed or appropriate** — a human correctly stopped all four on 02/07/2026 and `effective_status` is `CAMPAIGN_PAUSED`; writing `status=PAUSED` would be a no-op with a meaningless before/after row. The recommendation is about preventing the next four.

---

### P9 · [M] R17.8k/28d rides on a catalogue nobody has measured for three runs — OB → RC-2 (impact 4 / effort 1 once P2 clears) · Shopify · **auto-appliable**

**Problem.** GTIN/MPN, `google_product_category`, `product_type`, alt text, meta descriptions and description lengths are unknown for the whole Pastry catalogue (`03-merchant-feed-pastry.md`). The entire retargeting engine is DPA/catalog-driven — `DPA_Past_Purchasers` (R6,223.61, ROAS 13.07x), `DPA_Product_Viewers` (R6,625.86, 10.12x), `DPA_Cart_Abandoners` (R4,933.68, 9.77x) — **R17.8k/28d at the account's best ROAS, riding entirely on catalog quality** (`01-ppc-audit-pastry.md`).

**Root cause.** Agent 03 is 100% Shopify-dependent with no degraded mode; P2 zeroes it. Pastry carries a second gate the BoT side does not: store reachability is unverified.

**Solution.** Clear P2, verify reachability, then run the attribute audit. **Unmeasured is not healthy** — the standing Merchant Center 'Illegal drugs'/'Misleading claims' watch items could be neither confirmed nor cleared this run (`01-ppc-audit-pastry.md`).

---

### P10 · [M] One ad is breaching a CPA ceiling on a landing-page problem, not a hook problem (impact 3 / effort 1) · Meta · **needs a human**

**Problem.** Ad `Not a single lie ad` (120239422780760393), ACTIVE: R1,161.79 for 3 purchases — CPA **R387.26** (over the R300 stop ceiling) and ROAS **1.330**, the only live entity in either account breaching a CPA ceiling. CTR 3.88% and CPC R0.98 are healthy (`01-ppc-audit-pastry.md`).

**Root cause.** The hook works and the destination does not — cheap clicks that do not buy is an offer/landing-page mismatch. It sits inside `AS2_Body_Care_Broad`, whose adset-level ROAS of 5.772x is carrying it.

**Solution.** Human call: pause it, or match the landing page to the promise. **Outside the auto-gate** — `config.yaml` allows `pause_zero_conversion_adset` only, and this is an ad with 3 conversions. Freed budget goes to `RT_Past_Purchasers` (7d ROAS 13.49x, CPA R65.14). Note this is the one place where P3 and P10 intersect: if the destination is a legacy `/product/…` URL, the fix is the 301, not the ad.

---

### P11 · [M] Google Ads 851-084-2703 produced nothing — OB (impact 5 / effort 1) · **Google-Ads recommend-only**

**Problem.** No API/MCP; `automation/inbox/` holds only `README.md`. The account was **not accessed and not modified**, and no Google Ads figure appears in any report today (`01-ppc-audit-pastry.md`, `02-seo-audit-pastry.md`).

**Root cause.** The permanent bridge was never installed; `guardrails.google_ads.search_terms_csv_url_pastry` is empty and agent 07 delivered no file.

**Solution.** Install `automation/google-ads-script/export-search-terms.js` in 851-084-2703, schedule daily, publish as CSV, paste the URL into `config.yaml` (`01-ppc-audit-pastry.md` Rec 4). Both SEO reports correctly **declined** to issue any bid-reduction CSV — with no organic ranking data, cutting paid on terms assumed to rank organically is unsafe. That refusal stands.

---

### P12 · [M] Semrush and egress remain down — OB (impact 4 / effort 1 and 3) · Ops · **needs a human**

Semrush unit-blocked: no rankings, traffic, backlinks, Authority Score, Toxicity Score, CWV. **No disavow list may be produced or acted on** — submitting one without Toxicity data would be actively dangerous. Programmatic-SEO playbooks 1/2/12 stay **deferred**: the required cannibalization check is impossible and this domain already has an active duplication problem (P3), so programmatic pages would compound it (`02-seo-audit-pastry.md`). Units: https://www.semrush.com/mcp-access. Separately, the outbound HTTPS 403 is session-wide (it blocked `example.com` too) — an environment policy question, effort 3, correctly not routed around.

---

### P13 · [L] Housekeeping (impact 2 / effort 2) · Meta + dev · **mixed**

- **9 dormant duplicate campaigns**, including three near-identical copies and a stale `main` still holding a **R1,000/day** budget (`01-ppc-audit-pastry.md`). Same "duplicate instead of edit" habit as BoT's three duplicate collection pairs (`02-seo-audit-bot.md`) — see RC-3. **Archive, never delete** (`config.yaml` `never: [delete_campaign…]`).
- **Homepage title has no spaces around its pipe** — "…South Africa|Brightening…". Theme SEO field, dev/human, not a product attribute (`02-seo-audit-pastry.md`).
- **`/collections/all` and `/collections` are both indexed** — `noindex` per standing crawl-budget guidance, but verify existing directives first (unreadable this run).
- **3-day blackout 02/07–05/07/2026** — anyone comparing this 28d window to a prior period must adjust; rate metrics are unaffected.
- **Differentiate PDP copy from reseller listings** — with the same products on Takealot, Raines and two BoT properties, the brand's own PDPs need ingredient rationale, usage protocol and FAQ blocks the resellers do not have (`02-seo-audit-pastry.md` C2). Feeds P7's schema work.

## Auto-Applied Changes

none

This agent holds no write mandate on any platform and made zero connector calls. Nothing was applied, and nothing in this report has been executed.

## Recommendations

Ranked by impact ÷ effort. Items 1-3 are the high-impact/low-effort set.

1. **⭐ [C] Re-authorize Shopify, then pin `brands[pastry].domain: pastryskincare.co.za` (P2).** Impact 5 / effort 1. Human. Re-auth alone reproduces the outage; the config pin is the actual fix, and it also removes the `switch-shop` risk permanently.
2. **⭐ [C] Read the destination URLs of the four BoT-account Pastry adsets (P1 step 1).** Impact 5 / effort 1. Meta, read-only, auto-appliable, no human. It narrows the 100x diagnosis and scopes the MER question at the same time.
3. **⭐ [M] Install the Google Ads script bridge in 851-084-2703 (P11).** Impact 5 / effort 1. Human, recommend-only channel.
4. **[C] Diagnose the 100x value defect in Events Manager; freeze value-based prospecting scaling until it closes (P1).** Impact 5 / effort 2. Human only — pixel/CAPI are forbidden to agents.
5. **[C] Decide the property map and define what counts as "Pastry revenue" (P4).** Impact 5 / effort 3. Human. Nothing about MER is computable before this.
6. **[C] Finish the migration: confirm the authoritative tree, then 301 page-to-page (P3).** Impact 5 / effort 3. Human + dev.
7. **[H] Ship the four queued collection meta titles and the lowercase casing fix (P6).** Impact 4 / effort 2. Agent 03, auto-appliable, safe ahead of the redirect decision.
8. **[H] Launch the hyperpigmentation / SA-body-care editorial cluster here, not on BoT (P7).** Impact 5 / effort 3. Content team.
9. **[H] Refresh creative in `AS1_Hyperpigmentation` pre-emptively (P5).** Impact 4 / effort 3. One ad carrying R12,163.81 at frequency 5.464 is a single point of failure.
10. **[H] Adopt a no-in-app-boosting-for-sales rule (P8).** Impact 4 / effort 1. Prevents the next R1,717.74.
11. **[M] Run the full feed audit once P2 clears and reachability is confirmed (P9).** Impact 4 / effort 1. Agent 03, auto-appliable.
12. **[M] Resolve `Not a single lie ad` — pause or fix the destination (P10).** Impact 3 / effort 1. Human.
13. **[L] Archive the 9 dormant campaigns; fix the homepage title spacing (P13).** Impact 2 / effort 2.

## Handoff

### → Agent 05 (Keywords + Negatives)

Keyword and negative work only.

- **No search-term data exists for 851-084-2703** — `automation/inbox/` holds only `README.md` (`01-ppc-audit-pastry.md`). No negative list can be built this run. Do not synthesise candidates from campaign names.
- **Do not build a paid/organic dedupe list.** Semrush is unit-blocked; no Pastry ranking can be confirmed for any term (`02-seo-audit-pastry.md`).
- **The blue-ocean terms are hypotheses, not verified opportunities** — `glycolic acid body wash south africa`, `kojic acid soap south africa`, `hyperpigmentation treatment south africa`, `pastry skincare review`. `keyword_research` is unit-blocked; treat them as such.
- **Products confirmed live on the brand domain and worth keyword coverage:** glycolic acid body wash, niacinamide body lotion (fragrance-free and grapefruit), niacinamide body butter, niacinamide body mist (`02-seo-audit-pastry.md`).
- **Review intent is real and currently captured off-domain** — "Pastry Skin Care Reviews" and "…Before and After" exist as TikTok discovery pages. Relevant to coverage planning, and a reason the protected term `review` must stay protected.
- **Standing protected terms, unchanged:** never negate face wash / face serum / face cream / review / vs.
- **Skip feed-driven keyword mapping** — no `google_product_category` or `product_type` data for a third run (`03-merchant-feed-pastry.md`).
- **No Meta negatives, placements or audience exclusions were applied by any agent today** — nothing to avoid duplicating.

### → Agent 06 (Revenue Expansion)

Budget, scaling and kill calls.

**Authorize today — one bounded step, not a programme.** A single ≤20% increase on each of the three `RT_*` adsets (R250 → R300/day): `RT_Past_Purchasers` (7d ROAS 13.49x, CPA R65.14), `RT_Product_Viewers` (10.20x, R78.80), `RT_Cart_Abandoners` (9.44x, R112.53) (`01-ppc-audit-pastry.md`).

**Both sides of that call, since a reasonable person could argue either.**
*Against:* Pastry has no store revenue and no MER for two runs, so platform ROAS is entirely uncross-checked; retargeting ROAS is also the most likely of any segment to be attribution-inflated, since it converts people who were already going to buy. Scaling retargeting first is scaling the least incremental spend in the account.
*For:* the 100x defect **does not touch these adsets** — all four retargeting entities check exact at ratio 1.00x in the same API call that exposed the defect, so their values are internally consistent. They clear the 5.0x trigger by 4-9x, sit far under the R167 CPA ceiling, are capped at R250/day, and the step is R50/day each — a bounded probe with an obvious revert.
**Ruling: authorize the single step. Re-evaluate only once MER exists — do not compound it next run.** Retargeting-pool size, not budget, is the real ceiling here (`01-ppc-audit-pastry.md`).

**Do NOT authorize today:**
- **Any value-based bid scaling on `PASTRY_Main_Revenue` or its prospecting adsets.** Scaling a campaign whose purchase values may be mis-scaled by 100x amplifies the error (P1).
- **Any budget increase on the four BoT-account Pastry adsets**, despite them holding the best 7d ROAS in either account. Before P4 is decided, scaling them either funds this account's direct auction competitor or credits BoT with Pastry revenue.
- **Any reallocation framed as "freed budget".** **R0 was freed across both brands today** — nothing was paused or trimmed (`01-ppc-audit-pastry.md`).

**Escalate-only class (over the R500/day line in `config.yaml`, yours to decide):** `AS2_Body_Care_Broad` R537.60/day, `AS1_Hyperpigmentation` R531.87/day. Both healthy.

**Cannot be decided today, and why:**
- **Pastry MER, blended or otherwise.** Needs Shopify (P2) *and* a definition of which of the five storefronts count (P4). Two independent blockers — clearing only one is not enough. **Do not infer one.**
- **Whether the 100x defect is a reporting artifact or live bid-signal corruption.** Needs Events Manager; agents are forbidden to touch pixel/CAPI. The read-only destination-URL call (P1 step 1) narrows it but does not settle it.
- **Whether the Pastry store is even reachable from this connector.** Unverified; it may be a separate Shopify org (`03-merchant-feed-pastry.md`).
- **Whether the catalogue is healthy.** Unmeasured for three runs while R17.8k/28d of the account's best-ROAS spend rides on it. Report unmeasured, never clean.
- **Whether any Pastry term is safe to reduce paid dependency on.** Needs Semrush. Keep the standing refusal to issue a bid-reduction CSV.
- **Whether the legacy `/product/…` URLs should be redirected.** Needs the P3 platform confirmation first; the Shopify tree only *looks* authoritative.

**Framing for the digest:** `03-merchant-feed-pastry.md` recommends **"instrumentation first, decisions second"** for this brand and that is the correct frame — endorsed. Lead with the connector outage and the 100x anomaly, then report the one genuine win: **the domain is resolved, `pastryskincare.co.za`**. Note the 3-day blackout (02/07–05/07) before any period-over-period comparison.
