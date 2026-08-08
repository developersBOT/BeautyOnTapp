---
name: beautyontapp-meta-audit-engine
description: Make sure to use this skill whenever T says "audit Meta", "check Meta Ads", "Meta performance", "creative fatigue", "ASC audit", "Advantage+ audit", "frequency check", "EMQ", "Event Match Quality", "ASC cap", "New Customer Ratio", "Andromeda", "Creative Diversity Score", or any request to evaluate Meta Ads performance. EXECUTION ENGINE for Meta. v2 (May 2026) closes 12 gaps vs Foxwell / Motion / Confect / jetfuel.agency / Tag Hero / Snow Media / Stormy.ai — Andromeda/GEM/Lattice model, EMQ floors (Purchase ≥ 8.0, AddToCart ≥ 6.5), ASC existing-customer cap, 4-signal creative-kill rule, Creative Diversity Score (≥ 8 concepts), domain restriction screen, Pixel+CAPI dedup parity, AEM priority audit, placement breakdown, scaling-readiness 4-check, Threads ads SA status, account-level "6% of ads carry majority of spend" health. Always load with beautyontapp-meta, beautyontapp-meta-algorithm-intel, beautyontapp-meta-creative-testing, beautyontapp-bleeder-detection.
---

# BeautyOnTApp Meta Audit Engine v2 (May 2026)

## What changed in v2

Audit the right layer for the post-Andromeda era. Under the Oct 2025 full rollout of Andromeda (retrieval) + GEM (ranking) + Lattice (sequence learning), audience targeting is largely placebo. **Creative is the targeting. EMQ is the fuel. Diversity is the strategy.**

Source: Confect 3,014-advertiser study ($834M spend, 1M ads, 115.7B impressions, 73 countries) — avg ROAS declined 7% during Andromeda rollout, bottom quartile -31%.

## Required pre-loads

1. `beautyontapp-audit-first`
2. `beautyontapp-evidence-citations`
3. `beautyontapp-bleeder-detection`
4. `beautyontapp-meta` — pixel/CAPI/catalog state
5. `beautyontapp-meta-algorithm-intel` — Andromeda mental model deep dive
6. `beautyontapp-meta-creative-testing` — UGC + hook framework

## Hard constraints (never violate)

- Never create new Meta Pixels — audit only
- Never start new campaigns on Maximise Conversions
- Never touch Analyzify v4 directly — escalate CIP gaps to T
- Content ID = Shopify ID (NOT Variant ID) — `retailer_id` in Catalog
- Pre-Feb 23 2026 data unreliable — calibrate against post-Feb 23 only
- Never use Claude in Chrome with Meta Business Suite open if banking/Shopify admin also open in same window (ClaudeBleed)

## Section 1 — Andromeda mental model (the foundation)

**Order of operations inside Meta's stack:**
1. Andromeda decides which ads are eligible first — 4× more efficient than predecessor, 10,000× model complexity
2. GEM ranks + prices
3. Lattice handles sequence learning

**Implications:**
- Manual interest stacking is dead. Use broad.
- Audience size doesn't matter — creative does.
- Entity ID matters: Meta groups visually similar ads (same background / creator) under one ID. To diversify, change format / hook / talent / body — NOT headline copy.
- Structure: 1 campaign / 1-2 ad sets / 10-20 truly distinct creatives.

## Section 2 — EMQ audit (hard floors)

**Floors:**
- Purchase ≥ 8.0
- AddToCart ≥ 6.5
- Real 10/10 doesn't exist. 9.2-9.4 best in class.

**Weekly check (Events Manager → Data Sources):**

| Event | EMQ | CIPs flowing | Connection Method | Status |
|---|---|---|---|---|
| ViewContent | _ | _ | _ | _ |
| AddToCart | _ | _ | _ | _ |
| InitiateCheckout | _ | _ | _ | _ |
| Purchase | _ | _ | _ | _ |

**CIPs to verify (hashed, server-side via Analyzify v4):** email, phone, fn, ln, ct, st, zp, country, external_id, fbc, fbp

