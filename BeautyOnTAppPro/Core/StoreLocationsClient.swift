import Foundation

enum StoreLocationsError: LocalizedError, Equatable, Sendable {
  case invalidResponse
  case httpStatus(Int)
  case pageTooLarge
  case noLocations

  var errorDescription: String? {
    switch self {
    case .invalidResponse:
      return "BeautyOnTApp returned an unreadable store list."
    case .httpStatus(let status):
      return "BeautyOnTApp returned error \(status)."
    case .pageTooLarge:
      return "The store list was too large to load safely."
    case .noLocations:
      return "Store locations are unavailable right now."
    }
  }
}

protocol StoreLocationsFetching: Sendable {
  func fetchLocations() async throws -> [StoreLocation]
}

actor StoreLocationsClient: StoreLocationsFetching {
  static let shared = StoreLocationsClient()
  static let liveURL = URL(
    string: "https://beautyontapp.com/pages/locations"
  )!

  private static let maximumResponseBytes = 5 * 1_024 * 1_024

  private let session: URLSession
  private let endpoint: URL

  init(
    session: URLSession? = nil,
    endpoint: URL = StoreLocationsClient.liveURL
  ) {
    self.endpoint = endpoint
    if let session {
      self.session = session
    } else {
      let configuration = URLSessionConfiguration.default
      configuration.waitsForConnectivity = true
      configuration.timeoutIntervalForRequest = 20
      configuration.timeoutIntervalForResource = 30
      configuration.requestCachePolicy = .reloadRevalidatingCacheData
      self.session = URLSession(configuration: configuration)
    }
  }

  func fetchLocations() async throws -> [StoreLocation] {
    var request = URLRequest(url: endpoint)
    request.timeoutInterval = 30
    request.cachePolicy = .reloadRevalidatingCacheData
    request.setValue(
      "text/html,application/xhtml+xml",
      forHTTPHeaderField: "Accept"
    )

    let (data, response) = try await session.data(for: request)
    guard let response = response as? HTTPURLResponse,
      let responseURL = response.url,
      ShopifyAsset.isPrimaryStorefrontURL(responseURL),
      responseURL.path == Self.liveURL.path
    else {
      throw StoreLocationsError.invalidResponse
    }
    guard (200...299).contains(response.statusCode) else {
      throw StoreLocationsError.httpStatus(response.statusCode)
    }
    guard data.count <= Self.maximumResponseBytes else {
      throw StoreLocationsError.pageTooLarge
    }

    return try StoreLocationsParser.parse(data: data)
  }
}

enum StoreLocationsParser {
  private static let scriptPattern =
    #"(?is)<script\b([^>]*)>(.*?)</script\s*>"#
  private static let locatorDataIDPattern =
    #"(?i)\bid\s*=\s*(?:\"storeLocationsData-[^\"]+\"|'storeLocationsData-[^']+')"#
  private static let jsonLDTypePattern =
    #"(?i)\btype\s*=\s*(?:"application/ld\+json"|'application/ld\+json'|application/ld\+json(?:\s|$))"#

  static func parse(data: Data) throws -> [StoreLocation] {
    guard let html = String(data: data, encoding: .utf8) else {
      throw StoreLocationsError.invalidResponse
    }
    return try parse(html: html)
  }

  static func parse(html: String) throws -> [StoreLocation] {
    // The store-locator section carries the customer-facing addresses and
    // phone numbers. It is updated separately from the older JSON-LD block,
    // so it must take priority whenever it is available.
    let locatorLocations = try storeLocatorLocations(in: html)
    if !locatorLocations.isEmpty {
      return locatorLocations
    }

    let scripts = try jsonLDScripts(in: html)
    var locations: [StoreLocation] = []

    for script in scripts {
      let normalized = normalizedJSON(script)
      guard let data = normalized.data(using: .utf8),
        let root = try? JSONSerialization.jsonObject(with: data)
      else {
        continue
      }
      collectLocations(from: root, into: &locations)
    }

    var seenIDs = Set<String>()
    let unique = locations.filter { seenIDs.insert($0.id).inserted }
    guard !unique.isEmpty else {
      throw StoreLocationsError.noLocations
    }
    return unique
  }

