import AuthenticationServices
import CryptoKit
import Foundation
import Security
import UIKit

/// The native auth boundary. Shopify's hosted account UI is only used for the
/// passwordless OTP step; the app never treats that page as its destination.
@MainActor
protocol CustomerAuthenticating: AnyObject {
  var isConfigured: Bool { get }
  func authenticate() async throws -> CustomerIdentity
  func restore() async throws -> CustomerIdentity?
  func logout() async
}

struct CustomerIdentity: Codable, Equatable, Sendable {
  let id: String
  let displayName: String
  let firstName: String?
  let lastName: String?
  let email: String?

  var preferredFirstName: String {
    let candidate = firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    if !candidate.isEmpty { return candidate }
    return displayName.split(separator: " ").first.map(String.init) ?? displayName
  }
}

#if DEBUG
extension CustomerIdentity {
  /// Stable local identity used only by the UI test that validates the signed-in
  /// Profile presentation. It never ships in a release build.
  static let fixture = CustomerIdentity(
    id: "ui-test-tyler-ngwenya",
    displayName: "Tyler Ngwenya",
    firstName: "Tyler",
    lastName: "Ngwenya",
    email: "tyler@example.com"
  )
}
#endif

struct CustomerAuthConfiguration: Equatable, Sendable {
  let shopID: String
  let clientID: String
  let redirectURI: URL
  let discoveryURI: URL
  let customerAPIDiscoveryURI: URL

  var callbackScheme: String { redirectURI.scheme ?? "" }

  static func fromMainBundle() throws -> Self {
    let info = Bundle.main.infoDictionary ?? [:]
    func requiredURL(_ key: String) throws -> URL {
      guard let value = info[key] as? String, let url = URL(string: value) else {
        throw CustomerAuthError.notConfigured(key)
      }
      return url
    }
    guard let shopID = info["SHOPIFY_CUSTOMER_ACCOUNT_SHOP_ID"] as? String,
          !shopID.isEmpty,
          let clientID = info["SHOPIFY_CUSTOMER_ACCOUNT_CLIENT_ID"] as? String,
          !clientID.isEmpty
    else {
      throw CustomerAuthError.notConfigured("SHOPIFY_CUSTOMER_ACCOUNT_CLIENT_ID")
    }
    let redirectURI = try requiredURL("SHOPIFY_CUSTOMER_ACCOUNT_REDIRECT_URI")
    guard redirectURI.scheme?.hasPrefix("shop.") == true else {
      throw CustomerAuthError.invalidConfiguration("The Shopify callback must use a shop.* scheme.")
    }
    return Self(
      shopID: shopID,
      clientID: clientID,
      redirectURI: redirectURI,
      discoveryURI: try requiredURL("SHOPIFY_CUSTOMER_ACCOUNT_DISCOVERY_URL"),
      customerAPIDiscoveryURI: try requiredURL("SHOPIFY_CUSTOMER_ACCOUNT_API_DISCOVERY_URL")
    )
  }
}

enum CustomerAuthError: LocalizedError, Equatable {
  case notConfigured(String)
  case invalidConfiguration(String)
  case cancelled
  case invalidCallback
  case invalidState
  case discovery
  case token(String)
  case graphql(String)
  case noCustomer
  case keychain(OSStatus)

  var errorDescription: String? {
    switch self {
    case .notConfigured(let key):
      return "Shopify sign-in is not configured yet (missing \(key))."
    case .invalidConfiguration(let message): return message
    case .cancelled: return "Sign-in was cancelled."
    case .invalidCallback: return "Shopify returned an invalid sign-in callback."
    case .invalidState: return "Shopify sign-in could not be verified."
    case .discovery: return "Shopify sign-in is temporarily unavailable."
    case .token(let message): return "Shopify sign-in could not be completed: \(message)"
    case .graphql(let message): return "The customer account could not be loaded: \(message)"
    case .noCustomer: return "No customer account was returned by Shopify."
    case .keychain: return "The secure sign-in session could not be stored."
    }
  }
}

private struct OAuthDiscoveryDocument: Decodable {
  let authorizationEndpoint: URL
  let tokenEndpoint: URL
  let endSessionEndpoint: URL?

  enum CodingKeys: String, CodingKey {
    case authorizationEndpoint = "authorization_endpoint"
    case tokenEndpoint = "token_endpoint"
    case endSessionEndpoint = "end_session_endpoint"
  }
}

