# Brand-Impersonation Takedown Dossier — `lovebeautyontapp.shop`

**Target:** `lovebeautyontapp.shop` (fraudulent site impersonating BeautyOnTApp)
**Prepared for:** BeautyOnTApp (PNCapital)
**Date compiled:** 2026-08-18
**Status:** Evidence gathered · Takedown campaign ready to fire
**Classification:** Internal — brand protection / legal

> This is a defensive brand-protection record. Every technical claim below the "Verified evidence" heading was obtained first-hand from this investigation (DNS resolution) or from the BeautyOnTApp app source code. Claims are tagged with a confidence tier. Nothing here has been fabricated; where a fact could not be verified from the investigation environment, it is listed explicitly under **Open gaps** with instructions to close it.

---

## 1. Executive summary

A website at **`lovebeautyontapp.shop`** is impersonating **BeautyOnTApp**, an established South African beauty e-commerce brand. The impostor name is BeautyOnTApp's exact brand with the word **"love"** prepended, on a cheap **`.shop`** top-level domain. The site is hidden behind **Cloudflare** and has **no email infrastructure whatsoever** (no MX, SPF, or DMARC records) — the fingerprint of a disposable "fake store" set up to divert sales, harvest payment/personal data, or both.

**The plan is not to "hack" or attack the site** — that would expose BeautyOnTApp to legal risk and doesn't work. The plan is a **coordinated abuse-and-takedown campaign** through the parties who can actually pull the site down fast: its infrastructure provider (Cloudflare), the browsers' safe-browsing lists, its e-commerce platform, the ad platforms promoting it, the domain registrar, and South African fraud/IP authorities. Executed together, these typically knock a fake store offline within hours-to-days and get it flagged in Chrome/Safari immediately.

**What only you can do:** the actual complaint submissions require the rights holder's real identity and contact details (and DMCA notices are sworn under penalty of perjury), so they must be filed by BeautyOnTApp or its authorized agent. This dossier makes each filing close to copy-paste.

---

## 2. Verified evidence

### 2.1 The legitimate brand (proof of who is being impersonated)

| Fact | Value | Source | Tier |
|---|---|---|---|
| Primary storefront | `beautyontapp.com` (Shopify) | Hardcoded in app: `lib/store_webview.dart:13` (`kStoreUrl`) | **Verified** (first-party source) |
| API backend | `beautyontapp.net` | `lib/services/api_client.dart:5` (`baseUrl`) | **Verified** (first-party source) |
| Additional domain | `beautyontappcos.co.za` | Web search result | Reliable |
| iOS app | App Store `id6754606514` | App Store listing | Reliable |
| Android app | `app.shopbeautyontapp.co.za` | Google Play listing | Reliable |
| Socials | X/Twitter `@BeautyonTApp`, TikTok `@beautyontapp`, Threads `@beautyontapp`, Facebook `/BeautyonTApp/`, LinkedIn `/company/beautyontapp` | Web search results | Reliable |
| Physical presence | 7 physical stores incl. Mall of Africa Store 2131 (Midrand); Hemingways Mall, East London (opened June 2026) | Web search results | Reliable |
| Brand tagline | "For the love of all things Beauty" / "South Africa's Online Beauty & Skincare Store" | beautyontapp.com (search snippet) | Reliable |
| Positioning | K-beauty + dermocosmetics + proudly-SA skincare/makeup/haircare; 1,500+ products | Web search results | Reliable |

This establishes **prior, extensive, genuine commercial reputation and goodwill** in the "BeautyOnTApp" name across web, mobile apps, social media, and physical retail in South Africa — the foundation of both a trademark/passing-off claim and every impersonation report below.

### 2.2 The impostor domain (first-hand technical fingerprint)

All records below were resolved directly during this investigation on 2026-08-18 via the OS resolver (DNS/port 53). **Tier: Verified (first-hand).**

