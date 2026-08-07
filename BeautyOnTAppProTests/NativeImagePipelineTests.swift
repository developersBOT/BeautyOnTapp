import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import XCTest

@testable import BeautyOnTAppPro

final class NativeImagePipelineTests: XCTestCase {
  func testShopifyURLIsHTTPSWidthBoundedAndQueryPreserved() throws {
    let source = try XCTUnwrap(
      URL(
        string:
          "https://cdn.shopify.com/s/files/1/0001/product.jpg?v=42&width=9999"
      )
    )

    let optimized = try XCTUnwrap(
      NativeImageRequest.optimizedURL(
        source,
        pixelWidth: 600
      )
    )
    let components = try XCTUnwrap(
      URLComponents(
        url: optimized,
        resolvingAgainstBaseURL: false
      )
    )

    XCTAssertEqual(components.scheme, "https")
    XCTAssertEqual(components.host, "cdn.shopify.com")
    XCTAssertEqual(
      components.queryItems?.filter { $0.name == "width" }.map(\.value),
      ["600"]
    )
    XCTAssertEqual(
      components.queryItems?.first { $0.name == "v" }?.value,
      "42"
    )
  }

  func testExternalHTTPSURLIsNotRewrittenAndInsecureURLIsRejected()
    throws
  {
    let external = try XCTUnwrap(
      URL(string: "https://images.example.com/product.jpg?width=900")
    )
    XCTAssertEqual(
      NativeImageRequest.optimizedURL(
        external,
        pixelWidth: 600
      ),
      external
    )

    let insecure = try XCTUnwrap(
      URL(string: "http://cdn.shopify.com/product.jpg")
    )
    XCTAssertNil(
      NativeImageRequest.optimizedURL(
        insecure,
        pixelWidth: 600
      )
    )
  }

  func testDecodeDimensionUsesTheRenderedAspectRatio() throws {
    let source = try XCTUnwrap(
      URL(string: "https://cdn.shopify.com/product.jpg")
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: source,
        pixelWidth: 600,
        aspectRatio: 0.5
      )
    )

