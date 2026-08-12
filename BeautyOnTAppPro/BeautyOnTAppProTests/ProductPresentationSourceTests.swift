import XCTest

@testable import BeautyOnTAppPro

final class ProductPresentationSourceTests: XCTestCase {
  private let testMainSectionID = "template--current__main"

  override func tearDown() {
    ProductPresentationURLProtocol.response = nil
    super.tearDown()
  }

  func testDraftPreviewAndSectionRenderingPreserveQueryContract()
    throws
  {
    let pageURL = try XCTUnwrap(
      URL(
        string:
          "https://beautyontapp.com/products/example?variant=123"
      )
    )
    let previewURL = StorefrontThemeSource.applyingDraftTheme(
      to: pageURL,
      themeID: "163013951747"
    )
    let renderedURL = try StorefrontSectionResolver.sectionRenderingURL(
      pageURL: previewURL,
      sectionIDs: [testMainSectionID]
    )
    let items = try XCTUnwrap(
      URLComponents(
        url: renderedURL,
        resolvingAgainstBaseURL: false
      )?.queryItems
    )

    XCTAssertEqual(
      items.first { $0.name == "variant" }?.value,
      "123"
    )
    XCTAssertEqual(
      items.first { $0.name == "preview_theme_id" }?.value,
      "163013951747"
    )
    XCTAssertEqual(
      items.first { $0.name == "sections" }?.value,
      testMainSectionID
    )
  }

  func testParserReadsOnlySourcedProductPresentationFields() throws {
    let presentation = ProductPresentationHTMLParser.parse(
      html: """
        <div data-average-rating="1.00"
             data-number-of-reviews="999">
          Not a Judge.me badge
        </div>
        <div class="fake-jdgm-prev-badge"
             data-average-rating="1.00"
             data-number-of-reviews="999">
          Not the exact Judge.me class token
        </div>
        <div class="jdgm-widget">
          <div class="jdgm-prev-badge is-loaded"
               data-average-rating="4.25"
               data-number-of-reviews="323">
          </div>
        </div>
        <div class="fake-custom-product-tap-main">
          <strong>Wrong suffix-token price</strong>
          <span class="product-custom-tap-highlight">
            Wrong suffix-token installment
          </span>
        </div>
        <div class="custom-product-tap-main">
          <div class="layout-wrapper">
            <strong>R 325.00</strong>
            <span class="product-custom-tap-highlight">
              or <b>4 payments of R 81.25</b>
            </span>
          </div>
          <span class="cstm-tap-wallet-label">
            Pay your way at checkout
          </span>
          <span class="cstm-tap-wallets"
                aria-label="Payment options available at checkout">
            <button class="cstm-tap-wallet-badge"
                    aria-label="Learn more about Provider One">
              <img
                src="//beautyontapp.com/cdn/shop/files/provider.png?x=1&amp;width=100"
                alt="">
            </button>
            <span class="cstm-tap-wallet-badge"
                  role="img"
                  aria-label="Provider Two">
              <svg><title>Provider Two</title></svg>
            </span>
            <span class="cstm-tap-wallet-badge"
                  role="img"
                  aria-label="Apple Pay">
              <svg viewBox="0 0 38 24">
                <title>Apple Pay</title>
                <path fill="#000" d="M0 0h38v24H0z"></path>
              </svg>
            </span>
            <span class="cstm-tap-wallet-badge"
                  role="img"
                  aria-label="Google Pay">
              <svg viewBox="0 0 38 24">
                <title>Google Pay</title>
                <path fill="#4285F4" d="M0 0h38v24H0z"></path>
              </svg>
            </span>
            <span class="cstm-tap-wallet-badge"
                  role="img"
                  aria-label="Provider Three">
              <img src="http://beautyontapp.com/provider-three.png">
            </span>
            <span class="fake-cstm-tap-wallet-badge"
                  role="img"
                  aria-label="Wrong suffix-token provider">
            </span>
          </span>
        </div>
        <div class="custom-product-tap-main">
          <strong>R 1.00</strong>
          <span class="product-custom-tap-highlight">
            Wrong duplicate block
          </span>
        </div>
        """
    )

    XCTAssertEqual(
      presentation.reviewSummary,
      ProductReviewSummary(
        averageRating: 4.25,
        reviewCount: 323
      )
    )
    XCTAssertEqual(
      presentation.installmentSummary,
      ProductInstallmentSummary(
        priceText: "R 325.00",
        paymentText: "or 4 payments of R 81.25",
        walletHeading: "Pay your way at checkout"
      )
    )
    XCTAssertEqual(
      presentation.walletProviders.map(\.accessibilityLabel),
      [
        "Learn more about Provider One",
        "Provider Two",
        "Apple Pay",
        "Google Pay",
        "Provider Three",
      ]
    )
    XCTAssertEqual(
      presentation.walletProviders[0].imageURL?.scheme,
      "https"
    )
    XCTAssertEqual(
      presentation.walletProviders[0].imageURL?.host,
      "beautyontapp.com"
    )
    XCTAssertEqual(
      URLComponents(
        url: try XCTUnwrap(
          presentation.walletProviders[0].imageURL
        ),
        resolvingAgainstBaseURL: false
      )?.queryItems?.last?.value,
      "100"
    )
    XCTAssertNil(presentation.walletProviders[1].imageURL)
    XCTAssertNil(presentation.walletProviders[1].nativeMark)
    XCTAssertEqual(
      presentation.walletProviders[2].nativeMark,
      .applePay
    )
    XCTAssertEqual(
      presentation.walletProviders[3].nativeMark,
      .googlePay
    )
    XCTAssertNil(
      presentation.walletProviders[4].imageURL,
      "An insecure provider image must fail closed."
    )
    XCTAssertNil(presentation.walletProviders[4].nativeMark)
  }

