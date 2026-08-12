import Foundation
@preconcurrency import WebKit

enum CustomerSessionState: Equatable, Sendable {
  case unknown
  case signedOut
  case signedIn(firstName: String)

  var shouldShowHomeAccountBar: Bool {
    if case .signedIn = self {
      return false
    }
    return true
  }
}

struct CustomerSessionProbeResult: Equatable, Sendable {
  let state: CustomerSessionState
  let displayName: String?

  static let unknown = CustomerSessionProbeResult(
    state: .unknown,
    displayName: nil
  )
}

@MainActor
protocol CustomerSessionProbing: AnyObject {
  func probe() async -> CustomerSessionProbeResult
}

/// Reads the customer's Shopify theme session from the same persistent WebKit
/// data store used by protected web flows.
///
/// Theme contract source lock:
/// - `sections/bottom-bar.liquid`: `#shopModal3`, `.bot-account-entry`,
///   `/account/logout`, `#greeting-message`, and `#shopBtn3 span`.
/// - `sections/footer-group.json`: the three authenticated greeting prefixes.
@MainActor
final class CustomerSessionProbe: CustomerSessionProbing {
  static let rootURL = URL(string: "https://beautyontapp.com")!
  static let minimumTimeout: TimeInterval = 1
  static let maximumTimeout: TimeInterval = 15

  let timeoutInterval: TimeInterval

  // The storefront can take several seconds to hydrate its account section on
  // a cold WebKit process. Eight seconds was short enough to publish a false
  // "couldn't be verified" state immediately after sign-in. Keep this bounded
  // (rather than waiting forever), but allow the authenticated DOM a little
  // more time to settle.
  init(timeoutInterval: TimeInterval = 12) {
    self.timeoutInterval = min(
      max(timeoutInterval, Self.minimumTimeout),
      Self.maximumTimeout
    )
  }

  func probe() async -> CustomerSessionProbeResult {
    let run = CustomerSessionProbeRun(
      rootURL: Self.rootURL,
      timeoutInterval: timeoutInterval
    )
    return await run.start()
  }
}

struct CustomerSessionDOMSnapshot: Codable, Equatable, Sendable {
  let hasProfileModal: Bool
  let hasSignedOutEntry: Bool
  let hasLogoutLink: Bool
  let greeting: String
  let dockDisplayName: String

  var verifiedResult: CustomerSessionProbeResult {
    // The theme normally renders #shopModal3 in the root document, but a
    // Shopify section can arrive after the first authenticated snapshot (or
    // be omitted on a narrow template). The authenticated markers are the
    // stronger proof: a logout route plus a customer greeting. Requiring the
    // modal itself was leaving signed-in customers stuck on the native
    // "couldn't be verified" state even though the account session was valid.
    // A logout route plus the theme's customer greeting is the strongest
    // authenticated proof. Do this before checking the signed-out entry: a
    // Shopify section can briefly leave the hidden sign-in markup in the DOM
    // while the customer branch is being hydrated. Treating that stale node
    // as authoritative was the source of the native Profile spinner/error.
    if hasLogoutLink,
      let firstName = Self.authenticatedFirstName(from: greeting)
    {
      return CustomerSessionProbeResult(
        state: .signedIn(firstName: firstName),
        // The authenticated dock label is hydrated separately from the
        // greeting. Use the verified greeting name as a stable fallback so a
        // brief delayed dock render cannot leave the native profile/dock stuck
        // on the generic "Profile" label.
        displayName: Self.verifiedText(dockDisplayName, maximumLength: 160)
          ?? firstName
      )
    }

    if hasSignedOutEntry, !hasLogoutLink {
      return CustomerSessionProbeResult(
        state: .signedOut,
        displayName: nil
      )
    }

    return .unknown
  }

  private static let authenticatedGreetingPrefixes = [
    "Good Morning☀️ ",
    "Good Morning🌞 ",
    "Good Morning ",
    "Good Afternoon☀️ ",
    "Good Afternoon🌞 ",
    "Good Afternoon ",
    "Good Evening🌙 ",
    "Good Evening☀️ ",
    "Good Evening ",
  ]

