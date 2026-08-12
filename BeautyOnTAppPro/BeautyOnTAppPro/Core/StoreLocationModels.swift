import Foundation

struct StoreLocation: Identifiable, Equatable, Sendable {
  let id: String
  let name: String
  let pageURL: URL?
  let telephone: String?
  let email: String?
  let address: StorePostalAddress
  let coordinate: StoreCoordinate?
  let openingHours: [StoreOpeningHours]

  var mapsURL: URL? {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "maps.apple.com"

    let destination: String
    if let coordinate {
      destination = "\(coordinate.latitude),\(coordinate.longitude)"
    } else {
      destination = address.singleLine
    }
    guard !destination.isEmpty else { return nil }

    components.queryItems = [
      URLQueryItem(name: "q", value: name),
      URLQueryItem(name: "daddr", value: destination),
      URLQueryItem(name: "dirflg", value: "d"),
    ]
    return components.url
  }

  var telephoneURL: URL? {
    guard let telephone else { return nil }
    let scalars = telephone.unicodeScalars
    var normalized = ""
    for scalar in scalars {
      if CharacterSet.decimalDigits.contains(scalar) {
        normalized.unicodeScalars.append(scalar)
      } else if scalar == "+", normalized.isEmpty {
        normalized.append("+")
      }
    }
    let digitCount = normalized.unicodeScalars.filter {
      CharacterSet.decimalDigits.contains($0)
    }.count
    guard digitCount >= 7 else { return nil }
    return URL(string: "tel:\(normalized)")
  }

  var emailURL: URL? {
    guard let email,
      !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      return nil
    }
    var components = URLComponents()
    components.scheme = "mailto"
    components.path = email
    return components.url
  }
}

struct StorePostalAddress: Equatable, Sendable {
  let streetAddress: String?
  let locality: String?
  let region: String?
  let postalCode: String?
  let country: String?

  var lines: [String] {
    let cityLine = [locality, region, postalCode]
      .compactMap(Self.nonEmpty)
      .joined(separator: ", ")
    return [
      Self.nonEmpty(streetAddress),
      cityLine.isEmpty ? nil : cityLine,
      Self.nonEmpty(country),
    ].compactMap { $0 }
  }

  var singleLine: String {
    lines.joined(separator: ", ")
  }

  private static func nonEmpty(_ value: String?) -> String? {
    guard let value else { return nil }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}

struct StoreCoordinate: Equatable, Sendable {
  let latitude: Double
  let longitude: Double

  init?(latitude: Double, longitude: Double) {
    guard (-90...90).contains(latitude),
      (-180...180).contains(longitude)
    else {
      return nil
    }
    self.latitude = latitude
    self.longitude = longitude
  }
}

struct StoreOpeningHours: Identifiable, Equatable, Sendable {
  let days: [String]
  let opens: String
  let closes: String

  var id: String {
    "\(days.joined(separator: "|"))|\(opens)|\(closes)"
  }

  var daySummary: String {
    let normalized = Set(days.map { $0.lowercased() })
    let everyDay = Set([
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday",
    ])
    if normalized == everyDay {
      return "Daily"
    }
    return days.joined(separator: ", ")
  }
}
