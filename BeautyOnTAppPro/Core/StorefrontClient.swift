import Foundation

enum StorefrontError: LocalizedError, Equatable, Sendable {
  case invalidResponse
  case httpStatus(Int)
  case graphQL([String])
  case userErrors([String])
  case missingData(String)
  case emptySearch

  var errorDescription: String? {
    switch self {
    case .invalidResponse:
      return "BeautyOnTApp returned an unreadable response."
    case .httpStatus(let status):
      return "BeautyOnTApp returned error \(status)."
    case .graphQL(let messages), .userErrors(let messages):
      return messages.joined(separator: "\n")
    case .missingData(let name):
      return "\(name) is unavailable right now."
    case .emptySearch:
      return "Enter a product, brand or concern."
    }
  }

  var invalidatesPersistedCartID: Bool {
    switch self {
    case .missingData(let name):
      return name == "Cart"
    case .userErrors(let messages), .graphQL(let messages):
      return messages.contains { message in
        let normalized = message.lowercased()
        return normalized.contains("cart")
          && (normalized.contains("not found") || normalized.contains("does not exist")
            || normalized.contains("no longer exists") || normalized.contains("invalid cart"))
      }
    default:
      return false
    }
  }
}

enum CollectionSort: String, CaseIterable, Identifiable, Sendable {
  case featured = "COLLECTION_DEFAULT"
  case bestSelling = "BEST_SELLING"
  case price = "PRICE"
  case title = "TITLE"
  case newest = "CREATED"

  var id: String { rawValue }
}

