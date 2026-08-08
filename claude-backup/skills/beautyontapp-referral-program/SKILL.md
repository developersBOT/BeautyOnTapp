---
name: beautyontapp-referral-program
description: Referral and affiliate program design for BeautyOnTApp, Pastry Skincare, and Mzuri Skin — WhatsApp-first referral mechanics, cross-brand referral flows, physical store QR integration, Bestie Squad affiliate tiers, viral coefficient modeling, fraud prevention, Shopify app selection. Auto-invoke for "referral", "refer a friend", "affiliate", "ambassador", "word of mouth", "give get", "invite friends", "referral code", "referral program", "advocacy", "viral loop", or any customer acquisition via existing customers. NOT for influencer ops (use beautyontapp-influencer-ops). NOT for loyalty/points (use beautyontapp-retention).
---

# Referral & Affiliate Program for BeautyOnTApp

Beauty has natural word-of-mouth. When someone's skin improves, friends notice. This skill turns that into a systematic acquisition channel across 3 brands, 6 stores, and WhatsApp (96% SA penetration).

## HARD RULES
1. No free delivery as referral reward. No exceptions. (Business rule.)
2. Delay referral rewards 14 days post-purchase to clear return window.
3. Referral codes must work across all 3 brands.
4. WhatsApp sharing is the #1 channel. Design for it first.
5. Never "spam your friends" — always "share your glow."

---

## 1. THE REFERRAL LOOP

**Trigger → Share → Convert → Reward → Loop**

### Trigger Moments (When to ask)
- Post-purchase confirmation page + email (highest intent)
- After positive review submitted
- After skin analysis consultation (R285)
- After 3rd purchase (proven loyalty)
- When a friend compliments their skin (user-generated trigger — prompt via push notification)

### Share Mechanisms (Ranked by effectiveness for SA)
1. **WhatsApp** — pre-written message with personalized link + product photo (96% SA penetration)
2. **In-store QR code** — printed on receipts, packaging inserts, counter cards
3. **Personalized link** — unique URL per customer for tracking
4. **SMS** — fallback for non-WhatsApp users
5. **Instagram Story** — share template with swipe-up/link sticker
6. **Email** — lowest priority for SA beauty audience

### Convert (Landing experience)
- Referral link → dedicated landing page showing: who referred them, what they get, one-click to shop
- Auto-apply referral discount at checkout (no manual code entry)
- Show "Your friend [Name] thinks you'll love this" social proof

### Reward Structure
**Give R100, Get R100** (store credit, not discount — protects margin)

| Action | Referrer gets | Referee gets |
|---|---|---|
| First purchase by referee | R100 store credit | R100 off first order (min R300) |
| Referee makes 2nd purchase | R50 bonus credit | — |
| 3 successful referrals | Free deluxe sample set | — |
| 5 successful referrals | Full-size product (up to R400) | — |

### Loop (Keep it going)
- Email/WhatsApp referrer when friend purchases: "Your friend just ordered! You earned R100 🖤"
- Show referral progress dashboard in account: "2/5 referrals to unlock your free product"
- Goal-gradient effect: progress bar drives completion

---

## 2. INCENTIVE ECONOMICS

### Maximum Reward Formula
Max Reward = LTV × Margin − Target CAC

**BeautyOnTApp calculation:**
- Average order: VERIFY with T (estimate R400-600)
- Average margin: ~50% blended
- Repeat purchase rate: VERIFY
- Estimated LTV: VERIFY (estimate R1,200-2,000 over 12 months)
- Target CAC: R167 (excellent) to R300 (maximum)
- **Max referral reward: R100-200 range** — R100 is conservative and sustainable

### Cross-Brand Economics
- Referral code works across all 3 brands
- If referred from Pastry Skincare → credit works on BeautyOnTApp too (portfolio flywheel)
- Higher margins on SA brands (60-80%) mean Pastry/Mzuri referrals are more profitable

