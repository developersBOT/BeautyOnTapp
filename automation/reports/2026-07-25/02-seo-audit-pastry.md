---
agent: 02-seo-audit
brand: pastry
brand_name: Pastry Skincare
date: 2026-07-25
run_id: seo-audit-2026-07-25-a3f81c62
data_sources_used:
  - "WebSearch (Google/US index) — 8 queries run 25/07/2026. The ONLY live external data channel available this run. Used strictly for (a) resolving the brand's primary domain, (b) confirming which URLs are indexed and (c) reading SERP-displayed title tags. Not used for rankings, volumes, or traffic."
  - "Repo · automation/config.yaml (brands, guardrails, data-source health, benchmarks)"
  - "Repo · automation/agents/02-seo-audit.md (own playbook, decision logic, do-not-break rules)"
  - "Repo · automation/reports/2026-07-25/01-ppc-audit-pastry.md and 01-ppc-audit-bot.md (agent 01, same-day paid-side context)"
data_gaps:
  - "SEMRUSH — BLOCKED, NO SEO METRICS PRODUCED. site_audit, organic_research, backlinks_research and domain_overview were each called and each returned: 'active subscription, but does not have enough API units to complete this request'. Matches config.yaml data_sources.semrush.status = degraded. CONSEQUENCE: this report contains ZERO Site Health Score, ZERO ranking positions, ZERO keyword counts, ZERO organic traffic estimates, ZERO backlink/referring-domain counts, ZERO Authority Score, ZERO Toxicity Score, ZERO Core Web Vitals figures, and ZERO share-of-voice figures. None were estimated or inferred. More units: https://www.semrush.com/mcp-access"
  - "SHOPIFY — BLOCKED, TOKEN EXPIRED. get-shop-info and search_products both returned 'MCP server requires re-authorization (token expired)'; the server then disconnected. This is the SAME breakage agent 01 recorded and it has NOT been repaired. switch-shop was therefore NOT attempted this run — it is the call that revoked the token in agent 01's run, and attempting it against a dead connector could only have repeated the damage. CONSEQUENCE: no Pastry product/collection SEO attribute could be read, and it remains UNCONFIRMED whether pastryskincare.co.za is reachable from this Shopify connector at all."
  - "PASTRY DOMAIN NOW RESOLVED — but by WebSearch, not by Shopify. config.yaml sets brands[pastry].domain = 'auto' and agent 01 could not resolve it. This run resolves it to pastryskincare.co.za on the strength of 14 indexed URLs on that domain carrying Pastry Skincare product, collection and contact pages, plus the email customer@pastryskincare.co.za. This is strong evidence but is NOT a Shopify get-shop-info confirmation — the config value should be updated by a human only after the connector confirms it."
  - "DIRECT HTTP / WebFetch — BLOCKED BY EGRESS POLICY. curl and WebFetch both returned HTTP 403 from the session's agent proxy, for beautyontapp.com AND for a neutral control host (example.com), so the block is session-wide and not domain-specific. Per /root/.ccr/README.md a 403 means the host is not allowed by egress policy and must be reported, not routed around. pastryskincare.co.za was therefore never fetched. CONSEQUENCE: no raw HTML could be read, so the following could NOT be checked and are ABSENT, not passing: robots.txt contents, AI-bot access, llms.txt, sitemap.xml, canonical tags, H1 structure, meta DESCRIPTION text, Open Graph/Twitter tags, JSON-LD structured data, hreflang, redirect chains, HTTP status codes, page weight."
  - "SERP TITLES ARE INDIRECT EVIDENCE. Every title quoted below is the title Google DISPLAYED on 25/07/2026. Google rewrites titles in a minority of cases and the raw HTML could not be fetched. Treat each as 'indexed and displayed as shown' — the underlying <title> element is NOT VERIFIED. URLs observed ARE reliable evidence the page exists and is indexed."
  - "WebSearch is US-region. NOT valid evidence of South African rankings. NO ranking position, ordering or competitive placement is claimed anywhere in this report. Absence of a URL is NOT proof it does not exist."
  - "Prose summaries returned by WebSearch are that tool's paraphrase, not verbatim site copy, and are never quoted as site copy below."
  - "The WooCommerce-vs-Shopify platform split described in the top TECHNICAL finding is INFERRED FROM URL PATTERNS ONLY (/product/ + /product-category/ vs /products/ + /collections/). The underlying platforms could not be confirmed without HTTP access. The DUPLICATION itself is directly evidenced by indexed URLs; the CAUSE is inference and is tagged NOT VERIFIED."
  - "position_tracking not attempted: requires a configured Semrush project, and Semrush is unit-blocked at account level."
  - "AI-Overview / AEO visibility pass could not be completed — requires HTTP access (blocked) and SA-region SERPs (unavailable)."
  - "Google Ads (851-084-2703) overlap analysis not possible: no API/MCP, and agent 01 confirmed automation/inbox/ holds only README.md. No Google Ads figure appears in this report."
  - "MER/revenue context absent for Pastry: agent 01 could not reach the Pastry store either, so there is no store-revenue figure to weigh organic against for this brand."
