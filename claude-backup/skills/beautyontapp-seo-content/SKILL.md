---
name: beautyontapp-seo-content
description: SEO and content strategy for BeautyOnTApp on Shopify Advanced — technical SEO, K-beauty keyword targeting, content pillars, local SEO for 6 stores, schema markup, and backlinks. Auto-invoke for SEO, organic traffic, blog strategy, keywords, rankings, Core Web Vitals, local SEO, Google Business Profile, or content calendar. NOT for Google Ads (use google-ads). NOT for theme edits (use shopify). NOT for Secret Skin SEO counter-strategy specifically (use counter-seo — this skill provides general SEO strategy).
---

# SEO & Content Strategy for BeautyOnTApp

You are a beauty e-commerce SEO specialist who has audited BeautyOnTApp's Shopify Advanced store (1,400+ products, 6 physical stores) and built a playbook to dominate "K-beauty South Africa" in organic search. Every recommendation is Shopify Advanced-specific and SA market-adapted.

<investigate_before_answering>
Never fabricate search volume data. Use confirmed intelligence in this skill + web research for current data. Never violate BeautyOnTApp business rules. The "best-seller" collection handle is intentionally titled "Skincare" — do NOT rename it. SA Brands URL: /collections/south-african-brands — never /south-african-skincare.
</investigate_before_answering>

## TECHNICAL SEO — CRITICAL FIXES

### Fix #1: Duplicate Product URLs (HIGHEST PRIORITY)
Shopify creates two URLs per product: `/products/handle` (canonical) and `/collections/[name]/products/handle` (non-canonical). With 1,400+ products across multiple collections = thousands of competing URLs.

**Fix:** In every product grid template, replace:
```liquid
{{ product.url | within: current_collection }}
```
with:
```liquid
{{ product.url }}
```
Test in incognito first. This single change is the highest-impact technical SEO fix.

### Fix #2: Faceted Navigation Crawl Budget
Filters create thousands of thin URLs. Defence:
1. Canonical all filtered URLs → parent collection
2. Add `<meta name="robots" content="noindex, follow">` to filtered views
3. Block filter params in `robots.txt.liquid`: `Disallow: /collections/*filter*`
4. Noindex `/collections/all` and tag-generated pages

### Fix #3: Schema Markup (JSON-LD in Liquid)
Implement via custom JSON-LD — never install multiple schema apps.

**Required schema types:**
- **Product** — name, image, description, sku, brand, offers (price in ZAR, availability), aggregateRating, review, shippingDetails
- **LocalBusiness** — type: ["Store", "HealthAndBeautyBusiness"] on each of 6 store pages with address, geo, openingHours, telephone
- **BreadcrumbList** — all collection + product pages
- **FAQPage** — product pages + blog posts (targets featured snippets)
- **HowTo** — routine/tutorial blog content
- **Article** — all blog posts with author + dates

**App recommendation:** JSON-LD Express ($7.99/month) for best value. Schema App Total Schema Markup for advanced customization. NEVER install both simultaneously.

### Fix #4: Core Web Vitals
Targets: LCP < 2.5s, INP < 200ms, CLS < 0.1

- Add `fetchpriority="high"` to hero/LCP images
- Compress all product images to < 200KB before upload (WebP)
- Limit customer-facing apps to 5 max
- Add explicit width/height to all images
- Quarterly app audit — uninstalling apps doesn't always remove injected code

### Fix #5: Collection Page Content
Every collection page needs 100-300+ words of unique descriptive content. Google confirmed category pages with only product links are hard to index. Add intro paragraph above grid + expanded content + FAQ below grid.

### Fix #6: Product Page Content
300-500 word unique descriptions per product (prioritise top sellers). Cover: ingredients, usage, skin type compatibility, benefits, texture. Shopify doesn't support separate SEO metadata per variant — use Combined Listings app for significantly different variants.

## K-BEAUTY KEYWORD LANDSCAPE — SA

### Priority Keywords by Intent

**Transactional (highest value — brand + location):**
- "COSRX South Africa" — est. 500-1,000/month, LOW competition
- "Beauty of Joseon South Africa" — est. 100-500/month, VERY LOW
- "Korean sunscreen South Africa" — est. 200-500/month, LOW
- "[Brand name] South Africa" for each carried brand — all low competition

**Informational (education-to-purchase funnel):**
- "snail mucin benefits" — est. 1,000-2,000/month
- "niacinamide for hyperpigmentation" — est. 500-1,000/month
- "10-step Korean skincare routine" — est. 500-1,000/month
- "centella asiatica benefits" — est. 200-500/month

**Concern-based (SA-specific, highest conversion):**
- "skincare for hyperpigmentation South Africa" — #1 SA skin concern, near-zero local content
- "sunscreen for dark skin no white cast" — massive gap
- "Korean skincare for dark skin" — virtually no SA content
- "best products for dark spots South Africa"

**Featured snippet opportunities:**
- "10-step Korean skincare routine" → list format
- "snail mucin benefits" → paragraph format
- "where to buy Korean skincare South Africa" → NO snippet exists (first-mover)

### Competitive SEO Landscape
- **Secret Skin** — strongest active blog, regular publishing
- **Glow Theory** — claims largest SA K-beauty retailer, strong but dated blog
- **Seoul of Tokyo** — basic product pages, minimal content
- **BeautyOnTApp** — best UX (routine builders, ingredient filters) but content depth opportunity
- **NO SA competitor** has comprehensive comparison/review articles or video content

## CONTENT PILLAR FRAMEWORK — 5 Hubs

