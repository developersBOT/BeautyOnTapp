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

<!-- CHANNELS_PLACEHOLDER -->
*(Verified reporting channels and expected effects are populated in this section from live verification — see the channel table and the fill-in complaint templates in §6.)*

---

## 6. Ready-to-send complaint templates

<!-- TEMPLATES_PLACEHOLDER -->

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
