---
agent: 02-seo-audit
brand: bot
brand_name: BeautyOnTApp
date: 2026-07-25
run_id: seo-audit-2026-07-25-a3f81c62
data_sources_used:
  - "WebSearch (Google/US index) — 8 queries run 25/07/2026. The ONLY live external data channel available this run. Used strictly for (a) confirming which URLs are indexed and (b) reading SERP-displayed title tags. Not used for rankings, volumes, or traffic."
  - "Repo · automation/config.yaml (brands, guardrails, data-source health, benchmarks)"
  - "Repo · automation/agents/02-seo-audit.md (own playbook, decision logic, do-not-break rules)"
  - "Repo · automation/reports/2026-07-25/01-ppc-audit-bot.md and 01-ppc-audit-pastry.md (agent 01, same-day paid-side context)"
data_gaps:
  - "SEMRUSH — BLOCKED, NO SEO METRICS PRODUCED. site_audit, organic_research, backlinks_research and domain_overview were each called and each returned: 'active subscription, but does not have enough API units to complete this request'. Matches config.yaml data_sources.semrush.status = degraded. CONSEQUENCE: this report contains ZERO Site Health Score, ZERO ranking positions, ZERO keyword counts, ZERO organic traffic estimates, ZERO backlink/referring-domain counts, ZERO Authority Score, ZERO Toxicity Score, ZERO Core Web Vitals figures, and ZERO share-of-voice figures. None were estimated or inferred. More units: https://www.semrush.com/mcp-access"
  - "SHOPIFY — BLOCKED, TOKEN EXPIRED. get-shop-info and search_products both returned 'MCP server requires re-authorization (token expired)'; the server then disconnected. This is the SAME breakage agent 01 recorded (its switch-shop call revoked the token) and it has NOT been repaired since. CONSEQUENCE: the entire planned Shopify on-site SEO audit could not run — no product/collection meta titles or descriptions, no image alt text, no body word counts, no google_product_category/product_type, no handles, and no product IDs were read. The agent-03 handoff below is therefore built from SERP-observed URLs only, not from a store enumeration. Re-authorize via claude.ai connector settings."
  - "DIRECT HTTP / WebFetch — BLOCKED BY EGRESS POLICY. curl and WebFetch both returned HTTP 403 from the session's agent proxy, for beautyontapp.com AND for a neutral control host (example.com). Per /root/.ccr/README.md a 403 means 'the destination host is not allowed by your organization's egress policy for this session. Do not retry or route around it.' This was not retried or circumvented. CONSEQUENCE: no raw HTML could be read, so the following planned live-site checks could NOT be performed and are ABSENT from this report, not passed: robots.txt contents, AI-bot access (GPTBot/ClaudeBot/PerplexityBot/Google-Extended/CCBot), llms.txt presence, sitemap.xml presence and validity, canonical tags, H1 structure, meta DESCRIPTION text, Open Graph/Twitter card tags, JSON-LD structured data (Product/Organization/FAQPage/BreadcrumbList), hreflang, redirect chains, 4xx/5xx status codes, page weight and render-blocking resources."
  - "SERP TITLES ARE INDIRECT EVIDENCE. Every title quoted below is the title Google DISPLAYED in results on 25/07/2026. Google rewrites titles in an estimated minority of cases, and the underlying HTML could not be fetched to confirm. Treat each quoted title as 'indexed and displayed as shown' — the raw <title> element is NOT VERIFIED. URLs observed in results ARE reliable evidence that the page exists and is indexed."
  - "WebSearch is US-region. It is therefore NOT valid evidence of South African SERP rankings. NO ranking position, ordering, or competitive placement is claimed anywhere in this report. Absence of a URL from these results is likewise NOT proof the page does not exist."
  - "Prose summaries returned by WebSearch are that tool's own paraphrase, not verbatim site copy. They are used below ONLY to flag two factual inconsistencies for human confirmation (store count, product count), each tagged NOT VERIFIED. No site copy is quoted from them."
  - "position_tracking was not attempted: it requires a configured Semrush project, and Semrush is unit-blocked at the account level, so the call could not have succeeded. Movement data is absent, not estimated."
  - "AI-Overview / AEO visibility pass could not be completed. Whether beautyontapp.com is cited in AI Overviews on priority non-brand queries is UNKNOWN — the robots.txt AI-bot check requires HTTP access (blocked) and AIO presence requires SA-region SERPs (unavailable)."
  - "Google Ads overlap analysis not possible: agent 01 confirmed automation/inbox/ still holds only README.md, and no Google Ads API/MCP exists. No Google Ads figure appears in this report."
---

# 02 · SEO Audit — BeautyOnTApp — 2026-07-25

