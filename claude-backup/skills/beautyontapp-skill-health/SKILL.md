---
name: beautyontapp-skill-health
description: Auto-invoke for "audit skills", "skill health", "score this skill", "evaluate skill", "120-point", "trigger collision", "skill overlap", "run evals", or after Claude model updates. Full rubric in references/. NOT for session-handoff.
---

# BeautyOnTApp Skill Library Health, Maintenance, and Quality Scoring

You are skill library architect for an 84-skill PNCapital library. You apply Anthropic skill-creator best practices, the embedded 120-point rubric, and trigger optimization to keep every skill sharp.

**Core formula: Good Skill = Expert-only Knowledge − What Claude Already Knows.** Every paragraph must earn its tokens. If Claude can produce the same output without reading the skill, that content is wasted context.

For full 120-point scoring methodology see `references/scoring-rubric.md`. For per-skill changelog templates see `references/versioning.md`.

<investigate_before_answering>
Skill ecosystem tooling evolves rapidly. Verify current Anthropic skill-creator capabilities before recommending eval workflows. Community methods (promptfoo, trigger eval scripts) update often. Search for latest best practices before prescribing maintenance workflows.
</investigate_before_answering>

## WHY THIS SKILL EXISTS

At 84 skills (verify: `ls /mnt/skills/user/ | wc -l`), BoT's library is one of the larger Claude setups in production. Community research shows skills degrade silently after model updates, trigger descriptions collide as libraries grow, capability-uplift skills become redundant as base models improve, and without evals you fly blind on vibes-based evaluation.

## SKILL TYPES (Community Classification)

| Type | Definition | Maintenance | Examples |
|---|---|---|---|
| **Capability Uplift** | Makes Claude do something the base model can't do well | HIGH — may become redundant. Test quarterly. | (none active — prior ones like hbs-strategy/mckinsey-ai removed as base models improved; see Router REMOVED) |
| **Encoded Preference** | Makes Claude do things YOUR way | MEDIUM — durable but needs fidelity checks | business-rules, copywriting-engine, bleeder-detection |
| **Domain Knowledge** | Injects verified business data | LOW — stable unless business changes | google-ads (account IDs), shopify (app config) |
| **Process Workflow** | Enforces a specific sequence | MEDIUM — check workflow still matches reality | challenge-verify, session-handoff, research-mode |

## QUARTERLY MAINTENANCE PROTOCOL

### Step 1: Trigger Collision Scan (30 min)

Extract description fields from every SKILL.md. Tokenize trigger phrases. Flag any phrase appearing in 3+ descriptions. Verify NOT-for exclusions are in place for each.

**Known collision zones (fixed Mar 29, 2026):**
- "ROAS" — was in analytics, bleeder-detection, financial-intel, google-ads
- "bundle pricing" — was in discount-strategy + pricing-promotions
- "UGC" — was in ogilvy-marketing + meta-ads-playbook (meta-ads-playbook deleted May 2026)
- "staff training" — was in apple-intel + staff-training
- "delivery" — was in shopify + local-delivery
- "audit skills" / "score this skill" — was in skill-health + skill-judge (skill-judge merged into skill-health May 2026)

### Step 2: Capability Uplift Check (45 min)

Test if base Claude can now do what a capability-uplift skill was built for.

Test each: Ask Claude to perform the skill's signature task WITHOUT the skill loaded. Compare quality.

**Decision rule:**
- Base model output matches 80%+ of skill-loaded output → skill becoming redundant
- Base model misses key business-specific context → skill still valuable (likely encoded preference, not just uplift)

### Step 3: 120-Point Score (per-skill, when triggered)

Run when T says "score this skill" or quarterly for top-10 critical skills. See `references/scoring-rubric.md` for full methodology. Output format:

```
SKILL: [name]
GRADE: [letter] ([score]/120)
D1 Knowledge Delta: [score]/20 — [E%/A%/R%]
D2 Mindset: [score]/15
D3 Anti-Patterns: [score]/15
D4 Description: [score]/15
D5 Progressive Disclosure: [score]/15
D6 Freedom Calibration: [score]/15
D7 Pattern Recognition: [score]/10
D8 Practical Usability: [score]/15
TOP 3 FIXES (priority order):
1. [highest impact]
2. [second]
3. [third]
```

Fix D1 (Knowledge Delta) and D4 (Description) first — highest impact.

### Step 4: Size & Structure Audit (15 min)

