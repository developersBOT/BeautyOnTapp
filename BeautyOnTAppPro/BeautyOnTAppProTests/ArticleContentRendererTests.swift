import XCTest
@testable import BeautyOnTAppPro

final class ArticleContentRendererTests: XCTestCase {
  func testRendererPreservesTextAndVerifiedShopifyImagesInOrder() throws {
    let blocks = ArticleContentRenderer.blocks(
      html:
        """
        <h2>First section</h2>
        <p>Verified body.</p>
        <img src="https://cdn.shopify.com/s/files/article.jpg" alt="Article image">
        <p>Second section.</p>
        """
    )

    XCTAssertEqual(blocks.count, 3)
    guard case .text(_, let firstText) = blocks[0],
      case .image(_, let imageURL, let altText) = blocks[1],
      case .text(_, let lastText) = blocks[2]
    else {
      return XCTFail("Expected text, image, text block order.")
    }
    XCTAssertTrue(String(firstText.characters).contains("First section"))
    XCTAssertEqual(
      imageURL.absoluteString,
      "https://cdn.shopify.com/s/files/article.jpg"
    )
    XCTAssertEqual(altText, "Article image")
    XCTAssertTrue(String(lastText.characters).contains("Second section"))
  }

  func testRendererDropsUnsafeAndUntrustedEmbeddedContent() {
    let blocks = ArticleContentRenderer.blocks(
      html:
        """
        <script>alert('unsafe')</script>
        <p>Safe copy.</p>
        <img src="https://attacker.example/tracker.png">
        <iframe src="https://attacker.example"></iframe>
        """
    )

    XCTAssertEqual(blocks.count, 1)
    guard case .text(_, let text) = blocks[0] else {
      return XCTFail("Expected one safe text block.")
    }
    let value = String(text.characters)
    XCTAssertTrue(value.contains("Safe copy."))
    XCTAssertFalse(value.contains("unsafe"))
  }
}
