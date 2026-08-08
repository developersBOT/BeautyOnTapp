---
name: beautyontapp-bleeder-detection
description: Anti-conservative spending protocol for BeautyOnTApp Google Ads and Meta Ads. Auto-invoke BEFORE any campaign performance recommendation, pause/keep decision, budget advice, "wait for more data" suggestion, or campaign evaluation. Also auto-invoke when T shares campaign screenshots, performance data, asks "should I pause this", "is this working", "what about these campaigns", "are these bleeding", or when Claude is about to say "give it more time", "wait 7 days", "needs more data", "too early to tell", or any variant of conservative PPC advice. This skill OVERRIDES generic PPC best practices with T's proven account patterns. If Claude is about to recommend patience on a zero-conversion campaign, STOP and read this skill first. NOT for campaign structure or bidding changes (use google-ads or meta). NOT for creative testing.
---

# BeautyOnTApp Bleeder Detection & Anti-Conservative Spending Protocol

You are protecting T's advertising budget. Every rand spent on a zero-conversion campaign is a rand stolen from a campaign that converts. Your job is to detect bleeders fast and recommend action — not caution.

## WHY THIS SKILL EXISTS

On March 29, 2026, Claude told T to "wait until April 2" before pausing 6 campaigns that were clearly bleeding money. The data was visible in a screenshot: R937 CPA, R2,990 CPA, and 4 campaigns at zero conversions. Claude defaulted to generic PPC advice ("give it 7 days") instead of applying T's account history. T's money burned while Claude played it safe.

**This must never happen again.**

## THE CORE RULE

**Account pattern beats textbook advice. Always.**

BeautyOnTApp has a proven, documented pattern: new campaigns without conversion history bleed money. The Killswitch rebuild (KS_C1–C12) proved this — a 12-campaign restructure produced ZERO conversions on 10 of 12 campaigns. This is not a one-off. This is the account's DNA.

When Claude sees zero conversions + meaningful spend, the answer is not "wait for more data." The data IS the answer.

## BLEEDER DETECTION THRESHOLDS

### 🔴 IMMEDIATE BLEEDER — Recommend pause NOW
- Zero conversions + R150+ spend on any campaign
- CPA exceeds R500 on any non-brand campaign (brand CPA can be higher due to defensive positioning)
- ROAS below 1.0 after R200+ spend
- Any campaign following the Killswitch pattern: new structure, no conversion history, spending without converting

### 🟡 WATCH LIST — Flag but don't auto-pause
- 1-2 conversions but CPA above R300 on non-brand campaigns
- ROAS between 1.0-2.0 after R300+ spend
- Campaigns with conversions but declining trend over 3+ consecutive days

### 🟢 PERFORMING — Protect and scale
- ROAS above 5.0 consistently
- CPA below R100
- Stable or improving conversion trend
- These campaigns should receive budget from paused bleeders

## DECISION FRAMEWORK — USE THIS, NOT TEXTBOOK PPC

When evaluating any campaign, follow this sequence:

### Step 1: Check the numbers first
Read the actual data — spend, conversions, CPA, ROAS. Do not theorize about what "might" happen with more time.

### Step 2: Apply account pattern
Does this campaign have conversion history? If NO → it matches the Killswitch pattern. New campaigns without early conversions in this account do not suddenly start converting. They bleed.

### Step 3: Compare to proven performers
KS_C8_Brand_Protection converted from day one. Shopping_All_Products_v2 converted from day one. PMax converted from day one. If a campaign isn't converting while these are, the campaign is the problem — not the timeline.

### Step 4: Make the call
- Zero conversions + R150+ spend = **"This is a bleeder. Pause it."**
- CPA above R500 = **"CPA is unacceptable. Pause or restructure."**
- Early but showing signs = **"Flag as watch list. Check again in 48 hours."**

### Step 5: Redirect the money
Every pause recommendation MUST include a reallocation plan. Where does the freed budget go? Always toward the proven performers.

## PHRASES CLAUDE MUST NEVER USE FOR ZERO-CONVERSION CAMPAIGNS

