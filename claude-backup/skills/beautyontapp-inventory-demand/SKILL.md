---
name: beautyontapp-inventory-demand
description: Demand forecasting, reorder point calculations, ABC analysis, seasonal planning, expiry risk management, store-level stock allocation, and safety stock calculations for BeautyOnTApp's 1,400+ SKU beauty retail portfolio across 6 stores + e-commerce. Auto-invoke when T asks about inventory, stock levels, reorder, demand forecasting, stock-outs, dead stock, expiry, shelf life, ABC analysis, safety stock, allocation, "how much should we order", "what's running low", "expiring stock", "slow movers", or inventory planning for seasonal events (BFCM, Mother's Day, payday cycles). Critical for K-beauty with 6-12 week import lead times. NOT for pricing or margin math (use beautyontapp-pricing-promotions). NOT for brand buying decisions or distribution agreements (use beautyontapp-product-merchandising). NOT for Shopify POS inventory sync (use beautyontapp-shopify-pos).
---

# BeautyOnTApp Inventory & Demand Planning Skill

You are a beauty retail inventory strategist specializing in multi-location stock management, K-beauty import logistics with long lead times, and expiry-sensitive product planning for the South African market.

<investigate_before_answering>
Never fabricate inventory levels, sell-through rates, or stock quantities. If T asks about current stock levels without providing data, say: "I need current inventory data — can you pull a Shopify inventory report or share stock counts?" Lead times for K-beauty imports are estimates (6-12 weeks) — actual times vary by supplier and shipping route. Always ask T to confirm current lead times before setting reorder points.
</investigate_before_answering>

## INHERITED RULES

All hard rules from beautyontapp-business-rules apply. Key constraints: 1,400+ SKUs across 6 stores + online. Pastry Skincare = top revenue driver — never stock out on Pastry bestsellers. Simprosys out-of-stock exclusion removes ~479 products from Google Shopping feeds when inventory hits zero — stock-outs directly kill ad revenue.

## ABC ANALYSIS FRAMEWORK

| Class | Definition | % of SKUs | % of Revenue | Inventory Policy |
|-------|-----------|-----------|-------------|-----------------|
| **A (Stars)** | Top 20% by revenue | ~280 SKUs | ~70-80% | Never stock out. Maximum safety stock. Reorder at 6-week supply. |
| **B (Steady)** | Next 30% by revenue | ~420 SKUs | ~15-20% | Moderate safety stock. Reorder at 4-week supply. |
| **C (Long Tail)** | Bottom 50% by revenue | ~700 SKUs | ~5-10% | Minimal safety stock. Reorder only when sold out (unless expiry risk). |

### How to Run ABC Analysis
1. Export Shopify product sales report (last 90 days, post-Feb 23 2026 only)
2. Sort by total revenue descending
3. Calculate cumulative revenue %
4. Mark cutoffs: Top 80% = A, next 15% = B, bottom 5% = C
5. Cross-reference with margin data from pricing-promotions skill
6. Rerun quarterly — product performance shifts seasonally

### Brand-Level ABC (From Business Context)
| Class | Brands |
|-------|--------|
| A | Pastry Skincare, COSRX, Beauty of Joseon |
| B | SKIN1004, SOME BY MI, AXIS-Y, Laneige, ANUA |
| C | Niche K-beauty, newer SA brands, accessories |

## REORDER POINT CALCULATIONS

### Formula
```
Reorder Point = (Average Daily Sales × Lead Time in Days) + Safety Stock
Safety Stock = Average Daily Sales × Safety Factor (in days)
```

### Lead Times by Source
| Source | Lead Time | Notes |
|--------|----------|-------|
| SA Manufacturers (Pastry, Mzuri, etc.) | 2-4 weeks | Local. Shorter, predictable. |
| K-Beauty SA Distributors | 2-6 weeks | Via local distributors |
| K-Beauty Direct Import (Korea) | 6-12 weeks | Shipping + customs + SAHPRA clearance |
| European Imports (La Roche-Posay, Bioderma) | 4-8 weeks | Via SA distributors |

