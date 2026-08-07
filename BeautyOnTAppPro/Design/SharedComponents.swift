import SwiftUI

/// A compact BeautyOnTApp mark: an assistant sparkle with a small brand heart.
/// The restrained mark stays legible at dock and profile-row sizes.
struct BestieMark: View {
  let foreground: Color

  var body: some View {
    ZStack {
      Image(systemName: "sparkles")
        .font(.system(size: 22, weight: .semibold))
        .foregroundStyle(foreground)

      Image(systemName: "heart.fill")
        .font(.system(size: 7, weight: .semibold))
        .foregroundStyle(ThemeTokens.gold)
        .offset(x: -1, y: 9)
    }
    .accessibilityHidden(true)
  }
}

enum NativeRoute: Hashable {
  case brands
  case collection(title: String, handle: String)
  case product(StoreProduct)
  case blog(StoreBlogFeed)
  case article(StoreArticle)
  case cart

  @MainActor @ViewBuilder
  var destination: some View {
    switch self {
    case .brands:
      BrandsView()
    case .collection(let title, let handle):
      CollectionView(title: title, handle: handle)
    case .product(let product):
      ProductDetailView(product: product)
    case .blog(let feed):
      BlogFeedView(feed: feed)
    case .article(let article):
      ArticleDetailView(article: article)
    case .cart:
      CartView(mode: .full)
    }
  }
}

struct NativeNavigationLink<Label: View>: View {
  let route: NativeRoute
  private let label: Label

  init(
    route: NativeRoute,
    @ViewBuilder label: () -> Label
  ) {
    self.route = route
    self.label = label()
  }

  @ViewBuilder
  var body: some View {
    if #available(iOS 16.0, *) {
      NavigationLink(value: route) {
        label
      }
    } else {
      NavigationLink(destination: route.destination) {
        label
      }
    }
  }
}

struct NativeSwipeBackEnabler: UIViewRepresentable {
  func makeUIView(context: Context) -> UIView {
    SwipeBackBridgeView()
  }

  func updateUIView(
    _ uiView: UIView,
    context: Context
  ) {
    (uiView as? SwipeBackBridgeView)?.enableSystemGesture()
  }

  private final class SwipeBackBridgeView: UIView {
    override init(frame: CGRect) {
      super.init(frame: frame)
      isUserInteractionEnabled = false
      backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
      super.didMoveToWindow()
      enableSystemGesture()
    }

    func enableSystemGesture() {
      DispatchQueue.main.async { [weak self] in
        var responder: UIResponder? = self
        while let current = responder {
          if let controller = current as? UIViewController,
            let navigationController = controller.navigationController,
            navigationController.viewControllers.count > 1
          {
            navigationController.interactivePopGestureRecognizer?.delegate = nil
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            return
          }
          responder = current.next
        }
      }
    }
  }
}

private struct NativeSwipeBackModifier: ViewModifier {
  @Environment(\.dismiss) private var dismiss

  func body(content: Content) -> some View {
    content
      .background(NativeSwipeBackEnabler())
      .simultaneousGesture(
        DragGesture(
          minimumDistance: 16,
          coordinateSpace: .global
        )
        .onEnded { value in
          let horizontalTravel = value.translation.width
          let predictedTravel =
            value.predictedEndLocation.x - value.startLocation.x
          let isLeadingEdge = value.startLocation.x <= 28
          let isHorizontal =
            abs(value.translation.height) < abs(horizontalTravel) * 0.62

          guard
            isLeadingEdge,
            isHorizontal,
            horizontalTravel > 88,
            predictedTravel > 132
          else {
            return
          }
          dismiss()
        }
      )
  }
}

extension View {
  func nativeSwipeBack() -> some View {
    modifier(NativeSwipeBackModifier())
  }
}

struct RemoteProductImage: View {
  let url: URL?
  let aspectRatio: CGFloat
  let pixelWidth: Int
  let accessibilityLabel: String

  init(
    url: URL?,
    aspectRatio: CGFloat = 1,
    pixelWidth: Int = 600,
    accessibilityLabel: String = "Product image"
  ) {
    self.url = url
    self.aspectRatio = aspectRatio
    self.pixelWidth = pixelWidth
    self.accessibilityLabel = accessibilityLabel
  }

