import XCTest

@testable import BeautyOnTAppPro

final class IngredientGuideSnapshotTests: XCTestCase {
  private var guide: IngredientGuideSnapshot {
    .bundled
  }

  func testBundledSnapshotPreservesConfiguredCountsAndOrder() {
    XCTAssertEqual(guide.filters.count, 7)
    XCTAssertEqual(guide.ingredients.count, 24)

    XCTAssertEqual(
      guide.filters.map(\.id),
      [
        "filter_all",
        "filter_breakouts",
        "filter_pigmentation",
        "filter_hydration",
        "filter_texture",
        "filter_ageing",
        "filter_hair",
      ]
    )
    XCTAssertEqual(guide.ingredients.first?.id, "ingredient_retinol")
    XCTAssertEqual(guide.ingredients.first?.title, "Retinol")
    XCTAssertEqual(
      guide.ingredients.last?.id,
      "ingredient_alpha_arbutin"
    )
    XCTAssertEqual(guide.ingredients.last?.title, "Alpha-Arbutin")
  }

  func testBundledSnapshotPreservesEveryConfiguredSetting() {
    let settings = guide.settings

    XCTAssertEqual(settings.eyebrow, "Skincare, explained simply")
    XCTAssertEqual(settings.heading, "Ingredient Guide")
    XCTAssertEqual(
      settings.introText,
      "New to skincare? Start with what you want help with, then open one ingredient at a time. The source link under each card explains where the guidance comes from."
    )
    XCTAssertEqual(settings.noticeHeading, "Good to know.")
    XCTAssertEqual(
      settings.noticeText,
      "This guide is general education, not medical advice. Follow the directions on the product and speak to a qualified health professional about pregnancy, prescriptions, allergies, or a skin condition."
    )
    XCTAssertEqual(settings.searchLabel, "Search ingredients")
    XCTAssertEqual(settings.searchPlaceholder, "Search an ingredient")
    XCTAssertEqual(
      settings.filterLabel,
      "Filter ingredients by concern"
    )
    XCTAssertEqual(
      settings.noResultsText,
      "No ingredient matches that search yet."
    )
    XCTAssertEqual(settings.closeLabel, "Close Ingredient Guide")
    XCTAssertEqual(settings.surfaceColor, "#f5f5f7")
    XCTAssertEqual(settings.surfaceOpacity, 90)
    XCTAssertEqual(settings.backdropOpacity, 30)
    XCTAssertEqual(settings.textColor, "#1d1d1f")
    XCTAssertEqual(settings.mutedTextColor, "#6e6e73")
    XCTAssertEqual(settings.borderColor, "#c7c7cc")
    XCTAssertEqual(settings.accentColor, "#f5d7df")
    XCTAssertEqual(settings.linkColor, "#0066cc")
    XCTAssertEqual(settings.focusColor, "#007aff")
    XCTAssertEqual(settings.headingSize, 26)
    XCTAssertEqual(settings.cardTitleSize, 17)
    XCTAssertEqual(settings.bodySize, 16)
    XCTAssertEqual(settings.contentWidth, 720)
    XCTAssertEqual(settings.panelHeight, 88)
    XCTAssertEqual(settings.panelRadius, 28)
    XCTAssertEqual(settings.cardRadius, 18)
    XCTAssertEqual(settings.glassBlur, 24)
    XCTAssertEqual(settings.sidePadding, 20)
  }

  func testFilterLabelsAndQueriesAreSnapshotExact() {
    XCTAssertEqual(
      guide.filters.map(\.label),
      [
        "All ingredients",
        "Breakouts & pores",
        "Dark spots",
        "Dry & barrier",
        "Texture",
        "Visible ageing",
        "Hair & scalp",
      ]
    )
    XCTAssertEqual(
      guide.filters.map(\.query),
      [
        "",
        "acne",
        "pigmentation",
        "hydration",
        "texture",
        "ageing",
        "hair",
      ]
    )
  }

  func testIngredientFieldsAndSourcesAreSnapshotExact() throws {
    let retinol = try XCTUnwrap(guide.ingredients.first)

    XCTAssertEqual(retinol.id, "ingredient_retinol")
    XCTAssertEqual(retinol.title, "Retinol")
    XCTAssertEqual(
      retinol.summary,
      "For clogged pores, dark spots and visible ageing"
    )
    XCTAssertEqual(
      retinol.body,
      "Retinol is an over-the-counter retinoid. It can help unclog pores and reduce the look of fine lines and dark spots. Follow the product directions because irritation can happen."
    )
    XCTAssertEqual(
      retinol.searchTerms,
      "retinoid vitamin a acne fine lines pigmentation"
    )
    XCTAssertEqual(retinol.routineLabel, "PM")
    XCTAssertEqual(
      retinol.worksWith,
      "Moisturiser to help reduce dryness and irritation."
    )
    XCTAssertEqual(
      retinol.cautionWith,
      "Do not use during pregnancy. Use daytime sun protection and avoid applying to very dry, red or inflamed skin unless advised by a dermatologist."
    )
    XCTAssertEqual(
      retinol.beginnerTip,
      "Start with the least-intense formula every other night, then build up slowly."
    )
    XCTAssertEqual(retinol.cardAccent, "#f5d7df")
    XCTAssertNil(retinol.pairingSourceURL)
    XCTAssertEqual(
      retinol.sourceLabel,
      "Source: American Academy of Dermatology"
    )
    XCTAssertEqual(
      retinol.sourceURL?.absoluteString,
      "https://www.aad.org/public/everyday-care/skin-care-secrets/anti-aging/retinoid-retinol"
    )

    let vitaminC = try XCTUnwrap(
      guide.ingredients.first { $0.id == "ingredient_vitamin_c" }
    )
    XCTAssertEqual(
      vitaminC.pairingSourceURL?.absoluteString,
      "https://www.aad.org/public/everyday-care/skin-care-basics/care/skin-care-in-your-20s"
    )
  }

