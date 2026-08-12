import CoreGraphics
import Foundation
import ImageIO

enum NativeImageBackgroundTreatment: Hashable, Sendable {
  case none
  case whiteBackgroundToAlpha
  /// Detects a light, low-variance catalogue canvas per image and removes
  /// only the connected canvas. Composed/photographic artwork is left intact.
  case adaptiveProductBackgroundToAlpha
  /// Removes a connected white catalogue matte but keeps the source canvas.
  /// Keeping the canvas preserves the light/dark product scale and avoids
  /// making the same SKU appear zoomed when Dark Mode is enabled.
  case whiteBackgroundToAlphaPreservingCanvas
  case monochromeToAlpha
}

struct NativeImageRequest: Hashable, Sendable {
  static let minimumPixelWidth = 32
  static let maximumPixelWidth = 2_400
  static let maximumDecodeDimension = 4_096

  let url: URL
  let maximumPixelDimension: Int
  let backgroundTreatment: NativeImageBackgroundTreatment

  init?(
    sourceURL: URL?,
    pixelWidth: Int,
    aspectRatio: CGFloat = 1,
    backgroundTreatment: NativeImageBackgroundTreatment = .none
  ) {
    guard let sourceURL,
      let optimizedURL = Self.optimizedURL(
        sourceURL,
        pixelWidth: pixelWidth
      )
    else {
      return nil
    }

    let boundedWidth = Self.boundedPixelWidth(pixelWidth)
    let safeAspectRatio = max(0.1, min(aspectRatio, 10))
    let expectedHeight = Int(
      ceil(CGFloat(boundedWidth) / safeAspectRatio)
    )

    url = optimizedURL
    maximumPixelDimension = min(
      max(boundedWidth, expectedHeight),
      Self.maximumDecodeDimension
    )
    self.backgroundTreatment = backgroundTreatment
  }

  static func optimizedURL(
    _ sourceURL: URL,
    pixelWidth: Int
  ) -> URL? {
    guard sourceURL.scheme?.lowercased() == "https",
      sourceURL.host != nil
    else {
      return nil
    }

    guard isVerifiedShopifyImageURL(sourceURL) else {
      return sourceURL
    }

    let boundedWidth = boundedPixelWidth(pixelWidth)
    guard
      let optimized = ShopifyAsset.url(
        from: sourceURL.absoluteString,
        width: boundedWidth
      ),
      optimized.scheme?.lowercased() == "https",
      optimized.host?.lowercased() == sourceURL.host?.lowercased()
    else {
      return nil
    }

    let widthItems = URLComponents(
      url: optimized,
      resolvingAgainstBaseURL: false
    )?.queryItems?.filter { $0.name == "width" }

    guard widthItems?.count == 1,
      widthItems?.first?.value == String(boundedWidth)
    else {
      return nil
    }

    return optimized
  }

  static func boundedPixelWidth(_ pixelWidth: Int) -> Int {
    min(
      max(pixelWidth, minimumPixelWidth),
      maximumPixelWidth
    )
  }

  private static func isVerifiedShopifyImageURL(_ url: URL) -> Bool {
    guard let host = url.host?.lowercased() else {
      return false
    }

    if ShopifyAsset.isPrimaryStorefrontURL(url) {
      return url.path.lowercased().contains("/cdn/shop/")
    }

    return host == "cdn.shopify.com"
      || host.hasSuffix(".cdn.shopify.com")
      || host == "cdn.shopifycdn.net"
      || host.hasSuffix(".cdn.shopifycdn.net")
      || (host.hasSuffix(".myshopify.com")
        && url.path.lowercased().contains("/cdn/shop/"))
  }
}

struct PreparedNativeImage: Sendable {
  let cgImage: CGImage

  var memoryCost: Int {
    let bytesPerPixel = 4
    let (pixelCount, overflow) = cgImage.width.multipliedReportingOverflow(
      by: cgImage.height
    )
    guard !overflow else { return Int.max }

    let (cost, costOverflow) = pixelCount.multipliedReportingOverflow(
      by: bytesPerPixel
    )
    return costOverflow ? Int.max : cost
  }
}