---

# 02 · SEO Audit — Pastry Skincare — 2026-07-25

> ## ⛔ RUN SEVERELY DEGRADED — THREE OF FOUR DATA SOURCES DOWN
>
> | Source | Status | Effect |
> |---|---|---|
> | **Semrush** | **BLOCKED** — out of API units | No rankings, traffic, backlinks, health score, or CWV. The entire quantitative SEO layer is absent. |
> | **Shopify** | **BLOCKED** — token expired, server disconnected | No product/collection attribute audit. `switch-shop` deliberately NOT attempted (it caused this outage). |
> | **Direct HTTP / WebFetch** | **BLOCKED** — egress policy 403 (all hosts) | No robots.txt, sitemap, canonical, schema, H1, OG, or meta-description checks. |
> | **WebSearch** | ✅ working | The only live channel — and it **resolved the domain agent 01 could not**. |
>
> **No SEO metric has been invented to fill these gaps.**

Currency ZAR (R). Dates dd/mm/yyyy.

## Summary

- **✅ Pastry's primary domain is resolved: `pastryskincare.co.za`** — closing the gap agent 01 recorded as blocking (`config.yaml` still reads `domain: auto`). Resolved via 14 indexed URLs and the address `customer@pastryskincare.co.za`. **Resolved by WebSearch, not Shopify** — a human should confirm before editing config.
- **Three of four data sources are down.** No ranking, traffic, backlink, health-score or CWV figure appears in this report, and none was estimated. Pastry has now gone two consecutive runs with no store access and no MER.
- **[C] `pastryskincare.co.za` is serving two parallel URL structures on one domain** — legacy WooCommerce-shaped (`/product/…`, `/product-category/…`) alongside Shopify-shaped (`/products/…`, `/collections/…`) — with **the same product indexed at both**. This is the signature of an incomplete platform migration and is the single highest-impact finding.
- **[H] Meta titles are split clean down that same seam.** The Shopify-side product titles are genuinely good ("Niacinamide Body Lotion | Brighten & Even Body Tone"); the legacy-side titles repeat the brand up to three times, and the Shopify **collection** titles are bare defaults ("Products – Pastry Skincare", "body wash – Pastry Skincare" — lowercase).
- **[H] No editorial content found on the domain at all**, while the playbook makes SA-brand terms Pastry's uncontested priority vertical and agent 01 shows R14,451.38/28d of paid spend on `AS1_Hyperpigmentation` with no organic asset defending it.

## Findings

Severity `[C]/[H]/[M]/[L]` + (impact 1-5 / effort 1-5). Buckets per playbook decision logic.

### TECHNICAL

#### [C] Two parallel URL structures indexed on one domain — same products at two addresses (impact 5 / effort 3)

