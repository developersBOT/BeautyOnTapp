import Foundation
import Security
import UIKit

enum DockDestination: String, CaseIterable, Identifiable {
  case home
  case shop
  case exclusive
  case profile
  case stores
  case bestie

  static let primary: [DockDestination] = [
    .home,
    .shop,
    .exclusive,
    .profile,
  ]

  var id: String { rawValue }

  var label: String {
    switch self {
    case .home: return "Home"
    case .shop: return "Shop"
    case .exclusive: return "Exclusive"
    case .profile: return "Profile"
    case .stores: return "Stores"
    case .bestie: return "Ask Bestie"
    }
  }

  var symbol: String {
    switch self {
    case .home: return "house"
    case .shop: return "bag"
    case .exclusive: return "sparkles"
    case .profile: return "person"
    case .stores: return "mappin.and.ellipse"
    case .bestie: return "bestie.sparkle"
    }
  }
}

struct WebDestination: Identifiable, Equatable {
  let id = UUID()
  let title: String
  let url: URL
  let documentStartJavaScript: String?
  let postLoadJavaScript: String?
  let allowsExternalNavigation: Bool
  let allowsCommerceNavigation: Bool
  let reconcilesCartOnDismiss: Bool

  var isIsolatedBestie: Bool {
    title == "Ask Bestie"
      && documentStartJavaScript != nil
      && postLoadJavaScript != nil
  }

  static func == (lhs: WebDestination, rhs: WebDestination) -> Bool {
    lhs.id == rhs.id
  }
}

struct RootCollection: Identifiable, Equatable {
  let title: String
  let handle: String

  var id: String { handle }
}

struct ShopSheetFocusRequest: Equatable, Sendable {
  let rootTitle: String
  let destinationPath: String

  static let brands = ShopSheetFocusRequest(
    rootTitle: "Brands",
    destinationPath: "/pages/brands"
  )
}

@MainActor
final class AppModel: ObservableObject {
  @Published var selectedDock: DockDestination = .home
  @Published private(set) var rootDockDestination: DockDestination = .home
  @Published var cart: StoreCart = .empty
  @Published var tabsMenu: StoreMenu?
  @Published private(set) var shopMenu: StoreMenu?
  @Published private(set) var shopSheetFocus: ShopSheetFocusRequest?
  @Published private(set) var isShopMenuLoading = false
  @Published private(set) var isBootstrapComplete = false
  @Published var webDestination: WebDestination?
  @Published var rootCollection: RootCollection?
  @Published var isShopPresented = false
  @Published var isProfilePresented = false
  @Published var isSearchPresented = false
  @Published var isCartPresented = false
  @Published var isLovesPresented = false
  @Published var isIngredientGuidePresented = false
  @Published var presentedNativeProduct: StoreProduct?
  @Published var shouldPresentNativeCart = false
  @Published var shouldPresentNativeBrands = false
  @Published private(set) var isCartBusy = false
  @Published private(set) var isBuyNowBusy = false
  @Published var cartError: String?
  @Published private(set) var buyNowError: String?
  @Published private(set) var hasPendingCartRestore = false
  @Published private(set) var navigationResetID = UUID()
  @Published private(set) var isWishlistBridgeActivated = false
  @Published private(set) var isWishlistBridgeReady = false
  @Published private(set) var wishlistCount: Int?
  @Published private(set) var verifiedWishlistVariantStates: [String: Bool] = [:]
  @Published private(set) var wishlistMutationVariantIDs: Set<String> = []
  @Published private(set) var webSession: ProtectedWebSession?
  @Published private(set) var customerSession: CustomerSessionState = .unknown
  @Published private(set) var customerDisplayName: String?
  @Published private(set) var isCustomerSessionRefreshing = false
  @Published private(set) var isCustomerAuthInProgress = false
  @Published private(set) var transientNotice: String?

  let client: StorefrontClient

  private let cartVault: any CartIDStoring
  private let legacyCartMigrator: any LegacyWebCartMigrating
  private let customerSessionProbe: any CustomerSessionProbing
  private let customerAuthenticator: any CustomerAuthenticating
  private let externalURLOpener: (URL) -> Void
  private static let tabsMenuHandle = "tabs-menu"
  private static let shopMenuHandle = "navabr"
  private var suppliedWebSession: ProtectedWebSession?
  private var bootstrapTask: Task<Void, Never>?
  private let cacheTTL: TimeInterval
  private let cacheCapacity: Int
  private var pendingCartID: String?
  private var checkoutRequested = false
  private var fullCartRequested = false
  private var reconcileCartAfterWebDismissal = false
  private var didConsumeSuppliedWebSession = false
  private var productCache: [String: CacheEntry<StoreProduct>] = [:]
  private var collectionCache: [CollectionRequestKey: CacheEntry<ProductPage>] = [:]
  private var productRequests: [String: Task<StoreProduct, Error>] = [:]
  private var collectionRequests: [CollectionRequestKey: Task<ProductPage, Error>] = [:]
  private var customerSessionRefreshGeneration = 0
  private var didStartInitialCustomerSessionRefresh = false
  // A protected sign-in flow must not erase the last known state while the
  // WebKit cookie handoff is settling. Logout is the one flow that should
  // deliberately clear the published identity before probing again.
  private var clearCustomerSessionOnNextWebDismissal = false
  // Set only when the protected Shopify account flow has emitted verified
  // authenticated DOM markers.  This lets the native shell publish the name
  // immediately while the shared WebKit cookie is still settling.
  private var didCompleteCustomerAuthenticationHandoff = false
  private var pendingNativeWebNavigation: NativeStorefrontNavigation?
  private static let customerSessionRetryDelay: UInt64 = 250_000_000

  #if DEBUG
    private var usesSignedInProfileFixture: Bool {
      let arguments = ProcessInfo.processInfo.arguments
      return arguments.contains("-ui-test-signed-in-profile")
        || arguments.contains("-ui-preview-signed-in-profile")
    }

    private var opensSignedInProfilePreview: Bool {
      ProcessInfo.processInfo.arguments.contains("-ui-preview-signed-in-profile")
    }
  #endif

