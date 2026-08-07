import Foundation

struct BookEasyStore: Identifiable, Equatable, Sendable {
  let id: String
  let name: String
  let teamMemberID: String
  let teamMemberName: String
}

struct BookEasyDay: Identifiable, Equatable, Sendable {
  let date: String
  let timeSlots: [String]
  let slotsLeft: [Int]

  var id: String { date }
}

struct BookEasyAvailability: Equatable, Sendable {
  let stores: [BookEasyStore]
  let days: [BookEasyDay]
}

struct BookEasyBooking: Equatable, Sendable {
  let reservationID: String
  let date: String
  let time: String
  let location: BookEasyStore
  let appLoadTimestamp: Int64

  var cartAttributes: [StoreAttribute] {
    [
      StoreAttribute(key: "Date", value: date),
      StoreAttribute(key: "Time", value: time),
      StoreAttribute(key: "Location", value: location.name),
      StoreAttribute(key: "Team Member", value: location.teamMemberName),
      StoreAttribute(key: "_bookeasy-original-date", value: date),
      StoreAttribute(key: "_bookeasy-original-time", value: time),
      StoreAttribute(key: "_bookeasy-booking-id", value: reservationID),
      StoreAttribute(
        key: "_bookeasy-app-loaded-timestamp",
        value: String(appLoadTimestamp)
      ),
      StoreAttribute(
        key: "_bookeasy-maximum-quantity-per-session",
        value: "1"
      ),
      StoreAttribute(key: "_bookeasy-product-quantity", value: "1"),
    ]
  }
}

enum BookEasyError: LocalizedError, Equatable {
  case invalidProduct
  case invalidResponse
  case noBookingStores
  case slotUnavailable
  case reservationFailed

  var errorDescription: String? {
    switch self {
    case .invalidProduct:
      return "This service could not be prepared for booking."
    case .invalidResponse:
      return "Booking availability could not be loaded. Please try again."
    case .noBookingStores:
      return "No booking stores are currently available."
    case .slotUnavailable:
      return "That appointment was just taken. Choose another time."
    case .reservationFailed:
      return "The appointment could not be reserved. Please try again."
    }
  }
}

