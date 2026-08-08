---
name: beautyontapp-google-ads-scripts
description: Google Ads scripts and automation for BeautyOnTApp — PMax transparency scripts, monitoring automation, alerting, and Google Ads API scripts. Auto-invoke when T asks about Google Ads scripts, PMax scripts, PMax insights, automated monitoring, Mike Rhodes script, Nils Rooijmans, campaign automation, Google Ads API, scheduled reports, anomaly detection, or "automate Google Ads", "PMax transparency", "where is PMax spending", "PMax channel breakdown", "automated alerts", "scripts for Google Ads". NOT for native automated rules (use beautyontapp-google-ads-automated-rules). NOT for campaign management (use beautyontapp-google-ads).
---

# Google Ads Scripts & Automation

Scripts give you visibility and control that the Google Ads UI doesn't provide natively. For PMax specifically, scripts are the primary tool for cracking the black box.

## ESSENTIAL PMAX SCRIPTS

### 1. Mike Rhodes' PMax Insights Script ($199 one-time)
- **What it does:** Creates auto-updating Google Sheets with channel spend breakdowns (Search, Shopping, YouTube, Display, Discover, Gmail, Maps), search category analysis (brand/close-to-brand/non-brand), product performance segmentation, and placement visibility
- **Why it matters:** PMax channel-level reporting is now native, but this script provides historical trend data, better categorization, and alerting that the UI doesn't
- **URL:** https://mikerhodes.com.au/scripts/pmax
- **Setup:** Copy script → Google Ads → Tools → Scripts → paste → authorize → schedule daily
- **Output:** Auto-updating spreadsheet linked to your Google Ads account
- **Key metric to watch:** % of spend on Shopping vs Display/YouTube. Healthy ecommerce PMax = 60-80% Shopping. If Display > 20%, feed quality needs work.

### 2. Nils Rooijmans' Non-Converting Search Terms Script (FREE)
- **What it does:** Identifies PMax search terms generating clicks without conversions
- **Why it matters:** PMax now has native search term reporting, but this script aggregates patterns and flags waste systematically
- **Setup:** Install from Google Ads Scripts library → configure thresholds → schedule weekly
- **Action:** Export flagged terms → add as campaign-level negative keywords in PMax (self-serve, up to 10,000)

### 3. SMEC Brand Traffic Analyzer (FREE)
- **What it does:** Tracks branded query share in PMax over time
- **Why it matters:** Detects brand cannibalization between PMax and Search_Brand/KS_C8
- **Target:** <1% brand traffic in PMax if running dedicated brand Search campaigns
- **Source:** smarter-ecommerce.com

### 4. Flowboost Labelizer
- **What it does:** Segments products by breakeven ROAS and conversion rate for campaign structuring
- **Why it matters:** Automates Hero/Sidekick/Villain/Zombie product classification
- **Source:** producthero.com/labelizer
- **Action:** Use output to populate custom_label fields in Simprosys

## MONITORING & ALERTING SCRIPTS

### 5. Anomaly Detection Script
- **Purpose:** Alert when spend, CPA, ROAS, or conversion rate deviates significantly from 7-day average
- **Thresholds for BeautyOnTApp:**
  - Spend > 130% of daily average → alert
  - Conversions < 50% of daily average → alert
  - CPA > 150% of 7-day average → alert
  - Zero conversions by 6pm → alert
- **Schedule:** Run every 6 hours
- **Alert method:** Email to T

### 6. Budget Pacing Script
- **Purpose:** Track MTD spend vs monthly target across all campaigns
- **Thresholds:**
  - If pacing >110% of target → flag overspending
  - If pacing <80% of target → flag underspending
  - Hard ceiling: current Google daily ceiling in `03_PNCapital_Business_Facts §Advertising Ceilings` (sync script value when it changes)
- **Schedule:** Daily at 9am

### 7. Placement Exclusion Script
- **Purpose:** Auto-identify junk placements (mobile gaming apps, MFA sites, parked domains) consuming budget with zero conversions
- **Threshold:** Any placement with >R50 spend and 0 conversions → add to account-level exclusion list
- **Schedule:** Weekly
- **Scope:** Account-level exclusions cover PMax, Demand Gen, YouTube, Display, Search Partner Network

### 8. Search Term Negative Mining Script
- **Purpose:** Systematically identify search terms across all campaigns with spend > 2× target CPA and zero conversions
- **Action:** Auto-add to shared negative keyword list
- **Safety:** Exclude terms containing BeautyOnTApp brand variations and stocked brand names
- **Schedule:** Weekly

## GOOGLE ADS SCRIPTS SETUP GUIDE

### How to Install a Script
1. Navigate to: Google Ads → Tools → Scripts
2. Click "+ New Script"
3. Name the script descriptively (e.g., "PMax Channel Insights - Mike Rhodes")
4. Paste the script code
5. Click "Authorize" → grant permissions
6. Click "Preview" to test without making changes
7. Set schedule (daily, weekly, or custom)
8. Click "Save"

### Script Permissions
- Scripts run under the Google Ads account permissions
- They can read data, create reports, send emails, and modify campaigns
- Review what each script does before authorizing
- Never install scripts from untrusted sources

### Debugging
- Use "Preview" mode first — it runs the script without making changes
- Check the Logs tab for errors
- Common issues: API quota limits, sheet permission errors, date range issues

## BEAUTYONTAPP-SPECIFIC SCRIPT CONFIGURATION

### Account IDs to Configure
- BeautyOnTApp Google Ads: 820-452-9325
- BeautyOnTApp Merchant Center: 5717759749
- Pastry Skincare Google Ads: 851-084-2703
- Pastry Skincare Merchant Center: 5692060761 (separate, NOT shared with BoT)

### Negative Keyword Safety List (never auto-negate)
- beautyontapp, beauty on tapp, beautytapp (brand terms)
- face wash, face serum, face cream (blocked purchase-intent traffic historically)
- Any stocked brand names (COSRX, Beauty of Joseon, Pastry Skincare, etc.)

### Email Alert Recipients
- Configure to T's email for all alerts

## PRIORITY INSTALLATION ORDER

1. **Mike Rhodes PMax Insights** — immediate ROI, PMax transparency
2. **Non-Converting Search Terms** — automated waste identification
3. **Anomaly Detection** — catch problems before they accumulate
4. **Budget Pacing** — prevent overspend
5. **Brand Traffic Analyzer** — detect PMax brand cannibalization
6. **Placement Exclusion** — automated junk placement blocking
7. **Labelizer** — product performance segmentation
8. **Search Term Negative Mining** — automated negative management

## CROSS-SKILL INTEGRATION

| Skill | Relationship |
|-------|-------------|
| beautyontapp-ppc-audit-engine | Scripts enhance every audit step — reference script outputs during audits |
| beautyontapp-google-ads | Account IDs, campaign names for script configuration |
| beautyontapp-bleeder-detection | Script thresholds aligned with bleeder detection rules |
| beautyontapp-google-ads-automated-rules | Scripts complement native rules — scripts for reporting, rules for auto-pausing |
| beautyontapp-tools-stack | Scripts are part of the tools ecosystem |