  lazy var wishlistBridge: WishlistBridge = {
    let bridge = WishlistBridge()
    bridge.onReset = { [weak self] in
      self?.resetWishlistVerification()
    }
    bridge.onReadback = { [weak self] readback in
      self?.applyWishlistReadback(readback)
    }
    return bridge
  }()

  init(
    client: StorefrontClient = .shared,
    webSession: ProtectedWebSession? = nil,
    cartVault: any CartIDStoring = CartIDVault(),
    legacyCartMigrator: any LegacyWebCartMigrating =
      LegacyWebCartMigrator(),
    customerSessionProbe: any CustomerSessionProbing =
      CustomerSessionProbe(),
    customerAuthenticator: any CustomerAuthenticating =
      CustomerAuthClient(),
    externalURLOpener: @escaping (URL) -> Void = {
      UIApplication.shared.open($0)
    },
    cacheTTL: TimeInterval = 5 * 60,
    cacheCapacity: Int = 32
  ) {
    self.client = client
    self.suppliedWebSession = webSession
    self.cartVault = cartVault
    self.legacyCartMigrator = legacyCartMigrator
    self.customerSessionProbe = customerSessionProbe
    self.customerAuthenticator = customerAuthenticator
    self.externalURLOpener = externalURLOpener
    self.cacheTTL = max(0, cacheTTL)
    self.cacheCapacity = max(1, cacheCapacity)

    #if DEBUG
      if opensSignedInProfilePreview {
        isProfilePresented = true
      }
    #endif
  }

  func bootstrap() async {
    startInitialCustomerSessionRefreshIfNeeded()

    if isBootstrapComplete {
      return
    }
    if let bootstrapTask {
      await bootstrapTask.value
      return
    }

    let task = Task { @MainActor [weak self] in
      guard let self else { return }
      await self.performBootstrap()
    }
    bootstrapTask = task
    await task.value
    bootstrapTask = nil
  }

  func retryShopMenu() async {
    guard !isShopMenuLoading else { return }

    isShopMenuLoading = true
    defer { isShopMenuLoading = false }

    guard let menu = await fetchMenu(handle: Self.shopMenuHandle),
      menu.handle == Self.shopMenuHandle
    else {
      return
    }
    shopMenu = menu
  }

  private func performBootstrap() async {
    isShopMenuLoading = true
    defer {
      isShopMenuLoading = false
      isBootstrapComplete = true
    }

    #if DEBUG
      if ProcessInfo.processInfo.arguments.contains("-ui-test-reset-cart") {
        cartVault.delete()
        cart = .empty
        legacyCartMigrator.markComplete()
      }
    #endif

    async let tabsTask = fetchMenu(handle: Self.tabsMenuHandle)
    async let shopTask = fetchMenu(handle: Self.shopMenuHandle)

    await restoreCart()
    await migrateLegacyCartIfNeeded()

    let (fetchedTabsMenu, fetchedShopMenu) = await (
      tabsTask,
      shopTask
    )
    if fetchedTabsMenu?.handle == Self.tabsMenuHandle {
      tabsMenu = fetchedTabsMenu
    }
    if fetchedShopMenu?.handle == Self.shopMenuHandle {
      shopMenu = fetchedShopMenu
    }
  }

  private func startInitialCustomerSessionRefreshIfNeeded() {
    guard !didStartInitialCustomerSessionRefresh else {
      return
    }
    didStartInitialCustomerSessionRefresh = true

    Task { [weak self] in
      await self?.restoreNativeCustomerSessionOrProbe()
    }
  }

  private func restoreNativeCustomerSessionOrProbe() async {
    #if DEBUG
      if usesSignedInProfileFixture {
        publishCustomerIdentity(.fixture)
        return
      }
    #endif

    guard customerAuthenticator.isConfigured else {
      await refreshCustomerSession()
      return
    }
    do {
      if let identity = try await customerAuthenticator.restore() {
        publishCustomerIdentity(identity)
      } else {
        customerSession = .signedOut
        customerDisplayName = nil
      }
    } catch {
      // A failed restore must never leave the Profile in an indeterminate
      // "checking" state. The next explicit sign-in can recover the session.
      customerSession = .signedOut
      customerDisplayName = nil
    }
  }

  func selectDock(_ destination: DockDestination) {
    switch destination {
    case .home:
      isProfilePresented = false
      isShopPresented = false
      shopSheetFocus = nil
      resetNativeNavigation()
      selectedDock = .home
      rootDockDestination = .home
      rootCollection = nil
    case .shop:
      presentShop()
    case .exclusive:
      isProfilePresented = false
      isShopPresented = false
      shopSheetFocus = nil
      resetNativeNavigation()
      selectedDock = .exclusive
      rootDockDestination = .exclusive
      rootCollection = nil
    case .profile:
      isShopPresented = false
      shopSheetFocus = nil
      selectedDock = .profile
      isProfilePresented = true
      if !isCustomerSessionRefreshing {
        Task { [weak self] in
          await self?.refreshCustomerSession(clearPublishedState: false)
        }
      }
    case .stores:
      isProfilePresented = false
      isShopPresented = false
      shopSheetFocus = nil
      resetNativeNavigation()
      selectedDock = .stores
      rootDockDestination = .stores
      rootCollection = nil
    case .bestie:
      isProfilePresented = false
      isShopPresented = false
      shopSheetFocus = nil
      selectedDock = .bestie
      presentBestie()
    }
  }

  func presentShop(focusedOn focus: ShopSheetFocusRequest? = nil) {
    dismissPresentedSheets()
    isProfilePresented = false
    shopSheetFocus = focus
    selectedDock = .shop
    isShopPresented = true
  }

  func dismissShop() {
    isShopPresented = false
    shopSheetFocus = nil
    if selectedDock == .shop {
      selectedDock = rootDockDestination
    }
  }

  func dismissProfile() {
    isProfilePresented = false
    if selectedDock == .profile {
      selectedDock = rootDockDestination
    }
  }

  func openProfileCart() {
    dismissProfile()
    presentCart()
  }

  func openProfileSignIn() {
    dismissProfile()
    resetNativeNavigation()
    selectedDock = .home
    rootDockDestination = .home
    rootCollection = nil
    clearCustomerSessionOnNextWebDismissal = false
    if customerAuthenticator.isConfigured {
      startNativeCustomerAuthentication()
    } else {
      // Unit-test bundles and older development installs do not carry the
      // production Shopify client configuration. Preserve their legacy route
      // without allowing it in the shipped app.
      presentWeb(
        title: "Sign In",
        url: ShopifyAsset.shopRoot.appendingPathComponent("account/login")
      )
    }
  }

