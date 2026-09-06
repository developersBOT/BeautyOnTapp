# Implementation dispatch (verified targets only)

Status: ALL ITEMS BLOCKED BY READ-ONLY ACCESS. The Pastry Google Ads connector exposes only list/metadata/search; nothing in this package has been applied. No credentials, bypasses or permission expansions are proposed. Execute only with the stated authority, one item at a time, capturing pre-state, exact target, read-back, Change History, untouched-inventory comparison and rollback.

Account: customers/8510842703 (Pastry Skincare, ZAR, Africa/Johannesburg). Do not touch pastryskincare.co.za, themes, domains, Analyzify, Simprosys, Google & YouTube app, feeds or tracking.

| Dispatch | Change-sheet ID | Exact target | From | To | Authority needed | Pre-conditions |
|---|---|---|---|---|---|---|
| D-1 | CS-01 | campaignBudgets/15437657173 amount_micros | 400000000 | 200000000 | Budget reduction on Pastry_Brand_Search | none (alternative CS-01-ALT: target CPA 21010000 micros on campaign 23660059123; do not do both) |
| D-2 | CS-02 | adGroups/197968132526 status | ENABLED | PAUSED | Ad-group status | Confirm variant 46989386907889 is OUT_OF_STOCK in Shopify or on the live page; re-enable when IN_STOCK |
| D-3 | CS-03a | adGroupCriteria/197968132966~296254512880 cpc_bid_micros | ad-group R3.00 | 4100000 | Keyword bid | none |
| D-4 | CS-03b | adGroupCriteria/197968133486~312631480528 cpc_bid_micros | ad-group R3.00 | 6500000 | Keyword bid | none |
| D-5 | CS-03c | adGroupCriteria/197968133246~309843502541 cpc_bid_micros | ad-group R3.00 | 3600000 | Keyword bid | none |
| D-6 | CS-03d | adGroupCriteria/197968133886~320574128594 cpc_bid_micros | ad-group R3.00 | 4500000 | Keyword bid | none |
| D-7 | CS-04a | new EXACT keyword "niacinamide serum" in adGroups/197968133726 | absent | ENABLED, no keyword bid | Keyword add | none |
| D-8 | CS-04b | new EXACT keyword "hyperpigmentation serum" in adGroups/197968133726 | absent | ENABLED | Keyword add | none |
| D-9 | CS-04c | new EXACT keyword "dark spot corrector" in adGroups/197968132926 | absent | ENABLED | Keyword add | none |
| D-10 | CS-04d | new EXACT keyword "ceramide serum" in adGroups/197968132766 | absent | ENABLED | Keyword add | none |
| D-11 | CS-04e | new EXACT keyword "body acne wash" in adGroups/197968133886 | absent | ENABLED | Keyword add | none |
| D-12 | CS-04f | new EXACT keyword "exfoliating body wash" in adGroups/197968132966 | absent | ENABLED | Keyword add | none |
| D-13 | CS-06 | Shopify product images: products 9322841997553 (Brightening Body Oil) and 8818191630577 (Anti-Pigment Hand Cream SPF30) | image with promotional overlay | overlay-free primary image | Store owner | Not a Google Ads change; re-read shopping_product.issues after next sync |

Not dispatched (decision required): CS-05 product-route re-enable; CS-07 experiment housekeeping; CS-08 conversion hygiene.

Receipts to capture per item: pre-state read (search_search of the exact resource), mutation response resource_name, post-state read-back, change_event row (change_date_time, user_email, client_type, old/new values), diff of the full campaign/budget/keyword inventory against evidence/campaigns_inventory.csv and evidence/keywords_active_campaigns.csv showing only the intended field changed, and the rollback value above.
