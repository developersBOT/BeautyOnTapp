import Combine
import SwiftUI
@preconcurrency import WebKit

enum NativeStorefrontNavigation: Equatable, Sendable {
    case collection(handle: String)
    case product(handle: String)

    static func parse(_ url: URL) -> NativeStorefrontNavigation? {
        guard ShopifyAsset.isPrimaryStorefrontURL(url),
              url.user == nil,
              url.password == nil,
              url.port == nil || url.port == 443
        else {
            return nil
        }

        let components = url.pathComponents.filter { $0 != "/" }
        guard components.count == 2,
              let handle = verifiedHandle(components[1])
        else {
            return nil
        }

        switch components[0].lowercased() {
        case "collections":
            return .collection(handle: handle)
        case "products":
            return .product(handle: handle)
        default:
            return nil
        }
    }

    private static func verifiedHandle(_ value: String) -> String? {
        let handle = value.lowercased()
        guard !handle.isEmpty,
              handle.count <= 255,
              handle.first != "-",
              handle.last != "-",
              handle.utf8.allSatisfy({
                  (48 ... 57).contains($0) ||
                      (97 ... 122).contains($0) ||
                      $0 == 45
              })
        else {
            return nil
        }
        return handle
    }
}

#if DEBUG
private enum AskBestieUITestFixture {
    static let launchArgument = "-ui-test-bestie-fixture"

    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains(launchArgument)
    }

    static let html = """
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta
          name="viewport"
          content="width=device-width, initial-scale=1, viewport-fit=cover"
        >
        <title>Storefront fixture</title>
        <style>
          html,
          body {
            width: 100%;
            height: 100%;
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
          }

          #storefront-shell {
            min-height: 100%;
            padding: 32px;
            color: #fff;
            background: #b00020;
          }
        </style>
      </head>
      <body>
        <main id="storefront-shell">
          <h1>STOREFRONT SHELL SENTINEL</h1>
          <p>This content must never appear in the isolated chat flow.</p>
        </main>

        <div class="askTimmy-toggle-launcher-block">
          <button
            class="askTimmy-toggle-launcher-container"
            type="button"
            aria-label="Fixture Ask Bestie launcher"
          >
            <span class="askTimmy-toggle-launcher-content">Ask Bestie</span>
          </button>
        </div>

        <chat-widget></chat-widget>

        <script>
          (() => {
            class FixtureChatWidget extends HTMLElement {
              constructor() {
                super();
                this.attachShadow({ mode: 'open' });
              }

              connectedCallback() {
                this.shadowRoot.innerHTML = `
                  <style>
                    :host {
                      display: block;
                      width: 100%;
                      height: 100%;
                      color: #111;
                      background: #fff;
                    }

                    .chat-window-container {
                      box-sizing: border-box;
                      width: 100%;
                      height: 100%;
                      min-height: 100%;
                      padding:
                        max(28px, env(safe-area-inset-top))
                        24px
                        max(28px, env(safe-area-inset-bottom));
                      background: #fff;
                    }

                    .askTimmy-hide {
                      display: none;
                    }

                    .askTimmy-show {
                      display: flex;
                      flex-direction: column;
                    }

                    header {
                      display: flex;
                      align-items: center;
                      justify-content: space-between;
                      gap: 16px;
                      border-bottom: 1px solid #ddd;
                    }

                    h1 {
                      margin: 0;
                      font-size: 24px;
                    }

                    .askTimmy-minimize-button {
                      width: 44px;
                      height: 44px;
                      border: 0;
                      border-radius: 22px;
                      font-size: 22px;
                      background: #f2f2f7;
                    }

                    label {
                      margin-top: 32px;
                      font-weight: 600;
                    }

                    input {
                      box-sizing: border-box;
                      width: 100%;
                      min-height: 48px;
                      margin-top: 8px;
                      padding: 12px;
                      border: 1px solid #aaa;
                      border-radius: 14px;
                      font: inherit;
                    }
                  </style>
                  <section
                    class="chat-window-container askTimmy-hide"
                    role="dialog"
                    aria-label="Ask Bestie fixture chat"
                  >
                    <header>
                      <h1>Ask Bestie fixture chat</h1>
                      <button
                        class="askTimmy-minimize-button"
                        type="button"
                        aria-label="Minimize Ask Bestie"
                      >
                        −
                      </button>
                    </header>
                    <label for="bestie-fixture-message">
                      Ask Bestie message
                    </label>
                    <input
                      id="bestie-fixture-message"
                      type="text"
                      aria-label="Ask Bestie message"
                    >
                  </section>
                `;
              }

              componentOnReady() {
                return Promise.resolve(this);
              }

              showChat() {
                window.setTimeout(() => {
                  const panel = this.shadowRoot.querySelector(
                    '.chat-window-container'
                  );
                  panel.classList.remove('askTimmy-hide');
                  panel.classList.add('askTimmy-show');
                }, 120);
              }
            }

            customElements.define('chat-widget', FixtureChatWidget);

            document.addEventListener('openAskTimmyChat', () => {
              document.querySelector('chat-widget')?.showChat();
            });

            document.querySelector(
              '.askTimmy-toggle-launcher-container'
            )?.addEventListener('click', () => {
              document.dispatchEvent(
                new CustomEvent('openAskTimmyChat', {
                  bubbles: true,
                  composed: true
                })
              );
            });
          })();
        </script>
      </body>
    </html>
    """
}
#endif

