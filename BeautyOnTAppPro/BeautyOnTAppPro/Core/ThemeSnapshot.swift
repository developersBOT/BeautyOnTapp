import Foundation

enum StorefrontThemeSource {
  /// Native preview builds must use the same published storefront as the
  /// customer-facing app. Keeping a preview theme identifier here caused the
  /// app to request stale theme sections after that theme became live.
  static var activeDraftThemeID: String? {
    nil
  }

  static var homeSnapshotResourceName: String {
    activeDraftThemeID == nil ? "index" : "index-preview"
  }

  static func activeDraftThemeID(
    bundleIdentifier: String?
  ) -> String? {
    nil
  }

  static func applyingDraftTheme(
    to url: URL,
    themeID: String?
  ) -> URL {
    guard let themeID,
      var components = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
      )
    else {
      return url
    }

    var items = components.queryItems ?? []
    items.removeAll { $0.name == "preview_theme_id" }
    items.append(
      URLQueryItem(name: "preview_theme_id", value: themeID)
    )
    components.queryItems = items
    return components.url ?? url
  }
}

struct ThemeHomeSnapshot {
  let sections: [ThemeHomeSection]

  static let live: ThemeHomeSnapshot = {
    (try? ThemeSnapshotLoader.loadHome(resourceName: "index"))
      ?? ThemeHomeSnapshot(sections: [])
  }()

  static let bundled: ThemeHomeSnapshot = {
    (try? ThemeSnapshotLoader.loadHome(
      resourceName: StorefrontThemeSource.homeSnapshotResourceName
    )) ?? ThemeHomeSnapshot(sections: [])
  }()

  static let preview: ThemeHomeSnapshot = {
    (try? ThemeSnapshotLoader.loadHome(resourceName: "index-preview"))
      ?? ThemeHomeSnapshot(sections: [])
  }()
}

struct ThemeGreeting: Equatable {
  let kicker: String
  let prefix: String
  let suffix: String
  let subtext: String
}

struct ThemeHeroSlide: Identifiable, Equatable {
  let id: String
  let backgroundColor: String?
  let textColor: String?
  let imageReference: String?
  let heading: String
  let detail: String
  let buttonLabel: String
  let link: ThemeLink
}

struct ThemeProductRail: Equatable {
  let eyebrow: String
  let heading: String
  let collectionHandle: String
  let linkLabel: String
  let productCount: Int
}

struct ThemeSmartAnalysis: Equatable {
  let eyebrow: String
  let heading: String
  let detail: String
  let buttonLabel: String
  let link: ThemeLink
  let chips: [ThemeSmartChip]
}

struct ThemeSmartChip: Identifiable, Equatable {
  let id: String
  let label: String
  let price: String
  let link: ThemeLink
}

struct ThemeContentRail: Equatable {
  let eyebrow: String
  let heading: String
  let cards: [ThemeContentCard]
}

struct ThemeContentCard: Identifiable, Equatable {
  let id: String
  let imageReference: String?
  let heading: String
  let detailText: String
  let linkLabel: String
  let link: ThemeLink
}

struct ThemeRoutineRail: Equatable {
  let introEyebrow: String
  let introHeading: String
  let heading: String
  let period: String
  let cards: [ThemeRoutineCard]
}

struct ThemeRoutineCard: Identifiable, Equatable {
  let id: String
  let period: String
  let name: String
  let link: ThemeLink
}

struct ThemeGuidance: Equatable {
  let heading: String
  let subheading: String
  let cards: [ThemeGuidanceCard]
}

struct ThemeGuidanceCard: Identifiable, Equatable {
  let id: String
  let imageReference: String?
  let heading: String
  let link: ThemeLink
}

struct ThemeBlog: Equatable {
  let heading: String
  let handle: String
  let linkLabel: String
  let articleCount: Int
  let gridColumns: Int
  let isCarousel: Bool
  let showsCategory: Bool
  let isFullWidth: Bool
  let textAlignment: String
}

