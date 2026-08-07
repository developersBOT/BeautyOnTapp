import XCTest

@MainActor
final class NativeNavigationUITests: XCTestCase {
  private var app: XCUIApplication!

  func testHeaderSkincareOpensNativeCollection() {
    launchApp()
    assertSixItemDock()
    assertCurrentHomeChrome()
    keepScreenshot(named: "Native-Home-Source-Locked")

    let skincare = app.buttons["header-tab-skincare"]
    XCTAssertTrue(
      skincare.waitForExistence(timeout: 5),
      "The Skincare header tab must remain directly tappable."
    )
    assertHittable(skincare)
    skincare.tap()

    XCTAssertTrue(
      app.scrollViews["collection-skincare"].waitForExistence(timeout: 5),
      "Skincare must open as a native collection screen."
    )
    let activeSkincare = app.buttons["header-tab-skincare"]
    XCTAssertTrue(
      activeSkincare.isSelected,
      "The current Skincare tab must retain its native selected glass lens."
    )
    keepScreenshot(named: "Header-Skincare-Native-Collection")
  }

  func testHeaderBrandsOpensNativeDirectory() {
    launchApp()
    let brands = app.buttons["header-tab-brands"]
    XCTAssertTrue(
      brands.waitForExistence(timeout: 5),
      "The Brands header tab must remain directly tappable."
    )
    assertHittable(brands)
    brands.tap()

    XCTAssertTrue(
      app.scrollViews["brands-screen"].waitForExistence(timeout: 10),
      "Brands must open the native Brands directory instead of WebKit."
    )
    XCTAssertTrue(
      app.staticTexts["Shop by Brand"].waitForExistence(timeout: 10),
      "The native Brands directory must expose its live heading."
    )
    XCTAssertFalse(
      app.staticTexts["beautyontapp.com"].exists,
      "The native Brands directory must not expose a WebKit hostname."
    )
    XCTAssertTrue(
      app.buttons["brands-letter-A"].waitForExistence(timeout: 10),
      "The live brand response must populate the A–Z rail."
    )
    XCTAssertTrue(app.buttons["brands-letter-B"].exists)
    XCTAssertTrue(app.buttons["header-tab-brands"].isSelected)
  }

  func testShopAndProfileDismissRestoreUnderlyingStoresRoot() {
    launchApp()
    openProfileDestination("profile-stores")
    XCTAssertTrue(
      app.scrollViews["stores-screen"].waitForExistence(timeout: 5)
    )

    app.buttons["dock-shop"].tap()
    XCTAssertTrue(
      app.descendants(matching: .any)["shop-modal"]
        .waitForExistence(timeout: 5)
    )
    keepScreenshot(named: "Native-Shop-Glass-Sheet")
    app.buttons["shop-modal-close"].tap()
    XCTAssertTrue(
      app.scrollViews["stores-screen"].waitForExistence(timeout: 5),
      "Closing Shop must restore the Stores root beneath it."
    )

    app.buttons["dock-profile"].tap()
    XCTAssertTrue(
      app.descendants(matching: .any)["profile-modal"]
        .waitForExistence(timeout: 5)
    )
    keepScreenshot(named: "Native-Profile-Glass-Sheet")
    app.buttons["profile-modal-close"].tap()
    XCTAssertTrue(
      app.scrollViews["stores-screen"].waitForExistence(timeout: 5),
      "Closing Profile must restore the Stores root beneath it."
    )
  }

  func testSignedInProfileUsesCompactPremiumLayout() {
    launchApp(arguments: ["-ui-test-signed-in-profile"])

    let profile = app.buttons["dock-profile"]
    XCTAssertTrue(profile.waitForExistence(timeout: 5))
    profile.tap()

    XCTAssertTrue(
      app.descendants(matching: .any)["profile-modal"].waitForExistence(timeout: 5)
    )
    XCTAssertTrue(app.staticTexts["Tyler Ngwenya"].exists)

    let signOut = app.buttons["profile-logout"]
    XCTAssertTrue(signOut.waitForExistence(timeout: 5))
    XCTAssertTrue(signOut.isHittable)
    XCTAssertGreaterThanOrEqual(signOut.frame.height, 56)
    keepScreenshot(named: "Native-Signed-In-Profile-Premium")
  }

  func testHeaderSearchPresentsNativeSearch() {
    launchApp()

    let search = app.buttons["header-search"]
    XCTAssertTrue(
      search.waitForExistence(timeout: 5),
      "The header Search control must be visible."
    )
    XCTAssertEqual(search.label, "Search")
    assertMinimumTapTarget(search)
    assertHittable(search)
    search.tap()

    let searchScreen = app.scrollViews["search-screen"]
    let didOpenSearch = searchScreen.waitForExistence(timeout: 5)
    if !didOpenSearch {
      keepScreenshot(named: "Bottom-Search-Presentation-Failure")
    }
    let searchModalVisible =
      app.descendants(matching: .any)["search-modal"].exists
    XCTAssertTrue(
      didOpenSearch,
      "The header Search control must open the native search screen. "
        + "Modal visible: \(searchModalVisible)"
    )
    XCTAssertFalse(
      app.staticTexts["beautyontapp.com"].exists,
      "Header Search must not fall back to a WebKit browser."
    )
  }

