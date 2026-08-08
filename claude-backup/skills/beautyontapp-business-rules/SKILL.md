---
name: beautyontapp-business-rules
description: Core business rules, brand guidelines, pricing, delivery, and decision frameworks for all BeautyOnTApp brands. Auto-invoke alongside any other BeautyOnTApp skill, or for customer-facing content, pricing, chatbot config, ad copy, or brand voice decisions. NOT for campaign-specific settings (use google-ads or meta). NOT for code or theme edits (use shopify).
---

# BeautyOnTApp Core Business Rules & Decision Frameworks

These rules apply across ALL domains — Shopify, Meta Ads, Google Ads, Flutter app, chatbot, email, social media, and any customer-facing content. This skill co-triggers with every domain-specific skill.

<investigate_before_answering>
Never speculate about pricing, product rankings, brand relationships, or store configurations you have not verified against this skill. Never fabricate sales data, conversion rates, or performance metrics. If you don't have confirmed data, say: "I don't have confirmed data for this — can you verify?" Do not say something just to fill space. If you don't know, say you don't know.
</investigate_before_answering>

## HARD RULES — VIOLATIONS ARE UNACCEPTABLE

1. NEVER fabricate data. Wrong information is worse than no information. Silence beats fabrication.
2. NEVER fill space with generic advice. Every statement must be grounded in verified information from this skill.
3. NEVER say "you could try X or Y" when a confirmed correct answer exists. Give the answer.
4. If uncertain, say so. Ask ONE focused question. Do not present menus of possibilities.
5. T communicates directly and briefly. Execute immediately — do not re-explain what T already knows.
6. T corrects errors sharply. Never repeat a mistake or re-cover completed work.
7. Check all context before responding. Contradicting prior confirmed information is a serious failure.

## Non-Negotiable Business Rules

**GOVERNANCE HIERARCHY**: This skill's hard rules override ALL other skills. If a strategy framework or external playbook conflicts with these rules, business-rules wins. No exceptions. Strategic recommendations that violate business rules (budget ceilings, delivery pricing, tracking setup, brand classification) are invalid regardless of framework logic. Hierarchy: business-rules → hbs-strategy (WHAT to analyze) → mckinsey-ai (HOW to analyze) → domain skills (execution).

### 1. NO Free Delivery — EVER
- Standard: R60 (drop box/locker) or R120 (door-to-door), 1–4 days SA
- same-day delivery (Sandton + Mall of Africa): R75
- Customer-facing term: "same-day delivery." Internal/operational SLA: 1-hour turnaround. NEVER say "1-hour delivery" in ads, copy, or customer materials.
- NO free delivery threshold at ANY order value
- NEVER promise, imply, or advertise free shipping/delivery in ANY context: ads, email, chatbot, website, social

### 2. Brand Identity
- Brand emoji: 🖤 (black heart) — NEVER 💚 or any other
- Chatbot name: "Bestie" — NEVER "Timmy"
- Customer email: customer@beautyontapp.co.za
- Orders email: orders@beautyontapp.com

### 3. Brand Classification — CRITICAL
"Proudly South African" brands (NEVER "in-house," "our own brand," "house brand," "private label"):
- Pastry Skincare, Mzuri Skin, B'AiR Skincare, Lelive, Forme, Skin Functional

K-beauty brands ("K-beauty" or "Korean skincare"):
- COSRX, ANUA, Beauty of Joseon, medicube, SKIN1004, SOME BY MI, AXIS-Y

### 4. Pricing
- Skin analysis: R285 (NOT R220 — corrected and confirmed)
- Hair analysis: R199
- Both bookable via BookX widget on beautyontapp.com

### 5. Store Facts
- 6 physical stores: Mall of Africa, Menlyn Park, Gateway Umhlanga, Fourways Mall, Sandton City, Canal Walk Cape Town
- 1,400+ products across 50+ brands (not 1,200)
- SA Brands collection: /collections/south-african-brands (NEVER /south-african-skincare)
- Beauty Under R200 collection: /collections/smart-collection

### 6. Language Rule
- ENGLISH ONLY on all Google Ads and Meta campaigns — NEVER suggest Afrikaans targeting

### 7. Ad Spend Ceilings
- Google Ads daily ceiling — never recommend exceeding (current value in `03_PNCapital_Business_Facts §Advertising Ceilings`; verify, do not hardcode)
- Meta Ads daily ceiling — never recommend exceeding (current value in `03_PNCapital_Business_Facts §Advertising Ceilings`; verify, do not hardcode)
- Combined monthly maximum — current value in `03_PNCapital_Business_Facts §Advertising Ceilings` (verify; it changes)

### 8. Product Rankings — Data Only
- Pastry Skincare = actual top revenue driver (21 of top 145 bestsellers)
- SA body care must lead creative and ad copy priority
- NEVER assume or fabricate rankings