actor StorefrontClient {
  static let shared = StorefrontClient()

  static let apiVersion = "2026-07"
  static let shopDomain = "i0ma19-q8.myshopify.com"
  // Shopify's first-party Ajax cart endpoints are more reliable on the
  // canonical myshopify host than through the branded domain: the latter can
  // return a Cloudflare browser-verification page for a native URLSession,
  // which used to surface as "no delivery options" even when rates existed.
  private static let ajaxShopRoot = URL(
    string: "https://\(shopDomain)"
  )!

  private let endpoint: URL
  private let session: URLSession
  private let ajaxSession: URLSession
  private let decoder = JSONDecoder()

  init(
    session: URLSession? = nil,
    ajaxSession: URLSession? = nil
  ) {
    endpoint = URL(
      string: "https://\(Self.shopDomain)/api/\(Self.apiVersion)/graphql.json"
    )!

    if let session {
      self.session = session
    } else {
      let configuration = URLSessionConfiguration.default
      configuration.waitsForConnectivity = true
      configuration.timeoutIntervalForRequest = 20
      configuration.timeoutIntervalForResource = 45
      configuration.urlCache = URLCache(
        memoryCapacity: 64 * 1_024 * 1_024,
        diskCapacity: 256 * 1_024 * 1_024
      )
      configuration.requestCachePolicy = .useProtocolCachePolicy
      self.session = URLSession(configuration: configuration)
    }

    if let ajaxSession {
      self.ajaxSession = ajaxSession
    } else {
      // Shipping rates are exposed by the same Ajax endpoint used by the
      // storefront theme. Keep its short-lived cart isolated from the native
      // Storefront cart and from any WebKit session cookies.
      let configuration = URLSessionConfiguration.ephemeral
      configuration.waitsForConnectivity = true
      configuration.timeoutIntervalForRequest = 20
      configuration.timeoutIntervalForResource = 45
      // An ephemeral configuration must still retain the Shopify cart cookie
      // for the add.js -> shipping_rates.json sequence. Use a private,
      // in-memory store so rates are scoped to this client and never leak into
      // a WebKit or system cookie jar.
      configuration.httpCookieStorage = HTTPCookieStorage()
      configuration.httpShouldSetCookies = true
      configuration.httpCookieAcceptPolicy = .always
      configuration.urlCache = nil
      configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
      self.ajaxSession = URLSession(configuration: configuration)
    }
  }

  func collection(
    handle: String,
    first: Int = 20,
    after: String? = nil,
    sort: CollectionSort = .featured,
    reverse: Bool = false
  ) async throws -> ProductPage {
    let payload: CollectionResponse = try await graphQL(
      query: StorefrontQuery.collection,
      variables: [
        "handle": handle,
        "first": min(max(first, 1), 100),
        "after": after as Any,
        "sortKey": sort.rawValue,
        "reverse": reverse,
      ]
    )
    guard let collection = payload.collection else {
      throw StorefrontError.missingData("Collection")
    }
    return ProductPage(
      products: collection.products.nodes.compactMap {
        $0.product?.domain(payloadKind: .summary)
      },
      pageInfo: collection.products.pageInfo
    )
  }

  func product(handle: String) async throws -> StoreProduct {
    let payload: ProductResponse = try await graphQL(
      query: StorefrontQuery.product,
      variables: ["handle": handle]
    )
    guard let product = payload.product else {
      throw StorefrontError.missingData("Product")
    }
    return product.domain(payloadKind: .detail)
  }

  func productRecommendations(
    productID: String,
    limit: Int = 8
  ) async throws -> [StoreProduct] {
    let payload: ProductRecommendationsResponse = try await graphQL(
      query: StorefrontQuery.productRecommendations,
      variables: ["productId": productID]
    )
    return payload.productRecommendations
      .prefix(min(max(limit, 1), 8))
      .map { $0.domain(payloadKind: .summary) }
  }

  func search(
    _ query: String,
    first: Int = 20,
    after: String? = nil
  ) async throws -> ProductPage {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      throw StorefrontError.emptySearch
    }
    let payload: SearchResponse = try await graphQL(
      query: StorefrontQuery.search,
      variables: [
        "query": trimmed,
        "first": min(max(first, 1), 50),
        "after": after as Any,
      ]
    )
    return ProductPage(
      products: payload.search.nodes.compactMap {
        $0.product?.domain(payloadKind: .summary)
      },
      pageInfo: payload.search.pageInfo
    )
  }

  func menu(handle: String) async throws -> StoreMenu {
    let payload: MenuResponse = try await graphQL(
      query: StorefrontQuery.menu,
      variables: ["handle": handle]
    )
    guard let menu = payload.menu else {
      throw StorefrontError.missingData("Menu")
    }
    return menu.domain
  }

  func blog(
    handle: String,
    first: Int,
    after: String? = nil
  ) async throws -> StoreBlogFeed {
    let payload: BlogResponse = try await graphQL(
      query: StorefrontQuery.blog,
      variables: [
        "handle": handle,
        "first": min(max(first, 1), 50),
        "after": after as Any,
      ]
    )
    guard let blog = payload.blog else {
      throw StorefrontError.missingData("Blog")
    }
    return blog.domain
  }

  func createCart(merchandiseID: String, quantity: Int = 1) async throws -> StoreCart {
    try await createCart(
      lines: [
        StoreCartInputLine(
          merchandiseID: merchandiseID,
          quantity: quantity
        )
      ]
    )
  }

  func createCart(lines: [StoreCartInputLine]) async throws -> StoreCart {
    guard !lines.isEmpty else {
      throw StorefrontError.missingData("Cart lines")
    }
    let payload: CartCreateResponse = try await graphQL(
      query: StorefrontQuery.cartCreate,
      variables: [
        "input": [
          "lines": lines.map {
            var line = [
              "merchandiseId": $0.merchandiseID,
              "quantity": max($0.quantity, 1),
            ] as [String: Any]
            if !$0.attributes.isEmpty {
              line["attributes"] = $0.attributes.map {
                ["key": $0.key, "value": $0.value]
              }
            }
            return line
          }
        ]
      ]
    )
    try check(payload.cartCreate.userErrors)
    guard let cart = payload.cartCreate.cart else {
      throw StorefrontError.missingData("Cart")
    }
    return try await completeCart(cart)
  }

  func cart(id: String) async throws -> StoreCart {
    let payload: CartResponse = try await graphQL(
      query: StorefrontQuery.cart,
      variables: ["id": id]
    )
    guard let cart = payload.cart else {
      throw StorefrontError.missingData("Cart")
    }
    return try await completeCart(cart)
  }

  func addCartLines(
    cartID: String,
    merchandiseID: String,
    quantity: Int = 1,
    attributes: [StoreAttribute] = []
  ) async throws -> StoreCart {
    var line: [String: Any] = [
      "merchandiseId": merchandiseID,
      "quantity": max(quantity, 1),
    ]
    if !attributes.isEmpty {
      line["attributes"] = attributes.map {
        ["key": $0.key, "value": $0.value]
      }
    }
    let payload: CartLinesResponse = try await graphQL(
      query: StorefrontQuery.cartLinesAdd,
      variables: [
        "cartId": cartID,
        "lines": [line],
      ]
    )
    try check(payload.cartLinesAdd.userErrors)
    guard let cart = payload.cartLinesAdd.cart else {
      throw StorefrontError.missingData("Cart")
    }
    return try await completeCart(cart)
  }

  func updateCartLine(
    cartID: String,
    lineID: String,
    quantity: Int
  ) async throws -> StoreCart {
    let payload: CartLinesUpdateResponse = try await graphQL(
      query: StorefrontQuery.cartLinesUpdate,
      variables: [
        "cartId": cartID,
        "lines": [
          [
            "id": lineID,
            "quantity": max(quantity, 0),
          ]
        ],
      ]
    )
    try check(payload.cartLinesUpdate.userErrors)
    guard let cart = payload.cartLinesUpdate.cart else {
      throw StorefrontError.missingData("Cart")
    }
    return try await completeCart(cart)
  }

  func removeCartLine(cartID: String, lineID: String) async throws -> StoreCart {
    let payload: CartLinesRemoveResponse = try await graphQL(
      query: StorefrontQuery.cartLinesRemove,
      variables: [
        "cartId": cartID,
        "lineIds": [lineID],
      ]
    )
    try check(payload.cartLinesRemove.userErrors)
    guard let cart = payload.cartLinesRemove.cart else {
      throw StorefrontError.missingData("Cart")
    }
    return try await completeCart(cart)
  }

  func updateCartNote(cartID: String, note: String) async throws -> StoreCart {
    let payload: CartNoteUpdateResponse = try await graphQL(
      query: StorefrontQuery.cartNoteUpdate,
      variables: [
        "cartId": cartID,
        "note": note,
      ]
    )
    try check(payload.cartNoteUpdate.userErrors)
    guard let cart = payload.cartNoteUpdate.cart else {
      throw StorefrontError.missingData("Cart")
    }
    return try await completeCart(cart)
  }

  func estimateDelivery(
    cartID: String,
    provinceCode: String,
    postalCode: String
  ) async throws -> StoreCart {
    let resolvedCart: StoreCart
    do {
      let payload: CartDeliveryAddressesReplaceResponse = try await graphQL(
        query: StorefrontQuery.cartDeliveryAddressesReplace,
        variables: [
          "cartId": cartID,
          "addresses": [
            [
              "selected": true,
              "oneTimeUse": true,
              "validationStrategy": "COUNTRY_CODE_ONLY",
              "address": [
                "deliveryAddress": [
                  "countryCode": "ZA",
                  "provinceCode": provinceCode,
                  "zip": postalCode,
                ]
              ],
            ]
          ],
        ]
      )
      try check(payload.cartDeliveryAddressesReplace.userErrors)
      guard let cart = payload.cartDeliveryAddressesReplace.cart else {
        throw StorefrontError.missingData("Delivery options")
      }
      resolvedCart = try await completeCart(cart)
    } catch {
      // Shopify's Storefront delivery groups can legitimately be empty for a
      // postcode even while the storefront's carrier endpoint has rates. A
      // postcode validation error must not prevent that first-party endpoint
      // from being queried with the current native cart lines.
      let currentCart = try await cart(id: cartID)
      let ajaxOptions = try await ajaxDeliveryOptions(
        for: currentCart,
        provinceCode: provinceCode,
        postalCode: postalCode
      )
      guard !ajaxOptions.isEmpty else { throw error }
      return currentCart.replacingDeliveryOptions(ajaxOptions)
    }

    // The live theme's first-party shipping endpoint is the source of truth
    // for carrier-calculated rates. Storefront delivery groups can be empty
    // or omit a carrier option for the same postcode, so prefer the exact
    // storefront response whenever it is available and retain GraphQL as a
    // resilient fallback for products the Ajax cart cannot mirror.
    let ajaxOptions = (try? await ajaxDeliveryOptions(
      for: resolvedCart,
      provinceCode: provinceCode,
      postalCode: postalCode
    )) ?? []
    guard !ajaxOptions.isEmpty else {
      return resolvedCart
    }
    return resolvedCart.replacingDeliveryOptions(ajaxOptions)
  }

  private func ajaxDeliveryOptions(
    for cart: StoreCart,
    provinceCode: String,
    postalCode: String
  ) async throws -> [StoreDeliveryOption] {
    let items: [[String: Any]] = cart.lines.compactMap { line in
      guard let numericID = ShopifyNumericID.variant(
        from: line.merchandise.id
      ) else {
        return nil
      }
      return [
        "id": Int(numericID) as Any,
        "quantity": max(line.quantity, 1),
      ]
    }
    guard !items.isEmpty else { return [] }

    // Carrier-rate calculation is occasionally transient while Shopify is
    // creating the short-lived Ajax cart. Retry once after clearing that
    // temporary cart so a valid postcode does not surface as a false empty
    // result. The retry is deliberately bounded; it never masks a real
    // Shopify error with an invented rate.
    var lastError: Error?
    for attempt in 0..<2 {
      do {
        return try await ajaxDeliveryOptionsOnce(
          items: items,
          provinceCode: provinceCode,
          postalCode: postalCode
        )
      } catch {
        // A single unavailable variant makes Shopify reject a batched add.js
        // request. Rebuild the temporary cart one line at a time so a stale
        // cart line cannot hide valid delivery options for the rest of the
        // customer's cart.
        if items.count > 1,
          let options = try? await ajaxDeliveryOptionsByAddingAvailableItems(
            items: items,
            provinceCode: provinceCode,
            postalCode: postalCode
          ),
          !options.isEmpty
        {
          return options
        }

        lastError = error
        await clearAjaxCart()
        if attempt == 0 {
          try? await Task.sleep(nanoseconds: 350_000_000)
        }
      }
    }
    throw lastError ?? StorefrontError.invalidResponse
  }

  private func ajaxDeliveryOptionsOnce(
    items: [[String: Any]],
    provinceCode: String,
    postalCode: String
  ) async throws -> [StoreDeliveryOption] {

    let (addURL, addResponse) = try await appendAjaxItems(items)
    do {
      let options = try await ajaxShippingRates(
        addURL: addURL,
        addResponse: addResponse,
        provinceCode: provinceCode,
        postalCode: postalCode
      )
      await clearAjaxCart()
      return options
    } catch {
      await clearAjaxCart()
      throw error
    }
  }

  private func ajaxDeliveryOptionsByAddingAvailableItems(
    items: [[String: Any]],
    provinceCode: String,
    postalCode: String
  ) async throws -> [StoreDeliveryOption] {
    await clearAjaxCart()
    var lastAddResponse: (url: URL, response: HTTPURLResponse)?

    for item in items {
      guard let result = try? await appendAjaxItems([item]) else { continue }
      lastAddResponse = result
    }

    guard let lastAddResponse else {
      throw StorefrontError.missingData("Available cart lines")
    }
    do {
      let options = try await ajaxShippingRates(
        addURL: lastAddResponse.url,
        addResponse: lastAddResponse.response,
        provinceCode: provinceCode,
        postalCode: postalCode
      )
      await clearAjaxCart()
      return options
    } catch {
      await clearAjaxCart()
      throw error
    }
  }

  private func appendAjaxItems(
    _ items: [[String: Any]]
  ) async throws -> (url: URL, response: HTTPURLResponse) {
    let addURL = Self.ajaxShopRoot.appendingPathComponent("cart/add.js")
    var addRequest = URLRequest(url: addURL)
    addRequest.httpMethod = "POST"
    addRequest.httpBody = try JSONSerialization.data(
      withJSONObject: ["items": items]
    )
    addRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    addRequest.setValue("application/json", forHTTPHeaderField: "Accept")

    let (_, response) = try await ajaxSession.data(for: addRequest)
    guard let response = response as? HTTPURLResponse else {
      throw StorefrontError.invalidResponse
    }
    guard (200...299).contains(response.statusCode) else {
      throw StorefrontError.httpStatus(response.statusCode)
    }
    return (addURL, response)
  }

  private func ajaxShippingRates(
    addURL: URL,
    addResponse: HTTPURLResponse,
    provinceCode: String,
    postalCode: String
  ) async throws -> [StoreDeliveryOption] {
    var components = URLComponents(
      url: Self.ajaxShopRoot.appendingPathComponent(
        "cart/shipping_rates.json"
      ),
      resolvingAgainstBaseURL: false
    )!
    components.queryItems = [
      URLQueryItem(
        name: "shipping_address[country]",
        value: "South Africa"
      ),
      URLQueryItem(
        name: "shipping_address[province]",
        value: SouthAfricaProvince.name(for: provinceCode)
      ),
      URLQueryItem(
        name: "shipping_address[zip]",
        value: postalCode
      ),
    ]
    var ratesRequest = URLRequest(url: components.url!)
    ratesRequest.httpMethod = "GET"
    ratesRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    // Shopify binds shipping rates to the short-lived cart cookie created
    // by add.js. Explicitly forward the cookie captured from that response
    // as well as the session's in-memory cookie jar; this also survives
    // custom-domain redirects where URLSession may not reattach a host-only
    // cart cookie on the next request.
    if let cookieHeader = ajaxCookieHeader(
      for: addURL,
      response: addResponse
    ) {
      ratesRequest.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
    }

    let (ratesData, ratesResponse) = try await ajaxSession.data(for: ratesRequest)
    guard let ratesResponse = ratesResponse as? HTTPURLResponse else {
      throw StorefrontError.invalidResponse
    }
    guard (200...299).contains(ratesResponse.statusCode) else {
      throw StorefrontError.httpStatus(ratesResponse.statusCode)
    }

    let payload = try decoder.decode(AjaxShippingRatesResponse.self, from: ratesData)
    return payload.shippingRates.enumerated().map { index, rate in
      let title = rate.presentmentName ?? rate.name
      let methodType = title.localizedCaseInsensitiveContains("local")
        || title.localizedCaseInsensitiveContains("same-day")
        ? "LOCAL"
        : "SHIPPING"
      return StoreDeliveryOption(
        deliveryGroupID: "ajax-shipping-rates",
        handle: rate.code ?? "rate-\(index)",
        title: title,
        description: rate.description,
        methodType: methodType,
        estimatedCost: Money(
          amount: rate.price,
          currencyCode: rate.currency
        )
      )
    }
  }

  private func ajaxCookieHeader(
    for url: URL,
    response: HTTPURLResponse
  ) -> String? {
    var cookiesByName: [String: HTTPCookie] = [:]
    let storedCookies =
      ajaxSession.configuration.httpCookieStorage?.cookies(for: url) ?? []
    for cookie in storedCookies {
      cookiesByName[cookie.name] = cookie
    }

    let setCookieHeader = response.allHeaderFields.first { key, _ in
      String(describing: key).caseInsensitiveCompare("Set-Cookie") == .orderedSame
    }?.value
    if let setCookieHeader {
      let headerValues: [String]
      if let values = setCookieHeader as? [String] {
        headerValues = values
      } else {
        headerValues = [String(describing: setCookieHeader)]
      }
      for value in headerValues {
        for cookie in HTTPCookie.cookies(
          withResponseHeaderFields: ["Set-Cookie": value],
          for: url
        ) {
          cookiesByName[cookie.name] = cookie
        }
      }
    }

    guard !cookiesByName.isEmpty else { return nil }
    return cookiesByName.values
      .sorted { $0.name < $1.name }
      .map { "\($0.name)=\($0.value)" }
      .joined(separator: "; ")
  }

  private func clearAjaxCart() async {
    let clearURL = Self.ajaxShopRoot.appendingPathComponent("cart/clear.js")
    var request = URLRequest(url: clearURL)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    _ = try? await ajaxSession.data(for: request)
  }

  private func completeCart(_ cart: GraphQLCart) async throws -> StoreCart {
    var lines = cart.lines.nodes
    var seenLineIDs = Set(lines.map(\.id))
    var pageInfo = cart.lines.pageInfo
    var seenCursors: Set<String> = []

    while pageInfo.hasNextPage {
      guard let cursor = pageInfo.endCursor,
        seenCursors.insert(cursor).inserted
      else {
        throw StorefrontError.invalidResponse
      }
      let payload: CartLinesPageResponse = try await graphQL(
        query: StorefrontQuery.cartLinesPage,
        variables: [
          "id": cart.id,
          "first": 100,
          "after": cursor,
        ]
      )
      guard let nextCart = payload.cart else {
        throw StorefrontError.missingData("Cart")
      }
      for line in nextCart.lines.nodes where seenLineIDs.insert(line.id).inserted {
        lines.append(line)
      }
      pageInfo = nextCart.lines.pageInfo
    }

    return cart.domain(lines: lines)
  }

  private func check(_ errors: [StorefrontUserError]) throws {
    guard !errors.isEmpty else { return }
    throw StorefrontError.userErrors(errors.map(\.message))
  }

  private func graphQL<Value: Decodable>(
    query: String,
    variables: [String: Any]
  ) async throws -> Value {
    let normalizedVariables = variables.compactMapValues { value -> Any? in
      if let optional = value as? OptionalProtocol, optional.isNil {
        return nil
      }
      return value
    }
    let body = try JSONSerialization.data(
      withJSONObject: [
        "query": query,
        "variables": normalizedVariables,
      ]
    )
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.httpBody = body
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let (data, response) = try await session.data(for: request)
    guard let response = response as? HTTPURLResponse else {
      throw StorefrontError.invalidResponse
    }
    guard (200...299).contains(response.statusCode) else {
      throw StorefrontError.httpStatus(response.statusCode)
    }

    let envelope: GraphQLEnvelope<Value>
    do {
      envelope = try decoder.decode(GraphQLEnvelope<Value>.self, from: data)
    } catch {
      throw StorefrontError.invalidResponse
    }
    if let errors = envelope.errors, !errors.isEmpty {
      throw StorefrontError.graphQL(errors.map(\.message))
    }
    guard let value = envelope.data else {
      throw StorefrontError.invalidResponse
    }
    return value
  }
}

