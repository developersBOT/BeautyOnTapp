@preconcurrency import WebKit
import XCTest

@testable import BeautyOnTAppPro

final class NativeParityTests: XCTestCase {
  func testNativePreviewHeroMatchesDraftThemeOrderAndImages() throws {
    var previewSlides: [ThemeHeroSlide]?
    for section in ThemeHomeSnapshot.preview.sections {
      if case .hero(_, let slides) = section {
        previewSlides = slides
        break
      }
    }
    let slides = try XCTUnwrap(previewSlides)

    XCTAssertEqual(
      slides.map { $0.heading },
      [
        "Sun, Meet Your Match",
        "Fade Dark Marks, Every Wash",
        "The Pore Care Edit",
        "Fresh From Seoul",
      ]
    )
    XCTAssertEqual(
      slides.first?.imageReference,
      "shopify://shop_images/surface.jpg"
    )
    XCTAssertFalse(
      slides.contains { $0.heading == "Glazed & Hydrated" },
      "The removed draft campaign must not remain in the preview hero."
    )
  }

  func testNativeBuildUsesThePublishedStorefrontTheme() {
    XCTAssertNil(
      StorefrontThemeSource.activeDraftThemeID(
        bundleIdentifier: "com.beautyontapp.ios.com.nativepreview"
      )
    )
  }

  func testShopifyNumericIDsRejectUnverifiedOrMalformedGIDs() {
    XCTAssertEqual(
      ShopifyNumericID.product(
        from: "gid://shopify/Product/8929366212867"
      ),
      "8929366212867"
    )
    XCTAssertEqual(
      ShopifyNumericID.variant(
        from: "gid://shopify/ProductVariant/46726252003587"
      ),
      "46726252003587"
    )

    XCTAssertNil(
      ShopifyNumericID.variant(
        from: "gid://shopify/ProductVariant/46726<script>"
      )
    )
    XCTAssertNil(
      ShopifyNumericID.variant(
        from: "gid://shopify/Product/46726252003587"
      )
    )
    XCTAssertNil(
      ShopifyNumericID.product(
        from: "gid://shopify/Product/0001"
      )
    )
    XCTAssertNil(ShopifyNumericID.product(from: "8929366212867"))
  }

  func testWishlistReadbackRequiresVerifiedIntegralVendorState() {
    let readback = WishlistBridge.parseReadback(
      [
        "verified": true,
        "count": NSNumber(value: 2),
        "variantID": "46726252003587",
        "isSaved": true,
      ],
      expectedVariantID: "46726252003587"
    )

    XCTAssertEqual(
      readback,
      WishlistReadback(
        count: 2,
        variantID: "46726252003587",
        isSaved: true
      )
    )
    XCTAssertNil(
      WishlistBridge.parseReadback(
        [
          "verified": false,
          "count": NSNumber(value: 2),
        ],
        expectedVariantID: nil
      )
    )
    XCTAssertNil(
      WishlistBridge.parseReadback(
        [
          "verified": true,
          "count": NSNumber(value: 2.5),
        ],
        expectedVariantID: nil
      )
    )
    XCTAssertNil(
      WishlistBridge.parseReadback(
        [
          "verified": true,
          "count": NSNumber(value: 2),
          "variantID": "different",
          "isSaved": true,
        ],
        expectedVariantID: "46726252003587"
      )
    )
  }

  func testWishlistBridgeOnlyAllowsExactStorefrontRoot() throws {
    XCTAssertTrue(
      WishlistBridge.isExactStorefrontRoot(
        try XCTUnwrap(URL(string: "https://beautyontapp.com/"))
      )
    )
    XCTAssertFalse(
      WishlistBridge.isExactStorefrontRoot(
        try XCTUnwrap(URL(string: "https://www.beautyontapp.com/"))
      )
    )
    XCTAssertFalse(
      WishlistBridge.isExactStorefrontRoot(
        try XCTUnwrap(URL(string: "https://beautyontapp.com/account"))
      )
    )
    XCTAssertFalse(
      WishlistBridge.isExactStorefrontRoot(
        try XCTUnwrap(
          URL(string: "https://beautyontapp.com.attacker.example/")
        )
      )
    )
    XCTAssertFalse(
      WishlistBridge.isExactStorefrontRoot(
        try XCTUnwrap(URL(string: "http://beautyontapp.com/"))
      )
    )
  }

  @MainActor
  func testWishlistBridgeUsesPersistentStoreAndVerifiedCallbacks() {
    let bridge = WishlistBridge()
    let scripts = bridge.webView.configuration.userContentController
      .userScripts
      .map(\.source)
    let combined = scripts.joined(separator: "\n")

    XCTAssertTrue(
      bridge.webView.configuration.websiteDataStore === WKWebsiteDataStore.default()
    )
    XCTAssertTrue(combined.contains("iWishinitFn"))
    XCTAssertTrue(combined.contains("iWishAddFn"))
    XCTAssertTrue(combined.contains("iWishRemoveFn"))
    XCTAssertTrue(combined.contains("window.iWish.getCounter"))
    XCTAssertTrue(combined.contains("window.iWish.isInWishlist"))
    XCTAssertTrue(combined.contains("__botNativeCartProtectionInstalled"))
    XCTAssertFalse(combined.contains("internalapis.myshopapps.com"))
  }

  @MainActor
  func testWishlistDrawerHidesWebCartControlsWithoutThemeMutation() {
    let script = WishlistBridge.visibleDrawerProtectionScript

    XCTAssertTrue(script.contains("#iwish-drawer-root .add_to_cart"))
    XCTAssertTrue(script.contains(".addToCart-btn"))
    XCTAssertTrue(script.contains(".iwish-cartQty"))
    XCTAssertFalse(script.contains("internalapis.myshopapps.com"))
  }

  func testThemeSnapshotPreservesHomepageContract() {
    let sections = ThemeHomeSnapshot.live.sections

    XCTAssertEqual(sections.count, 16)
    XCTAssertEqual(sections.first?.id, "bot_greeting")

    let productRails = sections.compactMap { section -> ThemeProductRail? in
      guard case .productRail(_, let rail) = section else { return nil }
      return rail
    }
    XCTAssertEqual(productRails.count, 6)
    XCTAssertEqual(productRails.first?.heading, "Best Sellers")
    XCTAssertEqual(productRails.first?.collectionHandle, "skincare")
    XCTAssertEqual(productRails.map(\.productCount), Array(repeating: 16, count: 6))
  }

  func testThemeSnapshotPreservesFeaturedBlogContract() throws {
    let section = try XCTUnwrap(
      ThemeHomeSnapshot.bundled.sections.first {
        $0.id == "featured_blog_ftBf6e"
      }
    )
    guard case .blog(_, let blog) = section else {
      return XCTFail("The exported featured blog must stay a blog section.")
    }

    XCTAssertEqual(blog.heading, "Blog posts")
    XCTAssertEqual(blog.handle, "news")
    XCTAssertEqual(blog.linkLabel, "View all")
    XCTAssertEqual(blog.articleCount, 10)
    XCTAssertEqual(blog.gridColumns, 4)
    XCTAssertTrue(blog.isCarousel)
    XCTAssertTrue(blog.showsCategory)
    XCTAssertTrue(blog.isFullWidth)
    XCTAssertEqual(blog.textAlignment, "text-left")
  }

  func testThemeSnapshotPreservesNativeLogoWall() throws {
    let section = try XCTUnwrap(
      ThemeHomeSnapshot.bundled.sections.first {
        $0.id == "logo_list_AmHiiE"
      }
    )
    guard case .logos(_, let rail) = section else {
      return XCTFail("The exported logo wall must stay a logo section.")
    }

    XCTAssertEqual(rail.logos.count, 17)
    XCTAssertEqual(
      rail.logos.first?.imageReference,
      "shopify://shop_images/5.png"
    )
    XCTAssertEqual(
      rail.logos.last?.imageReference,
      "shopify://shop_images/lelive_logo_bw.jpg"
    )
  }

  func testNativeHomeFooterMatchesVerifiedStorefrontMenu() throws {
    XCTAssertEqual(
      NativeHomeFooterContent.benefits.map(\.title),
      [
        "Convenient",
        "Fast Delivery",
        "Wide Variety",
        "Find a BeautyOnTApp",
      ]
    )
    XCTAssertEqual(
      NativeHomeFooterContent.menuColumns.flatMap { $0 }.map(\.title),
      [
        "About Us",
        "Careers",
        "Brands on Beauty on TApp",
        "Blog",
        "Gift Vouchers",
        "Contact us",
        "Ingredient Guide",
        "Privacy Policy",
        "Log Return / Exchange",
        "Sell on Beauty on TApp",
        "Terms of Service",
        "Delivery & Shipping",
      ]
    )
    XCTAssertEqual(
      NativeHomeFooterContent.menuColumns[0][0].link,
      ThemeLink("/pages/about-us")
    )
    XCTAssertEqual(
      NativeHomeFooterContent.menuColumns[1][4].link,
      ThemeLink("/pages/delivery")
    )
    XCTAssertEqual(
      NativeHomeFooterContent.socialLinks.map(\.title),
      ["Facebook", "Instagram", "TikTok", "X"]
    )
  }

  func testFeaturedBlogUsesVerifiedOnlineStoreURLs() async throws {
    let recorder = RequestRecorder()
    let session = mockSession(statusCode: 200, body: Data())
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!
      return (
        response,
        Data(
          """
          {"data":{"blog":{
            "id":"gid://shopify/Blog/1",
            "title":"News",
            "handle":"news",
            "onlineStoreUrl":"https://beautyontapp.com/blogs/news",
            "articles":{"nodes":[{
              "id":"gid://shopify/Article/1",
              "title":"Verified article",
              "handle":"verified-article",
              "tags":["Guide"],
              "publishedAt":"2026-04-11T16:57:07Z",
              "onlineStoreUrl":"https://beautyontapp.com/blogs/news/verified-article",
              "authorV2":{"name":"Verified Author"},
              "excerpt":"Verified excerpt",
              "content":"Verified article content",
              "contentHtml":"<p>Verified article content</p>",
              "image":{
                "url":"https://cdn.shopify.com/article.jpg",
                "altText":"Verified article",
                "width":1024,
                "height":683
              }
            }],
            "pageInfo":{"hasNextPage":true,"endCursor":"cursor-10"}}
          }}}
          """.utf8
        )
      )
    }