## Tracking — Universal Rule
- Analyzify v4 = SINGLE SOURCE OF TRUTH (GA4, Google Ads, Meta Pixel 871956739065080, Meta CAPI)
- Purchase = ONLY primary conversion event across all platforms. All others (Add to Cart, Page View, Begin Checkout) = Secondary/observe only.
- **ALWAYS use "Conversions" column in Google Ads reports and CSV exports — NEVER "All conversions".** 4 Google-hosted actions (Clicks to call, Directions, Other engagements, Website visits) inflate "All conversions" by ~194 phantom conversions. These cannot be changed to Secondary (UI grayed out — excluded from account defaults, 0 campaigns assigned). Bidding is unaffected. The "Conversions" column only counts Purchase.
- Content ID = Shopify ID (NOT Variant ID) on BOTH browser pixel and CAPI integrations. Both Meta Catalogs use Shopify ID as retailer_id. [confirmed live on Analyzify, May 2026]
- Simprosys = product feeds ONLY, zero tracking
- Do-not-touch apps: Analyzify v4, Simprosys, BookX
- F&I (Facebook & Instagram channel) Data Sharing = OFF permanently. Never re-enable — causes duplicate pixel fires with mismatched event_ids.
- Pre-Feb 23 2026 data unreliable (bot traffic inflated all metrics). NEVER use as benchmark.

## Ads — Critical Prohibitions
- Acne Search campaign = money bleeder. Do NOT create or enable. Acne queries handled by PMax and Shopping only.
- Never start new campaigns on Maximise Conversions bidding. New campaigns must start on Maximize Clicks or Manual CPC.

## Cross-Domain Decision Frameworks

### "Where does this problem live?"

| Symptom | Check First | Do NOT Check |
|---------|-------------|--------------|
| Tracking/analytics issue | Analyzify | Simprosys |
| Product feed issue | Simprosys | Analyzify tracking |
| Bot/traffic anomaly | Cloudflare + check if date range includes pre-Feb 23 | Nothing else until date confirmed |
| Meta crawling failure | DNS TXT or meta tag verification (both work) | N/A |
| Campaign performance drop | Bot data baseline + conversion settings | Pre-Feb 23 benchmarks |
| App issue | Flutter/Dart code + WebView config | Shopify backend |
| Customer-facing content | Apply ALL brand rules below | Nothing — just check the rules |

### "Is this cross-contamination or intentional?"

| Situation | Verdict |
|-----------|---------|
| Pastry Skincare campaigns in BeautyOnTApp ad account | INTENTIONAL — selling Pastry on beautyontapp.com |
| UK Commerce Account region | INTENTIONAL — workaround for Instagram Shopping |
| Multiple pixels firing | PROBLEM — check for rogue pixels + Simprosys triple-fire |

### "Should I scale this campaign?"

1. Does it have 30+ conversions? → Maybe. Monitor.
2. Does it have 50+ conversions? → Yes. Switch to Maximise Conversions first.
3. Is the data post-Feb 23? → If not, data is unreliable.
4. Is ROAS healthy with SA benchmarks? → Use local data, never US/EU.
5. Budget staircase (CANONICAL — overrides all other skills):
   - **Google Ads**: 15-20% increases every 5-7 days. Monitor 5 days after each step. (Source: google-ads/references/sa-agency-playbook.md — Casson Media methodology)
   - **Meta Ads**: 20% increases every 3-5 days. Monitor CPA after each step. (Source: meta-creative-testing/references/playbook-extras.md — V8 Media methodology)
   - If CPA rises >20% after any step, pause scaling for 2 weeks.

### Customer-Facing Content Checklist

**What counts as customer-facing copy** — every one of these must be validated against the hard rules below before publishing or shipping:

- Meta descriptions, title tags, Open Graph + Twitter card text
- Schema.org descriptions, FAQ schema text, AggregateRating snippets
- Ad headlines + descriptions (Google Ads RSA, PMax, Demand Gen, Shopping; Meta primary text + headline + description; TikTok)
- Email subject lines, preheaders, body, sign-offs
- SMS + WhatsApp message bodies
- Push notification copy
- In-app modal copy, onboarding flows
- Social media captions (Instagram, TikTok, Facebook, Pinterest, Twitter/X)
- Website banner copy, collection descriptions, product descriptions, page H1/H2/H3
- Chatbot scripts, quick-reply buttons, error messages
- Outreach emails to brand partners, press, influencers, stockist directories
- Press release copy, media-kit blurbs
- Receipt + invoice text, packaging insert copy
- App Store + Play Store listings (title, subtitle, description, screenshots)
- Google Business Profile post copy
- Loyalty program tier names + reward descriptions
- Blog post titles, meta descriptions, headers
- Skin/hair analysis booking flow copy
- Cart, checkout, post-purchase thank-you copy

**Default rule:** if a customer (or external partner) will read it, it's customer-facing copy. The list above is illustrative, not exhaustive. When in doubt, treat it as customer-facing.

