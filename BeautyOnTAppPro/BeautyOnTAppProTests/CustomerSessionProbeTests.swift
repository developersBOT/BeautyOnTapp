import XCTest

@testable import BeautyOnTAppPro

@MainActor
final class CustomerSessionProbeTests: XCTestCase {
  func testHomeAccountBarStaysVisibleUntilSignedInIsVerified() {
    XCTAssertTrue(CustomerSessionState.unknown.shouldShowHomeAccountBar)
    XCTAssertTrue(CustomerSessionState.signedOut.shouldShowHomeAccountBar)
    XCTAssertFalse(
      CustomerSessionState.signedIn(firstName: "Tyler")
        .shouldShowHomeAccountBar
    )
  }

  func testProbeUsesExactStorefrontRootAndBoundedTimeout() {
    XCTAssertEqual(
      CustomerSessionProbe.rootURL.absoluteString,
      "https://beautyontapp.com"
    )
    XCTAssertEqual(
      CustomerSessionProbe(timeoutInterval: 0).timeoutInterval,
      CustomerSessionProbe.minimumTimeout
    )
    XCTAssertEqual(
      CustomerSessionProbe(timeoutInterval: 60).timeoutInterval,
      CustomerSessionProbe.maximumTimeout
    )
  }

  func testSignedOutRequiresModalAndSignedOutMarkerOnly() {
    let result = snapshot(
      hasSignedOutEntry: true,
      dockDisplayName: "Profile"
    ).verifiedResult

    XCTAssertEqual(result.state, .signedOut)
    XCTAssertNil(result.displayName)
  }

  func testSignedInParsesEveryExactThemeGreetingPrefix() {
    let cases = [
      ("Good Morning☀️ Tyler", "Tyler"),
      ("Good Afternoon🌞 Tyler", "Tyler"),
      ("Good Evening🌙 Tyler", "Tyler"),
    ]

    for (greeting, expectedFirstName) in cases {
      let result = snapshot(
        hasLogoutLink: true,
        greeting: greeting,
        dockDisplayName: " Tyler Ngwenya "
      ).verifiedResult

      XCTAssertEqual(result.state, .signedIn(firstName: expectedFirstName))
      XCTAssertEqual(result.displayName, "Tyler Ngwenya")
    }
  }

  func testSessionInterpretationUsesAuthenticatedMarkersWithoutModal() {
    let authenticatedWithoutModal = snapshot(
      hasProfileModal: false,
      hasLogoutLink: true,
      greeting: "Good Morning☀️ Tyler"
    ).verifiedResult
    XCTAssertEqual(
      authenticatedWithoutModal.state,
      .signedIn(firstName: "Tyler")
    )
    XCTAssertEqual(authenticatedWithoutModal.displayName, "Tyler")

    // A stale hidden sign-in node must not override the authenticated
    // customer branch while Shopify hydrates the profile modal.
    XCTAssertEqual(
      snapshot(
        hasSignedOutEntry: true,
        hasLogoutLink: true,
        greeting: "Good Morning☀️ Tyler"
      ).verifiedResult,
      CustomerSessionProbeResult(
        state: .signedIn(firstName: "Tyler"),
        displayName: "Tyler"
      )
    )
    XCTAssertEqual(
      snapshot(
        hasLogoutLink: true,
        greeting: "Hello Tyler"
      ).verifiedResult,
      .unknown
    )
    XCTAssertEqual(
      snapshot(
        hasLogoutLink: true,
        greeting: "Good Morning☀️ "
      ).verifiedResult,
      .unknown
    )
  }

  func testAuthenticatedDisplayNameFailsClosedIndependently() {
    let result = snapshot(
      hasLogoutLink: true,
      greeting: "Good Morning☀️ Tyler",
      dockDisplayName: ""
    ).verifiedResult

    XCTAssertEqual(result.state, .signedIn(firstName: "Tyler"))
    XCTAssertEqual(result.displayName, "Tyler")
  }

  func testSelectingProfilePublishesInjectedProbeResult() async {
    let probe = CustomerSessionProbeStub(
      results: [
        CustomerSessionProbeResult(
          state: .signedIn(firstName: "Tyler"),
          displayName: "Tyler Ngwenya"
        )
      ]
    )
    let model = makeModel(probe: probe)

    model.selectDock(.profile)

    await waitUntil {
      model.customerSession == .signedIn(firstName: "Tyler")
    }
    XCTAssertEqual(probe.callCount, 1)
    XCTAssertEqual(model.customerDisplayName, "Tyler Ngwenya")
  }

  func testRefreshCustomerSessionRetriesTransientUnknownResult() async {
    let probe = CustomerSessionProbeStub(
      results: [
        .unknown,
        CustomerSessionProbeResult(
          state: .signedIn(firstName: "Tyler"),
          displayName: "Tyler Ngwenya"
        ),
      ]
    )
    let model = makeModel(probe: probe)

    await model.refreshCustomerSession()

    XCTAssertEqual(
      model.customerSession,
      .signedIn(firstName: "Tyler")
    )
    XCTAssertEqual(model.customerDisplayName, "Tyler Ngwenya")
    XCTAssertEqual(probe.callCount, 2)
  }

  func testSelectingProfileKeepsVerifiedIdentityWhileRefreshStarts() async {
    let probe = CustomerSessionProbeStub(
      results: [
        CustomerSessionProbeResult(
          state: .signedIn(firstName: "Tyler"),
          displayName: "Tyler Ngwenya"
        ),
        .unknown,
      ]
    )
    let model = makeModel(probe: probe)
    await model.refreshCustomerSession()

    model.selectDock(.profile)

    XCTAssertEqual(model.customerSession, .signedIn(firstName: "Tyler"))
    XCTAssertEqual(model.customerDisplayName, "Tyler Ngwenya")

    await waitUntil {
      probe.callCount == 2
    }
    XCTAssertEqual(model.customerSession, .signedIn(firstName: "Tyler"))
    XCTAssertEqual(model.customerDisplayName, "Tyler Ngwenya")
    XCTAssertEqual(probe.callCount, 2)
  }

