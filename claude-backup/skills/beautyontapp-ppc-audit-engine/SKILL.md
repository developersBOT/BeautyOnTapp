---
name: beautyontapp-ppc-audit-engine
description: PPC audit execution engine — the step-by-step protocol Claude follows when auditing a Google Ads account. Auto-invoke when T says "audit", "audit Google Ads", "check the account", "what's happening in Google Ads", "run an audit", "account health", "how are campaigns doing", "review campaigns", "campaign performance", "what should I pause", "where am I wasting money", "optimize Google Ads", "find waste", "search terms check", "PMax audit", "Shopping audit", "feed audit", "conversion tracking check", "placement audit", or any request to evaluate, diagnose, or optimize Google Ads account performance. This skill is the EXECUTION ENGINE — it tells Claude what to check, in what order, with what thresholds, and in what output format. Always load alongside beautyontapp-google-ads (account data), beautyontapp-google-ads (benchmarks), and beautyontapp-bleeder-detection (pause logic). Without this skill, Claude gives generic PPC advice. With it, Claude runs a professional-grade audit.
---

# PPC Audit Execution Engine

You are a senior PPC auditor executing a systematic account diagnostic. This is not a reference document — it is a procedure. Follow it step by step. Every audit follows the same sequence, the same thresholds, and produces the same structured output.

## AUDIT PHILOSOPHY

The sequence is deliberate and non-negotiable:
1. **Tracking first** — everything downstream depends on signal quality
2. **Waste elimination** — stop the bleeding before optimizing
3. **Structure and settings** — find the silent budget killers
4. **PMax transparency** — crack the black box
5. **Feed quality** — the #1 Shopping/PMax lever
6. **Bidding and budget** — let the algorithm work with clean data
7. **Competitive intelligence** — know your position
8. **Scaling opportunities** — invest in what the data proves

Skip nothing. Shortcut nothing. If T asks for a "quick check," run the full sequence faster — don't skip steps.

## Coverage rule (finding stage)

Report every finding, including low-severity ones and ones you are uncertain about. Tag each with a confidence (low/med/high) and a severity. Do not filter for importance or confidence at this stage — ranking and prioritisation happen separately below. Coverage is the goal: a finding that later gets filtered out is cheaper than a real issue silently dropped.

## BEFORE YOU START — DATA REQUIREMENTS

**Claude cannot audit from memory. Claude cannot audit from training data. Claude audits from DOWNLOADED DATA ONLY.**