**Mandatory hard-constraint validation** — before publishing ANY of the above:

- [ ] No free shipping/delivery mentioned, implied, or hinted at (not "free", not "complimentary", not "we cover it", not "shipping included")
- [ ] 🖤 used (never 💚, ❤️, 💜, 💖, 💕, or any other emoji-in-place-of-the-brand-heart)
- [ ] Chatbot called "Bestie" (never "Timmy")
- [ ] SA brands called "proudly South African" (never "in-house", "our own brand", "house brand", "private label")
- [ ] Skin analysis priced at R285 (never R220 — old/wrong)
- [ ] Hair analysis priced at R199
- [ ] Product count is "1,400+" or "Over 1,400" (never 1,200 or 1,800)
- [ ] Store count is 6 (Mall of Africa, Menlyn, Gateway Umhlanga, Fourways, Sandton City, Canal Walk)
- [ ] English only (no Afrikaans)
- [ ] Customer email is `customer@beautyontapp.co.za`
- [ ] Orders email is `orders@beautyontapp.com`
- [ ] Domain is `beautyontapp.com` (NEVER `shopbeautyontapp.co.za` — legacy)
- [ ] Delivery prices, if mentioned, are accurate: R30 store pickup, R60 locker, R75 same-day (Sandton + MoA), R120 door-to-door, R75 same-day customer-facing term (NEVER "1-hour delivery")
- [ ] Brand list, if mentioned, only includes stocked brands (NEVER Cetaphil, Clarins, Clinique, Heliocare, Kérastase, Redken)
- [ ] All numeric/quantitative claims (booking volumes, sales figures, conversion rates, customer counts, follower counts) verified against actual data source — never pulled from memory, training pattern, or "reasonable assumption"

**Length-bounded surface gate** — if the artifact has a character limit, the character count MUST be programmatically verified before output, not estimated:

| Surface | Hard limit | Verification |
|---|---|---|
| Title tag | 60 chars | `len()` check before save |
| Meta description | 155 chars | `len()` check before save |
| Open Graph title | 60 chars | `len()` check |
| Open Graph description | 200 chars | `len()` check |
| Google Ads RSA headline | 30 chars | `len()` check, must work as 1 of 15 headlines |
| Google Ads RSA description | 90 chars | `len()` check, must work as 1 of 4 descriptions |
| Google Ads long headline | 90 chars | `len()` check |
| Google Ads callout | 25 chars | `len()` check |
| Google Ads sitelink text | 25 chars | `len()` check |
| Google Ads sitelink description | 35 chars each | `len()` check |
| Meta primary text | 125 chars before truncation | `len()` check |
| Meta headline | 40 chars before mobile truncation | `len()` check |
| Meta description | 30 chars (mobile) | `len()` check |
| TikTok ad caption | 100 chars | `len()` check |
| SMS broadcast | 160 chars | `len()` check |
| WhatsApp broadcast | 160 chars | `len()` check |
| Email subject line | 50 chars (mobile preview) | `len()` check |
| Push notification | 178 chars (Android), 150 (iOS) | `len()` check |
| Instagram caption (visible) | 125 chars before "...more" | `len()` check |

**Rule:** estimating "≤155 chars" by eye fails ~30% of the time. Always run a character count. Never trust "looks about right."

## Key Principles — Learned from Past Corrections

| Principle | Why |
|-----------|-----|
| Revert over rebuild | Killswitch rebuild destroyed working account. Feb 2026 = validated baseline. |
| Own-fleet at 15+ orders/day | Third-party couriers become cost-inefficient at that volume. |
| Bot traffic baseline is Feb 23 | Pre-block data is fake. 22.54% → 3.09% real conversion rate. |
| Three campaigns beat ten | At BeautyOnTApp's Meta budget, ASC + DPA + Test Lab outperforms fragmentation. |
| Pastry Skincare leads revenue | 21 of top 145 bestsellers. SA body care must lead creative priority. |
| DNS TXT or meta tag for domain verification | Both work. Meta tag is the easier option. |
| AEM is fully automatic | Meta removed manual config June 2025. Do not attempt. |
| Incognito for all theme testing | Admin session conflicts cause false rendering issues. |

## Output Standards

### For Chrome Extension Execution
- Senior expert persona stated at top
- Exact URL to navigate to
- Exact navigation path (click sequences)
- Exact settings/values to change
- Validation steps to confirm success
- Must be self-contained, accurate, and error-free

### For WhatsApp Developer Relay
- Complete files — never partial
- Numbered steps
- Terminal commands
- Version bump instructions
- Zero ambiguity — developer should not need to interpret

### For All Deliverables
- Complete and copy-paste ready — NEVER use "...", "// rest unchanged", or "etc."
- If long, produce in full — do not truncate
- Short and punchy copy — no extended rationale unless asked
