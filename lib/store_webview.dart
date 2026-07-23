import 'dart:async';

import 'package:beautyontapp/store_navigation_policy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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

  static const MethodChannel _iosWebViewPolicyChannel = MethodChannel(
    'beautyontapp/webview_policy',
  );
  static WebViewController? _preloaded;
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
  // Keep Apple-review-sensitive pages covered until their app-only compliance
  // state is verified: first-party email-only sign-in (Guideline 4.8) and the
  // dedicated permanent-deletion request (Guideline 5.1.1(v)).
  static final ValueNotifier<bool> _iosCompliancePageReady =
      ValueNotifier<bool>(true);
  static Timer? _loadTimeout;
  static int _navigationGeneration = 0;
  static String? _activeNavigationUrl;
  static int? _paintProbeGeneration;
  static bool _recoveryInFlight = false;
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
    bool protectedFlowActive = false;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_userAgent)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (!request.isMainFrame) return NavigationDecision.navigate;
            if (defaultTargetPlatform == TargetPlatform.iOS &&
                StoreNavigationPolicy.isHostedSocialSignInDestination(
                  request.url,
                )) {
              return NavigationDecision.prevent;
            }
            return StoreNavigationPolicy.shouldAllowMainFrame(
                  request.url,
                  protectedFlowActive: protectedFlowActive,
                )
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
          onPageStarted: (String url) {
            _navigationGeneration++;
            _activeNavigationUrl = url;
            _iosCompliancePageReady.value =
                defaultTargetPlatform != TargetPlatform.iOS ||
                (!StoreNavigationPolicy.isHostedCustomerLogin(url) &&
                    !StoreNavigationPolicy.isAccountDeletionPage(url));
            if (StoreNavigationPolicy.isFirstParty(url)) {
              protectedFlowActive =
                  StoreNavigationPolicy.isProtectedFirstPartyFlow(url);
            }
            _loadFailed.value = false;
            if (!_firstPageReady.value) {
              _armLoadTimeout();
              // Shopify's document can paint well before WebKit reports 80%
              // progress. Probe from navigation start so the native cover
              // leaves on the first useful frame, not after deferred scripts.
              _schedulePaintConfirmation(controller);
            }
          },
          onProgress: (int progress) {
            if (progress >= 80) _schedulePaintConfirmation(controller);
          },
          onPageFinished: (String url) {
            unawaited(_handlePageFinished(controller, url));
          },
          onWebResourceError: (WebResourceError error) {
            // iOS can terminate WKWebView's content process while Flutter
            // remains alive. The plugin reports that through this callback;
            // recover regardless of whether an earlier page was ready.
            if (error.errorType ==
                WebResourceErrorType.webContentProcessTerminated) {
              unawaited(_recoverWebContent(controller));
              return;
            }

            // -999 is iOS "navigation cancelled" — benign, fired on quick
            // link taps. Every other failed main-frame load gets a native
            // retry surface instead of exposing WKWebView's white background.
            final bool cancelled = error.errorCode == -999;
            if ((error.isForMainFrame ?? true) && !cancelled) {
              _showLoadFailure();
            }
          },
        ),
      );

    // iOS: navigate the WebView back/forward with the native swipe gesture.
    final platform = controller.platform;
    if (platform is WebKitWebViewController) {
      unawaited(_prepareIosWebView(controller, platform));
    } else {
      _scheduleInitialLoad(controller);
    }
    return controller;
  }

  static Future<void> _prepareIosWebView(
    WebViewController controller,
    WebKitWebViewController platform,
  ) async {
    try {
      await _iosWebViewPolicyChannel.invokeMethod<void>(
        'installGeolocationGuard',
        <String, int>{'webViewIdentifier': platform.webViewIdentifier},
      );
      await platform.setAllowsBackForwardNavigationGestures(true);
      _scheduleInitialLoad(controller);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Unable to prepare the iOS WebView policy: $error');
      }
      _showLoadFailure();
    }
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
    _armLoadTimeout();
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

  static void _showLoadFailure() {
    _loadTimeout?.cancel();
    if (!_loadFailed.value) _navigationGeneration++;
    _paintProbeGeneration = null;
    _recoveryInFlight = false;
    _firstPageReady.value = false;
    _iosCompliancePageReady.value = true;
    _loadFailed.value = true;
  }

  static void _armLoadTimeout() {
    _loadTimeout?.cancel();
    _loadTimeout = Timer(_loadTimeoutDuration, () {
      if (!_firstPageReady.value) _showLoadFailure();
    });
  }

  static void _schedulePaintConfirmation(WebViewController controller) {
    final int generation = _navigationGeneration;
    if (_paintProbeGeneration == generation) return;
    _paintProbeGeneration = generation;
    unawaited(_confirmMeaningfulPaint(controller, generation));
  }

  static Future<void> _handlePageFinished(
    WebViewController controller,
    String url,
  ) async {
    final int generation = _navigationGeneration;
    if (!_isActiveNavigation(generation, url)) return;
    await _applyAppCompliance(controller, url, generation);
    if (!_isActiveNavigation(generation, url)) return;
    if (await _healZeroViewport(controller)) return;
    if (!_isActiveNavigation(generation, url)) return;
    _schedulePaintConfirmation(controller);
  }

  static bool _isActiveNavigation(int generation, String url) {
    return generation == _navigationGeneration &&
        !_loadFailed.value &&
        _activeNavigationUrl == url;
  }

  static const String _storefrontAccountDeletionJs = r'''
(() => {
  if (location.hostname !== 'beautyontapp.com' &&
      !location.hostname.endsWith('.beautyontapp.com')) return true;
  if (location.hostname === 'account.beautyontapp.com' ||
      location.hostname.endsWith('.account.beautyontapp.com')) return true;

  const polishDeleteAccountPage = () => {
    const path = location.pathname.replace(/\/+$/, '');
    if (path !== '/pages/delete-account') return true;

    const form = document.querySelector(
      'form.contact-form[action^="/contact"]'
    );
    if (!form) return false;

    const search = new URLSearchParams(location.search);
    const postedByShopify =
      search.get('contact_posted') === 'true' ||
      search.get('account_deletion_requested') === '1' ||
      document.querySelector('[data-contact-success], .form-status--success');
    const submittedInThisSession =
      sessionStorage.getItem('__botAccountDeletionSubmitted') === 'true';
    const requested = postedByShopify && submittedInThisSession;
    if (requested) {
      sessionStorage.removeItem('__botAccountDeletionSubmitted');
      form.dataset.botDeletePolished = 'true';
      form.removeAttribute('method');
      form.removeAttribute('action');
      form.innerHTML = `
        <div
          id="botDeleteAccountSuccess"
          role="status"
          aria-live="polite"
          style="
            padding:24px;
            border:1px solid rgba(0,0,0,.12);
            border-radius:20px;
            background:#fff;
          "
        >
          <h2 style="margin:0 0 12px;">Deletion request received</h2>
          <p style="margin:0;">
            We will permanently delete or anonymize your BeautyonTApp account
            within 7 days and send confirmation to the email address you
            provided.
          </p>
        </div>
      `;
      return true;
    }

    form.setAttribute('aria-label', 'Permanent account deletion request');

    const emailInput = form.querySelector('input[name="contact[email]"]');
    const button = form.querySelector('button[type="submit"]');
    if (!emailInput || !button) return false;
    if (form.dataset.botDeletePolished === 'true') {
      return Boolean(
        document.getElementById('botDeleteAccountConfirmation') &&
        button.dataset.botDeleteHandler === 'true'
      );
    }

    const nameInput = form.querySelector('input[name="contact[Name]"]');
    nameInput?.closest('.form-floating')?.remove();

    emailInput.setAttribute('autocomplete', 'email');
    emailInput.setAttribute('aria-label', 'Account email address');
    emailInput.setAttribute('placeholder', 'Account email address');
    const emailLabel = form.querySelector(`label[for="${emailInput.id}"]`);
    if (emailLabel) emailLabel.textContent = 'Account email address*';

    const requestBody = form.querySelector('input[name="contact[Comment]"]');
    if (requestBody) {
      requestBody.value =
        'PERMANENT ACCOUNT DELETION REQUEST submitted in the BeautyonTApp app';
    }

    const ensureHiddenInput = (name, value) => {
      let input = form.querySelector(`input[name="${name}"]`);
      if (!input) {
        input = document.createElement('input');
        input.type = 'hidden';
        input.name = name;
        form.appendChild(input);
      }
      input.value = value;
    };
    ensureHiddenInput(
      'contact[Subject]',
      'PERMANENT ACCOUNT DELETION REQUEST'
    );
    ensureHiddenInput(
      'return_to',
      '/pages/delete-account?account_deletion_requested=1'
    );

    const explanation = Array.from(form.querySelectorAll('p')).find((node) =>
      node.textContent.includes('You are requesting deletion')
    );
    if (explanation) {
      explanation.textContent =
        'Enter the email address for your account, confirm the permanent ' +
        'deletion below, then submit the request. No phone call or separate ' +
        'email is required.';
    }

    button.textContent = 'Request permanent deletion';
    button.setAttribute('aria-label', 'Request permanent account deletion');

    if (!document.getElementById('botDeleteAccountConfirmation')) {
      const confirmation = document.createElement('label');
      confirmation.id = 'botDeleteAccountConfirmation';
      confirmation.style.cssText = [
        'display:flex',
        'align-items:flex-start',
        'gap:12px',
        'padding:16px',
        'border:1px solid rgba(0,0,0,.12)',
        'border-radius:16px',
        'font-size:16px',
        'line-height:1.35'
      ].join(';');
      confirmation.innerHTML = `
        <input
          type="checkbox"
          required
          aria-label="Confirm permanent account deletion"
          style="width:20px;height:20px;margin-top:1px;flex:0 0 auto;"
        >
        <span>
          I understand this permanently deletes my account and personal data,
          except records BeautyonTApp must retain by law.
        </span>
      `;
      const submitContainer = button.parentElement;
      submitContainer?.parentElement?.insertBefore(
        confirmation,
        submitContainer
      );
    }

    if (!button.dataset.botDeleteHandler) {
      button.dataset.botDeleteHandler = 'true';
      form.addEventListener('submit', () => {
        sessionStorage.setItem('__botAccountDeletionSubmitted', 'true');
        button.disabled = true;
        button.textContent = 'Submitting deletion request…';
      });
    }

    const contactSection = form.closest('section');
    const contactHeading = Array.from(
      contactSection?.querySelectorAll('p') || []
    ).find((node) => node.textContent.trim() === 'Contact Us');
    if (contactHeading) {
      contactHeading.textContent = 'Confirm permanent deletion';
    }
    form.dataset.botDeletePolished = 'true';
    return Boolean(
      document.getElementById('botDeleteAccountConfirmation') &&
      button.dataset.botDeleteHandler === 'true'
    );
  };

  const installDeleteAccountLink = () => {
    const profileRows = document.querySelector(
      '#shopModal3 .store-locations'
    );
    if (!profileRows || document.getElementById('botAppDeleteAccountLink')) {
      return Boolean(document.getElementById('botAppDeleteAccountLink'));
    }

    const link = document.createElement('a');
    link.id = 'botAppDeleteAccountLink';
    link.href = 'https://beautyontapp.com/pages/delete-account';
    link.className = 'custom-mackup bot-profile-delete-row';
    link.setAttribute('aria-label', 'Delete Account');
    link.innerHTML = `
      <svg
        class="custom-login-image-icon"
        width="40"
        height="40"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <path d="M4 7h16"></path>
        <path d="M9 3h6l1 4H8l1-4Z"></path>
        <path d="m7 7 1 14h8l1-14"></path>
        <path d="M10 11v6M14 11v6"></path>
      </svg>
      <div class="custom-mackup-content">
        <h3>Delete Account</h3>
        <p>Permanently delete your account and personal data</p>
      </div>
    `;

    const ordersRow = profileRows.querySelector('.bot-profile-orders-row');
    if (ordersRow) {
      ordersRow.insertAdjacentElement('afterend', link);
    } else {
      profileRows.appendChild(link);
    }
    return true;
  };

  const deleteAccountPageReady = polishDeleteAccountPage();
  installDeleteAccountLink();
  if (!window.__botDeleteAccountObserver && document.body) {
    window.__botDeleteAccountObserver = new MutationObserver(() => {
      polishDeleteAccountPage();
      if (!document.getElementById('botAppDeleteAccountLink')) {
        installDeleteAccountLink();
      }
    });
    window.__botDeleteAccountObserver.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
  return deleteAccountPageReady;
})()
''';

  static const String _iosFirstPartyLoginOnlyJs = r'''
(() => {
  if (location.hostname !== 'account.beautyontapp.com' &&
      !location.hostname.endsWith('.account.beautyontapp.com')) return true;
  if (!location.pathname.toLowerCase().startsWith('/authentication/login')) {
    return true;
  }

  const removeThirdPartyLogin = () => {
    document
      .querySelectorAll('a[href*="/authentication/social/"]')
      .forEach((link) => {
        const providerGroup = link.parentElement?.parentElement;
        (providerGroup || link).remove();
      });
  };

  removeThirdPartyLogin();
  if (!window.__botFirstPartyLoginObserver && document.documentElement) {
    window.__botFirstPartyLoginObserver = new MutationObserver(
      removeThirdPartyLogin
    );
    window.__botFirstPartyLoginObserver.observe(document.documentElement, {
      childList: true,
      subtree: true
    });
  }
  const socialLogin = document.querySelector(
    'a[href*="/authentication/social/"]'
  );
  const emailLogin = document.querySelector(
    'input[type="email"], input[name="email"]'
  );
  return !socialLogin && Boolean(emailLogin);
})()
''';

  static bool _javascriptResultIsTrue(Object result) {
    final String normalized = result.toString().replaceAll('"', '').trim();
    return result == true || normalized == 'true' || normalized == '1';
  }

  static Future<bool> _waitForJavaScriptSuccess(
    WebViewController controller,
    String script,
    int generation,
    String url,
  ) async {
    for (int attempt = 0; attempt < 40; attempt++) {
      if (!_isActiveNavigation(generation, url)) return false;
      final Object result = await controller.runJavaScriptReturningResult(
        script,
      );
      if (_javascriptResultIsTrue(result)) return true;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return false;
  }

  static void _showComplianceFailure(int generation, String url) {
    if (!_isActiveNavigation(generation, url)) return;
    // Never leave a customer behind an endless preparation spinner. Reveal
    // the native retry surface while keeping the unverified page inaccessible.
    _showLoadFailure();
  }

  static Future<void> _applyAppCompliance(
    WebViewController controller,
    String url,
    int generation,
  ) async {
    final bool isSensitiveIosPage =
        defaultTargetPlatform == TargetPlatform.iOS &&
        (StoreNavigationPolicy.isHostedCustomerLogin(url) ||
            StoreNavigationPolicy.isAccountDeletionPage(url));
    try {
      final bool deletionReady = await _waitForJavaScriptSuccess(
        controller,
        _storefrontAccountDeletionJs,
        generation,
        url,
      );
      if (!_isActiveNavigation(generation, url)) return;
      if (defaultTargetPlatform == TargetPlatform.iOS &&
          StoreNavigationPolicy.isAccountDeletionPage(url)) {
        if (deletionReady) {
          _iosCompliancePageReady.value = true;
        } else {
          _showComplianceFailure(generation, url);
        }
        return;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS &&
          StoreNavigationPolicy.isHostedCustomerLogin(url)) {
        final bool loginReady = await _waitForJavaScriptSuccess(
          controller,
          _iosFirstPartyLoginOnlyJs,
          generation,
          url,
        );
        if (!_isActiveNavigation(generation, url)) return;
        if (loginReady) {
          _iosCompliancePageReady.value = true;
        } else {
          _showComplianceFailure(generation, url);
        }
        return;
      }
      _iosCompliancePageReady.value = true;
    } catch (_) {
      if (!_isActiveNavigation(generation, url)) return;
      if (isSensitiveIosPage) {
        _showComplianceFailure(generation, url);
      } else {
        _iosCompliancePageReady.value = true;
      }
    }
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
  ) async {
    try {
      final Object result = await controller.runJavaScriptReturningResult(r'''
(() => {
  const body = document.body;
  const root = document.documentElement;
  const main = document.querySelector('#MainContent, main');
  if (!body || !root || !main) return false;

  const mainRect = main.getBoundingClientRect();
  const viewportReady = window.innerWidth > 1 && window.innerHeight > 1;
  const documentReady =
    body.childElementCount > 0 &&
    root.scrollHeight > 40 &&
    mainRect.width > 0 &&
    mainRect.height > 80;
  const hasPaintedMainImage = Array.from(main.querySelectorAll('img')).some(
    (image) => {
      const rect = image.getBoundingClientRect();
      return image.complete &&
        image.naturalWidth > 0 &&
        rect.width > 40 &&
        rect.height > 40;
    }
  );

  return viewportReady &&
    documentReady &&
    hasPaintedMainImage;
})()
''');
      final String normalized = result.toString().replaceAll('"', '').trim();
      return result == true || normalized == 'true' || normalized == '1';
    } catch (_) {
      return false;
    }
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
    await controller.setBackgroundColor(Colors.white);
    if (generation != _navigationGeneration || _loadFailed.value) return;
    _loadTimeout?.cancel();
    _automaticRecoveryAttempts = 0;
    _recoveryInFlight = false;
    _loadFailed.value = false;
    _firstPageReady.value = true;
    _scheduleRevealWatchdog(controller);
  }

  static Future<void> _recoverWebContent(WebViewController controller) async {
    if (_recoveryInFlight) return;
    if (_automaticRecoveryAttempts >= _maxAutomaticRecoveryAttempts) {
      _showLoadFailure();
      return;
    }

    _recoveryInFlight = true;
    _automaticRecoveryAttempts++;
    _viewportReloadUsed = false;
    unawaited(controller.setBackgroundColor(Colors.black));
    _showLoadingCover();
    _navigationGeneration++;
    _armLoadTimeout();

    try {
      // Let WebKit finish replacing the terminated process before reloading.
      await Future.delayed(const Duration(milliseconds: 200));
      await controller.reload();
    } catch (_) {
      try {
        await controller.loadRequest(storeRootUri());
      } catch (_) {
        _showLoadFailure();
      }
    }
  }

  static Future<void> _validateAfterResume(WebViewController controller) async {
    if (!_firstPageReady.value || _loadFailed.value || _recoveryInFlight) {
      return;
    }
    final int generation = _navigationGeneration;
    await Future.delayed(const Duration(milliseconds: 350));
    if (generation != _navigationGeneration ||
        !_firstPageReady.value ||
        _loadFailed.value ||
        _recoveryInFlight) {
      return;
    }
    final bool healthy = await _hasMeaningfulContent(controller);
    if (generation != _navigationGeneration ||
        !_firstPageReady.value ||
        _loadFailed.value ||
        _recoveryInFlight) {
      return;
    }
    if (!healthy) {
      await _recoverWebContent(controller);
    }
  }

  static void _retryFromError(WebViewController controller) {
    _automaticRecoveryAttempts = 0;
    _recoveryInFlight = false;
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
        _armLoadTimeout();
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

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();

    // Status-bar styling is owned by AppRoot in main.dart (light icons over
    // the splash, dark icons once the store is revealed).
    _controller = StoreWebView._preloaded ?? StoreWebView._buildController();
    StoreWebView._preloaded ??= _controller;
    WidgetsBinding.instance.addObserver(this);
    StoreWebView._loadFailed.addListener(_onNotifierChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    StoreWebView._loadFailed.removeListener(_onNotifierChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(StoreWebView._validateAfterResume(_controller));
    }
  }

  void _onNotifierChanged() {
    if (mounted) setState(() {});
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
            ValueListenableBuilder<bool>(
              valueListenable: StoreWebView._iosCompliancePageReady,
              builder: (_, bool ready, __) => Positioned.fill(
                child: BlockSemantics(
                  blocking: !ready,
                  child: IgnorePointer(
                    ignoring: ready,
                    child: AnimatedOpacity(
                      opacity: ready ? 0 : 1,
                      duration: const Duration(milliseconds: 160),
                      child: const ColoredBox(
                        color: Colors.white,
                        child: Center(child: CupertinoActivityIndicator()),
                      ),
                    ),
                  ),
                ),
              ),
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
                    CupertinoIcons.wifi_exclamationmark,
                    size: 38,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Let’s reconnect',
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
                    'BeautyOnTApp couldn’t refresh. Check your connection and try again.',
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
