import SwiftUI
@preconcurrency import WebKit
import XCTest

@testable import BeautyOnTAppPro

final class ResourceLinkRailTests: XCTestCase {
  override func tearDown() {
    ResourceLinkRailURLProtocol.response = nil
    super.tearDown()
  }

  func testFeaturedParserOnlyReadsVerifiedMarkerNavigation() throws {
    let html = """
      <nav aria-label="Unrelated">
        <a href="https://attacker.example/collections/fake">Wrong</a>
      </nav>
      <nav aria-label="Featured links" data-bot-featured-links>
        <a href="/collections/new-arrivals" class="guidance-item">
          <span class="guidance-item-text">New</span>
          <span class="guidance-item__icon guidance-item__icon--sparkle"
                style="color: #ff3b5c;"><svg><title>Ignored icon title</title></svg></span>
        </a>
        <a href="https://beautyontapp.com/collections/skincare"
           class="guidance-item is-current" aria-current="page">
          <span class="guidance-item-text">Best Seller</span>
          <img src="//beautyontapp.com/cdn/shop/files/bestsellers.svg?v=1"
               alt="">
        </a>
        <a href="https://attacker.example/collections/cleanser">
          Must not render
        </a>
      </nav>
      <nav data-bot-quick-links>
        <a href="/collections/cleansers">Not a featured item</a>
      </nav>
      """

    let items = ResourceLinkHTMLParser.parse(
      html: html,
      kind: .featured
    )

    XCTAssertEqual(items.map(\.label), ["New", "Best Seller"])
    XCTAssertEqual(items[0].destinationURL.path, "/collections/new-arrivals")
    XCTAssertEqual(items[0].iconHint, "sparkle")
    XCTAssertEqual(items[0].iconColorHex, 0xFF3B5C)
    XCTAssertFalse(items[0].isCurrent)
    XCTAssertEqual(items[1].destinationURL.path, "/collections/skincare")
    XCTAssertEqual(items[1].imageURL?.host, "beautyontapp.com")
    XCTAssertEqual(items[1].imageURL?.pathExtension, "svg")
    XCTAssertTrue(items[1].isCurrent)

    guard case .collection(let firstHandle) = items[0].link,
      case .collection(let secondHandle) = items[1].link
    else {
      return XCTFail("Verified collection destinations must stay native.")
    }
    XCTAssertEqual(firstHandle, "new-arrivals")
    XCTAssertEqual(secondHandle, "skincare")
  }

  func testQuickParserDecodesLabelsAndIgnoresBreadcrumbAnchors() {
    let html = """
      <nav data-bot-quick-links aria-label="Related links">
        <ul>
          <li><a href="/collections/sets">Sets &amp; Bundles</a></li>
          <li><a href="/collections/body-care"
                 data-current="true">  Body   Care  </a></li>
        </ul>
      </nav>
      <nav aria-label="Breadcrumbs">
        <a href="/">Home</a>
      </nav>
      """

    let items = ResourceLinkHTMLParser.parse(html: html, kind: .quick)

    XCTAssertEqual(items.map(\.label), ["Sets & Bundles", "Body Care"])
    XCTAssertEqual(
      items.map(\.destinationURL.path),
      ["/collections/sets", "/collections/body-care"]
    )
    XCTAssertEqual(items.map(\.isCurrent), [false, true])
  }

