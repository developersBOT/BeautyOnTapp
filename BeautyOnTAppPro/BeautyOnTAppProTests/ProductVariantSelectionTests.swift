import XCTest

@testable import BeautyOnTAppPro

final class ProductVariantSelectionTests: XCTestCase {
  func testGroupsPreserveShopifyOrderAndSelectionResolvesExactVariant() {
    let grapefruit = makeVariant(
      id: "grapefruit",
      options: [
        SelectedOption(name: "Size", value: "500ml"),
        SelectedOption(name: "Fragrance", value: "Grapefruit Fragrance"),
      ]
    )
    let fragranceFree = makeVariant(
      id: "fragrance-free",
      options: [
        SelectedOption(name: "Size", value: "500ml"),
        SelectedOption(name: "Fragrance", value: "Fragrance Free"),
      ]
    )
    var selection = ProductVariantSelection(
      variants: [grapefruit, fragranceFree],
      initialVariantID: grapefruit.id
    )

    XCTAssertEqual(
      selection.visibleOptionGroups,
      [
        ProductOptionGroup(name: "Size", values: ["500ml"]),
        ProductOptionGroup(
          name: "Fragrance",
          values: ["Grapefruit Fragrance", "Fragrance Free"]
        ),
      ]
    )

    selection.select("Fragrance Free", for: "Fragrance")

    XCTAssertEqual(selection.selectedVariantID, fragranceFree.id)
    XCTAssertEqual(
      selection.selectedValue(for: "Fragrance"),
      "Fragrance Free"
    )
  }

  func testAvailabilityDistinguishesSoldOutFromImpossibleCombination() {
    let available500 = makeVariant(
      id: "500-grapefruit",
      options: [
        SelectedOption(name: "Size", value: "500ml"),
        SelectedOption(name: "Fragrance", value: "Grapefruit"),
      ]
    )
    let soldOut500 = makeVariant(
      id: "500-free",
      available: false,
      options: [
        SelectedOption(name: "Size", value: "500ml"),
        SelectedOption(name: "Fragrance", value: "Fragrance Free"),
      ]
    )
    let available250 = makeVariant(
      id: "250-grapefruit",
      options: [
        SelectedOption(name: "Size", value: "250ml"),
        SelectedOption(name: "Fragrance", value: "Grapefruit"),
      ]
    )

    let selection500 = ProductVariantSelection(
      variants: [available500, soldOut500, available250],
      initialVariantID: available500.id
    )
    XCTAssertEqual(
      selection500.availability(
        of: "Fragrance Free",
        for: "Fragrance"
      ),
      .soldOut
    )

    let selection250 = ProductVariantSelection(
      variants: [available500, soldOut500, available250],
      initialVariantID: available250.id
    )
    XCTAssertEqual(
      selection250.availability(
        of: "Fragrance Free",
        for: "Fragrance"
      ),
      .incompatible
    )
  }

  func testDirectSelectionReconcilesToRealShopifyVariant() {
    let soldOut500 = makeVariant(
      id: "500-free",
      available: false,
      options: [
        SelectedOption(name: "Size", value: "500ml"),
        SelectedOption(name: "Fragrance", value: "Fragrance Free"),
      ]
    )
    let available250 = makeVariant(
      id: "250-grapefruit",
      options: [
        SelectedOption(name: "Size", value: "250ml"),
        SelectedOption(name: "Fragrance", value: "Grapefruit"),
      ]
    )
    var selection = ProductVariantSelection(
      variants: [soldOut500, available250],
      initialVariantID: available250.id
    )

    selection.select("Fragrance Free", for: "Fragrance")

    XCTAssertEqual(selection.selectedVariantID, soldOut500.id)
    XCTAssertEqual(selection.selectedValue(for: "Size"), "500ml")
    XCTAssertFalse(selection.selectedVariant?.availableForSale ?? true)
  }

  func testDefaultTitleIsNotShownAsCustomerOption() {
    let defaultVariant = makeVariant(
      id: "default",
      options: [
        SelectedOption(name: "Title", value: "Default Title")
      ]
    )

    XCTAssertTrue(
      ProductVariantSelection(variants: [defaultVariant])
        .visibleOptionGroups.isEmpty
    )
  }

  private func makeVariant(
    id: String,
    available: Bool = true,
    options: [SelectedOption]
  ) -> StoreVariant {
    StoreVariant(
      id: "gid://shopify/ProductVariant/\(id)",
      title: id,
      availableForSale: available,
      price: Money(amount: "325.00", currencyCode: "ZAR"),
      compareAtPrice: nil,
      selectedOptions: options,
      image: nil
    )
  }
}
