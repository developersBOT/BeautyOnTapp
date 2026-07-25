---
agent: 04-analyst-solutions
brand: bot
brand_name: BeautyOnTApp
date: 2026-07-25
run_id: analyst-solutions-2026-07-25-7b4e2a1d
data_sources_used:
  - "Repo · automation/reports/2026-07-25/01-ppc-audit-bot.md (Meta act 1615943869585748, 28d + 7d)"
  - "Repo · automation/reports/2026-07-25/01-ppc-audit-pastry.md (Meta act 2972238613000896, 28d + 7d)"
  - "Repo · automation/reports/2026-07-25/02-seo-audit-bot.md (WebSearch-only, degraded)"
  - "Repo · automation/reports/2026-07-25/02-seo-audit-pastry.md (WebSearch-only, degraded)"
  - "Repo · automation/reports/2026-07-25/03-merchant-feed-bot.md (blocked run)"
  - "Repo · automation/reports/2026-07-25/03-merchant-feed-pastry.md (blocked run)"
  - "Repo · automation/config.yaml (guardrails, benchmarks, data-source health)"
data_gaps:
  - "SYNTHESIS AGENT — NO NEW DATA PULLED. Zero connector calls were made this run (no Meta, no Shopify, no Semrush, no Google Ads). Every figure below is quoted from one of the six reports above and cited to it. Nothing was re-verified against a live platform."
  - "INHERITED GAP · Shopify token expired (3rd consecutive run) — no store enumeration, no feed data, no Pastry store revenue (03-merchant-feed-bot.md; 02-seo-audit-bot.md)."
  - "INHERITED GAP · Semrush out of API units — zero rankings, traffic, backlinks, Authority Score, CWV for either brand (02-seo-audit-bot.md)."
  - "INHERITED GAP · Outbound HTTPS 403 at the session proxy for ALL hosts including example.com — no robots.txt, sitemap, canonical, schema or H1 checks (02-seo-audit-bot.md)."
  - "INHERITED GAP · No Google Ads API/MCP and automation/inbox/ holds only README.md. ZERO Google Ads figures appear anywhere in this report (01-ppc-audit-bot.md)."
  - "NOT COMPUTED · True blended MER. The 17.55x figure is Meta-only and is an UPPER BOUND (01-ppc-audit-bot.md). Google Ads spend is unknown, so no blended MER is stated or inferred here."
  - "NOT COMPUTED · BoT-store-only ROAS. Whether the four BoT-account Pastry adsets land on beautyontapp.com or on pastryskincare.co.za is UNKNOWN, so BoT's revenue denominator is undetermined. Both readings are carried explicitly below; neither is asserted."
  - "The cross-account audience-collision magnitude is NOT VERIFIED — Meta overlap tooling is per-account and neither 01 report could measure across accounts."
---

# 04 · Analyst / Solutions — BeautyOnTApp — 2026-07-25

Currency ZAR (R). Windows as reported by agent 01: **28d = 28/06/2026–25/07/2026**, **7d = 19/07/2026–25/07/2026**.
This is a synthesis run. No channel data was pulled and no account was touched.

## Summary

- **One root cause explains most of today's marketing findings: nobody has decided which property owns which product line.** It surfaces as a PPC symptom (42.5% of BoT Meta spend sells Pastry — `01-ppc-audit-bot.md`), an SEO symptom (three live indexed BoT storefronts, two with identical title tags — `02-seo-audit-bot.md`) and a feed symptom (attribute work may be wasted pending a 301 decision — `03-merchant-feed-pastry.md`). It is **one** problem, not three.
- **Measurement integrity is the second root cause, and it is downstream of the first.** BoT's headline numbers — ROAS 7.28x, Meta-only MER 17.55x (`01-ppc-audit-bot.md`) — have a numerator from one system and a denominator from a property set that has not been defined. They are not wrong; they are **undetermined**.
- **The single highest-impact/lowest-effort item in the fleet is one read-only Meta call:** the destination URLs of the four `*PastrySkincare*`/`pastry` adsets in act 1615943869585748. That one field decides whether BoT's Meta ROAS is measuring BoT's own store or another store's sales. Impact 5 / effort 1.
- **Second: the Shopify outage is self-inflicted by config, not bad luck.** `config.yaml` sets `brands[pastry].domain: auto`, which forces a runtime `switch-shop`, which is the call that revoked the token (`01-ppc-audit-bot.md`, `03-merchant-feed-bot.md`). Re-authorizing without pinning the domain will reproduce the outage on the next run. Impact 5 / effort 1.
- **BoT is not bleeding and today's outages do not change that.** No adset qualified for auto-pause or trim; every delivering adset converted (`01-ppc-audit-bot.md`). The problem is not performance — it is that the performance cannot currently be attributed to a property.

