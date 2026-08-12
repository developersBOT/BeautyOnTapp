import XCTest

@testable import BeautyOnTAppPro

final class ProductReviewsSourceTests: XCTestCase {
  override func tearDown() {
    ProductReviewsURLProtocol.response = nil
    super.tearDown()
  }

  func testParserReadsThemeAndRenderedJudgeMeContract() throws {
    let document = try ProductReviewsHTMLParser.parse(
      html: try fixture()
    )

    XCTAssertEqual(
      document.summary,
      ProductReviewSummary(
        averageRating: 4.25,
        reviewCount: 8
      )
    )
    XCTAssertEqual(
      document.distribution,
      [
        ProductReviewDistribution(
          rating: 5,
          count: 5,
          percentage: 63
        ),
        ProductReviewDistribution(
          rating: 4,
          count: 2,
          percentage: 25
        ),
        ProductReviewDistribution(
          rating: 3,
          count: 0,
          percentage: 0
        ),
        ProductReviewDistribution(
          rating: 2,
          count: 0,
          percentage: 0
        ),
        ProductReviewDistribution(
          rating: 1,
          count: 1,
          percentage: 12
        ),
      ]
    )
    XCTAssertEqual(document.reviews.count, 2)
    XCTAssertTrue(document.hasMoreReviews)
    XCTAssertTrue(document.canLoadMoreReviews)
    XCTAssertEqual(
      document.pagination,
      ProductReviewsPagination(
        productID: "9204922384643",
        perPage: 5,
        currentPage: 1,
        totalCount: 8
      )
    )

    let first = try XCTUnwrap(document.reviews.first)
    XCTAssertEqual(first.id, "fixture-review-one")
    XCTAssertEqual(first.rating, 5)
    XCTAssertEqual(first.author, "A. Customer")
    XCTAssertTrue(first.isVerifiedBuyer)
    XCTAssertEqual(first.title, "Soft & comfortable")
    XCTAssertEqual(
      first.body,
      "Absorbs quickly.\nIt doesn't feel sticky."
    )
    XCTAssertEqual(
      first.merchantReply,
      "Thank you for sharing your experience."
    )

    let date = try XCTUnwrap(first.publishedAt)
    let components = Calendar(identifier: .gregorian)
      .dateComponents(
        in: TimeZone(secondsFromGMT: 0)!,
        from: date
      )
    XCTAssertEqual(components.year, 2026)
    XCTAssertEqual(components.month, 7)
    XCTAssertEqual(components.day, 24)
    XCTAssertEqual(components.hour, 20)
    XCTAssertEqual(components.minute, 29)
    XCTAssertEqual(components.second, 5)

    let second = try XCTUnwrap(document.reviews.last)
    XCTAssertEqual(second.id, "fixture-review-two")
    XCTAssertEqual(second.rating, 4)
    XCTAssertEqual(second.author, "Anonymous")
    XCTAssertFalse(second.isVerifiedBuyer)
    XCTAssertNil(second.title)
    XCTAssertNil(second.body)
    XCTAssertNil(second.merchantReply)
  }

  func testParserSupportsDirectSectionContentAndEmptyReviews()
    throws
  {
    let document = try ProductReviewsHTMLParser.parse(
      html: """
        <div
          class="jdgm-rev-widg"
          data-average-rating="0.00"
          data-number-of-reviews="0"
        >
          <div class="jdgm-rev-widg__body"></div>
        </div>
        """
    )

    XCTAssertEqual(document.summary.averageRating, 0)
    XCTAssertEqual(document.summary.reviewCount, 0)
    XCTAssertTrue(document.distribution.isEmpty)
    XCTAssertTrue(document.reviews.isEmpty)
    XCTAssertFalse(document.hasMoreReviews)
  }

