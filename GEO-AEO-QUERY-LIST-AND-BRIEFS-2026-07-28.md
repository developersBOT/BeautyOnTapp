# GEO/AEO Target Queries + First-Batch Page Briefs — 28 Jul 2026

Goal: get beautyontapp.com cited in Google AI Overviews (and AI Mode / Perplexity / ChatGPT answers) on **non-brand** queries — the class where AIOs appear and where BoT currently has near-zero footprint (May 2026 Semrush audit: 83% of organic traffic is brand search; category capture broken).

**Evidence discipline:** every product/brand callout below is restricted to vendors verified on the live store today (Admin API `productVendors`, 28 Jul 2026). Statistics carry sources found and read this conversation; anything unsourced is marked `[STAT NEEDS SOURCE]`. Search volumes are omitted — Semrush API units are exhausted; run the volume + AIO-presence baseline when units are topped up, before locking priority order.

---

## Part 1 — Target query list (16)

| # | Query | Intent class | Why BoT can win it (verified catalog ground) |
|---|---|---|---|
| 1 | korean skincare south africa | Category | 25+ K-beauty vendors live: COSRX, Anua, Beauty of Joseon, SKIN1004, Some By Mi, Axis-Y, Torriden, Medicube, Isntree, Mixsoon, Laneige, Innisfree, Biodance, Benton, Dr.Althea, Purito Seoul, Haruharu Wonder, Tocobo, TIAM, Barulab, K-Secret, Erborian, Arencia, Bonak, First Seed |
| 2 | k-beauty online store south africa | Category | Same catalog; local delivery + physical presence |
| 3 | best serum for hyperpigmentation south africa | Concern | Axis-Y, Some By Mi, Skin Functional, La Roche-Posay stocked; SA-relevant skin-of-colour angle |
| 4 | skincare for dark marks on african skin | Concern | Skin-of-colour focus; SA brands (Lelive, Nilotiqa, Mzuri Skin) + derm brands stocked |
| 5 | best moisturizer for dry skin south africa | Concern | CeraVe, Eucerin, Avène, Bioderma, La Roche-Posay + K-beauty barrier lines stocked |
| 6 | what does snail mucin do | Ingredient | COSRX and Benton stocked (snail category signatures) |
| 7 | niacinamide benefits for skin | Ingredient | Anua, Skin Functional, Neutriherbs stocked |
| 8 | what is centella asiatica (cica) in skincare | Ingredient | SKIN1004 (centella house brand) + Purito Seoul stocked |
| 9 | rice water / rice extract skincare benefits | Ingredient | Beauty of Joseon, Mixsoon stocked |
| 10 | niacinamide vs vitamin c | Comparison | Both categories stocked (Anua, TIAM, Skin Functional) |
| 11 | snail mucin vs hyaluronic acid | Comparison | COSRX/Benton + Torriden/Isntree stocked |
| 12 | mineral vs chemical sunscreen | Comparison | Tocobo, Beauty of Joseon, Black Girl Sunscreen, Eucerin stocked |
| 13 | how often should i exfoliate | Question | AAD guidance sourced (below); COSRX/Some By Mi exfoliant lines |
| 14 | korean skincare routine order | Question | Full routine coverage across stocked vendors |
| 15 | skincare store sandton / johannesburg / pretoria | Local | Verified stores (locations metaobjects, 28 Jul): Sandton City, Fourways Mall (Sandton), Mall of Africa (Midrand), Menlyn Park (Pretoria) |
| 16 | korean skincare store durban / cape town / east london | Local | Verified stores: Gateway (Umhlanga, Durban), Canal Walk (Century City, Cape Town), Hemingways Mall (East London) |

**Verified store locations (from the live `locations` metaobjects, 28 Jul 2026)** — one local landing page per metro, LocalBusiness schema each: Sandton City (83 Rivonia Rd, Sandhurst) · Fourways Mall (Witkoppen, Sandton) · Mall of Africa (Midrand) · Menlyn Park (Pretoria) · Gateway Theatre of Shopping (Umhlanga Ridge, Durban) · Canal Walk (Century City, Cape Town) · Hemingways Mall (East London). Data-hygiene flag: the Sandton City, Canal Walk and Hemingways metaobjects carry malformed latitude/longitude values (e.g. `-2610868.0`; Canal Walk longitude empty) — the locator's nearest-store geolocation can never select those three stores, and LocalBusiness schema needs correct geo coords.

Priority for the first batch: #1, #3, #6, #10, #13 (briefs below) — one per intent class, maximizing catalog fit and AIO-trigger likelihood. Re-rank after the Semrush volume/AIO baseline.

---

## Part 2 — First-batch briefs (8-block template)

### Brief 1 — "korean skincare south africa" (Category — flagship)