> ## ⛔ RUN SEVERELY DEGRADED — THREE OF FOUR DATA SOURCES DOWN
>
> | Source | Status | Effect |
> |---|---|---|
> | **Semrush** | **BLOCKED** — out of API units | No rankings, traffic, backlinks, health score, or CWV. The entire quantitative SEO layer is absent. |
> | **Shopify** | **BLOCKED** — token expired, server disconnected | The whole on-site product/collection SEO audit could not run. |
> | **Direct HTTP / WebFetch** | **BLOCKED** — egress policy 403 (all hosts) | No robots.txt, sitemap, canonical, schema, H1, OG, or meta-description checks. |
> | **WebSearch** | ✅ working | The only live channel. Yielded indexed-URL and SERP-title evidence — the basis of everything below. |
>
> **No SEO metric has been invented to fill these gaps.** Where a number would normally appear, the section says so explicitly.

Currency ZAR (R). Dates dd/mm/yyyy. Domain audited: **beautyontapp.com** (verified in `config.yaml`; independently corroborated as indexed this run).

## Summary

- **Three of four data sources are down** (Semrush units, Shopify token, HTTP egress). No ranking, traffic, backlink, health-score or Core-Web-Vitals figure appears anywhere in this report, and none was estimated. The Shopify token has now been broken across two consecutive agent runs.
- **[C] BeautyOnTApp is running at least three separate live, indexed storefront domains** — `beautyontapp.com`, `shopbeautyontapp.co.za` and `beautyontappcos.co.za` — and the first two serve the **byte-identical title tag** "BeautyOnTApp | South Africa's Online Beauty & Skincare Store". This is the single highest-impact finding of the run and it competes with, dilutes and cannibalises the primary domain.
- **[H] Duplicate collection pages are a systemic pattern, not a one-off** — three confirmed indexed pairs: `/collections/best-seller` + `/collections/best-sellers`, `/collections/mzuri` + `/collections/mzuri-skin`, `/collections/cosrx` + `/collections/cosrx-1`. The `-1` suffix is Shopify's auto-rename on a duplicate handle.
- **[H] The on-page gap is precisely product-level.** Collection meta titles are genuinely well-optimised with SA geo-targeting ("Korean Skincare South Africa | COSRX, ANUA & More | BeautyOnTApp"), but **product** titles run Shopify's bare default — "Advanced Snail Mucin Power Essence – BeautyOnTApp" carries neither the brand "COSRX" nor "South Africa". This is the highest-impact fix that is cleanly in agent 03's remit.
- **[H] Hyperpigmentation — the #1 SA skin concern per playbook — has no BoT editorial coverage.** A blog exists at `/blogs/news/`, but on hyperpigmentation queries only a *collection* page surfaced while six other SA skincare sites surfaced with editorial. Paid is carrying this theme hard on the Pastry side (agent 01: `AS1_Hyperpigmentation`, R14,451.38/28d) with no organic asset defending it.

## Findings

Severity `[C]/[H]/[M]/[L]` + (impact 1-5 / effort 1-5). Evidence is cited per finding. Buckets per playbook decision logic.

### TECHNICAL

#### [C] Three live indexed BeautyOnTApp storefront domains, two sharing an identical title tag (impact 5 / effort 4)

Evidence — all four URLs returned as indexed results, WebSearch 25/07/2026:

| Domain | SERP title observed | Platform shape (inferred from URL pattern) |
|---|---|---|
| `https://beautyontapp.com/` | "BeautyOnTApp \| South Africa's Online Beauty & Skincare Store" | Shopify (`/collections/`, `/products/`, `/pages/`, `/blogs/news/`) |
| `https://www.shopbeautyontapp.co.za/` | "BeautyOnTApp \| South Africa's Online Beauty & Skincare Store" | WooCommerce (`/product/…`, `/about-beauty-on-tapp/`) |
| `https://shopbeautyontapp.co.za/about-beauty-on-tapp/` | "About Beauty on TApp – Beauty on TApp" | WooCommerce |
| `https://beautyontappcos.co.za/` | "BeautyOnTApp" | not determinable |

`beautyontapp.com` is the domain `config.yaml` verifies and the one agent 01 confirmed against Shopify (`i0ma19-q8.myshopify.com`). The other two are live and indexed regardless.

Three compounding problems:
1. **Identical title tags on two live domains.** `beautyontapp.com/` and `www.shopbeautyontapp.co.za/` present the same title string to the index. For brand queries the two domains compete with each other.
2. **A full duplicate product catalogue.** `https://shopbeautyontapp.co.za/product/pastry-skincare-glycolic-acid-body-wash-fragrance-free/` and `https://beautyontapp.com/products/pastry-skincare-glycolic-acid-body-wash-pomegranate-fragrance` are the same product line on two owned domains.
3. **Split brand naming.** "BeautyOnTApp" (Shopify) vs "Beauty on TApp" (WooCommerce) fragments brand-entity signals.

