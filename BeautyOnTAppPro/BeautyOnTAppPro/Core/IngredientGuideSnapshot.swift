import Foundation

struct IngredientGuideSnapshot: Equatable, Sendable {
  let settings: IngredientGuideSettings
  let filters: [IngredientGuideFilter]
  let ingredients: [IngredientGuideIngredient]

  static let bundled: IngredientGuideSnapshot = {
    do {
      return try IngredientGuideSnapshotLoader.load()
    } catch {
      fatalError("The bundled Ingredient Guide snapshot is invalid: \(error)")
    }
  }()

  func matchingIngredients(query: String) -> [IngredientGuideIngredient] {
    let normalizedQuery = Self.normalized(query)
    guard !normalizedQuery.isEmpty else {
      return ingredients
    }
    return ingredients.filter {
      $0.searchHaystack.contains(normalizedQuery)
    }
  }

  func activeFilterID(query: String) -> String? {
    let normalizedQuery = Self.normalized(query)
    return filters.first {
      Self.normalized($0.query) == normalizedQuery
    }?.id
  }

  fileprivate static func normalized(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  }
}

struct IngredientGuideSettings: Equatable, Sendable {
  let eyebrow: String
  let heading: String
  let introText: String
  let noticeHeading: String
  let noticeText: String
  let searchLabel: String
  let searchPlaceholder: String
  let filterLabel: String
  let noResultsText: String
  let closeLabel: String
  let surfaceColor: String
  let surfaceOpacity: Int
  let backdropOpacity: Int
  let textColor: String
  let mutedTextColor: String
  let borderColor: String
  let accentColor: String
  let linkColor: String
  let focusColor: String
  let headingSize: Int
  let cardTitleSize: Int
  let bodySize: Int
  let contentWidth: Int
  let panelHeight: Int
  let panelRadius: Int
  let cardRadius: Int
  let glassBlur: Int
  let sidePadding: Int
}

struct IngredientGuideFilter: Identifiable, Equatable, Sendable {
  let id: String
  let label: String
  let query: String
}

struct IngredientGuideIngredient: Identifiable, Equatable, Sendable {
  let id: String
  let title: String
  let summary: String
  let body: String
  let searchTerms: String
  let routineLabel: String
  let worksWith: String
  let cautionWith: String
  let beginnerTip: String
  let cardAccent: String
  let pairingSourceLabel: String
  let pairingSourceURL: URL?
  let sourceLabel: String
  let sourceURL: URL?

  var searchHaystack: String {
    [
      title,
      summary,
      searchTerms,
      routineLabel,
      worksWith,
      cautionWith,
    ]
    .joined(separator: " ")
    .lowercased()
  }
}

struct IngredientGuideInteractionState: Equatable, Sendable {
  private(set) var query: String
  private(set) var expandedIngredientID: String?

  init(
    query: String = "",
    expandedIngredientID: String? = nil
  ) {
    self.query = query
    self.expandedIngredientID = expandedIngredientID
  }

  mutating func updateQuery(
    _ newValue: String,
    in guide: IngredientGuideSnapshot
  ) {
    query = newValue
    reconcileExpansion(in: guide)
  }

  mutating func selectFilter(
    _ filter: IngredientGuideFilter,
    in guide: IngredientGuideSnapshot
  ) {
    updateQuery(filter.query, in: guide)
  }

  mutating func toggleIngredient(_ ingredientID: String) {
    expandedIngredientID =
      expandedIngredientID == ingredientID ? nil : ingredientID
  }

  private mutating func reconcileExpansion(
    in guide: IngredientGuideSnapshot
  ) {
    guard let expandedIngredientID else {
      return
    }
    let visibleIDs = Set(
      guide.matchingIngredients(query: query).map(\.id)
    )
    if !visibleIDs.contains(expandedIngredientID) {
      self.expandedIngredientID = nil
    }
  }
}

enum IngredientGuideSnapshotError: Error, Equatable {
  case missingResource
  case malformedRoot
  case missingSettings
}

enum IngredientGuideSnapshotLoader {
  static func load(bundle: Bundle = .main) throws -> IngredientGuideSnapshot {
    let resourceURL =
      bundle.url(
        forResource: "ingredient-guide",
        withExtension: "json",
        subdirectory: "ThemeSnapshot"
      )
      ?? bundle.url(
        forResource: "ingredient-guide",
        withExtension: "json"
      )
    guard let resourceURL else {
      throw IngredientGuideSnapshotError.missingResource
    }
    return try decode(data: Data(contentsOf: resourceURL))
  }