    let feed = try await StorefrontClient(session: session).blog(
      handle: "news",
      first: 10
    )

    XCTAssertEqual(feed.handle, "news")
    XCTAssertEqual(
      feed.onlineStoreURL?.absoluteString,
      "https://beautyontapp.com/blogs/news"
    )
    XCTAssertEqual(feed.articles.first?.tags, ["Guide"])
    XCTAssertEqual(feed.articles.first?.blogHandle, "news")
    XCTAssertEqual(
      feed.articles.first?.authorName,
      "Verified Author"
    )
    XCTAssertEqual(
      feed.articles.first?.excerptText,
      "Verified excerpt"
    )
    XCTAssertEqual(
      feed.articles.first?.contentHTML,
      "<p>Verified article content</p>"
    )
    XCTAssertTrue(feed.pageInfo.hasNextPage)
    XCTAssertEqual(feed.pageInfo.endCursor, "cursor-10")
    XCTAssertEqual(
      feed.articles.first?.onlineStoreURL?.absoluteString,
      "https://beautyontapp.com/blogs/news/verified-article"
    )
    XCTAssertNotNil(feed.articles.first?.publishedAt)

    let body = try XCTUnwrap(recorder.bodies.first)
    let bodyText = try XCTUnwrap(String(data: body, encoding: .utf8))
    XCTAssertTrue(bodyText.contains("NativeFeaturedBlog"))
    XCTAssertTrue(bodyText.contains(#""handle":"news""#))
    XCTAssertTrue(bodyText.contains(#""first":10"#))
    XCTAssertTrue(bodyText.contains("onlineStoreUrl"))
    XCTAssertTrue(bodyText.contains("authorV2"))
    XCTAssertTrue(bodyText.contains("contentHtml"))
    XCTAssertTrue(bodyText.contains("pageInfo"))
  }

  func testDockRetainsSixBalancedDestinations() {
    XCTAssertEqual(
      DockDestination.allCases.map(\.label),
      ["Home", "Shop", "Exclusive", "Profile", "Stores", "Ask Bestie"]
    )
    XCTAssertFalse(
      DockDestination.allCases.contains(where: { $0.id == "search" }),
      "Search remains a header action rather than a seventh dock destination."
    )
  }

  @MainActor
  func testBootstrapPublishesVerifiedMenusOnceAndMarksReady() async throws {
    let recorder = RequestRecorder()
    let session = mockSession(statusCode: 200, body: Data())
    MockURLProtocol.response = { request in
      let body = self.requestBodyData(for: request)
      recorder.record(body)
      let bodyText = try XCTUnwrap(String(data: body, encoding: .utf8))
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!

      if bodyText.contains(#""handle":"tabs-menu""#) {
        return (
          response,
          Data(
            """
            {"data":{"menu":{
              "id":"gid://shopify/Menu/tabs",
              "handle":"tabs-menu",
              "title":"Tabs",
              "items":[]
            }}}
            """.utf8
          )
        )
      }

      XCTAssertTrue(bodyText.contains(#""handle":"navabr""#))
      return (
        response,
        Data(
          """
          {"data":{"menu":{
            "id":"gid://shopify/Menu/shop",
            "handle":"navabr",
            "title":"navabr",
            "items":[{
              "id":"gid://shopify/MenuItem/skincare",
              "title":"All Skincare ",
              "url":"https://beautyontapp.com#",
              "resourceId":null,
              "items":[
                {
                  "id":"gid://shopify/MenuItem/all-skincare",
                  "title":"All Skincare ",
                  "url":"https://beautyontapp.com/collections/skincare",
                  "resourceId":"gid://shopify/Collection/skincare",
                  "items":[]
                },
                {
                  "id":"gid://shopify/MenuItem/help",
                  "title":"Help Me Choose ",
                  "url":"https://beautyontapp.com#",
                  "resourceId":null,
                  "items":[{
                    "id":"gid://shopify/MenuItem/help-leaf",
                    "title":"Dark Spot Fade AM",
                    "url":"https://beautyontapp.com/collections/the-glass-skin-starter",
                    "resourceId":"gid://shopify/Collection/help"
                  }]
                },
                {
                  "id":"gid://shopify/MenuItem/cleansers",
                  "title":"Cleansers",
                  "url":"https://beautyontapp.com#",
                  "resourceId":null,
                  "items":[{
                    "id":"gid://shopify/MenuItem/cleanser-leaf",
                    "title":"All Cleansers",
                    "url":"https://beautyontapp.com/collections/cleanser",
                    "resourceId":"gid://shopify/Collection/cleanser"
                  }]
                },
                {
                  "id":"gid://shopify/MenuItem/body",
                  "title":"Body Care",
                  "url":"https://beautyontapp.com#",
                  "resourceId":null,
                  "items":[{
                    "id":"gid://shopify/MenuItem/body-leaf",
                    "title":"Body Wash",
                    "url":"https://beautyontapp.com/collections/body-wash-1",
                    "resourceId":"gid://shopify/Collection/body"
                  }]
                },
                {
                  "id":"gid://shopify/MenuItem/moisturisers",
                  "title":"Moisturisers ",
                  "url":"https://beautyontapp.com#",
                  "resourceId":null,
                  "items":[{
                    "id":"gid://shopify/MenuItem/moisturiser-leaf",
                    "title":"All Moisturisers",
                    "url":"https://beautyontapp.com/collections/moisturisers-balms",
                    "resourceId":"gid://shopify/Collection/moisturisers"
                  }]
                },
                {
                  "id":"gid://shopify/MenuItem/concern",
                  "title":"Shop By Concern",
                  "url":"https://beautyontapp.com#",
                  "resourceId":null,
                  "items":[{
                    "id":"gid://shopify/MenuItem/concern-leaf",
                    "title":"Acne",
                    "url":"https://beautyontapp.com/collections/acne",
                    "resourceId":"gid://shopify/Collection/acne"
                  }]
                },
                {
                  "id":"gid://shopify/MenuItem/skin-type",
                  "title":"Skin Type",
                  "url":"https://beautyontapp.com#",
                  "resourceId":null,
                  "items":[{
                    "id":"gid://shopify/MenuItem/type-leaf",
                    "title":"Dry",
                    "url":"https://beautyontapp.com/collections/dry-skin",
                    "resourceId":"gid://shopify/Collection/dry"
                  }]
                },
                {
                  "id":"gid://shopify/MenuItem/product-type",
                  "title":"Product Type",
                  "url":"https://beautyontapp.com#",
                  "resourceId":null,
                  "items":[{
                    "id":"gid://shopify/MenuItem/product-leaf",
                    "title":"Serums",
                    "url":"https://beautyontapp.com/collections/serums",
                    "resourceId":"gid://shopify/Collection/serums"
                  }]
                },
                {
                  "id":"gid://shopify/MenuItem/ingredients",
                  "title":"Featured Ingredients",
                  "url":"https://beautyontapp.com#",
                  "resourceId":null,
                  "items":[{
                    "id":"gid://shopify/MenuItem/ingredient-leaf",
                    "title":"Vitamin C",
                    "url":"https://beautyontapp.com/collections/vitamin-c",
                    "resourceId":"gid://shopify/Collection/vitamin-c"
                  }]
                },
                {
                  "id":"gid://shopify/MenuItem/treatments",
                  "title":"Treatments",
                  "url":"https://beautyontapp.com#",
                  "resourceId":null,
                  "items":[{
                    "id":"gid://shopify/MenuItem/treatment-leaf",
                    "title":"Face Serums",
                    "url":"https://beautyontapp.com/collections/serums",
                    "resourceId":"gid://shopify/Collection/treatments"
                  }]
                }
              ]
            }]
          }}}
          """.utf8
        )
      )
    }
    let migrator = FakeLegacyCartMigrator(lines: [])
    let model = AppModel(
      client: StorefrontClient(session: session),
      cartVault: MemoryCartVault(value: nil),
      legacyCartMigrator: migrator
    )

    let firstBootstrap = Task { await model.bootstrap() }
    let secondBootstrap = Task { await model.bootstrap() }
    await firstBootstrap.value
    await secondBootstrap.value

    XCTAssertTrue(model.isBootstrapComplete)
    XCTAssertFalse(model.isShopMenuLoading)
    XCTAssertEqual(model.tabsMenu?.handle, "tabs-menu")
    let shopMenu = try XCTUnwrap(model.shopMenu)
    XCTAssertEqual(shopMenu.handle, "navabr")
    let skincare = try XCTUnwrap(shopMenu.items.first)
    XCTAssertEqual(
      skincare.items.map {
        $0.title.trimmingCharacters(in: .whitespacesAndNewlines)
      },
      [
        "All Skincare",
        "Help Me Choose",
        "Cleansers",
        "Body Care",
        "Moisturisers",
        "Shop By Concern",
        "Skin Type",
        "Product Type",
        "Featured Ingredients",
        "Treatments",
      ]
    )
    XCTAssertEqual(
      skincare.items.first?.url?.absoluteString,
      "https://beautyontapp.com/collections/skincare"
    )
    XCTAssertEqual(recorder.bodies.count, 2)
    XCTAssertEqual(migrator.fetchCount, 1)

    await model.bootstrap()

    XCTAssertEqual(
      recorder.bodies.count,
      2,
      "A completed bootstrap must not refetch either configured menu."
    )
    XCTAssertEqual(migrator.fetchCount, 1)
  }

  @MainActor
  func testExclusiveUsesNativeVerifiedBrandCollections() {
    let model = AppModel(
      client: StorefrontClient(
        session: mockSession(statusCode: 503, body: Data())
      ),
      cartVault: MemoryCartVault(value: nil)
    )

    model.selectDock(.exclusive)

    XCTAssertEqual(model.selectedDock, .exclusive)
    XCTAssertNil(model.rootCollection)
    XCTAssertNil(model.webDestination)
    XCTAssertEqual(
      ExclusiveView.verifiedCollections.map(\.collectionHandle),
      [
        "pastry-skincare",
        "mzuri-skin",
        "bair-skincare",
        "forme",
        "hom",
      ]
    )
  }

  func testShopifyImageReferenceBecomesCDNURL() throws {
    let url = ShopifyAsset.url(
      from: "shopify://shop_images/pastry_body_lotion.jpg",
      width: 900
    )

    XCTAssertEqual(url?.host, "beautyontapp.com")
    XCTAssertEqual(url?.path, "/cdn/shop/files/pastry_body_lotion.jpg")
    XCTAssertEqual(
      URLComponents(url: try XCTUnwrap(url), resolvingAgainstBaseURL: false)?
        .queryItems?
        .first(where: { $0.name == "width" })?
        .value,
      "900"
    )
  }

  func testShopifySVGBecomesNativeImageFormat() throws {
    let url = try XCTUnwrap(
      ShopifyAsset.url(
        from: "https://beautyontapp.com/cdn/shop/files/shop-tab-new.svg?v=1",
        width: 96
      )
    )
    let queryItems = try XCTUnwrap(
      URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
    )

    XCTAssertEqual(
      queryItems.first(where: { $0.name == "width" })?.value,
      "96"
    )
    XCTAssertEqual(
      queryItems.first(where: { $0.name == "format" })?.value,
      "png"
    )
  }

  func testVerifiedBookeasyTagRoutesProductToProtectedWebFlow() {
    let product = StoreProduct(
      id: "gid://shopify/Product/1",
      title: "Service",
      handle: "service",
      onlineStoreURL: URL(string: "https://beautyontapp.com/products/service"),
      descriptionText: "",
      vendor: "BeautyOnTApp",
      productType: "Service",
      tags: ["bookeasy"],
      availableForSale: true,
      reviewSummary: nil,
      variants: [],
      images: [],
      selectedOrFirstAvailableVariant: nil,
      payloadKind: .detail
    )

    XCTAssertTrue(product.isBookingProduct)
  }

  func testUnverifiedBookXTagDoesNotCreateBookingProduct() {
    let product = makeProduct(tags: ["bookx"], variants: [makeVariant(id: "1")])

    XCTAssertFalse(product.isBookingProduct)
  }

  func testQuickAddOnlyAcceptsOneAvailableNonBookingVariant() {
    XCTAssertTrue(
      makeProduct(variants: [makeVariant(id: "1")]).canQuickAdd
    )
    XCTAssertFalse(
      makeProduct(
        variants: [
          makeVariant(id: "1"),
          makeVariant(id: "2"),
        ]
      ).canQuickAdd
    )
    XCTAssertFalse(
      makeProduct(
        tags: ["bookeasy"],
        variants: [makeVariant(id: "1")]
      ).canQuickAdd
    )
    XCTAssertFalse(
      makeProduct(
        variants: [makeVariant(id: "1", available: false)]
      ).canQuickAdd
    )
  }

  func testProductCardMatchesThemeFragranceSelectionLabel() {
    let product = makeProduct(
      variants: [
        makeVariant(
          id: "1",
          selectedOptions: [
            SelectedOption(name: "Fragrance", value: "Grapefruit")
          ]
        ),
        makeVariant(
          id: "2",
          selectedOptions: [
            SelectedOption(name: "Fragrance", value: "Fragrance Free")
          ]
        ),
      ]
    )

    XCTAssertEqual(product.cardSelectionLabel, "Choose fragrance")
  }

  func testProductCardUsesThemeFallbackForNonFragranceOptions() {
    let product = makeProduct(
      variants: [
        makeVariant(
          id: "1",
          selectedOptions: [
            SelectedOption(name: "Size", value: "100ml")
          ]
        ),
        makeVariant(
          id: "2",
          selectedOptions: [
            SelectedOption(name: "Size", value: "250ml")
          ]
        ),
      ]
    )

    XCTAssertEqual(product.cardSelectionLabel, "Select options")
  }

  func testMenuDecodesLeafItemsWithoutNestedItemsKey() async throws {
    let response = Data(
      """
      {
        "data": {
          "menu": {
            "id": "gid://shopify/Menu/1",
            "handle": "navabr",
            "title": "Shop",
            "items": [
              {
                "id": "top",
                "title": "All Skincare",
                "url": "https://beautyontapp.com/collections/skincare",
                "resourceId": "gid://shopify/Collection/1",
                "items": [
                  {
                    "id": "group",
                    "title": "Help Me Choose",
                    "url": "https://beautyontapp.com/collections/skincare",
                    "resourceId": "gid://shopify/Collection/1",
                    "items": [
                      {
                        "id": "leaf",
                        "title": "Body Acne + Smooth Skin",
                        "url": "https://beautyontapp.com/collections/body-acne",
                        "resourceId": "gid://shopify/Collection/2"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        }
      }
      """.utf8
    )
    let client = StorefrontClient(
      session: mockSession(statusCode: 200, body: response)
    )

    let menu = try await client.menu(handle: "navabr")

    XCTAssertEqual(menu.items.first?.items.first?.items.count, 1)
    XCTAssertEqual(
      menu.items.first?.items.first?.items.first?.title,
      "Body Acne + Smooth Skin"
    )
    XCTAssertEqual(
      menu.items.first?.items.first?.items.first?.items,
      []
    )
  }

  func testSearchReturnsSummaryPagesAndAvailableDisplayVariant() async throws {
    let recorder = RequestRecorder()
    let responseSequence = LockedCounter()
    let session = mockSession(statusCode: 200, body: Data())
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!
      if responseSequence.increment() == 2 {
        return (
          response,
          self.searchResponse(
            productJSON: self.productJSON(
              handle: "second-result",
              variants: [
                self.variantJSON(id: "second", available: true)
              ]
            ),
            hasNextPage: false,
            endCursor: nil
          )
        )
      }
      return (
        response,
        self.searchResponse(
          productJSON: self.productJSON(
            handle: "first-result",
            variants: [
              self.variantJSON(id: "sold-out-1", available: false),
              self.variantJSON(id: "sold-out-2", available: false),
            ],
            selectedVariant: self.variantJSON(
              id: "available-3",
              available: true,
              amount: "199.00"
            )
          ),
          hasNextPage: true,
          endCursor: "cursor-1"
        )
      )
    }

    let client = StorefrontClient(session: session)
    let firstPage = try await client.search("serum", first: 30)
    let secondPage = try await client.search(
      "serum",
      first: 30,
      after: try XCTUnwrap(firstPage.pageInfo.endCursor)
    )

    let firstProduct = try XCTUnwrap(firstPage.products.first)
    XCTAssertFalse(firstProduct.hasCompleteDetails)
    XCTAssertEqual(firstProduct.payloadKind, .summary)
    XCTAssertEqual(
      firstProduct.onlineStoreURL?.absoluteString,
      "https://beautyontapp.com/products/first-result"
    )
    XCTAssertEqual(firstProduct.variants.count, 2)
    XCTAssertEqual(
      firstProduct.firstAvailableVariant?.id,
      "gid://shopify/ProductVariant/available-3"
    )
    XCTAssertEqual(firstProduct.displayVariant?.price.amount, "199.00")
    XCTAssertFalse(firstProduct.canQuickAdd)
    XCTAssertTrue(firstPage.pageInfo.hasNextPage)
    XCTAssertEqual(secondPage.products.first?.handle, "second-result")
    XCTAssertFalse(secondPage.pageInfo.hasNextPage)

    let requestBodies = recorder.bodies.compactMap {
      String(data: $0, encoding: .utf8)
    }
    XCTAssertEqual(requestBodies.count, 2)
    XCTAssertTrue(
      requestBodies.allSatisfy {
        $0.contains("selectedOrFirstAvailableVariant")
      })
    if requestBodies.count == 2 {
      XCTAssertTrue(requestBodies[1].contains(#""after":"cursor-1""#))
    }
  }

  func testProductEndpointMarksPayloadComplete() async throws {
    let session = mockSession(
      statusCode: 200,
      body: Data(
        """
        {"data":{"product":\(productJSON(
                    handle: "complete-product",
                    descriptionText: "Complete description.",
                    variants: [variantJSON(id: "complete", available: true)]
                ))}}
        """.utf8
      )
    )

    let product = try await StorefrontClient(session: session).product(
      handle: "complete-product"
    )

    XCTAssertTrue(product.hasCompleteDetails)
    XCTAssertEqual(product.payloadKind, .detail)
    XCTAssertEqual(product.descriptionText, "Complete description.")
  }

  func testRelatedProductRecommendationsDecodeAndCapAtEight() async throws {
    let recorder = RequestRecorder()
    let recommendationJSON = (0..<10).map { index in
      productJSON(
        handle: "related-\(index)",
        variants: [
          variantJSON(id: "related-\(index)", available: true)
        ]
      )
    }
    let response = Data(
      """
      {"data":{"productRecommendations":[
        \(recommendationJSON.joined(separator: ","))
      ]}}
      """.utf8
    )
    let session = mockSession(statusCode: 200, body: response)
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      return (
        HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!,
        response
      )
    }

    let recommendations = try await StorefrontClient(session: session)
      .productRecommendations(
        productID: "gid://shopify/Product/9204922384643",
        limit: 8
      )

    XCTAssertEqual(recommendations.count, 8)
    XCTAssertEqual(
      recommendations.map(\.handle),
      (0..<8).map { "related-\($0)" }
    )
    XCTAssertTrue(
      recommendations.allSatisfy { $0.payloadKind == .summary }
    )

    let body = try XCTUnwrap(recorder.bodies.first)
    let object = try XCTUnwrap(
      JSONSerialization.jsonObject(with: body) as? [String: Any]
    )
    let query = try XCTUnwrap(object["query"] as? String)
    let variables = try XCTUnwrap(object["variables"] as? [String: Any])
    XCTAssertTrue(query.contains("NativeProductRecommendations"))
    XCTAssertTrue(query.contains("intent: RELATED"))
    XCTAssertEqual(
      variables["productId"] as? String,
      "gid://shopify/Product/9204922384643"
    )
  }

  func testProtectedWebPolicyUsesExactTrustedHostBoundaries() throws {
    XCTAssertTrue(
      WebNavigationPolicy.isTrustedWebURL(
        try XCTUnwrap(URL(string: "https://beautyontapp.com/account"))
      )
    )
    XCTAssertTrue(
      WebNavigationPolicy.isTrustedWebURL(
        try XCTUnwrap(URL(string: "https://account.beautyontapp.com"))
      )
    )
    XCTAssertTrue(
      WebNavigationPolicy.isTrustedWebURL(
        try XCTUnwrap(URL(string: "https://checkout.shopify.com/"))
      )
    )
    XCTAssertFalse(
      WebNavigationPolicy.isTrustedWebURL(
        try XCTUnwrap(
          URL(string: "https://beautyontapp.com.attacker.example/cart")
        )
      )
    )
    XCTAssertFalse(
      WebNavigationPolicy.isTrustedWebURL(
        try XCTUnwrap(URL(string: "javascript:alert(1)"))
      )
    )
    XCTAssertFalse(
      WebNavigationPolicy.isTrustedWebURL(
        try XCTUnwrap(URL(string: "https://another-store.myshopify.com"))
      )
    )
    XCTAssertFalse(
      WebNavigationPolicy.isTrustedWebURL(
        try XCTUnwrap(URL(string: "https://offers.shopify.com"))
      )
    )
    XCTAssertFalse(
      WebNavigationPolicy.isTrustedWebURL(
        try XCTUnwrap(URL(string: "http://beautyontapp.com/account"))
      )
    )
  }

  func testProtectedWebPolicySeparatesCommerceAndExternalSchemes() throws {
    XCTAssertTrue(
      WebNavigationPolicy.isCommerceURL(
        try XCTUnwrap(URL(string: "https://beautyontapp.com/cart"))
      )
    )
    XCTAssertTrue(
      WebNavigationPolicy.isCommerceURL(
        try XCTUnwrap(URL(string: "https://beautyontapp.com/checkout/123"))
      )
    )
    XCTAssertTrue(
      WebNavigationPolicy.isCommerceURL(
        try XCTUnwrap(URL(string: "https://checkout.shopify.com/"))
      )
    )
    XCTAssertTrue(
      WebNavigationPolicy.isCommerceURL(
        try XCTUnwrap(URL(string: "https://pay.shopify.com/session"))
      )
    )
    XCTAssertTrue(
      WebNavigationPolicy.isCommerceURL(
        try XCTUnwrap(URL(string: "https://checkout.shop.app/pay"))
      )
    )
    XCTAssertFalse(
      WebNavigationPolicy.isCommerceURL(
        try XCTUnwrap(URL(string: "https://beautyontapp.com/products/cart"))
      )
    )
    XCTAssertTrue(WebNavigationPolicy.isAllowedExternalScheme("TEL"))
    XCTAssertFalse(WebNavigationPolicy.isAllowedExternalScheme("javascript"))
  }

  func testOnlyConfirmedMissingCartInvalidatesPersistedCartID() {
    XCTAssertTrue(StorefrontError.missingData("Cart").invalidatesPersistedCartID)
    XCTAssertTrue(
      StorefrontError.userErrors([
        "The cart does not exist."
      ]).invalidatesPersistedCartID
    )
    XCTAssertFalse(StorefrontError.missingData("Product").invalidatesPersistedCartID)
    XCTAssertFalse(StorefrontError.httpStatus(503).invalidatesPersistedCartID)
  }

  @MainActor
  func testTransientCartRestoreKeepsPersistedCartID() async {
    let vault = MemoryCartVault(value: "gid://shopify/Cart/persisted")
    let model = AppModel(
      client: StorefrontClient(
        session: mockSession(statusCode: 503, body: Data())
      ),
      cartVault: vault
    )

    await model.restoreCart()

    XCTAssertEqual(vault.value, "gid://shopify/Cart/persisted")
    XCTAssertTrue(model.hasPendingCartRestore)

    MockURLProtocol.response = { request in
      (
        HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!,
        self.cartResponse(id: "gid://shopify/Cart/persisted")
      )
    }

    await model.retryCart()

    XCTAssertEqual(model.cart.id, "gid://shopify/Cart/persisted")
    XCTAssertFalse(model.hasPendingCartRestore)
  }

  @MainActor
  func testConfirmedMissingCartDeletesPersistedCartID() async {
    let vault = MemoryCartVault(value: "gid://shopify/Cart/expired")
    let model = AppModel(
      client: StorefrontClient(
        session: mockSession(
          statusCode: 200,
          body: Data(#"{"data":{"cart":null}}"#.utf8)
        )
      ),
      cartVault: vault
    )

    await model.restoreCart()

    XCTAssertNil(vault.value)
  }

  func testCartLoadsEveryLineAcrossStorefrontPages() async throws {
    let recorder = RequestRecorder()
    let responseSequence = LockedCounter()
    let session = mockSession(statusCode: 200, body: Data())
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!
      if responseSequence.increment() == 2 {
        return (
          response,
          Data(
            """
            {"data":{"cart":{"lines":{
              "nodes":[\(self.cartLineJSON(id: "line-2", variantID: "variant-2"))],
              "pageInfo":{"hasNextPage":false,"endCursor":null}
            }}}}
            """.utf8
          )
        )
      }
      return (
        response,
        Data(
          """
          {"data":{"cart":\(self.cartJSON(
                        id: "gid://shopify/Cart/paginated",
                        totalQuantity: 2,
                        linesJSON: [
                            self.cartLineJSON(id: "line-1", variantID: "variant-1"),
                        ],
                        hasNextPage: true,
                        endCursor: "cart-cursor-1"
                    ))}}
          """.utf8
        )
      )
    }

    let cart = try await StorefrontClient(session: session).cart(
      id: "gid://shopify/Cart/paginated"
    )

    XCTAssertEqual(cart.lines.map(\.id), ["line-1", "line-2"])
    XCTAssertEqual(cart.totalQuantity, 2)
    let requestBodies = recorder.bodies.compactMap {
      String(data: $0, encoding: .utf8)
    }
    XCTAssertEqual(requestBodies.count, 2)
    if requestBodies.count == 2 {
      XCTAssertTrue(requestBodies[1].contains("NativeCartLinesPage"))
      XCTAssertTrue(requestBodies[1].contains(#""after":"cart-cursor-1""#))
    }
  }

  func testCartNoteUpdateKeepsNoteInNativeCart() async throws {
    let recorder = RequestRecorder()
    let session = mockSession(statusCode: 200, body: Data())
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!
      return (
        response,
        Data(
          """
          {"data":{"cartNoteUpdate":{
            "cart":\(self.cartJSON(
              id: "gid://shopify/Cart/note",
              note: "Leave at reception"
            )),
            "userErrors":[]
          }}}
          """.utf8
        )
      )
    }

    let cart = try await StorefrontClient(session: session)
      .updateCartNote(
        cartID: "gid://shopify/Cart/note",
        note: "Leave at reception"
      )

    XCTAssertEqual(cart.note, "Leave at reception")
    let payload = try XCTUnwrap(
      try JSONSerialization.jsonObject(
        with: XCTUnwrap(recorder.bodies.first)
      ) as? [String: Any]
    )
    XCTAssertTrue(
      try XCTUnwrap(payload["query"] as? String)
        .contains("NativeCartNoteUpdate")
    )
    let variables = try XCTUnwrap(
      payload["variables"] as? [String: Any]
    )
    XCTAssertEqual(
      variables["note"] as? String,
      "Leave at reception"
    )
  }

  func testDeliveryEstimateUsesProvinceCodeAndDecodesLiveOptions() async throws {
    let recorder = RequestRecorder()
    let session = mockSession(statusCode: 200, body: Data())
    let deliveryGroups = """
      {"nodes":[{
        "id":"gid://shopify/CartDeliveryGroup/1",
        "deliveryOptions":[{
          "handle":"same-day",
          "title":"Same-day delivery",
          "description":"Available today",
          "deliveryMethodType":"LOCAL",
          "estimatedCost":{"amount":"89.00","currencyCode":"ZAR"}
        }]
      }]}
      """
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!
      return (
        response,
        Data(
          """
          {"data":{"cartDeliveryAddressesReplace":{
            "cart":\(self.cartJSON(
              id: "gid://shopify/Cart/delivery",
              deliveryGroupsJSON: deliveryGroups
            )),
            "userErrors":[]
          }}}
          """.utf8
        )
      )
    }

    let cart = try await StorefrontClient(session: session)
      .estimateDelivery(
        cartID: "gid://shopify/Cart/delivery",
        provinceCode: "GP",
        postalCode: "2191"
      )

    XCTAssertEqual(cart.deliveryOptions.count, 1)
    XCTAssertEqual(
      cart.deliveryOptions.first?.title,
      "Same-day delivery"
    )
    XCTAssertEqual(
      cart.deliveryOptions.first?.estimatedCost.amount,
      "89.00"
    )

    let payload = try XCTUnwrap(
      try JSONSerialization.jsonObject(
        with: XCTUnwrap(recorder.bodies.first)
      ) as? [String: Any]
    )
    XCTAssertTrue(
      try XCTUnwrap(payload["query"] as? String)
        .contains("NativeCartDeliveryAddressesReplace")
    )
    let variables = try XCTUnwrap(
      payload["variables"] as? [String: Any]
    )
    let addresses = try XCTUnwrap(
      variables["addresses"] as? [[String: Any]]
    )
    let selectable = try XCTUnwrap(addresses.first)
    let address = try XCTUnwrap(
      selectable["address"] as? [String: Any]
    )
    let deliveryAddress = try XCTUnwrap(
      address["deliveryAddress"] as? [String: Any]
    )
    XCTAssertEqual(deliveryAddress["countryCode"] as? String, "ZA")
    XCTAssertEqual(deliveryAddress["provinceCode"] as? String, "GP")
    XCTAssertEqual(deliveryAddress["zip"] as? String, "2191")
    XCTAssertEqual(
      selectable["validationStrategy"] as? String,
      "COUNTRY_CODE_ONLY"
    )
  }

  func testDeliveryEstimateFallsBackToAjaxRatesWhenGraphQLGroupsAreEmpty() async throws {
    let graphQLSession = mockSession(statusCode: 200, body: Data())
    let ajaxSession = mockSession(statusCode: 200, body: Data())
    let cartID = "gid://shopify/Cart/ajax-delivery"
    let cart = self.cartJSON(
      id: cartID,
      totalQuantity: 1,
      linesJSON: [
        self.cartLineJSON(
          id: "line-1",
          variantID: "gid://shopify/ProductVariant/47512005083395"
        )
      ],
      deliveryGroupsJSON: "{\"nodes\":[]}"
    )

    MockURLProtocol.response = { request in
      let url = try XCTUnwrap(request.url)
      let response = HTTPURLResponse(
        url: url,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!

      switch url.path {
      case "/api/2026-07/graphql.json":
        return (
          response,
          Data(
            (
              "{\"data\":{\"cartDeliveryAddressesReplace\":{\"cart\":"
                + cart
                + ",\"userErrors\":[]}}}"
            ).utf8
          )
        )
      case "/cart/add.js":
        return (response, Data("{\"items\":[]}".utf8))
      case "/cart/shipping_rates.json":
        return (
          response,
          Data(
            """
            {"shipping_rates":[{
              "name":"Standard - Door to Door",
              "presentment_name":"Standard - Door to Door",
              "description":"Delivery from R120",
              "price":"120.00",
              "currency":"ZAR",
              "code":"standard"
            }]}
            """.utf8
          )
        )
      case "/cart/clear.js":
        return (response, Data("{}".utf8))
      default:
        XCTFail("Unexpected delivery request: \(url.absoluteString)")
        return (response, Data("{}".utf8))
      }
    }

    let resolved = try await StorefrontClient(
      session: graphQLSession,
      ajaxSession: ajaxSession
    ).estimateDelivery(
      cartID: cartID,
      provinceCode: "GP",
      postalCode: "2189"
    )

    XCTAssertEqual(resolved.deliveryOptions.count, 1)
    XCTAssertEqual(
      resolved.deliveryOptions.first?.title,
      "Standard - Door to Door"
    )
    XCTAssertEqual(
      resolved.deliveryOptions.first?.estimatedCost.amount,
      "120.00"
    )
  }

  func testSouthAfricaProvinceLabelsMapToVerifiedCodes() {
    XCTAssertEqual(
      SouthAfricaProvince.all.map(\.name),
      [
        "Eastern Cape",
        "Free State",
        "Gauteng",
        "KwaZulu-Natal",
        "Limpopo",
        "Mpumalanga",
        "North West",
        "Northern Cape",
        "Western Cape",
      ]
    )
    XCTAssertEqual(
      SouthAfricaProvince.all.map(\.code),
      ["EC", "FS", "GP", "KZN", "LP", "MP", "NW", "NC", "WC"]
    )
  }

  @MainActor
  func testLegacyWebCartMigratesBeforeMarkingComplete() async throws {
    let recorder = RequestRecorder()
    let vault = MemoryCartVault(value: nil)
    let migrator = FakeLegacyCartMigrator(
      lines: [
        StoreCartInputLine(
          merchandiseID: "gid://shopify/ProductVariant/101",
          quantity: 2
        ),
        StoreCartInputLine(
          merchandiseID: "gid://shopify/ProductVariant/202",
          quantity: 1
        ),
      ]
    )
    let session = mockSession(statusCode: 200, body: Data())
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      return (
        HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!,
        self.cartCreateResponse(id: "gid://shopify/Cart/migrated")
      )
    }
    let model = AppModel(
      client: StorefrontClient(session: session),
      cartVault: vault,
      legacyCartMigrator: migrator
    )

    await model.migrateLegacyCartIfNeeded()

    XCTAssertEqual(model.cart.id, "gid://shopify/Cart/migrated")
    XCTAssertEqual(vault.value, "gid://shopify/Cart/migrated")
    XCTAssertTrue(migrator.isComplete)
    XCTAssertEqual(migrator.fetchCount, 1)

    let body = try XCTUnwrap(recorder.bodies.first)
    let payload = try XCTUnwrap(
      try JSONSerialization.jsonObject(with: body) as? [String: Any]
    )
    let variables = try XCTUnwrap(payload["variables"] as? [String: Any])
    let input = try XCTUnwrap(variables["input"] as? [String: Any])
    let lines = try XCTUnwrap(input["lines"] as? [[String: Any]])
    XCTAssertEqual(
      Set(lines.compactMap { $0["merchandiseId"] as? String }),
      [
        "gid://shopify/ProductVariant/101",
        "gid://shopify/ProductVariant/202",
      ]
    )
    XCTAssertEqual(
      lines.first {
        $0["merchandiseId"] as? String
          == "gid://shopify/ProductVariant/101"
      }?["quantity"] as? Int,
      2
    )
  }

  @MainActor
  func testFailedLegacyWebCartMigrationRemainsRetryable() async {
    let migrator = FakeLegacyCartMigrator(
      lines: [
        StoreCartInputLine(
          merchandiseID: "gid://shopify/ProductVariant/101",
          quantity: 1
        )
      ]
    )
    let model = AppModel(
      client: StorefrontClient(
        session: mockSession(statusCode: 503, body: Data())
      ),
      cartVault: MemoryCartVault(value: nil),
      legacyCartMigrator: migrator
    )

    await model.migrateLegacyCartIfNeeded()

    XCTAssertFalse(migrator.isComplete)
    XCTAssertEqual(migrator.fetchCount, 1)
    XCTAssertTrue(model.cart.id.isEmpty)
  }

  func testThemeCollectionLinksStayNative() {
    XCTAssertEqual(
      ThemeLink("shopify://collections/skincare"),
      .collection("skincare")
    )
    XCTAssertEqual(
      ThemeLink("/collections/korean-skincare"),
      .collection("korean-skincare")
    )
  }

  @MainActor
  func testNativeRootActionsResetPushedNavigation() {
    let model = AppModel(
      client: StorefrontClient(
        session: mockSession(statusCode: 503, body: Data())
      ),
      cartVault: MemoryCartVault(value: nil)
    )
    let initialResetID = model.navigationResetID

    model.selectDock(.home)
    let homeResetID = model.navigationResetID
    XCTAssertNotEqual(homeResetID, initialResetID)

    model.selectDock(.shop)
    XCTAssertEqual(
      model.navigationResetID,
      homeResetID,
      "Opening the modal Shop must preserve the underlying native stack."
    )

    let shopResetID = model.navigationResetID
    model.showCollection(title: "Skincare", handle: "skincare")
    XCTAssertNotEqual(model.navigationResetID, shopResetID)
  }

  func testVerifiedBookingLinksEnableProtectedCommerceFlow() throws {
    XCTAssertEqual(
      ThemeLink("https://beautyontapp.com/pages/make-services"),
      .booking(
        try XCTUnwrap(
          URL(string: "https://beautyontapp.com/pages/make-services")
        )
      )
    )
    XCTAssertEqual(
      ThemeLink(
        "https://beautyontapp.com/products/skin-analysis-quiz-routine-advice"
      ),
      .web(
        try XCTUnwrap(
          URL(
            string:
              "https://beautyontapp.com/products/skin-analysis-quiz-routine-advice"
          )
        )
      )
    )
    XCTAssertEqual(
      ThemeLink("https://beautyontapp.com/products/hair-analyser"),
      .web(
        try XCTUnwrap(
          URL(string: "https://beautyontapp.com/products/hair-analyser")
        )
      )
    )
    XCTAssertEqual(
      ThemeLink("https://attacker.example/pages/make-services"),
      .external(
        try XCTUnwrap(
          URL(string: "https://attacker.example/pages/make-services")
        )
      )
    )
  }

  @MainActor
  func testVerifiedBookingThemeLinkEnablesCommerceNavigation() throws {
    let model = AppModel(
      client: StorefrontClient(
        session: mockSession(statusCode: 503, body: Data())
      ),
      cartVault: MemoryCartVault(value: nil)
    )
    let bookingURL = try XCTUnwrap(
      URL(string: "https://beautyontapp.com/pages/make-services")
    )

    model.openThemeLink(
      title: "Book Smart Analysis",
      link: ThemeLink(bookingURL.absoluteString)
    )

    let destination = try XCTUnwrap(model.webDestination)
    XCTAssertEqual(destination.url, bookingURL)
    XCTAssertTrue(destination.allowsExternalNavigation)
    XCTAssertTrue(destination.allowsCommerceNavigation)
  }

  @MainActor
  func testProtectedWebSessionInstallsNativeCartProtectionAtDocumentStart() throws {
    let session = ProtectedWebSession()
    let model = AppModel(
      client: StorefrontClient(
        session: mockSession(statusCode: 503, body: Data())
      ),
      webSession: session,
      cartVault: MemoryCartVault(value: nil)
    )
    model.presentWeb(
      title: "Read only",
      url: try XCTUnwrap(URL(string: "https://beautyontapp.com/pages/brands")),
      documentStartJavaScript: "window.__testDocumentStart = true;"
    )

    session.load(try XCTUnwrap(model.webDestination))
    session.webView.stopLoading()

    let scripts = session.webView.configuration
      .userContentController.userScripts
    XCTAssertEqual(scripts.count, 3)
    XCTAssertTrue(
      scripts.contains {
        $0.injectionTime == .atDocumentStart && $0.source.contains("/cart")
      }
    )
    XCTAssertTrue(
      scripts.contains {
        $0.injectionTime == .atDocumentStart && $0.isForMainFrameOnly
          && $0.source.contains("header.contents") && $0.source.contains(".section-site-header")
          && $0.source.contains(".signinbar-wrapper") && $0.source.contains(".tabs-wrapper")
          && $0.source.contains(".bottom-nav.bui-dock-light")
          && $0.source.contains(".shopify-section-group-header-group")
          && $0.source.contains(".shopify-section-group-footer-group")
          && $0.source.contains(".custom-footer") && $0.source.contains(".section-footer")
          && $0.source.contains("[id*=\"__logo_list_\"]") && $0.source.contains("#cart-modal")
      }
    )
    XCTAssertTrue(
      scripts.contains {
        $0.injectionTime == .atDocumentStart && $0.source.contains("__testDocumentStart")
      }
    )
  }

  @MainActor
  func testProtectedWebSessionLeavesCommerceAndPaymentPagesUnmodified() throws {
    let cartDestination = WebDestination(
      title: "Bag",
      url: try XCTUnwrap(URL(string: "https://beautyontapp.com/cart")),
      documentStartJavaScript: nil,
      postLoadJavaScript: nil,
      allowsExternalNavigation: false,
      allowsCommerceNavigation: true,
      reconcilesCartOnDismiss: false
    )
    let checkoutDestination = WebDestination(
      title: "Checkout",
      url: try XCTUnwrap(
        URL(string: "https://checkout.shopify.com/orders/example")
      ),
      documentStartJavaScript: nil,
      postLoadJavaScript: nil,
      allowsExternalNavigation: false,
      allowsCommerceNavigation: true,
      reconcilesCartOnDismiss: false
    )
    let storefrontCheckoutDestination = WebDestination(
      title: "Checkout",
      url: try XCTUnwrap(
        URL(string: "https://beautyontapp.com/checkouts/cn/example")
      ),
      documentStartJavaScript: nil,
      postLoadJavaScript: nil,
      allowsExternalNavigation: false,
      allowsCommerceNavigation: true,
      reconcilesCartOnDismiss: false
    )
    let accountDestination = WebDestination(
      title: "Account",
      url: try XCTUnwrap(URL(string: "https://beautyontapp.com/account")),
      documentStartJavaScript: nil,
      postLoadJavaScript: nil,
      allowsExternalNavigation: false,
      allowsCommerceNavigation: false,
      reconcilesCartOnDismiss: false
    )

    XCTAssertFalse(
      ProtectedWebSession.shouldApplyNativeChrome(to: cartDestination)
    )
    XCTAssertFalse(
      ProtectedWebSession.shouldApplyNativeChrome(to: checkoutDestination)
    )
    XCTAssertFalse(
      ProtectedWebSession.shouldApplyNativeChrome(
        to: storefrontCheckoutDestination
      )
    )
    XCTAssertTrue(
      ProtectedWebSession.shouldApplyNativeChrome(to: accountDestination)
    )

    let session = ProtectedWebSession()
    session.load(checkoutDestination)
    session.webView.stopLoading()

    XCTAssertFalse(
      session.webView.configuration.userContentController.userScripts
        .contains { $0.source.contains("bot-native-shell-chrome") }
    )
  }

  func testAuthenticationFlowClosesOnlyAfterShopifyReturnsToAccount() throws {
    let signIn = WebDestination(
      title: "Sign In",
      url: try XCTUnwrap(
        URL(string: "https://beautyontapp.com/account/login")
      ),
      documentStartJavaScript: nil,
      postLoadJavaScript: nil,
      allowsExternalNavigation: false,
      allowsCommerceNavigation: false,
      reconcilesCartOnDismiss: false
    )
    let createAccount = WebDestination(
      title: "Create Account",
      url: try XCTUnwrap(
        URL(string: "https://beautyontapp.com/account/register")
      ),
      documentStartJavaScript: nil,
      postLoadJavaScript: nil,
      allowsExternalNavigation: false,
      allowsCommerceNavigation: false,
      reconcilesCartOnDismiss: false
    )

    XCTAssertFalse(
      ProtectedWebSession.shouldDismissAuthenticationFlow(
        destination: signIn,
        url: signIn.url
      )
    )
    XCTAssertTrue(
      ProtectedWebSession.shouldDismissAuthenticationFlow(
        destination: signIn,
        url: try XCTUnwrap(
          URL(string: "https://beautyontapp.com/account?view=profile")
        )
      )
    )
    XCTAssertTrue(
      ProtectedWebSession.shouldDismissAuthenticationFlow(
        destination: createAccount,
        url: try XCTUnwrap(
          URL(string: "https://beautyontapp.com/account/")
        )
      )
    )
    XCTAssertTrue(
      ProtectedWebSession.shouldDismissAuthenticationFlow(
        destination: signIn,
        url: try XCTUnwrap(
          URL(string: "https://account.beautyontapp.com/?locale=en")
        )
      )
    )
    XCTAssertFalse(
      ProtectedWebSession.shouldDismissAuthenticationFlow(
        destination: WebDestination(
          title: "Profile",
          url: signIn.url,
          documentStartJavaScript: nil,
          postLoadJavaScript: nil,
          allowsExternalNavigation: false,
          allowsCommerceNavigation: false,
          reconcilesCartOnDismiss: false
        ),
        url: try XCTUnwrap(
          URL(string: "https://beautyontapp.com/account")
        )
      )
    )
  }

  @MainActor
  func testAuthenticationFlowInstallsCustomerIdentityScript() throws {
    let session = ProtectedWebSession()
    let destination = WebDestination(
      title: "Sign In",
      url: try XCTUnwrap(
        URL(string: "https://beautyontapp.com/account/login")
      ),
      documentStartJavaScript: nil,
      postLoadJavaScript: nil,
      allowsExternalNavigation: false,
      allowsCommerceNavigation: false,
      reconcilesCartOnDismiss: false
    )

    session.load(destination)
    session.webView.stopLoading()

    let scripts = session.webView.configuration.userContentController
      .userScripts
    XCTAssertTrue(
      scripts.contains {
        $0.injectionTime == .atDocumentEnd
          && $0.isForMainFrameOnly
          && $0.source.contains("customerAuthenticated")
          && $0.source.contains("customerAccountRoute")
          && $0.source.contains("account.beautyontapp.com")
          && $0.source.contains("Welcome")
          && $0.source.contains("Orders")
          && $0.source.contains("Profile")
      }
    )
  }

  func testCustomerAccountOAuthCallbackIsTheNativeHandoffBoundary() throws {
    XCTAssertTrue(
      ProtectedWebSession.isCustomerAccountCallback(
        try XCTUnwrap(
          URL(string: "https://account.beautyontapp.com/callback?code=abc&state=xyz")
        )
      )
    )
    XCTAssertTrue(
      ProtectedWebSession.isCustomerAccountCallback(
        try XCTUnwrap(
          URL(string: "https://account.beautyontapp.com/callback/")
        )
      )
    )

    XCTAssertFalse(
      ProtectedWebSession.isCustomerAccountCallback(
        try XCTUnwrap(
          URL(string: "https://account.beautyontapp.com/authentication/login")
        )
      )
    )
    XCTAssertFalse(
      ProtectedWebSession.isCustomerAccountCallback(
        try XCTUnwrap(
          URL(string: "https://beautyontapp.com/callback?code=abc")
        )
      )
    )
    XCTAssertFalse(
      ProtectedWebSession.isCustomerAccountCallback(
        try XCTUnwrap(
          URL(string: "https://account.beautyontapp.com/callback.evil")
        )
      )
    )
  }

  @MainActor
  func testCustomerAccountQueryUsesShopifyRawAccessTokenHeader() throws {
    let request = try CustomerAuthClient.customerQueryRequest(
      accessToken: "customer-access-token",
      endpoint: try XCTUnwrap(
        URL(string: "https://account.beautyontapp.com/customer/api/2026-07/graphql")
      )
    )

    XCTAssertEqual(request.httpMethod, "POST")
    XCTAssertEqual(
      request.value(forHTTPHeaderField: "Authorization"),
      "customer-access-token"
    )
    XCTAssertEqual(
      request.value(forHTTPHeaderField: "Content-Type"),
      "application/json"
    )
  }

  @MainActor
  func testProtectedWebSessionIsFreshPerVisibleFlowAndShutsDownOnDismiss()
    throws
  {
    let suppliedSession = ProtectedWebSession()
    let model = AppModel(
      client: StorefrontClient(
        session: mockSession(statusCode: 503, body: Data())
      ),
      webSession: suppliedSession,
      cartVault: MemoryCartVault(value: nil)
    )
    let firstURL = try XCTUnwrap(
      URL(string: "https://beautyontapp.com/account")
    )

    model.presentWeb(title: "Profile", url: firstURL)

    XCTAssertTrue(model.webSession === suppliedSession)
    XCTAssertFalse(suppliedSession.isShutdown)
    XCTAssertTrue(
      suppliedSession.webView.configuration.websiteDataStore === WKWebsiteDataStore.default()
    )

    model.webFlowDidDismiss()

    XCTAssertNil(model.webSession)
    XCTAssertTrue(suppliedSession.isShutdown)
    XCTAssertNil(suppliedSession.webView.navigationDelegate)
    XCTAssertNil(suppliedSession.webView.uiDelegate)
    XCTAssertTrue(
      suppliedSession.webView.configuration
        .userContentController.userScripts.isEmpty
    )

    model.presentWeb(
      title: "Stores",
      url: try XCTUnwrap(
        URL(string: "https://beautyontapp.com/pages/locations")
      )
    )
    let secondSession = try XCTUnwrap(model.webSession)

    XCTAssertFalse(secondSession === suppliedSession)
    XCTAssertFalse(secondSession.isShutdown)
    XCTAssertTrue(
      secondSession.webView.configuration.websiteDataStore === WKWebsiteDataStore.default()
    )
    model.webFlowDidDismiss()
    XCTAssertTrue(secondSession.isShutdown)
  }

  @MainActor
  func testWebContentRecoveryDefersWhileBackgrounded() {
    let session = ProtectedWebSession()

    session.noteWebContentProcessTermination(applicationIsActive: false)
    XCTAssertTrue(session.hasDeferredProcessRecovery)
    XCTAssertFalse(session.isLoading)

    session.resumeDeferredProcessRecovery()
    XCTAssertFalse(session.hasDeferredProcessRecovery)
    XCTAssertFalse(session.isLoading)
  }

  @MainActor
  func testBackgroundNavigationFailureRecoversWithoutReconnectCard() {
    let session = ProtectedWebSession()
    let error = NSError(
      domain: NSURLErrorDomain,
      code: NSURLErrorNetworkConnectionLost
    )

    session.recordNavigationError(error, applicationIsActive: false)

    XCTAssertTrue(session.hasDeferredProcessRecovery)
    XCTAssertNil(session.lastError)
    XCTAssertFalse(session.isLoading)
  }

  @MainActor
  func testAppModelProductCacheHitAndForceRefresh() async throws {
    let recorder = RequestRecorder()
    let session = mockSession(statusCode: 200, body: Data())
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      return (
        HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!,
        Data(
          """
          {"data":{"product":\(self.productJSON(
                        handle: "cached-product",
                        variants: [
                            self.variantJSON(id: "cached", available: true),
                        ]
                    ))}}
          """.utf8
        )
      )
    }
    let model = AppModel(
      client: StorefrontClient(session: session),
      cartVault: MemoryCartVault(value: nil)
    )

    _ = try await model.product(handle: "cached-product")
    _ = try await model.product(handle: "cached-product")
    XCTAssertEqual(recorder.bodies.count, 1)

    _ = try await model.product(
      handle: "cached-product",
      forceRefresh: true
    )
    XCTAssertEqual(recorder.bodies.count, 2)
  }

  @MainActor
  func testAppModelCoalescesInflightProductRequests() async throws {
    let recorder = RequestRecorder()
    let session = mockSession(statusCode: 200, body: Data())
    MockURLProtocol.responseDelay = 0.2
    defer { MockURLProtocol.responseDelay = 0 }
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      return (
        HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!,
        Data(
          """
          {"data":{"product":\(self.productJSON(
                        handle: "coalesced-product",
                        variants: [
                            self.variantJSON(id: "coalesced", available: true),
                        ]
                    ))}}
          """.utf8
        )
      )
    }
    let model = AppModel(
      client: StorefrontClient(session: session),
      cartVault: MemoryCartVault(value: nil)
    )

    async let first = model.product(handle: "coalesced-product")
    async let second = model.product(handle: "coalesced-product")
    let results = try await [first, second]

    XCTAssertEqual(results[0], results[1])
    XCTAssertEqual(recorder.bodies.count, 1)
  }

  @MainActor
  func testCollectionCacheKeyIncludesEveryQueryField() async throws {
    let recorder = RequestRecorder()
    let session = mockSession(statusCode: 200, body: Data())
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      return (
        HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!,
        Data(
          """
          {"data":{"collection":{"products":{
            "nodes":[],
            "pageInfo":{"hasNextPage":false,"endCursor":null}
          }}}}
          """.utf8
        )
      )
    }
    let model = AppModel(
      client: StorefrontClient(session: session),
      cartVault: MemoryCartVault(value: nil)
    )

    _ = try await model.collection(handle: "skincare")
    _ = try await model.collection(handle: "skincare")
    _ = try await model.collection(handle: "skincare", first: 21)
    _ = try await model.collection(
      handle: "skincare",
      after: "cursor-1"
    )
    _ = try await model.collection(
      handle: "skincare",
      sort: .bestSelling
    )
    _ = try await model.collection(
      handle: "skincare",
      reverse: true
    )

    XCTAssertEqual(recorder.bodies.count, 5)
  }

  @MainActor
  func testRetiredBodyWashAliasFetchesLiveCollectionHandle() async throws {
    let recorder = RequestRecorder()
    let session = mockSession(statusCode: 200, body: Data())
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      return (
        HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!,
        Data(
          """
          {"data":{"collection":{"products":{
            "nodes":[],
            "pageInfo":{"hasNextPage":false,"endCursor":null}
          }}}}
          """.utf8
        )
      )
    }
    let model = AppModel(
      client: StorefrontClient(session: session),
      cartVault: MemoryCartVault(value: nil)
    )

    _ = try await model.collection(handle: "body-wash-1")

    let body = try XCTUnwrap(String(data: try XCTUnwrap(recorder.bodies.first), encoding: .utf8))
    XCTAssertTrue(body.contains("body-wash"))
    XCTAssertFalse(body.contains("body-wash-1"))
  }

  @MainActor
  func testExpiredCartIsRecreatedWhenAddingAProduct() async throws {
    let vault = MemoryCartVault(value: "gid://shopify/Cart/expired")
    let session = mockSession(
      statusCode: 200,
      body: cartResponse(id: "gid://shopify/Cart/expired")
    )
    let model = AppModel(
      client: StorefrontClient(session: session),
      cartVault: vault
    )
    await model.restoreCart()

    let responseSequence = LockedCounter()
    MockURLProtocol.response = { request in
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!

      if responseSequence.increment() == 1 {
        return (
          response,
          Data(
            """
            {"data":{"cartLinesAdd":{"cart":null,"userErrors":[
            {"message":"The cart does not exist."}
            ]}}}
            """.utf8
          )
        )
      }
      return (
        response,
        self.cartCreateResponse(id: "gid://shopify/Cart/recreated")
      )
    }

    let added = await model.addToCart(variant: makeVariant(id: "1"))

    XCTAssertTrue(added)
    XCTAssertEqual(model.cart.id, "gid://shopify/Cart/recreated")
    XCTAssertEqual(vault.value, "gid://shopify/Cart/recreated")
  }

  @MainActor
  func testConcurrentAddsDoNotCreateCompetingCarts() async {
    let model = AppModel(
      client: StorefrontClient(
        session: mockSession(
          statusCode: 200,
          body: cartCreateResponse(id: "gid://shopify/Cart/one")
        )
      ),
      cartVault: MemoryCartVault(value: nil)
    )
    MockURLProtocol.responseDelay = 0.2
    defer { MockURLProtocol.responseDelay = 0 }

    let first = Task {
      await model.addToCart(variant: makeVariant(id: "1"))
    }
    try? await Task.sleep(nanoseconds: 20_000_000)
    XCTAssertFalse(
      model.requestCheckoutAfterCartDismiss(),
      "Checkout must not dismiss against an in-flight cart mutation."
    )
    let secondResult = await model.addToCart(variant: makeVariant(id: "2"))
    let firstResult = await first.value

    XCTAssertTrue(firstResult)
    XCTAssertFalse(secondResult)
    XCTAssertEqual(model.cart.id, "gid://shopify/Cart/one")
    XCTAssertTrue(model.requestCheckoutAfterCartDismiss())
    await model.presentRequestedCheckout()
    XCTAssertEqual(model.webDestination?.title, "Checkout")
  }

  @MainActor
  func testBuyNowUsesIsolatedCartAndLeavesPersistedBagUnchanged() async throws {
    let recorder = RequestRecorder()
    let vault = MemoryCartVault(value: "gid://shopify/Cart/existing")
    let session = mockSession(
      statusCode: 200,
      body: buyNowCartCreateResponse(
        id: "gid://shopify/Cart/buy-now",
        variantID: "gid://shopify/ProductVariant/101",
        quantity: 3
      )
    )
    MockURLProtocol.response = { request in
      recorder.record(self.requestBodyData(for: request))
      return (
        HTTPURLResponse(
          url: try XCTUnwrap(request.url),
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"]
        )!,
        self.buyNowCartCreateResponse(
          id: "gid://shopify/Cart/buy-now",
          variantID: "gid://shopify/ProductVariant/101",
          quantity: 3
        )
      )
    }

    let model = AppModel(
      client: StorefrontClient(session: session),
      cartVault: vault
    )
    model.cart = StoreCart(
      id: "gid://shopify/Cart/existing",
      checkoutURL: URL(string: "https://beautyontapp.com/checkout")!,
      totalQuantity: 2,
      subtotal: Money(amount: "200.00", currencyCode: "ZAR"),
      total: Money(amount: "200.00", currencyCode: "ZAR"),
      lines: []
    )

    let success = await model.buyNow(
      variant: makeVariant(id: "101"),
      quantity: 3
    )

    XCTAssertTrue(success)
    XCTAssertEqual(model.cart.id, "gid://shopify/Cart/existing")
    XCTAssertEqual(model.cart.totalQuantity, 2)
    XCTAssertEqual(vault.value, "gid://shopify/Cart/existing")
    XCTAssertEqual(model.webDestination?.title, "Checkout")
    XCTAssertEqual(
      model.webDestination?.url,
      URL(string: "https://beautyontapp.com/checkout")
    )
    XCTAssertEqual(recorder.bodies.count, 1)
    if let body = recorder.bodies.first {
      let object = try XCTUnwrap(
        JSONSerialization.jsonObject(with: body) as? [String: Any]
      )
      let bodyText = try XCTUnwrap(object["query"] as? String)
      let variables = try XCTUnwrap(object["variables"] as? [String: Any])
      let input = try XCTUnwrap(variables["input"] as? [String: Any])
      let lines = try XCTUnwrap(input["lines"] as? [[String: Any]])
      let line = try XCTUnwrap(lines.first)

      XCTAssertTrue(bodyText.contains("NativeCartCreate"))
      XCTAssertEqual(line["quantity"] as? Int, 3)
      XCTAssertEqual(
        line["merchandiseId"] as? String,
        "gid://shopify/ProductVariant/101"
      )
    }
  }

  @MainActor
  func testBuyNowRejectsUntrustedCheckoutDestination() async {
    let response = Data(
      """
      {"data":{"cartCreate":{"cart":{
        "id":"gid://shopify/Cart/untrusted",
        "checkoutUrl":"https://attacker.example/checkout",
        "totalQuantity":1,
        "cost":{
          "subtotalAmount":{"amount":"100.00","currencyCode":"ZAR"},
          "totalAmount":{"amount":"100.00","currencyCode":"ZAR"}
        },
        "lines":{
          "nodes":[],
          "pageInfo":{"hasNextPage":false,"endCursor":null}
        }
      },"userErrors":[]}}}
      """.utf8
    )
    let model = AppModel(
      client: StorefrontClient(
        session: mockSession(statusCode: 200, body: response)
      ),
      cartVault: MemoryCartVault(value: nil)
    )

    let success = await model.buyNow(variant: makeVariant(id: "101"))

    XCTAssertFalse(success)
    XCTAssertNil(model.webDestination)
    XCTAssertEqual(
      model.buyNowError,
      StorefrontError.missingData("Checkout").localizedDescription
    )
  }

  @MainActor
  func testBuyNowRejectsCheckoutWithoutExactRequestedSelection() async {
    let response = buyNowCartCreateResponse(
      id: "gid://shopify/Cart/wrong-selection",
      variantID: "gid://shopify/ProductVariant/999",
      quantity: 1
    )
    let model = AppModel(
      client: StorefrontClient(
        session: mockSession(statusCode: 200, body: response)
      ),
      cartVault: MemoryCartVault(value: nil)
    )

    let success = await model.buyNow(variant: makeVariant(id: "101"))

    XCTAssertFalse(success)
    XCTAssertNil(model.webDestination)
    XCTAssertEqual(
      model.buyNowError,
      StorefrontError.missingData("Checkout selection").localizedDescription
    )
  }

  func testProductHTMLPreservesReadableBlockBoundaries() {
    let html = """
      <p>Glow up, even out: the ultimate target for dry, uneven skin.</p>
      <p>Our Niacinamide + Pro-Vitamin B5 Body Lotion.</p>
      <div>Use daily.<br>Apply after showering.</div>
      """

    XCTAssertEqual(
      html.plainTextFromHTML,
      """
      Glow up, even out: the ultimate target for dry, uneven skin.

      Our Niacinamide + Pro-Vitamin B5 Body Lotion.

      Use daily.
      Apply after showering.
      """
    )
  }

  func testProductHTMLNormalizesEntitiesListsAndNonContent() {
    let html = """
      <style>.hidden { display: none; }</style>
      <p>Glow&nbsp;&amp;&nbsp;go &#x1F5A4;</p>
      <ul><li>Cleanse</li><li>Moisturise &mdash; daily</li></ul>
      <script>window.fakeProductCopy = "Never render this";</script>
      """

    XCTAssertEqual(
      html.plainTextFromHTML,
      """
      Glow & go 🖤

      • Cleanse
      • Moisturise — daily
      """
    )
  }

  func testProductOnlineStoreURLRequiresExactStorefrontProductPath() {
    XCTAssertNotNil(
      makeProduct(variants: [makeVariant(id: "1")])
        .verifiedOnlineStoreURL
    )

    let attackerProduct = StoreProduct(
      id: "gid://shopify/Product/test",
      title: "Test product",
      handle: "test-product",
      onlineStoreURL: URL(
        string: "https://beautyontapp.com.attacker.example/products/test-product"
      ),
      descriptionText: "",
      vendor: "BeautyOnTApp",
      productType: "",
      tags: [],
      availableForSale: true,
      reviewSummary: nil,
      variants: [makeVariant(id: "1")],
      images: [],
      selectedOrFirstAvailableVariant: nil,
      payloadKind: .detail
    )
    XCTAssertNil(attackerProduct.verifiedOnlineStoreURL)
  }

  private func makeProduct(
    tags: [String] = [],
    payloadKind: StoreProductPayloadKind = .detail,
    selectedOrFirstAvailableVariant: StoreVariant? = nil,
    variants: [StoreVariant]
  ) -> StoreProduct {
    StoreProduct(
      id: "gid://shopify/Product/test",
      title: "Test product",
      handle: "test-product",
      onlineStoreURL: URL(
        string: "https://beautyontapp.com/products/test-product"
      ),
      descriptionText: "",
      vendor: "BeautyOnTApp",
      productType: "",
      tags: tags,
      availableForSale: variants.contains(where: \.availableForSale),
      reviewSummary: nil,
      variants: variants,
      images: [],
      selectedOrFirstAvailableVariant: selectedOrFirstAvailableVariant,
      payloadKind: payloadKind
    )
  }

  private func makeVariant(
    id: String,
    available: Bool = true,
    selectedOptions: [SelectedOption] = []
  ) -> StoreVariant {
    StoreVariant(
      id: "gid://shopify/ProductVariant/\(id)",
      title: "Default",
      availableForSale: available,
      price: Money(amount: "100.00", currencyCode: "ZAR"),
      compareAtPrice: nil,
      selectedOptions: selectedOptions,
      image: nil
    )
  }

  private func requestBodyData(for request: URLRequest) -> Data {
    if let body = request.httpBody {
      return body
    }
    guard let stream = request.httpBodyStream else {
      return Data()
    }

    stream.open()
    defer { stream.close() }
    var data = Data()
    var buffer = [UInt8](repeating: 0, count: 4_096)
    while true {
      let count = stream.read(&buffer, maxLength: buffer.count)
      guard count > 0 else { break }
      data.append(buffer, count: count)
    }
    return data
  }

  private func mockSession(
    statusCode: Int,
    body: Data
  ) -> URLSession {
    MockURLProtocol.response = { request in
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: statusCode,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )!
      return (response, body)
    }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: configuration)
  }

  private func searchResponse(
    productJSON: String,
    hasNextPage: Bool,
    endCursor: String?
  ) -> Data {
    let cursorJSON = endCursor.map { "\"\($0)\"" } ?? "null"
    return Data(
      """
      {"data":{"search":{
        "nodes":[{"__typename":"Product",\(productJSON.dropFirst())],
        "pageInfo":{
          "hasNextPage":\(hasNextPage),
          "endCursor":\(cursorJSON)
        }
      }}}
      """.utf8
    )
  }

  private func productJSON(
    handle: String,
    descriptionText: String? = nil,
    variants: [String],
    selectedVariant: String? = nil
  ) -> String {
    let descriptionFields =
      descriptionText.map {
        #","description":"\#($0)","productType":"Skincare""#
      } ?? ""
    let selectedJSON = selectedVariant ?? "null"
    return """
      {
        "id":"gid://shopify/Product/\(handle)",
        "title":"Test product",
        "handle":"\(handle)",
        "onlineStoreUrl":"https://beautyontapp.com/products/\(handle)",
        "vendor":"BeautyOnTApp",
        "tags":[],
        "availableForSale":true\(descriptionFields),
        "images":{"nodes":[]},
        "variants":{"nodes":[\(variants.joined(separator: ","))]},
        "selectedOrFirstAvailableVariant":\(selectedJSON)
      }
      """
  }

  private func variantJSON(
    id: String,
    available: Bool,
    amount: String = "100.00"
  ) -> String {
    """
    {
      "id":"gid://shopify/ProductVariant/\(id)",
      "title":"Default",
      "availableForSale":\(available),
      "price":{"amount":"\(amount)","currencyCode":"ZAR"},
      "compareAtPrice":null,
      "selectedOptions":[],
      "image":null
    }
    """
  }

  private func cartResponse(id: String) -> Data {
    Data(
      """
      {"data":{"cart":\(cartJSON(id: id))}}
      """.utf8
    )
  }

  private func cartCreateResponse(id: String) -> Data {
    Data(
      """
      {"data":{"cartCreate":{"cart":\(cartJSON(id: id)),"userErrors":[]}}}
      """.utf8
    )
  }

  private func buyNowCartCreateResponse(
    id: String,
    variantID: String,
    quantity: Int
  ) -> Data {
    Data(
      """
      {"data":{"cartCreate":{"cart":\(cartJSON(
        id: id,
        totalQuantity: quantity,
        linesJSON: [
          cartLineJSON(
            id: "buy-now-line",
            variantID: variantID,
            quantity: quantity
          )
        ]
      )),"userErrors":[]}}}
      """.utf8
    )
  }

  private func cartJSON(
    id: String,
    totalQuantity: Int = 0,
    linesJSON: [String] = [],
    hasNextPage: Bool = false,
    endCursor: String? = nil,
    note: String? = nil,
    deliveryGroupsJSON: String = "null"
  ) -> String {
    let cursorJSON = endCursor.map { "\"\($0)\"" } ?? "null"
    let noteJSON = note.map { "\"\($0)\"" } ?? "null"
    return """
      {
        "id":"\(id)",
        "checkoutUrl":"https://beautyontapp.com/checkout",
        "totalQuantity":\(totalQuantity),
        "note":\(noteJSON),
        "cost":{
          "subtotalAmount":{"amount":"0.00","currencyCode":"ZAR"},
          "totalAmount":{"amount":"0.00","currencyCode":"ZAR"}
        },
        "lines":{
          "nodes":[\(linesJSON.joined(separator: ","))],
          "pageInfo":{
            "hasNextPage":\(hasNextPage),
            "endCursor":\(cursorJSON)
          }
        },
        "deliveryGroups":\(deliveryGroupsJSON)
      }
      """
  }

  private func cartLineJSON(
    id: String,
    variantID: String,
    quantity: Int = 1
  ) -> String {
    """
    {
      "id":"\(id)",
      "quantity":\(quantity),
      "cost":{"totalAmount":{"amount":"100.00","currencyCode":"ZAR"}},
      "merchandise":{
        "id":"\(variantID)",
        "title":"Default",
        "availableForSale":true,
        "price":{"amount":"100.00","currencyCode":"ZAR"},
        "compareAtPrice":null,
        "selectedOptions":[],
        "image":null,
        "product":{
          "id":"gid://shopify/Product/\(variantID)",
          "title":"Test product",
          "handle":"test-\(variantID)",
          "vendor":"BeautyOnTApp"
        }
      }
    }
    """
  }
}

