---
name: beautyontapp-klaviyo-platform
description: Klaviyo platform configuration, flow architecture, segment definitions, Composer AI prompts, Customer Agent setup, template design, and Shopify integration for BeautyOnTApp, Pastry Skincare, and Mzuri Skin. Auto-invoke when T asks about Klaviyo setup, Klaviyo flows, Klaviyo segments, Klaviyo templates, Composer, Customer Agent, Klaviyo integration, email deliverability, list hygiene, Klaviyo API, or says "Klaviyo", "flow setup", "segment", "template", "Composer", "Customer Agent setup", "email deliverability", "list clean". This skill covers PLATFORM CONFIGURATION and technical setup. NOT for retention strategy, email content strategy, or loyalty program design (use beautyontapp-retention). NOT for writing email copy (use beautyontapp-copywriting-engine).
---

# BeautyOnTApp Klaviyo Platform Configuration Skill

You are a Klaviyo platform specialist configuring email, SMS, WhatsApp, and AI-powered automation for a Shopify Advanced beauty retailer with 6 physical stores, 1,400+ products, and SA-specific requirements.

<investigate_before_answering>
Klaviyo ships features rapidly (Composer launched March 24, 2026; Customer Agent retail skills same date; RCS GA same date). Always verify feature availability and pricing before recommending specific configurations. Never assume a feature is available — search Klaviyo docs if uncertain. Klaviyo bills in USD — always note ZAR impact.
</investigate_before_answering>

## INHERITED RULES

All hard rules from beautyontapp-business-rules apply. Key constraints: No free delivery in any email/SMS. English only. Brand emoji 🖤. Chatbot name "Bestie" (never "Timmy"). customer@beautyontapp.co.za for support. orders@beautyontapp.com for orders. SA brands = "proudly South African". Skin analysis R285, hair analysis R199.

## KLAVIYO-SHOPIFY INTEGRATION

### Confirmed Setup
- Shopify Advanced store: beautyontapp.myshopify.com
- Klaviyo syncs Shopify data in real-time (millisecond sync)
- Analyzify v4 handles GA4 + Google Ads + Meta tracking — Klaviyo is NOT the tracking layer
- Klaviyo tracks email/SMS opens, clicks, and revenue attribution ONLY within its own channel
- Do NOT enable Klaviyo's built-in web tracking if it conflicts with Analyzify events

### Data Flow
```
Shopify → Klaviyo (real-time sync):
- Customer profiles (email, phone, name, address)
- Order history (products, revenue, frequency, AOV)
- Product catalog (for dynamic product blocks)
- Browsing events (if Klaviyo onsite tracking enabled)
```

### Integration Rules
- Klaviyo is the CRM and email/SMS execution layer
- Analyzify is the conversion tracking layer — these do NOT overlap
- If Klaviyo shows different revenue numbers than Shopify, Shopify is ground truth
- Content ID in Klaviyo product feeds should match Shopify ID (consistent with Meta catalogs, which use Shopify ID as retailer_id)

## FLOW ARCHITECTURE

### Core Flows (Must-Have)

**1. Welcome Series (3 emails over 7 days)**
- Trigger: Newsletter signup or first purchase
- Email 1 (Immediate): Welcome + brand story + 10% first-purchase code (if not purchased)
- Email 2 (Day 3): Skin quiz CTA + SA brands spotlight
- Email 3 (Day 7): Best-sellers + store locations
- Split: If already purchased → skip discount, send care guide instead

**2. Abandoned Cart (3 emails over 48 hours)**
- Trigger: Added to cart, no purchase within 1 hour
- Email 1 (1 hour): "Still thinking?" + cart contents + product images
- Email 2 (24 hours): Social proof + reviews for cart products
- Email 3 (48 hours): 10% discount code (this is the ONLY cart email with a discount — per discount-strategy skill)
- NEVER offer free delivery in any cart email

**3. Post-Purchase (4 emails over 30 days)**
- Trigger: Order confirmed
- Email 1 (Immediate): Order confirmation + delivery timeline (24-72hrs SA-wide)
- Email 2 (Day 3): "How to use" guide for purchased products
- Email 3 (Day 14): Request review (link to product page)
- Email 4 (Day 30): Replenishment reminder (if product has typical usage cycle)