*Whether the legacy domains should 301 to `beautyontapp.com`, or are deliberately retained, is a business decision — NOT VERIFIED and explicitly not assumed here.* The SEO consequence of leaving three indexed storefronts live is not in doubt.

#### [H] Systemic duplicate collection handles — three confirmed indexed pairs (impact 4 / effort 2)

All six URLs returned as separate indexed results with distinct titles, WebSearch 25/07/2026:

| Pair | URL A (SERP title) | URL B (SERP title) |
|---|---|---|
| Best sellers | `/collections/best-seller` — "Skincare \| Korean & Local Products – BeautyOnTApp" | `/collections/best-sellers` — "Best Sellers \| Top-Rated Skincare in South Africa – BeautyOnTApp" |
| Mzuri | `/collections/mzuri` — "Mzuri Skin South Africa \| Luxury Skincare – BeautyOnTApp" | `/collections/mzuri-skin` — "Mzuri Skin \| Brightening Skincare for Melanin-Rich Skin – BeautyOnTApp" |
| COSRX | `/collections/cosrx` — "COSRX SA \| Korean Skincare Essentials – BeautyOnTApp" | `/collections/cosrx-1` — "Official COSRX Stockist South Africa \| Buy Snail Mucin Online – BeautyOnTApp" |

The `cosrx-1` handle is Shopify's automatic suffix when a handle already exists — direct evidence a duplicate collection was created rather than the existing one edited. Three independent pairs makes this a **process** problem, not three accidents.

Note also `/collections/best-seller` is titled "Skincare | …" while `/collections/skincare` separately exists and is titled "Skincare South Africa | Best Skin Products Online | BeautyOnTApp" — a fourth possible overlap.

⚠️ **Do-not-break constraint (playbook):** *"never rename the best-seller collection handle 'Skincare'"* and *"SA-brand collection lives at /collections/south-african-brands (never /south-african-skincare)"*. Any dedupe must confirm with a human which handle is protected **before** touching either. Deduping collections is **not** in agent 03's allowlist (no merge, no unpublish, no bulk status change) — it is a dev/human action.

#### [NOT ASSESSED] Core technical crawl layer — entirely unmeasurable this run

The following were on the plan and could **not** be checked, because both Semrush and HTTP access are blocked. They are absent, **not** passing: robots.txt contents and AI-bot access (GPTBot, ChatGPT-User, ClaudeBot, anthropic-ai, PerplexityBot, Perplexity-User, Google-Extended, CCBot) · llms.txt presence · sitemap.xml presence/validity · canonical tags · duplicate product URLs via `within: current_collection` (playbook "Fix #1", the highest-impact known technical fix — **status unknown this run**) · faceted-nav crawl budget · JSON-LD schema (Product, Organization, LocalBusiness ×6, BreadcrumbList, FAQPage) · Open Graph/Twitter tags · H1 structure · 4xx/5xx · redirect chains · Core Web Vitals · image weight/format.

### ON-PAGE

#### [H] Product meta titles run Shopify's bare default — brand and geo both missing (impact 4 / effort 2)

Six product URLs with SERP titles observed, WebSearch 25/07/2026:

| Product URL | SERP title observed | Defect |
|---|---|---|
| `/products/cosrx-advanced-snail-mucin-power-essence-100ml` | "Advanced Snail Mucin Power Essence – BeautyOnTApp" | **"COSRX" absent entirely**; no geo |
| `/products/cosrx-advanced-snail-mucin-gel-cleanser-150ml` | "Advanced Snail Mucin Gel Cleanser – BeautyOnTApp" | **"COSRX" absent entirely**; no geo |
| `/products/cosrx-mucin-essence-cream` | "Cosrx - Mucin Essence + Cream – BeautyOnTApp" | "Cosrx" mis-cased; no geo |
| `/products/cosrx-all-about-snail-kit` | "COSRX All About Snail Kit - BeautyOnTApp" | hyphen separator, inconsistent with the en-dash used site-wide; no geo |
| `/products/beauty-of-joseon-revive-ginseng-snail-mucin-serum` | "Revive Ginseng & Snail Mucin Serum – BeautyOnTApp" | **"Beauty of Joseon" absent entirely**; no geo |
| `/products/pastry-skincare-glycolic-acid-body-wash-pomegranate-fragrance` | "Glycolic Acid Body Wash – BeautyOnTApp" | **"Pastry" absent entirely**; no geo |

