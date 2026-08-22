# Google Reviews — Store Audit Prompt (for Gemini)

A copy-paste prompt for Gemini (use a browsing-enabled model, or Deep Research)
that audits the Google review footprint of every BeautyOnTApp location and online
store, and returns a ranked report you can forward to the team as-is.

## Before you send it

Fill in the two INPUT blocks at the top of the prompt:

- **INPUT 1** — the physical store list (name, address, and the Google Maps URL if
  you have it). These are not in this repo; the app fetches locations from the API
  at runtime, so they have to come from you or from the Shopify/GBP admin.
- **INPUT 2** — the online store domains. `beautyontapp.net` is pre-filled (it is
  the API host used throughout this app); add the rest.

Everything else is ready to go.

## How it behaves

The prompt is written so Gemini **marks what it cannot verify instead of estimating
it**. Review counts are exactly the kind of number a model will invent confidently,
so a half-filled input block gives you a shorter honest report, not a padded one.
Expect some rows to come back `NOT VERIFIED` — that is the prompt working.

It also refuses to state Google's policy thresholds from memory (seller-ratings
minimums, review policy) and forces Gemini to quote and cite the current Google
support docs instead. Those thresholds change.

## What it returns

1. An exec summary you can paste into Slack.
2. A priority table, scored 0–100, sorted most-urgent-first.
3. A one-card-per-store action list with named owners and 30-day targets.
4. A data-gaps table listing what could not be verified and what would unblock it.
5. A sources appendix.

---

## The prompt

