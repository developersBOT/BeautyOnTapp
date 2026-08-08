---
name: beautyontapp-ship-it-right-first-time
description: Prevents the failure pattern where Claude ships a deliverable, then T asks "are there any issues?" or "audit this" and Claude finds problems it should have caught before shipping. Use this skill BEFORE every file delivery, theme zip, Chrome dispatch, schema, Liquid edit, ad copy, email, prompt, or document. Make sure to invoke this skill whenever Claude is about to call present_files, deliver code, send a zip, or output a final deliverable. The user has been burned repeatedly by Claude finding "concerns" or "gaps" only after being asked to audit — those issues were always there, Claude just didn't check first. This skill makes Claude do that check BEFORE shipping, not after.
license: MIT
---

# Ship It Right The First Time

Before shipping ANY deliverable, you run the same audit T would run if asked. The audit happens BEFORE the file goes out, not after T asks for it.

## The failure pattern this skill prevents

1. T asks for X
2. Claude builds X
3. Claude ships X
4. T asks "is X clean?" or "audit X"
5. Claude finds issues it should have caught before shipping
6. T is annoyed because Claude wasted a turn

These issues were ALWAYS there. Claude just didn't check before shipping. That's the bug.

## The pre-ship audit (mandatory)

Before calling `present_files`, sending a zip, delivering code, or outputting a final document — run this self-check silently:

1. **Did I do what was asked?** Re-read T's most recent instruction. Did the deliverable match it word-for-word? If T said "update the theme I sent you," did I work on T's file or my old working copy?
2. **Is the deliverable internally consistent?** JSON parses, Liquid renders, schemas validate, code compiles, links resolve, file paths exist, references match.
3. **Are there known issues I haven't addressed?** If I'm aware of issues from earlier in this conversation that affect the deliverable, are they fixed or explicitly deferred with reason?
4. **Did I preserve the user's prior work?** If T sent me a file that already had fixes, did the deliverable preserve every one of them? Did I diff before shipping?
5. **Is anything in the deliverable that T didn't ask for?** No bonus changes, no "while I was here" edits, no scope creep.
6. **Could T's next message reasonably be "audit this"?** If yes, run the audit NOW and either fix what it would find or flag it explicitly in the delivery message.

If any check fails: fix it BEFORE shipping. Do not ship and apologize later.

## What goes in the delivery message

After running the pre-ship audit, the delivery message states:
- What was changed (1 line per change)
- What was preserved from prior work (1 line)
- Anything deliberately deferred and why (only if applicable)

Nothing else. No "let me know if you spot issues" — if there are issues, find them yourself first.

## Hard rules

- **No "concerns" or "gaps" sections AFTER shipping** unless T explicitly asks.
- **No "I noticed X but didn't fix it" lists** — fix it or don't mention it.
- **No "want me to audit this?" follow-ups** — you already did.
- **If you find an issue mid-build, fix it before shipping**, don't note it for later.
- **If a file you sent earlier had bugs, the next ship MUST resolve them**, not surface them as new findings.

## Recovery when this skill fails

If T calls out a missed issue after you ship:
1. Acknowledge once, briefly.
2. Fix it.
3. Do NOT explain why you missed it.
4. Do NOT promise to do better next time — just do better next time.

The goal is zero post-ship audits requested by T. Every deliverable should ship audit-clean.
