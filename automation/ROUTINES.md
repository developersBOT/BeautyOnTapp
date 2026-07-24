# Fleet Routines (the scheduler) — LIVE

The six agents run as **Routines** (scheduled triggers) on the Claude account,
staggered across the morning. **All six are created and enabled.** No manual
setup is required to run the fleet.

## Live Routines

| # | Routine | SAST | UTC cron | Trigger ID |
|---|---------|------|----------|------------|
| 01 | BoT Fleet · 01 PPC Audit | 08:00 | `4 6 * * *` | `trig_01B8nMr7HWL2sRo3ZgjvJrHF` |
| 02 | BoT Fleet · 02 SEO Audit | 09:00 | `8 7 * * *` | `trig_015Rby2GUfZjqfWBD7qxSxyS` |
| 03 | BoT Fleet · 03 Merchant/Feed | 09:30 | `34 7 * * *` | `trig_01742rqQsMybQa8F1JwBPKfk` |
| 04 | BoT Fleet · 04 Analyst/Solutions | 10:00 | `7 8 * * *` | `trig_01QBXJdagAxp2pUmfr6YQzxm` |
| 05 | BoT Fleet · 05 Keywords+Negatives | 10:30 | `33 8 * * *` | `trig_01Psj2CXdZoEd8eDgp7LAz2B` |
| 06 | BoT Fleet · 06 Revenue Expansion — digest | 11:00 | `9 9 * * *` | `trig_01JSMXVTvBgQgCfZ1uifZRF6` |

Crons are UTC (SAST − 2h); minutes are nudged off `:00` so the fleet doesn't
stampede. All six fire **daily**.

## Why these are session-bound (important)

Each Routine is **bound to the operator's Claude session** rather than spawning a
fresh session. This is deliberate and load-bearing:

- A **fresh** session starts with **no MCP connectors** — no Shopify, no Meta, no
  Semrush. Agents 01–03 and 05 would have no data to work with. (Verified: a
  fresh-session probe produced nothing.)
- A **session-bound** Routine resumes the operator's conversation, which *holds*
  the live connectors, so every agent gets real account data.

Consequence: the daily digest from agent 06 lands **in that conversation**
rather than as a separate push notification.

## What each Routine fires

Each prompt is self-contained and tells the agent to: check out the
`automation/reports` branch → read `config.yaml`, its own playbook, and the
day's earlier reports → run its playbook for both brands → auto-apply only
within guardrails → commit and push its reports. Each delegates the heavy
lifting to a subagent so the operator session stays lean.

The prompts are stored on the Routines themselves. The **playbooks** in
`agents/` hold the actual methodology — edit those to change agent behavior
without touching the Routines at all.

## Managing the fleet

- **Change what an agent does** → edit its playbook in `automation/agents/`,
  commit, push. Agents re-read the playbook on every run. No Routine change.
- **Change guardrails / brands / benchmarks** → edit `automation/config.yaml`.
- **Change a schedule** → update the Routine's cron (ask Claude, or the Routines
  UI), and update the table above.
- **Pause one agent** → disable that Routine.
- **Pause everything** → disable all six.

## Data-source dependencies

See `config.yaml` → `data_sources` for live status. As of 2026-07-24:

- **Shopify** and **Meta Ads** — live and verified.
- **Semrush** — subscription active but **out of API units**, so its calls fail.
  This degrades agent 02 and the opportunity half of agent 05. Agents record the
  gap rather than fabricating. More units: https://www.semrush.com/mcp-access
- **Google Ads** — no API/connector. Install
  `automation/google-ads-script/export-search-terms.js` once per account to
  automate the search-term feed (see that file's header), or drop a CSV in
  `automation/inbox/`.