  func testInlineWalletMarkRequiresMatchingSourcedTitle() {
    let presentation = ProductPresentationHTMLParser.parse(
      html: """
        <div class="custom-product-tap-main">
          <strong>R 10.00</strong>
          <span class="product-custom-tap-highlight">
            sourced payment text
          </span>
          <span class="cstm-tap-wallet-badge"
                role="img"
                aria-label="Apple Pay">
            <svg>
              <title>Google Pay</title>
              <path d="M0 0h1v1z"></path>
            </svg>
          </span>
          <span class="cstm-tap-wallet-badge"
                role="img"
                aria-label="Unknown Wallet">
            <svg>
              <title>Unknown Wallet</title>
              <path d="M0 0h1v1z"></path>
            </svg>
          </span>
          <span class="cstm-tap-wallet-badge"
                role="img"
                aria-label="Google Pay">
            <img src="/cdn/shop/files/google-pay.png">
            <svg>
              <title>Google Pay</title>
              <path d="M0 0h1v1z"></path>
            </svg>
          </span>
        </div>
        """
    )

    XCTAssertEqual(presentation.walletProviders.count, 3)
    XCTAssertNil(presentation.walletProviders[0].nativeMark)
    XCTAssertNil(presentation.walletProviders[1].nativeMark)
    XCTAssertNotNil(presentation.walletProviders[2].imageURL)
    XCTAssertNil(presentation.walletProviders[2].nativeMark)
  }