## Findings

Format: **problem → root cause → solution**. Severity `[C]/[H]/[M]/[L]`, impact 1-5 / effort 1-5, owning channel, and disposition (**auto-appliable** within `config.yaml` guardrails · **needs a human** · **Google-Ads recommend-only**).

Root-cause clusters used below: **RC-1 property & spend ownership sprawl** · **RC-2 measurement integrity** · **RC-3 duplicate-instead-of-edit process** · **OB operational blockers**.

---

### B1 · [C] BoT's ROAS and MER denominators are undefined — RC-1 (impact 5 / effort 3) · Meta + Shopify + SEO · **needs a human**

**Problem.** Three independent reports describe the same shape from three angles:
- R36,840.33 of R86,731.03 (**42.5%**) of 28d BoT Meta spend runs Pastry-branded creative across four adsets, producing 390 of the account's 798 purchases (**48.9%**), while Pastry runs its own ad account and its own store (`01-ppc-audit-bot.md`). A fifth thread — ad `mzuri scrub`, R2,588.81 — puts Mzuri Skin in the same account.
- BoT operates **at least three live indexed storefront domains** — `beautyontapp.com`, `shopbeautyontapp.co.za`, `beautyontappcos.co.za` — with the first two serving a byte-identical title tag and a duplicated product catalogue (`02-seo-audit-bot.md`).
- The same Pastry product line is indexed on **five** storefronts, two of them BoT-owned (`02-seo-audit-pastry.md`).

**Root cause.** There is no canonical register of which property sells which product line, which ad account funds it, and which analytics property records the sale. Every channel is therefore spending against an undecided property map.

**Why this is one root cause and not three.** `shopbeautyontapp.co.za` is WooCommerce-shaped (`/product/…`, `/about-beauty-on-tapp/` — `02-seo-audit-bot.md`) and `pastryskincare.co.za` is serving WooCommerce-shaped URLs alongside Shopify-shaped ones (`02-seo-audit-pastry.md`). That is **one half-finished Woo→Shopify migration spread across the estate**, not two unrelated site problems — and the Meta spend split is the same undecided ownership question expressed in budget. *Platform identification is inferred from URL patterns and is NOT VERIFIED (`02-seo-audit-pastry.md`); the duplication itself is directly evidenced by indexed URLs.*

**Consequence, stated precisely.** Two readings of BoT's account are equally consistent with today's data:
- *Reading A — the BoT-account Pastry adsets land on `beautyontapp.com`.* Then Meta's 798 purchases sit inside Shopify's 1,557 orders (51.3%) and MER 17.55x is a fair Meta-only upper bound.
- *Reading B — they land on `pastryskincare.co.za`.* Then only ~408 Meta purchases belong to BoT's store (26.2% of 1,557 orders) and BoT's reported 7.28x ROAS is partly measuring a different store's revenue.

**Neither can be ruled out today.** This is exactly why B2 exists.

**Solution.** (1) Run B2 — read the destination URLs, one read-only call. (2) Human decides: either consolidate Pastry prospecting into act 2972238613000896, or formally treat the BoT-side Pastry adsets as BoT-store traffic and stop duplicate prospecting in the Pastry account (`01-ppc-audit-bot.md` Rec 1). (3) Human decides whether the legacy domains are retained or 301'd page-to-page (`02-seo-audit-bot.md` T1). Steps 2 and 3 are the same decision asked twice.