actor BookEasyClient {
  static let live = BookEasyClient()

  private enum Configuration {
    static let apiRoot = URL(string: "https://bookeasy.logbase.io")!
    static let shop = "i0ma19-q8.myshopify.com"
    static let serviceID = "5R7iXNSxp4ej9MTWneis1L"
    // Only used for the first setup request. The returned enabled locations
    // and their team assignments are always the source of the picker.
    static let bootstrapLocationID = "9oFpsF5umYdktKYLgttxLd"
    static let bootstrapTeamID = "av6cWaprU9XCHe1p8yXjXD"
    static let pageURL =
      "https://beautyontapp.com/products/skin-analysis-quiz-routine-advice"
    static let userAgent = "BeautyOnTAppPro/1.1.3"
  }

  private let session: URLSession

  init(session: URLSession? = nil) {
    if let session {
      self.session = session
    } else {
      let configuration = URLSessionConfiguration.ephemeral
      configuration.timeoutIntervalForRequest = 20
      configuration.timeoutIntervalForResource = 30
      self.session = URLSession(configuration: configuration)
    }
  }

  func availability(
    productID: String,
    variantID: String,
    productPrice: Decimal,
    month: Date,
    store: BookEasyStore? = nil
  ) async throws -> BookEasyAvailability {
    let locationID = store?.id ?? Configuration.bootstrapLocationID
    let teamID = store?.teamMemberID ?? Configuration.bootstrapTeamID
    let payload = try slotsPayload(
      productID: productID,
      variantID: variantID,
      productPrice: productPrice,
      month: month,
      locationID: locationID,
      teamMemberID: teamID
    )
    let object = try await requestJSON(
      path: "/api/bookeasy/slots",
      method: "POST",
      body: payload
    )

    guard let root = object as? [String: Any] else {
      throw BookEasyError.invalidResponse
    }
    let stores = parseStores(root)
    guard !stores.isEmpty else { throw BookEasyError.noBookingStores }
    let days = parseDays(root)
    return BookEasyAvailability(stores: stores, days: days)
  }

  func reserve(
    product: StoreProduct,
    variant: StoreVariant,
    store: BookEasyStore,
    day: BookEasyDay,
    time: String
  ) async throws -> BookEasyBooking {
    guard
      let productID = numericID(product.id),
      let variantID = numericID(variant.id),
      let price = Decimal(string: variant.price.amount)
    else {
      throw BookEasyError.invalidProduct
    }

    let reservationID = Self.makeReservationID()
    let timestamp = Int64(Date().timeIntervalSince1970 * 1_000)
    let details: [String: Any] = [
      "date": day.date,
      "time": time,
      "location": store.name,
      "locationId": store.id,
      "teamMember": store.teamMemberName,
      "teamMemberId": store.teamMemberID,
      "translatedDate": day.date,
      "translatedTime": time,
      "customInfo": [:],
      "freeServiceFields": [:],
      "paymentMethod": [:],
      "id": reservationID,
      "isFreeService": false,
      "serviceId": Configuration.serviceID,
      "serviceName": "Skin Analysis",
      "serviceBy": "withProducts",
      "timezone": "Africa/Johannesburg",
      "selectedTimezone": "Africa/Johannesburg",
      "productId": productID,
      "variantId": variantID,
      "productName": product.title,
      "variantName": variant.title,
      "productPrice": NSDecimalNumber(decimal: price),
      "appLoadTimeStamp": timestamp,
      "userAgent": Configuration.userAgent,
      "productQuantity": 1,
      "currentLocale": "en",
      "presementCurrency": ["active": "ZAR", "rate": 1],
      "country": "ZA",
    ]
    let wrapped: [String: Any] = [
      "myShopifyDomain": Configuration.shop,
      "details": details,
      "currentPageURL": Configuration.pageURL,
      "userAgent": Configuration.userAgent,
    ]

    let validation: Data
    do {
      validation = try await requestData(
        path: "/api/bookeasy/validateDateAndTime",
        method: "POST",
        body: wrapped
      )
    } catch {
      // A failed validation transport is a reserve-step problem; the old
      // invalidResponse mapping showed the unrelated "availability could not
      // be loaded" copy on the review screen.
      throw BookEasyError.reservationFailed
    }
    guard String(data: validation, encoding: .utf8)?
      .trimmingCharacters(in: .whitespacesAndNewlines) == "true"
    else {
      throw BookEasyError.slotUnavailable
    }

    // The reservation endpoint answers 2xx with a bare JSON fragment (the
    // validate endpoint returns literal `true` the same way), so success is
    // the status code, not a parseable object. Parsing it as a JSON object
    // previously threw and surfaced as "availability could not be loaded".
    do {
      _ = try await requestData(
        path: "/api/bookeasy/reservation",
        method: "POST",
        body: wrapped
      )
    } catch {
      throw BookEasyError.reservationFailed
    }
    return BookEasyBooking(
      reservationID: reservationID,
      date: day.date,
      time: time,
      location: store,
      appLoadTimestamp: timestamp
    )
  }

  func deleteReservation(id: String) async {
    guard !id.isEmpty else { return }
    var components = URLComponents(
      url: Configuration.apiRoot
        .appendingPathComponent("api/bookeasy/reservation/delete"),
      resolvingAgainstBaseURL: false
    )
    components?.queryItems = [URLQueryItem(name: "id", value: id)]
    guard let url = components?.url else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    _ = try? await session.data(for: request)
  }

  private func slotsPayload(
    productID: String,
    variantID: String,
    productPrice: Decimal,
    month: Date,
    locationID: String,
    teamMemberID: String
  ) throws -> [String: Any] {
    guard
      let productID = numericID(productID),
      let variantID = numericID(variantID)
    else { throw BookEasyError.invalidProduct }

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Africa/Johannesburg")!
    let start = calendar.date(
      from: calendar.dateComponents([.year, .month], from: month)
    ) ?? month
    let components = calendar.dateComponents([.year, .month], from: start)
    return [
      "myShopifyDomain": Configuration.shop,
      "productId": productID,
      "serviceId": Configuration.serviceID,
      "variantId": variantID,
      "productPrice": NSDecimalNumber(decimal: productPrice),
      "selectedMonth": max(0, (components.month ?? 1) - 1),
      "selectedYear": components.year ?? calendar.component(.year, from: month),
      "selectedMonthDate": Int64(start.timeIntervalSince1970 * 1_000),
      "isFromDirectLink": false,
      "isMonthWisePreparationEnabled": true,
      "productQuantity": 1,
      "currentPageURL": Configuration.pageURL,
      "userAgent": Configuration.userAgent,
      "presentmentCurrency": ["active": "ZAR", "rate": 1],
      "country": "ZA",
      "locationId": locationID,
      "teamMemberId": teamMemberID,
    ]
  }

  private func parseStores(_ root: [String: Any]) -> [BookEasyStore] {
    guard
      let setup = root["setup"] as? [String: Any],
      let details = setup["details"] as? [String: Any],
      let locations = details["locations"] as? [[String: Any]],
      let teams = details["team"] as? [[String: Any]]
    else { return [] }

    var teamByLocation: [String: (String, String)] = [:]
    for team in teams {
      guard
        let teamID = team["id"] as? String,
        let teamName = team["name"] as? String,
        let teamLocations = team["locations"] as? [[String: Any]]
      else { continue }
      for location in teamLocations {
        if let locationID = location["id"] as? String {
          teamByLocation[locationID] = (teamID, teamName)
        }
      }
    }

    return locations.compactMap { location in
      guard
        let id = location["id"] as? String,
        let name = location["name"] as? String,
        let team = teamByLocation[id]
      else { return nil }
      return BookEasyStore(
        id: id,
        name: name,
        teamMemberID: team.0,
        teamMemberName: team.1
      )
    }
  }

  private func parseDays(_ root: [String: Any]) -> [BookEasyDay] {
    guard let slots = root["slots"] as? [[String: Any]] else { return [] }
    return slots.compactMap { slot in
      guard
        let date = slot["date"] as? String,
        let times = slot["timeSlots"] as? [String]
      else { return nil }
      let left = (slot["slotsLeft"] as? [Int]) ?? Array(repeating: 1, count: times.count)
      let available = times.enumerated().filter { index, _ in
        index >= left.count || left[index] > 0
      }
      return BookEasyDay(
        date: date,
        timeSlots: available.map(\.element),
        slotsLeft: available.map { index, _ in index < left.count ? left[index] : 1 }
      )
    }
  }

  private func requestJSON(
    path: String,
    method: String,
    body: [String: Any]
  ) async throws -> Any {
    let data = try await requestData(path: path, method: method, body: body)
    do {
      // Bookeasy endpoints may answer with bare fragments (`true`, an id
      // string); accept them rather than failing an otherwise-2xx response.
      return try JSONSerialization.jsonObject(
        with: data,
        options: [.fragmentsAllowed]
      )
    } catch {
      throw BookEasyError.invalidResponse
    }
  }

  private func requestData(
    path: String,
    method: String,
    body: [String: Any]
  ) async throws -> Data {
    let url = Configuration.apiRoot.appendingPathComponent(
      path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    )
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.setValue(Configuration.userAgent, forHTTPHeaderField: "User-Agent")
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    let (data, response) = try await session.data(for: request)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
      throw BookEasyError.invalidResponse
    }
    return data
  }

  private func numericID(_ gid: String) -> String? {
    gid.split(separator: "/").last.map(String.init)
  }

  private static func makeReservationID() -> String {
    String(UUID().uuidString.replacingOccurrences(of: "-", with: "")
      .lowercased().prefix(24))
  }
}