    XCTAssertEqual(request.maximumPixelDimension, 1_200)
  }

  func testConcurrentLoadsCoalesceThenUseMemoryCache() async throws {
    let stub = ImageNetworkStub(
      data: try XCTUnwrap(
        Data(
          base64Encoded:
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
        )
      ),
      delayNanoseconds: 80_000_000
    )
    let pipeline = NativeImagePipeline(
      memoryCostLimit: 1_024 * 1_024,
      memoryCountLimit: 4,
      networkLoader: { request in
        try await stub.load(request)
      }
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: URL(
          string: "https://cdn.shopify.com/product.png"
        ),
        pixelWidth: 320
      )
    )

    async let first = pipeline.image(for: request)
    async let second = pipeline.image(for: request)
    let (firstImage, secondImage) = try await (first, second)

    XCTAssertEqual(firstImage.cgImage.width, 1)
    XCTAssertEqual(secondImage.cgImage.height, 1)
    let coalescedRequestCount = await stub.requestCount
    let cachePolicy = await stub.lastCachePolicy
    XCTAssertEqual(coalescedRequestCount, 1)
    XCTAssertEqual(
      cachePolicy,
      .returnCacheDataElseLoad
    )

    _ = try await pipeline.image(for: request)

    let cachedRequestCount = await stub.requestCount
    let isCached = await pipeline.isImageCached(for: request)
    XCTAssertEqual(cachedRequestCount, 1)
    XCTAssertTrue(isCached)
  }

  func testCancellingOnlySubscriberCancelsUnderlyingLoad() async throws {
    let stub = ImageNetworkStub(
      data: try XCTUnwrap(
        Data(
          base64Encoded:
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
        )
      ),
      delayNanoseconds: 5_000_000_000
    )
    let pipeline = NativeImagePipeline(
      networkLoader: { request in
        try await stub.load(request)
      }
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: URL(
          string: "https://cdn.shopify.com/cancelled-product.png"
        ),
        pixelWidth: 320
      )
    )
    let loadTask = Task {
      try await pipeline.image(for: request)
    }

    for _ in 0..<100 {
      if await stub.requestCount == 1 {
        break
      }
      try await Task.sleep(nanoseconds: 1_000_000)
    }

    loadTask.cancel()

    do {
      _ = try await loadTask.value
      XCTFail("A cancelled image subscriber must not receive an image.")
    } catch is CancellationError {
      // Expected.
    }

    let cancellationCount = await stub.cancellationCount
    XCTAssertEqual(cancellationCount, 1)
  }

  func testDarkModeRemovalKeepsABoundedProductCutout() async throws {
    let data = try makePNG(
      width: 16,
      height: 16,
      foreground: CGRect(x: 5, y: 5, width: 6, height: 6),
      foregroundColor: (24, 96, 80, 255)
    )
    let pipeline = NativeImagePipeline(
      networkLoader: { request in
        (
          data,
          URLResponse(
            url: request.url!,
            mimeType: "image/png",
            expectedContentLength: data.count,
            textEncodingName: nil
          )
        )
      }
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: URL(string: "https://cdn.shopify.com/bounded.png"),
        pixelWidth: 64,
        backgroundTreatment: .whiteBackgroundToAlpha
      )
    )

    let image = try await pipeline.image(for: request)

    XCTAssertEqual(pixel(in: image.cgImage, x: 0, y: 0).alpha, 0)
    XCTAssertGreaterThan(pixel(in: image.cgImage, x: 8, y: 8).alpha, 0)
  }

  func testDarkModeRemovalPreservesImagesWhoseForegroundTouchesTheCropEdge()
    async throws
  {
    let data = try makePNG(
      width: 16,
      height: 16,
      foreground: CGRect(x: 0, y: 4, width: 8, height: 8),
      foregroundColor: (24, 96, 80, 255)
    )
    let pipeline = NativeImagePipeline(
      networkLoader: { request in
        (
          data,
          URLResponse(
            url: request.url!,
            mimeType: "image/png",
            expectedContentLength: data.count,
            textEncodingName: nil
          )
        )
      }
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: URL(string: "https://cdn.shopify.com/edge-product.png"),
        pixelWidth: 64,
        backgroundTreatment: .whiteBackgroundToAlpha
      )
    )

    let image = try await pipeline.image(for: request)
    let edgePixel = pixel(in: image.cgImage, x: 0, y: 8)

    XCTAssertEqual(edgePixel.alpha, 255)
    XCTAssertEqual(edgePixel.red, 24)
    XCTAssertEqual(edgePixel.green, 96)
    XCTAssertEqual(edgePixel.blue, 80)
  }

  func testDarkModeRemovalKeepsNearWhiteProductEdgesIntact() async throws {
    let data = try makeNearWhiteProductPNG(width: 16, height: 16)
    let pipeline = NativeImagePipeline(
      networkLoader: { request in
        (
          data,
          URLResponse(
            url: request.url!,
            mimeType: "image/png",
            expectedContentLength: data.count,
            textEncodingName: nil
          )
        )
      }
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: URL(string: "https://cdn.shopify.com/near-white-product.png"),
        pixelWidth: 64,
        backgroundTreatment: .whiteBackgroundToAlpha
      )
    )

    let image = try await pipeline.image(for: request)

    // The near-white antialiased edge is part of the product, not its canvas.
    // It must remain opaque so dark mode cannot create black slots in the item.
    XCTAssertGreaterThan(pixel(in: image.cgImage, x: 5, y: 8).alpha, 0)
    XCTAssertGreaterThan(pixel(in: image.cgImage, x: 10, y: 8).alpha, 0)
    XCTAssertGreaterThan(pixel(in: image.cgImage, x: 8, y: 8).alpha, 0)
    XCTAssertEqual(pixel(in: image.cgImage, x: 0, y: 0).alpha, 0)
  }

  func testDarkModeRemovalClearsWarmWhiteCompressedCanvas() async throws {
    let data = try makeWarmWhiteCanvasPNG(
      width: 32,
      height: 32,
      foreground: CGRect(x: 10, y: 9, width: 12, height: 14),
      foregroundColor: (24, 96, 80, 255)
    )
    let pipeline = NativeImagePipeline(
      networkLoader: { request in
        (
          data,
          URLResponse(
            url: request.url!,
            mimeType: "image/png",
            expectedContentLength: data.count,
            textEncodingName: nil
          )
        )
      }
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: URL(string: "https://cdn.shopify.com/warm-white.png"),
        pixelWidth: 128,
        backgroundTreatment: .whiteBackgroundToAlpha
      )
    )

    let image = try await pipeline.image(for: request)

    XCTAssertEqual(pixel(in: image.cgImage, x: 0, y: 0).alpha, 0)
    XCTAssertGreaterThan(pixel(in: image.cgImage, x: 16, y: 16).alpha, 0)
  }

  func testAdaptiveTreatmentRemovesWarmCatalogueCanvasPerImage()
    async throws
  {
    let data = try makeWarmWhiteCanvasPNG(
      width: 32,
      height: 32,
      foreground: CGRect(x: 10, y: 9, width: 12, height: 14),
      foregroundColor: (24, 96, 80, 255)
    )
    let pipeline = NativeImagePipeline(
      networkLoader: { request in
        (
          data,
          URLResponse(
            url: request.url!,
            mimeType: "image/png",
            expectedContentLength: data.count,
            textEncodingName: nil
          )
        )
      }
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: URL(string: "https://cdn.shopify.com/adaptive-warm.png"),
        pixelWidth: 128,
        backgroundTreatment: .adaptiveProductBackgroundToAlpha
      )
    )

    let image = try await pipeline.image(for: request)

    XCTAssertEqual(pixel(in: image.cgImage, x: 0, y: 0).alpha, 0)
    XCTAssertGreaterThan(pixel(in: image.cgImage, x: 16, y: 16).alpha, 0)
  }

  func testAdaptiveTreatmentLeavesComposedArtworkIntact()
    async throws
  {
    let data = try makeComposedArtworkPNG(width: 32, height: 32)
    let pipeline = NativeImagePipeline(
      networkLoader: { request in
        (
          data,
          URLResponse(
            url: request.url!,
            mimeType: "image/png",
            expectedContentLength: data.count,
            textEncodingName: nil
          )
        )
      }
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: URL(string: "https://cdn.shopify.com/composed-art.png"),
        pixelWidth: 128,
        backgroundTreatment: .adaptiveProductBackgroundToAlpha
      )
    )

    let image = try await pipeline.image(for: request)

    XCTAssertEqual(image.cgImage.width, 32)
    XCTAssertEqual(image.cgImage.height, 32)
    XCTAssertEqual(pixel(in: image.cgImage, x: 0, y: 0).alpha, 255)
    XCTAssertEqual(pixel(in: image.cgImage, x: 31, y: 31).alpha, 255)
  }

  func testDarkModeRemovalFeathersWhiteMatteAtTheProductEdge()
    async throws
  {
    let data = try makeNearWhiteProductPNG(width: 16, height: 16)
    let pipeline = NativeImagePipeline(
      networkLoader: { request in
        (
          data,
          URLResponse(
            url: request.url!,
            mimeType: "image/png",
            expectedContentLength: data.count,
            textEncodingName: nil
          )
        )
      }
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: URL(string: "https://cdn.shopify.com/matte-edge.png"),
        pixelWidth: 64,
        backgroundTreatment: .whiteBackgroundToAlpha
      )
    )

    let image = try await pipeline.image(for: request)
    let edge = pixel(in: image.cgImage, x: 5, y: 8)

    XCTAssertGreaterThan(edge.alpha, 0)
    XCTAssertLessThan(edge.alpha, 255)
    XCTAssertLessThan(edge.red, 249)
  }

  func testDarkModeRemovalTrimsValidatedWhiteMatteCanvas() async throws {
    let data = try makePNG(
      width: 256,
      height: 256,
      foreground: CGRect(x: 80, y: 56, width: 96, height: 144),
      foregroundColor: (24, 96, 80, 255)
    )
    let pipeline = NativeImagePipeline(
      networkLoader: { request in
        (
          data,
          URLResponse(
            url: request.url!,
            mimeType: "image/png",
            expectedContentLength: data.count,
            textEncodingName: nil
          )
        )
      }
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: URL(string: "https://cdn.shopify.com/trimmed-product.png"),
        pixelWidth: 256,
        backgroundTreatment: .whiteBackgroundToAlpha
      )
    )

    let image = try await pipeline.image(for: request)

    XCTAssertLessThan(image.cgImage.width, 256)
    XCTAssertLessThan(image.cgImage.height, 256)
  }

  func testDarkModeRemovalCanPreserveCatalogueCanvasScale() async throws {
    let data = try makePNG(
      width: 256,
      height: 256,
      foreground: CGRect(x: 80, y: 56, width: 96, height: 144),
      foregroundColor: (24, 96, 80, 255)
    )
    let pipeline = NativeImagePipeline(
      networkLoader: { request in
        (
          data,
          URLResponse(
            url: request.url!,
            mimeType: "image/png",
            expectedContentLength: data.count,
            textEncodingName: nil
          )
        )
      }
    )
    let request = try XCTUnwrap(
      NativeImageRequest(
        sourceURL: URL(string: "https://cdn.shopify.com/scale-stable.png"),
        pixelWidth: 256,
        backgroundTreatment: .whiteBackgroundToAlphaPreservingCanvas
      )
    )

    let image = try await pipeline.image(for: request)

    XCTAssertEqual(image.cgImage.width, 256)
    XCTAssertEqual(image.cgImage.height, 256)
    XCTAssertEqual(pixel(in: image.cgImage, x: 0, y: 0).alpha, 0)
    XCTAssertGreaterThan(pixel(in: image.cgImage, x: 128, y: 128).alpha, 0)
  }
}

