---
name: beautyontapp-skill-router
description: Master router for 76 BoT/PNCapital skills (Google/Meta/Shopify focused). Auto-invoke at START of every BoT task to select correct skill or bundle. Resolves disambiguation. NOT for execution.
---

# BeautyOnTApp Skill Router (FINAL — May 2026, post 38-skill cleanup)

Master index for routing tasks to the correct skill or bundle. Read FIRST on any BoT/Pastry/Mzuri/PNCapital task. Then invoke selected skills. Then execute.

**84 user skills total** in /mnt/skills/user/ (83 beautyontapp-*, 1 pastry-skincare-google-ads). The sa-tax-optimizer skill is a PHANTOM — it does not exist on disk; treat tax questions natively. Source-of-truth: `ls /mnt/skills/user/ | wc -l`.

T's stated rule: "99% of skills we need are Google + Meta + Shopify." Library is now focused on that core, plus SA-market competitive intelligence (Bash, Woolworths, Secret Skin) and international benchmarks T wants to beat in Africa (Sephora, Olive Young, Ulta).

## DELETED MAY 2026 (do not invoke)

38 skills deleted. Categories:
- **Generic finance theory** (Berkshire, Bridgewater, Citadel, BlackRock, Goldman, Walton) — Claude knows natively
- **Generic strategy frameworks** (HBS Porter/SWOT, McKinsey MECE) — Claude knows natively
- **Generic marketing theory** (marketing-psychology, creative-director, ogilvy-marketing, customer-research) — Claude applies natively + copywriting-engine covers BoT-specific
- **Aspirational playbooks** (apple-intel, uber-delivery-intel, v8-gloot-playbook) — superseded by domain skills
- **Round-1 deletions** (skill-judge, naspers-prosus-intel, google-ads-playbook, meta-ads-playbook) — content preserved in references/ of survivors
- **Takealot is competition** (takealot-intel, marketplace-strategy) — T decision: never selling there
- **Redundant** (apify-intel, kpi-dashboard, revops, financial-modeling, design-system, site-architecture, churn-prevention, workflow-automation) — covered by other skills
- **Future-state** (rag-product-discovery, video-production, subscription-replenishment, cross-border) — re-add when active
- **Generic infra** (team-composition, security-best-practices, accessibility) — Claude applies natively

## DISCIPLINE LAYER — ALWAYS-ON

1. **audit-first** — uploaded/referenced files, "audit", "review", "analyze", "check"
2. **ship-it-right-first-time** — BEFORE every file/zip/code/prompt delivery
3. **execute-dont-ask** — when T gives a directive
4. **terse-output** — every response unless T asks for detail
5. **evidence-citations** — numbers, stats, prices, dates, regulations
6. **shopify-liquid-auditor** — theme zip, .liquid, schema, JSON-LD
7. **ads-benchmarks-auditor** — Google/Meta/TikTok ad exports
8. **subagent-orchestrator** — "audit and fix", "review and ship"
9. **complete-deliverables** — multi-issue technical fix (3+ known issues)
10. **challenge-verify** — IRREVERSIBLE changes (campaign delete, pixel change, robots.txt, canonical)

## CORE BUNDLES

### GOOGLE ADS — 8 skills
- **google-ads** (primary, account IDs, SA agency playbook in references/sa-agency-playbook.md)
- **ppc-audit-engine** (THE audit protocol)
- **bleeder-detection** (anti-conservative spending, mandatory before pause/keep)
- **landing-page-optimization** (Quality Score impact)
- **ai-max-search** (broad match expansion evaluation)
- **google-ads-automated-rules** (auto-pause, CPA alerts)
- **google-ads-scripts** (PMax transparency)
- **pastry-skincare-google-ads** (Pastry account 851-084-2703)

### META ADS — 6 skills
- **meta** (primary, pixel/CAPI, catalog config)
- **meta-audit-engine** (audit protocol)
- **meta-creative-testing** (creative + UGC framework in references/playbook-extras.md)
- **meta-scaling-engine** (scaling cadence)
- **meta-algorithm-intel** (Andromeda/GEM/Lattice diagnostics)
- **meta-competitive-creative** (Ad Library spy)

### SHOPIFY — 3 skills
- **shopify** (theme, apps, Analyzify/Simprosys/BookX guardrails, checkout deadline)
- **shopify-pos** (6 stores, hardware, POS Pro)
- **shopify-liquid-auditor** (theme audit protocol)

### TRACKING / ANALYTICS — 4 skills
- **analytics** (GA4/Analyzify, Conversions column rule)
- **cross-channel-attribution** (MER, Meta vs Google reconciliation)
- **cross-channel-reporting** (weekly/monthly/quarterly templates)
- **ab-testing** (sample size at 1,500 orders/mo)

### CONTENT / BRAND — 5 skills
- **copywriting-engine** (every customer-facing copy task)
- **brand-context** (read before any content task)
- **business-rules** (source of truth)
- **tools-stack** (Screaming Frog, Semrush, Triple Whale)
- **d3-visualizations** (T is visual learner)

