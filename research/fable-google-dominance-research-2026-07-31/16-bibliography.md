# 16 — Bibliography

Every source inspected in this investigation, with exact path/URL, type, access timestamp (UTC, 2026-07-31), and limitation. No training-memory claims were used for PNCapital-, BeautyOnTApp-, competitor-, product-, store-, price-, ranking-, demand- or platform-state facts (dispatch anti_training_memory clause honored).

## Primary inputs

| Source | Type | Path/identifier | Accessed | Limitation |
|---|---|---|---|---|
| Investigation dispatch | uploaded file | `/root/.claude/uploads/74b7707f-.../7fa51ca0-fable5googledominanceresearchinvestigation.xml` — SHA-256 `cf6eb002…841fd`, 21,263 B, 142 lines | 04:40Z, read in full | Its embedded business claims (theme id, MC account, campaign id) are first-party context claims; theme id/name/role independently verified via Shopify this session; MC/campaign ids unverifiable this session |
| T directive | user message this conversation | "Skip semrush" | ~05:12Z | Standing for this investigation only |

## First-party platform readbacks (verified facts)

| Source | Type | Scope | Accessed | Limitation |
|---|---|---|---|---|
| Shopify shop record | MCP `get-shop-info` | name/domain/plan/currency/tz/country | 04:43Z | Point-in-time |
| shopify-theme-config.json | read-only Admin GraphQL (agent) | 5 themes; 7 SEO theme files incl. full robots.txt.liquid; layout head extracts; 8 domains; 3 markets; 9 publications; 7 locations | 04:46:58Z | `appInstallations`/`scriptTags` access denied (token scope) — app installs indirect only; secondary-domain redirect behavior not exposed by queried fields |
| shopify-products-quality.json | read-only Admin GraphQL (agent) | 1,760 products; 1,623 active fully scanned (7×250 pages, hasNextPage=false) | 04:46:58Z run | Barcode = first-variant proxy; descLen counts raw HTML chars; Shopify count responses showed a 1-product internal discrepancy (1759 vs 1760) |
| shopify-content-architecture.json | read-only Admin GraphQL (agent) | 525/525 collections; 10 menus; 32 pages; 1 blog/12 articles; 92 redirects (50 sampled); metafield/metaobject definitions | 04:50:01Z | Page object has no `seo` field (introspected); 42 redirects unsampled; metaobject defs first:50 only |
| repo-app-surface.json | Read/Grep/Glob over local clone @ commit 270527c (agent) | app ids, signing, deep links, WebView, pubspec | 05:02:13Z | Repo-only; live store listings and served assetlinks/AASA files not fetchable; minSdk/targetSdk resolve only at build time |

## Observed snapshots (never rank truth)

| Source | Type | Scope | Accessed | Limitation |
|---|---|---|---|---|
| websearch-brand.json | harness WebSearch (agent) | 10 brand/site queries; 22 own-URL indexed titles; app/social/legacy-domain observations | 04:51–04:53Z | US datacenter; flat link lists; no SERP features rendered; snippets are tool synthesis — only titles/URLs cited as observations |
| websearch-category.json | harness WebSearch (agent) | 10 ZA-commercial queries; competitor frequency table (15 domains) | 04:55–04:56Z | Same; ZA-localized ordering NOT VERIFIED; list position ≠ rank |
| websearch-local.json | harness WebSearch (agent) | 7 store + 2 shopping queries | 05:00Z run | Same; tool cannot render local packs/GBP artifacts — absence proves nothing |

## Blocked-source records (evidence of denial, kept as artifacts)

| Artifact | Records | Accessed |
|---|---|---|
| source-probes.json | All 12 dispatch-source probes with exact denial text/timestamps | 04:41–04:45Z |
| psi-fetch-log.txt + psi-home/collections-korean-skincare/collections-skincare/pages-locations .BLOCKED.json | PSI v5 keyless attempts, HTTP 429 "Queries per day", project 583797351490 | 05:01–05:09Z |
| Semrush MCP responses (7 toolkits) | "active subscription… not enough API units", remediation URL semrush.com/mcp-access | 04:44Z |
| Agent proxy status endpoint | connect_rejected 403 for beautyontapp.com:443 (×3) and www.google.com:443 | 04:42Z |
| WebFetch responses | HTTP 403 for beautyontapp.com/, /robots.txt, developers.google.com AI-features doc, apps.apple.com listing | 04:41–04:47Z |

## Not consulted (and why)

- Official Google Search Central / Merchant / GBP / CWV documentation: unreachable this session (WebFetch 403). Consequence honored: **no platform-mechanics or eligibility claim citing "current official documentation" appears in any file**, and no robots recommendation is made (dispatch P3).
- Screaming Frog v8.2.1/v8.2.2 exports, Business Facts, pre-publish QA record: macOS-local, unreachable — dependent reconciliations labeled NOT VERIFIED.
- Semrush data: skipped per T.

All evidence artifacts live in the session scratchpad (`…/scratchpad/evidence/`, two case-variant dirs — hashes in 00-source-manifest.md §B) and are reproducible from the workflow journal `wf_e423eff3-8d7` (8 agents, 160 tool uses, 0 errors).