Fourteen `pastryskincare.co.za` URLs surfaced across three queries on 25/07/2026. They fall into two mutually inconsistent structures:

**Legacy / WooCommerce-shaped:**

| URL | SERP title observed |
|---|---|
| `/product/pastry-skincare-niacinamide-body-mist/` | "Pastry Skincare Niacinamide Body Mist - Pastry Skincare" |
| `/product/pastry-skincare-niacinamide-body-lotion-fragrance-free/` | "Pastry Skincare Niacinamide Body Lotion – Fragrance Free - Pastry Skincare" |
| `/product/pastry-skincare-niacinamide-body-lotion-grapefruit-fragrance/` | "Pastry Skincare Niacinamide Body Lotion – Grapefruit Fragrance - Pastry Skincare" |
| `/product-category/bodycare/body-lotion` | "Body Lotions – Pastry Skincare" |
| `/contact/` | "Contact \| Pastry Skincare" |

**Shopify-shaped:**

| URL | SERP title observed |
|---|---|
| `/products/niacinamide-body-lotion` | "Niacinamide Body Lotion \| Brighten & Even Body Tone" |
| `/products/niacinamide-body-butter` | "Niacinamide Body Butter \| Brighten & Hydrate" |
| `/products/glycolic-acid-body-wash` | "Glycolic Acid Body Wash \| Body Acne & Dark Marks – Pastry Skincare" |
| `/collections/all` | "Products – Pastry Skincare" |
| `/collections/body-wash` | "body wash – Pastry Skincare" |
| `/collections/hyperpigmentation` | "Hyperpigmentation – Pastry Skincare" |
| `/collections` | "Collections – Pastry Skincare" |
| `/pages/locations` | "Where to Buy Pastry Skincare" |

**The overlap is direct and provable.** The niacinamide body lotion is indexed at **both** `/product/pastry-skincare-niacinamide-body-lotion-fragrance-free/` and `/products/niacinamide-body-lotion`. Body-lotion category listings exist at **both** `/product-category/bodycare/body-lotion` and (by structure) the `/collections/` tree. Contact sits at the WooCommerce `/contact/` rather than Shopify's `/pages/contact`, while `/pages/locations` uses the Shopify convention — the two systems are interleaved on one hostname.

Consequences: split ranking signals between duplicate URLs, wasted crawl budget, and ambiguous canonicalisation. Whether the legacy URLs 301 correctly could **not** be tested (no HTTP access) — but they are still **indexed and serving titles**, which is not what a correctly-301'd URL does.

*The platform identification is inferred from URL patterns and is **NOT VERIFIED**. The duplication is directly evidenced by the indexed URLs above.*

#### [NOT ASSESSED] Core technical crawl layer — entirely unmeasurable this run

Absent, **not** passing: robots.txt and AI-bot access (GPTBot, ChatGPT-User, ClaudeBot, anthropic-ai, PerplexityBot, Perplexity-User, Google-Extended, CCBot) · llms.txt · sitemap.xml presence/validity · canonical tags · redirect behaviour on legacy URLs · JSON-LD schema (Product, Organization, BreadcrumbList, FAQPage) · Open Graph/Twitter tags · H1 structure · 4xx/5xx · Core Web Vitals · image weight/format.

### ON-PAGE

#### [H] Legacy-side meta titles repeat the brand up to three times and mix separators (impact 4 / effort 2)

- `/product/pastry-skincare-niacinamide-body-lotion-fragrance-free/` → **"Pastry Skincare Niacinamide Body Lotion – Fragrance Free - Pastry Skincare"** (73 chars). "Pastry Skincare" appears **twice**, and the string uses an en-dash **and** a hyphen as separators in one title.
- `/product/pastry-skincare-niacinamide-body-lotion-grapefruit-fragrance/` → **"Pastry Skincare Niacinamide Body Lotion – Grapefruit Fragrance - Pastry Skincare"** (79 chars). Same defect, past the ~60-char truncation point.
- `/product/pastry-skincare-niacinamide-body-mist/` → **"Pastry Skincare Niacinamide Body Mist - Pastry Skincare"** (55 chars). Brand twice.