  func testBreadcrumbParserUsesOnlyServerAuthoredContextPath() {
    let html = """
      <nav aria-label="Breadcrumbs">
        <a href="/collections/wrong">Outside context</a>
      </nav>
      <div data-bot-context-breadcrumb="product-quick-links">
        <nav aria-label="Breadcrumbs">
          <a href="/" title="Home">Home</a>
          <span aria-hidden="true"><svg><path d="M0 0"></path></svg></span>
          <a href="/collections/pastry-skincare">Pastry Skincare</a>
          <span aria-hidden="true"><svg><path d="M0 0"></path></svg></span>
          <span class="bot-breadcrumb__current" aria-current="page">
            Niacinamide Body Lotion
          </span>
        </nav>
      </div>
      """

    let items = ResourceBreadcrumbHTMLParser.parse(html: html)

    XCTAssertEqual(
      items.map(\.label),
      ["Home", "Pastry Skincare", "Niacinamide Body Lotion"]
    )
    XCTAssertEqual(
      items.compactMap(\.destinationURL?.path),
      ["/", "/collections/pastry-skincare"]
    )
    XCTAssertEqual(items.map(\.isCurrent), [false, false, true])
    XCTAssertNil(items.last?.destinationURL)
    XCTAssertNil(items.last?.link)
  }

  func testDestinationVerificationFailsClosed() throws {
    XCTAssertNotNil(
      ResourceLinkHTMLParser.verifiedDestination(
        "/collections/skincare"
      )
    )
    XCTAssertNotNil(
      ResourceLinkHTMLParser.verifiedDestination(
        "https://www.beautyontapp.com/pages/locations"
      )
    )

    let rejected = [
      "//attacker.example/collections/skincare",
      "http://beautyontapp.com/collections/skincare",
      "https://beautyontapp.com.attacker.example/collections/skincare",
      "https://attacker.example/collections/skincare",
      "https://beautyontapp.com:444/collections/skincare",
      "javascript:alert(1)",
      "/\\attacker.example/collections/skincare",
      "/collections/skincare\njavascript:alert(1)",
    ]
    for href in rejected {
      XCTAssertNil(
        ResourceLinkHTMLParser.verifiedDestination(href),
        "Expected rejection for \(href)"
      )
    }
  }

  func testSectionDecoderKeepsFeaturedAndQuickRailsSeparate() throws {
    let featuredID =
      "template--current__bot_featured_links_universal"
    let quickID =
      "template--current__bot_quick_links_universal"
    let payload: [String: String] = [
      featuredID: """
      <nav data-bot-featured-links>
        <a href="/collections/new-arrivals">
          <span class="guidance-item-text">New</span>
        </a>
      </nav>
      """,
      quickID: """
      <nav data-bot-quick-links>
        <a href="/collections/serums">Serums</a>
      </nav>
      """,
    ]
    let data = try JSONSerialization.data(withJSONObject: payload)

    let rails = try ResourceLinkSectionDecoder.decode(
      data: data,
      featuredSectionID: featuredID,
      quickSectionID: quickID
    )

    XCTAssertEqual(rails.featured.map(\.label), ["New"])
    XCTAssertEqual(rails.quick.map(\.label), ["Serums"])
  }

  func testPageURLUsesVerifiedResourceWithoutVolatileSectionIDs() throws {
    let collectionURL = try ResourceLinkRailClient.pageURL(
      for: .collection(handle: "skincare")
    )
    let productURL = try ResourceLinkRailClient.pageURL(
      for: .product(handle: "niacinamide-body-lotion")
    )

    XCTAssertEqual(collectionURL.path, "/collections/skincare")
    XCTAssertEqual(productURL.path, "/products/niacinamide-body-lotion")
    XCTAssertNil(collectionURL.query)
    XCTAssertNil(productURL.query)
    XCTAssertThrowsError(
      try ResourceLinkRailClient.pageURL(
        for: .collection(handle: "../account")
      )
    )
    XCTAssertEqual(
      StorefrontSectionResolver.documentRepresentationAcceptHeader,
      "text/html"
    )
  }

  func testDocumentDiscoveryFindsCurrentProductRailSections() throws {
    let document = resourceLinkDocument(
      prefix: "template--current"
    )

    let featured = try XCTUnwrap(
      StorefrontSectionDocumentParser.section(
        in: document,
        purpose: .featuredLinks
      )
    )
    let quick = try XCTUnwrap(
      StorefrontSectionDocumentParser.section(
        in: document,
        purpose: .quickLinks
      )
    )

    XCTAssertEqual(
      featured.id,
      "template--current__bot_product_featured_links"
    )
    XCTAssertEqual(
      quick.id,
      "template--current__bot_product_quick_links"
    )
    XCTAssertTrue(featured.html.contains("data-bot-featured-links"))
    XCTAssertTrue(quick.html.contains("data-bot-quick-links"))
  }