  func testParserRejectsMissingOrMalformedReviewContract() {
    XCTAssertThrowsError(
      try ProductReviewsHTMLParser.parse(
        html: """
            <section id="not-product-reviews">
              <div
                class="fake-jdgm-rev-widg"
                data-average-rating="4.00"
                data-number-of-reviews="5"
              ></div>
            </section>
          """
      )
    ) { error in
      XCTAssertEqual(
        error as? ProductReviewsSourceError,
        .reviewsUnavailable
      )
    }

    XCTAssertThrowsError(
      try ProductReviewsHTMLParser.parse(
        html: """
            <section id="shopify-product-reviews">
              <div
                class="jdgm-rev-widg"
                data-average-rating="7.00"
                data-number-of-reviews="-1"
              ></div>
            </section>
          """
      )
    ) { error in
      XCTAssertEqual(
        error as? ProductReviewsSourceError,
        .reviewsUnavailable
      )
    }
  }

  func testRequestUsesVerifiedProductPageAndRejectsUnsafeHandles()
    throws
  {
    let url = try ProductReviewsSource.requestURL(
      forProductHandle: "niacinamide-body-lotion"
    )

    XCTAssertEqual(
      url.absoluteString,
      "https://beautyontapp.com/products/niacinamide-body-lotion"
    )

    for invalidHandle in [
      "",
      "../account",
      "product/name",
      "product?view=reviews",
      "product#reviews",
      "product name",
      String(repeating: "x", count: 256),
    ] {
      XCTAssertThrowsError(
        try ProductReviewsSource.requestURL(
          forProductHandle: invalidHandle
        )
      ) { error in
        XCTAssertEqual(
          error as? ProductReviewsSourceError,
          .invalidProductHandle
        )
      }
    }
  }

  func testPageRequestUsesExactJudgeMeContractAndSortMapping()
    throws
  {
    XCTAssertEqual(
      try ProductReviewsSource.pageURL(
        productID: "9204922384643",
        page: 2,
        perPage: 5,
        sort: .mostRecent
      ).absoluteString,
      "https://api.judge.me/reviews/reviews_for_widget?url=beautyontapp.com&shop_domain=beautyontapp.com&platform=shopify&page=2&per_page=5&product_id=9204922384643&sort_by=created_at&sort_dir=desc"
    )
    XCTAssertEqual(
      try ProductReviewsSource.pageURL(
        productID: "9204922384643",
        page: 1,
        perPage: 5,
        sort: .mostHelpful
      ).absoluteString,
      "https://api.judge.me/reviews/reviews_for_widget?url=beautyontapp.com&shop_domain=beautyontapp.com&platform=shopify&page=1&per_page=5&product_id=9204922384643&sort_by=most_helpful"
    )

    for productID in [
      "",
      "not-a-number",
      "١٢٣٤",
      String(repeating: "1", count: 33),
    ] {
      XCTAssertThrowsError(
        try ProductReviewsSource.pageURL(
          productID: productID,
          page: 1,
          perPage: 5,
          sort: .mostRecent
        )
      )
    }
    XCTAssertThrowsError(
      try ProductReviewsSource.pageURL(
        productID: "9204922384643",
        page: 0,
        perPage: 5,
        sort: .mostRecent
      )
    )
    XCTAssertThrowsError(
      try ProductReviewsSource.pageURL(
        productID: "9204922384643",
        page: 1,
        perPage: 101,
        sort: .mostRecent
      )
    )
  }

  func testWriteReviewUsesVerifiedThemeAnchorAndRejectsUnsafeHandle()
    throws
  {
    XCTAssertEqual(
      try ProductReviewSubmissionFlow.requestURL(
        forProductHandle: "niacinamide-body-lotion"
      ).absoluteString,
      "https://beautyontapp.com/products/niacinamide-body-lotion#judgeme_product_reviews"
    )
    XCTAssertThrowsError(
      try ProductReviewSubmissionFlow.requestURL(
        forProductHandle: "../account"
      )
    )
  }

