import Foundation
import SwiftUI
import UIKit
@preconcurrency import WebKit

struct WishlistReadback: Equatable, Sendable {
    let count: Int
    let variantID: String?
    let isSaved: Bool?
}

struct WishlistEntry: Codable, Equatable, Hashable, Sendable {
    let productID: String
    let variantID: String
    let handle: String
}

struct WishlistPage: Codable, Equatable, Sendable {
    let totalCount: Int
    let entries: [WishlistEntry]
}

enum ShopifyNumericID {
    static func product(from gid: String) -> String? {
        suffix(from: gid, resource: "Product")
    }

    static func variant(from gid: String) -> String? {
        suffix(from: gid, resource: "ProductVariant")
    }

    private static func suffix(
        from gid: String,
        resource: String
    ) -> String? {
        let prefix = "gid://shopify/\(resource)/"
        guard gid.hasPrefix(prefix) else { return nil }

        let suffix = String(gid.dropFirst(prefix.count))
        guard !suffix.isEmpty,
              suffix.utf8.allSatisfy({ (48 ... 57).contains($0) }),
              let numericID = UInt64(suffix),
              numericID > 0,
              String(numericID) == suffix
        else {
            return nil
        }
        return suffix
    }
}

@MainActor
final class WishlistBridge: NSObject {
    static let messageHandlerName = "botWishlist"
    static let initializationAttempts = 20
    static let initializationIntervalMilliseconds = 250

    static let documentStartBridgeScript = """
    (() => {
      if (window.__botNativeWishlistBridgeInstalled) return;
      window.__botNativeWishlistBridgeInstalled = true;

      const post = (event, variantID, productID) => {
        const handler =
          window.webkit &&
          window.webkit.messageHandlers &&
          window.webkit.messageHandlers.\(WishlistBridge.messageHandlerName);
        if (!handler) return;
        handler.postMessage({
          event: event,
          variantID: variantID == null ? null : String(variantID),
          productID: productID == null ? null : String(productID)
        });
      };

      const previousInit =
        typeof window.iWishinitFn === 'function' ? window.iWishinitFn : null;
      const previousAdd =
        typeof window.iWishAddFn === 'function' ? window.iWishAddFn : null;
      const previousRemove =
        typeof window.iWishRemoveFn === 'function' ? window.iWishRemoveFn : null;

      window.iWishinitFn = function() {
        try {
          if (previousInit) previousInit.apply(this, arguments);
        } finally {
          post('initialized', null, null);
        }
      };
      window.iWishAddFn = function(variantID, productID) {
        try {
          if (previousAdd) previousAdd.apply(this, arguments);
        } finally {
          post('added', variantID, productID);
        }
      };
      window.iWishRemoveFn = function(variantID, productID) {
        try {
          if (previousRemove) previousRemove.apply(this, arguments);
        } finally {
          post('removed', variantID, productID);
        }
      };

      const runtimeIsReady = () => (
        window.iWish &&
        typeof window.iWish.getCounter === 'function' &&
        typeof window.iWish.isInWishlist === 'function' &&
        typeof window.iWish.iwishAdd === 'function' &&
        typeof window.iWish.iwishRemove === 'function'
      );

      let attempts = 0;
      const probe = () => {
        attempts += 1;
        if (runtimeIsReady()) {
          post('ready', null, null);
          return;
        }
        if (attempts < \(WishlistBridge.initializationAttempts)) {
          window.setTimeout(
            probe,
            \(WishlistBridge.initializationIntervalMilliseconds)
          );
        } else {
          post('unavailable', null, null);
        }
      };

      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', probe, { once: true });
      } else {
        probe();
      }
    })();
    """

    static let visibleDrawerProtectionScript = """
    (() => {
      if (window.__botNativeWishlistCartControlsHidden) return;
      window.__botNativeWishlistCartControlsHidden = true;

      const style = document.createElement('style');
      style.id = 'bot-native-wishlist-cart-controls';
      style.textContent = `
        #iwish-drawer-root .iwish-cartQty,
        #iwish-drawer-root .cart-button,
        #iwish-drawer-root .add_to_cart,
        #iwish-drawer-root .paginationContainer .addToCart-btn {
          display: none !important;
          pointer-events: none !important;
        }
      `;

      const install = () => {
        if (!document.getElementById(style.id)) {
          (document.head || document.documentElement).appendChild(style);
        }
      };
      install();
      if (!document.head) {
        document.addEventListener('DOMContentLoaded', install, { once: true });
      }
    })();
    """

