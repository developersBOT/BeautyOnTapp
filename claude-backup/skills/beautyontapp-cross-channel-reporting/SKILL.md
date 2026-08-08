---
name: beautyontapp-cross-channel-reporting
description: Standardized cross-channel performance reporting for BeautyOnTApp — weekly, monthly, and quarterly report templates with consistent metrics, comparison logic, and output format. Auto-invoke when T says "how are things going", "weekly report", "monthly report", "performance update", "what's working", "dashboard", "MER", "cross-channel", "report", "summary of performance", "how did we do this week/month", or any request for a performance overview across Google Ads + Meta Ads + organic. Forces consistent reporting format so reports are comparable over time. NOT for campaign-level audits (use beautyontapp-ppc-audit-engine or beautyontapp-meta-audit-engine). NOT for GA4 deep dives (use beautyontapp-analytics).
---

# Cross-Channel Performance Reporting

Every report uses the same structure, same metrics, same comparisons. No more one-off formats.

## REPORT TYPES

### Weekly Quick Report (15 min)
Triggered by: "how are things going", "weekly update", "what's working"

**Structure:**
```
WEEK OF [date range]

💰 REVENUE & EFFICIENCY
- Total Revenue: R[X] (WoW: +/-X%)
- Total Ad Spend: R[X] (Google R[X] + Meta R[X])
- MER (Revenue / Ad Spend): [X]x (WoW: +/-X%)
- Blended ROAS: [X]x
- Blended CPA: R[X]

📊 GOOGLE ADS
- Spend: R[X] / R1,000 ceiling
- Conversions: [X] (WoW: +/-X%)
- ROAS: [X]x | CPA: R[X]
- Top campaign: [name] at [X]x ROAS
- Concern: [if any]

📱 META ADS
- Spend: R[X] / R2,000 ceiling
- Purchases: [X] (WoW: +/-X%)
- ROAS: [X]x | CPA: R[X]
- Frequency: [X] (threshold: 3.0)
- Creative fatigue: [yes/no + details]

⚡ ACTIONS NEEDED
- [Prioritized list of 1-3 things to do this week]
```

### Monthly Performance Report (1-2 hours)
Triggered by: "monthly report", "month end review", "how did we do this month"

**Structure:**
All Weekly Quick Report metrics PLUS:

```
📈 MONTH OF [month]

EXECUTIVE SUMMARY
- [3 sentences: what happened, what worked, what needs attention]

REVENUE TREND
- MoM comparison: [current] vs [prior month] vs [same month last year if available]
- Revenue by channel: Google Ads [R/% of total], Meta Ads [R/% of total], Organic [R/% of total]

GOOGLE ADS DEEP DIVE
- Campaign-level table: Campaign | Spend | Conv | CPA | ROAS | WoW Trend
- Budget utilization: R[X] spent / R[ceiling × days] available = [X]%
- Search terms: top 5 converting terms, top 5 wasters added as negatives
- Auction insights: Secret Skin IS trend, Clicks IS trend

META ADS DEEP DIVE
- Campaign-level table: Campaign | Spend | Purchases | CPA | ROAS | Frequency
- Creative performance: best performing ad, worst performing ad, fatigue status
- Audience breakdown: New vs Engaged vs Existing %

CROSS-CHANNEL INSIGHTS
- MER trend (4-week rolling)
- Channel efficiency comparison (Google ROAS vs Meta ROAS)
- Budget allocation recommendation for next month

NEXT MONTH PRIORITIES
- [Numbered list of 3-5 actions]
```

### Quarterly Strategic Review (4+ hours)
Triggered by: "quarterly review", "Q[X] review", "strategic review"

All Monthly Report metrics PLUS:
- QoQ trend analysis
- Budget ceiling challenge assessment (MER > 5.0× sustained?)
- Competitive landscape changes (Secret Skin, Woolworths, Takealot)
- Platform changes affecting strategy
- Tool stack evaluation
- Scaling readiness assessment

## KEY METRICS DEFINITIONS (use consistently)

| Metric | Definition | Source |
|--------|-----------|--------|
| MER | Total Revenue / Total Ad Spend (all channels) | Shopify Revenue / (Google + Meta spend) |
| Blended ROAS | Same as MER but expressed as multiplier | Same calculation |
| Google ROAS | Google Ads "Conv. value" / "Cost" | Google Ads "Conversions" column ONLY |
| Meta ROAS | Meta "Purchase ROAS" | Ads Manager (7d click + 1d view) |
| CPA | Cost / Conversions | Per-platform |
| Frequency | Average times each person saw the ad | Meta Ads Manager |

## COMPARISON LOGIC

- **WoW:** Compare current 7 days vs prior 7 days (same day-of-week alignment)
- **MoM:** Compare current calendar month vs prior calendar month
- **YoY:** Only if post-Feb 23 2026 data available (pre-Feb 23 is bot-inflated)
- **Never compare:** pre-Feb 23 vs post-Feb 23 data
- **Seasonality:** Note payday cycles (25th-month end typically +20-30% revenue), BFCM, Mother's Day

## BENCHMARKS TO COMPARE AGAINST

| Metric | 🔴 Critical | 🟡 Acceptable | 🟢 Strong |
|--------|------------|--------------|----------|
| MER | <1.82× | 1.82-5.0× | >5.0× |
| Google ROAS | <3× | 3-10× | >10× |
| Meta ROAS | <2× | 2-5× | >5× |
| Google CPA | >R300 | R100-R300 | <R100 |
| Meta CPA | >R150 | R72-R150 | <R72 |
| Meta Frequency | >3.0 | 2.0-3.0 | <2.0 |

## BUDGET CEILING MONITORING

Every report must include:
- Current daily run rate vs ceiling (current values in `03_PNCapital_Business_Facts §Advertising Ceilings`)
- If MER sustains >5.0× for 4+ weeks → proactively flag ceiling as bottleneck
- T decides whether to override — never override unilaterally

## CROSS-SKILL INTEGRATION

| Skill | When to reference |
|-------|------------------|
| beautyontapp-google-ads | Google campaign names, account data |
| beautyontapp-meta | Meta campaign names, asset IDs |
| beautyontapp-analytics | GA4 data for organic/direct channel attribution |
| beautyontapp-financial-intel | MER thresholds, CAC ceilings, unit economics |
| beautyontapp-bleeder-detection | Flag any campaign crossing bleeder thresholds during reporting |