  var body: some View {
    ZStack {
      // Keep the catalogue canvas intact. Product photography is the source
      // of truth for packaging colour; the image stage supplies its original
      // white canvas while the surrounding card remains an adaptive surface.
      // No matte-removal mask can eat into white bottles, tubes or bundles.
      PipelineRemoteImage(
        request: NativeImageRequest(
          sourceURL: url,
          pixelWidth: pixelWidth,
          aspectRatio: aspectRatio,
          backgroundTreatment: .none
        ),
        accessibilityLabel: accessibilityLabel
      ) { image in
        image
          .resizable()
          .scaledToFit()
          .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
          )
      } placeholder: {
        // Keep the same stable geometry while an image is loading and match
        // the white product-card stage in Light and Dark Mode.
        ThemeTokens.imageSurface
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .aspectRatio(aspectRatio, contentMode: .fit)
    .background(ThemeTokens.imageSurface)
    .clipped()
  }
}

struct SectionHeading: View {
  let eyebrow: String
  let title: String
  var trailingLabel: String?

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      if !eyebrow.isEmpty {
        Text(eyebrow.uppercased())
          .tracking(2.6)
          .themeScaledFont(
            size: 9,
            weight: .heavy,
            maximumScale: 1.3
          )
          .foregroundStyle(ThemeTokens.deepGold)
      }

      HStack(alignment: .firstTextBaseline, spacing: 9) {
        if !title.isEmpty {
          Text(title)
            .themeScaledFont(size: 17, weight: .bold)
            .foregroundStyle(ThemeTokens.ink)
        }

        if let trailingLabel, !trailingLabel.isEmpty {
          HStack(spacing: 5) {
            Text(trailingLabel)
            Image(systemName: "chevron.right")
              .font(.system(size: 8, weight: .bold))
          }
          .themeScaledFont(
            size: 9,
            weight: .bold,
            maximumScale: 1.3
          )
          .foregroundStyle(ThemeTokens.deepGold)
        }

        Spacer(minLength: 0)
      }
    }
    .padding(.horizontal, ThemeTokens.horizontalPadding)
  }
}

struct InlineErrorView: View {
  let message: String
  let retry: () -> Void

  var body: some View {
    VStack(spacing: 10) {
      Image(systemName: "arrow.clockwise.circle")
        .font(.title2)
      Text(message)
        .font(.footnote)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
      Button("Try Again", action: retry)
        .buttonStyle(.bordered)
        .tint(ThemeTokens.ink)
    }
    .frame(maxWidth: .infinity)
    .padding(20)
  }
}

struct WishlistHeartButton: View {
  @EnvironmentObject private var appModel: AppModel

  let product: StoreProduct
  let variant: StoreVariant

  private var isSaved: Bool? {
    appModel.verifiedWishlistState(for: variant.id)
  }

  private var isMutating: Bool {
    appModel.isWishlistMutationInFlight(for: variant.id)
  }

  private var hasVerifiedIDs: Bool {
    ShopifyNumericID.product(from: product.id) != nil
      && ShopifyNumericID.variant(from: variant.id) != nil
  }

  private var verificationTaskID: String {
    "\(variant.id)|\(appModel.isWishlistBridgeReady)"
  }

  var body: some View {
    Button {
      Task {
        let success = await appModel.toggleWishlist(
          product: product,
          variant: variant
        )
        UINotificationFeedbackGenerator().notificationOccurred(
          success ? .success : .error
        )
      }
    } label: {
      ZStack {
        if isMutating {
          ProgressView()
            .controlSize(.small)
            .tint(ThemeTokens.ink)
        } else {
          Image(systemName: isSaved == true ? "heart.fill" : "heart")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(ThemeTokens.ink)
        }
      }
      .frame(
        width: ThemeTokens.minimumTap,
        height: ThemeTokens.minimumTap
      )
      .contentShape(Circle())
    }
    .buttonStyle(.plain)
    .disabled(!hasVerifiedIDs || isMutating)
    .accessibilityLabel(accessibilityLabel)
    .accessibilityValue(accessibilityValue)
    .accessibilityHint(
      isSaved == nil
        ? "Verifies the current Loves status before updating it."
        : ""
    )
    .accessibilityIdentifier("wishlist-\(product.handle)")
    .task(id: verificationTaskID) {
      guard appModel.isWishlistBridgeReady else { return }
      await appModel.refreshWishlistState(variantGID: variant.id)
    }
  }

