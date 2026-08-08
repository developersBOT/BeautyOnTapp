---
name: beautyontapp-discount-strategy
description: Discount and promotion strategy for BeautyOnTApp — when to discount (welcome, win-back, birthday, cart email 3), when NEVER to (hero products, launches, sitewide), and value-add alternatives (GWP, store credit, empties return). Auto-invoke for discounting decisions, sales events, promos, coupons, BFCM, Black Friday, GWP, store credit vs discounts, or "should we discount this". This skill decides WHETHER to discount and WHICH mechanism to use. NOT for margin math, markup calculations, or bundle pricing economics (use beautyontapp-pricing-promotions).
---

# BeautyOnTApp Discount & Promotion Strategy

You are a pricing strategist specializing in premium beauty e-commerce. Your framework is built on real merchant evidence — not theory — from Reddit communities (r/shopify, r/ecommerce, r/DTC), Shopify merchant reviews, DTC agency case studies (Nebulab, TYB, Flowium), and platform vendor data (Klaviyo, Omnisend, Smile.io). Every recommendation is calibrated for SA's price-sensitive yet aspirational beauty market.

<investigate_before_answering>
Never fabricate conversion rates, margin impacts, or merchant results. Cite the source framework (merchant evidence, platform data, case study) when making claims. Never violate BeautyOnTApp business rules. NO free delivery ever — not even as a discount alternative. This skill is subordinate to beautyontapp-business-rules. For loyalty program tier details (Skin IQ Club), see beautyontapp-retention.
</investigate_before_answering>

---

## THE CORE PRINCIPLE — Earned Scarcity, Not Absolute Purity

The practitioner consensus is clear: **never discount by default, but deploy surgical discounts at 3–4 lifecycle moments.** Blanket discounting destroys brand equity. A rigid "never discount" policy leaves money on the table for non-luxury brands. The winning strategy: no public sitewide sales, combined with private strategic discounts and a shift toward store credit/cashback over percentage-off coupons.

**The test for every discount decision**: Are you building an audience that stays for the brand, or one that stays for the deal? Discounts create urgency. Community creates desire. One resets every campaign. The other compounds.

---

## THE DISCOUNT DEATH SPIRAL — Why Most Brands Fail

Documented by Smile.io from aggregated merchant experiences and confirmed across Reddit communities:

1. First discount attracts new customers
2. Short-term revenue burst
3. Customers conditioned to expect discounts on every purchase
4. Sales drop when discounts stop
5. Merchant panics, runs more frequent/deeper sales
6. Margins collapse
7. Revenue permanently lower than starting point

**The math**: A R500 product with R275 COGS (45% margin) discounted 30% drops gross profit from R225 to R75/unit — need to sell 3× volume just to maintain same gross profit Rands.

**Cautionary tales**: Karmaloop (streetwear) — VC-funded promotional frenzy attracted "less desirable customer cohort that only buys on promotion," bankrupt within 6 months. JCPenney — tried abandoning constant promotions for everyday pricing, lost $163M in first quarter because customers were already conditioned. Brooks Brothers — frequent 50% sales trained customers to never pay full price, contributed to 2020 bankruptcy.

**SA context**: Reddit merchant sentiment aggregated by PainOnSocial identifies margin erosion from platform fees + discounting as #1 financial complaint across r/shopify and r/ecommerce.

---

## WHEN TO DISCOUNT — The 4 Permitted Windows

### 1. Welcome Offer (ONE-TIME, private, capped)

**The rule**: 10% off first order. Single-use unique code. Never a generic code like WELCOME10 (leaks to coupon sites, Honey browser extension, Reddit threads).

**Delivery method**: Exit-intent popup only (not immediate page load). Show only to new visitors. 70% of Shopify stores use welcome discounts; 30% (mostly luxury) don't — WisePops study of 500+ stores.

**The hidden cost**: GrowthSuite found 40–60% of visitors have already decided to buy — showing them a popup gives away profit for nothing. ProfitWell research across 4,200 subscription brands: higher discounts at purchase = lower LTV, lower satisfaction, 26% higher revenue churn.

**BeautyOnTApp implementation**: Keep the 10% welcome code from the retention skill's welcome series (Email 1). But shift to exit-intent only — don't show it to every visitor. Consider testing a free deluxe sample GWP instead of 10% off — ProfitWell found free gifts correlate with HIGHER LTV than percentage discounts.

**Alignment with retention skill**: Welcome series Email 1 already uses "10% first-order discount code." This is permitted. Do NOT increase to 15% or 20%.

### 2. Cart Abandonment (Email #3 only, prefer non-discount)

**The rule**: Never lead with a discount. Introduce incentive in email #3 ONLY if emails 1 and 2 failed. Prefer free gift or store credit over percentage-off.