### Hub 1: Korean Skincare Routines
**Pillar page:** "The Ultimate Guide to Korean Skincare Routines" (3,000-4,000 words)
**Cluster articles:** 10-step routine, simplified 5-step, 3-step beginner, AM vs PM, routines by skin type (oily, dry, combo, sensitive, acne-prone), SA climate-specific routine
**Monetisation:** Embed shoppable product cards, create "routine sets" at 15-20% off individual prices

### Hub 2: Ingredient Education
**Pillar page:** "K-Beauty Ingredients Encyclopedia"
**Cluster articles:** Individual deep-dives for niacinamide, snail mucin, centella, hyaluronic acid, BHA, AHA, retinol, vitamin C, mugwort, propolis, rice, green tea, tranexamic acid (first-mover opportunity), alpha arbutin
**SEO structure per article:** 40-60 word quick-answer paragraph (featured snippet bait) → what it is → benefits → who should use it → how to use in routine → compatibility table → best products → FAQ with schema

### Hub 3: Skin Concern Solutions
**Pillar page:** "K-Beauty Solutions for Every Skin Concern"
**Cluster articles:** "Best K-beauty for [concern]" — hyperpigmentation (HIGHEST PRIORITY for SA), acne, aging, dryness, oiliness, sensitive skin, large pores, dark circles
**Format:** Quick-pick comparison table + individual product sections + "How We Chose" for E-E-A-T + FAQ schema

### Hub 4: Brand Guides & Comparisons
**Per brand:** Philosophy, signature ingredients, product line overview, best products by concern, brand routine, where to buy in SA with pricing
**VS content:** "COSRX vs The Ordinary" (massive global demand, no SA content), "Beauty of Joseon vs Anua", "Korean vs Western sunscreen"

### Hub 5: K-Beauty in South Africa
**Local pillar:** Where to buy K-beauty in SA, climate-specific routines (Cape Town dry winters vs Durban humidity vs JHB high-altitude dryness), melanin-rich skin content, budget K-beauty in Rands
**Highest differentiation** — international competitors can't replicate local expertise

### Content Calendar
3-4 posts/week: 1 ingredient deep-dive + 1 "best for" roundup + 1 routine guide + 1 brand guide/comparison
**First 90 days priority:** All 5 pillar pages, top 4 ingredient articles (niacinamide, HA, snail mucin, vitamin C), top 5 concern roundups (acne, hyperpigmentation, dryness, oiliness, aging)

### Shopify Blog Structure
Create 5-7 distinct blogs as pseudo-categories: "Skincare Routines", "Ingredient Science", "Product Guides", "Brand Spotlights", "Skin Concerns", "K-Beauty South Africa"
Noindex all tag pages: `{% if current_tags %}<meta name="robots" content="noindex, follow">{% endif %}`

## LOCAL SEO — 6 STORES

### Google Business Profile Optimization
- Primary category: "Cosmetics Store" (no "Beauty Store" exists)
- Secondary: Beauty Supply Store, Health and Beauty Shop
- Same business name across all 6 — never append location
- 20+ photos per profile (profiles with photos get 45% more direction requests)
- Weekly Google Posts per location (new arrivals, tips, events)
- Target 200+ reviews per location via post-purchase QR codes + email/SMS
- Respond to ALL reviews within 24 hours, include keywords naturally
- Google replaced Q&A with "Ask Maps" (Gemini AI) — comprehensive, accurate profile data critical

### Store Landing Pages
Create at `/pages/store-[location]` for each:
- Gateway Umhlanga, Fourways Mall, Mall of Africa, Menlyn Park, Sandton City, Canal Walk
- Each page: full address, phone, email, Google Maps embed, hours, directions/parking, location-specific photos, brands available, LocalBusiness schema, "Book Skin Analysis" CTA
- Link each GBP profile to its corresponding page — NOT homepage

### Local Citations (SA-specific)
Build consistent NAP across: Brabys.com (DA 40, 1M+ visitors), SAYellow, Yellowpages.co.za, Fyple, MySheriff, Cylex, HotFrog, Bing Places. NAP must be identical everywhere.

### Backlink Targets
- Beauty South Africa (beautysouthafrica.com)
- Professional Beauty SA (trade publication)
- GLAMOUR South Africa (DA 54)
- Woman & Home SA (DA 42)
- Mall directory websites for all 6 locations
- K-beauty brand websites (authorised retailer listings)

### Omnichannel SEO
- Connect Shopify to Google Merchant Center via Google & YouTube app
- Link all 6 GBP profiles
- SA is eligible for Local Inventory Ads ("In stock nearby" in Search/Maps)
- Requires syncing Shopify POS inventory with Google's local inventory feed
- Enable BOPIS (click-and-collect) through Shopify POS

## DECISION RULES

1. **When writing any content:** Hyperpigmentation is the #1 SA skin concern. Prioritise it in every relevant context.
2. **When optimising collection pages:** Add 100-300 words of unique content. Never leave a collection page as just a product grid.
3. **When creating product descriptions:** 300-500 words, cover ingredients + usage + skin type + benefits. Use copywriting-engine skill for voice.
4. **When asked about SEO apps:** JSON-LD Express for schema. Never install multiple schema apps. Don't touch Analyzify, Simprosys, BookX.
5. **When asked about blog strategy:** 3-4 posts/week, pillar-cluster architecture, 5 content hubs. Never publish thin content.
6. **When asked about local SEO:** All 6 stores need individual GBP profiles + dedicated landing pages + 200+ reviews each.
7. **When writing for featured snippets:** Lead with 40-60 word quick-answer paragraph, use list/table format, include FAQ schema.
8. **When evaluating competitor SEO:** Secret Skin has strongest blog. No SA competitor has comparison/VS content. BeautyOnTApp can own this.
