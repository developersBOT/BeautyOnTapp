---
name: beautyontapp-cart-recovery
description: Cart abandonment recovery for BeautyOnTApp — timed email/SMS/WhatsApp sequences, exit-intent popups, checkout friction audit, beauty-specific recovery messaging, cross-brand cart recovery, Klaviyo flow design. Auto-invoke for "cart abandonment", "abandoned cart", "checkout drop-off", "why aren't people completing orders", "cart recovery", "exit intent", "checkout optimization", or any question about recovering lost sales. NOT for CRO on pages (use beautyontapp-cro-engine). NOT for Klaviyo config (use beautyontapp-klaviyo-platform).
---

# Cart Abandonment Recovery for BeautyOnTApp

SA beauty e-commerce averages 65-75% cart abandonment. At ~1,500 orders/month, recovering even 5% of abandoned carts = 75+ additional orders/month. Beauty carts are abandoned for different reasons than generic e-commerce: product research, routine uncertainty, and price comparison.

## HARD RULES
1. No free delivery incentives in recovery flows. Ever. Business rule.
2. Never discount hero products in recovery. Use store credit instead.
3. WhatsApp is the primary recovery channel in SA (96% penetration). Email is secondary.
4. First recovery message within 1 hour. Urgency decays exponentially.
5. Max 4 recovery touchpoints. More = spam perception.

## RECOVERY SEQUENCE (4 Touchpoints)

### Touch 1: WhatsApp — 1 hour post-abandonment
"Hey [Name]! You left some 🖤 in your cart. Your [product name] is still waiting — want to complete your order? [cart link]"
- No discount. Just a reminder with product image.
- WhatsApp open rates: 90%+ in SA vs 20-30% email.

### Touch 2: Email — 4 hours post-abandonment
Subject: "Your routine is almost complete 🖤"
- Show cart contents with images
- Add "Complete Your Routine" CTA (not just "Buy Now")
- Include product benefits and star ratings as social proof
- Add "Not sure? Chat with Bestie" link to chatbot

### Touch 3: SMS — 24 hours post-abandonment
"Your [product] is selling fast! Complete your order before it's gone: [short link] — BeautyOnTApp"
- Scarcity trigger (only if stock is genuinely low)
- 160 chars max. Include opt-out.

### Touch 4: Email — 48 hours post-abandonment (final)
Subject: "Last chance — R50 store credit inside"
- R50 store credit (not discount) with minimum R300 spend
- Expires in 48 hours (creates urgency)
- "Or book a free skin analysis to find the right products" CTA
- If no conversion → exit sequence. Do not send more.

## BEAUTY-SPECIFIC ABANDONMENT REASONS + FIXES

| Reason | Signal | Fix |
|---|---|---|
| "Not sure if right for my skin" | Browse-to-cart but no purchase | Add skin type compatibility on PDP |
| "Too expensive" | Cart value >R500, no purchase | "Cost per day: R8" calculator |
| "Want to research more" | Multiple product views, single add-to-cart | "Complete Your Routine" with ingredient education |
| "Delivery cost surprise" | Cart → checkout → abandon at shipping | Show delivery cost on PDP (not checkout surprise) |
| "Just browsing" | <2 min session, single product view | Exit-intent popup with skin quiz |
| "Will buy in-store" | Location page visit + cart abandon | "Same product, same price in-store at [nearest store]" |

## EXIT-INTENT POPUP STRATEGY

Trigger: mouse moves toward browser close (desktop) or back button (mobile).

**Version A — Skin Quiz Lead Capture**
"Not sure what's right for your skin? Take our 2-min skin quiz 🖤"
→ Captures email + skin data → enters personalized email flow

**Version B — Store Redirect**
"Prefer to see it in person? Visit us at [nearest store based on IP geolocation]"
→ Keeps the sale in the ecosystem even if online cart is abandoned

**Version C — Routine Completion**
"You're 2 products away from a complete routine. See what's missing →"
→ Cross-sell driven by routine logic, not random recommendations

Never show discount popups on exit. Store credit in email Touch 4 only.

## CROSS-BRAND RECOVERY

When a customer abandons a Pastry Skincare product:
- Recovery Touch 2 can suggest BeautyOnTApp alternatives
- "Looking for something different? Try [Mzuri Skin alternative]"
- Cross-brand recovery drives portfolio LTV, not just single-brand conversion

## KLAVIYO FLOW DESIGN

```
Trigger: Checkout Started → No Purchase within 1 hour
├── Touch 1: WhatsApp (1hr) — reminder + product image
├── Wait 3 hours
├── Touch 2: Email (4hr) — routine completion + social proof
├── Wait 20 hours
├── Touch 3: SMS (24hr) — scarcity + short link
├── Wait 24 hours
├── Touch 4: Email (48hr) — R50 store credit + expiry
└── Exit flow
```

Filter: Exclude customers who purchased after any touchpoint. Exclude customers who opted out of marketing.

## METRICS TO TRACK

| Metric | Target | Source |
|---|---|---|
| Cart abandonment rate | <65% | Shopify Analytics |
| Recovery rate (abandoned → purchased) | >5% | Klaviyo |
| Revenue recovered/month | >R30,000 | Klaviyo |
| WhatsApp recovery rate | >8% | WhatsApp Business API |
| Email recovery rate | >3% | Klaviyo |
| Time to recovery | <24 hours avg | Klaviyo |

## DECISION RULES

1. **When cart abandonment rises above 75%**: Audit checkout flow for friction. Check if delivery cost is surprising customers.
2. **When recovery rate drops below 3%**: Refresh creative. Test new subject lines and WhatsApp copy.
3. **When Bash offers free delivery on beauty**: Do NOT match. Counter with "Same-day delivery — why wait 3-5 days?"
4. **When testing recovery offers**: Test R50 vs R75 vs R100 store credit. Never test percentage discounts.
5. **When cross-brand recovery outperforms single-brand**: Increase cross-brand suggestions in all flows.