  static func decode(data: Data) throws -> IngredientGuideSnapshot {
    guard
      let root = try JSONSerialization.jsonObject(with: data)
        as? IngredientGuideJSONDictionary,
      root.ingredientString("type") == "bot-ingredient-guide",
      let settingsJSON = root.ingredientDictionary("settings"),
      let blocks = root.ingredientDictionary("blocks"),
      let blockOrder = root.ingredientArray("block_order") as? [String]
    else {
      throw IngredientGuideSnapshotError.malformedRoot
    }

    let settings = try parseSettings(settingsJSON)
    var filters: [IngredientGuideFilter] = []
    var ingredients: [IngredientGuideIngredient] = []

    for blockID in blockOrder {
      guard let block = blocks.ingredientDictionary(blockID),
        let blockSettings = block.ingredientDictionary("settings")
      else {
        throw IngredientGuideSnapshotError.malformedRoot
      }

      switch block.ingredientString("type") {
      case "filter":
        guard let label = blockSettings.ingredientString("label"),
          !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
          continue
        }
        filters.append(
          IngredientGuideFilter(
            id: blockID,
            label: label,
            query: blockSettings.ingredientString("query") ?? ""
          )
        )

      case "ingredient":
        guard let title = blockSettings.ingredientString("title"),
          !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
          continue
        }
        ingredients.append(
          IngredientGuideIngredient(
            id: blockID,
            title: title,
            summary: blockSettings.ingredientString("summary") ?? "",
            body: blockSettings.ingredientString("body") ?? "",
            searchTerms: blockSettings.ingredientString("search_terms") ?? "",
            routineLabel: blockSettings.ingredientString("routine_label") ?? "",
            worksWith: blockSettings.ingredientString("works_with") ?? "",
            cautionWith: blockSettings.ingredientString("caution_with") ?? "",
            beginnerTip: blockSettings.ingredientString("beginner_tip") ?? "",
            cardAccent: blockSettings.ingredientString("card_accent") ?? "",
            pairingSourceLabel:
              blockSettings.ingredientString("pairing_source_label") ?? "",
            pairingSourceURL: try sourceURL(
              blockSettings.ingredientString("pairing_source_url")
            ),
            sourceLabel:
              blockSettings.ingredientString("source_label") ?? "",
            sourceURL: try sourceURL(
              blockSettings.ingredientString("source_url")
            )
          )
        )

      default:
        continue
      }
    }

    return IngredientGuideSnapshot(
      settings: settings,
      filters: filters,
      ingredients: ingredients
    )
  }

  private static func parseSettings(
    _ json: IngredientGuideJSONDictionary
  ) throws -> IngredientGuideSettings {
    guard
      let eyebrow = json.ingredientString("eyebrow"),
      let heading = json.ingredientString("heading"),
      let introText = json.ingredientString("intro_text"),
      let noticeHeading = json.ingredientString("notice_heading"),
      let noticeText = json.ingredientString("notice_text"),
      let searchLabel = json.ingredientString("search_label"),
      let searchPlaceholder = json.ingredientString("search_placeholder"),
      let filterLabel = json.ingredientString("filter_label"),
      let noResultsText = json.ingredientString("no_results_text"),
      let closeLabel = json.ingredientString("close_label"),
      let surfaceColor = json.ingredientString("surface_color"),
      let surfaceOpacity = json.ingredientInteger("surface_opacity"),
      let backdropOpacity = json.ingredientInteger("backdrop_opacity"),
      let textColor = json.ingredientString("text_color"),
      let mutedTextColor = json.ingredientString("muted_text_color"),
      let borderColor = json.ingredientString("border_color"),
      let accentColor = json.ingredientString("accent_color"),
      let linkColor = json.ingredientString("link_color"),
      let focusColor = json.ingredientString("focus_color"),
      let headingSize = json.ingredientInteger("heading_size"),
      let cardTitleSize = json.ingredientInteger("card_title_size"),
      let bodySize = json.ingredientInteger("body_size"),
      let contentWidth = json.ingredientInteger("content_width"),
      let panelHeight = json.ingredientInteger("panel_height"),
      let panelRadius = json.ingredientInteger("panel_radius"),
      let cardRadius = json.ingredientInteger("card_radius"),
      let glassBlur = json.ingredientInteger("glass_blur"),
      let sidePadding = json.ingredientInteger("side_padding")
    else {
      throw IngredientGuideSnapshotError.missingSettings
    }

    return IngredientGuideSettings(
      eyebrow: eyebrow,
      heading: heading,
      introText: introText,
      noticeHeading: noticeHeading,
      noticeText: noticeText,
      searchLabel: searchLabel,
      searchPlaceholder: searchPlaceholder,
      filterLabel: filterLabel,
      noResultsText: noResultsText,
      closeLabel: closeLabel,
      surfaceColor: surfaceColor,
      surfaceOpacity: surfaceOpacity,
      backdropOpacity: backdropOpacity,
      textColor: textColor,
      mutedTextColor: mutedTextColor,
      borderColor: borderColor,
      accentColor: accentColor,
      linkColor: linkColor,
      focusColor: focusColor,
      headingSize: headingSize,
      cardTitleSize: cardTitleSize,
      bodySize: bodySize,
      contentWidth: contentWidth,
      panelHeight: panelHeight,
      panelRadius: panelRadius,
      cardRadius: cardRadius,
      glassBlur: glassBlur,
      sidePadding: sidePadding
    )
  }

  private static func sourceURL(_ rawValue: String?) throws -> URL? {
    guard let rawValue = rawValue?
      .trimmingCharacters(in: .whitespacesAndNewlines),
      !rawValue.isEmpty
    else {
      return nil
    }
    guard let url = URL(string: rawValue),
      url.scheme?.lowercased() == "https"
    else {
      throw IngredientGuideSnapshotError.malformedRoot
    }
    return url
  }
}

private typealias IngredientGuideJSONDictionary = [String: Any]

private extension Dictionary where Key == String, Value == Any {
  func ingredientDictionary(
    _ key: String
  ) -> IngredientGuideJSONDictionary? {
    self[key] as? IngredientGuideJSONDictionary
  }

  func ingredientArray(_ key: String) -> [Any]? {
    self[key] as? [Any]
  }

  func ingredientString(_ key: String) -> String? {
    self[key] as? String
  }

  func ingredientInteger(_ key: String) -> Int? {
    if let value = self[key] as? Int {
      return value
    }
    return (self[key] as? NSNumber)?.intValue
  }
}
