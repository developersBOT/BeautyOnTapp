import XCTest
@testable import BeautyOnTAppPro

final class WishlistPageTests: XCTestCase {
  func testParsesVerifiedWishlistPageAndDeduplicatesVariants() {
    let json = """
    {
      "verified": true,
      "totalCount": 3,
      "entries": [
        {
          "productID": "8929366212867",
          "variantID": "46726252003587",
          "handle": "niacinamide-body-lotion"
        },
        {
          "productID": "8929366212867",
          "variantID": "46726252003587",
          "handle": "niacinamide-body-lotion"
        }
      ]
    }
    """

    XCTAssertEqual(
      WishlistBridge.parsePage(json),
      WishlistPage(
        totalCount: 3,
        entries: [
          WishlistEntry(
            productID: "8929366212867",
            variantID: "46726252003587",
            handle: "niacinamide-body-lotion"
          )
        ]
      )
    )
  }

  func testRejectsUnverifiedOrMalformedWishlistEntries() {
    XCTAssertNil(
      WishlistBridge.parsePage(
        """
        {"verified":false,"totalCount":0,"entries":[]}
        """
      )
    )
    XCTAssertNil(
      WishlistBridge.parsePage(
        """
        {
          "verified":true,
          "totalCount":1,
          "entries":[{
            "productID":"8929366212867",
            "variantID":"46726252003587",
            "handle":"../account"
          }]
        }
        """
      )
    )
    XCTAssertNil(
      WishlistBridge.parsePage(
        """
        {
          "verified":true,
          "totalCount":1,
          "entries":[{
            "productID":"not-a-number",
            "variantID":"46726252003587",
            "handle":"niacinamide-body-lotion"
          }]
        }
        """
      )
    )
  }
}
