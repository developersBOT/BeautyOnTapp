# App Store Review — Rejection Fix Runbook (BeautyOnTApp)

Version reviewed: **1.1.2 (build 4)** · Reviewed on: **iPad Air 11-inch (M3), iPadOS 26.5**

Apple rejected the app for **three** specific reasons. None of them is "web view / minimum
functionality (4.2)" — the storefront-in-a-WebView design was accepted. All three live in the
**login / account experience of the Shopify store shown inside the WebView**, so most of the fix
work happens in **Shopify admin** and **App Store Connect**, not in this Flutter repo.

> **Why so little of this is a code change in this repo:** the app loads
> `https://beautyontapp.com` in a `WKWebView` (`lib/store_webview.dart:13`). The "Sign in with
> Google" button, the account creation, and the (missing) account deletion all belong to that
> web store. Fixing them at the Shopify layer fixes them for both the app and the website, and
> avoids a blind, untested change to the app's launch path.

---

## 0. Status at a glance

| # | Guideline | Problem | Recommended fix | Where |
|---|-----------|---------|-----------------|-------|
| 1 | **4.8 Login Services** | Offers "Sign in with Google" but no privacy-preserving equivalent | Remove/disable third-party sign-in in the storefront **(Path A)** *or* add Sign in with Apple **(Path B)** | Shopify (or app) |
| 2 | **5.1.1(v) Account Deletion** | Account creation exists, no way to delete the account | Add a "Delete my account" flow reachable from the account area | Shopify + backend |
| 3 | **2.1(a) App Completeness** | The "Google" button is unresponsive on iPad | Removing Google (fix #1, Path A) also removes this button; otherwise fix OAuth new-window handling | Shopify (or app) |

Fixes #1 and #3 are the **same feature** (Google sign-in). Path A resolves both at once.

---

## 0.4 FINAL STATE (2026-07-24, pre-submission)

- **4.8 + 2.1(a) — RESOLVED.** "Sign in with Google" was disabled in Shopify admin
  (Settings → Customer accounts → Authentication → Google = **Off**; Shop = off; Facebook not
  connected). Only email sign-in remains, so guideline 4.8 no longer applies and the unresponsive
  Google button is gone.
- **5.1.1(v) — account deletion lives on the WEBSITE account profile** (hosted customer accounts at
  `account.beautyontapp.com`), reachable in-app after signing in. The separate "Delete Account" row
  in the app's Profile drawer is being **removed** as redundant.
- **Theme state:** the Profile-drawer delete row lives in `sections/bottom-bar.liquid`, in a block
  starting `{%- assign delete_account_page = pages['delete-account'] -%}` with class
  `bot-profile-delete-row`. Present in **v8.1.1 (live)** and **v8.1.3 (draft)**; absent from v8.1.2.
  Remove it via Online Store → Themes → Edit code (the connector cannot write to the live theme).
- **Before submitting, verify in the app:** sign in → open the account/profile page → confirm the
  account-deletion option is reachable there. That path is what the required screen recording must
  show; do not remove the drawer row until that website path is confirmed working in the app.

---

## 0.5 Verified against the live store (checked 2026-07-24 via Shopify Admin)

Store: **BeautyOnTApp**, `beautyontapp.com`, Advanced plan, South Africa (ZAR). Customer accounts
are **classic / theme-rendered**. Main theme: `beautyontapp-v8.1.0-funnel-cwv-draft-23jul2026`.

**4.8 + 2.1(a) — the "Google" button:** This is **Shopify's built-in "Sign in with Google"**, a
platform login option toggled in **Settings → Customer accounts** — **not theme code** (confirmed:
it appears in no theme file; login/register templates are email + password only). The app just
mirrors the store, so the button shows in-app too.
→ **Fix (Shopify setting, ~1 min):** Shopify admin → **Settings → Customer accounts** → in the
sign-in / login options, **turn OFF "Sign in with Google"** (and any other third-party/social
provider) so only email login is offered. Save.
- This removes the button **storefront-wide**, which clears **4.8** (no third-party login → the
  rule no longer applies) **and 2.1(a)** (the unresponsive Google button is gone).
- It's an **account-level setting**, so it can't be hidden "only in the app" (Shopify serves the
  button), and I **can't toggle it via the connector** — it must be done in admin.
- **Alternative (only if you want to keep Google):** if that same settings page offers a **"Sign in
  with Apple"** toggle, enabling it satisfies 4.8's "equivalent option" rule while keeping Google —
  **but** you would then still have to fix the unresponsive Google button for 2.1(a) (a WebView
  OAuth-popup problem), so **disabling Google is the cleaner path**.

**5.1.1(v) — account deletion (this store uses HOSTED new customer accounts):** The live sign-in
page is `account.beautyontapp.com` → this store runs Shopify's **new, hosted customer accounts**,
rendered by Shopify, **not the theme**. Consequences:
- A "Delete my account" link **cannot** be added by editing theme files. (An earlier edit to
  `snippets/account-header.liquid` in the v8.1.1 theme is **dormant** — that classic-accounts
  template is not used by hosted accounts. Harmless, but ineffective; revert if you want it clean.)
- The `/pages/delete-account` page **exists and works** as the deletion destination.
→ **Correct fix — a Customer Account UI Extension.** Hosted account pages can only be extended with
  a **Customer Account UI Extension** (Preact/TSX, scaffolded with Shopify CLI, shipped via a
  Shopify app: `shopify app deploy`). Add a **profile** or **full-page** extension with a "Delete
  account" action that links to `/pages/delete-account` (or calls a backend delete endpoint). Docs:
  https://shopify.dev/docs/api/customer-account-ui-extensions . I can write the extension code, but
  it must be deployed through your Shopify app + CLI (can't be done from this environment).
→ **Lighter alternative (riskier):** surface a clearly-labeled "Delete my account" link somewhere
  the reviewer reaches in the app (store menu/footer) pointing to `/pages/delete-account`, and show
  it in the required screen recording. Faster, but Apple prefers it inside the account area — the
  extension is the robust path.

> Note: the deletion page is a **request form** ("we usually complete deletion within 7 days"),
> not instant self-serve. For a non-highly-regulated beauty store this is generally acceptable to
> Apple **as long as it is reachable in-app and the recording shows the full initiate → confirm
> flow**. If Apple pushes back, upgrade the page to complete deletion immediately via an App Proxy
> calling the Admin API `customerDelete`.

---

## 1. What Apple said (verbatim)

**Guideline 4.8 – Design – Login Services**
> The app uses a third-party login service, but does not appear to offer as an equivalent login
> option another login service with all of the following features:
> - The login option limits data collection to the user's name and email address.
> - The login option allows users to keep their email address private from all parties as part of
>   setting up their account.
> - The login option does not collect interactions with the app for advertising purposes without
>   consent.
>
> Note that Sign in with Apple is a login service that meets all the requirements specified in
> guideline 4.8.

**Guideline 5.1.1(v) – Data Collection and Storage – Account Deletion**
> The app supports account creation but does not include an option to initiate account deletion…
> - Only offering to temporarily deactivate or disable an account is insufficient.
> - If users need to visit a website to finish deleting their account, include a link directly to
>   the website page where they can complete the process.
>
> Reply to this message with a screen recording captured on a physical device that demonstrates:
> creating a new account or signing in with the demo account; navigating to the account deletion
> option; the complete account deletion flow from initiation to confirmation.

**Guideline 2.1(a) – Performance – App Completeness**
> The app exhibited one or more bugs that would negatively impact users.
> Bug description: the 'google' button was not responsive.
> Device type: iPad Air 11-inch (M3), OS version: iPadOS 26.5.

---

## 2. Fix #1 — Guideline 4.8 (Login Services)

**Rule:** 4.8 only applies **if the app offers a third-party / social login** (Google, Facebook,
etc.). If the only login option is email/password (or email one-time-code), 4.8 does not apply and
no Sign in with Apple is required.

### Path A — Remove third-party sign-in from the storefront (recommended, fastest)

This is the fastest, lowest-risk route to approval and it **also fixes #3** (the broken Google
button disappears).

**A1 — Primary (Shopify admin, most reliable):** turn off the Google social login so the button is
gone everywhere.
- **New customer accounts:** Shopify **Settings → Customer accounts**. If a third-party/social
  login (Google) is enabled there or via an installed login app, disable it. New customer accounts
  primarily use email one-time codes — confirm no social provider is surfaced.
- **Classic customer accounts / theme-rendered login:** the Google button is markup in the theme's
  `customers/login.liquid` (or a "social login" app block). Remove that block, or the app that
  injects it. (Do this in the theme repo, not here.)
- After the change, open `https://beautyontapp.com/account/login` in **desktop Safari** and confirm
  **no Google/Facebook/Apple third-party buttons** appear — only email login.

**A2 — Fallback (app-side, only if login is theme-rendered on `beautyontapp.com`):** hide social
buttons **inside the app only** via CSS injected into first-party account pages. This is a
best-effort selector-based hide and **must be verified on a device** (I can't reach the live login
page from the build environment, so the selectors below are defensive guesses, not confirmed
matches). It will **not** work if login is served on a Shopify-hosted domain (e.g.
`shop.app` / `account.*`), because the app only injects into `beautyontapp.com` pages
(`lib/store_webview.dart:455-461`) — in that case use A1.

Add to `lib/store_webview.dart`. Call `_hideThirdPartyLoginInApp(controller)` from inside
`_configureBottomSafeArea` (or from `_markPageReady`) after confirming the page is first-party:

```dart
/// 4.8 compliance: hide third-party/social sign-in buttons when the storefront
/// login/account page is viewed INSIDE the app, so the app offers only email
/// login (Apple's 4.8 does not apply when no third-party login is presented).
/// Verify the selectors against the live login DOM on a device before relying
/// on this — theme markup varies. Prefer the Shopify-admin fix (Path A1).
static Future<void> _hideThirdPartyLoginInApp(WebViewController controller) async {
  try {
    await controller.runJavaScript(r'''
(function () {
  if (window.__botHideSocial) return;
  window.__botHideSocial = true;
  var css = [
    // Common Shopify / theme / app selectors for social login blocks.
    '[href*="google" i][href*="auth" i]',
    '[href*="/auth/google" i]',
    'button[class*="google" i]',
    'a[class*="google" i]',
    '[class*="social-login" i]',
    '[class*="oauth" i]',
    '[data-provider="google" i]',
    '[aria-label*="Google" i]',
    '[class*="external-login" i]',
    'form[action*="google" i]'
  ].join(',');
  function hide() {
    document.querySelectorAll(css).forEach(function (el) {
      el.style.setProperty('display', 'none', 'important');
    });
    // Text-match fallback: buttons/links literally labelled "… Google".
    document.querySelectorAll('button, a').forEach(function (el) {
      var t = (el.innerText || '').trim().toLowerCase();
      if (/(sign|log|continue).*(google|facebook)/.test(t) ||
          /(google|facebook).*(sign|log)/.test(t)) {
        el.style.setProperty('display', 'none', 'important');
      }
    });
  }
  hide();
  // Re-hide as the account UI hydrates/renders client-side.
  var n = 0, iv = setInterval(function () { hide(); if (++n > 20) clearInterval(iv); }, 400);
})();
''');
  } catch (_) {}
}
```

> Integration point: inside `_configureBottomSafeArea`, in the `isFirstPartyStore` branch, add
> `await _hideThirdPartyLoginInApp(controller);`. Because it is idempotent (`__botHideSocial`
> guard) it's safe to call on every first-party page.

### Path B — Add Sign in with Apple (Apple-preferred, heavier)

Only choose this if the business wants to keep Google sign-in. It requires, and cannot be shipped
without a build+test cycle:
1. A "Sign in with Apple" button on the login page **and** a working Apple ID → Shopify customer
   token exchange (native `sign_in_with_apple` plugin + your `beautyontapp.net` backend creating/
   linking the Shopify customer), **or** Shopify support for Apple as a login provider.
2. Enable the **Sign In with Apple** capability in the Runner target + provisioning profile.
3. You must still keep Google working (see fix #3) so both are "equivalent".

**Recommendation: Path A.** It clears 4.8 **and** 2.1(a) with no native auth work.

---

## 3. Fix #2 — Guideline 5.1.1(v) (Account Deletion)

The app must let a user **initiate and complete account deletion**, reachable from the account
area, as easily as they signed in. A temporary "deactivate" is **not** enough. A direct **link to a
web page** where deletion is completed is acceptable.

Because accounts are Shopify customer accounts, Shopify has **no self-serve customer deletion** out
of the box — you must add one:

**Option 1 (recommended) — a deletion page on the store + a visible link:**
1. Create a page, e.g. `https://beautyontapp.com/pages/delete-account`, with a short confirm form.
2. Wire its submit to a backend endpoint (Shopify **App Proxy** or your `beautyontapp.net` server)
   that calls the Admin API **`customerDelete`** (GraphQL) / `DELETE /customers/{id}.json` (REST)
   for the signed-in customer, then shows a confirmation. The account must be **actually deleted**,
   not hidden.
3. Surface a **"Delete my account"** link in the storefront account area (theme account page) so a
   logged-in user — and the reviewer — can reach it in-app. Because it's on `beautyontapp.com`, the
   WebView reaches it with no app change.

**Option 2 — native delete screen (only under Path B / native auth):** a Flutter screen calling a
backend delete endpoint. More work; only sensible if you're already building native auth.

**Do not** gate deletion behind "email/call us" — beauty retail is **not** a highly-regulated
industry, so Apple expects self-serve completion.

**In-app reachability check:** after adding the link, confirm that from the app you can:
sign in → open account → tap "Delete my account" → confirm → see the account deleted. That exact
path is what your screen recording (below) must show.

---

## 4. Fix #3 — Guideline 2.1(a) (unresponsive "Google" button)

**Root cause:** Google OAuth opens via a popup / new window (`target="_blank"` / `window.open`),
which `webview_flutter` does not open by default, so tapping the button does nothing — most visible
on iPad. `lib/store_webview.dart:56-62` already spoofs a Safari user agent to get past Google's
embedded-webview block, but that doesn't handle the new window.

- **If you take Path A (recommended):** the Google button is gone → this bug cannot occur. **Done.**
- **If you keep Google (Path B):** handle new-window / popup navigation so the OAuth window opens.
  On iOS `WKWebView`, `window.open` needs `WKUIDelegate.createWebViewWith` to load the request in
  the main web view. In `webview_flutter` this means configuring the WebKit controller to load
  popup targets in-place (or routing OAuth to an external browser / `SFSafariViewController`).
  This requires a build+test pass on a physical iPad.

Either way, **re-test on an iPad** (iPadOS 26.x) before resubmitting — the reviewer used one.

---

## 5. Privacy manifest (hardening — not one of the three blockers)

A ready-to-use `ios/Runner/PrivacyInfo.xcprivacy` has been added in this branch. It is **not**
required to clear this rejection, but declaring the "required reason" APIs your plugins use
(`shared_preferences` → NSUserDefaults; `get_storage`/`path_provider` → file timestamp) prevents
the ITMS-91053 privacy-manifest warning on future uploads.

**To activate it (one step, in Xcode):** open `ios/Runner.xcworkspace` → select
`PrivacyInfo.xcprivacy` under the **Runner** group → in the File Inspector, tick **Target
Membership → Runner**. (I did not wire it into `project.pbxproj` automatically because I can't
build/verify here and a bad project-file edit would break your Xcode Cloud build.)

---

## 6. App Store Connect — steps only you can do

I cannot submit or reply on your behalf (no access to your Apple account). After the fixes above
are built into a new build via Xcode Cloud:

1. **Increment the build number** (e.g. `1.1.2 (build 5)`), upload via Xcode Cloud.
2. **App Privacy** (App Store Connect → your app → App Privacy): make sure the data the **store**
   collects (email, name, purchase history, etc.) is declared. Unrelated to the manifest, but a
   common secondary flag.
3. **App Review Information → Notes:** paste the reply template (§7) and add a **demo account**
   (email + password) so the reviewer can sign in without Google.
4. Attach the **account-deletion screen recording** (see §7.2) — Apple explicitly requested it, and
   asks you to keep it in the Notes field for future submissions.
5. Select the new build and **Submit for Review**.

---

## 7. Resolution Center reply templates

Reply to Apple in the Resolution Center thread (App Store Connect) once the new build is attached.

### 7.1 — For 4.8 + 2.1(a) (Path A: Google removed)

> Thank you for the review. In this build we have removed the third-party "Sign in with Google"
> option from the app. The app now offers only email-based sign-in, so guideline 4.8's third-party
> login requirement no longer applies. This also resolves the 2.1(a) report: the unresponsive
> "Google" button has been removed. A demo account is provided in App Review Information for email
> sign-in.

### 7.1b — For 4.8 (Path B: Sign in with Apple added)

> This build adds Sign in with Apple as an equivalent login option alongside Google. Sign in with
> Apple limits data collection to name and email, lets users hide their email (Hide My Email), and
> does not track interactions for advertising, meeting all guideline 4.8 requirements.

### 7.2 — For 5.1.1(v) (account deletion)

> The app now provides in-app account deletion. From the account area, users tap "Delete my
> account", confirm, and the account is permanently deleted. A screen recording captured on a
> physical device is attached, showing: (1) signing in with the demo account, (2) navigating to the
> account deletion option, and (3) the complete deletion flow from initiation to confirmation. The
> recording is also saved in App Review Information → Notes for future submissions.

**Screen recording checklist (physical device, per Apple):**
- [ ] Sign in with the demo account (or create a new account)
- [ ] Navigate to the "Delete my account" option
- [ ] Show the full deletion flow initiation → confirmation

---

## 8. Recommended order of operations

1. **Shopify:** disable Google social login (§2 A1). — clears 4.8 + 2.1(a)
2. **Shopify + backend:** build the delete-account page/flow + visible account link (§3).
3. **App Store Connect:** add a demo account; declare App Privacy data (§6).
4. **Build:** bump build number, upload via Xcode Cloud. (Optional: activate the privacy manifest, §5.)
5. **Record:** capture the account-deletion screen recording on a real iPhone/iPad (§7.2).
6. **Submit** the new build + **reply** in Resolution Center with the templates (§7) and recording.

---

## 9. What was done in this branch vs. what needs you

**Done here (safe, no build/Apple access required):**
- This runbook (`APP_STORE_REVIEW.md`).
- `ios/Runner/PrivacyInfo.xcprivacy` (ready to activate in Xcode — hardening only).
- Drafted, verify-on-device app-side code for hiding third-party login (§2 A2).

**Needs you / a build environment (I can't do these from here):**
- Shopify admin/theme changes (disable Google login; add delete-account flow + link).
- Any Flutter build/test (no Flutter toolchain in this environment).
- Uploading a build, App Privacy declarations, demo account, screen recording, and Submit/Reply
  in App Store Connect (no access to your Apple account).
