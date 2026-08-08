---
name: beautyontapp-ai-max-search
description: AI Max for Search evaluation framework — Google's combined broad match + keywordless DSA + AI-generated text + Final URL expansion toggle. Make sure to use this skill whenever T asks about AI Max, AI Max for Search, broad match expansion, Google AI features for Search, DSA replacement, automatically created assets, Final URL expansion, keywordless targeting, or 'should I enable AI Max on Search campaigns'. Google claims 14% more conversions but practitioners report increased irrelevant queries — this skill provides the SA-beauty-specific evaluation framework. NOT for PMax (use ppc-audit-engine).

---

# AI Max for Search — Evaluation & Management

AI Max for Search launched globally in 2025 and is Google's fastest-growing AI product. It bundles four features into one toggle per Search campaign.

## WHAT AI MAX DOES (4 features in 1 toggle)

### 1. Broad Match Expansion
- All keywords behave as broad match regardless of original match type
- Google claims this captures queries you'd miss with exact/phrase
- Risk: irrelevant query volume increases significantly

### 2. Keywordless Targeting (DSA Replacement)
- Google crawls your website and serves ads for queries matching page content
- Replaces Dynamic Search Ads (DSA) which Google is sunsetting
- Risk: ads may serve for content pages (blog, About Us, FAQ) with no purchase intent

### 3. AI-Generated Ad Text
- Google auto-generates headlines and descriptions based on landing page content and query context
- These appear alongside your manually written assets
- Risk: off-brand messaging, inaccurate claims, missing brand guidelines (🖤, no free delivery mention)

### 4. Final URL Expansion
- Google chooses which URL to send traffic to, overriding your set landing page
- It selects the URL it predicts will convert best for each query
- Risk: traffic sent to blog posts, About Us, Terms & Conditions pages

## GOOGLE'S CLAIMS vs PRACTITIONER REALITY

| Claim | Source | Practitioner Reality |
|-------|--------|---------------------|
| 14% more conversions at similar CPA/ROAS | Google | Plausible for accounts with strong broad match history |
| 27% more conversions for exact/phrase-heavy accounts | Google | Higher gains reported when switching FROM tight match types |
| Lower CPA | Google | Mixed — CPA can spike during initial learning |

**Practitioner consensus (r/PPC, Search Engine Land, 2025-2026):**
- Query quality decreases — more irrelevant search terms
- Best for accounts with robust negative keyword lists and strong conversion signals
- Worst for accounts with thin conversion data, niche products, or strict brand guidelines
- Must be audited aggressively for query quality when enabled

## EVALUATION FRAMEWORK FOR BEAUTYONTAPP

### Should BeautyOnTApp Enable AI Max?

**Arguments FOR:**
- Account has strong conversion history (verify current 14-day conversion count meets Smart Bidding thresholds)
- SA CPC advantage means broader matching costs less to test
- Could capture long-tail K-beauty queries not in current keyword lists
- 1,400+ products means large URL surface for keywordless targeting

**Arguments AGAINST:**
- Strict brand guidelines (🖤 only, no free delivery, English only) conflict with AI-generated text
- Known problem brands (medicube waste, beautytap confusion) could be amplified
- KS_C8_Brand_Protection and Search_Brand have specific, validated keyword sets
- Final URL expansion could send traffic to blog/About pages with zero purchase intent
- "Revert over rebuild" principle — AI Max is a structural change

### RECOMMENDED APPROACH: Test on ONE campaign first

**Test Campaign:** Choose the lowest-risk non-brand Search campaign (lowest budget, weakest current performance — expendable if test fails)

**Test Protocol:**
1. Enable AI Max on Search_LocalBrands only
2. Set test duration: 14-21 days minimum
3. Monitor daily: search terms report for query quality
4. Compare: CPA, ROAS, conversion rate vs prior 14-day baseline
5. Watch for: irrelevant queries, off-brand auto-generated text, URL expansion to wrong pages

**Kill Criteria:**
- CPA increases >25% vs baseline after 14 days → disable
- >30% of search term spend going to irrelevant queries → disable
- Auto-generated ad text contains forbidden messaging (free delivery, Afrikaans, wrong brand claims) → disable immediately
- Final URL expansion sending >10% of clicks to non-commercial pages → disable URL expansion (can be turned off separately)

**Scale Criteria:**
- CPA at or below baseline after 21 days AND
- Conversion volume increased >10% AND
- Query quality acceptable (>70% of spend on relevant terms) AND
- No brand guideline violations
- → Enable on next campaign (Shopping_All_Products_v2)

### CAMPAIGNS TO NEVER ENABLE AI MAX ON

| Campaign | Reason |
|----------|--------|
| KS_C8_Brand_Protection | Brand defense requires exact control. AI Max would broaden to competitor brand queries. |
| Search_Brand | Same — brand queries require precision targeting. |

## AI MAX AUDIT CHECKLIST (when enabled)

Run weekly for any campaign with AI Max enabled:

1. **Search Terms Quality:** Download search terms → what % of spend goes to relevant queries?
2. **Auto-Generated Text Review:** Check Ads → are auto-created assets on-brand?
3. **Landing Page Report:** Are clicks going to the right pages? Check for blog/FAQ/About leakage
4. **Performance Comparison:** WoW comparison of CPA, ROAS, conversion rate vs pre-AI Max baseline
5. **Negative Keyword Coverage:** Are negatives sufficient to contain broad match expansion?

## INTERACTION WITH EXISTING FEATURES

- AI Max + PMax = OVERLAP RISK. Both use broad matching and URL expansion. If both are running, they compete and potentially cannibalize.
- AI Max replaces DSA — if any DSA campaigns exist, they should be migrated to AI Max or standard Search
- AI Max + Smart Bidding is mandatory — cannot use AI Max with Manual CPC

## 2025-2026 CONTEXT

- Google is pushing AI Max hard — it appears in Recommendations with inflated optimization scores
- Dismissing AI Max recommendation does NOT affect ad quality or delivery
- Google's "Power Pack" recommendation: Demand Gen + AI Max for Search + PMax. BeautyOnTApp currently runs PMax + Search + Shopping — Power Pack is not recommended without explicit testing.

## CROSS-SKILL INTEGRATION

| Skill | Relationship |
|-------|-------------|
| beautyontapp-ppc-audit-engine | AI Max adds new audit steps (query quality, auto-text, URL expansion) |
| beautyontapp-google-ads | Campaign-specific decision on where to enable |
| beautyontapp-bleeder-detection | AI Max can create new bleeders via broad match expansion |
| beautyontapp-copywriting-engine | AI-generated text must be checked against brand guidelines |
| beautyontapp-legal-compliance | AI-generated claims may violate SAHPRA or Google ad policy |