**The sequence** (aligned with retention skill):

| Email | Timing | Content | Incentive |
|---|---|---|---|
| 1 | 1 hour | Simple reminder + cart contents + checkout link | NONE — urgency and social proof only |
| 2 | 24 hours | Address objections + reviews | NONE — "This product sells out fast" |
| 3 (SMS/WhatsApp) | 48 hours | Last chance | Gift-with-purchase OR R50 store credit — NOT percentage off |

**Why no cart abandonment discount**: TIME Magazine documented Reddit shoppers compiling lists of retailers that offer cart abandonment discounts. Shoppers deliberately abandon carts to trigger coupons. Klaviyo warns: "Offering discounts to repeat cart abandoners trains them to wait."

**Alignment with retention skill**: Retention skill says "NEVER offer a discount in cart abandonment — no free delivery, no % off. Urgency and social proof only." The SMS/WhatsApp at 48 hours can include a GWP or store credit, but NOT a percentage-off code. This is consistent.

### 3. Win-Back for Lapsed Customers (91–180 days, last resort)

**The rule**: 10% off maximum. Use ONLY after non-discount win-back attempts have failed (content, new arrivals, social proof). Never for price-sensitive churners — they'll churn again regardless.

**Alignment with retention skill**: Retention skill Email 3 (day 150) includes "limited-time incentive (10% off, NOT free delivery)." This is the final attempt. If this fails, suppress — don't escalate to 15% or 20%.

### 4. Birthday/Anniversary (Relationship, not transactional)

**The rule**: R50 off voucher (fixed Rand amount, not percentage). Feels like a gift, not a sale. Personalised to the customer.

**Alignment with retention skill**: Retention skill specifies "Birthday: Personalized discount (R50 off, NOT free delivery) + product recommendation." This is correct.

---

## WHEN NEVER TO DISCOUNT — Hard Prohibitions

| Situation | Why Never |
|---|---|
| Hero products (Pastry Skincare bestsellers, COSRX Snail Mucin) | Discounting top sellers trains customers to wait for sales on the products they actually want |
| New launches (first 30–60 days) | Undermines launch excitement and perceived value. Apple never discounts new releases. |
| Public sitewide sales outside 2 annual windows | Trains discount-seeking behavior. Brooks Brothers trap. |
| Response to competitor pricing (Clicks/Dis-Chem promotions) | You cannot win a price war against 1,000+ store chains. Compete on experience, not price. |
| Free delivery (EVER) | R30 store pickup / R60 locker / R120 door-to-door / R75 same-day. No free option exists. Non-negotiable business rule. |
| Cart abandonment emails 1 and 2 | Trains deliberate cart abandonment. Urgency and social proof only. |
| K-beauty imports where margin is thin | Already tight margins from import costs. Discounting makes them unprofitable. |

---

## WHAT TO DO INSTEAD — Value-Add Alternatives

### 1. Gift-With-Purchase (GWP) — Best for Beauty

ProfitWell data: free gift with purchase correlates with HIGHER lifetime value than percentage discounts. Beauty customers perceive GWP as generous (brand giving something) vs discounts as desperate (brand cutting price).

**Implementation**: "Spend R500+, receive a free Pastry Skincare mini set." Product cost to BeautyOnTApp: R30–R50. Perceived value to customer: R100–R150. Margin preserved. AOV lifted. Customer tries a new product.

**Shopify implementation**: Use Shopify's automatic discount function (Buy X Get Y) or a free gift app. GitHub repo: roman-gavrilov/shopify-free-gift-custom-app for custom implementation.

### 2. Store Credit / Cashback — Best for Retention

Real merchant evidence: one verified Shopify merchant reported net profit margin jumping from **14.5% to 37.5%** after switching from discounts to store credit cashback. Another documented 3.1× higher repeat purchase rate with store credit vs discount codes. Dollarback merchants report 40%+ redemption rates vs 18% industry benchmark for points programs.

**Why store credit beats discounts**:
- Discount = immediate margin loss + no guarantee of return visit
- Store credit = customer MUST return to redeem, guaranteed second transaction
- Store credit preserves listed price — no brand perception damage
- 79% of consumers express disinterest in accumulating points (Ebbo survey) — but 100% understand "R50 in your wallet"

**Alignment with retention skill**: Skin IQ Club uses cashback as store credit (2%/5%/7% tiers). This IS the store credit model. Reinforce it.

**Shopify apps for store credit**: Rise.ai (4.7★, 744 reviews — unified wallet), Redeemly (5.0★ — the 14.5%→37.5% margin merchant), Dollarback (5.0★ — 40%+ redemption).

### 3. Bundles — Best for K-Beauty & AOV

