# BeautyOnTApp ATC Audit — Theme v8.1.5 (live) — 28 Jul 2026

**Dispatch:** Static code audit to pinpoint the defect suppressing session→ATC (15.2% → ~10% since unified-ios27-v21 published 13 Jul; unchanged at 9.9% after v8.1.5 "sibling-null-guards" published 27 Jul 17:02 UTC). Investigation only — zero edits made to any theme.

## Source audited

No theme zip exists locally (this repo is the Flutter app). Per dispatch constraint 3, the audit ran against the **live theme's actual files, fetched read-only via the Shopify Admin API on 28 Jul 2026**:

- **Audit target:** `bot-v8.1.5-sibling-null-guards-draft-26jul2026`, ID `gid://shopify/OnlineStoreTheme/162793554179`, role MAIN, updatedAt 2026-07-27T17:02:08Z — matches the dispatch exactly. `assets/main.mjs` md5 `cdbc6ab6d96c12dd166dc28e48adced7` (189,129 bytes).
- **Diff baselines (also fetched read-only):** v21 `beautyontapp-unified-ios27-theme-v21-13jul2026` (162430451971), main.mjs md5 `cae8da978d6473103ccf2327abd4383e`; v8.1.4 `bot-v8.1.4-runtime-stability-draft-26jul2026` (162790572291), main.mjs md5 `597780b3f1703d5c60ec207d7904f8d3`. `webkit-fix-test 2026-07-12` (162394439939) carries a main.mjs **byte-identical to v21's** (same md5) — no pre-13-Jul main.mjs exists on the store.
- Direct storefront/CDN fetches are blocked by this environment's network policy (proxy 403) — all content came via the Admin API (main.css via its API-signed storage URL).
- `main.mjs` is minified but with element names, selectors, and string literals intact — auditable. **All `main.mjs` line numbers below refer to a js-beautify–formatted copy of the exact live asset** (7,283 lines; code byte-identical, whitespace only). Liquid/CSS line numbers are the files' real line numbers.

---

## (a) Ranked root-cause candidates

### #1 — Unguarded customized-built-in `customElements.define` aborts main.mjs in WebKit; every ATC handler is defined after it

**Defect:** `assets/main.mjs` (beautified) **3806–3821**, at module top level:

```js
class _r extends HTMLButtonElement {
  ...
}
customElements.define("menu-hamburger", _r, {
  extends: "button"
});
```

Paired markup: `sections/header.liquid:224`:

```liquid
<button is="menu-hamburger" class="hamburger" aria-label="{{ 'accessibility.open_menu' | t }}">
```