Every one matches Shopify's untouched default pattern `{{ product.title }} – {{ shop.name }}`. The URL handles *do* carry the brand (`cosrx-…`, `beauty-of-joseon-…`, `pastry-skincare-…`) while the titles do not — so the data exists in the store and simply is not reaching the title tag.

This is the sharpest contrast in the audit: **collection** titles are well-built (next finding), **product** titles are untouched defaults. Agent 01 confirms K-beauty brand terms carry real paid money — `AS5_KoreanBrands` R14,038.52/28d — so these are exactly the terms where organic should be reducing paid dependency.

#### [POSITIVE] Collection meta titles are well-optimised with SA geo-targeting (impact n/a / effort n/a)

Recorded because it is genuinely good and should not be "fixed". SERP titles observed, WebSearch 25/07/2026:

- `/collections/korean-skincare` — "Korean Skincare South Africa | COSRX, ANUA & More | BeautyOnTApp"
- `/collections/skincare` — "Skincare South Africa | Best Skin Products Online | BeautyOnTApp"
- `/collections/hyperpigmentation` — "Hyperpigmentation Serum & Dark Spot Corrector SA | BeautyOnTApp"
- `/collections/anua` — "ANUA Skincare SA | Heartleaf K-Beauty – BeautyOnTApp"
- `/collections/pastry-skincare` — "Pastry Skincare | SA Body Care for Melanin-Rich Skin – BeautyOnTApp"
- `/collections/mzuri-skin` — "Mzuri Skin | Brightening Skincare for Melanin-Rich Skin – BeautyOnTApp"
- `/collections/standard-beauty` — "STANDARD. Beauty Products South Africa – BeautyOnTApp"
- `/collections/cosrx-1` — "Official COSRX Stockist South Africa | Buy Snail Mucin Online – BeautyOnTApp"

These already approximate the playbook's geo formula. **The product-title fix should copy this pattern, not invent a new one.**

#### [M] `/collections/make-up` title is ~78 characters and names the brand twice (impact 2 / effort 1)

SERP title observed: "Makeup | Beauty on TApp South Africa | Korean & Local Cosmetics – BeautyOnTApp" — 78 characters, past the ~60-character point where Google truncates, and it carries **both** "Beauty on TApp" and "BeautyOnTApp". It also reintroduces the spaced "Beauty on TApp" spelling used by the legacy WooCommerce domain, which works against the entity-consolidation issue in the [C] finding.

#### [M] Store count conflicts between the site and the playbook constant — 7 vs 6 (impact 3 / effort 1)

`https://beautyontapp.com/pages/locations` returned with SERP title **"Our Stores – Find BeautyOnTApp Near You | 7 SA Locations"**.

This conflicts with two other sources: the playbook's do-not-break brand facts state **"6 stores"**, and its GBP task enumerates exactly six (Gateway Umhlanga, Fourways, Mall of Africa, Menlyn Park, Sandton City, Canal Walk). A WebSearch prose summary also enumerated six named malls, and the Pastry-side summary referred to six — *both paraphrases, NOT VERIFIED*.

Only the **page title "7 SA Locations" is directly evidenced.** Which figure is correct is a factual question for a human, and it matters beyond SEO: store count drives LocalBusiness schema, GBP count, and NAP consistency. **No assumption is made here about which is right.**

#### [L] Title separator is inconsistent site-wide (impact 1 / effort 1)

En-dash "–" on most pages, pipe "|" on others, hyphen "-" on `/products/cosrx-all-about-snail-kit` ("COSRX All About Snail Kit - BeautyOnTApp"). Cosmetic and cheap to normalise alongside the product-title work.

### CONTENT

#### [H] Hyperpigmentation — the #1 SA skin concern — has no BoT editorial asset (impact 5 / effort 3)

On the hyperpigmentation query run 25/07/2026, BoT surfaced **only** with a commercial collection page (`/collections/hyperpigmentation`). Six other SA skincare sites surfaced with *editorial* content:

| Site | Editorial URL observed |
|---|---|
| SKIN functional | `skinfunctional.com/blogs/hyperpigmentation/hyperpigmentation-treatment-serum-south-africa-2026` |
| Skin Reform | `skinreform.co.za/pages/how-to-treat-hyperpigmentation-in-south-africa-2025-guide` |
| Yearn Skin | `yearnskin.co.za/blogs/the-skin-journal/the-dark-mark-dilemma-why-south-african-women-need-skincare-that-speaks-to-their-skin-tone` |
| The Skin Republic | `theskinrepublic.co.za/collections/skin-care-to-combat-pigmentation` |
| Bioderma SA | `bioderma.co.za/your-skin/dark-spots-skin/pigmentation-101-top-tips-to-tackle-dark-spots` |
| Fundamentals Skincare | `fundamentals-skincare.co.za/blog-news/skinclass-how-to-treat-hypigmentation/` |

