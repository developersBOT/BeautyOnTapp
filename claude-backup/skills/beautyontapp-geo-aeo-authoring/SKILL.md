---
name: beautyontapp-geo-aeo-authoring
description: Generative Engine Optimisation (GEO) and Answer Engine Optimisation (AEO) authoring discipline for BeautyOnTApp, Pastry Skincare, and Mzuri Skin. Writes content engineered to be cited by Google AI Overviews, AI Mode, Perplexity, ChatGPT, and Gemini. Produces passage-level structure where each section stands alone and is citable by query fan-out, 40-60 word opening answer paragraphs extractable verbatim by AI extractors, statistics-rich and quotation-rich content per Princeton GEO paper interventions, FAQPage + Article schema markup, named author E-E-A-T credentials. Make sure to invoke whenever T asks for "AI Overview optimisation", "AEO", "GEO", "AI Mode visibility", "ChatGPT citation", "Perplexity ranking", "AI Overviews", "passage-level content", "answer engine", "query fan-out", "be cited by AI", or any content brief that needs AI search visibility. Pairs with seo-content, onpage-seo, programmatic-seo, copywriting-engine.
---

# GEO / AEO Authoring

## Why this skill exists

48% of tracked Google queries now show AI Overviews per BrightEdge 2026 data — up from 30% twelve months prior. ChatGPT reached 900M weekly active users in February 2026. AI Overviews, AI Mode (Google's query fan-out search), Perplexity, ChatGPT search, and Gemini answers now intercept clicks before they reach BeautyOnTApp's pages. Ranking position 1 organically no longer guarantees the click.

BoT's current Semrush position (May 17 2026): 83% of organic traffic is brand search. Category capture is broken. The traffic loss to AI extractors compounds the existing weakness.

The fix is content engineered for AI citation, not just blue-link ranking. The methodology is well-documented:

- **Princeton/Georgia Tech/IIT Delhi/Allen AI** (Aggarwal et al., ACM KDD 2024 — *GEO: Generative Engine Optimization*): the canonical academic paper. Verified content-level interventions: statistics addition (+41% visibility), quotation addition (+28%), opening-paragraph answer structure (~+40%). The widely-cited 115% figure applies specifically to the "Cite Sources" strategy on rank-5 pages — most blog posts misattribute it.
- **Mike King (iPullRank)** *How AI Mode Works*: passage-level writing. Query fan-out retrieves passages, not pages. Each section must stand alone and be citable.
- **Aleyda Solis** *AI Search Optimization Checklist*: 40-60 word answer paragraph at the top of every page, extractable verbatim.

This skill operationalises those findings into PNCapital-specific authoring discipline.

## When to invoke

Auto-invoke when T asks for any of:
- AI Overview / AIO / AI Mode optimisation
- AEO / Answer Engine Optimisation
- GEO / Generative Engine Optimisation
- ChatGPT / Perplexity / Gemini citation strategy
- Content briefs that name AI visibility as a goal
- Passage-level content / query fan-out
- "Be cited by AI" / "rank in AI search"
- New content pieces targeting non-brand intent (because 83% of BoT traffic is already brand search — category capture is the gap)

Pair with `beautyontapp-seo-content` (general SEO strategy), `beautyontapp-onpage-seo` (page-level optimisation), `beautyontapp-programmatic-seo` (template pages), `beautyontapp-copywriting-engine` (when AI-optimised content is also customer-facing).

## What this skill produces

For each piece of content, the output includes:

1. **40-60 word opening answer paragraph** (the AI extraction candidate)
2. **Passage-level H2 structure** where each H2 introduces a section that stands alone and is citable independently
3. **Statistics block** with named sources (Princeton GEO +41% verified intervention)
4. **Quotation block** from named industry sources (Princeton GEO +28% verified intervention)
5. **FAQPage + Article JSON-LD schema** with all required @types
6. **Named author E-E-A-T credentials** (author name, credential, byline placement)
7. **AI bot access verification** for the page (GPTBot, ClaudeBot, PerplexityBot, Google-Extended in robots.txt)

## The 8-block content template

Every GEO/AEO page or section follows this structure. Skip blocks only with explicit reason.

### Block 1 — Title tag

Pattern: `[Query]: [Specific answer] | BeautyOnTApp`
- Under 60 chars.
- Includes primary query phrasing — AI extractors match query intent to title patterns.
- Brand suffix retains organic click-through if the page ranks blue-link too.

### Block 2 — Meta description

Pattern: `[40-60 char answer summary]. [10-20 char proof point]. [10-15 char CTA].`
- Under 155 chars.
- Includes one statistic or proof point (Princeton GEO statistics intervention).
- Maps to the opening paragraph but condensed.

### Block 3 — H1

Different phrasing from title. Question form is acceptable when the page targets a question query.

### Block 4 — Opening answer paragraph (the AI extraction candidate)

The single most important block.

- 40-60 words exactly.
- Directly answers the primary query in the first sentence.
- Contains one named statistic with attribution.
- Contains one named source.
- Written to be extracted verbatim by AI Overviews, Perplexity, ChatGPT, and AI Mode.
- Self-contained — does not require surrounding context to make sense.

Template:
> [Direct answer to query in one sentence]. [Supporting fact with statistic and named source]. [Specific BoT-relevant detail with named brand or product].

Example for "best hyaluronic acid serum south africa":
> The most effective hyaluronic acid serums for South African skin combine low and high molecular weight HA for multi-depth hydration. Dermatologist research published in the Journal of Cosmetic Dermatology (2024) shows multi-weight formulations deliver 42% more skin penetration than single-weight serums. BoT stocks COSRX, Some By Mi, and Axis-Y in this category.

### Block 5 — Passage-level H2 structure

4-6 H2 headings. Each H2 introduces a passage that:

- Stands alone (a query fan-out retrieval can lift just this section).
- Has its own internal answer paragraph (30-60 words at the top of the section).
- Cites at least one statistic or quotation in its body.
- Ends with a "BoT-specific application" sentence linking the general fact to a BoT product, service, or store.

Per Mike King (iPullRank): "Write at the passage level. AI Mode retrieves passages, not pages."

### Block 6 — Statistics block (Princeton GEO +41% intervention)

Minimum 3 named statistics. Format:
- Statistic with source name and publication date.
- Source should be authoritative (peer-reviewed journal, named industry research, named SA market data, BoT internal data).
- Avoid training-data figures — they may be outdated or hallucinated.

Forbidden:
- Statistics without a named source (refuse the field — output `[STAT NEEDS SOURCE]`).
- Statistics from training memory.
- "Studies show…" without naming the study.

### Block 7 — Quotation block (Princeton GEO +28% intervention)

Minimum 1, ideally 2 quotations from named industry sources. Format:
- Full quotation in quotation marks.
- Named author with credential.
- Publication and date.
- Topic relevance to the page.

Examples of valid quotation sources:
- Named SA dermatologists with verifiable practice locations
- Peer-reviewed journal authors
- Industry research bodies (CTPA, ISCN, regulatory bodies)
- Named brand founders / formulators

Forbidden:
- Invented quotations.
- "Experts say…" without naming the expert.
- Quotations attributed to "a leading dermatologist" without a name.

### Block 8 — FAQPage + Article JSON-LD schema

Every GEO/AEO page ships with both:

**FAQPage schema** — 3-5 Q&A pairs grounded in real consumer questions. Sources for questions:
- Google PAA (People Also Ask) for the primary query
- VoC mining from `beautyontapp-voc-mining` (real customer language)
- Competitor FAQ sections (gap-fill what they don't answer)

**Article schema** — full article markup with:
- `@type: "Article"` or `@type: "MedicalWebPage"` if claims are health-adjacent and evidence-backed
- `author` with `@type: "Person"`, name, credential, sameAs URL
- `publisher` with `@type: "Organization"`, name: "BeautyOnTApp", logo URL
- `datePublished` and `dateModified`
- `mainEntityOfPage`
- `description` matching meta description
- `image` with absolute URL

Optional but recommended for high-priority pages:
- `BreadcrumbList` schema
- `ItemList` schema if the page is a collection
- `Product` schema for product callouts (use Shopify ID as identifier per business rules)

## E-E-A-T author credentials

Every GEO/AEO page names an author with verifiable credentials. AI extractors increasingly weight authorship signals.

Required:
- Author name (full name, not initials).
- One named credential (dermatology degree, cosmetic chemistry background, beauty industry tenure, BoT consultation hours logged).
- Byline placement at top of article, not just bottom.
- `author` JSON-LD entry with `sameAs` pointing to verifiable profile (LinkedIn, professional registry, BoT team page).

If a piece of content has no verifiable author with relevant credential, do not invent one. Either:
- Identify a BoT team member with the relevant credential
- Use a generic "BeautyOnTApp Editorial Team" byline with the team page as `sameAs`
- Refuse the field and flag for T to assign a named author before publishing

## Robots.txt and AI bot access

GEO/AEO content requires the AI bots to be allowed in `robots.txt`. Verify and update:

```
User-agent: GPTBot
Allow: /

User-agent: ChatGPT-User
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: anthropic-ai
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: Perplexity-User
Allow: /

User-agent: Google-Extended
Allow: /

User-agent: CCBot
Allow: /
```

Default Shopify themes sometimes block these. Verify via `view-source:beautyontapp.com/robots.txt` before assuming access.

`llms.txt` at domain root: BoT business facts confirm this is live as of May 17 2026.

## Non-brand intent requirement

83% of BoT's current organic traffic is brand search. Brand-search pages do not need GEO/AEO discipline — they need conversion optimisation. GEO/AEO writing targets **non-brand intent**:

- Concern-based: "best serum for hyperpigmentation south africa"
- Ingredient-based: "what is niacinamide and what does it do"
- Category-based: "korean skincare south africa"
- Question-based: "how often should I exfoliate"
- Comparison-based: "hyaluronic acid vs glycerin"
- Local-based: "best skincare store sandton"

Every GEO/AEO brief must explicitly target a non-brand query. If the brief targets a brand query, redirect to `beautyontapp-cro-engine` or `beautyontapp-onpage-seo` instead.

## Source hierarchy for GEO/AEO claims

1. Peer-reviewed journals (cite journal name, year, DOI if available).
2. Named industry research (BrightEdge, Semrush, Conductor, Princeton GEO paper).
3. SA-specific market data (Stats SA, CTPA, named SA dermatology associations).
4. BoT internal data (Judge.me aggregate ratings, scan-to-purchase conversion rates, repeat-purchase data).
5. Named industry voices (dermatologists with verifiable credentials, named formulators, named brand founders).

Forbidden as sources:
- "Studies show" / "research suggests" without naming the study or research
- Training-memory statistics
- AI-generated statistics
- Competitor blog claims without verifying the primary source

## Princeton GEO interventions — verified evidence

From Aggarwal et al., *GEO: Generative Engine Optimization* (ACM KDD 2024):

| Intervention | Verified lift | Notes |
|---|---|---|
| Statistics addition | +41% visibility | Highest single content-level lever |
| Quotation addition | +28% visibility | Named sources required |
| Cite Sources | Up to 115% (rank-5 pages) | Most-misattributed figure in popular posts |
| Authoritative tone | +20% (in some categories) | Less reliable than 1-3 |
| Fluency optimisation | Marginal | Diminishing returns past readable baseline |
| Unique words / technical terminology | Modest | Works best in technical categories |
| Easy-to-understand structure | +20% | Maps to Block 5 passage-level structure |

Source: arxiv.org/abs/2311.09735 (verified arxiv entry, last revised 2024).

Mike King's *How AI Mode Works* extends this with the passage-level retrieval finding: AI Mode performs query fan-out at retrieval, then synthesises across retrieved passages from multiple pages. Pages that don't structure for passage retrieval lose to pages that do.

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| Writing a 1,500-word "ultimate guide" with no opening answer paragraph | AI extractors lift the first 40-60 words. Burying the answer means the AI cites the competitor that opened with theirs. |
| Statistics without sources | Princeton GEO +41% only applies to named, verifiable statistics. Unsourced stats are training-data hallucination risk. |
| "Experts say" / "studies show" | Princeton GEO quotation +28% requires the named source. Anonymous appeals to authority don't trigger the lift. |
| Schema markup applied to a page that contradicts its content | Schema-content mismatch is a Google manual action risk. The schema must reflect what's on the page. |
| FAQ schema with invented questions | If the FAQ doesn't appear on the rendered page, it's invalid schema. FAQs must be visible to users. |
| Brand-search content (targeting "beautyontapp" or store-name queries) | GEO/AEO is for non-brand intent. Brand queries need different optimisation. |
| Generic "best products for X" listicles with no BoT product callouts | Listicles without commercial intent waste authority. Every section should link general knowledge to specific BoT products or services. |

## Hard rules

- Every GEO/AEO page has Blocks 1-8. No exceptions.
- Every statistic carries a named source. No exceptions. `[STAT NEEDS SOURCE]` is the fallback.
- Every quotation carries a named author, publication, and date. No exceptions.
- Every page names an author with verifiable credentials. Anonymous content is forbidden.
- AI bot access verified in `robots.txt` before publishing.
- Schema markup matches rendered page content.
- Brand-search queries are redirected to `beautyontapp-cro-engine` or `beautyontapp-onpage-seo` — GEO/AEO is for non-brand intent only.
- Brand descriptions, ingredient claims, and stocking status follow the anti-fabrication rules from T's user preferences. Web_fetch the live page before writing positioning copy for any brand outside the confirmed SA-brand list and confirmed dermocosmetic list.

## Self-check before delivering

Run silently before shipping the brief or content:

1. Is the opening paragraph 40-60 words? Does it answer the query in sentence one?
2. Does the opening paragraph contain one named statistic with source?
3. Are H2 sections self-contained passages?
4. Does each H2 section have its own internal answer + statistic or quotation?
5. Are all statistics sourced? Any unsourced ones marked `[STAT NEEDS SOURCE]`?
6. Are all quotations attributed by name, publication, date?
7. Is FAQPage schema present with real consumer questions?
8. Is Article schema present with named author and credentials?
9. Is the page targeting non-brand intent?
10. Have AI bot access permissions been verified?

If any check fails, fix silently and re-deliver.

## What this skill does NOT do

- Does not generate the brand-search / homepage content — that's `beautyontapp-cro-engine`.
- Does not handle technical SEO audits — that's `beautyontapp-onpage-seo` + Screaming Frog.
- Does not handle programmatic SEO at scale — that's `beautyontapp-programmatic-seo` (though GEO/AEO blocks 1-8 apply to programmatic templates too).
- Does not write ad copy — that's `beautyontapp-copywriting-engine` and `beautyontapp-rsa-generator`.
- Does not configure Schema.org markup at the theme level — that's a Shopify theme task, separate dispatch.

## Model routing

- **New page brief from scratch**: Opus 4.7 with high effort. Multi-block reasoning, source hierarchy enforcement.
- **Existing page audit against GEO/AEO discipline**: Opus 4.7 with high effort. Reads attached page HTML + outputs gap analysis.
- **Programmatic template with GEO/AEO blocks 1-8**: Opus 4.7 with xhigh effort. Per-row uniqueness + source hierarchy.
- **Single block refresh** (e.g. rewrite the opening paragraph): Sonnet 4.6 with default thinking.
- **Schema markup authoring**: Sonnet 4.6 with high effort.

## Pairs with

- `beautyontapp-seo-content` — general SEO strategy and content calendar.
- `beautyontapp-onpage-seo` — technical on-page optimisation (titles, metas, internal links).
- `beautyontapp-programmatic-seo` — template pages at scale.
- `beautyontapp-copywriting-engine` — when AI-optimised content is also customer-facing brand copy.
- `beautyontapp-voc-mining` — sources real consumer questions for FAQPage schema.
- `beautyontapp-evidence-citations` — every claim carries a source.
- `beautyontapp-prompting-discipline` — XML scaffold + refuse-the-field defaults for the brief itself.
- `beautyontapp-audit-first` — read attached competitor pages or current BoT page before writing.

## Versioning

v1 — first deployed. Built from:

- Princeton/Georgia Tech/IIT Delhi/Allen AI: Aggarwal et al., *GEO: Generative Engine Optimization* (ACM KDD 2024, arxiv.org/abs/2311.09735).
- Mike King (iPullRank): *How AI Mode Works* — passage-level methodology.
- Aleyda Solis: *AI Search Optimization Checklist* (aleydasolis.com/en/ai-search/ai-search-optimization-checklist).
- BrightEdge 2026 data: 48% AIO presence on tracked queries (brightedge.com/resources/weekly-ai-search-insights/ai-overviews-one-year-presence-size-citing).
- TechCrunch 27 February 2026: ChatGPT 900M WAU.
- T's PNCapital business facts: 83% brand-search traffic, category capture broken, llms.txt live, AI bot access verified.

When Google AI Mode general availability ships (currently labs-only at the time of this writing), revisit Block 5 passage structure for any new retrieval pattern changes. When Perplexity, ChatGPT, or Gemini publish their own citation guidelines, fold them into the source hierarchy section.
