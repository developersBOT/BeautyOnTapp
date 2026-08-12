import Foundation

enum ResourceLinkRailKind: String, CaseIterable, Sendable {
  case featured
  case quick

  var navigationMarker: String {
    switch self {
    case .featured:
      return "data-bot-featured-links"
    case .quick:
      return "data-bot-quick-links"
    }
  }

  var accessibilityLabel: String {
    switch self {
    case .featured:
      return "Featured links"
    case .quick:
      return "Related links"
    }
  }
}

struct ResourceLinkItem: Identifiable, Equatable, @unchecked Sendable {
  let id: String
  let label: String
  let destinationURL: URL
  let link: ThemeLink
  let imageURL: URL?
  let iconHint: String?
  let iconColorHex: UInt?
  let isCurrent: Bool
}

struct ResourceBreadcrumbItem: Identifiable, Equatable, @unchecked Sendable {
  let id: String
  let label: String
  let destinationURL: URL?
  let link: ThemeLink?
  let isCurrent: Bool
}

struct ResourceLinkRails: Equatable, Sendable {
  let featured: [ResourceLinkItem]
  let quick: [ResourceLinkItem]
  let breadcrumb: [ResourceBreadcrumbItem]

  init(
    featured: [ResourceLinkItem],
    quick: [ResourceLinkItem],
    breadcrumb: [ResourceBreadcrumbItem] = []
  ) {
    self.featured = featured
    self.quick = quick
    self.breadcrumb = breadcrumb
  }

  static let empty = ResourceLinkRails(
    featured: [],
    quick: [],
    breadcrumb: []
  )

  var isEmpty: Bool {
    featured.isEmpty && quick.isEmpty && breadcrumb.isEmpty
  }

  /// Collections linked by the theme-authored rails are the most likely next
  /// destinations. Warming a small, deduplicated set lets their pills render
  /// immediately after the shopper taps one, without guessing destinations.
  func linkedCollectionResources(
    excluding resource: ResourceLinkResource,
    limit: Int = 4
  ) -> [ResourceLinkResource] {
    guard limit > 0 else { return [] }

    var resources: [ResourceLinkResource] = []
    var seen = Set<ResourceLinkResource>()

    for item in featured + quick {
      guard case .collection(let handle) = item.link else { continue }
      let candidate = ResourceLinkResource.collection(handle: handle)
      guard candidate != resource, seen.insert(candidate).inserted else {
        continue
      }

      resources.append(candidate)
      if resources.count == limit {
        return resources
      }
    }

    return resources
  }
}

enum ResourceLinkResource: Hashable, Sendable {
  case collection(handle: String)
  case product(handle: String)

  fileprivate var pathComponents: [String] {
    switch self {
    case .collection(let handle):
      return ["collections", handle]
    case .product(let handle):
      return ["products", handle]
    }
  }
}

enum ResourceLinkRailError: Error {
  case invalidResource
  case invalidResponse
  case responseTooLarge
}

