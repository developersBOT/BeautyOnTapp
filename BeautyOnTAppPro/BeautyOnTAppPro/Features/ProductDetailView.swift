import SwiftUI

enum ProductDetailMetrics {
  static let galleryHeight: CGFloat = 240
  static let wishlistVisualFootprint: CGFloat = 20
  static let wishlistHitTarget: CGFloat = 44
  static let presentationRatingHeight: CGFloat = 16
  static let presentationInstallmentHeight: CGFloat = 77
  static let walletBadgeWidth: CGFloat = 75.5
  static let walletBadgeHeight: CGFloat = 32
  static let walletHitTarget: CGFloat = 44
  static let walletMarkWidth: CGFloat = 52
  static let walletMarkHeight: CGFloat = 18
  // Keep the visual option pills compact while preserving a standard
  // 44pt outer hit target below. Simple values such as "500ml" should not
  // dominate the purchase panel, while fragrance choices remain easy to tap.
  // Match the 32pt visual height of the Pay buttons. The enclosing Button
  // still receives the standard 44pt hit target below.
  static let optionHeight: CGFloat = walletBadgeHeight
  static let quantityHeight: CGFloat = 48
  static let commerceButtonHeight: CGFloat = 50
  static let deliveryIconSize: CGFloat = 38
}

