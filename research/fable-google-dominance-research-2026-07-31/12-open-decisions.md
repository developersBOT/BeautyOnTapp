# 12 — Open Decisions (require T's authority)

Only decisions this investigation cannot make. Each states evidence, commercial trade-off, and the default no-change state.

## D1 — Grant first-party Google read access for research sessions
**Evidence:** GSC, Merchant Center 5717759749, GBP and GA4 were all unreachable this session (00-source-manifest.md §A rows 6, 8, 9); two google-site-verification metas are already live in the theme (shopify-theme-config.json), so this is permissioning, not engineering. **Trade-off:** without it, demand, feed eligibility, local truth and CWV stay NOT VERIFIED and Gates 1–3 of the roadmap cannot be sized; granting read-only API access carries minimal risk. **Default (no change):** those surfaces remain evidence gaps and the roadmap stalls at Gate 0.

## D2 — Egress/vantage for live-site and ZA SERP verification
**Evidence:** this environment's policy blocks beautyontapp.com, google.com and developers.google.com (proxy connect_rejected 403s, 04:42Z; WebFetch 403 ×4). **Trade-off:** allowlisting (or running checks from T's machine/a ZA vantage) unlocks URL-level verification, ZA SERP observation, schema validation and legacy-domain redirect checks; without it, all URL-fetch-dependent dispatch phases stay partially blocked. **Default:** US-origin WebSearch observation remains the ceiling of SERP evidence.

## D3 — Semrush: **decided by T this session**
T directed "Skip semrush" (this conversation, 2026-07-31) after the MCP reported an active subscription with zero API units. Recorded as a standing directive: demand sizing defers to GSC (D1). No Semrush spend is proposed. Reversal is T's call only.

## D4 — Legacy digital identity: shopbeautyontapp.co.za + Android app package
**Evidence:** the legacy domain is registered in Shopify (shopify-theme-config.json domains), still indexed carrying current brand titles, outranked beautyontapp.com on the observed COSRX query (websearch-category.json), was cited as the store website in a third-party Menlyn listing (websearch-local.json, unconfirmed), and is the published Play app's package id `app.shopbeautyontapp.co.za` (websearch-brand.json). Meanwhile this repo's Android build is unshippable to Play (template `com.example.beautyontapp` id, debug signing — repo-app-surface.json, file:line cited). **Trade-off:** consolidating identity (path-level 301 verification, citation updates, app-listing strategy) recovers split equity but the Play package id is immutable — changing it means a new listing and losing installs/reviews. **Default:** split identity persists; the legacy domain keeps intercepting brand-adjacent queries.

## D5 — Hemingways Mall (East London) store facts
**Evidence:** the indexed "7 SA Locations" title is verbatim-observed (websearch-brand.json); Hemingways itself is named only in tool-synthesized answers — including a synthesized opening date of 2026-06-27 and street address (websearch-local.json, explicitly labeled synthesis, not verbatim SERP content); Shopify holds no such location — 6 mall stores + head office only (shopify-theme-config.json locations). **Trade-off:** if the store is real, its absence from Shopify blocks every local workstream for that store (GBP linkage, any future local inventory — P14); if it is not, the site overclaims and the locations page needs correcting. **Default:** local-surface work proceeds for 6 stores only; Hemingways stays HELD as unverified (file 06).

## D6 — GTIN acquisition program
**Evidence:** 1,596 of 1,623 active products lack barcodes (shopify-products-quality.json); real Merchant impact unmeasured until D1. **Trade-off:** supplier/GS1 sourcing is slow, vendor-by-vendor work (top vendors first: COSRX 100, Skin Functional 77, Medicube 51, Fundamentals 49, ANUA 46); skipping it caps Shopping/free-listing matching indefinitely. **Default:** coverage stays at 1.66%; feed relies on whatever identifier fallback Simprosys applies (NOT VERIFIED).

## D7 — Duplicate-intent collections and the programmatic series
**Evidence:** 7 live duplicate pairs (incl. anti-aging 192 / anti-ageing 62; face-masks 103 / face-mask 133; best-sellers 129 / best-seller-1 364), 7 recycled handle-title mismatches, and ~225 empty programmatic brand×category collections (shopify-content-architecture.json). **Trade-off:** per-pair ownership decisions concentrate ranking signals but 301s carry index-transition cost; keeping both splits equity permanently. The dispatch (P6) forbids blanket consolidation — every pair needs an individual call. **Default:** all pairs stay live and competing with themselves.

## D8 — Cross-brand query observation (report-only per dispatch P8)
**Evidence:** the "Pastry Skincare South Africa" query surfaced the legacy BeautyOnTApp domain's /brands/pastry-skincare/ URL alongside Pastry's own properties (websearch-brand.json). No migration/redirect/canonical/domain recommendation is made — P8 prohibits it. **Decision:** whether to commission a dedicated cross-brand query-conflict study once ZA observation (D2) exists. **Default:** no action; observation logged only.
