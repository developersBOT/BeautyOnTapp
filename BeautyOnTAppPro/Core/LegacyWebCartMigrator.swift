import Foundation
@preconcurrency import WebKit

@MainActor
protocol LegacyWebCartMigrating: AnyObject {
  var isComplete: Bool { get }
  func fetchLines() async throws -> [StoreCartInputLine]
  func markComplete()
}

enum LegacyWebCartMigrationError: Error {
  case invalidResponse
}

@MainActor
final class LegacyWebCartMigrator: LegacyWebCartMigrating {
  private static let completionKey = "native-cart-migration-v1"

  private let dataStore: WKWebsiteDataStore
  private let defaults: UserDefaults
  private let session: URLSession

  init(
    dataStore: WKWebsiteDataStore = .default(),
    defaults: UserDefaults = .standard,
    session: URLSession? = nil
  ) {
    self.dataStore = dataStore
    self.defaults = defaults

    if let session {
      self.session = session
    } else {
      let configuration = URLSessionConfiguration.ephemeral
      configuration.httpCookieStorage = nil
      configuration.httpShouldSetCookies = false
      configuration.timeoutIntervalForRequest = 20
      configuration.timeoutIntervalForResource = 30
      self.session = URLSession(configuration: configuration)
    }
  }

  var isComplete: Bool {
    defaults.bool(forKey: Self.completionKey)
  }

  func fetchLines() async throws -> [StoreCartInputLine] {
    let cookies = await allCookies()
    let storefrontCookies = cookies.filter(Self.isStorefrontCookie)
    guard !storefrontCookies.isEmpty else {
      markComplete()
      return []
    }

    var request = URLRequest(
      url: ShopifyAsset.shopRoot.appendingPathComponent("cart.js")
    )
    request.httpMethod = "GET"
    request.cachePolicy = .reloadIgnoringLocalCacheData
    request.timeoutInterval = 20
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    for (field, value) in HTTPCookie.requestHeaderFields(
      with: storefrontCookies
    ) {
      request.setValue(value, forHTTPHeaderField: field)
    }

    let (data, response) = try await session.data(for: request)
    guard let response = response as? HTTPURLResponse,
      (200...299).contains(response.statusCode)
    else {
      throw LegacyWebCartMigrationError.invalidResponse
    }

    let legacyCart = try JSONDecoder().decode(
      LegacyWebCartResponse.self,
      from: data
    )
    return legacyCart.items.compactMap { item in
      guard item.variantID > 0, item.quantity > 0 else { return nil }
      return StoreCartInputLine(
        merchandiseID:
          "gid://shopify/ProductVariant/\(item.variantID)",
        quantity: item.quantity
      )
    }
  }

  func markComplete() {
    defaults.set(true, forKey: Self.completionKey)
  }

  private func allCookies() async -> [HTTPCookie] {
    await withCheckedContinuation { continuation in
      dataStore.httpCookieStore.getAllCookies { cookies in
        continuation.resume(returning: cookies)
      }
    }
  }

  private static func isStorefrontCookie(_ cookie: HTTPCookie) -> Bool {
    guard let host = ShopifyAsset.shopRoot.host?.lowercased() else {
      return false
    }
    let domain = cookie.domain
      .trimmingCharacters(in: CharacterSet(charactersIn: "."))
      .lowercased()
    return host == domain || host.hasSuffix(".\(domain)")
  }
}

private struct LegacyWebCartResponse: Decodable {
  let items: [LegacyWebCartItem]
}

private struct LegacyWebCartItem: Decodable {
  let variantID: Int64
  let quantity: Int

  private enum CodingKeys: String, CodingKey {
    case variantID = "variant_id"
    case quantity
  }
}