struct ProductDetailView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @EnvironmentObject private var appModel: AppModel

  @State private var product: StoreProduct
  @State private var variantSelection: ProductVariantSelection
  @State private var quantity = 1
  @State private var isLoading = false
  @State private var isAdding = false
  @State private var detailErrorMessage: String?
  @State private var actionErrorMessage: String?
  @State private var resourceLinkRails = ResourceLinkRails.empty
  @State private var resourceLinkRailsResource: ResourceLinkResource?
  @State private var resourceLinksRequestID: UUID?
  @State private var recommendations: [StoreProduct] = []
  @State private var presentation = ProductPresentation.empty
  @State private var isPresentationLoading = true
  @State private var presentationRequestID: UUID?
  @State private var isReviewsPresented = false
  @State private var isBookingPresented = false
  @State private var presentedWalletProvider: ProductWalletProvider?

  init(product: StoreProduct) {
    _product = State(initialValue: product)
    _variantSelection = State(
      initialValue: ProductVariantSelection(
        variants: product.variants,
        initialVariantID: product.displayVariant?.id
      )
    )
  }

  private var selectedVariant: StoreVariant? {
    variantSelection.selectedVariant ?? product.displayVariant
  }

  private var isCommerceBusy: Bool {
    isAdding || appModel.isCartBusy || appModel.isBuyNowBusy
  }

  var body: some View {
    ScrollViewReader { scrollProxy in
      ScrollView {
        LazyVStack(
          alignment: .leading,
          spacing: 0,
          pinnedViews: [.sectionHeaders]
        ) {
          Color.clear
            .frame(height: 0)
            .id(productScrollTopID)

          StoreHeader(
            appModel: appModel,
            presentation: .primary
          )

          Section {
            // Keep the product layout stable while the theme-authored rails
            // arrive. Showing gray pills here caused a loading flash above an
            // otherwise ready product image and purchase panel.
            ResourceLinkRailsView(rails: resourceLinkRails) {
              title,
              link in
              appModel.openThemeLink(title: title, link: link)
            }

            VStack(alignment: .leading, spacing: 22) {
              gallery
              productSummary

              if product.hasCompleteDetails {
                if !variantSelection.visibleOptionGroups.isEmpty {
                  optionSelectors
                }

                if !product.isBookingProduct {
                  quantityControl
                }

                if let actionErrorMessage {
                  Text(actionErrorMessage)
                    .themeScaledFont(
                      size: 13,
                      relativeTo: .footnote,
                      maximumScale: 2
                    )
                    .foregroundStyle(ThemeTokens.sale)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("product-action-error")
                }

                if product.isBookingProduct {
                  bookingAction
                } else {
                  commerceActions
                  deliveryCard
                }

                if !product.descriptionText.isEmpty {
                  productDescription
                }
              } else {
                detailLoadingState
              }

              reviewsRow

              if !recommendations.isEmpty {
                recommendationsRail
              }
            }
            .padding(.horizontal, ThemeTokens.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 100)
          } header: {
            StoreHeader(
              appModel: appModel,
              presentation: .tabs
            )
            .zIndex(1)
          }
        }
      }
      .accessibilityIdentifier("product-detail")
    .background(ThemeTokens.canvas)
    .nativeSoftTopScrollEdgeEffect()
    .navigationBarHidden(true)
      .nativeSwipeBack()
      .onAppear {
        DispatchQueue.main.async {
          scrollProxy.scrollTo(productScrollTopID, anchor: .top)
        }
      }
      .task {
        await refreshProduct()
      }
      .task(id: "resource-links-\(product.handle)") {
        await loadResourceLinkRails()
      }
      .task(id: "recommendations-\(product.id)") {
        await loadRecommendations()
      }
      .task(id: "presentation-\(product.handle)") {
        await loadProductPresentation()
      }
      .sheet(isPresented: $isReviewsPresented) {
        ProductReviewsView(
          productTitle: product.title,
          productHandle: product.handle
        )
      }
      .sheet(isPresented: $isBookingPresented) {
        if let selectedVariant {
          BookingFlowView(product: product, variant: selectedVariant)
            .environmentObject(appModel)
        }
      }
      .sheet(item: $presentedWalletProvider) { provider in
        if let information = provider.information {
          ProductPaymentProviderSheet(
            providerName: walletDisplayLabel(
              provider.accessibilityLabel
            ),
            information: information
          ) { url, label in
            appModel.openThemeLink(
              title: label,
              link: .external(url)
            )
          }
        }
      }
    }
  }

  private var productScrollTopID: String {
    "product-top-\(product.handle)"
  }

  private var galleryImages: [StoreImage] {
    var images = product.images
    if let variantImage = selectedVariant?.image,
      !images.contains(where: { $0.id == variantImage.id })
    {
      images.insert(variantImage, at: 0)
    }
    return images
  }

  @ViewBuilder
  private var gallery: some View {
    Group {
      if galleryImages.isEmpty {
        RemoteProductImage(url: product.primaryImageURL, pixelWidth: 1_200)
          .frame(
            maxWidth: .infinity,
            alignment: .center
          )
          .frame(
            height: ProductDetailMetrics.galleryHeight,
            alignment: .center
          )
          .accessibilityLabel(product.title)
      } else if galleryImages.count == 1, let image = galleryImages.first {
        RemoteProductImage(url: image.url, pixelWidth: 1_200)
          .frame(
            maxWidth: .infinity,
            alignment: .center
          )
          .frame(
            height: ProductDetailMetrics.galleryHeight,
            alignment: .center
          )
          .accessibilityLabel(image.altText ?? product.title)
      } else {
        TabView {
          ForEach(galleryImages) { image in
            RemoteProductImage(url: image.url, pixelWidth: 1_200)
              .tag(image.id)
              .accessibilityLabel(image.altText ?? product.title)
          }
        }
        .tabViewStyle(
          .page(
            indexDisplayMode: horizontalSizeClass == .compact
              ? .never
              : .automatic
          )
        )
        .frame(
          height: ProductDetailMetrics.galleryHeight,
          alignment: .center
        )
        .accessibilityLabel("Product images")
      }
    }
    // The media stage is deliberately white edge-to-edge. The product card
    // and purchase content remain adaptive surfaces below it; only the image
    // canvas is protected from the dark surround.
    .padding(.horizontal, -ThemeTokens.horizontalPadding)
    .frame(maxWidth: .infinity)
    .frame(height: ProductDetailMetrics.galleryHeight)
    .background(ThemeTokens.imageSurface)
    .clipped()
  }

  private var productSummary: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let selectedVariant {
        CompactProductWishlistButton(
          product: product,
          variant: selectedVariant
        )
      }

      Text(product.vendor.uppercased())
        .tracking(1.2)
        .themeScaledFont(
          size: 10,
          weight: .semibold,
          maximumScale: 1.4
        )
        .foregroundStyle(ThemeTokens.muted)

      Text(product.title)
        .themeScaledFont(
          size: 21,
          weight: .bold,
          maximumScale: 1.8
        )
        .foregroundStyle(ThemeTokens.ink)
        .fixedSize(horizontal: false, vertical: true)

      if let reviewSummary = presentation.reviewSummary {
        productRatingRow(reviewSummary)
      } else if isPresentationLoading {
        productRatingPlaceholder
      }

      if let installmentSummary = presentation.installmentSummary {
        installmentPresentation(installmentSummary)
      } else if isPresentationLoading {
        installmentPresentationPlaceholder
      }

      if let selectedVariant {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text(selectedVariant.price.text)
            .themeScaledFont(size: 18, weight: .bold)
            .foregroundStyle(ThemeTokens.ink)
          if let compareAt = selectedVariant.compareAtPrice,
            let compareAtAmount = Decimal(string: compareAt.amount),
            let sellingAmount = Decimal(
              string: selectedVariant.price.amount
            ),
            compareAtAmount > sellingAmount
          {
            Text(compareAt.text)
              .strikethrough()
              .themeScaledFont(size: 14)
              .foregroundStyle(ThemeTokens.muted)
          }
        }
        .accessibilityElement(children: .combine)
      }
    }
  }

  private func productRatingRow(
    _ summary: ProductReviewSummary
  ) -> some View {
    HStack(spacing: 7) {
      HStack(spacing: 1) {
        ForEach(0..<5, id: \.self) { index in
          Image(
            systemName: ratingSymbol(
              at: index,
              average: summary.averageRating
            )
          )
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(Color(hex: 0xF5B700))
        }
      }
      .accessibilityHidden(true)

      Text("\(summary.reviewCount) reviews")
        .themeScaledFont(size: 12)
        .foregroundStyle(ThemeTokens.ink)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
      "\(summary.averageRating.formatted(.number.precision(.fractionLength(0...2)))) out of 5 stars, \(summary.reviewCount) reviews"
    )
    .accessibilityIdentifier("product-rating-summary")
    .frame(
      height: ProductDetailMetrics.presentationRatingHeight,
      alignment: .leading
    )
  }

  private var productRatingPlaceholder: some View {
    HStack(spacing: 7) {
      RoundedRectangle(cornerRadius: 4, style: .continuous)
        .fill(ThemeTokens.ink.opacity(0.055))
        .frame(width: 74, height: 12)
      RoundedRectangle(cornerRadius: 4, style: .continuous)
        .fill(ThemeTokens.ink.opacity(0.055))
        .frame(width: 62, height: 11)
    }
    .frame(
      height: ProductDetailMetrics.presentationRatingHeight,
      alignment: .leading
    )
    .accessibilityHidden(true)
  }

  private func ratingSymbol(
    at index: Int,
    average: Double
  ) -> String {
    let value = average - Double(index)
    if value >= 0.75 {
      return "star.fill"
    }
    if value >= 0.25 {
      return "star.leadinghalf.filled"
    }
    return "star"
  }

  private func installmentPresentation(
    _ summary: ProductInstallmentSummary
  ) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .firstTextBaseline, spacing: 4) {
        Text(summary.priceText)
          .fontWeight(.semibold)
        Text(summary.paymentText)
          .fontWeight(.semibold)
      }
      .themeScaledFont(size: 12.6)
      .foregroundStyle(ThemeTokens.ink)
      .fixedSize(horizontal: false, vertical: true)

      if let heading = summary.walletHeading,
        !presentation.walletProviders.isEmpty
      {
        Text(heading)
          .themeScaledFont(size: 12)
          .foregroundStyle(ThemeTokens.muted)

        ScrollView(.horizontal, showsIndicators: false) {
          LazyHStack(spacing: 6) {
            ForEach(presentation.walletProviders) { provider in
              walletBadge(provider)
            }
          }
        }
        .frame(height: ProductDetailMetrics.walletHitTarget)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(heading)
      }
    }
    .accessibilityIdentifier("product-installment-summary")
    .frame(
      minHeight: hasWalletPresentation
        ? ProductDetailMetrics.presentationInstallmentHeight
        : ProductDetailMetrics.presentationRatingHeight,
      alignment: .topLeading
    )
  }

  private var installmentPresentationPlaceholder: some View {
    VStack(alignment: .leading, spacing: 8) {
      RoundedRectangle(cornerRadius: 4, style: .continuous)
        .fill(ThemeTokens.ink.opacity(0.055))
        .frame(width: 218, height: 13)
      RoundedRectangle(cornerRadius: 4, style: .continuous)
        .fill(ThemeTokens.ink.opacity(0.055))
        .frame(width: 142, height: 11)
      HStack(spacing: 6) {
        ForEach(0..<4, id: \.self) { _ in
          RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(ThemeTokens.ink.opacity(0.045))
            .frame(
              width: ProductDetailMetrics.walletBadgeWidth,
              height: ProductDetailMetrics.walletBadgeHeight
            )
        }
      }
    }
    .frame(
      height: ProductDetailMetrics.presentationInstallmentHeight,
      alignment: .topLeading
    )
    .clipped()
    .accessibilityHidden(true)
  }

  private var hasWalletPresentation: Bool {
    presentation.installmentSummary?.walletHeading != nil
      && !presentation.walletProviders.isEmpty
  }

  private func walletBadge(
    _ provider: ProductWalletProvider
  ) -> some View {
    Group {
      if provider.isInteractive {
        Button {
          presentedWalletProvider = provider
        } label: {
          walletBadgeArtwork(provider)
        }
        .buttonStyle(.plain)
        .frame(minHeight: ProductDetailMetrics.walletHitTarget)
        .contentShape(Rectangle())
        .accessibilityLabel(provider.accessibilityLabel)
        .accessibilityHint("Shows payment information")
        .accessibilityIdentifier(
          "product-payment-provider-\(paymentProviderIdentifier(provider))"
        )
      } else {
        walletBadgeArtwork(provider)
          .accessibilityElement(children: .ignore)
          .accessibilityLabel(provider.accessibilityLabel)
      }
    }
  }

  private func walletBadgeArtwork(
    _ provider: ProductWalletProvider
  ) -> some View {
    Group {
      if let nativeMark = provider.nativeMark {
        nativeWalletMark(nativeMark)
      } else if let imageURL = provider.imageURL {
        PipelineRemoteImage(
          request: NativeImageRequest(
            sourceURL: imageURL,
            pixelWidth: 180
          ),
          accessibilityLabel: nil
        ) { image in
          image
            .resizable()
            .scaledToFit()
        } placeholder: {
          Text(walletDisplayLabel(provider.accessibilityLabel))
            .themeScaledFont(size: 10, weight: .semibold)
        }
      } else {
        Text(walletDisplayLabel(provider.accessibilityLabel))
          .themeScaledFont(size: 10, weight: .semibold)
      }
    }
    .foregroundStyle(ThemeTokens.ink)
    .frame(
      width: ProductDetailMetrics.walletMarkWidth,
      height: ProductDetailMetrics.walletMarkHeight
    )
    .frame(
      width: ProductDetailMetrics.walletBadgeWidth,
      height: ProductDetailMetrics.walletBadgeHeight
    )
    .background(
      ThemeTokens.controlSurface.opacity(0.90),
      in: RoundedRectangle(cornerRadius: 13, style: .continuous)
    )
    .overlay {
      RoundedRectangle(cornerRadius: 13, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.65), lineWidth: 0.8)
    }
  }

  @ViewBuilder
  private func nativeWalletMark(
    _ mark: ProductWalletNativeMark
  ) -> some View {
    switch mark {
    case .applePay:
      HStack(alignment: .center, spacing: 1.5) {
        Image(systemName: "apple.logo")
          .font(.system(size: 12.5, weight: .medium))
        Text("Pay")
          .font(.system(size: 11, weight: .semibold))
      }
      .foregroundStyle(ThemeTokens.ink)
    case .googlePay:
      HStack(alignment: .center, spacing: 1.5) {
        GoogleWalletGMark()
          .frame(width: 10, height: 10)
        Text("Pay")
          .font(.system(size: 9.5, weight: .medium))
          .foregroundStyle(ThemeTokens.muted)
      }
    }
  }

  private func walletDisplayLabel(_ label: String) -> String {
    let prefix = "Learn more about "
    if label.hasPrefix(prefix) {
      return String(label.dropFirst(prefix.count))
    }
    return label
  }

  private func paymentProviderIdentifier(
    _ provider: ProductWalletProvider
  ) -> String {
    walletDisplayLabel(provider.accessibilityLabel)
      .lowercased()
      .unicodeScalars
      .map {
        CharacterSet.alphanumerics.contains($0)
          ? String($0)
          : "-"
      }
      .joined()
  }

  private var optionSelectors: some View {
    VStack(alignment: .leading, spacing: 14) {
      ForEach(variantSelection.visibleOptionGroups) { group in
        VStack(alignment: .leading, spacing: 6) {
          Text(group.name.uppercased())
            .tracking(1.3)
            .themeScaledFont(
              size: 10,
              weight: .semibold,
              maximumScale: 1.5
            )
            .foregroundStyle(ThemeTokens.muted)

          ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 7) {
              ForEach(group.values, id: \.self) { value in
                optionButton(value: value, group: group)
              }
            }
            .padding(.vertical, 1)
          }
        }
      }
    }
    .accessibilityIdentifier("product-options")
  }

  private func optionButton(
    value: String,
    group: ProductOptionGroup
  ) -> some View {
    let availability = variantSelection.availability(
      of: value,
      for: group.name
    )
    let isSelected =
      variantSelection.selectedValue(for: group.name)
      == value
    let isIncompatible = availability == .incompatible

    return Button {
      NativeHaptics.play(.selection)
      actionErrorMessage = nil
      if reduceMotion {
        variantSelection.select(value, for: group.name)
      } else {
        withAnimation(ThemeTokens.controlSpring) {
          variantSelection.select(value, for: group.name)
        }
      }
    } label: {
      VStack(spacing: 2) {
        Text(value)
          .themeScaledFont(size: 12.6, weight: .semibold)
          .lineLimit(2)
          .multilineTextAlignment(.center)
        if availability == .soldOut {
          Text("Sold out")
            .themeScaledFont(
              size: 9,
              weight: .semibold,
              maximumScale: 1.4
            )
        }
      }
      .foregroundStyle(
        isSelected
          ? ThemeTokens.primaryButtonForeground
          : availability == .available
            ? ThemeTokens.ink
            : ThemeTokens.soft
      )
      .padding(.horizontal, 10)
      .frame(
        minWidth: 80,
        minHeight: ProductDetailMetrics.optionHeight
      )
      .background(
        isSelected ? ThemeTokens.primaryButton : ThemeTokens.controlSurface,
        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .stroke(
            isSelected
              ? ThemeTokens.ink
              : ThemeTokens.separator.opacity(0.65),
            lineWidth: 0.8
          )
      }
      .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
      .opacity(isIncompatible ? 0.65 : 1)
    }
    // The capsule is compact; the button keeps the full platform hit target.
    .frame(minHeight: ThemeTokens.minimumTap)
    .buttonStyle(.plain)
    .nativePressResponse(scale: 0.985)
    .disabled(isCommerceBusy)
    .accessibilityLabel("\(group.name), \(value)")
    .accessibilityValue(
      optionAccessibilityValue(
        isSelected: isSelected,
        availability: availability
      )
    )
    .accessibilityHint(
      isIncompatible
        ? "Selecting this value also changes another option to a real product combination."
        : ""
    )
  }

  private func optionAccessibilityValue(
    isSelected: Bool,
    availability: ProductOptionValueAvailability
  ) -> String {
    var values = [isSelected ? "Selected" : "Not selected"]
    switch availability {
    case .available:
      values.append("Available")
    case .soldOut:
      values.append("Sold out")
    case .incompatible:
      values.append("Unavailable")
    }
    return values.joined(separator: ", ")
  }

  private var quantityControl: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("QUANTITY")
        .tracking(1.3)
        .themeScaledFont(
          size: 10,
          weight: .semibold,
          maximumScale: 1.5
        )
        .foregroundStyle(ThemeTokens.muted)

      HStack(spacing: 0) {
        quantityButton(
          symbol: "minus",
          label: "Decrease quantity",
          isDisabled: quantity <= 1
        ) {
          quantity = max(1, quantity - 1)
        }

        Text("\(quantity)")
          .themeScaledFont(size: 16, weight: .bold)
          .foregroundStyle(ThemeTokens.ink)
          .frame(width: 48, height: ThemeTokens.minimumTap)
          .accessibilityHidden(true)

        quantityButton(
          symbol: "plus",
          label: "Increase quantity",
          isDisabled: quantity >= 99
        ) {
          quantity = min(99, quantity + 1)
        }
      }
      .padding(.horizontal, 5)
      .frame(height: ProductDetailMetrics.quantityHeight)
      .background(
        ThemeTokens.controlSurface,
        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(ThemeTokens.separator.opacity(0.65), lineWidth: 0.8)
      }
      .fixedSize()
      .accessibilityElement(children: .contain)
      .accessibilityLabel("Quantity")
      .accessibilityValue("\(quantity)")
      .accessibilityIdentifier("product-quantity")
    }
  }

  private func quantityButton(
    symbol: String,
    label: String,
    isDisabled: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button {
      NativeHaptics.play(.selection)
      action()
    } label: {
      Image(systemName: symbol)
        .font(.system(size: 13, weight: .semibold))
        .frame(
          width: ThemeTokens.minimumTap,
          height: ThemeTokens.minimumTap
        )
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .nativePressResponse(scale: 0.985)
    .foregroundStyle(isDisabled ? ThemeTokens.soft : ThemeTokens.ink)
    .disabled(isDisabled || isCommerceBusy)
    .accessibilityLabel(label)
  }

  private var commerceActions: some View {
    VStack(spacing: 8) {
      Button {
        addSelectedVariantToCart()
      } label: {
        Group {
          if isAdding {
            ProgressView().tint(ThemeTokens.primaryButtonForeground)
          } else if selectedVariant?.availableForSale == true {
            Text("Add to cart")
          } else {
            Text("Sold out")
          }
        }
        .themeScaledFont(size: 13.5, weight: .semibold)
        .frame(maxWidth: .infinity)
        .frame(minHeight: ProductDetailMetrics.commerceButtonHeight)
      }
      .buttonStyle(.plain)
      .foregroundStyle(ThemeTokens.primaryButtonForeground)
      .background(
        selectedVariant?.availableForSale == true
          ? ThemeTokens.primaryButton
          : ThemeTokens.soft,
        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
      )
      .disabled(
        isCommerceBusy || selectedVariant?.availableForSale != true
      )
      .accessibilityIdentifier("product-add-to-cart")

      Button {
        buySelectedVariantNow()
      } label: {
        Group {
          if appModel.isBuyNowBusy {
            ProgressView().tint(ThemeTokens.primaryButtonForeground)
          } else {
            Text("Buy it now")
          }
        }
        .themeScaledFont(size: 13.5, weight: .semibold)
        .frame(maxWidth: .infinity)
        .frame(minHeight: ProductDetailMetrics.commerceButtonHeight)
      }
      .buttonStyle(.plain)
      .foregroundStyle(ThemeTokens.primaryButtonForeground)
      .background(
        selectedVariant?.availableForSale == true
          ? ThemeTokens.primaryButton
          : ThemeTokens.soft,
        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
      )
      .disabled(
        isCommerceBusy || selectedVariant?.availableForSale != true
      )
      .accessibilityHint(
        "Starts checkout for only this selection and leaves your bag unchanged."
      )
      .accessibilityIdentifier("product-buy-now")
    }
  }

  private var bookingAction: some View {
    Button {
      NativeHaptics.play(.navigation)
      isBookingPresented = true
    } label: {
      Text("Book an appointment")
        .themeScaledFont(size: 13.5, weight: .semibold)
        .frame(maxWidth: .infinity)
        .frame(minHeight: ProductDetailMetrics.commerceButtonHeight)
    }
    .buttonStyle(.plain)
    .foregroundStyle(ThemeTokens.primaryButtonForeground)
    .background(
      selectedVariant?.availableForSale != true
        ? ThemeTokens.soft
        : ThemeTokens.primaryButton,
      in: RoundedRectangle(cornerRadius: 14, style: .continuous)
    )
    .disabled(selectedVariant?.availableForSale != true || isCommerceBusy)
    .accessibilityIdentifier("product-book-service")
  }

  private var deliveryCard: some View {
    HStack(spacing: 12) {
      Image(systemName: "truck.box")
        .font(.system(size: 18, weight: .medium))
        .foregroundStyle(ThemeTokens.ink)
        .frame(
          width: ProductDetailMetrics.deliveryIconSize,
          height: ProductDetailMetrics.deliveryIconSize
        )
        .background(
          ThemeTokens.cardSurface,
          in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )

      VStack(alignment: .leading, spacing: 4) {
        Text(resolvedDeliveryEstimate.eyebrow.uppercased())
          .tracking(1.1)
          .themeScaledFont(
            size: 9,
            weight: .semibold,
            maximumScale: 1.4
          )
          .foregroundStyle(ThemeTokens.muted)
        Text(resolvedDeliveryEstimate.heading)
          .themeScaledFont(
            size: 13.5,
            weight: .semibold,
            maximumScale: 1.8
          )
          .foregroundStyle(ThemeTokens.ink)
        Text(resolvedDeliveryEstimate.message)
          .themeScaledFont(
            size: 11,
            maximumScale: 1.8
          )
          .foregroundStyle(ThemeTokens.muted)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(14)
    .background(
      ThemeTokens.deliverySurface,
      in: RoundedRectangle(cornerRadius: 17, style: .continuous)
    )
    .overlay {
      RoundedRectangle(cornerRadius: 17, style: .continuous)
        .stroke(ThemeTokens.deliveryAccent.opacity(0.25), lineWidth: 0.8)
    }
    .accessibilityElement(children: .combine)
    .accessibilityIdentifier("product-delivery")
  }

  private var resolvedDeliveryEstimate: ProductDeliveryEstimate {
    presentation.deliveryEstimate ?? .nonVolatileFallback
  }

  private var productDescription: some View {
    Text(product.descriptionText)
      .themeScaledFont(
        size: 15,
        relativeTo: .body,
        maximumScale: 2
      )
      .foregroundStyle(ThemeTokens.ink)
      .lineSpacing(4)
      .fixedSize(horizontal: false, vertical: true)
      .accessibilityIdentifier("product-description")
  }

  private var reviewsRow: some View {
    Button {
      openProductReviews()
    } label: {
      HStack(spacing: 12) {
        Text(
          presentation.reviewSummary.map {
            "Reviews (\($0.reviewCount))"
          } ?? "Reviews"
        )
        .themeScaledFont(size: 18, weight: .bold)

        Spacer(minLength: 8)

        if let summary = presentation.reviewSummary {
          HStack(spacing: 1) {
            ForEach(0..<5, id: \.self) { index in
              Image(
                systemName: ratingSymbol(
                  at: index,
                  average: summary.averageRating
                )
              )
              .font(.system(size: 15, weight: .semibold))
              .foregroundStyle(Color(hex: 0xF5B700))
            }
          }
          .accessibilityHidden(true)
        }

        Image(systemName: "chevron.right")
          .font(.system(size: 13, weight: .semibold))
      }
      .foregroundStyle(ThemeTokens.ink)
      .frame(maxWidth: .infinity)
      .frame(minHeight: 72)
      .contentShape(Rectangle())
      .overlay(alignment: .top) {
        Divider()
      }
      .overlay(alignment: .bottom) {
        Divider()
      }
    }
    .buttonStyle(.plain)
    .accessibilityHint("Opens the verified customer reviews")
    .accessibilityIdentifier("product-reviews")
  }

  @ViewBuilder
  private var detailLoadingState: some View {
    if isLoading || detailErrorMessage == nil {
      HStack(spacing: 10) {
        ProgressView()
          .tint(ThemeTokens.gold)
        Text("Loading product options…")
          .themeScaledFont(size: 13, weight: .semibold)
          .foregroundStyle(ThemeTokens.muted)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 18)
      .accessibilityIdentifier("product-detail-loading")
    } else if let detailErrorMessage {
      InlineErrorView(message: detailErrorMessage) {
        Task { await refreshProduct() }
      }
      .accessibilityIdentifier("product-detail-retry")
    }
  }

  private var recommendationsRail: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("You may also like")
        .themeScaledFont(size: 22, weight: .bold)
        .foregroundStyle(ThemeTokens.ink)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(alignment: .top, spacing: ThemeTokens.productRailGap) {
          ForEach(recommendations) { recommendation in
            ProductCardView(
              product: recommendation,
              width: ThemeTokens.productCardWidth
            )
          }
        }
      }
      .accessibilityIdentifier("product-recommendations")
    }
  }

  private func addSelectedVariantToCart() {
    guard product.hasCompleteDetails,
      !product.isBookingProduct,
      let selectedVariant
    else {
      return
    }
    isAdding = true
    actionErrorMessage = nil
    Task {
      let success = await appModel.addToCart(
        variant: selectedVariant,
        quantity: quantity
      )
      if success {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        appModel.presentCart()
      } else {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        actionErrorMessage = appModel.cartError
      }
      isAdding = false
    }
  }

  private func buySelectedVariantNow() {
    guard product.hasCompleteDetails,
      !product.isBookingProduct,
      let selectedVariant
    else {
      return
    }
    actionErrorMessage = nil
    Task {
      let success = await appModel.buyNow(
        variant: selectedVariant,
        quantity: quantity
      )
      UINotificationFeedbackGenerator().notificationOccurred(
        success ? .success : .error
      )
      if !success {
        actionErrorMessage = appModel.buyNowError
      }
    }
  }

  private func refreshProduct() async {
    guard !isLoading, !product.hasCompleteDetails else { return }
    isLoading = true
    detailErrorMessage = nil
    defer { isLoading = false }
    do {
      let refreshed = try await appModel.product(handle: product.handle)
      let previousVariantID = variantSelection.selectedVariantID
      product = refreshed
      variantSelection.replaceVariants(
        refreshed.variants,
        preferredVariantID: refreshed.variants.contains(where: {
          $0.id == previousVariantID
        })
          ? previousVariantID
          : refreshed.displayVariant?.id
      )
    } catch {
      detailErrorMessage = error.localizedDescription
    }
  }

  private func loadResourceLinkRails() async {
    let resource = ResourceLinkResource.product(handle: product.handle)
    let requestID = UUID()
    resourceLinksRequestID = requestID
    let client = ResourceLinkRailClient.shared

    // Keep theme-authored product navigation visible while the draft/live
    // theme is refreshed. This mirrors the collection behavior and avoids
    // a rail disappearing after a transient response failure.
    if let cached = await client.cachedRails(for: resource) {
      guard resourceLinksRequestID == requestID else { return }
      resourceLinkRails = cached
      resourceLinkRailsResource = resource
    } else if resourceLinkRailsResource != resource {
      resourceLinkRails = .empty
      resourceLinkRailsResource = resource
    }

    do {
      let loaded = try await client.rails(
        for: resource,
        forceRefresh: StorefrontThemeSource.activeDraftThemeID != nil
      )
      try Task.checkCancellation()
      guard resourceLinksRequestID == requestID else { return }
      resourceLinkRails = loaded
      resourceLinkRailsResource = resource

      let linkedCollections = loaded.linkedCollectionResources(
        excluding: resource
      )
      if !linkedCollections.isEmpty {
        Task(priority: .utility) {
          await client.prefetch(linkedCollections)
        }
      }
    } catch {
      guard !Task.isCancelled, resourceLinksRequestID == requestID else {
        return
      }
    }
  }

  private func loadRecommendations() async {
    do {
      let loaded = try await appModel.client.productRecommendations(
        productID: product.id,
        limit: 8
      )
      try Task.checkCancellation()
      recommendations = loaded

      if let summaries = try? await ProductCardReviewsSource.shared
        .summaries(forProductHandle: product.handle)
      {
        try Task.checkCancellation()
        recommendations = recommendations.applying(
          reviewSummaries: summaries
        )
      }
    } catch {
      guard !Task.isCancelled else { return }
      recommendations = []
    }
  }

  private func loadProductPresentation() async {
    let requestID = UUID()
    presentationRequestID = requestID
    presentation = .empty
    isPresentationLoading = true
    defer {
      if presentationRequestID == requestID {
        isPresentationLoading = false
      }
    }
    do {
      let loaded = try await ProductPresentationSource.shared.presentation(
        forProductHandle: product.handle
      )
      try Task.checkCancellation()
      guard presentationRequestID == requestID else { return }
      presentation = loaded
    } catch {
      guard !Task.isCancelled,
        presentationRequestID == requestID
      else {
        return
      }
      presentation = .empty
    }
  }

  private func openProductReviews() {
    isReviewsPresented = true
  }
}

