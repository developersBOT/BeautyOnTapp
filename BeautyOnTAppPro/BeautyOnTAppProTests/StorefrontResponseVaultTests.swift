import Foundation
import XCTest

@testable import BeautyOnTAppPro

final class StorefrontResponseVaultTests: XCTestCase {
  private func makeVault() -> (vault: StorefrontResponseVault, directory: URL)
  {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("vault-tests-\(UUID().uuidString)")
    return (StorefrontResponseVault(directory: directory), directory)
  }

  func testRoundTripsRawResponseBytes() async throws {
    let (vault, directory) = makeVault()
    defer { try? FileManager.default.removeItem(at: directory) }

    let key = StorefrontResponseVault.key(for: Data("query-a".utf8))
    let payload = Data(#"{"data": {"menu": {"handle": "navabr"}}}"#.utf8)

    await vault.write(key: key, data: payload)
    let read = await vault.read(key: key)

    XCTAssertEqual(read, payload)
  }

  func testMissingAndExpiredEntriesReadAsAbsent() async throws {
    let (vault, directory) = makeVault()
    defer { try? FileManager.default.removeItem(at: directory) }

    let key = StorefrontResponseVault.key(for: Data("query-b".utf8))
    let absent = await vault.read(key: key)
    XCTAssertNil(absent)

    await vault.write(key: key, data: Data("cached".utf8))
    // An entry written a moment ago is already older than a zero max age;
    // this is the "stale beyond honesty" path without waiting out 72 hours.
    let expired = await vault.read(key: key, maxAge: 0)
    XCTAssertNil(expired)

    let fresh = await vault.read(key: key)
    XCTAssertEqual(fresh, Data("cached".utf8))
  }

  func testEmptyDataIsNeverStored() async throws {
    let (vault, directory) = makeVault()
    defer { try? FileManager.default.removeItem(at: directory) }

    let key = StorefrontResponseVault.key(for: Data("query-c".utf8))
    await vault.write(key: key, data: Data())

    let read = await vault.read(key: key)
    XCTAssertNil(read)
  }

  func testKeysAreStableAndCollisionResistant() {
    let first = StorefrontResponseVault.key(for: Data("fingerprint".utf8))
    let second = StorefrontResponseVault.key(for: Data("fingerprint".utf8))
    let other = StorefrontResponseVault.key(for: Data("different".utf8))

    XCTAssertEqual(first, second)
    XCTAssertNotEqual(first, other)
    // SHA-256 hex — filesystem-safe filenames.
    XCTAssertEqual(first.count, 64)
    XCTAssertTrue(first.allSatisfy(\.isHexDigit))
  }

  func testRemoveAllClearsTheStore() async throws {
    let (vault, directory) = makeVault()
    defer { try? FileManager.default.removeItem(at: directory) }

    let key = StorefrontResponseVault.key(for: Data("query-d".utf8))
    await vault.write(key: key, data: Data("cached".utf8))
    await vault.removeAll()

    let read = await vault.read(key: key)
    XCTAssertNil(read)
  }
}