/// Reads the live first-party Brands directory. Keeping this separate from
/// the Storefront API avoids deriving collection handles from vendor names;
/// the page itself is the source of truth for both display labels and links.
actor BrandDirectoryClient {
  static let shared = BrandDirectoryClient()

  private let session: URLSession

  init(session: URLSession? = nil) {
    if let session {
      self.session = session
    } else {
      let configuration = URLSessionConfiguration.default
      configuration.waitsForConnectivity = true
      configuration.timeoutIntervalForRequest = 20
      configuration.timeoutIntervalForResource = 30
      configuration.requestCachePolicy = .useProtocolCachePolicy
      self.session = URLSession(configuration: configuration)
    }
  }

  func fetchBrands() async throws -> [NativeBrand] {
    let url = ShopifyAsset.shopRoot.appendingPathComponent("pages/brands")
    var request = URLRequest(url: url)
    request.setValue("text/html", forHTTPHeaderField: "Accept")

    let (data, response) = try await session.data(for: request)
    guard let response = response as? HTTPURLResponse else {
      throw StorefrontError.invalidResponse
    }
    guard (200...299).contains(response.statusCode) else {
      throw StorefrontError.httpStatus(response.statusCode)
    }
    guard let html = String(data: data, encoding: .utf8) else {
      throw StorefrontError.invalidResponse
    }

    let pattern = #"<li[^>]*data-brand-item[^>]*>[\s\S]*?<a[^>]*href="([^"]+)"[^>]*>([\s\S]*?)</a>"#
    let expression = try NSRegularExpression(pattern: pattern)
    let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)
    var seen = Set<String>()
    var brands: [NativeBrand] = []

    for match in expression.matches(in: html, range: fullRange) {
      guard
        let hrefRange = Range(match.range(at: 1), in: html),
        let nameRange = Range(match.range(at: 2), in: html)
      else { continue }

      let name = Self.decodeHTML(String(html[nameRange]))
        .trimmingCharacters(in: .whitespacesAndNewlines)
      guard !name.isEmpty else { continue }

      let href = String(html[hrefRange])
      let handle = Self.collectionHandle(from: href)
      let key = "\(name.casefolded)|\(handle ?? href)"
      guard seen.insert(key).inserted else { continue }
      brands.append(NativeBrand(name: name, handle: handle))
    }

    guard !brands.isEmpty else {
      throw StorefrontError.missingData("Brands")
    }
    return brands.sorted {
      $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
    }
  }

  private static func collectionHandle(from href: String) -> String? {
    guard let url = URL(string: href) else { return nil }
    let components = url.pathComponents.filter { $0 != "/" }
    guard components.count == 2,
      components[0].caseInsensitiveCompare("collections") == .orderedSame,
      !components[1].isEmpty
    else { return nil }
    return components[1]
  }

  private static func decodeHTML(_ value: String) -> String {
    value
      .replacingOccurrences(of: "&amp;", with: "&")
      .replacingOccurrences(of: "&quot;", with: "\"")
      .replacingOccurrences(of: "&#39;", with: "'")
      .replacingOccurrences(of: "&apos;", with: "'")
      .replacingOccurrences(of: "&nbsp;", with: " ")
  }
}