---

### B2 · [C] The one field that resolves B1 is one read-only call away — RC-2 (impact 5 / effort 1) · Meta · **auto-appliable (read-only)** ⭐ HIGH IMPACT / LOW EFFORT

**Problem.** No report states where the four BoT-account Pastry adsets send traffic. `01-ppc-audit-bot.md` records explicitly that "no landing-page URLs were exposed by the Meta tools" — because ad-level creative destinations were not requested, not because they are unavailable.

**Root cause.** The audit pulled entity performance (`ads_get_ad_entities`) but not creative destinations (`ads_get_creatives` / `ads_get_ad_preview`). A read-only gap, not a permissions or outage gap.

**Solution.** On the next agent-01 run, read the destination/link URL for: `pastry new testing ads` (120247583433840573), `AS2_PastrySkincare - NEW testing 25 June` (120246829531210573), `AS1_PastrySkincare - mathebe's hands ad` (120243874233120573), `AS1_PastrySkincare - new` (120245178160350573), and ad `mzuri scrub` (120244697460350573). Record the host for each. This is read-only, inside guardrails, needs no human, and settles B1, B9 and half of P1 in the Pastry backlog. **Do this before any further reconciliation work.**

---

### B3 · [C] The Shopify outage is caused by config, and re-auth alone will reproduce it — OB (impact 5 / effort 1) · Ops · **needs a human** ⭐ HIGH IMPACT / LOW EFFORT

**Problem.** The Shopify token has been expired for three consecutive runs. Agent 01 lost BoT re-queries and all Pastry revenue; agent 02 lost the entire on-site audit; agent 03 could do nothing at all (`03-merchant-feed-bot.md`).

**Root cause — and this is the part no single report states.** `config.yaml` sets `brands[pastry].domain: auto`, "resolved at runtime via Shopify `switch-shop` + `get-shop-info`". Agent 01 therefore *had* to call `switch-shop`, and `switch-shop` is the confirmed trigger of the revocation (`03-merchant-feed-bot.md`). The config makes the outage a scheduled event, not an accident. Meanwhile `02-seo-audit-pastry.md` resolved the domain independently — `pastryskincare.co.za`, on 14 indexed URLs plus `customer@pastryskincare.co.za`.

**Solution, in order.** (1) Human re-authorizes the Shopify connector in claude.ai connector settings — one action, unblocks three agents across both brands. (2) On the first restored run, call `get-shop-info` **before** any write and confirm the store. (3) Pin `brands[pastry].domain: pastryskincare.co.za` in `config.yaml` **only after** `get-shop-info` confirms it (`02-seo-audit-pastry.md` T2), so no future run needs a runtime `switch-shop`. (4) Keep the BoT-first sequencing rule permanently (`03-merchant-feed-bot.md` Rec 2) — if the switch fails again, BoT's work survives. **Step 3 is the one that stops this recurring; steps 1-2 only clear today's symptom.**

---

### B4 · [H] Frequency problems in both accounts are probably one cross-account collision — RC-1 (impact 4 / effort 2) · Meta · **auto-appliable, but blocked on B1**

**Problem.** BoT: campaign `BOOST_BeautyOnTApp_Brands` runs 28d frequency **7.31** while no constituent adset exceeds 4.65, with a sum-of-adset-reach ÷ campaign-reach ratio of **2.03** (`01-ppc-audit-bot.md`). Pastry: `AS1_Hyperpigmentation` runs prospecting frequency **5.538** and `AS2_Body_Care_Broad` 4.321, yet that account's cross-adset overlap ratios are mild (1.28 / 1.56) — "the frequency is coming from repeat exposure inside the adsets, not from adsets colliding" (`01-ppc-audit-pastry.md`).

