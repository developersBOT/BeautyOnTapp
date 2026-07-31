# 01 — Executive Verdict

BeautyOnTApp Google dominance investigation, 2026-07-31. Evidence base: full first-party Shopify readback (1,623 active products, 525 collections, theme v8.2.2, 92 redirects), US-origin Google index observation, repo audit. Nine of twelve dispatch sources were unreachable this session (00-source-manifest.md §A) — this verdict states only what the accessible evidence supports.

## Strongest current advantages (verified)

1. **On-page plumbing is largely done.** 96.5% of active products have SEO titles, 97.8% have SEO descriptions; the theme's title/meta/canonical/noindex logic is disciplined and CWV-conscious (LCP preload, deferred modules, CLS-reserving critical CSS). [shopify-products-quality.json; shopify-theme-config.json]
2. **The category asset base is real.** 525-product Korean-skincare collection, 360-product acne collection with a strong indexed title, an 11-page ingredient hub with answer-shaped titles, and an "AI Agents & LLMs" page updated the morning of this audit. [shopify-content-architecture.json; websearch-brand.json]
3. **Brand surface is coherent at index level.** Home, key collections, both app stores, IG/TikTok/X all indexed with intentional titles; locations page surfaced for all 7 observed store queries. [websearch-brand.json; websearch-local.json]
4. **Structured-data ownership is clean.** One owner per schema type in the theme (Organization/LocalBusiness/Breadcrumb/About), Product schema left to Webrex per policy. [shopify-theme-config.json]

## Five largest verified blockers

1. **F-SHOP-01 — 98.34% of the active catalog has no GTIN/barcode** (27 of 1,623). Whatever Merchant Center shows (unverified), the feed's matching/eligibility ceiling is set here. First move is an MC diagnostics readback, then supplier GTIN sourcing by top vendors (COSRX 100 products, Medicube 51, ANUA 46…).
2. **F-ENT-02 — legacy-domain identity split.** shopbeautyontapp.co.za is still indexed carrying current brand titles, outranked the main site on the observed COSRX query, is cited by at least one mall listing, and is the Android app's package identity. Path-level redirect state is unverified and is the single highest-leverage verification to run from an unblocked vantage.
3. **F-ARCH-06 + F-ONPAGE-01 — ~225 programmatic brand×category collections with no copy and no SEO fields**, inside a wider 72.8%-empty-description collection estate. This is the site's passage-answerability gap for both classic SERPs and AI surfaces (AI-03).
4. **F-TECH-01/-02/-03 — redirect estate conflicts**: 5 redirects sit on live nav-linked collection paths, 2 verified 2-hop chains, 1 broken target (`/pages/yourprivacychoices` doesn't exist). Small count, high certainty, cheap to fix once live behavior is verified.
5. **F-LOCAL-01/-03 — local surface unproven**: the site claims 7 stores (incl. Hemingways East London) but Shopify holds 6 retail locations + head office, names drift across locations, and GBP state is unverifiable from this environment for every store. Local-inventory work is correctly parked until this reconciles (P14).

## Already fixed (as far as this session can see)

Theme v8.2.2 (published 04:14Z today) contains the remediation artifacts the dispatch describes: custom robots.txt.liquid with the single legacy-collection Allow rule, pagination/filter/tag noindex logic, collection meta-description fallback, branded-title guard at 60 chars. Item-by-item reconciliation against the pre-publish QA record and the two crawls was **impossible** (files unreachable) — NOT VERIFIED beyond the theme-code evidence. Google's index still shows pre-remediation state for at least 6 URLs (F-TECH-04); expected recrawl lag, confirmable only in GSC.

## Largest NOT VERIFIED blocks (in commercial-priority order)

1. Merchant Center eligibility/disapprovals (account 5717759749) — no channel.
2. GSC demand, indexation, CWV, Links — no channel (two site-verification metas confirmed in the theme, so access is a permissioning task, not an engineering one).
3. ZA-localized SERPs incl. AI Overviews, local packs, Shopping units — egress-blocked.
4. GBP state for all stores — no channel.
5. CrUX field CWV — keyless PSI daily quota exhausted.
6. Backlink profile — Semrush skipped per T; GSC Links unavailable.

## The single recommended strategic sequence

**Unblock evidence → close verified structural gaps → build the local+shopping proof base → then scale content/authority.** Concretely: (1) restore GSC+MC readback and run the ZA observation protocol; (2) fix the verified redirect/nav/menu defects and reconcile the Hemingways/location facts; (3) GTIN + productType program sized by real MC diagnostics; (4) collection-copy program prioritized by nav-linked/high-count collections (this is simultaneously the AI-surface program); (5) only then authority/digital-PR, sized by a real backlink baseline. Full gated plan: 11-roadmap-90-days.md.