  func testShopSkincareParentOpensLayeredMenuAndDirectAllRowNavigates() {
    launchApp()
    let shop = app.buttons["Shop"]
    XCTAssertTrue(shop.waitForExistence(timeout: 5))
    assertHittable(shop)
    shop.tap()

    let skincare = app.buttons["shop-item-all-skincare"]
    XCTAssertTrue(
      skincare.waitForExistence(timeout: 10),
      "The verified navabr menu must expose its All Skincare parent."
    )
    assertHittable(skincare)
    for identifier in [
      "shop-featured-trending-on-social",
      "shop-featured-only-at-beautyontapp",
      "shop-featured-bestsellers",
      "shop-featured-hyperpigmentation",
      "shop-featured-local-owned-brands",
      "shop-featured-luxury-skincare",
      "shop-featured-k-beauty",
    ] {
      XCTAssertTrue(
        app.buttons[identifier].waitForExistence(timeout: 5),
        "Shop must preserve every Featured destination from the verified theme."
      )
    }
    keepScreenshot(named: "Native-Shop-Source-Locked")
    skincare.tap()

    let skincarePanel = app.scrollViews["shop-panel-all-skincare"]
    XCTAssertTrue(
      skincarePanel.waitForExistence(timeout: 5),
      "All Skincare must open its verified nested menu."
    )
    keepScreenshot(named: "Native-Shop-All-Skincare")

    let directAllSkincare = app.buttons["shop-menu-item-all-skincare"]
    let helpMeChoose = app.buttons["shop-menu-item-help-me-choose"]
    XCTAssertTrue(directAllSkincare.waitForExistence(timeout: 5))
    XCTAssertTrue(helpMeChoose.waitForExistence(timeout: 5))
    assertHittable(helpMeChoose)
    helpMeChoose.tap()

    XCTAssertTrue(
      skincarePanel.waitForExistence(timeout: 5),
      "Nested Skincare groups must expand inside the verified glass accordion."
    )
    XCTAssertTrue(
      app.buttons["shop-menu-item-body-acne-smooth-skin"]
        .waitForExistence(timeout: 5)
    )
    keepScreenshot(named: "Native-Shop-Help-Me-Choose")

    helpMeChoose.tap()

    XCTAssertTrue(directAllSkincare.waitForExistence(timeout: 5))
    assertHittable(directAllSkincare)
    directAllSkincare.tap()

    XCTAssertTrue(
      app.scrollViews["collection-skincare"].waitForExistence(timeout: 5),
      "The direct All Skincare row must use its verified collection URL."
    )
    keepScreenshot(named: "Shop-Skincare-Native-Collection")
  }

  func testBackgroundResumeKeepsHomeUsableWithoutReconnectOverlay() {
    launchApp()
    assertCurrentHomeChrome()

    XCUIDevice.shared.press(.home)
    app.activate()

    XCTAssertTrue(
      app.buttons["Search"].waitForExistence(timeout: 5),
      "Returning from another app must preserve the native storefront."
    )
    XCTAssertFalse(
      app.staticTexts["Let’s reconnect"].exists,
      "A normal background/resume cycle must not show a reconnect blocker."
    )
    XCTAssertTrue(app.buttons["Shop"].isHittable)
  }

  func testAskBestieOpensOnlyTheChatAndSurvivesBackgroundResume() {
    launchApp(arguments: ["-ui-test-bestie-fixture"])

    openProfileDestination("profile-ask-bestie")

    XCTAssertTrue(
      app.descendants(matching: .any)["bestie-isolated-web-flow"]
        .waitForExistence(timeout: 5),
      "Ask Bestie must use its isolated full-screen chat flow."
    )

    let ready = app.descendants(matching: .any)["bestie-isolated-ready"]
    let didBecomeReady = ready.waitForExistence(timeout: 8)
    XCTAssertTrue(
      didBecomeReady,
      "Ask Bestie must not uncover WebKit until its visible panel posts ready."
    )
    XCTAssertTrue(
      app.staticTexts["Ask Bestie fixture chat"].waitForExistence(timeout: 3),
      "The fixture chat panel inside the widget shadow root must be visible."
    )
    XCTAssertTrue(
      app.textFields["Ask Bestie message"].waitForExistence(timeout: 3),
      "The visible Ask Bestie panel must expose its message field."
    )
    XCTAssertFalse(
      app.buttons["Done"].exists,
      "Ask Bestie must not look like a generic in-app browser."
    )
    XCTAssertFalse(app.staticTexts["beautyontapp.com"].exists)
    XCTAssertFalse(
      app.staticTexts["STOREFRONT SHELL SENTINEL"].exists,
      "Document-start isolation must hide the storefront fixture."
    )

    XCUIDevice.shared.press(.home)
    app.activate()

    XCTAssertTrue(
      app.descendants(matching: .any)["bestie-isolated-ready"]
        .waitForExistence(timeout: 8),
      "Ask Bestie must remain open after returning to the app."
    )
    XCTAssertTrue(app.staticTexts["Ask Bestie fixture chat"].exists)
    XCTAssertFalse(app.staticTexts["STOREFRONT SHELL SENTINEL"].exists)
    XCTAssertFalse(app.staticTexts["Let’s reconnect"].exists)

    let minimize = app.buttons["Minimize Ask Bestie"]
    XCTAssertTrue(
      minimize.waitForExistence(timeout: 3),
      "The fixture must expose the widget minimize control."
    )
    assertHittable(minimize)
    minimize.tap()

    XCTAssertTrue(
      app.descendants(matching: .any)["bestie-isolated-web-flow"]
        .waitForNonExistence(timeout: 5),
      "The widget minimize control must dismiss the isolated native cover."
    )
    XCTAssertTrue(
      app.scrollViews["home-screen"].waitForExistence(timeout: 5),
      "Dismissing Ask Bestie must restore the native storefront."
    )
    keepScreenshot(named: "Ask-Bestie-Isolated-Resume")
  }