```text
You are a local-search and Google Ads analyst. Audit the Google review footprint
of a South African multi-location beauty retailer and produce a report its
marketing team can act on this week. The reader is a marketing manager, not an
SEO specialist — write plainly.

=====================================================================
INPUT 1 - PHYSICAL STORES TO AUDIT
=====================================================================
Audit exactly these locations. Do not add, merge, split, or invent any location.

  1. <store name> | <full street address, suburb, city> | <Google Maps URL if known>
  2. <store name> | <full street address, suburb, city> | <Google Maps URL if known>
  3. ...
  (add or remove rows as needed)

If no Google Maps URL is given, search Google Maps for the store name plus its
city. Match a profile only when the name, street address and business category
all line up. If you cannot match with high confidence, mark that row UNMATCHED
and move on. Never audit a profile you are not certain belongs to this business.
Auditing the wrong profile is worse than reporting a gap.

=====================================================================
INPUT 2 - ONLINE STORES (for the Google Ads seller-ratings check)
=====================================================================
  1. beautyontapp.net
  2. <other store domains>

=====================================================================
GROUND RULES - READ THESE BEFORE COLLECTING ANYTHING
=====================================================================
These override every other instruction in this prompt, including the output
format. If following the output format would require breaking one of these,
break the format.

1. Every number in this report must come from a page you actually opened during
   this session. Next to each figure, give the URL and the date you read it.
2. If you cannot open a profile, or a figure is not displayed on it, write
   "NOT VERIFIED - <reason>". Never estimate, approximate, interpolate, average,
   or recall a figure from training data.
3. Report figures exactly as displayed. Do not round "1,247 reviews" to "~1,200".
4. Review counts and ratings are live figures that drift daily. Stamp the whole
   report with the date and time you collected the data.
5. If Google Maps and Google Search show different counts or ratings for the same
   profile, report both and flag the discrepancy. Do not silently pick one.
6. An empty cell is a failure. A cell marked NOT VERIFIED is correct work. A
   report with 4 verified stores and 3 marked NOT VERIFIED is more useful to me
   than 7 confident-looking rows, and I will spot-check.
7. Do not state any Google policy, threshold, or eligibility requirement from
   memory. Look up the current Google support documentation, quote the relevant
   sentence verbatim, and cite the URL. If you cannot find it, say so.
8. Do not infer a store's performance from the neighbourhood, the brand, or how
   other stores in the list are doing.

=====================================================================
STEP 1 - COLLECT, PER PHYSICAL STORE
=====================================================================
For each location in INPUT 1, open its Google Business Profile (Maps and the
Search knowledge panel) and record:

  Identity
  - Profile name exactly as displayed
  - Full address as displayed
  - Primary business category, and any secondary categories
  - The Maps URL you used
  - Whether the profile appears claimed/verified, if visible

  Review health
  - Total review count
  - Average star rating, to one decimal
  - Number of reviews posted in the last 90 days (if the interface does not let
    you count this reliably, say so rather than guessing)
  - Date of the most recent review
  - Number of 1-star and 2-star reviews
  - The single most repeated complaint across the negative reviews, with one
    verbatim quote and its date. If there is no clear pattern, say "no recurring
    theme".
  - The single most repeated compliment, with one verbatim quote and its date

  Owner engagement
  - How many of the 20 most recent reviews have an owner response
  - Date of the most recent owner response
  - Whether negative reviews specifically are being answered

  Profile completeness - mark each present or missing
  - Opening hours set, and any special-hours set
  - Phone number
  - Website link, and whether it points to a store-specific page or a generic
    homepage
  - Business description
  - Products or services listed
  - Booking/appointment link
  - Photo count, and roughly how many are owner-posted vs customer-posted
  - Date of the most recent owner-posted photo or update

=====================================================================
STEP 2 - LOCAL BENCHMARK, PER PHYSICAL STORE
=====================================================================
For each location, find the 3 nearest comparable businesses - beauty retailers,
skincare stores, cosmetics chains - within roughly 5 km. For each, record name,
review count, average rating, and the Maps URL.

Then give, per location, the median review count and median rating of those 3.
This is the local par. A store is not "bad" at 80 reviews if local par is 60, and
is not "fine" at 300 if local par is 900.

If you cannot find 3 comparable businesses near a location, use what you find and
say how many you used.

=====================================================================
STEP 3 - SCORE AND RANK
=====================================================================
Score each verified location 0-100. Higher means more urgent. Show your working
for each component so the team can argue with it.

  Volume gap - up to 40 points
    ((local par review count - store review count) / local par review count),
    clamped to 0-1, multiplied by 40. A store at or above par scores 0.

  Rating risk - up to 25 points
    Below 4.0 = 25 | 4.0 to 4.3 = 15 | 4.4 to 4.6 = 8 | above 4.6 = 0

  Velocity - up to 20 points
    Reviews in the last 90 days:
    0 = 20 | 1-2 = 14 | 3-5 = 8 | 6-10 = 4 | more than 10 = 0

  Owner responsiveness - up to 15 points
    Share of the 20 most recent reviews with an owner reply:
    under 25% = 15 | 25-50% = 10 | 51-80% = 5 | over 80% = 0

  Tier: 70+ Critical | 45-69 High | 25-44 Medium | under 25 Maintain

Any location with an unverified input for a component: score the components you
can, state the partial score as a range, and label it PARTIAL. Do not fill the
missing component with a default value.

=====================================================================
STEP 4 - GOOGLE ADS IMPACT
=====================================================================
Explain, for this business specifically, how the review gaps above affect paid
performance. Cover at least:

  - Location assets / location extensions: which audited stores are eligible to
    show in ads, and what a missing or unverified profile costs.
  - Seller ratings in Search ads: state the current eligibility requirements by
    quoting Google's own support documentation and citing the URL. Then say, for
    each domain in INPUT 2, whether it currently appears to meet them and what
    evidence you used. If you cannot determine this from public sources, say so
    and name what account-side data would settle it.
  - Store visits and local reach in Performance Max: how profile completeness and
    review volume feed it, cited to Google documentation.

Do not assert a threshold number without a quote and a URL.

=====================================================================
STEP 5 - COMPLIANCE GUARDRAIL
=====================================================================
The team will read this report as permission to go and get reviews. Before the
recommendations, include a short section stating what they must not do.

Check Google's current review policies and quote the relevant lines with URLs.
At minimum, address whether these are permitted:
  - offering a discount, free product, loyalty points, or a competition entry in
    exchange for a review
  - asking only satisfied customers for reviews while diverting unhappy ones to a
    private form ("review gating")
  - staff, family, or agency-posted reviews
  - buying reviews from third-party services
  - bulk-soliciting reviews from a purchased or scraped contact list

State the actual consequence of breaching these, per Google's documentation.

Separately: this is a South African business, so any review-request flow that
uses customer contact details is a direct-marketing activity under POPIA. Flag
that the team must confirm lawful basis and a working opt-out before any bulk
SMS, WhatsApp, or email review request. Do not attempt to give legal advice -
flag it as a check to run.

=====================================================================
STEP 6 - OUTPUT FORMAT
=====================================================================
Produce exactly these five sections, in this order.

  1. EXECUTIVE SUMMARY
     Under 150 words, plain language, no jargon. Name the stores in trouble, the
     single biggest pattern across the estate, and the one action that matters
     most this month. Written so it can be pasted into Slack unedited.

  2. PRIORITY TABLE
     One row per location, sorted by score descending. Columns:
     Store | Reviews | Rating | Local par (reviews) | Gap | Last 90 days |
     Owner reply rate | Score | Tier
     Mark PARTIAL rows clearly. Put UNMATCHED and NOT VERIFIED rows at the
     bottom, below the scored ones, not interleaved.

  3. STORE ACTION CARDS
     One short card per location, Critical and High tiers first. Each card:
     - What is wrong, in two sentences
     - Exactly 3 actions, each concrete enough to do without asking a follow-up
       question. "Reply to the 6 unanswered 1-star reviews from June-August" is
       an action. "Improve review engagement" is not.
     - Who should own it: store manager, marketing, or head office
     - A 30-day target expressed as a number

  4. DATA GAPS
     A table of every field you marked NOT VERIFIED or UNMATCHED, with the reason
     and the specific thing that would unblock it - a Maps URL, GBP admin access,
     a Google Ads account export. Be specific about which one.

  5. SOURCES
     Every URL you opened, grouped by store, each with the date you read it.

=====================================================================
STOP CONDITIONS
=====================================================================
- If you can verify fewer than half the locations in INPUT 1, do not pad the
  report. Deliver the verified stores, the gaps table, and a one-line note that
  the audit is partial and why.
- If INPUT 1 is still showing placeholder text when you start, stop and say the
  store list has not been filled in. Do not search for the retailer's locations
  yourself and audit whatever you find.
```

---

## Notes on what this prompt deliberately does not do

- **It does not name the stores.** The location list is not in this repo — the app
  pulls it from the API at runtime — so inventing a store list here would have put
  fabricated addresses into a document going to the team.
- **It does not hardcode Google's seller-rating threshold or review policy.** Those
  numbers change, and a wrong threshold in a team report leads to the wrong call
  about whether a domain is eligible. Gemini is required to quote and cite the
  live docs instead.
- **It does not treat "get more reviews" as automatically safe.** Step 5 exists
  because the usual response to this kind of report is a review drive that quietly
  breaks Google's review policy or POPIA.
