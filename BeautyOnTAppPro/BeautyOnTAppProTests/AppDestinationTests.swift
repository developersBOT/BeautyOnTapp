import XCTest
@testable import BeautyOnTAppPro

@MainActor
final class AppDestinationTests: XCTestCase {
  func testStoresDockIsNativeAndDoesNotStartWebKit() {
    let model = makeModel()

    model.selectDock(.stores)

    XCTAssertEqual(model.selectedDock, .stores)
    XCTAssertNil(model.rootCollection)
    XCTAssertNil(model.webDestination)
    XCTAssertNil(model.webSession)
  }

  func testBestieUsesIsolatedUpgradedWidgetAndReportsFailure() throws {
    let model = makeModel()

    model.selectDock(.bestie)

    let destination = try XCTUnwrap(model.webDestination)
    XCTAssertEqual(model.selectedDock, .bestie)
    XCTAssertEqual(destination.title, "Ask Bestie")
    XCTAssertEqual(destination.url, ShopifyAsset.shopRoot)
    XCTAssertTrue(destination.isIsolatedBestie)
    XCTAssertTrue(
      destination.documentStartJavaScript?
        .contains("body > *:not(chat-widget)") == true
    )

    let launcher = try XCTUnwrap(destination.postLoadJavaScript)
    XCTAssertTrue(launcher.contains("customElements.get('chat-widget')"))
    XCTAssertTrue(launcher.contains("componentOnReady"))
    XCTAssertTrue(launcher.contains("isAddToCartEnabled = false"))
    XCTAssertTrue(launcher.contains("openAskTimmyChat"))
    XCTAssertTrue(launcher.contains("findLauncher"))
    XCTAssertTrue(
      launcher.contains(".chat-window-container.askTimmy-show")
    )
    XCTAssertTrue(launcher.contains("getBoundingClientRect"))
    XCTAssertTrue(launcher.contains("askTimmy-minimize-button"))
    XCTAssertTrue(launcher.contains("event.composedPath"))
    XCTAssertTrue(launcher.contains("post('dismiss')"))
    XCTAssertTrue(launcher.contains("attempts >= 120"))
    XCTAssertTrue(
      launcher.contains(ProtectedWebSession.scriptMessageHandlerName)
    )
    XCTAssertTrue(launcher.contains("'failure'"))
  }

  func testStorefrontHomeBreadcrumbReturnsToNativeHome() {
    let model = makeModel()
    model.selectDock(.stores)

    model.openThemeLink(
      title: "Home",
      link: .web(ShopifyAsset.shopRoot)
    )

    XCTAssertEqual(model.selectedDock, .home)
    XCTAssertNil(model.rootCollection)
    XCTAssertNil(model.webDestination)
    XCTAssertNil(model.webSession)
  }

  func testExactThemeBrandsTabOpensNativeDirectoryFromCurrentRoot() throws {
    let model = makeModel()
    model.selectDock(.stores)

    model.openThemeLink(
      title: "Brands",
      link: .web(
        try XCTUnwrap(
          URL(string: "https://beautyontapp.com/pages/brands")
        )
      )
    )

    XCTAssertTrue(model.shouldPresentNativeBrands)
    XCTAssertFalse(model.isShopPresented)
    XCTAssertEqual(model.rootDockDestination, .stores)
    XCTAssertNil(model.shopSheetFocus)
    XCTAssertNil(model.webDestination)
    XCTAssertNil(model.webSession)
  }

  func testBrandsRouteWithQueryDoesNotReplaceItsWebDestination() throws {
    let model = makeModel()
    let url = try XCTUnwrap(
      URL(string: "https://beautyontapp.com/pages/brands?view=compact")
    )

    model.openThemeLink(title: "Brands", link: .web(url))

    XCTAssertFalse(model.isShopPresented)
    XCTAssertNil(model.shopSheetFocus)
    XCTAssertEqual(model.webDestination?.url, url)
  }

  func testExternalThemeLinkOpensOutsideWebKit() throws {
    var openedURL: URL?
    let model = AppModel(
      cartVault: AppDestinationCartVault(),
      externalURLOpener: { openedURL = $0 }
    )
    let externalURL = try XCTUnwrap(
      URL(string: "https://payflex.co.za/")
    )

    model.openThemeLink(
      title: "Payflex",
      link: ThemeLink(externalURL.absoluteString)
    )

    XCTAssertEqual(openedURL, externalURL)
    XCTAssertNil(model.webDestination)
    XCTAssertNil(model.webSession)
  }

  private func makeModel() -> AppModel {
    AppModel(cartVault: AppDestinationCartVault())
  }
}

private final class AppDestinationCartVault: CartIDStoring {
  func read() -> String? { nil }
  func write(_ value: String) {}
  func delete() {}
}