private func makeNearWhiteProductPNG(width: Int, height: Int) throws -> Data {
  let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
  let bytesPerRow = width * 4
  var pixels = [UInt8](repeating: 255, count: bytesPerRow * height)

  for y in 5 ..< 11 {
    for x in 5 ..< 11 {
      let offset = y * bytesPerRow + x * 4
      let edge = x == 5 || x == 10 || y == 5 || y == 10
      let value: UInt8 = edge ? 249 : 232
      pixels[offset] = value
      pixels[offset + 1] = value
      pixels[offset + 2] = value
      pixels[offset + 3] = 255
    }
  }

  guard
    let provider = CGDataProvider(data: Data(pixels) as CFData),
    let image = CGImage(
      width: width,
      height: height,
      bitsPerComponent: 8,
      bitsPerPixel: 32,
      bytesPerRow: bytesPerRow,
      space: colorSpace,
      bitmapInfo: CGBitmapInfo(
        rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
      ),
      provider: provider,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )
  else {
    throw NativeImagePipelineError.decodeFailed
  }

  let output = NSMutableData()
  guard
    let destination = CGImageDestinationCreateWithData(
      output,
      UTType.png.identifier as CFString,
      1,
      nil
    )
  else {
    throw NativeImagePipelineError.decodeFailed
  }

  CGImageDestinationAddImage(destination, image, nil)
  guard CGImageDestinationFinalize(destination) else {
    throw NativeImagePipelineError.decodeFailed
  }
  return output as Data
}