private extension String {
  var casefolded: String { lowercased() }
}

private protocol OptionalProtocol {
  var isNil: Bool { get }
}

extension Optional: OptionalProtocol {
  var isNil: Bool { self == nil }
}

private struct GraphQLEnvelope<Value: Decodable>: Decodable {
  let data: Value?
  let errors: [GraphQLError]?
}

private struct GraphQLError: Decodable {
  let message: String
}

private struct StorefrontUserError: Decodable {
  let message: String
}

private struct CollectionResponse: Decodable {
  let collection: GraphQLCollection?
}

private struct ProductResponse: Decodable {
  let product: GraphQLProduct?
}

private struct ProductRecommendationsResponse: Decodable {
  let productRecommendations: [GraphQLProduct]
}

private struct SearchResponse: Decodable {
  let search: GraphQLProductConnection
}

private struct MenuResponse: Decodable {
  let menu: GraphQLMenu?
}

private struct BlogResponse: Decodable {
  let blog: GraphQLBlog?
}

private struct CartResponse: Decodable {
  let cart: GraphQLCart?
}

private struct CartLinesPageResponse: Decodable {
  let cart: GraphQLCartLinesPage?
}

private struct CartCreateResponse: Decodable {
  let cartCreate: CartMutationPayload
}

private struct CartLinesResponse: Decodable {
  let cartLinesAdd: CartMutationPayload
}