  func testStaleNullSectionResponseFallsBackToCurrentDocument()
    async throws
  {
    let recorder = ResourceLinkRailRequestRecorder()
    let currentDocument = resourceLinkDocument(
      prefix: "template--current"
    )
    let staleFeatured =
      "template--stale__bot_product_featured_links"
    let staleQuick =
      "template--stale__bot_product_quick_links"

    let client = makeResourceLinkClient(
      recorder: recorder,
      initialSectionIDs: [
        .featuredLinks: staleFeatured,
        .quickLinks: staleQuick,
      ]
    ) { request in
      if request.url?.query != nil {
        return try self.resourceLinkResponse(
          request: request,
          contentType: "application/json",
          data: JSONSerialization.data(
            withJSONObject: [
              staleFeatured: NSNull(),
              staleQuick: NSNull(),
            ]
          )
        )
      }
      return try self.resourceLinkResponse(
        request: request,
        contentType: "text/html",
        data: Data(currentDocument.utf8)
      )
    }

    let rails = try await client.rails(
      for: .product(handle: "verified-product")
    )

    XCTAssertEqual(rails.featured.map(\.label), ["New"])
    XCTAssertEqual(rails.quick.map(\.label), ["Body Care"])
    XCTAssertEqual(recorder.requests.count, 2)
    XCTAssertTrue(
      recorder.requests[0].url?.query?.contains(staleFeatured)
        == true
    )
    XCTAssertNil(recorder.requests[1].url?.query)
  }

  func testSuccessfulDiscoveryCachesCurrentIDsForNextRender()
    async throws
  {
    let recorder = ResourceLinkRailRequestRecorder()
    let currentPrefix = "template--current"
    let currentFeatured =
      "\(currentPrefix)__bot_product_featured_links"
    let currentQuick =
      "\(currentPrefix)__bot_product_quick_links"
    let document = resourceLinkDocument(prefix: currentPrefix)

    let client = makeResourceLinkClient(
      recorder: recorder
    ) { request in
      if request.url?.query != nil {
        let payload = try JSONSerialization.data(
          withJSONObject: [
            currentFeatured: """
            <nav data-bot-featured-links>
              <a href="/collections/new-arrivals">
                <span class="guidance-item-text">New</span>
              </a>
            </nav>
            """,
            currentQuick: """
            <nav data-bot-quick-links>
              <a href="/collections/body-care">Body Care</a>
            </nav>
            """,
          ]
        )
        return try self.resourceLinkResponse(
          request: request,
          contentType: "application/json",
          data: payload
        )
      }
      return try self.resourceLinkResponse(
        request: request,
        contentType: "text/html",
        data: Data(document.utf8)
      )
    }

    _ = try await client.rails(
      for: .product(handle: "verified-product")
    )
    _ = try await client.rails(
      for: .product(handle: "second-verified-product")
    )

    XCTAssertEqual(recorder.requests.count, 2)
    XCTAssertNil(recorder.requests[0].url?.query)
    XCTAssertTrue(
      recorder.requests[1].url?.query?.contains(currentFeatured)
        == true
    )
    XCTAssertTrue(
      recorder.requests[1].url?.query?.contains(currentQuick)
        == true
    )
  }

  func testCachedRailsRemainAvailableForImmediateRendering()
    async throws
  {
    let recorder = ResourceLinkRailRequestRecorder()
    let document = resourceLinkDocument(prefix: "template--current")
    let client = makeResourceLinkClient(recorder: recorder) { request in
      try self.resourceLinkResponse(
        request: request,
        contentType: "text/html",
        data: Data(document.utf8)
      )
    }
    let resource = ResourceLinkResource.collection(handle: "skincare")

    let loaded = try await client.rails(for: resource)
    let cached = await client.cachedRails(for: resource)

    XCTAssertEqual(cached, loaded)
    XCTAssertEqual(recorder.requests.count, 1)
  }

