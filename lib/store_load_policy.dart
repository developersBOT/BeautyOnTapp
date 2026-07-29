import 'package:flutter/widgets.dart';

/// Pure lifecycle/error policy for the storefront WebView.
///
/// Keeping these decisions outside the controller makes the background/resume
/// rules deterministic and unit-testable without constructing a platform
/// WebView.
class StoreLoadPolicy {
  StoreLoadPolicy({AppLifecycleState initialState = AppLifecycleState.resumed})
    : _lifecycleState = initialState;

  AppLifecycleState _lifecycleState;
  bool _resumeRecoveryPending = false;
  int _lifecycleEpoch = 0;

  AppLifecycleState get lifecycleState => _lifecycleState;
  bool get isResumed => _lifecycleState == AppLifecycleState.resumed;
  bool get resumeRecoveryPending => _resumeRecoveryPending;
  int get lifecycleEpoch => _lifecycleEpoch;

  void didChangeLifecycle(AppLifecycleState state) {
    _lifecycleState = state;
    _lifecycleEpoch++;
    if (!isResumed) {
      _resumeRecoveryPending = true;
    }
  }

  /// Coalesces any number of background failures into one foreground check.
  void deferRecovery() {
    _resumeRecoveryPending = true;
    _lifecycleEpoch++;
  }

  bool consumeResumeRecovery({
    required bool pageReady,
    required bool loadFailed,
    required bool recoveryInFlight,
  }) {
    final bool shouldValidate =
        _resumeRecoveryPending || !pageReady || loadFailed || recoveryInFlight;
    _resumeRecoveryPending = false;
    return shouldValidate;
  }

  /// Full-page failure UI is valid only for an active foreground main frame.
  bool shouldSurfaceResourceError({
    required bool? isForMainFrame,
    required int errorCode,
    bool resumeValidationInFlight = false,
  }) {
    return isResumed &&
        !resumeValidationInFlight &&
        isForMainFrame == true &&
        errorCode != -999;
  }

  /// WebKit may emit several main-frame callbacks for one failed navigation.
  /// Only the first non-cancellation error for that navigation owns recovery.
  bool shouldHandleMainFrameErrorForNavigation({
    required bool? isForMainFrame,
    required int errorCode,
    required int navigationGeneration,
    required int? handledNavigationGeneration,
  }) {
    return isForMainFrame == true &&
        errorCode != -999 &&
        handledNavigationGeneration != navigationGeneration;
  }

  /// A timeout is valid only for the exact foreground navigation that armed it.
  bool isCurrentLoadTimeout({
    required int scheduledNavigationGeneration,
    required int currentNavigationGeneration,
    required int scheduledLifecycleEpoch,
    required bool pageReady,
  }) {
    return isResumed &&
        !pageReady &&
        scheduledNavigationGeneration == currentNavigationGeneration &&
        scheduledLifecycleEpoch == _lifecycleEpoch;
  }

  bool isSafeStorefrontRecoveryFallback(Uri uri) {
    final String host = uri.host.toLowerCase();
    final String encodedPath = uri.path.toLowerCase();
    // Recovery never needs to convert an encoded route into a new GET.
    // Treat every percent-encoded path as reload-only so encoded slashes,
    // letters, dot-segments, or malformed escapes cannot disguise a
    // checkout/account/OAuth route.
    if (encodedPath.contains('%')) return false;
    late final String path;
    try {
      path = Uri.decodeComponent(encodedPath);
    } on FormatException {
      return false;
    }
    final bool isBeautyOnTAppHost =
        host == 'beautyontapp.com' || host.endsWith('.beautyontapp.com');
    final bool isProtectedFlow =
        path == '/checkout' ||
        path == '/checkouts' ||
        path.startsWith('/checkouts/') ||
        path == '/account' ||
        path.startsWith('/account/') ||
        path == '/oauth' ||
        path.startsWith('/oauth/');
    final bool usesDefaultHttpsPort = !uri.hasPort || uri.port == 443;
    return uri.scheme == 'https' &&
        usesDefaultHttpsPort &&
        isBeautyOnTAppHost &&
        !isProtectedFlow;
  }

  /// A healthy or inconclusive result wins. Ordinary resume recovery requires
  /// the complete bounded probe set to be definitely unhealthy.
  bool shouldRecoverAfterResumeProbes(
    List<bool?> results, {
    int requiredProbeCount = 3,
  }) {
    return results.length >= requiredProbeCount &&
        results
            .take(requiredProbeCount)
            .every((bool? result) => result == false);
  }

  /// Once WebKit reports a real main-frame error, an inconclusive JavaScript
  /// probe is no longer enough to defer forever. Wait for the complete
  /// bounded probe set, preserve the page if any probe is healthy, otherwise
  /// allow the controller to attempt its bounded automatic recovery.
  bool shouldRecoverAfterMainFrameErrorProbes(
    List<bool?> results, {
    int requiredProbeCount = 2,
  }) {
    return results.length >= requiredProbeCount &&
        !results.take(requiredProbeCount).any((bool? result) => result == true);
  }
}