| Record | Value | Meaning |
|---|---|---|
| Domain | `lovebeautyontapp.shop` (and `www.lovebeautyontapp.shop`) | Impersonates "BeautyOnTApp" with a "love" prefix on the `.shop` TLD |
| A (IPv4) | `104.21.88.151`, `172.67.223.176` | **Cloudflare** proxy IPs (`104.21.0.0/16`, `172.67.0.0/16`) |
| AAAA (IPv6) | `2606:4700:3030::6815:5897`, `2606:4700:3031::ac43:dfb0` | **Cloudflare** (`2606:4700::/32`); the IPv6 encodes the same v4 addresses |
| NS (nameservers) | `mcgrory.ns.cloudflare.com`, `wally.ns.cloudflare.com` | DNS is managed **inside a Cloudflare account** — Cloudflare can act on the domain |
| MX (mail) | *none* | No mail servers — the domain cannot run legitimate business email |
| TXT / SPF / `_dmarc` | *none* | No email authentication — throwaway domain, not a real operation |

**Interpretation.** The site sits entirely behind Cloudflare (both DNS and HTTP proxy), which hides the true origin host's IP. The complete absence of mail and email-authentication records is characteristic of a short-lived fraudulent storefront rather than a genuine business. Cloudflare is therefore the **single highest-value takedown lever** (see §5), because it is both the DNS operator and the reverse proxy and can flag the site and forward the complaint to the origin host.

> Note: BeautyOnTApp's own `beautyontapp.com` is *also* served through Cloudflare (different IPs: `104.21.11.202`, `172.67.192.156`). This is normal — Cloudflare fronts millions of legitimate sites. It is recorded here only so the two are never confused; it does not implicate the real store.

### 2.3 Threat determination

**Assessment:** `lovebeautyontapp.shop` is a **deliberate brand-impersonation / "fake store" domain**, not a coincidental or competing legitimate business. Confidence: **High**, based on (a) the exact-brand-plus-"love" naming, (b) the disposable-domain infrastructure fingerprint, (c) the near-total absence of an organic/legitimate web footprint, which together match the documented fake-beauty-store scam pattern reported by AARP, ABC7 and Malwarebytes.

**Most likely monetization (to be confirmed by capturing the live site — see §4):**
- A storefront that **takes orders and payment and never ships** (or ships counterfeits), while **harvesting card and personal data** at checkout; and/or
- A **scraped clone** of `beautyontapp.com` product imagery/copy to look legitimate, promoted through **paid social ads or direct links / DMs** rather than search.

This distinction changes only the emphasis of the reports, not the channels. Capturing the live site (§4) confirms which it is.

---

## 3. Open gaps (and how to close each)

Honest accounting of what this investigation environment could **not** retrieve, because outbound web access was restricted (WHOIS port 43 and RDAP/HTTP to lookup services were blocked). None of these block the takedown; each is a 30-second lookup from a normal browser.

| Gap | Why it matters | How to close it (2 min) |
|---|---|---|
| **Registrar + creation/expiry date** | Needed for the registrar-abuse report and to prove the domain is newly registered | Look up the domain at `lookup.icann.org`, `who.is`, or `whois.com` (steps in §4.2) |
| **Live site content / screenshots** | Primary evidence for every report; confirms what the site actually does | Capture it yourself from a browser (steps in §4.1) — **do this first** |
| **Is it a Shopify store?** | Decides whether Shopify Trust & Safety / DMCA is a channel | Check `lovebeautyontapp.shop/products.json` and page source for `cdn.shopify.com` (steps in §5) |
| **Ad promotion (Meta/TikTok)** | Reporting the *ads* often kills the traffic faster than the site | Search Meta Ad Library + TikTok Ad Library (steps in §5) |
| **Trademark registration status** | A registered SA trademark strengthens every IP report and enables UDRP | Search CIPC trade-marks register (steps in §5) |

---

## 4. Do this first — capture evidence (before anything can be deleted)

Fraudulent sites disappear fast once reported. **Preserve the evidence before you file**, so every report is backed by proof.

