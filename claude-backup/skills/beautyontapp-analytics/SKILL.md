---
name: beautyontapp-analytics
description: GA4 dashboard reading, Analyzify v4 report interpretation, attribution modeling, Meta Ads Manager metrics, Google Ads performance analysis, and cross-channel diagnosis for BeautyOnTApp and Pastry Skincare. Make sure to use this skill whenever T asks 'what's working', 'how are we performing', 'read this report', 'what does this metric mean', attribution, conversion rate, bounce rate, sessions, traffic source, channel breakdown, GA4, dashboard, 'why did sales drop', 'compare this week', or shares screenshots/exports from GA4, Ads Manager, or Shopify Analytics. NOT for pause/keep decisions (use bleeder-detection).

---

# BeautyOnTApp Analytics and Performance Diagnosis Skill

Multi-channel performance diagnosis for beauty e-commerce. Read GA4 dashboards, Analyzify reports, Meta Ads Manager exports, Google Ads reports, and Shopify Analytics — then translate data into actionable decisions for BeautyOnTApp, Pastry Skincare, and Mzuri Skin.

<investigate_before_answering>
Never fabricate metrics, conversion rates, traffic numbers, or revenue figures. If T shares a screenshot or export, read exactly what is shown — do not extrapolate or assume missing data. If asked about current performance without data provided, say: "I don't have live data — can you share a screenshot or export?" Pre-Feb 23 2026 data is unreliable (bot traffic). NEVER use pre-Feb 23 data as a baseline for any analysis.
</investigate_before_answering>

## INHERITED RULES

All hard rules from beautyontapp-business-rules apply. Key constraints for this skill: Purchase = ONLY primary conversion event. Analyzify v4 = single source of truth. Pre-Feb 23 2026 data unreliable. SA benchmarks only — never US/EU. See business-rules skill for full rule sets.

## THE TRACKING STACK — What Measures What

| Layer | Tool | What It Measures | What It Does NOT Measure |
|---|---|---|---|
| Analyzify v4 | GA4 events, Google Ads conversions, Meta Pixel, Meta CAPI | All conversion tracking, all attribution | Product feeds |
| GA4 | Sessions, users, traffic sources, funnels, events, attribution | Full customer journey | Ad-platform-specific metrics (use Ads Manager) |
| Meta Ads Manager | CPM, CTR, CPC, CPA, ROAS, frequency, delivery | Meta-specific campaign performance | Google Ads or organic performance |
| Google Ads | CPC, CTR, ROAS, impression share, search terms | Google-specific campaign performance | Meta or organic performance |
| Shopify Analytics | Revenue, orders, AOV, top products, sales by channel | Transaction data, product performance | Attribution (use GA4), ad metrics |
| Simprosys | Product feed health, disapprovals, feed sync status | Feed quality only | Zero tracking — never use for analytics |

### Source of Truth Hierarchy

When numbers conflict across platforms (and they will):
1. **Revenue**: Shopify Analytics = ground truth (actual transactions)
2. **Conversions**: Analyzify/GA4 = primary attribution source
3. **Campaign metrics**: Use each platform's native reporting (Meta for Meta, Google for Google)
4. **Traffic**: GA4 = primary (with Cloudflare bot filtering since Feb 23)

### Why Numbers Disagree

| Situation | Why | What To Do |
|---|---|---|
| Meta reports more conversions than GA4 | Meta uses 7-day click / 1-day view window. GA4 uses last-click by default. | Compare using GA4's data-driven attribution, not last-click. |
| Google Ads reports more conversions than GA4 | Google Ads uses its own conversion window and may count assists differently. | Use Analyzify-fed GA4 as tiebreaker. |
| Shopify revenue > sum of GA4 channel revenue | GA4 may miss some direct/unattributed transactions. | Shopify revenue is the real number. GA4 shows the journey. |
| Traffic spiked but conversions didn't | Bot traffic or low-quality traffic source. Check if date range includes pre-Feb 23 data. | Filter to post-Feb 23 only. Check Cloudflare analytics for bot %. |

## GA4 — HOW TO READ IT FOR BEAUTYONTAPP

### Key Reports and What They Tell You

