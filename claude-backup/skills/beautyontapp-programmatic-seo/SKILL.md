---
name: beautyontapp-programmatic-seo
description: Programmatic SEO for BeautyOnTApp — template-driven page generation at scale for location-based beauty pages, ingredient glossaries, brand comparison pages, concern-based landing pages, and routine pages. 12 playbook patterns adapted for Shopify Advanced with 1,400+ products across 6 stores. Auto-invoke for "programmatic SEO", "generate pages at scale", "template pages", "location pages", "glossary", "comparison pages", "auto-generate content", "[city] skincare", "skincare near me", or any request to create SEO pages at scale. NOT for individual page optimization (use beautyontapp-onpage-seo). NOT for blog content (use beautyontapp-seo-content).
---

# Programmatic SEO for BeautyOnTApp

Generate hundreds of SEO-optimized pages from templates + data. While Bash has no content strategy and Secret Skin publishes 1 blog/month, BeautyOnTApp can programmatically create pages that compound organic traffic for years. Each template creates 10-50+ unique pages that collectively dominate long-tail beauty searches in SA.

## HARD RULES
1. Every generated page must have unique, valuable content — not just data substitution.
2. Minimum 300 words of unique content per page (Google thin content threshold).
3. All pages must include FAQPage schema (GEO optimization).
4. Internal links to relevant products and collections on every page.
5. noindex pages that don't meet quality threshold rather than publishing thin content.
6. English only. ZAR pricing only.
7. VERIFY brand stocking via confirmed stocked list before creating "Where to Buy" or brand-specific pages. Do not create pages for brands NOT VERIFIED as stocked.

## 12 PROGRAMMATIC PLAYBOOKS

### 1. Location + Concern Pages
Template: "Best [Product Type] in [City] | BeautyOnTApp"
Pages: 6 cities × 10 concerns = 60 pages
Example: "Best Moisturizer for Dry Skin in Cape Town"
Data: City name, climate notes, nearest store address, relevant products
Unique content: City-specific climate advice (CT wind, JHB altitude dryness, KZN humidity)

### 2. Ingredient Glossary
Template: "[Ingredient] Benefits, Uses & Best Products | BeautyOnTApp"
Pages: 50+ ingredients = 50+ pages
Example: "Niacinamide — Benefits, Uses & Best Products in South Africa"
Data: Ingredient name, INCI name, benefits, skin types, concentrations, products containing it
Unique content: SA-specific advice, product recommendations with ZAR pricing

### 3. Brand vs Brand Comparisons
Template: "[Brand A] vs [Brand B]: Which is Better for [Concern]?"
Pages: 20+ brand pairs = 20+ pages
Example: "COSRX vs The Ordinary: Best for Hyperpigmentation"
Data: Brand info, product comparisons, pricing, ingredient analysis
Unique content: Side-by-side tables, expert verdict, SA availability

### 4. Concern Solution Hubs
Template: "Best Korean Skincare for [Concern] in South Africa"
Pages: 12 concerns = 12 pages
Example: "Best Korean Skincare for Hyperpigmentation in South Africa"
Data: Concern name, key ingredients, product recommendations
Unique content: SA-specific advice, melanin-rich skin considerations, routine sequences

### 5. Routine Builders
Template: "[Number]-Step [Skin Type] Skincare Routine"
Pages: 5 skin types × 3 routine lengths = 15 pages
Example: "5-Step Oily Skin Morning Routine"
Data: Skin type, step number, product category, recommended products
Unique content: Step-by-step instructions, product pairing logic, SA climate adjustments

### 6. Store Landing Pages (Enhanced)
Template: "Korean Beauty Store in [City] — [Mall Name] | BeautyOnTApp"
Pages: 6 stores = 6 pages (already partially built)
Data: Address, hours, Google Maps embed, photos, brands available, LocalBusiness schema
Unique content: Parking info, nearby landmarks, store-exclusive events, staff bios

### 7. "Best [Product Category]" Roundups
Template: "Best [Category] in South Africa ([Year])"
Pages: 15 categories = 15 pages
Example: "Best Korean Sunscreens in South Africa (2026)"
Data: Product name, price, rating, key features, pros/cons
Unique content: Testing methodology, expert picks, SA climate suitability

### 8. Price Comparison by Brand
Template: "[Brand] Products & Prices in South Africa"
Pages: 30+ brands = 30+ pages
Example: "COSRX Products & Prices in South Africa — Full Catalog"
Data: All products by brand, ZAR pricing, availability
Unique content: Price-per-ml analysis, bundle suggestions, store availability

### 9. Skin Type Guides
Template: "Complete [Skin Type] Skincare Guide — South Africa"
Pages: 6 skin types = 6 pages
Example: "Complete Guide to Oily Skin Care — South Africa"
Data: Skin type characteristics, recommended ingredients, products
Unique content: SA climate adaptation, melanin-rich skin variants, expert tips

### 10. Seasonal Skincare
Template: "[Season] Skincare Routine for South Africa"
Pages: 4 seasons × 3 regions = 12 pages
Example: "Winter Skincare Routine for Cape Town"
Data: Season, region, climate challenges, product recommendations
Unique content: Region-specific climate data, ingredient swaps by season

### 11. FAQ Hubs
Template: "[Topic] FAQ — Frequently Asked Questions"
Pages: 10 topic hubs = 10 pages
Example: "Korean Skincare FAQ — Everything You Need to Know"
Data: 15-20 questions per hub, sourced from Google PAA + customer queries
Unique content: Answers with BeautyOnTApp expertise, product links, schema markup

### 12. "Where to Buy" Pages
Template: "Where to Buy [Brand] in South Africa"
Pages: 30+ brands = 30+ pages
Example: "Where to Buy COSRX in South Africa — Online & In-Store"
Data: Brand name, BeautyOnTApp stores that stock it, online availability, pricing
Unique content: Authenticity verification, authorized retailer badge, comparison with other SA retailers

## TOTAL PAGE POTENTIAL
12 playbooks × avg 25 pages each = **~300 pages** of indexed, traffic-driving content. At average 50 monthly visits/page = 15,000 additional monthly organic visits.

## IMPLEMENTATION ON SHOPIFY

- Use Shopify Pages + Metafields for structured data
- Matrixify for bulk page creation
- Custom Liquid templates per playbook type
- Schema markup auto-injected per template (see beautyontapp-onpage-seo for schema rules)
- Internal linking automated: each page links to relevant collection + 3-5 products

## DECISION RULES

1. **Priority order**: Start with Playbooks 1, 2, and 12 — highest search volume and lowest competition.
2. **Quality gate**: Every page must score 8+/10 on GEO readiness before indexing.
3. **Bash counter**: Bash has zero programmatic content. Every indexed page widens the moat.
4. **Content freshness**: Update pricing and product recommendations quarterly. Add `dateModified` to schema.
5. **Cannibalization check**: Run Semrush Position Tracking to ensure programmatic pages don't cannibalize collection pages.