  func openProfileCreateAccount() {
    dismissProfile()
    resetNativeNavigation()
    selectedDock = .home
    rootDockDestination = .home
    rootCollection = nil
    clearCustomerSessionOnNextWebDismissal = false
    if customerAuthenticator.isConfigured {
      startNativeCustomerAuthentication()
    } else {
      presentWeb(
        title: "Create Account",
        url: ShopifyAsset.shopRoot.appendingPathComponent("account/register")
      )
    }
  }

  func openProfileLogout() {
    dismissProfile()
    clearCustomerSessionOnNextWebDismissal = true
    if customerAuthenticator.isConfigured {
      isCustomerAuthInProgress = true
      Task { [weak self] in
        guard let self else { return }
        await self.customerAuthenticator.logout()
        self.isCustomerAuthInProgress = false
        self.invalidateCustomerSession()
        self.selectedDock = self.rootDockDestination
        self.rootCollection = nil
      }
    } else {
      presentWeb(
        title: "Logout",
        url: ShopifyAsset.shopRoot.appendingPathComponent("account/logout")
      )
    }
  }

  private func startNativeCustomerAuthentication() {
    guard !isCustomerAuthInProgress else { return }
    isCustomerAuthInProgress = true
    customerSessionRefreshGeneration &+= 1
    isCustomerSessionRefreshing = false
    Task { [weak self] in
      guard let self else { return }
      defer { self.isCustomerAuthInProgress = false }
      do {
        let identity = try await self.customerAuthenticator.authenticate()
        self.publishCustomerIdentity(identity)
        // OAuth callback completion is the native return point. The hosted
        // Shopify account page is never left underneath the storefront.
        self.dismissPresentedOverlays()
        self.dismissPresentedSheets()
        self.selectedDock = .home
        self.rootDockDestination = .home
        self.rootCollection = nil
        self.resetNativeNavigation()
      } catch CustomerAuthError.cancelled {
        // Cancellation is a normal user action; keep Home signed out without
        // presenting a noisy error banner.
        self.customerSession = .signedOut
        self.customerDisplayName = nil
      } catch {
        self.customerSession = .signedOut
        self.customerDisplayName = nil
        self.showTransientNotice(error.localizedDescription)
      }
    }
  }

  private func publishCustomerIdentity(_ identity: CustomerIdentity) {
    customerSessionRefreshGeneration &+= 1
    isCustomerSessionRefreshing = false
    customerSession = .signedIn(firstName: identity.preferredFirstName)
    customerDisplayName = identity.displayName
  }

  func openProfileDeleteAccount() {
    dismissProfile()
    presentWeb(
      title: "Delete my account",
      url: ShopifyAsset.shopRoot.appendingPathComponent(
        "pages/delete-account"
      )
    )
  }

  func openProfileBuyItAgain() {
    dismissProfile()
    presentWeb(
      title: "Buy It Again",
      url: ShopifyAsset.shopRoot.appendingPathComponent("account/login")
    )
  }

  func openProfileOrderTracking() {
    dismissProfile()
    // v8.1.9 leaves `order-link` blank, so the theme resolves this row to
    // `routes.account_url`.
    presentWeb(
      title: "Track My Order",
      url: ShopifyAsset.shopRoot.appendingPathComponent("account")
    )
  }

  func openProfileStores() {
    selectDock(.stores)
  }

  func openProfileLoves() {
    dismissProfile()
    presentLoves()
  }

  func openProfileIngredientGuide() {
    dismissProfile()
    dismissPresentedSheets()
    isIngredientGuidePresented = true
  }

  func openProfileBestie() {
    dismissProfile()
    presentBestie()
  }

  private func presentBestie() {
    presentWeb(
      title: "Ask Bestie",
      url: ShopifyAsset.shopRoot,
      documentStartJavaScript: Self.bestieIsolationJavaScript,
      postLoadJavaScript: Self.bestieLauncherJavaScript
    )
  }

  static let bestieIsolationJavaScript = """
    (() => {
      const install = () => {
        const root = document.documentElement;
        if (!root) return false;
        root.classList.add('bot-native-bestie');
        if (document.getElementById('bot-native-bestie-isolation')) {
          return true;
        }

        const style = document.createElement('style');
        style.id = 'bot-native-bestie-isolation';
        style.textContent = `
          html.bot-native-bestie,
          html.bot-native-bestie body {
            width: 100% !important;
            height: 100% !important;
            min-height: 100% !important;
            margin: 0 !important;
            overflow: hidden !important;
            background: #fff !important;
          }

          html.bot-native-bestie body > *:not(chat-widget) {
            display: none !important;
          }

          html.bot-native-bestie body > chat-widget {
            display: block !important;
            position: fixed !important;
            inset: 0 !important;
            width: 100% !important;
            height: 100% !important;
            z-index: 2147483647 !important;
          }

          html.bot-native-bestie body:not(.bot-native-bestie-ready)::before {
            content: 'Opening Ask Bestie…';
            position: fixed;
            inset: 0;
            z-index: 2147483646;
            display: grid;
            place-items: center;
            color: #6e6e73;
            background: #fff;
            font: 600 15px -apple-system, BlinkMacSystemFont, sans-serif;
          }
        `;
        root.appendChild(style);
        return true;
      };

      if (install()) return;
      const observer = new MutationObserver(() => {
        if (!install()) return;
        observer.disconnect();
      });
      observer.observe(document, { childList: true, subtree: true });
    })();
    """