**Root cause.** Two ad accounts prospect the same SA beauty audience for the same products, spending a combined **R65,976.49/28d** on Pastry-product prospecting (`01-ppc-audit-bot.md`). Pastry's within-account arithmetic exonerates its own adsets, which makes an *external* source of repeat exposure the leading explanation. The two accounts cannot see each other: Meta's overlap tooling is per-account, so each audit could only report its half. **Magnitude NOT VERIFIED** — neither report could measure cross-account overlap, and CPM inflation was not isolated (`01-ppc-audit-bot.md`).

**Solution.** Mutual audience exclusions between `AS6_Mixed_Store`, `AS5_KoreanBrands` and the three BoT-side Pastry prospecting adsets are `add_audience_exclusion` — explicitly auto-appliable under `config.yaml`. **Do not apply them yet:** the correct exclusion set depends on B1's consolidation decision, and applying exclusions inside one account cannot fix collision that originates in another. Sequence B1 → then apply. Per `on_uncertainty: escalate`, escalated.

---

### B5 · [H] "Duplicate instead of edit" is an organisational habit, visible in three systems — RC-3 (impact 4 / effort 2) · Shopify + Meta + dev · **needs a human**

**Problem.** The same signature appears in three unrelated tools:
- Shopify: three confirmed indexed duplicate collection pairs — `/collections/best-seller` + `/best-sellers`, `/mzuri` + `/mzuri-skin`, `/cosrx` + `/cosrx-1`. The `-1` suffix is Shopify's auto-rename on a colliding handle, i.e. direct evidence a duplicate was created rather than the original edited (`02-seo-audit-bot.md`).
- Meta (Pastry account): 9 dormant duplicate campaigns including three near-identical copies, plus a stale `main` still holding a R1,000/day budget (`01-ppc-audit-pastry.md`).
- Brand estate: two Apple app listings and a Play Store package namespaced to the *legacy* domain (`02-seo-audit-bot.md`).

**Root cause.** No creation convention and no periodic dedupe sweep, in any system. `02-seo-audit-bot.md` calls the three collection pairs "a **process** problem, not three accidents" — the Meta and app-listing evidence confirms the process spans well beyond Shopify.

**Solution.** (1) Confirm the canonical member of each collection pair, 301 the loser, canonical-tag the survivor — **confirm the protected handle first**; the playbook forbids renaming the best-seller collection handle 'Skincare' (`02-seo-audit-bot.md` T2). (2) Archive (never delete — `config.yaml` `never: [delete_campaign…]`) the 9 dormant Pastry campaigns. (3) Adopt a naming/creation convention plus a monthly dedupe pass. Collection merges are **outside agent 03's allowlist** — dev/human only.

---

### B6 · [H] Product meta titles are bare Shopify defaults on exactly the terms paid is buying — RC-2/on-page (impact 4 / effort 2) · Shopify · **auto-appliable once B3 clears**

**Problem.** Six confirmed products run Shopify's untouched `{{ product.title }} – {{ shop.name }}` pattern; "COSRX", "Beauty of Joseon" and "Pastry" are absent from titles entirely, and no title carries geo (`02-seo-audit-bot.md`). Collection titles on the same store are genuinely well-built with SA geo-targeting.

**Root cause.** Collection titles were hand-optimised; product titles were never touched. The brand data exists in the store — the URL handles carry it (`cosrx-…`, `beauty-of-joseon-…`) — it simply is not reaching the title tag.

**Why it matters commercially.** `AS5_KoreanBrands` spends R14,038.52/28d on exactly these brand terms (`01-ppc-audit-bot.md`) with no organic asset carrying the brand name in its title.

**Solution.** Apply `[Brand] [Product] [Size/Variant] | BeautyOnTApp`, ≤60 chars, catalogue-wide, copying the collection pages' existing geo pattern rather than inventing one. Six concrete rewrites are already queued verbatim in `03-merchant-feed-bot.md`. `fix_meta_title` is in agent 03's allowlist — **fully auto-appliable the moment the connector returns**. This is the cheapest revenue-relevant fix in the BoT backlog.

