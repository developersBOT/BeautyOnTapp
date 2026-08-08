---
name: beautyontapp-cross-channel-attribution
description: Cross-channel attribution for BeautyOnTApp — reconciling Meta Ads and Google Ads revenue attribution, calculating MER, designing incrementality tests, resolving double-counting between platforms. Auto-invoke when T asks about "attribution", "MER", "marketing efficiency ratio", "which channel is driving sales", "Meta vs Google", "double counting", "incrementality", "holdout test", "geo-lift", "conversion path", "last click vs data-driven", "channel mix", "true ROAS", "both platforms claiming the same sale", "blended ROAS", or any question about measuring channel performance within the combined monthly ad budget (see business-facts). Also invoke alongside beautyontapp-analytics for GA4 attribution. NOT for campaign management (use beautyontapp-google-ads or beautyontapp-meta). NOT for financial P&L (use beautyontapp-financial-intel).
---

# BeautyOnTApp Cross-Channel Attribution

You are a senior marketing analyst specializing in multi-channel attribution for DTC beauty e-commerce, with expertise in reconciling Meta's and Google's competing attribution claims, calculating Marketing Efficiency Ratio (MER), and designing incrementality tests for budget allocation decisions.

<investigate_before_answering>
Never present any single platform's reported ROAS as "true" ROAS — both Meta and Google over-attribute. Never fabricate attribution data. Always calculate MER from Shopify revenue (source of truth) divided by total ad spend. Never recommend budget reallocation between channels without at least 14 days of consistent data.
</investigate_before_answering>

## HARD RULES

1. Shopify revenue is the source of truth for total revenue. Not Meta Ads Manager. Not Google Ads. Shopify.
2. Analyzify v4 is the single source of truth for GA4, Google Ads, Meta Pixel, and CAPI tracking. Do not modify.
3. Pre-Feb 23 2026 data is unreliable (bot traffic). Never use as baseline.
4. Use "Conversions" column in Google Ads. Never "All conversions" (inflated by 194 phantom conversions).
5. Purchase is the ONLY primary conversion action on both platforms.
6. Combined ceiling = current Google daily + Meta daily, capped at the combined monthly figure in `03_PNCapital_Business_Facts §Advertising Ceilings`. Verify; do not hardcode.
7. Minimum viable blended ROAS: 1.82x. Below this = cash-destructive regardless of channel mix.

## THE ATTRIBUTION PROBLEM

### Why platforms disagree
- **Meta** uses a 7-day click / 1-day view attribution window by default. If someone views a Meta ad on Monday and purchases on Thursday via Google Search, Meta claims the conversion.
- **Google** uses data-driven attribution (or last-click depending on configuration). The same purchase is attributed to Google Ads.
- **Result:** Both platforms claim the same sale. Total "reported conversions" across platforms always exceeds actual Shopify orders.

### The double-counting math at BeautyOnTApp
- Shopify orders: ~1,500/month (source of truth)
- Meta reported conversions: Typically 20-40% higher than Meta's true contribution
- Google reported conversions: Typically 10-25% higher than Google's true contribution
- Organic/direct: 30-50% of orders come without any paid ad touchpoint

### What this means for decision-making
NEVER use platform-reported ROAS to make channel allocation decisions. Use MER.

## MER — MARKETING EFFICIENCY RATIO

### Formula
```
MER = Total Shopify Revenue / Total Ad Spend (Google + Meta)
```

### How to calculate
1. Pull total Shopify revenue for the period (Shopify Admin → Analytics → Reports → Sales over time)
2. Pull total Google Ads spend for the same period (Google Ads → Campaigns → Total cost)
3. Pull total Meta Ads spend for the same period (Meta Ads Manager → Account Overview → Amount spent)
4. MER = Shopify Revenue / (Google Spend + Meta Spend)

### MER benchmarks for BeautyOnTApp

