# 00 — Source Manifest

Investigation: BeautyOnTApp Google dominance gap analysis.
Executed 2026-07-31, 04:40–05:10 UTC, in a remote Claude Code container (linux, session `74b7707f`), branch `claude/new-session-5jpwou`.
Dispatch: `7fa51ca0-fable5googledominanceresearchinvestigation.xml` — SHA-256 `cf6eb00223c476f6507cb0daa9a00f955ea7b465219bc844f3c0d118c70841fd`, 21,263 bytes, 142 lines, read in full 2026-07-31T04:40Z.

**Output-directory substitution:** the dispatch's `/Users/tn/Documents/google bot/execution-2026-07-31/fable-google-dominance-research/` is a macOS-local path unreachable from this container. Outputs are delivered at `research/fable-google-dominance-research-2026-07-31/` on branch `claude/new-session-5jpwou` (draft PR #6).

## A. Required sources — access outcome

| # | Dispatch source ID | Target | Outcome | Evidence of outcome |
|---|---|---|---|---|
| 1 | business_facts | `/Users/tn/.../03_PNCapital_Business_Facts.md` | **INACCESSIBLE** — macOS-local path; not in container; repo glob for `*business*facts*` empty | probe 04:41Z |
| 2 | prepublish_evidence | `sf-remediation-prepublish-qa-2026-07-31.md` | **INACCESSIBLE** — macOS-local | probe 04:41Z |
| 3 | baseline_sf | SF exports `postpublish-live-v8.2.1-complete/` | **INACCESSIBLE** — macOS-local; completion gates unevaluable | probe 04:41Z |
| 4 | postpublish_sf | SF exports `postpublish-live-v8.2.2-complete/` | **INACCESSIBLE** — macOS-local; completion gates unevaluable | probe 04:41Z |
| 5 | semrush | Semrush MCP incl. Site Audit campaign 29228518 | **BLOCKED then SKIPPED** — all 7 toolkits returned "active subscription… not enough API units" at 04:44Z; T then directed "Skip semrush" (this conversation, 2026-07-31) | tool responses + user message |
| 6 | gsc | sc-domain:beautyontapp.com | **INACCESSIBLE** — no authenticated channel in session toolset | session tool roster |
| 7 | shopify | BeautyOnTApp Shopify Admin (read-only) | **ACCESSIBLE** — shop verified: BeautyOnTApp, beautyontapp.com, Advanced, ZAR, SAST, South Africa (04:43Z); matches dispatch's stated verification | get-shop-info response |
| 8 | merchant_center | account 5717759749 | **INACCESSIBLE** — no authenticated channel | session tool roster |
| 9 | business_profile | GBP per location | **INACCESSIBLE** — no authenticated channel; public-maps inference disallowed by dispatch | session tool roster |
| 10 | crux | CrUX field data (via PSI v5 keyless) | **BLOCKED** — host reachable but HTTP 429 "Queries per day" exhausted on shared anonymous project 583797351490; retries at 05:01–05:02Z all 429 | psi-fetch-log.txt, 4 × .BLOCKED.json |
| 11 | public_site | beautyontapp.com fetches | **BLOCKED** — egress proxy `connect_rejected 403` (04:42:01Z ×3); WebFetch also 403; proxy README: report, don't retry | proxy status endpoint |
| 12 | google_primary | developers.google.com docs | **BLOCKED** — WebFetch 403 (04:44Z) | tool response |
| 13 | current_serps | google.com ?gl=za&hl=en | **BLOCKED** — egress 403 (04:42:02Z). Partial substitute: harness WebSearch (**US-only** per its schema) used as observed snapshots, never as ZA rank truth | proxy status + tool schema |

Score: 2 of 12 dispatch sources fully accessible (shopify; current_serps partially via US-origin substitute). All findings files mark the dependent fields NOT VERIFIED accordingly.

## B. Evidence artifacts produced this session (all read back in full or via structured extraction)

| File | SHA-256 (first 16) | Bytes | Producer / scope | Retrieved (UTC) |
|---|---|---|---|---|
| source-probes.json | 9fda1f647feb8e4d | 6,270 | main loop — access probes | 04:41–04:45Z |
| shopify-theme-config.json | c90877039fece84b | 13,857 | agent, read-only GraphQL: themes (5, target verified MAIN), theme SEO files (7), robots.txt.liquid full text, layout head extracts, 8 domains, 3 markets, 9 publications, 7 locations | 04:46:58Z |
| shopify-products-quality.json | a6ddfc64f95f5bd8 | 375,796 | agent: 1760 products (1623 active, **100% of active scanned**, 7 pages × 250), per-product SEO/barcode/alt/desc fields + aggregates | 04:46:58Z run |
| shopify-content-architecture.json | e39d6619e53d622b | 29,700 | agent: 525/525 collections (11 pages), 10 menus, 32 pages, 1 blog/12 articles, 92 redirects (50 sampled), metafield/metaobject definitions | 04:50:01Z run |
| websearch-brand.json | 0fe075015bfa24a8 | 29,920 | agent: 10 brand/site queries — 22 own-URL indexed titles, app/social presence, legacy-domain observation | 04:51–04:53Z |
| websearch-category.json | 00f8af8ce721c3f1 | 34,544 | agent: 10 ZA-commercial queries — presence 6/10, competitor frequency table (15 domains) | 04:55–04:56Z |
| websearch-local.json | c88f1180158d1dda | 25,238 | agent: 7 store + 2 shopping queries — cross-query observations, zero GBP artifacts (correctly caveated) | 05:00Z run |
| repo-app-surface.json | f7aa9c1b86075fe9 | 11,607 | agent, Read/Grep/Glob only over local clone @ 270527c: app ids, signing, deep-link absence, WebView UA, analytics absence — all claims file:line-cited | 05:02:13Z |
| psi-fetch-log.txt + 4 × psi-*.BLOCKED.json | 005fa1556e95750a + 4 | 2,456 + ~830 | agent: PSI attempts + per-URL blocked records | 05:01–05:09Z |

Row-count / coverage gates met: products 1623/1623 active (hasNextPage=false page 7); collections 525/525 (hasNextPage=false page 11); pages 32/32; menus 10; redirects 92 counted / 50 row-sampled (42 unsampled — flagged in F-TECH-02).

## C. Provenance rules applied

- **Verified fact** = first-party Shopify Admin readback this session, or repo file:line, or full file content quoted.
- **Observed snapshot** = WebSearch results: US datacenter, flat link lists, no SERP features rendered — never used as ZA rank truth (labels on every dependent row).
- **NOT VERIFIED** = everything requiring sources 1–4, 6, 8–13 above.
- Zero writes: no Shopify mutation, no external-platform change, no theme edit, no robots change, no Semrush/MC/GBP/GSC/Ads touch. Only repo files under `research/` were created, on the designated branch. Attestation in 13-validation-manifest.json.

## D. Limitations that bound every downstream file

1. No ZA-localized SERP, no rankings, no search volumes, no CTR — files 03/05 are observation-only.
2. No reconciliation against the v8.2.1/v8.2.2 crawls or pre-publish QA — "already fixed" claims (dispatch phase 2) could not be checked item-by-item; F-TECH-04 covers the observable index-lag symptoms instead.
3. No GSC/MC/GBP/CrUX — files 06/07/10 record structured evidence gaps with the exact unblocking action.
4. Semrush intentionally skipped by T — demand sizing deferred to GSC access (file 14).