struct ThemeLogoRail: Equatable {
  let logos: [ThemeLogo]
}

struct ThemeLogo: Identifiable, Equatable {
  let id: String
  let imageReference: String?
  let altText: String
  let link: ThemeLink
}

enum ThemeHomeSection: Identifiable {
  case greeting(String, ThemeGreeting)
  case hero(String, [ThemeHeroSlide])
  case productRail(String, ThemeProductRail)
  case smartAnalysis(String, ThemeSmartAnalysis)
  case contentRail(String, ThemeContentRail)
  case routine(String, ThemeRoutineRail)
  case guidance(String, ThemeGuidance)
  case blog(String, ThemeBlog)
  case logos(String, ThemeLogoRail)

  var id: String {
    switch self {
    case .greeting(let id, _),
      .hero(let id, _),
      .productRail(let id, _),
      .smartAnalysis(let id, _),
      .contentRail(let id, _),
      .routine(let id, _),
      .guidance(let id, _),
      .blog(let id, _),
      .logos(let id, _):
      return id
    }
  }
}

enum ThemeLink: Equatable {
  case collection(String)
  case booking(URL)
  case web(URL)
  case external(URL)
  case none

  private static let bookingPaths: Set<String> = [
    "/pages/make-services",
  ]

  init(_ rawValue: String?) {
    guard var rawValue = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines),
      !rawValue.isEmpty,
      rawValue != "#"
    else {
      self = .none
      return
    }

    if rawValue.hasPrefix("shopify://collections/") {
      self = .collection(String(rawValue.dropFirst("shopify://collections/".count)))
      return
    }
    if rawValue.hasPrefix("/collections/") {
      self = .collection(String(rawValue.dropFirst("/collections/".count)))
      return
    }
    if rawValue.hasPrefix("shopify://pages/") {
      rawValue = "/pages/" + rawValue.dropFirst("shopify://pages/".count)
    }
    if rawValue.hasPrefix("/") {
      self = Self.webLink(
        ShopifyAsset.shopRoot.appendingPathComponent(String(rawValue.dropFirst()))
      )
      return
    }
    if let url = URL(string: rawValue) {
      self = Self.webLink(url)
    } else {
      self = .none
    }
  }

  private static func webLink(_ url: URL) -> ThemeLink {
    let normalizedPath =
      url.path.count > 1 && url.path.hasSuffix("/")
      ? String(url.path.dropLast())
      : url.path
    if ShopifyAsset.isPrimaryStorefrontURL(url),
      bookingPaths.contains(normalizedPath)
    {
      return .booking(url)
    }
    if ShopifyAsset.isPrimaryStorefrontURL(url) {
      return .web(url)
    }
    if url.scheme?.lowercased() == "https"
      || WebNavigationPolicy.isAllowedExternalScheme(
        url.scheme?.lowercased() ?? ""
      )
    {
      return .external(url)
    }
    return .none
  }
}

enum ThemeSnapshotError: Error {
  case missingResource
  case malformedRoot
}

private enum ThemeSnapshotLoader {
  static func loadHome(
    bundle: Bundle = .main,
    resourceName: String = "index"
  ) throws -> ThemeHomeSnapshot {
    let resourceURL =
      bundle.url(
        forResource: resourceName,
        withExtension: "json",
        subdirectory: "ThemeSnapshot"
      )
      ?? bundle.url(
        forResource: resourceName,
        withExtension: "json"
      )
    guard let resourceURL else {
      throw ThemeSnapshotError.missingResource
    }
    let data = try Data(contentsOf: resourceURL)
    guard let root = try JSONSerialization.jsonObject(with: data) as? JSONDictionary,
      let sections = root.dictionary("sections"),
      let order = root.array("order") as? [String]
    else {
      throw ThemeSnapshotError.malformedRoot
    }

    return ThemeHomeSnapshot(
      sections: order.compactMap { sectionID in
        guard let section = sections.dictionary(sectionID),
          section.bool("disabled") != true
        else {
          return nil
        }
        return parseSection(id: sectionID, section: section)
      }
    )
  }