None carries a benefit hook or any geo term.

#### [H] Shopify-side collection titles are bare platform defaults (impact 4 / effort 2)

| URL | SERP title | Defect |
|---|---|---|
| `/collections/all` | "Products – Pastry Skincare" | Generic; zero keyword value |
| `/collections/body-wash` | "body wash – Pastry Skincare" | **Lowercase collection name**; no geo, no hook |
| `/collections/hyperpigmentation` | "Hyperpigmentation – Pastry Skincare" | Single word; no geo, no hook — and this is the brand's #1 concern term |
| `/collections` | "Collections – Pastry Skincare" | Generic index page indexed |

All four match Shopify's untouched default `{{ collection.title }} – {{ shop.name }}`. **"body wash – Pastry Skincare" also reveals the underlying collection title itself is lowercase** — a data defect in the store, not just the template.

`/collections/hyperpigmentation` is the most costly of these: hyperpigmentation is the playbook's #1 SA skin concern and the theme agent 01 shows carrying R14,451.38/28d of paid spend, and its title is one bare word.

#### [POSITIVE] Shopify-side product titles are well-built (impact n/a / effort n/a)

Recorded so these are **not** "fixed":
- `/products/niacinamide-body-lotion` — "Niacinamide Body Lotion | Brighten & Even Body Tone" (51 chars)
- `/products/niacinamide-body-butter` — "Niacinamide Body Butter | Brighten & Hydrate" (44 chars)
- `/products/glycolic-acid-body-wash` — "Glycolic Acid Body Wash | Body Acne & Dark Marks – Pastry Skincare" (66 chars)
- `/pages/locations` — "Where to Buy Pastry Skincare"

Ingredient + benefit hook, well-sized, keyword-led. **This is the in-house pattern to extend to the collections and the legacy pages** — no new convention needed.

#### [M] Homepage title is missing spaces around its separator (impact 2 / effort 1)

`https://pastryskincare.co.za/` → **"Pastry Skincare South Africa|Brightening & Sensitive Skin Solutions"** — the pipe has no surrounding spaces ("`Africa|Brightening`"). Content and length (67 chars) are otherwise fine; this reads as a typo in the homepage SEO title field. Cheap fix, and it is the single most-seen title on the domain.

#### [M] BoT's Pastry collection title outclasses Pastry's own (impact 3 / effort 2)

`beautyontapp.com/collections/pastry-skincare` is titled **"Pastry Skincare | SA Body Care for Melanin-Rich Skin – BeautyOnTApp"** — geo-targeted, audience-specific, benefit-led. Pastry's own equivalent listing pages are titled "Products – Pastry Skincare" and "body wash – Pastry Skincare".

The retailer is currently better optimised for the brand's own name than the brand's own site is. Since agent 01 established that both properties are being fed by paid spend on the same products, this directly affects which property captures brand demand.

### CONTENT

#### [H] No editorial or blog content found anywhere on the domain (impact 4 / effort 3)

Across three queries — including one explicitly seeking "blog about" content — **every** `pastryskincare.co.za` URL returned was a product, collection, contact or locations page. No `/blogs/`, no article, no guide, no ingredient explainer surfaced.

The playbook is explicit that this is the wrong way round: *"Pastry SA-brand content (glycolic acid body wash, kojic acid soap, niacinamide body lotion) outranks K-beauty content because Secret Skin cannot compete there"* and *"Hyperpigmentation is the #1 SA skin concern — prioritise it in every relevant content and keyword recommendation."* Pastry owns an uncontested vertical and is publishing nothing into it.

Meanwhile the BoT report shows six SA skincare sites holding hyperpigmentation editorial (SKIN functional, Skin Reform, Yearn Skin, The Skin Republic, Bioderma SA, Fundamentals Skincare) — an SA-made, dermatologist-positioned brand has a natural right to that conversation and is absent from it.