  static let bestieLauncherJavaScript = """
    (() => {
      const post = (event, message) => {
        const handler =
          window.webkit &&
          window.webkit.messageHandlers &&
          window.webkit.messageHandlers.\(ProtectedWebSession.scriptMessageHandlerName);
        if (!handler) return;
        handler.postMessage({
          event: event,
          message: message || null
        });
      };

      document.addEventListener('click', (event) => {
        const path =
          typeof event.composedPath === 'function'
          ? event.composedPath()
          : [];
        const isMinimize = path.some((node) =>
          node instanceof Element &&
          node.classList.contains('askTimmy-minimize-button')
        );
        if (!isMinimize) return;
        event.preventDefault();
        event.stopImmediatePropagation();
        post('dismiss');
      }, true);

      const findLauncher = () =>
        document.querySelector('.askTimmy-toggle-launcher-content') ||
        document.querySelector('.askTimmy-toggle-launcher-container') ||
        document.querySelector('[class*="askTimmy"][class*="launcher"]') ||
        document.querySelector('[class*="askTimmy"][class*="toggle"]') ||
        document.querySelector('.askTimmy-bubble');

      const deepQuery = (root, selector) => {
        if (!root) return null;
        const direct = root.querySelector?.(selector);
        if (direct) return direct;
        if (root.shadowRoot) {
          const shadowMatch = deepQuery(root.shadowRoot, selector);
          if (shadowMatch) return shadowMatch;
        }
        const nodes = root.querySelectorAll?.('*') || [];
        for (const node of nodes) {
          if (!node.shadowRoot) continue;
          const match = deepQuery(node.shadowRoot, selector);
          if (match) return match;
        }
        return null;
      };

      let isPreparing = false;
      let didTrigger = false;
      const prepare = async () => {
        if (isPreparing) return null;
        const widget = document.querySelector('chat-widget');
        if (!widget || !customElements.get('chat-widget')) {
          return null;
        }
        if (didTrigger) return widget;

        isPreparing = true;
        try {
          if (typeof widget.componentOnReady === 'function') {
            await widget.componentOnReady();
          }
          widget.isAddToCartEnabled = false;
          const launcher = findLauncher();
          if (launcher) {
            launcher.click();
          } else {
            document.dispatchEvent(
              new CustomEvent('openAskTimmyChat', {
                bubbles: true,
                composed: true
              })
            );
          }
          didTrigger = true;
          return widget;
        } catch (_) {
          return null;
        } finally {
          isPreparing = false;
        }
      };

      const open = async () => {
        const widget = await prepare();
        if (!widget) return false;
        const chatWindow = deepQuery(
          widget,
          '.chat-window-container.askTimmy-show'
        );
        if (!chatWindow) return false;
        const bounds = chatWindow.getBoundingClientRect();
        const style = getComputedStyle(chatWindow);
        if (
          bounds.width < 1 ||
          bounds.height < 1 ||
          style.display === 'none' ||
          style.visibility === 'hidden' ||
          Number(style.opacity) === 0
        ) {
          return false;
        }
        document.body?.classList.add('bot-native-bestie-ready');
        post('ready');
        return true;
      };

      let attempts = 0;
      const timer = setInterval(async () => {
        attempts += 1;
        if (await open()) {
          clearInterval(timer);
          return;
        }
        if (attempts >= 120) {
          clearInterval(timer);
          post(
            'failure',
            'Ask Bestie couldn’t open. Check your connection and try again.'
          );
        }
      }, 250);
      void open().then((opened) => {
        if (opened) clearInterval(timer);
      });
    })();
    """

  func showCollection(title: String, handle: String) {
    let resolvedHandle = canonicalCollectionHandle(handle)
    resetNativeNavigation()
    selectedDock = resolvedHandle == "only-at-beautyontapp" ? .exclusive : .home
    rootDockDestination = selectedDock
    rootCollection = RootCollection(title: title, handle: resolvedHandle)
    isShopPresented = false
    shopSheetFocus = nil
  }

  /// Theme links can retain retired storefront aliases. Resolve known aliases
  /// once at the navigation boundary so pills, home rails and deep links all
  /// open the same native collection.
  private func canonicalCollectionHandle(_ handle: String) -> String {
    let normalized = handle.trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()
    switch normalized {
    case "body-wash-1":
      return "body-wash"
    default:
      return normalized
    }
  }

  func showBrands() {
    dismissPresentedOverlays()
    dismissPresentedSheets()
    webDestination = nil
    rootCollection = nil
    selectedDock = rootDockDestination
    shouldPresentNativeBrands = true
  }

  func presentSearch() {
    dismissPresentedOverlays()
    dismissPresentedSheets()
    DispatchQueue.main.async { [weak self] in
      guard let self,
        !self.isShopPresented,
        !self.isProfilePresented,
        self.webDestination == nil
      else {
        return
      }
      self.isSearchPresented = true
    }
  }

  func presentCart() {
    dismissPresentedOverlays()
    dismissPresentedSheets()
    isCartPresented = true
  }

  func presentFullCart() {
    dismissPresentedOverlays()
    dismissPresentedSheets()
    shouldPresentNativeCart = true
  }

  func requestFullCartAfterCartDismiss() {
    fullCartRequested = true
    isCartPresented = false
  }

  func presentRequestedFullCart() {
    guard fullCartRequested, webDestination == nil else {
      fullCartRequested = false
      return
    }
    fullCartRequested = false
    presentFullCart()
  }

  private func dismissPresentedOverlays() {
    if isShopPresented {
      dismissShop()
    }
    if isProfilePresented {
      dismissProfile()
    }
  }

  private func dismissPresentedSheets() {
    isSearchPresented = false
    isCartPresented = false
    isLovesPresented = false
    isIngredientGuidePresented = false
  }

  func presentWeb(
    title: String,
    url: URL,
    documentStartJavaScript: String? = nil,
    postLoadJavaScript: String? = nil,
    allowsExternalNavigation: Bool = false,
    allowsCommerceNavigation: Bool = false,
    reconcilesCartOnDismiss: Bool = false
  ) {
    dismissPresentedOverlays()
    dismissPresentedSheets()
    prepareWebSession()
    if allowsCommerceNavigation {
      // Checkout and verified BookX journeys must stay inside their protected
      // first-party session; reopening their product path natively would
      // interrupt payment or service selection.
      webSession?.onNativeStorefrontNavigation = nil
    }
    webDestination = WebDestination(
      title: title,
      url: url,
      documentStartJavaScript: documentStartJavaScript,
      postLoadJavaScript: postLoadJavaScript,
      allowsExternalNavigation: allowsExternalNavigation,
      allowsCommerceNavigation: allowsCommerceNavigation,
      reconcilesCartOnDismiss: reconcilesCartOnDismiss
    )
    reconcileCartAfterWebDismissal = reconcilesCartOnDismiss
  }

