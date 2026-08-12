import Combine
import CoreGraphics
import CryptoKit
import Foundation

/// How a remote home snapshot reached the app. Persisted with the payload so
/// a failing transport shows up in diagnostics instead of failing silently.
enum ThemeSyncTransport: String, Sendable {
  case metaobject
  case filesCDN
}

/// A raw `templates/index.json` document fetched from the live storefront,
/// exactly as the theme editor saved it. The app renders the same JSON the
/// website renders — this payload is the "one thing" contract between the
/// Shopify theme and the native Home.
struct ThemeSyncPayload: Equatable, Sendable {
  let rawJSON: Data
  let hash: String
  let transport: ThemeSyncTransport
  let fetchedAt: Date

  init(rawJSON: Data, transport: ThemeSyncTransport, fetchedAt: Date = Date()) {
    self.rawJSON = rawJSON
    self.hash = ThemeSyncPayload.hash(of: rawJSON)
    self.transport = transport
    self.fetchedAt = fetchedAt
  }

  static func hash(of data: Data) -> String {
    SHA256.hash(data: data)
      .map { String(format: "%02x", $0) }
      .joined()
  }
}

/// Fetches the published theme's home template settings at runtime and keeps
/// a last-known-good copy on disk, so weekly storefront image changes reach
/// the app without an App Store release.
///
/// Transport order:
/// 1. Storefront API metaobject `bot_native_theme` / `home` — structured,
///    never CDN-stale, written by the theme-sync automation whenever the
///    published theme changes.
/// 2. Shopify Files CDN `bot-native-home.json` — tokenless fallback for the
///    same document.
///
/// Every remote document must pass `ThemeHomeSnapshot` validation before it
/// can replace what is on screen; a malformed or empty sync can never blank
/// Home. With no reachable transport the app keeps the newest of: last
/// synced disk copy, bundled snapshot — which is exactly today's behaviour.
actor ThemeSyncService {
  typealias NetworkLoader =
    @Sendable (URLRequest) async throws -> (Data, URLResponse)

  static let shared = ThemeSyncService()

  /// Foreground refreshes are throttled so returning to the app repeatedly
  /// does not hammer the storefront; content changes weekly, not hourly.
  static let minimumRefreshInterval: TimeInterval = 15 * 60

  private static let maximumResponseBytes = 3 * 1_024 * 1_024

  private static let metaobjectQuery = """
    query BotNativeHome {
      metaobject(handle: {type: "bot_native_theme", handle: "home"}) {
        updatedAt
        indexJSON: field(key: "index_json") { value }
      }
    }
    """

  private let networkLoader: NetworkLoader
  private let directory: URL
  private var lastAttemptAt: Date?

  init(
    networkLoader: NetworkLoader? = nil,
    directory: URL? = nil
  ) {
    if let networkLoader {
      self.networkLoader = networkLoader
    } else {
      let configuration = URLSessionConfiguration.ephemeral
      configuration.waitsForConnectivity = false
      configuration.timeoutIntervalForRequest = 15
      configuration.timeoutIntervalForResource = 30
      // Freshness is the whole point of this service; both transports carry
      // their own change detection, so HTTP-level caching only hides updates.
      configuration.urlCache = nil
      configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
      let session = URLSession(configuration: configuration)
      self.networkLoader = { request in
        try await session.data(for: request)
      }
    }

    if let directory {
      self.directory = directory
    } else {
      let base =
        FileManager.default.urls(
          for: .applicationSupportDirectory,
          in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
      self.directory = base.appendingPathComponent(
        "ThemeSync",
        isDirectory: true
      )
    }
  }

  // MARK: Disk

  private var payloadURL: URL {
    directory.appendingPathComponent("home.json")
  }

  private var metadataURL: URL {
    directory.appendingPathComponent("home.meta.json")
  }

  private struct StoredMetadata: Codable {
    let hash: String
    let transport: String
    let fetchedAt: Date
  }

  /// The newest validated payload that previously synced, or nil when the
  /// app has never synced (first launch, or after a device restore).
  func storedPayload() -> ThemeSyncPayload? {
    guard
      let data = try? Data(contentsOf: payloadURL),
      let metadataData = try? Data(contentsOf: metadataURL),
      let metadata = try? JSONDecoder().decode(
        StoredMetadata.self,
        from: metadataData
      ),
      metadata.hash == ThemeSyncPayload.hash(of: data),
      let transport = ThemeSyncTransport(rawValue: metadata.transport)
    else {
      return nil
    }
    return ThemeSyncPayload(
      rawJSON: data,
      transport: transport,
      fetchedAt: metadata.fetchedAt
    )
  }

  private func store(_ payload: ThemeSyncPayload) {
    do {
      try FileManager.default.createDirectory(
        at: directory,
        withIntermediateDirectories: true
      )
      let metadata = StoredMetadata(
        hash: payload.hash,
        transport: payload.transport.rawValue,
        fetchedAt: payload.fetchedAt
      )
      try payload.rawJSON.write(to: payloadURL, options: .atomic)
      try JSONEncoder().encode(metadata).write(
        to: metadataURL,
        options: .atomic
      )
    } catch {
      // Persistence is an optimisation; the in-memory snapshot stays valid.
    }
  }

  // MARK: Remote

  /// Fetches the current storefront home document, newest transport first.
  /// Returns nil when throttled, offline, or when no transport produced a
  /// document that passes snapshot validation.
  func refresh(force: Bool = false) async -> ThemeSyncPayload? {
    let now = Date()
    if !force,
      let lastAttemptAt,
      now.timeIntervalSince(lastAttemptAt) < Self.minimumRefreshInterval
    {
      return nil
    }
    lastAttemptAt = now

    if let payload = await fetchFromMetaobject() {
      store(payload)
      return payload
    }
    if let payload = await fetchFromFilesCDN() {
      store(payload)
      return payload
    }
    return nil
  }

  private func fetchFromMetaobject() async -> ThemeSyncPayload? {
    let endpoint = URL(
      string:
        "https://\(StorefrontClient.shopDomain)/api/\(StorefrontClient.apiVersion)/graphql.json"
    )!
    guard
      let body = try? JSONSerialization.data(
        withJSONObject: ["query": Self.metaobjectQuery]
      )
    else {
      return nil
    }

    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.httpBody = body
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    guard
      let data = await loadValidatedData(for: request),
      let root = try? JSONSerialization.jsonObject(with: data)
        as? [String: Any],
      let payload = (root["data"] as? [String: Any])?["metaobject"]
        as? [String: Any],
      let field = payload["indexJSON"] as? [String: Any],
      let value = field["value"] as? String,
      let json = value.data(using: .utf8)
    else {
      return nil
    }
    return validatedPayload(json, transport: .metaobject)
  }

  private func fetchFromFilesCDN() async -> ThemeSyncPayload? {
    // The hour bucket keeps Shopify's CDN cache effective within the hour
    // while guaranteeing a weekly image change can never be pinned behind a
    // stale immutable cache entry.
    let hourBucket = Int(Date().timeIntervalSince1970 / 3_600)
    guard
      let url = URL(
        string:
          "https://beautyontapp.com/cdn/shop/files/bot-native-home.json?cb=\(hourBucket)"
      )
    else {
      return nil
    }
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    guard let data = await loadValidatedData(for: request) else {
      return nil
    }
    return validatedPayload(data, transport: .filesCDN)
  }

  private func loadValidatedData(for request: URLRequest) async -> Data? {
    guard let (data, response) = try? await networkLoader(request) else {
      return nil
    }
    if let httpResponse = response as? HTTPURLResponse,
      !(200...299).contains(httpResponse.statusCode)
    {
      return nil
    }
    guard !data.isEmpty, data.count <= Self.maximumResponseBytes else {
      return nil
    }
    return data
  }

  private func validatedPayload(
    _ data: Data,
    transport: ThemeSyncTransport
  ) -> ThemeSyncPayload? {
    // Normalise before hashing so the same template always produces the
    // same payload hash regardless of Shopify's auto-generated banner.
    let normalized = ThemeSnapshotLoader.strippingThemeBanner(from: data)
    guard
      let snapshot = try? ThemeHomeSnapshot.parse(data: normalized),
      snapshot.isAcceptableHome
    else {
      return nil
    }
    return ThemeSyncPayload(rawJSON: normalized, transport: transport)
  }
}

/// Publishes the home snapshot the app renders, replacing the build-time
/// `ThemeHomeSnapshot.bundled` constant as Home's source of truth.
///
/// Ordering guarantees:
/// - First frame renders instantly from the bundle (unchanged behaviour).
/// - The last synced snapshot on disk replaces it as soon as it is read.
/// - A remote refresh then follows in the background. Content only ever
///   moves forward; nothing on screen is removed while a fetch is running,
///   so there is no loading state and no flash.
@MainActor
final class ThemeSnapshotStore: ObservableObject {
  static let shared = ThemeSnapshotStore()

  @Published private(set) var home: ThemeHomeSnapshot
  /// Increments only when the rendered sections actually changed. Views key
  /// refresh work off this so an unchanged sync causes zero re-rendering.
  @Published private(set) var generation = 0

  private let service: ThemeSyncService
  private var appliedHash: String?
  private var isActivated = false

  init(service: ThemeSyncService = .shared) {
    self.service = service
    home = ThemeHomeSnapshot.bundled
    appliedHash = ThemeHomeSnapshot.bundledPayloadHash
  }

  /// Called once from the root scene. Loads the newest stored snapshot and
  /// then refreshes from the storefront.
  func activate() async {
    guard !isActivated else {
      await refreshIfStale()
      return
    }
    isActivated = true

    if let stored = await service.storedPayload() {
      apply(stored)
    }
    if let fresh = await service.refresh(force: true) {
      apply(fresh)
    }
  }

  /// Called when the app returns to the foreground. Throttled inside the
  /// service so rapid app switching costs nothing.
  func refreshIfStale() async {
    guard isActivated else { return }
    if let fresh = await service.refresh() {
      apply(fresh)
    }
  }

  private func apply(_ payload: ThemeSyncPayload) {
    guard payload.hash != appliedHash else { return }
    guard
      let snapshot = try? ThemeHomeSnapshot.parse(data: payload.rawJSON),
      snapshot.isAcceptableHome
    else {
      return
    }

    appliedHash = payload.hash
    home = snapshot
    generation &+= 1

    // Decode-ahead so a changed hero never paints a placeholder: by the time
    // SwiftUI diffs the new sections, their images are already in the
    // pipeline's cache (or in flight on the same request the view will make).
    // Requests are computed here so the detached task only captures a
    // Sendable array, never the snapshot itself.
    let prefetchRequests = Self.prefetchRequests(for: snapshot)
    Task.detached(priority: .utility) {
      for request in prefetchRequests {
        _ = try? await NativeImagePipeline.shared.image(for: request)
      }
    }
  }

  /// Mirrors the exact request geometry HomeView uses per section type, so
  /// the prefetch and the view resolve to identical cache keys.
  static func prefetchRequests(
    for snapshot: ThemeHomeSnapshot
  ) -> [NativeImageRequest] {
    var requests: [NativeImageRequest] = []

    func append(
      _ reference: String?,
      width: Int,
      aspectRatio: CGFloat = 1
    ) {
      guard
        let request = NativeImageRequest(
          sourceURL: ShopifyAsset.url(from: reference, width: width),
          pixelWidth: width,
          aspectRatio: aspectRatio
        )
      else {
        return
      }
      requests.append(request)
    }

    for section in snapshot.sections {
      switch section {
      case .hero(_, let slides):
        for slide in slides {
          append(
            slide.imageReference,
            width: 900,
            aspectRatio: ThemeTokens.heroImageAspectRatio
          )
        }
      case .contentRail(_, let rail):
        for card in rail.cards {
          append(card.imageReference, width: 700, aspectRatio: 4 / 3)
        }
      case .guidance(_, let guidance):
        for card in guidance.cards {
          append(card.imageReference, width: 220)
        }
      case .logos(_, let rail):
        for logo in rail.logos {
          append(logo.imageReference, width: 384, aspectRatio: 3 / 2)
        }
      case .greeting, .productRail, .smartAnalysis, .routine, .blog:
        continue
      }
    }

    // Heroes first, then a bounded tail; a cold sync must not queue an
    // unbounded image backlog behind the images the user is looking at.
    return Array(requests.prefix(24))
  }
}