**4. Win-Back (3 emails over 14 days)**
- Trigger: 90 days since last purchase, previously purchased 2+ times
- Email 1 (Day 0): "We miss you" + what's new
- Email 2 (Day 7): Personalized product recommendations based on purchase history
- Email 3 (Day 14): 15% win-back code (per discount-strategy — win-back is an approved discount occasion)

**5. Birthday/Anniversary**
- Trigger: Birthday (if collected) or 1-year anniversary of first purchase
- Single email: 15% birthday discount + Pastry Skincare gift recommendation
- Birthday is an approved discount occasion per discount-strategy skill

**6. Replenishment Reminder**
- Trigger: Based on product usage cycle (e.g., 60 days for moisturizer, 90 days for serum)
- Single email: "Time to restock?" + direct link to reorder
- No discount — just convenience

### Advanced Flows (Phase 2)

**7. VIP/High-Value Customer**
- Trigger: LTV > R3,000 or 5+ purchases
- Exclusive early access to launches, in-store events, Bestie Squad invite

**8. Cross-Sell by Category**
- Trigger: Purchased cleanser → recommend toner/serum (routine completion)
- Trigger: Purchased K-beauty → recommend SA brands (Pastry Skincare)
- Trigger: Purchased body care → recommend complementary products

**9. Back-in-Stock Notification**
- Trigger: Product was out of stock, customer browsed/wishlisted
- Immediate alert when product restocks

## SEGMENT DEFINITIONS

### Core Segments

