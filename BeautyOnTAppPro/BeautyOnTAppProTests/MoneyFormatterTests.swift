import XCTest

@testable import BeautyOnTAppPro

final class MoneyFormatterTests: XCTestCase {
  func testStorefrontMoneyUsesThemeDecimalAndGroupingSeparators() {
    XCTAssertEqual(
      MoneyFormatter.string(shopifyDecimal: "335.00"),
      "R 335.00"
    )
    XCTAssertEqual(
      MoneyFormatter.string(shopifyDecimal: "1055.00"),
      "R 1,055.00"
    )
  }
}