---

### B7 · [H] Hyperpigmentation: paid carries it, organic does not exist — RC-2/content (impact 5 / effort 3) · SEO/content · **needs a human**

**Problem.** On hyperpigmentation queries BoT surfaced only with a commercial collection page while six SA competitors surfaced with editorial, the two strongest using year-stamped SA-geo URL patterns (`02-seo-audit-bot.md`). Pastry's own domain returned zero editorial URLs across three queries (`02-seo-audit-pastry.md`). Meanwhile `AS1_Hyperpigmentation` spends R14,451.38/28d on the theme (`01-ppc-audit-pastry.md`).

**Root cause.** No editorial programme on the #1 SA skin concern, on either property. The BoT blog exists but sits on Shopify's default `news` handle with low observed coverage; publishing velocity is **NOT VERIFIED** (`02-seo-audit-bot.md`).

**Solution.** Build the cluster with GEO/AEO structure (40-60 word opening answer, passage-level H2s, FAQPage + Article schema), copy the year-stamped SA-geo URL pattern, internal-link into `/collections/hyperpigmentation`. **Argue both sides on placement:** BoT is the retailer with the broader catalogue and existing blog infrastructure, but Pastry is the SA-made brand with the strongest topical right and an uncontested vertical (`02-seo-audit-pastry.md`). **Ruling: publish on Pastry, syndicate a distinct retailer-angle version on BoT.** Duplicating the same article across two owned domains would add to the duplication problem in B1/B5.

---

### B8 · [M] The catalogue has been unmeasured for three runs while R17.6k/28d rides on it — OB → RC-2 (impact 4 / effort 1 once B3 clears) · Shopify · **auto-appliable**

**Problem.** GTIN/MPN coverage, `google_product_category`, `product_type`, image alt text, meta descriptions and description word counts are unknown for the entire catalogue (`03-merchant-feed-bot.md`). Two DPA/catalog-driven retargeting adsets — `DPA_Broad_Catalog` (R9,021.45, ROAS 6.30x) and `DPA_Cart_Abandoners_7d` (R8,570.99, ROAS 7.74x) — carry ~R17.6k/28d of spend directly on catalog quality (`01-ppc-audit-bot.md`).

**Root cause.** Agent 03 is 100% Shopify-dependent with no degraded mode; the outage in B3 zeroes it.

**Solution.** Clear B3, then run the full attribute audit. **State plainly for the digest: unmeasured is not healthy** (`03-merchant-feed-bot.md`) — the absence of feed findings today is an absence of measurement, and the standing Merchant Center 'Illegal drugs'/'Misleading claims' watch items could be **neither confirmed nor cleared** (`01-ppc-audit-bot.md`).

---

### B9 · [M] Meta and Shopify disagree about the shape of the same demand — RC-2 (impact 4 / effort 2) · Analytics · **needs a human; cannot be closed today**

**Problem.** Meta claims 798 purchases and R631,486.38 against Shopify's 1,557 orders and R1,522,112.10 — 51.3% of orders but only 41.5% of revenue, implying Meta AOV R791.34 vs store AOV R977.59 (`01-ppc-audit-bot.md`).

**Root cause — undetermined, and deliberately left so.** At least three candidates are live simultaneously: (a) ordinary click/view-through attribution inflation, unquantifiable because the attribution window behind Meta's columns was not surfaced by the tool (`01-ppc-audit-bot.md`); (b) a genuine product-mix effect if the 42.5% Pastry spend sells lower-AOV body care; (c) a property mismatch if those purchases land off `beautyontapp.com` (B1 Reading B). And `02-seo-audit-bot.md` adds a fourth axis: organic/direct sessions landing on `shopbeautyontapp.co.za` or `beautyontappcos.co.za` sit **outside** the Shopify property whose revenue was used as the denominator.