  func testParserAssociatesExactProviderTargetWithSourcedPanel() throws {
    let presentation = ProductPresentationHTMLParser.parse(
      html: """
        <div class="custom-product-tap-main">
          <strong>R 325.00</strong>
          <span class="product-custom-tap-highlight">
            or <b>4 payments of R 81.25</b>
          </span>
          <span class="cstm-tap-wallet-label">
            Pay your way at checkout
          </span>
          <span class="cstm-tap-wallets">
            <button
              type="button"
              class="cstm-tap-wallet-badge cstm-tap-wallet-badge--provider cstm-tap-pay"
              data-tap-target="option-1"
              aria-label="Learn more about Payflex"
            >
              <img
                src="//beautyontapp.com/cdn/shop/files/payflex.png?width=100"
                alt="Payflex">
            </button>
            <span class="cstm-tap-wallet-badge"
                  role="img"
                  aria-label="Apple Pay">
              <svg><title>Apple Pay</title></svg>
            </span>
          </span>
        </div>

        <div class="fake-cstm-tap-modal"
             id="cstmTapModal"
             role="dialog">
          <span id="cstmTapModalTitle"
                class="cstm-tap-modal-title">
            Decoy title
          </span>
        </div>

        <div class="cstm-tap-modal"
             id="cstmTapModal"
             role="dialog"
             aria-modal="true">
          <div class="cstm-tap-modal-header">
            <span id="cstmTapModalTitle"
                  class="cstm-tap-modal-title">
              Shop Now Pay Later
            </span>
          </div>
          <div class="cstm-tap-panel"
               id="cstm-tap-panel-option-1"
               role="tabpanel"
               hidden>
            <div class="cstm-tap-panel-icon">
              <img
                src="//beautyontapp.com/cdn/shop/files/payflex.png?width=160"
                alt="Payflex">
            </div>
            <h3>Shop now. Pay later.</h3>
            <div class="cstm-tap-panel-subheading">
              <p>Split your purchase into 4 interest-free payments.</p>
            </div>
            <ol>
              <li>Add items to your cart</li>
              <li>Select this option at checkout</li>
              <li>Complete your purchase in 4 easy payments</li>
            </ol>
            <small>
              <p>Terms and conditions apply. See provider website for full details.</p>
            </small>
            <a class="cstm-tap-learn-link"
               href="https://payflex.co.za/"
               target="_blank"
               rel="noopener">
              Learn more
            </a>
            <button class="cstm-tap-got-it">Got It</button>
          </div>
        </div>
        """
    )

    XCTAssertEqual(presentation.walletProviders.count, 2)
    let payflex = try XCTUnwrap(
      presentation.walletProviders.first
    )
    XCTAssertTrue(payflex.isInteractive)
    let information = try XCTUnwrap(payflex.information)
    XCTAssertEqual(information.modalTitle, "Shop Now Pay Later")
    XCTAssertEqual(
      information.logoURL?.absoluteString,
      "https://beautyontapp.com/cdn/shop/files/payflex.png?width=160"
    )
    XCTAssertEqual(information.heading, "Shop now. Pay later.")
    XCTAssertEqual(
      information.subheading,
      "Split your purchase into 4 interest-free payments."
    )
    XCTAssertEqual(
      information.steps,
      [
        "Add items to your cart",
        "Select this option at checkout",
        "Complete your purchase in 4 easy payments",
      ]
    )
    XCTAssertEqual(
      information.caption,
      "Terms and conditions apply. See provider website for full details."
    )
    XCTAssertEqual(information.ctaLabel, "Learn more")
    XCTAssertEqual(
      information.ctaURL?.absoluteString,
      "https://payflex.co.za/"
    )

    XCTAssertFalse(presentation.walletProviders[1].isInteractive)
    XCTAssertNil(presentation.walletProviders[1].information)
  }

  func testProviderInteractionFailsClosedForMismatchAndUnsafeCTA() {
    let presentation = ProductPresentationHTMLParser.parse(
      html: """
        <div class="custom-product-tap-main">
          <strong>R 325.00</strong>
          <span class="product-custom-tap-highlight">
            or 4 payments
          </span>
          <button class="cstm-tap-wallet-badge"
                  data-tap-target="option-2"
                  aria-label="Mismatched Provider">
            Provider
          </button>
          <button class="cstm-tap-wallet-badge"
                  data-tap-target="option-1"
                  aria-label="Unsafe Link Provider">
            Provider
          </button>
        </div>
        <div class="cstm-tap-modal"
             id="cstmTapModal"
             role="dialog">
          <span id="cstmTapModalTitle"
                class="cstm-tap-modal-title">
            Payment information
          </span>
          <div class="cstm-tap-panel"
               id="cstm-tap-panel-option-1"
               role="tabpanel">
            <h3>Sourced heading</h3>
            <a class="cstm-tap-learn-link"
               href="https://user@payflex.co.za/">
              Unsafe destination
            </a>
          </div>
        </div>
        """
    )

    XCTAssertEqual(presentation.walletProviders.count, 2)
    XCTAssertFalse(presentation.walletProviders[0].isInteractive)
    XCTAssertNil(presentation.walletProviders[0].information)

    XCTAssertTrue(presentation.walletProviders[1].isInteractive)
    XCTAssertEqual(
      presentation.walletProviders[1].information?.heading,
      "Sourced heading"
    )
    XCTAssertNil(
      presentation.walletProviders[1].information?.ctaLabel
    )
    XCTAssertNil(
      presentation.walletProviders[1].information?.ctaURL
    )
  }

