# 11 — 90-Day Research-Backed Roadmap

Investigation-only output: every item below is a **recommendation mapped to a finding ID** (04-url-gap-ledger.csv unless noted), with success criterion, dependency, risk and rollback boundary. Nothing here was executed. Sequencing principle (01-executive-verdict.md): unblock evidence → close verified structural gaps → build local+shopping proof base → scale content/authority.

Roles: T = decision owner. All KPI references = 14-measurement-framework.csv.

## Gate 0 — Immediate (days 0–7): unblock evidence + fix only what is already fully verified

| # | Action | Finding | Success criterion | Dependency | Risk / rollback boundary |
|---|---|---|---|---|---|
| 0.1 | Grant a research channel to GSC (sc-domain:beautyontapp.com), Merchant Center 5717759749, GBP, GA4 — or run those readbacks on T's authenticated machine | F-MEAS-01, F-LOCAL-03, F-SHOP-01, F-PERF-01, D1 | Files 06/07/10 + 14 baselines populated from first-party data | T authority | None — read-only access |
| 0.2 | Re-run the ZA observation protocol (query set in file 03) from a ZA vantage with gl=za&hl=en, device + time logged | file 03 caveat row, D2 | Every file-03 row upgraded from US-observed to ZA-observed | unblocked vantage | None — observation only |
| 0.3 | Verify live behavior of the 5 nav-linked redirected collection paths, then per path either delete the redirect or remove nav link + collection | F-TECH-01 | Zero nav links pointing at redirecting paths | 0.2 vantage | Redirect deletion is reversible (re-create row); do NOT bulk-delete — one decision per path |
| 0.4 | Repoint the broken privacy redirect and the 2-hop chains to final destinations | F-TECH-02, F-TECH-03 | Each head URL returns a single 301 to a 200 page | T confirms intended privacy destination | Reversible (redirect rows) |
| 0.5 | Repoint footer Careers to the published /pages/careers | F-ARCH-05 | Footer link returns 200 | none | Trivially reversible |
| 0.6 | Reconcile Hemingways: real store → create Shopify location; not real → correct site copy + "7 SA Locations" claim | F-LOCAL-01, D5 | Shopify locations list matches live store list 1:1 | T store facts | Facts must come from T — dispatch P9 forbids fabricated store facts |
| 0.7 | GSC URL-inspect (indexed version) the 6 stale-index URLs from F-TECH-04 | F-TECH-04 | Confirmed: directives read (wait out recrawl) vs not read (escalate) | 0.1 | No action without inspection result — index lag is the expected explanation |

**Gate 0 exit test:** GSC/MC/GBP baselines captured; redirect estate has zero verified conflicts; store-facts reconciled.

## Gate 1 — Day 30: shopping + local foundations (sized by real diagnostics)

| # | Action | Finding | Success criterion | Dependency | Risk / rollback |
|---|---|---|---|---|---|
| 1.1 | MC diagnostics readback → size the real GTIN impact (disapprovals, demotions, `identifier_exists` handling in Simprosys) | F-SHOP-01, SHOP-FEED-01 | File 07 rewritten with exact MC issue counts | 0.1 | Read-only; Simprosys ownership untouched (P7) |
| 1.2 | GTIN acquisition wave 1: top vendors (COSRX 100, Skin Functional 77, Medicube 51, Fundamentals 49, ANUA 46) from supplier invoices/GS1 — no invented codes | F-SHOP-01, D6 | Barcode coverage ≥25% of active catalog; MC GTIN warnings falling | supplier data | Only verified codes entered; rollback = field clear |
| 1.3 | Fill productType for the 546 blanks; publish-or-exclude decision for the 18 no-onlineStoreUrl products; SKUs for the 24 blanks | F-SHOP-02, F-SHOP-04, SHOP-SKU-01 | empty productType <5%; zero fed products without landing page | 1.1 cross-check | Field edits reversible |
| 1.4 | Authenticated GBP audit per store: existence, categories, NAP vs normalized Shopify names, hours, reviews, photos | F-LOCAL-02, F-LOCAL-03 | File 06 GBP columns populated for all stores | 0.1, 0.6 | Read/audit first; profile edits are a Gate 2 decision |
| 1.5 | Menu integrity pass: rebuild main-menu items; fix navabr product-URL/dead links (Dark Marks → /collections/dark-marks etc.) | F-ARCH-01, F-ARCH-02 | No nav item resolves to '#' or to a single product where a category collection exists | 0.3 | Menu edits reversible; verify which surface consumes main-menu first |
| 1.6 | Decide the 7 duplicate-intent collection pairs + 7 handle-title mismatches — one decision per pair, NO blanket consolidation (P6) | F-ARCH-03, F-ARCH-04, D7 | Decision log: one owner URL per intent | T authority | 301s reversible only with index cost — decide before acting |

**Gate 1 exit test:** MC issue count trending down; GBP truth table complete; nav has zero verified defects.

## Gate 2 — Day 60: content + passage answerability (= the AI-surface program)

