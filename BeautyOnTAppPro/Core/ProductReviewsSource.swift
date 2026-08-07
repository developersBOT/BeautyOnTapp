import Foundation

struct ProductReviewDistribution: Identifiable, Equatable, Sendable {
  let rating: Int
  let count: Int
  let percentage: Int

  var id: Int { rating }
}

struct ProductReview: Identifiable, Equatable, Sendable {
  let id: String
  let rating: Int
  let author: String?
  let isVerifiedBuyer: Bool
  let publishedAt: Date?
  let title: String?
  let body: String?
  let merchantReply: String?
}

enum ProductReviewSort: String, CaseIterable, Identifiable, Sendable {
  case mostRecent = "most-recent"
  case highestRating = "highest-rating"
  case lowestRating = "lowest-rating"
  case mostHelpful = "most-helpful"

  var id: String { rawValue }

  var title: String {
    switch self {
    case .mostRecent:
      return "Most Recent"
    case .highestRating:
      return "Highest Rating"
    case .lowestRating:
      return "Lowest Rating"
    case .mostHelpful:
      return "Most Helpful"
    }
  }

  fileprivate var sortBy: String {
    switch self {
    case .mostRecent:
      return "created_at"
    case .highestRating, .lowestRating:
      return "rating"
    case .mostHelpful:
      return "most_helpful"
    }
  }

  fileprivate var sortDirection: String? {
    switch self {
    case .mostRecent, .highestRating:
      return "desc"
    case .lowestRating:
      return "asc"
    case .mostHelpful:
      return nil
    }
  }
}

struct ProductReviewsPagination: Equatable, Sendable {
  let productID: String
  let perPage: Int
  let currentPage: Int
  let totalCount: Int

  var hasNextPage: Bool {
    currentPage * perPage < totalCount
  }
}

struct ProductReviewsPage: Equatable, Sendable {
  let page: Int
  let totalCount: Int
  let reviews: [ProductReview]
}

struct ProductReviewsDocument: Equatable, Sendable {
  static let maximumLoadedReviews = 100

  let summary: ProductReviewSummary
  let distribution: [ProductReviewDistribution]
  let reviews: [ProductReview]
  let pagination: ProductReviewsPagination?

  init(
    summary: ProductReviewSummary,
    distribution: [ProductReviewDistribution],
    reviews: [ProductReview],
    pagination: ProductReviewsPagination? = nil
  ) {
    self.summary = summary
    self.distribution = distribution
    self.reviews = Array(reviews.prefix(Self.maximumLoadedReviews))
    self.pagination = pagination
  }

  var totalAvailableReviews: Int {
    pagination?.totalCount ?? summary.reviewCount
  }

  var hasMoreReviews: Bool {
    totalAvailableReviews > reviews.count
  }

  var canLoadMoreReviews: Bool {
    reviews.count < Self.maximumLoadedReviews
      && pagination?.hasNextPage == true
  }

  func merging(
    _ page: ProductReviewsPage,
    replacingCurrentReviews: Bool
  ) -> ProductReviewsDocument {
    guard let pagination else { return self }

    var merged = replacingCurrentReviews ? [] : reviews
    var seenIDs = Set(merged.map(\.id))

    for review in page.reviews
    where merged.count < Self.maximumLoadedReviews {
      guard seenIDs.insert(review.id).inserted else { continue }
      merged.append(review)
    }

    return ProductReviewsDocument(
      summary: summary,
      distribution: distribution,
      reviews: merged,
      pagination: ProductReviewsPagination(
        productID: pagination.productID,
        perPage: pagination.perPage,
        currentPage: page.page,
        totalCount: page.totalCount
      )
    )
  }
}

enum ProductReviewsSourceError: LocalizedError, Equatable, Sendable {
  case invalidProductHandle
  case invalidResponse
  case httpStatus(Int)
  case responseTooLarge
  case reviewsUnavailable

  var errorDescription: String? {
    switch self {
    case .invalidProductHandle:
      return "This product’s reviews cannot be loaded."
    case .invalidResponse:
      return "BeautyOnTApp returned an unreadable reviews page."
    case .httpStatus:
      return "Reviews are unavailable right now."
    case .responseTooLarge:
      return "The reviews page was too large to load safely."
    case .reviewsUnavailable:
      return "Reviews are unavailable for this product right now."
    }
  }
}

protocol ProductReviewsProviding: Sendable {
  func reviews(
    forProductHandle handle: String,
    forceRefresh: Bool
  ) async throws -> ProductReviewsDocument

  func reviewPage(
    for pagination: ProductReviewsPagination,
    page: Int,
    sort: ProductReviewSort
  ) async throws -> ProductReviewsPage
}

extension ProductReviewsProviding {
  func reviews(
    forProductHandle handle: String
  ) async throws -> ProductReviewsDocument {
    try await reviews(
      forProductHandle: handle,
      forceRefresh: false
    )
  }
}