  func testProfileCommonRowsOpenAndCloseNativeLovesAndIngredientGuide() {
    launchApp()

    let profile = app.buttons["dock-profile"]
    XCTAssertTrue(profile.waitForExistence(timeout: 5))
    assertHittable(profile)
    profile.tap()

    let profileModal = app.descendants(matching: .any)["profile-modal"]
    XCTAssertTrue(
      profileModal.waitForExistence(timeout: 5),
      "Profile must open as the native modal."
    )

    for row in [
      (
        "profile-cart",
        "Cart, Review your items"
      ),
      (
        "profile-buy-it-again",
        "Buy It Again, Reorder from in-store and online purchases"
      ),
      (
        "profile-order-tracking",
        "Track My Order, See dispatch status and tracking details"
      ),
      (
        "profile-stores",
        "Stores, Choose your store"
      ),
      (
        "profile-loves",
        "Loves, View saved products"
      ),
      (
        "profile-ingredient-guide",
        "Ingredient Guide, Learn what skincare ingredients do"
      ),
      (
        "profile-ask-bestie",
        "Ask Bestie, Chat with our beauty assistant"
      ),
    ] {
      let control = app.buttons[row.0]
      XCTAssertTrue(
        control.waitForExistence(timeout: 5),
        "Profile is missing its common \(row.0) row."
      )
      XCTAssertEqual(
        control.label,
        row.1,
        "The \(row.0) row must retain the exact native title and subtitle."
      )
    }

    let profileContent = app.scrollViews["profile-content"]
    let ingredientGuide = app.buttons["profile-ingredient-guide"]
    scroll(profileContent, untilHittable: ingredientGuide)
    assertHittable(ingredientGuide)
    ingredientGuide.tap()

    let nativeIngredientGuide = app.descendants(matching: .any)[
      "ingredient-guide"
    ]
    XCTAssertTrue(
      nativeIngredientGuide.waitForExistence(timeout: 5),
      "Ingredient Guide must open as its native full-screen experience."
    )
    XCTAssertFalse(app.staticTexts["beautyontapp.com"].exists)

    let closeIngredientGuide = app.buttons["ingredient-guide-close"]
    XCTAssertTrue(closeIngredientGuide.waitForExistence(timeout: 5))
    assertMinimumTapTarget(closeIngredientGuide)
    assertHittable(closeIngredientGuide)
    closeIngredientGuide.tap()
    XCTAssertTrue(
      nativeIngredientGuide.waitForNonExistence(timeout: 5),
      "Closing Ingredient Guide must dismiss the native experience."
    )

    XCTAssertTrue(profile.waitForExistence(timeout: 5))
    assertHittable(profile)
    profile.tap()
    XCTAssertTrue(profileModal.waitForExistence(timeout: 5))

    let loves = app.buttons["profile-loves"]
    scroll(app.scrollViews["profile-content"], untilHittable: loves)
    assertHittable(loves)
    loves.tap()

    let nativeLoves = app.scrollViews["loves-view"]
    XCTAssertTrue(
      nativeLoves.waitForExistence(timeout: 5),
      "Loves must open as its native sheet."
    )
    XCTAssertFalse(app.staticTexts["beautyontapp.com"].exists)

    let closeLoves = app.buttons["loves-close"]
    XCTAssertTrue(closeLoves.waitForExistence(timeout: 5))
    assertHittable(closeLoves)
    closeLoves.tap()
    XCTAssertTrue(
      nativeLoves.waitForNonExistence(timeout: 5),
      "Closing Loves must dismiss the native sheet."
    )
    XCTAssertTrue(
      app.scrollViews["home-screen"].waitForExistence(timeout: 5),
      "Closing the profile destinations must restore the native storefront."
    )
  }