private struct CartLinesUpdateResponse: Decodable {
  let cartLinesUpdate: CartMutationPayload
}

private struct CartLinesRemoveResponse: Decodable {
  let cartLinesRemove: CartMutationPayload
}

private struct CartNoteUpdateResponse: Decodable {
  let cartNoteUpdate: CartMutationPayload
}

private struct CartDeliveryAddressesReplaceResponse: Decodable {
  let cartDeliveryAddressesReplace: CartMutationPayload
}

private struct AjaxShippingRatesResponse: Decodable {
  let shippingRates: [AjaxShippingRate]

  private enum CodingKeys: String, CodingKey {
    case shippingRates = "shipping_rates"
  }
}

private struct AjaxShippingRate: Decodable {
  let name: String
  let presentmentName: String?
  let description: String?
  let price: String
  let currency: String
  let code: String?

  private enum CodingKeys: String, CodingKey {
    case name
    case presentmentName = "presentment_name"
    case description
    case price
    case currency
    case code
  }
}

private struct CartMutationPayload: Decodable {
  let cart: GraphQLCart?
  let userErrors: [StorefrontUserError]
}

private struct GraphQLCollection: Decodable {
  let products: GraphQLProductConnection
}

private struct GraphQLProductConnection: Decodable {
  let nodes: [GraphQLProductNode]
  let pageInfo: StorefrontPageInfo
}

private enum GraphQLProductNode: Decodable {
  case product(GraphQLProduct)
  case unsupported