  func testExternalProviderURLValidationRequiresSafeHTTPS() {
    XCTAssertEqual(
      ProductPresentationHTMLParser.verifiedExternalHTTPSURL(
        "https://payflex.co.za/"
      )?.absoluteString,
      "https://payflex.co.za/"
    )

    for source in [
      "http://payflex.co.za/",
      "javascript:alert(1)",
      "/relative",
      "//payflex.co.za/path",
      "https://user@payflex.co.za/",
      "https://payflex.co.za:444/",
      #"https://payflex.co.za/\evil"#,
    ] {
      XCTAssertNil(
        ProductPresentationHTMLParser
          .verifiedExternalHTTPSURL(source),
        "Expected external URL rejection for \(source)"
      )
    }
  }

  func testWalletUIModelOnlyEnablesSourcedRenderablePanels() {
    let emptyInformation = ProductWalletProviderInformation(
      modalTitle: "Payment information",
      logoURL: nil,
      heading: nil,
      subheading: nil,
      steps: [],
      caption: nil,
      ctaLabel: nil,
      ctaURL: nil
    )
    let noninteractive = ProductWalletProvider(
      id: "static-mark",
      accessibilityLabel: "Apple Pay",
      imageURL: nil,
      nativeMark: .applePay,
      information: emptyInformation
    )
    XCTAssertFalse(noninteractive.isInteractive)

    let sourcedInformation = ProductWalletProviderInformation(
      modalTitle: "Shop Now Pay Later",
      logoURL: nil,
      heading: "Shop now. Pay later.",
      subheading: nil,
      steps: [],
      caption: nil,
      ctaLabel: nil,
      ctaURL: nil
    )
    let interactive = ProductWalletProvider(
      id: "provider",
      accessibilityLabel: "Learn more about Payflex",
      imageURL: nil,
      nativeMark: nil,
      information: sourcedInformation
    )
    XCTAssertTrue(interactive.isInteractive)
  }

  func testParserReadsExactRenderedDeliveryEstimate() {
    let presentation = ProductPresentationHTMLParser.parse(
      html: """
        <aside class="fake-bot-delivery-estimate">
          <span class="bot-delivery-estimate__eyebrow">
            Wrong label
          </span>
          <strong class="bot-delivery-estimate__heading">
            Wrong heading
          </strong>
          <span class="bot-delivery-estimate__text">
            Wrong message
          </span>
        </aside>
        <aside class="bot-delivery-estimate">
          <span class="bot-delivery-estimate__icon"
                aria-hidden="true">
            <svg></svg>
          </span>
          <span class="bot-delivery-estimate__copy">
            <span class="bot-delivery-estimate__eyebrow">
              Estimated delivery
            </span>
            <strong class="bot-delivery-estimate__heading">
              Your glow, on the way
            </strong>
            <span class="bot-delivery-estimate__text">
              Delivery from R60 · final options shown at checkout.
            </span>
          </span>
        </aside>
        """
    )

    XCTAssertEqual(
      presentation.deliveryEstimate,
      ProductDeliveryEstimate(
        eyebrow: "Estimated delivery",
        heading: "Your glow, on the way",
        message:
          "Delivery from R60 · final options shown at checkout."
      )
    )
  }

  func testDeliveryFallbackContainsNoHardcodedTariff() {
    let fallback = ProductDeliveryEstimate.nonVolatileFallback

    XCTAssertEqual(fallback.eyebrow, "Estimated delivery")
    XCTAssertEqual(fallback.heading, "Your glow, on the way")
    XCTAssertEqual(
      fallback.message,
      "Final options shown at checkout."
    )
    XCTAssertFalse(fallback.message.localizedCaseInsensitiveContains("R60"))

    let incomplete = ProductPresentationHTMLParser.parse(
      html: """
        <aside class="bot-delivery-estimate">
          <span class="bot-delivery-estimate__eyebrow">
            Estimated delivery
          </span>
          <strong class="bot-delivery-estimate__heading">
            Your glow, on the way
          </strong>
        </aside>
        """
    )
    XCTAssertNil(incomplete.deliveryEstimate)
  }

