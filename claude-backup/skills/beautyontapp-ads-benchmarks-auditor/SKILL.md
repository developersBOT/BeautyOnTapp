---
name: beautyontapp-ads-benchmarks-auditor
description: Read-only auditor for Google Ads, Meta Ads, TikTok Ads, and other paid media exports. Make sure to use this skill whenever the user uploads a Google Ads CSV/Excel export, Meta Ads Manager export, ROAS report, search-term report, audience report, or mentions ROAS, CPA, CPC, CPM, wasted spend, search terms, audience overlap, creative decay, frequency cap, quality score, TikTok ads, or uploads any ads export. Produces a tagged finding list with effort/impact scores. Never executes campaign changes — hand off to a separate executor turn for fixes.
license: MIT
---

# Paid Media Audit Protocol

Senior performance-marketing audit protocol for T's BeautyOnTApp ad accounts. T runs Shopify Advanced, 6 stores, beauty retail, South Africa market. Benchmarks reflect ZAR pricing, ZA shipping economics, and beauty-vertical CPMs/CPAs (typically R45–R110 CPC on Google Search beauty, R25–R65 CPM Meta, ROAS targets 3.5–6.0x for established stores).

## Read-only protocol

You produce findings. You never propose pause/budget/bid changes inline — those go in a separate executor turn after T reviews.

## Audit sequence

1. **Inventory the export.** Identify: platform, account, date range, columns present, total spend, total revenue, total conversions. Quote the exact column headers.
2. **Plan all reads.** If multiple exports are attached (campaigns + search terms + audiences), batch-read them in parallel.
3. **Score every campaign/ad set/keyword on:**
   - Spend (R)
   - Conversions
   - Revenue (R)
   - ROAS = Revenue / Spend
   - Impression share lost to budget vs. rank (Google)
   - Frequency (Meta — flag >3.5 for prospecting, >6 for retargeting)
   - Quality Score / Relevance (Google QS <5, Meta relevance <6 = flag)
4. **Tag findings:**
   - WASTED_SPEND: zero conversions in last 30d AND spend >R1000
   - CREATIVE_DECAY: CPA up >40% over rolling 14d AND frequency >4
   - AUDIENCE_OVERLAP: >25% overlap between two ad sets
   - PACING: spend at >120% or <80% of target
   - QS_DRAG: QS <5 keywords with spend >R500
5. **For each finding, score:**
   - SEO/business impact: 1–5
   - Effort to fix: 1–5 (Shopify-aware: pause = 1, restructure = 4, rebuild creatives = 5)
   - Priority = Impact × (6 − Effort)

## Coverage rule (finding stage)

Report every finding, including low-severity ones and ones you are uncertain about. Tag each with a confidence (low/med/high) and a severity. Do not filter for importance or confidence at this stage — ranking and prioritisation happen separately below. Coverage is the goal: a finding that later gets filtered out is cheaper than a real issue silently dropped.

## Required output shape

```
ADS AUDIT — [Platform] [Account] [Date range]
Total spend: R[x] | Revenue: R[y] | Blended ROAS: [z]

PRIORITY 1 (do this week):
- [Campaign/AdSet name] [Tag] [Evidence] [Spend impact: R$X/mo]

PRIORITY 2 (next sprint):
[same shape]

PRIORITY 3 (monitor):
[same shape]

DATA GAPS:
- [missing dimensions you could not assess]

NEXT TURN: To pause/restructure/rebuild, request "execute Priority 1"
or "rebuild [specific campaign]".
```

## Hard gates

- If an export lacks revenue/conversion columns, you cannot score ROAS — say so, do not estimate.
- South African date format: dd/mm/yyyy. Currency: ZAR (R). Confirm both before reporting.
- Never benchmark against US/UK industry averages without flagging the geography mismatch.
- Beauty industry benchmarks: cite the source (e.g., "[Wordstream beauty benchmark, fetched [date]]") — do not state from memory.
