---
agent: merchant-feed
brand: pastry
date: 2026-07-25
run_id: 03-merchant-feed-2026-07-25-blocked
data_sources_used: []
data_gaps:
  - "Shopify MCP connector: token expired, requires re-authorization. Zero product data read, zero writes attempted."
  - "Unconfirmed whether pastryskincare.co.za is reachable from this connector at all — it may be a separate Shopify org, or mid-migration from WooCommerce."
  - "Google Merchant Center: no API/connector in this environment (recommend-only by design)."
  - "Outbound HTTPS blocked by the environment network policy (403 CONNECT at the proxy), so live product pages could not be fetched as a fallback."
---

## Summary

- **Run blocked. Zero products audited, zero fixes applied, zero writes attempted.**
- The Shopify connector's token is **expired**; verified this run via `get-shop-info` → `requires re-authorization (token expired)`.
- `switch-shop` was **deliberately not called**. Agent 01's use of it is what revoked the token, and with the connector already dead there was nothing to gain and a repeat outage to risk.
- **Pastry carries an extra unknown beyond the outage:** it is unconfirmed that this connector can reach `pastryskincare.co.za` at all. Even after re-authorization, that must be verified before any write.
- Agent 02's handoff list is preserved below, ready to execute once both the auth and the store-reachability question are resolved.

## Findings

- **[C] Shopify connector unauthenticated — blocks this agent entirely** (impact 5 / effort 1). Same root cause as the BoT report. Merchant/Feed has no non-Shopify degraded mode.
- **[H] Pastry store reachability is unverified** (impact 4 / effort 2). Agent 02 could not confirm that `pastryskincare.co.za` is served by the same Shopify org as `beautyontapp.com`, and found it serving **legacy WooCommerce URL shapes alongside Shopify ones** — consistent with an unfinished migration. Until `get-shop-info` returns the Pastry domain after a switch, treat Pastry writes as blocked on verification, not merely on auth.
- **[H] Feed writes here may be wasted work pending a 301 decision** (impact 3 / effort 2). Agent 02 found the same product indexed at both `/product/…` (legacy) and `/products/…` (Shopify). Optimising titles on URLs that are scheduled for redirect is effort spent twice. The redirect decision should precede the attribute work.
- **[M] Feed health entirely unmeasured** (impact 3 / effort 1). GTIN/MPN, `google_product_category`, `product_type`, alt text, meta descriptions and description lengths are all unknown for the Pastry catalogue.

## Auto-Applied Changes

none

*(No writes attempted. Two independent gates were unmet: connector authentication, and confirmation that the connector reaches the Pastry store.)*

## Recommendations

1. **Re-authorize the Shopify connector** (shared with the BoT report — one action, unblocks both brands and three agents).
2. **Then confirm Pastry is reachable**: after `switch-shop`, call `get-shop-info` and check the domain is `pastryskincare.co.za`. If it returns a different store, stop and report — do not write.
3. **Decide the legacy-URL 301s before investing in Pastry attribute work**, so titles are not optimised on pages that are about to redirect.

## Queued work — ready when auth *and* reachability are confirmed

From agent 02 (SERP-observed; a starting set, not the full catalogue).

**Job 1 — collection meta titles.** Rule: `[Concern/Category] [Qualifier] | Pastry Skincare`, ≤60 chars. This mirrors the brand's own existing good pattern (`/products/niacinamide-body-lotion`) — do not invent a new convention.

| Collection | Proposed title | Chars |
|---|---|---|
| `hyperpigmentation` | Hyperpigmentation Body Care South Africa \| Pastry Skincare | 57 |
| `body-wash` | Body Wash for Body Acne & Dark Marks \| Pastry Skincare | 53 |
| `all` | All Products \| SA Body & Face Care \| Pastry Skincare | 51 |
| `collections` (index) | Shop by Concern \| Pastry Skincare South Africa | 46 |

**Job 2 — data defect.** The `body-wash` collection's **title field is literally lowercase** ("body wash"), visible in its SERP title. Correct the casing, and check every other collection for the same defect while connected.

**Job 3 — leave alone, already good:** `/products/niacinamide-body-lotion`, `/products/niacinamide-body-butter`, `/products/glycolic-acid-body-wash`, `/pages/locations`.

**Job 4 — audit fresh once connected:** meta descriptions, image alt text, description word counts (products <300 words = Medium; collections <100 words = High), `google_product_category`, `product_type`, missing GTIN/MPN.

**Explicitly out of scope:** the legacy `/product/…` and `/product-category/…` URLs (pending the 301 decision); any 301/canonical/redirect/noindex work; the homepage title (theme field, not a product attribute); any price, status or bulk change; and **writing anything at all if `get-shop-info` does not confirm the Pastry store**.

## Handoff

**→ Agent 04 (Analyst/Solutions):** No Pastry feed data for a third consecutive run. Pastry now has **three** compounding unknowns: no store revenue, no MER, and an unverified store connection — on top of agent 02's finding that Pastry sells through at least five indexed storefronts. Scope which properties are in play before computing anything for this brand.

**→ Agent 05 (Keywords + Negatives):** No product taxonomy data available; skip feed-driven keyword mapping for Pastry.

**→ Agent 06 (Revenue Expansion):** The Pastry picture is now the thinnest in the fleet — no revenue, no MER, no feed data, an unverified store link, and agent 01's unresolved 100× `omni_purchase_values` anomaly on its prospecting entities. Recommend framing Pastry as **"instrumentation first, decisions second"** in today's digest rather than making spend calls on data this incomplete.