  func testLinkedCollectionResourcesAreDeduplicatedAndExcludeCurrent() {
    let current = ResourceLinkResource.collection(handle: "skincare")
    let baseURL = ShopifyAsset.shopRoot
    let skincare = ResourceLinkItem(
      id: "skincare",
      label: "Skincare",
      destinationURL: baseURL.appendingPathComponent("collections/skincare"),
      link: ThemeLink("/collections/skincare"),
      imageURL: nil,
      iconHint: nil,
      iconColorHex: nil,
      isCurrent: true
    )
    let cleansers = ResourceLinkItem(
      id: "cleansers",
      label: "Cleansers",
      destinationURL: baseURL.appendingPathComponent("collections/cleansers"),
      link: ThemeLink("/collections/cleansers"),
      imageURL: nil,
      iconHint: nil,
      iconColorHex: nil,
      isCurrent: false
    )
    let duplicateCleansers = ResourceLinkItem(
      id: "cleansers-duplicate",
      label: "Cleansers",
      destinationURL: baseURL.appendingPathComponent("collections/cleansers"),
      link: ThemeLink("/collections/cleansers"),
      imageURL: nil,
      iconHint: nil,
      iconColorHex: nil,
      isCurrent: false
    )
    let serums = ResourceLinkItem(
      id: "serums",
      label: "Serums",
      destinationURL: baseURL.appendingPathComponent("collections/serums"),
      link: ThemeLink("/collections/serums"),
      imageURL: nil,
      iconHint: nil,
      iconColorHex: nil,
      isCurrent: false
    )

    let rails = ResourceLinkRails(
      featured: [skincare, cleansers],
      quick: [duplicateCleansers, serums]
    )

    XCTAssertEqual(
      rails.linkedCollectionResources(excluding: current),
      [
        .collection(handle: "cleansers"),
        .collection(handle: "serums"),
      ]
    )
  }

  func testPrecompiledExpressionsRemainStableAcrossRepeatedParses() {
    let html = """
      <nav data-bot-featured-links>
        <a href="/collections/new-arrivals">
          <span class="guidance-item-text">New</span>
        </a>
      </nav>
      <nav data-bot-quick-links>
        <a href="/collections/serums">Serums</a>
      </nav>
      <div data-bot-context-breadcrumb="collection-quick-links">
        <nav aria-label="Breadcrumbs">
          <a href="/">Home</a>
          <span aria-current="page">Skincare</span>
        </nav>
      </div>
      """

    for _ in 0..<100 {
      XCTAssertEqual(
        ResourceLinkHTMLParser.parse(
          html: html,
          kind: .featured
        ).map(\.label),
        ["New"]
      )
      XCTAssertEqual(
        ResourceLinkHTMLParser.parse(
          html: html,
          kind: .quick
        ).map(\.label),
        ["Serums"]
      )
      XCTAssertEqual(
        ResourceBreadcrumbHTMLParser.parse(html: html).map(\.label),
        ["Home", "Skincare"]
      )
    }
  }

  @MainActor
  func testRailsViewHostsBothResourceDrivenRows() {
    let featured = ResourceLinkItem(
      id: "featured-0",
      label: "New",
      destinationURL: ShopifyAsset.shopRoot
        .appendingPathComponent("collections/new-arrivals"),
      link: ThemeLink("/collections/new-arrivals"),
      imageURL: nil,
      iconHint: "sparkle",
      iconColorHex: 0xFF3B5C,
      isCurrent: false
    )
    let quick = ResourceLinkItem(
      id: "quick-0",
      label: "Serums",
      destinationURL: ShopifyAsset.shopRoot
        .appendingPathComponent("collections/serums"),
      link: ThemeLink("/collections/serums"),
      imageURL: nil,
      iconHint: nil,
      iconColorHex: nil,
      isCurrent: true
    )
    let controller = UIHostingController(
      rootView: ResourceLinkRailsView(
        rails: ResourceLinkRails(
          featured: [featured],
          quick: [quick]
        ),
        open: { _, _ in }
      )
    )

    controller.loadViewIfNeeded()
    controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 120)
    controller.view.layoutIfNeeded()