  private static func storeLocatorLocations(
    in html: String
  ) throws -> [StoreLocation] {
    let scriptRegex = try NSRegularExpression(pattern: scriptPattern)
    let locatorIDRegex = try NSRegularExpression(pattern: locatorDataIDPattern)
    let fullRange = NSRange(html.startIndex..., in: html)
    var locations: [StoreLocation] = []

    for match in scriptRegex.matches(in: html, range: fullRange) {
      guard match.numberOfRanges >= 3,
        let attributesRange = Range(match.range(at: 1), in: html),
        let bodyRange = Range(match.range(at: 2), in: html)
      else {
        continue
      }

      let attributes = String(html[attributesRange])
      let attributeSearchRange = NSRange(attributes.startIndex..., in: attributes)
      guard locatorIDRegex.firstMatch(in: attributes, range: attributeSearchRange) != nil,
        let data = normalizedJSON(String(html[bodyRange])).data(using: .utf8),
        let entries = try? JSONDecoder().decode([StoreLocatorEntry].self, from: data)
      else {
        continue
      }

      locations.append(contentsOf: entries.compactMap(StoreLocation.init))
    }

    var seenIDs = Set<String>()
    return locations.filter { seenIDs.insert($0.id).inserted }
  }

  private static func jsonLDScripts(in html: String) throws -> [String] {
    let scriptRegex = try NSRegularExpression(
      pattern: scriptPattern
    )
    let typeRegex = try NSRegularExpression(
      pattern: jsonLDTypePattern
    )
    let fullRange = NSRange(html.startIndex..., in: html)

    return scriptRegex.matches(in: html, range: fullRange).compactMap {
      match in
      guard match.numberOfRanges >= 3,
        let attributesRange = Range(match.range(at: 1), in: html),
        let bodyRange = Range(match.range(at: 2), in: html)
      else {
        return nil
      }
      let attributes = String(html[attributesRange])
      let attributesNSRange = NSRange(
        attributes.startIndex...,
        in: attributes
      )
      guard
        typeRegex.firstMatch(
          in: attributes,
          range: attributesNSRange
        ) != nil
      else {
        return nil
      }
      return String(html[bodyRange])
    }
  }