private struct ProductPaymentProviderSheet: View {
  @Environment(\.dismiss) private var dismiss

  let providerName: String
  let information: ProductWalletProviderInformation
  let openExternal: (URL, String) -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        header

        VStack(alignment: .leading, spacing: 20) {
          if let logoURL = information.logoURL {
            PipelineRemoteImage(
              request: NativeImageRequest(
                sourceURL: logoURL,
                pixelWidth: 320
              ),
              accessibilityLabel: providerName
            ) { image in
              image
                .resizable()
                .scaledToFit()
            } placeholder: {
              Text(providerName)
                .themeScaledFont(size: 17, weight: .semibold)
                .foregroundStyle(ThemeTokens.ink)
            }
            .frame(maxWidth: 132, minHeight: 38, maxHeight: 48)
          }

          if let heading = information.heading {
            Text(heading)
              .themeScaledFont(
                size: 25,
                weight: .bold,
                relativeTo: .title2,
                maximumScale: 1.45
              )
              .foregroundStyle(ThemeTokens.ink)
              .fixedSize(horizontal: false, vertical: true)
              .accessibilityAddTraits(.isHeader)
              .accessibilityIdentifier(
                "product-payment-provider-heading"
              )
          }

          if let subheading = information.subheading {
            Text(subheading)
              .themeScaledFont(
                size: 16,
                relativeTo: .body,
                maximumScale: 1.7
              )
              .foregroundStyle(ThemeTokens.muted)
              .fixedSize(horizontal: false, vertical: true)
          }

          if !information.steps.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
              ForEach(
                Array(information.steps.enumerated()),
                id: \.offset
              ) { index, step in
                HStack(alignment: .top, spacing: 12) {
                  Text("\(index + 1)")
                    .themeScaledFont(size: 13, weight: .bold)
                    .foregroundStyle(ThemeTokens.primaryButtonForeground)
                    .frame(width: 26, height: 26)
                    .background(
                      ThemeTokens.ink,
                      in: Circle()
                    )

                  Text(step)
                    .themeScaledFont(
                      size: 15,
                      relativeTo: .body,
                      maximumScale: 1.7
                    )
                    .foregroundStyle(ThemeTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 3)
                }
              }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(
              "product-payment-provider-steps"
            )
          }