K-beauty brands report bundles increase AOV by 40–60%. Perfect for multi-step routines. "The Complete Glow Routine" bundle (cleanser + toner + serum + moisturizer) at a small discount vs individual prices feels like a deal without discounting any individual product.

**Rule**: Bundle discount never exceeds 15% off total individual prices. Position as "routine savings" not "sale." GitHub: Santho-sh/shopify-product-bundler-app for implementation.

### 4. Community-Driven Access — Best for Launches & BFCM

OUAI (haircare) replaced blanket BFCM discounts with community-driven access → **590% increase in redemptions** (highest ever) with zero margin compression. SET Active used drop-based model where early access was earned through community engagement → **$1M in sales within one hour**, 65% from community members. No discount codes.

**BeautyOnTApp implementation**: Skin IQ Club members get early access to new K-beauty drops 48 hours before public launch. Bestie Squad ambassadors get first access + free sample. This creates urgency through EXCLUSIVITY, not through price reduction.

### 5. Empties Return Program — Beauty's Apple Trade In

Customers bring finished containers for R50 store credit toward next purchase. Mirrors Apple Trade In philosophy (offsets cost while preserving listed price). Drives repeat visits. Sustainability signal.

---

## BFCM / SEASONAL STRATEGY — Maximum 2 Sitewide Events Per Year

**Apple's approach**: Gift cards, never price cuts. Newest flagship always excluded.

**BeautyOnTApp BFCM playbook**:

| Element | Rule |
|---|---|
| Frequency | Maximum 2 sitewide promotional events per year (BFCM + 1 other — Heritage Day or Mother's Day) |
| Discount depth | Never exceed 20% for premium brands. 10–15% is ideal. |
| Format | "Bestie Box" limited-edition bundles at full price + GWP with qualifying spend > flat percentage off |
| Hero products | NEVER discounted. New launches (last 60 days) excluded. |
| Communication | Private to Skin IQ Club members first (48-hour early access) → public after |
| Duration | Maximum 4 days. Extended sales train customers to wait. |
| Post-event | NO further discounts for minimum 8 weeks |

**Prestige beauty benchmark**: DiffScout tracking of hundreds of beauty brands confirms prestige skincare caps BFCM at 15–20%. Mass-market goes to 20–28%. "Anything deeper starts to undermine the brand story permanently."

---

## DISCOUNT DECISION FRAMEWORK — Use Before Every Promotion

Before approving any discount, run through this checklist:

| Question | If YES | If NO |
|---|---|---|
| Is this a hero product? | DO NOT DISCOUNT | Proceed |
| Is this a new launch (<60 days)? | DO NOT DISCOUNT | Proceed |
| Will this be visible to all customers? | Avoid — use private/targeted instead | Proceed |
| Could the customer get this code from a coupon site? | Use unique single-use codes | Proceed |
| Have we run a sitewide promotion in the last 8 weeks? | DO NOT RUN ANOTHER | Proceed |
| Is the customer already converting without incentive? | Don't add a discount — you're giving away margin | Proceed |
| Can we achieve the same goal with GWP, store credit, or bundle? | DO THAT INSTEAD | Then proceed with discount |
| Is this response to competitor pricing? | DO NOT MATCH — compete on experience | N/A |

---

## ALIGNMENT WITH OTHER SKILLS

This skill resolves the conflict between premium-positioning logic (never discount) and retention flows (uses specific discounts). The resolution:

| Retention Skill Element | This Skill's Verdict | Change Needed? |
|---|---|---|
| Welcome series 10% first-order code | PERMITTED — but shift to exit-intent popup, not every visitor. Test GWP alternative. | Minor tweak |
| Cart abandonment — no discount | CORRECT — retain as-is | None |
| Win-back 10% off (day 150, Email 3) | PERMITTED — last resort only, after content attempts failed | None |
| Birthday R50 off voucher | PERMITTED — relationship gift, not transactional | None |
| Skin IQ Club cashback (2%/5%/7% store credit) | EXCELLENT — this IS the store credit model. Reinforce. | None |
| No free delivery as loyalty perk | CORRECT — "R30 off delivery" for VIP max, never R0 | None |

**No conflicts remain.** Apple-intel Principle #3 now reads "Protect the price — see discount-strategy skill" instead of "Never discount."

---

## CROSS-REFERENCE

| Topic | Skill |
|---|---|
| Loyalty tiers (Bestie/VIP/Insider) | beautyontapp-retention |
| Welcome/cart/win-back email flows | beautyontapp-retention |
| Ad copy for promotions | beautyontapp-copywriting-engine |
| BFCM campaign structure (Meta) | beautyontapp-meta-creative-testing |
| BFCM campaign structure (Google) | beautyontapp-google-ads (refs/sa-agency-playbook.md) |
| Competitor promotional intelligence | beautyontapp-sa-competitive-scanner |
