import XCTest

@testable import BeautyOnTAppPro

final class ProductCardPresentationTests: XCTestCase {
  func testRenderedThemeCardsProduceReviewSummaries() throws {
    let summaries = ProductReviewsHTMLParser.cardSummaries(
      html: """
        <div class="product-card group">
          <a href="/products/body-lotion">Body lotion</a>
          <div class="product-card__info">
            <div class="product-card__rating">
              <div class="rating" role="img"
                   aria-label="4.9 out of 5.0 stars"></div>
              <span class="visually-hidden">323 total reviews</span>
            </div>
          </div>
        </div>
        <div class="product-card group">
          <a href="/products/hand-cream">Hand cream</a>
          <div class="rating" role="img"
               aria-label="4.5 out of 5 stars"></div>
          <span class="visually-hidden">1,245 total reviews</span>
        </div>
        """
    )

    XCTAssertEqual(
      try XCTUnwrap(summaries["body-lotion"]).averageRating,
      4.9,
      accuracy: 0.001
    )
    XCTAssertEqual(summaries["body-lotion"]?.reviewCount, 323)
    XCTAssertEqual(
      try XCTUnwrap(summaries["hand-cream"]).averageRating,
      4.5,
      accuracy: 0.001
    )
    XCTAssertEqual(summaries["hand-cream"]?.reviewCount, 1_245)
  }

  func testRenderedThemeCardParserRejectsUnverifiedMarkup() {
    let summaries = ProductReviewsHTMLParser.cardSummaries(
      html: """
        <div class="product-card group">
          <a href="/products/no-rating">No rating</a>
        </div>
        <div class="product-card group">
          <a href="https://attacker.example/products/fake">Fake</a>
          <div aria-label="5 out of 5 stars"></div>
          <span class="visually-hidden">100 total reviews</span>
        </div>
        """
    )

    XCTAssertTrue(summaries.isEmpty)
  }

  func testSaleUsesFirstVariantAndMatchesThemeMoneyCopy() {
    let firstVariant = makeVariant(
      id: "first",
      price: "999.00",
      compareAtPrice: "1055.00"
    )
    let secondVariant = makeVariant(
      id: "second",
      price: "100.00",
      compareAtPrice: "500.00"
    )
    let presentation = ProductCardPresentation(
      product: makeProduct(variants: [firstVariant, secondVariant])
    )

    XCTAssertEqual(presentation.badgeText, "SAVE R 56.00")
    XCTAssertEqual(presentation.badgeStyle, .sale)
    XCTAssertEqual(presentation.compareAtPriceText, "R 1,055.00")
    XCTAssertEqual(presentation.currentPriceText, "R 999.00")
    XCTAssertEqual(presentation.callToActionText, "Select options")
  }

  func testSoldOutBadgeTakesPriorityOverCompareAtPrice() {
    let variant = makeVariant(
      id: "sold-out",
      available: false,
      price: "325.00",
      compareAtPrice: "400.00"
    )
    let presentation = ProductCardPresentation(
      product: makeProduct(
        availableForSale: false,
        variants: [variant]
      )
    )

    XCTAssertEqual(presentation.badgeText, "SOLD OUT")
    XCTAssertEqual(presentation.badgeStyle, .soldOut)
    XCTAssertNil(presentation.compareAtPriceText)
    XCTAssertEqual(presentation.currentPriceText, "R 325.00")
    XCTAssertEqual(presentation.callToActionText, "Sold out")
  }

  func testSingleAvailableVariantUsesAddToCartWithoutUnsourcedBadge() {
    let presentation = ProductCardPresentation(
      product: makeProduct(
        variants: [
          makeVariant(id: "available", price: "169.00")
        ]
      )
    )

    XCTAssertNil(presentation.badgeText)
    XCTAssertNil(presentation.badgeStyle)
    XCTAssertNil(presentation.compareAtPriceText)
    XCTAssertEqual(presentation.currentPriceText, "R 169.00")
    XCTAssertEqual(presentation.callToActionText, "Add to cart")
  }

  private func makeProduct(
    availableForSale: Bool = true,
    variants: [StoreVariant]
  ) -> StoreProduct {
    StoreProduct(
      id: "gid://shopify/Product/card-test",
      title: "Card test",
      handle: "card-test",
      onlineStoreURL: URL(
        string: "https://beautyontapp.com/products/card-test"
      ),
      descriptionText: "",
      vendor: "BeautyOnTApp",
      productType: "",
      tags: [],
      availableForSale: availableForSale,
      reviewSummary: nil,
      variants: variants,
      images: [],
      selectedOrFirstAvailableVariant: variants.first,
      payloadKind: .summary
    )
  }

  private func makeVariant(
    id: String,
    available: Bool = true,
    price: String,
    compareAtPrice: String? = nil
  ) -> StoreVariant {
    StoreVariant(
      id: "gid://shopify/ProductVariant/\(id)",
      title: "Default",
      availableForSale: available,
      price: Money(amount: price, currencyCode: "ZAR"),
      compareAtPrice: compareAtPrice.map {
        Money(amount: $0, currencyCode: "ZAR")
      },
      selectedOptions: [],
      image: nil
    )
  }
}
