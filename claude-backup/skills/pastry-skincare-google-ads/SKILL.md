---
name: pastry-skincare-google-ads
description: Google Ads account management for Pastry Skincare (Account 851-084-2703). Auto-invoke when T mentions Pastry Skincare Google Ads, Pastry Skincare campaigns, Pastry PPC, Pastry conversions, Pastry tracking, or any Google Ads question specific to the Pastry Skincare account (not BeautyOnTApp). NOT for BeautyOnTApp Google Ads (use beautyontapp-google-ads). NOT for Pastry Skincare Meta Ads (use beautyontapp-meta, which covers both brands).
---

# Pastry Skincare Google Ads Account

## Account IDs

| Asset | ID |
|---|---|
| Pastry Skincare Google Ads | 851-084-2703 |
| Merchant Center | 5692060761 |

## HARD RULES (inherited from PNCapital)

1. Purchase is the ONLY primary conversion action
2. Analyzify v4 = sole tracking source
3. Never start new campaigns on Maximize Conversions
4. English only
5. Never mention free delivery
6. Revert over rebuild
7. Post-Feb 23 2026 data only
8. Campaign-Specific Goals with Purchase only — never Account-Default
9. "Conversions" column only — never "All conversions"
10. Pastry Skincare = "proudly South African" — never "in-house" or "our own brand"

## PRODUCT CONTEXT

- Pastry Skincare is the top revenue driver across PNCapital (21 of top 145 bestsellers)
- SA brand with high margins (60-80% confirmed)
- This means Pastry should be the MOST profitable Google Ads account — poor performance is a red flag, not expected behavior

## MERCHANT CENTER

- Shared Merchant Center 5717759749 with BeautyOnTApp
- Simprosys manages feeds for both brands
- Pastry products should have their own product type taxonomy
- Check disapproval status for Pastry products specifically during audits

## AUDIT PROTOCOL

Use the same beautyontapp-ppc-audit-engine protocol. Key Pastry-specific checks:

1. **Conversion tracking:** Verify Pastry has a working Analyzify Purchase conversion action — either its own or properly imported from BeautyOnTApp
2. **Campaign-Specific Goals:** Every campaign must use Campaign-Specific Goals with Purchase only
3. **Google-hosted phantom actions:** Check for auto-created local actions (same issue as BeautyOnTApp)
4. **Budget ceiling scope:** Confirm with T whether R1,000/day ceiling is per-account or combined across BeautyOnTApp + Pastry
5. **Feed quality:** Pastry product titles should follow SA brand formula: Brand + Product Type + Key Ingredient + Skin Type + Size

## BUDGET CONTEXT

- BeautyOnTApp Google Ads ceiling: see `03_PNCapital_Business_Facts §Advertising Ceilings` (changes — do not hardcode)
- **UNRESOLVED:** Whether this ceiling applies per-account or combined across both accounts
- Always clarify with T before making budget recommendations for Pastry

## CHROME EXTENSION PROMPT REQUIREMENTS

When T requests an audit or fix prompt for Pastry, it must be:
- Fully autonomous (no manual data requirements)
- Account-specific to 851-084-2703
- Cover all steps from beautyontapp-ppc-audit-engine
- Include exact URLs with Pastry account ID in the ocid parameter

## CROSS-SKILL INTEGRATION

| Skill | When to use |
|-------|------------|
| beautyontapp-ppc-audit-engine | Full audit execution protocol |
| beautyontapp-bleeder-detection | Pause/keep thresholds |
| beautyontapp-google-ads | Shared Merchant Center context, BeautyOnTApp tracking patterns |
| beautyontapp-copywriting-engine | Pastry ad copy (SA brand voice) |