Note the top two have **year-stamped, SA-geo-targeted URLs** ("…south-africa-2026", "…south-africa-2025-guide") — a deliberate, repeatable pattern BoT is not running.

This is the playbook's category-capture gap, now with named evidence. It is also where paid money is going: agent 01 shows `AS1_Hyperpigmentation` at R14,451.38/28d in the Pastry account with, as far as this run can tell, no organic editorial asset defending the theme.

*No claim is made about SA ranking order — this is a US-region result set. The finding is the **absence of a BoT editorial URL** from a result set containing six competitor editorial URLs.*

#### [M] Blog is live but on the default handle, with low observed coverage (impact 3 / effort 3)

Two posts confirmed indexed, WebSearch 25/07/2026:
- `/blogs/news/affordable-skincare-for-african-skin-brands-designed-for-real-results` — "Affordable Skincare for African Skin: Brands Designed for Real Results – BeautyOnTApp"
- `/blogs/news/why-k-beauty-korean-skincare-are-totally-worth-the-hype` — "Why K-Beauty + Korean Skincare Is Totally Worth The Hype – BeautyOnTApp"

Both are on Shopify's default blog handle `news`, a weak topical signal versus a themed path (compare SKIN functional's `/blogs/hyperpigmentation/`). Both titles are decent and on-brand.

**Publishing velocity is UNKNOWN.** Two posts surfacing is not evidence that only two exist — the playbook's 3-4 posts/week target cannot be assessed without site access. Tagged **NOT VERIFIED**.

#### [M] `/collections/south-african-brands` did not surface in any query (impact 3 / effort 1) — NOT VERIFIED

The playbook's do-not-break rule states the SA-brand collection *"lives at /collections/south-african-brands (never /south-african-skincare)"*. Across two targeted queries, individual SA brand collections surfaced (`/collections/pastry-skincare`, `/collections/mzuri`, `/collections/mzuri-skin`, `/collections/standard-beauty`) but the parent `/collections/south-african-brands` did not.

**Absence from a US-region result set is not proof the page is missing or unindexed.** Flagged only as a cheap thing for a human to eyeball once site access returns. Do **not** act on this without confirmation, and do **not** create a page at the forbidden `/south-african-skincare` path.

#### [M] Product count conflicts — "1,400+" vs "over 1500" (impact 2 / effort 1) — NOT VERIFIED

The playbook's do-not-break facts state "1,400+ products". A WebSearch prose summary for `beautyontappcos.co.za` stated "over 1500 beauty products". The latter is the search tool's paraphrase, not verbatim site copy, so **neither figure is verified here**. Raised because the playbook treats the product count as a consistency-critical brand fact.

### AUTHORITY

#### [H] Brand equity is split across three domains and two app listings (impact 4 / effort 4)

Beyond the three storefronts in the [C] finding, two **separate** mobile app listings are indexed:
- `apps.apple.com/in/app/beautyontapp/id6754606514` — "BeautyOnTApp"
- `apps.apple.com/za/app/shop-beauty-on-tapp/id6504258569` — "Shop Beauty on TApp"
- `play.google.com/store/apps/details?id=app.shopbeautyontapp.co.za` — "Beauty on TApp" (package namespaced to the **legacy** domain)

Any inbound link, citation, review or app install accruing to `shopbeautyontapp.co.za` or `beautyontappcos.co.za` builds authority for a domain that is not the commercial primary. Third-party citations observed pointing at the legacy entity include `aftership.com/brands/shopbeautyontapp.co.za`, `mallofafrica.co.za/store/beauty-on-tapp/`, `za.linkedin.com/company/beautyontapp`, `facebook.com/BeautyonTApp` and `x.com/beautyontapp`.

**Magnitude cannot be quantified** — link counts, referring domains and Authority Score all require Semrush. Tagged **NOT VERIFIED** as to size; the structural split itself is directly evidenced.

#### [M] Counter-SEO competitor map needs a new entrant added (impact 2 / effort 1)

Playbook-named SA K-beauty competitors confirmed live and indexed this run: `secretskin.co.za` (Secret Skin — agency link `westerncloud.co.za/secret-skin/` also confirmed), `seouloftokyo.co.za`, `sevenblossoms.co.za`, `arcstore.co.za` (`/k-beauty-at-arc`).

**Not in the playbook map and surfacing on the core category query: `k-beautyhouse.co.za`** — "Best Korean Beauty Products South Africa, Korean Skincare Products". Recommend adding to the tracked set.

