import SwiftUI

private struct NativeLovesItem: Identifiable, Sendable {
  let entry: WishlistEntry
  let product: StoreProduct
  let variant: StoreVariant

  var id: String { entry.variantID }
}

struct LovesView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var appModel: AppModel

  @State private var items: [NativeLovesItem] = []
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var loadGeneration = 0

  var body: some View {
    Group {
      if #available(iOS 16.0, *) {
        NavigationStack {
          content
        }
      } else {
        NavigationView {
          content
        }
        .navigationViewStyle(.stack)
      }
    }
    .task {
      await load()
    }
  }

  private var content: some View {
    ScrollView {
      Group {
        if isLoading && items.isEmpty {
          loadingState
        } else if let errorMessage, items.isEmpty {
          InlineErrorView(message: errorMessage) {
            Task { await load() }
          }
          .padding(.top, 80)
        } else if items.isEmpty {
          emptyState
        } else {
          LazyVGrid(
            columns: [
              GridItem(
                .flexible(
                  minimum: 0,
                  maximum: ThemeTokens.productGridCardMaxWidth
                ),
                spacing: 10,
                alignment: .top
              ),
              GridItem(
                .flexible(
                  minimum: 0,
                  maximum: ThemeTokens.productGridCardMaxWidth
                ),
                spacing: 10,
                alignment: .top
              ),
            ],
            spacing: 9
          ) {
            ForEach(items) { item in
              LovesProductCard(item: item) {
                await remove(item)
              }
            }
          }
            .padding(.horizontal, ThemeTokens.horizontalPadding)
          .padding(.vertical, 14)
        }
      }
      .frame(maxWidth: .infinity)
    }
    .background(ThemeTokens.canvas)
    .navigationTitle("Loves")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
          dismiss()
        }
        .font(.body.weight(.semibold))
        .foregroundStyle(ThemeTokens.ink)
        .accessibilityIdentifier("loves-close")
      }
    }
    .refreshable {
      await load()
    }
    .accessibilityIdentifier("loves-view")
  }

  private var loadingState: some View {
    VStack(spacing: 14) {
      ProgressView()
        .tint(ThemeTokens.gold)
      Text("Loading your Loves…")
        .themeScaledFont(size: 14, weight: .medium)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 120)
    .accessibilityIdentifier("loves-loading")
  }

  private var emptyState: some View {
    VStack(spacing: 14) {
      Image(systemName: "heart")
        .font(.system(size: 40, weight: .light))
      Text("Your Loves are waiting")
        .themeScaledFont(size: 20, weight: .bold)
      Text("Tap the heart on any product to save it here.")
        .themeScaledFont(size: 14)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .foregroundStyle(ThemeTokens.ink)
    .padding(.horizontal, 32)
    .padding(.top, 110)
    .accessibilityIdentifier("loves-empty")
  }

  private func load() async {
    guard !isLoading else { return }
    loadGeneration &+= 1
    let generation = loadGeneration

    isLoading = true
    errorMessage = nil
    appModel.activateWishlistBridge()
    defer {
      if generation == loadGeneration {
        isLoading = false
      }
    }

    var entries: [WishlistEntry] = []
    var totalCount = 0

    for pageNumber in 1 ... 20 {
      guard generation == loadGeneration else { return }
      guard let page = await appModel.wishlistBridge.page(
        limit: 50,
        number: pageNumber
      ) else {
        errorMessage =
          "Your Loves couldn’t refresh. Check your connection and try again."
        return
      }

      if pageNumber == 1 {
        totalCount = page.totalCount
      }
      entries.append(contentsOf: page.entries)

      if entries.count >= totalCount || page.entries.isEmpty {
        break
      }
    }

    let uniqueEntries = entries.reduce(into: [WishlistEntry]()) {
      result,
      entry in
      guard !result.contains(where: { $0.variantID == entry.variantID }) else {
        return
      }
      result.append(entry)
    }

    let client = appModel.client
    let loaded = await withTaskGroup(
      of: (Int, NativeLovesItem?).self,
      returning: [NativeLovesItem].self
    ) { group in
      for (index, entry) in uniqueEntries.enumerated() {
        group.addTask {
          guard
            let product = try? await client.product(handle: entry.handle),
            ShopifyNumericID.product(from: product.id) == entry.productID,
            let variant = product.variants.first(where: {
              ShopifyNumericID.variant(from: $0.id) == entry.variantID
            })
          else {
            return (index, nil)
          }

          let reviewSummary = try? await ProductReviewsSource.shared
            .reviews(forProductHandle: product.handle)
            .summary

          return (
            index,
            NativeLovesItem(
              entry: entry,
              product: product.applying(
                reviewSummary: reviewSummary ?? product.reviewSummary
              ),
              variant: variant
            )
          )
        }
      }

      var indexed: [(Int, NativeLovesItem)] = []
      for await (index, item) in group {
        if let item {
          indexed.append((index, item))
        }
      }
      return indexed.sorted { $0.0 < $1.0 }.map(\.1)
    }

    guard generation == loadGeneration else { return }
    if !uniqueEntries.isEmpty && loaded.isEmpty {
      errorMessage =
        "Your saved products couldn’t refresh. Check your connection and try again."
      return
    }
    items = loaded
  }

  private func remove(_ item: NativeLovesItem) async {
    let success = await appModel.toggleWishlist(
      product: item.product,
      variant: item.variant
    )
    guard success else {
      errorMessage =
        "That product couldn’t be removed from Loves. Please try again."
      return
    }

    withAnimation(ThemeTokens.controlSpring) {
      items.removeAll { $0.id == item.id }
    }
    UINotificationFeedbackGenerator().notificationOccurred(.success)
  }
}