private func makeWarmWhiteCanvasPNG(
  width: Int,
  height: Int,
  foreground: CGRect,
  foregroundColor: (UInt8, UInt8, UInt8, UInt8)
) throws -> Data {
  let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
  let bytesPerRow = width * 4
  var pixels = [UInt8](repeating: 0, count: bytesPerRow * height)

  for y in 0 ..< height {
    for x in 0 ..< width {
      let offset = y * bytesPerRow + x * 4
      let isForeground = foreground.contains(
        CGPoint(x: CGFloat(x), y: CGFloat(y))
      )
      if isForeground {
        pixels[offset] = foregroundColor.0
        pixels[offset + 1] = foregroundColor.1
        pixels[offset + 2] = foregroundColor.2
        pixels[offset + 3] = foregroundColor.3
      } else {
        pixels[offset] = 248
        pixels[offset + 1] = 247
        pixels[offset + 2] = 246
        pixels[offset + 3] = 255
      }
    }
  }

  guard
    let provider = CGDataProvider(data: Data(pixels) as CFData),
    let image = CGImage(
      width: width,
      height: height,
      bitsPerComponent: 8,
      bitsPerPixel: 32,
      bytesPerRow: bytesPerRow,
      space: colorSpace,
      bitmapInfo: CGBitmapInfo(
        rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
      ),
      provider: provider,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )
  else {
    throw NativeImagePipelineError.decodeFailed
  }

  let output = NSMutableData()
  guard
    let destination = CGImageDestinationCreateWithData(
      output,
      UTType.png.identifier as CFString,
      1,
      nil
    )
  else {
    throw NativeImagePipelineError.decodeFailed
  }
  CGImageDestinationAddImage(destination, image, nil)
  guard CGImageDestinationFinalize(destination) else {
    throw NativeImagePipelineError.decodeFailed
  }
  return output as Data
}

