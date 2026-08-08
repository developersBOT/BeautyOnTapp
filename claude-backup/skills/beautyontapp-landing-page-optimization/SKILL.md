---
name: beautyontapp-landing-page-optimization
description: Landing page audit and optimization for Google Ads Quality Score and conversion rate improvement on BeautyOnTApp's Shopify store. Auto-invoke when T asks about Quality Score, landing page experience, page speed, mobile optimization, collection page optimization, product page conversion rate, message match, bounce rate, landing page for ads, "QS is low", "landing page score", "why is my CPA high" (since landing page experience is a major CPA driver), or any request to improve the pages ads point to. Also auto-invoke when beautyontapp-ppc-audit-engine identifies QS below 7 on high-spend keywords. NOT for Shopify theme code edits (use beautyontapp-shopify). NOT for SEO content strategy (use beautyontapp-seo-content).
---

# Landing Page Optimization for Ads Performance

Landing Page Experience is one of three Quality Score sub-factors. QS of 7 = 28% CPC discount. QS of 10 = 50% CPC discount. Fixing landing pages is often cheaper than raising bids.

## LANDING PAGE AUDIT PROTOCOL

### Step 1: Identify High-Impact Pages
- Pull the Landing Pages report in Google Ads (Pages tab → Landing Pages)
- Sort by Cost descending
- Focus on top 10 pages by spend — these drive the most QS impact
- Cross-reference with keyword-level QS data (Columns → Quality Score → Landing page exp.)

### Step 2: Speed Check (Critical for Mobile-First SA Market)
- 70%+ of BeautyOnTApp traffic is mobile
- Target: page load under 3 seconds on mobile
- Tools: Google PageSpeed Insights (free), GTmetrix
- Check each top landing page individually — site-wide averages hide problem pages
- Common Shopify speed killers: unoptimized images, too many apps loading JS, render-blocking CSS, heavy Liquid loops

### Step 3: Message Match Audit
For each top landing page + the ads pointing to it:
- Does the page headline match the ad headline promise?
- Does the page content address the search intent behind the keyword?
- Is the primary CTA visible above the fold on mobile?
- Example: Ad says "Korean Skincare Essentials" → landing page should be /collections/korean-skincare, NOT homepage

### Step 4: Mobile Experience Check
- Is the page fully responsive?
- Can users add to cart within 2 taps from landing?
- Are product images zoomable?
- Is the price visible without scrolling?
- Are trust signals visible (reviews, ratings, delivery info)?
- Is the BeautyOnTApp 🖤 branding consistent?

### Step 5: Content Relevance
- Does the collection page have descriptive text (not just product grid)?
- Collection descriptions improve QS by providing keyword-relevant content
- Target: 150-300 words of relevant, keyword-rich description per collection page
- Does the product page have complete information (ingredients, how-to-use, skin type suitability)?

### Step 6: Conversion Path
- How many clicks from landing to checkout?
- Is Quick View available on collection pages?
- Are filters functional and fast?
- Does the page show delivery options (R75 same-day, R120 door-to-door, R60 locker)?
- Is the skin analysis booking (R285) CTAs visible where relevant?

## QS FIX PRIORITIZATION

| QS Sub-Factor | Fix Priority | Actions |
|---------------|-------------|---------|
| Landing Page Experience: Below Average | 1st (cheapest fix) | Speed optimization, content relevance, mobile UX |
| Ad Relevance: Below Average | 2nd | Tighter ad group theming, better keyword-to-ad alignment |
| Expected CTR: Below Average | 3rd | New ad copy with stronger hooks, extensions |

## LANDING PAGE TYPES AND REQUIREMENTS

### Collection Pages (most common ad landing)
- /collections/korean-skincare, /collections/south-african-brands, /collections/best-seller, etc.
- Must have: collection title, descriptive text (150-300 words), functional filters, product count, clear CTAs
- URL mapping: verify ads point to correct collection handle (e.g., SA Brands = /collections/south-african-brands, never /south-african-skincare)
- Best-seller handle = "Skincare" by design — breadcrumb "Home > Skincare" is intentional

### Product Pages
- Must have: product title, price, product description, ingredients, how-to-use, reviews, high-quality images, Add to Cart button above fold
- Mobile: price and CTA must be visible without scrolling

### Homepage
- Should NOT be the primary ad landing page for non-brand campaigns
- Brand campaigns (KS_C8, Search_Brand) → homepage is acceptable
- Non-brand campaigns → always point to relevant collection or product page

## PMAX FINAL URL EXPANSION CHECK

- PMax with URL expansion ON may send traffic to: About Us, Blog posts, Terms & Conditions, FAQ
- Pull PMax Landing Page report → sort by Cost
- If non-commercial pages appear in top 10 by cost → exclude those URLs or disable expansion
- This is checked in Step 4.6 of the PPC audit engine but gets its own deep-dive here

## ALWAYS WEB_FETCH BEFORE RECOMMENDING

**HARD RULE from memory:** Always web_fetch beautyontapp.com before making any site recommendation, collection page suggestion, UX advice, or feature recommendation. Never assume what's on the site — verify first. Claude previously recommended features the site already had (filtering, badges, quiz, Quick View, reviews).

## CROSS-SKILL INTEGRATION

| Skill | Relationship |
|-------|-------------|
| beautyontapp-ppc-audit-engine | Triggers this skill when QS < 7 found on high-spend keywords |
| beautyontapp-shopify | Theme code changes for speed/UX fixes |
| beautyontapp-seo-content | Collection page content also serves SEO — align keyword strategy |
| beautyontapp-google-ads | Campaign → landing page URL mapping |
| beautyontapp-tools-stack | PageSpeed Insights, GTmetrix, Screaming Frog for crawl analysis |

---

## 7-DIMENSION CRO SCORING (Page-Level)

Score each landing page 1-10 on these dimensions (ranked by impact):

1. **Value Proposition Clarity**: Can visitors understand what this page offers within 5 seconds? Beauty test: "Can I tell what skin concern this solves instantly?"
2. **Headline Effectiveness**: Does headline communicate core benefit? Outcome-focused ("Even-toned skin") not feature-focused ("Contains niacinamide").
3. **CTA Placement & Copy**: One clear primary action visible without scrolling? "Add to Routine" > "Add to Cart".
4. **Visual Hierarchy**: Can scanners get main message from headings + images? Product hero + benefit + price above fold on mobile.
5. **Trust Signals**: Reviews, ratings, badges near CTAs? Star rating, review count, "Same-day delivery" badge.
6. **Objection Handling**: Common concerns addressed on-page? "Suitable for all skin types" / skin type selector.
7. **Friction Points**: Unnecessary steps, slow loads, confusing UX? Mobile load <3s, clear variant selector, visible delivery info.

Score 50-70 = optimise. Score <50 = redesign. Score >70 = test incremental improvements.

### Quick Wins vs High-Impact
- **Quick wins** (implement today): Add review count near CTA, add "Same-day delivery" badge, fix mobile CTA visibility
- **High-impact** (A/B test): Headline rewrite, hero image change, page layout restructure
- **Test ideas**: UGC hero vs studio shot, benefit-led vs ingredient-led headline, single CTA vs dual CTA