### SEO — 7 skills
- **seo-content** (strategy, AEO, local SEO 6 stores)
- **onpage-seo** (Semrush execution)
- **counter-ppc** (Secret Skin Google Ads)
- **counter-seo** (Secret Skin organic)
- **tiktok** (SA discovery channel)
- **programmatic-seo** (template pages at scale)
- **web-performance** (Core Web Vitals, SA mobile 70%+)

### COMPETITORS / BENCHMARKS — 6 skills
**SA market:**
- **bash-intel** (TFG/Bash R5B beauty target — biggest threat)
- **woolworths-intel** (#1 direct competitor — premium mall, AMAZI)
- **sa-competitive-scanner** (16-competitor master scanner)

**Africa-expansion benchmarks (per T's stated intent):**
- **sephora-intel** (LVMH model — beat them in Africa)
- **olive-young-intel** (CJ K-beauty curation playbook)
- **ulta-intel** (mass+prestige scaling model)

### OPERATIONS — 12 skills
- **flutter-app** (Dart, APK, Liquid Glass UI)
- **local-delivery** (R75 1-hour, EasyRoutes, 6-bike fleet)
- **klaviyo-platform** (flow setup, segments, templates)
- **retention** (CRM/email/SMS/WhatsApp strategy + churn/win-back/loyalty)
- **cart-recovery** (Klaviyo flows)
- **cro-engine** (page conversion)
- **customer-experience** (Bestie chatbot, NPS, returns scripts)
- **whatsapp-commerce** (96% SA penetration)
- **influencer-ops** (Bestie Squad, SA UGC R500-R2K)
- **ugc-management** (Judge.me, content rights)
- **loyalty-redesign** (Toki Pay-as-you-Go selected, replaced OneLoyalty)
- **webapp-testing** (Playwright competitor scraping, pixel verification)

### PRICING / FINANCIALS — 3 skills
- **pricing-promotions** (margin math, bundle econ)
- **discount-strategy** (when/whether to discount)
- **financial-intel** (store P&L, MER, CAC ceilings)

### COMPLIANCE — 3 skills
- **legal-compliance** (SAHPRA, ad policy)
- **privacy-compliance** (POPIA, skin analysis data)

### PRODUCT / INVENTORY — 3 skills
- **inventory-demand** (1,400+ SKUs, K-beauty 6-12wk lead times)
- **product-merchandising** (K-beauty buying, SA brand assortment)
- **returns-management** (beauty-specific reasons)

### PEOPLE / ASSETS — 3 skills
- **staff-training** (skin analysis SOP, 6 stores)
- **brand-visual-guidelines** (3-brand color/typography)
- **web-assets** (favicons, OG images, GBP covers)

### LIBRARY HEALTH — 1 skill
- **skill-health** (120-point rubric in references/scoring-rubric.md, library maintenance)

### CONTINUITY — 2 skills
- **session-handoff** ("continue where we left off")
- **chat-handoff** (bare keyword "handoff")

## DISAMBIGUATION TABLE

| Query signal | Use this | NOT this |
|---|---|---|
| POS, in-store, till, hardware | shopify-pos | shopify |
| Delivery, riders, EasyRoutes, dispatch | local-delivery | shopify |
| Klaviyo flow setup, segments, templates | klaviyo-platform | retention |
| Email/SMS/WhatsApp strategy, lifecycle | retention | klaviyo-platform |
| Should we discount? Which mechanism? | discount-strategy | pricing-promotions |
| Margin math, markup, bundle econ | pricing-promotions | discount-strategy |
| Tax / SARS / VAT / CGT | (native — phantom skill) | financial-intel |
| Current P&L, store unit economics | financial-intel | (financial-modeling deleted) |
| Secret Skin PPC counter-moves | counter-ppc | sa-competitive-scanner |
| Secret Skin SEO counter-moves | counter-seo | seo-content |
| OneLoyalty replacement, points | loyalty-redesign | retention |
| TikTok content / short-form | tiktok | meta-creative-testing |
| Influencer ops, rates, contracts | influencer-ops | meta-creative-testing |
| Pause/keep ad campaign | bleeder-detection FIRST | (any other) |
| Score this skill / 120-point rubric | skill-health (refs) | (deleted: skill-judge) |
| SA agency Google Ads playbook | google-ads (refs) | (deleted: google-ads-playbook) |
| Meta UGC framework / SA UGC sourcing | meta-creative-testing (refs) | (deleted: meta-ads-playbook) |

## VERIFICATION RULES

- Before delivering ANY file/zip/code/prompt → ship-it-right-first-time
- Before IRREVERSIBLE changes → challenge-verify
- Before factual claims in unfamiliar territory → research-mode
- Before continuing previous session work → session-handoff

## ROUTING PROTOCOL

1. Read query.
2. Identify task category.
3. Check disambiguation table for collisions.
4. Load required bundle + any deep-dive skills.
5. Always include relevant discipline-layer skills.
6. Execute with selected skills loaded.

When unsure, default to the more specific skill. When two seem equal, load both. Never substitute training knowledge for skill content.