**Glow Theory did not surface** in this result set — not evidence it is inactive (US-region search), just unconfirmed this run.

#### [NOT ASSESSED] Backlink profile, Authority Score, toxicity, disavow list

All require Semrush. **No referring-domain count, no Authority Score, no Toxicity Score and no disavow candidate list is produced this run.** No disavow action should be taken on the basis of this report.

## Auto-Applied Changes

**none**

This is a recommend-only agent per `automation/agents/02-seo-audit.md` ("Auto-applied actions: **None**"). No Shopify write, no theme edit, no Google Ads change, no Meta change was made or attempted.

For completeness: even had writes been in scope, the Shopify connector was unreachable for the entire run (token expired), so no write was technically possible.

| Change | Before → After | Revert |
|---|---|---|
| *(none)* | — | — |

## Recommendations

Prioritised by impact ÷ effort, split by bucket and owner. Nothing here has been executed.

### TECHNICAL

**T1. [C] Decide the domain strategy, then consolidate to one storefront.** Owner: **human + dev**. Impact 5 / effort 4.
Three live indexed storefronts is the biggest structural SEO liability found. Sequence: (1) a human confirms whether `shopbeautyontapp.co.za` and `beautyontappcos.co.za` are legacy or deliberate; (2) if legacy, 301 every URL to its `beautyontapp.com` equivalent — page-to-page, not a blanket redirect to the homepage; (3) fix the duplicate homepage title on whichever domain survives; (4) consolidate the two Apple app listings and re-point the Play Store package's brand naming; (5) update third-party citations (AfterShip, Mall of Africa, LinkedIn, Facebook, X) to the surviving domain. **Do not begin redirects before step 1** — if a domain is intentionally separate, redirecting it destroys a live channel.

**T2. [H] Fix the duplicate-collection creation process, then dedupe the three pairs.** Owner: **human + dev**. Impact 4 / effort 2.
Confirm the canonical member of each pair, 301 the loser to the winner, and canonical-tag the survivor. **Confirm the protected handle first** — the playbook forbids renaming the best-seller collection handle 'Skincare'. Not agent 03's job: merging/unpublishing collections is outside its allowlist.

**T3. [H] Re-run the full technical audit the moment Semrush units and HTTP access return.** Owner: **human (unblock) → agent 02 next run**. Impact 5 / effort 1.
The entire technical layer is unmeasured. In particular the playbook's "Fix #1" — duplicate product URLs from `{{ product.url | within: current_collection }}` — is flagged as the highest-impact known technical fix and its **current status is unknown**. Purchase units at https://www.semrush.com/mcp-access and have the egress policy for this session reviewed.

