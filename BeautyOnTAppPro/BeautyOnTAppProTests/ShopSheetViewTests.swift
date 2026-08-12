import XCTest

@testable import BeautyOnTAppPro

final class ShopSheetViewTests: XCTestCase {
  func testSelectingAnotherRootResetsInlineDisclosureState() {
    var state = ShopSheetAccordionState(
      selectedRootID: "all-skincare",
      expandedItemIDs: ["help-me-choose"]
    )

    state.selectRoot("bath-and-body")

    XCTAssertEqual(state.selectedRootID, "bath-and-body")
    XCTAssertTrue(state.expandedItemIDs.isEmpty)
  }

  func testDismissingFloatingPanelPreservesRootMenuMode() {
    var state = ShopSheetAccordionState(
      selectedRootID: "all-skincare",
      expandedItemIDs: ["help-me-choose"]
    )

    state.dismissPanel()

    XCTAssertNil(state.selectedRootID)
    XCTAssertTrue(state.expandedItemIDs.isEmpty)
  }

  func testMenuRefreshClosesOnlyMissingRootPanel() {
    var retained = ShopSheetAccordionState(
      selectedRootID: "all-skincare",
      expandedItemIDs: ["help-me-choose"]
    )
    retained.reconcile(
      availableRootIDs: ["all-skincare", "bath-and-body"]
    )

    XCTAssertEqual(retained.selectedRootID, "all-skincare")
    XCTAssertEqual(retained.expandedItemIDs, ["help-me-choose"])

    retained.reconcile(availableRootIDs: ["bath-and-body"])

    XCTAssertNil(retained.selectedRootID)
    XCTAssertTrue(retained.expandedItemIDs.isEmpty)
  }

  func testExactThemeBrandsFocusSelectsBrandsRootByTitle() throws {
    let brands = menuItem(
      id: "brands-root",
      title: " Brands ",
      path: "/pages/brands",
      children: [menuItem(id: "a-z", title: "A-Z")]
    )
    var state = ShopSheetAccordionState()

    XCTAssertTrue(
      state.focusRoot(.brands, in: [
        menuItem(id: "skincare-root", title: "All Skincare"),
        brands,
      ])
    )
    XCTAssertEqual(state.selectedRootID, brands.id)
    XCTAssertTrue(state.expandedItemIDs.isEmpty)
  }

  func testExactThemeBrandsFocusFallsBackToVerifiedPath() throws {
    var state = ShopSheetAccordionState()
    let brands = menuItem(
      id: "brands-root",
      title: "Shop by brand",
      path: "/pages/brands/"
    )

    XCTAssertTrue(state.focusRoot(.brands, in: [brands]))
    XCTAssertEqual(state.selectedRootID, brands.id)
  }

  func testMissingFocusLeavesCurrentShopRootUntouched() {
    var state = ShopSheetAccordionState(
      selectedRootID: "all-skincare",
      expandedItemIDs: ["help-me-choose"]
    )

    XCTAssertFalse(
      state.focusRoot(
        .brands,
        in: [menuItem(id: "skincare", title: "All Skincare")]
      )
    )
    XCTAssertEqual(state.selectedRootID, "all-skincare")
    XCTAssertEqual(state.expandedItemIDs, ["help-me-choose"])
  }

  private func menuItem(
    id: String,
    title: String,
    path: String? = nil,
    children: [StoreMenuItem] = []
  ) -> StoreMenuItem {
    StoreMenuItem(
      id: id,
      title: title,
      url: path.map {
        ShopifyAsset.shopRoot.appendingPathComponent(
          String($0.drop(while: { $0 == "/" }))
        )
      },
      resourceID: nil,
      items: children
    )
  }
}
