---
name: beautyontapp-web-performance
description: Web performance optimization for BeautyOnTApp — Core Web Vitals, Lighthouse audits, image optimization (AVIF/WebP), font optimization, third-party script management, mobile-first SA network optimization, Shopify-specific performance patterns, page weight budgets. Auto-invoke for "site speed", "page speed", "slow loading", "Core Web Vitals", "LCP", "CLS", "INP", "Lighthouse", "performance score", "mobile speed", "images too large", "third party scripts", or any question about site speed. NOT for SEO (use beautyontapp-onpage-seo). NOT for CRO (use beautyontapp-cro-engine).
---

# Web Performance for BeautyOnTApp

SA mobile traffic is 70%+. Many users browse on 3G/4G with limited data plans. Every 0.1s of mobile speed improvement = 8.4% conversion increase. Bash runs on VTEX with enterprise CDN infrastructure. BeautyOnTApp wins by being lighter, faster, and optimized for SA network conditions on Shopify.

## HARD RULES
1. Target: <3s mobile load time. <2.5s = competitive advantage.
2. Page weight budget: <1.5MB total, <300KB JavaScript.
3. Never lazy-load the LCP (Largest Contentful Paint) image.
4. Never add apps without measuring performance impact first.
5. Quarterly app audit — uninstalled apps leave zombie code.

## CORE WEB VITALS TARGETS

| Metric | Good | Needs Improvement | Poor | BeautyOnTApp target |
|---|---|---|---|---|
| LCP | ≤2.5s | 2.5-4.0s | >4.0s | <2.0s |
| INP | ≤200ms | 200-500ms | >500ms | <150ms |
| CLS | ≤0.1 | 0.1-0.25 | >0.25 | <0.05 |
| FCP | ≤1.8s | 1.8-3.0s | >3.0s | <1.5s |
| TBT | ≤200ms | 200-600ms | >600ms | <150ms |

## IMAGE OPTIMIZATION (1,400+ Products)

### Format Priority
1. WebP (Shopify auto-serves via CDN — confirmed)
2. AVIF (40-50% smaller than WebP — VERIFY Shopify CDN AVIF support before relying on it. Shopify may not auto-serve AVIF.)
3. JPEG as fallback only

### Size Budgets
| Image type | Max dimensions | Max file size |
|---|---|---|
| Product hero | 800×800px | <100KB |
| Collection banner | 1200×400px | <150KB |
| Blog hero | 1200×630px | <120KB |
| Thumbnail | 400×400px | <40KB |
| Logo | SVG preferred | <10KB |

### LCP Image Optimization
```html
<img src="hero.webp" fetchpriority="high" loading="eager" width="800" height="800" alt="...">
```
- fetchpriority="high" on the first visible image
- loading="eager" (NOT lazy) for above-fold images
- Explicit width/height to prevent CLS
- Preload in `<head>`: `<link rel="preload" as="image" href="hero.webp">`

## FONT OPTIMIZATION

- Use system fonts where possible: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto`
- If custom fonts required: `font-display: swap` (prevents invisible text)
- Preload critical fonts: `<link rel="preload" as="font" type="font/woff2" href="..." crossorigin>`
- Maximum 2 custom font families, 3 weights each
- Subset fonts to Latin characters only (remove CJK if present)

## THIRD-PARTY SCRIPT MANAGEMENT

### Script Budget
Max 5 essential third-party scripts. Every additional script costs ~50-100ms.

### Essential (keep):
- Analyzify v4 (tracking — single source of truth)
- Shopify core scripts (non-negotiable)
- Judge.me or review app (social proof)
- Growave (legacy loyalty — being replaced by Toki; remove once migration completes)
- BookX (booking)

### Audit quarterly:
- Remove unused app scripts (apps leave code after uninstall)
- Check `theme.liquid` and `layout/*.liquid` for orphan `<script>` tags
- Use Chrome DevTools → Network → filter JS to see all loaded scripts
- Screaming Frog > Custom Extraction for script inventory

### Defer non-critical:
```html
<script src="non-critical.js" defer></script>
```
Or load via Intersection Observer when user scrolls to relevant section.

## SHOPIFY-SPECIFIC PERFORMANCE

### Liquid Rendering
- Minimize `{% for %}` loops on collection pages (each iteration = render time)
- Use `{% render %}` not `{% include %}` (scoped rendering, fewer side effects)
- Paginate collections at 48 products/page (balance between UX and performance)
- `{% cache %}` Liquid tag — VERIFY availability on Shopify Advanced. May be Plus-only or require 2025+ theme engine. Do not implement without verification.

### App Impact Assessment
Before installing any new Shopify app:
1. Run Lighthouse before installation (save score)
2. Install app
3. Run Lighthouse after installation
4. If score drops >5 points → evaluate if the app's value justifies the cost
5. Document in app inventory spreadsheet

### CDN & Caching
- Shopify CDN handles this automatically via cdn.shopify.com
- Ensure all images use Shopify's image CDN URLs (not uploaded to custom hosting)
- Static assets cached at edge globally
- Dynamic pages: use Shopify's built-in caching (no custom CDN needed)

## SA NETWORK OPTIMIZATION

### Mobile Data Reality
- Many SA users on capped data plans (1-5GB/month)
- 3G still significant in non-metro areas
- Optimize for 3G: target <3s on "Slow 3G" in Chrome DevTools
- Every KB matters — users will bounce if a page consumes too much data

### Testing Protocol
1. Chrome DevTools → Network → "Slow 3G" throttle → load key pages
2. Real device testing: Android mid-range phone on Vodacom/MTN network
3. PageSpeed Insights (both Mobile and Desktop scores)
4. WebPageTest (set location to Cape Town if available)

## PERFORMANCE MONITORING CADENCE

| Check | Frequency | Tool |
|---|---|---|
| Core Web Vitals (field data) | Monthly | Google Search Console |
| Lighthouse audit | Monthly | Chrome DevTools |
| PageSpeed Insights | After any theme/app change | PageSpeed Insights |
| Script inventory | Quarterly | Chrome DevTools Network tab |
| App impact assessment | Before every app install | Lighthouse before/after |
| Image audit | Quarterly | Screaming Frog |

## DECISION RULES

1. **When LCP >2.5s**: Check hero image size, preload status, and font loading. Fix images first.
2. **When CLS >0.1**: Add explicit width/height to all images. Check for dynamic content insertion.
3. **When installing a new app**: Lighthouse before AND after. No exceptions.
4. **When performance drops after theme update**: Check for new scripts in theme.liquid. Uninstalled app code may have returned.
5. **When Bash is faster**: Their VTEX enterprise infrastructure has a CDN advantage. We win by being lighter (fewer scripts, smaller images, system fonts).
6. **When PageSpeed score drops below 70**: Stop all other optimization work until performance is restored. Speed = conversions = revenue.
