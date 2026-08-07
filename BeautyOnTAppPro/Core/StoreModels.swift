import Foundation

struct Money: Decodable, Equatable, Hashable, Sendable {
    let amount: String
    let currencyCode: String

    var text: String {
        MoneyFormatter.string(shopifyDecimal: amount)
    }
}

enum StoreProductPayloadKind: Equatable, Hashable, Sendable {
    case summary
    case detail
}

struct StoreProduct: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let title: String
    let handle: String
    let onlineStoreURL: URL?
    let descriptionText: String
    let vendor: String
    let productType: String
    let tags: [String]
    let availableForSale: Bool
    let reviewSummary: ProductReviewSummary?
    let variants: [StoreVariant]
    let images: [StoreImage]
    let selectedOrFirstAvailableVariant: StoreVariant?
    let payloadKind: StoreProductPayloadKind

    var firstAvailableVariant: StoreVariant? {
        variants.first(where: \.availableForSale)
            ?? selectedOrFirstAvailableVariant.flatMap { variant in
                variant.availableForSale ? variant : nil
            }
    }

    var displayVariant: StoreVariant? {
        firstAvailableVariant ?? variants.first
    }

    var primaryImageURL: URL? {
        images.first?.url ?? displayVariant?.image?.url
    }

    var priceText: String {
        displayVariant?.price.text ?? ""
    }

    var verifiedOnlineStoreURL: URL? {
        guard let onlineStoreURL,
              ShopifyAsset.isPrimaryStorefrontURL(onlineStoreURL)
        else {
            return nil
        }

        let pathComponents = onlineStoreURL.pathComponents.filter { $0 != "/" }
        guard let productsIndex = pathComponents.firstIndex(of: "products"),
              pathComponents.indices.contains(productsIndex + 1),
              pathComponents[productsIndex + 1]
                  .caseInsensitiveCompare(handle) == .orderedSame
        else {
            return nil
        }
        return onlineStoreURL
    }

    var isBookingProduct: Bool {
        tags.contains(where: { $0.caseInsensitiveCompare("bookeasy") == .orderedSame })
    }

    var hasCompleteDetails: Bool {
        payloadKind == .detail
    }

    var canQuickAdd: Bool {
        !isBookingProduct &&
            variants.count == 1 &&
            variants.first?.availableForSale == true
    }

    var cardSelectionLabel: String {
        let fragranceValues = variants.flatMap(\.selectedOptions)
            .filter {
                $0.name.localizedCaseInsensitiveContains("fragrance")
            }
            .map(\.value)
        let distinctFragrances = Set(
            fragranceValues.map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            }
        )

        return distinctFragrances.count > 1
            ? "Choose fragrance"
            : "Select options"
    }

    func applying(
        reviewSummary: ProductReviewSummary?
    ) -> StoreProduct {
        StoreProduct(
            id: id,
            title: title,
            handle: handle,
            onlineStoreURL: onlineStoreURL,
            descriptionText: descriptionText,
            vendor: vendor,
            productType: productType,
            tags: tags,
            availableForSale: availableForSale,
            reviewSummary: reviewSummary,
            variants: variants,
            images: images,
            selectedOrFirstAvailableVariant: selectedOrFirstAvailableVariant,
            payloadKind: payloadKind
        )
    }
}

struct StoreVariant: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let title: String
    let availableForSale: Bool
    let price: Money
    let compareAtPrice: Money?
    let selectedOptions: [SelectedOption]
    let image: StoreImage?
}

struct SelectedOption: Decodable, Equatable, Hashable, Sendable {
    let name: String
    let value: String
}

struct StoreImage: Identifiable, Equatable, Hashable, Sendable {
    let url: URL
    let altText: String?
    let width: Int?
    let height: Int?

    var id: URL { url }
}

struct StoreMenu: Identifiable, Equatable, Sendable {
    let id: String
    let handle: String
    let title: String
    let items: [StoreMenuItem]
}

struct StoreMenuItem: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let url: URL?
    let resourceID: String?
    let items: [StoreMenuItem]

    var collectionHandle: String? {
        guard let url, url.pathComponents.count >= 3 else { return nil }
        let components = url.pathComponents
        guard components[1] == "collections" else { return nil }
        return components[2]
    }
}

/// A brand entry read from the first-party Brands directory. The collection
/// handle is carried with the label so tapping a brand stays in native
/// navigation without guessing a destination from its name.
struct NativeBrand: Identifiable, Equatable, Hashable, Sendable {
    let name: String
    let handle: String?

    var id: String {
        "\(handle ?? name.lowercased())|\(name.lowercased())"
    }
}

struct StoreCart: Equatable, Sendable {
    let id: String
    let checkoutURL: URL
    let totalQuantity: Int
    let subtotal: Money
    let total: Money
    let lines: [StoreCartLine]
    let note: String?
    let deliveryOptions: [StoreDeliveryOption]