**Acquisition > Traffic Acquisition:**
Shows sessions by channel (Organic Search, Paid Search, Paid Social, Direct, Referral, Email). Use this to answer: "Where is traffic coming from?" and "Which channels convert?" ALWAYS filter to post-Feb 23 2026 date range.

**Acquisition > User Acquisition:**
Shows NEW users by first touch channel. Use this to answer: "How are we acquiring new customers?" and "Is paid social bringing new users or recycling existing ones?"

**Engagement > Events:**
Purchase event = primary KPI. All others (add_to_cart, begin_checkout, page_view) = diagnostic only. Never optimize campaigns for non-Purchase events.

**Monetization > Ecommerce Purchases:**
Revenue, transactions, AOV by product/category. Cross-reference with Shopify Analytics for ground truth revenue.

**Retention > Returning Users:**
New vs returning user split. Target: 30-40% returning users within 12 months (see retention skill).

### GA4 Attribution Models

| Model | When To Use | BeautyOnTApp Default |
|---|---|---|
| Data-driven (DDA) | Best overall — uses ML to distribute credit across touchpoints | YES — use this as primary |
| Last click | Understates top-of-funnel (Meta prospecting looks weak) | Use for comparison only |
| First click | Overstates awareness channels | Rarely useful |

**Critical insight**: Meta prospecting campaigns (ASC_BeautyOnTApp_Main) will ALWAYS look worse on last-click attribution than data-driven. If T asks "is Meta working?" — check data-driven attribution first, not last-click.

### Analyzify-Specific Reports

Analyzify v4 feeds GA4 with enhanced e-commerce events. Key confirmed data points:
- Purchase EMQ: 9.3/10 (confirmed Mar 22, 2026) — excellent quality
- CAPI adds +31.4% additional conversions vs pixel alone
- Event deduplication: 81.43% total coverage
- Content ID = Shopify ID (NOT Variant ID) — matches both Meta catalogs' retailer_id [confirmed live on Analyzify, May 2026]

When reading GA4 purchase data, know that Analyzify is the source — not Shopify's built-in GA4 integration (which was removed). Any GA4 conversion data IS Analyzify data.

## META ADS MANAGER — HOW TO READ IT

### Key Metrics (within current Meta ceiling)

| Metric | What It Tells You | BeautyOnTApp Target | Red Flag |
|---|---|---|---|
| ROAS | Revenue per rand spent | 2x+ by month 2-3 | Below 1.5x for 7+ days |
| CPA | Cost per purchase | Under R500 | Above R500 for 5+ days |
| CPM | Cost per 1,000 impressions | R115-R200 (SA beauty prospecting) | Above R300 (check audience overlap or Q4 competition) |
| CTR | Click-through rate | 1.5%+ | Below 0.8% (creative problem) |
| CPC | Cost per click | Under R30 | Above R50 consistently |
| Frequency | Average times a person saw the ad | Under 3.0 for prospecting | Above 3.0 = fatigue (see meta-ads-playbook kill rules) |
| CVR | Conversion rate (purchases / clicks) | 3.5%+ | Below 2% (landing page or audience problem) |

### Reading Campaign Performance by Structure

| Campaign | What Good Looks Like | What To Check If Bad |
|---|---|---|
| ASC_BeautyOnTApp_Main | Stable CPA, exiting learning, 60-70% of spend | Creative diversity (8+ concepts?), Advantage+ enhancements OFF? |
| RTG_DPA_Funnel | Highest ROAS in account, low CPA | Catalog connected? Audience size shrinking? Overlap with email? |
| TEST_Creative_Lab | Finding winners at controlled cost | Each creative getting equal spend? Kill rules applied? |

### Attribution Window Settings

Meta default: 7-day click, 1-day view. This means Meta claims a conversion if someone clicked an ad in the last 7 days OR viewed one in the last 1 day before purchasing. This is WHY Meta ROAS often looks higher than GA4 — GA4 uses different attribution. Do not change these windows. Consistency is more important than "accuracy." Compare trends, not absolute numbers.

## GOOGLE ADS — HOW TO READ IT