@MainActor
final class ProtectedWebSession: NSObject, ObservableObject {
    static let scriptMessageHandlerName = "botNativeWebFlow"

    let webView: WKWebView
    var onNativeStorefrontNavigation:
        ((NativeStorefrontNavigation) -> Void)?
    var onDismissRequest: (() -> Void)?
    /// Called only after the hosted Shopify account UI proves that a customer
    /// session exists.  The native shell uses this to close the temporary
    /// authentication cover and publish the customer name before the
    /// background storefront probe catches up.
    var onCustomerAuthentication:
        ((CustomerSessionProbeResult) -> Void)?
    /// Called when Shopify reaches an authenticated customer-account route but
    /// its name is not readable yet (for example, inside a shadow tree).
    /// The native shell dismisses the temporary web surface immediately and
    /// lets the shared-cookie probe resolve the identity in the background.
    var onCustomerAccountRoute: (() -> Void)?

    @Published private(set) var isLoading = false
    @Published private(set) var estimatedProgress = 0.0
    @Published private(set) var canGoBack = false
    @Published private(set) var lastError: String?
    @Published private(set) var currentHost: String?
    @Published private(set) var hasReceivedReadySignal = false
    private(set) var hasDeferredProcessRecovery = false
    private(set) var isShutdown = false

    private var destination: WebDestination?
    private var progressObservation: NSKeyValueObservation?
    private var backObservation: NSKeyValueObservation?
    private var scriptMessageProxy: ProtectedWebScriptMessageProxy?
    private var didPublishCustomerAuthentication = false

    override init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground

