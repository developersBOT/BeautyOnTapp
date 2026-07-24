# Reports

The fleet writes here. One dated folder per day (`YYYY-MM-DD`, SAST), one
markdown file per agent per brand:

```
reports/2026-07-24/
├── 01-ppc-audit-bot.md
├── 01-ppc-audit-pastry.md
├── 02-seo-audit-bot.md
├── 02-seo-audit-pastry.md
├── 03-merchant-feed-bot.md
├── ...
└── 06-revenue-expansion-bot.md    # the morning digest (also pushed to T)
```

## Report shape (every agent)

YAML front-matter, then fixed sections:

```markdown
---
agent: ppc-audit
brand: bot
date: 2026-07-24
run_id: <session id>
data_sources_used: [meta-ads-mcp, semrush-paid_search_research]
data_gaps: ["no Google Ads search-term CSV in inbox"]
---

## Summary
- up to 5 bullets

## Findings
- [C] <critical finding>  (impact 5 / effort 2)  — evidence: <tool/row>
- [H] ...

## Auto-Applied Changes
| change | before → after | revert |
|--------|----------------|--------|
| ...    | ...            | ...    |
(or: none)

## Recommendations
1. <human / Google-Ads action>  (impact / effort)

## Handoff
- <what the next agents should pick up>
```

The **06-revenue-expansion** file each day is the executive digest — read that
one first; it summarizes everything above it and is what gets pushed to T.