### CRITICAL: Column Selection
**ALWAYS use "Conversions" column — NEVER "All conversions".** 4 Google-hosted actions (Clicks to call, Directions, Other engagements, Website visits) inflate "All conversions" by ~194 phantom conversions. The "Conversions" column only counts Purchase (the only action assigned to campaigns). This applies to all Google Ads reports, CSV exports, and dashboard views.

### Key Metrics for Beauty E-Commerce

| Metric | What It Tells You | BeautyOnTApp Target | Red Flag |
|---|---|---|---|
| Conversion Rate | Purchases / clicks | 3%+ for Shopping, 2%+ for Search | Below 1.5% |
| Search Impression Share | % of available impressions captured | 60%+ for brand terms | Below 40% (budget or bid too low) |
| Search Term Report | Actual queries triggering ads | Relevant beauty/skincare terms | Irrelevant queries eating budget |
| Quality Score | Keyword relevance (Search only) | 7+ for brand terms, 5+ for generic | Below 4 (landing page or ad relevance issue) |

### Campaign-Specific Reading

- **PMax campaigns**: Limited search term visibility. Check asset group performance, audience signals, and product group ROAS. Cross-reference with Merchant Center for disapprovals.
- **Shopping campaigns**: Check Search Term Report for irrelevant queries. Monitor product-level ROAS. See google-ads-playbook for custom label bidding strategy.
- **Search campaigns**: Check Search_BestSellers Final URL = /collections/best-seller (singular, with hyphen — fixed Mar 22, 2026). Monitor quality scores and impression share.

## SHOPIFY ANALYTICS — HOW TO READ IT

### What Shopify Does Best

- **Total revenue**: Ground truth. If GA4 and Shopify disagree on revenue, Shopify wins.
- **Top products by revenue**: Use to validate Pastry Skincare as top revenue driver (21 of 145 bestsellers confirmed).
- **Sales by channel**: Online Store vs Point of Sale vs other channels.
- **AOV**: Average order value. Benchmark and track trends.
- **Returning customer rate**: Cross-reference with GA4 retention reports.

### What Shopify Does NOT Do Well