  func openThemeLink(title: String, link: ThemeLink) {
    switch link {
    case .collection(let handle):
      showCollection(title: title, handle: handle)
    case .web(let url):
      if !openStorefrontURLNatively(title: title, url: url) {
        presentWeb(title: title, url: url)
      }
    case .booking(let url):
      presentWeb(
        title: title,
        url: url,
        allowsExternalNavigation: true,
        allowsCommerceNavigation: true
      )
    case .external(let url):
      externalURLOpener(url)
    case .none:
      showTransientNotice("That destination is unavailable right now.")
    }
  }

  @discardableResult
  func openStorefrontURLNatively(
    title: String,
    url: URL
  ) -> Bool {
    guard ShopifyAsset.isPrimaryStorefrontURL(url),
      url.user == nil,
      url.password == nil,
      url.port == nil || url.port == 443
    else {
      return false
    }

    let pathComponents = url.pathComponents.filter { $0 != "/" }
    if pathComponents.isEmpty,
      url.query == nil,
      url.fragment == nil
    {
      selectDock(.home)
      return true
    }

    if pathComponents.count == 2,
      pathComponents[0].caseInsensitiveCompare("pages") == .orderedSame,
      pathComponents[1].caseInsensitiveCompare("brands") == .orderedSame,
      url.query == nil,
      url.fragment == nil
    {
      showBrands()
      return true
    }

    guard let navigation = NativeStorefrontNavigation.parse(url) else {
      return false
    }
    openNativeWebNavigation(navigation, collectionTitle: title)
    return true
  }

  func presentLoves() {
    dismissPresentedOverlays()
    dismissPresentedSheets()
    isLovesPresented = true
  }

  func cartLine(forVariantID variantID: String) -> StoreCartLine? {
    cart.lines.first(where: { $0.merchandise.id == variantID })
  }

  func cartQuantity(forVariantID variantID: String) -> Int {
    cartLine(forVariantID: variantID)?.quantity ?? 0
  }

  func updateCartNote(_ note: String) async -> Bool {
    guard !cart.id.isEmpty, !isCartBusy else { return false }
    isCartBusy = true
    cartError = nil
    defer { isCartBusy = false }
    do {
      setCart(try await client.updateCartNote(cartID: cart.id, note: note))
      return true
    } catch {
      cartError = error.localizedDescription
      showTransientNotice(error.localizedDescription)
      return false
    }
  }

  func estimateDelivery(
    provinceCode: String,
    postalCode: String
  ) async -> [StoreDeliveryOption] {
    guard !cart.id.isEmpty, !isCartBusy else { return [] }
    isCartBusy = true
    cartError = nil
    defer { isCartBusy = false }
    do {
      let updated = try await client.estimateDelivery(
        cartID: cart.id,
        provinceCode: provinceCode,
        postalCode: postalCode
      )
      setCart(updated)
      return updated.deliveryOptions
    } catch {
      cartError = error.localizedDescription
      return []
    }
  }

  func activateWishlistBridge() {
    if !isWishlistBridgeActivated {
      isWishlistBridgeActivated = true
    }
    wishlistBridge.start()
  }

  func verifiedWishlistState(for variantGID: String) -> Bool? {
    guard let variantID = ShopifyNumericID.variant(from: variantGID) else {
      return nil
    }
    return verifiedWishlistVariantStates[variantID]
  }

  func isWishlistMutationInFlight(for variantGID: String) -> Bool {
    guard let variantID = ShopifyNumericID.variant(from: variantGID) else {
      return false
    }
    return wishlistMutationVariantIDs.contains(variantID)
  }

  func refreshWishlistState(variantGID: String) async {
    guard isWishlistBridgeActivated,
      isWishlistBridgeReady,
      ShopifyNumericID.variant(from: variantGID) != nil
    else {
      return
    }
    _ = await wishlistBridge.readback(variantGID: variantGID)
  }

  func toggleWishlist(
    product: StoreProduct,
    variant: StoreVariant
  ) async -> Bool {
    guard ShopifyNumericID.product(from: product.id) != nil,
      let variantID = ShopifyNumericID.variant(from: variant.id),
      !wishlistMutationVariantIDs.contains(variantID)
    else {
      showTransientNotice("Loves is unavailable for this product.")
      return false
    }

    activateWishlistBridge()
    wishlistMutationVariantIDs.insert(variantID)
    defer { wishlistMutationVariantIDs.remove(variantID) }

    guard
      let readback = await wishlistBridge.toggle(
        productGID: product.id,
        variantGID: variant.id
      )
    else {
      showTransientNotice(
        "Loves couldn’t refresh. Check your connection and try again."
      )
      return false
    }
    let isVerified =
      readback.variantID == variantID && readback.isSaved != nil
    if !isVerified {
      showTransientNotice(
        "Loves couldn’t confirm that change. Please try again."
      )
    }
    return isVerified
  }

  func showTransientNotice(_ message: String) {
    let normalized = message.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    guard !normalized.isEmpty else { return }
    transientNotice = normalized

    Task { [weak self] in
      do {
        try await Task.sleep(nanoseconds: 3_200_000_000)
      } catch {
        return
      }
      guard self?.transientNotice == normalized else { return }
      self?.transientNotice = nil
    }
  }

  @discardableResult
  func requestCheckoutAfterCartDismiss() -> Bool {
    guard !cart.id.isEmpty, !isCartBusy else { return false }
    checkoutRequested = true
    return true
  }

  func presentRequestedCheckout() async {
    while checkoutRequested && isCartBusy {
      do {
        try await Task.sleep(nanoseconds: 50_000_000)
      } catch {
        checkoutRequested = false
        return
      }
    }
    guard checkoutRequested, !cart.id.isEmpty else {
      checkoutRequested = false
      return
    }
    checkoutRequested = false
    presentWeb(
      title: "Checkout",
      url: cart.checkoutURL,
      allowsExternalNavigation: true,
      allowsCommerceNavigation: true,
      reconcilesCartOnDismiss: true
    )
  }