| # | Action | Finding | Success criterion | Dependency | Risk / rollback |
|---|---|---|---|---|---|
| 2.1 | Collection copy wave 1: nav-linked + top-product-count collections currently empty (from the 382-empty list; skip the already-rich skincare/acne/cosrx/la-roche-posay set) | F-ONPAGE-01, AI-03 | seo.description coverage >75% on nav-linked collections | brand-accurate inputs (P9 — no fabricated claims) | Copy edits reversible; existing SEO pairs preserved (P5) |
| 2.2 | Programmatic series decision executed (from 1.6 scope choice): describe-and-keep the sellers, or noindex/park the rest — per-segment, not blanket | F-ARCH-06, D7 | Sampled series pages show unique copy or intentional noindex | 1.6 | Noindex via existing theme criteria only; robots.txt untouched (P3) |
| 2.3 | Thin-product-copy wave: 131 products, supplier-sourced copy only (local brands Purpul Hair, Native Child, Brothers Beard, Ndanaka first) | F-ONPAGE-02 | Thin count <50 | supplier copy | No invented ingredient/benefit claims (P9) |
| 2.4 | Blog restart + drafts resolution (publish or delete 3 drafts, remove their stopgap redirects); ingredient-hub interlinking from matching collections | F-CONT-01, F-AI-02 | ≥2 sourced posts/month; ingredient pages linked from relevant collections | content owner | Editorial; reversible |
| 2.5 | Alt-text review of the 62 flagged products — product photos only, intentional decorative empties documented and left alone | F-ONPAGE-03, MEDIA-01, P10 | Every product-photo featured image has descriptive alt; exceptions logged | manual review | Reversible |
| 2.6 | Set page SEO titles for /pages/brands + /pages/make-services | F-ONPAGE-04 | Indexed titles show branded descriptive titles after recrawl | none | Two pages only — not a universal title action (P5) |
| 2.7 | Validate rendered JSON-LD (Rich Results test) incl. LocalBusiness against reconciled store facts; verify Organization sameAs covers verified profiles | ENT-01, ENT-02, F-ENT-01 | Zero validation errors on sampled URLs | 0.2, 0.6 | Read/validate only; Webrex untouched (P4) |

**Gate 2 exit test:** GSC non-brand impressions trend up on touched collections with CTR held (KPI rows 1–2); zero schema validation errors.

## Gate 3 — Day 90: authority, legacy equity, app surface — sized by real baselines

| # | Action | Finding | Success criterion | Dependency | Risk / rollback |
|---|---|---|---|---|---|
| 3.1 | Legacy-domain verification: sample shopbeautyontapp.co.za URLs — path-level 301s to equivalents? Report recoverable equity to T | F-ENT-02, AUTH-02, D4 | Verified redirect map; decision brief for T | 0.2 | Report-only until T decides |
| 3.2 | Backlink baseline from GSC Links; only then scope digital-PR/supplier-link opportunities | AUTH-01 | File 08 populated; PR target list evidence-ranked | 0.1 | No outreach this phase (dispatch bars external contact in-investigation; execution needs T sign-off) |
| 3.3 | Reputation verification: Hellopeter profile read; if 2.7 confirmed, review-response program brief | ENT-05, F-ENT-03 | Verified score + response-coverage plan | 0.2 | Report-only |
| 3.4 | ZA AI-surface measurement cycle 1 on the tracked query set (AI Overview presence + citation share) | F-AI-02, ENT-06, KPI row 11 | First citation-share baseline recorded | 0.2 | Observation only |
| 3.5 | App-surface decision brief: legacy Play package vs this repo's unshippable Android config (com.example id, debug signing), deep-link absence, unmeasurable app traffic | APP-01–APP-04, D4 | T decision on app identity + linking roadmap | repo facts (verified) | Report-only; OAuth constraint on UA documented |
| 3.6 | CWV cycle: PSI-with-key + GSC CWV per URL group; populate file 10 with p75 field metrics; only then any performance work | F-PERF-01 | File 10 has real field rows; failing groups (if any) root-caused | 0.1 / API key | No performance changes before field data exists |
| 3.7 | Local-inventory readiness assessment — only if 0.6 + 1.4 fully reconciled (locations ↔ GBP ↔ store codes ↔ inventory) | F-LOCAL-05, SHOP-LIA-01, P14 | Written readiness verdict (may be "not ready") | 0.6, 1.4 | Do NOT activate anything — assessment only |

**Gate 3 exit test:** every file-02 NOT VERIFIED surface has either real data or a dated, owned unblocking task; 90-day KPI review against file 14 baselines.

## Standing constraints across all gates

Robots.txt untouched (P3). Webrex sole Product-schema source (P4). No universal title replacement (P5). No blanket collection consolidation; no new oil-cleanser collection, no TXA change, no SwiitchBeauty rewrite, no Fundamentals image re-push (P6). Analyzify/Simprosys/BookX/Webrex/pixels/checkout/tracking/feed ownership unchanged (P7). pastryskincare.co.za out of scope (P8). Google & YouTube product sync stays off (P16). Semrush stays skipped per T (this conversation) unless T reverses.
