---
name: beautyontapp-webapp-testing
description: Python Playwright live-site testing for PNCapital — validate beautyontapp.com, Pastry, and Mzuri sites; verify Meta Pixel and Analyzify v4 events fire with Variant ID as Content ID; screenshot and scrape competitors (Bash, Secret Skin, Woolworths, Takealot, Clicks, Dis-Chem, Glow Theory, Seoul of Tokyo, MYKOCO); inspect live OG tags, canonical URLs, JSON-LD schema; check Core Web Vitals; detect broken links; capture network requests to spot pixel duplicates or F&I Data Sharing leaks; validate /pages/delivery R30 pricing compliance. Auto-invoke when T asks to test, verify, check, scrape, screenshot, audit live, capture network, inspect DOM, or validate any live URL. Also auto-invoke for "does the pixel fire", "what does Bash show", "verify our OG image", "is Secret Skin bidding on X", "is our schema correct", "screenshot their storefront", "are we showing R30 on delivery". Uses headless Chromium in the Claude.ai Linux sandbox.
---

# BeautyOnTApp Webapp Testing

## Purpose

T's skills give advice about what to check. This skill actually checks it. Runs Python Playwright in Claude.ai's Linux sandbox against live public URLs — beautyontapp.com, the 3 brand sites, and all tracked competitors — and returns real data (screenshots, DOM, network requests, HTTP status) instead of theoretical recommendations.

This is the Anthropic webapp-testing skill adapted for PNCapital. The stock Anthropic version is built for local dev server testing (localhost:5173) which T does not do on claude.ai. This version is built for public site testing and competitor intelligence.

## When to use

- "Does the Meta Pixel fire on beautyontapp.com checkout?"
- "Screenshot Bash's K-beauty landing page"
- "Is Secret Skin bidding on COSRX keywords today?" (check their landing pages for intent signals)
- "Verify the OG image on our homepage shows correctly"
- "Check if /pages/delivery shows R30 for pickup"
- "Scrape Woolworths Beauty's product tiles and list the K-beauty brands they stock"
- "What's our Lighthouse score for mobile on the homepage?"
- "Are there broken links in the south-african-brands collection?"
- "Take a screenshot of the Glow Theory storefront and list their brand logos"
- "Inspect the JSON-LD schema on a Pastry product page"
- "What pixel events fire when I add a product to cart?"

## When NOT to use

