---
name: beautyontapp-ugc-management
description: User-generated content collection, rights management, and product page display for BeautyOnTApp — photo/video review incentives, UGC rights acquisition, Judge.me photo review optimization, before/after content governance, cross-brand UGC sharing, Bestie Squad content pipeline integration. Auto-invoke for "UGC", "user generated content", "customer photos", "before and after", "photo reviews", "video reviews", "content rights", "customer testimonials", "review photos", "social proof photos", or any question about collecting and displaying customer content. NOT for influencer ops (use beautyontapp-influencer-ops). NOT for TikTok content (use beautyontapp-tiktok).
---

# UGC Management for BeautyOnTApp

UGC is the #1 conversion driver in beauty e-commerce. Customer photos of real results on real SA skin tones convert 4-6x higher than studio shots. Bash has no UGC strategy — they display standard product images. This is a moat. Every authentic customer photo on a PDP is trust capital competitors can't buy.

## HARD RULES
1. Never publish customer photos without explicit written or digital consent.
2. Never use customer content in paid ads without a separate paid-use rights agreement.
3. Before/after photos require SAHPRA-compliant disclaimers: "Individual results may vary."
4. All UGC must be moderated before display — filter inappropriate content, off-brand imagery.
5. Cross-brand sharing (Pastry customer photo on BeautyOnTApp PDP) requires consent for both brands.
6. Never fabricate reviews or incentivize specific star ratings. Review incentives for submission only, not for positive content.

## UGC COLLECTION SYSTEM

### Channel 1: Post-Purchase Review Requests (Automated via Klaviyo + Judge.me)
```
Day 14 post-delivery: Email — "How's your skin feeling? Share your results 🖤"
  - Include product photo and order details
  - "Add a photo for 50 Glow Rewards points" (PROPOSED program name)
  - Direct link to Judge.me review form
  - Mobile-optimized (70%+ will open on phone)

Day 21 (if no review): SMS reminder — "Your review helps others find the right products"

Day 28 (photo follow-up): Email — "Show us your glow! Before/after photos welcome"
  - Only send if customer submitted text review but no photo
```

### Channel 2: Instagram/TikTok Hashtag Collection
- Primary hashtag: #BeautyOnTApp
- Brand-specific: #PastrySkincare #MzuriSkin
- Campaign-specific: #MyGlowJourney #BeautyOnTAppResults
- Monitor hashtags weekly using social listening (manual or Apify)
- DM customers requesting permission: "We love your photo! Can we feature it on our site? [consent link]"

### Channel 3: In-Store Content Stations
- Mirror + ring light selfie station at each of 6 stores
- QR code → upload photo → instant R50 store credit
- Staff trained to suggest: "Would you like to take a before photo? Come back in 4 weeks for the after!"
- Store-specific UGC drives local SEO and foot traffic

### Channel 4: Bestie Squad (Tier 1 Creators)
- Cross-reference with beautyontapp-influencer-ops for pipeline
- Bestie Squad members commit to 2 UGC submissions/month
- Content goes to both social and PDP display

## RIGHTS MANAGEMENT

### Consent Tiers
| Tier | Permissions | How acquired |
|---|---|---|
| Review consent | Display on product page, emails | Checkbox on review form |
| Social reshare | Repost on BeautyOnTApp social accounts | DM consent + saved confirmation |
| Paid media use | Use in Meta/Google ads | Separate agreement (template in references/) |
| Cross-brand use | Display on Pastry/Mzuri pages | Explicit multi-brand consent checkbox |

### Consent Language (Review Form)
"By submitting a review with photos, you grant BeautyOnTApp permission to display your content on our website and marketing emails. For paid advertising or cross-brand use, we'll always ask separately."

### Content Moderation
Before publishing any UGC, check:
- [ ] Photo is relevant to the product
- [ ] No identifying info of minors
- [ ] No competitor branding visible
- [ ] Before/after has SAHPRA disclaimer
- [ ] Image quality sufficient for display (not blurry/dark)
- [ ] No offensive or inappropriate content

## PRODUCT PAGE DISPLAY

### Judge.me Configuration
- Enable photo reviews prominently (not collapsed)
- Photo carousel above text reviews
- Sort: "Most helpful" default, with photo filter option
- Display format: customer name (first name only) + verified purchase badge + skin type (if provided)

### UGC Gallery Section on PDPs
Below reviews, add "Customer Results" gallery:
- Grid of customer photos (4-8 images)
- Each photo links to the full review
- "Share your results" CTA at bottom
- Lazy-load images for performance (beautyontapp-web-performance)

### Homepage UGC Section
- Rotating customer photo carousel
- "Real results from real customers" heading
- Mix brands: Pastry, K-beauty, Mzuri results together
- Link each photo to the product used

## METRICS

| Metric | Target | Source |
|---|---|---|
| Photo review submission rate | >15% of all reviews | Judge.me |
| UGC photos collected/month | >100 | Judge.me + social |
| Rights-cleared photos/month | >60 | Internal tracking |
| PDPs with customer photos | >50% of top 100 products | Judge.me |
| UGC conversion lift | >25% vs no-UGC PDPs | A/B test |

## DECISION RULES

1. **When a PDP has zero customer photos**: Prioritize for free product seeding to Bestie Squad Tier 1 creators.
2. **When a customer posts an amazing before/after**: Fast-track rights acquisition. Offer R100 store credit for paid media consent.
3. **When Bash starts collecting UGC**: They'll get generic product shots from fashion shoppers. Beauty UGC requires skin journey context — our Bestie Squad + consultation pipeline produces this at a level Bash can't match.
4. **When moderating negative UGC**: Publish honest negative reviews (builds trust). Only remove photos that violate content guidelines — never remove because of low star ratings.
5. **When UGC supply exceeds demand**: Create a "Community Gallery" page as an SEO asset — hundreds of real customer photos, searchable by skin type and concern.