  private var accessibilityLabel: String {
    guard let isSaved else {
      return "Loves for \(product.title)"
    }
    return isSaved
      ? "Remove \(product.title) from Loves"
      : "Save \(product.title) to Loves"
  }

  private var accessibilityValue: String {
    guard hasVerifiedIDs else { return "Unavailable" }
    guard let isSaved else { return "Status not verified" }
    return isSaved ? "Saved" : "Not saved"
  }
}

enum ProductCardBadgeStyle: Equatable {
  case sale
  case soldOut
}

struct ProductCardPresentation: Equatable {
  let badgeText: String?
  let badgeStyle: ProductCardBadgeStyle?
  let currentPriceText: String
  let compareAtPriceText: String?
  let callToActionText: String

  init(product: StoreProduct) {
    let cardVariant = product.variants.first ?? product.displayVariant
    currentPriceText = cardVariant?.price.text ?? ""
    if !product.availableForSale {
      callToActionText = "Sold out"
    } else if product.isBookingProduct {
      callToActionText = "Book"
    } else if product.canQuickAdd {
      callToActionText = "Add to cart"
    } else {
      callToActionText = product.cardSelectionLabel
    }

    guard product.availableForSale else {
      badgeText = "SOLD OUT"
      badgeStyle = .soldOut
      compareAtPriceText = nil
      return
    }

    guard
      let price = cardVariant?.price,
      let compareAtPrice = cardVariant?.compareAtPrice,
      let priceAmount = Decimal(
        string: price.amount,
        locale: Locale(identifier: "en_US_POSIX")
      ),
      let compareAtAmount = Decimal(
        string: compareAtPrice.amount,
        locale: Locale(identifier: "en_US_POSIX")
      ),
      compareAtAmount > priceAmount
    else {
      badgeText = nil
      badgeStyle = nil
      compareAtPriceText = nil
      return
    }

    badgeText = "SAVE \(MoneyFormatter.string(decimal: compareAtAmount - priceAmount))"
    badgeStyle = .sale
    compareAtPriceText = compareAtPrice.text
  }

  var isOnSale: Bool {
    badgeStyle == .sale
  }
}

struct ProductCardView: View {
  @EnvironmentObject private var appModel: AppModel
  let product: StoreProduct
  var width: CGFloat? = ThemeTokens.productCardWidth

  @State private var isAdding = false
  @State private var optionProduct: StoreProduct?
  @State private var pendingBuyNowVariant: StoreVariant?

  private var presentation: ProductCardPresentation {
    ProductCardPresentation(product: product)
  }