**Solution.** Do not attempt reconciliation until B2 and B3 are done. Then: confirm which domains feed which analytics property, then reconcile Meta purchases against Shopify orders for the same window. **Per instruction, no missing metric is reconstructed here — the correct output today is that this cannot be decided.**

---

### B10 · [M] Google Ads has produced zero data for the fleet — OB (impact 5 / effort 1) · **Google-Ads recommend-only**

**Problem.** No Google Ads API or MCP exists in this environment and `automation/inbox/` holds only `README.md`. Account 820-452-9325 was **not accessed and not modified**, and no Google Ads figure appears in any of today's six reports (`01-ppc-audit-bot.md`, `02-seo-audit-bot.md`).

**Root cause.** The permanent bridge was never installed. `config.yaml` provides `guardrails.google_ads.search_terms_csv_url_bot`, currently empty, and `automation/google-ads-script/export-search-terms.js` exists but is not deployed. Agent 07 is designed to run locally at 07:30 SAST and push exports into `inbox/`; no such file arrived today.

**Solution.** Install the script in 820-452-9325, schedule it daily, publish the Sheet as CSV, paste the URL into `config.yaml` (Option B, `01-ppc-audit-bot.md` Rec 3). The one-off CSV (Option A) closes today only; the bridge closes it permanently and also fixes whatever stopped agent 07. Note both `02-*` reports correctly **declined** to issue any bid-reduction CSV — with no organic ranking data, cutting paid on terms assumed to rank organically is unsafe. That refusal is right and should stand.

---

### B11 · [M] Two Meta watch items that are neither bleeders nor scaling candidates (impact 3 / effort 1) · Meta · **needs a human**

- `AS5_KoreanBrands`: R14,038.52/28d, ROAS 3.986, CPA R171.20 — under the 5.0x scaling trigger and marginally over the R167 ceiling, but improving (7d 4.753x / R130.38) and not a bleeder on any `config.yaml` test (`01-ppc-audit-bot.md`). **Ruling: no new budget, no trim. It is the last-place candidate for any reallocation, not a source of it.**
- `AS1_Visitors_7d_NoPurchase`: 28d ROAS 1.766 (below the 1.82x floor) and CPA R344.98 (over R300), but 7d ROAS 2.68 / CPA R238.06 and human-restarted 16/07/2026 (`01-ppc-audit-bot.md`). **Ruling: review at ~30/07/2026; trim the R300/day only if 7d ROAS has not held ≥1.82x.** This is recovery-tracking on a converting adset, not "give it more time" applied to zero-conversion spend — which does not occur anywhere in this account.

---

### B12 · [M] Two more operational blockers, both outside the marketing stack — OB (impact 4 / effort 1 and 3) · Ops · **needs a human**

- **Semrush out of API units.** Zero rankings, traffic, backlinks, Authority Score, Toxicity Score or CWV for either brand (`02-seo-audit-bot.md`). Consequences that must not be quietly dropped: no disavow list may be produced or acted on (submitting one without Toxicity data would be actively dangerous), programmatic-SEO playbooks 1/2/12 stay **deferred** because the required cannibalization check is impossible, and the playbook's 83%-brand-search baseline is a **stale skill estimate, not this month's data**. Effort 1: https://www.semrush.com/mcp-access
- **Outbound HTTPS 403 at the session proxy, for all hosts including `example.com`** (`02-seo-audit-bot.md`). This is an environment egress policy, not a site problem, and it was correctly not routed around. It blocks robots.txt/AI-bot access, `llms.txt`, sitemap, canonicals, schema, H1, OG and CWV checks indefinitely. Effort 3 — needs a policy review, not a click.

---

### B13 · [L] Cheap consistency items, none blocking (impact 2 / effort 1) · Shopify + dev · **mixed**

