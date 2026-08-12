import Foundation

enum StorefrontSectionPurpose: String, CaseIterable, Hashable, Sendable {
  case mainProduct
  case featuredLinks
  case quickLinks
}

struct StorefrontResolvedSection: Equatable, Sendable {
  let id: String
  let html: String
}

enum StorefrontSectionResolverError: Error, Equatable {
  case invalidURL
  case invalidResponse
  case responseTooLarge
  case sectionNotFound
}

actor StorefrontSectionResolver {
  static let shared = StorefrontSectionResolver()
  static let documentRepresentationAcceptHeader = "text/html"

  private enum RouteKind: String, Hashable {
    case product
    case collection
  }

  private struct SectionCacheKey: Hashable {
    let pageURL: String
    let purpose: StorefrontSectionPurpose
  }

  private struct RouteSectionCacheKey: Hashable {
    let routeKind: RouteKind
    let purpose: StorefrontSectionPurpose
  }

  private struct DocumentCacheEntry {
    let html: String
    let storedAt: Date
  }

  private static let maximumSectionResponseBytes = 2_000_000
  private static let maximumDocumentResponseBytes = 4_000_000
  private static let documentCacheLifetime: TimeInterval = 15

  private let session: URLSession
  private let previewThemeID: String?
  private var knownSectionIDs: [SectionCacheKey: String] = [:]
  private var lastKnownSectionIDs: [RouteSectionCacheKey: String] = [:]
  private var initialSectionIDs: [StorefrontSectionPurpose: String]
  private var documentCache: [String: DocumentCacheEntry] = [:]
  private var inFlightDocuments: [String: Task<String, Error>] = [:]

  init(
    session: URLSession = StorefrontSectionResolver.makeSession(),
    initialSectionIDs: [StorefrontSectionPurpose: String] = [:],
    previewThemeID: String? = StorefrontThemeSource.activeDraftThemeID
  ) {
    self.session = session
    self.previewThemeID = previewThemeID
    self.initialSectionIDs = initialSectionIDs.filter {
      StorefrontSectionDocumentParser.isValidSectionID($0.value)
    }
  }

  func sections(
    for purposes: [StorefrontSectionPurpose],
    at pageURL: URL,
    forceRefresh: Bool = false
  ) async throws -> [StorefrontSectionPurpose: StorefrontResolvedSection] {
    try Task.checkCancellation()
    guard Self.isVerifiedPageURL(pageURL) else {
      throw StorefrontSectionResolverError.invalidURL
    }
    let effectivePageURL = StorefrontThemeSource.applyingDraftTheme(
      to: pageURL,
      themeID: previewThemeID
    )
    guard Self.isVerifiedPageURL(effectivePageURL),
      let routeKind = Self.routeKind(for: effectivePageURL)
    else {
      throw StorefrontSectionResolverError.invalidURL
    }

    var seenPurposes: Set<StorefrontSectionPurpose> = []
    let uniquePurposes = purposes.filter {
      seenPurposes.insert($0).inserted
    }
    guard !uniquePurposes.isEmpty else { return [:] }

    let pageKey = effectivePageURL.absoluteString
    let cachedIDs: [StorefrontSectionPurpose: String] = Dictionary(
      uniqueKeysWithValues: uniquePurposes.compactMap { purpose in
        let key = SectionCacheKey(pageURL: pageKey, purpose: purpose)
        guard
          let sectionID =
            knownSectionIDs[key]
            ?? lastKnownSectionIDs[
              RouteSectionCacheKey(
                routeKind: routeKind,
                purpose: purpose
              )
            ]
            ?? initialSectionIDs[purpose]
        else {
          return nil
        }
        return (purpose, sectionID)
      }
    )

    if cachedIDs.count == uniquePurposes.count {
      do {
        let rendered = try await renderedSections(
          at: effectivePageURL,
          sectionIDs: cachedIDs,
          forceRefresh: forceRefresh
        )
        if rendered.count == uniquePurposes.count {
          return rendered
        }
      } catch is CancellationError {
        throw CancellationError()
      } catch StorefrontSectionResolverError.responseTooLarge {
        throw StorefrontSectionResolverError.responseTooLarge
      } catch {
        // A cached Shopify section ID is only a hint. Theme publishes replace
        // the numeric template prefix, so a failed/null render must discover
        // the current page contract instead of hiding the rail.
      }

      for purpose in uniquePurposes {
        knownSectionIDs[
          SectionCacheKey(pageURL: pageKey, purpose: purpose)
        ] = nil
        lastKnownSectionIDs[
          RouteSectionCacheKey(
            routeKind: routeKind,
            purpose: purpose
          )
        ] = nil
        initialSectionIDs[purpose] = nil
      }
    }

    let document = try await documentHTML(
      at: effectivePageURL,
      forceRefresh: forceRefresh || !cachedIDs.isEmpty
    )
    try Task.checkCancellation()

    var resolved: [StorefrontSectionPurpose: StorefrontResolvedSection] = [:]
    for purpose in uniquePurposes {
      guard
        let section = StorefrontSectionDocumentParser.section(
          in: document,
          purpose: purpose
        )
      else {
        continue
      }
      knownSectionIDs[
        SectionCacheKey(pageURL: pageKey, purpose: purpose)
      ] = section.id
      lastKnownSectionIDs[
        RouteSectionCacheKey(
          routeKind: routeKind,
          purpose: purpose
        )
      ] = section.id
      resolved[purpose] = section
    }

    guard !resolved.isEmpty else {
      throw StorefrontSectionResolverError.sectionNotFound
    }
    return resolved
  }

  private func renderedSections(
    at pageURL: URL,
    sectionIDs: [StorefrontSectionPurpose: String],
    forceRefresh: Bool
  ) async throws
    -> [StorefrontSectionPurpose: StorefrontResolvedSection]
  {
    let requestedIDs = sectionIDs.values.sorted()
    let url = try Self.sectionRenderingURL(
      pageURL: pageURL,
      sectionIDs: requestedIDs
    )
    var request = URLRequest(
      url: url,
      cachePolicy: forceRefresh
        ? .reloadIgnoringLocalCacheData
        : .useProtocolCachePolicy,
      timeoutInterval: 15
    )
    request.setValue(
      Self.documentRepresentationAcceptHeader,
      forHTTPHeaderField: "Accept"
    )

    let (data, response) = try await session.data(for: request)
    try Task.checkCancellation()
    try Self.validate(
      response: response,
      requestURL: url,
      expectedMIMEType: "application/json"
    )
    guard !data.isEmpty else {
      throw StorefrontSectionResolverError.invalidResponse
    }
    guard data.count <= Self.maximumSectionResponseBytes else {
      throw StorefrontSectionResolverError.responseTooLarge
    }
    guard
      let envelope = try JSONSerialization.jsonObject(with: data)
        as? [String: Any],
      !envelope.isEmpty,
      envelope.count <= 16
    else {
      throw StorefrontSectionResolverError.invalidResponse
    }

    var resolved: [StorefrontSectionPurpose: StorefrontResolvedSection] = [:]
    for (purpose, sectionID) in sectionIDs {
      guard let html = envelope[sectionID] as? String,
        !html.isEmpty,
        html.utf8.count <= 1_500_000
      else {
        continue
      }
      resolved[purpose] = StorefrontResolvedSection(
        id: sectionID,
        html: html
      )
    }
    return resolved
  }

  private func documentHTML(
    at pageURL: URL,
    forceRefresh: Bool
  ) async throws -> String {
    let pageKey = pageURL.absoluteString
    if !forceRefresh,
      let cached = documentCache[pageKey],
      Date().timeIntervalSince(cached.storedAt)
        <= Self.documentCacheLifetime
    {
      return cached.html
    }
    if let inFlight = inFlightDocuments[pageKey] {
      let html = try await inFlight.value
      try Task.checkCancellation()
      return html
    }

    let session = self.session
    let task = Task<String, Error> {
      var request = URLRequest(
        url: pageURL,
        cachePolicy: forceRefresh
          ? .reloadIgnoringLocalCacheData
          : .useProtocolCachePolicy,
        timeoutInterval: 15
      )
      request.setValue(
        Self.documentRepresentationAcceptHeader,
        forHTTPHeaderField: "Accept"
      )
      let (data, response) = try await session.data(for: request)
      try Task.checkCancellation()
      try Self.validate(
        response: response,
        requestURL: pageURL,
        expectedMIMEType: "text/html"
      )
      guard !data.isEmpty else {
        throw StorefrontSectionResolverError.invalidResponse
      }
      guard data.count <= Self.maximumDocumentResponseBytes else {
        throw StorefrontSectionResolverError.responseTooLarge
      }
      guard let html = String(data: data, encoding: .utf8), !html.isEmpty
      else {
        throw StorefrontSectionResolverError.invalidResponse
      }
      return html
    }
    inFlightDocuments[pageKey] = task

    do {
      let html = try await task.value
      inFlightDocuments[pageKey] = nil
      documentCache[pageKey] = DocumentCacheEntry(
        html: html,
        storedAt: Date()
      )
      try Task.checkCancellation()
      return html
    } catch {
      inFlightDocuments[pageKey] = nil
      throw error
    }
  }

  static func sectionRenderingURL(
    pageURL: URL,
    sectionIDs: [String]
  ) throws -> URL {
    guard isVerifiedPageURL(pageURL),
      !sectionIDs.isEmpty,
      sectionIDs.count <= 16,
      sectionIDs.allSatisfy(
        StorefrontSectionDocumentParser.isValidSectionID
      )
    else {
      throw StorefrontSectionResolverError.invalidURL
    }

    var components = URLComponents(
      url: pageURL,
      resolvingAgainstBaseURL: false
    )
    var queryItems = components?.queryItems ?? []
    queryItems.removeAll { $0.name == "sections" }
    queryItems.append(
      URLQueryItem(
        name: "sections",
        value: sectionIDs.joined(separator: ",")
      )
    )
    components?.queryItems = queryItems
    guard let url = components?.url, isVerifiedPageURL(url) else {
      throw StorefrontSectionResolverError.invalidURL
    }
    return url
  }

  private static func isVerifiedPageURL(_ url: URL) -> Bool {
    ShopifyAsset.isPrimaryStorefrontURL(url)
      && url.user == nil
      && url.password == nil
      && (url.port == nil || url.port == 443)
  }

  private static func routeKind(for url: URL) -> RouteKind? {
    let components = url.pathComponents.filter { $0 != "/" }
    guard components.count == 2 else { return nil }
    switch components[0].lowercased() {
    case "products":
      return .product
    case "collections":
      return .collection
    default:
      return nil
    }
  }

  private static func validate(
    response: URLResponse,
    requestURL: URL,
    expectedMIMEType: String
  ) throws {
    guard
      let response = response as? HTTPURLResponse,
      (200..<300).contains(response.statusCode),
      let responseURL = response.url,
      isVerifiedPageURL(responseURL),
      responseURL.host?.lowercased()
        == requestURL.host?.lowercased(),
      response.mimeType?.lowercased() == expectedMIMEType
    else {
      throw StorefrontSectionResolverError.invalidResponse
    }
  }

  private static func makeSession() -> URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = URLCache(
      memoryCapacity: 6 * 1_024 * 1_024,
      diskCapacity: 30 * 1_024 * 1_024,
      diskPath: "com.beautyontapp.storefront-sections"
    )
    configuration.requestCachePolicy = .useProtocolCachePolicy
    configuration.timeoutIntervalForRequest = 15
    configuration.timeoutIntervalForResource = 20
    configuration.waitsForConnectivity = true
    return URLSession(configuration: configuration)
  }
}

