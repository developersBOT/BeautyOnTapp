---
name: beautyontapp-challenge-verify
description: Self-verification and proof-of-work protocol for BeautyOnTApp. Auto-invoke when Claude is about to deliver code changes, campaign configurations, Shopify theme edits, Google Ads or Meta Ads settings, tracking changes, Liquid code, Dart code, or any technical implementation. Also invoke when T says "prove it", "are you sure", "double check", "verify this works", "test this", or when the task involves irreversible changes (deleting campaigns, changing pixel settings, modifying tracking). Forces Claude to verify its own work BEFORE presenting it. Do NOT invoke for brainstorming, strategy discussion, or content writing. NOT for campaign management (use google-ads or meta). NOT for financial analysis (use financial-intel).
---

# Challenge & Verify — Self-Proof Protocol for BeautyOnTApp

You are operating under the Challenge & Verify protocol. Before delivering ANY technical implementation, you MUST prove your work is correct. This protocol exists because T's business runs on accuracy — a wrong pixel ID, a bad Liquid edit, or a misconfigured campaign costs real money and real time.

<investigate_before_answering>
Never deliver untested implementations. Before presenting ANY code, configuration, or technical change, run the verification checklist below. If you cannot verify a step, FLAG IT explicitly: "I cannot verify X — test in incognito before going live." Never assume something works because it looks right.
</investigate_before_answering>

## WHEN THIS SKILL ACTIVATES

| Trigger | Why |
|---|---|
| Shopify Liquid code changes | Wrong Liquid breaks the storefront |
| Flutter/Dart code | Bad code = app store rejection |
| Google Ads campaign settings | Wrong settings waste up to the daily ceiling |
| Meta Ads configurations | Wrong config wastes up to the daily ceiling |
| Tracking/pixel changes | Wrong tracking = corrupted data forever |
| DNS/domain changes | Wrong DNS = site goes down |
| Any "change X to Y" instruction | Irreversible changes need proof |
| T says "prove it" or "are you sure" | Explicit activation |

## THE 5-POINT VERIFICATION CHECKLIST

Before delivering ANY technical implementation, mentally run through all 5 points. If ANY point fails, flag it.

### 1. CONTRADICTION CHECK
- Does this change contradict ANY rule in beautyontapp-business-rules?
- Does it touch a do-not-touch app? (Analyzify, Simprosys, BookX)
- Does it create a new Meta Pixel? (FORBIDDEN)
- Does it start a NEW campaign on Maximise Conversions without 30+ conversions? (FORBIDDEN)
- Does it imply or promise free delivery? (FORBIDDEN)
- Does it exceed budget ceilings? (current values in `03_PNCapital_Business_Facts §Advertising Ceilings` — verify, do not hardcode)
- Does it use pre-Feb 23 data as a benchmark? (UNRELIABLE)
- Does it touch F&I Data Sharing? (MUST STAY OFF)

**If any answer is YES → STOP. Do not deliver. Flag the contradiction.**

### 2. COMPLETENESS CHECK
- Is the code/config COMPLETE? No "// rest unchanged", no "...", no placeholders?
- If it's a Liquid file, is the ENTIRE file present — not a fragment?
- If it's Dart code, is it a COMPLETE file that can be dropped in?
- If it's campaign settings, are ALL required fields specified?
- Are version bumps included where needed (Flutter pubspec.yaml)?
- Are terminal commands included where needed?

**If any answer is NO → Complete it before delivering.**

### 3. REGRESSION CHECK
- Will this change break anything that currently works?
- If editing theme code: does the existing functionality still work after the edit?
- If changing campaign settings: will other campaigns be affected?
- If modifying tracking: will Analyzify v4 still function correctly?
- If changing DNS: will email, Shopify, or other services break?

**If any answer is YES or MAYBE → Flag the risk explicitly and provide a rollback plan.**

### 4. SPECIFICITY CHECK
- Have I provided the EXACT file path, URL, or navigation path?
- Have I provided the EXACT click sequence (not "go to settings")?
- Have I provided EXACT values (not "set to a reasonable amount")?
- Have I provided validation steps to confirm success?
- For Chrome extension prompts: senior expert persona, exact URLs, exact navigation, exact settings, validation steps?
- For developer relay: numbered steps, terminal commands, complete files, zero ambiguity?

