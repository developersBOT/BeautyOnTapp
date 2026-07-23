import 'package:beautyontapp/store_navigation_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Store navigation policy', () {
    test('keeps secure BeautyOnTApp pages inside the app', () {
      for (final String url in <String>[
        'https://beautyontapp.com/',
        'https://www.beautyontapp.com/cart',
        'https://shop.beautyontapp.com/collections/skincare',
      ]) {
        expect(
          StoreNavigationPolicy.shouldAllowMainFrame(
            url,
            protectedFlowActive: false,
          ),
          isTrue,
          reason: url,
        );
      }
    });

    test('blocks external promotional and app-download destinations', () {
      for (final String url in <String>[
        'https://apps.apple.com/app/id123',
        'https://play.google.com/store/apps/details?id=example',
        'https://example.com/promotion',
        'market://details?id=example',
        'itms-apps://apps.apple.com/app/id123',
      ]) {
        expect(
          StoreNavigationPolicy.shouldAllowMainFrame(
            url,
            protectedFlowActive: false,
          ),
          isFalse,
          reason: url,
        );
      }
    });

    test('never opens an app-download destination during protected flows', () {
      for (final String url in <String>[
        'https://apps.apple.com/app/id123',
        'https://play.google.com/store/apps/details?id=example',
        'market://details?id=example',
        'itms-apps://apps.apple.com/app/id123',
      ]) {
        expect(
          StoreNavigationPolicy.shouldAllowMainFrame(
            url,
            protectedFlowActive: true,
          ),
          isFalse,
          reason: url,
        );
      }
    });

    test('allows external redirects only during a protected flow', () {
      for (final String url in <String>[
        'https://beautyontapp.com/checkouts/session-id',
        'https://account.beautyontapp.com/',
      ]) {
        expect(
          StoreNavigationPolicy.isProtectedFirstPartyFlow(url),
          isTrue,
          reason: url,
        );
      }

      expect(
        StoreNavigationPolicy.shouldAllowMainFrame(
          'https://accounts.google.com/signin',
          protectedFlowActive: true,
        ),
        isTrue,
      );
      expect(
        StoreNavigationPolicy.shouldAllowMainFrame(
          'https://secure-payment-provider.example/session',
          protectedFlowActive: true,
        ),
        isTrue,
      );
      expect(
        StoreNavigationPolicy.shouldAllowMainFrame(
          'https://secure-payment-provider.example/session',
          protectedFlowActive: false,
        ),
        isFalse,
      );
    });

    test('rejects insecure and lookalike storefront hosts', () {
      for (final String url in <String>[
        'http://beautyontapp.com/',
        'https://beautyontapp.com.example.com/',
        'https://evilbeautyontapp.com/',
      ]) {
        expect(
          StoreNavigationPolicy.shouldAllowMainFrame(
            url,
            protectedFlowActive: false,
          ),
          isFalse,
          reason: url,
        );
      }
    });
  });
}