- **Store count 6 vs 7.** `/pages/locations` is titled "7 SA Locations"; the playbook constant says 6 (`02-seo-audit-bot.md`). Human call — it drives LocalBusiness schema, GBP count and NAP consistency. Explicitly **not** agent 03's to change.
- **Product count 1,400+ vs "over 1500"** — the latter is a WebSearch paraphrase, **NOT VERIFIED**; neither figure is confirmed (`02-seo-audit-bot.md`).
- **`/collections/make-up` title** is 78 chars and names the brand twice, reintroducing the legacy "Beauty on TApp" spelling — `fix_meta_title`, **auto-appliable**, already queued in `03-merchant-feed-bot.md`.
- **Title separators inconsistent site-wide** — bundle into B6.
- **`RTG_Website_Visitors` has no campaign-level budget cap**; control sits at adset level, R1,000/day total against ~R751/day actual (`01-ppc-audit-bot.md`). Observation, not a defect.
- **`/collections/south-african-brands` did not surface** — absence from a US-region result set is **not** proof it is missing. Verify manually; never create it at the forbidden `/south-african-skincare` path (`02-seo-audit-bot.md`).

## Auto-Applied Changes

none

This agent holds no write mandate on any platform and made zero connector calls. Nothing was applied, and nothing in this report has been executed.

## Recommendations

Ranked by impact ÷ effort. Items 1-3 are the high-impact/low-effort set and should all be done before anything else in this list.

1. **⭐ [C] Read the destination URLs of the five BoT-account Pastry/Mzuri entities (B2).** Impact 5 / effort 1. Meta, read-only, auto-appliable, no human needed. It resolves the largest ambiguity in the fleet and unblocks B1, B9 and the Pastry 100× diagnosis.
2. **⭐ [C] Re-authorize Shopify, then pin `brands[pastry].domain` in config (B3).** Impact 5 / effort 1. Human. Re-auth alone will reproduce the outage — the config pin is the actual fix.
3. **⭐ [M] Install the Google Ads script bridge in 820-452-9325 (B10).** Impact 5 / effort 1. Human, recommend-only channel. Closes a gap that has now blocked agents 01, 02 and 05 simultaneously.
4. **[C] Decide the property map, then execute it (B1).** Impact 5 / effort 3. Human. One decision answers both the Meta consolidation question and the domain 301 question.
5. **[H] Ship the queued product meta titles catalogue-wide (B6 + B13).** Impact 4 / effort 2. Agent 03, auto-appliable, already written and waiting.
6. **[H] Build the hyperpigmentation cluster on Pastry, syndicate to BoT (B7).** Impact 5 / effort 3. Content team.
7. **[H] Apply cross-adset audience exclusions — after B1, not before (B4).** Impact 4 / effort 2. Meta, auto-appliable once the decision exists.
8. **[H] Fix the duplicate-creation process, then dedupe (B5).** Impact 4 / effort 2. Human + dev, protected handle confirmed first.
9. **[M] Run the full feed audit the moment Shopify returns (B8).** Impact 4 / effort 1. Agent 03, auto-appliable.
10. **[M] Restore Semrush units; escalate the egress-403 policy separately (B12).** Impact 4 / effort 1 and 3. Human.
11. **[L] Resolve store count, product count and separators (B13).** Impact 2 / effort 1. Human, then agent 03.

## Handoff

### → Agent 05 (Keywords + Negatives)

Keyword and negative work only. Everything budget-related is in the agent 06 block.

- **You have no search-term data for 820-452-9325 and cannot build a negative list this run.** `automation/inbox/` holds only `README.md` (`01-ppc-audit-bot.md`). Do not synthesise candidates from campaign names or from memory.
- **Do not build a paid/organic dedupe list.** Semrush is unit-blocked, so no BoT ranking can be confirmed for any term; a negative or bid cut justified by "organic already covers it" would be unfounded (`02-seo-audit-bot.md`).
- **Carry the durable rules forward, unchanged, ready to package the moment a CSV lands:** `medicube` negated everywhere except `Shopping_All_Products_v2`; `beautytap` phrase-match; **never negate** face wash / face serum / face cream / review / vs (`01-ppc-audit-bot.md`).
- **Themes where paid carries the load and organic is thin** — use for coverage planning, not for negation: Korean/K-beauty brand terms (`AS5_KoreanBrands`, R14,038.52/28d), mixed local-brand terms (`AS6_Mixed_Store`, R14,179.55/28d), hyperpigmentation (`AS1_Hyperpigmentation`, R14,451.38/28d, Pastry account).
- **Skip feed-driven keyword mapping entirely** — no `google_product_category` or `product_type` data exists for a third run (`03-merchant-feed-bot.md`).
- **No Meta negatives, placement exclusions or audience exclusions were applied by any agent today**, so there is nothing to avoid duplicating (`01-ppc-audit-bot.md`).