WebKit (Safari on macOS, **every** browser on iOS including Chrome/iOS, and every iOS in-app WebView — Instagram/Facebook ad traffic and BeautyOnTApp's own Flutter WKWebView app) has never shipped customized built-in elements: this `define` throws `NotSupportedError`. The throw happens during **module evaluation** of the single-bundle `main.mjs`, so evaluation aborts and **every `customElements.define` after line 3821 never runs**. No polyfill exists anywhere in the theme (grep for ungap/builtin/NotSupportedError across main.mjs, vendor.mjs, theme.liquid: 0 hits).

Dead in WebKit (all defined after 3821): `product-form` (4301), `quick-add-button` (4507), `quick-add-modal` (4558), `sticky-add-to-cart` (6668), `variant-picker` (7039), `variant-radios` (7061), `notification-wrapper` (4016), `modal-trigger` (3938), `search-modal` (5958), plus the `DOMContentLoaded`/`pageshow` init at 7254–7261.

Still alive in WebKit (defined before 3819): `cart-form` (532), `x-modal` (1436), `modal-drawer` (1602), `cart-modal` (1631), `facet-filters-form` (3086), `facets-drawer-modal` (3103), announcement bar, dropdowns, mega-menu. The classic scripts `bot-app-ui.js`, `beauty-bottom-sheet.js`, `liquid-glass.js` are separate non-module files and run fine — the dock, sheets, menus, filters, cart page and checkout all work. **The site looks fully alive; only add-to-cart is dead.**

**Mechanism, per ATC surface (all in WebKit):**

- **Card quick-add & sticky ATC:** the button is JS-only — `snippets/product-card.liquid:222–249` and `snippets/product-sticky-add-to-cart.liquid:21–42` render `<quick-add-button>…<button type="button">`. No form, no href. `quick-add-button` never upgrades → click does nothing. (bot-app-ui.js's capture-phase delegate at its line 1788 deliberately does not preventDefault the quick-add click — it only tags the slot and returns — so nothing else adds either.)
- **Product-page buy button:** `snippets/product-page-buy-buttons.liquid:50–56` server-renders the variant input **disabled**:

  ```liquid
  <input
    data-variant-info="variant_id"
    type="hidden"
    name="id"
    value="{{ product.selected_or_first_available_variant.id }}"
    disabled
  >
  ```

  The only code that re-enables it is `product-form`'s constructor — main.mjs 4250: `this.form.querySelector("[name=id]").disabled = !1` — which never runs in WebKit. The native `{% form 'product' %}` POST therefore submits **without an `id` parameter** → no add. The `type="submit"` button itself stays clickable, so the user sees a page navigation to an error, or nothing usable — never a cart addition.
- **Variant selection:** `variant-picker` (7039) dead → shade/fragrance selection inert on top of the dead button.

**Why the metrics fit:** cart-form/checkout live before the throw and checkout is Shopify-hosted — matching "checkout completion is intact; the loss is entirely at add-to-cart." Cross-device by construction (iOS WebKit monopoly + macOS Safari). Arithmetic check: mobile fell 15.6% → 10.9%; if ~30% of mobile sessions are WebKit (iOS browsers + in-app webviews + the BoT app) and their ATC ≈ 0, blended ATC = 15.6 × 0.70 = **10.92%** — the observed figure. Desktop's 12.2% → 6.5% implies a ~47% WebKit share of desktop sessions if this were the sole cause — high; candidates #2/#3 plausibly supply the desktop remainder. Browser-share split: **NOT VERIFIED** — ShopifyQL exposes no browser/OS dimension (`session_browser`, `session_os` both rejected; queries attempted 28 Jul).

**Onset:** v21 (13 Jul) carries the identical unguarded define at its beautified line 3813. The `webkit-fix-test 2026-07-12` theme carries the identical bundle — a WebKit investigation was underway the day before v21 published. Whether the pre-13-Jul live theme lacked this define: **NOT VERIFIED** (no pre-13-Jul artifact exists on the store). WebKit's non-support of customized built-ins is asserted as of knowledge cutoff (Jan 2026) and is confirmed empirically by test (c) in one page-load.

**Why v8.1.5 didn't fix it:** none of the 8.1.x guards touch this (see (b)). The one visible loss the hamburger caused was already papered over with an inline-onclick workaround — `sections/header.liquid:349–354` opens the menu via `onclick="…shopBtn1.click()"`, added "07 Jun 2026" per its comment — so the module abort produces **no visible breakage** other than dead ATC.

### #2 — variant-picker permanently disables the add button on any failed/non-ok section fetch (all engines)

**Defect A — disable without re-enable.** main.mjs 6989–7012:

```js
async handleChange(e) {
  var n, s;
  this.setLoading(!0), (n = this.productForm) == null || n.setErrorMessage();
  ...
}
setLoading(e) {
  var n;
  e ? (this.classList.add("disabled"), (n = this.addButton) == null || n.setAttribute("disabled", "")) : this.classList.remove("disabled")
}
```

`setLoading(true)` sets the `disabled` **attribute** on `[name="add"]` (the buy button, product-page-buy-buttons.liquid:66–68). `setLoading(false)` — the `finally` path — only removes a class and **never removes the button's disabled attribute**. Re-enabling relies entirely on `updateDOM()` (6907–6934) syncing attributes from the fetched section HTML, or on the `catch` (7000) after a thrown error.

**Defect B — a fetch rejection produces a promise that never settles, cached forever.** main.mjs 6874–6875:

```js
async fetchUrl(t) {
  return Pt.has(t) || Pt.set(t, new Promise(e => fetch(t).then(n => n.text().then(e))).catch(e => (console.error("Failed to fetch product", e), Pt.delete(t), !1))), Pt.get(t)
}
```

The resolver `e` is only wired to the success chain; a network-level `fetch` rejection rejects the *inner* chain (unhandled), while the *outer* promise — the one cached in `Pt` and awaited — **stays pending forever**. The `.catch` is attached to the outer promise, which never rejects, so `Pt.delete` never runs either. Result: `await this.productRenderer.switchVariant(...)` hangs → no `catch`, no `finally` → button stays disabled → **every subsequent variant click awaits the same poisoned cache entry**. Permanent, silent, per-page ATC death. `preloadOptions()` (6938–6947, fired on first visibility and after every switch) seeds `Pt` with one fetch per option value, multiplying the poisoning surface.

**Defect C — non-ok responses are treated as success.** `fetchUrl` never checks `response.ok`. A 429/500 body parses to a document with no `[data-variant-info]` → `updateDOM` no-ops → nothing throws → `finally` runs but (Defect A) never re-enables → button stays disabled with **zero console output**.

Scope: multi-variant products only (`snippets/product-variant-picker.liquid:17` — `{% unless product.has_only_default_variant %}`), desktop + mobile, all engines. Fires on variant interaction when a section fetch fails or rate-limits — plausibly desktop-weighted (variant exploration + preload storms), supplying the desktop drop that #1 alone under-explains.

### #3 — Facet re-render leaves the collection section in a stuck "loading" state on any failed fetch (desktop-weighted; degrades, does not hard-block)

main.mjs 3061–3083 (`facet-filters-form.onSubmit`): `this.parentSection.classList.add("loading")` on entry (3063); removal only on the success path (3083). The catch (3079–3082) logs non-abort errors and returns — **`.loading` is never removed on failure**. Effect per `assets/main.css`: `.shopify-section.loading .loading-target { opacity: 0.5 }` (3918–3920), `.shopify-section.loading.loading .products-collection-grid { opacity: 0.5 }` (5380–5382), `.shopify-section.loading.loading .pagination { pointer-events: none }` (5383–5385). The grid dims to 50% and pagination dies until reload; ATC buttons remain technically clickable — this **degrades** conversion rather than hard-blocking it, and is ranked accordingly. Desktop is the heavy path: the sidebar form auto-submits on every checkbox change (facets.liquid renders no `manual` for the desktop sidebar; `collection-grid.liquid:26` vs the drawer's `manual: true` at `facets-drawer.liquid:26`).

Related, same family: `facets-drawer-modal.hide()` (3095–3098) — the v8.1.x guard `e && (…, this.formChanged && e.onSubmit())` means a null form silently **skips applying the selected filters** on "Apply". Structurally the form is always rendered inside the drawer (facets-drawer.liquid:26 → facets.liquid:12–18), so the null case is rare; when it fires it produces dead-feeling filters, not dead ATC.

**Explicitly cleared during Phase 4** (evidence in section (f)): section-swap listener death (all ATC handlers are per-element custom elements re-upgraded after innerHTML swaps — upgrades run post-children-attach; `quick-add-button` binds click on itself, 4467), `scroll-animate` interception (display:contents, main.css:1626; no fetched grid/card/facet markup carries `data-animation`), instant.page (vendor.mjs is instant.page v5.2.0 — prefetch-only; mousedown-shortcut mode not enabled), bot-app-ui/beauty-bottom-sheet/liquid-glass click interception (all preventDefaults scoped to their own nav/sheet/stepper elements; the quick-add click passes through untouched — bot-app-ui.js 1788–1815), post-add DOM throws (`qe()`/#CartBubble, notification-wrapper — all fire **after** the `/cart/add` fetch, so they cannot move Shopify's server-side ATC metric), lqip image latching (`xe()` at 120–131 resolves on both `load` and `error`; plus the 18 Jul CSS fail-open at main.css 10868–10870).

---

## (b) Guard-coverage verdict (Phase 3)

**The v8.1.5 release's own delta is two characters.** Complete `diff` of beautified main.mjs v8.1.4 → v8.1.5 (one hunk, verbatim):

```diff
   connectedCallback() {
-    this.closest(".shopify-section").addEventListener("slideshow:update", this.handleSlideshowUpdate)
+    this.closest(".shopify-section")?.addEventListener("slideshow:update", this.handleSlideshowUpdate)
   }
   disconnectedCallback() {
-    this.closest(".shopify-section").removeEventListener("slideshow:update", this.handleSlideshowUpdate)
+    this.closest(".shopify-section")?.removeEventListener("slideshow:update", this.handleSlideshowUpdate)
   }
```

That is a **slideshow dots indicator** (`slideshow-control-dots`, defined at 6169). It has no connection to facets or ATC.

**Full v21 → v8.1.5 delta is six hunks** (complete diff, 51 changed lines — nothing else changed in main.mjs):

| # | Element (define line) | Guard | After the guard fires | ATC path? |
|---|---|---|---|---|
| 1 | `facets-drawer-modal` (3103) `show`/`hide` | `const e = this.querySelector("facet-filters-form"); e && …` | `show`: drawer opens, input listener silently skipped. `hide`: **`formChanged && e.onSubmit()` silently skipped — selected filters never apply.** Also fixed v21's `bind()`-in-add/removeEventListener defect. | No — filters |
| 2 | media-carousel connected/disconnected (3536–3543) | `t && t.addEventListener("variant:change", …)` | Carousel silently never reacts to variant changes | No — media |
| 3 | media-carousel `handleVariantChange` (3689) | `if (!t.detail.variant) return` | Silent skip | No — media |
| 4 | `product-card-swatches` (4247) | rewrite: `listenersBound` flag, delegated `handleMouseover` with `!e` and `n &&` guards | Silent skip of hover preload; crash on missing label/template fixed | No — swatch preload |
| 5 | slideshow dots (6169) — **the only v8.1.5 change** | `?.` on `closest(".shopify-section")` | Silent no-op | No — slideshow |
| 6 | `sticky-header` (6762) | `if (…, !this.section) return;` + `this.onScrollHandler &&` in disconnect | Sticky header silently inert | No — header |

**Verdict:**
1. **The shipped guards do not cover the path that breaks add-to-cart.** No hunk touches `os()` (417), `product-form.onSubmitHandler` (4255), `quick-add-button` (4465), `quick-add-modal` (4508), `sticky-add-to-cart` (6627), `variant-picker`/`Bd` (6858–7061), or the module-eval abort at 3806–3821. No try/catch around any cart-add fetch was added anywhere in 8.1.x (the six hunks above are the entire diff).
2. **Two guards convert loud failures into silent-dead behavior:** hunk 1's `hide()` shape (`e && (…, this.formChanged && e.onSubmit())`) suppresses the null-ref while silently discarding the user's filter selections — the exact "guard that returns early and skips the work" failure mode the dispatch flagged — but for filters, not ATC.
3. **The known facet-filters-form null-ref is a bystander.** Its patch sites are all in the filter/media/header flows. The exact DOM state that produced the original v21 throw is **NOT VERIFIED** from static markup (the drawer structurally always contains its form; the likeliest window is transient — element queried before/after a section-swap replaced drawer content). Fixing it (v8.1.1–v8.1.5) could not and did not move ATC, which is exactly what the 9.9% → 9.9% before/after data shows.
4. Guard attribution within the 8.1.x line: hunks 1–4 and 6 arrived between v21 and v8.1.4 (endpoints diffed; per-version attribution across 8.1.0–8.1.4 **NOT VERIFIED** — intermediate themes not diffed); hunk 5 is v8.1.5's.

---

## (c) Cheapest confirming test for candidate #1 (described, not executed)

One page-load in any WebKit browser (macOS Safari, or any iPhone browser, or the BoT app's WebView with the inspector attached):

1. Open any product page with DevTools console + network open.
2. **Watch console on load:** expect an uncaught `NotSupportedError` originating from `main.mjs` (the `menu-hamburger` define).
3. **Type:** `customElements.get('product-form')` → expect `undefined`, while `customElements.get('facet-filters-form')` → expect a class (proves the module died mid-eval, not wholesale).
4. **Click Add to cart:** network shows **no** request to `/cart/add.js`; if the native form navigates, the POST to `/cart/add` carries no `id` param (the input is still `disabled` — inspect it in Elements).
5. Control: same page in Chrome — both elements defined, `/cart/add.js` fires, item adds.

Candidate #2's confirm (same session, Chrome): DevTools → Network → block `?section_id=` requests (or go offline), click a variant swatch → the add button gets `disabled` and never recovers; subsequent variant clicks never re-attempt (poisoned `Pt` cache).

## (d) Fix scope for the fix dispatch (files + functions only — no code here)

1. **assets/main.mjs — the customized-built-in define (candidate #1, ship first):** guard or replace `customElements.define("menu-hamburger", _r, {extends:"button"})` (beautified 3806–3821) so module evaluation survives WebKit — feature-detect/try-wrap, or convert `menu-hamburger` to an autonomous element. If converted, update the single usage `sections/header.liquid:224` (`<button is="menu-hamburger">`). Nothing else references it (theme-wide grep: 1 hit).
2. **assets/main.mjs — variant-picker hardening (candidate #2):** `Bd.fetchUrl` (6874–6875): settle on fetch rejection, check `response.ok`, purge the `Pt` entry on failure; `Un.setLoading` (7009–7012): re-enable `addButton` on the false branch; `Bd.switchVariant` (6877–6886): fail loudly into `handleChange`'s existing catch (7000) instead of no-op'ing on error HTML.
3. **assets/main.mjs — facets hygiene (candidate #3, lowest priority):** `Sr.onSubmit` (3061–3083): remove the section `loading` class on the error path; `Er.hide` (3095–3098): fall back to submitting the sibling/visible filters form instead of silently dropping `formChanged`.

## (e) NOT VERIFIED register

- Pre-13-Jul theme contents and any pre-13-Jul↔v21 diff — no artifact exists on the store (`webkit-fix-test 2026-07-12` is bundle-identical to v21).
- WebKit/Safari share of sessions and per-browser ATC — ShopifyQL has no browser/OS dimension (`session_browser`, `session_os` both rejected 28 Jul); the 30%/47% shares in (a) are arithmetic implications, not measurements.
- WebKit's customized-built-ins behavior is asserted from spec/platform status as of Jan 2026 knowledge cutoff; test (c) step 2–3 confirms it in one page-load.
- The exact v21 DOM state that produced the observed facet-filters-form null reference.
- Per-version attribution of guards across v8.1.0–v8.1.4 (only endpoints v21, v8.1.4, v8.1.5 were diffed).
- `enable_reveal_on_scroll_animations` effective value (key absent from settings_data current — schema default not checked; irrelevant to ATC since no grid markup carries `data-animation`).
- App embeds (Analyzify, Simprosys, BookEasy, Judge.me, wishlist, AskTimmy, Clarity, Klaviyo — settings_data blocks) were not analyzed per constraints 2/5; noted exposure only: the wishlist embed's config references `facet-filters-form` as a selector.

---

## (f) Phase 1–2–4 evidence appendix

### Phase 1 — the four ATC chains (v8.1.5, as-fetched)

**1. Product page buy button.** `snippets/product-page-buy-buttons.liquid:42–101`: `<product-form>` wrapping `{% form 'product' %}` with hidden `input[name=id][disabled]` (50–56) and `button[type=submit][name=add]` (65–92). JS: `product-form` = `Jr`, defined main.mjs 4301; constructor (4250) queries `form`, re-enables `[name=id]`, binds submit; `onSubmitHandler` (4255–4292) → `fetch(window.routes.cart_add_url)` (4263) with `qt("form-data")` headers (53–61) → popup path `nn()` (464–472) into `#variant-added-modal` (`layout/theme.liquid:337–339`; `settings_data: "added_to_cart_notification":"popup"`), drawer path `en()` (455–458) via `cart-modal.reloadContent`. Errors: try/catch logs, `finally` re-enables via `D()` (4018–4038).

**2. Card quick-add.** `snippets/product-card.liquid:211–278`: BoT slot `[data-bui-card-cart]` wraps `<quick-add-button [variant-id] handle …><button type="button">` (222–249) + a bot-app-ui quantity stepper (250–274; stepper shown instead of the button when the variant is already in cart, 226/253). JS: `quick-add-button` = `ra` (4465–4507); constructor binds click on itself (4467 — survives grid swaps); direct add → `os()` (417–446): fetch `cart_add_url` with `sections:["cart-bubble","variant-added"]`, then `qe()` (#CartBubble, 448–451; `sections/cart-bubble.liquid` exists, renders `{{ cart.item_count }}`), then `product:added-to-cart` dispatch; select-options path → `sa()` (4453–4456) fetches the product page → `Ie()` (4458–4464, requires `.section-main-product` — present, `sections/main-product.liquid` schema line 603) → `cs()` (460–463) → `quick-add-modal.setProductInfo` (4518–4532; requires `#quick-add-media` — present via `snippets/product-info.liquid:277` → `snippets/product-quick-add-media.liquid:11`; note unguarded `n.remove()` at 4528–4529) → inner `product-form` → chain 1. bot-app-ui.js's capture delegate (1788–1815) intentionally passes the quick-add click through (returns without preventDefault; only its own `[data-bui-quantity-*]` steppers preventDefault) — steppers do their own `cart/add.js`/`cart/change.js` mutations (1569–1624).

**3. Sticky ATC.** `snippets/product-sticky-add-to-cart.liquid:5–44`: `<sticky-add-to-cart>` + the same `<quick-add-button>` (21–42) → chain 2. `sticky-add-to-cart` = `_d` (6627–6668) only toggles visibility; unguarded getters `this.section.querySelector` (6642–6644), `handleIntersections`' `this.addToCartButton.getBoundingClientRect()` (6656) and `isAboveThreshold`'s `this.footer.getBoundingClientRect()` (6661–6666) can throw inside the observer callback — visibility bugs only, not click suppression.

**4. Cart modal re-render.** `sections/cart-modal.liquid` (x-modal markup + `cart-side-inner` blocks) → `cart-modal` = `$s` (1603–1631): document-level `product:added-to-cart` → `reloadContent` (1616–1619, section fetch) → `updateFromSectionHtml` (1620–1625) `replaceChildren` inside `tn()` state-preserve. `cart-form` = `ds` (473–532): change → `cart_change_url` (507), remove buttons bound per-instance in `connectedCallback` (480), error path re-renders the section and writes `#Cart-Errors` (527–530).

### Phase 2 — facet-filters-form dissection

Full class (`Sr`, main.mjs 3054–3086) quoted in the working copy; its complete DOM-query inventory vs the actual markup:

| Query (line) | Current markup | Null risk |
|---|---|---|
| `this.querySelector("form")` (3059) | `snippets/facets.liquid:18` and `snippets/collection-sort.liquid:2` both render `<form>` unconditionally inside the element | None as rendered; if ever null and no `manual` attr → TypeError in `connectedCallback` (unguarded in v8.1.5) |
| `closest(".shopify-section")` (3059) | Facets render only inside the collection/search grid section | Null only for detached in-flight completions; `onSubmit` line 3063 would throw (unguarded) |
| `document.querySelectorAll('facet-filters-form:not([type=…])')` (3059) | Captures the sort form + **both** filter forms (desktop sidebar `id="FacetFiltersForm-"`, drawer duplicate `id="FacetFiltersForm-drawer"` — both in DOM at all widths, CSS-hidden per breakpoint: `collection-grid.liquid:25/34`) | `new FormData(r.facetForm)` (3069) throws if a captured form never upgraded — safe post-CEReactions in steady state |
| `document.querySelector(".active-facets") ?? parentSection`, `.header?.clientHeight` (3083) | `.active-facets` unconditional in `snippets/collection-facets-active.liquid:18` | Guarded |

Post-filter-change trace: `onSubmit` → abort/debounce (3063–3067) → merged FormData across forms (3068–3072) → `xt()` (373–379) → `ss()` section_id fetch (380–387) → `Zi()` (389–393): **whole-section `innerHTML` swap** inside `tn()` (395–405), which save/restores state for `[data-preserve-state]` elements — all four such classes implement both methods (`x-modal` 1296/1301, `dropdown-element` 2794/2799, `smooth-collapse` 6553/6558, `sticky-sidebar` 6846/6852 — verified). Listener survival: every ATC handler in the grid is a per-element custom element; innerHTML-inserted elements upgrade **after** children attach (fragment parsing runs no constructors mid-parse), so new `quick-add-button`s re-bind on connect — the swap does not orphan ATC in Blink/Gecko. In WebKit the swap is moot: the buttons were never upgraded (candidate #1). Failure path: stuck `.loading` (candidate #3).

Other consumers of `facet-filters-form` in theme JS: only `facets-drawer-modal` (3087–3103). No non-collection-page JS references it; it renders only via `snippets/facets.liquid`/`collection-sort.liquid` inside collection/search grids. (External: the wishlist app embed's stored config uses it as a CSS selector — out of scope.)

### Phase 4 — beyond the facets

1. **Script order / registration races:** `layout/theme.liquid:92–95` — `vendor.mjs` then `main.mjs`, both `type="module" defer`, before `{{ content_for_header }}`. Modules evaluate after parse; the inline body script defining `window.routes`/`variantStrings`/`cartStrings` (356–405) runs during parse — **defined before any module consumer runs; no race**. Single-bundle main.mjs, no top-level await, no dynamic imports — the only module-eval kill-switch is candidate #1. `window.activeModals` initialized at module top (1273) before use.
2. **routes/variantStrings early consumption:** none — all reads are inside handlers/classes executed post-parse.
3. **scroll-animate / data-instant:** `scroll-animate` is `display: contents` (main.css:1626) and only animates `[data-animation]` targets — **no fetched card/grid/facet markup carries `data-animation`** (repo-wide grep of fetched files: 0 hits), so it can neither hide nor intercept the grid. `data-instant-whitelist` (theme.liquid:197) feeds **instant.page v5.2.0** (vendor.mjs:1) = `<link rel=prefetch>` on hover only; click-hijack (`mousedown-shortcut`) mode requires `data-instant-mousedown-shortcut`, absent. Cleared.
4. **Delegation roots:** no ATC handler hangs off a swap-destroyed static container — theme binds per-element (custom elements) or to `document`/`body` (smooth-scroll 7267, jr submit 4040–4047, bot-app-ui capture 1788). Cleared.
5. **bot-app-ui.js / beauty-bottom-sheet.js / liquid-glass.js:** every `preventDefault`/`stopPropagation` is scoped to their own UI — tab links (`a[data-bui-tab]`, 465–493), dock bar drag (1004–1046), sheet open/close buttons (`#shopBtn1-3`, `.shop-modal .close-btn`, 550–577), askBestie trigger (bottom-bar.liquid 953–969), bui steppers (1803–1814). The quick-add click passes through untouched (1789–1801). liquid-glass.js is visual-only (2 listeners, pointer shine). Cleared as ATC suppressors; noted as candidate-#1 beneficiaries (they keep the site feeling alive in WebKit).
6. **Swallowed errors around cart-add added in 8.1.x:** none — the complete v21→v8.1.5 main.mjs diff is the six hunks in (b); no try/catch was added, and `os()`/`Jr`/`ra` are untouched.

Escalation check: the ATC-suppressing code is theme code (main.mjs + header.liquid + buy-buttons.liquid) — no app-injected cause found; no escalation to T required on that criterion.