  func testSearchMatchesOnlyTheThemeSearchHaystack() {
    XCTAssertEqual(
      guide.matchingIngredients(query: "vitamin b3").map(\.title),
      ["Niacinamide"]
    )
    XCTAssertEqual(
      guide.matchingIngredients(query: "antioxidant").map(\.title),
      ["Vitamin C"]
    )
    XCTAssertEqual(
      guide.matchingIngredients(query: "pregnancy").map(\.title),
      ["Retinol"]
    )
    XCTAssertTrue(
      guide.matchingIngredients(query: "promise of results").isEmpty,
      "Body copy is intentionally excluded from the exported theme search haystack."
    )
    XCTAssertEqual(
      guide.matchingIngredients(query: "  VITAMIN B3 \n").map(\.title),
      ["Niacinamide"]
    )
  }

  func testConfiguredFilterQueriesReturnExpectedIngredients() {
    XCTAssertEqual(
      guide.matchingIngredients(query: "hair").map(\.title),
      ["Shea Butter", "Argan Oil"]
    )
    XCTAssertEqual(
      guide.matchingIngredients(query: "texture").map(\.title),
      ["Glycolic Acid", "Ginseng", "Lactic Acid", "Mandelic Acid"]
    )
  }

  func testActiveFilterRequiresAnExactNormalizedQueryMatch() {
    XCTAssertEqual(guide.activeFilterID(query: ""), "filter_all")
    XCTAssertEqual(
      guide.activeFilterID(query: " PIGMENTATION "),
      "filter_pigmentation"
    )
    XCTAssertNil(guide.activeFilterID(query: "dark spots"))
  }

  func testInteractionAllowsOnlyOneExpandedIngredient() {
    var state = IngredientGuideInteractionState()

    state.toggleIngredient("ingredient_retinol")
    XCTAssertEqual(state.expandedIngredientID, "ingredient_retinol")

    state.toggleIngredient("ingredient_niacinamide")
    XCTAssertEqual(state.expandedIngredientID, "ingredient_niacinamide")

    state.toggleIngredient("ingredient_niacinamide")
    XCTAssertNil(state.expandedIngredientID)
  }

  func testFilteringClosesAnExpandedIngredientThatBecomesHidden() throws {
    var state = IngredientGuideInteractionState()
    state.toggleIngredient("ingredient_retinol")

    let vitaminB3Filter = IngredientGuideFilter(
      id: "test",
      label: "Vitamin B3",
      query: "vitamin b3"
    )
    state.selectFilter(vitaminB3Filter, in: guide)

    XCTAssertEqual(state.query, "vitamin b3")
    XCTAssertNil(state.expandedIngredientID)

    let niacinamide = try XCTUnwrap(
      guide.matchingIngredients(query: state.query).first
    )
    state.toggleIngredient(niacinamide.id)
    state.updateQuery("nicotinamide", in: guide)

    XCTAssertEqual(
      state.expandedIngredientID,
      "ingredient_niacinamide"
    )
  }

  func testDecoderRejectsMissingConfiguredSettings() {
    let data = Data(
      """
      {
        "type": "bot-ingredient-guide",
        "settings": {},
        "blocks": {},
        "block_order": []
      }
      """.utf8
    )

    XCTAssertThrowsError(
      try IngredientGuideSnapshotLoader.decode(data: data)
    ) { error in
      XCTAssertEqual(
        error as? IngredientGuideSnapshotError,
        .missingSettings
      )
    }
  }

  func testDecoderRejectsNonHTTPSConfiguredSourceURL() throws {
    let sourceURL = try XCTUnwrap(
      Bundle.main.url(
        forResource: "ingredient-guide",
        withExtension: "json",
        subdirectory: "ThemeSnapshot"
      )
      ?? Bundle.main.url(
        forResource: "ingredient-guide",
        withExtension: "json"
      )
    )
    let sourceData = try Data(contentsOf: sourceURL)
    var root = try XCTUnwrap(
      try JSONSerialization.jsonObject(with: sourceData)
        as? [String: Any]
    )
    var blocks = try XCTUnwrap(
      root["blocks"] as? [String: Any]
    )
    var retinol = try XCTUnwrap(
      blocks["ingredient_retinol"] as? [String: Any]
    )
    var settings = try XCTUnwrap(
      retinol["settings"] as? [String: Any]
    )
    settings["source_url"] = "http://example.com"
    retinol["settings"] = settings
    blocks["ingredient_retinol"] = retinol
    root["blocks"] = blocks
    let data = try JSONSerialization.data(withJSONObject: root)

    XCTAssertThrowsError(
      try IngredientGuideSnapshotLoader.decode(data: data)
    ) { error in
      XCTAssertEqual(
        error as? IngredientGuideSnapshotError,
        .malformedRoot
      )
    }
  }
}