    init(
        id: String,
        checkoutURL: URL,
        totalQuantity: Int,
        subtotal: Money,
        total: Money,
        lines: [StoreCartLine],
        note: String? = nil,
        deliveryOptions: [StoreDeliveryOption] = []
    ) {
        self.id = id
        self.checkoutURL = checkoutURL
        self.totalQuantity = totalQuantity
        self.subtotal = subtotal
        self.total = total
        self.lines = lines
        self.note = note
        self.deliveryOptions = deliveryOptions
    }

    static let empty = StoreCart(
      id: "",
      checkoutURL: ShopifyAsset.shopRoot.appendingPathComponent("checkout"),
        totalQuantity: 0,
        subtotal: Money(amount: "0", currencyCode: "ZAR"),
        total: Money(amount: "0", currencyCode: "ZAR"),
        lines: [],
        note: nil,
      deliveryOptions: []
    )

    func replacingDeliveryOptions(
      _ options: [StoreDeliveryOption]
    ) -> StoreCart {
      StoreCart(
        id: id,
        checkoutURL: checkoutURL,
        totalQuantity: totalQuantity,
        subtotal: subtotal,
        total: total,
        lines: lines,
        note: note,
        deliveryOptions: options
      )
    }
  }

struct StoreCartLine: Identifiable, Equatable, Sendable {
    let id: String
    let quantity: Int
    let merchandise: StoreVariant
    let product: StoreProductSummary
    let cost: Money
    let attributes: [StoreAttribute]

    var bookingReservationID: String? {
      attributes.first(where: { $0.key == "_bookeasy-booking-id" })?.value
    }

    var bookingDetails: [StoreAttribute] {
      let visible = Set(["Date", "Time", "Location", "Team Member"])
      return attributes.filter { visible.contains($0.key) }
    }
}

struct StoreCartInputLine: Equatable, Sendable {
    let merchandiseID: String
    let quantity: Int
    let attributes: [StoreAttribute]

    init(
      merchandiseID: String,
      quantity: Int,
      attributes: [StoreAttribute] = []
    ) {
      self.merchandiseID = merchandiseID
      self.quantity = quantity
      self.attributes = attributes
    }
}

struct StoreAttribute: Codable, Equatable, Hashable, Sendable {
    let key: String
    let value: String
}

struct StoreDeliveryOption: Identifiable, Equatable, Sendable {
    let deliveryGroupID: String
    let handle: String
    let title: String
    let description: String?
    let methodType: String
    let estimatedCost: Money

    var id: String {
        "\(deliveryGroupID)|\(handle)"
    }
}

struct StoreRegion: Identifiable, Equatable, Hashable, Sendable {
    let name: String
    let code: String

    var id: String { code }
}

enum SouthAfricaProvince {
    static let all: [StoreRegion] = [
        StoreRegion(name: "Eastern Cape", code: "EC"),
        StoreRegion(name: "Free State", code: "FS"),
        StoreRegion(name: "Gauteng", code: "GP"),
        StoreRegion(name: "KwaZulu-Natal", code: "KZN"),
        StoreRegion(name: "Limpopo", code: "LP"),
        StoreRegion(name: "Mpumalanga", code: "MP"),
        StoreRegion(name: "North West", code: "NW"),
        StoreRegion(name: "Northern Cape", code: "NC"),
        StoreRegion(name: "Western Cape", code: "WC"),
    ]

    static func name(for code: String) -> String {
        all.first(where: { $0.code == code })?.name ?? code
    }
}

struct StoreProductSummary: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let handle: String
    let vendor: String
}

struct StorefrontPageInfo: Decodable, Equatable, Hashable, Sendable {
    let hasNextPage: Bool
    let endCursor: String?

    static let end = StorefrontPageInfo(hasNextPage: false, endCursor: nil)
}

struct ProductPage: Equatable, Sendable {
    let products: [StoreProduct]
    let pageInfo: StorefrontPageInfo
}

extension Array where Element == StoreProduct {
    func applying(
        reviewSummaries: [String: ProductReviewSummary]
    ) -> [StoreProduct] {
        map { product in
            guard let summary = reviewSummaries[product.handle] else {
                return product
            }
            return product.applying(reviewSummary: summary)
        }
    }
}

struct StoreBlogFeed: Equatable, Hashable, Sendable {
    let id: String
    let title: String
    let handle: String
    let onlineStoreURL: URL?
    let articles: [StoreArticle]
    let pageInfo: StorefrontPageInfo
}

struct StoreArticle: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let title: String
    let handle: String
    let blogHandle: String
    let tags: [String]
    let publishedAt: Date?
    let onlineStoreURL: URL?
    let image: StoreImage?
    let authorName: String?
    let excerptText: String
    let contentText: String
    let contentHTML: String
}

enum ShopifyAsset {
    static let shopRoot = URL(string: "https://beautyontapp.com")!