- **Page:** new landing/guide page (not the raw collection) linking into the K-beauty collections.
- **Block 1 Title:** `Korean Skincare South Africa: Authentic K-Beauty Brands | BeautyOnTApp` (≤60 chars — trim at authoring).
- **Block 2 Meta:** 40–60-char answer + proof point (SA skincare market US$813m/2025, Statista) + CTA. ≤155 chars.
- **Block 3 H1:** `Where to Buy Authentic Korean Skincare in South Africa`
- **Block 4 Opening answer (40–60 words, draft):** "Authentic Korean skincare is available in South Africa through local stockists that import directly from Korean brands. South Africa's skin-care market reached an estimated US$813 million in 2025 and is growing 4.8% annually (Statista Market Forecast, 2025). BeautyOnTApp stocks 25+ K-beauty brands including COSRX, Anua, Beauty of Joseon and SKIN1004, with local delivery."
- **Block 5 H2 passages (each self-contained, 30–60-word internal answer + one stat/quote + BoT application sentence):**
  1. What makes Korean skincare different (formulation philosophy)
  2. K-beauty brands available in South Africa (verified stocked-brand list)
  3. How to spot authentic vs grey-import K-beauty
  4. Building a Korean routine for SA climate
  5. Delivery, returns and where to start
- **Block 6 Stats (≥3):** (a) Statista ZA skin-care US$813.30m 2025, CAGR 4.77% 2025–2029 — sourced this conversation; (b) BoT internal: 25+ K-beauty vendors live on store (Admin API, 28 Jul 2026); (c) `[STAT NEEDS SOURCE — K-beauty global export/growth figure; pull from Statista/Euromonitor K-beauty report at authoring]`.
- **Block 7 Quote (≥1):** named source required — options: named Statista/Euromonitor analyst line from the ZA report, or a named K-beauty founder statement from a verifiable interview. Do not publish with an anonymous quote.
- **Block 8 Schema:** Article + FAQPage (3–5 real PAA questions — pull live PAA at authoring; candidates: "Is Korean skincare good for African skin?", "Why is Korean skincare so popular?", "Is COSRX authentic in South Africa?") + BreadcrumbList + ItemList of linked collections.
- **Author:** named BoT team member with credential, or "BeautyOnTApp Editorial Team" + team page `sameAs`. **[NEEDS T: assign]**

### Brief 2 — "best serum for hyperpigmentation south africa" (Concern)

- **Block 4 Opening answer (draft):** "The best-evidenced serums for hyperpigmentation contain niacinamide, which reduced visible dark spots within 4 weeks at 5% concentration in clinical testing (Hakozaki et al., British Journal of Dermatology, 2002). For South African skin tones, gentle actives matter: aggressive exfoliation can trigger post-inflammatory marks in darker skin (American Academy of Dermatology). BeautyOnTApp stocks niacinamide serums from Axis-Y, Some By Mi and Skin Functional."
- **H2 passages:** 1) What causes hyperpigmentation (incl. PIH in darker skin tones — the SA-specific angle competitors miss); 2) Niacinamide: the evidence; 3) Other proven actives (azelaic, vitamin C, tranexamic — each `[STAT NEEDS SOURCE]` until pulled); 4) What to avoid on melanin-rich skin (AAD caution on strong chemical/mechanical exfoliation where dark spots follow inflammation); 5) Serums stocked at BoT by budget.
- **Stats:** (a) Hakozaki et al. 2002, BJD — 5% niacinamide reduced dark spots in 4 weeks; melanosome-transfer inhibition up to 68% in vitro; (b) JAAD split-face study — 5% nicotinamide significantly decreased hyperpigmented area at 4–8 weeks; (c) AAD: strong exfoliation cautioned for darker skin tones prone to post-inflammatory marks.
- **Quote:** named SA dermatologist with verifiable practice preferred **[NEEDS SOURCING at authoring — do not invent]**; fallback: named study author quoted from the paper.
- **Schema:** Article + FAQPage. Health-adjacent claims must match cited studies exactly — no "cure/remove" language.
- **Product callouts:** vendor-level verified (Axis-Y, Some By Mi, Skin Functional, La Roche-Posay). Specific product names: verify against live catalog at authoring.

### Brief 3 — "what does snail mucin do" (Ingredient)

