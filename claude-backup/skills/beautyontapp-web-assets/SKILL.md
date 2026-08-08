---
name: beautyontapp-web-assets
description: Generate production-ready brand assets for PNCapital's 3 brands (BeautyOnTApp, Pastry Skincare, Mzuri Skin) and 6 physical stores — favicons, Flutter iOS and Android app icons at all required sizes, PWA manifests, Open Graph social share images, Instagram profile and feed and story sizes, Facebook covers, TikTok profile images, Google Business Profile covers for Gateway, Fourways, Mall of Africa, Menlyn, Sandton, and Canal Walk, and WhatsApp Business display pictures. Auto-invoke when T asks for favicons, app icons, social media images, Open Graph, PWA manifest, GBP covers, brand asset pack, logo variants, Flutter launcher icons, Instagram templates, or any request to resize, crop, or generate images for web, mobile, or social. Uses Python Pillow with brand-aware palettes and outputs organized folders ready to drop into Shopify theme, Flutter assets directory, or social media scheduler.
---

# BeautyOnTApp Web Assets

## Purpose

Generate every web, mobile, and social asset PNCapital needs at the correct size, format, and brand styling — in one pass, without manual Photoshop work. Covers all 3 brands and all 6 physical store locations.

## When to use

- "Generate favicons for beautyontapp.com"
- "I need Flutter app icons for iOS and Android"
- "Make Instagram post templates for Pastry Skincare"
- "Create Google Business Profile covers for our 6 stores"
- "Produce an Open Graph image for this blog post"
- "Build the full asset pack for Mzuri Skin launch"
- "Resize this logo for TikTok profile"
- "PWA manifest icons for the web app"
- Any launch, rebrand, or new store opening requiring consistent asset production

## Required inputs

Before generating, confirm T has provided:

1. **Source logo** — vector SVG preferred, or PNG at minimum 1024×1024
2. **Brand** — BeautyOnTApp, Pastry Skincare, or Mzuri Skin (affects color palette and typography)
3. **Asset scope** — favicons only, app icons only, social only, GBP only, or complete pack
4. **Output directory** (optional) — defaults to `/home/claude/output/[brand]/[asset-type]/`

If any are missing, ask before generating. Never assume brand palette.

## Brand color tokens

Use these as `--emoji-bg` or background color defaults:

**BeautyOnTApp**
- Primary: `#000000`
- Accent: `#C9A961`
- Cream: `#F5F1EA`
- Contrast rule: logo white on black, or black on champagne

**Pastry Skincare**
- Primary: `#F4C9C4`
- Accent: `#8B5A3C`
- Cream: `#FFF8F3`
- Contrast rule: logo caramel on pastry pink, or caramel on cream

**Mzuri Skin**
- Primary: `#4A5D3A`
- Accent: `#D4A574`
- Cream: `#F8F5F0`
- Contrast rule: logo wheat on olive, or olive on cream

## Asset specifications

### Favicons (web)

Generate these sizes for every brand:

| File | Size | Format | Purpose |
|------|------|--------|---------|
| favicon-16x16.png | 16×16 | PNG | Legacy browser tabs |
| favicon-32x32.png | 32×32 | PNG | Modern browser tabs |
| favicon-48x48.png | 48×48 | PNG | Desktop shortcut |
| favicon-96x96.png | 96×96 | PNG | Android desktop |
| favicon.ico | Multi-res (16,32,48) | ICO | Universal fallback |
| apple-touch-icon.png | 180×180 | PNG | iOS home screen |
| safari-pinned-tab.svg | Vector | SVG monochrome | Safari pinned tabs |

### Flutter app icons (BeautyOnTApp app only)

**iOS (`ios/Runner/Assets.xcassets/AppIcon.appiconset/`):**

| Size | Scale | Filename |
|------|-------|----------|
| 20×20 | @2x | Icon-App-20x20@2x.png (40×40) |
| 20×20 | @3x | Icon-App-20x20@3x.png (60×60) |
| 29×29 | @2x | Icon-App-29x29@2x.png (58×58) |
| 29×29 | @3x | Icon-App-29x29@3x.png (87×87) |
| 40×40 | @2x | Icon-App-40x40@2x.png (80×80) |
| 40×40 | @3x | Icon-App-40x40@3x.png (120×120) |
| 60×60 | @2x | Icon-App-60x60@2x.png (120×120) |
| 60×60 | @3x | Icon-App-60x60@3x.png (180×180) |
| 76×76 | @1x | Icon-App-76x76.png (76×76) |
| 76×76 | @2x | Icon-App-76x76@2x.png (152×152) |
| 83.5×83.5 | @2x | Icon-App-83.5x83.5@2x.png (167×167) |
| 1024×1024 | @1x | Icon-App-1024x1024.png (App Store) |