---

## 3. WHATSAPP-FIRST DESIGN

### Pre-Written Share Message Template
```
Hey! 🖤 I've been using [product name] from BeautyOnTApp and my skin is LOVING it. 
They gave me a link to share — you get R100 off your first order (min R300): 
[personalized link]
Same-day delivery in JHB or visit their store at [nearest store]. 
```

### WhatsApp Mechanics
- Shopify generates unique referral link per customer
- Share button opens WhatsApp with pre-populated message
- Link tracks: referrer ID, referred customer, purchase attribution
- Works on WhatsApp Web and mobile

---

## 4. PHYSICAL STORE INTEGRATION

### In-Store Touchpoints
- **Receipts**: QR code + "Share your glow — Give R100, Get R100" printed on every receipt
- **Packaging inserts**: Branded card with QR code in every delivery box
- **Counter cards**: At each of 6 store registers
- **Post-consultation**: Beauty advisor hands referral card after skin analysis
- **Shopping bags**: QR code on exterior — walking billboard

### Store-Specific Referral Tracking
- Each store gets a unique UTM: `?ref=store-sandton`, `?ref=store-gateway`
- Track which stores generate the most referrals
- Incentivize staff: bonus per referral originated from their store

---

## 5. BESTIE SQUAD AFFILIATE TIER

For power referrers who consistently drive new customers:

| Tier | Threshold | Commission | Benefits |
|---|---|---|---|
| Friend | 1-4 referrals | R100 store credit each | Standard rewards |
| Bestie | 5-14 referrals | 10% commission on referred sales | Early access to new products |
| Ambassador | 15+ referrals | 15% commission + custom code | Free products, featured on socials |

Ambassadors graduate into the Bestie Squad influencer program (see beautyontapp-influencer-ops).

---

## 6. FRAUD PREVENTION

- **14-day reward delay**: reward only after return window closes
- **Minimum purchase**: R300 minimum for referee discount (prevents gaming)
- **Self-referral block**: same email/phone/IP cannot refer themselves
- **Address matching**: flag if referrer and referee share shipping address
- **Velocity limit**: max 20 referrals per month per account (anti-bot)
- **Store credit not cash**: prevents pure arbitrage

---

## 7. SHOPIFY APP OPTIONS

| App | Price | Key features |
|---|---|---|
| ReferralCandy | $59/mo | WhatsApp sharing, Shopify native, automated rewards |
| Friendbuy | Custom pricing | Enterprise features, A/B testing on incentives |
| Yotpo Referrals | Bundled with Yotpo | If already using Yotpo for reviews |
| Smile.io | $49/mo+ | Referrals + loyalty combined — but Toki (Skin IQ Club) already handles loyalty |

**Recommendation**: ReferralCandy — best WhatsApp integration for SA market. VERIFY pricing current.

---

## 8. VIRAL COEFFICIENT MODELING

**K-factor = Invitations × Conversion Rate**

Target: K > 0.5 (each customer brings half a new customer)
- Invitations per customer: target 3 (prompted at 3 trigger moments)
- Conversion rate per invitation: target 15-20% (strong for warm referrals)
- K = 3 × 0.17 = 0.51 — sustainable referral growth

Track monthly: referral invitations sent, conversion rate, K-factor, CAC via referral vs paid.

---

## 9. DECISION RULES

1. **When launching**: Start with Give R100, Get R100. Simple. WhatsApp + post-purchase page. Expand later.
2. **When optimizing**: Test reward amounts (R75 vs R100 vs R150). Test share channel distribution.
3. **When scaling**: Add Bestie Squad affiliate tier for power referrers. Add in-store QR touchpoints.
4. **When cross-brand**: Ensure referral credit works on all 3 brands. Track which brand generates most referrals.
5. **When evaluating ROI**: Referral CAC should be <R167. If >R300, reduce reward amount or tighten fraud controls.
