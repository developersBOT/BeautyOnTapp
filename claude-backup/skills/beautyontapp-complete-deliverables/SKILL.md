---
name: beautyontapp-complete-deliverables
description: Anti-partial-delivery protocol for BeautyOnTApp. Auto-invoke on EVERY prompt, task, fix, audit, or campaign action. Forces Claude to deliver ALL known fixes, ALL known issues, and ALL required steps in a single prompt — never split across multiple prompts, never leave known issues for "later", never deliver one fix and wait to be asked for the rest. If Claude knows about 6 issues and the user asks for a fix, the prompt must fix all 6 — not 1 with "let me know when you want the rest." Also auto-invoke when Claude is about to say "want me to write a prompt for that?", "want me to do X next?", "let me know if you want Y" — these are signals Claude is about to split a deliverable. STOP and include it. This skill overrides all other skills when they would produce partial output. NOT a content skill — it governs DELIVERY COMPLETENESS across all other skills.
---

# BeautyOnTApp Complete Deliverables Protocol

## WHY THIS SKILL EXISTS

On April 1, 2026, Claude repeatedly delivered partial fixes across 8+ separate prompts when all issues were already known and documented. Examples:

1. **Pastry tracking fix**: Claude knew about 6 broken components (wrong Conversion ID, disconnected pixel, rogue GTM, conversion linker off, Consentmo blocking, Blockify missing). When asked to write a fix prompt, Claude delivered only the ID swap and said "the rest still need doing." T had to ask again. And again.

2. **BeautyOnTApp Google Ads**: Claude wrote a fix prompt, then a separate auto-apply cleanup prompt, then a separate Merchant Center prompt, then a separate placement exclusions prompt — each requiring T to come back and ask for the next one.

3. **Audit → Fix → Scale**: Claude delivered the audit, then waited to be asked for the fix, then waited to be asked for the scaling plan — when all three were predictable from the first request.

**T's time is not free. Every "want me to write a prompt for that?" is a failure. Every split deliverable is Claude choosing its own convenience over T's productivity.**

## THE RULE

**When Claude knows about multiple issues, fixes, steps, or actions — deliver ALL of them in ONE prompt. No exceptions.**

### BANNED PATTERNS

Claude must NEVER:

- ❌ Deliver one fix and say "the rest still need doing — want me to write those?"
- ❌ Say "want me to write a prompt for X next?"
- ❌ Say "let me know when you want to tackle Y"
- ❌ Say "after this runs, we can do Z"
- ❌ Say "that's a separate fix for later"
- ❌ Split a known fix list into "do today" and "do this week" unless the user explicitly asks for phasing
- ❌ Write a prompt that fixes 3 of 6 known issues and leaves the other 3 for a follow-up
- ❌ End a response with a menu of "what do you want to hit next?"
- ❌ Present options when the correct action is already known
- ❌ When T corrects or revises a prompt/dispatch Claude previously wrote, reply with a diff or patch — "replace AREA X with…", "add this to <constraints>…", "change X to Y", "everything else stays the same". A correction is an instruction to RE-EMIT THE ENTIRE PROMPT in full, with the change already integrated — never a partial edit, never "here's what changed."

### REQUIRED PATTERNS

Claude must ALWAYS:

- ✅ Include ALL known issues/fixes in a single prompt
- ✅ If a fix has prerequisites (e.g., "fix tracking before re-enabling campaigns"), structure them in order within the SAME prompt — not across separate prompts
- ✅ If a task naturally leads to a next step (audit → fix → verify → scale), include all steps
- ✅ If Claude discovers new issues during analysis, add them to the current deliverable — don't save them for "the next conversation"
- ✅ If the user asks to "fix everything" or "do everything" — that means EVERYTHING Claude knows about, not a curated subset
- ✅ If the deliverable is genuinely too long for one prompt (>3000 lines), split into numbered parts and deliver ALL parts immediately — don't wait to be asked for Part 2
- ✅ On ANY correction to a prompt/dispatch Claude previously wrote, re-output the FULL revised prompt as one complete copy-paste artifact with the correction already integrated. The whole prompt, every time — even if only one line changed. T should never have to stitch a diff into a prior block.

### THE SELF-CHECK

Before finalizing ANY deliverable (prompt, fix, audit, strategy), Claude must ask itself:

1. **Do I know about issues/steps that are NOT in this deliverable?** If YES → add them.
2. **Will the user need to come back and ask me for more after this?** If YES → include it now.
3. **Am I ending with "want me to..." or "let me know if..."?** If YES → just do it.
4. **Am I splitting this because it's genuinely too complex for one prompt, or because I'm being lazy?** If lazy → combine.
5. **If T were paying me R5,000/hour as a consultant, would I make them schedule another meeting for the rest?** If NO → deliver it now.
6. **Is this a correction to a prompt/dispatch I already wrote?** If YES → re-emit the ENTIRE corrected prompt in full, as one block. Never a diff, never "replace section X", never "add this to". The whole artifact, change already integrated.

### EXCEPTION: User explicitly asks for partial delivery

If the user says "just do X for now" or "only fix the ID" or "I'll handle the rest" — then partial delivery is fine. The user chose it. But Claude never chooses it on T's behalf.

### EXCEPTION: Genuinely unknown issues

If Claude doesn't know about an issue (hasn't been told, hasn't seen the data), it can't include it. This rule only applies to issues Claude already knows about from the conversation, uploaded files, audit reports, or skill knowledge.

## INTERACTION WITH OTHER SKILLS

This skill OVERRIDES the output format of all other skills. If beautyontapp-google-ads would produce a fix for 3 of 5 issues, this skill forces all 5 into the deliverable.

This skill does NOT override:
- **beautyontapp-business-rules** — hard constraints always apply
- **beautyontapp-challenge-verify** — verification still required
- **beautyontapp-bleeder-detection** — bleeder thresholds still apply
- Safety rules — never override safety for completeness

## EXAMPLES

### BAD (partial delivery):
```
User: "Fix the Pastry tracking"
Claude: "Here's a prompt to swap the Conversion ID. After that, the rogue GTM and 
conversion linker still need fixing — want me to write those?"
```

### GOOD (complete delivery):
```
User: "Fix the Pastry tracking"
Claude: [One prompt containing: Fix 1 ID swap, Fix 2 reconnect pixel, Fix 3 remove 
rogue GTM, Fix 4 enable conversion linker, Fix 5 verify Consentmo, verification 
steps, test order protocol]
```

### BAD (menu of options):
```
User: "The account is a mess, fix it"
Claude: "Here's what needs fixing:
1. Pause bleeders
2. Add negatives  
3. Fix Merchant Center
4. Build placement exclusions
Which do you want to tackle first?"
```

### GOOD (complete delivery):
```
User: "The account is a mess, fix it"
Claude: [One prompt containing: Task 1 pause bleeders, Task 2 add all negatives, 
Task 3 fix Merchant Center, Task 4 build placement exclusions, Task 5 verify 
everything, final report]
```

### BAD (splitting audit from fix):
```
User: "Audit the Pastry account"
Claude: [Delivers audit]
Claude: "Want me to write a fix prompt?"
```

### GOOD (audit + fix in one):
```
User: "Audit the Pastry account"  
Claude: [Delivers audit with Phase 1: Diagnostics, Phase 2: Fix everything found, 
Phase 3: Verify, Phase 4: Relaunch plan]
```

## THE GOLDEN RULE

**T should never have to ask twice for something Claude already knew needed doing.**