actor ResourceLinkRailClient {
  static let shared = ResourceLinkRailClient(
    sectionResolver: .shared
  )

  private struct CacheEntry {
    let value: ResourceLinkRails
    let storedAt: Date
  }

  private let sectionResolver: StorefrontSectionResolver
  private let cacheLifetime: TimeInterval
  private let cacheCapacity: Int
  private var cache: [ResourceLinkResource: CacheEntry] = [:]
  private var inFlight: [ResourceLinkResource: Task<ResourceLinkRails, Error>] = [:]

  init(
    session: URLSession? = nil,
    cacheLifetime: TimeInterval = 30 * 60,
    cacheCapacity: Int = 64,
    sectionResolver: StorefrontSectionResolver? = nil,
    initialSectionIDs: [StorefrontSectionPurpose: String] = [:],
    previewThemeID: String? = StorefrontThemeSource.activeDraftThemeID
  ) {
    if let sectionResolver {
      self.sectionResolver = sectionResolver
    } else {
      self.sectionResolver = StorefrontSectionResolver(
        session: session ?? ResourceLinkRailClient.makeSession(),
        initialSectionIDs: initialSectionIDs,
        previewThemeID: previewThemeID
      )
    }
    self.cacheLifetime = max(0, cacheLifetime)
    self.cacheCapacity = max(1, cacheCapacity)
  }

  func rails(
    for resource: ResourceLinkResource,
    forceRefresh: Bool = false
  ) async throws -> ResourceLinkRails {
    if !forceRefresh,
      let cached = cache[resource],
      Date().timeIntervalSince(cached.storedAt) <= cacheLifetime
    {
      return cached.value
    }

    if let task = inFlight[resource] {
      return try await task.value
    }

    let resolver = sectionResolver
    let task = Task {
      let pageURL = try Self.pageURL(for: resource)
      let resolved: [StorefrontSectionPurpose: StorefrontResolvedSection]
      do {
        resolved = try await resolver.sections(
          for: [.featuredLinks, .quickLinks],
          at: pageURL,
          forceRefresh: forceRefresh
        )
      } catch is CancellationError {
        throw CancellationError()
      } catch StorefrontSectionResolverError.responseTooLarge {
        throw ResourceLinkRailError.responseTooLarge
      } catch {
        throw ResourceLinkRailError.invalidResponse
      }

      let rails = ResourceLinkSectionDecoder.decode(
        featuredHTML: resolved[.featuredLinks]?.html,
        quickHTML: resolved[.quickLinks]?.html
      )
      try Task.checkCancellation()
      guard !rails.isEmpty else {
        throw ResourceLinkRailError.invalidResponse
      }
      return rails
    }
    inFlight[resource] = task

    let rails: ResourceLinkRails
    do {
      rails = try await task.value
    } catch {
      inFlight[resource] = nil
      throw error
    }
    inFlight[resource] = nil

    cache[resource] = CacheEntry(value: rails, storedAt: Date())
    trimCacheIfNeeded()
    return rails
  }

  /// Returns the last verified rails even after their freshness window.
  /// Views use this only as an immediate visual fallback while a current
  /// Shopify refresh is in flight, so a transient request failure cannot
  /// erase already valid navigation from the screen.
  func cachedRails(
    for resource: ResourceLinkResource
  ) -> ResourceLinkRails? {
    cache[resource]?.value
  }

  /// Warm the small set of theme-authored collection destinations discovered
  /// from the visible rail. Failures are intentionally ignored: prefetching
  /// must never delay or change the currently visible collection.
  func prefetch(_ resources: [ResourceLinkResource]) async {
    for resource in resources {
      if let cached = cache[resource],
        Date().timeIntervalSince(cached.storedAt) <= cacheLifetime
      {
        continue
      }

      _ = try? await rails(for: resource)
    }
  }

  static func pageURL(for resource: ResourceLinkResource) throws -> URL {
    guard resource.pathComponents.count == 2,
      Self.isValidHandle(resource.pathComponents[1])
    else {
      throw ResourceLinkRailError.invalidResource
    }

    var url = ShopifyAsset.shopRoot
    for component in resource.pathComponents {
      url.appendPathComponent(component)
    }

    guard ShopifyAsset.isPrimaryStorefrontURL(url),
      url.user == nil,
      url.password == nil,
      url.port == nil || url.port == 443
    else {
      throw ResourceLinkRailError.invalidResource
    }
    return url
  }

  fileprivate static func isValidHandle(_ handle: String) -> Bool {
    guard !handle.isEmpty, handle.count <= 255 else { return false }
    return handle.unicodeScalars.allSatisfy { scalar in
      CharacterSet.alphanumerics.contains(scalar) || scalar == "-"
    }
  }

  private static func makeSession() -> URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = URLCache(
      memoryCapacity: 4 * 1_024 * 1_024,
      diskCapacity: 24 * 1_024 * 1_024
    )
    configuration.requestCachePolicy = .useProtocolCachePolicy
    configuration.timeoutIntervalForRequest = 15
    configuration.timeoutIntervalForResource = 20
    return URLSession(configuration: configuration)
  }

  private func trimCacheIfNeeded() {
    guard cache.count > cacheCapacity else { return }
    let overflow = cache.count - cacheCapacity
    let oldest =
      cache
      .sorted { $0.value.storedAt < $1.value.storedAt }
      .prefix(overflow)
      .map(\.key)
    for key in oldest {
      cache[key] = nil
    }
  }
}

