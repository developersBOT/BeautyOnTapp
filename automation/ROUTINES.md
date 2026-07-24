# Fleet Routines (the scheduler)

The six agents run as **Routines** (scheduled triggers) on the Claude account —
one per agent, staggered across the morning. This file is the source of record
for what each Routine should be, so they can be audited or recreated.

## Schedule

| # | Routine name | SAST | UTC cron | Playbook | Connectors needed | Notify |
|---|--------------|------|----------|----------|-------------------|--------|
| 01 | BoT Fleet · 01 PPC Audit | 08:00 | `4 6 * * *` | `agents/01-ppc-audit.md` | Meta, Semrush, Shopify | – |
| 02 | BoT Fleet · 02 SEO Audit | 09:00 | `8 7 * * *` | `agents/02-seo-audit.md` | Semrush, Shopify | – |
| 03 | BoT Fleet · 03 Merchant/Feed | 09:30 | `34 7 * * *` | `agents/03-merchant-feed.md` | Shopify, Semrush | – |
| 04 | BoT Fleet · 04 Analyst/Solutions | 10:00 | `7 8 * * *` | `agents/04-analyst-solutions.md` | (reads reports; Shopify optional) | – |
| 05 | BoT Fleet · 05 Keywords+Negatives | 10:30 | `33 8 * * *` | `agents/05-keywords-negatives.md` | Semrush, Meta, Shopify | – |
| 06 | BoT Fleet · 06 Revenue Expansion | 11:00 | `9 9 * * *` | `agents/06-revenue-expansion.md` | Meta, Shopify | **push + email** |

All fire **daily** as a fresh session (`create_new_session_on_fire`). Minutes are
nudged off `:00` so the fleet doesn't stampede. Only #06 sends a completion
notification — its report is the morning digest delivered to T.

## The prompt each Routine fires

Same template for all six, substituting `{NN}`, `{AGENT NAME}`, `{ID}`, `{FILE}`:

```
You are the {AGENT NAME} — agent {NN} of 6 in the BeautyOnTApp marketing
automation fleet. Fresh scheduled session, no prior memory. Work fully
autonomously; never ask questions.

LOAD YOUR INSTRUCTIONS (the automation/ tree lives on the operational branch,
not the default branch):
1. cd into the BeautyOnTApp repository (your working directory).
2. git fetch origin automation/reports
3. git checkout -B automation/reports origin/automation/reports
4. Read automation/config.yaml (brands, guardrails, benchmarks, schedule).
5. Read every report already in
   automation/reports/$(TZ=Africa/Johannesburg date +%F)/ (earlier agents today).
6. Read and FOLLOW EXACTLY your playbook: automation/agents/{FILE}

Then run your job for BOTH brands (BeautyOnTApp and Pastry Skincare).

POSTURE — auto-apply-where-safe: auto-apply ONLY on Meta and Shopify within the
config.yaml guardrails, logging every change with before→after + revert steps.
GOOGLE ADS IS RECOMMEND-ONLY — never claim to have changed the account; produce
upload-ready Google Ads Editor CSVs / step lists / a Google Ads Script instead.
When uncertain, escalate (recommend) rather than act.

OUTPUT: commit one report per brand to
automation/reports/$(TZ=Africa/Johannesburg date +%F)/{NN}-{ID}-<brand>.md in the
playbook's report shape, then git pull --rebase and git push origin
automation/reports (retry with backoff on network errors).
```

Agent 06 appends:

```
FINAL: your report for both brands IS the executive morning digest — what changed
overnight, what the fleet auto-applied today across Meta/Shopify, what needs T's
decision, and the top 3 priorities per brand, skimmable in under 60 seconds. End
your session with that digest as your final message so it reaches T via the
completion notification.
```

## Creating / editing the Routines

**Connectors are the critical requirement.** Agents 01–03 and 05 need live
Semrush / Shopify / Meta access. A scheduled session must have those connectors
attached or it can only run the git/analysis parts.

- **From the claude.ai Routines UI** — create each Routine with the name, cron,
  and prompt above, and attach the connectors listed in the table. This is the
  reliable path because the UI lets you attach your connectors per-Routine.
- **Editing later** — change cadence or prompt in the UI, or edit the playbook in
  `agents/` (no Routine change needed — agents re-read the playbook every run).
- **Pause the fleet** — disable the Routines.

## Managing state

- Live branch the agents read/write: **`automation/reports`**.
- To change guardrails, brands, or benchmarks: edit `automation/config.yaml`.
- To change what an agent does: edit its playbook in `automation/agents/`.
