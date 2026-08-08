---
name: beautyontapp-google-ads-automated-rules
description: Google Ads native automated rules for BeautyOnTApp — auto-pause bleeders, budget protection, CPA alerts, and scheduled actions using Google Ads' built-in rules engine. Auto-invoke when T asks about automated rules, auto-pause, "automatically pause", "alert me when", "budget protection", "CPA alert", "automated actions", "rules engine", "schedule pause", or wants to set up guardrails that work when T isn't watching. NOT for Google Ads scripts (use beautyontapp-google-ads-scripts). NOT for campaign management decisions (use beautyontapp-google-ads + beautyontapp-bleeder-detection).
---

# Google Ads Native Automated Rules

Automated rules protect budget 24/7 when T isn't watching. They complement scripts — scripts are for reporting and analysis, rules are for automated actions.

## RULE SETUP PATH

Google Ads → Tools → Bulk Actions → Rules → + New Rule

## RECOMMENDED RULES FOR BEAUTYONTAPP

### Rule 1: Bleeder Auto-Pause (Campaign Level)
**Purpose:** Auto-pause campaigns spending with zero conversions
- **Apply to:** All enabled campaigns
- **Condition:** Cost > R150 AND Conversions < 1
- **Time period:** Last 7 days
- **Action:** Pause campaign
- **Frequency:** Daily at 6am
- **Email notification:** Always
- **SAFETY:** Exclude KS_C8_Brand_Protection (must NEVER be paused — add to exclusion or use label filter)

### Rule 2: CPA Spike Alert (Campaign Level)
**Purpose:** Alert when CPA exceeds acceptable threshold
- **Apply to:** All enabled campaigns (except brand campaigns)
- **Condition:** Cost / Conv > R300 AND Conversions >= 1
- **Time period:** Last 7 days
- **Action:** Send email only (don't auto-pause — CPA spikes may be temporary)
- **Frequency:** Daily at 9am

### Rule 3: Budget Ceiling Guard (Account Level)
**Purpose:** Prevent total daily spend from exceeding the current Google ceiling (R1,000/day at last update — sync to `03_PNCapital_Business_Facts` when the ceiling changes)
- **Apply to:** All enabled campaigns
- **Condition:** Cost > [ceiling − R50 buffer] (R950 when ceiling is R1,000 — update if ceiling changes)
- **Time period:** Today
- **Action:** Send email alert
- **Frequency:** Every 4 hours
- **Note:** Google doesn't have a true account-level daily cap — this alert lets T manually intervene

### Rule 4: Low Search Impression Share Alert
**Purpose:** Flag when winner campaigns lose visibility
- **Apply to:** KS_C8_Brand_Protection, Search_Brand
- **Condition:** Search impr. share < 70%
- **Time period:** Last 7 days
- **Action:** Send email only
- **Frequency:** Weekly on Monday at 9am

### Rule 5: Learning Phase Protection
**Purpose:** Prevent changes during learning phase
- **Note:** Google doesn't have a native rule for this. Instead, create a label-based system:
  - When changing a campaign's bid strategy → add label "LEARNING - [date]"
  - Set rule: If campaign has label "LEARNING" → send reminder email to not touch it
  - Remove label manually after 14 days

### Rule 6: Ad Disapproval Alert
**Purpose:** Catch disapproved ads before they accumulate downtime
- **Apply to:** All ads
- **Condition:** Status = Disapproved
- **Action:** Send email
- **Frequency:** Daily at 8am

### Rule 7: Zero Impression Campaign Alert
**Purpose:** Catch campaigns that stopped serving (budget exhaustion, policy issue, or targeting problem)
- **Apply to:** All enabled campaigns
- **Condition:** Impressions = 0
- **Time period:** Yesterday
- **Action:** Send email
- **Frequency:** Daily at 9am

### Rule 8: Shopping Product Disapproval Alert
**Purpose:** Catch Merchant Center product disapprovals affecting Shopping/PMax
- **Note:** This requires checking Merchant Center directly — no Google Ads rule covers this
- **Alternative:** Set up Merchant Center email notifications for product issues
- **Path:** Merchant Center → Settings → Notifications → enable "Product issues" alerts

## RULE CONFIGURATION BEST PRACTICES

### Labels for Rule Management
Create these labels in Google Ads → Labels:
- **DO-NOT-PAUSE** — Apply to KS_C8_Brand_Protection and any other campaigns that must never be auto-paused
- **LEARNING** — Apply to campaigns in bid strategy learning phase
- **BLEEDER-WATCH** — Apply to campaigns on the watch list from audit

### Time Period Selection
- "Last 7 days" for conversion-based rules (accounts for attribution lag)
- "Today" only for spend-based alerts (real-time budget protection)
- Never use "Last 14 days" for pause rules — too much lag, slow to react
- Never use "Yesterday" for conversion rules — attribution delay means yesterday's data is incomplete

### Testing Before Going Live
1. Create rule with action = "Email only" first
2. Run for 1 week to verify it catches what you expect
3. If accurate → change action to "Pause" (for auto-pause rules)
4. Always keep email notification ON even for auto-actions

### Rules vs Scripts Decision Framework
| Need | Use |
|------|-----|
| Auto-pause based on simple conditions | Automated Rule |
| Complex multi-metric analysis | Script |
| Reporting and dashboards | Script |
| Real-time budget protection | Automated Rule |
| Search term negative mining | Script |
| PMax channel transparency | Script |
| Ad disapproval alerts | Automated Rule |

## SAFETY RULES

1. **NEVER auto-pause KS_C8_Brand_Protection** — best campaign in the account, must always stay enabled
2. **NEVER auto-pause based on "Today" conversion data** — attribution lag makes same-day data unreliable
3. **Always set email notifications** — even for auto-actions, T needs visibility
4. **Review rule triggers weekly** — check which campaigns were affected by rules in Change History
5. **Start with alerts, graduate to actions** — prove accuracy before automating pauses

## CROSS-SKILL INTEGRATION

| Skill | Relationship |
|-------|-------------|
| beautyontapp-bleeder-detection | Rule thresholds align with bleeder thresholds (R150 zero-conv = bleeder) |
| beautyontapp-google-ads-scripts | Scripts complement rules — scripts report, rules act |
| beautyontapp-google-ads | Campaign names, account structure for rule targeting |
| beautyontapp-ppc-audit-engine | Audit verifies rules are configured correctly |