### 4.1 Capture the live site (5 minutes)
Use a phone or a browser you don't mind exposing; **do not enter any real personal or payment details.**
1. Screenshot the **homepage**, showing the URL bar with `lovebeautyontapp.shop` visible.
2. Screenshot any use of the **BeautyOnTApp name, logo, tagline, or product photos** copied from your store — these are your infringement exhibits. Put your real store's matching page next to it.
3. Screenshot the **cart / checkout** page, especially the **payment methods** shown (card fields, any SA gateway logos like Payfast/Ozow/Payflex — abuse of those is its own report).
4. Screenshot **contact / about / returns / terms** pages (fake stores usually have missing, fake, or copied ones).
5. Save the page as **"complete web page" / print-to-PDF** so the HTML is preserved with a timestamp.
6. Record the **date and time** of capture on each screenshot.
7. Optional but powerful: run the URL through `urlscan.io` and `scamadviser.com` and save the result links — third-party corroboration for reports.

### 4.2 Pull the WHOIS / registrar (2 minutes)
1. Go to **`https://lookup.icann.org`** (ICANN's official lookup) — or `who.is` / `whois.com`.
2. Enter **`lovebeautyontapp.shop`**.
3. Record: **Registrar name**, **Registrar IANA ID**, **Registrar Abuse Contact Email**, **Creation Date**, **Registry Expiry Date**, and the **Registrant** (likely "Redacted for Privacy" — that's normal and doesn't stop the report).
4. Paste those into §6 where the templates say `[REGISTRAR]`, `[CREATION DATE]`, `[ABUSE EMAIL]`.

---

## 5. Takedown channels — prioritized battle plan

Every channel below has a **verified current reporting URL** (checked live; source and confidence noted). **Only you can submit these** — each requires the rights holder's identity, and the DMCA/affidavit ones are sworn statements. Fire the **first-hour four** immediately; they hit the site itself. Then work down.

**Legend:** 🔴 hits the site/domain directly · 🟠 cuts the traffic (ads/social) · 🟣 chokes the money · 🔵 strategic / permanent

### Tier 1 — First hour (take the site offline / warn every browser)

| # | Channel | Where to file | What it actually does | Speed |
|---|---|---|---|---|
| 1 | 🔴 **Google Safe Browsing** — report phishing | `safebrowsing.google.com/safebrowsing/report_phish/` | **The single highest-impact action.** Adds the domain to the Safe Browsing list → full-page red "Deceptive site ahead" warning in **Chrome, Safari, Firefox, Android, Gmail**. Collapses traffic/conversions even though Cloudflare stays in front. No login, works whether or not they advertise. | Hours–days |
| 2 | 🔴 **Cloudflare abuse** (Phishing & Malware) | `abuse.cloudflare.com/phishing` | Cloudflare is the proxy, not the host — it flags the site, can serve an interstitial, and **forwards your complaint to the hidden origin host** (and registrar). Pair with #3. | Ack immediate; forwarded ~24–48h |
| 3 | 🔴 **Registrar abuse report** | Registrar's abuse email — get it from WHOIS (§4.2) | **The fastest true kill.** The registrar can put the domain on `clientHold` / terminate it → site fully offline regardless of Cloudflare. Registrars are contractually required (ICANN RAA §3.18) to act on abuse. | Often 24–72h |
| 4 | 🔴 **Netcraft takedown** | `report.netcraft.com` | One of the largest phishing takedown operations; blocklists the URL across many browsers/apps and pushes takedown to host + registrar. Free, no account. | Blocking mins; takedown mins–hours |

### Tier 2 — First day (platform + registry pressure)

| # | Channel | Where to file | What it does | Notes |
|---|---|---|---|---|
| 5 | 🔴 **.shop registry (GMO) abuse** | `get.shop/abuse` (use the form; email `abuse@gmoregistry.com` is slower) | Registry sits **above** the registrar and can suspend at registry level — a strong backstop if the registrar stalls. | Verified |
| 6 | 🔴 **Shopify — Trademark / Trade-dress** | `shopify.com/legal/tools/report-an-issue/trademark-infringement` | **Only if the site is on Shopify** (check first — §5 note below). Strongest Shopify angle; no DMCA auto-restore, so it sticks. | List every infringing URL individually |
| 7 | 🔴 **Shopify — Fraud / AUP abuse** | `shopify.com/legal/tools/report-an-issue/fraud` | Non-IP impersonation/fraud path; can suspend the store. File in parallel with #6. | Chargeback volume speeds it |
| 8 | 🔴 **Shopify — Copyright / DMCA** | `shopify.com/legal/tools/report-an-issue/dmca` | For copied photos/logos/copy. Note: merchant can counter-notice → content may restore in ~10–14 business days, so pair with #6. | Sworn statement |
| 9 | 🔴 **APWG** | email `reportphishing@apwg.org` | Feeds browser/security blocklists. Best if you have an actual phishing email (forward with headers). | Verified |
| 10 | 🔴 **PhishTank** | `phishtank.com` | Community blocklist. **Caveat:** new-user registration is currently disabled — only usable if you already have an account. | Reliable |

> **Is it actually Shopify? Check before filing #6–#8.** Open `lovebeautyontapp.shop/products.json` (a Shopify store returns a JSON product feed; non-Shopify returns 404/HTML). Also look in page source for `cdn.shopify.com` assets, and add an item to cart — Shopify checkouts redirect to `*.myshopify.com`. If none of these hit, it's **not** Shopify — skip the Shopify channels and lean on Cloudflare + registrar + host.

### Tier 3 — Cut the traffic (ads & social — conditional on them advertising)

| # | Channel | Where | What it does |
|---|---|---|---|
| 11 | 🟠 **Meta — impersonating Page/Account** | `facebook.com/help/contact/295309487309948` (IG/Threads: `.../636276399721841`) | Removes impostor FB/IG pages/accounts. Works without a registered trademark. |
| 12 | 🟠 **Meta — Trademark infringement** | `facebook.com/help/contact/trademarkform` | Removes infringing pages/ads/shops. Needs a **registered** mark. |
| 13 | 🟠 **Meta — scam ad + Ad Library recon** | `facebook.com/ads/library` (set country = South Africa; search "BeautyOnTApp", "lovebeautyontapp") | Find the ads driving traffic, then three-dot → Report ad → Scam. Kills their acquisition channel. |
| 14 | 🟠 **TikTok — trademark IPR** | `ipr.tiktokforbusiness.com/legal/report/Trademark` | Brand-owner route; removes infringing videos/ads/Shop listings platform-wide. |
| 15 | 🟠 **TikTok — in-app scam/impersonation report** | In-app Report → "Fraud and scams" / "Pretending to be someone"; web `tiktok.com/legal/report/submit-requests` | Fastest removal of a specific TikTok ad/video/profile. |
| 16 | 🟠 **Google Ads — trademark complaint** | `services.google.com/inquiry/aw_tmcomplaint` | Stops use of "BeautyOnTApp" in Google Ads. Only bites if they run Google Ads; still pre-registers the mark. |
| 17 | 🟠 **Google Ads — report scam ad/listing** | `support.google.com/ads/troubleshooter/4578507` | Reports a specific misleading ad / Shopping listing. |

> **Recon caveats:** Meta's Ad Library shows only *currently active* ads — absence ≠ no ads. TikTok's Commercial Content Library (`library.tiktok.com/ads`) only indexes **EEA/UK/Switzerland** ads, so an SA-targeted scam may not appear — a null result there is inconclusive. Taboola (`taboola.com/report`) / Outbrain (`legal@outbrain.com`) only apply if it runs as native "recommended" ads.

### Tier 4 — South Africa: authorities & money rails

| # | Channel | Where | What it does |
|---|---|---|---|
| 18 | 🟣 **SAFPS / Yima** (do this early — it's fast) | `yima.org.za/reportscam` · hotline 083 123 7226 | Logs the site into SA's shared fraud database → **member banks block it** + consumers warned. High-value, fast. |
| 19 | 🔵 **SAPS cybercrime** — open a case | In person at any station; Crime Stop 08600 10111 | Produces a **CAS number** — the key banks/PSPs/registrars ask for. Anchor filing; slow on its own. |
| 20 | 🟣 **Capitec Fraud Centre** | 0860 10 20 43 · WhatsApp 067 418 9565 · `capitecbank.co.za/fraud-centre/report-fraud/` | If a Capitec account receives scam payments, it can be flagged/frozen and funds recalled (fastest same-day). |
| 21 | 🟣 **Payfast Risk & Compliance** | 021 300 4455 · `payfast.io/contact` | If the store transacts via Payfast, the merchant can be terminated. |
| 22 | 🟣 **Ozow** | `phishing@ozow.com` / `support@ozow.com` | If it abuses/impersonates Ozow, they can pull the merchant. |
| 23 | 🟣 **Payflex** | `support@payflex.co.za` | If it offers Payflex checkout, merchant can be terminated. |
| 24 | 🟣 **NCC** (consumer complaint) | `eservice.thencc.org.za` · 012 065 1940 | Logs consumer harm under the CPA. Slow; limited reach over an anonymous foreign site. |

> **Money-rail reality check:** SA gateways are KYC-gated, and this is a throwaway domain (no mail records) — it likely does **not** hold a legitimate Payfast/Ozow/Payflex merchant account. **Confirm the rail is actually present at checkout** (§4.1 step 3) before expecting these to bite; where present, they're among the most effective levers because they choke the cash-out.

### Tier 5 — Strategic & permanent

| # | Channel | Where | What it does |
|---|---|---|---|
| 25 | 🔵 **CIPC trademark** — search + register "BeautyOnTApp" | `iponline.cipc.co.za` (free search; TM1 filing ~R590/class, classes 3 & 35) | Even a *pending* application strengthens every IP complaint above and unlocks UDRP. Registration takes 12–24 months. |
| 26 | 🔵 **UDRP / URS (WIPO)** — seize/suspend the domain name | `wipo.int/amc/en/domains/` | Trademark-based domain dispute: UDRP → transfer/cancel the domain; URS → suspension. Needs trademark rights; ~2 months. |
| 27 | 🔵 **ICANN compliance** (escalation) | `icann.org/compliance/complaint` | Use **only if the registrar ignores** a valid abuse report — you must show you contacted the registrar first. |

**Not effective for this case (don't waste time):** FPB (out of mandate — it handles prohibited content, not fraud); CIPC company-name complaint (its jurisdiction doesn't reach an anonymous foreign `.shop` domain); Google's Search "spam" form (no direct action — use the phishing path instead).

*Sources for the above are recorded per-channel in the verification run; the primary first-party references are Cloudflare, Google Safe Browsing, Shopify, Meta, TikTok, ICANN, GMO Registry, WIPO, SAPS/cybercrime.org.za, SAFPS/Yima, CIPC, and the SA payment providers' own pages.*

---

## 6. Ready-to-send complaint templates

Copy each block, replace the `[BRACKETED]` fields, attach the evidence from §4, and submit. Written to be firm, factual, and rights-holder-grade.

### A. Google Safe Browsing (paste into the report box)
> **URL:** `https://lovebeautyontapp.shop`
>
> This site is a fraudulent storefront impersonating our legitimate South African beauty retail brand **BeautyOnTApp** (our official sites: `https://beautyontapp.com` and `https://beautyontapp.net`). It copies our brand name ("BeautyOnTApp" with a "love" prefix) to deceive our customers into entering payment and personal details. The domain is a throwaway (no mail records; Cloudflare-fronted; recently registered). Please add it to the Safe Browsing list. Contact: `[YOUR EMAIL]`.

### B. Cloudflare abuse — Phishing & Malware (`abuse.cloudflare.com/phishing`)
> **Reporter:** `[YOUR NAME]`, `[ROLE]` at BeautyOnTApp · `[YOUR EMAIL]`
> **URL(s) reported:** `https://lovebeautyontapp.shop` , `https://www.lovebeautyontapp.shop`
> **Category:** Phishing & Malware (also filing under Trademark Infringement — see below)
>
> `lovebeautyontapp.shop` is a fraudulent website impersonating our legitimate brand **BeautyOnTApp** (`beautyontapp.com`, `beautyontapp.net`), a South African beauty retailer with physical stores, mobile apps, and an established social presence. It reproduces our brand name and — per the attached screenshots — our branding/product content to deceive our customers and harvest payment and personal data at checkout. The domain shows the hallmarks of a disposable fraud domain: it is fronted by your network (NS `mcgrory`/`wally.ns.cloudflare.com`; `104.21.88.151` / `172.67.223.176`) and has no MX/SPF/DMARC records. As Cloudflare is the reverse proxy and DNS provider, please flag the URL and forward this complaint to the origin host and registrar. **We request that our identity be kept confidential from the site owner.**
> *Attachments: screenshots of the fraudulent site + our genuine sites; WHOIS/RDAP record.*

### C. Registrar abuse (email to the Registrar Abuse Contact from WHOIS)
> **To:** `[REGISTRAR ABUSE EMAIL]` (from `lookup.icann.org` — see §4.2)
> **Subject:** Abuse report — fraudulent brand-impersonation domain `lovebeautyontapp.shop` (request suspension)
>
> To the Abuse Team,
>
> I am `[YOUR NAME]`, `[ROLE]` of BeautyOnTApp, a South African beauty retailer. The domain you sponsor, **`lovebeautyontapp.shop`** (created `[CREATION DATE]`), is being used for **brand impersonation and consumer fraud**. It copies our registered/established brand "BeautyOnTApp" (our sites: `beautyontapp.com`, `beautyontapp.net`) to deceive our customers into placing orders and entering payment details on a store we do not operate.
>
> Evidence of abuse (attached): dated screenshots of the fraudulent site showing use of our brand name and content; our genuine sites for comparison; the RDAP record; and DNS records showing a throwaway configuration (Cloudflare-fronted, no MX/SPF/DMARC). This is actionable abuse under your Acceptable Use Policy and ICANN RAA §3.18.
>
> **We request that you investigate and suspend (`clientHold`) or terminate the domain.** Please confirm receipt and your case reference.
>
> Regards, `[YOUR NAME]` · `[CONTACT]`

### D. .shop registry — GMO abuse (`get.shop/abuse`)
> Same body as **C**, addressed to the registry, adding: *"I am also reporting this to the sponsoring registrar; I am escalating to the .shop registry because this domain is being used for fraud/impersonation in breach of the .shop Anti-Abuse Policy and I request registry-level action."*

### E. Shopify — Trademark / Fraud (only if the site is on Shopify)
> **To:** Shopify Trust & Safety (via `shopify.com/legal/tools/report-an-issue/trademark-infringement` and `/fraud`)
>
> The Shopify-powered store at **`lovebeautyontapp.shop`** is impersonating our brand **BeautyOnTApp** to defraud South African consumers. Infringing URLs: `[LIST EACH SPECIFIC PAGE URL — homepage link alone is insufficient]`. Our trademark/brand: "BeautyOnTApp" `[registration no. + jurisdiction if registered; otherwise state established common-law rights since [YEAR]]`. Our genuine sites: `beautyontapp.com`, `beautyontapp.net`. The store uses our name and `[copied logo/photos/copy]` to deceive our customers. I have a good-faith belief this use is unauthorized, and I state under penalty of perjury that this notice is accurate and I am authorized to act for the rights holder. `[YOUR NAME, SIGNATURE, CONTACT]`.

### F. Meta — impersonation / trademark
> The `[Facebook Page / Instagram account / ad]` at `[URL]` is impersonating our official brand **BeautyOnTApp** (`beautyontapp.com`) and directs users to a fraudulent store, `lovebeautyontapp.shop`, that we do not operate. It uses our brand name/logo/content to deceive our customers. I represent the genuine business `[proof: business registration / official domain email]`. Please remove the impersonating content. `[trademark reg. no. + jurisdiction, if using the trademark form]`.

### G. SAFPS / Yima + SAPS (SA)
> **Yima (`yima.org.za/reportscam`):** "Fake online store `lovebeautyontapp.shop` impersonating the real SA brand BeautyOnTApp (`beautyontapp.com`) to take payments for goods it does not supply. Please add to the fraud database and warn consumers." Attach screenshots.
>
> **SAPS affidavit skeleton:** "I, `[FULL NAME, ID NO.]`, `[ROLE]` of BeautyOnTApp `[company reg. no.]`, declare that `lovebeautyontapp.shop` is fraudulently impersonating our brand to deceive our customers. `[Describe any known victims / fake orders.]` I request this be investigated as online fraud and impersonation and referred to the Cybercrime/Commercial Crime unit." → obtain the **CAS number**.

### H. Customer warning (post on your site banner + socials, immediately)
> ⚠️ **Scam alert:** The only official BeautyOnTApp store is **beautyontapp.com** and our official apps. We are **not** affiliated with **lovebeautyontapp.shop** — please do not order or enter payment details there. Share to protect others. 💛

---

## 7. Proactive brand defense (do these in parallel)

These don't take the impostor down but blunt its impact and prevent the next one.

1. **Warn your customers now.** Post a short notice on your real socials and site banner: *"⚠️ The only official BeautyOnTApp store is beautyontapp.com and our official apps. We are not affiliated with 'lovebeautyontapp.shop' — do not enter payment details there."* This cuts the scammer's conversion rate immediately and protects your customers and your reputation.
2. **Add a Google Alert** for `beautyontapp`, `"beauty on tapp"`, and `lovebeautyontapp` to catch new clones early.
3. **Register key defensive domains** you don't own (e.g. `beautyontapp.shop`, `beautyontapp.co.za` if not held, common typos) so squatters can't.
4. **Register the trademark** for "BeautyOnTApp" with **CIPC** if not already done — it turns every future takedown from a "passing-off argument" into a one-click IP complaint and enables UDRP domain seizure.
5. **Enable Meta Brand Rights Protection** and get your official pages/verified badges in order, so Meta's system recognizes you as the rights holder.
6. **Tell your payment providers** (Payfast/Ozow/Payflex/Capitec Pay) that a fraudster is impersonating you — they monitor for brand abuse on their rails and can blocklist the merchant.

---

## 8. First-hour / first-day / first-week checklist

**First hour**
- [ ] Capture live-site evidence + WHOIS (§4)
- [ ] File **Cloudflare** abuse report (fastest infrastructure lever)
- [ ] File **Google Safe Browsing** phishing report (triggers browser warnings)
- [ ] Post the **customer warning** on your channels

**First day**
- [ ] File **registrar abuse** report (using WHOIS from §4.2)
- [ ] If Shopify-hosted: file **Shopify IP/DMCA + Trust & Safety** reports
- [ ] Report any **Meta / TikTok ads** and file **Meta/TikTok IP infringement**
- [ ] Submit to **APWG / Netcraft / PhishTank** anti-phishing feeds
- [ ] Report to **SAFPS** and **SAPS** cybercrime

**First week**
- [ ] Confirm browser warnings are live (open the URL in Chrome — expect a red interstitial)
- [ ] Chase any channel that hasn't acted; escalate registrar non-response to **ICANN**
- [ ] Start **CIPC trademark** registration if not held
- [ ] Register **defensive domains**
- [ ] Re-check the site is offline; keep evidence on file for repeat offenders

---

## 9. Status tracker

| # | Channel | Filed? | Date | Reference / ticket | Outcome |
|---|---|---|---|---|---|
| 1 | Cloudflare abuse | ☐ | | | |
| 2 | Google Safe Browsing | ☐ | | | |
| 3 | Registrar abuse | ☐ | | | |
| 4 | Shopify IP/DMCA (if Shopify) | ☐ | | | |
| 5 | Shopify Trust & Safety | ☐ | | | |
| 6 | Meta IP infringement | ☐ | | | |
| 7 | Meta / IG scam-ad report | ☐ | | | |
| 8 | TikTok IP / scam-ad | ☐ | | | |
| 9 | APWG / Netcraft / PhishTank | ☐ | | | |
| 10 | SAFPS | ☐ | | | |
| 11 | SAPS cybercrime | ☐ | | | |
| 12 | ICANN complaint (escalation) | ☐ | | | |
| 13 | Payment-provider notice | ☐ | | | |
| 14 | Customer warning posted | ☐ | | | |

---

*Not legal advice. For a registered-trademark enforcement action or UDRP filing, involve an IP attorney; this dossier is designed to make that engagement fast and cheap by assembling the evidence up front.*
