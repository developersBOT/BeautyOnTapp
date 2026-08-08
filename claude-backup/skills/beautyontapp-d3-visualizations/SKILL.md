---
name: beautyontapp-d3-visualizations
description: Interactive D3.js visualizations for PNCapital reporting — MER timelines, ROAS breakdowns, CPA trend charts, cohort heatmaps, funnel diagrams, multi-brand revenue flows, 6-store performance spiders, and competitor positioning maps (Bash, Woolworths, Secret Skin, Clicks, Dis-Chem). Auto-invoke when T asks for a chart, visualization, graph, dashboard view, trend line, heatmap, funnel, sankey, treemap, or any visual representation of BeautyOnTApp, Pastry Skincare, or Mzuri Skin data. Also auto-invoke for strategy reports, audit summaries, investor decks, executive dashboards, KPI scorecards, and whenever T pastes performance data and wants to see patterns. Always produces single-file HTML artifacts with inline D3.js v7 — no external dependencies, no build tools. Uses brand-aware color palettes and enforces SA beauty benchmark overlays (1.82x MER floor, 5.0x scaling trigger, R167/R300 CPA ceilings).
---

# BeautyOnTApp D3.js Visualizations

## Purpose

T is a visual learner. Static pptx charts and text tables do not communicate well. This skill produces interactive D3.js visualizations as single-file HTML artifacts that render natively in claude.ai. Every chart is purpose-built for PNCapital's actual decisions: campaign pause/scale, multi-brand revenue allocation, store expansion, competitive positioning, tracking health.

## When to use

- T asks for any visualization: chart, graph, heatmap, timeline, funnel, sankey, treemap, scatter, radar
- T pastes performance data (GA4 exports, Google Ads reports, Meta data, Analyzify dashboards, Semrush exports)
- Strategy reports, audit summaries, investor decks, executive updates require visuals
- KPI dashboards, cross-channel reports, cohort analyses
- Multi-brand comparisons (BeautyOnTApp vs Pastry vs Mzuri)
- Competitor positioning questions (Bash, Woolworths, Takealot, Clicks, Dis-Chem, Secret Skin, Glow Theory, Seoul of Tokyo)
- Store-level performance comparisons (Gateway, Fourways, Mall of Africa, Menlyn, Sandton, Canal Walk)
- SEO ranking visualizations (keyword position trees, SERP competitive maps, authority leak visualizations)

## Output contract

ALWAYS produce a single self-contained HTML artifact. Never produce static images when data is interactive. Never use Chart.js or other libraries when D3 is requested. Inline D3 v7 from unpkg with version pinning.

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>[Report Title]</title>
<script src="https://unpkg.com/d3@7"></script>
<style>
/* Inline CSS using PNCapital brand tokens */
</style>
</head>
<body>
<div id="chart"></div>
<script>
// D3 visualization code
</script>
</body>
</html>
```

## Brand color palettes

Use these palettes unless T overrides. If `beautyontapp-brand-visual-guidelines` has been updated, defer to that skill.

**BeautyOnTApp (primary)**
- Primary: `#000000` (brand 🖤)
- Accent 1: `#C9A961` (champagne gold)
- Accent 2: `#F5F1EA` (cream)
- Signal: `#E63946` (alert red)
- Neutral: `#6B7280` (slate)

**Pastry Skincare**
- Primary: `#F4C9C4` (pastry pink)
- Accent: `#8B5A3C` (caramel)
- Cream: `#FFF8F3`

**Mzuri Skin**
- Primary: `#4A5D3A` (olive)
- Accent: `#D4A574` (wheat)
- Cream: `#F8F5F0`

**Multi-brand comparison sequence** (3 brands one chart): `["#000000", "#F4C9C4", "#4A5D3A"]`

**Competitor palette** (visually distinct from PNCapital brands):
- Bash/TFG: `#7C3AED` (TFG purple)
- Woolworths: `#00843D` (Woolies green)
- Takealot: `#0072CE` (Takealot blue)
- Clicks: `#FF6B35` (Clicks orange)
- Dis-Chem: `#E31E24` (Dis-Chem red)
- Secret Skin: `#B4B4B4` (neutral grey — deliberately understated)
- Glow Theory: `#FFB4D9` (pink — generic K-beauty)
- Seoul of Tokyo: `#9D4EDD` (purple)