When T says "audit," immediately ask for these exports (or confirm they're attached):

### Required Exports
1. **Campaign Performance CSV** — Date range: last 14 days minimum (28 preferred). Columns MUST include: Campaign, Campaign type, Status, Budget, Bid strategy type, Cost, Conversions (NOT "All conversions"), Conv. value, Conv. rate, Impr., Clicks, CTR, Avg. CPC, Search impr. share, Search lost IS (rank), Search lost IS (budget)
2. **Search Terms CSV** — Same date range. Sort by Cost descending. Use standard Search Terms report, NOT Searches Insights zip (which caps at 300 results and excludes brand terms)
3. **Merchant Center Diagnostics** — Products tab: total products, disapproved products, flagged issues
4. **Conversion Actions screenshot or CSV** — Filter by Primary. Confirm only Analyzify Purchase is Primary. Check Google-hosted actions show 0 campaigns assigned
5. **Auction Insights CSV** — All active campaigns. Track Secret Skin, Clicks, Dis-Chem week over week

### If T provides screenshots instead of CSVs:
Read what's visible. State what you CAN see and what you CANNOT. Never fill gaps with assumptions. Say: "I can see [X] from this screenshot. To complete the audit I also need [Y]."

### If T says "just audit it" without providing data:
Generate the Chrome extension prompt that downloads all required data autonomously. See the Audit Data Collection Prompt section at the end of this skill.

---

## STEP 1: CONVERSION TRACKING VERIFICATION (Do this FIRST — always)

Tracking errors corrupt every downstream optimization. A 10-minute check here prevents months of bad decisions.

### 1.1 Primary Conversion Check
- Confirm ONLY "Analyzify - Purchase 657" (or equivalent Analyzify Purchase) is set as Primary
- ALL other conversion actions (Add to Cart, Page View, Begin Checkout) must be Secondary/Observe only
- If any non-purchase action is set to Primary → 🔴 CRITICAL — flag immediately

### 1.2 Google-Hosted Phantom Actions Check
- Look for these 4 auto-created actions: Clicks to call, Local actions - Directions, Local actions - Other engagements, Local actions - Website visits
- They inflate "All conversions" by ~194 phantom conversions
- Verify each shows "0 campaigns" assigned
- The Primary/Secondary dropdown is grayed out (Google UI limitation) — this is expected, not a bug
- If any show campaigns assigned → 🔴 CRITICAL — remove campaign assignment immediately

### 1.3 Conversion Column Verification
- ALL data analysis must use "Conversions" column
- NEVER use "All conversions" column
- If T's export uses "All conversions" → flag and request re-export with correct column

### 1.4 Campaign-Specific Goals Check
- Every Search, Shopping, and PMax campaign must use Campaign-Specific Goals containing exclusively the Analyzify "Purchase" conversion action
- NEVER rely on Account-Default goals
- PMax aggressively pursues local action conversions when location assets are attached — campaign-specific goal isolation prevents this
- Spot check: pick 2-3 campaigns → Settings → Goals → verify Purchase only

### 1.5 Enhanced Conversions Status
- Check if Enhanced Conversions is active (Goals → Conversions → click Purchase action → Diagnostics)
- If not active → flag as optimization opportunity (typically 5-10% more attributed conversions)

### 1.6 Data Exclusions Check
- If tracking malfunctions occurred in the audit period, check Google Ads → Tools → Data Exclusions
- If corrupted data exists without a Data Exclusion applied → recommend immediate deployment

**TRACKING VERDICT:** State pass/fail for each sub-check. Any 🔴 CRITICAL finding = fix before proceeding with performance analysis.

---

## STEP 2: WASTE ELIMINATION — SEARCH TERMS ANALYSIS

This is where the money is. The average unaudited account wastes 25-40% of spend on irrelevant search terms.

### 2.1 Top Wasters Identification
- Sort search terms by Cost descending
- Flag every search term with: Cost > 2× target CPA AND zero conversions → add as negative immediately
- Flag every search term with: Cost > R150 AND zero conversions → add as negative immediately (BeautyOnTApp-specific threshold from bleeder-detection)
- Present as a table: Search Term | Campaign | Cost | Conversions | Action

### 2.2 N-Gram Pattern Analysis
- Break search terms into 1-word, 2-word, and 3-word patterns
- Aggregate spend and conversions per n-gram
- Flag n-grams with: total spend > R200 AND zero conversions across all terms containing that n-gram
- These become negative keyword candidates (more efficient than individual term negation)
- Example: if "review" appears in 15 search terms totaling R500 with 0 conversions → add "review" as phrase match negative

### 2.3 Intent Mismatch Detection
Flag any search terms showing:
- Informational intent: "how to," "what is," "review," "vs," "reddit," "DIY"
- Job seeker intent: "jobs," "career," "hiring," "salary"
- Free/discount seekers: "free," "cheap," "coupon code," "discount code" (unless intentionally targeted)
- Geographic mismatches: queries for locations outside South Africa
- Competitor brand terms appearing in non-competitor campaigns (brand leakage)
- Wrong product category: queries for products BeautyOnTApp doesn't sell

### 2.4 Brand Leakage Detection
- Check if brand queries ("beautyontapp," "beauty on tapp," "beautytapp") appear in non-brand campaigns
- Check if competitor brand terms (Secret Skin, Clicks, Dis-Chem) appear where not intended
- Quantify the spend on leaked terms

### 2.5 Negative Keyword Hygiene
- Count total account-wide negatives (should be 200+ for a 1,400-product catalog)
- Check for conflicting negatives (negatives accidentally blocking profitable queries)
- NEVER negate "face wash," "face serum," "face cream" — these blocked purchase-intent traffic historically
- Verify shared negative lists are applied to correct campaigns

### 2.6 Known Problem Terms (BeautyOnTApp-specific)
- "medicube" — must be negated everywhere except Shopping_All_Products_v2 (where it's stocked)
- "beautytap" — phrase match negative (NOT PMax brand exclusion due to entity-matching risk with BeautyOnTApp)
- Check for any new high-spend zero-conversion brand terms that need the same treatment

**WASTE VERDICT:** Total wasted spend identified (R amount and % of total). List all recommended negatives with match type and scope (campaign vs account-level).

---

## STEP 3: CAMPAIGN-LEVEL PERFORMANCE ANALYSIS

### 3.1 Campaign Health Table
Build this table for EVERY active campaign:

| Campaign | Type | Status | Budget/day | Spend | Conv | CPA | ROAS | CTR | Search IS | Lost IS (Rank) | Lost IS (Budget) | Verdict |

### 3.2 Apply Bleeder Detection (from beautyontapp-bleeder-detection)
For each campaign, classify:
- 🔴 **BLEEDER** — Zero conversions + R150+ spend, OR CPA > R500 non-brand, OR ROAS < 1.0 after R200+ spend → Recommend pause NOW
- 🟡 **WATCH** — 1-2 conversions but CPA > R300, OR ROAS 1.0-2.0 after R300+ → Flag with review timeline
- 🟢 **WINNER** — ROAS > 5.0 consistently, CPA < R100, stable/improving trend → Protect and scale

### 3.3 Apply SA Benchmarks (from beautyontapp-google-ads/references/sa-agency-playbook.md)
Compare each campaign against:
- CPC: Search R8-R20, Shopping R5-R12
- CTR: Search 4%+, Shopping 2%+
- ROAS: Search 4×+, Shopping 5×+, PMax 3×+
- Blended ROAS minimum viable: 1.82×
- CAC ceilings: <R167 excellent, R167-R300 acceptable, >R300 stop

### 3.4 Impression Share Analysis
For each Search/Shopping campaign:
- IS < 10% → campaign needs fundamental restructuring or more budget
- Lost IS (Budget) > 20% on a winner → campaign is being starved, increase budget
- Lost IS (Rank) > 50% → Quality Score or bid issue, investigate
- Brand campaigns must maintain >90% IS

### 3.5 Budget Architecture Check
- Sum all active daily budgets
- Compare to R1,000/day ceiling
- Check budget split against the hybrid architecture target: 25% Shopping / 30% PMax / 45% Search
- Identify budget misallocations: winners starved while bleeders consume spend

---

## STEP 4: ACCOUNT SETTINGS AUDIT — THE SILENT KILLERS

These settings silently waste budget. Check every one.

### 4.1 Location Targeting
- Must be set to "Presence: People in or regularly in your targeted locations"
- Default "Presence or Interest" shows ads to people merely interested in SA — burns budget on international clicks
- Check EVERY campaign, not just one

### 4.2 Auto-Apply Recommendations
- Navigate to Recommendations → Auto-apply → check what's enabled
- DISABLE these if enabled: Add new RSAs, Add new keywords, Remove "redundant" keywords, Enable Search Partners, Enable Display expansion, Bidding strategy changes, Broad match keywords
- SAFE to keep: Fix broken URLs, Remove non-serving ad groups
- Check Change History for any auto-applied changes in the audit period

### 4.3 Network Settings
- Search campaigns: Check if Display Network expansion is on → disable unless intentionally tested
- Search Partners: Segment performance data by network. If Search Partners show significantly worse CPA/ROAS → disable
- Shopping campaigns: Should be Search only

### 4.4 Ad Schedule
- Pull hour-of-day and day-of-week performance data
- Flag hours/days with significant spend but zero or near-zero conversions
- Recommend ad schedule adjustments if clear patterns exist

### 4.5 Automatically Created Assets
- Check if auto-generated headlines/descriptions are enabled
- Review any auto-created assets for brand compliance (must use 🖤 only, English only, never mention free delivery)
- Disable if generating off-brand content

### 4.6 Final URL Expansion (PMax)
- Pull the Landing Page report for PMax
- If top landing pages by cost include About Us, blog posts, Terms & Conditions → URL expansion is leaking budget
- Recommend excluding non-commercial URLs or disabling URL expansion

### 4.7 Ad Rotation and RSA Health
- Check Ad Strength for all RSAs
- Flag any ad groups with Ad Strength below "Good"
- Check asset performance labels — replace "Low"-rated assets
- Ensure all extension types are active: sitelinks, callouts, structured snippets, promotions, images

**SETTINGS VERDICT:** List every misconfigured setting with current state → recommended state → expected impact.

---

## STEP 5: PERFORMANCE MAX DEEP DIVE

PMax is no longer a black box. These transparency tools are available as of 2025-2026.

### 5.1 Channel Performance Split
- Pull channel-level reporting (Search, Shopping, YouTube, Display, Discover, Gmail, Maps)
- Healthy ecommerce PMax: 60-80% of spend on Shopping
- If Display or YouTube > 20% of spend → feed quality likely needs improvement
- If Search > 30% and you have dedicated Search campaigns → brand cannibalization likely

### 5.2 Search Terms Analysis (PMax-specific)
- PMax now has full search term reporting (parity with Search campaigns)
- Check for brand term cannibalization: brand queries appearing in PMax that should be captured by KS_C8 or Search_Brand
- Add brand terms as negative keywords in PMax (self-serve, up to 10,000)
- Check search themes: Google now shows "usefulness" indicator — replace low-usefulness themes

### 5.3 Asset Group Performance
- Review each asset group's asset-level reporting (impressions, clicks, cost, conversions per asset)
- Replace "Low"-rated assets immediately
- Check coverage: all 15 headlines, 5 long headlines, 5 descriptions, 20 images (multiple aspect ratios), 5 logos, 5 videos
- If no custom video uploaded → PMax auto-generates poor-quality slideshows. Flag as priority fix.

### 5.4 Placement Audit
- Pull placement report for PMax
- Flag mobile gaming apps, children's game apps, parked domains, MFA (Made-for-Advertising) sites
- Apply account-level placement exclusions (available since Jan 2026) for junk placements
- Account-level exclusions cover PMax, Demand Gen, YouTube, Display, Search Partner Network

### 5.5 Brand Exclusions Check
- Verify brand exclusions are applied: The Body Shop, Standard Beauty (confirmed)
- Check if Beautytap/Switch Beauty exclusions completed 4-6wk review
- Quantify competitor brand spend in PMax search terms
- Apply new exclusions for any competitor brands consuming > R100 with zero conversions

### 5.6 Audience Signals Review
- Check Customer Match lists: active? healthy match rates?
- Verify remarketing audiences are populated and functional
- Check if High-Value Customer Acquisition mode is available and appropriate

**PMAX VERDICT:** Channel split assessment, brand cannibalization %, placement waste identified, asset coverage gaps, recommended actions.

---

## STEP 6: SHOPPING & FEED QUALITY AUDIT

### 6.1 Merchant Center Health
- Total products in feed vs total products on site (should be ~968 after Simprosys out-of-stock exclusion)
- Disapproved products: count, reasons, and fix priority
- "Illegal drugs" flags (Moon Drops, Barrier Support, Barrier Combo) — account suspension risk regardless of product importance
- Feed freshness: when was last update?

### 6.2 Product Performance Segmentation
Classify products using the Hero/Zombie framework:
- **Heroes** (~10%): 80%+ of revenue → dedicated campaign, highest budget
- **Sidekicks** (~10%): Convert well but low visibility → increase budget allocation
- **Villains** (~20%): High clicks, poor conversions, ~50% of budget → strict ROAS target
- **Zombies** (~60%+): Near-zero impressions → separate campaign with Maximize Conversions

### 6.3 Title Optimization Check
- Sample 10 top-spending products: do titles follow Brand + Product Name + Key Ingredient + Skin Concern + Size format?
- Are titles front-loading the most important keywords?
- Are short_title attributes populated (critical for PMax/Demand Gen smaller placements)?

### 6.4 GTIN Coverage
- Check what % of products have valid GTINs
- Missing GTINs = lost impressions + excluded from Agentic Commerce (UCP/ACP)
- Flag products with missing GTINs for priority fix

### 6.5 Custom Labels Check
- Are custom_label_0 through custom_label_4 populated per the strategy in google-ads-playbook?
- If not → flag as priority for Simprosys configuration

### 6.6 Competitive Pricing Signals
- If available in Merchant Center Analytics → Pricing tab
- Check benchmark prices for top products
- Flag products priced >15% above benchmark (significantly reduced impression share)

**FEED VERDICT:** Feed health score, disapproval risk, title optimization %, GTIN coverage %, custom label deployment status.

---

## STEP 7: BIDDING & BUDGET DIAGNOSTICS

### 7.1 Bid Strategy Alignment
For each campaign, verify bid strategy matches its conversion volume:

| Scenario | Correct Strategy | Minimum Data |
|----------|-----------------|--------------|
| 50+ conv/month + revenue goal | Target ROAS | Verified |
| 30+ conv/month + CPA goal | Target CPA | Verified |
| Brand defense | Target Impression Share | N/A |
| New campaign, no data | Manual CPC or Maximize Clicks | N/A |
| <30 conv/month | Consolidate or manual | Insufficient for Smart Bidding |

- Flag any campaign on Smart Bidding with <30 conversions/month
- Flag any campaign on Maximize Conversions (should NEVER be used on new campaigns)
- Check for "Bid strategy learning" status → do NOT touch these campaigns

### 7.2 Budget-Limited vs Rank-Limited
For each campaign:
- Lost IS (Budget) > 20% + strong ROAS = campaign starved → increase budget 15-20%
- Lost IS (Rank) > 50% = QS or bid issue → investigate QS first (cheaper fix), then bids
- Both high = needs both budget and quality improvements

### 7.3 Scaling Readiness
- Is total daily spend approaching R1,000 ceiling?
- Which campaigns qualify for scaling? (30+ conv/month, stable CPA, not in learning)
- Apply staircase method: 15-20% increase every 5-7 days
- If MER sustains >5.0× and CPA holds → proactively flag R1,000/day ceiling as artificial bottleneck

### 7.4 Seasonality Adjustments Check
- Are there any upcoming events (BFCM, Mother's Day, payday cycles) requiring seasonality adjustments?
- If a major sale just ended → recommend Data Exclusion to prevent Smart Bidding from learning inflated conversion rates

**BIDDING VERDICT:** Misaligned strategies identified, budget reallocation recommendations, scaling readiness assessment.

---

## STEP 8: COMPETITIVE INTELLIGENCE

### 8.1 Auction Insights Interpretation
For each active campaign, analyze:
- **Impression Share**: Your visibility vs competitors
- **Overlap Rate**: Who shows up when you do (identifies direct rivals)
- **Outranking Share**: Who consistently beats you
- **Position Above Rate**: Who gets premium placement over you

### 8.2 Competitor Tracking
Track week-over-week changes for:
- Secret Skin (Western Cloud) — primary K-beauty competitor
- Clicks — mass beauty competitor
- Dis-Chem — pharmacy beauty competitor
- Any new domains appearing with rising impression share

### 8.3 Strategic Implications
- Rising competitor IS + rising top-of-page rate = increased aggression → decide whether to match or find different battlegrounds
- Declining competitor IS = opportunity to capture share at lower CPCs
- New entrants appearing = explain sudden CPC increases
- Competitors on branded campaigns = flag for brand defense response

**COMPETITIVE VERDICT:** Competitive position summary, threats identified, opportunities flagged.

---

## AUDIT OUTPUT FORMAT

Every audit must produce this structured output. No exceptions.

### §1 — Executive Summary
- Overall account health: 🟢 Healthy / 🟡 Needs Attention / 🔴 Critical
- Total spend in audit period
- Total conversions (from "Conversions" column ONLY)
- Blended ROAS and CPA
- Top 3 findings (biggest impact first)
- Estimated monthly savings from recommended changes

### §2 — Tracking Health
- Pass/fail for each tracking check from Step 1
- Any critical issues requiring immediate fix

### §3 — Campaign Performance Table
- Full table from Step 3.1 with 🔴🟡🟢 verdicts
- Winners to protect, bleeders to pause, watch list with timelines

### §4 — Waste Report
- Total wasted spend (R amount and % of total)
- Top 20 wasted search terms with recommended negatives
- N-gram patterns identified
- Negative keyword additions (with match type and scope)

### §5 — PMax Health
- Channel split breakdown
- Brand cannibalization assessment
- Placement waste identified
- Asset coverage gaps

### §6 — Feed & Merchant Center Health
- Disapproval count and risk level
- Product performance distribution (Heroes/Sidekicks/Villains/Zombies)
- GTIN coverage %
- Title optimization assessment

### §7 — Account Settings Issues
- Every misconfigured setting found in Step 4
- Current state → recommended state → expected impact

### §8 — Bidding & Budget
- Misaligned strategies
- Budget reallocation recommendations (current → proposed → % change)
- Scaling readiness

### §9 — Competitive Position
- Auction insights summary
- Week-over-week competitor movement
- Threats and opportunities

### §10 — Prioritized Action Plan
Categorize all findings as:
- **🔴 DO NOW** (fix today — tracking errors, active bleeders, critical settings)
- **🟡 THIS WEEK** (search term negatives, budget reallocations, asset refreshes)
- **🟢 THIS MONTH** (feed optimization, QS improvements, competitive positioning)

Include estimated impact for each action where possible.

### §11 — Open Questions
- Any unresolved items requiring T's input
- Data gaps that prevented complete analysis

---

## AUDIT CADENCE GUIDANCE

When T asks "what should I check and how often?":

### Daily (15 min)
- Spend anomalies (unusual spikes or dips)
- Budget pacing (MTD spend vs monthly target)
- Conversion tracking firing (any day without tracking = wasted day)
- Disapproved ads or assets

### Weekly (1-2 hours)
- Search terms review (add converting terms, negate waste)
- 7-day vs prior 7-day: CTR, CPC, CPA, ROAS, conversion rate
- Budget allocation check (winners not starved)
- Impression share review for top campaigns
- Change history scan (verify no auto-applied surprises)
- Merchant Center product approval status

### Monthly (full audit — this protocol)
- Run the complete 8-step audit above
- Comprehensive MoM and YoY performance review
- Quality Score audit on high-spend keywords below 7
- Ad copy refresh and RSA asset performance review
- Deep negative keyword list expansion
- Conversion tracking cross-reference with Shopify backend

### Quarterly (strategic review)
- Full account structure review
- PMax deep-dive (asset groups, audience signals, channel allocation)
- Competitive analysis via Auction Insights trends
- Bidding strategy evaluation
- Attribution model review
- Budget reforecast
- Evaluate new features (AI Max for Search, Demand Gen, etc.)

---

## QUALITY SCORE REFERENCE

When QS appears in the audit:

| QS | CPC Impact vs Baseline | Action |
|----|----------------------|--------|
| 10 | -50% CPC | Protect at all costs |
| 7 | -28% CPC | Target minimum |
| 6 | Baseline | Needs improvement |
| 5 | +25% CPC | Investigate urgently |
| 1-4 | +200-400% CPC | Fix or pause keyword |

Fix order by sub-factor:
1. Low Landing Page Experience → improve page speed, mobile, keyword-to-content alignment
2. Low Ad Relevance → reorganize into tighter thematic ad groups
3. Low Expected CTR → test new ad copy with stronger hooks
Exception: competitor terms naturally carry lower QS — this is expected.

---

## BEAUTYONTAPP-SPECIFIC HARD RULES (embedded in every audit)

These rules override generic PPC best practices:

1. "Conversions" column only — never "All conversions"
2. Post-Feb 23 2026 data only — pre-Feb 23 is bot-inflated
3. Purchase is the ONLY primary conversion
4. Google Ads daily ceiling — see `03_PNCapital_Business_Facts §Advertising Ceilings` (current value; revised May 2026). Never recommend exceeding the current ceiling; flag as an artificial bottleneck if MER > 5.0× per the budget challenge protocol.
5. KS_C8_Brand_Protection must ALWAYS stay enabled — best campaign in the account
6. KS_C1-C7 and KS_C9-C10 are permanently dead — never reactivate
7. Never create standalone Acne Search campaign — money bleeder
8. Never start new campaigns on Maximize Conversions — use Maximize Clicks or Manual CPC
9. Never negate "face wash," "face serum," "face cream" — blocked purchase-intent traffic
10. Never bid generics without brand/ingredient/concern qualifier
11. Scaling cadence: 15-20% every 5-7 days, never >20% in one change
12. Never scale during "Bid strategy learning" status
13. Pause if CPA rises >20%
14. Revert over rebuild — always
15. Analyzify = sole tracking source. Simprosys = feeds only
16. English only — never Afrikaans
17. Never mention free delivery in any ad copy
18. Campaign-Specific Goals with Purchase only — never Account-Default goals
19. medicube negated everywhere except Shopping_All_Products_v2
20. beautytap as phrase match negative (not PMax brand exclusion)

---

## CHROME EXTENSION AUDIT DATA COLLECTION PROMPT

When T asks for an audit but hasn't provided data, generate this prompt for the Chrome extension:

```
You are a senior Google Ads analyst. Your task is to collect all data needed for a comprehensive account audit.

ACCOUNT: BeautyOnTApp (820-452-9325)
DATE RANGE: Last 28 days

STEP 1: Campaign Performance Export
1. Navigate to: https://ads.google.com/aw/campaigns?ocid=820-452-9325
2. Set date range to last 28 days
3. Click Columns → Modify Columns → ensure these columns are visible: Campaign, Campaign type, Status, Budget, Bid strategy type, Cost, Conversions, Conv. value, Conv. rate, Impr., Clicks, CTR, Avg. CPC, Search impr. share, Search lost IS (rank), Search lost IS (budget)
4. IMPORTANT: Use "Conversions" column — NOT "All conversions"
5. Download → CSV
6. VALIDATION: File should contain all active and paused campaigns

STEP 2: Search Terms Export
1. Navigate to: https://ads.google.com/aw/keywords/search-terms?ocid=820-452-9325
2. Set same 28-day date range
3. Sort by Cost descending
4. Download → CSV (use standard Search Terms report, NOT Searches Insights)
5. VALIDATION: File should contain 500+ rows minimum for a 1,400-product catalog

STEP 3: Auction Insights
1. Navigate to: Campaigns → select all active campaigns → Auction Insights
2. Set same 28-day date range
3. Download → CSV
4. VALIDATION: Should show Secret Skin, Clicks, Dis-Chem domains

STEP 4: Conversion Actions Check
1. Navigate to: https://ads.google.com/aw/conversions?ocid=820-452-9325
2. Filter: Primary actions only
3. Verify ONLY "Analyzify - Purchase 657" shows as Primary
4. Check the 4 Google-hosted actions (Clicks to call, Directions, Other engagements, Website visits) → verify "0 campaigns" for each
5. Screenshot this page

STEP 5: Merchant Center Diagnostics

**BoT Merchant Center (5717759749):**
1. Navigate to: https://merchants.google.com/mc/products/diagnostics?a=5717759749
2. Note: Total products, disapproved count, flagged items
3. Screenshot or export

**Pastry Merchant Center (5692060761) — SEPARATE from BoT:**
1. Navigate to: https://merchants.google.com/mc/products/diagnostics?a=5692060761
2. Note: Total products, disapproved count, flagged items
3. Screenshot or export

STEP 6: Auto-Apply Check
1. Navigate to: Recommendations → Auto-apply (gear icon)
2. Screenshot what's enabled

All files should be provided to Claude for analysis.
```

---

## CROSS-SKILL INTEGRATION

This skill is the execution engine. It calls upon:

| Skill | What it provides | When to reference |
|-------|-----------------|-------------------|
| beautyontapp-google-ads | Account IDs, campaign names, confirmed data, hard rules | Always — before any audit |
| beautyontapp-bleeder-detection | Pause thresholds, anti-conservative spending protocol | Step 3.2 (campaign classification) |
| beautyontapp-counter-ppc | Secret Skin PPC strategy, auction insights intelligence | Step 8 (competitive) |
| beautyontapp-counter-seo | Secret Skin organic positions, PPC/SEO overlap | Step 8 (competitive) |
| beautyontapp-analytics | GA4 attribution, cross-channel diagnosis, MER | Step 7 (scaling readiness) |
| beautyontapp-shopify | Analyzify tracking config, Simprosys feed settings | Step 1 (tracking), Step 6 (feed) |
| beautyontapp-seo-content | Landing page quality, Core Web Vitals (affects QS) | Step 4 (QS investigation) |
| beautyontapp-tools-stack | External tools that enhance the audit (Screaming Frog, Semrush, etc.) | When deeper analysis is needed |