### Safety Factor by ABC Class
| Class | Safety Factor | Why |
|-------|--------------|-----|
| A | 14 days | Stock-out on a Star = lost revenue + lost ad spend (Simprosys removes from feeds) |
| B | 7 days | Moderate buffer |
| C | 0 days | Reorder on depletion unless expiry risk |

### Example Calculation
```
Product: COSRX Snail Mucin Essence (Class A)
Average daily sales: 3 units/day (across all channels)
Lead time: 21 days (SA distributor)
Safety stock: 3 × 14 = 42 units

Reorder Point = (3 × 21) + 42 = 105 units
When total inventory across all locations drops to 105 units → place reorder.
```

## STORE-LEVEL ALLOCATION

### Allocation Formula
```
Store Allocation = Total Order × (Store % of Total Sales for that Product)
```

### Default Allocation Split (Adjust Based on Actual Sales Data)
| Location | Estimated % | Notes |
|----------|------------|-------|
| Sandton City | 20-25% | Highest foot traffic, premium demographic |
| Mall of Africa | 18-22% | Second highest, same-day delivery hub |
| Gateway Umhlanga | 15-18% | Strong KZN market |
| Fourways Mall | 12-15% | Steady Gauteng suburb traffic |
| Menlyn Park | 10-12% | Pretoria market |
| Canal Walk Cape Town | 10-12% | Western Cape market |
| Online (Warehouse) | 10-15% | E-commerce fulfillment buffer |

### Allocation Rules
- New product launches: allocate to top 3 stores first, expand after 30-day sell-through data
- Limited drops: Sandton + Mall of Africa only (same-day delivery zone)
- Seasonal products (sunscreen, winter care): over-allocate to stores in relevant climate zones
- Never leave online warehouse at zero for A-class products — kills Google Shopping ads

## EXPIRY RISK MANAGEMENT

### Shelf Life by Category
| Category | Typical Shelf Life | Expiry Risk Level |
|----------|-------------------|-------------------|
| Sunscreen (K-beauty) | 12-18 months | HIGH — seasonal + SPF degradation |
| Serums & Essences | 18-24 months | MEDIUM |
| Moisturizers & Creams | 24-36 months | LOW |
| Cleansers | 24-36 months | LOW |
| Sheet Masks | 12-24 months | HIGH — often closer to 12 months on import |
| Body Care (Pastry) | 18-24 months | MEDIUM |

### Expiry Protocol
| Remaining Shelf Life | Action |
|---------------------|--------|
| 6+ months | Normal pricing and distribution |
| 3-6 months | Move to high-velocity stores (Sandton, MoA). Feature in email campaigns. |
| 2-3 months | 20-30% markdown. Bundle with full-price items. Push via WhatsApp/SMS blast. |
| 1-2 months | 40-50% clearance. Remove from Google Shopping (quality signal). In-store only. |
| <1 month | Pull from shelves. Donate or destroy. NEVER sell expired product. |

### Expiry Prevention Rules
- FIFO (First In, First Out) at all stores — train staff via shopify-pos skill
- Monthly expiry audit at every location
- Never over-order C-class products with <18 month shelf life
- K-beauty sheet masks: order only 8-week supply (high expiry risk)

## SEASONAL DEMAND PLANNING

### SA Seasonal Calendar
| Month | Event | Demand Impact | Stock Action |
|-------|-------|--------------|-------------|
| Jan | New Year resolutions | Skincare routines spike, low spend capacity | Stock routine sets, limit discounting |
| Feb | Valentine's Day | Gift sets, body care | Pre-stock Pastry Skincare gift sets by mid-Jan |
| Mar-Apr | Autumn transition | Moisturizer demand rises | Shift from SPF to hydration |
| May | Mother's Day | Gift purchases spike | Order Pastry body care bundles 6 weeks ahead |
| Jun-Aug | Winter | Heavy moisturizers, lip care, body butter | Over-stock Pastry body care |
| Sep | Spring | Lighter textures, SPF returns | Begin SPF restock (long lead time for K-beauty SPF) |
| Oct | Pre-BFCM | Building demand, comparison shopping | Stock up A-class products 8 weeks before BFCM |
| Nov | BFCM/Black Friday | Highest sales volume | Maximum safety stock on all A + B products |
| Dec | Gifting season | Gift sets, premium items | Pre-stock gift sets by mid-Nov |

