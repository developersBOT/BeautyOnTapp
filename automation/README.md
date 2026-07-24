# BeautyOnTApp Marketing Automation Fleet

A fleet of six scheduled agents that run every morning (SAST), audit and act on
BeautyOnTApp and Pastry Skincare across Google Ads, SEO, Merchant/Shopping feed,
and Meta — then hand a single decision digest to T.

Each agent runs as a **Routine** (a persistent scheduled trigger on the Claude
account) — **all six are live and enabled**, see `ROUTINES.md`. At its scheduled
time the Routine resumes the operator's Claude session (which holds the live
Shopify / Meta / Semrush connectors), reads the reports the earlier agents
already committed today, does its job via a subagent, and commits its own
report. The last agent produces the executive morning digest.

## The daily cascade

| # | Agent | ~Time (SAST) | What it does | Autonomy |
|---|-------|--------------|--------------|----------|
| 07 | **Local Google Ads Auditor** | 07:30 | Runs **on your computer**: sweeps and audits *every* Google Ads export, pushes normalized CSVs into `inbox/` so the cloud agents have real data | Recommend-only |
| 01 | **PPC Audit** | 08:00 | Audits Google Ads + Meta paid performance; flags bleeders / wasted spend / CPA over ceiling | Meta: auto-acts · Google Ads: recommends |
| 02 | **SEO Audit** | 09:00 | Semrush site audit, rankings, backlinks, AI-Overview visibility | Recommends |
| 03 | **Merchant / Feed** | 09:30 | Shopping-feed & product-data health; fixes safe Shopify attributes | Shopify: auto-fixes · Merchant Center: recommends |
| 04 | **Analyst → Solutions** | 10:00 | Reads 01–03, builds a prioritized problem→solution backlog per brand | Synthesis only |
| 05 | **Keywords + Negatives** | 10:30 | Finds new keyword opportunities; mines junk terms into negatives | Meta: auto-acts · Google Ads negatives: CSV to upload |
| 06 | **Revenue Expansion** | 11:00 | The decider — final budget/scaling/kill calls; **pushes the morning digest** | Authorizes + acts within guardrails |

## How the agents chain (git as the shared memory)

Fresh sessions don't share memory, so the fleet chains through git. Everything
operational lives on the **`automation/reports`** branch:

```
automation/
├── config.yaml              # single source of truth (brands, guardrails, schedule)
├── agents/                  # the six playbooks (human-editable)
│   ├── 01-ppc-audit.md
│   ├── 02-seo-audit.md
│   ├── 03-merchant-feed.md
│   ├── 04-analyst-solutions.md
│   ├── 05-keywords-negatives.md
│   └── 06-revenue-expansion.md
├── inbox/                   # drop Google Ads CSV exports here
└── reports/
    └── YYYY-MM-DD/          # one dated folder per day
        ├── 01-ppc-audit-bot.md
        ├── 01-ppc-audit-pastry.md
        ├── 02-seo-audit-bot.md
        └── ...
```

Each agent, on wake: `git fetch origin automation/reports` → read today's folder →
work → write its report → `git pull --rebase` → `git push`. Distinct filenames
mean no collisions even if two runs overlap.

## Operating posture: auto-apply-where-safe

Agents **act** on channels we can write to, within tight guardrails, and
**recommend** everywhere else. Every automatic change is logged in that day's
report with `before → after` and exact revert steps. See `config.yaml`
`guardrails:` for the authoritative list. In short:

- **Google Ads** — recommend-only, always (no write API here). Agents produce
  ready-to-upload Editor CSVs, step lists, or Google Ads Scripts.
- **Meta** — may add negatives/exclusions, pause a clear bleeder adset
  (≥7 days, ≥R300 spend, 0 conversions), or trim a budget ≤20%. Never deletes,
  never touches the pixel, escalates anything spending >R500/day.
- **Shopify** — may fix feed/SEO attributes (title, description, meta, alt text,
  GTIN, category). Never changes price, publish status, or runs bulk edits.

## The Google Ads data bridge

Google Ads has no API or connector in this environment, so the account's own
**search-term / spend** data has to reach the fleet another way:

1. **Google Ads Script (recommended — automates it permanently).** Install
   `automation/google-ads-script/export-search-terms.js` once per account; it
   runs daily inside Google Ads and publishes the search-term report to a Google
   Sheet. Paste the published CSV URL into `config.yaml`
   (`search_terms_csv_url_bot` / `_pastry`) and agents fetch it automatically
   every morning. Setup instructions are in the script's header.
2. **CSV drop (fallback).** Export from Google Ads (Campaigns → Insights &
   Reports → Search Terms → Download CSV) into `automation/inbox/`.

If neither is present, agents 01 and 05 still run everything else and record the
missing account data as a data gap — they never fabricate it.

## Data-source health

`config.yaml` → `data_sources` is the live status board. As of 2026-07-24:
Shopify and Meta Ads are verified live; **Semrush is out of API units** (which
degrades agent 02 and half of agent 05 until topped up at
https://www.semrush.com/mcp-access); Google Ads uses the bridge above.

## Managing the fleet

- **Pause everything**: disable the Routines (ask Claude, or the Routines UI).
- **Change what an agent does**: edit its playbook in `agents/` and commit.
- **Change the schedule**: edit `schedule_utc` here *and* ask Claude to re-sync
  the Routines (the Routines are the live scheduler; this file documents intent).
- **Add a brand / channel**: extend `config.yaml` `brands:` and the relevant
  playbooks.

## Caveats

- Routines fire in **UTC**; the crons in `config.yaml` are the SAST times
  converted (UTC = SAST − 2h), with minutes nudged off `:00`.
- Scheduled sessions rely on the Semrush/Shopify/Meta MCP connections being
  present in headless runs. If a run reports a missing connection, re-authorize
  it from an interactive session.
