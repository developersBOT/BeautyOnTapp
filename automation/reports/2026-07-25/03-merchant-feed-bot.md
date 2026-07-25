---
agent: merchant-feed
brand: bot
date: 2026-07-25
run_id: 03-merchant-feed-2026-07-25-blocked
data_sources_used: []
data_gaps:
  - "Shopify MCP connector: token expired, server returns 'requires re-authorization' on every call. Zero product data could be read and zero writes attempted."
  - "Google Merchant Center: no API/connector in this environment (recommend-only by design)."
  - "Outbound HTTPS blocked by the environment network policy (403 CONNECT at the proxy), so live product pages could not be fetched as a fallback."
---

## Summary

- **Run blocked. Zero products audited, zero fixes applied, zero writes attempted.**
- The Shopify connector's token is **expired** and requires human re-authorization. Verified directly this run: `get-shop-info` returned `requires re-authorization (token expired)`.
- This is the **third consecutive run** affected — agent 01 lost Pastry MER to it, agent 02 lost the entire on-site audit, and this agent could do nothing at all. Merchant/Feed is 100% Shopify-dependent, so there is no degraded mode available.
- Agent 02's handoff list is **preserved verbatim below** and is ready to execute the moment auth is restored. No work has been lost — only delayed.
- **No fabrication:** no product counts, feed-health figures, or attribute statistics appear in this report, because none could be observed.

## Findings

- **[C] Shopify connector unauthenticated — blocks this agent entirely** (impact 5 / effort 1). Evidence: `mcp__…__get-shop-info` → `MCP server requires re-authorization (token expired)`. Effort is 1 because the fix is a single re-authorization in claude.ai connector settings; impact is 5 because agents 01, 02 and 03 all degrade without it and agent 03 cannot function at all.
- **[H] `switch-shop` is the confirmed trigger of the outage** (impact 4 / effort 2). Agent 01 called it mid-run to reach Pastry and the token was revoked immediately after. Sequencing rule for every future run, already adopted by agent 02 and this agent: **complete all BeautyOnTApp writes first, commit, then attempt Pastry last** — so a repeat failure costs Pastry's slice, never both brands. `switch-shop` was deliberately NOT called this run.
- **[M] Feed health is entirely unmeasured for a third day** (impact 3 / effort 1). GTIN/MPN coverage, `google_product_category`, `product_type`, image alt text, meta descriptions, and description word counts remain unknown for the whole catalogue. Unknown is not the same as healthy — this is an unmeasured surface, not a clean one.

## Auto-Applied Changes

none

*(No writes were attempted. The connector was verified dead before any mutation was considered, per the config guardrail `on_uncertainty: escalate`.)*

## Recommendations

1. **Re-authorize the Shopify connector** in claude.ai connector settings. Single highest-leverage action available today — it unblocks three agents at once.
2. **Adopt the BoT-first sequencing permanently.** Until the `switch-shop` revocation behaviour is understood, every Shopify-touching agent must finish and commit BeautyOnTApp before attempting Pastry.
3. **Treat Pastry as possibly out of reach from this connector.** Agent 02 flagged that `pastryskincare.co.za` may be a separate Shopify org or mid-migration. After any future `switch-shop`, call `get-shop-info` and confirm the domain **before** writing anything.

## Queued work — ready to execute when auth returns

Handed over by agent 02 (SERP-observed; a verified starting set, **not** a complete catalogue list — enumerate fully once connected).

**Job 1 — product meta titles.** Rule: `[Brand] [Product] [Size/Variant] | BeautyOnTApp`, ≤60 chars, brand always present, pipe separator.

| Product handle | Proposed title | Chars |
|---|---|---|
| `cosrx-advanced-snail-mucin-power-essence-100ml` | COSRX Advanced Snail Mucin Essence 100ml \| BeautyOnTApp | 55 |
| `cosrx-advanced-snail-mucin-gel-cleanser-150ml` | COSRX Snail Mucin Gel Cleanser 150ml \| BeautyOnTApp | 51 |
| `cosrx-mucin-essence-cream` | COSRX Snail Mucin Essence + Cream Set \| BeautyOnTApp | 52 |
| `cosrx-all-about-snail-kit` | COSRX All About Snail Kit SA \| BeautyOnTApp | 43 |
| `beauty-of-joseon-revive-ginseng-snail-mucin-serum` | Beauty of Joseon Ginseng Snail Serum \| BeautyOnTApp | 51 |
| `pastry-skincare-glycolic-acid-body-wash-pomegranate-fragrance` | Pastry Glycolic Acid Body Wash Pomegranate \| BeautyOnTApp | 57 |

**Job 2 — collection meta title.** `/collections/make-up`: 78 chars with the brand duplicated → `Makeup South Africa | Korean & Local Cosmetics | BeautyOnTApp` (61).

**Job 3 — audit fresh once connected** (invisible to agent 02, all inside this agent's allowlist): meta descriptions across products and collections, image alt text, description word counts (<300 words = Medium gap), `google_product_category`, `product_type`, missing GTIN/MPN.

**Explicitly out of scope — do not do these:** merging/redirecting/renaming the duplicate collection pairs (`best-seller`/`best-sellers`, `mzuri`/`mzuri-skin`, `cosrx`/`cosrx-1`); changing the "7 SA Locations" store count; any price, status or bulk change; creating `/collections/south-african-brands`.

## Handoff

**→ Agent 04 (Analyst/Solutions):** Merchant/Feed contributed **no data** today — do not treat the absence of feed findings as a clean feed. The catalogue is unmeasured, not healthy. The connector outage is now a three-run pattern and belongs in your root-cause analysis as an operational blocker, not a marketing finding.

**→ Agent 05 (Keywords + Negatives):** No `google_product_category` or `product_type` data is available, so do not attempt feed-driven keyword mapping this run.

**→ Agent 06 (Revenue Expansion):** Escalate **re-authorizing Shopify** as the top operational action of the day — it is one click and unblocks three agents. Agent 02 separately recommends leading the digest with the connector outage rather than with findings; this run corroborates that. Note also that the queued title fixes are cheap, reversible, and immediately executable once auth returns.