- Local dev testing (T doesn't run local servers on claude.ai sandbox)
- Authenticated admin flows (Shopify admin, Google Ads UI) — use Chrome extension prompts instead
- Real-time monitoring — each Claude.ai session starts with a fresh container, so there's no persistent watcher
- Testing the Flutter app — use Claude Code with the device locally

## Setup (first run per session)

Claude.ai sandbox starts fresh each conversation. Install Playwright on first use:

```bash
pip install playwright --break-system-packages
playwright install chromium
playwright install-deps chromium 2>/dev/null || true
```

Time: ~30-60 seconds. Cache across the same conversation.

## Core patterns

### Pattern 1: Verify Meta Pixel fires

```python
from playwright.sync_api import sync_playwright

pixel_events = []

def capture_pixel(request):
    if 'facebook.com/tr' in request.url:
        pixel_events.append({
            'url': request.url,
            'method': request.method,
            'post_data': request.post_data
        })

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.on('request', capture_pixel)
    page.goto('https://beautyontapp.com/products/[handle]')
    page.wait_for_load_state('networkidle')
    # Simulate add to cart via UI or direct cart API
    browser.close()

# Analyze pixel_events for event name, Content ID, Variant ID
```

Check: PageView fires on landing, ViewContent fires on PDP, AddToCart fires on button click, InitiateCheckout fires on checkout button.

### Pattern 2: Verify Analyzify v4 Custom Pixel

Analyzify v4 routes through Shopify Web Pixels API. Look for:

```python
# Analyzify sandbox pixel ID format
analyzify_calls = [r for r in requests if 'analyzify' in r.url.lower() or 'web-pixels' in r.url]
```

Confirm: Variant ID appears as Content ID. Confirm no duplicate fires (F&I Data Sharing must NOT be re-enabled).

### Pattern 3: Competitor screenshot + DOM inspection

```python
with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={'width': 375, 'height': 812})  # mobile first
    page.goto('https://bash.com/collections/beauty')
    page.wait_for_load_state('networkidle')
    page.screenshot(path='/tmp/bash-beauty-mobile.png', full_page=True)

    # Extract product tiles
    products = page.locator('[data-product-card], .product-item, .product-tile').all()
    for p in products[:20]:
        print(p.inner_text())

    browser.close()
```

Competitor URLs to keep handy:

| Competitor | URL | Focus |
|-----------|-----|-------|
| Bash (TFG) | bash.com | K-beauty, Beauty Box, pricing |
| Woolworths Beauty | woolworths.co.za/cat/Beauty/_/N-1z13s3s | Exclusives, AMAZI |
| Takealot | takealot.com/beauty | TakealotMORE, pricing |
| Clicks | clicks.co.za | Private label, ClubCard |
| Dis-Chem | dischem.co.za | Benefits of bulk, pharmacist model |
| Secret Skin | secretskin.co.za | 80+ K-beauty brands, no SA brands |
| Glow Theory | glowtheory.co.za | Skincare curation |
| Seoul of Tokyo | seoulof tokyo.co.za | K-beauty + J-beauty |
| MYKOCO | mykoco.co.za | K-beauty specialist |
| EggBeauty | weareegg.com | K-beauty |

### Pattern 4: OG tag and schema verification

```python
page.goto('https://beautyontapp.com/products/[handle]')
page.wait_for_load_state('networkidle')

# OG tags
og_data = page.evaluate("""() => {
    const meta = {};
    document.querySelectorAll('meta[property^="og:"], meta[name^="twitter:"]').forEach(el => {
        meta[el.getAttribute('property') || el.getAttribute('name')] = el.getAttribute('content');
    });
    return meta;
}""")

# JSON-LD schema
schemas = page.evaluate("""() => {
    return Array.from(document.querySelectorAll('script[type="application/ld+json"]'))
        .map(s => JSON.parse(s.textContent));
}""")
```

Verify: Product schema has brand, offers, availability, GTIN (agentic commerce readiness). BreadcrumbList present. Organization on homepage. LocalBusiness on store pages.

### Pattern 5: Core Web Vitals + Lighthouse metrics

Use Playwright's performance API:

```python
metrics = page.evaluate("""() => {
    return new Promise(resolve => {
        new PerformanceObserver((list) => {
            const entries = list.getEntries();
            resolve(entries.map(e => ({
                name: e.name, value: e.value || e.duration, type: e.entryType
            })));
        }).observe({type: 'largest-contentful-paint', buffered: true});
        setTimeout(() => resolve('timeout'), 5000);
    });
}""")
```

Or use PageSpeed Insights API directly for a proper Lighthouse run:

```python
import requests
api_key = '[T provides]'
url = f'https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://beautyontapp.com&strategy=mobile&key={api_key}'
data = requests.get(url).json()
lcp = data['lighthouseResult']['audits']['largest-contentful-paint']['displayValue']
cls = data['lighthouseResult']['audits']['cumulative-layout-shift']['displayValue']
```

### Pattern 6: Broken link check

```python
from urllib.parse import urljoin
page.goto('https://beautyontapp.com/collections/south-african-brands')
page.wait_for_load_state('networkidle')

hrefs = page.evaluate("""() => Array.from(document.querySelectorAll('a[href]'))
    .map(a => a.href).filter(h => h.includes('beautyontapp.com'))""")

broken = []
for href in set(hrefs):
    resp = page.request.get(href)
    if resp.status >= 400:
        broken.append((href, resp.status))
```

### Pattern 7: /pages/delivery R30 verification

Business rule: Store pickup is R30, NOT free. Critical for KS_C8's 6th sitelink.

```python
page.goto('https://beautyontapp.com/pages/delivery')
page.wait_for_load_state('networkidle')
content = page.content()

# Must show R30 for store pickup
assert 'R30' in content, 'MISSING R30 store pickup pricing'
assert 'R60' in content, 'Missing R60 locker'
assert 'R120' in content, 'Missing R120 door-to-door'
assert 'R75' in content, 'Missing R75 same-day (Sandton + MoA)'

# Must NOT say "free delivery" anywhere
assert 'free delivery' not in content.lower(), 'Free delivery text detected - violates business rule'
```

## Always run headless on claude.ai

```python
browser = p.chromium.launch(headless=True)
```

The sandbox has no display — non-headless will fail. This is the opposite of lackeyjb/playwright-skill which defaults to headless=False (that's for Claude Code with a real desktop).

## Output conventions

1. After any screenshot, save to `/home/claude/output/[task-name]/` and use `present_files` to surface for T
2. For data extraction, output JSON + human-readable summary
3. For pixel verification, output a table: Event Name | Fired | Content ID | Variant ID Match | Notes
4. For broken links, output CSV with status codes
5. Always include the URL tested and timestamp

## PNCapital-specific test scenarios (ready to run)

### Scenario A: Full site health check
Test homepage + top 5 collections + 3 product pages. Capture: status, LCP, CLS, OG image, pixel fires. Output: health scorecard.

### Scenario B: Competitor K-beauty audit
Screenshot + scrape K-beauty landing pages for Bash, Secret Skin, Woolworths, Glow Theory, Seoul of Tokyo. List brands each stocks. Output: gap analysis table.

### Scenario C: Pixel integrity audit
Walk through homepage → collection → PDP → add to cart → cart → checkout button. Log every pixel fire. Flag: duplicates, missing Purchase event mapping, F&I leaks.

### Scenario D: Schema.org audit
Verify Product, Organization, LocalBusiness, BreadcrumbList, FAQPage schemas fire on appropriate pages. Required for agentic commerce (UCP) + AEO.

### Scenario E: Delivery page compliance
Check /pages/delivery shows all 4 rates correctly (R30/R60/R75/R120) and never says "free delivery."

### Scenario F: Meta Ad Library screenshot
Navigate to Meta Ad Library, search a competitor name, screenshot active ads. (Ad Library is public — no auth needed.)

### Scenario G: Google Business Profile check
Navigate to each of 6 store GBPs, screenshot the main card, extract hours and ratings.

## Integration with existing PNCapital skills

- **beautyontapp-shopify** — verify Analyzify v4 tracking integrity on live site
- **beautyontapp-meta** — validate Meta Pixel and CAPI event parity
- **beautyontapp-google-ads** — not directly (needs auth) but can verify landing page QS factors
- **beautyontapp-analytics** — compare GA4 numbers against live pixel fires
- **beautyontapp-counter-ppc, beautyontapp-counter-seo** — scrape Secret Skin live
- **beautyontapp-bash-intel** — scrape Bash live
- **beautyontapp-woolworths-intel** — scrape Woolworths Beauty live
- **beautyontapp-sa-competitive-scanner** — bulk competitor monitoring
- **beautyontapp-web-performance** — actual LCP/CLS/INP measurements
- **beautyontapp-onpage-seo, beautyontapp-seo-content** — verify meta tags, schema, canonicals
- **beautyontapp-tools-stack** — supplements Screaming Frog for targeted checks without paid licence

## Guidelines

- ALWAYS use `headless=True` on claude.ai (no display in sandbox)
- ALWAYS wait for `networkidle` on dynamic pages before DOM inspection
- NEVER test authenticated flows requiring T's passwords — ask T to provide session cookies if needed, or use Chrome extension prompts for admin tasks
- NEVER scrape at aggressive rates — respect competitors' robots.txt and add `page.wait_for_timeout(2000)` between requests
- NEVER store or transmit T's credentials — if testing requires auth, test only the pre-auth state
- ALWAYS save screenshots to `/home/claude/output/` and surface via present_files
- ALWAYS include the URL and timestamp in output
- PREFER `page.request.get(url)` for status checks (faster than full page loads)
- For competitor scraping, set a realistic User-Agent: `page = browser.new_page(user_agent='Mozilla/5.0 ...')` — default Playwright UA sometimes gets blocked

## Anti-fabrication protocol

If the site is down, returns 403, or pixel doesn't fire — report that accurately. Do NOT fabricate results. Do NOT write "pixel verified" when Playwright couldn't load the page. NOT VERIFIED beats false confidence.

## Self-check before delivery

Before returning results to T, verify:
1. Playwright actually ran (not a simulated response)
2. Screenshots saved and are accessible via present_files
3. Network requests actually captured (not hallucinated)
4. URL and timestamp in every report
5. If assertion failed, the failure is clearly flagged (don't bury a broken pixel in a positive-sounding summary)
6. Business rule violations (e.g., "free delivery" text on /pages/delivery) surfaced prominently, not as a footnote
