---
name: beautyontapp-subagent-orchestrator
description: For any complex task that combines analysis and execution (audit a theme then fix it, analyze ads then restructure, review schema then deploy), this skill enforces a two-phase pattern — fresh read-only auditor subagent first, then independent executor subagent with the auditor report as context. Use this skill whenever a task spans audit + execute, when T says "audit and fix", "review and update", "analyze and ship", "find issues and resolve them", or when the deliverable requires both diagnosis and treatment. Pairs with audit-first, ads-benchmarks-auditor, shopify-liquid-auditor.
license: MIT
---

# Auditor → Executor Orchestration

You implement the orchestrator-worker pattern from Anthropic's *Building Effective Agents*: a central agent (you) decomposes a complex task, delegates to fresh subagents with isolated context, and synthesizes their results.

## When to invoke this pattern

Any task where:
- Diagnosis precedes treatment (audit → fix)
- The auditor benefits from NOT seeing the executor's reasoning
- T wants independent verification before action
- The task spans >3 distinct phases or files

## Phase 1: Auditor subagent (read-only)

Spawn a subagent with this prompt template:

```
You are a senior [domain] auditor. Read-only mode.

Task: [user's audit goal]

Tools allowed: Read, Grep, Glob, WebFetch (no Write, no Edit, no Bash mutations).

Read every relevant file in one parallel batch. Quote evidence verbatim.
Tag findings by severity (Critical/High/Medium/Low). Score each by
impact and effort. Output in the audit report shape.

Hard cap: 800 words. Self-contained — do not ask clarifying questions;
make reasonable assumptions and flag them.
```

Wait for the subagent's audit report. Do not skip Phase 1 to "save time" — the independence of the auditor is the point.

## Phase 2: Executor subagent (or main agent)

Pass the auditor's report (verbatim) plus T's execution scope to the executor:

```
You are a senior [domain] engineer. Execution mode.

Auditor's findings (verbatim):
[paste audit report]

Scope: [which findings to address — Critical only? P1 + P2?]

Tools allowed: Read, Write, Edit, Bash.

Implement each finding in scope. After each implementation, run
verification (build, test, schema validator, JSON parse, Liquid lint —
domain-appropriate). Only claim "done" with fresh verification evidence.

Output: implemented changes + verification log + remaining findings.
```

## Phase 3: Synthesis (you)

Reconcile auditor's findings vs. executor's deliverables:
- Done: [list]
- Blocked: [list with one-sentence reason and one targeted question]
- Cancelled: [list with reason]
- Out of scope (deferred): [list]

Do not end with in_progress or pending items.

## Hard gates

- Never let the executor see T's original framing of the problem — only the auditor's findings. This forces grounded execution.
- Never let the auditor write or modify files. If the auditor's report contains a "fix," reject and re-spawn.
- If executor reports "all done" but verification log is empty, reject and demand fresh verification evidence.
