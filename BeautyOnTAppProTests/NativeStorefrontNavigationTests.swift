import XCTest
@testable import BeautyOnTAppPro

final class NativeStorefrontNavigationTests: XCTestCase {
  func testParsesPrimaryStorefrontProductAndCollectionRoutes() {
    XCTAssertEqual(
      NativeStorefrontNavigation.parse(
        URL(
          string:
            "https://beautyontapp.com/products/niacinamide-body-lotion?variant=123"
        )!
      ),
      .product(handle: "niacinamide-body-lotion")
    )
    XCTAssertEqual(
      NativeStorefrontNavigation.parse(
        URL(
          string:
            "https://www.beautyontapp.com/collections/korean-skincare"
        )!
      ),
      .collection(handle: "korean-skincare")
    )
  }

  func testRejectsUntrustedNestedAndInvalidStorefrontRoutes() {
    let rejected = [
      "https://example.com/products/niacinamide-body-lotion",
      "http://beautyontapp.com/products/niacinamide-body-lotion",
      "https://beautyontapp.com/blogs/news/post",
      "https://beautyontapp.com/products/",
      "https://beautyontapp.com/products/not_valid",
      "https://user@beautyontapp.com/products/niacinamide-body-lotion",
    ]

    for value in rejected {
      XCTAssertNil(
        NativeStorefrontNavigation.parse(URL(string: value)!),
        value
      )
    }
  }

  @MainActor
  func testProtectedCommerceFlowDoesNotInterceptItsOwnProductRoute() {
    let model = AppModel(cartVault: NativeNavigationCartVault())

    model.presentWeb(
      title: "Book this service",
      url: URL(
        string: "https://beautyontapp.com/products/skin-analysis"
      )!,
      allowsExternalNavigation: true,
      allowsCommerceNavigation: true
    )

    XCTAssertNil(model.webSession?.onNativeStorefrontNavigation)
    model.webFlowDidDismiss()

    model.presentWeb(
      title: "Account",
      url: URL(string: "https://beautyontapp.com/account")!
    )

    XCTAssertNotNil(model.webSession?.onNativeStorefrontNavigation)
  }
}

private final class NativeNavigationCartVault: CartIDStoring {
  func read() -> String? { nil }
  func write(_ value: String) {}
  func delete() {}
}
