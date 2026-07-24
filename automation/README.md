# BeautyOnTApp Marketing Automation Fleet

A fleet of six scheduled agents that run every morning (SAST), audit and act on
BeautyOnTApp and Pastry Skincare across Google Ads, SEO, Merchant/Shopping feed,
and Meta — then hand a single decision digest to T.

Each agent runs as a **Routine** (a persistent scheduled trigger on the Claude
account). At its scheduled time it spins up a **fresh Claude session** in this
environment, reads the reports the earlier agents already committed today, does
its job, commits its own report, and (the last one) pushes a digest to T's phone
and email.

## The daily cascade

| # | Agent | ~Time (SAST) | What it does | Autonomy |
|---|-------|--------------|--------------|----------|
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

Google Ads has no API in this environment. Agents 01 and 05 do all the *external*
analysis autonomously via Semrush. For your account's own **search-term / spend**
data they need one of:

1. **CSV drop** — export from Google Ads (Campaigns → Insights & Reports →
   Search Terms → Download CSV) and drop it in `automation/inbox/`. The agent
   picks it up automatically. See `inbox/README.md`.
2. **Google Ads Script** — the agents emit a ready-to-run script that publishes
   the search-term report on a schedule; wire it once and the loop closes.

If neither is present, the agents still run the external half and flag the gap.

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