  private static func normalizedJSON(_ rawValue: String) -> String {
    var value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    if value.hasPrefix("<!--") {
      value.removeFirst(4)
    }
    if value.hasSuffix("-->") {
      value.removeLast(3)
    }
    return value.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private static func collectLocations(
    from value: Any,
    into locations: inout [StoreLocation]
  ) {
    if let values = value as? [Any] {
      for nestedValue in values {
        collectLocations(from: nestedValue, into: &locations)
      }
      return
    }

    guard let object = value as? [String: Any] else {
      return
    }
    if isHealthAndBeautyBusiness(object),
      let location = location(from: object)
    {
      locations.append(location)
    }

    if let graph = object["@graph"] {
      collectLocations(from: graph, into: &locations)
    }
  }

  private static func isHealthAndBeautyBusiness(
    _ object: [String: Any]
  ) -> Bool {
    if let type = object["@type"] as? String {
      return type == "HealthAndBeautyBusiness"
    }
    if let types = object["@type"] as? [String] {
      return types.contains("HealthAndBeautyBusiness")
    }
    return false
  }

  private static func location(
    from object: [String: Any]
  ) -> StoreLocation? {
    guard let name = nonEmptyString(object["name"]) else {
      return nil
    }

    let addressObject = object["address"] as? [String: Any] ?? [:]
    let address = StorePostalAddress(
      streetAddress: nonEmptyString(addressObject["streetAddress"]),
      locality: nonEmptyString(addressObject["addressLocality"]),
      region: nonEmptyString(addressObject["addressRegion"]),
      postalCode: nonEmptyString(addressObject["postalCode"]),
      country: nonEmptyString(addressObject["addressCountry"])
    )

    let sourceID = nonEmptyString(object["@id"])
    let stableID = sourceID ?? "store|\(name)|\(address.singleLine)"
    let pageURL = nonEmptyString(object["url"]).flatMap(URL.init(string:))

    return StoreLocation(
      id: stableID,
      name: name,
      pageURL: pageURL,
      telephone: nonEmptyString(object["telephone"]),
      email: nonEmptyString(object["email"]),
      address: address,
      coordinate: coordinate(from: object["geo"]),
      openingHours: openingHours(from: object["openingHoursSpecification"])
    )
  }

  private static func coordinate(from value: Any?) -> StoreCoordinate? {
    guard let object = value as? [String: Any],
      let latitude = doubleValue(object["latitude"]),
      let longitude = doubleValue(object["longitude"])
    else {
      return nil
    }
    return StoreCoordinate(latitude: latitude, longitude: longitude)
  }

  private static func openingHours(
    from value: Any?
  ) -> [StoreOpeningHours] {
    let values: [Any]
    if let list = value as? [Any] {
      values = list
    } else if let value {
      values = [value]
    } else {
      return []
    }

    return values.compactMap { value in
      guard let object = value as? [String: Any],
        let opens = nonEmptyString(object["opens"]),
        let closes = nonEmptyString(object["closes"])
      else {
        return nil
      }

      let days = dayValues(object["dayOfWeek"])
      guard !days.isEmpty else { return nil }
      return StoreOpeningHours(days: days, opens: opens, closes: closes)
    }
  }

  private static func dayValues(_ value: Any?) -> [String] {
    let rawDays: [String]
    if let days = value as? [String] {
      rawDays = days
    } else if let day = value as? String {
      rawDays = [day]
    } else {
      return []
    }

    return rawDays.compactMap { rawDay in
      let fragment =
        rawDay
        .split(whereSeparator: { $0 == "/" || $0 == "#" })
        .last
        .map(String.init) ?? rawDay
      return nonEmptyString(fragment)
    }
  }

  private static func doubleValue(_ value: Any?) -> Double? {
    if let number = value as? NSNumber {
      return number.doubleValue
    }
    if let string = value as? String {
      return Double(string)
    }
    return nil
  }

  private static func nonEmptyString(_ value: Any?) -> String? {
    guard let string = value as? String else { return nil }
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}

private struct StoreLocatorEntry: Decodable {
  let id: Int
  let name: String
  let addressLine1: String?
  let addressLine2: String?
  let city: String?
  let postalCode: String?
  let state: String?
  let country: String?
  let phoneNumber: String?
  let email: String?
  let latitude: Double?
  let longitude: Double?
  let visible: Bool?

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case addressLine1 = "address_line1"
    case addressLine2 = "address_line2"
    case city
    case postalCode = "postal_code"
    case state
    case country
    case phoneNumber = "phone_number"
    case email
    case latitude
    case longitude
    case visible
  }
}

private extension StoreLocation {
  init?(_ entry: StoreLocatorEntry) {
    guard entry.visible != false,
      let name = entry.name.trimmedNonEmpty
    else {
      return nil
    }

    let streetAddress = [entry.addressLine1, entry.addressLine2]
      .compactMap(\.trimmedNonEmpty)
      .joined(separator: ", ")
      .trimmedNonEmpty
    let coordinate: StoreCoordinate?
    if let latitude = entry.latitude, let longitude = entry.longitude {
      coordinate = StoreCoordinate(latitude: latitude, longitude: longitude)
    } else {
      coordinate = nil
    }

    self.init(
      id: "store-locator-\(entry.id)",
      name: name.hasPrefix("BeautyOnTApp") ? name : "BeautyOnTApp \(name)",
      pageURL: StoreLocationsClient.liveURL,
      telephone: entry.phoneNumber.trimmedNonEmpty,
      email: entry.email.trimmedNonEmpty,
      address: StorePostalAddress(
        streetAddress: streetAddress,
        locality: entry.city.trimmedNonEmpty,
        region: entry.state.trimmedNonEmpty,
        postalCode: entry.postalCode.trimmedNonEmpty,
        country: entry.country.trimmedNonEmpty
      ),
      coordinate: coordinate,
      openingHours: []
    )
  }
}

private extension String {
  var trimmedNonEmpty: String? {
    let value = trimmingCharacters(in: .whitespacesAndNewlines)
    guard !value.isEmpty else { return nil }
    return value
  }
}

private extension Optional where Wrapped == String {
  var trimmedNonEmpty: String? {
    flatMap { $0.trimmedNonEmpty }
  }
}