  func testSkincareFirstTwoCardsFillIPhone17ProMaxGrid() {
    launchApp()

    let skincare = app.buttons["header-tab-skincare"]
    XCTAssertTrue(skincare.waitForExistence(timeout: 5))
    assertHittable(skincare)
    skincare.tap()

    let collection = app.scrollViews["collection-skincare"]
    XCTAssertTrue(collection.waitForExistence(timeout: 5))

    let productCards = app.descendants(matching: .any).matching(
      NSPredicate(format: "identifier BEGINSWITH 'product-card-'")
    )
    let first = productCards.element(boundBy: 0)
    let second = productCards.element(boundBy: 1)
    XCTAssertTrue(
      first.waitForExistence(timeout: 20),
      "The live Skincare collection must expose its first product card."
    )
    XCTAssertTrue(
      second.waitForExistence(timeout: 20),
      "The live Skincare collection must expose its second product card."
    )

    let orderedCards = [first, second].sorted {
      $0.frame.minX < $1.frame.minX
    }
    let leftCard = orderedCards[0]
    let rightCard = orderedCards[1]
    let leftInset = leftCard.frame.minX - app.frame.minX
    let rightInset = app.frame.maxX - rightCard.frame.maxX
    let interCardGap = rightCard.frame.minX - leftCard.frame.maxX

    XCTAssertGreaterThanOrEqual(
      leftInset,
      0,
      "The first card must remain inside the display."
    )
    XCTAssertLessThanOrEqual(
      abs(leftInset - rightInset),
      2,
      "The compact product grid must remain centred."
    )
    XCTAssertGreaterThanOrEqual(
      rightInset,
      0,
      "The second card must remain inside the display."
    )
    XCTAssertGreaterThanOrEqual(
      leftCard.frame.width,
      172,
      "The product grid must use the available display width."
    )
    XCTAssertLessThanOrEqual(
      leftCard.frame.width,
      182,
      "The cards must remain one measured step below the previous zoomed-in layout."
    )
    XCTAssertGreaterThanOrEqual(
      interCardGap,
      8,
      "The two-column grid must preserve at least 8 points between cards."
    )
    XCTAssertLessThanOrEqual(
      interCardGap,
      12,
      "The compact two-column grid must not waste width between cards."
    )
    XCTAssertLessThanOrEqual(
      abs(leftCard.frame.minY - rightCard.frame.minY),
      2,
      "The first two products must occupy the same grid row."
    )
    XCTAssertLessThanOrEqual(
      abs(leftCard.frame.height - rightCard.frame.height),
      2,
      "Different product data must not create uneven card heights."
    )

    let firstHandle =
      "pastry-skincare-niacinamide-body-lotion-grapefruit-fragrance"
    let secondHandle = "anti-pigment-hand-cream-spf30"
    let firstRating = app.descendants(matching: .any)[
      "product-card-rating-\(firstHandle)"
    ]
    let secondRating = app.descendants(matching: .any)[
      "product-card-rating-\(secondHandle)"
    ]
    XCTAssertTrue(
      firstRating.waitForExistence(timeout: 20),
      "The product card must expose its live Shopify review summary."
    )
    XCTAssertTrue(
      secondRating.waitForExistence(timeout: 20),
      "Every reviewed product must expose its live Shopify review summary."
    )
    XCTAssertTrue(firstRating.label.contains("reviews"))
    XCTAssertTrue(secondRating.label.contains("reviews"))

    let firstAction = app.buttons["product-card-options-\(firstHandle)"]
    let secondAction = app.buttons["product-card-add-\(secondHandle)"]
    XCTAssertTrue(firstAction.waitForExistence(timeout: 5))
    XCTAssertTrue(secondAction.waitForExistence(timeout: 5))
    XCTAssertLessThanOrEqual(
      abs(firstAction.frame.minY - secondAction.frame.minY),
      2,
      "All card actions must share one baseline."
    )
    XCTAssertGreaterThanOrEqual(
      leftCard.frame.maxY - firstAction.frame.maxY,
      12,
      "The product action must retain bottom breathing room."
    )
    keepScreenshot(named: "Skincare-Aligned-Rated-Product-Cards")
  }

  func testLiveProductPayflexOpensNativeInformationSheet() {
    launchApp()

    let skincare = app.buttons["header-tab-skincare"]
    XCTAssertTrue(skincare.waitForExistence(timeout: 5))
    assertHittable(skincare)
    skincare.tap()

    let collection = app.scrollViews["collection-skincare"]
    XCTAssertTrue(collection.waitForExistence(timeout: 5))

    let product = app.buttons[
      "product-link-pastry-skincare-niacinamide-body-lotion-grapefruit-fragrance"
    ]
    XCTAssertTrue(
      product.waitForExistence(timeout: 20),
      "The live Skincare contract must include Niacinamide Body Lotion."
    )
    scroll(collection, untilHittable: product)
    assertHittable(product)
    product.tap()

    let productDetail = app.scrollViews["product-detail"]
    XCTAssertTrue(
      productDetail.waitForExistence(timeout: 5),
      "The verified live product must open natively."
    )

    let payflex = app.buttons["product-payment-provider-payflex"]
    scroll(productDetail, untilHittable: payflex)
    XCTAssertTrue(
      payflex.waitForExistence(timeout: 10),
      "The live product must expose its interactive Payflex control."
    )
    assertMinimumTapTarget(payflex)
    assertHittable(payflex)

    for walletMark in ["Apple Pay", "Google Pay"] {
      let mark = app.descendants(matching: .any).matching(
        NSPredicate(format: "label == %@", walletMark)
      ).firstMatch
      XCTAssertTrue(
        mark.waitForExistence(timeout: 5),
        "The live product must expose the static \(walletMark) mark."
      )
      XCTAssertFalse(
        app.buttons[walletMark].exists,
        "The static \(walletMark) mark must not masquerade as a button."
      )
    }

    payflex.tap()
    let providerSheet = app.scrollViews[
      "product-payment-provider-sheet"
    ]
    XCTAssertTrue(
      providerSheet.waitForExistence(timeout: 5),
      "Payflex must open the native product-payment-provider-sheet."
    )

    let close = app.buttons["product-payment-provider-close"]
    XCTAssertTrue(close.waitForExistence(timeout: 5))
    assertMinimumTapTarget(close)
    assertHittable(close)
    close.tap()
    XCTAssertTrue(providerSheet.waitForNonExistence(timeout: 5))
  }