private func makeComposedArtworkPNG(width: Int, height: Int) throws -> Data {
  let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
  let bytesPerRow = width * 4
  var pixels = [UInt8](repeating: 0, count: bytesPerRow * height)

  for y in 0 ..< height {
    for x in 0 ..< width {
      let offset = y * bytesPerRow + x * 4
      let diagonal = (x + y) % 3
      switch diagonal {
      case 0:
        pixels[offset] = 28
        pixels[offset + 1] = 120
        pixels[offset + 2] = 214
      case 1:
        pixels[offset] = 248
        pixels[offset + 1] = 202
        pixels[offset + 2] = 70
      default:
        pixels[offset] = 214
        pixels[offset + 1] = 78
        pixels[offset + 2] = 118
      }
      pixels[offset + 3] = 255
    }
  }

  guard
    let provider = CGDataProvider(data: Data(pixels) as CFData),
    let image = CGImage(
      width: width,
      height: height,
      bitsPerComponent: 8,
      bitsPerPixel: 32,
      bytesPerRow: bytesPerRow,
      space: colorSpace,
      bitmapInfo: CGBitmapInfo(
        rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
      ),
      provider: provider,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )
  else {
    throw NativeImagePipelineError.decodeFailed
  }

  let output = NSMutableData()
  guard
    let destination = CGImageDestinationCreateWithData(
      output,
      UTType.png.identifier as CFString,
      1,
      nil
    )
  else {
    throw NativeImagePipelineError.decodeFailed
  }
  CGImageDestinationAddImage(destination, image, nil)
  guard CGImageDestinationFinalize(destination) else {
    throw NativeImagePipelineError.decodeFailed
  }
  return output as Data
}

private func makePNG(
  width: Int,
  height: Int,
  foreground: CGRect,
  foregroundColor: (UInt8, UInt8, UInt8, UInt8)
) throws -> Data {
  let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
  let bytesPerRow = width * 4
  var pixels = [UInt8](repeating: 255, count: bytesPerRow * height)

  for y in 0 ..< height {
    for x in 0 ..< width where foreground.contains(CGPoint(x: x, y: y)) {
      let offset = y * bytesPerRow + x * 4
      pixels[offset] = foregroundColor.0
      pixels[offset + 1] = foregroundColor.1
      pixels[offset + 2] = foregroundColor.2
      pixels[offset + 3] = foregroundColor.3
    }
  }

  guard
    let provider = CGDataProvider(data: Data(pixels) as CFData),
    let image = CGImage(
      width: width,
      height: height,
      bitsPerComponent: 8,
      bitsPerPixel: 32,
      bytesPerRow: bytesPerRow,
      space: colorSpace,
      bitmapInfo: CGBitmapInfo(
        rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
      ),
      provider: provider,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )
  else {
    throw NativeImagePipelineError.decodeFailed
  }

  let output = NSMutableData()
  guard
    let destination = CGImageDestinationCreateWithData(
      output,
      UTType.png.identifier as CFString,
      1,
      nil
    )
  else {
    throw NativeImagePipelineError.decodeFailed
  }

  CGImageDestinationAddImage(destination, image, nil)
  guard CGImageDestinationFinalize(destination) else {
    throw NativeImagePipelineError.decodeFailed
  }
  return output as Data
}

private func pixel(
  in image: CGImage,
  x: Int,
  y: Int
) -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
  guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
    return (0, 0, 0, 0)
  }

  let bytesPerRow = image.width * 4
  var pixels = [UInt8](repeating: 0, count: bytesPerRow * image.height)
  let rendered = pixels.withUnsafeMutableBytes { rawBuffer -> Bool in
    guard
      let baseAddress = rawBuffer.baseAddress,
      let context = CGContext(
        data: baseAddress,
        width: image.width,
        height: image.height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      )
    else {
      return false
    }
    context.draw(
      image,
      in: CGRect(
        x: 0,
        y: 0,
        width: image.width,
        height: image.height
      )
    )
    return true
  }

  guard rendered else {
    return (0, 0, 0, 0)
  }

  let offset = y * bytesPerRow + x * 4
  return (
    pixels[offset],
    pixels[offset + 1],
    pixels[offset + 2],
    pixels[offset + 3]
  )
}

private actor ImageNetworkStub {
  let data: Data
  let delayNanoseconds: UInt64

  private(set) var requestCount = 0
  private(set) var lastCachePolicy: URLRequest.CachePolicy?
  private(set) var cancellationCount = 0

  init(
    data: Data,
    delayNanoseconds: UInt64
  ) {
    self.data = data
    self.delayNanoseconds = delayNanoseconds
  }

  func load(_ request: URLRequest) async throws -> (Data, URLResponse) {
    requestCount += 1
    lastCachePolicy = request.cachePolicy
    do {
      try await Task.sleep(nanoseconds: delayNanoseconds)
    } catch is CancellationError {
      cancellationCount += 1
      throw CancellationError()
    }

    return (
      data,
      URLResponse(
        url: request.url!,
        mimeType: "image/png",
        expectedContentLength: data.count,
        textEncodingName: nil
      )
    )
  }
}
