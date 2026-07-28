# v8.1.6 WebKit ATC Fix — Handoff — 28 Jul 2026

> **REBASE NOTE (28 Jul, ~17:00Z) — v8.1.7 supersedes the theme below for publishing.**
> Live/MAIN changed after the original duplication: `bot-v8.1.6-footer-alignment-draft-27jul2026` (162827305219) was published 11:46Z. Its `assets/main.mjs` is byte-identical to v8.1.5's (`cdbc6ab6…`, verified via Admin API), so the validated patch applies unchanged. The fix was rebased:
>
> - **Publish candidate:** `bot-v8.1.7-webkit-atc-fix-28jul2026` — ID **162860105987**, UNPUBLISHED, duplicated from the new live 162827305219.
>   **Preview:** `https://beautyontapp.com/?preview_theme_id=162860105987`
> - **Same artifact, no re-patching:** the identical patched `assets/main.mjs` (md5 `7c465b4c6b153a242607f7091e67d3ed`) was staged-uploaded from disk and upserted; Admin API readback confirms the checksum byte-exact.
> - **Step-3 gate (v8.1.7 vs live 162827305219): PASS** — 662 files on both sides, none missing, none extra, exactly one checksum delta: `assets/main.mjs` (`cdbc6ab6…` → `7c465b4c…`). Verified twice: an initial listing ran while `themeDuplicate`'s async file copy was still materializing (transiently showed 88 files); the final comparison ran after materialization completed. The copier did not overwrite the upserted patch (its created/updated timestamps remain the upsert's, 16:47:34Z).
> - **Step-4 scope check (live 162827305219 vs v8.1.5 162793554179): two files differ, both characterized from full content diffs.**
>   1. `sections/footer-bar.liquid` (12,233 → 13,063 B) — footer-scoped CSS/markup polish only (footer-item flex→grid, app-badge sizing wrappers, mobile alignment). No JS, no ATC surface. Expected.
>   2. `snippets/pagefly-main-js.liquid` (4,540 → 4,560 B) — **flagged per step 4** as the one delta outside footer scope: a 4-line escaping hardening in PageFly's analytics payload (`'{{ product.title }}'` → `{{ product.title | json }}`, same for `pf_product_page_image` / `pf_collection_name` / `pf_collection_page_image`). App-owned analytics loader (PageFly — not Analyzify/Simprosys/BookX), gated behind PageFly metafields, no interaction with any patched main.mjs site or ATC path. v8.1.7 inherits it from live, so publishing reverts nothing.
> - The stale fix theme `bot-v8.1.6-webkit-atc-fix-28jul2026` (162858270979) is **left in place** per constraints — do not publish it (it would revert today's footer changes); cleanup is T's call.
> - The validation record below (engine simulation, 21 shipped-bytes unit assertions, WebKit-preview escalation) applies to v8.1.7 verbatim — it is the same bundle on a base whose only deltas are the two characterized files above.

---

**Theme:** `bot-v8.1.6-webkit-atc-fix-28jul2026` — ID `gid://shopify/OnlineStoreTheme/162858270979`, **UNPUBLISHED**. Duplicated server-side from live `bot-v8.1.5` (162793554179) via Admin API `themeDuplicate` (Shopify CLI is not installed in this environment and all storefront/admin hosts are blocked by its network policy — the Admin API duplicate is the CLI-equivalent; the API additionally hard-blocks theme-file writes to the live/MAIN theme, mechanically enforcing constraint 1). Live theme untouched; nothing published.

**Preview URL:** `https://beautyontapp.com/?preview_theme_id=162858270979`
(also listed in Online Store → Themes under the v8.1.6 name; same param works on the myshopify domain.)

**Files changed: exactly one — `assets/main.mjs`** (189,129 → 189,993 bytes, six replacement sites). Verified two ways: (1) the duplicate's `checksumMd5` for assets/main.mjs is `7c465b4c6b153a242607f7091e67d3ed`, byte-identical to the locally patched file; (2) full three-page checksum comparison of all ~660 theme files between 162793554179 and 162858270979 shows **zero** other differences. `sections/header.liquid` was NOT modified — the hamburger fallback lives inside the guarded catch (smaller diff than the optional header edit).

## The diff (minified sites, shown expanded)

**Fix 1 — WebKit bundle survival + hamburger fallback** (audit beautified 3806–3821):

```diff
-customElements.define("menu-hamburger",_r,{extends:"button"});
+try{customElements.define("menu-hamburger",_r,{extends:"button"})}catch(mhErr){
+  document.addEventListener("click",function(mhEv){
+    var mhB=mhEv.target&&mhEv.target.closest?mhEv.target.closest("button.hamburger"):null;
+    if(!mhB)return;
+    var mhM=document.querySelector("[data-mobile-menu]");
+    if(!mhM||typeof mhM.show!="function")return;
+    mhB.__mhActive=!mhB.__mhActive,mhB.__mhActive?mhM.show():mhM.hide()
+  }),
+  document.addEventListener("hide",function(mhEv){
+    var mhT=mhEv.target;
+    mhT&&mhT.matches&&mhT.matches("[data-mobile-menu]")&&
+      document.querySelectorAll("button.hamburger").forEach(function(mhB){mhB.__mhActive=!1})
+  },!0)};
```

The fallback replicates `_r` exactly (read from the class body): click toggles an active flag and calls `show()`/`hide()` on `[data-mobile-menu]` (`snippets/mobile-menu.liquid:18` — `mobile-menu extends modal-drawer`, so both methods exist); the capture-phase `hide` listener mirrors `_r.connectedCallback`'s reset of the active flag when the menu closes by other means. Chromium behavior untouched — the try succeeds there and `_r` runs as before.

**Fix 2 — variant-picker recovery** (audit 6874–6875, 6877–6886, 7009–7012):

```diff
-async fetchUrl(t){return Pt.has(t)||Pt.set(t,new Promise(e=>fetch(t).then(n=>n.text().then(e))).catch(e=>(console.error("Failed to fetch product",e),Pt.delete(t),!1))),Pt.get(t)}
+async fetchUrl(t){return Pt.has(t)||Pt.set(t,fetch(t).then(n=>{if(!n.ok)throw new Error("HTTP "+n.status);return n.text()}).catch(e=>(console.error("Failed to fetch product",e),Pt.delete(t),!1))),Pt.get(t)}
```

```diff
-n=await this.fetchUrl(e.toString()),s=this.variantPicker.quickAddModal?Ie(n):new DOMParser().parseFromString(n,"text/html");
+n=await this.fetchUrl(e.toString());if(n===!1)throw new Error("Variant section fetch failed");const s=this.variantPicker.quickAddModal?Ie(n):new DOMParser().parseFromString(n,"text/html");
```

```diff
-setLoading(e){var n;e?(this.classList.add("disabled"),(n=this.addButton)==null||n.setAttribute("disabled","")):this.classList.remove("disabled")}
+setLoading(e){var n,s;e?(this.classList.add("disabled"),(n=this.addButton)==null||(n.setAttribute("disabled",""),n.setAttribute("data-vp-loading","1"))):(this.classList.remove("disabled"),(s=this.addButton)!=null&&s.hasAttribute("data-vp-loading")&&(s.removeAttribute("disabled"),s.removeAttribute("data-vp-loading")))}
```

`setLoading(false)` removes `disabled` only when the `data-vp-loading` ownership marker survives. `updateDOM`'s attribute sync wipes the marker when it applied fetched state — so a fetched **sold-out** variant's `disabled` is preserved (no regression), while fetch-failure paths (where updateDOM never ran) re-enable the button.

**Fix 3 — facet loading release + drawer selection preservation** (audit 3061–3083, 3095–3098):

```diff
-catch(s){s.name!=="AbortError"&&console.error(s);return}
+catch(s){s.name!=="AbortError"&&(console.error(s),this.parentSection.classList.remove("loading"));return}
```

(AbortError keeps `.loading` — the superseding submit owns and clears it.)

```diff
-hide(t){const e=this.querySelector("facet-filters-form");return e&&(e.removeEventListener("input",this.handleFormChange),this.formChanged&&e.onSubmit()),this.formChanged=!1,super.hide(t)}
+hide(t){const e=this.querySelector("facet-filters-form");return e&&(e.removeEventListener("input",this.handleFormChange),this.formChanged&&e.onSubmit(),this.formChanged=!1),super.hide(t)}
```

(`formChanged` reset moved inside the `e && (…)` group: a null form lookup now preserves the user's selections for the next hide instead of silently discarding them.)

## Material discovery during fix 1

`vendor.mjs`'s single `{extends:"br"}` occurrence is the support **probe** of a bundled @ungap-style customized-built-ins polyfill, already inside its own `try{}catch{}` (no change needed, none made). The polyfill patches `customElements.define` when the probe throws — so pure contract-level simulation shows even unpatched main.mjs surviving *when vendor's polyfill installs successfully*. Production WebKit evidence (the verified NotSupportedError + dead ATC) therefore implies the polyfill itself dies in real WebKit before patching define (vendor and main are separate modules — vendor failing does not stop main, which then hits the native throwing define). The shipped guard makes main.mjs survival **unconditional** — correct under every variant: polyfill working (try succeeds through it, zero behavior change), polyfill dead (catch fires, ATC elements register natively as autonomous elements, hamburger falls back), or native support someday (try succeeds).

## Validation results

Environment facts, established empirically before validation: Playwright **WebKit is not installed** (`/opt/pw-browsers` contains Chromium only, browser downloads blocked), and the proxy denies CONNECT to `beautyontapp.com`, `*.myshopify.com`, and `admin.shopify.com` — **no browser in this environment can reach the preview URL in any engine**. Per the dispatch's escalation clause, WebKit-against-preview validation is not substituted with Chromium — items needing the real preview are marked BLOCKED and handed to T with exact steps. What ran instead: (a) an **engine-contract simulation** in local Chromium — real vendor.mjs + main.mjs served locally, with `customElements.define` patched to throw `NotSupportedError` on `{extends:}` exactly as WebKit's native define does, in six configurations including polyfill-alive and polyfill-dead; (b) **21 unit assertions executed against the exact shipped bytes** extracted from the uploaded bundle; (c) cryptographic diff-scope verification.

| # | Gate item | Status | Evidence |
|---|---|---|---|
| 1 | WebKit console: zero uncaught NotSupportedError (home/collection/PDP) | **BLOCKED — escalated** | Simulation: unpatched+polyfill-dead reproduces the exact production error; patched same config = **zero page errors**. Real-WebKit run needed (steps below). |
| 2 | WebKit: product-form / quick-add-button / sticky-add-to-cart / variant-picker all defined | **BLOCKED — escalated** | Simulation (both patched configs): all four + quick-add-modal, facet elements, cart elements register. Unpatched polyfill-dead: all five ATC elements undefined — the production signature. |
| 3 | WebKit ATC: PDP / card quick-add / sticky each POST /cart/add.js → 200 | **BLOCKED — escalated** | Requires storefront. Mechanism restored per item 2; fetch path untouched by the diff. |
| 4 | Chromium regression: ATC paths, hamburger, bottom-sheet nav, filters, sort, cart drawer | **PARTIAL (local engine pass)** | Native-Chromium configs, patched vs unpatched: identical registration (12/12 elements), zero page errors, hamburger drives `[data-mobile-menu]` show/hide (spy: 1/1). Bundle parses clean (esbuild). Storefront click-through still needed on preview. |
| 5 | Fix 2: blocked `**/*section_id*` → swatch click → button re-enables; unblock → next click succeeds | **PARTIAL (unit-proven)** | Shipped-bytes unit tests: rejected fetch settles (no hang), poisoned cache purged, next call re-fetches; 429 treated as failure; catch+finally leaves button enabled; sold-out `disabled` preserved. 8/8 + 3/3 + 1 structural. |
| 6 | Fix 3: blocked facet fetch → grid exits `.loading`; drawer preserves selections | **PARTIAL (unit-proven)** | Shipped-bytes unit tests: non-abort error removes `.loading`, AbortError leaves it; null-form hide preserves `formChanged` and still hides; preserved selections submit on next hide. 5/5. |
| 7 | Diff scope: only specified sites; no other files | **PASS** | Duplicate's assets/main.mjs md5 = local patched md5 (`7c465b4c6b153a242607f7091e67d3ed`); full ~660-file checksum comparison v8.1.5 ↔ v8.1.6: zero other differences. Six replacement sites, each unique-matched. |

**Hamburger fallback status (one line):** shipped inside the fix-1 catch — in WebKit-without-polyfill it toggles the same `[data-mobile-menu]` drawer the `_r` class drives, verified by spy in simulation; Chromium path untouched; the independent `#shopBtn1` bottom-sheet hamburger is untouched.

## For T — the 10-minute WebKit confirmation before publishing

On macOS Safari or any iPhone (preview URL above): (1) open a product page with the console visible — expect **no** uncaught NotSupportedError; (2) `customElements.get('product-form')` → class (not undefined); (3) tap Add to cart → Network shows POST `/cart/add.js` → 200, cart badge increments; (4) repeat for a card quick-add and the sticky bar; (5) tap the header hamburger — menu opens; (6) quick Chromium pass of the same plus filters/sort/cart drawer. Then publish v8.1.6 from Online Store → Themes.

## Escalations

1. **WebKit-against-preview validation impossible in this environment** (no WebKit binary; storefront hosts proxy-blocked) — per dispatch, not substituted; items 1–3 above are T's pre-publish checklist.
2. **Additional `{extends:}` define found:** one, in vendor.mjs — it is the polyfill's own already-guarded probe; no change needed or made; no visible behavior depends on changing it.
3. No validation item failed; blocked ≠ failed. Fixes are landed, byte-verified, and evidence-backed to the limit this environment allows.
