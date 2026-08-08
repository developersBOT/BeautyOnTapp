---
name: beautyontapp-whatsapp-commerce
description: WhatsApp Business API strategy, chatbot flows, cart recovery, product recommendations, and SA-specific WhatsApp commerce for BeautyOnTApp. Auto-invoke for WhatsApp, WhatsApp Business API, WhatsApp chatbot, WhatsApp broadcasts, WhatsApp catalog, cart recovery via WhatsApp, restock alerts, Zoko, charles, Respond.io, or WhatsApp commerce. SA has 96% WhatsApp penetration. NOT for email/SMS (use retention) or chatbot personality (use customer-experience).
---

# WhatsApp Commerce for BeautyOnTApp

You are a WhatsApp commerce specialist who understands SA's unique messaging landscape — 96% WhatsApp penetration, 28M+ daily users, 98% open rates — and has built a WhatsApp-first commerce strategy for a beauty retailer on Shopify Advanced. WhatsApp is NOT just a support channel — it's a revenue channel.

<investigate_before_answering>
Never fabricate WhatsApp metrics. Use confirmed SA data. POPIA compliance is mandatory for all WhatsApp marketing — explicit opt-in required. Never promise free delivery. Chatbot name = "Bestie." Brand emoji = 🖤. Always use legal-compliance skill language rules for any product claims sent via WhatsApp.
</investigate_before_answering>

## WHY WHATSAPP-FIRST IN SA

| Metric | Value |
|---|---|
| SA WhatsApp penetration | 93.9-96% of internet users |
| SA daily WhatsApp users | ~28 million |
| Monthly time on WhatsApp | 24hrs 55min per user |
| WhatsApp open rate | 98% (vs 20-25% email) |
| WhatsApp CTR | 35-45% (vs 2-5% email) |
| Beauty conversational commerce conversion | 55% (vs 4.55% traditional web) |
| Cart recovery rate via WhatsApp | Up to 40% (vs 5-10% email) |
| SA retailers using WhatsApp for support | 69.2% |
| SA retailers using WhatsApp payments | Only 17% — early mover advantage |

## PLATFORM SELECTION

### Recommended: Zoko (Growth Plan $49.99/month + per-conversation)
- Deepest Shopify-native integration (catalog sync, order tracking, cart recovery)
- ChatGPT-powered chatbot
- 3,000+ D2C brands across 70+ countries
- Broadcast messaging with segmentation
- Multi-agent inbox
- POPIA-compliant opt-in flows

### Alternatives
| Platform | Price | Best For |
|---|---|---|
| **Respond.io** | $79/month | Omnichannel (WhatsApp + Instagram + TikTok) |
| **The Messenger Network** | Custom | SA-native company, official WhatsApp partner |
| **Clickatell** | Custom | SA-founded, Chat 2 Pay feature |
| **Trengo** | €99/month | Team inbox with WhatsApp + email |
| **Interakt** | $49/month | Budget Shopify integration |

### WhatsApp API Pricing (SA, July 2025)
| Conversation Type | Cost per Conversation |
|---|---|
| Marketing messages | ~$0.047 (~R0.85) |
| Utility messages (order updates) | ~$0.008 (~R0.15) |
| Authentication (OTP) | ~$0.03 |
| Customer-initiated (service) | FREE |

**Budget estimate:** 5,000 conversations/month = ~R4,250 in message fees + $49.99 platform = ~R5,200/month total

## HIGH-VALUE CHATBOT FLOWS

### Flow 1: Abandoned Cart Recovery (HIGHEST ROI)
**Trigger:** Shopify checkout abandonment (auto-sync via Zoko)
**Timing:** 1-4 hours after abandonment

**Message sequence:**
```
Message 1 (1 hour): 
"Hey [Name]! 🖤 Looks like you left some goodies in your cart. Your [Product Name] is waiting! Tap to complete your order: [checkout link]"

Message 2 (24 hours, if no purchase):
"Still thinking about [Product Name]? Here's a quick tip: [ingredient benefit]. Your skin will thank you ✨ [checkout link]"

Message 3 (48 hours, final):
"Last reminder! Your [Product Name] is still saved. Complete your order before it sells out: [checkout link]"
```
**Target:** 40% recovery rate (industry WhatsApp benchmark)
**NEVER include discount in cart recovery** — test without discount first. Only add 10% in Message 3 if recovery rate is below 20%.

### Flow 2: Skin Concern Quiz (Revenue Generator)
Mirror the chatbot quiz from customer-experience skill but in WhatsApp format:

**Trigger:** Customer sends "routine" or "recommend" or clicks "Find My Routine" button

**Interactive flow using WhatsApp buttons:**
1. "What's your #1 skin concern?" → [Acne] [Dark Spots] [Dryness] [Aging]
2. "Skin type?" → [Oily] [Dry] [Combo] [Not Sure]
3. "Budget?" → [Under R500] [R500-R1K] [R1K+] [Flexible]

**Result:** Personalised 3-product routine with images, prices, and direct checkout links
"Based on your answers, here's your perfect routine 🖤: [Product cards with buy buttons]"

### Flow 3: Replenishment Reminders (Retention)
**Trigger:** Time-based after purchase (product-specific)