## PNCapital benchmark overlays

Every performance chart MUST include these reference lines when relevant:

| Metric | Threshold | Line style | Color |
|--------|-----------|------------|-------|
| MER | 1.82x floor | Solid red | `#E63946` |
| MER | 5.0x scaling trigger | Dashed green | `#10B981` |
| CPA | R167 excellent | Dashed green | `#10B981` |
| CPA | R300 stop | Solid red | `#E63946` |
| Google Ads | current daily ceiling (business-facts) | Dotted grey | `#6B7280` |
| Meta Ads | current daily ceiling (business-facts) | Dotted grey | `#6B7280` |
| Data cutoff | 23 Feb 2026 | Vertical dashed black | `#000000` (label: "Pre-Feb 23 unreliable") |
| Authority Score | BoT current 18 | Horizontal solid black | label "BoT current" |
| Authority Score | BoT 6-month target 25+ | Horizontal dashed green | label "Target" |

## Core chart templates

### 1. MER Timeline (most common use case)

X-axis: dates. Y-axis: MER (ratio). Line chart with 1.82x floor line, 5.0x trigger line, data cutoff marker. Tooltip: date, MER value, Google spend, Meta spend, total revenue.

### 2. Campaign ROAS Bar Chart

Horizontal bars sorted by ROAS descending. Color by ROAS tier: >3x green, 1.82-3x yellow, <1.82x red. Pin KS_C8_Brand_Protection to top (always highest ROAS).

### 3. CPA Trend by Campaign

Small-multiple line charts, one per active campaign. R167 + R300 reference lines. Highlight campaigns crossing R300 in red.

### 4. Cohort Retention Heatmap

Rows: acquisition week. Columns: weeks since acquisition. Color: retention % (viridis scale). Annotate repurchase rate at week 4 and week 12.

### 5. Multi-Brand Revenue Sankey

Left: BeautyOnTApp, Pastry Skincare, Mzuri Skin. Middle: channel (Online, 6 stores). Right: customer segment (First-time, Repeat, VIP). Flow widths proportional to revenue.

### 6. Store Performance Radar (6 stores)

One spider chart with 6 axes per store: Revenue, Foot traffic, Basket size, Conversion rate, Staff productivity, Repeat rate. Store comparison overlay.

### 7. Competitor Positioning 2x2 Map

X-axis: Price position (Mass → Prestige). Y-axis: Specialization (Generalist → K-beauty specialist). Plot: BeautyOnTApp, Bash, Woolworths, Takealot, Clicks, Dis-Chem, Secret Skin, Glow Theory, Seoul of Tokyo. Size = SA market share or Semrush organic traffic estimate.

### 8. Funnel Visualization

Stages: Impressions → Sessions → Add to Cart → Checkout → Purchase. Drop-off % between stages. Benchmark lines from SA DTC beauty.

### 9. Campaign Budget Allocation Treemap

Rectangles sized by spend, colored by ROAS tier. Quick visual of where money is going and whether it's productive.

### 10. Channel MER Breakdown

Stacked area chart: Google, Meta, Organic, Direct, Email contribution over time. Total line on top shows blended MER.

### 11. SEO Authority Comparison (new May 2026)

Horizontal bar chart of Authority Score + Referring Domains across BeautyOnTApp, shopbeautyontapp.co.za (old domain), pastryskincare.co.za, and top SA competitors (Glow Theory, Secret Skin, Bash, Woolworths). Annotate the "old domain leak" specifically — shopbeautyontapp.co.za has 90 ref domains vs beautyontapp.com's 54.

### 12. Keyword Position Tree (new May 2026)

Hierarchical tree showing BoT's keyword positions grouped by category (brand search, K-beauty SA, dermocosmetic, ingredient, concern, generic). Color-coded by position tier (1-3 green, 4-10 yellow, 11+ red). Visualizes the 83% brand-search dependency.

## Anti-AI-slop directives

T has expressed preference for non-generic output. Enforce these rules:

- NO purple gradients on white. NO generic pastel dashboards.
- USE bold, editorial typography — pair a serif (e.g., "Playfair Display", "DM Serif Display") with a clean sans (e.g., "Inter", "IBM Plex Sans")
- USE sparse, deliberate color. Dominant neutral + 1-2 accent colors per chart. Avoid rainbow palettes.
- USE meaningful annotations: label the 2-3 most important data points directly on the chart, not just via legend
- INCLUDE a title block with: report name, date range, brand(s), data source
- AXES labels must explain units (R, %, count, ratio) — never bare numbers
- ADD context: reference lines, benchmark zones, target bands