    XCTAssertNotNil(controller.view)
    XCTAssertEqual(controller.view.bounds.width, 390)
    XCTAssertGreaterThan(controller.view.bounds.height, 0)
  }

  private func resourceLinkDocument(prefix: String) -> String {
    """
    <html><body>
      <div id="shopify-section-\(prefix)__bot_product_featured_links"
           class="shopify-section">
        <nav data-bot-featured-links>
          <a href="/collections/new-arrivals">
            <span class="guidance-item-text">New</span>
          </a>
        </nav>
      </div>
      <div id="shopify-section-\(prefix)__bot_product_quick_links"
           class="shopify-section">
        <nav data-bot-quick-links>
          <a href="/collections/body-care">Body Care</a>
        </nav>
        <div data-bot-context-breadcrumb="\(prefix)__bot_product_quick_links">
          <nav aria-label="Breadcrumbs">
            <a href="/">Home</a>
            <span aria-current="page">Verified Product</span>
          </nav>
        </div>
      </div>
      <section id="shopify-section-\(prefix)__main"
               class="shopify-section section-main-product">
        <section class="main-product-template"></section>
      </section>
    </body></html>
    """
  }

  private func makeResourceLinkClient(
    recorder: ResourceLinkRailRequestRecorder,
    initialSectionIDs: [StorefrontSectionPurpose: String] = [:],
    response:
      @escaping (URLRequest) throws
      -> (HTTPURLResponse, Data)
  ) -> ResourceLinkRailClient {
    ResourceLinkRailURLProtocol.response = { request in
      recorder.record(request)
      return try response(request)
    }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [
      ResourceLinkRailURLProtocol.self
    ]
    return ResourceLinkRailClient(
      session: URLSession(configuration: configuration),
      cacheLifetime: 5 * 60,
      initialSectionIDs: initialSectionIDs,
      previewThemeID: nil
    )
  }

  private func resourceLinkResponse(
    request: URLRequest,
    contentType: String,
    data: Data
  ) throws -> (HTTPURLResponse, Data) {
    let url = try XCTUnwrap(request.url)
    let response = HTTPURLResponse(
      url: url,
      statusCode: 200,
      httpVersion: "HTTP/1.1",
      headerFields: ["Content-Type": contentType]
    )!
    return (response, data)
  }
}

private final class ResourceLinkRailRequestRecorder:
  @unchecked Sendable
{
  private let lock = NSLock()
  private var storage: [URLRequest] = []

  var requests: [URLRequest] {
    lock.withLock { storage }
  }

  func record(_ request: URLRequest) {
    lock.withLock {
      storage.append(request)
    }
  }
}

private final class ResourceLinkRailURLProtocol: URLProtocol {
  nonisolated(unsafe) static var response: ((URLRequest) throws -> (HTTPURLResponse, Data))?

  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(
    for request: URLRequest
  ) -> URLRequest {
    request
  }