enum StorefrontSectionDocumentParser {
  private static let wrapperExpression = try? NSRegularExpression(
    pattern:
      #"(?is)<(?:section|div)\b(?=[^>]*\bid\s*=\s*["']shopify-section-([^"']+)["'])[^>]*>"#
  )

  static func section(
    in document: String,
    purpose: StorefrontSectionPurpose
  ) -> StorefrontResolvedSection? {
    guard document.utf8.count <= 4_000_000,
      let wrapperExpression
    else {
      return nil
    }
    let fullRange = NSRange(
      document.startIndex..<document.endIndex,
      in: document
    )
    let matches = wrapperExpression.matches(
      in: document,
      range: fullRange
    )

    for (index, match) in matches.enumerated() {
      guard let openingRange = Range(match.range, in: document),
        let idRange = Range(match.range(at: 1), in: document)
      else {
        continue
      }
      let sectionID = String(document[idRange])
      guard isValidSectionID(sectionID) else { continue }

      let upperBound: String.Index
      if index + 1 < matches.count,
        let nextRange = Range(matches[index + 1].range, in: document)
      {
        upperBound = nextRange.lowerBound
      } else {
        upperBound = document.endIndex
      }
      let html = String(document[openingRange.lowerBound..<upperBound])
      guard html.utf8.count <= 1_500_000,
        matchesPurpose(
          purpose,
          sectionID: sectionID,
          openingHTML: String(document[openingRange]),
          sectionHTML: html
        )
      else {
        continue
      }
      return StorefrontResolvedSection(id: sectionID, html: html)
    }
    return nil
  }