  func addToCart(
    variant: StoreVariant,
    quantity: Int = 1,
    attributes: [StoreAttribute] = []
  ) async -> Bool {
    guard variant.availableForSale else {
      cartError = "This option is sold out."
      showTransientNotice("This option is sold out.")
      return false
    }
    guard !isCartBusy else { return false }

    isCartBusy = true
    cartError = nil
    defer { isCartBusy = false }

    do {
      if cart.id.isEmpty, let pendingCartID {
        do {
          setCart(try await client.cart(id: pendingCartID))
        } catch let error as StorefrontError
          where error.invalidatesPersistedCartID
        {
          invalidateCart()
        } catch {
          cartError = error.localizedDescription
          showTransientNotice(error.localizedDescription)
          return false
        }
      }

      let updated: StoreCart
      if cart.id.isEmpty {
        updated = try await client.createCart(
          lines: [
            StoreCartInputLine(
              merchandiseID: variant.id,
              quantity: quantity,
              attributes: attributes
            )
          ]
        )
      } else {
        updated = try await client.addCartLines(
          cartID: cart.id,
          merchandiseID: variant.id,
          quantity: quantity,
          attributes: attributes
        )
      }
      setCart(updated)
      return true
    } catch let error as StorefrontError
      where error.invalidatesPersistedCartID && !cart.id.isEmpty
    {
      invalidateCart()
      do {
        let recreated = try await client.createCart(
          lines: [
            StoreCartInputLine(
              merchandiseID: variant.id,
              quantity: quantity,
              attributes: attributes
            )
          ]
        )
        setCart(recreated)
        return true
      } catch {
        cartError = error.localizedDescription
        showTransientNotice(error.localizedDescription)
        return false
      }
    } catch {
      cartError = error.localizedDescription
      showTransientNotice(error.localizedDescription)
      return false
    }
  }

  func buyNow(variant: StoreVariant, quantity: Int = 1) async -> Bool {
    guard variant.availableForSale else {
      buyNowError = "This option is sold out."
      return false
    }
    guard !isBuyNowBusy, !isCartBusy else { return false }

    isBuyNowBusy = true
    buyNowError = nil
    defer { isBuyNowBusy = false }

    do {
      let requestedQuantity = max(quantity, 1)
      let checkoutCart = try await client.createCart(
        merchandiseID: variant.id,
        quantity: requestedQuantity
      )
      guard WebNavigationPolicy.isCommerceURL(checkoutCart.checkoutURL) else {
        throw StorefrontError.missingData("Checkout")
      }
      guard checkoutCart.totalQuantity == requestedQuantity,
        checkoutCart.lines.count == 1,
        checkoutCart.lines.first?.merchandise.id == variant.id,
        checkoutCart.lines.first?.quantity == requestedQuantity
      else {
        throw StorefrontError.missingData("Checkout selection")
      }

      // Buy Now intentionally uses a separate one-item Storefront cart.
      // It never replaces or appends to the customer's persisted bag.
      presentWeb(
        title: "Checkout",
        url: checkoutCart.checkoutURL,
        allowsExternalNavigation: true,
        allowsCommerceNavigation: true
      )
      return true
    } catch {
      buyNowError = error.localizedDescription
      return false
    }
  }

  func setCartLine(_ line: StoreCartLine, quantity: Int) async {
    guard !cart.id.isEmpty, !isCartBusy else { return }
    isCartBusy = true
    cartError = nil
    defer { isCartBusy = false }

    do {
      let updated: StoreCart
      if quantity <= 0 {
        updated = try await client.removeCartLine(
          cartID: cart.id,
          lineID: line.id
        )
      } else {
        updated = try await client.updateCartLine(
          cartID: cart.id,
          lineID: line.id,
          quantity: quantity
        )
      }
      setCart(updated)
      if quantity <= 0, let reservationID = line.bookingReservationID {
        await BookEasyClient.live.deleteReservation(id: reservationID)
      }
    } catch let error as StorefrontError
      where error.invalidatesPersistedCartID
    {
      invalidateCart()
      cartError = error.localizedDescription
    } catch {
      cartError = error.localizedDescription
    }
  }

  func retryCart() async {
    guard !isCartBusy else { return }
    let cartID = cart.id.isEmpty ? pendingCartID : cart.id
    guard let cartID, !cartID.isEmpty else { return }
    isCartBusy = true
    cartError = nil
    defer { isCartBusy = false }
    do {
      setCart(try await client.cart(id: cartID))
    } catch let error as StorefrontError
      where error.invalidatesPersistedCartID
    {
      invalidateCart()
    } catch {
      cartError = error.localizedDescription
    }
  }

  func retryPendingCartWhenAvailable() async {
    while isCartBusy {
      do {
        try await Task.sleep(nanoseconds: 100_000_000)
      } catch {
        return
      }
    }
    if hasPendingCartRestore {
      await retryCart()
    } else if cart.id.isEmpty {
      await migrateLegacyCartIfNeeded()
    }
  }

  func webFlowDidDismiss() {
    let dismissedSession = webSession
    let nativeNavigation = pendingNativeWebNavigation
    pendingNativeWebNavigation = nil
    webSession = nil
    dismissedSession?.shutdown()
    if selectedDock == .bestie {
      selectedDock = .home
      rootDockDestination = .home
    }

    let shouldReconcile = reconcileCartAfterWebDismissal
    reconcileCartAfterWebDismissal = false
    if isWishlistBridgeActivated {
      wishlistBridge.reinitializeFromPersistentSession()
    }
    if shouldReconcile {
      Task { [weak self] in
        await self?.retryCart()
      }
    }
    let clearCustomerSession = clearCustomerSessionOnNextWebDismissal
    clearCustomerSessionOnNextWebDismissal = false
    let completedAuthentication = didCompleteCustomerAuthenticationHandoff
    didCompleteCustomerAuthenticationHandoff = false
    if clearCustomerSession {
      invalidateCustomerSession()
    }
    Task { [weak self] in
      if completedAuthentication {
        // Shopify commits the new-account cookie after the hosted account
        // page finishes. Give WebKit one short run-loop turn before the
        // storefront probe reads the shared data store.
        try? await Task.sleep(nanoseconds: 600_000_000)
      }
      // Preserve the last verified identity during sign-in/create-account and
      // other web flows. A transient unknown DOM snapshot must not turn the
      // native Profile into an error state or leave the dock name blank.
      await self?.refreshCustomerSession(
        clearPublishedState: clearCustomerSession
      )
    }
    if let nativeNavigation {
      openNativeWebNavigation(nativeNavigation)
    }
  }

