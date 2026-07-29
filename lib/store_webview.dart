import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'store_load_policy.dart';

// The store URL is HARDCODED by design. The app must load with zero external
// API dependencies — do not replace this with a remote lookup of any kind.
const String kStoreUrl = 'https://beautyontapp.com';

/// Store root with app-attribution UTMs. The spoofed browser user agent
/// (required for Google OAuth) makes app sessions indistinguishable from
/// mobile web in Shopify/GA4 — these parameters are the only signal that a
/// session came from the app. Applied to the initial load and recovery
/// reloads only; in-page navigation keeps the session's first-touch UTMs.
Uri storeRootUri() => Uri.parse(kStoreUrl).replace(
  queryParameters: {
    'utm_source': 'beautyontapp_app',
    'utm_medium': 'app',
    'utm_campaign': defaultTargetPlatform == TargetPlatform.iOS
        ? 'app_ios'
        : 'app_android',
  },
);

/// Browser-like user agent shared by every WebView in the app so first-party
/// analytics cookies stay consistent across the storefront and checkout.
String get kBrowserUserAgent => defaultTargetPlatform == TargetPlatform.iOS
    ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) '
          'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 '
          'Mobile/15E148 Safari/604.1'
    : 'Mozilla/5.0 (Linux; Android 15) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36';

class StoreWebView extends StatefulWidget {
  const StoreWebView({super.key});

  static WebViewController? _preloaded;
  // Bumped on every navigation event so the screen can re-check history state.
  static final ValueNotifier<int> _navTick = ValueNotifier<int>(0);
  static final ValueNotifier<bool> _loadFailed = ValueNotifier<bool>(false);
  // True after a BeautyOnTApp page has been prepared to use the iPhone's
  // bottom safe area. The app always protects the status bar itself, while
  // the theme-owned dock uses env(safe-area-inset-bottom) at the bottom.
  static final ValueNotifier<bool> _pageExtendsIntoBottomSafeArea =
      ValueNotifier<bool>(false);
  // Flips true once the FIRST page has fully rendered. Until then a black
  // brand cover hides the WebView so the user never sees a white screen
  // between the splash and the store.
  static final ValueNotifier<bool> _firstPageReady = ValueNotifier<bool>(false);
  static Timer? _loadTimeout;
  static final StoreLoadPolicy _loadPolicy = StoreLoadPolicy();
  static int _navigationGeneration = 0;
  static int? _paintProbeGeneration;
  static int _resumeValidationGeneration = 0;
  static bool _resumeValidationInFlight = false;
  static bool _mainFrameErrorRecoveryPending = false;
  static int? _handledMainFrameErrorGeneration;
  static bool _recoveryInFlight = false;
  static bool _webContentProcessRecoveryPending = false;
  static int _automaticRecoveryAttempts = 0;
  static const int _maxAutomaticRecoveryAttempts = 2;
  // Shopify can keep document.readyState at "loading" while its already
  // painted storefront continues fetching deferred app/theme resources.
  // Main-frame failures still surface immediately through the delegate; this
  // timeout only catches a genuinely hung navigation.
  static const Duration _loadTimeoutDuration = Duration(seconds: 45);

  /// True once the first store page has fully rendered. The splash screen
  /// uses this to skip its hold phase when the store is already loaded.
  static bool get isStoreReady => _firstPageReady.value;
  static ValueListenable<bool> get storeReadyListenable => _firstPageReady;

  /// Called from main() so the store starts warming behind the branded launch
  /// surface. The controller is created immediately, but the actual page load
  /// waits for the first Flutter frame — see _scheduleInitialLoad.
  static void preload() {
    _preloaded ??= _buildController();
  }

  // Google blocks OAuth inside embedded WebViews it can detect. A browser-like
  // user agent lets "Sign in with Google" on the store work inside the app.
  static String get _userAgent => kBrowserUserAgent;