  func testBootstrapStartsSessionProbeWithoutWaitingForIt() async {
    let probe = SuspendedCustomerSessionProbe()
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [CustomerSessionBootstrapURLProtocol.self]
    let model = AppModel(
      client: StorefrontClient(
        session: URLSession(configuration: configuration)
      ),
      cartVault: CustomerSessionMemoryCartVault(),
      legacyCartMigrator: CompletedCustomerSessionCartMigrator(),
      customerSessionProbe: probe
    )

    await model.bootstrap()

    XCTAssertTrue(model.isBootstrapComplete)
    await waitUntil {
      probe.callCount == 1
    }
    XCTAssertEqual(model.customerSession, .unknown)

    probe.resolve(
      CustomerSessionProbeResult(
        state: .signedOut,
        displayName: nil
      )
    )
    await waitUntil {
      model.customerSession == .signedOut
    }
  }

  func testWebFlowDismissalRefreshesCustomerSession() async {
    let probe = CustomerSessionProbeStub(
      results: [
        CustomerSessionProbeResult(
          state: .signedOut,
          displayName: nil
        ),
        CustomerSessionProbeResult(
          state: .signedIn(firstName: "Tyler"),
          displayName: "Tyler Ngwenya"
        ),
      ]
    )
    let model = makeModel(probe: probe)

    await model.refreshCustomerSession()
    XCTAssertEqual(model.customerSession, .signedOut)
    XCTAssertNil(model.customerDisplayName)

    model.webFlowDidDismiss()

    await waitUntil {
      model.customerSession == .signedIn(firstName: "Tyler")
    }
    XCTAssertEqual(probe.callCount, 2)
    XCTAssertEqual(model.customerDisplayName, "Tyler Ngwenya")
  }

  func testProfileAccountActionRoutesMatchVerifiedThemeRoutes() throws {
    let logoutModel = makeModel(probe: CustomerSessionProbeStub())
    logoutModel.openProfileLogout()
    XCTAssertEqual(
      logoutModel.webDestination?.url,
      try XCTUnwrap(
        URL(string: "https://beautyontapp.com/account/logout")
      )
    )

    let deleteModel = makeModel(probe: CustomerSessionProbeStub())
    deleteModel.openProfileDeleteAccount()
    XCTAssertEqual(
      deleteModel.webDestination?.url,
      try XCTUnwrap(
        URL(string: "https://beautyontapp.com/pages/delete-account")
      )
    )
  }

  private func snapshot(
    hasProfileModal: Bool = true,
    hasSignedOutEntry: Bool = false,
    hasLogoutLink: Bool = false,
    greeting: String = "",
    dockDisplayName: String = ""
  ) -> CustomerSessionDOMSnapshot {
    CustomerSessionDOMSnapshot(
      hasProfileModal: hasProfileModal,
      hasSignedOutEntry: hasSignedOutEntry,
      hasLogoutLink: hasLogoutLink,
      greeting: greeting,
      dockDisplayName: dockDisplayName
    )
  }

  private func makeModel(probe: any CustomerSessionProbing) -> AppModel {
    AppModel(
      cartVault: CustomerSessionMemoryCartVault(),
      customerSessionProbe: probe
    )
  }

  private func waitUntil(
    _ predicate: @escaping @MainActor () -> Bool,
    file: StaticString = #filePath,
    line: UInt = #line
  ) async {
    for _ in 0..<100 {
      if predicate() {
        return
      }
      try? await Task.sleep(nanoseconds: 10_000_000)
    }
    XCTFail("Timed out waiting for customer-session state.", file: file, line: line)
  }
}

@MainActor
private final class CustomerSessionProbeStub: CustomerSessionProbing {
  private var results: [CustomerSessionProbeResult]
  private(set) var callCount = 0

  init(results: [CustomerSessionProbeResult] = [.unknown]) {
    self.results = results
  }

  func probe() async -> CustomerSessionProbeResult {
    callCount += 1
    guard !results.isEmpty else {
      return .unknown
    }
    return results.removeFirst()
  }
}

private final class CustomerSessionMemoryCartVault: CartIDStoring {
  func read() -> String? { nil }
  func write(_ value: String) {}
  func delete() {}
}

@MainActor
private final class SuspendedCustomerSessionProbe: CustomerSessionProbing {
  private var continuation: CheckedContinuation<CustomerSessionProbeResult, Never>?
  private(set) var callCount = 0

  func probe() async -> CustomerSessionProbeResult {
    callCount += 1
    return await withCheckedContinuation { continuation in
      self.continuation = continuation
    }
  }

  func resolve(_ result: CustomerSessionProbeResult) {
    let continuation = continuation
    self.continuation = nil
    continuation?.resume(returning: result)
  }
}

@MainActor
private final class CompletedCustomerSessionCartMigrator:
  LegacyWebCartMigrating
{
  var isComplete: Bool { true }
  func fetchLines() async throws -> [StoreCartInputLine] { [] }
  func markComplete() {}
}

private final class CustomerSessionBootstrapURLProtocol: URLProtocol {
  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    guard let url = request.url,
      let response = HTTPURLResponse(
        url: url,
        statusCode: 503,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
      )
    else {
      client?.urlProtocol(
        self,
        didFailWithError: URLError(.badServerResponse)
      )
      return
    }

    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: Data("{}".utf8))
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}
