import XCTest

@testable import BeautyOnTAppPro

@MainActor
final class ProfileSheetTests: XCTestCase {
  func testProfileGreetingUsesLocalHourAndUpdatesAcrossDayParts() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let day = Date(timeIntervalSince1970: 0)

    XCTAssertEqual(
      ProfileGreeting.text(for: day.addingTimeInterval(6 * 60 * 60), firstName: "Tyler", calendar: calendar),
      "Good Morning☀️ Tyler"
    )
    XCTAssertEqual(
      ProfileGreeting.text(for: day.addingTimeInterval(13 * 60 * 60), firstName: "Tyler", calendar: calendar),
      "Good Afternoon☀️ Tyler"
    )
    XCTAssertEqual(
      ProfileGreeting.text(for: day.addingTimeInterval(19 * 60 * 60), firstName: "Tyler", calendar: calendar),
      "Good Evening🌙 Tyler"
    )
  }

  func testProfileGreetingFallsBackToBestieWhenNameIsMissing() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    XCTAssertEqual(
      ProfileGreeting.text(
        for: Date(timeIntervalSince1970: 14 * 60 * 60),
        firstName: "   ",
        calendar: calendar
      ),
      "Good Afternoon☀️ Bestie."
    )
  }

  func testProfileDockPresentsNativeSheetWithoutStartingWebFlow() {
    let model = makeModel()

    model.selectDock(.profile)

    XCTAssertEqual(model.selectedDock, .profile)
    XCTAssertTrue(model.isProfilePresented)
    XCTAssertNil(model.webDestination)
    XCTAssertNil(model.webSession)
  }

  func testProfileCloseReturnsFocusDestinationToUnderlyingHome() {
    let model = makeModel()
    model.selectDock(.profile)

    model.dismissProfile()

    XCTAssertFalse(model.isProfilePresented)
    XCTAssertEqual(model.selectedDock, .home)
  }

  func testProfileOpenAndClosePreservesUnderlyingExclusiveRoot() {
    let model = makeModel()
    model.selectDock(.exclusive)

    model.selectDock(.profile)

    XCTAssertTrue(model.isProfilePresented)
    XCTAssertEqual(model.selectedDock, .profile)
    XCTAssertEqual(model.rootDockDestination, .exclusive)

    model.dismissProfile()

    XCTAssertFalse(model.isProfilePresented)
    XCTAssertEqual(model.selectedDock, .exclusive)
    XCTAssertEqual(model.rootDockDestination, .exclusive)
  }

  func testProfileCartUsesNativeCartPresentation() {
    let model = makeModel()
    model.selectDock(.profile)

    model.openProfileCart()

    XCTAssertFalse(model.isProfilePresented)
    XCTAssertTrue(model.isCartPresented)
    XCTAssertNil(model.webDestination)
  }

  func testProfileAuthenticationUsesVerifiedShopifyRoutes() throws {
    let signInModel = makeModel()
    signInModel.selectDock(.profile)
    signInModel.openProfileSignIn()

    XCTAssertEqual(
      signInModel.webDestination?.url,
      try XCTUnwrap(
        URL(string: "https://beautyontapp.com/account/login")
      )
    )
    XCTAssertEqual(signInModel.selectedDock, .home)
    XCTAssertEqual(signInModel.rootDockDestination, .home)
    XCTAssertFalse(signInModel.isProfilePresented)

    let createModel = makeModel()
    createModel.selectDock(.profile)
    createModel.openProfileCreateAccount()

    XCTAssertEqual(
      createModel.webDestination?.url,
      try XCTUnwrap(
        URL(string: "https://beautyontapp.com/account/register")
      )
    )
    XCTAssertEqual(createModel.selectedDock, .home)
    XCTAssertEqual(createModel.rootDockDestination, .home)
    XCTAssertFalse(createModel.isProfilePresented)
  }

  func testVerifiedAuthenticationReturnsToNativeHomeAndPublishesCustomerName() {
    let model = makeModel()
    model.selectDock(.profile)
    model.openProfileSignIn()

    model.customerAuthenticationDidSucceed(
      CustomerSessionProbeResult(
        state: .signedIn(firstName: "Tyler"),
        displayName: "Tyler Ngwenya"
      )
    )

    XCTAssertNil(model.webDestination)
    XCTAssertEqual(model.selectedDock, .home)
    XCTAssertEqual(model.rootDockDestination, .home)
    XCTAssertFalse(model.isProfilePresented)
    XCTAssertEqual(model.customerSession, .signedIn(firstName: "Tyler"))
    XCTAssertEqual(model.customerDisplayName, "Tyler Ngwenya")
  }

  func testAuthenticatedAccountRouteReturnsToNativeHomeBeforeNameProbe() throws {
    let model = makeModel()
    model.selectDock(.profile)
    model.openProfileSignIn()

    model.customerAuthenticationAccountRouteDidReach()

    XCTAssertNil(model.webDestination)
    XCTAssertEqual(model.selectedDock, .home)
    XCTAssertEqual(model.rootDockDestination, .home)
    XCTAssertFalse(model.isProfilePresented)
    XCTAssertEqual(model.customerSession, .unknown)
    XCTAssertNil(model.customerDisplayName)
  }

  func testBuyItAgainUsesSnapshotVerifiedAccountLoginRoute() throws {
    let model = makeModel()
    model.selectDock(.profile)

    model.openProfileBuyItAgain()

    XCTAssertEqual(
      model.webDestination?.url,
      try XCTUnwrap(
        URL(string: "https://beautyontapp.com/account/login")
      )
    )
  }

  func testOrderTrackingUsesUploadedThemeAccountFallback() throws {
    let model = makeModel()
    model.selectDock(.profile)

    model.openProfileOrderTracking()

    XCTAssertEqual(
      model.webDestination?.url,
      try XCTUnwrap(
        URL(string: "https://beautyontapp.com/account")
      )
    )
  }

  func testStoresMovesFromPrimaryDockIntoProfileAndStaysNative() {
    let model = makeModel()
    model.selectDock(.profile)

    model.openProfileStores()

    XCTAssertFalse(model.isProfilePresented)
    XCTAssertEqual(model.selectedDock, .stores)
    XCTAssertEqual(model.rootDockDestination, .stores)
    XCTAssertNil(model.webDestination)
    XCTAssertNil(model.webSession)
  }

  func testIngredientGuideUsesBundledThemeExactNativePresentation() {
    let model = makeModel()
    model.selectDock(.profile)

    model.openProfileIngredientGuide()

    XCTAssertFalse(model.isProfilePresented)
    XCTAssertTrue(model.isIngredientGuidePresented)
    XCTAssertNil(model.webDestination)
    XCTAssertNil(model.webSession)
  }

  func testLovesUsesNativePresentationWithoutStartingWebFlow() {
    let model = makeModel()
    model.selectDock(.profile)

    model.openProfileLoves()

    XCTAssertFalse(model.isProfilePresented)
    XCTAssertTrue(model.isLovesPresented)
    XCTAssertNil(model.webDestination)
    XCTAssertNil(model.webSession)
  }

  private func makeModel() -> AppModel {
    AppModel(
      cartVault: ProfileMemoryCartVault(),
      customerSessionProbe: ProfileCustomerSessionProbe()
    )
  }
}

@MainActor
private final class ProfileCustomerSessionProbe: CustomerSessionProbing {
  func probe() async -> CustomerSessionProbeResult {
    .unknown
  }
}

private final class ProfileMemoryCartVault: CartIDStoring {
  func read() -> String? { nil }
  func write(_ value: String) {}
  func delete() {}
}
