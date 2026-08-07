import XCTest

@testable import BeautyOnTAppPro

final class StoreLocationsTests: XCTestCase {
  override func tearDown() {
    StoreLocationsURLProtocol.response = nil
    super.tearDown()
  }

  func testClientFetchesTheCurrentLocationsPageAtRuntime() async throws {
    let recorder = StoreLocationsRequestRecorder()
    let body = Data(fixture.utf8)
    StoreLocationsURLProtocol.response = { request in
      recorder.record(request)
      let response = HTTPURLResponse(
        url: try XCTUnwrap(request.url),
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "text/html; charset=utf-8"]
      )!
      return (response, body)
    }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [StoreLocationsURLProtocol.self]
    let client = StoreLocationsClient(
      session: URLSession(configuration: configuration)
    )

    let locations = try await client.fetchLocations()

    XCTAssertEqual(locations.count, 2)
    let request = try XCTUnwrap(recorder.requests.first)
    XCTAssertEqual(request.url, StoreLocationsClient.liveURL)
    XCTAssertEqual(
      request.value(forHTTPHeaderField: "Accept"),
      "text/html,application/xhtml+xml"
    )
  }

  func testParsesThemeHealthAndBeautyBusinessContract() throws {
    let locations = try StoreLocationsParser.parse(html: fixture)

    XCTAssertEqual(locations.count, 2)
    let gateway = try XCTUnwrap(
      locations.first { $0.name == "BeautyOnTApp Gateway Umhlanga" }
    )
    XCTAssertEqual(
      gateway.id,
      "https://beautyontapp.com/#store-gateway-umhlanga"
    )
    XCTAssertEqual(
      gateway.address.streetAddress,
      "Gateway Theatre of Shopping, 1 Palm Boulevard"
    )
    XCTAssertEqual(gateway.address.locality, "Umhlanga")
    XCTAssertEqual(gateway.coordinate?.latitude, -29.7282)
    XCTAssertEqual(gateway.coordinate?.longitude, 31.0681)
    XCTAssertEqual(gateway.openingHours.first?.daySummary, "Daily")
    XCTAssertEqual(gateway.openingHours.first?.opens, "08:00")
    XCTAssertEqual(gateway.openingHours.first?.closes, "19:00")

    let fourways = try XCTUnwrap(
      locations.first { $0.name == "BeautyOnTApp Fourways Mall" }
    )
    XCTAssertEqual(fourways.telephone, "+27 11 465 6095")
    XCTAssertEqual(fourways.telephoneURL?.absoluteString, "tel:+27114656095")
  }

  func testSupportsGraphAndTypeArrays() throws {
    let html = """
      <script TYPE='application/ld+json'>
      {
        "@context": "https://schema.org",
        "@graph": [
          {
            "@type": ["Organization", "HealthAndBeautyBusiness"],
            "@id": "store-one",
            "name": "Store One",
            "address": {
              "streetAddress": "1 Main Road",
              "addressCountry": "ZA"
            },
            "geo": {
              "latitude": "-26.1",
              "longitude": "28.2"
            }
          }
        ]
      }
      </script>
      """

    let locations = try StoreLocationsParser.parse(html: html)

    XCTAssertEqual(locations.map(\.name), ["Store One"])
    XCTAssertEqual(locations.first?.coordinate?.latitude, -26.1)
  }

  func testIgnoresUnrelatedJSONLDAndMalformedScripts() throws {
    let html = """
      <script type="application/ld+json">not-json</script>
      <script type="application/ld+json">
        {"@type":"Organization","name":"BeautyOnTApp"}
      </script>
      \(fixture)
      """

    let locations = try StoreLocationsParser.parse(html: html)

    XCTAssertEqual(locations.count, 2)
  }

  func testDeduplicatesBySchemaIdentifier() throws {
    let duplicated = fixture.replacingOccurrences(
      of: "</body>",
      with: fixture + "</body>"
    )

    let locations = try StoreLocationsParser.parse(html: duplicated)

    XCTAssertEqual(locations.count, 2)
  }

  func testRejectsPagesWithoutCurrentStoreSchema() {
    XCTAssertThrowsError(
      try StoreLocationsParser.parse(
        html: """
          <script type="application/ld+json">
            {"@type":"Organization","name":"BeautyOnTApp"}
          </script>
          """
      )
    ) { error in
      XCTAssertEqual(error as? StoreLocationsError, .noLocations)
    }
  }

  func testBuildsNativeMapsURLFromCoordinate() throws {
    let location = try XCTUnwrap(
      try StoreLocationsParser.parse(html: fixture).first
    )
    let components = try XCTUnwrap(
      URLComponents(
        url: try XCTUnwrap(location.mapsURL),
        resolvingAgainstBaseURL: false
      )
    )

    XCTAssertEqual(components.host, "maps.apple.com")
    XCTAssertEqual(
      components.queryItems?.first { $0.name == "daddr" }?.value,
      "-29.7282,31.0681"
    )
  }

  private let fixture = """
      <html>
        <head>
          <script type="application/ld+json">
          [
            {
              "@context": "https://schema.org",
              "@type": "HealthAndBeautyBusiness",
              "@id": "https://beautyontapp.com/#store-gateway-umhlanga",
              "name": "BeautyOnTApp Gateway Umhlanga",
              "url": "https://beautyontapp.com/pages/locations",
              "address": {
                "@type": "PostalAddress",
                "streetAddress": "Gateway Theatre of Shopping, 1 Palm Boulevard",
                "addressLocality": "Umhlanga",
                "addressRegion": "KwaZulu-Natal",
                "postalCode": "4319",
                "addressCountry": "ZA"
              },
              "geo": {
                "@type": "GeoCoordinates",
                "latitude": -29.7282,
                "longitude": 31.0681
              },
              "openingHoursSpecification": [{
                "@type": "OpeningHoursSpecification",
                "dayOfWeek": [
                  "Monday",
                  "Tuesday",
                  "Wednesday",
                  "Thursday",
                  "Friday",
                  "Saturday",
                  "Sunday"
                ],
                "opens": "08:00",
                "closes": "19:00"
              }]
            },
            {
              "@context": "https://schema.org",
              "@type": "HealthAndBeautyBusiness",
              "@id": "https://beautyontapp.com/#store-fourways",
              "name": "BeautyOnTApp Fourways Mall",
              "telephone": "+27 11 465 6095",
              "address": {
                "@type": "PostalAddress",
                "streetAddress": "Fourways Mall, William Nicol Drive",
                "addressLocality": "Fourways",
                "addressRegion": "Gauteng",
                "postalCode": "2055",
                "addressCountry": "ZA"
              }
            }
          ]
          </script>
        </head>
        <body></body>
      </html>
    """
}

private final class StoreLocationsRequestRecorder: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: [URLRequest] = []

  var requests: [URLRequest] {
    lock.withLock { storage }
  }

  func record(_ request: URLRequest) {
    lock.withLock {
      storage.append(request)
    }
  }
}

private final class StoreLocationsURLProtocol: URLProtocol {
  nonisolated(unsafe) static var response: ((URLRequest) throws -> (HTTPURLResponse, Data))?

  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    do {
      let response = try XCTUnwrap(Self.response)(request)
      client?.urlProtocol(
        self,
        didReceive: response.0,
        cacheStoragePolicy: .notAllowed
      )
      client?.urlProtocol(self, didLoad: response.1)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}
}
