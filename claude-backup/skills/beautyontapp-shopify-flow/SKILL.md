---
name: beautyontapp-shopify-flow
description: Design, deploy, and audit Shopify Flow automations for BeautyOnTApp on Shopify Advanced (Flow is included at no cost and runs server-side — zero Claude token cost). Auto-invoke when T says "Flow", "automate in Shopify", "alert me when", "auto-tag", "workflow", "guard", or when any recurring manual admin check surfaces — catalog hygiene (missing product type or tags, null SKUs, duplicate SKUs, delisted-vendor republish), low-stock alerts, order tagging (B2B, high-value), refund notifications. Also invoke when a Shopify audit finding repeats a failure class Flow could have caught. NOT for email/SMS flows (use beautyontapp-klaviyo-platform). NOT for ad-platform rules (use beautyontapp-google-ads-automated-rules). NOT for theme code (use beautyontapp-shopify). Never build Flows that write to products, feeds, or data managed by Analyzify, Simprosys, or BookX.
---

# BeautyOnTApp Shopify Flow

Principle: any recurring check that reduces to **trigger → condition → action** belongs in Flow, not in a Claude chat. Flow runs 24/7 on Shopify's side at zero token cost. Claude's job is designing the workflow, writing the exact trigger/condition/action spec, and verifying it fired correctly — not performing the check itself.

## Deployment rules (narrow bridge)

- Build in Shopify Admin → Apps → **Flow** (install the free Shopify Flow app if not present).
- Alert-only first: every new workflow starts with tag + email actions. Promote to write actions (e.g. set status to Draft) only after one week of clean alerts.
- Never build Flows that modify anything Analyzify, Simprosys, or BookX owns.
- Test every workflow with a throwaway draft product / test order before enabling; delete the test artifact after.
- Exact trigger/condition/action names below are from Shopify Flow's standard library — confirm each exists in the Flow editor at build time before promising it in a dispatch; Flow's action catalogue changes.

## Recipe library

Each recipe guards a failure class that has actually occurred [source: Shopify audit, prior session — re-verify current state in admin before citing counts].

**R1 — Missing-metadata guard.** Trigger: Product added to store (and: Product status updated → Active). Condition: product type is empty OR tags is empty. Action: add product tag `needs-metadata` + send internal email. Guards the live-listing-stripped-of-tags/product-type failure class.

**R2 — Null-SKU guard.** Trigger: Product variant added. Condition: SKU is empty. Action: add tag `sku-missing` + email. Guards the null-SKU bundle failure class.

**R3 — Duplicate-SKU check.** Trigger: Product variant added. Step: Get product variant data (query: `sku:<new variant SKU>`). Condition: result count > 1. Action: tag `sku-duplicate` + email. Guards the duplicate-SKU failure class. Verify the "Get product variant data" step is available in the editor; if absent, fall back to a monthly variant export + duplicate scan dispatched to the Haiku tier.

**R4 — Delisted-vendor republish guard.** Trigger: Product status updated → Active. Condition: vendor is any of the delisted list (seed: TIAM [source: prior-session audit — confirm current delist list with T at build time]; extend as brands are removed). Action (week 1): tag `blocked-vendor` + email. Action (after clean week, if T approves): set product status to Draft. Guards the delisted-brand-still-live failure class.

**R5 — Low-stock alert.** Trigger: Product inventory quantity changed. Condition: available quantity ≤ threshold at a given location. Action: email per location. Thresholds come from the PML Stock Take / reorder-point work — do not hardcode figures in the workflow name; keep them editable in the condition.

**R6 — B2B / high-value order tagging.** Trigger: Order created. Condition: order total ≥ threshold OR customer tagged B2B. Action: tag order `b2b-review`. Feeds the invoice-chase workflow.

**R7 — Refund notification.** Trigger: Refund created. Action: email + tag customer `refunded`. Feeds returns analysis.

## Do NOT use Flow for

- Back-in-stock customer notifications — Klaviyo BIS owns that (e.g. the restocking-soon PDP pattern).
- Price or discount changes — pricing decisions stay with T via the pricing skills.
- Anything touching tracking, pixels, or product feeds.
- Auto-deleting or redirecting products — 301s carry SEO implications and go through theme/admin review.

## Validation

After enabling each workflow: create one violating test artifact, confirm the tag and email arrive within minutes, delete the test artifact, record the workflow name + date in the ops log. Done = all deployed recipes have a passed test on record.

## Versioning

v1 (5 Jul 2026) — created to move recurring catalog-hygiene and order checks out of Claude chats onto Shopify's side after repeat audit findings in the same failure classes.