  func testLiveAskBestieUsesReadyBridgeWithoutBrowserChrome() {
    launchApp()

    openProfileDestination("profile-ask-bestie")

    let isolatedFlow = app.descendants(matching: .any)[
      "bestie-isolated-web-flow"
    ]
    XCTAssertTrue(
      isolatedFlow.waitForExistence(timeout: 5),
      "Live Ask Bestie must open inside its isolated native flow."
    )

    let ready = app.descendants(matching: .any)["bestie-isolated-ready"]
    XCTAssertTrue(
      ready.waitForExistence(timeout: 35),
      "The live widget must post its panel-ready bridge before being shown."
    )
    XCTAssertFalse(
      app.buttons["Done"].exists,
      "Live Ask Bestie must not expose generic browser chrome."
    )
    XCTAssertFalse(
      app.staticTexts["beautyontapp.com"].exists,
      "Live Ask Bestie must not expose a storefront hostname."
    )

    let widgetDismiss = app.buttons.matching(
      NSPredicate(
        format: "label CONTAINS[c] 'minimize' OR identifier CONTAINS[c] 'askTimmy-minimize'"
      )
    ).firstMatch

    if widgetDismiss.waitForExistence(timeout: 5) {
      assertHittable(widgetDismiss)
      widgetDismiss.tap()

      XCTAssertTrue(
        isolatedFlow.waitForNonExistence(timeout: 5),
        "Dismissing live Ask Bestie must restore the native storefront."
      )
      XCTAssertTrue(app.scrollViews["home-screen"].waitForExistence(timeout: 5))
    }
  }

  func testNativeSearchBagAndProductSurfacesOpen() {
    launchApp()
    let search = app.buttons["header-search"]
    XCTAssertTrue(search.waitForExistence(timeout: 5))
    search.tap()
    XCTAssertTrue(
      app.scrollViews["search-screen"].waitForExistence(timeout: 5)
    )
    XCTAssertTrue(app.staticTexts["Search BeautyOnTApp"].exists)
    keepScreenshot(named: "Native-Search")
    app.buttons["Done"].tap()

    let bag = app.buttons.matching(
      NSPredicate(format: "label BEGINSWITH 'Bag,'")
    ).firstMatch
    XCTAssertTrue(bag.waitForExistence(timeout: 5))
    assertHittable(bag)
    bag.tap()
    XCTAssertTrue(
      app.staticTexts["Your cart is empty"].waitForExistence(timeout: 5)
    )
    let continueShopping = app.buttons["empty-cart-continue"]
    XCTAssertTrue(
      continueShopping.waitForExistence(timeout: 5),
      "The empty-bag action must be visible."
    )
    XCTAssertTrue(
      continueShopping.isHittable,
      "The empty-bag action must not be clipped by the sheet."
    )
    XCTAssertLessThan(
      continueShopping.frame.maxY,
      app.frame.maxY - 24,
      "The empty-bag action must remain fully inside the visible sheet."
    )
    keepScreenshot(named: "Native-Empty-Bag")
    let closeCart = app.buttons["cart-close"]
    XCTAssertTrue(closeCart.waitForExistence(timeout: 5))
    closeCart.tap()

    let skincare = app.buttons["header-tab-skincare"]
    XCTAssertTrue(skincare.waitForExistence(timeout: 5))
    assertHittable(skincare)
    skincare.tap()
    XCTAssertTrue(
      app.scrollViews["collection-skincare"].waitForExistence(timeout: 5)
    )

    let firstProduct = app.buttons.matching(
      NSPredicate(format: "identifier BEGINSWITH 'product-link-'")
    ).firstMatch
    XCTAssertTrue(
      firstProduct.waitForExistence(timeout: 10),
      "A native collection must expose tappable native product cards."
    )
    firstProduct.tap()
    XCTAssertTrue(
      app.scrollViews["product-detail"].waitForExistence(timeout: 5)
    )
    keepScreenshot(named: "Native-Product-Detail")

    let home = app.buttons["dock-home"]
    assertHittable(home)
    home.tap()
    XCTAssertTrue(
      app.scrollViews["home-screen"].waitForExistence(timeout: 5),
      "Home must pop a pushed product instead of becoming a no-op."
    )
    XCTAssertFalse(app.scrollViews["product-detail"].exists)
  }