**T4. [M] Restore the two blocked connectors — this is now a repeat failure.** Owner: **human**. Impact 5 / effort 1.
Shopify has been broken across two consecutive runs (agent 01's `switch-shop` revoked it; still revoked). Re-authorize in claude.ai connector settings. Note the egress-policy 403 blocks *all* outbound HTTP for this session, including neutral hosts — that is an environment-level policy question, not a site problem.

### ON-PAGE

**O1. [H] Rewrite product meta titles to carry brand + product + geo.** Owner: **agent 03** (Shopify `fix_meta_title` is explicitly in its allowlist). Impact 4 / effort 2.
Highest impact-to-effort item that is cleanly automatable. Follow the pattern the collection pages already use. Concrete list in the Handoff below.

**O2. [M] Shorten `/collections/make-up` title and remove the duplicated brand name.** Owner: **agent 03**. Impact 2 / effort 1.
Current 78 chars with both "Beauty on TApp" and "BeautyOnTApp". Suggested: `Makeup South Africa | Korean & Local Cosmetics | BeautyOnTApp` (61 chars).

**O3. [M] Resolve the 6-vs-7 store count, then propagate it everywhere.** Owner: **human**, then agent 03 / dev. Impact 3 / effort 1.
`/pages/locations` says "7 SA Locations"; the playbook constant says 6. Once settled, align the page, LocalBusiness schema, GBP count and all NAP citations. **Do not guess** — this is a brand fact the playbook marks consistency-critical.

**O4. [L] Normalise the title separator.** Owner: **agent 03**, bundled into O1. Impact 1 / effort 1.

### CONTENT

**C1. [H] Build the hyperpigmentation content cluster — highest-priority content bet.** Owner: **content team**. Impact 5 / effort 3.
The #1 SA skin concern, with six competitors holding editorial and BoT holding only a commercial collection page. Copy the year-stamped SA-geo URL pattern the two strongest competitors use. Add the GEO/AEO structure from the playbook (40-60 word opening answer paragraph, passage-level H2s, named statistics, FAQPage + Article schema). Point the cluster's internal links at `/collections/hyperpigmentation`. This also defends a theme currently carried by paid spend (agent 01: R14,451.38/28d).

**C2. [M] Move the blog off the default `news` handle to themed paths.** Owner: **dev + content**. Impact 3 / effort 3.
`/blogs/news/` → themed blogs (e.g. `/blogs/hyperpigmentation/`, `/blogs/k-beauty/`). Requires 301s for existing posts — sequence it **after** T1/T2 so redirect work happens once.

**C3. [M] Verify `/collections/south-african-brands` exists and is indexed.** Owner: **human**, 2-minute check. Impact 3 / effort 1.
Did not surface this run. If missing, build it at that exact path — the playbook forbids `/south-african-skincare`. Pastry and Mzuri are the uncontested vertical per playbook prioritisation.

**C4. [M] Confirm the product count (1,400+ vs 1,500+) and align site copy.** Owner: **human**. Impact 2 / effort 1.

### AUTHORITY

**A1. [H] Fold link consolidation into the domain decision.** Owner: **human**. Impact 4 / effort 4.
Blocked behind T1 — reclaiming authority from the legacy domains is only possible once their fate is decided. Sizing requires Semrush.

**A2. [M] Add `k-beautyhouse.co.za` to the tracked competitor set.** Owner: **agent 06 / human**. Impact 2 / effort 1.

**A3. [M] Backlink outreach and disavow — DEFERRED, do not act on this report.** Owner: **human**. Impact 4 / effort 3.
The playbook targets (GLAMOUR SA, Woman & Home SA, Beauty South Africa, Professional Beauty SA) stand as standing recommendations, but **no gap analysis and no disavow list could be produced** — Semrush is down. **Submitting a disavow file without Toxicity Score data would be actively dangerous.** Defer entirely until units are restored.

### GOOGLE ADS (recommend-only)

**G1. No Google Ads recommendation is issued this run.** No organic ranking data exists to prove any term is safe to reduce paid dependency on, and `automation/inbox/` still holds only `README.md` (confirmed by agent 01). Issuing a bid-reduction CSV on unverified rankings would risk cutting paid traffic on terms where organic does not in fact rank. **Deferred until Semrush returns.**

## Handoff

### → Agent 03 (Merchant/Feed) — owns Shopify writes, fires 09:34 SAST

⚠️ **READ FIRST — CONNECTOR IS DEAD.** The Shopify MCP token is expired and the server disconnects on call. Agent 01 broke it with `switch-shop`; it was still broken for my entire run. **You will not be able to write anything until a human re-authorizes it.** If it is restored: **do all BeautyOnTApp work first and completely, then attempt Pastry** — `switch-shop` is what revoked the token, and Pastry may be a separate store entirely (see the Pastry report).

⚠️ **I could not enumerate the catalogue.** Everything below comes from SERP-observed URLs, so it is a **verified starting set, not a complete list**. Once connected, enumerate all products and apply the same rule.

**Job 1 — product meta titles (`fix_meta_title`, in your allowlist). Six confirmed cases:**

| Product handle | Current title (SERP-observed) | Proposed | Chars |
|---|---|---|---|
| `cosrx-advanced-snail-mucin-power-essence-100ml` | "Advanced Snail Mucin Power Essence – BeautyOnTApp" | `COSRX Advanced Snail Mucin Essence 100ml \| BeautyOnTApp` | 55 |
| `cosrx-advanced-snail-mucin-gel-cleanser-150ml` | "Advanced Snail Mucin Gel Cleanser – BeautyOnTApp" | `COSRX Snail Mucin Gel Cleanser 150ml \| BeautyOnTApp` | 51 |
| `cosrx-mucin-essence-cream` | "Cosrx - Mucin Essence + Cream – BeautyOnTApp" | `COSRX Snail Mucin Essence + Cream Set \| BeautyOnTApp` | 52 |
| `cosrx-all-about-snail-kit` | "COSRX All About Snail Kit - BeautyOnTApp" | `COSRX All About Snail Kit SA \| BeautyOnTApp` | 43 |
| `beauty-of-joseon-revive-ginseng-snail-mucin-serum` | "Revive Ginseng & Snail Mucin Serum – BeautyOnTApp" | `Beauty of Joseon Ginseng Snail Serum \| BeautyOnTApp` | 51 |
| `pastry-skincare-glycolic-acid-body-wash-pomegranate-fragrance` | "Glycolic Acid Body Wash – BeautyOnTApp" | `Pastry Glycolic Acid Body Wash Pomegranate \| BeautyOnTApp` | 57 |

**The rule to apply catalogue-wide:** `[Brand] [Product] [Size/Variant] | BeautyOnTApp`, ≤60 chars, brand name always present, pipe separator. Derive the brand from the handle prefix where the title omits it. Mirror the geo-targeting the collection titles already use.

**Job 2 — one collection meta title (`fix_meta_title`):**
- `/collections/make-up`: "Makeup | Beauty on TApp South Africa | Korean & Local Cosmetics – BeautyOnTApp" (78 chars) → `Makeup South Africa | Korean & Local Cosmetics | BeautyOnTApp` (61 chars). Removes the duplicated brand name and the legacy "Beauty on TApp" spelling.

**Job 3 — audit these yourself, I could not see them:** meta **descriptions** (all products/collections), image **alt text**, product **description word counts** (playbook: <300 words = Medium gap), `google_product_category`, `product_type`, missing GTIN/MPN. All are in your allowlist and all were completely invisible to me.

**DO NOT do these — outside your allowlist:**
- ❌ Merging, redirecting, unpublishing or renaming the duplicate collection pairs (`best-seller`/`best-sellers`, `mzuri`/`mzuri-skin`, `cosrx`/`cosrx-1`) — that is dev/human, and a protected handle is involved.
- ❌ Changing the "7 SA Locations" store count anywhere — unresolved factual conflict, human call.
- ❌ Any price, status or bulk change.
- ❌ Creating `/collections/south-african-brands` — verify first; never use `/south-african-skincare`.

### → Agent 04 (Analyst/Solutions)

- **No organic traffic figure, no brand/non-brand split, and no top-landing-page list is available.** Semrush is unit-blocked. Do **not** infer an organic contribution — the playbook's 83%-brand-search baseline is a **stale skill estimate that I could not verify** and must not be treated as this month's data.
- **Material to your attribution problem:** at least three live indexed BoT storefront domains exist. If any organic or direct sessions land on `shopbeautyontapp.co.za` or `beautyontappcos.co.za`, they sit outside the `beautyontapp.com` Shopify property whose revenue agent 01 used (R1,522,112.10 / 1,557 orders / 28d). Confirm which domains feed which analytics property **before** reconciling MER.
- This compounds the cross-brand problem agent 01 handed you (42.5% of BoT Meta spend running Pastry creative). Brand and property boundaries are unclear on **both** the paid and organic sides.

### → Agent 05 (Keywords + Negatives)

- **No organic ranking data — do not build a paid/organic dedupe list this run.** I cannot confirm that BoT ranks page 1 for any term, so any negative or bid cut justified by "organic already covers it" would be unfounded.
- Themes where paid carries the load and organic assets look thin (from agent 01 + my content findings): **hyperpigmentation / dark marks** (Pastry `AS1_Hyperpigmentation`, R14,451.38/28d — no BoT editorial found), **Korean/K-beauty brand terms** (`AS5_KoreanBrands`, R14,038.52/28d — collection pages strong, product titles missing brand names), **body care** (`AS2_Body_Care_Broad`, R14,684.78/28d).
- Standing protected terms unchanged: never negate face wash / face serum / face cream / review / vs.

### → Agent 06 (Revenue Expansion)

- **Lead the digest with the connector outage, not with SEO wins.** Three of four data sources were down; today's organic picture is qualitative only.
- **Escalate as the top organic item: three live indexed BoT storefronts**, two serving an identical title tag. It needs a human decision before any SEO work compounds.
- **Top content bet: the hyperpigmentation cluster** — #1 SA concern, six competitors holding editorial, BoT holding none, and paid spending R14,451.38/28d on the theme.
- **Add `k-beautyhouse.co.za`** to the tracked competitor set alongside the confirmed-live `secretskin.co.za`, `seouloftokyo.co.za`, `sevenblossoms.co.za`, `arcstore.co.za`. Glow Theory unconfirmed this run.
- **Programmatic-SEO playbooks 1/2/12 are DEFERRED** — the playbook requires a cannibalization check via position_tracking first, and that is unavailable. Given three confirmed duplicate collection pairs already exist, launching programmatic pages now would worsen a live duplication problem.
- **No disavow list, no backlink roadmap, no GBP gap sizing** — all Semrush-dependent.

### → Dev / code-review (recommend-only, not an SEO write)

1. **Domain consolidation + 301 map** (blocked on the human decision in T1) — highest priority.
2. **Duplicate collection 301s + canonicals** — confirm the protected handle first.
3. **Unverified this run, re-check when access returns:** duplicate product URLs (`within: current_collection`), faceted-nav noindex/canonical, JSON-LD schema, Core Web Vitals, `robots.txt` AI-bot access, `llms.txt`, `sitemap.xml`.
4. **Blog path restructure** off the default `news` handle — sequence after items 1-2 so redirects are done once.