enum ResourceLinkSectionDecoder {
  static func decode(
    featuredHTML: String?,
    quickHTML: String?
  ) -> ResourceLinkRails {
    ResourceLinkRails(
      featured: ResourceLinkHTMLParser.parse(
        html: featuredHTML ?? "",
        kind: .featured
      ),
      quick: ResourceLinkHTMLParser.parse(
        html: quickHTML ?? "",
        kind: .quick
      ),
      breadcrumb: ResourceBreadcrumbHTMLParser.parse(
        html: quickHTML ?? ""
      )
    )
  }

  static func decode(
    data: Data,
    featuredSectionID: String?,
    quickSectionID: String?
  ) throws -> ResourceLinkRails {
    guard
      let response = try JSONSerialization.jsonObject(with: data)
        as? [String: Any],
      !response.isEmpty,
      response.count <= 16,
      [featuredSectionID, quickSectionID]
        .compactMap({ $0 })
        .allSatisfy(StorefrontSectionDocumentParser.isValidSectionID)
    else {
      throw ResourceLinkRailError.invalidResponse
    }

    let featuredHTML = featuredSectionID.flatMap {
      response[$0] as? String
    }
    let quickHTML = quickSectionID.flatMap {
      response[$0] as? String
    }
    guard featuredHTML != nil || quickHTML != nil else {
      throw ResourceLinkRailError.invalidResponse
    }
    return decode(
      featuredHTML: featuredHTML,
      quickHTML: quickHTML
    )
  }
}