  func testNativeProductOptionsCartAndSwipeBackFlow() {
    launchApp()

    let skincare = app.buttons["header-tab-skincare"]
    XCTAssertTrue(skincare.waitForExistence(timeout: 5))
    skincare.tap()

    let collection = app.scrollViews["collection-skincare"]
    XCTAssertTrue(collection.waitForExistence(timeout: 5))

    let handle =
      "pastry-skincare-niacinamide-body-lotion-grapefruit-fragrance"
    let chooseOptions = app.buttons[
      "product-card-options-\(handle)"
    ]
    XCTAssertTrue(
      chooseOptions.waitForExistence(timeout: 20),
      "The verified multi-option product must expose a native options action."
    )
    scroll(collection, untilHittable: chooseOptions)
    assertHittable(chooseOptions)
    chooseOptions.tap()

    let optionsSheet = app.descendants(matching: .any)[
      "product-options-\(handle)"
    ]
    XCTAssertTrue(
      optionsSheet.waitForExistence(timeout: 8),
      "Choose fragrance must open the native product option sheet."
    )
    XCTAssertLessThanOrEqual(
      optionsSheet.frame.height,
      390,
      "A simple product option sheet must not leave an empty lower panel."
    )
    keepScreenshot(named: "Native-Compact-Product-Options")
    XCTAssertFalse(app.staticTexts["beautyontapp.com"].exists)

    let add = app.buttons["product-options-add"]
    XCTAssertTrue(add.waitForExistence(timeout: 8))
    assertHittable(add)
    add.tap()

    let profile = app.buttons["dock-profile"]
    XCTAssertTrue(profile.waitForExistence(timeout: 5))
    let oneItemBadge = XCTNSPredicateExpectation(
      predicate: NSPredicate(
        format: "label CONTAINS %@",
        "1 item in cart"
      ),
      object: profile
    )
    XCTAssertEqual(
      XCTWaiter.wait(for: [oneItemBadge], timeout: 15),
      .completed,
      "The Profile dock badge must show the first cart item immediately."
    )

    let directAddHandle = "anti-pigment-hand-cream-spf30"
    let directAdd = app.buttons[
      "product-card-add-\(directAddHandle)"
    ]
    XCTAssertTrue(directAdd.waitForExistence(timeout: 8))
    assertHittable(directAdd)
    directAdd.tap()

    let quantity = app.descendants(matching: .any)[
      "product-card-quantity-\(directAddHandle)"
    ]
    XCTAssertTrue(
      quantity.waitForExistence(timeout: 15),
      "Direct add must replace the card CTA with its native quantity."
    )

    let bag = app.buttons["header-bag"]
    XCTAssertTrue(bag.waitForExistence(timeout: 5))
    XCTAssertTrue(
      bag.label.contains("2 items"),
      "The bag badge and accessibility count must update immediately."
    )
    XCTAssertTrue(
      profile.label.contains("2 items in cart"),
      "The Profile dock badge must stay in sync with the live cart quantity."
    )
    keepScreenshot(named: "Profile-Dock-Live-Cart-Badge")
    bag.tap()

    XCTAssertTrue(
      app.descendants(matching: .any)["cart-drawer"]
        .waitForExistence(timeout: 8),
      "The bag must open the native cart drawer."
    )
    XCTAssertFalse(app.staticTexts["beautyontapp.com"].exists)

    let delivery = app.buttons["cart-delivery-estimator"]
    XCTAssertTrue(delivery.waitForExistence(timeout: 8))
    delivery.tap()

    let province = app.buttons["delivery-province"]
    XCTAssertTrue(
      province.waitForExistence(timeout: 8),
      "Delivery estimates must use the native South African province control."
    )
    province.tap()
    let westernCape = app.buttons["Western Cape"]
    XCTAssertTrue(westernCape.waitForExistence(timeout: 5))
    westernCape.tap()
    XCTAssertTrue(province.label.contains("Western Cape"))

    province.tap()
    let gauteng = app.buttons["Gauteng"]
    XCTAssertTrue(gauteng.waitForExistence(timeout: 5))
    gauteng.tap()
    XCTAssertTrue(province.label.contains("Gauteng"))

    let postcode = app.textFields["delivery-postcode"]
    XCTAssertTrue(postcode.waitForExistence(timeout: 5))
    XCTAssertEqual(
      postcode.value as? String,
      "",
      "The delivery postcode must start blank and require customer input."
    )
    postcode.tap()
    postcode.typeText("2191")

    let getEstimate = app.buttons["delivery-get-estimate"]
    XCTAssertTrue(getEstimate.waitForExistence(timeout: 5))
    if !getEstimate.isHittable {
      app.swipeUp()
    }
    assertHittable(getEstimate)
    getEstimate.tap()
    XCTAssertTrue(
      app.descendants(matching: .any)["delivery-options"]
        .waitForExistence(timeout: 20),
      "The native delivery estimator must return live storefront rates."
    )
    XCTAssertFalse(app.descendants(matching: .any)["delivery-options-empty"].exists)
    app.buttons["Close delivery estimator"].tap()

    // Exercise a second postcode from a clean estimator presentation. Gauteng
    // 2189 is a regression case: the Storefront API can return an empty
    // delivery-group list even though the storefront shipping endpoint has
    // live rates. The native estimator must surface those rates and must not
    // retain the previous postcode's options.
    delivery.tap()
    let alternatePostcode = app.textFields["delivery-postcode"]
    XCTAssertTrue(alternatePostcode.waitForExistence(timeout: 8))
    alternatePostcode.tap()
    alternatePostcode.typeText("2189")
    let alternateEstimate = app.buttons["delivery-get-estimate"]
    XCTAssertTrue(alternateEstimate.waitForExistence(timeout: 5))
    if !alternateEstimate.isHittable {
      app.swipeUp()
    }
    assertHittable(alternateEstimate)
    alternateEstimate.tap()

    let alternateOptions = app.descendants(matching: .any)["delivery-options"]
    let alternateEmpty = app.descendants(matching: .any)["delivery-options-empty"]
    let alternateDeadline = Date().addingTimeInterval(20)
    while Date() < alternateDeadline,
      !alternateOptions.exists,
      !alternateEmpty.exists
    {
      RunLoop.main.run(until: Date().addingTimeInterval(0.25))
    }
    XCTAssertTrue(
      alternateOptions.exists,
      "Gauteng 2189 must surface the live storefront delivery rates rather than the GraphQL empty-group response."
    )
    XCTAssertFalse(alternateEmpty.exists)
    app.buttons["Close delivery estimator"].tap()

    let fullCart = app.buttons["cart-view-full"]
    XCTAssertTrue(fullCart.waitForExistence(timeout: 8))
    fullCart.tap()

    let cartPage = app.otherElements["cart-full"]
    XCTAssertTrue(
      cartPage.waitForExistence(timeout: 8),
      "View Cart must transition to the native full-cart page."
    )
    XCTAssertFalse(
      app.buttons["Back"].exists,
      "Native cart navigation must not add a visible custom back button."
    )

    let leadingEdge = app.coordinate(
      withNormalizedOffset: CGVector(dx: 0.01, dy: 0.52)
    )
    let swipeDestination = app.coordinate(
      withNormalizedOffset: CGVector(dx: 0.82, dy: 0.52)
    )
    leadingEdge.press(
      forDuration: 0.05,
      thenDragTo: swipeDestination,
      withVelocity: .fast,
      thenHoldForDuration: 0
    )
    XCTAssertTrue(
      collection.waitForExistence(timeout: 8),
      "The standard leading-edge swipe must return from the native cart."
    )
    keepScreenshot(named: "Native-Options-Cart-Swipe-Back")
  }