- **Block 4 Opening answer (draft):** "Snail mucin (snail secretion filtrate) hydrates skin and supports repair: it contains hyaluronic acid, glycoproteins and allantoin, and reduced transepidermal water loss for up to 24 hours after application in testing (Journal of Cosmetic Dermatology review, 2024). Evidence for wound-repair effects is promising but still early-stage. BeautyOnTApp stocks snail-mucin ranges from COSRX and Benton."
- **H2 passages:** 1) What snail mucin is and how it's collected; 2) Hydration: the TEWL evidence; 3) Repair/soothing: what studies show (SSF improved wound closure and collagen deposition in preclinical models — framed honestly as preclinical); 4) Who should use it / who should skip it; 5) COSRX vs Benton snail products at BoT.
- **Stats:** (a) TEWL reduction at application, 1h and 24h — Singh et al. review, *Journal of Cosmetic Dermatology*, 2024; (b) SSF wound-closure/collagen findings — PMC preclinical study (2021); (c) composition (HA, allantoin, glycoproteins, AMPs) — same review. Honesty rule: label preclinical evidence as preclinical — the review itself stresses larger trials are needed, and saying so is a citability feature, not a weakness.
- **Quote:** pull a direct sentence from the named 2024 JCD review authors.
- **Schema:** Article + FAQPage (candidates: "Is snail mucin cruelty-free?", "Can snail mucin cause breakouts?", "Is snail mucin good for oily skin?" — confirm against PAA).

### Brief 4 — "niacinamide vs vitamin c" (Comparison)

- **Block 4 Opening answer (draft):** "Niacinamide and vitamin C both target dark marks and dullness but work differently: niacinamide blocks pigment transfer (up to 68% melanosome-transfer inhibition in vitro, British Journal of Dermatology, 2002) and strengthens the barrier, while vitamin C is an antioxidant that inhibits melanin synthesis. They can be used together. BeautyOnTApp stocks both, from Anua, TIAM and Skin Functional."
- **H2 passages:** 1) How each works (mechanism); 2) Which for dark marks; 3) Which for dullness/antioxidant defence `[STAT NEEDS SOURCE — vitamin C clinical figure; pull a named ascorbic-acid study at authoring]`; 4) Can you layer them (the old "don't combine" myth — debunk with a named source); 5) Picking one at BoT by skin type/budget.
- **Stats:** niacinamide anchors as Brief 2; vitamin C side requires sourcing at authoring — do not publish with the vitamin C column unsourced.
- **Schema:** Article + FAQPage.

### Brief 5 — "how often should i exfoliate" (Question)

- **Block 4 Opening answer (draft):** "Most skin types should exfoliate once or twice a week to start, adjusting by response — stronger exfoliants need less frequent use (American Academy of Dermatology). Oily, resilient skin may tolerate 2–3× weekly; dry or sensitive skin suits gentler acids weekly. If you have a darker skin tone prone to dark marks, the AAD advises avoiding aggressive exfoliation."
- **H2 passages:** 1) Chemical vs physical exfoliation; 2) Frequency by skin type (AAD-grounded); 3) Exfoliating melanin-rich skin safely (SA-relevant, PIH caution); 4) Signs you're over-exfoliating; 5) BoT exfoliant picks (COSRX, Some By Mi ranges — product names verified at authoring).
- **Stats/refs:** AAD "How to safely exfoliate at home" (method-by-skin-type, darker-skin-tone caution); frequency guidance 1–2× weekly start. Third stat `[STAT NEEDS SOURCE — over-exfoliation/barrier-damage figure]`.
- **Schema:** Article + FAQPage.

---

## Standing rules for all five (from the GEO/AEO playbook)

- Opening paragraph 40–60 words, answer in sentence one, one named stat, self-contained.
- Every H2 = liftable passage with its own mini-answer.
- No unsourced stats (`[STAT NEEDS SOURCE]` blocks publication), no anonymous quotes, no invented FAQ items (must match rendered page + real PAA).
- Named author with credential or Editorial Team + team page — **T to assign before first publish**.
- AI-bot access: verified 28 Jul — robots.txt is Shopify default (Googlebot unrestricted; AIO uses standard Googlebot), no nosnippet anywhere in the theme; llms.txt live per May business facts.
- Measure: once Semrush API units are topped up, run the AIO-presence baseline on all 16 queries (who's cited today), then re-check 4–6 weeks after publishing.

## Sources gathered this conversation

- Hakozaki et al. 2002 / JAAD niacinamide studies: jaad.org (S0190-9622(04)03457-7), mdpi.com/2076-3921/10/8/1315
- Snail mucin: onlinelibrary.wiley.com/doi/10.1111/jocd.16269 (JCD 2024 review), pmc.ncbi.nlm.nih.gov/articles/PMC8402640 (SSF wound model), pmc.ncbi.nlm.nih.gov/articles/PMC12452115
- SA market: statista.com/outlook/cmo/beauty-personal-care/skin-care/south-africa (US$813.30m 2025, CAGR 4.77%)
- Exfoliation: aad.org/public/everyday-care/skin-care-secrets/routine/safely-exfoliate-at-home
- Catalog: Shopify Admin API productVendors, live store, 28 Jul 2026
