---
name: beautyontapp-cro-engine
description: Full-funnel conversion rate optimization for BeautyOnTApp — 7-dimension page scoring, popup/form/signup/onboarding CRO, mobile-first SA optimization, beauty-specific trust signals, PDP optimization, collection page conversion, checkout friction reduction. Auto-invoke for "CRO", "conversion rate", "why aren't people buying", "bounce rate high", "add to cart rate", "checkout abandonment", "page not converting", "optimize page", "trust signals", "CTA", "above the fold", "friction", or any conversion optimization question. NOT for landing page QS (use beautyontapp-landing-page-optimization). NOT for cart recovery emails (use beautyontapp-cart-recovery).
---

# CRO Engine for BeautyOnTApp

You drive traffic. This skill converts it. Every page on beautyontapp.com is scored across 7 dimensions and optimized for SA mobile users (70%+ of traffic). Beauty CRO differs from generic e-commerce: skincare purchases are high-consideration, trust-dependent, and routine-driven.

## HARD RULES
1. Mobile-first. Always. SA is 70%+ mobile. Design for thumb zones.
2. Page load <3s on mobile. Every 0.1s = 8.4% conversion impact.
3. Never A/B test with <2,000 visitors per variant. At 1,500 orders/month, only test BIG changes.
4. No free delivery incentives in CRO tests. Business rule.
5. Social proof is the #1 conversion lever in beauty. Reviews > everything.

## 7-DIMENSION PAGE SCORING

Score every key page 1-10 per dimension. Total /70.

### 1. Value Proposition Clarity (10)
Can visitors understand what this page offers within 5 seconds?
- **PDP test**: "Can I tell what skin concern this solves instantly?"
- **Collection test**: "Do I know why these products are grouped together?"
- **Homepage test**: "Do I know what BeautyOnTApp is and why I should care?"
- Fix: One clear headline above fold. Benefit-first, not feature-first.

### 2. Headline Effectiveness (10)
Does the headline communicate the core benefit?
- ✅ "Even-toned, glowing skin in 14 days" (outcome)
- ❌ "COSRX Advanced Snail 96 Mucin Power Essence 100ml" (just the product name)
- Fix: Add benefit subtitle under product title on PDPs.

### 3. CTA Placement & Copy (10)
One clear primary action visible without scrolling on mobile.
- Beauty CTA hierarchy: "Add to Routine" > "Add to Cart" > "Buy Now"
- Secondary CTA: "Book Skin Analysis" (drives R285 consultation)
- Sticky mobile CTA bar at bottom of screen (never hide behind scroll)
- Fix: Replace "Add to Cart" with value-language CTAs.

### 4. Visual Hierarchy & Scannability (10)
Can scanners get main message from headings + images alone?
- Product hero + price + star rating + key benefit visible above fold on mobile
- Ingredient highlights as visual badges, not buried in description
- Fix: Add visual ingredient badges (niacinamide, snail mucin, SPF icons)

### 5. Trust Signals (10)
Reviews, ratings, badges near CTAs.
- **Must-have**: Star rating + review count next to price
- **Should-have**: "Same-day delivery" badge, "Tested in 6 stores" badge
- **Nice-to-have**: "SA #1 K-beauty retailer", ingredients sourcing badges
- **Beauty-specific**: Before/after photos, dermatologist endorsements, SAHPRA compliance
- Fix: Add trust badge row between price and ATC button.

### 6. Objection Handling (10)
Are common concerns addressed on-page?
- "Will this work for my skin?" → Skin type compatibility indicator
- "Is it worth the price?" → Cost-per-day calculator or comparison
- "Is it authentic?" → "Authorised retailer" badge with brand logos
- "What if it doesn't work?" → Returns policy link near CTA
- Fix: Add collapsible FAQ section on every PDP.

### 7. Friction Points (10)
Unnecessary steps, slow loads, confusing UX.
- Mobile load <3s (PageSpeed Insights)
- Variant selector clear and tappable (44px minimum touch targets)
- Delivery info visible without scrolling
- Guest checkout available (don't force account creation)
- Fix: Audit mobile checkout flow — every additional field = 7% abandonment increase.

## SCORING THRESHOLDS

| Score | Action |
|---|---|
| 60-70 | Optimized. Test incremental improvements. |
| 45-59 | Needs work. Implement quick wins first. |
| 30-44 | Significant issues. Prioritize top 3 dimensions. |
| <30 | Redesign required. |

## QUICK WINS (Implement This Week)

1. Add star rating + review count next to price on all PDPs
2. Add "Same-day delivery in JHB" badge above ATC button
3. Make ATC button sticky on mobile (always visible at bottom)
4. Add "Suitable for [skin type]" badge on PDPs where data exists
5. Review checkout fields via Shopify admin → Settings → Checkout. On Shopify Advanced, field removal is limited (unlike Plus). Use checkout extensibility API for customization. Flag for Plus upgrade evaluation if checkout friction is a major conversion blocker.

## PAGE-SPECIFIC CRO

### Product Detail Pages (PDPs)
- Hero image: lifestyle/application shot (not just product on white)
- Below hero: price + rating + "Same-day delivery" + ATC
- Tab 1: How to use + routine position
- Tab 2: Ingredients with benefit callouts
- Tab 3: Reviews with photo reviews prioritized
- FAQ section: 3-5 questions (with FAQPage schema)
- "Complete Your Routine" cross-sell section

### Collection Pages
- Above grid: 100-300 words of SEO/GEO-optimized content
- Filter bar: Skin type, concern, price range, brand
- Product cards: Image + name + price + rating + "Best Seller" badge
- Infinite scroll = bad. Paginated with "Load More" = good.

### Homepage
- Hero: rotating banner with clear CTA per slide
- Section 2: Top sellers (social proof)
- Section 3: Shop by concern (personalization path)
- Section 4: SA brands spotlight (margin driver)
- Section 5: "Find a store near you" (O2O bridge)

## DECISION RULES

1. **Before optimizing any page**: Score all 7 dimensions first. Fix the lowest score.
2. **When CRO conflicts with SEO**: CRO wins on PDPs and checkout. SEO wins on collection pages and blog.
3. **When testing**: Only test changes expected to produce 30%+ lift. At current volume, smaller lifts aren't statistically detectable.
4. **When Bash improves their beauty UX**: Our CRO advantage is consultation-led. Add "Not sure? Book a free skin analysis" CTAs everywhere.
5. **Mobile always**: Test on real Android devices on SA mobile networks. Chrome DevTools mobile emulation is not enough.