  private static func parseSection(
    id: String,
    section: JSONDictionary
  ) -> ThemeHomeSection? {
    let type = section.string("type") ?? ""
    let settings = section.dictionary("settings") ?? [:]

    switch type {
    case "bot-greeting":
      return .greeting(
        id,
        ThemeGreeting(
          kicker: settings.string("kicker") ?? "",
          prefix: settings.string("greeting_prefix") ?? "",
          suffix: settings.string("greeting_suffix") ?? "",
          subtext: settings.string("subtext") ?? ""
        )
      )

    case "custom-collection-slider":
      let slides = orderedBlocks(section).map { blockID, block in
        let blockSettings = block.dictionary("settings") ?? [:]
        return ThemeHeroSlide(
          id: blockID,
          backgroundColor: blockSettings.string("bg-color"),
          textColor: blockSettings.string("text-color"),
          imageReference: blockSettings.string("image"),
          heading: blockSettings.string("slide-heading") ?? "",
          detail: blockSettings.string("description") ?? "",
          buttonLabel: blockSettings.string("btn-text") ?? "",
          link: ThemeLink(blockSettings.string("btn-link"))
        )
      }
      return .hero(id, slides)

    case "featured-collection":
      guard let handle = settings.string("collection"), !handle.isEmpty else {
        return nil
      }
      return .productRail(
        id,
        ThemeProductRail(
          eyebrow: settings.string("eyebrow_text") ?? "",
          heading: settings.string("heading") ?? "",
          collectionHandle: handle,
          linkLabel: settings.string("link_text") ?? "View all",
          productCount: min(
            max(settings.integer("products_count") ?? 20, 1),
            100
          )
        )
      )

    case "bot-smart-analysis":
      let chips = [
        ThemeSmartChip(
          id: "one",
          label: settings.string("chip1_label") ?? "",
          price: settings.string("chip1_price") ?? "",
          link: ThemeLink(settings.string("chip1_link"))
        ),
        ThemeSmartChip(
          id: "two",
          label: settings.string("chip2_label") ?? "",
          price: settings.string("chip2_price") ?? "",
          link: ThemeLink(settings.string("chip2_link"))
        ),
      ].filter { !$0.label.isEmpty }
      return .smartAnalysis(
        id,
        ThemeSmartAnalysis(
          eyebrow: settings.string("eyebrow") ?? "",
          heading: settings.string("heading") ?? "",
          detail: settings.string("text") ?? "",
          buttonLabel: settings.string("btn_label") ?? "",
          link: ThemeLink(settings.string("btn_link")),
          chips: chips
        )
      )

    case "multicolumn":
      let cards = orderedBlocks(section).compactMap { blockID, block -> ThemeContentCard? in
        guard block.bool("disabled") != true else { return nil }
        let blockSettings = block.dictionary("settings") ?? [:]
        return ThemeContentCard(
          id: blockID,
          imageReference: blockSettings.string("image"),
          heading: blockSettings.string("heading") ?? "",
          detailText: (blockSettings.string("content") ?? "")
            .plainTextFromHTML,
          linkLabel: blockSettings.string("link_text") ?? "",
          link: ThemeLink(blockSettings.string("link_url"))
        )
      }
      return .contentRail(
        id,
        ThemeContentRail(
          eyebrow: settings.string("eyebrow_text") ?? "",
          heading: settings.string("heading") ?? "",
          cards: cards
        )
      )

    case "bot-routine-tiles":
      let cards = orderedBlocks(section).compactMap { blockID, block -> ThemeRoutineCard? in
        guard block.bool("disabled") != true else { return nil }
        let blockSettings = block.dictionary("settings") ?? [:]
        let name = blockSettings.string("name") ?? ""
        guard !name.isEmpty else { return nil }
        return ThemeRoutineCard(
          id: blockID,
          period: blockSettings.string("period") ?? "",
          name: name,
          link: ThemeLink(blockSettings.string("link"))
        )
      }
      return .routine(
        id,
        ThemeRoutineRail(
          introEyebrow: settings.string("intro_eyebrow") ?? "",
          introHeading: settings.string("intro_heading") ?? "",
          heading: settings.string("heading") ?? "",
          period: cards.first?.period ?? "",
          cards: cards
        )
      )

    case "text-with-icon":
      return .guidance(
        id,
        ThemeGuidance(
          heading: settings.string("heading") ?? "",
          subheading: settings.string("sub-heading") ?? "",
          cards: guidanceCards(settings)
        )
      )

    case "featured-blog":
      return .blog(
        id,
        ThemeBlog(
          heading: settings.string("heading") ?? "",
          handle: settings.string("blog") ?? "",
          linkLabel: settings.string("link_text") ?? "View all",
          articleCount: max(1, settings.integer("articles_count") ?? 3),
          gridColumns: max(1, settings.integer("grid_columns") ?? 3),
          isCarousel: settings.bool("carousel") ?? true,
          showsCategory: settings.bool("show_category") ?? true,
          isFullWidth: settings.bool("full_width") ?? false,
          textAlignment: settings.string("text_alignment") ?? "text-left"
        )
      )

    case "logo-list":
      let logos = orderedBlocks(section).compactMap { blockID, block -> ThemeLogo? in
        guard block.bool("disabled") != true else { return nil }
        let blockSettings = block.dictionary("settings") ?? [:]
        return ThemeLogo(
          id: blockID,
          imageReference: blockSettings.string("image"),
          altText: blockSettings.string("alt_text") ?? "",
          link: ThemeLink(blockSettings.string("link"))
        )
      }
      return .logos(id, ThemeLogoRail(logos: logos))

    default:
      return nil
    }
  }