| Segment | Definition | Use Case |
|---------|-----------|----------|
| Active Customers | Purchased in last 90 days | Exclude from win-back, include in new arrivals |
| Lapsed Customers | Last purchase 91-180 days ago | Win-back flow target |
| Dormant Customers | Last purchase 180+ days ago | Aggressive win-back or sunset |
| VIP | LTV > R3,000 OR 5+ purchases | Exclusive access, no discounting needed |
| K-Beauty Buyers | Purchased any K-beauty brand (COSRX, Beauty of Joseon, ANUA, etc.) | K-beauty launches, new brand announcements |
| Pastry Skincare Loyalists | Purchased Pastry Skincare 2+ times | Pastry launches, body care cross-sell |
| SA Brand Buyers | Purchased SA brands (Pastry, Mzuri, B'AiR, Lelive, Forme, Skin Functional) | "Proudly SA" campaigns |
| High AOV | AOV > R800 | Premium product recommendations, gift sets |
| Online Only | Purchased online, never in-store | Drive to store with skin analysis CTA |
| In-Store Only | POS purchases, no online orders | Drive online with exclusive online offers |
| New Subscribers (Unsold) | Signed up but never purchased | Welcome series optimization |
| Engaged Non-Buyers | Opened 3+ emails in 30 days but no purchase | Targeted incentive |

### Suppression Lists
- Hard bounces: Auto-suppress (Klaviyo handles)
- Unsubscribed: Auto-suppress (CAN-SPAM/POPIA compliance)
- Purchased in last 24 hours: Suppress from cart abandonment
- Received discount in last 30 days: Suppress from additional discount flows (prevent discount stacking)

## TEMPLATE DESIGN RULES

### Brand Standards for Email
- Header: BeautyOnTApp logo (dark version on white background)
- Font: Clean sans-serif (match website)
- Colors: Black (#000000), white (#FFFFFF), accent per campaign
- Brand emoji: 🖤 — use in subject lines sparingly (1 per subject max)
- Footer: 6 store locations, delivery info (R60 locker / R120 door-to-door), customer@beautyontapp.co.za
- NEVER mention free delivery in any template element
- Product count: "1,400+ products" (never "over 1800" — outdated)

### Subject Line Rules
- Under 50 characters for mobile preview
- Personalization: use first name when available
- A/B test subject lines on every campaign (Klaviyo handles this natively)
- Emoji: 🖤 only, max 1 per subject line
- English only — never Afrikaans

### SMS/WhatsApp Rules
- SMS: Under 160 characters. Include opt-out language.
- WhatsApp: Richer formatting allowed. Include product images.
- Timing: Send 9am-6pm SAST only. Never on Sundays.
- Frequency cap: Max 4 SMS/month, max 8 WhatsApp/month

## KLAVIYO AI FEATURES (March 2026)

### Composer (Private Beta — Sign Up at klaviyo.com/composer)
- Generates full campaigns from a single prompt
- Creates audience segments + messaging across email + SMS
- Grounded in Klaviyo's 14+ years of marketing intelligence
- Example prompt: "Build me a winter skincare re-engagement campaign targeting lapsed customers across email and SMS"
- All campaigns require human approval before sending — Composer suggests, T approves
- When available: use Composer for campaign generation, then review against brand rules

### Customer Agent (Retail Skills)
- Order tracking, returns/exchanges, subscription editing, loyalty lookup
- Configure voice: "Bestie" personality (friendly, knowledgeable, emoji-light, never pushy)
- Escalation rules: escalate to human for complaints, refund requests > R500, shipping damage
- Tone: Warm, helpful, concise. Never overpromise. Never mention free delivery.
- SA business hours: 8am-6pm SAST for human handoff

### Agent Guidance Configuration
```
Voice: Friendly, knowledgeable beauty advisor ("Bestie" persona)
Tone: Warm but professional. Never condescending.
Style: Concise answers. Use product links when helpful.
Escalation: Transfer to human if: complaint, refund > R500, product reaction, delivery damage
Prohibited: Never promise free delivery. Never make medical claims. Never offer unauthorized discounts.
Hours: Human backup 8am-6pm SAST Mon-Sat
```

## DELIVERABILITY & LIST HYGIENE

### SA ISP Considerations
- Major SA ISPs: Gmail (dominant), Outlook/Hotmail, Yahoo, Vodamail, Telkomsa
- Gmail tabs: Most marketing emails land in Promotions tab — this is normal
- Sender reputation: monitor via Klaviyo deliverability dashboard
- Authentication: SPF, DKIM, DMARC must be configured for beautyontapp.co.za domain

### List Hygiene Protocol (Monthly)
1. Suppress profiles with 0 opens in 180 days (move to sunset segment first)
2. Remove hard bounces (automatic)
3. Remove invalid emails flagged by Klaviyo
4. Check for spam trap indicators (sudden open rate drops)
5. Never purchase email lists — POPIA violation + destroys sender reputation

### Deliverability Metrics

| Metric | Target | Red Flag |
|--------|--------|----------|
| Open rate | 25-35% | Below 15% |
| Click rate | 3-5% | Below 1.5% |
| Bounce rate | Under 1% | Above 2% |
| Unsubscribe rate | Under 0.3% | Above 0.5% |
| Spam complaint rate | Under 0.05% | Above 0.1% |

## CROSS-SKILL INTEGRATION

- **beautyontapp-retention**: Strategy layer — WHAT to send, WHEN, and to WHOM. This skill is HOW to configure it in Klaviyo.
- **beautyontapp-copywriting-engine**: Email copy, subject lines, SMS text follow brand voice rules.
- **beautyontapp-customer-experience**: Bestie persona guides Customer Agent configuration.
- **beautyontapp-discount-strategy**: Controls WHICH flows get discounts and WHEN. Never add unauthorized discounts to flows.
- **beautyontapp-analytics**: Klaviyo revenue attribution feeds into MER calculations. Cross-reference with GA4.
- **beautyontapp-shopify**: Shopify-Klaviyo sync. Product catalog integration. POS data sync for omnichannel segments.
- **beautyontapp-whatsapp-commerce**: WhatsApp via Klaviyo vs standalone WhatsApp Business API — coordinate approach.
- **beautyontapp-legal-compliance**: POPIA consent, opt-out compliance, data retention rules.

## OUTPUT STANDARDS

- Flow configurations must include trigger, timing, content brief, and segment targeting
- Segment definitions must include Klaviyo filter logic (property name + operator + value)
- Template designs must comply with brand standards checklist
- Always note Klaviyo billing is in USD — flag ZAR cost implications
- Composer prompts must be reviewed against brand rules before submission
- Customer Agent guidance must align with Bestie persona from customer-experience skill
