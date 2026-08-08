---
name: beautyontapp-returns-management
description: Returns and reverse logistics for BeautyOnTApp — return policy design, beauty-specific return reasons (shade mismatch, sensitivity reactions, wrong product for skin type), in-store returns for online orders, return-to-exchange conversion, loss prevention, restocking criteria for opened beauty products. Auto-invoke for "returns", "refund", "exchange", "return policy", "wrong shade", "product didn't work", "allergic reaction", "return to store", "reverse logistics", or any returns/refund question. NOT for fraud detection. NOT for customer service scripts (use beautyontapp-customer-experience).
---

# Returns Management for BeautyOnTApp

Beauty returns are unique: opened products can't be resold, shade mismatches are common, and skin reactions create liability. A good return policy builds trust (reduces purchase anxiety) while protecting margins. Bash's TFG has a 30-day return policy across 4,766 stores. BeautyOnTApp needs a policy that's generous enough to compete but smart enough to protect margin.

## HARD RULES
1. Never resell opened/used beauty products. Hygiene and SAHPRA compliance.
2. In-store returns for online orders must be supported at all 6 stores (omnichannel expectation).
3. Never charge a restocking fee on unopened products. Customer trust > margin recovery.
4. Refund to original payment method. Store credit only if customer requests it.
5. Track return reasons — high return rates on specific products signal product-market fit issues.

## RETURN POLICY (PROPOSED — VERIFY with T)

### Standard Returns
- **Timeframe**: 14 days from delivery (VERIFY current policy)
- **Condition**: Unopened, sealed, original packaging
- **Process**: Customer contacts CX → receives return authorization → returns via post or in-store
- **Refund**: Original payment method within 5-7 business days

### Beauty-Specific Exceptions
| Situation | Policy | Rationale |
|---|---|---|
| Shade mismatch | Exchange for correct shade (no return needed if exchanging) | Common in beauty — punishing this loses customers |
| Skin reaction/allergy | Full refund, no return of product needed | Liability + hygiene — don't accept back |
| "Didn't work for me" | Store credit for next purchase (not refund) | Reduces loss, retains customer |
| Wrong product received | Full refund + correct product shipped free | Our error = our cost |
| Damaged in transit | Full refund or replacement, no return needed | Delivery insurance covers this |

### No Returns On
- Opened/used products (except allergic reaction)
- Sale/clearance items (VERIFY if this is current policy)
- Gift cards
- Skin analysis services (R285/R199)

## RETURN-TO-EXCHANGE CONVERSION

Goal: Convert returns into exchanges, retaining the revenue in-house.

### Exchange Incentives
- "Exchange instead of refund? We'll add R30 store credit to your next order 🖤"
- In-store: beauty advisor helps find the RIGHT product → exchange + upsell opportunity
- Online: suggest alternatives based on stated return reason → "Customers who returned [X] loved [Y]"

### Return Reason → Product Recommendation Engine
| Return reason | Automated suggestion |
|---|---|
| "Too heavy/greasy" | Lighter-weight alternatives in same concern category |
| "Didn't see results" | Higher-concentration product or longer usage guide |
| "Wrong shade" | Shade finder quiz link + exchange for correct shade |
| "Skin reaction" | Sensitive-skin alternatives + "Book free skin analysis" |
| "Too expensive" | Similar products at lower price point + "Subscribe & save 10%" |

## IN-STORE RETURNS FOR ONLINE ORDERS

- All 6 stores must accept returns for any online order
- POS staff scan order barcode → verify order in Shopify → process refund/exchange
- Staff training: never refuse an in-store return for an online order without manager approval
- Inventory adjustment: returned item goes back into store inventory if unopened

## REVERSE LOGISTICS

### For Postal Returns
- Provide prepaid return label OR customer ships at own cost (VERIFY current policy)
- Returns shipped to: nearest store or central warehouse (VERIFY)
- Track all return shipments — untracked returns = lost inventory

### For In-Store Returns
- Product returned directly to store inventory
- Unopened: restock. Opened: write off (marked as "return loss" in inventory)
- Monthly return loss report per store

## METRICS

| Metric | Target | Worry threshold |
|---|---|---|
| Return rate (% of orders) | <5% | >8% |
| Return-to-exchange rate | >40% | <20% |
| Time to refund | <7 business days | >14 days |
| Top return reasons | Track monthly | Any single reason >30% of returns |
| Return loss (opened product value) | <R[X]/month (VERIFY) | Growing trend |

## DECISION RULES

1. **When return rate exceeds 8%**: Investigate by product. High return products need better PDP information (photos, ingredients, skin type guidance) not a stricter return policy.
2. **When a product has >20% return rate**: Pull from ads, add "Consult with beauty advisor before purchasing" badge, investigate formulation/expectation mismatch.
3. **When customers return to stores**: This is a WIN — it brings them physically into a store where beauty advisors can recommend alternatives. Train staff to treat returns as consultation opportunities.
4. **When Bash offers easy returns via 4,766 stores**: We can't match on convenience. Counter with BETTER service — personal consultation during the return, finding the right product, turning a return into a loyalty moment.
5. **When tracking returns**: Log every return reason in a structured format (not free text). This data feeds product selection, CRO, and ad targeting decisions.
