# BeautyOnTApp native ↔ Shopify: one source of truth

The native app renders the storefront's own `templates/index.json`. Until
build 54 that document was **baked into the binary** at build time, which is
why weekly homepage image changes never appeared in the app. From build 55
the app fetches the live document at runtime and falls back gracefully.

## How Home gets its content now

```
first frame            bundled snapshot (unchanged, instant)
   ↓ ~ms
last synced copy       Application Support/ThemeSync/home.json
   ↓ background
live storefront        1) Storefront API metaobject bot_native_theme/home
                       2) Shopify Files CDN bot-native-home.json (fallback)
```

- `ThemeSnapshotStore` (Core/ThemeSyncService.swift) publishes the snapshot
  HomeView renders. Content only ever moves forward; nothing on screen is
  removed while a fetch runs, so there is no loading state — a change
  crossfades in (`.animation` on `themeStore.generation`).
- Every remote document must pass `ThemeHomeSnapshot.isAcceptableHome`
  (≥3 sections, a renderable hero slide, a product rail) before it can
  replace what is on screen. A partial theme save, an error page, or a
  truncated response can never blank Home.
- New hero/tile images are prefetched through `NativeImagePipeline` at the
  exact sizes HomeView requests, so a swapped hero never paints a
  placeholder.
- Refresh happens on launch and on returning to the foreground, throttled
  to one attempt per 15 minutes.

## What keeps the metaobject fresh

`bot_native_theme` is a metaobject definition (storefront access: public
read) with a single `home` entry:

| field | content |
| --- | --- |
| `index_json` | verbatim `templates/index.json` of the published theme |
| `theme_name` | which theme version it came from |
| `synced_at` | ISO-8601 sync time |

Two independent writers, either is sufficient:

1. **GitHub Action** `.github/workflows/native-theme-sync.yml` — Mondays
   06:15 SAST + manual "Run workflow". Needs the `SHOPIFY_ADMIN_TOKEN`
   repository secret (custom app: `read_themes`, `write_metaobjects`).
2. **Claude** — any session with the BeautyOnTApp Shopify connector can
   re-sync on demand ("sync the native home metaobject"): read the MAIN
   theme's `templates/index.json`, `metaobjectUpsert` it into
   `bot_native_theme/home`.

The app also accepts a tokenless fallback file at
`https://beautyontapp.com/cdn/shop/files/bot-native-home.json` (Shopify
admin → Content → Files, upload with exactly that filename) — useful if the
Storefront API metaobject read is ever unavailable.

## Failure behaviour (by design)

| Situation | What the customer sees |
| --- | --- |
| Metaobject missing / not yet seeded | Files CDN tried; else last synced copy; else bundled — today's behaviour, never worse |
| Malformed or partial template synced | Rejected by validation; previous Home stays |
| Offline launch | Last synced copy instantly, no spinner |
| Theme rebuilt / renamed | Nothing to change — the sync reads whichever theme has role MAIN |

## Fast-and-smooth layer (same change set)

`StorefrontResponseVault` (Core/StorefrontResponseVault.swift) gives
catalogue reads a disk-backed stale-while-revalidate path:

- Cached: collections, products, recommendations, menus, blog, brands
  directory, store locations. **Never cached:** cart, checkout, search,
  customer session.
- Cold launch paints menus/rails/blog/stores from last-known-good bytes
  instantly; a background refresh follows. When refreshed bytes differ,
  `AppModel.contentGeneration` bumps (debounced) and visible rails re-read
  silently — the redacted placeholder only ever appears when the app has
  nothing at all (true first run or >72h stale).

## THEME-PARITY.md

The parity contract is unchanged: native section renderers must still match
the theme's markup semantics. What changed is only where the *settings*
come from (live vs baked). When a theme release adds a **new section type**
to the homepage, the app skips it until a renderer ships — add the renderer
and update the bundled snapshot in the same release.