  var body: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .topLeading) {
        NativeNavigationLink(route: .product(product)) {
          VStack(spacing: 0) {
            RemoteProductImage(
              url: product.primaryImageURL,
              aspectRatio: ThemeTokens.productCardImageAspectRatio,
              pixelWidth: 480
            )
            .scaleEffect(ThemeTokens.productCardImageScale)
            .frame(maxWidth: .infinity, alignment: .center)
            .clipShape(
              RoundedRectangle(
                cornerRadius: ThemeTokens.imageRadius,
                style: .continuous
              )
            )

            VStack(spacing: 0) {
              VStack(spacing: 4) {
                Text(product.vendor.uppercased())
                  .tracking(0.55)
                  .themeScaledFont(
                    size: ThemeTokens.productCardTextSize,
                    weight: .bold,
                    maximumScale: 1.15
                  )
                  .foregroundStyle(ThemeTokens.ink)
                  .lineLimit(1)
                  .minimumScaleFactor(0.82)
                  .frame(maxWidth: .infinity)
                  .frame(height: ThemeTokens.productCardVendorHeight)
                  .accessibilityIdentifier(
                    "product-card-vendor-\(product.handle)"
                  )

                Text(product.title)
                  .themeScaledFont(
                    size: ThemeTokens.productCardTextSize,
                    weight: .bold,
                    maximumScale: 1.15
                  )
                  .foregroundStyle(ThemeTokens.ink)
                  .multilineTextAlignment(.center)
                  .lineLimit(2)
                  .minimumScaleFactor(0.86)
                  .frame(maxWidth: .infinity)
                  .frame(
                    height: ThemeTokens.productCardTitleHeight,
                    alignment: .top
                  )
                  .accessibilityIdentifier(
                    "product-card-title-\(product.handle)"
                  )

                productRating
                  .frame(height: ThemeTokens.productCardRatingHeight)

                price
                  .frame(height: ThemeTokens.productCardPriceHeight)
              }
            }
            .padding(.horizontal, 7)
            .padding(.top, 7)
          }
        }
        .nativePressResponse(scale: 0.985)
        .accessibilityIdentifier("product-link-\(product.handle)")

        if let variant = product.displayVariant {
          WishlistHeartButton(product: product, variant: variant)
            .zIndex(1)
        }

        if let badgeText = presentation.badgeText,
          let badgeStyle = presentation.badgeStyle
        {
          productBadge(text: badgeText, style: badgeStyle)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 9)
            .padding(.trailing, 7)
            .allowsHitTesting(false)
            .zIndex(1)
        }
      }

      Group {
        if product.availableForSale,
          !product.isBookingProduct,
          !product.canQuickAdd
        {
          Button {
            optionProduct = product
          } label: {
            Text(presentation.callToActionText)
              .themeScaledFont(
                size: ThemeTokens.productCardTextSize,
                weight: .bold,
                maximumScale: 1.15
              )
              .frame(maxWidth: .infinity)
              .frame(minHeight: ThemeTokens.minimumTap)
          }
          .accessibilityIdentifier(
            "product-card-options-\(product.handle)"
          )
        } else if product.canQuickAdd,
          let variant = product.firstAvailableVariant,
          let line = appModel.cartLine(forVariantID: variant.id)
        {
          ProductCardQuantityControl(line: line)
        } else {
          Button {
            if product.isBookingProduct {
              guard let productURL = product.verifiedOnlineStoreURL else {
                return
              }
              appModel.presentWeb(
                title: product.title,
                url: productURL,
                allowsExternalNavigation: true,
                allowsCommerceNavigation: true
              )
              return
            }
            guard product.canQuickAdd,
              let variant = product.firstAvailableVariant
            else {
              return
            }
            isAdding = true
            Task {
              let success = await appModel.addToCart(variant: variant)
              if success {
                UINotificationFeedbackGenerator()
                  .notificationOccurred(.success)
              }
              isAdding = false
            }
          } label: {
            Group {
              if isAdding {
                ProgressView()
                  .tint(ThemeTokens.ink)
              } else {
                Text(presentation.callToActionText)
                  .themeScaledFont(
                    size: ThemeTokens.productCardTextSize,
                    weight: .bold,
                    maximumScale: 1.15
                  )
              }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: ThemeTokens.minimumTap)
          }
          .accessibilityIdentifier(
            "product-card-add-\(product.handle)"
          )
        }
      }
      .nativePressResponse(scale: 0.97)
      .foregroundStyle(
        product.availableForSale
          ? ThemeTokens.ink
          : ThemeTokens.muted
      )
      .frame(minHeight: ThemeTokens.minimumTap)
      .background {
        ProductCardActionSurface(
          isEnabled: product.availableForSale
            && !isAdding
            && !appModel.isCartBusy
        )
        .frame(height: 34)
      }
      .contentShape(Rectangle())
      .disabled(
        !product.availableForSale || isAdding || appModel.isCartBusy
          || (product.isBookingProduct && product.verifiedOnlineStoreURL == nil)
      )
      .padding(.horizontal, 14)
      .padding(.top, 2)
      .padding(.bottom, 14)
    }
    .background(ThemeTokens.cardSurface)
    .clipShape(
      RoundedRectangle(
        cornerRadius: ThemeTokens.productCardCornerRadius,
        style: .continuous
      )
    )
    .overlay {
      RoundedRectangle(
        cornerRadius: ThemeTokens.productCardCornerRadius,
        style: .continuous
      )
      .stroke(ThemeTokens.separator, lineWidth: 0.7)
    }
    .shadow(color: Color(hex: 0x281E0C).opacity(0.08), radius: 7, y: 3)
    .frame(width: width)
    .frame(maxWidth: width == nil ? .infinity : nil)
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("product-card-\(product.handle)")
    .sheet(
      item: $optionProduct,
      onDismiss: {
        guard let variant = pendingBuyNowVariant else { return }
        pendingBuyNowVariant = nil
        Task {
          _ = await appModel.buyNow(variant: variant)
        }
      }
    ) { selectedProduct in
      ProductQuickOptionSheet(
        product: selectedProduct,
        onDismiss: {
          optionProduct = nil
        },
        onBuyNow: { variant in
          pendingBuyNowVariant = variant
          optionProduct = nil
        }
      )
      .environmentObject(appModel)
      .nativeSheetStyle(.options)
    }
  }

  @ViewBuilder
  private var price: some View {
    if presentation.isOnSale,
      let compareAtPriceText = presentation.compareAtPriceText
    {
      HStack(alignment: .firstTextBaseline, spacing: 5) {
        Text(compareAtPriceText)
          .strikethrough()
          .themeScaledFont(
            size: ThemeTokens.productCardTextSize,
            weight: .semibold,
            maximumScale: 1.1
          )
          .foregroundStyle(ThemeTokens.muted)

        Text(presentation.currentPriceText)
          .themeScaledFont(
            size: ThemeTokens.productCardTextSize,
            weight: .bold,
            maximumScale: 1.1
          )
          .foregroundStyle(ThemeTokens.sale)
      }
      .lineLimit(1)
      .minimumScaleFactor(0.72)
      .frame(maxWidth: .infinity, alignment: .center)
      .accessibilityIdentifier("product-card-price-\(product.handle)")
      .accessibilityElement(children: .combine)
      .accessibilityLabel(
        "Was \(compareAtPriceText), now \(presentation.currentPriceText)"
      )
    } else {
      Text(presentation.currentPriceText)
        .themeScaledFont(
          size: ThemeTokens.productCardTextSize,
          weight: .bold,
          maximumScale: 1.1
        )
        .foregroundStyle(ThemeTokens.ink)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityIdentifier("product-card-price-\(product.handle)")
    }
  }

  @ViewBuilder
  private var productRating: some View {
    if let reviewSummary = product.reviewSummary {
      HStack(spacing: 2.5) {
        HStack(spacing: 1) {
          ForEach(1...5, id: \.self) { position in
            Image(
              systemName: ratingSymbol(
                position: position,
                averageRating: reviewSummary.averageRating
              )
            )
            .font(.system(size: 9, weight: .semibold))
          }
        }
        .foregroundStyle(Color(hex: 0xF5B301))

        Text("(\(reviewSummary.reviewCount))")
          .themeScaledFont(
            size: ThemeTokens.productCardTextSize,
            weight: .semibold,
            maximumScale: 1.1
          )
          .foregroundStyle(ThemeTokens.muted)
          .monospacedDigit()
      }
      .lineLimit(1)
      .frame(maxWidth: .infinity, alignment: .center)
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(
        "\(String(format: "%.1f", reviewSummary.averageRating)) out of 5, "
          + "\(reviewSummary.reviewCount) reviews"
      )
      .accessibilityIdentifier("product-card-rating-\(product.handle)")
    } else {
      Color.clear
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityHidden(true)
    }
  }

  private func ratingSymbol(
    position: Int,
    averageRating: Double
  ) -> String {
    let threshold = Double(position)
    if averageRating >= threshold {
      return "star.fill"
    }
    if averageRating >= threshold - 0.5 {
      return "star.leadinghalf.filled"
    }
    return "star"
  }

  private func productBadge(
    text: String,
    style: ProductCardBadgeStyle
  ) -> some View {
    Text(text)
      .themeScaledFont(size: 8, weight: .bold, maximumScale: 1.15)
      .foregroundStyle(Color.white)
      .padding(.horizontal, 6)
      .frame(minHeight: 20)
      .background(
        style == .sale ? ThemeTokens.sale : ThemeTokens.ink
      )
      .accessibilityLabel(text)
      .accessibilityIdentifier("product-badge-\(product.handle)")
  }
}