  func testSourceAuditedProductMetricsRemainStable() {
    XCTAssertEqual(ProductDetailMetrics.galleryHeight, 240)
    XCTAssertEqual(
      ProductDetailMetrics.wishlistVisualFootprint,
      20
    )
    XCTAssertEqual(ProductDetailMetrics.wishlistHitTarget, 44)
    XCTAssertEqual(ProductDetailMetrics.optionHeight, 32)
    XCTAssertEqual(ProductDetailMetrics.quantityHeight, 48)
    XCTAssertEqual(ProductDetailMetrics.commerceButtonHeight, 50)
    XCTAssertEqual(ProductDetailMetrics.deliveryIconSize, 38)
    XCTAssertEqual(ResourceLinkRailMetrics.railHeight, 44)
    XCTAssertEqual(ResourceLinkRailMetrics.breadcrumbHeight, 30)
    XCTAssertEqual(ResourceLinkRailMetrics.fontSize, 14)
  }

  func testParserRejectsInvalidReviewValuesAndUnverifiedImages() {
    let presentation = ProductPresentationHTMLParser.parse(
      html: """
        <div class="jdgm-prev-badge"
             data-average-rating="5.01"
             data-number-of-reviews="-2"></div>
        <div class="custom-product-tap-main">
          <strong>R 10.00</strong>
          <span class="product-custom-tap-highlight">
            sourced payment text
          </span>
          <button class="cstm-tap-wallet-badge"
                  aria-label="Outside Host">
            <img src="https://attacker.example/provider.png">
          </button>
        </div>
        """
    )

    XCTAssertNil(presentation.reviewSummary)
    XCTAssertEqual(presentation.walletProviders.count, 1)
    XCTAssertNil(presentation.walletProviders[0].imageURL)

    let rejectedSources = [
      "http://beautyontapp.com/provider.png",
      "https://attacker.example/provider.png",
      "https://www.beautyontapp.com/provider.png",
      "https://beautyontapp.com.attacker.example/provider.png",
      "https://user@beautyontapp.com/provider.png",
      "https://beautyontapp.com:444/provider.png",
      "javascript:alert(1)",
      #"//attacker.example/provider.png"#,
      #"/\attacker.example/provider.png"#,
    ]

    for source in rejectedSources {
      XCTAssertNil(
        ProductPresentationHTMLParser.verifiedImageURL(source),
        "Expected rejection for \(source)"
      )
    }
  }

  func testParserBoundsWalletItemsAndResponseHTML() throws {
    let walletHTML = (0..<12).map { index in
      """
      <span class="cstm-tap-wallet-badge"
            aria-label="Provider \(index)">
      </span>
      """
    }.joined()
    let presentation = ProductPresentationHTMLParser.parse(
      html: """
        <div class="custom-product-tap-main">
          <strong>Source price</strong>
          <span class="product-custom-tap-highlight">
            Source installment
          </span>
          \(walletHTML)
        </div>
        """
    )

    XCTAssertEqual(presentation.walletProviders.count, 8)
    XCTAssertEqual(
      presentation.walletProviders.last?.accessibilityLabel,
      "Provider 7"
    )

    let oversizedHTML = String(
      repeating: "x",
      count: 1_500_001
    )
    let oversizedPayload = try sectionPayload(html: oversizedHTML)
    XCTAssertThrowsError(
      try ProductPresentationSectionDecoder.decode(
        data: oversizedPayload,
        sectionID: testMainSectionID
      )
    ) { error in
      XCTAssertEqual(
        error as? ProductPresentationSourceError,
        .invalidResponse
      )
    }
  }

  func testSectionDecoderRequiresDiscoveredMainSectionKey() throws {
    let validPayload = try sectionPayload(
      html: """
        <div class="jdgm-prev-badge"
             data-average-rating="4.00"
             data-number-of-reviews="5"></div>
        """
    )
    let valid = try ProductPresentationSectionDecoder.decode(
      data: validPayload,
      sectionID: testMainSectionID
    )
    XCTAssertEqual(valid.reviewSummary?.averageRating, 4)
    XCTAssertEqual(valid.reviewSummary?.reviewCount, 5)

    let wrongKey = try JSONSerialization.data(
      withJSONObject: [
        "product": """
        <div class="jdgm-prev-badge"
             data-average-rating="4.00"
             data-number-of-reviews="5"></div>
        """
      ]
    )
    XCTAssertThrowsError(
      try ProductPresentationSectionDecoder.decode(
        data: wrongKey,
        sectionID: testMainSectionID
      )
    ) { error in
      XCTAssertEqual(
        error as? ProductPresentationSourceError,
        .invalidResponse
      )
    }
  }