  func testSourceFetchesFirstPartyHTMLAndCachesResult() async throws {
    let recorder = ProductReviewsRequestRecorder()
    let fixtureData = Data(try fixture().utf8)
    ProductReviewsURLProtocol.response = { request in
      recorder.record(request)
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: [
          "Content-Type": "text/html; charset=utf-8"
        ]
      )!
      return (response, fixtureData)
    }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [ProductReviewsURLProtocol.self]
    let source = ProductReviewsSource(
      session: URLSession(configuration: configuration),
      cacheLifetime: 60
    )

    let first = try await source.reviews(
      forProductHandle: "fixture-product"
    )
    let second = try await source.reviews(
      forProductHandle: "fixture-product"
    )

    XCTAssertEqual(first, second)
    XCTAssertEqual(recorder.requests.count, 1)
    let request = try XCTUnwrap(recorder.requests.first)
    XCTAssertEqual(
      request.url?.absoluteString,
      "https://beautyontapp.com/products/fixture-product"
    )
    XCTAssertEqual(
      request.value(forHTTPHeaderField: "Accept"),
      "text/html,application/xhtml+xml"
    )
  }

  func testSourceLoadsPageAndMergeDeduplicatesReviewIDs()
    async throws
  {
    let recorder = ProductReviewsRequestRecorder()
    let pageData = try pageFixtureData()
    ProductReviewsURLProtocol.response = { request in
      recorder.record(request)
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: [
          "Content-Type": "application/json; charset=utf-8"
        ]
      )!
      return (response, pageData)
    }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [ProductReviewsURLProtocol.self]
    let source = ProductReviewsSource(
      session: URLSession(configuration: configuration)
    )
    let firstPage = try ProductReviewsHTMLParser.parse(
      html: try fixture()
    )
    let pagination = try XCTUnwrap(firstPage.pagination)

    let secondPage = try await source.reviewPage(
      for: pagination,
      page: 2,
      sort: .lowestRating
    )
    let merged = firstPage.merging(
      secondPage,
      replacingCurrentReviews: false
    )

    XCTAssertEqual(secondPage.page, 2)
    XCTAssertEqual(secondPage.totalCount, 8)
    XCTAssertEqual(
      secondPage.reviews.map(\.id),
      ["fixture-review-two", "fixture-review-three"]
    )
    XCTAssertEqual(
      merged.reviews.map(\.id),
      [
        "fixture-review-one",
        "fixture-review-two",
        "fixture-review-three",
      ]
    )
    XCTAssertEqual(Set(merged.reviews.map(\.id)).count, 3)
    XCTAssertEqual(merged.pagination?.currentPage, 2)
    XCTAssertEqual(merged.pagination?.totalCount, 8)

    let request = try XCTUnwrap(recorder.requests.first)
    XCTAssertEqual(
      request.url?.absoluteString,
      "https://api.judge.me/reviews/reviews_for_widget?url=beautyontapp.com&shop_domain=beautyontapp.com&platform=shopify&page=2&per_page=5&product_id=9204922384643&sort_by=rating&sort_dir=asc"
    )
    XCTAssertEqual(
      request.value(forHTTPHeaderField: "Accept"),
      "application/json"
    )
  }

  func testMergeReplacesCurrentPageWhenSortingAndDeduplicates()
    throws
  {
    let document = try ProductReviewsHTMLParser.parse(
      html: try fixture()
    )
    let duplicate = try XCTUnwrap(document.reviews.first)
    let replacement = ProductReview(
      id: "sorted-review",
      rating: 1,
      author: "Sorted Customer",
      isVerifiedBuyer: true,
      publishedAt: nil,
      title: "Sorted first",
      body: nil,
      merchantReply: nil
    )

    let sorted = document.merging(
      ProductReviewsPage(
        page: 1,
        totalCount: 8,
        reviews: [replacement, duplicate, replacement]
      ),
      replacingCurrentReviews: true
    )

    XCTAssertEqual(
      sorted.reviews.map(\.id),
      ["sorted-review", "fixture-review-one"]
    )
    XCTAssertEqual(sorted.pagination?.currentPage, 1)
  }

  func testPageParserRequiresJudgeMeContainerAndStableReviewIDs() throws {
    XCTAssertThrowsError(
      try ProductReviewsHTMLParser.parsePage(
        html: "<div class='jdgm-rev'></div>"
      )
    ) { error in
      XCTAssertEqual(
        error as? ProductReviewsSourceError,
        .invalidResponse
      )
    }

    let reviews = try ProductReviewsHTMLParser.parsePage(
      html: """
        <div class="jdgm-rev-widg__reviews">
          <div class="jdgm-rev">
            <span class="jdgm-rev__rating" data-score="5"></span>
          </div>
        </div>
        """
    )
    XCTAssertTrue(reviews.isEmpty)
  }

  func testSourceRejectsPageResponseFromUnverifiedHost()
    async throws
  {
    let pageData = try pageFixtureData()
    ProductReviewsURLProtocol.response = { _ in
      let response = HTTPURLResponse(
        url: URL(
          string:
            "https://example.com/reviews/reviews_for_widget"
        )!,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: [
          "Content-Type": "application/json; charset=utf-8"
        ]
      )!
      return (response, pageData)
    }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [ProductReviewsURLProtocol.self]
    let source = ProductReviewsSource(
      session: URLSession(configuration: configuration)
    )

    do {
      _ = try await source.reviewPage(
        for: ProductReviewsPagination(
          productID: "9204922384643",
          perPage: 5,
          currentPage: 1,
          totalCount: 8
        ),
        page: 2,
        sort: .mostRecent
      )
      XCTFail("Expected an invalid response.")
    } catch {
      XCTAssertEqual(
        error as? ProductReviewsSourceError,
        .invalidResponse
      )
    }
  }

  func testSourceRejectsRedirectToAPathOutsideTheProduct()
    async throws
  {
    let fixtureData = Data(try fixture().utf8)
    ProductReviewsURLProtocol.response = { _ in
      let response = HTTPURLResponse(
        url: URL(string: "https://beautyontapp.com/account")!,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: [
          "Content-Type": "text/html; charset=utf-8"
        ]
      )!
      return (response, fixtureData)
    }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [ProductReviewsURLProtocol.self]
    let source = ProductReviewsSource(
      session: URLSession(configuration: configuration)
    )

    do {
      _ = try await source.reviews(
        forProductHandle: "fixture-product"
      )
      XCTFail("Expected an invalid response.")
    } catch {
      XCTAssertEqual(
        error as? ProductReviewsSourceError,
        .invalidResponse
      )
    }
  }

  private func fixture() throws -> String {
    let bundle = Bundle(for: Self.self)
    let url =
      bundle.url(
        forResource: "product-reviews",
        withExtension: "html",
        subdirectory: "Fixtures"
      )
      ?? bundle.url(
        forResource: "product-reviews",
        withExtension: "html"
      )
    return try String(
      contentsOf: XCTUnwrap(url),
      encoding: .utf8
    )
  }

  private func pageFixtureData() throws -> Data {
    let bundle = Bundle(for: Self.self)
    let url =
      bundle.url(
        forResource: "product-reviews-page-2",
        withExtension: "json",
        subdirectory: "Fixtures"
      )
      ?? bundle.url(
        forResource: "product-reviews-page-2",
        withExtension: "json"
      )
    return try Data(contentsOf: XCTUnwrap(url))
  }
}

private final class ProductReviewsRequestRecorder:
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

private final class ProductReviewsURLProtocol: URLProtocol {
  nonisolated(unsafe) static var response: ((URLRequest) throws -> (HTTPURLResponse, Data))?

  override class func canInit(
    with request: URLRequest
  ) -> Bool {
    true
  }

  override class func canonicalRequest(
    for request: URLRequest
  ) -> URLRequest {
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