struct ProductCardActionSurface: View {
  @Environment(\.colorScheme) private var colorScheme
  let isEnabled: Bool

  var body: some View {
    Capsule()
      // The action remains a separate elevated control on a dark card. A
      // secondary-system fill was too close to the card surface, so the
      // button disappeared into the grid in Dark Mode.
      .fill(ThemeTokens.elevatedSurface.opacity(isEnabled ? 0.98 : 0.86))
      .overlay {
        Capsule()
          .stroke(
            colorScheme == .dark
              ? Color.white.opacity(isEnabled ? 0.30 : 0.20)
              : ThemeTokens.ink.opacity(isEnabled ? 0.22 : 0.14),
            lineWidth: 0.9
          )
      }
      .shadow(
        color: Color.black.opacity(isEnabled ? 0.08 : 0.03),
        radius: 6,
        y: 2
      )
  }
}

private struct ProductCardQuantityControl: View {
  @EnvironmentObject private var appModel: AppModel
  let line: StoreCartLine

  var body: some View {
    HStack(spacing: 0) {
      quantityButton(
        symbol: "minus",
        label: "Decrease \(line.product.title) quantity"
      ) {
        Task {
          await appModel.setCartLine(
            line,
            quantity: line.quantity - 1
          )
        }
      }

      Text("\(line.quantity)")
        .themeScaledFont(size: 12.5, weight: .bold)
        .monospacedDigit()
        .frame(minWidth: 30)
        .accessibilityLabel("Quantity \(line.quantity)")

      quantityButton(
        symbol: "plus",
        label: "Increase \(line.product.title) quantity"
      ) {
        Task {
          await appModel.setCartLine(
            line,
            quantity: line.quantity + 1
          )
        }
      }
    }
    .frame(maxWidth: .infinity)
    .frame(height: ThemeTokens.minimumTap)
    .accessibilityIdentifier(
      "product-card-quantity-\(line.product.handle)"
    )
  }

