# Local Google Ads Auditor (fleet agent 07)

An agent that runs **on your own computer**, where the Google Ads exports
actually live, and audits **every one of them** — then feeds the results up to
the cloud fleet.

## Why this exists

There is no Google Ads API or MCP connector anywhere in this system. The cloud
agents (01 PPC Audit, 05 Keywords + Negatives) can see Meta, Shopify and Semrush,
but they are **blind to your Google Ads account's own numbers** — spend, search
terms, conversions. Every run they recorded it as a data gap.

Your exports are on your laptop. So the auditor goes to them:

```
 your computer                                    the cloud fleet
 ┌──────────────────────────────┐                ┌────────────────────────┐
 │ ~/Downloads, ~/Desktop,      │                │ 08:00  01 PPC Audit    │
 │ ~/BeautyOnTApp-GoogleAds     │                │ 09:00  02 SEO          │
 │   Search terms report.csv    │                │ 09:30  03 Merchant     │
 │   Campaign report.csv        │  07:30 daily   │ 10:00  04 Analyst      │
 │   Products report.csv    ────┼───────────────▶│ 10:30  05 Keywords     │
 │   ...every export            │  audit + push  │ 11:00  06 Revenue      │
 └──────────────────────────────┘                └────────────────────────┘
        agent 07 sweeps ALL of them              they finally have real data
```

It runs at **07:30**, half an hour before the cloud cascade starts, so agents 01
and 05 wake up with real account data instead of a gap.

## What it does each run

1. **Sweeps every** CSV / XLSX / TSV in your watch folders — no sampling, no
   "most recent only", no top-N. Files it can't parse are listed explicitly with
   a reason; nothing is dropped silently.
2. **Classifies** each file by report type (search terms, keywords, campaigns,
   shopping/products, assets, auction insights) and by brand (BeautyOnTApp vs
   Pastry Skincare).
3. **Audits all of them** using the same thresholds as the rest of the fleet —
   bleeder detection, wasted-spend rules, the 4-bucket negative classification,
   R167/R300 CPA ceilings, the Conversions-not-All-conversions rule.
4. **Produces** a per-brand audit report plus ready-to-upload Google Ads Editor
   negative-keyword CSVs, de-duplicated against what was already proposed.
5. **Normalizes the exports into `automation/inbox/`** and pushes everything to
   the `automation/reports` branch — this is the bridge that unblocks the cloud
   agents.

It **never modifies your Google Ads account**. Google Ads is recommend-only
across the whole fleet; the deliverables are audits and upload-ready files.

## Install (once)

You need the [Claude Code CLI](https://claude.com/claude-code) installed and
logged in, plus a local clone of this repo with push access.

```bash
git clone <your-repo-url> ~/BeautyOnTapp        # if you don't have it yet
cd ~/BeautyOnTapp/automation/local-agent

./install.sh
```

That creates `config.env`, makes `~/BeautyOnTApp-GoogleAds/`, and schedules the
daily 07:30 run (launchd on macOS, cron on Linux).

**Then edit `config.env`** — mainly `REPO_DIR` and `WATCH_DIRS`:

```bash
REPO_DIR="$HOME/BeautyOnTapp"
WATCH_DIRS="$HOME/Downloads $HOME/Desktop $HOME/BeautyOnTApp-GoogleAds"
MAX_AGE_DAYS=0        # 0 = audit every export ever found
```

## Test it before trusting it

```bash
# 1. See exactly which files it would audit — no Claude, no push
DRY_RUN=1 ./run-gads-audit.sh

# 2. Real run, right now
./run-gads-audit.sh

# 3. Is the schedule installed? When did it last run?
./install.sh --status
```

Logs land in `~/Library/Logs/beautyontapp-gads-auditor/` (macOS).

## Getting the exports

From Google Ads: **Campaigns → Insights & Reports → Search Terms → Download →
CSV**. Save it anywhere in `WATCH_DIRS`. Do the same for Campaign, Keyword, and
Products reports if you want them audited too — the agent handles whatever it
finds.

Do this for both accounts: **BoT 820-452-9325** and **Pastry 851-084-2703**.
Keep the account name in the filename (e.g. `pastry-search-terms.csv`) if the
export itself has no account column — it helps brand attribution.

**Want the downloads automated too?** Install
`../google-ads-script/export-search-terms.js` in each Google Ads account; it
publishes the search-term report to a Google Sheet on a schedule, so you never
click Download again.

## Managing it

| Task | Command |
|------|---------|
| Check status / last run | `./install.sh --status` |
| Run right now | `./run-gads-audit.sh` |
| See what it would audit | `DRY_RUN=1 ./run-gads-audit.sh` |
| Change the audit method | edit `audit-prompt.md` |
| Change folders/paths | edit `config.env` |
| Stop the schedule | `./install.sh --remove` |

`config.env` is gitignored — it holds machine-specific paths, so your laptop's
settings never end up in the repo.