private struct LovesProductCard: View {
  @EnvironmentObject private var appModel: AppModel

  let item: NativeLovesItem
  let onRemove: () async -> Void

  @State private var isAdding = false
  @State private var isRemoving = false

  var body: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .topLeading) {
        NativeNavigationLink(route: .product(item.product)) {
          VStack(spacing: 0) {
            RemoteProductImage(
              url: item.variant.image?.url ?? item.product.primaryImageURL,
              aspectRatio: ThemeTokens.productCardImageAspectRatio,
              pixelWidth: 480
            )
            .scaleEffect(ThemeTokens.productCardImageScale)
            .frame(maxWidth: .infinity, alignment: .center)
            .aspectRatio(
              ThemeTokens.productCardImageAspectRatio,
              contentMode: .fit
            )

            Text(item.product.vendor.uppercased())
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

            Text(item.product.title)
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

            if item.variant.title != "Default Title" {
              Text(item.variant.title)
                .themeScaledFont(
                  size: ThemeTokens.productCardTextSize,
                  weight: .medium,
                  maximumScale: 1.1
                )
                .foregroundStyle(ThemeTokens.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity)
                .frame(height: ThemeTokens.productCardRatingHeight)
            } else {
              Color.clear
                .frame(height: ThemeTokens.productCardRatingHeight)
            }

            lovesRating
              .frame(height: ThemeTokens.productCardRatingHeight)

            Text(item.variant.price.text)
              .themeScaledFont(
                size: ThemeTokens.productCardTextSize,
                weight: .bold,
                maximumScale: 1.1
              )
              .foregroundStyle(ThemeTokens.ink)
              .lineLimit(1)
              .minimumScaleFactor(0.8)
              .frame(maxWidth: .infinity, alignment: .center)
              .frame(height: ThemeTokens.productCardPriceHeight)
          }
          .padding(.horizontal, 8)
          .padding(.top, 7)
        }
        .buttonStyle(.plain)

        Button {
          guard !isRemoving else { return }
          isRemoving = true
          Task {
            await onRemove()
            isRemoving = false
          }
        } label: {
          Group {
            if isRemoving {
            ProgressView()
                .tint(ThemeTokens.ink)
            } else {
              Image(systemName: "heart.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(ThemeTokens.dangerAccent)
            }
          }
          .frame(
            width: ThemeTokens.minimumTap,
            height: ThemeTokens.minimumTap
          )
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remove \(item.product.title) from Loves")
        .accessibilityIdentifier(
          "loves-remove-\(item.product.handle)"
        )
      }

      Button {
        guard item.variant.availableForSale else { return }
        isAdding = true
        Task {
          let success = await appModel.addToCart(variant: item.variant)
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
            Text(item.variant.availableForSale ? "Add to cart" : "Sold out")
              .themeScaledFont(
                size: ThemeTokens.productCardTextSize,
                weight: .bold,
                maximumScale: 1.15
              )
              .minimumScaleFactor(0.86)
          }
        }
        .frame(maxWidth: .infinity)
        .frame(height: ThemeTokens.minimumTap)
      }
      .buttonStyle(.plain)
      .nativePressResponse(scale: 0.97)
      .foregroundStyle(
        item.variant.availableForSale
          ? ThemeTokens.ink
          : ThemeTokens.muted
      )
      .background {
        ProductCardActionSurface(
          isEnabled: item.variant.availableForSale
            && !isAdding
            && !appModel.isCartBusy
        )
          .frame(height: 34)
      }
      .disabled(
        !item.variant.availableForSale ||
        isAdding ||
        isRemoving ||
        appModel.isCartBusy
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
    .shadow(
      color: Color(hex: 0x281E0C).opacity(0.08),
      radius: 7,
      y: 3
    )
    .accessibilityIdentifier("loves-product-\(item.product.handle)")
  }

  @ViewBuilder
  private var lovesRating: some View {
    if let summary = item.product.reviewSummary {
      HStack(spacing: 2.5) {
        HStack(spacing: 1) {
          ForEach(1...5, id: \.self) { position in
            Image(
              systemName: ratingSymbol(
                position: position,
                averageRating: summary.averageRating
              )
            )
            .font(.system(size: 9, weight: .semibold))
          }
        }
        .foregroundStyle(Color(hex: 0xF5B301))

        Text("(\(summary.reviewCount))")
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
        "\(summary.averageRating.formatted(.number.precision(.fractionLength(0...1)))) out of 5, "
          + "\(summary.reviewCount) reviews"
      )
    } else {
      Color.clear
        .frame(maxWidth: .infinity)
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
}