  private static func orderedBlocks(_ section: JSONDictionary) -> [(String, JSONDictionary)] {
    guard let blocks = section.dictionary("blocks"),
      let order = section.array("block_order") as? [String]
    else {
      return []
    }
    return order.compactMap { id in
      guard let block = blocks.dictionary(id) else { return nil }
      return (id, block)
    }
  }

  private static func guidanceCards(_ settings: JSONDictionary) -> [ThemeGuidanceCard] {
    let definitions: [(String, String, String, String)] = [
      ("one", "image-one", "image-head-one", "image-one-link"),
      ("two", "image-two", "image-two-text", "image-two-url"),
      ("three", "image-three", "image-head-three", "image-three-url"),
      ("four", "image-four", "heading-four", "image-four-url"),
      ("five", "image-five", "headind-five", "image-five-url"),
      ("six", "image-six", "heading-six", "image-six-url"),
      ("seven", "image-sevn", "heading-sevn", "heading-sevn-url"),
      ("eight", "image-eight", "heading-eight", "image-eight-url"),
    ]
    return definitions.compactMap { id, imageKey, headingKey, linkKey in
      let heading = settings.string(headingKey) ?? ""
      guard !heading.isEmpty else { return nil }
      return ThemeGuidanceCard(
        id: id,
        imageReference: settings.string(imageKey),
        heading: heading,
        link: ThemeLink(settings.string(linkKey))
      )
    }
  }
}

private typealias JSONDictionary = [String: Any]

extension Dictionary where Key == String, Value == Any {
  fileprivate func dictionary(_ key: String) -> JSONDictionary? {
    self[key] as? JSONDictionary
  }

  fileprivate func array(_ key: String) -> [Any]? {
    self[key] as? [Any]
  }

  fileprivate func string(_ key: String) -> String? {
    self[key] as? String
  }

  fileprivate func bool(_ key: String) -> Bool? {
    self[key] as? Bool
  }

  fileprivate func integer(_ key: String) -> Int? {
    if let value = self[key] as? Int {
      return value
    }
    return (self[key] as? NSNumber)?.intValue
  }
}