**Android (`android/app/src/main/res/`):**

| Density | Folder | Size |
|---------|--------|------|
| mdpi | mipmap-mdpi/ic_launcher.png | 48×48 |
| hdpi | mipmap-hdpi/ic_launcher.png | 72×72 |
| xhdpi | mipmap-xhdpi/ic_launcher.png | 96×96 |
| xxhdpi | mipmap-xxhdpi/ic_launcher.png | 144×144 |
| xxxhdpi | mipmap-xxxhdpi/ic_launcher.png | 192×192 |
| Play Store | (separate) | 512×512 |

**Adaptive icons (Android 8+):** generate foreground + background layers at 108×108 dp.

### PWA manifest icons

Sizes: 192×192, 256×256, 384×384, 512×512. Generate `manifest.json` with:

```json
{
  "name": "BeautyOnTApp",
  "short_name": "BeautyOnTApp",
  "icons": [...],
  "theme_color": "#000000",
  "background_color": "#F5F1EA",
  "display": "standalone"
}
```

Adjust name, theme, and background per brand.

### Social media — per brand

**Instagram:**
- Profile: 320×320 (displayed at 110×110 but upload at 320)
- Feed square: 1080×1080
- Feed portrait: 1080×1350
- Story / Reels: 1080×1920
- Highlight cover: 1080×1920 (design for center 720×720 safe area)

**Facebook:**
- Profile: 170×170
- Cover: 820×312 (mobile safe area: 640×312 centered)
- Post: 1200×630
- Event cover: 1920×1080

**TikTok:**
- Profile: 200×200 (upload at 1080×1080 for sharpness)
- Video thumbnail: 1080×1920

**LinkedIn:**
- Company logo: 300×300
- Company cover: 1128×191
- Post image: 1200×627

**Twitter / X:**
- Profile: 400×400
- Header: 1500×500
- In-feed post: 1200×675

**Pinterest:**
- Profile: 165×165
- Standard pin: 1000×1500

**WhatsApp Business:**
- Display picture: 500×500
- Catalog product: 1000×1000

### Open Graph (shared on Facebook, LinkedIn, WhatsApp, iMessage)

- Standard: 1200×630
- With logo watermark in bottom-right
- Title text overlay zone: top-left quadrant, max 60 chars
- Use brand cream background with logo accent

### Google Business Profile — all 6 stores

Generate for each store location:

| Asset | Size | Notes |
|-------|------|-------|
| Logo | 250×250 | Brand logo centered |
| Cover photo | 1080×608 | Storefront or interior photo |
| Profile photo | 250×250 | Logo or storefront close-up |

**Store list:**
1. Gateway Theatre of Shopping, Umhlanga
2. Fourways Mall
3. Mall of Africa
4. Menlyn Park
5. Sandton City
6. Canal Walk, Cape Town

For each store cover, include store name overlay in brand typography. Use cream background with accent color typography.

## Python implementation pattern

Use Python Pillow. Confirm `pip install Pillow` has run. For emoji fallback, `pip install pilmoji 'emoji<2.0.0'`.

```python
from PIL import Image, ImageDraw, ImageFont
import os

def generate_favicon_set(source_path, output_dir, brand):
    """Generate all favicon sizes from a source image."""
    os.makedirs(output_dir, exist_ok=True)
    src = Image.open(source_path).convert("RGBA")

    sizes = [(16, 'favicon-16x16.png'),
             (32, 'favicon-32x32.png'),
             (48, 'favicon-48x48.png'),
             (96, 'favicon-96x96.png'),
             (180, 'apple-touch-icon.png')]

    for size, name in sizes:
        resized = src.resize((size, size), Image.LANCZOS)
        resized.save(os.path.join(output_dir, name), optimize=True)

    # Multi-resolution .ico
    src.save(os.path.join(output_dir, 'favicon.ico'),
             sizes=[(16, 16), (32, 32), (48, 48)])
```

Similar generators for Flutter iOS set, Flutter Android set, social media set, GBP set.

## HTML integration output

After generating favicons, output the HTML tags T should paste into Shopify theme `theme.liquid`:

```html
<link rel="icon" type="image/png" sizes="32x32" href="{{ 'favicon-32x32.png' | asset_url }}">
<link rel="icon" type="image/png" sizes="16x16" href="{{ 'favicon-16x16.png' | asset_url }}">
<link rel="apple-touch-icon" sizes="180x180" href="{{ 'apple-touch-icon.png' | asset_url }}">
<link rel="manifest" href="{{ 'manifest.json' | asset_url }}">
<meta name="theme-color" content="#000000">
```

For OG tags:

