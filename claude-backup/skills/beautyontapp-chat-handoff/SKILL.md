---
name: beautyontapp-chat-handoff
description: Generates a structured session-handoff summary that transfers context from the current BeautyOnTApp chat to a new Claude session without losing business-critical specifics. Produces a single copy-paste block with five fixed sections (Core context, Key decisions, Business specifics, What's pending, Tone and style), bullets only, no preamble or sign-off. Activate ONLY on the explicit keyword command — "handoff", "handoft" (common typo), "/handoff", "/Handoff", or any case variation of the literal word. Do NOT activate on broader session-continuity phrases like "save progress", "wrap up for now", "continue where we left off", "what were we working on", or "summarize what we did" — those route to beautyontapp-session-handoff instead. This skill is the keyword-triggered copy-paste export format; beautyontapp-session-handoff is the narrative session-continuity protocol. Treat the bare word "handoff" as sufficient trigger signal on its own.
---

# BeautyOnTApp Chat Handoff

Emits a clean, copy-paste session summary for transferring context to a new Claude chat within the PNCapital skill library. Output replaces all normal conversational formatting. Preserves business-critical specifics (account IDs, campaign names, numbers, tools, skills invoked) that generic handoff formats would strip.

## When to activate

Activate on explicit keyword match only, case-insensitive, with or without leading slash:

- `handoff`
- `handoft` (common typo)
- `/handoff`
- `/Handoff`
- "handoff summary" / "give me a handoff" / "generate a handoff"

**Do NOT activate on** (these route to `beautyontapp-session-handoff` instead):
- "save progress", "wrap up for now", "save this chat"
- "continue where we left off", "what were we working on", "pick up from last time"
- "summarize what we did", "what's left to do"
- Any phrasing focused on session continuity rather than the literal keyword command

When triggered, do not ask clarifying questions. Do not acknowledge the command. Emit the handoff block directly.

## Output format

Emit exactly this structure. No text before, no text after.

```
Handoff summary

1. Core context
- [bullet]
- [bullet]

2. Key decisions
- [bullet]
- [bullet]

3. Business specifics
- [bullet]
- [bullet]

4. What's pending
- [bullet]
- [bullet]

5. Tone and style
- [bullet]
```

## What goes in each section

1. **Core context** — The main goal, project, or problem driving this chat. What is T actually trying to accomplish?

2. **Key decisions** — Specific preferences, constraints, facts, or rulings T established in this chat that must carry forward. Include explicit rejections ("T said X won't work", "T overrode Y").

3. **Business specifics** — The hard facts that matter for BeautyOnTApp operations. Include verbatim where mentioned:
   - Account IDs touched (e.g., Google Ads 820-452-9325 / 851-084-2703, Meta Pixel, Merchant Center)
   - Campaign names referenced (e.g., KS_C8_Brand_Protection, PMax_BeautyOnTApp, Shopping_All_Products_v2)
   - Brands in scope (BeautyOnTApp / Pastry Skincare / Mzuri Skin / other PNCapital brand)
   - Stores referenced (Gateway Umhlanga, Fourways, Mall of Africa, Menlyn, Sandton, Canal Walk)
   - Numbers: budgets (R/day, R/month), CPA, ROAS, MER, order counts, conv counts
   - Tools surfaced or used (Screaming Frog, Semrush, Ahrefs, Meta Ad Library, Analyzify v4, Simprosys)
   - Skills invoked or overridden in this chat
   - Apps, dates, URLs, file names, SKUs, product handles mentioned
   - If none of the above was discussed: `- None established in this session`

4. **What's pending** — The very next task, the unanswered question, the thing mid-execution. Include any blocker or waiting-on.

5. **Tone and style** — How T has been communicating in THIS specific chat (observed, not prescriptive). Example: "direct and terse", "technical with numbers-heavy feedback", "iterating on wording".

## Hard rules

- Bullets only inside each section. No prose paragraphs, no sub-headers, no numbered lists within sections.
- No hallucination. Every bullet must come from something explicitly said or decided in THIS chat. If a section has no content, write: `- None established in this session`.
- No filler. No "Here's your handoff", no "Hope this helps", no "Let me know if you need changes", no emoji, no sign-off.
- No meta-commentary. Do not explain what the handoff is or what each section does.
- Single clean block. One output, ready to copy and paste into a new chat.
- Keep bullets tight. One fact per bullet. No explanations tacked on.
- **Preserve specifics verbatim.** Account IDs, campaign names, numbers, URLs, file names, deadlines — exact values, never generalized.
- Section 5 is observed tone, not prescriptive.
- Do NOT restate T's stored memory, userPreferences, or skill library contents — only what was discussed in THIS chat.

## Anti-patterns

- Padding thin sections with inferred content
- Summarizing business specifics into vague phrasing ("discussed some campaigns" instead of naming them)
- Restating the userPreferences file or skill router — only what was discussed in THIS chat
- Adding a "Next steps" or "Recommendations" section
- Wrapping output in explanatory prose
- Using markdown headers (##, ###) instead of the numbered format
- Ending with "Want me to adjust anything?" or similar
- Activating on session-continuity phrases that belong to beautyontapp-session-handoff