actor NativeImagePipeline {
  typealias NetworkLoader =
    @Sendable (URLRequest) async throws -> (Data, URLResponse)

  static let shared = NativeImagePipeline()

  private final class CacheBox {
    let image: PreparedNativeImage

    init(_ image: PreparedNativeImage) {
      self.image = image
    }
  }

  private struct InFlight {
    let task: Task<PreparedNativeImage, Error>
    var subscribers: Set<UUID>
  }

  private static let maximumResponseBytes = 24 * 1_024 * 1_024

  private let memoryCache = NSCache<NSString, CacheBox>()
  private let networkLoader: NetworkLoader
  private var inFlight: [NativeImageRequest: InFlight] = [:]

  init(
    memoryCostLimit: Int = 64 * 1_024 * 1_024,
    memoryCountLimit: Int = 180,
    urlCache: URLCache? = nil,
    networkLoader: NetworkLoader? = nil
  ) {
    memoryCache.totalCostLimit = memoryCostLimit
    memoryCache.countLimit = memoryCountLimit

    if let networkLoader {
      self.networkLoader = networkLoader
    } else {
      let resolvedCache =
        urlCache
        ?? URLCache(
          memoryCapacity: 48 * 1_024 * 1_024,
          diskCapacity: 256 * 1_024 * 1_024,
          diskPath: "com.beautyontapp.native-images"
        )
      let configuration = URLSessionConfiguration.default
      configuration.urlCache = resolvedCache
      configuration.requestCachePolicy = .useProtocolCachePolicy
      configuration.waitsForConnectivity = true
      configuration.httpMaximumConnectionsPerHost = 6
      let session = URLSession(configuration: configuration)

      self.networkLoader = { request in
        try await session.data(for: request)
      }
    }
  }

  func image(for request: NativeImageRequest) async throws
    -> PreparedNativeImage
  {
    if let cached = cachedImage(for: request) {
      return cached
    }

    let subscriberID = UUID()
    let task: Task<PreparedNativeImage, Error>

    if var existing = inFlight[request] {
      existing.subscribers.insert(subscriberID)
      inFlight[request] = existing
      task = existing.task
    } else {
      let loader = networkLoader
      task = Task(priority: .utility) {
        var urlRequest = URLRequest(
          url: request.url,
          cachePolicy: .returnCacheDataElseLoad,
          timeoutInterval: 30
        )
        urlRequest.setValue(
          "image/avif,image/webp,image/*,*/*;q=0.5",
          forHTTPHeaderField: "Accept"
        )

        let (data, response) = try await loader(urlRequest)
        try Task.checkCancellation()
        try Self.validate(data: data, response: response)
        return try Self.decode(
          data: data,
          maximumPixelDimension: request.maximumPixelDimension,
          backgroundTreatment: request.backgroundTreatment
        )
      }
      inFlight[request] = InFlight(
        task: task,
        subscribers: [subscriberID]
      )
    }

    return try await withTaskCancellationHandler {
      do {
        let preparedImage = try await task.value
        try Task.checkCancellation()
        complete(
          request: request,
          subscriberID: subscriberID,
          preparedImage: preparedImage
        )
        return preparedImage
      } catch {
        complete(
          request: request,
          subscriberID: subscriberID,
          preparedImage: nil
        )
        throw error
      }
    } onCancel: {
      Task {
        await self.cancelSubscriber(
          subscriberID,
          for: request
        )
      }
    }
  }

  func removeAllCachedImages() {
    memoryCache.removeAllObjects()
  }

  func isImageCached(for request: NativeImageRequest) -> Bool {
    cachedImage(for: request) != nil
  }

  private func cachedImage(
    for request: NativeImageRequest
  ) -> PreparedNativeImage? {
    memoryCache.object(
      forKey: cacheKey(for: request) as NSString
    )?.image
  }

  private func complete(
    request: NativeImageRequest,
    subscriberID: UUID,
    preparedImage: PreparedNativeImage?
  ) {
    if let preparedImage {
      memoryCache.setObject(
        CacheBox(preparedImage),
        forKey: cacheKey(for: request) as NSString,
        cost: min(preparedImage.memoryCost, Int.max)
      )
    }

    guard var existing = inFlight[request] else {
      return
    }

    existing.subscribers.remove(subscriberID)
    if existing.subscribers.isEmpty {
      inFlight.removeValue(forKey: request)
    } else {
      inFlight[request] = existing
    }
  }

  private func cancelSubscriber(
    _ subscriberID: UUID,
    for request: NativeImageRequest
  ) {
    guard var existing = inFlight[request] else {
      return
    }

    existing.subscribers.remove(subscriberID)
    if existing.subscribers.isEmpty {
      existing.task.cancel()
      inFlight.removeValue(forKey: request)
    } else {
      inFlight[request] = existing
    }
  }

  private func cacheKey(for request: NativeImageRequest) -> String {
    "\(request.url.absoluteString)|\(request.maximumPixelDimension)|\(request.backgroundTreatment)"
  }

  private static func validate(
    data: Data,
    response: URLResponse
  ) throws {
    guard !data.isEmpty,
      data.count <= maximumResponseBytes
    else {
      throw NativeImagePipelineError.invalidResponse
    }

    if let httpResponse = response as? HTTPURLResponse {
      guard (200...299).contains(httpResponse.statusCode)
      else {
        throw NativeImagePipelineError.httpStatus(
          httpResponse.statusCode
        )
      }
    }

    if let mimeType = response.mimeType?.lowercased(),
      !mimeType.hasPrefix("image/"),
      mimeType != "application/octet-stream"
    {
      throw NativeImagePipelineError.invalidContentType
    }
  }

  private static func decode(
    data: Data,
    maximumPixelDimension: Int,
    backgroundTreatment: NativeImageBackgroundTreatment
  ) throws -> PreparedNativeImage {
    let sourceOptions: CFDictionary =
      [
        kCGImageSourceShouldCache: false
      ] as CFDictionary

    guard
      let source = CGImageSourceCreateWithData(
        data as CFData,
        sourceOptions
      )
    else {
      throw NativeImagePipelineError.decodeFailed
    }

    let thumbnailOptions: CFDictionary =
      [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceThumbnailMaxPixelSize: maximumPixelDimension,
      ] as CFDictionary

    guard
      let cgImage = CGImageSourceCreateThumbnailAtIndex(
        source,
        0,
        thumbnailOptions
      )
    else {
      throw NativeImagePipelineError.decodeFailed
    }

    guard backgroundTreatment != .none else {
      return PreparedNativeImage(cgImage: cgImage)
    }

    return PreparedNativeImage(
      cgImage: try makeTransparent(
        cgImage: cgImage,
        treatment: backgroundTreatment
      )
    )
  }

  private static func makeTransparent(
    cgImage: CGImage,
    treatment: NativeImageBackgroundTreatment
  ) throws -> CGImage {
    let width = cgImage.width
    let height = cgImage.height
    guard width > 0, height > 0,
      let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
    else {
      throw NativeImagePipelineError.decodeFailed
    }

    let bytesPerRow = width * 4
    var pixels = [UInt8](repeating: 0, count: bytesPerRow * height)
    let byteCount = bytesPerRow * height
    let pixelCount = width * height
    var rendered = false
    // A catalogue image is not necessarily a cutout. Some Shopify images are
    // full-bleed compositions or contain white packaging that touches the
    // crop edge. If the mask does not describe a clearly bounded foreground,
    // keep the source image intact rather than erasing product pixels.
    var keepOriginalImage = false
    var transparentCropRect: CGRect?

    pixels.withUnsafeMutableBytes { rawBuffer in
      guard let baseAddress = rawBuffer.baseAddress,
        let context = CGContext(
          data: baseAddress,
          width: width,
          height: height,
          bitsPerComponent: 8,
          bytesPerRow: bytesPerRow,
          space: colorSpace,
          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
      else {
        return
      }
      let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)

      context.interpolationQuality = .high
      context.draw(
        cgImage,
        in: CGRect(x: 0, y: 0, width: width, height: height)
      )
      rendered = true

      switch treatment {
      case .none:
        break
      case .monochromeToAlpha:
        // Logo exports are not consistent: some use white, some use a very
        // light gray, and some use a JPEG white background. Deriving alpha
        // from absolute darkness leaves those gray backgrounds as visible
        // rectangles on a dark surface. Sample the border, remove only the
        // connected background region, and keep the remaining mark as a
        // white alpha mask for a stable appearance in Dark Mode.
        var edgeRed = 0.0
        var edgeGreen = 0.0
        var edgeBlue = 0.0
        var edgeCount = 0.0

        func sampleEdge(_ pixelIndex: Int) {
          let offset = pixelIndex * 4
          guard buffer[offset + 3] > 2 else { return }
          edgeRed += Double(buffer[offset])
          edgeGreen += Double(buffer[offset + 1])
          edgeBlue += Double(buffer[offset + 2])
          edgeCount += 1
        }

        for x in 0 ..< width {
          sampleEdge(x)
          sampleEdge((height - 1) * width + x)
        }
        if height > 2 {
          for y in 1 ..< (height - 1) {
            sampleEdge(y * width)
            sampleEdge(y * width + (width - 1))
          }
        }

        guard edgeCount > 0 else {
          for offset in stride(from: 0, to: byteCount, by: 4) {
            let alpha = buffer[offset + 3]
            buffer[offset] = alpha
            buffer[offset + 1] = alpha
            buffer[offset + 2] = alpha
          }
          break
        }

        let backgroundRed = edgeRed / edgeCount
        let backgroundGreen = edgeGreen / edgeCount
        let backgroundBlue = edgeBlue / edgeCount
        let backgroundSpread = max(
          abs(backgroundRed - backgroundGreen),
          max(
            abs(backgroundRed - backgroundBlue),
            abs(backgroundGreen - backgroundBlue)
          )
        )
        let tolerance = max(24.0, backgroundSpread + 18.0)
        var background = [UInt8](repeating: 0, count: pixelCount)
        var queue: [Int] = []
        queue.reserveCapacity(width * 2 + height * 2)

        func isConnectedBackground(_ pixelIndex: Int) -> Bool {
          let offset = pixelIndex * 4
          guard buffer[offset + 3] > 2 else { return true }
          let red = Double(buffer[offset])
          let green = Double(buffer[offset + 1])
          let blue = Double(buffer[offset + 2])
          let maxChannel = max(red, max(green, blue))
          let minChannel = min(red, min(green, blue))
          let channelSpread = maxChannel - minChannel
          guard channelSpread <= max(32.0, backgroundSpread + 22.0) else {
            return false
          }
          return max(
            abs(red - backgroundRed),
            max(
              abs(green - backgroundGreen),
              abs(blue - backgroundBlue)
            )
          ) <= tolerance
        }

        func seed(_ pixelIndex: Int) {
          guard background[pixelIndex] == 0,
            isConnectedBackground(pixelIndex)
          else {
            return
          }
          background[pixelIndex] = 1
          queue.append(pixelIndex)
        }

        for x in 0 ..< width {
          seed(x)
          seed((height - 1) * width + x)
        }
        if height > 2 {
          for y in 1 ..< (height - 1) {
            seed(y * width)
            seed(y * width + (width - 1))
          }
        }

        var head = 0
        while head < queue.count {
          let pixelIndex = queue[head]
          head += 1
          let x = pixelIndex % width
          let y = pixelIndex / width

          if x > 0 { seed(pixelIndex - 1) }
          if x + 1 < width { seed(pixelIndex + 1) }
          if y > 0 { seed(pixelIndex - width) }
          if y + 1 < height { seed(pixelIndex + width) }
        }

        for pixelIndex in 0 ..< pixelCount {
          let offset = pixelIndex * 4
          guard background[pixelIndex] == 0 else {
            buffer[offset] = 0
            buffer[offset + 1] = 0
            buffer[offset + 2] = 0
            buffer[offset + 3] = 0
            continue
          }

          // The bitmap is premultiplied RGBA. Keep every non-background
          // logo pixel as a white, premultiplied alpha pixel. This preserves
          // intentional interior shapes (for example a badge inside a logo)
          // while removing only the outer canvas.
          let alpha = buffer[offset + 3]
          buffer[offset] = alpha
          buffer[offset + 1] = alpha
          buffer[offset + 2] = alpha
        }
      case .whiteBackgroundToAlpha,
        .adaptiveProductBackgroundToAlpha,
        .whiteBackgroundToAlphaPreservingCanvas:
        var background = [UInt8](repeating: 0, count: pixelCount)
        var queue: [Int] = []
        queue.reserveCapacity(width * 2 + height * 2)

        // Product photography is not uniform: one SKU may use a pure-white
        // canvas, another a warm compressed white, and another a light-grey
        // studio matte. Estimate the edge colour for the adaptive treatment
        // instead of applying one global white threshold to every image.
        let edgePixels: [(red: Int, green: Int, blue: Int)] = {
          var samples: [(red: Int, green: Int, blue: Int)] = []
          samples.reserveCapacity((width + height) * 2)

          func append(_ pixelIndex: Int) {
            let offset = pixelIndex * 4
            guard buffer[offset + 3] > 0 else { return }
            samples.append(
              (
                red: Int(buffer[offset]),
                green: Int(buffer[offset + 1]),
                blue: Int(buffer[offset + 2])
              )
            )
          }

          for x in 0 ..< width {
            append(x)
            if height > 1 { append((height - 1) * width + x) }
          }
          if height > 2 {
            for y in 1 ..< (height - 1) {
              append(y * width)
              if width > 1 { append(y * width + (width - 1)) }
            }
          }
          return samples
        }()

        let edgeAverage: (red: Int, green: Int, blue: Int) = {
          guard !edgePixels.isEmpty else { return (255, 255, 255) }
          let totals = edgePixels.reduce(into: (red: 0, green: 0, blue: 0)) {
            $0.red += $1.red
            $0.green += $1.green
            $0.blue += $1.blue
          }
          return (
            red: totals.red / edgePixels.count,
            green: totals.green / edgePixels.count,
            blue: totals.blue / edgePixels.count
          )
        }()

        let adaptiveEdgeIsCatalogueCanvas: Bool = {
          guard treatment == .adaptiveProductBackgroundToAlpha,
            !edgePixels.isEmpty
          else {
            return false
          }

          let brightNeutralSamples = edgePixels.filter { sample in
            let minimum = min(sample.red, min(sample.green, sample.blue))
            let maximum = max(sample.red, max(sample.green, sample.blue))
            return minimum >= 210 && maximum - minimum <= 28
          }
          let neutralRatio = Double(brightNeutralSamples.count)
            / Double(edgePixels.count)
          let averageMinimum = min(
            edgeAverage.red,
            min(edgeAverage.green, edgeAverage.blue)
          )
          return neutralRatio >= 0.78 && averageMinimum >= 210
        }()

        func isLightNeutral(_ pixelIndex: Int) -> Bool {
          let offset = pixelIndex * 4
          let red = Int(buffer[offset])
          let green = Int(buffer[offset + 1])
          let blue = Int(buffer[offset + 2])
          let minimum = min(red, min(green, blue))
          let maximum = max(red, max(green, blue))
          if adaptiveEdgeIsCatalogueCanvas {
            // Stay conservative around white packaging. The first adaptive
            // pass used a 205 threshold and entered the bottles/tubes because
            // their matte-white pixels were indistinguishable from the light
            // catalogue canvas. Adaptive mode still decides per image whether
            // a canvas is eligible, but the connected-fill threshold matches
            // the proven white-background path so the product itself remains
            // opaque on a dark card.
            let distance = max(
              abs(red - edgeAverage.red),
              max(
                abs(green - edgeAverage.green),
                abs(blue - edgeAverage.blue)
              )
            )
            return minimum >= 246
              && maximum - minimum <= 24
              && distance <= 18
          }
          // Keep the threshold conservative. Product photography commonly
          // contains near-white packaging and soft antialiased edges; a broad
          // flood-fill threshold can enter the product and leave transparent
          // holes that render as black gaps on a dark card.
          // Shopify's JPEG/WebP derivatives frequently turn a white source
          // canvas into a very slightly warm 246–249 matte. Treat that narrow
          // range as canvas too; the near-foreground guard below still keeps
          // the edge of a white product from being flood-filled away.
          return minimum >= 246 && maximum - minimum <= 24
        }

        func isNearForeground(_ pixelIndex: Int) -> Bool {
          let x = pixelIndex % width
          let y = pixelIndex / width

          func isLightNeutralOrOutside(_ neighbour: Int) -> Bool {
            guard neighbour >= 0, neighbour < pixelCount else { return true }
            return isLightNeutral(neighbour)
          }

          // Preserve the established one-pixel matte feather for the legacy
          // white-background treatment. The wider guard is only needed by
          // the adaptive path, which is intentionally more defensive around
          // white packaging.
          if treatment != .adaptiveProductBackgroundToAlpha {
            if x > 0, !isLightNeutralOrOutside(pixelIndex - 1) { return true }
            if x + 1 < width, !isLightNeutralOrOutside(pixelIndex + 1) {
              return true
            }
            if y > 0, !isLightNeutralOrOutside(pixelIndex - width) {
              return true
            }
            if y + 1 < height,
              !isLightNeutralOrOutside(pixelIndex + width)
            {
              return true
            }
            return false
          }

          // White bottles, tubes and labels are often connected to the
          // source matte by anti-aliased pixels. A one-pixel check lets the
          // flood fill cross that bridge and leaves holes in the packaging.
          // Protect a small neighbourhood around any non-neutral foreground
          // pixel instead. This costs only a bounded 7x7 inspection per seed
          // and keeps the edge of the actual product fully opaque.
          for offsetY in -3 ... 3 {
            for offsetX in -3 ... 3 {
              guard offsetX != 0 || offsetY != 0 else { continue }
              let neighbourX = x + offsetX
              let neighbourY = y + offsetY
              guard
                neighbourX >= 0,
                neighbourX < width,
                neighbourY >= 0,
                neighbourY < height
              else {
                continue
              }

              let neighbour = neighbourY * width + neighbourX
              if !isLightNeutralOrOutside(neighbour) {
                return true
              }
            }
          }

          return false
        }

        func seed(_ pixelIndex: Int) {
          guard background[pixelIndex] == 0,
            isLightNeutral(pixelIndex),
            !isNearForeground(pixelIndex)
          else {
            return
          }
          background[pixelIndex] = 1
          queue.append(pixelIndex)
        }

        for x in 0 ..< width {
          seed(x)
          seed((height - 1) * width + x)
        }
        for y in 0 ..< height {
          seed(y * width)
          seed(y * width + (width - 1))
        }

        var head = 0
        while head < queue.count {
          let pixelIndex = queue[head]
          head += 1
          let x = pixelIndex % width
          let y = pixelIndex / width

          if x > 0 { seed(pixelIndex - 1) }
          if x + 1 < width { seed(pixelIndex + 1) }
          if y > 0 { seed(pixelIndex - width) }
          if y + 1 < height { seed(pixelIndex + width) }
        }

        var backgroundPixelCount = 0
        var foregroundPixelCount = 0
        var foregroundMinX = width
        var foregroundMinY = height
        var foregroundMaxX = -1
        var foregroundMaxY = -1

        for pixelIndex in 0 ..< pixelCount {
          if background[pixelIndex] == 1 {
            backgroundPixelCount += 1
            continue
          }

          foregroundPixelCount += 1
          let x = pixelIndex % width
          let y = pixelIndex / width
          foregroundMinX = min(foregroundMinX, x)
          foregroundMinY = min(foregroundMinY, y)
          foregroundMaxX = max(foregroundMaxX, x)
          foregroundMaxY = max(foregroundMaxY, y)
        }

        let minimumBackgroundPixels = max(16, pixelCount / 10)
        let minimumForegroundPixels = max(16, pixelCount / 100)
        let foregroundTouchesEdge = foregroundMinX <= 1
          || foregroundMinY <= 1
          || foregroundMaxX >= width - 2
          || foregroundMaxY >= height - 2
        let foregroundConsumesCanvas = foregroundPixelCount
          >= Int(Double(pixelCount) * 0.90)

        guard
          backgroundPixelCount >= minimumBackgroundPixels,
          foregroundPixelCount >= minimumForegroundPixels,
          !foregroundTouchesEdge,
          !foregroundConsumesCanvas
        else {
          keepOriginalImage = true
          break
        }

        // Product exports often reserve a large, empty square around a
        // relatively small item. Once the white matte is removed, that
        // unused canvas becomes the reason otherwise identical cards appear
        // to have different image sizes. Trim it only for the validated,
        // bounded white-background case; full-bleed/composed artwork keeps
        // its original canvas.
        if width >= 128, height >= 128 {
          let foregroundRect = CGRect(
            x: foregroundMinX,
            y: foregroundMinY,
            width: foregroundMaxX - foregroundMinX + 1,
            height: foregroundMaxY - foregroundMinY + 1
          )
          let padding = max(
            6.0,
            ceil(max(foregroundRect.width, foregroundRect.height) * 0.08)
          )
          var cropRect = foregroundRect.insetBy(dx: -padding, dy: -padding)
          let targetAspect = CGFloat(width) / CGFloat(height)
          let cropAspect = cropRect.width / max(cropRect.height, 1)

          if cropAspect > targetAspect {
            let desiredHeight = cropRect.width / targetAspect
            let expansion = desiredHeight - cropRect.height
            cropRect.origin.y -= expansion / 2
            cropRect.size.height = desiredHeight
          } else {
            let desiredWidth = cropRect.height * targetAspect
            let expansion = desiredWidth - cropRect.width
            cropRect.origin.x -= expansion / 2
            cropRect.size.width = desiredWidth
          }

          let canvas = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
          )
          cropRect = cropRect.intersection(canvas)
          let integerCrop = CGRect(
            x: floor(cropRect.minX),
            y: floor(cropRect.minY),
            width: floor(cropRect.width),
            height: floor(cropRect.height)
          )

          if integerCrop.width >= 32, integerCrop.height >= 32 {
            transparentCropRect = integerCrop
          }
        }

        // Shopify's catalogue cut-outs are frequently JPEGs composited on a
        // white matte. The flood fill correctly removes the connected canvas,
        // but the first antialiased product pixels still contain a little of
        // that white matte. On a dark card those pixels read as a bright halo.
        // Feather only the near-white boundary ring; interior product pixels
        // (including white packaging) remain fully opaque.
        func touchesBackground(_ pixelIndex: Int) -> Bool {
          let x = pixelIndex % width
          let y = pixelIndex / width

          // Include the one-pixel pure-white ring that the conservative flood
          // fill leaves around near-white packaging. Looking two pixels out
          // gives us a clean matte edge without touching product interiors.
          for offsetY in -2 ... 2 {
            for offsetX in -2 ... 2 {
              guard offsetX != 0 || offsetY != 0 else { continue }
              let neighbourX = x + offsetX
              let neighbourY = y + offsetY
              guard
                neighbourX >= 0,
                neighbourX < width,
                neighbourY >= 0,
                neighbourY < height
              else {
                continue
              }

              if background[neighbourY * width + neighbourX] == 1 {
                return true
              }
            }
          }

          return false
        }

        func matteEdgeAlpha(
          red: UInt8,
          green: UInt8,
          blue: UInt8
        ) -> UInt8? {
          let minimum = min(Int(red), min(Int(green), Int(blue)))
          let maximum = max(Int(red), max(Int(green), Int(blue)))
          guard minimum >= 225, maximum - minimum <= 42 else {
            return nil
          }

          // A white matte contributes the brightest part of an edge. Keep a
          // small minimum alpha so white packaging stays present, then let
          // darker edge pixels become progressively more opaque.
          let brightness = (Int(red) + Int(green) + Int(blue)) / 3
          let edgeOpacity = min(
            1.0,
            max(0.14, Double(255 - brightness) / 32.0)
          )
          return UInt8(edgeOpacity * 255.0)
        }

        for pixelIndex in 0 ..< background.count {
          guard background[pixelIndex] == 1 else { continue }
          let offset = pixelIndex * 4
          // Zero the premultiplied colour as well as alpha. Some renderers
          // preserve RGB in fully transparent pixels and would otherwise
          // show the original white rectangle on a dark card.
          buffer[offset] = 0
          buffer[offset + 1] = 0
          buffer[offset + 2] = 0
          buffer[offset + 3] = 0
        }

        for pixelIndex in 0 ..< pixelCount {
          guard background[pixelIndex] == 0,
            // Adaptive mode is deliberately non-destructive: after removing
            // the connected matte, keep every remaining product pixel fully
            // opaque. Feathering a near-white ring is attractive for simple
            // cut-outs but can make white packaging look translucent on a
            // dark surface, so the adaptive path leaves that ring intact.
            treatment != .adaptiveProductBackgroundToAlpha,
            touchesBackground(pixelIndex)
          else {
            continue
          }

          let offset = pixelIndex * 4
          guard
            let edgeAlpha = matteEdgeAlpha(
              red: buffer[offset],
              green: buffer[offset + 1],
              blue: buffer[offset + 2]
            )
          else {
            continue
          }

          let sourceAlpha = Double(buffer[offset + 3]) / 255.0
          let alpha = min(sourceAlpha, Double(edgeAlpha) / 255.0)
          let transparentWhite = 1.0 - alpha

          // Remove the known white contribution while retaining premultiplied
          // RGB, which is what the CGContext/CGImage below expects.
          buffer[offset] = UInt8(
            max(
              0,
              min(
                255,
                Double(buffer[offset]) - transparentWhite * 255.0
              )
            )
          )
          buffer[offset + 1] = UInt8(
            max(
              0,
              min(
                255,
                Double(buffer[offset + 1]) - transparentWhite * 255.0
              )
            )
          )
          buffer[offset + 2] = UInt8(
            max(
              0,
              min(
                255,
                Double(buffer[offset + 2]) - transparentWhite * 255.0
              )
            )
          )
          buffer[offset + 3] = UInt8(alpha * 255.0)
        }
      }
    }

    if keepOriginalImage {
      return cgImage
    }

    guard rendered,
      let provider = CGDataProvider(data: Data(pixels) as CFData),
      let output = CGImage(
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
        shouldInterpolate: true,
        intent: .defaultIntent
      )
    else {
      throw NativeImagePipelineError.decodeFailed
    }

    if treatment == .whiteBackgroundToAlpha
      || treatment == .adaptiveProductBackgroundToAlpha,
      let transparentCropRect,
      let cropped = output.cropping(to: transparentCropRect)
    {
      return cropped
    }

    return output
  }
}

enum NativeImagePipelineError: Error, Equatable {
  case invalidResponse
  case httpStatus(Int)
  case invalidContentType
  case decodeFailed
}