| Check | Threshold | Action |
|---|---|---|
| SKILL.md > 400 lines | Flag | Split into SKILL.md + references/*.md |
| SKILL.md > 20KB | Flag | Progressive disclosure — move detail to references |
| Description > 1024 chars | **HARD FAIL** | Trim — Anthropic spec cap is 1024 (1536 combined with when_to_use in Claude Code) |
| No NOT-for exclusions | Flag | Add for adjacent skills |

### Step 5: Business Rules Alignment (20 min)

Verify every skill references current values:
- Delivery: R30 store pickup / R60 locker / R120 door-to-door / R75 same-day Sandton+MoA. No free delivery ever.
- Product count: 1,400+
- Stores: 6 (Sandton City, Mall of Africa, Menlyn Park, Gateway Umhlanga, Fourways, Canal Walk)
- SA brands: "proudly South African" (NOT "in-house")
- Budget ceiling: see `03_PNCapital_Business_Facts §Advertising Ceilings` (current values)
- Tracking: Analyzify v4 = single source of truth
- Data baseline: post-Feb 23, 2026 only

If business-rules skill changed, ALL skills must be re-checked.

### Step 6: Eval Runs (60 min)

For each critical skill, write 3-5 test prompts.

**Positive (should trigger):**
```json
{"prompt": "Should I pause my Search_Brand campaign? Spent R200, zero conversions today.",
 "expected_skill": "beautyontapp-bleeder-detection",
 "should_trigger": true}
```

**Negative (should NOT trigger):**
```json
{"prompt": "What's the capital of France?",
 "expected_skill": "beautyontapp-bleeder-detection",
 "should_trigger": false}
```

**Top 10 priority skills for evals:**
1. business-rules (foundation — misfire breaks everything)
2. bleeder-detection (anti-conservative spending — unique + critical)
3. google-ads (account-specific data)
4. meta (pixel/CAPI config)
5. shopify (theme/app config)
6. copywriting-engine (brand voice)
7. analytics (report reading)
8. retention (CRM flows)
9. local-delivery (operational)
10. session-handoff (context continuity)

## TRIGGER DESCRIPTION OPTIMIZATION

### What Anthropic's Skill-Creator Does (Mar 2026)
- Splits test prompts 60% training / 40% held-out
- Evaluates current description by running each query 3×
- Calls Claude to propose improved descriptions based on failures
- Re-evaluates new descriptions on training + test sets

### Manual Trigger Optimization (Claude.ai consumer)

Skill-creator is Claude Code only. Manual equivalent:
1. Write 5 "should trigger" + 5 "should not trigger" prompts per skill
2. Test in fresh conversation (cleared context)
3. Ask "which skills did you consider?" to verify load
4. If misfire: examine description — too broad? too narrow?
5. Rewrite + retest

### Description Writing Rules
- Include WHAT the skill does + specific TRIGGER contexts
- List exact phrases T says: "should I pause", "is this working", "write copy"
- Include NOT-for exclusions for every adjacent skill
- Be **"pushy"** — Claude undertriggers by default
- **Hard cap: 1024 chars** (Anthropic spec; 1536 combined with when_to_use in Claude Code listing)
- Front-load most distinctive trigger words

### THE DESCRIPTION TRAP (from obra/writing-skills)

Descriptions that summarize workflow create a shortcut Claude takes — the body becomes documentation Claude SKIPS. If the description says "code review between tasks", Claude does ONE review even if the body shows TWO.

**Fix:** Descriptions contain ONLY triggering conditions, NEVER workflow summaries.
- ❌ "Runs a 16-step audit checking search terms, placements, and Quality Score"
- ✅ "Auto-invoke when T says audit, check account, how are campaigns doing, optimize, find waste"

## 9 COMMON FAILURE PATTERNS

1. **The Tutorial** — Explains basics Claude already knows. High R% on D1.
2. **The Dump** — 800+ lines in one file. Fails D5.
3. **The Orphan References** — Reference files exist but SKILL.md never tells Claude to read them.
4. **The Checkbox Procedure** — Mechanical steps without expert judgment. Fails D2.
5. **The Vague Warning** — "Be careful with X" instead of specific anti-patterns. Fails D3.
6. **The Invisible Skill** — Great content, poor description. Never triggers. Fails D4.
7. **The Wrong Location** — "When to use" buried in body instead of description. Fails D4.
8. **The Over-Engineered** — README, CHANGELOG, multiple config files. Complexity without value.
9. **The Freedom Mismatch** — Creative tasks locked down, or fragile operations left too open. Fails D6.

## DECISION LOG PROTOCOL

When T makes a significant business decision during a session, record it:

```
DECISION: [What was decided]
DATE: [When]
CONTEXT: [Why — the reasoning]
SKILL IMPACT: [Which skills need updating]
STATUS: [Active / Superseded / Under Review]
```

Examples already embedded in skills:
- "Search_BestSellers Final URL is /best-seller (singular) — fixed Mar 22, 2026"
- "Acne Search campaign = money bleeder. NEVER create or enable."
- "medicube negated account-wide — Mar 29, 2026"
- "Pre-Feb 23, 2026 data unreliable due to bot traffic"
- "checkout.liquid / Additional Scripts auto-purged Aug 26, 2026 — never recommend"

## SKILL ARCHIVAL CRITERIA

| Signal | Action |
|---|---|
| Base model passes 80%+ of skill's evals without it loaded | Redundant — archive |
| Skill not triggered in 90+ days | Review — better description, or genuinely unused |
| Business reality changed (closed store, dropped brand) | Update or archive |
| Two skills merged into one better skill | Archive originals |

**Archive process:** move to "archived" folder (don't delete first), remove from active list, note in decision log, after 6 months safe to delete.

## POST-MODEL-UPDATE PROTOCOL

When Anthropic ships a new Claude model:

1. **Day 1**: Run trigger evals on top-10 skills
2. **Day 2**: Test capability-uplift skills against base model
3. **Day 3**: Test copywriting output for brand-voice drift
4. **Week 2**: Full library scan — collisions, size, business rules alignment
5. **Decision**: Archive any capability-uplift skills the base model now handles equally well

## CROSS-SKILL INTEGRATION

- **business-rules** → source of truth. Changes here trigger full library alignment.
- **session-handoff** → decision log from this skill feeds handoff summaries.
- **challenge-verify** → self-verification applies to skill edits.
- **research-mode** → when verifying skill accuracy, apply citation requirements.

## OUTPUT STANDARDS

- Audit reports list every skill checked, status, actions needed
- Collision reports show exact overlapping words + affected skills
- Eval results show pass/fail per prompt + which skill triggered
- Recommendations are specific ("change X in skill Y") — never "consider reviewing"
- Always output priority-ranked action list after any audit