  enum CodingKeys: String, CodingKey {
    case typename = "__typename"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let typename = try container.decodeIfPresent(String.self, forKey: .typename)
    if typename == nil || typename == "Product" {
      self = .product(try GraphQLProduct(from: decoder))
    } else {
      self = .unsupported
    }
  }

  var product: GraphQLProduct? {
    guard case .product(let product) = self else { return nil }
    return product
  }
}

private struct GraphQLProduct: Decodable {
  let id: String
  let title: String
  let handle: String
  let onlineStoreUrl: URL?
  let description: String
  let vendor: String
  let productType: String
  let tags: [String]
  let availableForSale: Bool
  let images: GraphQLImageConnection
  let variants: GraphQLVariantConnection
  let selectedOrFirstAvailableVariant: GraphQLVariant?

  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case handle
    case onlineStoreUrl
    case description
    case vendor
    case productType
    case tags
    case availableForSale
    case images
    case variants
    case selectedOrFirstAvailableVariant
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    title = try container.decode(String.self, forKey: .title)
    handle = try container.decode(String.self, forKey: .handle)
    onlineStoreUrl = try container.decodeIfPresent(URL.self, forKey: .onlineStoreUrl)
    description =
      try container.decodeIfPresent(String.self, forKey: .description) ?? ""
    vendor = try container.decode(String.self, forKey: .vendor)
    productType =
      try container.decodeIfPresent(String.self, forKey: .productType) ?? ""
    tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    availableForSale = try container.decode(Bool.self, forKey: .availableForSale)
    images =
      try container.decodeIfPresent(
        GraphQLImageConnection.self,
        forKey: .images
      ) ?? GraphQLImageConnection(nodes: [])
    variants =
      try container.decodeIfPresent(
        GraphQLVariantConnection.self,
        forKey: .variants
      ) ?? GraphQLVariantConnection(nodes: [])
    selectedOrFirstAvailableVariant =
      try container.decodeIfPresent(
        GraphQLVariant.self,
        forKey: .selectedOrFirstAvailableVariant
      )
  }

  func domain(payloadKind: StoreProductPayloadKind) -> StoreProduct {
    StoreProduct(
      id: id,
      title: title,
      handle: handle,
      onlineStoreURL: onlineStoreUrl,
      descriptionText: description,
      vendor: vendor,
      productType: productType,
      tags: tags,
      availableForSale: availableForSale,
      reviewSummary: nil,
      variants: variants.nodes.map(\.domain),
      images: images.nodes.map(\.domain),
      selectedOrFirstAvailableVariant: selectedOrFirstAvailableVariant?.domain,
      payloadKind: payloadKind
    )
  }
}

private struct GraphQLImageConnection: Decodable {
  let nodes: [GraphQLImage]
}

private struct GraphQLImage: Decodable {
  let url: URL
  let altText: String?
  let width: Int?
  let height: Int?

  var domain: StoreImage {
    StoreImage(url: url, altText: altText, width: width, height: height)
  }
}

private struct GraphQLVariantConnection: Decodable {
  let nodes: [GraphQLVariant]
}

private struct GraphQLVariant: Decodable {
  let id: String
  let title: String
  let availableForSale: Bool
  let price: Money
  let compareAtPrice: Money?
  let selectedOptions: [SelectedOption]
  let image: GraphQLImage?

  var domain: StoreVariant {
    StoreVariant(
      id: id,
      title: title,
      availableForSale: availableForSale,
      price: price,
      compareAtPrice: compareAtPrice,
      selectedOptions: selectedOptions,
      image: image?.domain
    )
  }
}

private struct GraphQLMenu: Decodable {
  let id: String
  let handle: String
  let title: String
  let items: [GraphQLMenuItem]

  var domain: StoreMenu {
    StoreMenu(id: id, handle: handle, title: title, items: items.map(\.domain))
  }
}

private struct GraphQLMenuItem: Decodable {
  let id: String
  let title: String
  let url: URL?
  let resourceId: String?
  let items: [GraphQLMenuItem]

  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case url
    case resourceId
    case items
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    title = try container.decode(String.self, forKey: .title)
    url = try container.decodeIfPresent(URL.self, forKey: .url)
    resourceId = try container.decodeIfPresent(
      String.self,
      forKey: .resourceId
    )
    items =
      try container.decodeIfPresent(
        [GraphQLMenuItem].self,
        forKey: .items
      ) ?? []
  }

  var domain: StoreMenuItem {
    StoreMenuItem(
      id: id,
      title: title,
      url: url,
      resourceID: resourceId,
      items: items.map(\.domain)
    )
  }
}

private struct GraphQLBlog: Decodable {
  let id: String
  let title: String
  let handle: String
  let onlineStoreUrl: URL?
  let articles: GraphQLArticleConnection

  var domain: StoreBlogFeed {
    StoreBlogFeed(
      id: id,
      title: title,
      handle: handle,
      onlineStoreURL: onlineStoreUrl,
      articles: articles.nodes.map {
        $0.domain(blogHandle: handle)
      },
      pageInfo: articles.pageInfo
    )
  }
}

private struct GraphQLArticleConnection: Decodable {
  let nodes: [GraphQLArticle]
  let pageInfo: StorefrontPageInfo

  private enum CodingKeys: String, CodingKey {
    case nodes
    case pageInfo
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    nodes =
      try container.decodeIfPresent(
        [GraphQLArticle].self,
        forKey: .nodes
      ) ?? []
    pageInfo =
      try container.decodeIfPresent(
        StorefrontPageInfo.self,
        forKey: .pageInfo
      ) ?? .end
  }
}