  private func quantityButton(
    symbol: String,
    label: String,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Image(systemName: symbol)
        .font(.system(size: 12.5, weight: .semibold))
        .frame(
          maxWidth: .infinity,
          minHeight: ThemeTokens.minimumTap
        )
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .disabled(appModel.isCartBusy)
    .accessibilityLabel(label)
  }
}

private struct ProductQuickOptionSheet: View {
  @Environment(\.accessibilityReduceTransparency)
  private var reduceTransparency
  @EnvironmentObject private var appModel: AppModel

  @State private var resolvedProduct: StoreProduct
  @State private var selection: ProductVariantSelection
  @State private var isLoading = false
  @State private var isAdding = false
  @State private var errorMessage: String?

  let onDismiss: () -> Void
  let onBuyNow: (StoreVariant) -> Void

  init(
    product: StoreProduct,
    onDismiss: @escaping () -> Void,
    onBuyNow: @escaping (StoreVariant) -> Void
  ) {
    _resolvedProduct = State(initialValue: product)
    _selection = State(
      initialValue: ProductVariantSelection(
        variants: product.variants,
        initialVariantID: product.displayVariant?.id
      )
    )
    self.onDismiss = onDismiss
    self.onBuyNow = onBuyNow
  }

  private var selectedVariant: StoreVariant? {
    selection.selectedVariant
  }

  var body: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(Color.secondary.opacity(0.34))
        .frame(width: 36, height: 5)
        .padding(.top, 8)
        .padding(.bottom, 12)