        let proxy = ProtectedWebScriptMessageProxy(delegate: self)
        scriptMessageProxy = proxy
        webView.configuration.userContentController.add(
            proxy,
            name: Self.scriptMessageHandlerName
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        progressObservation = webView.observe(
            \.estimatedProgress,
            options: [.initial, .new]
        ) { [weak self] webView, _ in
            Task { @MainActor in
                self?.estimatedProgress = webView.estimatedProgress
            }
        }
        backObservation = webView.observe(
            \.canGoBack,
            options: [.initial, .new]
        ) { [weak self] webView, _ in
            Task { @MainActor in
                self?.canGoBack = webView.canGoBack
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func load(_ destination: WebDestination) {
        guard !isShutdown else { return }
        self.destination = destination
        lastError = nil
        hasReceivedReadySignal = false
        didPublishCustomerAuthentication = false
        currentHost = destination.url.host?.lowercased()
        configureDocumentStartScripts(for: destination)

        if webView.url == destination.url, !webView.isLoading {
            if destination.documentStartJavaScript == nil,
               destination.allowsCommerceNavigation
            {
                runPostLoadScript()
            } else {
                isLoading = true
                estimatedProgress = 0
                webView.reload()
            }
            return
        }

        isLoading = true
        estimatedProgress = 0
        loadDestinationContent(destination)
    }

    func retry() {
        guard !isShutdown else { return }
        lastError = nil
        hasReceivedReadySignal = false
        isLoading = true
        estimatedProgress = 0
        if let destination {
            loadDestinationContent(destination)
        } else {
            webView.reload()
        }
    }

    func goBack() {
        guard !isShutdown else { return }
        guard webView.canGoBack else { return }
        webView.goBack()
    }

    func shutdown() {
        guard !isShutdown else { return }
        isShutdown = true

        NotificationCenter.default.removeObserver(self)
        progressObservation?.invalidate()
        progressObservation = nil
        backObservation?.invalidate()
        backObservation = nil

        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.configuration.userContentController.removeAllUserScripts()
        webView.configuration.userContentController
            .removeScriptMessageHandler(
                forName: Self.scriptMessageHandlerName
            )
        scriptMessageProxy = nil

        destination = nil
        onNativeStorefrontNavigation = nil
        onDismissRequest = nil
        onCustomerAuthentication = nil
        onCustomerAccountRoute = nil
        didPublishCustomerAuthentication = false
        hasDeferredProcessRecovery = false
        isLoading = false
        estimatedProgress = 0
        canGoBack = false
        lastError = nil
        currentHost = nil
        hasReceivedReadySignal = false
    }

    private func loadDestinationContent(_ destination: WebDestination) {
        #if DEBUG
        if destination.isIsolatedBestie,
           AskBestieUITestFixture.isEnabled
        {
            webView.loadHTMLString(
                AskBestieUITestFixture.html,
                baseURL: destination.url
            )
            return
        }
        #endif

        var request = URLRequest(url: destination.url)
        request.timeoutInterval = 45
        request.cachePolicy = .useProtocolCachePolicy
        webView.load(request)
    }

    private func runPostLoadScript() {
        guard let script = destination?.postLoadJavaScript else { return }
        webView.evaluateJavaScript(script) { [weak self] _, error in
            guard error != nil else { return }
            Task { @MainActor [weak self] in
                guard let self, !self.isShutdown else { return }
                self.isLoading = false
                self.hasReceivedReadySignal = false
                self.lastError =
                    self.destination?.title == "Ask Bestie"
                    ? "Ask Bestie couldn’t open. Check your connection and try again."
                    : "This screen couldn’t finish loading."
            }
        }
    }

    fileprivate func receiveScriptMessage(_ message: WKScriptMessage) {
        guard message.name == Self.scriptMessageHandlerName,
              let body = message.body as? [String: Any],
              let event = body["event"] as? String
        else {
            return
        }

        switch event {
        case "ready":
            isLoading = false
            lastError = nil
            hasReceivedReadySignal = true
        case "failure":
            isLoading = false
            hasReceivedReadySignal = false
            let message =
                (body["message"] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            lastError =
                message?.isEmpty == false
                ? message
                : "This screen couldn’t finish loading."
        case "dismiss":
            onDismissRequest?()
        case "customerAuthenticated":
            guard !didPublishCustomerAuthentication,
                  let firstName = Self.verifiedCustomerText(
                    body["firstName"] as? String,
                    maximumLength: 80
                  )
            else {
                return
            }
            let displayName = Self.verifiedCustomerText(
                body["displayName"] as? String,
                maximumLength: 160
            ) ?? firstName
            didPublishCustomerAuthentication = true
            onCustomerAuthentication?(
                CustomerSessionProbeResult(
                    state: .signedIn(firstName: firstName),
                    displayName: displayName
                )
            )
        case "customerAccountRoute":
            guard destination.map(Self.isAuthenticationFlow) == true else {
                return
            }
            onCustomerAccountRoute?()
        default:
            break
        }
    }

    private func configureDocumentStartScripts(for destination: WebDestination) {
        let controller = webView.configuration.userContentController
        controller.removeAllUserScripts()

        if !destination.allowsCommerceNavigation {
            controller.addUserScript(
                WKUserScript(
                    source: Self.nativeCartProtectionScript,
                    injectionTime: .atDocumentStart,
                    forMainFrameOnly: false
                )
            )
        }

        if Self.shouldApplyNativeChrome(to: destination) {
            controller.addUserScript(
                WKUserScript(
                    source: Self.nativeChromeScript,
                    injectionTime: .atDocumentStart,
                    forMainFrameOnly: true
                )
            )
        }

        if Self.isAuthenticationFlow(destination) {
            controller.addUserScript(
                WKUserScript(
                    source: Self.customerAuthenticationScript,
                    injectionTime: .atDocumentEnd,
                    forMainFrameOnly: true
                )
            )
        }

        if let script = destination.documentStartJavaScript {
            controller.addUserScript(
                WKUserScript(
                    source: script,
                    injectionTime: .atDocumentStart,
                    forMainFrameOnly: true
                )
            )
        }
    }

    func noteWebContentProcessTermination(applicationIsActive: Bool) {
        guard !isShutdown else { return }
        guard applicationIsActive else {
            hasDeferredProcessRecovery = true
            isLoading = false
            lastError = nil
            hasReceivedReadySignal = false
            return
        }
        reloadAfterWebContentProcessTermination()
    }

    func resumeDeferredProcessRecovery() {
        guard !isShutdown else { return }
        guard hasDeferredProcessRecovery else { return }
        hasDeferredProcessRecovery = false
        reloadAfterWebContentProcessTermination()
    }

    private func reloadAfterWebContentProcessTermination() {
        isLoading = true
        lastError = nil
        hasReceivedReadySignal = false
        #if DEBUG
        if let destination,
           destination.isIsolatedBestie,
           AskBestieUITestFixture.isEnabled
        {
            loadDestinationContent(destination)
            return
        }
        #endif
        if webView.url != nil {
            webView.reload()
        } else if let destination {
            load(destination)
        } else {
            isLoading = false
        }
    }

    @objc private func applicationDidEnterBackground() {
        // Process termination is handled by the delegate and deliberately
        // deferred until the next active notification.
    }

    @objc private func applicationDidBecomeActive() {
        resumeDeferredProcessRecovery()
    }

    static func shouldApplyNativeChrome(to destination: WebDestination) -> Bool {
        ShopifyAsset.isPrimaryStorefrontURL(destination.url) &&
            !WebNavigationPolicy.isCommerceURL(destination.url)
    }

    static func isAuthenticationFlow(_ destination: WebDestination) -> Bool {
        destination.title == "Sign In" || destination.title == "Create Account"
    }

    /// Shopify's new customer-account OAuth flow returns to this exact
    /// first-party callback route after the customer has authenticated.  The
    /// callback can contain only a code/state query and no account DOM, so it
    /// must be handled from navigation rather than waiting for the hosted
    /// account page to render a name.
    nonisolated static func isCustomerAccountCallback(_ url: URL?) -> Bool {
        guard let url,
              url.scheme?.caseInsensitiveCompare("https") == .orderedSame,
              url.host?.caseInsensitiveCompare("account.beautyontapp.com") == .orderedSame,
              url.user == nil,
              url.password == nil,
              url.port == nil || url.port == 443
        else {
            return false
        }

        let path = url.path
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .lowercased()
        return path == "callback"
    }

    private static func verifiedCustomerText(
        _ rawValue: String?,
        maximumLength: Int
    ) -> String? {
        guard let rawValue else { return nil }
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, value.count <= maximumLength else { return nil }
        guard value.unicodeScalars.allSatisfy({
            !CharacterSet.controlCharacters.contains($0)
        }) else {
            return nil
        }
        return value
    }

    /// Shopify's new customer-account host is a separate first-party origin.
    /// The initial login page and the authenticated account page can therefore
    /// share the same host and URL shape; DOM proof is required before the
    /// native shell closes the auth flow.
    static let customerAuthenticationScript = """
    (() => {
      const handler = window.webkit?.messageHandlers?.botNativeWebFlow;
      if (!handler) return;

      const clean = (value) => (value || '').replace(/\\s+/g, ' ').trim();
      let didPost = false;
      const postAuthenticatedRouteIfNeeded = () => {
        if (didPost) return false;

        // New customer accounts can render their authenticated surface in a
        // custom element/shadow tree. In that case body.innerText may never
        // contain Welcome/Orders/Profile even though the URL has moved past
        // the login route. Only accept a trusted, non-login account route and
        // require an account marker when the route is not /account itself.
        const host = (window.location.hostname || '').toLowerCase();
        const path = (window.location.pathname || '/')
          .replace(/\\/+$/, '')
          .toLowerCase() || '/';
        const isPrimaryStore = host === 'beautyontapp.com' ||
          host === 'www.beautyontapp.com';
        const isAccountHost = host === 'account.beautyontapp.com';
        const isLoginPath = /\\/(login|register|signup|sign-up|recover|challenge|authenticate)(?:\\/|$)/i
          .test(path);
        const isPrimaryAccountPath = isPrimaryStore &&
          /^\\/account(?:\\/.*)?$/i.test(path) && !isLoginPath;
        const isAccountHostPath = isAccountHost && path !== '/' &&
          !isLoginPath;
        if (!isPrimaryAccountPath && !isAccountHostPath) return false;

        const bodyText = clean(document.body?.innerText || '');
        const accountSurface = !!document.querySelector(
          'shopify-account, customer-account, shopify-customer-account,' +
          '[data-shopify-customer-account], [data-account-page]'
        );
        const hasAccountNavigation = /\\bOrders\\b/i.test(bodyText) &&
          /\\bProfile\\b/i.test(bodyText);
        const hasWelcome = /\\bWelcome(?:,|\\s)/i.test(bodyText);
        const hasLogout = Array.from(document.querySelectorAll('a[href]'))
          .some((link) => /\\/account\\/logout(?:[?#]|$)/i.test(link.href));
        if (!hasAccountNavigation && !hasWelcome && !hasLogout &&
            !(isPrimaryAccountPath && accountSurface)) return false;

        didPost = true;
        handler.postMessage({ event: 'customerAccountRoute' });
        return true;
      };
      const postIfAuthenticated = () => {
        if (didPost) return;

        // Shopify's customer-account surface is progressively rendered. Read
        // both body text and visible navigation controls so the handoff still
        // works when Orders/Profile are buttons rather than links.
        const bodyText = clean(document.body?.innerText || '');
        const controlText = clean(Array.from(
          document.querySelectorAll('a,button,[role="button"],[role="tab"]')
        ).map((node) => node.innerText || node.getAttribute('aria-label') || '')
          .join(' '));
        const pageText = clean(`${bodyText} ${controlText}`);
        const welcome = pageText.match(
          /\\bWelcome(?:,|\\s)\\s*([^.!?\\n]{1,80})/i
        );
        const displayName = clean(welcome?.[1] || '');
        const firstName = displayName.split(' ')[0];
        const hasAccountNavigation = /\\bOrders\\b/i.test(pageText) &&
          /\\bProfile\\b/i.test(pageText);
        const hasStorefrontGreeting = /\\bGood (Morning|Afternoon|Evening)/i
          .test(pageText);
        const hasLogout = Array.from(document.querySelectorAll('a[href]'))
          .some((link) => /\\/account\\/logout(?:[?#]|$)/i.test(link.href));

        if (!firstName || (!hasAccountNavigation &&
            !(hasStorefrontGreeting && hasLogout))) {
          postAuthenticatedRouteIfNeeded();
          return;
        }

        didPost = true;
        handler.postMessage({
          event: 'customerAuthenticated',
          firstName,
          displayName: displayName || firstName
        });
      };

      const schedule = () => {
        postAuthenticatedRouteIfNeeded();
        postIfAuthenticated();
        let attempts = 0;
        const timer = setInterval(() => {
          postIfAuthenticated();
          attempts += 1;
          if (didPost || attempts >= 300) clearInterval(timer);
        }, 200);

        // The account page can be hydrated after document-end. Watch bounded
        // DOM mutations so a delayed Welcome/Orders/Profile still hands back
        // to the native shell without leaving the hosted page on screen.
        const observer = new MutationObserver(postIfAuthenticated);
        observer.observe(document.documentElement || document.body, {
          childList: true,
          subtree: true,
          characterData: true
        });
        window.setTimeout(() => observer.disconnect(), 60000);
      };

      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', schedule, { once: true });
      } else {
        schedule();
      }
    })();
    """

    private func enforceNativeChromeIfNeeded() {
        guard let destination,
              Self.shouldApplyNativeChrome(to: destination)
        else {
            return
        }
        webView.evaluateJavaScript(Self.nativeChromeScript)
    }

    static let nativeChromeScript = """
    (() => {
      const host = window.location.hostname.toLowerCase();
      const path = window.location.pathname.toLowerCase();
      const isBeautyOnTApp =
        host === 'beautyontapp.com' || host === 'www.beautyontapp.com';
      const isCommerce =
        path === '/cart' ||
        path.startsWith('/cart/') ||
        path === '/checkout' ||
        path.startsWith('/checkout/') ||
        path === '/checkouts' ||
        path.startsWith('/checkouts/');

      if (!isBeautyOnTApp || isCommerce) return;

      const installNativeChrome = () => {
        const root = document.documentElement;
        if (!root) return false;

        root.classList.add('bot-native-web-flow');
        if (document.getElementById('bot-native-shell-chrome')) return true;

        const style = document.createElement('style');
        style.id = 'bot-native-shell-chrome';
        style.textContent = `
          html.bot-native-web-flow {
            --announcement-bar-height: 0px !important;
            --header-group-height: 0px !important;
            --header-height: 0px !important;
            --header-height-actual: 0px !important;
            --header-height-sticky: 0px !important;
          }

          html.bot-native-web-flow header.contents,
          html.bot-native-web-flow .shopify-section-group-header-group,
          html.bot-native-web-flow .shopify-section-group-footer-group,
          html.bot-native-web-flow .section-site-header,
          html.bot-native-web-flow .top-bar-main-section,
          html.bot-native-web-flow .signinbar-wrapper,
          html.bot-native-web-flow .tabs-wrapper,
          html.bot-native-web-flow .bottom-nav.bui-dock-light,
          html.bot-native-web-flow #shopModal1,
          html.bot-native-web-flow #shopModal2,
          html.bot-native-web-flow #shopModal3,
          html.bot-native-web-flow .custom-footer,
          html.bot-native-web-flow .section-footer,
          html.bot-native-web-flow .section-footer-bar,
          html.bot-native-web-flow footer,
          html.bot-native-web-flow [id*="footer_bar"],
          html.bot-native-web-flow [id*="footer-bar"],
          html.bot-native-web-flow [id*="__logo_list_"],
          html.bot-native-web-flow [id*="__logo-list-"],
          html.bot-native-web-flow #cart-modal,
          html.bot-native-web-flow modal-trigger[target="#cart-modal"],
          html.bot-native-web-flow .bot-mobile-cart {
            display: none !important;
          }
        `;
        root.appendChild(style);
        return true;
      };

      if (installNativeChrome()) return;

      const observer = new MutationObserver(() => {
        if (!installNativeChrome()) return;
        observer.disconnect();
      });
      observer.observe(document, { childList: true, subtree: true });
    })();
    """

    static let nativeCartProtectionScript = """
    (() => {
      if (window.__botNativeCartProtectionInstalled) return;
      window.__botNativeCartProtectionInstalled = true;

      const mutationPath = (candidate) => {
        try {
          const raw = candidate instanceof Request ? candidate.url : String(candidate || '');
          const path = new URL(raw, window.location.href).pathname.toLowerCase();
          return /^\\/cart\\/(add|change|update|clear)(?:\\.js)?\\/?$/.test(path);
        } catch (_) {
          return false;
        }
      };

      const originalFetch = window.fetch.bind(window);
      window.fetch = (input, init) => {
        if (mutationPath(input)) {
          return Promise.resolve(new Response(
            JSON.stringify({
              status: 409,
              description: 'Use the BeautyOnTApp app bag.'
            }),
            {
              status: 409,
              headers: { 'Content-Type': 'application/json' }
            }
          ));
        }
        return originalFetch(input, init);
      };

      const originalOpen = XMLHttpRequest.prototype.open;
      const originalSend = XMLHttpRequest.prototype.send;
      XMLHttpRequest.prototype.open = function(method, url) {
        this.__botNativeBlocksCartMutation = mutationPath(url);
        return originalOpen.apply(this, arguments);
      };
      XMLHttpRequest.prototype.send = function() {
        if (this.__botNativeBlocksCartMutation) {
          this.abort();
          return;
        }
        return originalSend.apply(this, arguments);
      };

      if (navigator.sendBeacon) {
        const originalBeacon = navigator.sendBeacon.bind(navigator);
        navigator.sendBeacon = (url, data) => {
          if (mutationPath(url)) return false;
          return originalBeacon(url, data);
        };
      }

      const blocksForm = (form) => {
        if (!(form instanceof HTMLFormElement)) return false;
        return mutationPath(form.getAttribute('action') || '');
      };
      document.addEventListener('submit', (event) => {
        if (!blocksForm(event.target)) return;
        event.preventDefault();
        event.stopImmediatePropagation();
      }, true);

      const originalSubmit = HTMLFormElement.prototype.submit;
      HTMLFormElement.prototype.submit = function() {
        if (blocksForm(this)) return;
        return originalSubmit.apply(this, arguments);
      };
    })();
    """
}

private final class ProtectedWebScriptMessageProxy:
    NSObject,
    WKScriptMessageHandler
{
    weak var delegate: ProtectedWebSession?

    init(delegate: ProtectedWebSession) {
        self.delegate = delegate
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        Task { @MainActor [weak delegate] in
            delegate?.receiveScriptMessage(message)
        }
    }
}

extension ProtectedWebSession: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url,
              let scheme = url.scheme?.lowercased()
        else {
            decisionHandler(.cancel)
            return
        }

        if scheme == "https" {
            if WebNavigationPolicy.isTrustedWebURL(url) {
                if let nativeNavigation =
                    NativeStorefrontNavigation.parse(url),
                   navigationAction.targetFrame?.isMainFrame != false,
                   let onNativeStorefrontNavigation
                {
                    decisionHandler(.cancel)
                    onNativeStorefrontNavigation(nativeNavigation)
                    return
                }

                if WebNavigationPolicy.isCommerceURL(url),
                   destination?.allowsCommerceNavigation != true
                {
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.allow)
                }
                return
            }

            if scheme == "https",
               destination?.allowsExternalNavigation == true
            {
                decisionHandler(.allow)
                return
            }

            decisionHandler(.cancel)
            openExternally(
                navigationAction.request,
                navigationType: navigationAction.navigationType,
                allowsAutomaticRedirect:
                    destination?.allowsExternalNavigation == true
            )
            return
        }

        if scheme == "http" {
            decisionHandler(.cancel)
            return
        }

        if scheme == "about" {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
        guard WebNavigationPolicy.isAllowedExternalScheme(scheme) else {
            return
        }
        openExternally(
            navigationAction.request,
            navigationType: navigationAction.navigationType,
            allowsAutomaticRedirect:
                destination?.allowsExternalNavigation == true
        )
    }

    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        Task { @MainActor in
            self.isLoading = true
            self.lastError = nil
            self.hasReceivedReadySignal = false
        }
    }

    func webView(
        _ webView: WKWebView,
        didCommit navigation: WKNavigation!
    ) {
        currentHost = webView.url?.host?.lowercased()
        enforceNativeChromeIfNeeded()

        // The OAuth callback is the handoff boundary.  It intentionally has
        // no dependency on the account page's rendered DOM, which may be
        // delayed or hidden in a shadow tree.  AppModel dismisses the
        // temporary web surface and waits briefly before probing the shared
        // Shopify cookie.
        if destination.map(Self.isAuthenticationFlow) == true,
           Self.isCustomerAccountCallback(webView.url) {
            onCustomerAccountRoute?()
        }
    }

    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        Task { @MainActor in
            if self.destination?.isIsolatedBestie != true {
                self.isLoading = false
            }
            self.enforceNativeChromeIfNeeded()

            // The account host can be the login page both before and after the
            // redirect.  Do not dismiss from the URL alone; the injected
            // customerAuthenticationScript closes only after it sees the
            // authenticated account navigation/name markers.
            self.evaluateCustomerAuthenticationIfNeeded()
            self.runPostLoadScript()

            // Keep this check in didFinish as well as didCommit.  Some WebKit
            // versions expose the final callback URL only after the document
            // commits, while others update it by didFinish.
            if self.destination.map(Self.isAuthenticationFlow) == true,
               Self.isCustomerAccountCallback(self.webView.url) {
                self.onCustomerAccountRoute?()
            }
        }
    }