          if let caption = information.caption {
            Text(caption)
              .themeScaledFont(
                size: 12,
                relativeTo: .footnote,
                maximumScale: 1.8
              )
              .foregroundStyle(ThemeTokens.muted)
              .fixedSize(horizontal: false, vertical: true)
              .padding(14)
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(
                ThemeTokens.controlSurface,
                in: RoundedRectangle(
                  cornerRadius: 14,
                  style: .continuous
                )
              )
          }

          if let ctaLabel = information.ctaLabel,
            let ctaURL = information.ctaURL
          {
            Button {
              openExternal(ctaURL, ctaLabel)
            } label: {
              HStack(spacing: 7) {
                Text(ctaLabel)
                Image(systemName: "arrow.up.right")
                  .font(.system(size: 12, weight: .semibold))
              }
              .themeScaledFont(size: 15, weight: .semibold)
              .foregroundStyle(ThemeTokens.ink)
              .frame(maxWidth: .infinity)
              .frame(minHeight: 48)
              .background(
                ThemeTokens.controlSurface,
                in: RoundedRectangle(
                  cornerRadius: 14,
                  style: .continuous
                )
              )
              .overlay {
                RoundedRectangle(
                  cornerRadius: 14,
                  style: .continuous
                )
                .stroke(ThemeTokens.separator.opacity(0.65), lineWidth: 0.8)
              }
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens in your browser")
            .accessibilityIdentifier(
              "product-payment-provider-external-link"
            )
          }

          Button {
            dismiss()
          } label: {
            Text("Got It")
              .themeScaledFont(size: 16, weight: .semibold)
              .foregroundStyle(ThemeTokens.primaryButtonForeground)
              .frame(maxWidth: .infinity)
              .frame(minHeight: 50)
              .background(
                ThemeTokens.ink,
                in: RoundedRectangle(
                  cornerRadius: 15,
                  style: .continuous
                )
              )
          }
          .buttonStyle(.plain)
          .accessibilityIdentifier(
            "product-payment-provider-dismiss"
          )
        }
        .padding(.horizontal, ThemeTokens.horizontalPadding)
        .padding(.top, 26)
        .padding(.bottom, 36)
      }
    }
    .background(ThemeTokens.canvas)
    .accessibilityIdentifier("product-payment-provider-sheet")
  }

  private var header: some View {
    HStack(spacing: 12) {
      Text(information.modalTitle ?? providerName)
        .themeScaledFont(
          size: 18,
          weight: .semibold,
          relativeTo: .headline,
          maximumScale: 1.5
        )
        .foregroundStyle(ThemeTokens.ink)
        .lineLimit(2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityAddTraits(.isHeader)

      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(ThemeTokens.ink)
          .frame(width: 44, height: 44)
          .background(
            ThemeTokens.cardSurface.opacity(0.86),
            in: Circle()
          )
          .overlay {
            Circle()
              .stroke(ThemeTokens.separator.opacity(0.65), lineWidth: 0.8)
          }
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Close")
      .accessibilityIdentifier(
        "product-payment-provider-close"
      )
    }
    .padding(.horizontal, ThemeTokens.horizontalPadding)
    .padding(.vertical, 10)
    .background(.ultraThinMaterial)
    .overlay(alignment: .bottom) {
      Divider()
    }
  }
}