  private static func authenticatedFirstName(from greeting: String) -> String? {
    for prefix in authenticatedGreetingPrefixes where greeting.hasPrefix(prefix) {
      let suffix = String(greeting.dropFirst(prefix.count))
      return verifiedText(
        suffix.trimmingCharacters(in: CharacterSet(charactersIn: ".")),
        maximumLength: 80
      )
    }
    return nil
  }

  private static func verifiedText(
    _ rawValue: String,
    maximumLength: Int
  ) -> String? {
    let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !value.isEmpty, value.count <= maximumLength else {
      return nil
    }
    guard
      value.unicodeScalars.allSatisfy({
        !CharacterSet.controlCharacters.contains($0)
      })
    else {
      return nil
    }
    return value
  }
}

@MainActor
private final class CustomerSessionProbeRun:
  NSObject,
  WKNavigationDelegate,
  WKScriptMessageHandler
{
  private static let messageHandlerName = "customerSessionProbe"
  private static let snapshotJavaScript = """
    (() => {
    const modal = document.querySelector('#shopModal3');
    const signedOutEntry = modal?.querySelector('.bot-account-entry');
      const dockSpans = document.querySelectorAll('#shopBtn3 span');
      const dockLabel = dockSpans.length
        ? dockSpans[dockSpans.length - 1]
        : null;
      const hasLogoutLink = Array.from(document.querySelectorAll('a[href]'))
        .some((link) => {
          try {
            const url = new URL(link.href, window.location.href);
            return url.origin === window.location.origin &&
              url.pathname.replace(/\\/+$/, '') === '/account/logout';
          } catch (_) {
            return false;
          }
        });
      return JSON.stringify({
        hasProfileModal: Boolean(modal),
        hasSignedOutEntry: Boolean(signedOutEntry),
        hasLogoutLink,
        greeting:
          document.querySelector('#greeting-message')?.textContent?.trim() || '',
        dockDisplayName:
          dockLabel?.textContent?.trim() || ''
      });
    })();
    """
  private static let earlySnapshotJavaScript = """
    (() => {
      const postSnapshot = () => {
        try {
          const snapshot = \(snapshotJavaScript)
          window.webkit.messageHandlers.customerSessionProbe
            .postMessage(snapshot);
        } catch (_) {}
      };
      const postSnapshotsUntilSettled = () => {
        postSnapshot();
        let attempts = 0;
        const timer = setInterval(() => {
          postSnapshot();
          attempts += 1;
          if (attempts >= 50) {
            clearInterval(timer);
          }
        }, 100);
      };
      if (document.readyState === 'loading') {
        document.addEventListener(
          'DOMContentLoaded',
          () => setTimeout(postSnapshotsUntilSettled, 0),
          { once: true }
        );
      } else {
        setTimeout(postSnapshotsUntilSettled, 0);
      }
    })();
    """

  private let rootURL: URL
  private let timeoutInterval: TimeInterval
  private let webView: WKWebView
  private var continuation: CheckedContinuation<CustomerSessionProbeResult, Never>?
  private var timeoutTask: Task<Void, Never>?
  private var isComplete = false

  init(rootURL: URL, timeoutInterval: TimeInterval) {
    self.rootURL = rootURL
    self.timeoutInterval = timeoutInterval

    let configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = .default()
    configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    configuration.userContentController.addUserScript(
      WKUserScript(
        source: Self.earlySnapshotJavaScript,
        injectionTime: .atDocumentStart,
        forMainFrameOnly: true
      )
    )
    webView = WKWebView(frame: .zero, configuration: configuration)

    super.init()
    configuration.userContentController.add(
      self,
      name: Self.messageHandlerName
    )
    webView.navigationDelegate = self
  }

  func start() async -> CustomerSessionProbeResult {
    await withCheckedContinuation { continuation in
      self.continuation = continuation

      var request = URLRequest(url: Self.cacheBustedURL(rootURL))
      // Authentication cookies are written by the protected login web view.
      // Do not let a cached signed-out storefront response win the first
      // native refresh after that flow closes.
      request.cachePolicy = .reloadIgnoringLocalCacheData
      request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
      request.setValue("no-cache", forHTTPHeaderField: "Pragma")
      request.timeoutInterval = timeoutInterval
      webView.load(request)

      let nanoseconds = UInt64(timeoutInterval * 1_000_000_000)
      timeoutTask = Task { @MainActor [weak self] in
        do {
          try await Task.sleep(nanoseconds: nanoseconds)
        } catch {
          return
        }
        self?.finish(with: .unknown)
      }
    }
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    guard Self.isVerifiedRootURL(webView.url, expectedRoot: rootURL) else {
      finish(with: .unknown)
      return
    }

    webView.evaluateJavaScript(Self.snapshotJavaScript) {
      [weak self]
      value,
      error in
      Task { @MainActor in
        guard let self, error == nil, let json = value as? String,
          let data = json.data(using: .utf8),
          let snapshot = try? JSONDecoder().decode(
            CustomerSessionDOMSnapshot.self,
            from: data
          )
        else {
          // The theme can still be hydrating its account controls when the
          // navigation delegate fires. The injected poll will deliver a
          // later, verified snapshot; let the bounded timeout handle a real
          // network failure instead of publishing an early `.unknown` state.
          return
        }
        self.finishIfVerified(snapshot.verifiedResult)
      }
    }
  }

  func webView(
    _ webView: WKWebView,
    didFail navigation: WKNavigation!,
    withError error: Error
  ) {
    finish(with: .unknown)
  }

  func webView(
    _ webView: WKWebView,
    didFailProvisionalNavigation navigation: WKNavigation!,
    withError error: Error
  ) {
    finish(with: .unknown)
  }

  func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    finish(with: .unknown)
  }

  func userContentController(
    _ userContentController: WKUserContentController,
    didReceive message: WKScriptMessage
  ) {
    guard message.name == Self.messageHandlerName,
      Self.isVerifiedRootURL(webView.url, expectedRoot: rootURL),
      let json = message.body as? String,
      let snapshot = Self.decodeSnapshot(json)
    else {
      return
    }
    finishIfVerified(snapshot.verifiedResult)
  }

  private static func decodeSnapshot(
    _ json: String
  ) -> CustomerSessionDOMSnapshot? {
    guard let data = json.data(using: .utf8) else {
      return nil
    }
    return try? JSONDecoder().decode(
      CustomerSessionDOMSnapshot.self,
      from: data
    )
  }

  private static func cacheBustedURL(_ rootURL: URL) -> URL {
    guard var components = URLComponents(
      url: rootURL,
      resolvingAgainstBaseURL: false
    ) else {
      return rootURL
    }
    var queryItems = components.queryItems ?? []
    queryItems.append(
      URLQueryItem(
        name: "_native_session_probe",
        value: UUID().uuidString
      )
    )
    components.queryItems = queryItems
    return components.url ?? rootURL
  }

  private func finishIfVerified(_ result: CustomerSessionProbeResult) {
    guard result.state != .unknown else { return }
    finish(with: result)
  }

  private static func isVerifiedRootURL(
    _ candidate: URL?,
    expectedRoot: URL
  ) -> Bool {
    guard let candidate,
      candidate.scheme?.lowercased() == "https",
      candidate.host?.lowercased() == expectedRoot.host?.lowercased(),
      candidate.port == nil || candidate.port == 443
    else {
      return false
    }
    return candidate.path.isEmpty || candidate.path == "/"
  }

  private func finish(with result: CustomerSessionProbeResult) {
    guard !isComplete else { return }
    isComplete = true

    timeoutTask?.cancel()
    timeoutTask = nil
    webView.stopLoading()
    webView.navigationDelegate = nil
    webView.configuration.userContentController
      .removeScriptMessageHandler(forName: Self.messageHandlerName)
    webView.configuration.userContentController.removeAllUserScripts()

    let continuation = continuation
    self.continuation = nil
    continuation?.resume(returning: result)
  }
}
