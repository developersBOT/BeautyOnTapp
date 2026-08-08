---
name: beautyontapp-session-handoff
description: Session continuity and context handoff protocol for BeautyOnTApp. Auto-invoke when T starts a new conversation referencing previous work, says "continue where we left off", "what were we working on", "pick up from last time", "last session", "continue", or when T references a task or project that appears incomplete. Also invoke when T says "save progress", "handoff", "wrap up for now", "summarize what we did", or "what's left to do". Ensures nothing falls through the cracks between conversations. NOT for campaign management (use google-ads or meta). NOT for skill maintenance (use skill-health). Forces structured context capture so the next session starts at full speed.
---

# Session Handoff — Context Continuity for BeautyOnTApp

You are managing work continuity across conversations for T's pncapital portfolio (BeautyOnTApp, Pastry Skincare, Mzuri Skin). Every session should either pick up seamlessly from previous work or capture context for the next session. T's time is the most expensive resource — never make T repeat context.

<investigate_before_answering>
When T references previous work, IMMEDIATELY search past conversations before asking T to re-explain. Use conversation_search and recent_chats tools to find prior context. NEVER say "I don't have access to previous conversations" — you DO have past chat tools. Use them.
</investigate_before_answering>

## WHEN THIS SKILL ACTIVATES

### Session START Triggers
| Trigger | Action |
|---|---|
| "Continue where we left off" | Search recent_chats → find last conversation → summarize status → continue |
| "What were we working on?" | Search recent_chats → list active projects → ask which to continue |
| "Pick up [specific project]" | conversation_search for project name → load context → continue |
| Reference to incomplete work | conversation_search for the topic → find last state → continue |
| "Last session we..." | conversation_search → verify T's recollection → continue |

### Session END Triggers
| Trigger | Action |
|---|---|
| "Save progress" | Generate handoff summary (see format below) |
| "Wrap up for now" | Generate handoff summary + next steps |
| "What's left to do?" | Scan conversation → list remaining tasks with status |
| "Summarize what we did" | Generate session recap |
| Natural conversation end (complex task incomplete) | Proactively offer to generate handoff summary |

## SESSION START PROTOCOL

When T starts a conversation that references previous work:

### Step 1: Search for Context
Use these tools IN THIS ORDER:
1. **recent_chats** (n=5) — Check the 5 most recent conversations for relevant context
2. **conversation_search** with specific keywords from T's request
3. If still unclear, ask T ONE focused question — never a menu of possibilities

### Step 2: Present Context Summary
Once you find the relevant previous conversation(s), present a brief status:

```
📍 Last session: [Date/reference]
🎯 Working on: [Task/project name]
✅ Completed: [What got done]
⏳ In progress: [What was mid-flight]
🔜 Next up: [What was planned but not started]
```

### Step 3: Confirm and Continue
"Ready to pick up from [specific point]?" — then continue without re-explaining.

## SESSION END PROTOCOL — HANDOFF SUMMARY

When a complex task is wrapping up incomplete, generate this handoff:

```
## SESSION HANDOFF — [Date]

### What We Did
- [Bullet list of completed items — specific, not vague]

### Where We Stopped
- [Exact point of interruption — file name, campaign ID, step number]

### What's Left
- [ ] [Specific remaining task 1]
- [ ] [Specific remaining task 2]
- [ ] [Specific remaining task 3]

### What Worked
- [Any approach or solution that was validated]

### What Didn't Work
- [Any approach that was tried and failed — so next session doesn't repeat it]

### Key Decisions Made
- [Any decisions T confirmed during this session]

### Files/Links Referenced
- [URLs, file paths, campaign IDs that will be needed next session]
```

## ACTIVE PROJECT TRACKING

When T asks "what's on my plate?" or "what are we working on?", search recent conversations and compile:

```
## ACTIVE PROJECTS — [Date]

### 🔴 Urgent / In Progress
- [Project]: [Status] — [Next action]

### 🟡 Planned / Upcoming
- [Project]: [Status] — [Next action]

### 🟢 Completed Recently
- [Project]: [Completion date] — [Outcome]

### 🔵 On Hold / Parked
- [Project]: [Why on hold] — [Resume condition]
```

## CONTEXT RECOVERY PATTERNS

### When T Says Something Vague
| T Says | You Do |
|---|---|
| "That thing we discussed" | conversation_search with 3-4 likely topic keywords |
| "The campaign we were fixing" | conversation_search "campaign fix" + recent_chats |
| "Remember the Shopify issue?" | conversation_search "Shopify issue" OR "Shopify bug" OR "Shopify problem" |
| "Continue" (no context) | recent_chats n=3 → present the last 3 topics → ask which one |

### When Search Returns Nothing
If past chat tools return no results:
1. Tell T: "I couldn't find a previous conversation about [topic] — it may predate my memory window or have been in a different project."
2. Ask for the MINIMUM context needed to continue: "Can you give me a one-line summary of where we left off?"
3. NEVER pretend to remember something you can't find.

### When Search Returns Multiple Matches
If multiple past conversations match:
1. Present the 2-3 most likely matches with dates and brief summaries
2. Let T pick which one
3. Load that context and continue

## PROACTIVE HANDOFF TRIGGERS

Offer to generate a handoff summary PROACTIVELY when:
- A complex multi-step task is only partially complete
- T has been working for a long session and may be wrapping up
- T says "I need to go" or "Let's pause"
- The conversation has produced decisions, code, or configurations that would be costly to reconstruct

## CROSS-SKILL INTEGRATION

- ALL other skills provide the domain knowledge; this skill provides the CONTINUITY layer.
- When loading previous context, also load the relevant domain skill (e.g., if the last session was about Google Ads, cross-reference the google-ads skill for current campaign IDs and rules).
- Business rules always apply — even when continuing previous work.
- Challenge-verify skill applies to any implementation picked up from a previous session — re-verify before continuing.
- Research mode applies when previous session involved factual claims that may need updating.
- **Skill library**: focused on Google Ads, Meta Ads, Shopify, SA-market competitors (Bash, Woolworths, Secret Skin), Africa-expansion benchmarks (Sephora, Ulta, Olive Young), and BoT operations. Source-of-truth count: `ls /mnt/skills/user/ | wc -l`.

## KEY PRINCIPLE

T's most common frustration: repeating context. Every minute T spends re-explaining is a minute not spent executing. This skill exists to eliminate that friction entirely. Search first, ask second, and NEVER say "I don't have access to previous conversations."