private enum ResourceLinkParserExpressions {
  static let railAnchor = make(
    #"(?is)<a\b([^>]*)>(.*?)</a\s*>"#
  )
  static let attribute = make(
    #"(?is)([A-Za-z_:][-A-Za-z0-9_:.]*)\s*(?:=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+)))?"#
  )
  static let guidanceText = make(
    #"(?is)<(?:span|div)\b(?=[^>]*\bclass\s*=\s*["'][^"']*\bguidance-item-text\b[^"']*["'])[^>]*>(.*?)</(?:span|div)\s*>"#
  )
  static let image = make(#"(?is)<img\b([^>]*)>"#)
  static let iconHint = make(
    #"\bguidance-item__icon--([A-Za-z0-9_-]+)\b"#
  )
  static let iconColor = make(
    #"(?i)\bcolor\s*:\s*#([0-9a-f]{6})\b"#
  )
  static let navigationClose = make(#"(?is)</nav\s*>"#)
  static let svg = make(#"(?is)<svg\b[^>]*>.*?</svg\s*>"#)
  static let whitespace = make(#"\s+"#)
  static let breadcrumbItem = make(
    #"(?is)<a\b([^>]*)>(.*?)</a\s*>|<(?:span|strong)\b([^>]*)>(.*?)</(?:span|strong)\s*>"#
  )
  static let breadcrumbContextOpen = make(
    #"(?is)<(?:div|section)\b(?=[^>]*\bdata-bot-context-breadcrumb\b)[^>]*>"#
  )
  static let breadcrumbNavigationOpen = make(
    #"(?is)<nav\b(?=[^>]*\baria-label\s*=\s*["']Breadcrumbs["'])[^>]*>"#
  )

  private static let featuredNavigationOpen = makeNavigationOpen(
    marker: ResourceLinkRailKind.featured.navigationMarker
  )
  private static let quickNavigationOpen = makeNavigationOpen(
    marker: ResourceLinkRailKind.quick.navigationMarker
  )

  static func navigationOpen(
    for kind: ResourceLinkRailKind
  ) -> NSRegularExpression? {
    switch kind {
    case .featured:
      return featuredNavigationOpen
    case .quick:
      return quickNavigationOpen
    }
  }

  private static func makeNavigationOpen(
    marker: String
  ) -> NSRegularExpression? {
    let escapedMarker = NSRegularExpression.escapedPattern(for: marker)
    return make(
      #"(?is)<nav\b(?=[^>]*\b"# + escapedMarker + #"\b)[^>]*>"#
    )
  }

  private static func make(_ pattern: String) -> NSRegularExpression? {
    try? NSRegularExpression(pattern: pattern)
  }
}

enum ResourceLinkHTMLParser {
  private static let maximumHTMLBytes = 1_500_000
  private static let maximumItemsPerRail = 24
  private static let maximumLabelLength = 120

  static func parse(
    html: String,
    kind: ResourceLinkRailKind
  ) -> [ResourceLinkItem] {
    guard html.utf8.count <= maximumHTMLBytes,
      let navigationHTML = navigationHTML(
        in: html,
        kind: kind
      )
    else {
      return []
    }

    guard let anchorExpression = ResourceLinkParserExpressions.railAnchor else {
      return []
    }

    let fullRange = NSRange(
      navigationHTML.startIndex..<navigationHTML.endIndex,
      in: navigationHTML
    )
    let matches = anchorExpression.matches(
      in: navigationHTML,
      range: fullRange
    )

    return matches.prefix(maximumItemsPerRail).enumerated().compactMap {
      offset,
      match in
      guard let attributesRange = Range(match.range(at: 1), in: navigationHTML),
        let bodyRange = Range(match.range(at: 2), in: navigationHTML)
      else {
        return nil
      }

      let attributesText = String(navigationHTML[attributesRange])
      let body = String(navigationHTML[bodyRange])
      let attributes = parseAttributes(attributesText)
      guard let rawHref = attributes["href"],
        let destination = verifiedDestination(rawHref),
        let label = label(in: body),
        !label.isEmpty,
        label.count <= maximumLabelLength
      else {
        return nil
      }

      let imageURL = imageURL(in: body)
      let iconHint = iconHint(in: body)
      return ResourceLinkItem(
        id: [
          kind.rawValue,
          String(offset),
          destination.url.absoluteString,
          label,
        ].joined(separator: "|"),
        label: label,
        destinationURL: destination.url,
        link: destination.link,
        imageURL: imageURL,
        iconHint: iconHint,
        iconColorHex: iconColorHex(in: body),
        isCurrent: isCurrent(attributes: attributes)
      )
    }
  }

  static func verifiedDestination(
    _ encodedHref: String
  ) -> (url: URL, link: ThemeLink)? {
    let href = encodedHref.plainTextFromHTML
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard !href.isEmpty,
      !href.contains("\\"),
      href.unicodeScalars.allSatisfy({
        !CharacterSet.controlCharacters.contains($0)
      })
    else {
      return nil
    }

    let url: URL
    if href.hasPrefix("/") {
      guard !href.hasPrefix("//"),
        let resolved = URL(
          string: href,
          relativeTo: ShopifyAsset.shopRoot
        )?.absoluteURL
      else {
        return nil
      }
      url = resolved
    } else {
      guard let resolved = URL(string: href) else { return nil }
      url = resolved
    }

    guard ShopifyAsset.isPrimaryStorefrontURL(url),
      url.user == nil,
      url.password == nil,
      url.port == nil || url.port == 443
    else {
      return nil
    }

    return (url, themeLink(for: url))
  }

  private static func navigationHTML(
    in html: String,
    kind: ResourceLinkRailKind
  ) -> String? {
    guard
      let openingExpression =
        ResourceLinkParserExpressions.navigationOpen(for: kind)
    else {
      return nil
    }

    let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)
    guard
      let openingMatch = openingExpression.firstMatch(
        in: html,
        range: fullRange
      ),
      let openingRange = Range(openingMatch.range, in: html)
    else {
      return nil
    }

    let suffix = String(html[openingRange.upperBound...])
    guard
      let closingExpression =
        ResourceLinkParserExpressions.navigationClose
    else {
      return nil
    }
    let suffixRange = NSRange(
      suffix.startIndex..<suffix.endIndex,
      in: suffix
    )
    guard
      let closingMatch = closingExpression.firstMatch(
        in: suffix,
        range: suffixRange
      ),
      let closingRange = Range(closingMatch.range, in: suffix)
    else {
      return nil
    }

    return String(suffix[..<closingRange.lowerBound])
  }

  private static func parseAttributes(_ source: String) -> [String: String] {
    guard let expression = ResourceLinkParserExpressions.attribute else {
      return [:]
    }

    let sourceRange = NSRange(source.startIndex..<source.endIndex, in: source)
    var attributes: [String: String] = [:]
    for match in expression.matches(in: source, range: sourceRange) {
      guard let nameRange = Range(match.range(at: 1), in: source) else {
        continue
      }
      let name = source[nameRange].lowercased()
      var value = ""
      for group in 2...4 where match.range(at: group).location != NSNotFound {
        if let valueRange = Range(match.range(at: group), in: source) {
          value = String(source[valueRange]).plainTextFromHTML
        }
        break
      }
      attributes[name] = value
    }
    return attributes
  }

  private static func label(in anchorBody: String) -> String? {
    if let expression = ResourceLinkParserExpressions.guidanceText {
      let fullRange = NSRange(
        anchorBody.startIndex..<anchorBody.endIndex,
        in: anchorBody
      )
      if let match = expression.firstMatch(
        in: anchorBody,
        range: fullRange
      ),
        let contentRange = Range(match.range(at: 1), in: anchorBody)
      {
        return normalizedLabel(String(anchorBody[contentRange]))
      }
    }

    guard let svgExpression = ResourceLinkParserExpressions.svg else {
      return nil
    }
    let fullRange = NSRange(
      anchorBody.startIndex..<anchorBody.endIndex,
      in: anchorBody
    )
    let withoutSVG = svgExpression.stringByReplacingMatches(
      in: anchorBody,
      range: fullRange,
      withTemplate: ""
    )
    return normalizedLabel(withoutSVG)
  }

  private static func normalizedLabel(_ html: String) -> String? {
    guard
      let whitespaceExpression =
        ResourceLinkParserExpressions.whitespace
    else {
      return nil
    }
    let plainText = html.plainTextFromHTML
    let fullRange = NSRange(
      plainText.startIndex..<plainText.endIndex,
      in: plainText
    )
    let label =
      whitespaceExpression
      .stringByReplacingMatches(
        in: plainText,
        range: fullRange,
        withTemplate: " "
      )
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return label.isEmpty ? nil : label
  }

  private static func imageURL(in anchorBody: String) -> URL? {
    guard let expression = ResourceLinkParserExpressions.image else {
      return nil
    }
    let fullRange = NSRange(
      anchorBody.startIndex..<anchorBody.endIndex,
      in: anchorBody
    )
    guard let match = expression.firstMatch(in: anchorBody, range: fullRange),
      let attributesRange = Range(match.range(at: 1), in: anchorBody)
    else {
      return nil
    }

    let attributes = parseAttributes(String(anchorBody[attributesRange]))
    guard let source = attributes["src"] ?? attributes["data-src"],
      let url = ShopifyAsset.url(from: source, width: 48),
      url.scheme?.lowercased() == "https",
      let host = url.host?.lowercased(),
      ShopifyAsset.isPrimaryStorefrontURL(url) || host == "cdn.shopify.com"
    else {
      return nil
    }
    return url
  }

  private static func iconHint(in anchorBody: String) -> String? {
    guard let expression = ResourceLinkParserExpressions.iconHint else {
      return nil
    }
    let fullRange = NSRange(
      anchorBody.startIndex..<anchorBody.endIndex,
      in: anchorBody
    )
    guard let match = expression.firstMatch(in: anchorBody, range: fullRange),
      let hintRange = Range(match.range(at: 1), in: anchorBody)
    else {
      return nil
    }
    return String(anchorBody[hintRange]).lowercased()
  }

  private static func iconColorHex(in anchorBody: String) -> UInt? {
    guard let expression = ResourceLinkParserExpressions.iconColor else {
      return nil
    }
    let fullRange = NSRange(
      anchorBody.startIndex..<anchorBody.endIndex,
      in: anchorBody
    )
    guard let match = expression.firstMatch(in: anchorBody, range: fullRange),
      let colorRange = Range(match.range(at: 1), in: anchorBody)
    else {
      return nil
    }
    return UInt(String(anchorBody[colorRange]), radix: 16)
  }

  private static func isCurrent(attributes: [String: String]) -> Bool {
    if let current = attributes["aria-current"]?.lowercased(),
      !current.isEmpty,
      current != "false"
    {
      return true
    }
    if let current = attributes["data-current"]?.lowercased(),
      current == "true" || current == "page"
    {
      return true
    }

    let currentClassTokens: Set<String> = [
      "active",
      "current",
      "is-active",
      "is-current",
    ]
    let classTokens = Set(
      (attributes["class"] ?? "")
        .lowercased()
        .split(whereSeparator: \.isWhitespace)
        .map(String.init)
    )
    return !currentClassTokens.isDisjoint(with: classTokens)
  }

  private static func themeLink(for url: URL) -> ThemeLink {
    guard url.query == nil,
      url.fragment == nil
    else {
      return ThemeLink(url.absoluteString)
    }

    let pathComponents = url.pathComponents.filter { $0 != "/" }
    if pathComponents.count == 2,
      pathComponents[0].caseInsensitiveCompare("collections") == .orderedSame,
      ResourceLinkRailClient.isValidHandle(pathComponents[1])
    {
      return ThemeLink("/collections/\(pathComponents[1])")
    }
    return ThemeLink(url.absoluteString)
  }
}

enum ResourceBreadcrumbHTMLParser {
  private static let maximumHTMLBytes = 1_500_000
  private static let maximumItems = 12
  private static let maximumLabelLength = 120

  static func parse(html: String) -> [ResourceBreadcrumbItem] {
    guard html.utf8.count <= maximumHTMLBytes,
      let navigationHTML = breadcrumbNavigationHTML(in: html)
    else {
      return []
    }

    guard let expression = ResourceLinkParserExpressions.breadcrumbItem else {
      return []
    }
    let fullRange = NSRange(
      navigationHTML.startIndex..<navigationHTML.endIndex,
      in: navigationHTML
    )

    return expression.matches(in: navigationHTML, range: fullRange)
      .prefix(maximumItems)
      .enumerated()
      .compactMap { offset, match in
        let isAnchor = match.range(at: 1).location != NSNotFound
        let attributesGroup = isAnchor ? 1 : 3
        let bodyGroup = isAnchor ? 2 : 4
        guard
          let attributesRange = Range(
            match.range(at: attributesGroup),
            in: navigationHTML
          ),
          let bodyRange = Range(
            match.range(at: bodyGroup),
            in: navigationHTML
          )
        else {
          return nil
        }

        let attributes = parseAttributes(
          String(navigationHTML[attributesRange])
        )
        let isCurrent = currentState(attributes)
        guard isAnchor || isCurrent,
          let label = normalizedLabel(
            String(navigationHTML[bodyRange])
          ),
          !label.isEmpty,
          label.count <= maximumLabelLength
        else {
          return nil
        }

        if isAnchor {
          guard let href = attributes["href"],
            let destination =
              ResourceLinkHTMLParser.verifiedDestination(href)
          else {
            return nil
          }
          return ResourceBreadcrumbItem(
            id: "breadcrumb|\(offset)|\(destination.url.absoluteString)|\(label)",
            label: label,
            destinationURL: destination.url,
            link: destination.link,
            isCurrent: isCurrent
          )
        }

        return ResourceBreadcrumbItem(
          id: "breadcrumb|\(offset)|current|\(label)",
          label: label,
          destinationURL: nil,
          link: nil,
          isCurrent: true
        )
      }
  }

  private static func breadcrumbNavigationHTML(in html: String) -> String? {
    guard
      let contextExpression =
        ResourceLinkParserExpressions.breadcrumbContextOpen
    else {
      return nil
    }
    let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)
    guard
      let contextMatch = contextExpression.firstMatch(
        in: html,
        range: fullRange
      ),
      let contextRange = Range(contextMatch.range, in: html)
    else {
      return nil
    }

    let contextSuffix = String(html[contextRange.upperBound...])
    guard
      let navigationExpression =
        ResourceLinkParserExpressions.breadcrumbNavigationOpen
    else {
      return nil
    }
    let suffixRange = NSRange(
      contextSuffix.startIndex..<contextSuffix.endIndex,
      in: contextSuffix
    )
    guard
      let navigationMatch = navigationExpression.firstMatch(
        in: contextSuffix,
        range: suffixRange
      ),
      let navigationRange = Range(
        navigationMatch.range,
        in: contextSuffix
      )
    else {
      return nil
    }

    let navigationSuffix = String(
      contextSuffix[navigationRange.upperBound...]
    )
    guard
      let closingExpression =
        ResourceLinkParserExpressions.navigationClose
    else {
      return nil
    }
    let navigationSuffixRange = NSRange(
      navigationSuffix.startIndex..<navigationSuffix.endIndex,
      in: navigationSuffix
    )
    guard
      let closingMatch = closingExpression.firstMatch(
        in: navigationSuffix,
        range: navigationSuffixRange
      ),
      let closingRange = Range(
        closingMatch.range,
        in: navigationSuffix
      )
    else {
      return nil
    }
    return String(navigationSuffix[..<closingRange.lowerBound])
  }

  private static func parseAttributes(_ source: String) -> [String: String] {
    guard let expression = ResourceLinkParserExpressions.attribute else {
      return [:]
    }

    let sourceRange = NSRange(source.startIndex..<source.endIndex, in: source)
    var attributes: [String: String] = [:]
    for match in expression.matches(in: source, range: sourceRange) {
      guard let nameRange = Range(match.range(at: 1), in: source) else {
        continue
      }
      let name = source[nameRange].lowercased()
      var value = ""
      for group in 2...4 where match.range(at: group).location != NSNotFound {
        if let valueRange = Range(match.range(at: group), in: source) {
          value = String(source[valueRange]).plainTextFromHTML
        }
        break
      }
      attributes[name] = value
    }
    return attributes
  }

  private static func normalizedLabel(_ html: String) -> String? {
    guard
      let svgExpression = ResourceLinkParserExpressions.svg,
      let whitespaceExpression = ResourceLinkParserExpressions.whitespace
    else {
      return nil
    }
    let htmlRange = NSRange(html.startIndex..<html.endIndex, in: html)
    let withoutSVG = svgExpression.stringByReplacingMatches(
      in: html,
      range: htmlRange,
      withTemplate: ""
    )
    let plainText = withoutSVG.plainTextFromHTML
    let plainTextRange = NSRange(
      plainText.startIndex..<plainText.endIndex,
      in: plainText
    )
    let label =
      whitespaceExpression
      .stringByReplacingMatches(
        in: plainText,
        range: plainTextRange,
        withTemplate: " "
      )
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return label.isEmpty ? nil : label
  }

  private static func currentState(_ attributes: [String: String]) -> Bool {
    guard let current = attributes["aria-current"]?.lowercased() else {
      return false
    }
    return !current.isEmpty && current != "false"
  }
}