These phrases are BANNED when a campaign has zero conversions and R150+ spend:

- ❌ "Give it more time"
- ❌ "Wait 7 days before making decisions"
- ❌ "It's too early to tell"
- ❌ "The campaign only has 1-2 days of data"
- ❌ "Needs more data before we can evaluate"
- ❌ "Let it run through a full cycle"
- ❌ "Standard practice is to wait..."
- ❌ "PPC best practice recommends..."
- ❌ "It might improve with more impressions"
- ❌ "The algorithm needs time to optimize"

## WHAT CLAUDE MUST SAY INSTEAD

When textbook PPC advice conflicts with account data:

✅ **"Textbook says wait, but your account history shows this pattern fails. [Campaign X] has R[amount] spend with [0/near-zero] conversions — that matches the Killswitch bleeder pattern. Recommend pause and reallocate to [performing campaign]."**

Always:
1. State the data (spend, conversions, CPA)
2. Reference the account pattern (Killswitch)
3. Compare to proven performers
4. Recommend specific action (pause + where to move the budget)
5. If genuinely uncertain, say so — but lean toward protecting the budget, not protecting the campaign

## WHEN TEXTBOOK ADVICE IS VALID

Generic PPC rules ARE valid in these specific scenarios:

- **Brand campaigns:** KS_C8_Brand_Protection and Search_Brand serve a defensive purpose. High CPA is acceptable if they're blocking competitors from bidding on "beautyontapp" terms. Do not apply bleeder logic to brand defense.
- **First 48 hours of a campaign with prior conversion history:** If a campaign was paused and restarted (not a new build), give it 48 hours — it has historical data to draw on.
- **Seasonal shifts:** If ALL campaigns see CPA rise simultaneously (e.g., Q4 CPM spike), that's market-level — not a campaign-level bleeder.
- **Budget under R50 total spend:** At very low spend, zero conversions is expected. The R150 threshold exists for this reason.

## PROVEN ACCOUNT BENCHMARKS

These are the campaigns that WORK in this account. Use them as the benchmark — not industry averages:

| Campaign | Typical ROAS | Role |
|----------|-------------|------|
| KS_C8_Brand_Protection | 200-338x | Brand defense — never pause |
| Search_Brand | 30-50x | Brand capture — core performer |
| Shopping_All_Products_v2 | 40-60x | Shopping — high ROAS |
| PMax_BeautyOnTApp | 12-20x | Broad reach — largest converter by volume |

Any new campaign that can't approach PMax-level ROAS (12x+) within R300 of spend is underperforming relative to this account's proven capability.

## FAILED CAMPAIGN PATTERNS — DO NOT REPEAT

| Pattern | Example | Result | Lesson |
|---------|---------|--------|--------|
| 12-campaign rebuild | Killswitch KS_C1-C12 | 0 conversions on 10/12 | New structures bleed without history |
| Standalone Acne Search | Search_Acne | Money bleeder | Niche intent handled by PMax + Shopping |
| Category-specific Search at low budget | Search_Korean, Search_BestSellers, Search_LocalBrands | R937-R2,990 CPA | Budget too thin for standalone category campaigns |
| Category-specific Shopping at low budget | Shopping_Korean, Shopping_SA_Brands, Shopping_Brand_Fortress_v2 | 0 conversions | Budget too thin — consolidate into Shopping_All_Products |

## THE GOLDEN RULE

**T's money is not a textbook exercise. When the data says a campaign is bleeding, say so immediately. Do not dress it up with caveats about "needing more time." The Killswitch taught us that waiting costs money. Act on what you see, not what you hope will happen.**

## CROSS-SKILL INTEGRATION

This skill overrides recommendations from:
- **beautyontapp-google-ads** — when that skill's bidding phase framework suggests waiting, but data shows a bleeder
- **beautyontapp-analytics** — when that skill's "3 bad days is a trend" rule would delay action on obvious zero-conversion campaigns

This skill does NOT override:
- **beautyontapp-business-rules** — budget ceilings, brand rules, and tracking rules always apply
- **beautyontapp-challenge-verify** — verification protocol still applies before executing changes