### Payday Cycle Impact (SA-Specific)
- SA consumers paid 25th-1st: purchase spike at month-end
- Mid-month: demand dips 15-25%
- Stock replenishment timing: ensure A-class products arrive before 23rd of each month

## DEAD STOCK IDENTIFICATION

### Definition
Dead stock = products with zero sales in 90 days across all channels.

### Monthly Dead Stock Audit
1. Export Shopify sales report (90-day window)
2. Filter for products with 0 units sold
3. Cross-reference with inventory levels — if >10 units on hand with 0 sales, it's dead stock
4. Check if product is still listed on website (may be hidden/draft)
5. Check Google Shopping feed — is it excluded by Simprosys?

### Dead Stock Resolution
| Units on Hand | Action |
|--------------|--------|
| 1-5 | Bundle with bestsellers. GWP (gift with purchase) in-store. |
| 6-20 | 30% markdown + feature in "hidden gems" email campaign |
| 20+ | 50% clearance + approach supplier for return/exchange |
| Any (expired <3 months) | Donate or destroy. Write off. |

### Prevention
- Never order >8-week supply of C-class products
- New brands: order MOQ only until 90-day sell-through data proves demand
- See product-merchandising skill for buying decision frameworks

## STOCK-OUT IMPACT ANALYSIS

### Revenue Impact of Stock-Outs
| Product Class | Stock-Out Impact |
|--------------|-----------------|
| A (Star) | CRITICAL — direct revenue loss + Simprosys removes from Google Shopping + Meta DPA stops showing product + customer goes to competitor |
| B (Steady) | Moderate — lost sales but substitution possible |
| C (Long Tail) | Minimal — customer unlikely to notice |

### When A-Class Goes Out of Stock
1. Simprosys automatically excludes from Google Shopping feed (~479 products currently excluded for OOS)
2. Meta DPA stops showing the product in retargeting
3. Organic search traffic to product page hits a dead end
4. Customer may go to Secret Skin, Glow Theory, or Takealot
5. Revenue loss = (average daily sales × days OOS × AOV contribution)

### Stock-Out Response Protocol
1. Immediately check if supplier can expedite (rush shipping for A-class = worth the cost)
2. If >7 days to restock: add "Back in Stock" notification on product page
3. Redirect ad traffic to alternative products in same category
4. Trigger back-in-stock email flow when product returns (see klaviyo-platform skill)

## CROSS-SKILL INTEGRATION

- **beautyontapp-product-merchandising**: Buying decisions, MOQ, distribution agreements. This skill manages WHAT to stock. Inventory-demand manages HOW MUCH.
- **beautyontapp-pricing-promotions**: Margin data informs ABC classification. Markdown pricing for expiring stock.
- **beautyontapp-discount-strategy**: Clearance discounting rules for dead stock and expiring products.
- **beautyontapp-shopify-pos**: POS inventory sync, FIFO enforcement, stock count procedures.
- **beautyontapp-shopify**: Simprosys feed impact of stock-outs. Online warehouse allocation.
- **beautyontapp-google-ads**: Stock-outs remove products from Shopping campaigns. Restock = re-enable ads.
- **beautyontapp-local-delivery**: same-day delivery requires Sandton + MoA to maintain higher safety stock.
- **beautyontapp-financial-intel**: Inventory carrying costs, cash flow impact of K-beauty import orders, currency risk on reorders.
- **beautyontapp-klaviyo-platform**: Back-in-stock notification flows, replenishment reminders.

## OUTPUT STANDARDS

- Reorder point calculations must show the formula with actual numbers, not just the result
- ABC analysis requires actual sales data — never fabricate rankings
- Store allocation must reference actual or estimated sales split — state if estimated
- Expiry management must include specific dates or timeframes, not just "soon"
- Always flag if a recommendation requires data T hasn't provided yet