    static func isPrimaryStorefrontURL(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "https",
              let host = url.host?.lowercased()
        else {
            return false
        }
        return host == "beautyontapp.com" || host == "www.beautyontapp.com"
    }

    static func url(from reference: String?, width: Int? = nil) -> URL? {
        guard var reference, !reference.isEmpty else {
            return nil
        }

        if reference.hasPrefix("//") {
            reference = "https:" + reference
        }

        if reference.hasPrefix("shopify://shop_images/") {
            let filename = String(reference.dropFirst("shopify://shop_images/".count))
            var components = URLComponents(
                url: shopRoot.appendingPathComponent("cdn/shop/files/\(filename)"),
                resolvingAgainstBaseURL: false
            )
            if let width {
                components?.queryItems = [URLQueryItem(name: "width", value: String(width))]
            }
            return components?.url
        }

        guard var components = URLComponents(string: reference) else {
            return nil
        }
        let isShopifyCDN =
            components.host?.contains("shopify") == true ||
            components.path.contains("/cdn/shop/")
        if isShopifyCDN {
            var items = components.queryItems ?? []
            if let width {
                items.removeAll(where: { $0.name == "width" })
                items.append(URLQueryItem(name: "width", value: String(width)))
            }
            if components.path.lowercased().hasSuffix(".svg") {
                items.removeAll(where: { $0.name == "format" })
                items.append(URLQueryItem(name: "format", value: "png"))
            }
            components.queryItems = items
        }
        return components.url
    }
}

extension String {
    var plainTextFromHTML: String {
        replacingOccurrences(
            of: #"(?is)<!--.*?-->|<(script|style)\b[^>]*>.*?</\1\s*>"#,
            with: "",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"(?i)<br\s*/?\s*>"#,
            with: "\n",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"(?i)<li\b[^>]*>"#,
            with: "• ",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"(?i)</li\s*>"#,
            with: "\n",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"(?i)</(?:p|div|h[1-6]|blockquote|section|article|ul|ol|table)\s*>"#,
            with: "\n\n",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"(?i)</tr\s*>"#,
            with: "\n",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"(?i)</(?:td|th)\s*>"#,
            with: "\t",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"(?s)<[^>]+>"#,
            with: "",
            options: .regularExpression
        )
        .decodingLightweightHTMLEntities
        .replacingOccurrences(of: "\u{00A0}", with: " ")
        .replacingOccurrences(
            of: #"\r\n?"#,
            with: "\n",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"[ \t]+"#,
            with: " ",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"[ \t]*\n[ \t]*"#,
            with: "\n",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"\n{3,}"#,
            with: "\n\n",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var decodingLightweightHTMLEntities: String {
        var output = ""
        var cursor = startIndex

        while cursor < endIndex,
              let ampersand = self[cursor...].firstIndex(of: "&")
        {
            output.append(contentsOf: self[cursor..<ampersand])

            let searchEnd =
                index(ampersand, offsetBy: 16, limitedBy: endIndex) ?? endIndex
            guard let semicolon = self[ampersand..<searchEnd].firstIndex(of: ";")
            else {
                output.append("&")
                cursor = index(after: ampersand)
                continue
            }

            let entityStart = index(after: ampersand)
            let entity = String(self[entityStart..<semicolon])
            if let decoded = Self.decodeHTMLEntity(entity) {
                output.append(contentsOf: decoded)
            } else {
                output.append(contentsOf: self[ampersand...semicolon])
            }
            cursor = index(after: semicolon)
        }

        output.append(contentsOf: self[cursor...])
        return output
    }

    private static func decodeHTMLEntity(_ entity: String) -> String? {
        if entity.hasPrefix("#x") || entity.hasPrefix("#X") {
            return unicodeScalarString(
                String(entity.dropFirst(2)),
                radix: 16
            )
        }
        if entity.hasPrefix("#") {
            return unicodeScalarString(
                String(entity.dropFirst()),
                radix: 10
            )
        }

        switch entity.lowercased() {
        case "nbsp":
            return "\u{00A0}"
        case "amp":
            return "&"
        case "quot":
            return "\""
        case "apos", "#39":
            return "'"
        case "lt":
            return "<"
        case "gt":
            return ">"
        case "ndash":
            return "–"
        case "mdash":
            return "—"
        case "hellip":
            return "…"
        case "lsquo":
            return "‘"
        case "rsquo":
            return "’"
        case "ldquo":
            return "“"
        case "rdquo":
            return "”"
        case "bull":
            return "•"
        case "middot":
            return "·"
        case "times":
            return "×"
        case "copy":
            return "©"
        case "reg":
            return "®"
        case "trade":
            return "™"
        default:
            return nil
        }
    }

    private static func unicodeScalarString(
        _ digits: String,
        radix: Int
    ) -> String? {
        guard let value = UInt32(digits, radix: radix),
              let scalar = UnicodeScalar(value)
        else {
            return nil
        }
        return String(scalar)
    }
}