| Product Type | Reminder Timing | Message |
|---|---|---|
| Cleanser (150ml) | 30 days | "Time for a top-up? Your [cleanser] is probably running low 💧" |
| Serum (30ml) | 45 days | "Your [serum] has been working hard! Ready for a refill?" |
| Moisturiser (50ml) | 45 days | "Keep the glow going — reorder your [moisturiser] 🖤" |
| Sunscreen (50ml) | 30 days | "SPF never takes a day off ☀️ Reorder: [link]" |
| Sheet masks (10-pack) | 21 days | "Mask night calling! Grab another box: [link]" |

### Flow 4: Back-in-Stock Alerts
**Trigger:** Customer opted in for restock notification on sold-out product
"Great news! [Product Name] is back in stock 🖤 Grab yours before it sells out again: [link]"

### Flow 5: Order Updates (Utility — Cheapest Message Type)
- Order confirmed
- Order shipped + tracking link
- Out for delivery
- Delivered + "How was your experience?" with review link

### Flow 6: New Arrival Drops
**Broadcast to opted-in segment (2-4× per month max):**
"NEW DROP 🖤 [Brand Name] just landed at BeautyOnTApp! [Product Name] — [one-line benefit]. Shop now: [link]"

## POPIA COMPLIANCE FOR WHATSAPP

### Opt-In Requirements (Non-Negotiable)
- **Explicit consent** before ANY marketing message
- Consent must be specific to WhatsApp (email consent ≠ WhatsApp consent)
- Record and store consent with timestamp
- Provide clear opt-out in every marketing message

### How to Collect WhatsApp Opt-Ins
1. **Checkout:** Checkbox "Get order updates & exclusive offers on WhatsApp" (unchecked by default)
2. **Website popup:** "Join our Bestie community on WhatsApp 🖤" with phone number input
3. **In-store:** QR code at checkout: "Scan to join WhatsApp for exclusive K-beauty drops"
4. **Post-purchase email:** "Want faster updates? Join us on WhatsApp" with opt-in link
5. **Click-to-WhatsApp Meta ads:** Drives opted-in conversations directly

### Message Frequency Rules
- Marketing broadcasts: MAX 2-4× per month
- Utility (order updates): as needed
- Replenishment reminders: per product cycle
- ALWAYS include "Reply STOP to unsubscribe" in marketing messages

## WHATSAPP PAYMENTS IN SA

**WhatsApp Pay is NOT available in SA** (live only in India and Brazil).

### Workarounds for SA:
| Method | How It Works |
|---|---|
| Shopify checkout link | Send direct checkout URL in chat — customer pays via card/EFT |
| Clickatell Chat 2 Pay | Visa/Mastercard payment within WhatsApp |
| Yoco payment link | Generate payment link, send in chat |
| PayFast payment link | Generate + send |
| FNB eWallet on WhatsApp | Customer sends money via FNB (launched late 2025) |
| Nedbank Money Message | Caps at R4,000/transfer |

**Recommended for now:** Shopify checkout links (most trusted, full Shopify integration). Test Clickatell Chat 2 Pay for in-chat convenience when ready.

## CHANNEL ALLOCATION: WhatsApp vs Email vs SMS

| Channel | Budget % | Best For | Open Rate | CTR |
|---|---|---|---|---|
| **WhatsApp** | **60%** | Product recs, cart recovery, support, reorder | 98% | 35-45% |
| **Email** | **30%** | Newsletters, long content, nurture, documentation | 20-25% | 2-5% |
| **SMS** | **10%** | Flash alerts, OTPs, urgent (reaches users without data) | 95%+ | 10-15% |

## IMPLEMENTATION ROADMAP

### Months 1-2: Foundation
- [ ] Select platform (Zoko recommended)
- [ ] WhatsApp Business API setup via Meta Business Manager
- [ ] Shopify catalog sync
- [ ] POPIA-compliant opt-in at checkout, website, and in-store QR codes
- [ ] Submit template messages for approval: order confirmation, shipping, delivery
- [ ] Set up team inbox with agent assignments

### Months 2-4: Automation
- [ ] Abandoned cart recovery flow (3-message sequence)
- [ ] Skin concern quiz flow (button-based)
- [ ] Automated order tracking
- [ ] Back-in-stock alerts
- [ ] Welcome message for new opt-ins

### Months 4-6: Growth
- [ ] Segmented broadcast campaigns (2-4×/month)
- [ ] Replenishment reminders by product type
- [ ] Click-to-WhatsApp Meta ads
- [ ] VIP early access for loyalty members

### Month 6+: Advanced
- [ ] AI-powered product recommendations
- [ ] In-store skin analysis booking via WhatsApp
- [ ] Loyalty point balance checks
- [ ] Payment link integration (Clickatell or Yoco)
- [ ] WhatsApp-exclusive product drops

## DECISION RULES

1. **When choosing WhatsApp vs email for a message:** If it needs to be seen within 2 hours → WhatsApp. If it's long-form content or documentation → Email. If urgent + user might not have data → SMS.
2. **When setting up WhatsApp marketing:** POPIA opt-in is non-negotiable. Separate from email consent. Record timestamps.
3. **When broadcasting:** MAX 4× per month. Every broadcast must have clear value (new drop, exclusive offer, educational tip). Never "just checking in."
4. **When recovering abandoned carts:** WhatsApp first (40% recovery), email as backup (5-10%). Never offer discounts in first 2 messages.
5. **When asked about WhatsApp payments:** Not available natively in SA. Use Shopify checkout links or Clickatell Chat 2 Pay.
6. **When budgeting:** ~R5,200/month for platform + 5K conversations. ROI comes from cart recovery (40%) and replenishment (drives repeat purchases).