  /// Completes the native handoff as soon as the hosted Shopify account UI
  /// proves that authentication succeeded. The account webpage is a temporary
  /// credential surface; it must never remain visible as the post-login app.
  func customerAuthenticationDidSucceed(
    _ result: CustomerSessionProbeResult
  ) {
    guard case .signedIn(let firstName) = result.state,
          webDestination.map({ ProtectedWebSession.isAuthenticationFlow($0) }) == true
    else {
      return
    }

    didCompleteCustomerAuthenticationHandoff = true
    customerSessionRefreshGeneration &+= 1
    isCustomerSessionRefreshing = false
    customerSession = .signedIn(firstName: firstName)
    customerDisplayName = result.displayName ?? firstName

    // Authentication always returns to the native storefront Home. Do this
    // before dismissing the cover so SwiftUI never reveals an old Profile,
    // Shop, or account webpage underneath the transition.
    dismissPresentedOverlays()
    dismissPresentedSheets()
    selectedDock = .home
    rootDockDestination = .home
    rootCollection = nil
    resetNativeNavigation()
    webDestination = nil
  }

  /// Dismisses the temporary Shopify account surface when the authenticated
  /// route is visible but the account UI has not exposed a readable customer
  /// name yet. The shared WebKit cookie is reconciled by `webFlowDidDismiss`.
  func customerAuthenticationAccountRouteDidReach() {
    guard webDestination.map({ ProtectedWebSession.isAuthenticationFlow($0) }) == true
    else {
      return
    }

    didCompleteCustomerAuthenticationHandoff = true
    dismissPresentedOverlays()
    dismissPresentedSheets()
    selectedDock = .home
    rootDockDestination = .home
    rootCollection = nil
    resetNativeNavigation()
    webDestination = nil
  }

  func refreshCustomerSession(
    clearPublishedState: Bool = true
  ) async {
    #if DEBUG
      if usesSignedInProfileFixture {
        publishCustomerIdentity(.fixture)
        return
      }
    #endif

    customerSessionRefreshGeneration &+= 1
    let generation = customerSessionRefreshGeneration
    isCustomerSessionRefreshing = true
    defer {
      if generation == customerSessionRefreshGeneration {
        isCustomerSessionRefreshing = false
      }
    }
    if clearPublishedState {
      customerSession = .unknown
      customerDisplayName = nil
    }

    if customerAuthenticator.isConfigured {
      do {
        if let identity = try await customerAuthenticator.restore() {
          guard generation == customerSessionRefreshGeneration else { return }
          publishCustomerIdentity(identity)
        } else {
          customerSession = .signedOut
          customerDisplayName = nil
        }
      } catch {
        customerSession = .signedOut
        customerDisplayName = nil
      }
      return
    }

    // A Shopify login commits its cookie at the end of the protected
    // WKWebView flow. The first probe can therefore briefly see the old
    // signed-out HTML. Retry the indeterminate result instead of trapping
    // Profile on "couldn't be verified".
    let attempts = clearPublishedState ? 3 : 2
    var result = CustomerSessionProbeResult.unknown
    for attempt in 0..<attempts {
      result = await customerSessionProbe.probe()
      guard generation == customerSessionRefreshGeneration else {
        return
      }
      if result.state != .unknown || attempt == attempts - 1 {
        break
      }
      do {
        try await Task.sleep(nanoseconds: Self.customerSessionRetryDelay)
      } catch {
        return
      }
    }
    if result.state == .unknown, !clearPublishedState {
      // Keep a verified identity visible while a background refresh is still
      // settling. A transient/incomplete DOM snapshot must not turn the
      // profile back into an indeterminate signing-in state.
      return
    }
    customerSession = result.state
    customerDisplayName = result.displayName
  }

  private func invalidateCustomerSession() {
    customerSessionRefreshGeneration &+= 1
    isCustomerSessionRefreshing = false
    customerSession = .unknown
    customerDisplayName = nil
  }

  func product(
    handle: String,
    forceRefresh: Bool = false
  ) async throws -> StoreProduct {
    let now = Date()
    if !forceRefresh,
      let cached = productCache[handle],
      cached.isFresh(at: now, ttl: cacheTTL)
    {
      return cached.value
    }

    if let request = productRequests[handle] {
      return try await request.value
    }

    let request = Task { [client] in
      try await client.product(handle: handle)
    }
    productRequests[handle] = request

    do {
      let product = try await request.value
      productRequests[handle] = nil
      productCache[handle] = CacheEntry(value: product, storedAt: Date())
      trimCache(&productCache)
      return product
    } catch {
      productRequests[handle] = nil
      throw error
    }
  }

  func collection(
    handle: String,
    first: Int = 20,
    after: String? = nil,
    sort: CollectionSort = .featured,
    reverse: Bool = false,
    forceRefresh: Bool = false
  ) async throws -> ProductPage {
    // Theme snapshots can retain storefront aliases after Shopify retires
    // them. Resolve at the data boundary too, so deep links, rails and direct
    // collection fetches cannot bypass native navigation's normalization.
    let resolvedHandle = canonicalCollectionHandle(handle)
    let key = CollectionRequestKey(
      handle: resolvedHandle,
      first: first,
      after: after,
      sort: sort,
      reverse: reverse
    )
    if forceRefresh {
      collectionCache = collectionCache.filter { cachedKey, _ in
        cachedKey.handle != resolvedHandle || cachedKey.sort != sort || cachedKey.reverse != reverse
      }
    }
    let now = Date()
    if !forceRefresh,
      let cached = collectionCache[key],
      cached.isFresh(at: now, ttl: cacheTTL)
    {
      return cached.value
    }

    if let request = collectionRequests[key] {
      return try await request.value
    }

    let request = Task { [client] in
      try await client.collection(
        handle: resolvedHandle,
        first: first,
        after: after,
        sort: sort,
        reverse: reverse
      )
    }
    collectionRequests[key] = request

    do {
      let page = try await request.value
      collectionRequests[key] = nil
      collectionCache[key] = CacheEntry(value: page, storedAt: Date())
      trimCache(&collectionCache)
      return page
    } catch {
      collectionRequests[key] = nil
      throw error
    }
  }