  static WebViewController _buildController() {
    late final WebViewController controller;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_userAgent)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            // A tap can start a real navigation while the bounded resume
            // health check is still probing the previously committed page.
            // Hand ownership to the new navigation immediately so its
            // main-frame errors are not suppressed as resume noise.
            if (_loadPolicy.isResumed && _resumeValidationInFlight) {
              _resumeValidationGeneration++;
              _resumeValidationInFlight = false;
            }
            if (_loadPolicy.isResumed) {
              _mainFrameErrorRecoveryPending = false;
            }
            _navigationGeneration++;
            _handledMainFrameErrorGeneration = null;
            _navTick.value++;
            if (!_loadPolicy.isResumed) {
              _deferRecoveryUntilResume(invalidateNavigation: false);
              return;
            }
            _loadFailed.value = false;
            if (!_firstPageReady.value) {
              _armLoadTimeout(controller);
              // Shopify's document can paint well before WebKit reports 80%
              // progress. Probe from navigation start so the native cover
              // leaves on the first useful frame, not after deferred scripts.
              _schedulePaintConfirmation(controller);
            }
          },
          onUrlChange: (_) => _navTick.value++,
          onProgress: (int progress) {
            if (!_loadPolicy.isResumed) return;
            if (progress >= 80) _schedulePaintConfirmation(controller);
          },
          onPageFinished: (_) {
            _navTick.value++;
            if (!_loadPolicy.isResumed) {
              _deferRecoveryUntilResume(invalidateNavigation: false);
              return;
            }
            unawaited(_handlePageFinished(controller));
          },
          onWebResourceError: (WebResourceError error) {
            // iOS can terminate WKWebView's content process while Flutter
            // remains alive. Coalesce that signal into the lifecycle-aware
            // health check instead of reloading while WebKit is suspended or
            // still thawing on foreground.
            if (error.errorType ==
                WebResourceErrorType.webContentProcessTerminated) {
              if (_webContentProcessRecoveryPending) return;
              _webContentProcessRecoveryPending = true;
              _deferRecoveryUntilResume();
              _handledMainFrameErrorGeneration = _navigationGeneration;
              if (_loadPolicy.isResumed) {
                unawaited(_validateAfterResume(controller));
              }
              return;
            }

            final bool isMainFrameFailure =
                error.isForMainFrame == true && error.errorCode != -999;
            if (isMainFrameFailure &&
                !_loadPolicy.shouldHandleMainFrameErrorForNavigation(
                  isForMainFrame: error.isForMainFrame,
                  errorCode: error.errorCode,
                  navigationGeneration: _navigationGeneration,
                  handledNavigationGeneration: _handledMainFrameErrorGeneration,
                )) {
              return;
            }
            if (isMainFrameFailure) {
              _handledMainFrameErrorGeneration = _navigationGeneration;
              _mainFrameErrorRecoveryPending = true;
            }

            if (!_loadPolicy.shouldSurfaceResourceError(
              isForMainFrame: error.isForMainFrame,
              errorCode: error.errorCode,
              resumeValidationInFlight: _resumeValidationInFlight,
            )) {
              if (!_loadPolicy.isResumed && isMainFrameFailure) {
                _deferRecoveryUntilResume();
                _handledMainFrameErrorGeneration = _navigationGeneration;
              }
              return;
            }

            unawaited(_handleForegroundNavigationError(controller));
          },
        ),
      );

    // iOS: navigate the WebView back/forward with the native swipe gesture.
    final platform = controller.platform;
    if (platform is WebKitWebViewController) {
      platform.setAllowsBackForwardNavigationGestures(true);
    }
    _scheduleInitialLoad(controller);
    return controller;
  }

  /// Starts the first page load only AFTER the first Flutter frame, once the
  /// platform WKWebView has been attached and sized. If the load starts while
  /// the native view still has a zero frame, WebKit commits the page with a
  /// 0x0 layout viewport — innerWidth 0, every vw unit 0, media queries
  /// collapsed, zero-area lazy images never fetched — and it never recovers
  /// on its own. On slow launches this is the "Exclusive tab shows no product
  /// images" bug (fast devices win the race, which is why it only appeared on
  /// some phones). The splash overlay fully covers this deferral.
  static void _scheduleInitialLoad(WebViewController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        unawaited(_loadStoreRoot(controller));
      });
    });
  }

  static Future<void> _loadStoreRoot(WebViewController controller) async {
    _viewportReloadUsed = false;
    unawaited(controller.setBackgroundColor(Colors.black));
    _showLoadingCover();
    _navigationGeneration++;
    _armLoadTimeout(controller);
    try {
      await controller.loadRequest(storeRootUri());
    } catch (_) {
      _showLoadFailure();
    }
  }

  static void _showLoadingCover() {
    _loadFailed.value = false;
    _firstPageReady.value = false;
    _pageExtendsIntoBottomSafeArea.value = false;
  }

  static void _deferRecoveryUntilResume({bool invalidateNavigation = true}) {
    _loadTimeout?.cancel();
    _loadTimeout = null;
    _loadPolicy.deferRecovery();
    _recoveryInFlight = false;
    _resumeValidationGeneration++;
    _resumeValidationInFlight = false;
    if (invalidateNavigation) {
      _navigationGeneration++;
      _paintProbeGeneration = null;
    }
  }

  static void _showLoadFailure() {
    if (!_loadPolicy.isResumed) {
      _deferRecoveryUntilResume();
      return;
    }
    _loadTimeout?.cancel();
    _loadTimeout = null;
    if (!_loadFailed.value) _navigationGeneration++;
    _paintProbeGeneration = null;
    _recoveryInFlight = false;
    _mainFrameErrorRecoveryPending = false;
    _firstPageReady.value = false;
    _loadFailed.value = true;
  }

  static void _armLoadTimeout(WebViewController controller) {
    _loadTimeout?.cancel();
    if (!_loadPolicy.isResumed) {
      _loadTimeout = null;
      _deferRecoveryUntilResume(invalidateNavigation: false);
      return;
    }
    final int navigationGeneration = _navigationGeneration;
    final int lifecycleEpoch = _loadPolicy.lifecycleEpoch;
    _loadTimeout = Timer(_loadTimeoutDuration, () {
      if (!_loadPolicy.isResumed) {
        _deferRecoveryUntilResume(invalidateNavigation: false);
        return;
      }
      if (_loadPolicy.isCurrentLoadTimeout(
        scheduledNavigationGeneration: navigationGeneration,
        currentNavigationGeneration: _navigationGeneration,
        scheduledLifecycleEpoch: lifecycleEpoch,
        pageReady: _firstPageReady.value,
      )) {
        if (_recoveryInFlight &&
            _automaticRecoveryAttempts < _maxAutomaticRecoveryAttempts) {
          _recoveryInFlight = false;
          unawaited(_recoverWebContent(controller));
        } else {
          _showLoadFailure();
        }
      }
    });
  }

  static void _schedulePaintConfirmation(WebViewController controller) {
    final int generation = _navigationGeneration;
    if (_paintProbeGeneration == generation) return;
    _paintProbeGeneration = generation;
    unawaited(_confirmMeaningfulPaint(controller, generation));
  }

  static Future<void> _handlePageFinished(WebViewController controller) async {
    final int generation = _navigationGeneration;
    if (await _healZeroViewport(controller)) return;
    if (generation != _navigationGeneration || _loadFailed.value) return;
    _schedulePaintConfirmation(controller);
  }

  /// WebView progress 100 and onPageFinished only mean that navigation ended;
  /// they do not prove that WebKit has painted useful content. Keep the native
  /// cover visible until the document has a visible, non-empty layout.
  static Future<void> _confirmMeaningfulPaint(
    WebViewController controller,
    int generation,
  ) async {
    try {
      for (int attempt = 0; attempt < 75; attempt++) {
        await Future.delayed(Duration(milliseconds: attempt == 0 ? 120 : 400));
        if (generation != _navigationGeneration) return;
        if (await _hasMeaningfulContent(controller)) {
          await _markPageReady(controller, generation);
          return;
        }
      }
    } finally {
      if (_paintProbeGeneration == generation) {
        _paintProbeGeneration = null;
      }
    }
  }

  static Future<bool> _hasMeaningfulContent(
    WebViewController controller,
  ) async => await _probeMeaningfulContent(controller) == true;

  /// Returns null when WebKit cannot answer yet (common while its content
  /// process is thawing after resume). That is inconclusive, not proof that
  /// the document is empty.
  static Future<bool?> _probeMeaningfulContent(
    WebViewController controller,
  ) async {
    try {
      final Object result = await controller.runJavaScriptReturningResult(r'''
(() => {
  const body = document.body;
  const root = document.documentElement;
  if (!body || !root) return false;

  const text = (body.innerText || '').replace(/\s+/g, ' ').trim();
  const title = (document.title || '').trim();
  const viewportReady = window.innerWidth > 1 && window.innerHeight > 1;
  const documentReady = body.childElementCount > 0 && root.scrollHeight > 40;
  const hasLoadedImage = Array.from(document.images).some(
    (image) => image.complete && image.naturalWidth > 0
  );

  return viewportReady &&
    documentReady &&
    (text.length >= 24 || title.length >= 3 || hasLoadedImage);
})()
''');
      final String normalized = result.toString().replaceAll('"', '').trim();
      return result == true || normalized == 'true' || normalized == '1';
    } catch (_) {
      return null;
    }
  }

  static Future<void> _handleForegroundNavigationError(
    WebViewController controller,
  ) async {
    if (!_loadPolicy.isResumed) {
      _deferRecoveryUntilResume();
      return;
    }

    final int generation = _navigationGeneration;
    final List<bool?> probeResults = <bool?>[];
    if (_firstPageReady.value) {
      // A failed provisional navigation normally leaves the last committed
      // page intact. Give it two chances to prove that before covering it.
      for (final Duration delay in const <Duration>[
        Duration(milliseconds: 250),
        Duration(milliseconds: 500),
      ]) {
        await Future.delayed(delay);
        if (!_loadPolicy.isResumed || generation != _navigationGeneration) {
          return;
        }
        final bool? result = await _probeMeaningfulContent(controller);
        if (!_loadPolicy.isResumed || generation != _navigationGeneration) {
          return;
        }
        if (result == true) {
          _loadTimeout?.cancel();
          _loadTimeout = null;
          _mainFrameErrorRecoveryPending = false;
          _loadFailed.value = false;
          return;
        }
        probeResults.add(result);
      }
      if (!_loadPolicy.shouldRecoverAfterResumeProbes(
        probeResults,
        requiredProbeCount: 2,
      )) {
        if (!_loadPolicy.shouldRecoverAfterMainFrameErrorProbes(
          probeResults,
          requiredProbeCount: 2,
        )) {
          _loadPolicy.deferRecovery();
          return;
        }
      }

      // The delegate already confirmed a main-frame failure. If neither
      // bounded probe could prove the old page healthy, heal on this same
      // foreground cycle rather than waiting for another app switch.
      if (_recoveryInFlight) _recoveryInFlight = false;
      await _recoverWebContent(controller);
      return;
    }

    if (_recoveryInFlight &&
        _automaticRecoveryAttempts < _maxAutomaticRecoveryAttempts) {
      _recoveryInFlight = false;
      await _recoverWebContent(controller);
      return;
    }
    _showLoadFailure();
  }

  static Future<void> _markPageReady(
    WebViewController controller,
    int generation,
  ) async {
    if (generation != _navigationGeneration || _loadFailed.value) return;
    if (await _healZeroViewport(controller)) return;
    if (generation != _navigationGeneration || _loadFailed.value) return;
    await _configureBottomSafeArea(controller);
    if (generation != _navigationGeneration || _loadFailed.value) return;
    await _installWebKitTabTapRecovery(controller);
    if (generation != _navigationGeneration || _loadFailed.value) return;
    await controller.setBackgroundColor(Colors.white);
    if (generation != _navigationGeneration || _loadFailed.value) return;
    _loadTimeout?.cancel();
    _loadTimeout = null;
    _automaticRecoveryAttempts = 0;
    _recoveryInFlight = false;
    _webContentProcessRecoveryPending = false;
    _mainFrameErrorRecoveryPending = false;
    _loadFailed.value = false;
    _firstPageReady.value = true;
    _navTick.value++;
    _scheduleRevealWatchdog(controller);
  }

  static Future<void> _recoverWebContent(WebViewController controller) async {
    if (!_loadPolicy.isResumed) {
      _deferRecoveryUntilResume();
      return;
    }
    if (_recoveryInFlight) return;
    if (_automaticRecoveryAttempts >= _maxAutomaticRecoveryAttempts) {
      _showLoadFailure();
      return;
    }

    // Claim the recovery slot and attempt budget before the first await.
    // WebKit can report several errors for one failed navigation; without an
    // atomic claim, concurrent handlers can consume both attempts while only
    // one reload is actually started.
    _recoveryInFlight = true;
    _automaticRecoveryAttempts++;
    final int recoveryAttempt = _automaticRecoveryAttempts;
    final int sourceNavigationGeneration = _navigationGeneration;
    final int recoveryLifecycleEpoch = _loadPolicy.lifecycleEpoch;
    _handledMainFrameErrorGeneration = sourceNavigationGeneration;

    Uri? safeFallbackUri;
    // Fail closed. A GET fallback is permitted only after currentUrl()
    // positively verifies a safe first-party storefront page. Unknown URLs
    // stay reload-only so checkout/account/OAuth state cannot be replaced by
    // a storefront-root request.
    bool protectedOrExternalFlow = true;
    try {
      final String? currentUrl = await controller.currentUrl();
      final Uri? currentUri = Uri.tryParse(currentUrl ?? '');
      if (currentUri != null &&
          (currentUri.scheme == 'https' || currentUri.scheme == 'http')) {
        if (_loadPolicy.isSafeStorefrontRecoveryFallback(currentUri)) {
          safeFallbackUri = currentUri;
          protectedOrExternalFlow = false;
        } else {
          protectedOrExternalFlow = true;
        }
      }
    } catch (_) {}

    final bool stillOwnsRecovery =
        _loadPolicy.isResumed &&
        _loadPolicy.lifecycleEpoch == recoveryLifecycleEpoch &&
        _recoveryInFlight &&
        _automaticRecoveryAttempts == recoveryAttempt;
    if (!stillOwnsRecovery) return;
    if (sourceNavigationGeneration != _navigationGeneration) {
      // A real navigation took ownership while currentUrl was resolving.
      _recoveryInFlight = false;
      return;
    }

    _webContentProcessRecoveryPending = false;
    _mainFrameErrorRecoveryPending = false;
    _viewportReloadUsed = false;
    unawaited(controller.setBackgroundColor(Colors.black));
    _showLoadingCover();
    _navigationGeneration++;
    // Ignore late duplicate callbacks from the failed source navigation
    // during the short pre-reload delay. onPageStarted clears this for the
    // actual recovery navigation, whose own first failure may spend attempt 2.
    _handledMainFrameErrorGeneration = _navigationGeneration;
    _armLoadTimeout(controller);
    final int recoveryGeneration = _navigationGeneration;

    try {
      // Let WebKit finish replacing the terminated process before reloading.
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_loadPolicy.isResumed) {
        return;
      }
      if (recoveryGeneration != _navigationGeneration) {
        // A newer navigation or resume validator owns the state now. A stale
        // task may release only its own recovery slot.
        if (_loadPolicy.lifecycleEpoch == recoveryLifecycleEpoch &&
            _recoveryInFlight &&
            _automaticRecoveryAttempts == recoveryAttempt) {
          _recoveryInFlight = false;
        }
        return;
      }
      await controller.reload();
    } catch (_) {
      if (!_loadPolicy.isResumed) {
        _deferRecoveryUntilResume();
        return;
      }
      if (!_recoveryInFlight || _automaticRecoveryAttempts != recoveryAttempt) {
        return;
      }
      if (protectedOrExternalFlow) {
        await _retryRecoveryOrShowFailure(controller, recoveryAttempt);
        return;
      }
      if (safeFallbackUri == null) {
        await _retryRecoveryOrShowFailure(controller, recoveryAttempt);
        return;
      }
      try {
        await controller.loadRequest(safeFallbackUri);
      } catch (_) {
        await _retryRecoveryOrShowFailure(controller, recoveryAttempt);
      }
    }
  }

  static Future<void> _retryRecoveryOrShowFailure(
    WebViewController controller,
    int failedAttempt,
  ) async {
    if (!_loadPolicy.isResumed) {
      _deferRecoveryUntilResume();
      return;
    }
    if (!_recoveryInFlight || _automaticRecoveryAttempts != failedAttempt) {
      return;
    }
    if (_automaticRecoveryAttempts >= _maxAutomaticRecoveryAttempts) {
      _showLoadFailure();
      return;
    }

    final int navigationGeneration = _navigationGeneration;
    final int lifecycleEpoch = _loadPolicy.lifecycleEpoch;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_loadPolicy.isResumed ||
        _loadPolicy.lifecycleEpoch != lifecycleEpoch ||
        navigationGeneration != _navigationGeneration ||
        !_recoveryInFlight ||
        _automaticRecoveryAttempts != failedAttempt) {
      return;
    }

    _recoveryInFlight = false;
    await _recoverWebContent(controller);
  }

  static void _handleLifecycleChange(
    WebViewController controller,
    AppLifecycleState state,
  ) {
    final bool wasResumed = _loadPolicy.isResumed;
    _loadPolicy.didChangeLifecycle(state);

    if (!_loadPolicy.isResumed) {
      _resumeValidationGeneration++;
      _resumeValidationInFlight = false;
      _loadTimeout?.cancel();
      _loadTimeout = null;
      _recoveryInFlight = false;
      _navigationGeneration++;
      _paintProbeGeneration = null;
      return;
    }

    if (!wasResumed) {
      _automaticRecoveryAttempts = 0;
    }
    unawaited(_validateAfterResume(controller));
  }

  static Future<void> _validateAfterResume(WebViewController controller) async {
    if (!_loadPolicy.isResumed) return;

    final bool shouldValidate = _loadPolicy.consumeResumeRecovery(
      pageReady: _firstPageReady.value,
      loadFailed: _loadFailed.value,
      recoveryInFlight: _recoveryInFlight,
    );
    if (!shouldValidate) return;

    final int resumeValidation = ++_resumeValidationGeneration;
    _resumeValidationInFlight = true;
    try {
      final int generation = _navigationGeneration;
      final int lifecycleEpoch = _loadPolicy.lifecycleEpoch;
      final bool hadLatchedFailure = _loadFailed.value;
      final bool hadReadyPage = _firstPageReady.value;
      final bool processRecoveryPending = _webContentProcessRecoveryPending;
      _loadTimeout?.cancel();
      _loadTimeout = null;
      _loadFailed.value = false;
      _recoveryInFlight = false;
      if (processRecoveryPending) {
        _showLoadingCover();
      }

      final List<bool?> probeResults = <bool?>[];
      for (final Duration delay in const <Duration>[
        Duration(milliseconds: 350),
        Duration(milliseconds: 650),
        Duration(seconds: 1),
      ]) {
        await Future.delayed(delay);
        if (!_loadPolicy.isResumed ||
            lifecycleEpoch != _loadPolicy.lifecycleEpoch ||
            resumeValidation != _resumeValidationGeneration ||
            generation != _navigationGeneration) {
          return;
        }

        final bool? result = await _probeMeaningfulContent(controller);
        if (!_loadPolicy.isResumed ||
            lifecycleEpoch != _loadPolicy.lifecycleEpoch ||
            resumeValidation != _resumeValidationGeneration ||
            generation != _navigationGeneration) {
          return;
        }

        if (result == true) {
          _webContentProcessRecoveryPending = false;
          _mainFrameErrorRecoveryPending = false;
          if (!_firstPageReady.value || hadLatchedFailure) {
            await _markPageReady(controller, generation);
          } else {
            _loadFailed.value = false;
            _automaticRecoveryAttempts = 0;
            _scheduleRevealWatchdog(controller);
          }
          return;
        }
        probeResults.add(result);
      }

      final bool definitelyUnhealthy = _loadPolicy
          .shouldRecoverAfterResumeProbes(probeResults);
      final bool explicitMainFrameFailure =
          _mainFrameErrorRecoveryPending &&
          _loadPolicy.shouldRecoverAfterMainFrameErrorProbes(
            probeResults,
            requiredProbeCount: 3,
          );
      if (processRecoveryPending ||
          explicitMainFrameFailure ||
          definitelyUnhealthy ||
          !hadReadyPage) {
        await _recoverWebContent(controller);
      } else {
        // WebKit did not answer, but the last page was already painted and no
        // termination signal was received. Preserve it and validate again
        // after the next lifecycle transition instead of destroying a healthy
        // session.
        _loadPolicy.deferRecovery();
      }
    } finally {
      if (resumeValidation == _resumeValidationGeneration) {
        _resumeValidationInFlight = false;
      }
    }
  }

  static void _retryFromError(WebViewController controller) {
    _automaticRecoveryAttempts = 0;
    _recoveryInFlight = false;
    _webContentProcessRecoveryPending = false;
    _mainFrameErrorRecoveryPending = false;
    unawaited(_loadStoreRoot(controller));
  }

  // True once the one-shot zero-viewport recovery reload has been used.
  static bool _viewportReloadUsed = false;

  /// Last-resort recovery for a page that still committed with a locked 0x0
  /// layout viewport: reload once now that the view has real bounds. The
  /// page is already broken in that state, so one extra load is strictly
  /// an improvement; the session guard prevents any reload loop.
  static Future<bool> _healZeroViewport(WebViewController controller) async {
    if (_viewportReloadUsed) return false;
    try {
      final Object r = await controller.runJavaScriptReturningResult(
        'window.innerWidth',
      );
      // iOS delivers JS numbers as Dart double, Android as a JSON string —
      // normalize as num. (int.tryParse("0.0") is null, which would silently
      // disable this heal on the only platform that has the bug.)
      final num? width = r is num
          ? r
          : num.tryParse(r.toString().replaceAll('"', ''));
      // Re-check the guard: onPageFinished can fire twice for one page and
      // both calls may have passed the entry check before this await.
      if (width != null && width == 0 && !_viewportReloadUsed) {
        _viewportReloadUsed = true;
        unawaited(controller.setBackgroundColor(Colors.black));
        _showLoadingCover();
        _navigationGeneration++;
        _armLoadTimeout(controller);
        try {
          await controller.reload();
        } catch (_) {
          _showLoadFailure();
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  // In-page watchdog, installed once per document (dies with it on
  // navigation). Heals the theme's WebKit-only product-card failures.
  // Idempotent; on a healthy page every selector matches nothing.
  //  1) CSS: .media inside the product card's flex <a> has no definite size,
  //     only %-sized descendants — WebKit resolves that cycle to 0x0 (images
  //     invisible even when loaded); Chromium stretches it. width:100% +
  //     align-self:flex-start gives WebKit a definite box; rendering in
  //     Chromium is unchanged.
  //  2) lqip-element: images hidden by ".image-loader.loading img{opacity:0}"
  //     whose reveal JS died — un-lazy them so WebKit fetches, then reveal
  //     (and drop placeholder/loading-bar, as the theme's own reveal does)
  //     once bytes have actually arrived. The interval also covers images
  //     that only start loading after the user scrolls.
  //  3) scroll-animate: cards latched invisible when their reveal animation
  //     was cancelled (dataset.animationPlaying stuck, promise rejected with
  //     no handler). A reveal is only treated as stuck after TWO ticks 2s
  //     apart — healthy reveals run ~600ms and then leave the selector set —
  //     and is cleared per animation GROUP (one latched card strands its
  //     whole group's stagger loop), so healthy groups keep their entrance
  //     animation.
  static const String _revealWatchdogJs = '''
(function(){
  if(window.__botWatchdog)return;
  if(!document.getElementById('__bot-media-fix')){
    var st=document.createElement('style');
    st.id='__bot-media-fix';
    st.textContent='.product-card a > .media{width:100%;align-self:flex-start}';
    document.head.appendChild(st);
  }
  function heal(){
    document.querySelectorAll('.image-loader.loading img[loading="lazy"]')
      .forEach(function(i){i.loading='eager';});
    document.querySelectorAll('.image-loader.loading').forEach(function(el){
      var ims=el.querySelectorAll('img');
      var i=ims[0];
      if(i&&i.complete&&i.naturalWidth>0){
        el.classList.remove('loading');el.classList.add('loaded');
        i.style.opacity='1';
        if(ims[1])ims[1].remove();
        var b=el.querySelector('.loading-bar');if(b)b.remove();
      }
    });
    var latched=Object.create(null);
    document.querySelectorAll('scroll-animate [data-animation]').forEach(function(e){
      if(e.dataset.animationPlaying){
        if(e.dataset.botSeen){
          e.dataset.botLatched='1';
          if(e.dataset.animationGroup)latched[e.dataset.animationGroup]=1;
        }else{
          e.dataset.botSeen='1';
        }
      }
    });
    document.querySelectorAll('scroll-animate [data-animation]').forEach(function(e){
      if(e.dataset.botLatched||
         (e.dataset.animationGroup&&latched[e.dataset.animationGroup])){
        delete e.dataset.animation;
        delete e.dataset.animationGroup;
        delete e.dataset.animationPlaying;
        delete e.dataset.botSeen;
        delete e.dataset.botLatched;
      }
    });
  }
  heal();
  window.__botWatchdog=setInterval(heal,2000);
})();
''';

  static void _scheduleRevealWatchdog(WebViewController controller) {
    controller.runJavaScript(_revealWatchdogJs).catchError((_) {});
  }

  /// Keeps genuine taps on the theme's horizontally scrollable category rail
  /// navigable in WKWebView. The theme treats any 8px horizontal pointer drift
  /// as a drag and cancels the following anchor click, which can leave a
  /// genuine tap inert inside the app.
  ///
  /// This capture-phase guard only takes over the theme's false-positive band
  /// when:
  /// - the pointer ends on the same category link;
  /// - horizontal movement exceeded the theme's 8px cut-off but stayed within
  ///   a conservative tap-sized range;
  /// - vertical movement remained small; and
  /// - the rail itself did not scroll.
  ///
  /// Ordinary taps, deliberate swipes, mouse clicks, keyboard activation,
  /// external documents, and every link outside the top category rail keep the
  /// theme's existing behavior and event propagation.
  static const String _webKitTabTapRecoveryJs = r'''
(function(){
  if(window.__botWebKitTabTapRecovery)return;
  var hostname=window.location.hostname.toLowerCase();
  if(hostname!=='beautyontapp.com'&&hostname!=='www.beautyontapp.com')return;
  window.__botWebKitTabTapRecovery=true;

  var active=null;
  var themeDragThreshold=8;
  var maxTapX=24;
  var maxTapY=12;
  var maxScrollTravel=1;
  var maxClickDelay=750;

  function categoryLink(target){
    return target&&target.closest
      ?target.closest('.tabs-wrapper a[data-bui-tab][href]')
      :null;
  }

  function clear(){
    active=null;
  }

  document.addEventListener('pointerdown',function(event){
    var link=categoryLink(event.target);
    if(!link||event.pointerType!=='touch'){
      clear();
      return;
    }

    var rail=link.closest('.tabs-wrapper');
    active={
      pointerId:event.pointerId,
      link:link,
      rail:rail,
      startX:event.clientX,
      startY:event.clientY,
      maxX:0,
      maxY:0,
      startScrollLeft:rail?rail.scrollLeft:0,
      maxScroll:0,
      ended:false,
      endedAt:0
    };
  },true);

  document.addEventListener('pointermove',function(event){
    if(!active||event.pointerId!==active.pointerId)return;
    active.maxX=Math.max(active.maxX,Math.abs(event.clientX-active.startX));
    active.maxY=Math.max(active.maxY,Math.abs(event.clientY-active.startY));
    if(active.rail){
      active.maxScroll=Math.max(
        active.maxScroll,
        Math.abs(active.rail.scrollLeft-active.startScrollLeft)
      );
    }
  },true);

  document.addEventListener('pointerup',function(event){
    if(!active||event.pointerId!==active.pointerId)return;
    active.maxX=Math.max(active.maxX,Math.abs(event.clientX-active.startX));
    active.maxY=Math.max(active.maxY,Math.abs(event.clientY-active.startY));
    if(active.rail){
      active.maxScroll=Math.max(
        active.maxScroll,
        Math.abs(active.rail.scrollLeft-active.startScrollLeft)
      );
    }
    active.ended=categoryLink(event.target)===active.link;
    active.endedAt=Date.now();
  },true);

  document.addEventListener('pointercancel',clear,true);

  document.addEventListener('click',function(event){
    var link=categoryLink(event.target);
    var gesture=active;
    clear();
    if(!link||!gesture)return;
    if(Date.now()-gesture.endedAt>maxClickDelay)return;
    if(gesture.link!==link)return;
    if(
      gesture.maxX>maxTapX||
      gesture.maxY>maxTapY||
      gesture.maxScroll>maxScrollTravel
    ){
      event.preventDefault();
      return;
    }
    if(!gesture.ended)return;
    if(gesture.maxX<=themeDragThreshold)return;

    var destination;
    try{
      destination=new URL(link.href,window.location.href);
    }catch(_){
      return;
    }
    if(destination.origin!==window.location.origin)return;

    event.preventDefault();
    window.location.assign(destination.href);
  },true);
})();
''';

  static Future<void> _installWebKitTabTapRecovery(
    WebViewController controller,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await controller.runJavaScript(_webKitTabTapRecoveryJs);
    } catch (_) {
      // A page without an injectable document keeps its native link behavior.
    }
  }

  /// Extends first-party storefront pages through the iPhone's bottom safe
  /// area. The live theme already positions its dock with
  /// env(safe-area-inset-bottom), but WebKit only exposes that inset when the
  /// viewport opts into `viewport-fit=cover`. External account, checkout and
  /// OAuth pages retain the native bottom inset.
  static Future<void> _configureBottomSafeArea(
    WebViewController controller,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      _pageExtendsIntoBottomSafeArea.value = false;
      return;
    }

    try {
      final String? currentUrl = await controller.currentUrl();
      final Uri? currentUri = Uri.tryParse(currentUrl ?? '');
      final String host = currentUri?.host.toLowerCase() ?? '';
      final String path = currentUri?.path.toLowerCase() ?? '';
      final bool isProtectedFlow =
          path == '/checkout' ||
          path == '/checkouts' ||
          path.startsWith('/checkouts/') ||
          path == '/account' ||
          path.startsWith('/account/') ||
          path == '/oauth' ||
          path.startsWith('/oauth/');
      final bool isFirstPartyStore =
          (host == 'beautyontapp.com' || host.endsWith('.beautyontapp.com')) &&
          !isProtectedFlow;
      if (!isFirstPartyStore) {
        _pageExtendsIntoBottomSafeArea.value = false;
        return;
      }

      final Object result = await controller.runJavaScriptReturningResult(r'''
(() => {
  // Only theme pages with the floating dock move into the bottom safe area.
  // Checkout, hosted account and other first-party pages keep Flutter's
  // native bottom inset when the dock is absent.
  if (!document.querySelector('.bottom-nav')) return false;

  let viewport = document.querySelector('meta[name="viewport"]');
  if (!viewport) {
    viewport = document.createElement('meta');
    viewport.name = 'viewport';
    viewport.content = 'width=device-width,initial-scale=1';
    document.head.appendChild(viewport);
  }

  const content = viewport.getAttribute('content') || '';
  if (!/(^|,)\s*viewport-fit\s*=\s*cover\s*(,|$)/i.test(content)) {
    viewport.setAttribute(
      'content',
      `${content.replace(/\s*,?\s*$/, '')},viewport-fit=cover`,
    );
  }

  let safeAreaStyle = document.getElementById('__bot-ios-safe-area');
  if (!safeAreaStyle) {
    safeAreaStyle = document.createElement('style');
    safeAreaStyle.id = '__bot-ios-safe-area';
    safeAreaStyle.textContent = `
      body .bottom-nav {
        bottom: calc(10px + env(safe-area-inset-bottom, 0px)) !important;
      }
      body .shop-modal.glass-sheet {
        bottom: calc(80px + env(safe-area-inset-bottom, 0px)) !important;
        max-height: calc(100vh - 80px - env(safe-area-inset-bottom, 0px)) !important;
        padding-bottom: max(16px, env(safe-area-inset-bottom, 16px)) !important;
      }
      body .shop-modal.open:not(.glass-sheet) {
        margin-bottom: calc(75px + env(safe-area-inset-bottom, 0px)) !important;
      }
    `;
    document.head.appendChild(safeAreaStyle);
  }

  return /(^|,)\s*viewport-fit\s*=\s*cover\s*(,|$)/i.test(
    viewport.getAttribute('content') || '',
  );
})()
''');
      final String normalized = result.toString().replaceAll('"', '').trim();
      final bool configured =
          result == true || normalized == 'true' || normalized == '1';
      if (configured) {
        // Let WebKit publish the new CSS safe-area environment before Flutter
        // expands the platform view. This keeps the floating dock stationary.
        await Future.delayed(const Duration(milliseconds: 50));
      }
      _pageExtendsIntoBottomSafeArea.value = configured;
    } catch (_) {
      _pageExtendsIntoBottomSafeArea.value = false;
    }
  }

  @override
  State<StoreWebView> createState() => _StoreWebViewState();
}

class _StoreWebViewState extends State<StoreWebView>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  bool _awayFromHome = false;

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();

    // Status-bar styling is owned by AppRoot in main.dart (light icons over
    // the splash, dark icons once the store is revealed).
    _controller = StoreWebView._preloaded ?? StoreWebView._buildController();
    StoreWebView._preloaded ??= _controller;
    WidgetsBinding.instance.addObserver(this);
    StoreWebView._navTick.addListener(_refreshBackState);
    StoreWebView._loadFailed.addListener(_onNotifierChanged);
    _refreshBackState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    StoreWebView._navTick.removeListener(_refreshBackState);
    StoreWebView._loadFailed.removeListener(_onNotifierChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    StoreWebView._handleLifecycleChange(_controller, state);
  }

  void _onNotifierChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshBackState() async {
    final bool canGoBack = await _controller.canGoBack();
    if (!mounted) return;
    if (canGoBack != _awayFromHome) {
      setState(() => _awayFromHome = canGoBack);
    }
  }

  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    }
    _refreshBackState();
  }

  void _retry() {
    StoreWebView._retryFromError(_controller);
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets insets = MediaQuery.paddingOf(context);
    // iOS: always keep page headers and landscape content inside the top/side
    // safe areas. First-party store pages extend through the bottom safe area
    // after viewport-fit=cover is enabled, letting the theme's existing
    // env(safe-area-inset-bottom) dock align to the device edge. Hosted
    // account/checkout pages keep the native bottom inset too.
    // Android: WebView has no automatic inset handling, so always keep the
    // page out of the system bars; white scaffold = white (not black) bars.
    final Widget web = WebViewWidget(controller: _controller);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        // Android system back walks the web history first, then exits.
        if (await _controller.canGoBack()) {
          await _controller.goBack();
          _refreshBackState();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: _isAndroid
                  ? SafeArea(child: web)
                  : ValueListenableBuilder<bool>(
                      valueListenable:
                          StoreWebView._pageExtendsIntoBottomSafeArea,
                      builder: (_, bool extendsIntoBottomSafeArea, __) =>
                          AnimatedPadding(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            padding: EdgeInsets.only(
                              top: insets.top,
                              left: insets.left,
                              right: insets.right,
                              bottom: extendsIntoBottomSafeArea
                                  ? 0
                                  : insets.bottom,
                            ),
                            child: web,
                          ),
                    ),
            ),
            if (StoreWebView._loadFailed.value)
              Positioned.fill(child: _LoadErrorView(onRetry: _retry)),
            // Full-screen black brand cover until the FIRST page has fully
            // rendered — this is what prevents any white screen after the
            // splash on slow connections. Fades out when ready.
            Positioned.fill(
              child: ValueListenableBuilder<bool>(
                valueListenable: StoreWebView._firstPageReady,
                builder: (_, ready, __) {
                  final bool hidden = ready || StoreWebView._loadFailed.value;
                  return IgnorePointer(
                    ignoring: hidden,
                    child: AnimatedOpacity(
                      opacity: hidden ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: const _LoadingCover(),
                    ),
                  );
                },
              ),
            ),
            // Android only: floating back button, 34px, top-left.
            // Homepage-conditional — appears ONLY once the user has
            // navigated away from home. Hidden on home is intended.
            if (_isAndroid && _awayFromHome)
              Positioned(
                top: insets.top + 8,
                left: 10,
                child: _FloatingBackButton(onTap: _goBack),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCover extends StatelessWidget {
  const _LoadingCover();

  @override
  Widget build(BuildContext context) {
    final double logoW = MediaQuery.sizeOf(context).width * 0.55;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/u_logo.svg',
              width: logoW,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 28),
            const CupertinoActivityIndicator(radius: 11, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        color: const Color(0xFFF5F5F7),
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0x14000000)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_circle,
                    size: 38,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Page didn’t reload',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'BeautyOnTApp couldn’t reload this page. Tap below to try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF6E6E73),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(25),
                      onPressed: onRetry,
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
