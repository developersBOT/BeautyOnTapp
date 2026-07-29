import 'package:beautyontapp/store_load_policy.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StoreLoadPolicy lifecycle recovery', () {
    test('background failures coalesce and never surface immediately', () {
      final StoreLoadPolicy policy = StoreLoadPolicy();

      policy.didChangeLifecycle(AppLifecycleState.paused);
      policy.deferRecovery();
      policy.deferRecovery();

      expect(policy.isResumed, isFalse);
      expect(policy.resumeRecoveryPending, isTrue);
      expect(
        policy.shouldSurfaceResourceError(
          isForMainFrame: true,
          errorCode: -1009,
        ),
        isFalse,
      );

      policy.didChangeLifecycle(AppLifecycleState.resumed);
      expect(
        policy.consumeResumeRecovery(
          pageReady: true,
          loadFailed: false,
          recoveryInFlight: false,
        ),
        isTrue,
      );
      expect(
        policy.consumeResumeRecovery(
          pageReady: true,
          loadFailed: false,
          recoveryInFlight: false,
        ),
        isFalse,
      );
    });

    test(
      'only active main-frame non-cancellation errors can fail the page',
      () {
        final StoreLoadPolicy policy = StoreLoadPolicy();

        expect(
          policy.shouldSurfaceResourceError(
            isForMainFrame: false,
            errorCode: -1009,
          ),
          isFalse,
        );
        expect(
          policy.shouldSurfaceResourceError(
            isForMainFrame: null,
            errorCode: -1009,
          ),
          isFalse,
        );
        expect(
          policy.shouldSurfaceResourceError(
            isForMainFrame: true,
            errorCode: -999,
          ),
          isFalse,
        );
        expect(
          policy.shouldSurfaceResourceError(
            isForMainFrame: true,
            errorCode: -1009,
            resumeValidationInFlight: true,
          ),
          isFalse,
        );
        expect(
          policy.shouldSurfaceResourceError(
            isForMainFrame: true,
            errorCode: -1009,
          ),
          isTrue,
        );
      },
    );

    test('main-frame errors coalesce once per navigation generation', () {
      final StoreLoadPolicy policy = StoreLoadPolicy();

      expect(
        policy.shouldHandleMainFrameErrorForNavigation(
          isForMainFrame: true,
          errorCode: -1009,
          navigationGeneration: 4,
          handledNavigationGeneration: null,
        ),
        isTrue,
      );
      expect(
        policy.shouldHandleMainFrameErrorForNavigation(
          isForMainFrame: true,
          errorCode: -1009,
          navigationGeneration: 4,
          handledNavigationGeneration: 4,
        ),
        isFalse,
      );
      expect(
        policy.shouldHandleMainFrameErrorForNavigation(
          isForMainFrame: true,
          errorCode: -1009,
          navigationGeneration: 5,
          handledNavigationGeneration: 4,
        ),
        isTrue,
      );
      expect(
        policy.shouldHandleMainFrameErrorForNavigation(
          isForMainFrame: true,
          errorCode: -999,
          navigationGeneration: 5,
          handledNavigationGeneration: 4,
        ),
        isFalse,
      );
    });

    test('every background state invalidates an armed foreground timeout', () {
      for (final AppLifecycleState state in <AppLifecycleState>[
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        final StoreLoadPolicy policy = StoreLoadPolicy();
        const int navigationGeneration = 7;
        final int scheduledEpoch = policy.lifecycleEpoch;

        policy.didChangeLifecycle(state);
        expect(
          policy.isCurrentLoadTimeout(
            scheduledNavigationGeneration: navigationGeneration,
            currentNavigationGeneration: navigationGeneration,
            scheduledLifecycleEpoch: scheduledEpoch,
            pageReady: false,
          ),
          isFalse,
        );

        policy.didChangeLifecycle(AppLifecycleState.resumed);
        expect(
          policy.isCurrentLoadTimeout(
            scheduledNavigationGeneration: navigationGeneration,
            currentNavigationGeneration: navigationGeneration,
            scheduledLifecycleEpoch: scheduledEpoch,
            pageReady: false,
          ),
          isFalse,
        );

        expect(
          policy.isCurrentLoadTimeout(
            scheduledNavigationGeneration: navigationGeneration,
            currentNavigationGeneration: navigationGeneration,
            scheduledLifecycleEpoch: policy.lifecycleEpoch,
            pageReady: false,
          ),
          isTrue,
        );
      }
    });

    test('a ready page cannot be failed by an overdue timeout', () {
      final StoreLoadPolicy policy = StoreLoadPolicy();

      expect(
        policy.isCurrentLoadTimeout(
          scheduledNavigationGeneration: 4,
          currentNavigationGeneration: 4,
          scheduledLifecycleEpoch: policy.lifecycleEpoch,
          pageReady: true,
        ),
        isFalse,
      );
    });

    test('fallback loads are limited to safe first-party GET pages', () {
      final StoreLoadPolicy policy = StoreLoadPolicy();

      expect(
        policy.isSafeStorefrontRecoveryFallback(
          Uri.parse('https://beautyontapp.com/collections/skincare'),
        ),
        isTrue,
      );
      expect(
        policy.isSafeStorefrontRecoveryFallback(
          Uri.parse('https://www.beautyontapp.com/products/example'),
        ),
        isTrue,
      );
      for (final String url in <String>[
        'http://beautyontapp.com/collections/skincare',
        'https://beautyontapp.com/checkout',
        'https://beautyontapp.com/checkouts/example',
        'https://beautyontapp.com/account',
        'https://beautyontapp.com/account/login',
        'https://beautyontapp.com/account%2Flogin',
        'https://beautyontapp.com/%61ccount/login',
        'https://beautyontapp.com/checkouts%2Fexample',
        'https://beautyontapp.com/oauth/authorize',
        'https://beautyontapp.com/oauth%2Fauthorize',
        'https://beautyontapp.com:8443/collections/skincare',
        'https://beautyontapp.com.evil.example/collections/skincare',
        'https://accounts.google.com/signin',
      ]) {
        expect(
          policy.isSafeStorefrontRecoveryFallback(Uri.parse(url)),
          isFalse,
          reason: url,
        );
      }
    });

    test('resume requires the full probe set and any healthy result wins', () {
      final StoreLoadPolicy policy = StoreLoadPolicy();

      expect(policy.shouldRecoverAfterResumeProbes(<bool?>[false]), isFalse);
      expect(
        policy.shouldRecoverAfterResumeProbes(<bool?>[false, null]),
        isFalse,
      );
      expect(
        policy.shouldRecoverAfterResumeProbes(<bool?>[false, null, false]),
        isFalse,
      );
      expect(
        policy.shouldRecoverAfterResumeProbes(<bool?>[null, null, null]),
        isFalse,
      );
      expect(
        policy.shouldRecoverAfterResumeProbes(<bool?>[false, false, false]),
        isTrue,
      );
      expect(
        policy.shouldRecoverAfterResumeProbes(<bool?>[
          false,
          false,
        ], requiredProbeCount: 2),
        isTrue,
      );
      expect(
        policy.shouldRecoverAfterResumeProbes(<bool?>[
          false,
          null,
        ], requiredProbeCount: 2),
        isFalse,
      );
      expect(
        policy.shouldRecoverAfterResumeProbes(<bool?>[false, null, true]),
        isFalse,
      );
    });

    test('latched failure is always eligible for foreground validation', () {
      final StoreLoadPolicy policy = StoreLoadPolicy();

      expect(
        policy.consumeResumeRecovery(
          pageReady: false,
          loadFailed: true,
          recoveryInFlight: false,
        ),
        isTrue,
      );
    });

    test(
      'an explicit main-frame error recovers after bounded nonhealthy probes',
      () {
        final StoreLoadPolicy policy = StoreLoadPolicy();

        expect(
          policy.shouldRecoverAfterMainFrameErrorProbes(<bool?>[null]),
          isFalse,
        );
        expect(
          policy.shouldRecoverAfterMainFrameErrorProbes(<bool?>[null, null]),
          isTrue,
        );
        expect(
          policy.shouldRecoverAfterMainFrameErrorProbes(<bool?>[false, null]),
          isTrue,
        );
        expect(
          policy.shouldRecoverAfterMainFrameErrorProbes(<bool?>[null, true]),
          isFalse,
        );
        expect(
          policy.shouldRecoverAfterMainFrameErrorProbes(<bool?>[
            null,
            null,
            null,
          ], requiredProbeCount: 3),
          isTrue,
        );
      },
    );
  });
}