private struct CustomerAPIDiscoveryDocument: Decodable {
  let graphqlAPI: URL

  enum CodingKeys: String, CodingKey { case graphqlAPI = "graphql_api" }
}

private struct OAuthTokenResponse: Decodable {
  let accessToken: String
  let refreshToken: String?
  let idToken: String?
  let expiresIn: Int

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case idToken = "id_token"
    case expiresIn = "expires_in"
  }
}

fileprivate struct StoredCustomerTokens: Codable {
  let accessToken: String
  let refreshToken: String?
  let idToken: String?
  let expiresAt: Date
}

private struct CustomerQueryResponse: Decodable {
  let data: CustomerQueryData?
  let errors: [CustomerGraphQLError]?
}

private struct CustomerQueryData: Decodable {
  let customer: CustomerQueryCustomer?
}

private struct CustomerQueryCustomer: Decodable {
  let id: String
  let displayName: String
  let firstName: String?
  let lastName: String?
  let emailAddress: CustomerEmail?
}

private struct CustomerEmail: Decodable { let emailAddress: String }
private struct CustomerGraphQLError: Decodable { let message: String }

@MainActor
final class CustomerAuthClient: NSObject, CustomerAuthenticating,
  ASWebAuthenticationPresentationContextProviding
{
  private let urlSession: URLSession
  private let keychain: CustomerAuthKeychain
  private let configurationProvider: () throws -> CustomerAuthConfiguration
  private var webAuthenticationSession: ASWebAuthenticationSession?

  var isConfigured: Bool {
    // Unit-test bundles are hosted inside the app target, so they can see the
    // production Info.plist values. Keep the real OAuth path opt-in for the
    // shipped app while allowing AppModel's injected probe doubles to exercise
    // the legacy compatibility path in deterministic tests.
    guard NSClassFromString("XCTestCase") == nil else { return false }
    return (try? configurationProvider()) != nil
  }

  init(
    urlSession: URLSession = .shared,
    keychain: CustomerAuthKeychain = CustomerAuthKeychain(),
    configurationProvider: @escaping () throws -> CustomerAuthConfiguration = {
      try CustomerAuthConfiguration.fromMainBundle()
    }
  ) {
    self.urlSession = urlSession
    self.keychain = keychain
    self.configurationProvider = configurationProvider
    super.init()
  }

  func authenticate() async throws -> CustomerIdentity {
    let configuration = try configurationProvider()
    let discovery = try await discover(configuration)
    let customerAPI = try await discoverCustomerAPI(configuration)
    let verifier = Self.randomBase64URL(bytes: 32)
    let state = Self.randomBase64URL(bytes: 32)
    let challenge = Self.base64URL(Data(SHA256.hash(data: Data(verifier.utf8))))

    var components = URLComponents(url: discovery.authorizationEndpoint, resolvingAgainstBaseURL: false)
    components?.queryItems = [
      URLQueryItem(name: "client_id", value: configuration.clientID),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "redirect_uri", value: configuration.redirectURI.absoluteString),
      URLQueryItem(name: "scope", value: "openid email customer-account-api:full"),
      URLQueryItem(name: "state", value: state),
      URLQueryItem(name: "code_challenge", value: challenge),
      URLQueryItem(name: "code_challenge_method", value: "S256"),
    ]
    guard let authorizeURL = components?.url else {
      throw CustomerAuthError.invalidConfiguration("Shopify authorize URL could not be built.")
    }

    let callback = try await beginWebAuthentication(
      url: authorizeURL,
      callbackScheme: configuration.callbackScheme
    )
    guard callback.scheme == configuration.callbackScheme,
          callback.host == configuration.redirectURI.host,
          callback.path == configuration.redirectURI.path,
          let items = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems,
          let returnedState = items.first(where: { $0.name == "state" })?.value,
          returnedState == state,
          let code = items.first(where: { $0.name == "code" })?.value,
          !code.isEmpty
    else {
      if let error = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "error" })?.value,
         error == "access_denied"
      {
        throw CustomerAuthError.cancelled
      }
      throw CustomerAuthError.invalidCallback
    }

    let tokens = try await exchangeCode(
      code: code,
      verifier: verifier,
      configuration: configuration,
      tokenEndpoint: discovery.tokenEndpoint
    )
    try keychain.save(tokens)
    do {
      let identity = try await queryCustomer(accessToken: tokens.accessToken, endpoint: customerAPI.graphqlAPI)
      return identity
    } catch {
      keychain.clear()
      throw error
    }
  }

  func restore() async throws -> CustomerIdentity? {
    guard var tokens = keychain.load() else { return nil }
    let configuration = try configurationProvider()
    let discovery = try await discover(configuration)
    let customerAPI = try await discoverCustomerAPI(configuration)
    if tokens.expiresAt <= Date().addingTimeInterval(60) {
      guard let refreshToken = tokens.refreshToken else {
        keychain.clear()
        return nil
      }
      tokens = try await refresh(
        refreshToken: refreshToken,
        configuration: configuration,
        tokenEndpoint: discovery.tokenEndpoint,
        oldIDToken: tokens.idToken
      )
      try keychain.save(tokens)
    }
    do {
      return try await queryCustomer(accessToken: tokens.accessToken, endpoint: customerAPI.graphqlAPI)
    } catch {
      if case CustomerAuthError.graphql = error {
        return nil
      }
      throw error
    }
  }

  func logout() async {
    if let tokens = keychain.load(), let idToken = tokens.idToken,
       let configuration = try? configurationProvider(),
       let discovery = try? await discover(configuration),
       let endpoint = discovery.endSessionEndpoint
    {
      var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
      components?.queryItems = [URLQueryItem(name: "id_token_hint", value: idToken)]
      if let url = components?.url {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        _ = try? await urlSession.data(for: request)
      }
    }
    keychain.clear()
  }

  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    return scenes.flatMap(\.windows).first(where: \.isKeyWindow)
      ?? scenes.flatMap(\.windows).first
      ?? UIWindow(frame: UIScreen.main.bounds)
  }

  private func beginWebAuthentication(url: URL, callbackScheme: String) async throws -> URL {
    try await withCheckedThrowingContinuation { continuation in
      let session = ASWebAuthenticationSession(
        url: url,
        callbackURLScheme: callbackScheme
      ) { [weak self] callback, error in
        self?.webAuthenticationSession = nil
        if let error = error as? ASWebAuthenticationSessionError,
           error.code == .canceledLogin
        {
          continuation.resume(throwing: CustomerAuthError.cancelled)
        } else if let error {
          continuation.resume(throwing: error)
        } else if let callback {
          continuation.resume(returning: callback)
        } else {
          continuation.resume(throwing: CustomerAuthError.invalidCallback)
        }
      }
      session.presentationContextProvider = self
      // Keep the existing Safari/Shop SSO available, while the result still
      // returns as an OAuth token owned by this app.
      session.prefersEphemeralWebBrowserSession = false
      self.webAuthenticationSession = session
      guard session.start() else {
        self.webAuthenticationSession = nil
        continuation.resume(throwing: CustomerAuthError.discovery)
        return
      }
    }
  }

  private func discover(_ configuration: CustomerAuthConfiguration) async throws -> OAuthDiscoveryDocument {
    var request = URLRequest(url: configuration.discoveryURI)
    request.cachePolicy = .reloadIgnoringLocalCacheData
    let (data, response) = try await urlSession.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw CustomerAuthError.discovery
    }
    do { return try JSONDecoder().decode(OAuthDiscoveryDocument.self, from: data) }
    catch { throw CustomerAuthError.discovery }
  }

  private func discoverCustomerAPI(_ configuration: CustomerAuthConfiguration) async throws -> CustomerAPIDiscoveryDocument {
    let (data, response) = try await urlSession.data(from: configuration.customerAPIDiscoveryURI)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw CustomerAuthError.discovery
    }
    do { return try JSONDecoder().decode(CustomerAPIDiscoveryDocument.self, from: data) }
    catch { throw CustomerAuthError.discovery }
  }

  private func exchangeCode(
    code: String,
    verifier: String,
    configuration: CustomerAuthConfiguration,
    tokenEndpoint: URL
  ) async throws -> StoredCustomerTokens {
    var request = URLRequest(url: tokenEndpoint)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpBody = Self.formBody([
      "grant_type": "authorization_code",
      "client_id": configuration.clientID,
      "redirect_uri": configuration.redirectURI.absoluteString,
      "code": code,
      "code_verifier": verifier,
    ])
    return try await decodeTokens(request: request)
  }

  private func refresh(
    refreshToken: String,
    configuration: CustomerAuthConfiguration,
    tokenEndpoint: URL,
    oldIDToken: String?
  ) async throws -> StoredCustomerTokens {
    var request = URLRequest(url: tokenEndpoint)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpBody = Self.formBody([
      "grant_type": "refresh_token",
      "client_id": configuration.clientID,
      "refresh_token": refreshToken,
    ])
    var tokens = try await decodeTokens(request: request)
    if tokens.idToken == nil {
      tokens = StoredCustomerTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken ?? refreshToken,
        idToken: oldIDToken,
        expiresAt: tokens.expiresAt
      )
    }
    return tokens
  }

  private func decodeTokens(request: URLRequest) async throws -> StoredCustomerTokens {
    let (data, response) = try await urlSession.data(for: request)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
      let message = String(data: data, encoding: .utf8) ?? "token endpoint rejected the request"
      throw CustomerAuthError.token(message)
    }
    do {
      let response = try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
      return StoredCustomerTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        idToken: response.idToken,
        expiresAt: Date().addingTimeInterval(TimeInterval(response.expiresIn))
      )
    } catch {
      throw CustomerAuthError.token("invalid token response")
    }
  }

  private func queryCustomer(accessToken: String, endpoint: URL) async throws -> CustomerIdentity {
    let request = try Self.customerQueryRequest(
      accessToken: accessToken,
      endpoint: endpoint
    )
    let (data, response) = try await urlSession.data(for: request)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
      throw CustomerAuthError.graphql("the customer API request failed")
    }
    let decoded: CustomerQueryResponse
    do { decoded = try JSONDecoder().decode(CustomerQueryResponse.self, from: data) }
    catch { throw CustomerAuthError.graphql("invalid customer API response") }
    if let error = decoded.errors?.first, decoded.data?.customer == nil {
      throw CustomerAuthError.graphql(error.message)
    }
    guard let customer = decoded.data?.customer else { throw CustomerAuthError.noCustomer }
    return CustomerIdentity(
      id: customer.id,
      displayName: customer.displayName,
      firstName: customer.firstName,
      lastName: customer.lastName,
      email: customer.emailAddress?.emailAddress
    )
  }

  static func customerQueryRequest(
    accessToken: String,
    endpoint: URL
  ) throws -> URLRequest {
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    // The Customer Account API expects the OAuth access token itself. Unlike
    // many OAuth APIs, Shopify does not use the `Bearer` scheme here.
    request.setValue(accessToken, forHTTPHeaderField: "Authorization")
    request.httpBody = try JSONSerialization.data(withJSONObject: [
      "query": "query CustomerIdentity { customer { id displayName firstName lastName emailAddress { emailAddress } } }"
    ])
    return request
  }

  private static func randomBase64URL(bytes: Int) -> String {
    var data = Data(count: bytes)
    _ = data.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, bytes, $0.baseAddress!) }
    return base64URL(data)
  }

  private static func base64URL(_ data: Data) -> String {
    data.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .trimmingCharacters(in: CharacterSet(charactersIn: "="))
  }

  private static func formBody(_ values: [String: String]) -> Data {
    let body = values.sorted { $0.key < $1.key }
      .map { "\(percentEncode($0.key))=\(percentEncode($0.value))" }
      .joined(separator: "&")
    return Data(body.utf8)
  }

  private static func percentEncode(_ value: String) -> String {
    // OAuth token requests use application/x-www-form-urlencoded. URLQueryAllowed
    // leaves '&' and '=' unescaped, which would change the meaning of values
    // such as redirect_uri and code_verifier.
    let unreserved = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))
    return value.addingPercentEncoding(withAllowedCharacters: unreserved) ?? value
  }
}

final class CustomerAuthKeychain: @unchecked Sendable {
  private let service = "com.beautyontapp.customer-auth"
  private let account = "oauth-tokens"

  fileprivate func load() -> StoredCustomerTokens? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var item: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
          let data = item as? Data
    else { return nil }
    return try? JSONDecoder().decode(StoredCustomerTokens.self, from: data)
  }

  fileprivate func save(_ tokens: StoredCustomerTokens) throws {
    let data = try JSONEncoder().encode(tokens)
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
    let attributes: [String: Any] = [
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
    ]
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    if status == errSecItemNotFound {
      var add = query
      attributes.forEach { add[$0.key] = $0.value }
      guard SecItemAdd(add as CFDictionary, nil) == errSecSuccess else {
        throw CustomerAuthError.keychain(status)
      }
    } else if status != errSecSuccess {
      throw CustomerAuthError.keychain(status)
    }
  }

  func clear() {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
    SecItemDelete(query as CFDictionary)
  }
}