  func testPageURLUsesProductRouteWithoutVolatileSectionID()
    throws
  {
    let url = try ProductPresentationSource.pageURL(
      forProductHandle: "niacinamide-body-lotion"
    )

    XCTAssertEqual(url.scheme, "https")
    XCTAssertEqual(url.host, "beautyontapp.com")
    XCTAssertEqual(
      url.path,
      "/products/niacinamide-body-lotion"
    )
    XCTAssertNil(url.query)

    for unsafeHandle in [
      "",
      "../account",
      "product?view=ajax",
      "product/variant",
      String(repeating: "a", count: 256),
    ] {
      XCTAssertThrowsError(
        try ProductPresentationSource.pageURL(
          forProductHandle: unsafeHandle
        )
      ) { error in
        XCTAssertEqual(
          error as? ProductPresentationSourceError,
          .invalidProductHandle
        )
      }
    }
  }

  func testClientUsesDocumentRepresentationAndBoundedTTLCache()
    async throws
  {
    let recorder = ProductPresentationRequestRecorder()
    let payload = try sectionPayload(
      html: """
        <div class="jdgm-prev-badge"
             data-average-rating="4.75"
             data-number-of-reviews="28"></div>
        """
    )
    let source = makeSource(
      payload: payload,
      recorder: recorder
    )

    let first = try await source.presentation(
      forProductHandle: "verified-product"
    )
    let second = try await source.presentation(
      forProductHandle: "verified-product"
    )

    XCTAssertEqual(first, second)
    XCTAssertEqual(recorder.requests.count, 1)
    XCTAssertEqual(
      recorder.requests[0].value(
        forHTTPHeaderField: "Accept"
      ),
      "text/html"
    )
    XCTAssertEqual(
      recorder.requests[0].url?.query,
      "sections=\(testMainSectionID)"
    )

    _ = try await source.presentation(
      forProductHandle: "verified-product",
      forceRefresh: true
    )
    XCTAssertEqual(recorder.requests.count, 2)
  }

  func testMainSectionDiscoveryUsesCurrentSemanticWrapper() throws {
    let section = try XCTUnwrap(
      StorefrontSectionDocumentParser.section(
        in: productDocument(
          sectionID: testMainSectionID,
          rating: "4.75",
          count: "28"
        ),
        purpose: .mainProduct
      )
    )

    XCTAssertEqual(section.id, testMainSectionID)
    let presentation = try ProductPresentationSectionDecoder.decode(
      html: section.html
    )
    XCTAssertEqual(presentation.reviewSummary?.averageRating, 4.75)
    XCTAssertEqual(presentation.reviewSummary?.reviewCount, 28)
  }

  func testStaleNullMainSectionFallsBackToCurrentDocument()
    async throws
  {
    let recorder = ProductPresentationRequestRecorder()
    let staleID = "template--stale__main"
    let currentID = testMainSectionID
    let document = productDocument(
      sectionID: currentID,
      rating: "4.80",
      count: "42"
    )

    ProductPresentationURLProtocol.response = { request in
      recorder.record(request)
      let url = try XCTUnwrap(request.url)
      if url.query != nil {
        let response = HTTPURLResponse(
          url: url,
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!
        return (
          response,
          try JSONSerialization.data(
            withJSONObject: [staleID: NSNull()]
          )
        )
      }

      let response = HTTPURLResponse(
        url: url,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "text/html"]
      )!
      return (response, Data(document.utf8))
    }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [
      ProductPresentationURLProtocol.self
    ]
    let source = ProductPresentationSource(
      session: URLSession(configuration: configuration),
      initialSectionID: staleID,
      previewThemeID: nil
    )

    let presentation = try await source.presentation(
      forProductHandle: "verified-product"
    )

    XCTAssertEqual(presentation.reviewSummary?.averageRating, 4.8)
    XCTAssertEqual(presentation.reviewSummary?.reviewCount, 42)
    XCTAssertEqual(recorder.requests.count, 2)
    XCTAssertTrue(
      recorder.requests[0].url?.query?.contains(staleID) == true
    )
    XCTAssertNil(recorder.requests[1].url?.query)
  }