private struct CompactProductWishlistButton: View {
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
        width: ProductDetailMetrics.wishlistVisualFootprint,
        height: ProductDetailMetrics.wishlistVisualFootprint
      )
      .frame(
        width: ProductDetailMetrics.wishlistHitTarget,
        height: ProductDetailMetrics.wishlistHitTarget,
        alignment: .topLeading
      )
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .padding(
      .trailing,
      ProductDetailMetrics.wishlistVisualFootprint
        - ProductDetailMetrics.wishlistHitTarget
    )
    .padding(
      .bottom,
      ProductDetailMetrics.wishlistVisualFootprint
        - ProductDetailMetrics.wishlistHitTarget
    )
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

private struct GoogleWalletGMark: View {
  var body: some View {
    Canvas { context, size in
      let center = CGPoint(
        x: size.width / 2,
        y: size.height / 2
      )
      let radius = min(size.width, size.height) * 0.37
      let lineWidth = min(size.width, size.height) * 0.18

      stroke(
        context: &context,
        center: center,
        radius: radius,
        lineWidth: lineWidth,
        color: Color(hex: 0xEA4335),
        from: 200,
        to: 315
      )
      stroke(
        context: &context,
        center: center,
        radius: radius,
        lineWidth: lineWidth,
        color: Color(hex: 0x4285F4),
        from: 315,
        to: 405
      )
      stroke(
        context: &context,
        center: center,
        radius: radius,
        lineWidth: lineWidth,
        color: Color(hex: 0x34A853),
        from: 45,
        to: 135
      )
      stroke(
        context: &context,
        center: center,
        radius: radius,
        lineWidth: lineWidth,
        color: Color(hex: 0xFBBC04),
        from: 135,
        to: 200
      )

      var crossbar = Path()
      crossbar.move(to: center)
      crossbar.addLine(
        to: CGPoint(
          x: center.x + radius,
          y: center.y
        )
      )
      context.stroke(
        crossbar,
        with: .color(Color(hex: 0x4285F4)),
        style: StrokeStyle(
          lineWidth: lineWidth,
          lineCap: .square
        )
      )
    }
    .accessibilityHidden(true)
  }

  private func stroke(
    context: inout GraphicsContext,
    center: CGPoint,
    radius: CGFloat,
    lineWidth: CGFloat,
    color: Color,
    from start: Double,
    to end: Double
  ) {
    var path = Path()
    path.addArc(
      center: center,
      radius: radius,
      startAngle: .degrees(start),
      endAngle: .degrees(end),
      clockwise: false
    )
    context.stroke(
      path,
      with: .color(color),
      style: StrokeStyle(
        lineWidth: lineWidth,
        lineCap: .butt
      )
    )
  }
}