  func testHeaderControlsMeetMinimumTapTargets() {
    launchApp()
    for identifier in [
      "header-home",
      "header-search",
      "header-profile",
      "header-bag",
      "header-menu",
      "header-tab-skincare",
    ] {
      let control = app.buttons[identifier]
      XCTAssertTrue(
        control.waitForExistence(timeout: 5),
        "Missing header control: \(identifier)"
      )
      assertMinimumTapTarget(control)
    }
  }

  func testDockLensCanBeDraggedToNextDestination() {
    launchApp()

    let home = app.buttons["dock-home"]
    let shop = app.buttons["dock-shop"]
    XCTAssertTrue(home.waitForExistence(timeout: 5))
    XCTAssertTrue(shop.waitForExistence(timeout: 5))
    assertHittable(home)
    assertHittable(shop)

    let start = home.coordinate(
      withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)
    )
    let end = shop.coordinate(
      withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)
    )
    start.press(
      forDuration: 0.05,
      thenDragTo: end,
      withVelocity: .fast,
      thenHoldForDuration: 0
    )

    XCTAssertTrue(
      app.descendants(matching: .any)["shop-modal"]
        .waitForExistence(timeout: 8),
      "Dragging across the dock must commit the destination when the finger lifts."
    )
  }

  func testShopModalContainsFocusAndGrabberDismisses() {
    launchApp()
    let shop = app.buttons["dock-shop"]
    XCTAssertTrue(shop.waitForExistence(timeout: 5))
    shop.tap()

    let modal = app.descendants(matching: .any)["shop-modal"]
    XCTAssertTrue(
      modal.waitForExistence(timeout: 5),
      "Shop must expose an identified modal accessibility container."
    )
    XCTAssertFalse(
      app.buttons["dock-home"].exists,
      "The storefront behind Shop must be hidden from accessibility."
    )

    let close = app.buttons["shop-modal-close"]
    XCTAssertTrue(close.waitForExistence(timeout: 5))
    assertMinimumTapTarget(close)
    close.tap()

    XCTAssertTrue(
      shop.waitForExistence(timeout: 5),
      "Dismissing Shop must restore the dock."
    )
    shop.tap()

    let grabber = app.descendants(matching: .any)["shop-modal-grabber"]
    XCTAssertTrue(
      grabber.waitForExistence(timeout: 5),
      "The visible Shop grabber must be an accessible control."
    )
    grabber.coordinate(
      withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)
    ).press(
      forDuration: 0.1,
      thenDragTo: app.coordinate(
        withNormalizedOffset: CGVector(dx: 0.5, dy: 0.78)
      )
    )

    let dismissal = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "exists == false"),
      object: modal
    )
    XCTAssertEqual(
      XCTWaiter.wait(for: [dismissal], timeout: 5),
      .completed,
      "Dragging the visible grabber down must dismiss Shop."
    )
    XCTAssertTrue(shop.waitForExistence(timeout: 5))
  }

  func testFeaturedBlogRendersNativeArticleCards() {
    launchApp()
    let home = app.scrollViews["home-screen"]
    XCTAssertTrue(home.waitForExistence(timeout: 5))

    let rail = app.scrollViews["blog-article-rail"]
    for _ in 0..<14 where !rail.exists {
      home.swipeUp()
    }

    XCTAssertTrue(
      rail.waitForExistence(timeout: 10),
      "The exported news blog must render as native article cards."
    )
    XCTAssertTrue(app.buttons["blog-view-all"].exists)
    XCTAssertTrue(
      app.buttons.matching(
        NSPredicate(format: "identifier BEGINSWITH 'blog-article-'")
      ).firstMatch.exists
    )
    keepScreenshot(named: "Native-Featured-Blog")
  }

  func testHomeRendersNativeLogoWallAndCompleteFooterMenu() {
    launchApp()
    let home = app.scrollViews["home-screen"]
    XCTAssertTrue(home.waitForExistence(timeout: 5))

    let logoWall = app.descendants(matching: .any)["home-logo-wall"]
    for _ in 0..<24 where !logoWall.exists {
      home.swipeUp()
    }
    XCTAssertTrue(
      logoWall.waitForExistence(timeout: 5),
      "The exported storefront logo wall must render natively."
    )

    let screenFrame = app.frame
    let visibleTop = screenFrame.minY + 150
    let visibleBottom = screenFrame.maxY - 110
    for _ in 0..<10 {
      let frame = logoWall.frame
      if frame.minY >= visibleTop && frame.maxY <= visibleBottom {
        break
      }
      let startY: CGFloat = frame.maxY > visibleBottom ? 0.68 : 0.42
      let endY: CGFloat = frame.maxY > visibleBottom ? 0.50 : 0.60
      home.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: startY))
        .press(
          forDuration: 0.05,
          thenDragTo: home.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: endY)
          )
        )
    }
    XCTAssertGreaterThanOrEqual(
      logoWall.frame.minY,
      visibleTop,
      "The logo wall must not be clipped by the header in the capture."
    )
    XCTAssertLessThanOrEqual(
      logoWall.frame.maxY,
      visibleBottom,
      "The complete logo wall must fit above the dock in the capture."
    )
    keepScreenshot(named: "Native-Home-Logo-Wall")

    let copyright = app.staticTexts["© 2026 BeautyOnTApp"]
    for _ in 0..<14 where !copyright.isHittable {
      home.swipeUp()
    }
    XCTAssertTrue(
      app.descendants(matching: .any)["home-native-footer"]
        .waitForExistence(timeout: 5),
      "The full black storefront footer must render natively."
    )
    XCTAssertTrue(copyright.waitForExistence(timeout: 5))
    XCTAssertTrue(
      copyright.isHittable,
      "The complete native footer must be scrollable above the dock."
    )
    XCTAssertTrue(app.staticTexts["Download the BeautyOnTApp App"].exists)
    keepScreenshot(named: "Native-Home-Logo-Wall-And-Footer")

    for menuTitle in [
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
    ] {
      XCTAssertTrue(
        app.buttons[menuTitle].exists || app.staticTexts[menuTitle].exists,
        "Missing native footer menu item: \(menuTitle)"
      )
    }

    for socialTitle in ["Facebook", "Instagram", "TikTok", "X"] {
      XCTAssertTrue(
        app.buttons[socialTitle].exists,
        "Missing native footer social link: \(socialTitle)"
      )
    }
  }

  private func launchApp(arguments: [String] = []) {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = ["-ui-test-reset-cart"] + arguments
    app.launch()
    let launchExperience = app.otherElements["launch-experience"]
    if launchExperience.exists {
      XCTAssertTrue(
        launchExperience.waitForNonExistence(timeout: 6),
        "The cold-start brand animation must hand control to the app."
      )
    }
  }

  private func assertSixItemDock() {
    for (identifier, label) in [
      ("dock-home", "Home"),
      ("dock-shop", "Shop"),
      ("dock-exclusive", "Exclusive"),
      ("dock-profile", "Profile"),
      ("dock-stores", "Stores"),
      ("dock-bestie", "Ask Bestie"),
    ] {
      let destination = app.buttons[identifier]
      XCTAssertTrue(
        destination.waitForExistence(timeout: 5),
        "Missing dock destination: \(label)"
      )
      XCTAssertEqual(
        destination.label,
        label,
        "Dock destination \(identifier) must retain its accessible label."
      )
    }

    XCTAssertFalse(
      app.buttons["dock-search"].exists,
      "Search belongs in the header, not as a detached dock orb."
    )
  }

  private func openProfileDestination(_ identifier: String) {
    let profile = app.buttons["dock-profile"]
    XCTAssertTrue(profile.waitForExistence(timeout: 5))
    assertHittable(profile)
    profile.tap()

    let profileModal = app.descendants(matching: .any)["profile-modal"]
    XCTAssertTrue(
      profileModal.waitForExistence(timeout: 5),
      "Profile must open before selecting \(identifier)."
    )

    let destination = app.buttons[identifier]
    let content = app.scrollViews["profile-content"]
    XCTAssertTrue(destination.waitForExistence(timeout: 5))
    scroll(content, untilHittable: destination)
    assertHittable(destination)
    destination.tap()
  }

  private func assertCurrentHomeChrome() {
    XCTAssertTrue(
      app.scrollViews["home-screen"].waitForExistence(timeout: 5),
      "The native Home storefront must be visible."
    )
    XCTAssertTrue(
      app.buttons["header-search"].exists,
      "Home must retain the native Search control."
    )
    XCTAssertTrue(
      app.buttons["header-menu"].exists,
      "Home must retain the native menu control."
    )
    XCTAssertTrue(
      app.buttons["dock-home"].exists,
      "Home must retain the identified dock destination."
    )
  }

  private func keepScreenshot(named name: String) {
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  private func assertHittable(
    _ element: XCUIElement,
    timeout: TimeInterval = 5
  ) {
    let expectation = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "hittable == true"),
      object: element
    )
    XCTAssertEqual(
      XCTWaiter.wait(for: [expectation], timeout: timeout),
      .completed,
      "Expected \(element) to become hittable."
    )
  }

  private func scroll(
    _ scrollView: XCUIElement,
    untilHittable element: XCUIElement,
    maximumSwipes: Int = 6
  ) {
    for _ in 0..<maximumSwipes where !element.isHittable {
      scrollView.swipeUp()
    }
  }

  private func assertMinimumTapTarget(
    _ element: XCUIElement,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    XCTAssertGreaterThanOrEqual(
      element.frame.width,
      44,
      "Tap target must be at least 44 points wide.",
      file: file,
      line: line
    )
    XCTAssertGreaterThanOrEqual(
      element.frame.height,
      44,
      "Tap target must be at least 44 points high.",
      file: file,
      line: line
    )
  }
}
