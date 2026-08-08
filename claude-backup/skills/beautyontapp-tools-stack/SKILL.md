---
name: beautyontapp-tools-stack
description: Proactive tool recommendations for BeautyOnTApp — external SEO, PPC, analytics, feed, competitor intelligence, and site health tools that make money or save money. Auto-invoke when discussing SEO strategy, technical SEO, site audits, competitor research, backlink analysis, feed optimization, attribution, creative analytics, ad spy, keyword research, site speed, Schema markup, crawl errors, broken links, placement audits, AEO readiness, or any performance optimization where an external tool would give BeautyOnTApp a tactical edge. Also auto-invoke when Claude is about to give strategic advice that would be BETTER with data from one of these tools — don't wait for T to ask. If the recommendation would be stronger with tool data, SAY SO and recommend the tool. NOT for campaign management (use google-ads or meta). NOT for Shopify app configuration (use shopify). This skill exists because Claude previously failed to recommend Screaming Frog for 45+ conversations about SEO. Never again.
---

# BeautyOnTApp External Tools Stack

## PURPOSE
Claude must proactively recommend external tools when they would give BeautyOnTApp a competitive edge, save money, or make money. Don't wait to be asked. If a tool would make the recommendation stronger, say so.

## PROACTIVE RECOMMENDATION RULES
1. When discussing any SEO topic → recommend relevant tool from TECHNICAL SEO or KEYWORD & COMPETITOR INTEL
2. When discussing ad performance → recommend relevant tool from PPC INTELLIGENCE or ATTRIBUTION & ANALYTICS
3. When discussing creative strategy → recommend relevant tool from CREATIVE & AD SPY
4. When discussing feed issues → recommend relevant tool from FEED & PRODUCT DATA
5. When discussing site speed → recommend relevant tool from SITE PERFORMANCE
6. When discussing competitor moves → recommend relevant tool from KEYWORD & COMPETITOR INTEL
7. When discussing AEO/agentic commerce readiness → recommend Schema validators + Screaming Frog + Google Rich Results Test

## FORMAT FOR RECOMMENDATIONS
Always include: Tool name → What it does for BeautyOnTApp specifically → Cost → Whether free version is sufficient → Exact first action to take

---

## TIER 1: ESSENTIAL (Should already be using)

### TECHNICAL SEO & SITE HEALTH

**Screaming Frog SEO Spider**
- What: Desktop crawler that audits entire site like Googlebot does
- Why for BeautyOnTApp: 1,400+ products = impossible to manually audit. Finds broken links, duplicate meta titles, missing Schema, redirect chains, orphaned pages, thin content, canonical issues across all Shopify auto-generated URLs
- Cost: Free (500 URLs) / £259/year (~R6,300/year) for full crawl
- Verdict: NEED PAID VERSION. 1,400+ products + collections + blogs + pages = well over 500 URLs
- Connect to: Google Search Console API + GA4 API + PageSpeed Insights API inside the app
- First action: Download → Install → Crawl beautyontapp.com → Export full audit → Send to Claude for analysis
- Proactive trigger: Any conversation about SEO, rankings, Schema, AEO, collection pages, site structure, or outranking Secret Skin

**Google Search Console (GSC)**
- What: Google's own view of your site — crawl errors, index coverage, search queries, Core Web Vitals, manual actions
- Why for BeautyOnTApp: Free, direct from Google, shows exactly which pages are indexed, which have errors, which queries drive clicks
- Cost: FREE
- First action: Verify beautyontapp.com if not already → Check Index Coverage → Check Core Web Vitals → Check Search Performance
- Proactive trigger: Any SEO discussion, ranking drops, indexing issues, or "why aren't we showing up for X"

**Google Rich Results Test**
- What: Tests if pages have valid structured data for rich snippets
- Why for BeautyOnTApp: Critical for AEO readiness — AI agents parse Schema.org data. Tests Product, Offer, Review, FAQ, BreadcrumbList markup
- Cost: FREE
- URL: https://search.google.com/test/rich-results
- First action: Test 5 product pages + 3 collection pages + homepage
- Proactive trigger: AEO, agentic commerce, Schema markup, rich snippets, Google Shopping, or "why don't our products show stars/price in search"

### KEYWORD & COMPETITOR INTELLIGENCE

