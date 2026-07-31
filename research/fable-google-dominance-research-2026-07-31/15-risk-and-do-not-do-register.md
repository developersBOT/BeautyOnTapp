# 15 — Risk & Do-Not-Do Register

Investigation: BeautyOnTApp Google dominance gap analysis, 2026-07-31.
Source of constraints: uploaded dispatch `7fa51ca0-fable5googledominanceresearchinvestigation.xml` (SHA-256 `cf6eb002…841fd`), `<hard_constraints>` block, read in full 2026-07-31. [source: dispatch lines 60–76]

## A. Prohibited actions honored this session (zero-write attestation inputs)

| # | Prohibition | Dispatch source | Session compliance evidence |
|---|---|---|---|
| P1 | Investigation only — zero Shopify, theme, content, redirect, robots, sitemap, GSC, Merchant Center, GBP, Google Ads, Semrush or external-platform changes | dispatch line 61 | Only read tools called: `get-shop-info`, `graphql_query` (reads), WebSearch, curl GET probes. No mutation tool invoked; workflow agent prompts hard-ban `graphql_mutation`. |
| P2 | No live-theme edits; no theme create/publish | line 62 | Theme read via GraphQL only. |
| P3 | No robots.txt change or robots recommendation without URL-level proof + current official Google support | line 63 | Official Google docs unreachable this session (WebFetch 403) → **no robots recommendation is made anywhere in this deliverable set**. |
| P4 | No schema consolidation, no custom Product JSON-LD, no Webrex modification, no alternative Product-schema app proposal | line 64 | Webrex treated as sole Product schema source throughout; file 08 only records ownership. |
| P5 | No universal title replacement; preserve existing SEO title/description pairs | line 65 | No title rewrite recommended; on-page findings are coverage counts only. |
| P6 | No new oil-cleanser collection, no TXA destination change, no SwiitchBeauty rewrite, no Fundamentals image re-push, no blanket collection consolidation | line 66 | None of these appear in any recommendation. |
| P7 | No changes to Analyzify, Simprosys, BookX, Webrex, pixels, checkout, tracking, feed ownership | line 67 | App inventory read-only; file 07 assumes Simprosys remains feed source. |
| P8 | No pastryskincare.co.za migration/redirect/canonical/domain-strategy recommendation; cross-brand conflict is a decision item only | line 68 | Cross-brand observation (if any) recorded in file 12 only. |
| P9 | No fabricated provenance, positioning, ingredients, stock, prices, service/store facts, product attributes | line 69 | Every populated field cites a source; absent evidence = NOT VERIFIED. |
| P10 | Intentional empty-alt decorative images / width-20 placeholders are not copywriting opportunities | line 70 | Alt-coverage counts in file 04/07 flag this caveat inline. |
| P11 | Partial crawls, stale Semrush screens, historical snapshots, search snippets, training memory ≠ current evidence | line 71 | WebSearch observations are labeled "observed snapshot, US-origin, not ZA SERP truth" and never used as rank truth; no Semrush data exists this session at all. |
| P12 | Semrush figures = dated third-party estimates for prioritization only | line 72 | Moot this session (Semrush blocked, zero API units) — recorded in files 00/12. |
| P13 | Indexing request ≠ indexed/ranked | line 73 | No indexing claims made from requests. |
| P14 | No local-inventory activation or readiness claim without Shopify-location ↔ GBP ↔ store-code ↔ inventory reconciliation | line 74 | GBP inaccessible → local-inventory readiness is NOT VERIFIED in files 06/07; no activation recommended. |
| P15 | No new paid tool unless an installed/first-party tool cannot answer a defined gap, with verified current price/limits/overlap/exit | line 75 | No new paid tool recommended. Semrush API-unit top-up is surfaced in file 12 as a decision on an **existing** subscription, with the vendor URL the tool itself returned; current pricing NOT VERIFIED (vendor page unreachable this session). |
| P16 | Do not enable Google & YouTube product sync | line 50 | Channel presence observed read-only; no enablement action anywhere. |

## B. Risks attached to this investigation's own limitations

| Risk ID | Risk | Evidence | Boundary |
|---|---|---|---|
| R1 | Acting on this report as if it were a full-surface audit. Nine of the twelve required sources were unreachable this session (see file 00) — GSC, Merchant Center, GBP, ZA SERPs, public-site HTML, official Google docs, Semrush, and both Screaming Frog crawl sets. | source-probes.json, 2026-07-31T04:41–04:45Z | Treat every NOT VERIFIED row as an open evidence task, not a cleared item. Do not sequence 60/90-day work that depends on unverified surfaces until access is restored (file 12, decisions D1–D4). |
| R2 | US-origin WebSearch observations being mistaken for ZA rankings. WebSearch tool is documented US-only; local packs, Shopping units and AI Overviews are not rendered in its results. | WebSearch schema, this session | Files 03/05/09 carry the label on every row; no rank numbers recorded. |
| R3 | First-party Shopify counts drifting. Product/collection/page counts are a 2026-07-31 snapshot of a live store. | evidence files, retrieval timestamps inline | Reverify volatile counts before executing any dependent fix (dispatch line 14 requires reverification of volatile state). |
| R4 | Keyless PSI quota shaping the CWV picture. Field (CrUX) data may cover only some URLs; lab values are single-run diagnostics, not field truth. | psi-summary.json | File 10 separates FIELD vs LAB per row; blocked URLs are recorded as blocked, not degraded. |
| R5 | Duplicate remediation. The dispatch states theme v8.2.2 shipped a remediation on 2026-07-31, but the pre-publish QA record is unreachable, so "already fixed" cannot be reconciled item-by-item. | dispatch lines 13, 27; probe log | File 04 findings are labeled "state at 2026-07-31 per named source"; before executing any fix, reconcile against `sf-remediation-prepublish-qa-2026-07-31.md` on the machine that holds it. |

## C. Recommendations rejected during this investigation, and why

| Rejected action | Why rejected |
|---|---|
| Scraping beautyontapp.com or google.com via alternate routes after proxy 403 | Egress policy denial; proxy README instructs report-don't-retry. Routing around policy is prohibited by the environment and would taint evidence provenance. |
| Using training memory to fill competitor names, market shares, or brand positioning | Dispatch `<anti_training_memory>` (line 139); PNCapital discipline gate 4/5. All competitor rows come only from queries actually run this session. |
| Estimating search volumes / rankings to populate file 03 | Both demand sources (GSC, Semrush ZA) unreachable; dispatch line 88 forbids estimating missing volumes or rankings. |
| Scoring unmeasured surfaces in file 02 | Dispatch line 121 requires NOT VERIFIED instead of invented scores. |
| Declaring local-inventory or GBP readiness from the Shopify locations list alone | Dispatch lines 49, 74 require reconciled GBP + store codes + inventory; GBP was inaccessible. |
| Recommending robots/sitemap changes | Requires URL-level proof plus current official Google documentation (line 63); official docs unreachable this session. |