private struct GraphQLArticle: Decodable {
  let id: String
  let title: String
  let handle: String
  let tags: [String]
  let publishedAt: String
  let onlineStoreUrl: URL?
  let image: GraphQLImage?
  let authorV2: GraphQLArticleAuthor?
  let excerpt: String?
  let content: String
  let contentHtml: String

  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case handle
    case tags
    case publishedAt
    case onlineStoreUrl
    case image
    case authorV2
    case excerpt
    case content
    case contentHtml
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    title = try container.decode(String.self, forKey: .title)
    handle = try container.decode(String.self, forKey: .handle)
    tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    publishedAt = try container.decode(String.self, forKey: .publishedAt)
    onlineStoreUrl = try container.decodeIfPresent(
      URL.self,
      forKey: .onlineStoreUrl
    )
    image = try container.decodeIfPresent(
      GraphQLImage.self,
      forKey: .image
    )
    authorV2 = try container.decodeIfPresent(
      GraphQLArticleAuthor.self,
      forKey: .authorV2
    )
    excerpt = try container.decodeIfPresent(
      String.self,
      forKey: .excerpt
    )
    content =
      try container.decodeIfPresent(String.self, forKey: .content) ?? ""
    contentHtml =
      try container.decodeIfPresent(
        String.self,
        forKey: .contentHtml
      ) ?? ""
  }

  func domain(blogHandle: String) -> StoreArticle {
    StoreArticle(
      id: id,
      title: title,
      handle: handle,
      blogHandle: blogHandle,
      tags: tags,
      publishedAt: ISO8601DateFormatter().date(from: publishedAt),
      onlineStoreURL: onlineStoreUrl,
      image: image?.domain,
      authorName: authorV2?.name,
      excerptText: excerpt ?? "",
      contentText: content,
      contentHTML: contentHtml
    )
  }
}

private struct GraphQLArticleAuthor: Decodable {
  let name: String
}

private struct GraphQLCart: Decodable {
  let id: String
  let checkoutUrl: URL
  let totalQuantity: Int
  let cost: GraphQLCartCost
  let lines: GraphQLCartLineConnection
  let note: String?
  let deliveryGroups: GraphQLCartDeliveryGroupConnection?

  func domain(lines resolvedLines: [GraphQLCartLine]? = nil) -> StoreCart {
    StoreCart(
      id: id,
      checkoutURL: checkoutUrl,
      totalQuantity: totalQuantity,
      subtotal: cost.subtotalAmount,
      total: cost.totalAmount,
      lines: (resolvedLines ?? lines.nodes).map(\.domain),
      note: note,
      deliveryOptions: deliveryGroups?.nodes.flatMap(\.domainOptions) ?? []
    )
  }
}

private struct GraphQLCartDeliveryGroupConnection: Decodable {
  let nodes: [GraphQLCartDeliveryGroup]
}

private struct GraphQLCartDeliveryGroup: Decodable {
  let id: String
  let deliveryOptions: [GraphQLCartDeliveryOption]

  var domainOptions: [StoreDeliveryOption] {
    deliveryOptions.map {
      StoreDeliveryOption(
        deliveryGroupID: id,
        handle: $0.handle,
        title: $0.title ?? "Delivery",
        description: $0.description,
        methodType: $0.deliveryMethodType,
        estimatedCost: $0.estimatedCost
      )
    }
  }
}

private struct GraphQLCartDeliveryOption: Decodable {
  let handle: String
  let title: String?
  let description: String?
  let deliveryMethodType: String
  let estimatedCost: Money
}

private struct GraphQLCartLinesPage: Decodable {
  let lines: GraphQLCartLineConnection
}

private struct GraphQLCartCost: Decodable {
  let subtotalAmount: Money
  let totalAmount: Money
}

private struct GraphQLCartLineConnection: Decodable {
  let nodes: [GraphQLCartLine]
  let pageInfo: StorefrontPageInfo

  private enum CodingKeys: String, CodingKey {
    case nodes
    case pageInfo
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    nodes = try container.decode([GraphQLCartLine].self, forKey: .nodes)
    pageInfo =
      try container.decodeIfPresent(
        StorefrontPageInfo.self,
        forKey: .pageInfo
      ) ?? .end
  }
}

private struct GraphQLCartLine: Decodable {
  let id: String
  let quantity: Int
  let merchandise: GraphQLCartMerchandise
  let cost: GraphQLCartLineCost
  let attributes: [StoreAttribute]

  private enum CodingKeys: String, CodingKey {
    case id
    case quantity
    case merchandise
    case cost
    case attributes
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    quantity = try container.decode(Int.self, forKey: .quantity)
    merchandise = try container.decode(GraphQLCartMerchandise.self, forKey: .merchandise)
    cost = try container.decode(GraphQLCartLineCost.self, forKey: .cost)
    attributes =
      try container.decodeIfPresent([StoreAttribute].self, forKey: .attributes) ?? []
  }

  var domain: StoreCartLine {
    StoreCartLine(
      id: id,
      quantity: quantity,
      merchandise: merchandise.domain,
      product: merchandise.product.domain,
      cost: cost.totalAmount,
      attributes: attributes
    )
  }
}

private struct GraphQLCartLineCost: Decodable {
  let totalAmount: Money
}

private struct GraphQLCartMerchandise: Decodable {
  let id: String
  let title: String
  let availableForSale: Bool
  let price: Money
  let compareAtPrice: Money?
  let selectedOptions: [SelectedOption]
  let image: GraphQLImage?
  let product: GraphQLProductSummary

  var domain: StoreVariant {
    StoreVariant(
      id: id,
      title: title,
      availableForSale: availableForSale,
      price: price,
      compareAtPrice: compareAtPrice,
      selectedOptions: selectedOptions,
      image: image?.domain
    )
  }
}

private struct GraphQLProductSummary: Decodable {
  let id: String
  let title: String
  let handle: String
  let vendor: String

  var domain: StoreProductSummary {
    StoreProductSummary(id: id, title: title, handle: handle, vendor: vendor)
  }
}

