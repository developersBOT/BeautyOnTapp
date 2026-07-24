# Inbox — Google Ads exports

Drop Google Ads CSV exports here so the **PPC Audit** (01) and
**Keywords + Negatives** (05) agents can use your account's real data. There is
no Google Ads API in this environment, so this folder is the bridge.

## What to drop

**Search-term report** (the important one, for negatives + waste):
Google Ads → Campaigns → Insights & Reports → Search Terms → Download → CSV.
Include these columns: `Search term`, `Match type`, `Added/Excluded`, `Campaign`,
`Ad group`, `Clicks`, `Impressions`, `Cost`, `Conversions`, `Cost / conv.`,
`Conv. rate`. Date range 7–30 days.

**Optional, for a deeper PPC audit:** campaign, ad-group, and keyword performance
exports over the same window.

## Naming so agents pick the right file

Use: `<brand>-<report>-<YYYY-MM-DD>.csv`

- `bot-searchterms-2026-07-24.csv`
- `pastry-searchterms-2026-07-24.csv`
- `bot-campaigns-2026-07-24.csv`

Agents use the most recent file per brand and ignore anything older than 30 days.
If no file is present for a brand, the agent runs the external-data half (Semrush)
and flags the missing account data in its report.

## Prefer to automate the export?

Ask Claude for the **Google Ads Script** version — it publishes the search-term
report to a Google Sheet on a schedule, and the agent reads it directly. Wire it
once and you never touch a CSV again.
