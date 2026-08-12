# BeautyOnTApp

BeautyOnTApp is a Flutter WebView wrapper for the first-party storefront at
`https://beautyontapp.com`.

## Runtime architecture

The shipped app has one live path:

`lib/main.dart` → `lib/splash_screen.dart` → `lib/store_webview.dart`

The store URL is hardcoded so app startup has no remote configuration or
external API dependency. Storefront browsing, customer accounts, cart and
checkout remain owned by the website inside the WebView.

## App-attribution measurement

Initial and error-recovery store loads include platform-specific app UTMs.
Website analytics and purchase attribution continue through the existing web
tracking implementation.

Before running any App campaigns, integrate Firebase Analytics + Google Ads app conversion import (needs google-services.json / GoogleService-Info.plist from the Firebase project).

Firebase is intentionally not included until the required project credentials
are available.