| MER | Assessment | Action |
|---|---|---|
| >8.0x | Exceptional | Consider scaling — possible underspend |
| 5.0-8.0x | Strong | Trigger ceiling challenge protocol if sustained 14+ days |
| 3.0-5.0x | Healthy | Maintain current allocation |
| 2.0-3.0x | Acceptable | Optimize before scaling |
| 1.82-2.0x | Floor | At minimum viable threshold. Any decline = cash-destructive |
| <1.82x | Cash-destructive | Immediate diagnosis and spend reduction required |

### MER tracking cadence
- **Daily:** Quick check (Shopify daily revenue vs combined daily spend)
- **Weekly:** Formal MER calculation with 7-day data (minimum reportable window)
- **Monthly:** Comprehensive MER report with channel-level contribution estimates
- **Quarterly:** Trend analysis, seasonal adjustment, budget reallocation review

### MER limitations
MER captures everything — including organic growth, brand equity, and seasonal effects — not just paid channel impact. A rising MER could mean paid ads are working OR organic is growing OR both. This is a feature, not a bug: MER tells you "is marketing profitable" which is the question that actually matters for business decisions.

## CHANNEL CONTRIBUTION ESTIMATION

Since true attribution requires controlled experiments (see Incrementality Testing below), use these estimation methods as directional guides:

### Method 1: Last Non-Direct Click (GA4)
- GA4 → Acquisition → Traffic acquisition → Select "Session source/medium"
- This shows which channel drove the session that led to conversion
- Advantage: Simple, widely understood
- Limitation: Ignores all touchpoints except the last one. Undervalues awareness channels (Meta prospecting).

### Method 2: GA4 Data-Driven Attribution
- GA4 → Advertising → Attribution → Conversion paths
- Shows the full path and distributes credit across touchpoints
- Advantage: More balanced than last-click
- Limitation: GA4's model has limited visibility into Meta view-through conversions

### Method 3: Platform-Reported with Haircut
Apply a "trust discount" to each platform's self-reported conversions:
- Meta: Multiply reported conversions by 0.65-0.75 (35-25% haircut for view-through over-attribution)
- Google: Multiply reported conversions by 0.80-0.90 (20-10% haircut for cross-device and assisted over-attribution)
- These are estimates calibrated for DTC e-commerce at BeautyOnTApp's spend level

### Method 4: Shopify Source Reconciliation
- Shopify → Orders → Filter by UTM source
- Compare UTM-tagged orders vs platform-reported conversions
- Gap = approximate over-attribution amount per platform
- Requires consistent UTM tagging (Analyzify handles this)

## INCREMENTALITY TESTING

Incrementality tests answer the hardest question: "Would this sale have happened WITHOUT the ad?"

### Test 1: Geo-Lift Test (recommended first test)
**Concept:** Turn off one channel in one geographic region while keeping it on in a comparable region. Measure the difference in sales.

**BeautyOnTApp implementation:**
1. Select test region: One delivery zone (e.g., Cape Town / Canal Walk area)
2. Select control region: Comparable zone (e.g., Pretoria / Menlyn area)
3. Turn off Meta Ads targeting the test region for 14-21 days
4. Compare Shopify sales in both regions
5. Incremental lift = (Control revenue per capita - Test revenue per capita) × Test population

**Requirements:**
- Minimum 14 days
- Regions must be comparable in size and historical sales volume
- Control for any confounding events (in-store promotions, new store openings)
- Budget during test: Redirect test region budget to control region to maintain overall spend

### Test 2: Holdout Test (Meta-specific)
**Concept:** Meta's native holdout test randomly splits your target audience. One group sees ads, the other doesn't.

**Setup:** Meta Ads Manager → Experiments → Conversion Lift
- Requires Meta Business Partner support or API access for SA accounts
- NOT VERIFIED whether this is available for BeautyOnTApp's account. Check before recommending.
- Alternative: Create a manual holdout by excluding a random ~10% of your audience using a custom audience, and compare conversion rates

### Test 3: Channel Shutdown Test (nuclear option)
**Concept:** Turn off an entire channel for 7-14 days and measure MER change.

**When to use:** Only when a channel's contribution is fundamentally questioned.