*Publishing velocity is UNKNOWN and absence from a US-region result set is not proof no blog exists — but three queries returning zero editorial URLs is a meaningful signal. Tagged **NOT VERIFIED** as to completeness.*

#### [M] Same products syndicated across at least five domains, with no confirmed canonical strategy (impact 3 / effort 3)

The glycolic acid body wash is indexed on:

| Domain | URL |
|---|---|
| **pastryskincare.co.za** (brand) | `/products/glycolic-acid-body-wash` |
| takealot.com | `/glycolic-acid-body-wash-pastry-skincare/PLID96314392` |
| beautyontapp.com | `/products/pastry-skincare-glycolic-acid-body-wash-pomegranate-fragrance` |
| shopbeautyontapp.co.za | `/product/pastry-skincare-glycolic-acid-body-wash-fragrance-free/` |
| raines.africa | `/en/product/glycolic-acid-body-wash-pastry-skincare` |

Retail syndication is normal and mostly healthy (Takealot and Raines are legitimate reseller citations). Two caveats: (1) if these PDPs share manufacturer-supplied descriptions, the brand's own PDP has no differentiated content to win on; (2) two of the five are **BoT-owned** properties — see the [C] multi-domain finding in `02-seo-audit-bot.md`, where BoT itself runs three indexed storefronts.

**No claim is made about which domain ranks better in South Africa** — that requires SA-region SERP data (unavailable) and Semrush (blocked).

#### [M] `/collections/all` and `/collections` are both indexed (impact 2 / effort 2)

"Products – Pastry Skincare" (`/collections/all`) and "Collections – Pastry Skincare" (`/collections`) are both in the index. The playbook's standing technical guidance for the fleet is to `noindex` `/collections/all` and tag pages as a crawl-budget measure. Same recommendation applies here; **whether a noindex directive is already present could not be checked** without HTTP access.

### AUTHORITY

#### [M] Retail and social citations exist; the link profile itself is unmeasurable (impact 3 / effort 3)

Confirmed indexed third-party references to the brand: `takealot.com` (product listing), `raines.africa` (product listing), `facebook.com/pastryskincare`, `x.com/pastry_skincare` (an X post announcing the glycolic/lactic body wash launch), and TikTok discovery pages for "Pastry Skin Care Reviews". `beautyontapp.com/collections/pastry-skincare` is the retail partner page.

That is a reasonable baseline of commercial and social citations for a young SA brand. **But no referring-domain count, no Authority Score, no toxicity assessment and no competitor backlink gap can be produced** — all require Semrush. **No disavow list is issued and none should be acted on from this report.**

#### [NOT ASSESSED] Backlink profile, Authority Score, toxicity, disavow candidates

Semrush-dependent. Absent entirely.

## Auto-Applied Changes

**none**

This is a recommend-only agent per `automation/agents/02-seo-audit.md` ("Auto-applied actions: **None**"). No Shopify write, no theme edit, no Google Ads change, no Meta change was made or attempted.

For completeness: the Shopify connector was unreachable for the whole run, and `switch-shop` was deliberately not called — it is the call that revoked the token during agent 01's run.

| Change | Before → After | Revert |
|---|---|---|
| *(none)* | — | — |

## Recommendations

Prioritised by impact ÷ effort, split by bucket and owner. Nothing here has been executed.

### TECHNICAL

**T1. [C] Finish the platform migration — pick one URL structure and 301 the other.** Owner: **human + dev**. Impact 5 / effort 3.
Sequence: (1) confirm which platform is live and authoritative (the Shopify-shaped tree looks current — its titles are optimised and `/pages/locations` follows Shopify conventions — but this is inference, **verify first**); (2) map every legacy `/product/…` and `/product-category/…` URL to its `/products/…` or `/collections/…` equivalent; (3) 301 page-to-page, never a blanket redirect to the homepage; (4) verify the legacy URLs drop out of the index. The niacinamide body lotion pair is the confirmed test case.