```html
<meta property="og:title" content="[Title]">
<meta property="og:image" content="[1200x630 URL]">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:type" content="website">
<meta property="og:url" content="https://beautyontapp.com/[path]">
```

## Output folder structure

Generate assets into this structure for easy handoff to T:

```
output/
└── [brand]/
    ├── favicons/
    │   ├── favicon-16x16.png
    │   ├── favicon-32x32.png
    │   ├── favicon-48x48.png
    │   ├── favicon-96x96.png
    │   ├── favicon.ico
    │   ├── apple-touch-icon.png
    │   ├── safari-pinned-tab.svg
    │   └── html-tags.txt
    ├── flutter/
    │   ├── ios/
    │   │   └── AppIcon.appiconset/
    │   │       ├── [all 12 iOS sizes]
    │   │       └── Contents.json
    │   ├── android/
    │   │   ├── mipmap-mdpi/ic_launcher.png
    │   │   ├── mipmap-hdpi/ic_launcher.png
    │   │   ├── mipmap-xhdpi/ic_launcher.png
    │   │   ├── mipmap-xxhdpi/ic_launcher.png
    │   │   └── mipmap-xxxhdpi/ic_launcher.png
    │   └── play-store-icon-512.png
    ├── pwa/
    │   ├── icon-192.png
    │   ├── icon-256.png
    │   ├── icon-384.png
    │   ├── icon-512.png
    │   └── manifest.json
    ├── social/
    │   ├── instagram/
    │   ├── facebook/
    │   ├── tiktok/
    │   ├── linkedin/
    │   ├── twitter/
    │   ├── pinterest/
    │   └── whatsapp/
    ├── og-images/
    │   └── default-og-1200x630.png
    └── gbp/
        ├── gateway/
        ├── fourways/
        ├── mall-of-africa/
        ├── menlyn/
        ├── sandton/
        └── canal-walk/
```

After generation, use `present_files` to surface the output folder as a zip so T can download.

## Validation checks before delivery

1. All generated images match target dimensions exactly (no 1px drift from resampling)
2. PNG files are optimized (use `optimize=True` in Pillow save)
3. Transparent backgrounds preserved where required (favicons, app icons for iOS)
4. Brand-specific palette was used (reject if generic)
5. WCAG contrast maintained between logo and background
6. File names match platform conventions exactly (Flutter asset naming is strict — wrong filename = build failure)
7. For Flutter iOS: `Contents.json` matches Xcode's expected schema
8. For GBP covers: store name overlay is readable at thumbnail size

## Integration with existing PNCapital skills

- **beautyontapp-brand-visual-guidelines** — source of truth for logo files, palette, typography. Always consult first.
- **beautyontapp-flutter-app** — destination for iOS/Android app icon output. Place into correct asset directory.
- **beautyontapp-shopify** — destination for favicon/OG output. Upload to theme assets.
- **beautyontapp-tiktok, beautyontapp-influencer-ops, beautyontapp-ugc-management** — consumers of social media templates.
- **beautyontapp-shopify-pos** — each store's GBP cover is part of the local SEO stack.
- **beautyontapp-seo-content, beautyontapp-onpage-seo** — OG images are part of every blog post launch.

## Anti-AI-slop directives

- NO generic AI-rendered photography. Use T's supplied photography or brand vector art only.
- NO rainbow gradients on social templates.
- NO center-cropped logo that cuts off the mark — always check padding and safe areas.
- USE real brand typography (Pastry's caramel, BeautyOnTApp's champagne, Mzuri's olive) — not generic sans-serif.
- TEST at actual thumbnail size — a favicon that looks great at 256px but is illegible at 16px has failed.

## Guidelines

- ALWAYS ask which brand before generating (3 palettes, 3 logo sets)
- ALWAYS output a complete set for the requested scope — if T asks for "Instagram assets," deliver profile + feed + story in one pass
- NEVER produce stretched or blurry outputs — if source logo is below required resolution, flag it and ask for a higher-resolution source
- NEVER skip the favicon.ico (legacy browsers still use it)
- NEVER guess brand colors if beautyontapp-brand-visual-guidelines has been updated
- For Flutter icons: iOS 1024×1024 must have NO transparency (Apple rejects App Store submissions with transparent app icons)
- For Android adaptive icons: design within the inner 66dp safe zone — outer regions may be cropped by the launcher mask

## Self-check before delivery

Before returning output to T, verify:
1. Correct brand palette used
2. All requested sizes generated
3. File names match platform conventions
4. Folder structure matches the standard above
5. HTML tags provided for web assets
6. Flutter Contents.json matches Xcode schema (if iOS icons requested)
7. Source logo resolution was sufficient (no upscaling artifacts)
8. Transparent backgrounds preserved where required
9. iOS App Store icon is opaque (no alpha)
10. Output zipped and surfaced via present_files