### → Agent 06 (Revenue Expansion)

Budget, scaling and kill calls.

**Authorize today:**
- **Modest budget increases on BoT non-Pastry adsets only.** The efficiency case survives both readings of B1: strip out all R36,840.33 of Pastry spend and all 390 of its purchases and the residual BoT-account spend is R49,890.70 for 408 purchases — **CPA R122.28, still inside the R167 excellent ceiling** (derived from `01-ppc-audit-bot.md` figures; arithmetic only, no new data). Best candidates by 7d ROAS: `AS6_Mixed_Store` 8.75x / CPA R83.23, `AS_Cart_Abandoners_7d` 6.62x / R138.24, `AS2_Visitors_8_30d_NoPurchase` 5.89x / R149.01. Cap each step at the `config.yaml` 20% limit.
- **Escalate B2 and B3 as the day's top two actions** — both impact 5 / effort 1.

**Do NOT authorize today:**
- **Any budget increase on the four BoT-account Pastry adsets**, despite them holding the account's best 7d ROAS (`pastry new testing ads` 12.41x). Scaling them before B1 either scales a second ad account's direct auction competitor or credits BoT with another store's revenue — and we cannot currently tell which. Their strength is exactly why the decision matters.
- **Any reallocation framed as "freed budget".** **R0 was freed across both brands today** — nothing was paused or trimmed anywhere (`01-ppc-audit-bot.md`, `01-ppc-audit-pastry.md`). Every increase must come from new budget.
- **Double-counting the 16/07/2026 human increase** on `BOOST_BeautyOnTApp_Brands` (R2,550 → R3,060/day, +20%) as untapped headroom (`01-ppc-audit-bot.md`).

**Escalate-only class (never auto-actioned, yours to decide):** `AS5_KoreanBrands` R596.04/day, `AS6_Mixed_Store` R535.06/day, `pastry new testing ads` R525.02/day — all over the R500/day line in `config.yaml`.

**Cannot be decided today, and why:**
- **Whether BoT's Meta ROAS measures BoT's own store.** Needs B2 (destination URLs). Until then 7.28x is undetermined, not wrong.
- **True blended MER, either brand.** Needs Google Ads spend (B10). 17.55x is a Meta-only **upper bound** and must be labelled as such in the digest (`01-ppc-audit-bot.md`).
- **Whether the Meta/Shopify order-vs-revenue gap is attribution, product mix or property mismatch.** Needs B2 + B3 (B9). Do not pick one.
- **Whether the catalogue is healthy.** Unmeasured for three runs — report it as unmeasured, never as clean (`03-merchant-feed-bot.md`).
- **Whether any BoT term is safe to reduce paid dependency on.** Needs Semrush. Both SEO reports correctly issued **no** Google Ads recommendation; keep it that way.
- **Whether the legacy domains should be redirected.** A business decision, explicitly **NOT VERIFIED** as legacy (`02-seo-audit-bot.md`). Redirecting a deliberately separate domain destroys a live channel.

**Framing for the digest:** lead with the connector outage and the property-map decision, not with SEO wins (`02-seo-audit-bot.md`). Add `k-beautyhouse.co.za` to the tracked competitor set. Programmatic-SEO playbooks 1/2/12 stay **deferred** — launching programmatic pages onto three confirmed duplicate collection pairs would worsen a live duplication problem.