**T2. [H] Update `config.yaml` with the resolved domain — after Shopify confirms it.** Owner: **human**. Impact 3 / effort 1.
`brands[pastry].domain` currently reads `auto`, and agent 01 was blocked by it. Evidence strongly supports `pastryskincare.co.za`. **Do not hard-code it from this report alone** — confirm via `get-shop-info` once the connector is restored, since it is still unknown whether that store is even reachable from this connector.

**T3. [H] Restore the two blocked connectors — now a repeat failure.** Owner: **human**. Impact 5 / effort 1.
Shopify has been down across two consecutive runs. Re-authorize in claude.ai connector settings. Semrush units: https://www.semrush.com/mcp-access. Separately, the egress-policy 403 blocks all outbound HTTP for this session including neutral hosts — an environment-level question, not a site problem.

**T4. [M] `noindex` `/collections/all` and the tag pages; confirm `/collections` should be indexed.** Owner: **dev**. Impact 2 / effort 2.
Standard crawl-budget hygiene per playbook. Verify current directives first — they could not be read this run.

### ON-PAGE

**O1. [H] Rewrite the four default collection meta titles.** Owner: **agent 03** (`fix_meta_title`, in allowlist). Impact 4 / effort 2. Concrete list in the Handoff.
Also fix the **underlying lowercase collection title** on `body-wash` (`fix_product_title`'s collection equivalent) — the SERP title exposes it as a store-data defect, not just a template one.

**O2. [M] Fix the homepage title's missing spaces.** Owner: **human/dev** (theme SEO field, not a product/collection attribute). Impact 2 / effort 1.
"Pastry Skincare South Africa|Brightening & Sensitive Skin Solutions" → `Pastry Skincare South Africa | Brightening & Sensitive Skin Solutions`.

**O3. [M] Rewrite legacy-side titles — but only if T1 keeps those URLs.** Owner: **agent 03**, blocked on T1. Impact 3 / effort 2.
If the legacy URLs are being 301'd (the likely correct outcome) **this work is unnecessary** — do not spend effort optimising titles on pages scheduled for redirect. Sequence T1 first.

### CONTENT

**C1. [H] Launch editorial on the uncontested SA-brand vertical, led by hyperpigmentation.** Owner: **content team**. Impact 5 / effort 3.
The playbook's highest-priority content bet for this brand. Start with the terms the playbook names as blue-ocean: `glycolic acid body wash south africa`, `kojic acid soap south africa`, `niacinamide body lotion`, `hyperpigmentation treatment south africa`. Use the GEO/AEO structure (40-60 word opening answer paragraph, passage-level H2s, named statistics, FAQPage + Article schema). An SA-made, dermatologist-tested brand has the strongest possible right to this topic, and six competitors are currently holding the editorial ground (list in `02-seo-audit-bot.md`).

**C2. [M] Differentiate PDP copy from reseller listings.** Owner: **content + agent 03**. Impact 3 / effort 3.
With the same products live on Takealot, Raines and two BoT properties, the brand's own PDPs need copy the resellers do not have — full ingredient rationale, usage protocol, before/after context, FAQ blocks. This also feeds C1's schema work.

**C3. [M] Add a hyperpigmentation content hub linking to `/collections/hyperpigmentation`.** Owner: **content**. Impact 3 / effort 3.
The collection exists; nothing appears to link into it editorially. Pairs directly with C1.

### AUTHORITY

**A1. [M] Backlink and disavow work — DEFERRED, do not act on this report.** Owner: **human**. Impact 4 / effort 3.
Playbook outreach targets (GLAMOUR SA, Woman & Home SA, Beauty South Africa, Professional Beauty SA) stand as standing recommendations, but **no gap analysis and no disavow list could be produced** — Semrush is down. **Submitting a disavow file without Toxicity Score data would be actively dangerous.** Defer entirely.

**A2. [M] Convert existing social and reseller citations into linked brand mentions.** Owner: **human**. Impact 3 / effort 2.
Confirmed live surfaces: Facebook, X, TikTok review discovery pages, Takealot, Raines, BoT. Ensure each points at `pastryskincare.co.za` (or the surviving canonical domain per T1) rather than at a legacy URL. Cheap, and it compounds with T1.

### GOOGLE ADS (recommend-only)

**G1. No Google Ads recommendation is issued this run** for account 851-084-2703. No organic ranking data exists to justify reducing paid dependency on any term, and `automation/inbox/` still holds only `README.md` (confirmed by agent 01). Issuing a bid-reduction CSV on unverified rankings would risk cutting paid traffic on terms where organic does not in fact rank. **Deferred until Semrush returns.** The account was **not** accessed and **not** modified; no Google Ads figure appears in this report.

## Handoff

### → Agent 03 (Merchant/Feed) — owns Shopify writes, fires 09:34 SAST

⚠️ **READ THIS BEFORE TOUCHING THE CONNECTOR.**
1. The Shopify MCP token is **expired** and the server disconnects on call. Agent 01 broke it with `switch-shop`; it was still broken through my entire run. Nothing can be written until a human re-authorizes.
2. **`switch-shop` is the specific call that caused this outage.** If the connector is restored: **complete 100% of BeautyOnTApp's writes first**, commit them, and only then attempt to reach Pastry. If the switch kills the connector again, BoT's work survives.
3. **It is unconfirmed that `pastryskincare.co.za` is reachable from this connector at all.** It may be a separate Shopify org, or mid-migration from WooCommerce (see the [C] finding). Call `get-shop-info` after switching and confirm the domain **before** writing anything — if it returns a different store, stop.

⚠️ **I could not enumerate the catalogue.** Everything below is from SERP-observed URLs — a **verified starting set, not a complete list**.

**Job 1 — collection meta titles (`fix_meta_title`). Four confirmed cases:**

| Collection | Current title (SERP-observed) | Proposed | Chars |
|---|---|---|---|
| `hyperpigmentation` | "Hyperpigmentation – Pastry Skincare" | `Hyperpigmentation Body Care South Africa \| Pastry Skincare` | 57 |
| `body-wash` | "body wash – Pastry Skincare" | `Body Wash for Body Acne & Dark Marks \| Pastry Skincare` | 53 |
| `all` | "Products – Pastry Skincare" | `All Products \| SA Body & Face Care \| Pastry Skincare` | 51 |
| `collections` (index) | "Collections – Pastry Skincare" | `Shop by Concern \| Pastry Skincare South Africa` | 46 |

**The rule:** `[Concern/Category] [Qualifier] | Pastry Skincare`, ≤60 chars, benefit or geo hook present. **This is the brand's own existing pattern** — mirror `/products/niacinamide-body-lotion` ("Niacinamide Body Lotion | Brighten & Even Body Tone"), do not invent a new convention.

**Job 2 — data defect (`fix_product_title` equivalent for collections):**
- The `body-wash` collection's **title field is lowercase** ("body wash"), exposed by its SERP title. Correct to "Body Wash". Check every other collection for the same casing defect while you are in there.

**Job 3 — do NOT rewrite these; they are already good:**
- `/products/niacinamide-body-lotion`, `/products/niacinamide-body-butter`, `/products/glycolic-acid-body-wash`, `/pages/locations`. Leave them alone.

**Job 4 — audit these yourself, I could not see them:** meta **descriptions** (all products/collections), image **alt text**, product **description word counts** (playbook: <300 words = Medium gap; collections <100 words = High), `google_product_category`, `product_type`, missing GTIN/MPN. All in your allowlist, all invisible to me.

**DO NOT do these — outside your allowlist or blocked on a decision:**
- ❌ Touching the legacy `/product/…` and `/product-category/…` URLs — they are pending a 301 decision (T1). Optimising titles on pages scheduled for redirect is wasted work.
- ❌ Any 301, canonical, redirect or noindex work — dev/human, not a Shopify attribute write.
- ❌ Editing the homepage title — theme SEO field, not a product/collection attribute.
- ❌ Any price, status or bulk change.
- ❌ Writing anything at all if `get-shop-info` does not confirm you are on the Pastry store.

### → Agent 04 (Analyst/Solutions)

- **Pastry's domain is `pastryskincare.co.za`** (WebSearch-resolved; Shopify-unconfirmed). This closes the blocker agent 01 flagged — you can now scope organic analysis to a known domain, though no organic data exists yet.
- **Still no store revenue and still no MER for Pastry** — two consecutive runs. Do not infer one.
- **New attribution complication:** the brand sells through at least five indexed storefronts — its own site, Takealot, Raines, `beautyontapp.com` and `shopbeautyontapp.co.za`. Combined with agent 01's finding that 42.5% of BoT Meta spend (R36,840.33/28d) runs Pastry creative while the Pastry account independently spent R52,423.54/28d on the same line, **a Pastry sale can land in at least two owned stores and two third-party retailers.** Establish which properties are in scope before computing any Pastry MER.
- Agent 01's 100× `omni_purchase_values` defect is unaffected by anything here — it remains the priority tracking fix.

### → Agent 05 (Keywords + Negatives)

- **No organic ranking data — do not build a paid/organic dedupe list this run.** I cannot confirm Pastry ranks page 1 for anything.
- The playbook's blue-ocean terms (`glycolic acid body wash south africa`, `kojic acid soap south africa`, `hyperpigmentation treatment south africa`, `pastry skincare review`) remain **unvalidated** — live volume/difficulty needs `keyword_research`, which is unit-blocked. Treat them as hypotheses, not verified opportunities.
- Products confirmed live on the brand domain and worth keyword coverage: glycolic acid body wash, niacinamide body lotion (fragrance-free and grapefruit), niacinamide body butter, niacinamide body mist.
- Note "Pastry Skin Care Reviews" and "Pastry Skin Care Reviews Before and After" exist as **TikTok discovery pages** — review intent is real and currently captured off-domain.
- Standing protected terms unchanged: never negate face wash / face serum / face cream / review / vs.

### → Agent 06 (Revenue Expansion)

- **Lead with the connector outage.** Three of four sources down; today's Pastry organic picture is qualitative only.
- **✅ Win to report: the Pastry domain is resolved** — `pastryskincare.co.za`, closing agent 01's blocker.
- **Escalate as top organic item: the unfinished platform migration** (duplicate legacy + Shopify URLs on one domain). It needs a human decision before content or on-page work compounds on top of it.
- **Top content bet: hyperpigmentation and SA-brand body care editorial** — the playbook's uncontested vertical, currently zero editorial found, and R14,451.38/28d of paid spend riding on the theme with no organic defence.
- **Programmatic-SEO playbooks 1/2/12 are DEFERRED** — the playbook requires a cannibalization check via position_tracking (unavailable), and this domain already has an active duplication problem. Adding programmatic pages now would compound it.
- **No disavow list, no backlink roadmap, no authority sizing** — all Semrush-dependent.

### → Dev / code-review (recommend-only, not an SEO write)

1. **Legacy-to-current 301 map** (blocked on the T1 human decision) — highest priority. Page-to-page, never blanket-to-homepage.
2. **Homepage title typo** — missing spaces around the pipe.
3. **`noindex` `/collections/all` and tag pages**; confirm `/collections` index status.
4. **Unverified this run, re-check when access returns:** `robots.txt` AI-bot access, `llms.txt`, `sitemap.xml`, canonical tags, JSON-LD schema (Product, Organization, BreadcrumbList, FAQPage), Core Web Vitals, redirect behaviour on all legacy URLs.