    private func evaluateCustomerAuthenticationIfNeeded() {
        guard let destination,
              Self.isAuthenticationFlow(destination)
        else { return }
        webView.evaluateJavaScript(Self.customerAuthenticationScript)
    }

    nonisolated static func shouldDismissAuthenticationFlow(
        destination: WebDestination,
        url: URL?
    ) -> Bool {
        guard destination.title == "Sign In"
                || destination.title == "Create Account"
        else {
            return false
        }
        guard let url,
              WebNavigationPolicy.isTrustedWebURL(url)
        else {
            return false
        }
        let path = url.path.trimmingCharacters(
            in: CharacterSet(charactersIn: "/")
        )
        // This remains a route-candidate helper for tests and diagnostics. A
        // real dismissal still requires the DOM proof above.
        return path.caseInsensitiveCompare("account") == .orderedSame
            || url.host?.caseInsensitiveCompare("account.beautyontapp.com") == .orderedSame
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        record(error)
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        record(error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        noteWebContentProcessTermination(
            applicationIsActive: UIApplication.shared.applicationState == .active
        )
    }

    private func record(_ error: Error) {
        recordNavigationError(
            error,
            applicationIsActive:
                UIApplication.shared.applicationState == .active
        )
    }

    func recordNavigationError(
        _ error: Error,
        applicationIsActive: Bool
    ) {
        let nsError = error as NSError
        guard nsError.code != NSURLErrorCancelled else { return }
        guard applicationIsActive else {
            isLoading = false
            lastError = nil
            hasReceivedReadySignal = false
            hasDeferredProcessRecovery = true
            return
        }
        Task { @MainActor in
            self.isLoading = false
            self.hasReceivedReadySignal = false
            self.lastError = error.localizedDescription
        }
    }

    private func openExternally(
        _ request: URLRequest,
        navigationType: WKNavigationType,
        allowsAutomaticRedirect: Bool
    ) {
        guard let url = request.url else { return }
        let method = request.httpMethod?.uppercased() ?? "GET"
        guard method == "GET" || method == "HEAD" else { return }
        guard allowsAutomaticRedirect ||
              navigationType == .linkActivated ||
              navigationType == .formSubmitted
        else {
            return
        }
        UIApplication.shared.open(url)
    }
}

extension ProtectedWebSession: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard navigationAction.targetFrame == nil,
              let url = navigationAction.request.url
        else {
            return nil
        }