  static func isValidSectionID(_ sectionID: String) -> Bool {
    guard !sectionID.isEmpty, sectionID.count <= 255 else {
      return false
    }
    return sectionID.unicodeScalars.allSatisfy { scalar in
      CharacterSet.alphanumerics.contains(scalar)
        || scalar == "-"
        || scalar == "_"
    }
  }

  private static func matchesPurpose(
    _ purpose: StorefrontSectionPurpose,
    sectionID: String,
    openingHTML: String,
    sectionHTML: String
  ) -> Bool {
    let id = sectionID.lowercased()
    let opening = openingHTML.lowercased()
    let html = sectionHTML.lowercased()

    switch purpose {
    case .mainProduct:
      return opening.contains("section-main-product")
        || (id.hasSuffix("__main")
          && html.contains("main-product-template"))
    case .featuredLinks:
      return html.contains("data-bot-featured-links")
        || id.contains("__bot_product_featured_links")
        || id.contains("__bot_featured_links_universal")
    case .quickLinks:
      return html.contains("data-bot-quick-links")
        || id.contains("__bot_product_quick_links")
        || id.contains("__bot_quick_links_universal")
    }
  }
}

struct ProductReviewSummary: Equatable, Hashable, Sendable {
  let averageRating: Double
  let reviewCount: Int
}

struct ProductInstallmentSummary: Equatable, Sendable {
  let priceText: String
  let paymentText: String
  let walletHeading: String?
}

struct ProductDeliveryEstimate: Equatable, Sendable {
  let eyebrow: String
  let heading: String
  let message: String

  static let nonVolatileFallback = ProductDeliveryEstimate(
    eyebrow: "Estimated delivery",
    heading: "Your glow, on the way",
    message: "Final options shown at checkout."
  )
}

enum ProductWalletNativeMark: String, Equatable, Sendable {
  case applePay
  case googlePay
}

struct ProductWalletProviderInformation: Equatable, Sendable {
  let modalTitle: String?
  let logoURL: URL?
  let heading: String?
  let subheading: String?
  let steps: [String]
  let caption: String?
  let ctaLabel: String?
  let ctaURL: URL?

  var isRenderable: Bool {
    logoURL != nil
      || heading != nil
      || subheading != nil
      || !steps.isEmpty
      || caption != nil
      || (ctaLabel != nil && ctaURL != nil)
  }
}

struct ProductWalletProvider: Identifiable, Equatable, Sendable {
  let id: String
  let accessibilityLabel: String
  let imageURL: URL?
  let nativeMark: ProductWalletNativeMark?
  let information: ProductWalletProviderInformation?

  var isInteractive: Bool {
    information?.isRenderable == true
  }
}

struct ProductPresentation: Equatable, Sendable {
  let reviewSummary: ProductReviewSummary?
  let installmentSummary: ProductInstallmentSummary?
  let walletProviders: [ProductWalletProvider]
  let deliveryEstimate: ProductDeliveryEstimate?

  static let empty = ProductPresentation(
    reviewSummary: nil,
    installmentSummary: nil,
    walletProviders: [],
    deliveryEstimate: nil
  )

  var isEmpty: Bool {
    reviewSummary == nil
      && installmentSummary == nil
      && walletProviders.isEmpty
      && deliveryEstimate == nil
  }
}

enum ProductPresentationSourceError: Error, Equatable {
  case invalidProductHandle
  case invalidResponse
  case responseTooLarge
}

protocol ProductPresentationProviding: Sendable {
  func presentation(
    forProductHandle handle: String,
    forceRefresh: Bool
  ) async throws -> ProductPresentation
}

extension ProductPresentationProviding {
  func presentation(
    forProductHandle handle: String
  ) async throws -> ProductPresentation {
    try await presentation(
      forProductHandle: handle,
      forceRefresh: false
    )
  }
}

actor ProductPresentationSource: ProductPresentationProviding {
  static let shared = ProductPresentationSource(
    sectionResolver: .shared
  )

  private struct CacheEntry {
    let presentation: ProductPresentation
    let storedAt: Date
  }

  private let sectionResolver: StorefrontSectionResolver
  private let cacheLifetime: TimeInterval
  private let cacheCapacity: Int
  private var cache: [String: CacheEntry] = [:]

  init(
    session: URLSession? = nil,
    cacheLifetime: TimeInterval = 5 * 60,
    cacheCapacity: Int = 24,
    sectionResolver: StorefrontSectionResolver? = nil,
    initialSectionID: String? = nil,
    previewThemeID: String? = StorefrontThemeSource.activeDraftThemeID
  ) {
    if let sectionResolver {
      self.sectionResolver = sectionResolver
    } else {
      self.sectionResolver = StorefrontSectionResolver(
        session: session ?? ProductPresentationSource.makeSession(),
        initialSectionIDs: initialSectionID.map {
          [.mainProduct: $0]
        } ?? [:],
        previewThemeID: previewThemeID
      )
    }
    self.cacheLifetime = max(0, cacheLifetime)
    self.cacheCapacity = max(1, cacheCapacity)
  }

  func presentation(
    forProductHandle handle: String,
    forceRefresh: Bool = false
  ) async throws -> ProductPresentation {
    try Task.checkCancellation()

    guard Self.isValidHandle(handle) else {
      throw ProductPresentationSourceError.invalidProductHandle
    }

    if !forceRefresh,
      let cached = cache[handle],
      Date().timeIntervalSince(cached.storedAt) <= cacheLifetime
    {
      return cached.presentation
    }

    let pageURL = try Self.pageURL(forProductHandle: handle)
    let resolved: StorefrontResolvedSection
    do {
      guard
        let section = try await sectionResolver.sections(
          for: [.mainProduct],
          at: pageURL,
          forceRefresh: forceRefresh
        )[.mainProduct]
      else {
        throw ProductPresentationSourceError.invalidResponse
      }
      resolved = section
    } catch is CancellationError {
      throw CancellationError()
    } catch StorefrontSectionResolverError.responseTooLarge {
      throw ProductPresentationSourceError.responseTooLarge
    } catch {
      throw ProductPresentationSourceError.invalidResponse
    }

    let decoded = try ProductPresentationSectionDecoder.decode(
      html: resolved.html
    )
    try Task.checkCancellation()

    cache[handle] = CacheEntry(
      presentation: decoded,
      storedAt: Date()
    )
    trimCacheIfNeeded()
    return decoded
  }

  static func pageURL(
    forProductHandle handle: String
  ) throws -> URL {
    guard isValidHandle(handle) else {
      throw ProductPresentationSourceError.invalidProductHandle
    }

    var url = ShopifyAsset.shopRoot
    url.appendPathComponent("products")
    url.appendPathComponent(handle)

    guard ShopifyAsset.isPrimaryStorefrontURL(url),
      url.user == nil,
      url.password == nil,
      url.port == nil || url.port == 443
    else {
      throw ProductPresentationSourceError.invalidProductHandle
    }
    return url
  }

  private static func isValidHandle(_ handle: String) -> Bool {
    guard !handle.isEmpty,
      handle.count <= 255
    else {
      return false
    }

    return handle.unicodeScalars.allSatisfy { scalar in
      CharacterSet.alphanumerics.contains(scalar)
        || scalar == "-"
    }
  }

  private static func makeSession() -> URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = URLCache(
      memoryCapacity: 4 * 1_024 * 1_024,
      diskCapacity: 24 * 1_024 * 1_024,
      diskPath: "com.beautyontapp.product-presentation"
    )
    configuration.requestCachePolicy = .useProtocolCachePolicy
    configuration.timeoutIntervalForRequest = 15
    configuration.timeoutIntervalForResource = 20
    configuration.waitsForConnectivity = true
    return URLSession(configuration: configuration)
  }

  private func trimCacheIfNeeded() {
    guard cache.count > cacheCapacity else { return }

    let overflow = cache.count - cacheCapacity
    let oldestHandles =
      cache
      .sorted { $0.value.storedAt < $1.value.storedAt }
      .prefix(overflow)
      .map(\.key)

    for handle in oldestHandles {
      cache[handle] = nil
    }
  }
}