private enum StorefrontQuery {
  static let productVariantFields = """
    id
    title
    availableForSale
    price { amount currencyCode }
    compareAtPrice { amount currencyCode }
    selectedOptions { name value }
    image { url altText width height }
    """

  static let productCardFields = """
    id
    title
    handle
    onlineStoreUrl
    vendor
    tags
    availableForSale
    images(first: 1) {
      nodes { url altText width height }
    }
    variants(first: 2) {
      nodes { \(productVariantFields) }
    }
    selectedOrFirstAvailableVariant {
      \(productVariantFields)
    }
    """

  static let productDetailFields = """
    id
    title
    handle
    onlineStoreUrl
    description
    vendor
    productType
    tags
    availableForSale
    images(first: 12) {
      nodes { url altText width height }
    }
    variants(first: 100) {
      nodes { \(productVariantFields) }
    }
    selectedOrFirstAvailableVariant {
      \(productVariantFields)
    }
    """

  static let collection = """
    query NativeCollection(
      $handle: String!
      $first: Int!
      $after: String
      $sortKey: ProductCollectionSortKeys!
      $reverse: Boolean!
    ) {
      collection(handle: $handle) {
        products(
          first: $first
          after: $after
          sortKey: $sortKey
          reverse: $reverse
        ) {
          nodes { \(productCardFields) }
          pageInfo { hasNextPage endCursor }
        }
      }
    }
    """

  static let product = """
    query NativeProduct($handle: String!) {
      product(handle: $handle) { \(productDetailFields) }
    }
    """

  static let productRecommendations = """
    query NativeProductRecommendations($productId: ID!) {
      productRecommendations(productId: $productId, intent: RELATED) {
        \(productCardFields)
      }
    }
    """

  static let search = """
    query NativeSearch($query: String!, $first: Int!, $after: String) {
      search(query: $query, first: $first, after: $after, types: [PRODUCT]) {
        nodes {
          __typename
          ... on Product { \(productCardFields) }
        }
        pageInfo { hasNextPage endCursor }
      }
    }
    """

  static let menu = """
    query NativeMenu($handle: String!) {
      menu(handle: $handle) {
        id
        handle
        title
        items {
          id title url resourceId
          items {
            id title url resourceId
            items { id title url resourceId }
          }
        }
      }
    }
    """

  static let blog = """
    query NativeFeaturedBlog(
      $handle: String!
      $first: Int!
      $after: String
    ) {
      blog(handle: $handle) {
        id
        title
        handle
        onlineStoreUrl
        articles(
          first: $first
          after: $after
          sortKey: PUBLISHED_AT
          reverse: true
        ) {
          nodes {
            id
            title
            handle
            tags
            publishedAt
            onlineStoreUrl
            authorV2 { name }
            excerpt
            content
            contentHtml
            image { url altText width height }
          }
          pageInfo { hasNextPage endCursor }
        }
      }
    }
    """

  static let cartLineFields = """
    id
    quantity
    attributes { key value }
    cost { totalAmount { amount currencyCode } }
    merchandise {
      ... on ProductVariant {
        id
        title
        availableForSale
        price { amount currencyCode }
        compareAtPrice { amount currencyCode }
        selectedOptions { name value }
        image { url altText width height }
        product { id title handle vendor }
      }
    }
    """

  static let cartFields = """
    id
    checkoutUrl
    totalQuantity
    note
    cost {
      subtotalAmount { amount currencyCode }
      totalAmount { amount currencyCode }
    }
    lines(first: 100) {
      nodes { \(cartLineFields) }
      pageInfo { hasNextPage endCursor }
    }
    deliveryGroups(first: 10) {
      nodes {
        id
        deliveryOptions {
          handle
          title
          description
          deliveryMethodType
          estimatedCost { amount currencyCode }
        }
      }
    }
    """

  static let cartLinesPage = """
    query NativeCartLinesPage($id: ID!, $first: Int!, $after: String) {
      cart(id: $id) {
        lines(first: $first, after: $after) {
          nodes { \(cartLineFields) }
          pageInfo { hasNextPage endCursor }
        }
      }
    }
    """

  static let cartCreate = """
    mutation NativeCartCreate($input: CartInput!) {
      cartCreate(input: $input) {
        cart { \(cartFields) }
        userErrors { message }
      }
    }
    """

  static let cart = """
    query NativeCart($id: ID!) {
      cart(id: $id) { \(cartFields) }
    }
    """

  static let cartLinesAdd = """
    mutation NativeCartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
      cartLinesAdd(cartId: $cartId, lines: $lines) {
        cart { \(cartFields) }
        userErrors { message }
      }
    }
    """

  static let cartLinesUpdate = """
    mutation NativeCartLinesUpdate($cartId: ID!, $lines: [CartLineUpdateInput!]!) {
      cartLinesUpdate(cartId: $cartId, lines: $lines) {
        cart { \(cartFields) }
        userErrors { message }
      }
    }
    """

  static let cartLinesRemove = """
    mutation NativeCartLinesRemove($cartId: ID!, $lineIds: [ID!]!) {
      cartLinesRemove(cartId: $cartId, lineIds: $lineIds) {
        cart { \(cartFields) }
        userErrors { message }
      }
    }
    """

  static let cartNoteUpdate = """
    mutation NativeCartNoteUpdate($cartId: ID!, $note: String!) {
      cartNoteUpdate(cartId: $cartId, note: $note) {
        cart { \(cartFields) }
        userErrors { message }
      }
    }
    """

  static let cartDeliveryAddressesReplace = """
    mutation NativeCartDeliveryAddressesReplace(
      $cartId: ID!
      $addresses: [CartSelectableAddressInput!]!
    ) {
      cartDeliveryAddressesReplace(
        cartId: $cartId
        addresses: $addresses
      ) {
        cart { \(cartFields) }
        userErrors { message }
      }
    }
    """
}