Attribution (doesn't know which ad drove the sale — use GA4), multi-touch journey analysis (use GA4 path exploration), campaign-level performance (use Ads Manager).

## PERFORMANCE DIAGNOSIS FRAMEWORK

### "Why Did Sales Drop?"

1. **Check date range** — Does it include pre-Feb 23? If yes, filter to post-Feb 23 only.
2. **Check traffic** — GA4 Traffic Acquisition. Did sessions drop? Which channel?
3. **Check conversion rate** — If traffic is stable but CVR dropped, it's a site/offer problem, not a traffic problem.
4. **Check ad spend** — Did budget decrease or campaigns pause? Check both Meta and Google.
5. **Check product availability** — Are bestsellers out of stock? Simprosys out-of-stock exclusion removes ~479 products from feeds.
6. **Check external factors** — SA public holidays, load shedding, payday cycles (25th of month), seasonal patterns.
7. **Check competitors** — Did a competitor launch a sale? (Use sa-competitive-scanner + Meta Ad Library.)

### "Is This Campaign Working?"

1. Use post-Feb 23 data only.
2. Check ROAS against SA beauty benchmarks (see meta-ads-playbook or google-ads-playbook). Never benchmark against US/EU.
3. Compare using data-driven attribution in GA4 — not last-click.
4. Check if campaign has exited learning phase — Meta needs 25-50 Purchase events per ad set per week.
5. Look at trend, not snapshot — 3 bad days is a trend. 1 bad day is noise.
6. Cross-reference platforms — If Meta says ROAS is 4x but GA4 says 1.5x, the truth is somewhere between. GA4 data-driven is the tiebreaker.

### "What Should We Spend More On?"

1. Rank by CPA — Lowest CPA campaigns get more budget first.
2. Check headroom — Is impression share below 60%? Budget increase will capture more.
3. Check learning phase — Only scale campaigns that have exited learning and shown stable CPA for 7+ days.
4. Follow scaling cadence from business-rules skill — Google: 15-20% every 5-7 days. Meta: 20% every 3-5 days.
5. Never exceed the ceilings in `03_PNCapital_Business_Facts §Advertising Ceilings` (Google daily, Meta daily, combined monthly) — verify current values; they change.

### "What's Our Blended Performance?"

| Metric | How To Calculate | Target |
|---|---|---|
| MER (Marketing Efficiency Ratio) | Total Shopify revenue / total ad spend (Google + Meta) | 5:1 to 8:1 |
| Blended CAC | Total ad spend / total new customers | Below R500 |
| Organic share | (Total revenue - ad-attributed revenue) / total revenue | 40-60% |
| Paid share | Ad-attributed revenue / total revenue | 40-60% |

If organic share drops below 30%: Over-dependent on paid. Invest in retention (email, SMS, WhatsApp — see retention skill) before scaling ad spend.

## SA-SPECIFIC ANALYTICS CONSIDERATIONS

### Payday Cycles

SA consumers are paid on the 25th-1st. Expect purchase spikes around month-end and dips mid-month. When comparing week-over-week, always check where in the pay cycle each week falls.

### Load Shedding Impact

Severe load shedding correlates with mobile traffic spikes (people on data) and desktop traffic drops. Monitor device split during stage 4+ periods. Conversion rates typically drop during extended outages.

### Seasonal Patterns

- **Q3 (Jul-Sep)**: Lowest Meta CPMs. Front-load prospecting spend (see v8-gloot-playbook).
- **Q4 (Oct-Dec)**: Highest CPMs, highest revenue. Black Friday/gifting season. CPMs can 2-3x.
- **Jan**: Post-holiday dip. New Year skincare resolutions drive interest but lower spend capacity.
- **Mother's Day (May)**: Gift purchases spike. Push gift sets and Pastry Skincare body care bundles.

### Currency Conversion

When comparing SA metrics to international benchmarks: ~R18.50 = $1 USD. All benchmarks in BeautyOnTApp skills use ZAR unless explicitly stated.

## CROSS-SKILL INTEGRATION

- **beautyontapp-business-rules**: Budget ceilings, scaling cadence, data baseline (post-Feb 23 only). Source of truth for any conflict.
- **beautyontapp-meta**: Campaign names, asset IDs, tracking architecture. Use when diagnosing Meta-specific issues.
- **beautyontapp-google-ads**: Account IDs, campaign structure, Merchant Center. Use when diagnosing Google-specific issues.
- **beautyontapp-shopify**: Analyzify configuration, Simprosys feed health, product/collection data. Use for site-side diagnosis.
- **beautyontapp-retention**: Email/SMS/WhatsApp revenue attribution, organic share targets. Use when assessing retention contribution.
- **beautyontapp-sa-competitive-scanner**: Competitor activity that may explain performance shifts.

## OUTPUT STANDARDS

- When reading a screenshot or export: state EXACTLY what the data shows, then interpret. Never add data that isn't visible.
- When diagnosing: follow the frameworks above in order. State each check and its finding.
- When recommending action: reference the specific campaign/channel, cite the metric that triggered the recommendation, and state the expected impact range.
- Never fabricate metrics. If data is missing, say what's needed to complete the analysis.
- Always specify date range. Always confirm post-Feb 23 baseline.

---

## BEAUTY E-COMMERCE CUSTOM EVENT TAXONOMY

Beyond standard Shopify Enhanced E-commerce, track these beauty-specific events:

| Event | Trigger | Properties |
|---|---|---|
| skin_quiz_completed | Skin quiz submission | skin_type, concerns[], routine_type |
| routine_builder_viewed | Routine builder opened | entry_point, products_shown |
| shade_finder_used | Shade finder tool used | product_id, selected_shade |
| store_locator_clicked | Store locator opened | source_page, nearest_store |
| skin_analysis_booked | BookX booking completed | store_location, service_type, value |
| sample_requested | Sample requested | product_id, skin_type |
| brand_page_viewed | Brand collection viewed | brand_name, entry_source |
| delivery_tracking_opened | Tracking viewed | order_id, delivery_method |

### Multi-Brand Content Groups (GA4)
Set content_group on all events: "beautyontapp" | "pastry_skincare" | "mzuri_skin". Enables cross-brand comparison.

### O2O UTM Strategy
Each store gets unique UTMs: ?utm_source=store&utm_medium=qr&utm_campaign=[location]. Track which stores drive online purchases.