actor ProductReviewsSource: ProductReviewsProviding {
  static let shared = ProductReviewsSource()

  private struct CacheEntry {
    let document: ProductReviewsDocument
    let storedAt: Date
  }

  private static let maximumResponseBytes = 5 * 1_024 * 1_024
  private static let maximumPageResponseBytes = 1 * 1_024 * 1_024
  private static let reviewsPageEndpoint = URL(
    string: "https://api.judge.me/reviews/reviews_for_widget"
  )!

  private let session: URLSession
  private let cacheLifetime: TimeInterval
  private let cacheCapacity: Int
  private var cache: [String: CacheEntry] = [:]

  init(
    session: URLSession = ProductReviewsSource.makeSession(),
    cacheLifetime: TimeInterval = 5 * 60,
    cacheCapacity: Int = 24
  ) {
    self.session = session
    self.cacheLifetime = max(0, cacheLifetime)
    self.cacheCapacity = max(1, cacheCapacity)
  }

  func reviews(
    forProductHandle handle: String,
    forceRefresh: Bool = false
  ) async throws -> ProductReviewsDocument {
    try Task.checkCancellation()

    guard Self.isValidHandle(handle) else {
      throw ProductReviewsSourceError.invalidProductHandle
    }

    if !forceRefresh,
      let cached = cache[handle],
      Date().timeIntervalSince(cached.storedAt) <= cacheLifetime
    {
      return cached.document
    }

    let url = try Self.requestURL(forProductHandle: handle)
    var request = URLRequest(
      url: url,
      cachePolicy: .reloadRevalidatingCacheData,
      timeoutInterval: 20
    )
    request.setValue(
      "text/html,application/xhtml+xml",
      forHTTPHeaderField: "Accept"
    )

    let (data, response) = try await session.data(for: request)
    try Task.checkCancellation()

    guard let response = response as? HTTPURLResponse,
      let responseURL = response.url,
      Self.isVerifiedResponseURL(responseURL, requestURL: url)
    else {
      throw ProductReviewsSourceError.invalidResponse
    }
    guard (200..<300).contains(response.statusCode) else {
      throw ProductReviewsSourceError.httpStatus(response.statusCode)
    }
    guard
      response.mimeType?.lowercased() == "text/html"
        || response.mimeType?.lowercased() == "application/xhtml+xml"
    else {
      throw ProductReviewsSourceError.invalidResponse
    }
    guard !data.isEmpty else {
      throw ProductReviewsSourceError.invalidResponse
    }
    guard data.count <= Self.maximumResponseBytes else {
      throw ProductReviewsSourceError.responseTooLarge
    }

    let document = try ProductReviewsHTMLParser.parse(data: data)
    try Task.checkCancellation()

    cache[handle] = CacheEntry(
      document: document,
      storedAt: Date()
    )
    trimCacheIfNeeded()
    return document
  }

  func reviewPage(
    for pagination: ProductReviewsPagination,
    page: Int,
    sort: ProductReviewSort
  ) async throws -> ProductReviewsPage {
    try Task.checkCancellation()

    let url = try Self.pageURL(
      productID: pagination.productID,
      page: page,
      perPage: pagination.perPage,
      sort: sort
    )
    var request = URLRequest(
      url: url,
      cachePolicy: .reloadRevalidatingCacheData,
      timeoutInterval: 20
    )
    request.setValue(
      "application/json",
      forHTTPHeaderField: "Accept"
    )

    let (data, response) = try await session.data(for: request)
    try Task.checkCancellation()

    guard let response = response as? HTTPURLResponse,
      let responseURL = response.url,
      Self.isVerifiedPageResponseURL(
        responseURL,
        requestURL: url
      )
    else {
      throw ProductReviewsSourceError.invalidResponse
    }
    guard (200..<300).contains(response.statusCode) else {
      throw ProductReviewsSourceError.httpStatus(response.statusCode)
    }
    guard response.mimeType?.lowercased() == "application/json"
    else {
      throw ProductReviewsSourceError.invalidResponse
    }
    guard !data.isEmpty else {
      throw ProductReviewsSourceError.invalidResponse
    }
    guard data.count <= Self.maximumPageResponseBytes else {
      throw ProductReviewsSourceError.responseTooLarge
    }

    let payload: ReviewsPageResponse
    do {
      payload = try JSONDecoder().decode(
        ReviewsPageResponse.self,
        from: data
      )
    } catch {
      throw ProductReviewsSourceError.invalidResponse
    }

    guard payload.page == page,
      (0...ProductReviewsHTMLParser.maximumReviewCount)
        .contains(payload.totalCount),
      payload.html.utf8.count <= Self.maximumPageResponseBytes
    else {
      throw ProductReviewsSourceError.invalidResponse
    }

    let reviews = try ProductReviewsHTMLParser.parsePage(
      html: payload.html
    )
    guard reviews.count <= pagination.perPage,
      payload.totalCount >= reviews.count
    else {
      throw ProductReviewsSourceError.invalidResponse
    }

    return ProductReviewsPage(
      page: payload.page,
      totalCount: payload.totalCount,
      reviews: reviews
    )
  }

  static func requestURL(
    forProductHandle handle: String
  ) throws -> URL {
    guard isValidHandle(handle) else {
      throw ProductReviewsSourceError.invalidProductHandle
    }

    var url = ShopifyAsset.shopRoot
    url.appendPathComponent("products")
    url.appendPathComponent(handle)

    guard ShopifyAsset.isPrimaryStorefrontURL(url),
      url.user == nil,
      url.password == nil,
      url.port == nil || url.port == 443
    else {
      throw ProductReviewsSourceError.invalidProductHandle
    }
    return url
  }

  static func pageURL(
    productID: String,
    page: Int,
    perPage: Int,
    sort: ProductReviewSort
  ) throws -> URL {
    guard isValidProductID(productID),
      (1...2_000_000).contains(page),
      (1...100).contains(perPage),
      var components = URLComponents(
        url: reviewsPageEndpoint,
        resolvingAgainstBaseURL: false
      )
    else {
      throw ProductReviewsSourceError.invalidResponse
    }

    components.queryItems = [
      URLQueryItem(name: "url", value: "beautyontapp.com"),
      URLQueryItem(
        name: "shop_domain",
        value: "beautyontapp.com"
      ),
      URLQueryItem(name: "platform", value: "shopify"),
      URLQueryItem(name: "page", value: String(page)),
      URLQueryItem(name: "per_page", value: String(perPage)),
      URLQueryItem(name: "product_id", value: productID),
      URLQueryItem(name: "sort_by", value: sort.sortBy),
    ]
    if let direction = sort.sortDirection {
      components.queryItems?.append(
        URLQueryItem(name: "sort_dir", value: direction)
      )
    }

    guard let url = components.url,
      isVerifiedReviewsPageEndpoint(url)
    else {
      throw ProductReviewsSourceError.invalidResponse
    }
    return url
  }

  static func isVerifiedReviewsPageEndpoint(_ url: URL) -> Bool {
    url.scheme?.lowercased() == "https"
      && url.host?.lowercased() == "api.judge.me"
      && url.path == "/reviews/reviews_for_widget"
      && url.user == nil
      && url.password == nil
      && (url.port == nil || url.port == 443)
  }

  private static func isValidHandle(_ handle: String) -> Bool {
    guard !handle.isEmpty, handle.count <= 255 else {
      return false
    }
    return handle.unicodeScalars.allSatisfy { scalar in
      CharacterSet.alphanumerics.contains(scalar)
        || scalar == "-"
    }
  }

  static func isValidProductID(_ productID: String) -> Bool {
    !productID.isEmpty
      && productID.count <= 32
      && productID.unicodeScalars.allSatisfy {
        (48...57).contains($0.value)
      }
  }

  private static func isVerifiedResponseURL(
    _ responseURL: URL,
    requestURL: URL
  ) -> Bool {
    guard ShopifyAsset.isPrimaryStorefrontURL(responseURL),
      responseURL.user == nil,
      responseURL.password == nil,
      responseURL.port == nil || responseURL.port == 443,
      responseURL.host?.lowercased()
        == requestURL.host?.lowercased(),
      responseURL.path == requestURL.path
    else {
      return false
    }
    return true
  }

  private static func isVerifiedPageResponseURL(
    _ responseURL: URL,
    requestURL: URL
  ) -> Bool {
    isVerifiedReviewsPageEndpoint(responseURL)
      && responseURL == requestURL
  }

  private static func makeSession() -> URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = URLCache(
      memoryCapacity: 6 * 1_024 * 1_024,
      diskCapacity: 32 * 1_024 * 1_024,
      diskPath: "com.beautyontapp.product-reviews"
    )
    configuration.requestCachePolicy = .reloadRevalidatingCacheData
    configuration.timeoutIntervalForRequest = 20
    configuration.timeoutIntervalForResource = 30
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

actor ProductCardReviewsSource {
  static let shared = ProductCardReviewsSource()

  private struct CacheEntry {
    let summaries: [String: ProductReviewSummary]
    let storedAt: Date
  }

  private static let maximumResponseBytes = 5 * 1_024 * 1_024
  private let session: URLSession
  private let cacheLifetime: TimeInterval
  private let cacheCapacity: Int
  private var cache: [String: CacheEntry] = [:]

  init(
    session: URLSession = ProductCardReviewsSource.makeSession(),
    cacheLifetime: TimeInterval = 5 * 60,
    cacheCapacity: Int = 24
  ) {
    self.session = session
    self.cacheLifetime = max(0, cacheLifetime)
    self.cacheCapacity = max(1, cacheCapacity)
  }

  func summaries(
    forCollectionHandle handle: String,
    page: Int = 1,
    forceRefresh: Bool = false
  ) async throws -> [String: ProductReviewSummary] {
    try await summaries(
      at: Self.collectionURL(handle: handle, page: page),
      forceRefresh: forceRefresh
    )
  }

  func summaries(
    forSearchQuery query: String,
    page: Int = 1,
    forceRefresh: Bool = false
  ) async throws -> [String: ProductReviewSummary] {
    try await summaries(
      at: Self.searchURL(query: query, page: page),
      forceRefresh: forceRefresh
    )
  }

  func summaries(
    forProductHandle handle: String,
    forceRefresh: Bool = false
  ) async throws -> [String: ProductReviewSummary] {
    try await summaries(
      at: ProductReviewsSource.requestURL(
        forProductHandle: handle
      ),
      forceRefresh: forceRefresh
    )
  }

  static func collectionURL(
    handle: String,
    page: Int = 1
  ) throws -> URL {
    guard isValidHandle(handle), (1...10_000).contains(page) else {
      throw ProductReviewsSourceError.invalidResponse
    }
    var url = ShopifyAsset.shopRoot
    url.appendPathComponent("collections")
    url.appendPathComponent(handle)
    if page > 1 {
      var components = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
      )
      components?.queryItems = [
        URLQueryItem(name: "page", value: String(page))
      ]
      guard let pagedURL = components?.url else {
        throw ProductReviewsSourceError.invalidResponse
      }
      url = pagedURL
    }
    guard isVerifiedPageURL(url) else {
      throw ProductReviewsSourceError.invalidResponse
    }
    return url
  }

  static func searchURL(
    query: String,
    page: Int = 1
  ) throws -> URL {
    let trimmed = query.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    guard !trimmed.isEmpty,
      trimmed.count <= 200,
      (1...10_000).contains(page),
      var components = URLComponents(
        url: ShopifyAsset.shopRoot.appendingPathComponent("search"),
        resolvingAgainstBaseURL: false
      )
    else {
      throw ProductReviewsSourceError.invalidResponse
    }
    components.queryItems = [
      URLQueryItem(name: "q", value: trimmed),
      URLQueryItem(name: "type", value: "product"),
      URLQueryItem(name: "page", value: String(page)),
    ]
    guard let url = components.url, isVerifiedPageURL(url) else {
      throw ProductReviewsSourceError.invalidResponse
    }
    return url
  }

  private func summaries(
    at url: URL,
    forceRefresh: Bool
  ) async throws -> [String: ProductReviewSummary] {
    try Task.checkCancellation()
    guard Self.isVerifiedPageURL(url) else {
      throw ProductReviewsSourceError.invalidResponse
    }

    let cacheKey = url.absoluteString
    if !forceRefresh,
      let cached = cache[cacheKey],
      Date().timeIntervalSince(cached.storedAt) <= cacheLifetime
    {
      return cached.summaries
    }

    var request = URLRequest(
      url: url,
      cachePolicy: .reloadRevalidatingCacheData,
      timeoutInterval: 20
    )
    request.setValue(
      "text/html,application/xhtml+xml",
      forHTTPHeaderField: "Accept"
    )

    let (data, response) = try await session.data(for: request)
    try Task.checkCancellation()

    guard let response = response as? HTTPURLResponse,
      let responseURL = response.url,
      Self.isVerifiedPageURL(responseURL),
      responseURL.path == url.path,
      (200..<300).contains(response.statusCode),
      response.mimeType?.lowercased() == "text/html"
        || response.mimeType?.lowercased() == "application/xhtml+xml",
      !data.isEmpty
    else {
      throw ProductReviewsSourceError.invalidResponse
    }
    guard data.count <= Self.maximumResponseBytes else {
      throw ProductReviewsSourceError.responseTooLarge
    }

    let parsed = try ProductReviewsHTMLParser.cardSummaries(
      data: data
    )
    cache[cacheKey] = CacheEntry(
      summaries: parsed,
      storedAt: Date()
    )
    trimCacheIfNeeded()
    return parsed
  }

  private static func isValidHandle(_ handle: String) -> Bool {
    !handle.isEmpty
      && handle.count <= 255
      && handle.unicodeScalars.allSatisfy {
        CharacterSet.alphanumerics.contains($0) || $0 == "-"
      }
  }

  private static func isVerifiedPageURL(_ url: URL) -> Bool {
    ShopifyAsset.isPrimaryStorefrontURL(url)
      && url.user == nil
      && url.password == nil
      && (url.port == nil || url.port == 443)
  }

  private static func makeSession() -> URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = URLCache(
      memoryCapacity: 8 * 1_024 * 1_024,
      diskCapacity: 48 * 1_024 * 1_024,
      diskPath: "com.beautyontapp.product-card-reviews"
    )
    configuration.requestCachePolicy = .reloadRevalidatingCacheData
    configuration.timeoutIntervalForRequest = 20
    configuration.timeoutIntervalForResource = 30
    configuration.waitsForConnectivity = true
    return URLSession(configuration: configuration)
  }

  private func trimCacheIfNeeded() {
    guard cache.count > cacheCapacity else { return }
    let overflow = cache.count - cacheCapacity
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

private struct ReviewsPageResponse: Decodable {
  let html: String
  let totalCount: Int
  let page: Int

  private enum CodingKeys: String, CodingKey {
    case html
    case totalCount = "total_count"
    case page
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    html = try container.decode(String.self, forKey: .html)
    totalCount = try container.decode(Int.self, forKey: .totalCount)

    if let integerPage = try? container.decode(
      Int.self,
      forKey: .page
    ) {
      page = integerPage
    } else {
      let stringPage = try container.decode(
        String.self,
        forKey: .page
      )
      guard let integerPage = Int(stringPage) else {
        throw DecodingError.dataCorruptedError(
          forKey: .page,
          in: container,
          debugDescription: "The page value is not an integer."
        )
      }
      page = integerPage
    }
  }
}

enum ProductReviewSubmissionFlow {
  static func requestURL(
    forProductHandle handle: String
  ) throws -> URL {
    let productURL = try ProductReviewsSource.requestURL(
      forProductHandle: handle
    )
    guard
      var components = URLComponents(
        url: productURL,
        resolvingAgainstBaseURL: false
      )
    else {
      throw ProductReviewsSourceError.invalidProductHandle
    }
    components.fragment = "judgeme_product_reviews"

    guard let url = components.url,
      ShopifyAsset.isPrimaryStorefrontURL(url)
    else {
      throw ProductReviewsSourceError.invalidProductHandle
    }
    return url
  }
}

enum ProductReviewsHTMLParser {
  private static let maximumHTMLBytes = 5 * 1_024 * 1_024
  static let maximumReviewCount = 10_000_000
  private static let maximumRenderedReviews = 100
  private static let maximumFieldLength = 20_000
  private static let productHandleExpression = try? NSRegularExpression(
    pattern: #"(?is)href\s*=\s*["']/products/([^"'?#/]+)"#
  )
  private static let cardRatingExpression = try? NSRegularExpression(
    pattern:
      #"(?is)aria-label\s*=\s*["']([0-9]+(?:\.[0-9]+)?)\s+out\s+of\s+([0-9]+(?:\.[0-9]+)?)\s+stars["']"#
  )
  private static let cardReviewCountExpression =
    try? NSRegularExpression(
      pattern:
        #"(?is)class\s*=\s*["'][^"']*visually-hidden[^"']*["'][^>]*>\s*([0-9][0-9,]*)\s+total\s+reviews"#
    )

  static func parse(data: Data) throws -> ProductReviewsDocument {
    guard data.count <= maximumHTMLBytes else {
      throw ProductReviewsSourceError.responseTooLarge
    }
    guard let html = String(data: data, encoding: .utf8) else {
      throw ProductReviewsSourceError.invalidResponse
    }
    return try parse(html: html)
  }

  static func parse(html: String) throws -> ProductReviewsDocument {
    guard html.utf8.count <= maximumHTMLBytes else {
      throw ProductReviewsSourceError.responseTooLarge
    }

    let contract = try reviewsContract(in: html)
    guard let summary = summary(in: contract) else {
      throw ProductReviewsSourceError.reviewsUnavailable
    }

    return ProductReviewsDocument(
      summary: summary,
      distribution: distribution(in: contract),
      reviews: reviews(in: contract),
      pagination: pagination(
        in: contract,
        totalCount: summary.reviewCount
      )
    )
  }

  static func parsePage(html: String) throws -> [ProductReview] {
    guard html.utf8.count <= maximumHTMLBytes else {
      throw ProductReviewsSourceError.responseTooLarge
    }

    let hasReviewsContainer = ProductReviewsHTML.openingElements(
      named: "div",
      in: html
    ).contains {
      ProductReviewsHTML.hasClass(
        "jdgm-rev-widg__reviews",
        attributes: $0.attributes
      )
    }
    guard hasReviewsContainer else {
      throw ProductReviewsSourceError.invalidResponse
    }

    return reviews(
      in: html,
      requiresSourceID: true
    )
  }

  static func cardSummaries(
    data: Data
  ) throws -> [String: ProductReviewSummary] {
    guard data.count <= maximumHTMLBytes,
      let html = String(data: data, encoding: .utf8)
    else {
      throw ProductReviewsSourceError.invalidResponse
    }
    return cardSummaries(html: html)
  }

  static func cardSummaries(
    html: String
  ) -> [String: ProductReviewSummary] {
    guard html.utf8.count <= maximumHTMLBytes else {
      return [:]
    }

    var summaries: [String: ProductReviewSummary] = [:]
    let cardOpenings = ProductReviewsHTML.openingElements(
      named: "div",
      in: html
    ).filter {
      ProductReviewsHTML.hasClass(
        "product-card",
        attributes: $0.attributes
      )
    }

    for index in cardOpenings.indices.prefix(500) {
      let cardStart = cardOpenings[index].range.lowerBound
      let cardEnd =
        cardOpenings.index(after: index) < cardOpenings.endIndex
        ? cardOpenings[cardOpenings.index(after: index)].range.lowerBound
        : html.endIndex
      let cardBody = String(html[cardStart..<cardEnd])

      guard
        let handle = firstCapture(
          productHandleExpression,
          group: 1,
          in: cardBody
        ),
        let averageSource = firstCapture(
          cardRatingExpression,
          group: 1,
          in: cardBody
        ),
        let maximumSource = firstCapture(
          cardRatingExpression,
          group: 2,
          in: cardBody
        ),
        let countSource = firstCapture(
          cardReviewCountExpression,
          group: 1,
          in: cardBody
        )?.replacingOccurrences(of: ",", with: ""),
        let average = Double(averageSource),
        let maximum = Double(maximumSource),
        let count = Int(countSource),
        average.isFinite,
        maximum.isFinite,
        maximum > 0,
        count > 0,
        count <= maximumReviewCount
      else {
        continue
      }

      summaries[handle] = ProductReviewSummary(
        averageRating: min(max(average / maximum * 5, 0), 5),
        reviewCount: count
      )
    }
    return summaries
  }

  private static func reviewsContract(in html: String) throws -> String {
    let sectionOpenings = ProductReviewsHTML.openingElements(
      named: "section",
      in: html
    )

    if let section = sectionOpenings.first(where: {
      $0.attributes["id"] == "shopify-product-reviews"
    }) {
      guard
        let closingRange = ProductReviewsHTML.firstClosingTag(
          named: "section",
          after: section.range.upperBound,
          in: html
        )
      else {
        throw ProductReviewsSourceError.invalidResponse
      }
      return String(html[section.range.lowerBound..<closingRange.upperBound])
    }

    let hasDirectWidget = ProductReviewsHTML.openingElements(
      named: "div",
      in: html
    ).contains {
      ProductReviewsHTML.hasClass(
        "jdgm-rev-widg",
        attributes: $0.attributes
      )
    }
    guard hasDirectWidget else {
      throw ProductReviewsSourceError.reviewsUnavailable
    }
    return html
  }

  private static func summary(
    in html: String
  ) -> ProductReviewSummary? {
    let openings = ProductReviewsHTML.openingElements(
      named: nil,
      in: html
    )

    let candidates = [
      openings.first {
        ProductReviewsHTML.hasClass(
          "jdgm-rev-widg",
          attributes: $0.attributes
        )
      },
      openings.first {
        ProductReviewsHTML.hasClass(
          "jdgm-widget",
          attributes: $0.attributes
        )
      },
      openings.first {
        ProductReviewsHTML.hasClass(
          "jdgm-prev-badge",
          attributes: $0.attributes
        )
      },
    ].compactMap { $0 }

    for source in candidates {
      guard
        let averageSource =
          source.attributes["data-average-rating"],
        let countSource =
          source.attributes["data-number-of-reviews"],
        let average = Double(averageSource),
        average.isFinite,
        (0...5).contains(average),
        let count = Int(countSource),
        (0...maximumReviewCount).contains(count)
      else {
        continue
      }

      return ProductReviewSummary(
        averageRating: average,
        reviewCount: count
      )
    }
    return nil
  }

  private static func distribution(
    in html: String
  ) -> [ProductReviewDistribution] {
    var values: [ProductReviewDistribution] = []
    var seenRatings = Set<Int>()

    for opening in ProductReviewsHTML.openingElements(
      named: "div",
      in: html
    ) {
      guard
        ProductReviewsHTML.hasClass(
          "jdgm-histogram__row",
          attributes: opening.attributes
        ),
        let ratingSource = opening.attributes["data-rating"],
        let countSource = opening.attributes["data-frequency"],
        let percentageSource = opening.attributes["data-percentage"],
        let rating = Int(ratingSource),
        (1...5).contains(rating),
        let count = Int(countSource),
        (0...maximumReviewCount).contains(count),
        let percentage = Int(percentageSource),
        (0...100).contains(percentage),
        seenRatings.insert(rating).inserted
      else {
        continue
      }

      values.append(
        ProductReviewDistribution(
          rating: rating,
          count: count,
          percentage: percentage
        )
      )
    }

    return values.sorted { $0.rating > $1.rating }
  }

  private static func pagination(
    in html: String,
    totalCount: Int
  ) -> ProductReviewsPagination? {
    let openings = ProductReviewsHTML.openingElements(
      named: "div",
      in: html
    )

    guard
      let widget = openings.first(where: {
        ProductReviewsHTML.hasClass(
          "jdgm-review-widget",
          attributes: $0.attributes
        )
      }),
      let productID = ProductReviewsHTML.nonEmpty(
        widget.attributes["data-product-id"]
          ?? widget.attributes["data-id"]
      ),
      ProductReviewsSource.isValidProductID(productID),
      let paginate = openings.first(where: {
        ProductReviewsHTML.hasClass(
          "jdgm-paginate",
          attributes: $0.attributes
        )
      }),
      let perPageSource = paginate.attributes["data-per-page"],
      let perPage = Int(perPageSource),
      (1...100).contains(perPage),
      let endpointSource = ProductReviewsHTML.nonEmpty(
        paginate.attributes["data-url"]
      ),
      let endpoint = URL(string: endpointSource),
      ProductReviewsSource.isVerifiedReviewsPageEndpoint(endpoint)
    else {
      return nil
    }

    return ProductReviewsPagination(
      productID: productID,
      perPage: perPage,
      currentPage: 1,
      totalCount: totalCount
    )
  }

  private static func reviews(
    in html: String,
    requiresSourceID: Bool = false
  ) -> [ProductReview] {
    let openings = ProductReviewsHTML.openingElements(
      named: "div",
      in: html
    ).filter {
      ProductReviewsHTML.hasClass(
        "jdgm-rev",
        attributes: $0.attributes
      )
    }

    var parsedReviews: [ProductReview] = []
    var seenIDs = Set<String>()

    for (index, opening)
      in openings
      .prefix(maximumRenderedReviews)
      .enumerated()
    {
      let end =
        openings.indices.contains(index + 1)
        ? openings[index + 1].range.lowerBound
        : html.endIndex
      let cardHTML = String(html[opening.range.lowerBound..<end])

      guard
        let ratingAttributes =
          ProductReviewsHTML.firstOpeningAttributes(
            classToken: "jdgm-rev__rating",
            in: cardHTML
          ),
        let ratingSource = ratingAttributes["data-score"],
        let rating = Int(ratingSource),
        (1...5).contains(rating)
      else {
        continue
      }

      let sourceID = ProductReviewsHTML.nonEmpty(
        opening.attributes["data-review-id"]
      )
      if requiresSourceID, sourceID == nil {
        continue
      }
      let stableID = sourceID ?? "rendered-review-\(index)"
      guard seenIDs.insert(stableID).inserted else {
        continue
      }

      let timestampAttributes =
        ProductReviewsHTML.firstOpeningAttributes(
          classToken: "jdgm-rev__timestamp",
          in: cardHTML
        )
      let timestamp = timestampAttributes?["data-content"]
        .flatMap(ProductReviewsHTML.reviewDate)

      parsedReviews.append(
        ProductReview(
          id: stableID,
          rating: rating,
          author: bounded(
            ProductReviewsHTML.elementText(
              classToken: "jdgm-rev__author",
              in: cardHTML
            )
          ),
          isVerifiedBuyer:
            opening.attributes["data-verified-buyer"]?
            .lowercased() == "true",
          publishedAt: timestamp,
          title: bounded(
            ProductReviewsHTML.elementText(
              classToken: "jdgm-rev__title",
              in: cardHTML
            )
          ),
          body: bounded(
            ProductReviewsHTML.elementText(
              classToken: "jdgm-rev__body",
              in: cardHTML
            )
          ),
          merchantReply: bounded(
            ProductReviewsHTML.elementText(
              classToken: "jdgm-rev__reply",
              in: cardHTML
            )
          )
        )
      )
    }

    return parsedReviews
  }

  private static func bounded(_ value: String?) -> String? {
    guard let value, value.count <= maximumFieldLength else {
      return nil
    }
    return value
  }

  private static func firstCapture(
    _ expression: NSRegularExpression?,
    group: Int,
    in source: String
  ) -> String? {
    guard let expression,
      let match = expression.firstMatch(
        in: source,
        range: NSRange(
          source.startIndex..<source.endIndex,
          in: source
        )
      ),
      match.numberOfRanges > group,
      let range = Range(match.range(at: group), in: source)
    else {
      return nil
    }
    return String(source[range])
  }
}

private enum ProductReviewsHTML {
  struct OpeningElement {
    let name: String
    let range: Range<String.Index>
    let attributes: [String: String]
  }

  private static let anyOpeningTag = make(
    #"(?is)<([A-Za-z][A-Za-z0-9:-]*)\b([^>]*)>"#
  )
  private static let attribute = make(
    #"(?is)([A-Za-z_:][-A-Za-z0-9_:.]*)\s*(?:=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+)))?"#
  )
  private static let removableContent = make(
    #"(?is)<!--.*?-->|<(?:script|style)\b[^>]*>.*?</(?:script|style)\s*>"#
  )
  private static let lineBreakTags = make(
    #"(?is)<br\s*/?>|</(?:p|li|div|blockquote)\s*>"#
  )
  private static let tags = make(#"(?is)<[^>]+>"#)
  private static let horizontalWhitespace = make(#"[^\S\r\n]+"#)
  private static let repeatedNewlines = make(#"(?:\s*\n\s*){2,}"#)

  static func openingElements(
    named requestedName: String?,
    in html: String
  ) -> [OpeningElement] {
    guard let anyOpeningTag else { return [] }

    return anyOpeningTag.matches(
      in: html,
      range: fullRange(of: html)
    ).prefix(20_000).compactMap { match in
      guard let nameRange = Range(match.range(at: 1), in: html),
        let attributesRange = Range(match.range(at: 2), in: html),
        let openingRange = Range(match.range, in: html)
      else {
        return nil
      }

      let name = html[nameRange].lowercased()
      if let requestedName,
        name != requestedName.lowercased()
      {
        return nil
      }

      return OpeningElement(
        name: String(name),
        range: openingRange,
        attributes: parseAttributes(String(html[attributesRange]))
      )
    }
  }

  static func firstClosingTag(
    named name: String,
    after start: String.Index,
    in html: String
  ) -> Range<String.Index>? {
    let escaped = NSRegularExpression.escapedPattern(for: name)
    guard
      let expression = make(
        "(?is)</\\s*\(escaped)\\s*>"
      )
    else {
      return nil
    }
    let searchRange = NSRange(start..<html.endIndex, in: html)
    guard
      let match = expression.firstMatch(
        in: html,
        range: searchRange
      )
    else {
      return nil
    }
    return Range(match.range, in: html)
  }

  static func firstOpeningAttributes(
    classToken: String,
    in html: String
  ) -> [String: String]? {
    openingElements(named: nil, in: html).first {
      hasClass(classToken, attributes: $0.attributes)
    }?.attributes
  }

  static func elementText(
    classToken: String,
    in html: String
  ) -> String? {
    guard
      let opening = openingElements(
        named: nil,
        in: html
      ).first(where: {
        hasClass(classToken, attributes: $0.attributes)
      }),
      let closing = matchingClosingTag(
        named: opening.name,
        after: opening.range.upperBound,
        in: html
      )
    else {
      return nil
    }

    return normalizedText(
      String(html[opening.range.upperBound..<closing.lowerBound])
    )
  }

  static func hasClass(
    _ classToken: String,
    attributes: [String: String]
  ) -> Bool {
    (attributes["class"] ?? "")
      .split(whereSeparator: \.isWhitespace)
      .contains { $0 == classToken }
  }

  static func nonEmpty(_ value: String?) -> String? {
    guard let value else { return nil }
    let trimmed = value.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    return trimmed.isEmpty ? nil : trimmed
  }

  static func reviewDate(_ source: String) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"
    return formatter.date(from: source)
  }

  private static func parseAttributes(
    _ source: String
  ) -> [String: String] {
    guard let attribute else { return [:] }

    var attributes: [String: String] = [:]
    for match in attribute.matches(
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

  private static func matchingClosingTag(
    named name: String,
    after start: String.Index,
    in html: String
  ) -> Range<String.Index>? {
    let escaped = NSRegularExpression.escapedPattern(for: name)
    guard
      let tokens = make(
        "(?is)<\(escaped)\\b[^>]*>|</\\s*\(escaped)\\s*>"
      )
    else {
      return nil
    }

    var depth = 1
    for match in tokens.matches(
      in: html,
      range: NSRange(start..<html.endIndex, in: html)
    ) {
      guard let range = Range(match.range, in: html) else {
        continue
      }
      let token = html[range]
      if token.hasPrefix("</") {
        depth -= 1
        if depth == 0 {
          return range
        }
      } else if !token.hasSuffix("/>") {
        depth += 1
      }
    }
    return nil
  }

  private static func normalizedText(_ html: String) -> String? {
    var result = html

    if let removableContent {
      result = removableContent.stringByReplacingMatches(
        in: result,
        range: fullRange(of: result),
        withTemplate: ""
      )
    }
    if let lineBreakTags {
      result = lineBreakTags.stringByReplacingMatches(
        in: result,
        range: fullRange(of: result),
        withTemplate: "\n"
      )
    }
    if let tags {
      result = tags.stringByReplacingMatches(
        in: result,
        range: fullRange(of: result),
        withTemplate: " "
      )
    }

    result = decodeHTMLEntities(result)
      .replacingOccurrences(of: "\u{00A0}", with: " ")

    if let horizontalWhitespace {
      result = horizontalWhitespace.stringByReplacingMatches(
        in: result,
        range: fullRange(of: result),
        withTemplate: " "
      )
    }
    if let repeatedNewlines {
      result = repeatedNewlines.stringByReplacingMatches(
        in: result,
        range: fullRange(of: result),
        withTemplate: "\n"
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
          offsetBy: 24,
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
    switch entity.lowercased() {
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
    case "ndash":
      return "–"
    case "mdash":
      return "—"
    case "lsquo":
      return "‘"
    case "rsquo":
      return "’"
    case "ldquo":
      return "“"
    case "rdquo":
      return "”"
    case "hellip":
      return "…"
    default:
      break
    }

    let normalized = entity.lowercased()
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

  private static func make(
    _ pattern: String
  ) -> NSRegularExpression? {
    try? NSRegularExpression(pattern: pattern)
  }

  private static func fullRange(of string: String) -> NSRange {
    NSRange(string.startIndex..<string.endIndex, in: string)
  }
}