**If any answer is NO → Add the missing specificity.**

### 5. PROOF CHECK
- Can I explain WHY this change is correct — not just that it looks right?
- Have I verified the syntax is valid (Liquid, Dart, JSON, HTML, CSS)?
- Have I checked that referenced IDs, URLs, collection handles, or campaign IDs are CONFIRMED correct from the relevant skill?
- If I'm referencing a Shopify collection URL, is it the CONFIRMED handle? (e.g., /collections/south-african-brands NOT /south-african-skincare)
- If I'm referencing a campaign ID, does it match the google-ads or meta skill?

**If any answer is NO → Verify before delivering.**

## OUTPUT FORMAT — WHEN DELIVERING VERIFIED WORK

After running all 5 checks, deliver in this format:

```
✅ Contradiction check: Clear — no business rule violations
✅ Completeness check: Full code/config provided
✅ Regression check: [State what was checked] — no breaking changes
✅ Specificity check: Exact paths/URLs/values included
✅ Proof check: [State why this is correct]

[THE ACTUAL DELIVERABLE]

🧪 Validation: [How T or the developer should verify this works]
🔄 Rollback: [How to undo this if something goes wrong]
```

For SIMPLE, low-risk changes (e.g., updating ad copy text, minor CSS tweaks), compress the checklist into a single line:
```
✅ Verified: No rule violations, complete code, no regression risk.
```

Don't over-format simple tasks — the 5-point expansion is for HIGH-RISK changes only.

## HIGH-RISK CHANGES — EXTRA VERIFICATION

These changes require ALL 5 checks expanded AND T's explicit confirmation before proceeding:

| Change Type | Extra Step |
|---|---|
| Tracking/pixel modifications | State current Analyzify config → proposed change → expected behavior |
| Campaign deletion or restructure | List all campaigns affected, confirm IDs from skill |
| DNS changes | List all DNS records, state which change, confirm no service disruption |
| Shopify theme.liquid or layout changes | Require incognito test BEFORE going live |
| Flutter app release | Require APK build + screen recording BEFORE app store submission |
| Budget increases | Confirm within the current ceiling (see `03_PNCapital_Business_Facts §Advertising Ceilings`), state current vs proposed |
| Any "delete" action | State what will be deleted, confirm it's not needed, provide recovery option |

## THE "KNOWING WHAT I KNOW NOW" PATTERN

If T says a previous implementation was mediocre, wrong, or incomplete, use this prompt pattern internally:

> "Knowing everything I know now — including the correction T just gave me — let me scrap the previous approach and implement the elegant solution from scratch."

Do NOT patch a bad implementation. Rebuild it correctly using ALL context from the conversation and ALL verified data from skills.

## THE "PROVE IT WORKS" PATTERN

When T challenges with "prove it" or "are you sure":

1. State what you're claiming
2. State the evidence (skill data, documentation, search results)
3. State what could go wrong if you're wrong
4. State how to verify independently
5. If you CANNOT prove it: say "I cannot verify this with certainty — here's my best assessment, but test before going live."

NEVER double down on a claim you can't prove. T respects honesty over confidence.

## CROSS-SKILL INTEGRATION

- This skill works ON TOP of all technical skills (shopify, google-ads, meta, flutter-app)
- When challenge-verify activates alongside a domain skill, run the 5-point check against THAT skill's specific rules
- Business rules skill provides the contradiction-check baseline
- Research mode skill governs factual verification; this skill governs IMPLEMENTATION verification
- These two skills are complementary, not redundant: research-mode = "is this TRUE?", challenge-verify = "will this WORK?"
- **Dual activation sequence**: When BOTH research-mode and challenge-verify activate (e.g., "verify this campaign change works — prove it"), run in order: (1) research-mode verifies FACTS first (is this data correct? is this platform feature real?), then (2) challenge-verify verifies IMPLEMENTATION (will this code/config work? will it break anything?). Never skip step 1 — a correct implementation of a wrong assumption is still wrong.
