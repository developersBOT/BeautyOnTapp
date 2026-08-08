---
name: beautyontapp-privacy-compliance
description: POPIA privacy compliance and data protection for BeautyOnTApp — consent management, data subject rights, cookie banners, email/SMS opt-in, cross-brand data sharing, skin analysis data handling, Shopify privacy configuration, PCI compliance for 6 physical POS locations. Auto-invoke for "POPIA", "privacy", "data protection", "consent", "cookie banner", "opt-in", "opt-out", "data subject request", "right to delete", "PCI compliance", "card security", "customer data", or any privacy/data protection question. NOT for SAHPRA cosmetics regulations (use beautyontapp-legal-compliance). NOT for ad policy compliance (use beautyontapp-legal-compliance).
---

# Privacy Compliance (POPIA + PCI) for BeautyOnTApp

POPIA (Protection of Personal Information Act) is SA's GDPR equivalent, fully enforced since July 2021. BeautyOnTApp processes personal data across 3 brands, 6 physical stores (POS), online (Shopify), delivery fleet (addresses), skin analysis (health-adjacent data), Klaviyo (marketing), and Apify (scraping). Non-compliance = fines up to R10M or imprisonment.

## HARD RULES
1. Never collect data without explicit, informed consent.
2. Never share customer data between brands without cross-brand consent.
3. Skin analysis data is "special personal information" under POPIA — extra protections required.
4. Never store payment card data outside Shopify/POS payment processors.
5. Data subject requests must be responded to within 30 days.
6. Information Officer must be registered with the Information Regulator.

## POPIA REQUIREMENTS MAPPED TO BEAUTYONTAPP

### 1. Consent Management
- **Online checkout**: Separate checkboxes for: (a) order processing (required), (b) marketing emails (optional), (c) WhatsApp marketing (optional), (d) cross-brand marketing (optional — "Receive updates from Pastry Skincare and Mzuri Skin")
- **In-store POS**: Staff must verbally confirm marketing consent. POS receipt includes opt-in QR code.
- **Skin analysis**: Separate written consent for storing skin analysis data. Explain: what data is collected, how it's used, how long it's kept, who has access.
- **Apify scraping**: Only scrape publicly available business data. Never customer PII.

### 2. Data Subject Rights (Must Support All)
| Right | Implementation |
|---|---|
| Right to access | Customer can request all data held. Export from Shopify + Klaviyo within 30 days. |
| Right to correction | Customer can request data corrections. Process within 30 days. |
| Right to deletion | Customer can request all data deleted. Delete from Shopify, Klaviyo, GA4, EasyRoutes. 30 days. |
| Right to object to processing | Customer can opt out of marketing at any time. Immediate effect. |
| Right to data portability | Provide data in machine-readable format (CSV/JSON). |

### 3. Cookie Consent
- Cookie banner required on first visit
- Categories: Essential (always on), Analytics (opt-in), Marketing (opt-in)
- Essential: Shopify session, cart, checkout
- Analytics: GA4, Analyzify
- Marketing: Meta Pixel, CAPI
- Respect consent: if user declines marketing cookies, Meta Pixel must not fire
- Shopify's Customer Privacy API handles this natively

### 4. Cross-Brand Data Sharing
- BeautyOnTApp, Pastry Skincare, and Mzuri Skin are separate brands under PNCapital
- Sharing customer data between brands requires explicit consent
- "Would you like to receive updates from our other brands?" checkbox
- Never assume consent for Brand B because customer consented for Brand A

### 5. Skin Analysis Data (Special Personal Information)
POPIA classifies health data as "special personal information" requiring additional protections:
- Explicit written consent before collecting
- Purpose limitation: skin analysis data used only for product recommendations
- Secure storage: encrypted, access restricted to trained beauty advisors
- Retention: delete after 24 months of inactivity (unless customer consents to longer)
- Never use skin analysis data for ad targeting without explicit consent

### 6. PCI Compliance (6 Physical Stores)
- Never store card numbers on any device
- POS terminals handle card processing via Shopify Payments (PCI Level 1 certified)
- Staff training: never write down card numbers, never process cards on personal devices
- Regular POS terminal firmware updates
- Incident response: if card data breach suspected, notify Information Regulator as soon as reasonably possible (POPIA Section 22 — NOT the GDPR 72-hour rule)

## SHOPIFY PRIVACY CONFIGURATION

### Customer Privacy API
```javascript
// Check consent before firing tracking pixels
Shopify.customerPrivacy.setTrackingConsent({
  analytics: userConsented('analytics'),
  marketing: userConsented('marketing'),
  preferences: true,
  sale_of_data: false
});
```

### Analyzify Privacy Integration
Analyzify v4 respects Shopify Customer Privacy API. When marketing consent = false:
- Meta Pixel does not fire
- CAPI does not send
- GA4 fires in limited mode (no user-level data)

### Data Retention
- Customer accounts: active indefinitely (customer can request deletion)
- Order data: 7 years (SA tax requirement — SARS)
- Marketing data: until consent withdrawn
- Skin analysis data: 24 months of inactivity
- Delivery addresses: 90 days post-delivery (for returns)
- CCTV in stores: 30 days

## COMPLIANCE CHECKLIST

- [ ] Information Officer registered with Information Regulator
- [ ] Privacy Policy updated on beautyontapp.com (link in footer)
- [ ] Cookie consent banner implemented
- [ ] Marketing consent checkboxes on checkout
- [ ] Cross-brand consent checkbox implemented
- [ ] Skin analysis consent form created (paper + digital)
- [ ] Data subject request process documented
- [ ] Staff trained on POPIA basics (all 6 stores)
- [ ] POS terminals on latest firmware
- [ ] Data processing register maintained
- [ ] Third-party processor agreements signed (Klaviyo, Analyzify, EasyRoutes, Apify)

## DECISION RULES

1. **When launching new marketing channel**: Verify consent is collected for that specific channel before sending.
2. **When a customer requests data deletion**: Process across ALL systems within 30 days. Shopify, Klaviyo, GA4, EasyRoutes, any spreadsheets.
3. **When sharing data between brands**: Only with explicit cross-brand consent. Never assume.
4. **When Apify scrapes competitor data**: Only publicly available business data. Never PII.
5. **When storing skin analysis results**: Encrypted storage, purpose-limited, 24-month retention, explicit written consent.
6. **When auditing**: Annual POPIA compliance review. Update privacy policy. Check consent mechanisms still work.
