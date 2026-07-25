# iOS 1.1.2 build 9 — theme-owned account deletion

Date: 25 July 2026

## Verified

- The Flutter app no longer injects a Delete Account profile row.
- The Flutter app no longer rewrites the theme's `/pages/delete-account` form.
- The hosted customer login presents the first-party email verification-code flow without a Google sign-in button on the iPad Air 11-inch (M3), iOS 26.5 simulator.
- `flutter analyze` completed with no issues.
- All 11 Flutter tests passed.
- `ios/Runner/Info.plist` passed `plutil -lint`.
- The iOS simulator build completed successfully with Xcode 26.6.
- The simulator launch log contained no matched critical app errors.

## Evidence

- `01-ipad-launch.png`: storefront launch on the Apple-review iPad simulator.
- `02-ipad-email-login.png`: first-party email login on the Apple-review iPad simulator.
- `critical.log`: filtered critical simulator log output.

## Not verified

- Physical-iPad camera and photo-library flows.
- Physical-iPad account deletion flow after email-code authentication.
- Permanent account deletion completion.
- App Store review credentials and review-notes acceptance.