        if WebNavigationPolicy.isTrustedWebURL(url) {
            if let nativeNavigation =
                NativeStorefrontNavigation.parse(url),
               let onNativeStorefrontNavigation
            {
                onNativeStorefrontNavigation(nativeNavigation)
                return nil
            }

            if !WebNavigationPolicy.isCommerceURL(url) ||
                destination?.allowsCommerceNavigation == true
            {
                webView.load(navigationAction.request)
            }
        } else if url.scheme?.lowercased() == "https",
                  destination?.allowsExternalNavigation == true
        {
            webView.load(navigationAction.request)
        } else {
            openExternally(
                navigationAction.request,
                navigationType: navigationAction.navigationType,
                allowsAutomaticRedirect:
                    destination?.allowsExternalNavigation == true
            )
        }
        return nil
    }
}

enum WebNavigationPolicy {
    private static let trustedHosts: Set<String> = [
        "beautyontapp.com",
        "www.beautyontapp.com",
        "account.beautyontapp.com",
        "i0ma19-q8.myshopify.com",
        "accounts.shopify.com",
        "checkout.shopify.com",
        "pay.shopify.com",
        "shopify.com",
        "shop.app",
        "checkout.shop.app",
    ]

    private static let externalSchemes: Set<String> = [
        "facetime",
        "facetime-audio",
        "mailto",
        "maps",
        "sms",
        "tel",
    ]