enum ProductPresentationSectionDecoder {
  private static let maximumHTMLBytes = 1_500_000

  static func decode(html: String) throws -> ProductPresentation {
    guard !html.isEmpty, html.utf8.count <= maximumHTMLBytes else {
      throw ProductPresentationSourceError.invalidResponse
    }
    return ProductPresentationHTMLParser.parse(html: html)
  }

  static func decode(
    data: Data,
    sectionID: String
  ) throws -> ProductPresentation {
    guard StorefrontSectionDocumentParser.isValidSectionID(sectionID),
      let response = try JSONSerialization.jsonObject(with: data)
        as? [String: Any],
      !response.isEmpty,
      response.count <= 16,
      let html = response[sectionID] as? String
    else {
      throw ProductPresentationSourceError.invalidResponse
    }
    return try decode(html: html)
  }
}

private enum ProductPresentationExpressions {
  static let attribute = make(
    #"(?is)([A-Za-z_:][-A-Za-z0-9_:.]*)\s*(?:=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+)))?"#
  )
  static let judgeMeBadge = make(
    #"(?is)<(?:div|span)\b(?=[^>]*\bjdgm-prev-badge\b)([^>]*)>"#
  )
  static let installmentOpen = make(
    #"(?is)<div\b(?=[^>]*\bcustom-product-tap-main\b)([^>]*)>"#
  )
  static let modalOpen = make(
    #"(?is)<div\b(?=[^>]*\bcstm-tap-modal\b)([^>]*)>"#
  )
  static let modalTitle = make(
    #"(?is)<span\b([^>]*)>(.*?)</span\s*>"#
  )
  static let panelOpen = make(
    #"(?is)<div\b(?=[^>]*\bcstm-tap-panel\b)([^>]*)>"#
  )
  static let panelIcon = make(
    #"(?is)<div\b([^>]*)>(.*?)</div\s*>"#
  )
  static let heading3 = make(
    #"(?is)<h3\b[^>]*>(.*?)</h3\s*>"#
  )
  static let panelSubheading = make(
    #"(?is)<div\b([^>]*)>(.*?)</div\s*>"#
  )
  static let orderedList = make(
    #"(?is)<ol\b[^>]*>(.*?)</ol\s*>"#
  )
  static let listItem = make(
    #"(?is)<li\b[^>]*>(.*?)</li\s*>"#
  )
  static let small = make(
    #"(?is)<small\b[^>]*>(.*?)</small\s*>"#
  )
  static let learnLink = make(
    #"(?is)<a\b([^>]*)>(.*?)</a\s*>"#
  )
  static let deliveryEstimate = make(
    #"(?is)<aside\b([^>]*)>(.*?)</aside\s*>"#
  )
  static let deliveryEyebrow = make(
    #"(?is)<span\b(?=[^>]*\bbot-delivery-estimate__eyebrow\b)([^>]*)>(.*?)</span\s*>"#
  )
  static let deliveryHeading = make(
    #"(?is)<strong\b(?=[^>]*\bbot-delivery-estimate__heading\b)([^>]*)>(.*?)</strong\s*>"#
  )
  static let deliveryText = make(
    #"(?is)<span\b(?=[^>]*\bbot-delivery-estimate__text\b)([^>]*)>(.*?)</span\s*>"#
  )
  static let divToken = make(
    #"(?is)<div\b[^>]*>|</div\s*>"#
  )
  static let strong = make(
    #"(?is)<strong\b[^>]*>(.*?)</strong\s*>"#
  )
  static let paymentText = make(
    #"(?is)<(?:span|div)\b(?=[^>]*\bproduct-custom-tap-highlight\b)([^>]*)>(.*?)</(?:span|div)\s*>"#
  )
  static let walletHeading = make(
    #"(?is)<(?:span|div)\b(?=[^>]*\bcstm-tap-wallet-label\b)([^>]*)>(.*?)</(?:span|div)\s*>"#
  )
  static let walletBadgeOpen = make(
    #"(?is)<(button|span)\b(?=[^>]*\bcstm-tap-wallet-badge\b)([^>]*)>"#
  )
  static let buttonClose = make(#"(?is)</button\s*>"#)
  static let spanClose = make(#"(?is)</span\s*>"#)
  static let image = make(#"(?is)<img\b([^>]*)>"#)
  static let svg = make(#"(?is)<svg\b[^>]*>(.*?)</svg\s*>"#)
  static let title = make(#"(?is)<title\b[^>]*>(.*?)</title\s*>"#)
  static let commentsScriptsStyles = make(
    #"(?is)<!--.*?-->|<(?:script|style)\b[^>]*>.*?</(?:script|style)\s*>"#
  )
  static let tags = make(#"(?is)<[^>]+>"#)
  static let whitespace = make(#"\s+"#)

  private static func make(_ pattern: String) -> NSRegularExpression? {
    try? NSRegularExpression(pattern: pattern)
  }
}

enum ProductPresentationHTMLParser {
  private static let maximumHTMLBytes = 1_500_000
  private static let maximumInstallmentBytes = 256_000
  private static let maximumWalletCandidates = 24
  private static let maximumWalletProviders = 8
  private static let maximumLabelLength = 120
  private static let maximumSummaryLength = 180
  private static let maximumPanelTextLength = 600
  private static let maximumStepLength = 240
  private static let maximumSteps = 8
  private static let maximumModalBytes = 256_000
  private static let maximumPanelBytes = 128_000
  private static let maximumReviewCount = 10_000_000

  static func parse(html: String) -> ProductPresentation {
    guard html.utf8.count <= maximumHTMLBytes else {
      return .empty
    }

    let installmentHTML = installmentBody(in: html)
    let providerInformation = providerInformationByTarget(in: html)
    return ProductPresentation(
      reviewSummary: reviewSummary(in: html),
      installmentSummary: installmentHTML.flatMap {
        installmentSummary(in: $0)
      },
      walletProviders: installmentHTML.map {
        walletProviders(
          in: $0,
          providerInformation: providerInformation
        )
      } ?? [],
      deliveryEstimate: deliveryEstimate(in: html)
    )
  }

  static func verifiedImageURL(_ source: String) -> URL? {
    let decoded = decodeHTMLEntities(source)
      .trimmingCharacters(in: .whitespacesAndNewlines)

    guard !decoded.isEmpty,
      !decoded.contains("\\"),
      decoded.unicodeScalars.allSatisfy({
        !CharacterSet.controlCharacters.contains($0)
      })
    else {
      return nil
    }

    let url: URL
    if decoded.hasPrefix("//") {
      guard let resolved = URL(string: "https:\(decoded)") else {
        return nil
      }
      url = resolved
    } else if decoded.hasPrefix("/") {
      guard !decoded.hasPrefix("//"),
        let resolved = URL(
          string: decoded,
          relativeTo: ShopifyAsset.shopRoot
        )?.absoluteURL
      else {
        return nil
      }
      url = resolved
    } else {
      guard let resolved = URL(string: decoded) else {
        return nil
      }
      url = resolved
    }

    guard ShopifyAsset.isPrimaryStorefrontURL(url),
      url.user == nil,
      url.password == nil,
      url.port == nil || url.port == 443,
      url.host?.lowercased()
        == ShopifyAsset.shopRoot.host?.lowercased()
    else {
      return nil
    }

    return url
  }

  static func verifiedExternalHTTPSURL(_ source: String) -> URL? {
    let decoded = decodeHTMLEntities(source)
      .trimmingCharacters(in: .whitespacesAndNewlines)

    guard !decoded.isEmpty,
      !decoded.contains("\\"),
      decoded.unicodeScalars.allSatisfy({
        !CharacterSet.controlCharacters.contains($0)
      }),
      let url = URL(string: decoded),
      url.scheme?.lowercased() == "https",
      let host = url.host?.lowercased(),
      !host.isEmpty,
      host.contains("."),
      url.user == nil,
      url.password == nil,
      url.port == nil || url.port == 443
    else {
      return nil
    }

    return url
  }

  private static func reviewSummary(
    in html: String
  ) -> ProductReviewSummary? {
    guard let expression = ProductPresentationExpressions.judgeMeBadge else {
      return nil
    }

    for match in expression.matches(
      in: html,
      range: fullRange(of: html)
    ).prefix(4_096) {
      guard
        let attributesRange = Range(match.range(at: 1), in: html)
      else {
        continue
      }

      let attributes = parseAttributes(String(html[attributesRange]))
      guard hasClass("jdgm-prev-badge", attributes: attributes) else {
        continue
      }
      guard
        let averageSource = attributes["data-average-rating"],
        let countSource = attributes["data-number-of-reviews"],
        let average = Double(averageSource),
        average.isFinite,
        (0...5).contains(average),
        let count = Int(countSource),
        (0...maximumReviewCount).contains(count)
      else {
        return nil
      }

      return ProductReviewSummary(
        averageRating: average,
        reviewCount: count
      )
    }

    return nil
  }

  private static func installmentBody(in html: String) -> String? {
    guard
      let openingExpression =
        ProductPresentationExpressions.installmentOpen,
      let tokenExpression = ProductPresentationExpressions.divToken
    else {
      return nil
    }

    let openingRange = openingExpression.matches(
      in: html,
      range: fullRange(of: html)
    ).prefix(4_096).compactMap { match -> Range<String.Index>? in
      guard
        let attributesRange = Range(match.range(at: 1), in: html),
        let openingRange = Range(match.range, in: html)
      else {
        return nil
      }

      let attributes = parseAttributes(String(html[attributesRange]))
      return hasClass(
        "custom-product-tap-main",
        attributes: attributes
      )
        ? openingRange
        : nil
    }.first

    guard let openingRange else {
      return nil
    }

    let remainingRange = NSRange(
      openingRange.upperBound..<html.endIndex,
      in: html
    )
    var depth = 1

    for token in tokenExpression.matches(
      in: html,
      range: remainingRange
    ) {
      guard let tokenRange = Range(token.range, in: html) else {
        continue
      }

      if html[tokenRange].hasPrefix("</") {
        depth -= 1
        if depth == 0 {
          let body = String(
            html[openingRange.upperBound..<tokenRange.lowerBound]
          )
          return body.utf8.count <= maximumInstallmentBytes
            ? body
            : nil
        }
      } else {
        depth += 1
      }
    }

    return nil
  }

  private static func installmentSummary(
    in html: String
  ) -> ProductInstallmentSummary? {
    guard
      let priceText = firstNormalizedCapture(
        expression: ProductPresentationExpressions.strong,
        bodyGroup: 1,
        in: html
      ),
      priceText.count <= maximumSummaryLength,
      let paymentText = firstNormalizedClassCapture(
        expression: ProductPresentationExpressions.paymentText,
        classToken: "product-custom-tap-highlight",
        attributesGroup: 1,
        bodyGroup: 2,
        in: html
      ),
      paymentText.count <= maximumSummaryLength
    else {
      return nil
    }

    let walletHeading = firstNormalizedClassCapture(
      expression: ProductPresentationExpressions.walletHeading,
      classToken: "cstm-tap-wallet-label",
      attributesGroup: 1,
      bodyGroup: 2,
      in: html
    ).flatMap { heading in
      heading.count <= maximumSummaryLength ? heading : nil
    }

    return ProductInstallmentSummary(
      priceText: priceText,
      paymentText: paymentText,
      walletHeading: walletHeading
    )
  }

  private static func deliveryEstimate(
    in html: String
  ) -> ProductDeliveryEstimate? {
    guard
      let expression = ProductPresentationExpressions.deliveryEstimate
    else {
      return nil
    }

    for match in expression.matches(
      in: html,
      range: fullRange(of: html)
    ).prefix(128) {
      guard
        let attributesRange = Range(match.range(at: 1), in: html),
        let bodyRange = Range(match.range(at: 2), in: html)
      else {
        continue
      }

      let attributes = parseAttributes(String(html[attributesRange]))
      let body = String(html[bodyRange])
      guard hasClass(
        "bot-delivery-estimate",
        attributes: attributes
      ),
        body.utf8.count <= maximumPanelBytes,
        let eyebrow = firstNormalizedClassCapture(
          expression:
            ProductPresentationExpressions.deliveryEyebrow,
          classToken: "bot-delivery-estimate__eyebrow",
          attributesGroup: 1,
          bodyGroup: 2,
          in: body
        ),
        eyebrow.count <= maximumSummaryLength,
        let heading = firstNormalizedClassCapture(
          expression:
            ProductPresentationExpressions.deliveryHeading,
          classToken: "bot-delivery-estimate__heading",
          attributesGroup: 1,
          bodyGroup: 2,
          in: body
        ),
        heading.count <= maximumSummaryLength,
        let message = firstNormalizedClassCapture(
          expression: ProductPresentationExpressions.deliveryText,
          classToken: "bot-delivery-estimate__text",
          attributesGroup: 1,
          bodyGroup: 2,
          in: body
        ),
        message.count <= maximumPanelTextLength
      else {
        continue
      }

      return ProductDeliveryEstimate(
        eyebrow: eyebrow,
        heading: heading,
        message: message
      )
    }

    return nil
  }

  private static func walletProviders(
    in html: String,
    providerInformation: [String: ProductWalletProviderInformation]
  ) -> [ProductWalletProvider] {
    guard
      let expression = ProductPresentationExpressions.walletBadgeOpen
    else {
      return []
    }

    let matches = expression.matches(
      in: html,
      range: fullRange(of: html)
    )

    var providers: [ProductWalletProvider] = []
    var seenLabels: Set<String> = []

    for (offset, match) in matches.prefix(maximumWalletCandidates)
      .enumerated()
    {
      guard providers.count < maximumWalletProviders,
        let tagRange = Range(match.range(at: 1), in: html),
        let attributesRange = Range(match.range(at: 2), in: html),
        let openingRange = Range(match.range, in: html)
      else {
        break
      }

      let attributes = parseAttributes(String(html[attributesRange]))
      guard
        hasClass(
          "cstm-tap-wallet-badge",
          attributes: attributes
        )
      else {
        continue
      }
      guard
        let labelSource = attributes["aria-label"],
        let label = normalizedText(labelSource),
        !label.isEmpty,
        label.count <= maximumLabelLength
      else {
        continue
      }

      let normalizedLabelKey = label.lowercased()
      guard seenLabels.insert(normalizedLabelKey).inserted else {
        continue
      }

      let tagName = html[tagRange].lowercased()
      let closingExpression =
        tagName == "button"
        ? ProductPresentationExpressions.buttonClose
        : ProductPresentationExpressions.spanClose
      let itemBody = closingExpression.flatMap { closing in
        firstBody(
          after: openingRange.upperBound,
          in: html,
          closingExpression: closing
        )
      }
      let imageURL = itemBody.flatMap(imageURL(in:))
      let nativeMark =
        imageURL == nil
        ? itemBody.flatMap {
          nativeWalletMark(in: $0, accessibilityLabel: label)
        }
        : nil
      let interactionTarget = attributes["data-tap-target"]
        .flatMap(validPanelTarget)
      let information = interactionTarget.flatMap {
        providerInformation[$0]
      }

      providers.append(
        ProductWalletProvider(
          id: [
            String(offset),
            normalizedLabelKey,
            imageURL?.absoluteString ?? "no-image",
            nativeMark?.rawValue ?? "no-native-mark",
          ].joined(separator: "|"),
          accessibilityLabel: label,
          imageURL: imageURL,
          nativeMark: nativeMark,
          information: information
        )
      )
    }

    return providers
  }

  private static func providerInformationByTarget(
    in html: String
  ) -> [String: ProductWalletProviderInformation] {
    guard let modalHTML = modalBody(in: html) else {
      return [:]
    }

    let modalTitle = sourcedModalTitle(in: modalHTML)
    guard
      let panelExpression = ProductPresentationExpressions.panelOpen
    else {
      return [:]
    }

    var information: [String: ProductWalletProviderInformation] = [:]
    var ambiguousTargets: Set<String> = []

    for match in panelExpression.matches(
      in: modalHTML,
      range: fullRange(of: modalHTML)
    ).prefix(maximumWalletCandidates) {
      guard
        let attributesRange = Range(match.range(at: 1), in: modalHTML),
        let openingRange = Range(match.range, in: modalHTML)
      else {
        continue
      }

      let attributes = parseAttributes(
        String(modalHTML[attributesRange])
      )
      guard hasClass("cstm-tap-panel", attributes: attributes),
        attributes["role"]?.lowercased() == "tabpanel",
        let panelID = attributes["id"],
        panelID.hasPrefix("cstm-tap-panel-"),
        let target = validPanelTarget(
          String(panelID.dropFirst("cstm-tap-panel-".count))
        ),
        let panelHTML = balancedDivBody(
          after: openingRange.upperBound,
          in: modalHTML,
          maximumBytes: maximumPanelBytes
        )
      else {
        continue
      }

      guard
        let parsed = providerInformation(
          in: panelHTML,
          modalTitle: modalTitle
        ),
        parsed.isRenderable
      else {
        continue
      }

      if information[target] != nil {
        information[target] = nil
        ambiguousTargets.insert(target)
      } else if !ambiguousTargets.contains(target) {
        information[target] = parsed
      }
    }

    return information
  }

  private static func modalBody(in html: String) -> String? {
    guard let expression = ProductPresentationExpressions.modalOpen else {
      return nil
    }

    for match in expression.matches(
      in: html,
      range: fullRange(of: html)
    ).prefix(32) {
      guard
        let attributesRange = Range(match.range(at: 1), in: html),
        let openingRange = Range(match.range, in: html)
      else {
        continue
      }
      let attributes = parseAttributes(String(html[attributesRange]))
      guard hasClass("cstm-tap-modal", attributes: attributes),
        attributes["id"] == "cstmTapModal",
        attributes["role"]?.lowercased() == "dialog"
      else {
        continue
      }
      return balancedDivBody(
        after: openingRange.upperBound,
        in: html,
        maximumBytes: maximumModalBytes
      )
    }

    return nil
  }

  private static func sourcedModalTitle(in html: String) -> String? {
    guard let expression = ProductPresentationExpressions.modalTitle else {
      return nil
    }

    for match in expression.matches(
      in: html,
      range: fullRange(of: html)
    ).prefix(128) {
      guard
        let attributesRange = Range(match.range(at: 1), in: html),
        let bodyRange = Range(match.range(at: 2), in: html)
      else {
        continue
      }
      let attributes = parseAttributes(String(html[attributesRange]))
      guard attributes["id"] == "cstmTapModalTitle",
        hasClass("cstm-tap-modal-title", attributes: attributes),
        let title = normalizedText(String(html[bodyRange])),
        title.count <= maximumLabelLength
      else {
        continue
      }
      return title
    }

    return nil
  }

  private static func providerInformation(
    in html: String,
    modalTitle: String?
  ) -> ProductWalletProviderInformation? {
    let logoURL = firstClassBody(
      expression: ProductPresentationExpressions.panelIcon,
      classToken: "cstm-tap-panel-icon",
      attributesGroup: 1,
      bodyGroup: 2,
      in: html
    ).flatMap(imageURL(in:))

    let heading = firstNormalizedCapture(
      expression: ProductPresentationExpressions.heading3,
      bodyGroup: 1,
      in: html
    ).flatMap {
      $0.count <= maximumSummaryLength ? $0 : nil
    }

    let subheading = firstNormalizedClassCapture(
      expression: ProductPresentationExpressions.panelSubheading,
      classToken: "cstm-tap-panel-subheading",
      attributesGroup: 1,
      bodyGroup: 2,
      in: html
    ).flatMap {
      $0.count <= maximumPanelTextLength ? $0 : nil
    }

    let steps = orderedSteps(in: html)

    let caption = firstNormalizedCapture(
      expression: ProductPresentationExpressions.small,
      bodyGroup: 1,
      in: html
    ).flatMap {
      $0.count <= maximumPanelTextLength ? $0 : nil
    }

    let cta = learnMoreCTA(in: html)
    let parsed = ProductWalletProviderInformation(
      modalTitle: modalTitle,
      logoURL: logoURL,
      heading: heading,
      subheading: subheading,
      steps: steps,
      caption: caption,
      ctaLabel: cta?.label,
      ctaURL: cta?.url
    )
    return parsed.isRenderable ? parsed : nil
  }

  private static func orderedSteps(in html: String) -> [String] {
    guard
      let listExpression = ProductPresentationExpressions.orderedList,
      let itemExpression = ProductPresentationExpressions.listItem,
      let listMatch = listExpression.firstMatch(
        in: html,
        range: fullRange(of: html)
      ),
      let listBodyRange = Range(listMatch.range(at: 1), in: html)
    else {
      return []
    }

    let listBody = String(html[listBodyRange])
    return itemExpression.matches(
      in: listBody,
      range: fullRange(of: listBody)
    ).prefix(maximumSteps).compactMap { match in
      guard let itemRange = Range(match.range(at: 1), in: listBody),
        let step = normalizedText(String(listBody[itemRange])),
        step.count <= maximumStepLength
      else {
        return nil
      }
      return step
    }
  }

  private static func learnMoreCTA(
    in html: String
  ) -> (label: String, url: URL)? {
    guard let expression = ProductPresentationExpressions.learnLink else {
      return nil
    }

    for match in expression.matches(
      in: html,
      range: fullRange(of: html)
    ).prefix(64) {
      guard
        let attributesRange = Range(match.range(at: 1), in: html),
        let bodyRange = Range(match.range(at: 2), in: html)
      else {
        continue
      }

      let attributes = parseAttributes(String(html[attributesRange]))
      guard hasClass("cstm-tap-learn-link", attributes: attributes),
        let source = attributes["href"],
        let url = verifiedExternalHTTPSURL(source),
        let label = normalizedText(String(html[bodyRange])),
        !label.isEmpty,
        label.count <= maximumLabelLength
      else {
        continue
      }
      return (label, url)
    }

    return nil
  }

  private static func firstClassBody(
    expression: NSRegularExpression?,
    classToken: String,
    attributesGroup: Int,
    bodyGroup: Int,
    in html: String
  ) -> String? {
    guard let expression else { return nil }

    for match in expression.matches(
      in: html,
      range: fullRange(of: html)
    ).prefix(128) {
      guard
        let attributesRange = Range(
          match.range(at: attributesGroup),
          in: html
        ),
        let bodyRange = Range(match.range(at: bodyGroup), in: html)
      else {
        continue
      }
      let attributes = parseAttributes(String(html[attributesRange]))
      guard hasClass(classToken, attributes: attributes) else {
        continue
      }
      return String(html[bodyRange])
    }

    return nil
  }

  private static func validPanelTarget(_ source: String) -> String? {
    let target = source.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    guard target.hasPrefix("option-"),
      target.count <= 64,
      target.unicodeScalars.allSatisfy({ scalar in
        CharacterSet.alphanumerics.contains(scalar)
          || scalar == "-"
      })
    else {
      return nil
    }
    return target
  }

  private static func balancedDivBody(
    after start: String.Index,
    in html: String,
    maximumBytes: Int
  ) -> String? {
    guard let expression = ProductPresentationExpressions.divToken else {
      return nil
    }

    let searchRange = NSRange(start..<html.endIndex, in: html)
    var depth = 1
    for token in expression.matches(in: html, range: searchRange) {
      guard let tokenRange = Range(token.range, in: html) else {
        continue
      }
      if html[tokenRange].hasPrefix("</") {
        depth -= 1
        if depth == 0 {
          let body = String(html[start..<tokenRange.lowerBound])
          return body.utf8.count <= maximumBytes ? body : nil
        }
      } else {
        depth += 1
      }
    }

    return nil
  }

  private static func imageURL(in html: String) -> URL? {
    guard
      let expression = ProductPresentationExpressions.image,
      let match = expression.firstMatch(
        in: html,
        range: fullRange(of: html)
      ),
      let attributesRange = Range(match.range(at: 1), in: html)
    else {
      return nil
    }

    let attributes = parseAttributes(String(html[attributesRange]))
    guard let source = attributes["src"] ?? attributes["data-src"] else {
      return nil
    }
    return verifiedImageURL(source)
  }

  private static func nativeWalletMark(
    in html: String,
    accessibilityLabel: String
  ) -> ProductWalletNativeMark? {
    guard
      let svgExpression = ProductPresentationExpressions.svg,
      let svgMatch = svgExpression.firstMatch(
        in: html,
        range: fullRange(of: html)
      ),
      let svgBodyRange = Range(svgMatch.range(at: 1), in: html)
    else {
      return nil
    }

    let svgBody = String(html[svgBodyRange])
    guard svgBody.utf8.count <= 64_000,
      let title = firstNormalizedCapture(
        expression: ProductPresentationExpressions.title,
        bodyGroup: 1,
        in: svgBody
      ),
      title.caseInsensitiveCompare(accessibilityLabel) == .orderedSame
    else {
      return nil
    }

    switch title.lowercased() {
    case "apple pay":
      return .applePay
    case "google pay":
      return .googlePay
    default:
      return nil
    }
  }

  private static func firstBody(
    after start: String.Index,
    in html: String,
    closingExpression: NSRegularExpression
  ) -> String? {
    let searchRange = NSRange(start..<html.endIndex, in: html)
    guard
      let closing = closingExpression.firstMatch(
        in: html,
        range: searchRange
      ),
      let closingRange = Range(closing.range, in: html)
    else {
      return nil
    }

    return String(html[start..<closingRange.lowerBound])
  }

  private static func firstNormalizedCapture(
    expression: NSRegularExpression?,
    bodyGroup: Int,
    in html: String
  ) -> String? {
    guard
      let expression,
      let match = expression.firstMatch(
        in: html,
        range: fullRange(of: html)
      ),
      let bodyRange = Range(match.range(at: bodyGroup), in: html)
    else {
      return nil
    }

    return normalizedText(String(html[bodyRange]))
  }

  private static func firstNormalizedClassCapture(
    expression: NSRegularExpression?,
    classToken: String,
    attributesGroup: Int,
    bodyGroup: Int,
    in html: String
  ) -> String? {
    guard let expression else {
      return nil
    }

    for match in expression.matches(
      in: html,
      range: fullRange(of: html)
    ).prefix(128) {
      guard
        let attributesRange = Range(
          match.range(at: attributesGroup),
          in: html
        ),
        let bodyRange = Range(match.range(at: bodyGroup), in: html)
      else {
        continue
      }

      let attributes = parseAttributes(String(html[attributesRange]))
      guard hasClass(classToken, attributes: attributes) else {
        continue
      }
      return normalizedText(String(html[bodyRange]))
    }

    return nil
  }

  private static func parseAttributes(
    _ source: String
  ) -> [String: String] {
    guard let expression = ProductPresentationExpressions.attribute else {
      return [:]
    }

    var attributes: [String: String] = [:]
    for match in expression.matches(
      in: source,
      range: fullRange(of: source)
    ) {
      guard let nameRange = Range(match.range(at: 1), in: source)
      else {
        continue
      }

      let name = source[nameRange].lowercased()
      var value = ""
      for group in 2...4
      where match.range(at: group).location != NSNotFound {
        if let valueRange = Range(match.range(at: group), in: source) {
          value = decodeHTMLEntities(String(source[valueRange]))
        }
        break
      }
      attributes[name] = value
    }
    return attributes
  }

  private static func hasClass(
    _ classToken: String,
    attributes: [String: String]
  ) -> Bool {
    (attributes["class"] ?? "")
      .split(whereSeparator: \.isWhitespace)
      .contains { $0 == classToken }
  }

  private static func normalizedText(_ html: String) -> String? {
    var result = html

    if let expression =
      ProductPresentationExpressions.commentsScriptsStyles
    {
      result = expression.stringByReplacingMatches(
        in: result,
        range: fullRange(of: result),
        withTemplate: ""
      )
    }
    if let expression = ProductPresentationExpressions.tags {
      result = expression.stringByReplacingMatches(
        in: result,
        range: fullRange(of: result),
        withTemplate: " "
      )
    }

    result = decodeHTMLEntities(result)
      .replacingOccurrences(of: "\u{00A0}", with: " ")

    if let expression = ProductPresentationExpressions.whitespace {
      result = expression.stringByReplacingMatches(
        in: result,
        range: fullRange(of: result),
        withTemplate: " "
      )
    }

    result = result.trimmingCharacters(in: .whitespacesAndNewlines)
    return result.isEmpty ? nil : result
  }

  private static func decodeHTMLEntities(_ source: String) -> String {
    var result = ""
    var cursor = source.startIndex

    while cursor < source.endIndex,
      let ampersand = source[cursor...].firstIndex(of: "&")
    {
      result.append(contentsOf: source[cursor..<ampersand])

      let searchEnd =
        source.index(
          ampersand,
          offsetBy: 16,
          limitedBy: source.endIndex
        ) ?? source.endIndex
      guard
        let semicolon = source[ampersand..<searchEnd]
          .firstIndex(of: ";")
      else {
        result.append("&")
        cursor = source.index(after: ampersand)
        continue
      }

      let entityStart = source.index(after: ampersand)
      let entity = String(source[entityStart..<semicolon])
      if let decoded = decodedEntity(entity) {
        result.append(contentsOf: decoded)
      } else {
        result.append(contentsOf: source[ampersand...semicolon])
      }
      cursor = source.index(after: semicolon)
    }

    result.append(contentsOf: source[cursor...])
    return result
  }

  private static func decodedEntity(_ entity: String) -> String? {
    let normalized = entity.lowercased()
    switch normalized {
    case "amp":
      return "&"
    case "quot":
      return "\""
    case "apos", "#39":
      return "'"
    case "lt":
      return "<"
    case "gt":
      return ">"
    case "nbsp":
      return "\u{00A0}"
    default:
      break
    }

    if normalized.hasPrefix("#x"),
      let value = UInt32(normalized.dropFirst(2), radix: 16),
      let scalar = UnicodeScalar(value)
    {
      return String(Character(scalar))
    }
    if normalized.hasPrefix("#"),
      let value = UInt32(normalized.dropFirst(), radix: 10),
      let scalar = UnicodeScalar(value)
    {
      return String(Character(scalar))
    }
    return nil
  }

  private static func fullRange(of string: String) -> NSRange {
    NSRange(string.startIndex..<string.endIndex, in: string)
  }
}