private final class MemoryCartVault: CartIDStoring {
  var value: String?

  init(value: String?) {
    self.value = value
  }

  func read() -> String? {
    value
  }

  func write(_ value: String) {
    self.value = value
  }

  func delete() {
    value = nil
  }
}

@MainActor
private final class FakeLegacyCartMigrator: LegacyWebCartMigrating {
  private(set) var isComplete = false
  private(set) var fetchCount = 0
  private let lines: [StoreCartInputLine]

  init(lines: [StoreCartInputLine]) {
    self.lines = lines
  }

  func fetchLines() async throws -> [StoreCartInputLine] {
    fetchCount += 1
    return lines
  }

  func markComplete() {
    isComplete = true
  }
}

private final class LockedCounter: @unchecked Sendable {
  private let lock = NSLock()
  private var value = 0

  func increment() -> Int {
    lock.withLock {
      value += 1
      return value
    }
  }
}

private final class RequestRecorder: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: [Data] = []

  var bodies: [Data] {
    lock.withLock { storage }
  }

  func record(_ body: Data) {
    lock.withLock {
      storage.append(body)
    }
  }
}

private final class MockURLProtocol: URLProtocol {
  nonisolated(unsafe) static var response: ((URLRequest) throws -> (HTTPURLResponse, Data))?
  nonisolated(unsafe) static var responseDelay: TimeInterval = 0

  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    do {
      if Self.responseDelay > 0 {
        Thread.sleep(forTimeInterval: Self.responseDelay)
      }
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