      HStack(alignment: .top, spacing: 12) {
        RemoteProductImage(
          url: selectedVariant?.image?.url
            ?? resolvedProduct.primaryImageURL,
          pixelWidth: 220,
          accessibilityLabel: resolvedProduct.title
        )
        .frame(width: 64, height: 64)
        .clipShape(
          RoundedRectangle(cornerRadius: 14, style: .continuous)
        )

        VStack(alignment: .leading, spacing: 5) {
          Text(resolvedProduct.title)
            .themeScaledFont(size: 17, weight: .bold)
            .foregroundStyle(ThemeTokens.ink)
            .lineLimit(2)
          Text(
            selectedVariant?.price.text
              ?? resolvedProduct.priceText
          )
          .themeScaledFont(size: 15, weight: .bold)
          .foregroundStyle(ThemeTokens.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Button(action: onDismiss) {
          Image(systemName: "xmark")
            .font(.system(size: 17, weight: .semibold))
            .frame(
              width: ThemeTokens.minimumTap,
              height: ThemeTokens.minimumTap
            )
        }
        .buttonStyle(.plain)
        .adaptiveGlass(in: Circle(), interactive: true)
        .accessibilityLabel("Close options")
        .accessibilityIdentifier("product-options-close")
      }
      .padding(.horizontal, 20)

      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 14) {
          if isLoading {
            ProgressView("Loading options")
              .frame(maxWidth: .infinity)
              .padding(.vertical, 10)
          }

          ForEach(selection.visibleOptionGroups) { group in
            optionGroup(group)
          }

          if let errorMessage {
            Text(errorMessage)
              .themeScaledFont(size: 12, weight: .medium)
              .foregroundStyle(ThemeTokens.sale)
              .frame(maxWidth: .infinity, alignment: .leading)
          }

          purchaseActions
            .padding(.top, 2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 18)
      }
    }
    .background {
      if reduceTransparency {
        ThemeTokens.canvas
      } else {
        Rectangle().fill(.ultraThinMaterial)
      }
    }
    .task {
      await loadCompleteProduct()
    }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(
      "product-options-\(resolvedProduct.handle)"
    )
  }

  private var purchaseActions: some View {
    VStack(spacing: 8) {
      Button {
        addSelectedVariant()
      } label: {
        Group {
          if isAdding {
            ProgressView()
              .tint(.white)
          } else {
            Text("Add to cart")
              .themeScaledFont(size: 15, weight: .bold)
          }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .contentShape(Capsule())
      }
      .buttonStyle(.plain)
      .foregroundStyle(ThemeTokens.primaryButtonForeground)
      .background(ThemeTokens.primaryButton, in: Capsule())
      .accessibilityIdentifier("product-options-add")

      Button {
        guard let selectedVariant,
          selectedVariant.availableForSale
        else {
          return
        }
        onBuyNow(selectedVariant)
      } label: {
        Text("Buy it now")
          .themeScaledFont(size: 15, weight: .bold)
          .frame(maxWidth: .infinity)
          .frame(height: 48)
          .contentShape(Capsule())
      }
      .buttonStyle(.plain)
      .foregroundStyle(ThemeTokens.ink)
      .adaptiveGlass(
        in: Capsule(),
        tint: ThemeTokens.glassControlTint,
        interactive: true
      )
      .overlay {
        Capsule()
          .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.7)
      }
      .accessibilityIdentifier("product-options-buy-now")
    }
    .disabled(
      selectedVariant?.availableForSale != true
        || isLoading
        || isAdding
        || appModel.isCartBusy
    )
  }

  private func optionGroup(
    _ group: ProductOptionGroup
  ) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(group.name.uppercased())
        .tracking(0.9)
        .themeScaledFont(size: 11, weight: .bold)
        .foregroundStyle(ThemeTokens.muted)

      if #available(iOS 26.0, *) {
        GlassEffectContainer(spacing: 6) {
          optionValues(group)
        }
      } else {
        optionValues(group)
      }
    }
  }

  private func optionValues(
    _ group: ProductOptionGroup
  ) -> some View {
    LazyVGrid(
      columns: [
        GridItem(.adaptive(minimum: 128), spacing: 6)
      ],
      spacing: 6
    ) {
      ForEach(group.values, id: \.self) { value in
        let availability = selection.availability(
          of: value,
          for: group.name
        )
        let isSelected =
          selection.selectedValue(for: group.name) == value

        Button {
          withAnimation(
            .spring(response: 0.26, dampingFraction: 0.88)
          ) {
            selection.select(value, for: group.name)
          }
          NativeHaptics.play(.selection)
        } label: {
          Text(value)
            .themeScaledFont(
              size: 13,
              weight: isSelected ? .bold : .semibold
            )
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(
          availability == .available
            ? ThemeTokens.ink
            : ThemeTokens.soft
        )
        .adaptiveGlass(
          in: RoundedRectangle(
            cornerRadius: 15,
            style: .continuous
          ),
          tint: isSelected
            ? ThemeTokens.glassOptionSelectionTint
            : ThemeTokens.glassSelectionTint,
          interactive: availability == .available
        )
        .overlay {
          RoundedRectangle(
            cornerRadius: 15,
            style: .continuous
          )
          .stroke(
            ThemeTokens.separator.opacity(isSelected ? 0.68 : 0.42),
            lineWidth: isSelected ? 1 : 0.7
          )
        }
        .disabled(availability != .available)
        .accessibilityAddTraits(
          isSelected ? .isSelected : []
        )
      }
    }
  }

  private func loadCompleteProduct() async {
    guard !resolvedProduct.hasCompleteDetails else { return }
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }
    do {
      let loaded = try await appModel.product(
        handle: resolvedProduct.handle
      )
      let preferred = selection.selectedVariantID
      resolvedProduct = loaded
      selection.replaceVariants(
        loaded.variants,
        preferredVariantID: preferred
      )
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func addSelectedVariant() {
    guard let selectedVariant,
      selectedVariant.availableForSale
    else {
      return
    }
    isAdding = true
    errorMessage = nil
    Task {
      let success = await appModel.addToCart(
        variant: selectedVariant
      )
      isAdding = false
      if success {
        UINotificationFeedbackGenerator()
          .notificationOccurred(.success)
        onDismiss()
      } else {
        UINotificationFeedbackGenerator()
          .notificationOccurred(.error)
        errorMessage = appModel.cartError
      }
    }
  }
}

struct ProductRailView: View {
  @EnvironmentObject private var appModel: AppModel
  let specification: ThemeProductRail

  @State private var products: [StoreProduct] = []
  @State private var errorMessage: String?
  @State private var isLoading = false

  private var railSpacing: CGFloat {
    switch specification.collectionHandle {
    case "skincare", "korean-skincare":
      ThemeTokens.productRailTightGap
    default:
      ThemeTokens.productRailGap
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      NativeNavigationLink(
        route: .collection(
          title: specification.heading,
          handle: specification.collectionHandle
        )
      ) {
        SectionHeading(
          eyebrow: specification.eyebrow,
          title: specification.heading,
          trailingLabel: specification.linkLabel
        )
      }
      .buttonStyle(.plain)

      if isLoading && products.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: railSpacing) {
            ForEach(0..<3, id: \.self) { _ in
              RoundedRectangle(
                cornerRadius: ThemeTokens.productCardCornerRadius
              )
              .fill(ThemeTokens.elevatedSurface)
              .frame(
                width: ThemeTokens.productCardWidth,
                height: 300
              )
              .redacted(reason: .placeholder)
            }
          }
          .padding(.horizontal, ThemeTokens.horizontalPadding)
        }
      } else if let errorMessage, products.isEmpty {
        InlineErrorView(message: errorMessage, retry: load)
      } else {
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHStack(spacing: railSpacing) {
            ForEach(products) { product in
              ProductCardView(product: product)
            }
          }
          .padding(.horizontal, ThemeTokens.horizontalPadding)
          .padding(.vertical, 4)
        }
      }
    }
    .padding(.vertical, ThemeTokens.sectionVerticalPadding)
    .task(id: specification.collectionHandle) {
      await loadProducts()
    }
  }

  private func load() {
    Task { await loadProducts() }
  }

  private func loadProducts() async {
    guard !isLoading else { return }
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }
    do {
      let page = try await appModel.collection(
        handle: specification.collectionHandle,
        first: specification.productCount
      )
      products = page.products

      if let summaries = try? await ProductCardReviewsSource.shared
        .summaries(
          forCollectionHandle: specification.collectionHandle
        )
      {
        try Task.checkCancellation()
        products = products.applying(
          reviewSummaries: summaries
        )
      }
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