**Connection Method for Purchase must = "Multiple"** (Pixel + CAPI dedup'd). Browser-only and Server-only volumes < 10% of total.

**Deduplication parity:** `event_id` must match across Pixel and CAPI events. Verify via Test Events tool.

**Action if Purchase < 8.0:**
1. Capture which CIPs are missing
2. Compare to Analyzify v4 server-side payload spec
3. Escalate to T — do NOT touch Analyzify directly

## Section 3 — Aggregated Event Measurement (AEM) audit

Events Manager → Aggregated Event Measurement for `beautyontapp.com`:

- 8-event priority list
- Purchase = priority 1 (FLAG if not)
- Optimization events (priorities 2-4) match active campaign objectives
- No orphan events (listed but not firing)
- `event_id` set on all 8 events

Quarterly audit. Update if campaign mix changes.

## Section 4 — ASC (Advantage+ Shopping) cap audit

**Required setting per ASC campaign:**

| Brand | Existing-customer cap | Reason |
|---|---|---|
| BeautyOnTApp | 20% | Acquisition-led at current scale |
| Pastry Skincare | 30% | Higher repurchase, 60-80% margin product |

**Existing customer source:** Shopify customer list (orders > 0) — re-upload monthly.

**New Customer Ratio target:** ≥ 65% measured weekly. If < 65%, lower cap by 5%.

Without cap: ASC spends most budget retargeting people who would have bought anyway. Inflated ROAS, minimal incremental revenue.

## Section 5 — 4-signal creative-kill audit (weekly)

For each active ad (7-day window):

| Signal | Threshold |
|---|---|
| Frequency | > 3.0 |
| First-Time Impression Ratio | < 50% |
| CTR vs peak | declined ≥ 20% |
| Hook Rate (3-sec views / impressions) | < 25% |

**Any 3 of 4 = KILL**
**Any 2 of 4 = ITERATE** (different hook on same body, OR different talent on same script — NEVER just headline copy change)

## Section 6 — Creative Diversity Score (CDS) — monthly

Count distinct Entity-ID-eligible concepts in last 30 days per active campaign.

**Target: ≥ 8 concepts per active BoT campaign.**

Tag every active ad with three dimensions:

1. **Format** — static / video / carousel / UGC
2. **Hook archetype** — problem / social-proof / demo / founder / transformation
3. **Talent type** — founder / UGC creator / professional

Pass = ≥ 4 distinct combinations per active ad set; ≥ 8 across the account.

Per Motion 2026 Benchmarks (550K ads, 6K advertisers, $1.3B spend Sept 2025–Jan 2026): ~50% of ads receive no spend, 6% carry the majority. Need ~10 concepts shipped/month to find 1 winner at 5-10% winner rate.

## Section 7 — Scaling readiness 4-check

Before scaling any ad set:

1. ≥ 50 conversions in 7 days
2. 7-day ROAS ≥ campaign target + 20%
3. Frequency < 2.5
4. Hook Rate ≥ 30%

All 4 must be true. Scale 20-30% every 3 days. Reset to baseline if performance drops > 25%.

## Section 8 — Placement breakdown audit (weekly)

Ads Manager → Breakdown → Placement (7-day window):

- Flag any placement with > 20% of spend AND (CTR or CVR) < 50% of account average
- Reels typically wins prospecting for beauty; Feed wins retargeting
- Audience Network — flag if > 10% spend share without clear performance justification

## Section 9 — Domain health + restriction screen

Events Manager → Data Sources → Pixel:
- Any "Limited Data Use", "Restricted", or "Health & Wellness" badges → FLAG immediately
- Q1 2026 saw 34% spike in health-related rejections vs Q4 2025 per Zappush
- BoT cosmetic claims = safe. Anti-acne / anti-aging "medical" claims / supplement = restriction risk.
- No documented case of category-removal-through-appeal for genuine health-product brands.

**Action if restricted:** copy + landing page audit — strip medical efficacy language. EMQ collapses to ~5/10 under restriction; recovers to 8.5-9 with proper server payload after appeal.

## Section 10 — Account-level ad health: "6% rule"

Weekly check:
- Total ads active
- Ads with spend in last 7 days
- Ads carrying ≥ 80% of spend (the "6% winners")

If ≤ 3 ads carrying 80% of spend across the account: creative velocity gap. Increase shipping cadence to 6-10 new concepts/month minimum.

## Section 11 — Pixel + CAPI dedup parity (Connection Method)

Events Manager → Overview → Connection Method column:

- Purchase should show "Multiple"
- Inspect by event_id: browser + server events should pair 1:1

If not paired: Meta double-counts → inflated ROAS in Ads Manager. Audit Analyzify v4 server payload (escalate to T).

## Section 12 — Threads ads status

**NOT VERIFIED in South Africa as of May 2026.** Do not allocate budget. Quarterly check Meta announcements.

## Output format

**Page 1 — Bottom line:**
- 12-section health (Pass/Fail/Watch) summary
- EMQ scorecard
- Creative Diversity Score
- ASC cap status (BoT + Pastry)
- Top 5 fixes ranked by ZAR impact

**Page 2 — Creative:**
- 4-signal kill audit results — what to kill, what to iterate
- Diversity tag matrix
- Top concept winners (the 6%) — what's working

**Page 3 — Tracking + structure:**
- EMQ per event
- AEM priority list
- ASC cap settings
- Placement breakdown

**Appendix:** Full diagnostics, Test Events screenshots, ad library tag dump

## When NOT to use this skill

- Single creative copy review → `beautyontapp-meta-creative-testing`
- "Why did CPA spike yesterday" → `beautyontapp-meta-algorithm-intel`
- Pixel install / CAPI debug → `beautyontapp-meta`
- Google Ads audit → `beautyontapp-ppc-audit-engine`
- Competitor creative spy → `beautyontapp-meta-competitive-creative`

## Anti-patterns (override generic best practice)

- "Add 5 lookalike audiences" → Andromeda makes this placebo. Use broad.
- "Test 30 headline variants" → Same Entity ID under Andromeda. Diversify format/hook/talent instead.
- "Pause this ad because CPA went up Day 1" → see `beautyontapp-bleeder-detection`
- "ASC will auto-optimize" → Without existing-customer cap, ASC over-retargets. Set cap.
- "Subscribe to Triple Whale to measure incrementality" → NEVER below the true Meta monthly budget threshold (~R200K/month — see business-facts; verify)
- "Lookalike from purchasers" without uploading Shopify list to Pixel — wastes the existing-customer-cap mechanism