  func testClientRejectsOversizedOrCrossHostResponses()
    async throws
  {
    let oversized = Data(
      repeating: 0x78,
      count: 2_000_001
    )
    let oversizedSource = makeSource(payload: oversized)

    do {
      _ = try await oversizedSource.presentation(
        forProductHandle: "verified-product"
      )
      XCTFail("Oversized responses must fail closed.")
    } catch {
      XCTAssertEqual(
        error as? ProductPresentationSourceError,
        .responseTooLarge
      )
    }

    let validPayload = try sectionPayload(
      html: """
        <div class="jdgm-prev-badge"
             data-average-rating="4.00"
             data-number-of-reviews="5"></div>
        """
    )
    let crossHostSource = makeSource(
      payload: validPayload,
      responseURL: URL(
        string: "https://attacker.example/products/verified-product"
      )!
    )

    do {
      _ = try await crossHostSource.presentation(
        forProductHandle: "verified-product"
      )
      XCTFail("Cross-host responses must fail closed.")
    } catch {
      XCTAssertEqual(
        error as? ProductPresentationSourceError,
        .invalidResponse
      )
    }
  }

  func testCancelledTaskDoesNotStartPresentationRequest()
    async throws
  {
    let recorder = ProductPresentationRequestRecorder()
    let source = makeSource(
      payload: try sectionPayload(html: "<section></section>"),
      recorder: recorder
    )
    let gate = ProductPresentationTestGate()
    let task = Task {
      await gate.wait()
      return try await source.presentation(
        forProductHandle: "verified-product"
      )
    }

    await gate.waitUntilReady()
    task.cancel()
    await gate.open()

    do {
      _ = try await task.value
      XCTFail("A cancelled presentation load must not continue.")
    } catch is CancellationError {
      XCTAssertTrue(recorder.requests.isEmpty)
    } catch {
      XCTFail("Expected CancellationError, received \(error).")
    }
  }

  private func sectionPayload(html: String) throws -> Data {
    try JSONSerialization.data(
      withJSONObject: [
        testMainSectionID: html
      ]
    )
  }

  private func productDocument(
    sectionID: String,
    rating: String,
    count: String
  ) -> String {
    """
    <html><body>
      <div id="shopify-section-template--current__bot_product_quick_links"
           class="shopify-section">
        <nav data-bot-quick-links>
          <a href="/collections/body-care">Body Care</a>
        </nav>
      </div>
      <section id="shopify-section-\(sectionID)"
               class="shopify-section section-main-product">
        <section class="main-product-template">
          <div class="jdgm-prev-badge"
               data-average-rating="\(rating)"
               data-number-of-reviews="\(count)"></div>
        </section>
      </section>
    </body></html>
    """
  }

  private func makeSource(
    payload: Data,
    responseURL: URL? = nil,
    recorder: ProductPresentationRequestRecorder? = nil
  ) -> ProductPresentationSource {
    ProductPresentationURLProtocol.response = { request in
      recorder?.record(request)
      let url: URL
      if let responseURL {
        url = responseURL
      } else {
        url = try XCTUnwrap(request.url)
      }
      let response = HTTPURLResponse(
        url: url,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!
      return (response, payload)
    }

    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [
      ProductPresentationURLProtocol.self
    ]
    return ProductPresentationSource(
      session: URLSession(configuration: configuration),
      cacheLifetime: 5 * 60,
      initialSectionID: testMainSectionID,
      previewThemeID: nil
    )
  }
}

private final class ProductPresentationRequestRecorder:
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

private actor ProductPresentationTestGate {
  private var isOpen = false
  private var readyContinuations: [CheckedContinuation<Void, Never>] = []
  private var openContinuations: [CheckedContinuation<Void, Never>] = []

  func wait() async {
    guard !isOpen else { return }

    for continuation in readyContinuations {
      continuation.resume()
    }
    readyContinuations.removeAll()

    await withCheckedContinuation { continuation in
      openContinuations.append(continuation)
    }
  }

  func waitUntilReady() async {
    guard !isOpen,
      openContinuations.isEmpty
    else {
      return
    }

    await withCheckedContinuation { continuation in
      readyContinuations.append(continuation)
    }
  }

  func open() {
    isOpen = true
    for continuation in openContinuations {
      continuation.resume()
    }
    openContinuations.removeAll()
    for continuation in readyContinuations {
      continuation.resume()
    }
    readyContinuations.removeAll()
  }
}

private final class ProductPresentationURLProtocol: URLProtocol {
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