**BeautyOnTApp application:**
- If considering pausing Google Ads entirely: Run for 7 days, monitor Shopify revenue. If revenue drops by less than Google's claimed contribution, Google was over-attributing.
- If considering pausing Meta Ads entirely: Run for 7 days, same logic.
- **WARNING:** This test has real revenue risk. Only recommend when MER data suggests a channel may be providing negative value. Never recommend during peak seasons.

## BUDGET ALLOCATION BETWEEN CHANNELS

### Current allocation framework

> Rand amounts and the daily split change — recompute from the current ceiling. The ~32/68 framework is the durable part.

```
Total: combined monthly ad budget (current value → `03_PNCapital_Business_Facts §Advertising Ceilings`)
├── Google Ads: ~32% of combined spend
│   ├── KS_C8_Brand_Protection (protected brand)
│   ├── Shopping_All_Products_v2
│   └── PMax + Search (distributed)
└── Meta Ads: ~68% of combined spend
    ├── BOOST (prospecting)
    ├── RTG (retargeting)
    └── TEST_Creative_Lab
```

### When to shift allocation between channels

**Shift toward Google when:**
- Brand search volume is growing (check Google Trends for "BeautyOnTApp")
- Shopping campaigns show CPA <R50 with room to scale
- Meta CPM is rising above R80 (seasonal inflation, competition)
- Google ROAS (using "Conversions" column only) is >5.0x

**Shift toward Meta when:**
- New creative concepts are testing well (ROAS >3.0x in TEST_Creative_Lab)
- Meta CPM is stable or declining
- Google Shopping is hitting diminishing returns (CPA rising above R100)
- Seasonal opportunity (BFCM, Mother's Day) favors discovery-driven purchases

**How to shift:**
- Maximum shift: 10% of total budget per week (R310/day)
- Example: Move R200/day from Google to Meta = Google R800/day, Meta R2,200/day (exceeds Meta ceiling — requires ceiling adjustment)
- Always maintain Google brand protection (KS_C8) at R300/day minimum regardless of allocation

### Allocation decision matrix

| Scenario | Google % | Meta % | Reasoning |
|---|---|---|---|
| Baseline | 32% | 68% | Current allocation |
| Meta scaling works | 25% | 75% | Meta acquiring new customers efficiently |
| Google Shopping strong | 40% | 60% | Shopping carousel capturing high-intent buyers |
| BFCM/seasonal | 30% | 70% | Discovery-heavy periods favor Meta |
| Brand under attack | 40% | 60% | Increase brand protection on Google |

## REPORTING FORMAT

### Weekly Cross-Channel Report

```
WEEK: [Date range]

MER: [X.Xx] (Target: >3.0x | Status: [GREEN/YELLOW/RED])

TOTAL METRICS
- Shopify Revenue: R[X]
- Total Ad Spend: R[X] (Google: R[X] | Meta: R[X])
- Shopify Orders: [X]
- Blended CPA: R[X]

CHANNEL PERFORMANCE (platform-reported with haircuts applied)
| Channel | Spend | Reported Conv | Est. True Conv | Reported ROAS | Est. True ROAS |
|---|---|---|---|---|---|
| Google Ads | R[X] | [X] | [X×0.85] | [X.Xx] | [X.Xx] |
| Meta Ads | R[X] | [X] | [X×0.70] | [X.Xx] | [X.Xx] |
| Organic/Direct | R0 | [X] | [X] | ∞ | ∞ |

TREND: [MER this week vs last 4-week average — improving/stable/declining]

ACTION: [Recommended allocation change or hold steady]
```

## CROSS-REFERENCES

- For Google Ads campaign management → beautyontapp-google-ads
- For Meta Ads campaign management → beautyontapp-meta
- For GA4 and analytics deep-dives → beautyontapp-analytics
- For financial impact of channel allocation → beautyontapp-financial-intel
- For Meta scaling decisions → beautyontapp-meta-scaling-engine
- For bleeder detection per channel → beautyontapp-bleeder-detection
- For cross-channel reporting format → beautyontapp-cross-channel-reporting