  private func fetchMenu(handle: String) async -> StoreMenu? {
    try? await client.menu(handle: handle)
  }

  func restoreCart() async {
    guard let cartID = cartVault.read(), !cartID.isEmpty else { return }
    guard !isCartBusy else { return }
    pendingCartID = cartID
    hasPendingCartRestore = true
    isCartBusy = true
    cartError = nil
    defer { isCartBusy = false }
    do {
      setCart(try await client.cart(id: cartID))
    } catch let error as StorefrontError
      where error.invalidatesPersistedCartID
    {
      invalidateCart()
    } catch {
      // A normal offline or transient server failure must not destroy the
      // customer's persisted cart. It will be retried when they open Bag.
      cartError = error.localizedDescription
    }
  }

  func migrateLegacyCartIfNeeded() async {
    guard !legacyCartMigrator.isComplete else { return }

    if !cart.id.isEmpty || hasPendingCartRestore || cartVault.read() != nil {
      legacyCartMigrator.markComplete()
      return
    }
    guard !isCartBusy else { return }

    do {
      let legacyLines = try await legacyCartMigrator.fetchLines()
      guard !legacyLines.isEmpty else {
        legacyCartMigrator.markComplete()
        return
      }

      isCartBusy = true
      defer { isCartBusy = false }

      let migratedCart = try await client.createCart(lines: legacyLines)
      setCart(migratedCart)
      legacyCartMigrator.markComplete()
    } catch {
      // Keep the migration pending. A transient network or Shopify
      // failure is retried on the next launch or when Bag is opened.
    }
  }

  private func setCart(_ cart: StoreCart) {
    self.cart = cart
    pendingCartID = nil
    hasPendingCartRestore = false
    if cart.id.isEmpty {
      cartVault.delete()
    } else {
      cartVault.write(cart.id)
    }
  }

  private func invalidateCart() {
    cart = .empty
    pendingCartID = nil
    hasPendingCartRestore = false
    cartVault.delete()
  }

  private func resetNativeNavigation() {
    navigationResetID = UUID()
  }

  private func resetWishlistVerification() {
    isWishlistBridgeReady = false
    wishlistCount = nil
    verifiedWishlistVariantStates = [:]
  }

  private func applyWishlistReadback(_ readback: WishlistReadback) {
    wishlistCount = readback.count
    isWishlistBridgeReady = true
    if let variantID = readback.variantID,
      let isSaved = readback.isSaved
    {
      verifiedWishlistVariantStates[variantID] = isSaved
    }
  }

  private func prepareWebSession() {
    webSession?.shutdown()

    let session: ProtectedWebSession
    if !didConsumeSuppliedWebSession, let suppliedWebSession {
      didConsumeSuppliedWebSession = true
      self.suppliedWebSession = nil
      session = suppliedWebSession
    } else {
      session = ProtectedWebSession()
    }
    session.onNativeStorefrontNavigation = { [weak self] navigation in
      self?.queueNativeWebNavigation(navigation)
    }
    session.onDismissRequest = { [weak self] in
      self?.webDestination = nil
    }
    session.onCustomerAuthentication = { [weak self] result in
      self?.customerAuthenticationDidSucceed(result)
    }
    session.onCustomerAccountRoute = { [weak self] in
      self?.customerAuthenticationAccountRouteDidReach()
    }
    webSession = session
  }

  private func queueNativeWebNavigation(
    _ navigation: NativeStorefrontNavigation
  ) {
    guard webDestination != nil else { return }
    pendingNativeWebNavigation = navigation
    webDestination = nil
  }

  private func openNativeWebNavigation(
    _ navigation: NativeStorefrontNavigation,
    collectionTitle: String? = nil
  ) {
    switch navigation {
    case .collection(let handle):
      let sourcedTitle = collectionTitle?.trimmingCharacters(
        in: .whitespacesAndNewlines
      )
      let fallbackTitle =
        handle
        .split(separator: "-")
        .map { $0.capitalized }
        .joined(separator: " ")
      let resolvedTitle: String
      if let sourcedTitle, !sourcedTitle.isEmpty {
        resolvedTitle = sourcedTitle
      } else {
        resolvedTitle = fallbackTitle.isEmpty ? "Shop" : fallbackTitle
      }
      showCollection(
        title: resolvedTitle,
        handle: handle
      )
    case .product(let handle):
      Task { [weak self] in
        guard let self else { return }
        do {
          self.presentedNativeProduct = try await self.product(
            handle: handle
          )
        } catch {
          self.showTransientNotice(
            "That product couldn’t load. Check your connection and try again."
          )
        }
      }
    }
  }

  private func trimCache<Key: Hashable, Value>(
    _ cache: inout [Key: CacheEntry<Value>]
  ) {
    let expiration = Date().addingTimeInterval(-cacheTTL)
    cache = cache.filter { $0.value.storedAt >= expiration }

    let overflow = cache.count - cacheCapacity
    guard overflow > 0 else { return }
    let oldestKeys =
      cache
      .sorted { $0.value.storedAt < $1.value.storedAt }
      .prefix(overflow)
      .map(\.key)
    for key in oldestKeys {
      cache[key] = nil
    }
  }
}

private struct CacheEntry<Value> {
  let value: Value
  let storedAt: Date

  func isFresh(at date: Date, ttl: TimeInterval) -> Bool {
    date.timeIntervalSince(storedAt) <= ttl
  }
}

private struct CollectionRequestKey: Hashable {
  let handle: String
  let first: Int
  let after: String?
  let sort: CollectionSort
  let reverse: Bool
}

protocol CartIDStoring {
  func read() -> String?
  func write(_ value: String)
  func delete()
}

final class CartIDVault: CartIDStoring {
  private let service = "com.beautyontapp.ios.native-cart"
  private let account = "storefront-cart-id"

  func read() -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var result: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
      let data = result as? Data
    else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }

  func write(_ value: String) {
    guard let data = value.data(using: .utf8) else { return }
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
    let attributes: [String: Any] = [
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
    ]
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    if status == errSecItemNotFound {
      var newItem = query
      for (key, value) in attributes {
        newItem[key] = value
      }
      SecItemAdd(newItem as CFDictionary, nil)
    }
  }

  func delete() {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
    SecItemDelete(query as CFDictionary)
  }
}