    let webView: WKWebView

    var onReset: (() -> Void)?
    var onReadback: ((WishlistReadback) -> Void)?

    private var messageProxy: WishlistScriptMessageProxy?
    private var started = false
    private var runtimeIsReady = false
    private var hasDeferredReload = false

    override init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.userContentController.addUserScript(
            WKUserScript(
                source: ProtectedWebSession.nativeCartProtectionScript,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
        )
        configuration.userContentController.addUserScript(
            WKUserScript(
                source: Self.documentStartBridgeScript,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            )
        )

        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()

        let proxy = WishlistScriptMessageProxy(delegate: self)
        messageProxy = proxy
        webView.configuration.userContentController.add(
            proxy,
            name: Self.messageHandlerName
        )

        webView.navigationDelegate = self
        webView.isHidden = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func start() {
        guard !started else { return }
        started = true
        loadVerifiedStorefront()
    }

    func reinitializeFromPersistentSession() {
        guard started else { return }
        loadVerifiedStorefront()
    }

    func readback(variantGID: String) async -> WishlistReadback? {
        guard let variantID = ShopifyNumericID.variant(from: variantGID),
              await waitForRuntime()
        else {
            return nil
        }
        return await verifiedReadback(variantID: variantID)
    }

    func toggle(
        productGID: String,
        variantGID: String
    ) async -> WishlistReadback? {
        guard let productID = ShopifyNumericID.product(from: productGID),
              let variantID = ShopifyNumericID.variant(from: variantGID),
              await waitForRuntime()
        else {
            return nil
        }

        let script = Self.toggleScript(
            productID: productID,
            variantID: variantID
        )
        guard let result = try? await webView.evaluateJavaScript(script),
              let readback = Self.parseReadback(
                  result,
                  expectedVariantID: variantID
              )
        else {
            return nil
        }

        onReadback?(readback)
        return readback
    }

    func page(
        limit: Int = 20,
        number: Int = 1
    ) async -> WishlistPage? {
        guard await waitForRuntime() else {
            return nil
        }

        let safeLimit = min(max(limit, 1), 50)
        let safePage = max(number, 1)
        let body = """
        const limit = Number(arguments.limit);
        const page = Number(arguments.page);
        const sleep = (milliseconds) =>
          new Promise((resolve) => setTimeout(resolve, milliseconds));

        for (
          let attempt = 0;
          attempt < \(Self.initializationAttempts) &&
            typeof window.fetchWishlist !== 'function';
          attempt += 1
        ) {
          await sleep(\(Self.initializationIntervalMilliseconds));
        }

        if (typeof window.fetchWishlist !== 'function') {
          return JSON.stringify({ verified: false });
        }

        try {
          const response = await window.fetchWishlist(limit, page, 0);
          const rows = Array.isArray(response && response.result)
            ? response.result
            : [];
          const entries = rows.map((row) => ({
            productID: String((row && row.id) || ''),
            variantID: String(
              (row && row.variant && row.variant.id) || ''
            ),
            handle: String((row && row.handle) || '')
          })).filter((entry) => (
            /^\\d+$/.test(entry.productID) &&
            /^\\d+$/.test(entry.variantID) &&
            entry.handle.length > 0
          ));
          const rawTotal = Number(
            response && response.total_records != null
              ? response.total_records
              : entries.length
          );
          const totalCount =
            Number.isSafeInteger(rawTotal) && rawTotal >= 0
              ? rawTotal
              : entries.length;
          return JSON.stringify({
            verified: true,
            totalCount: totalCount,
            entries: entries
          });
        } catch (_) {
          return JSON.stringify({ verified: false });
        }
        """

        guard
            let result = try? await webView.callAsyncJavaScript(
                body,
                arguments: [
                    "limit": safeLimit,
                    "page": safePage,
                ],
                in: nil,
                contentWorld: .page
            ),
            let json = result as? String
        else {
            return nil
        }
        return Self.parsePage(json)
    }

    nonisolated static func isExactStorefrontRoot(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "https",
              url.host?.lowercased() == "beautyontapp.com",
              url.user == nil,
              url.password == nil,
              url.port == nil || url.port == 443,
              url.query == nil
        else {
            return false
        }
        return url.path.isEmpty || url.path == "/"
    }

    nonisolated static func parseReadback(
        _ result: Any,
        expectedVariantID: String?
    ) -> WishlistReadback? {
        guard let payload = result as? [String: Any],
              payload["verified"] as? Bool == true,
              let countNumber = payload["count"] as? NSNumber
        else {
            return nil
        }

        let count = countNumber.intValue
        guard count >= 0,
              countNumber.doubleValue == Double(count)
        else {
            return nil
        }

        guard let expectedVariantID else {
            return WishlistReadback(
                count: count,
                variantID: nil,
                isSaved: nil
            )
        }

        guard let returnedVariantID = payload["variantID"] as? String,
              returnedVariantID == expectedVariantID,
              ShopifyNumericID.variant(
                  from: "gid://shopify/ProductVariant/\(returnedVariantID)"
              ) != nil,
              let isSaved = payload["isSaved"] as? Bool
        else {
            return nil
        }

        return WishlistReadback(
            count: count,
            variantID: returnedVariantID,
            isSaved: isSaved
        )
    }

    nonisolated static func parsePage(_ json: String) -> WishlistPage? {
        guard let data = json.data(using: .utf8),
              let envelope = try? JSONDecoder().decode(
                  WishlistPageEnvelope.self,
                  from: data
              ),
              envelope.verified,
              let totalCount = envelope.totalCount,
              totalCount >= 0,
              let entries = envelope.entries
        else {
            return nil
        }

        let validated = entries.filter { entry in
            ShopifyNumericID.product(
                from: "gid://shopify/Product/\(entry.productID)"
            ) != nil &&
            ShopifyNumericID.variant(
                from: "gid://shopify/ProductVariant/\(entry.variantID)"
            ) != nil &&
            Self.isValidHandle(entry.handle)
        }
        guard validated.count == entries.count else {
            return nil
        }

        var seen = Set<String>()
        let deduplicated = validated.filter {
            seen.insert($0.variantID).inserted
        }
        return WishlistPage(
            totalCount: max(totalCount, deduplicated.count),
            entries: deduplicated
        )
    }

    private nonisolated static func isValidHandle(_ handle: String) -> Bool {
        guard !handle.isEmpty,
              handle.count <= 255,
              handle.first != "-",
              handle.last != "-"
        else {
            return false
        }
        return handle.utf8.allSatisfy {
            (48 ... 57).contains($0) ||
            (97 ... 122).contains($0) ||
            $0 == 45
        }
    }

    private func loadVerifiedStorefront() {
        runtimeIsReady = false
        onReset?()

        var request = URLRequest(url: ShopifyAsset.shopRoot)
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 30
        webView.load(request)
    }

    private func waitForRuntime() async -> Bool {
        start()
        if runtimeIsReady {
            return true
        }

        for _ in 0 ..< Self.initializationAttempts {
            do {
                try await Task.sleep(
                    nanoseconds:
                        UInt64(Self.initializationIntervalMilliseconds) *
                        1_000_000
                )
            } catch {
                return false
            }
            if runtimeIsReady {
                return true
            }
        }
        return false
    }

    private func verifiedReadback(
        variantID: String?
    ) async -> WishlistReadback? {
        let script = Self.readbackScript(variantID: variantID)
        guard let result = try? await webView.evaluateJavaScript(script),
              let readback = Self.parseReadback(
                  result,
                  expectedVariantID: variantID
              )
        else {
            return nil
        }
        onReadback?(readback)
        return readback
    }

    private static func readbackScript(variantID: String?) -> String {
        let variantExpression = variantID.map { "'\($0)'" } ?? "null"
        return """
        (() => {
          const variantID = \(variantExpression);
          if (
            !window.iWish ||
            typeof window.iWish.getCounter !== 'function' ||
            typeof window.iWish.isInWishlist !== 'function'
          ) {
            return { verified: false };
          }
          const count = Number(window.iWish.getCounter());
          if (!Number.isSafeInteger(count) || count < 0) {
            return { verified: false };
          }
          return {
            verified: true,
            count: count,
            variantID: variantID,
            isSaved:
              variantID === null
                ? null
                : Boolean(window.iWish.isInWishlist(variantID))
          };
        })();
        """
    }

    private static func toggleScript(
        productID: String,
        variantID: String
    ) -> String {
        """
        (() => {
          const productID = '\(productID)';
          const variantID = '\(variantID)';
          if (
            !window.iWish ||
            typeof window.iWish.getCounter !== 'function' ||
            typeof window.iWish.isInWishlist !== 'function' ||
            typeof window.iWish.iwishAdd !== 'function' ||
            typeof window.iWish.iwishRemove !== 'function'
          ) {
            return { verified: false };
          }

          const wasSaved = Boolean(window.iWish.isInWishlist(variantID));
          if (wasSaved) {
            window.iWish.iwishRemove(variantID, productID);
          } else {
            window.iWish.iwishAdd(variantID, productID, 1);
          }

          const isSaved = Boolean(window.iWish.isInWishlist(variantID));
          const count = Number(window.iWish.getCounter());
          if (
            isSaved === wasSaved ||
            !Number.isSafeInteger(count) ||
            count < 0
          ) {
            return { verified: false };
          }
          return {
            verified: true,
            count: count,
            variantID: variantID,
            isSaved: isSaved
          };
        })();
        """
    }

    fileprivate func receive(_ message: WKScriptMessage) {
        guard message.frameInfo.isMainFrame,
              let sourceURL = message.frameInfo.request.url,
              Self.isExactStorefrontRoot(sourceURL),
              let payload = message.body as? [String: Any],
              let event = payload["event"] as? String
        else {
            return
        }

        switch event {
        case "initialized", "ready":
            runtimeIsReady = true
            Task {
                _ = await verifiedReadback(variantID: nil)
            }
        case "added", "removed":
            guard let variantID = payload["variantID"] as? String,
                  ShopifyNumericID.variant(
                      from: "gid://shopify/ProductVariant/\(variantID)"
                  ) != nil
            else {
                return
            }
            runtimeIsReady = true
            Task {
                _ = await verifiedReadback(variantID: variantID)
            }
        case "unavailable":
            runtimeIsReady = false
        default:
            break
        }
    }

    @objc private func applicationDidBecomeActive() {
        guard hasDeferredReload else { return }
        hasDeferredReload = false
        loadVerifiedStorefront()
    }
}

private struct WishlistPageEnvelope: Decodable {
    let verified: Bool
    let totalCount: Int?
    let entries: [WishlistEntry]?
}

extension WishlistBridge: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if url.absoluteString == "about:blank" ||
            Self.isExactStorefrontRoot(url)
        {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        runtimeIsReady = false
        onReset?()
        if UIApplication.shared.applicationState == .active {
            loadVerifiedStorefront()
        } else {
            hasDeferredReload = true
        }
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        runtimeIsReady = false
        onReset?()
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        runtimeIsReady = false
        onReset?()
    }
}

private final class WishlistScriptMessageProxy: NSObject, WKScriptMessageHandler {
    weak var delegate: WishlistBridge?

    init(delegate: WishlistBridge) {
        self.delegate = delegate
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        Task { @MainActor [weak delegate] in
            delegate?.receive(message)
        }
    }
}

struct HiddenWishlistWebView: UIViewRepresentable {
    let bridge: WishlistBridge

    func makeUIView(context: Context) -> UIView {
        let host = UIView(frame: .zero)
        host.isHidden = true
        host.isUserInteractionEnabled = false

        let webView = bridge.webView
        webView.removeFromSuperview()
        host.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: host.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: host.trailingAnchor),
            webView.topAnchor.constraint(equalTo: host.topAnchor),
            webView.bottomAnchor.constraint(equalTo: host.bottomAnchor),
        ])
        bridge.start()
        return host
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    static func dismantleUIView(_ uiView: UIView, coordinator: Void) {
        for subview in uiView.subviews {
            subview.removeFromSuperview()
        }
    }
}
