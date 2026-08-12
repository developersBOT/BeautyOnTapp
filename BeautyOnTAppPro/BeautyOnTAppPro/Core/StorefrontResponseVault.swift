import CryptoKit
import Foundation

/// Disk store for raw storefront read responses (GraphQL reads and the
/// brands directory page), keyed by the exact request they answered.
///
/// This is what makes a cold launch paint instantly: menus, rails, blog and
/// brands render from the last-known-good bytes while the network refresh
/// runs silently behind them (stale-while-revalidate). Only catalogue reads
/// belong here — cart, checkout and customer state must never touch disk.
actor StorefrontResponseVault {
  static let shared = StorefrontResponseVault()

  /// Reads older than this are treated as absent: after a week away the
  /// catalogue may have shifted too far for a silent stale paint to be
  /// honest, so the app falls back to a fresh network load.
  static let maximumStaleAge: TimeInterval = 72 * 60 * 60

  private static let maximumEntryCount = 160
  private static let maximumTotalBytes = 12 * 1_024 * 1_024

  private let directory: URL
  private let fileManager = FileManager.default

  init(directory: URL? = nil) {
    if let directory {
      self.directory = directory
    } else {
      let base =
        FileManager.default.urls(
          for: .applicationSupportDirectory,
          in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
      self.directory = base.appendingPathComponent(
        "StorefrontCache/v1",
        isDirectory: true
      )
    }
  }

  static func key(for requestFingerprint: Data) -> String {
    SHA256.hash(data: requestFingerprint)
      .map { String(format: "%02x", $0) }
      .joined()
  }

  func read(
    key: String,
    maxAge: TimeInterval = StorefrontResponseVault.maximumStaleAge
  ) -> Data? {
    let url = entryURL(for: key)
    guard
      let attributes = try? fileManager.attributesOfItem(atPath: url.path),
      let modifiedAt = attributes[.modificationDate] as? Date,
      Date().timeIntervalSince(modifiedAt) <= maxAge,
      let data = try? Data(contentsOf: url),
      !data.isEmpty
    else {
      return nil
    }
    return data
  }

  func write(key: String, data: Data) {
    guard !data.isEmpty else { return }
    do {
      try fileManager.createDirectory(
        at: directory,
        withIntermediateDirectories: true
      )
      try data.write(to: entryURL(for: key), options: .atomic)
    } catch {
      // Caching is best effort; the live response was already delivered.
      return
    }
    trim()
  }

  func removeAll() {
    try? fileManager.removeItem(at: directory)
  }

  private func entryURL(for key: String) -> URL {
    directory.appendingPathComponent("\(key).json")
  }

  private func trim() {
    guard
      let urls = try? fileManager.contentsOfDirectory(
        at: directory,
        includingPropertiesForKeys: [
          .contentModificationDateKey, .fileSizeKey,
        ]
      )
    else {
      return
    }

    struct Entry {
      let url: URL
      let modifiedAt: Date
      let bytes: Int
    }

    let entries = urls.compactMap { url -> Entry? in
      guard
        let values = try? url.resourceValues(forKeys: [
          .contentModificationDateKey, .fileSizeKey,
        ])
      else {
        return nil
      }
      return Entry(
        url: url,
        modifiedAt: values.contentModificationDate ?? .distantPast,
        bytes: values.fileSize ?? 0
      )
    }.sorted { $0.modifiedAt > $1.modifiedAt }

    var keptCount = 0
    var keptBytes = 0
    for entry in entries {
      keptCount += 1
      keptBytes += entry.bytes
      if keptCount > Self.maximumEntryCount
        || keptBytes > Self.maximumTotalBytes
      {
        try? fileManager.removeItem(at: entry.url)
      }
    }
  }
}