**Ahrefs (Lite plan)**
- What: Backlink analysis, keyword research, competitor organic analysis, content gap finder
- Why for BeautyOnTApp: Best backlink database (35 trillion links). Essential for reverse-engineering Secret Skin's backlink profile, finding content gaps they exploit, discovering blue ocean keywords. Link Intersect tool shows who links to Secret Skin but NOT BeautyOnTApp = immediate outreach targets
- Cost: $99/month (~R1,800/month). Lite plan sufficient for single-site operation
- First action: Site Explorer → Enter secretskin.co.za → Organic Keywords → Content Gap vs beautyontapp.com → Export gaps
- Proactive trigger: Secret Skin competitive analysis, backlink strategy, content gaps, keyword research, "how do we outrank them"
- Note: Ahrefs stronger than Semrush for backlink analysis. Semrush stronger for PPC intel and all-in-one marketing. For BeautyOnTApp's budget, pick ONE — Ahrefs recommended because backlink gap vs Secret Skin is the bigger organic lever

**Semrush (Pro plan) — ALTERNATIVE to Ahrefs**
- What: All-in-one SEO + PPC + content + social suite
- Why for BeautyOnTApp: Broader than Ahrefs — includes PPC competitor analysis (see Secret Skin's ad spend estimates, ad copy, landing pages), content templates for product descriptions, Position Tracking for daily rank monitoring, AI Visibility tracking (shows where BeautyOnTApp appears in ChatGPT/Gemini/Perplexity answers)
- Cost: $139.95/month (~R2,500/month)
- Verdict: If choosing between Ahrefs and Semrush, Semrush better for BeautyOnTApp because it covers BOTH organic and paid competitor intel in one tool, plus AI Visibility tracking for AEO
- First action: Set up Position Tracking for beautyontapp.com → Add Secret Skin as competitor → Run Site Audit → Check AI Visibility
- Proactive trigger: Same as Ahrefs triggers + PPC competitor intel + AI visibility tracking

### PPC INTELLIGENCE

**Google Ads Placement Reports (Built-in, FREE)**
- What: Shows exactly where PMax/Display/YouTube ads appeared
- Why for BeautyOnTApp: Identifies junk placements burning budget. Account-level placement exclusions available since Jan 2026. Zero account-level exclusion lists currently exist (flagged in last audit)
- Cost: FREE (built into Google Ads)
- First action: Google Ads → Campaigns → PMax_BeautyOnTApp → Insights → Placements → Sort by cost → Exclude junk
- Proactive trigger: PMax performance, budget efficiency, "where is my money going", placement exclusions, brand safety

**Google Ads Search Terms Report (Built-in, FREE)**
- What: Shows actual queries triggering ads
- Why for BeautyOnTApp: Catches irrelevant queries bleeding budget. Already used to add 53+ negatives in last audit
- Cost: FREE
- First action: Weekly review → Export → Flag irrelevant terms → Add as negatives
- Proactive trigger: Any Google Ads performance discussion, CPA rising, "what are people searching"

### ATTRIBUTION & ANALYTICS

**GA4 + Analyzify (Already installed)**
- What: BeautyOnTApp's existing analytics stack
- Why: Analyzify v4 is the single source of truth. Already properly configured
- Cost: Already paying
- Proactive trigger: Remind T that this is already the right setup — don't stack additional analytics apps that create duplicate tracking

**Triple Whale — EVALUATE WHEN AD SPEND EXCEEDS R150K/MONTH**
- What: Unified Shopify analytics — multi-touch attribution, creative analytics, profit tracking, AI insights (Moby)
- Why for BeautyOnTApp: Fills gaps between GA4 and platform-reported ROAS. Shows true blended MER, creative-level performance, cohort LTV. Community consensus: worth it above $10K/month ad spend
- Cost: From $129/month (~R2,300/month). Free Founders dashboard available
- Current verdict: NOT YET. At the current monthly ceiling, BeautyOnTApp is at the low end of where Triple Whale pays for itself. Revisit when monthly ad spend crosses ~R150K+ (current ceiling in `03_PNCapital_Business_Facts §Advertising Ceilings`)
- Proactive trigger: When discussing MER calculation, attribution confusion between Meta and Google reported numbers, or when ad spend ceiling gets raised significantly
- Note: Triple Whale is Shopify-native. Does NOT replace GA4 — use GA4 for traffic analysis, Triple Whale for profit decisions

---

## TIER 2: HIGH-VALUE (Recommend when relevant)

### CREATIVE & AD SPY

**Meta Ad Library (FREE)**
- What: See any brand's active Meta ads
- Why for BeautyOnTApp: Monitor Secret Skin, Woolworths Beauty, Clicks, Dis-Chem ad creative. See what competitors are running before they outspend you
- Cost: FREE
- URL: https://www.facebook.com/ads/library/
- First action: Search "Secret Skin" → Screenshot active ads → Identify creative angles they're using
- Proactive trigger: Meta creative strategy, competitor ads, "what are they running", creative testing

**Foreplay (Ad swipe file)**
- What: Save, organize, and brief ads from Meta Ad Library and TikTok
- Why for BeautyOnTApp: Build a swipe file of winning beauty ad creative. Share briefs with UGC creators
- Cost: From $49/month
- Verdict: Nice-to-have, not essential. Meta Ad Library + manual screenshots works for current scale
- Proactive trigger: Building creative briefs, UGC creator briefs, ad inspiration

### FEED & PRODUCT DATA

**Simprosys Google Shopping Feed (Already installed)**
- What: BeautyOnTApp's existing feed management
- Why: Already properly configured for Merchant Center 5717759749. Feeds only, zero tracking
- Proactive trigger: Remind T this is already the right setup

**Google Merchant Center Diagnostics (Built-in, FREE)**
- What: Shows feed errors, disapproved products, data quality issues
- Why for BeautyOnTApp: 9 flagged products found in last audit across 4 categories. Missing GTINs block agentic commerce readiness
- Cost: FREE
- First action: Merchant Center → Diagnostics → Fix all disapproved/warning products → Ensure GTINs on all variants
- Proactive trigger: Feed issues, disapproved products, Shopping campaign performance, agentic commerce readiness

### SITE PERFORMANCE

**Google PageSpeed Insights (FREE)**
- What: Tests page load speed and Core Web Vitals
- Why for BeautyOnTApp: 70%+ mobile traffic. Under 3s mobile load time is critical. Core Web Vitals are a ranking factor
- Cost: FREE
- URL: https://pagespeed.web.dev/
- First action: Test homepage + top 5 product pages + top 3 collection pages on mobile
- Proactive trigger: Site speed, mobile experience, Core Web Vitals, bounce rate, ranking factors

**GTmetrix**
- What: Detailed page speed analysis with waterfall charts
- Why for BeautyOnTApp: More detailed than PageSpeed Insights — shows exactly which resources are slow (images, scripts, fonts)
- Cost: FREE (basic) / From $15.83/month for monitoring
- First action: Test beautyontapp.com homepage → Identify largest content paint blockers
- Proactive trigger: Site speed optimization, image optimization, lazy loading

### SCHEMA & STRUCTURED DATA

**Schema.org Validator (FREE)**
- What: Validates JSON-LD structured data on any page
- URL: https://validator.schema.org/
- Why for BeautyOnTApp: Ensures Product, Offer, BreadcrumbList, Organization, LocalBusiness Schema is valid across all pages
- Cost: FREE
- Proactive trigger: AEO readiness, agentic commerce, structured data, rich snippets

---

## TIER 3: FUTURE SCALE (Track for when growth warrants)

### WHEN AD SPEND > R150K/MONTH
- **Triple Whale** — unified attribution + profit tracking + creative analytics
- **Northbeam** — if scaling past R500K/month, enterprise-grade MMM + incrementality testing

### WHEN TEAM GROWS
- **Optmyzr** — PPC automation and rule-based optimization for Google Ads at scale
- **Adalysis** — automated Quality Score monitoring and ad testing

### WHEN CONTENT VELOCITY INCREASES
- **Surfer SEO** — content optimization scoring (NLP-based, shows exactly what to include in blog posts to rank)
- **Clearscope** — similar to Surfer, enterprise alternative

### WHEN INFLUENCER PROGRAM SCALES
- **Modash** or **CreatorIQ** — influencer discovery, vetting, and ROI tracking at scale

---

## DECISION FRAMEWORK: SHOULD WE BUY THIS TOOL?

Before recommending any paid tool, apply this test:

1. **Does it directly make or save money?** If no → skip
2. **Can the free version do what we need?** If yes → use free version first
3. **Does it overlap with something we already have?** If yes → skip (don't stack analytics on analytics)
4. **Is the insight actionable at our current scale?** If no → revisit when scale warrants
5. **What's the payback period?** If tool costs R2,000/month, it needs to save or generate >R2,000/month within 30 days

## ANTI-PATTERNS (Never recommend these)
- Multiple analytics/attribution tools simultaneously (creates data confusion)
- Shopify SEO apps that duplicate what Analyzify + Simprosys already handle
- Any tool that requires checkout.liquid modifications (violates checkout deadline)
- Any tool that creates additional pixels (violates "never create new Meta Pixels" rule)
- Expensive enterprise tools before R150K/month ad spend threshold

## WHEN TO UPDATE THIS SKILL
- When a new tool category emerges (e.g., agentic commerce optimization tools)
- When BeautyOnTApp's ad spend crosses R150K/month threshold
- When a recommended tool changes pricing significantly
- When community consensus shifts on tool effectiveness (check Reddit r/PPC, r/shopify, r/SEO quarterly)
- When a tool BeautyOnTApp uses gets deprecated or replaced