    private static let commerceHosts: Set<String> = [
        "checkout.shopify.com",
        "pay.shopify.com",
        "checkout.shop.app",
    ]

    static func isTrustedWebURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(),
              scheme == "https",
              let host = url.host?.lowercased()
        else {
            return false
        }
        return trustedHosts.contains(host)
    }

    static func isAllowedExternalScheme(_ scheme: String) -> Bool {
        externalSchemes.contains(scheme.lowercased())
    }

    static func isCommerceURL(_ url: URL) -> Bool {
        guard isTrustedWebURL(url),
              let host = url.host?.lowercased()
        else {
            return false
        }
        if commerceHosts.contains(host) {
            return true
        }
        let path = url.path.lowercased()
        return path == "/cart" ||
            path.hasPrefix("/cart/") ||
            path == "/checkout" ||
            path.hasPrefix("/checkout/") ||
            path == "/checkouts" ||
            path.hasPrefix("/checkouts/")
    }
}

struct PersistentWebView: UIViewRepresentable {
    @ObservedObject var session: ProtectedWebSession

    func makeUIView(context: Context) -> WebViewContainer {
        let container = WebViewContainer()
        container.attach(session.webView)
        return container
    }

    func updateUIView(_ container: WebViewContainer, context: Context) {
        container.attach(session.webView)
    }

    static func dismantleUIView(_ container: WebViewContainer, coordinator: Void) {
        container.detach()
    }
}

final class WebViewContainer: UIView {
    private weak var hostedWebView: WKWebView?

    func attach(_ webView: WKWebView) {
        guard hostedWebView !== webView || webView.superview !== self else { return }
        hostedWebView?.removeFromSuperview()
        webView.removeFromSuperview()
        hostedWebView = webView
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    func detach() {
        hostedWebView?.removeFromSuperview()
        hostedWebView = nil
    }
}