  override func startLoading() {
    do {
      let result = try XCTUnwrap(Self.response)(request)
      client?.urlProtocol(
        self,
        didReceive: result.0,
        cacheStoragePolicy: .notAllowed
      )
      client?.urlProtocol(self, didLoad: result.1)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}
}

@MainActor
final class LegacyWebCartMigratorTests: XCTestCase {
  func testNoRelevantStorefrontCookiesCompletesWithoutNetworkRequest()
    async throws
  {
    let dataStore = WKWebsiteDataStore.nonPersistent()
    try await setCookie(
      name: "cart",
      value: "unrelated-token",
      domain: ".unrelated.example",
      in: dataStore
    )
    let recorder = LegacyCartRequestRecorder()
    let session = makeSession(
      body: Data(#"{"items":[]}"#.utf8),
      recorder: recorder
    )
    let (defaults, suiteName) = try makeDefaults()
    defer {
      defaults.removePersistentDomain(forName: suiteName)
      LegacyCartURLProtocol.response = nil
    }
    let migrator = LegacyWebCartMigrator(
      dataStore: dataStore,
      defaults: defaults,
      session: session
    )

    let lines = try await migrator.fetchLines()

    XCTAssertTrue(lines.isEmpty)
    XCTAssertTrue(migrator.isComplete)
    XCTAssertTrue(recorder.requests.isEmpty)
  }

  func testRelevantStorefrontCookiePreservesRequestAndDecodeSemantics()
    async throws
  {
    let dataStore = WKWebsiteDataStore.nonPersistent()
    try await setCookie(
      name: "cart",
      value: "legacy-token",
      domain: ".beautyontapp.com",
      in: dataStore
    )
    let recorder = LegacyCartRequestRecorder()
    let session = makeSession(
      body: Data(
        """
        {
          "items": [
            {"variant_id": 101, "quantity": 2},
            {"variant_id": 0, "quantity": 4}
          ]
        }
        """.utf8
      ),
      recorder: recorder
    )
    let (defaults, suiteName) = try makeDefaults()
    defer {
      defaults.removePersistentDomain(forName: suiteName)
      LegacyCartURLProtocol.response = nil
    }
    let migrator = LegacyWebCartMigrator(
      dataStore: dataStore,
      defaults: defaults,
      session: session
    )

    let lines = try await migrator.fetchLines()

    XCTAssertEqual(lines.count, 1)
    XCTAssertEqual(
      lines.first?.merchandiseID,
      "gid://shopify/ProductVariant/101"
    )
    XCTAssertEqual(lines.first?.quantity, 2)
    XCTAssertFalse(migrator.isComplete)
    XCTAssertEqual(recorder.requests.count, 1)
    XCTAssertTrue(
      recorder.requests[0]
        .value(forHTTPHeaderField: "Cookie")?
        .contains("cart=legacy-token") == true
    )
  }

  private func makeDefaults() throws -> (UserDefaults, String) {
    let suiteName = "LegacyWebCartMigratorTests.\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)
    return (defaults, suiteName)
  }

  private func makeSession(
    body: Data,
    recorder: LegacyCartRequestRecorder
  ) -> URLSession {
    LegacyCartURLProtocol.response = { request in
      recorder.record(request)
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!
      return (response, body)
    }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [LegacyCartURLProtocol.self]
    return URLSession(configuration: configuration)
  }

  private func setCookie(
    name: String,
    value: String,
    domain: String,
    in dataStore: WKWebsiteDataStore
  ) async throws {
    let cookie = try XCTUnwrap(
      HTTPCookie(
        properties: [
          .domain: domain,
          .path: "/",
          .name: name,
          .value: value,
          .secure: "TRUE",
          .expires: Date().addingTimeInterval(3_600),
        ]
      )
    )
    await withCheckedContinuation { continuation in
      dataStore.httpCookieStore.setCookie(cookie) {
        continuation.resume()
      }
    }
  }
}

private final class LegacyCartRequestRecorder: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: [URLRequest] = []

  var requests: [URLRequest] {
    lock.withLock { storage }
  }

  func record(_ request: URLRequest) {
    lock.withLock {
      storage.append(request)
    }
  }
}

private final class LegacyCartURLProtocol: URLProtocol {
  nonisolated(unsafe) static var response: ((URLRequest) throws -> (HTTPURLResponse, Data))?

  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    do {
      let response = try XCTUnwrap(Self.response)(request)
      client?.urlProtocol(
        self,
        didReceive: response.0,
        cacheStoragePolicy: .notAllowed
      )
      client?.urlProtocol(self, didLoad: response.1)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}
}
