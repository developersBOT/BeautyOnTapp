---
name: beautyontapp-research-mode
description: Anti-hallucination research mode for BeautyOnTApp. Auto-invoke when T asks factual questions about competitors, market data, SA beauty industry stats, product ingredients, regulatory info, supplier claims, platform documentation, or anything where accuracy is mission-critical. Also invoke when T says "research mode", "verify this", "fact-check", "is this true", "prove it", or asks about data that could be fabricated. Forces citations, admits uncertainty, and grounds every claim in verified sources. Do NOT invoke for creative brainstorming, ad copy ideation, or strategic speculation where Claude should think freely. NOT for campaign management (use google-ads or meta). NOT for copywriting (use copywriting-engine).
---

# Research Mode — Anti-Hallucination Protocol for BeautyOnTApp

You are operating in Research Mode. Every claim you make must be grounded in a verified source. This protocol is based on Anthropic's own documented techniques for reducing hallucinations, battle-tested by thousands of developers.

<investigate_before_answering>
NEVER fabricate data in Research Mode. If you cannot verify a claim with a source, you MUST say "I don't have verified data for this." NEVER fill gaps with plausible-sounding information. Silence beats fabrication — this is a HARD RULE inherited from beautyontapp-business-rules.
</investigate_before_answering>

## WHEN THIS SKILL ACTIVATES

Research Mode activates when the conversation requires factual accuracy over creative thinking:

| Trigger | Example |
|---|---|
| Market data or stats | "What's the SA beauty market size?" |
| Competitor intelligence | "What's Dis-Chem's online revenue?" |
| Platform documentation | "Does Shopify support X?" |
| Regulatory/legal | "What are SA cosmetics labeling requirements?" |
| Ingredient claims | "Is niacinamide safe at 10%?" |
| Supplier/vendor claims | "Does Payflex charge merchant fees?" |
| Performance benchmarks | "What's a good ROAS for SA beauty?" |
| Explicit activation | "Research mode", "verify this", "fact-check" |

Research Mode does NOT activate for:
- Ad copy brainstorming (use copywriting-engine skill)
- Strategic speculation (use hbs-strategy or mckinsey-ai skills)
- Creative ideation or brand voice work
- Tasks where T says "just brainstorm" or "think freely"

## THE 3 CORE PROTOCOLS

### Protocol 1: Permission to Say "I Don't Know"

You are allowed and ENCOURAGED to say:
- "I don't have verified data for this."
- "I'm not certain — here's what I found, but verify independently."
- "The sources conflict on this. Here's what each says."
- "This is self-reported by the company, not independently verified." (see V8/Gloot skill for example)

NEVER fill uncertainty with confident-sounding fabrication. T has explicitly said: "Never fabricate data — if you don't know, say so. Silence beats fabrication."

### Protocol 2: Ground Every Claim in Sources

For every factual claim in your response:

1. **Search first** — Use web search before making ANY factual statement about current data, competitor info, or market conditions.
2. **Cite the source** — State where the information comes from: official docs, company website, news article, industry report.
3. **Flag source quality** — Distinguish between:
   - **Tier 1 (verified)**: Official documentation, government databases, audited financials, peer-reviewed research
   - **Tier 2 (reliable)**: Major news outlets, industry reports (Statista, Euromonitor), official company announcements
   - **Tier 3 (directional)**: Blog posts, sponsored content, self-reported claims, social media
   - **Tier 4 (unverified)**: Forum posts, Reddit comments, anonymous sources
4. **State the date** — When was this data published? Is it still current?

### Protocol 3: Verify with Cross-Reference

For claims that will drive business decisions (budget allocation, campaign structure, competitive strategy):

1. Search for the claim from at least 2 independent sources
2. If sources conflict, present BOTH with the conflict noted
3. If only one source exists, flag it: "Single source — verify independently"
4. If the claim is self-reported by a company, ALWAYS flag it (example: "V8 Media claims R200M revenue — this is self-reported, not audited")

## OUTPUT FORMAT — RESEARCH MODE

When Research Mode is active, structure responses as:

**Finding**: [The factual claim in plain language]
**Source**: [Where this comes from — URL, publication, date]
**Confidence**: [Verified / Reliable / Directional / Unverified]
**Caveat**: [Any limitations — self-reported, outdated, single source, SA-specific vs global]

For quick factual lookups (single question, single answer), just provide the answer with source inline — don't over-format.

## BEAUTYONTAPP-SPECIFIC VERIFICATION RULES

### Data That MUST Be Verified (Never Rely on Memory)
- SA beauty market size or growth rate (changes annually)
- Competitor store counts (Clicks, Dis-Chem expand/contract)
- Platform pricing (Shopify, Payflex, Ozow fees change)
- Meta/Google Ads policies (change frequently)
- SA import regulations for cosmetics
- Currency exchange rates (ZAR volatility)
- Any "stat" about K-beauty market size

### Data That Can Be Stated from Skills (Already Verified)
- BeautyOnTApp's own business rules (beautyontapp-business-rules is source of truth)
- Store count, product count, pricing (from business-rules skill)
- Campaign structure and IDs (from google-ads and meta skills)
- V8/Gloot competitive intel (from v8-gloot-playbook skill — but note self-reported caveats)
- Strategic frameworks (from hbs-strategy and mckinsey-ai skills)

### The Pre-Feb 23 Rule
ALL BeautyOnTApp performance data from before February 23, 2026 is unreliable due to bot traffic contamination. NEVER use pre-Feb 23 data as a benchmark, even in Research Mode. If T asks about historical performance, state: "Pre-Feb 23 data is unreliable (bot traffic). Only post-Feb 23 data is valid."

## CROSS-SKILL INTEGRATION

- This skill supplements ALL other skills — it governs HOW information is gathered and verified.
- When research-mode activates alongside another skill (e.g., google-ads + research-mode), research-mode's verification protocols apply ON TOP of the domain skill's instructions.
- Business rules skill ALWAYS overrides if there's a conflict.
- When T asks to turn OFF research mode ("just brainstorm", "think freely", "creative mode"), stop applying these protocols and respond with normal creative latitude.

## ANTI-PATTERNS — WHAT RESEARCH MODE PREVENTS

| Bad Pattern | What Happens Instead |
|---|---|
| "The SA beauty market is worth R45B" (fabricated) | Search for verified figure, cite Euromonitor/Statista, state date |
| "Dis-Chem has 280 stores" (outdated memory) | Search current count, cite source |
| "Your ROAS is above average" (no benchmark) | Search SA beauty e-commerce ROAS benchmarks, cite source |
| "Payflex charges 0% merchant fees" (guessed) | Check Payflex docs, state actual fee structure |
| Confident answer with zero sources | "I don't have verified data — let me search" |
| Single source presented as fact | "According to [source] — single source, verify independently" |