## Accessibility

All charts must pass WCAG AA contrast. Use viridis or cividis for sequential data (colorblind-safe). For categorical, pair color with shape/pattern so charts remain legible in monochrome print.

## Integration with existing PNCapital skills (77-skill canonical list)

This skill pairs with:
- `beautyontapp-analytics` — D3 for GA4 attribution flows and channel breakdowns
- `beautyontapp-cross-channel-reporting` — D3 for MER timelines and weekly/monthly reports
- `beautyontapp-meta-audit-engine` — D3 for campaign ROAS bars and creative fatigue curves
- `beautyontapp-ppc-audit-engine` — D3 for PMax transparency breakdowns and search terms treemaps
- `beautyontapp-financial-intel` — D3 for P&L waterfalls and break-even charts
- `beautyontapp-bleeder-detection` — D3 for zero-conversion flag charts
- `beautyontapp-onpage-seo` — D3 for keyword position trees, ranking timelines, SERP competitive maps
- `beautyontapp-counter-seo` — D3 for organic position visualization vs Secret Skin / Glow Theory
- `beautyontapp-tools-stack` — D3 outputs from Semrush + Screaming Frog data
- `beautyontapp-sa-competitive-scanner` — D3 for competitor positioning 2x2 maps

## Examples

**Example 1: MER timeline request**

User: "Show me MER over the last 30 days"
Response: Single HTML artifact with D3 line chart. X-axis: last 30 days. Y-axis: MER. Red reference line at 1.82x. Green dashed line at 5.0x. Vertical black dashed line at Feb 23, 2026 with label "Pre-Feb 23 unreliable." Tooltip on hover shows date + MER + Google spend + Meta spend.

**Example 2: Competitor positioning**

User: "Map SA beauty retail competitors"
Response: HTML artifact with D3 scatter plot. 2x2 quadrants. Annotate quadrant labels: "Mass Generalist", "Mass K-beauty", "Prestige Generalist", "Prestige K-beauty Specialist". Plot competitors using competitor palette. Size bubbles by Semrush organic traffic. BeautyOnTApp bubble labeled in bold. Caption: "BeautyOnTApp occupies the Prestige K-beauty Specialist quadrant — only SA retailer with this positioning."

**Example 3: SEO authority leak visualization (new use case)**

User: "Visualize the shopbeautyontapp.co.za authority leak"
Response: HTML artifact with D3 horizontal bar chart. Two bars: beautyontapp.com (54 ref domains, AS 18) vs shopbeautyontapp.co.za (90 ref domains, AS 12). Annotate cosrx.com (DA 50, 32 backlinks) as the specific recoverable asset. Tooltip on each bar shows full Semrush metrics.

## Guidelines

- ALWAYS use D3 v7 from unpkg (not jsdelivr — has had outages)
- ALWAYS include title, subtitle with date range, data source caption
- ALWAYS include interactive tooltips for data points
- NEVER output a static chart when data is meaningful enough to interact with
- NEVER use default D3 color scales (`d3.schemeCategory10`) for PNCapital data — use brand palettes above
- NEVER omit PNCapital benchmark overlays when chart shows a benchmarked metric
- NEVER use purple/generic gradients ("AI slop")
- If data is missing, do not fabricate — use null, label as "no data," explain in caption
- Pre-Feb 23 2026 data: exclude or clearly mark as unreliable

## Tools

Inside the HTML artifact:
- D3 v7 for all charts
- Native DOM for tooltips (no extra tooltip libraries)
- Native SVG — never canvas unless performance demands
- CSS variables for colors (easier to adjust)

## Self-check before delivery

Before returning the HTML artifact, verify:
1. D3 loads from unpkg CDN with explicit v7 pin
2. Title block includes report name, date range, brand, data source
3. All numbers have units
4. Benchmark lines present where applicable
5. Tooltips work on hover
6. Anti-AI-slop typography (serif + sans pair, not generic system fonts)
7. Accessibility: WCAG AA contrast, colorblind-safe palette
8. Self-contained: no external dependencies beyond D3 CDN
