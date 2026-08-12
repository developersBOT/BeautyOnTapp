import SwiftUI

struct CollectionView: View {
  @EnvironmentObject private var appModel: AppModel
  let title: String
  let handle: String
  let showsNavigationTitle: Bool

  @State private var products: [StoreProduct] = []
  @State private var pageInfo = StorefrontPageInfo(hasNextPage: false, endCursor: nil)
  @State private var errorMessage: String?
  @State private var isLoading = false
  @State private var sortOption: CollectionSortOption = .featured
  @State private var activeRequestID: UUID?
  @State private var resourceLinkRails = ResourceLinkRails.empty
  @State private var resourceLinkRailsResource: ResourceLinkResource?
  @State private var resourceLinksRequestID: UUID?
  @State private var loadedPageNumber = 0
  @State private var reviewRequestGeneration = UUID()

  private let columns = [
    GridItem(
      .flexible(maximum: ThemeTokens.productGridCardMaxWidth),
      spacing: 10,
      alignment: .top
    ),
    GridItem(
      .flexible(maximum: ThemeTokens.productGridCardMaxWidth),
      spacing: 10,
      alignment: .top
    ),
  ]

  init(
    title: String,
    handle: String,
    showsNavigationTitle: Bool = true
  ) {
    self.title = title
    self.handle = handle
    self.showsNavigationTitle = showsNavigationTitle
  }

  var body: some View {
    ScrollView {
      LazyVStack(
        alignment: .leading,
        spacing: 0,
        pinnedViews: [.sectionHeaders]
      ) {
        StoreHeader(
          appModel: appModel,
          presentation: .primary
        )

        Section {
          // Do not replace the collection with gray placeholder rails while
          // the real Shopify links are resolving. The products are already
          // usable at this point, so a placeholder creates a visible flash
          // and pushes the grid down before snapping back into place.
          ResourceLinkRailsView(rails: resourceLinkRails) {
            title,
            link in
            appModel.openThemeLink(title: title, link: link)
          }

          collectionToolbar

          if let errorMessage, products.isEmpty {
            InlineErrorView(message: errorMessage) {
              Task { await reload(forceRefresh: true) }
            }
          } else {
            LazyVGrid(columns: columns, spacing: 9) {
              ForEach(products) { product in
                ProductCardView(product: product, width: nil)
              }
            }
            .padding(.horizontal, ThemeTokens.horizontalPadding)

            if isLoading {
              ProgressView()
                .tint(ThemeTokens.gold)
                .frame(maxWidth: .infinity)
                .padding()
            } else if pageInfo.hasNextPage {
              Button {
                Task { await loadNextPage() }
              } label: {
                Text("LOAD MORE")
                  .tracking(0.5)
                  .themeScaledFont(size: 11, weight: .bold)
                  .frame(maxWidth: .infinity)
                  .frame(height: 48)
              }
              .buttonStyle(.plain)
              .foregroundStyle(ThemeTokens.primaryButtonForeground)
              .background(ThemeTokens.primaryButton, in: Capsule())
              .padding(.horizontal, ThemeTokens.horizontalPadding)
            }
          }
        } header: {
          StoreHeader(
            appModel: appModel,
            presentation: .tabs,
            activeCollectionHandle: handle
          )
          .zIndex(1)
        }
      }
    }
    .accessibilityIdentifier("collection-\(handle)")
    .background(ThemeTokens.canvas)
    .nativeSoftTopScrollEdgeEffect()
    .navigationTitle(showsNavigationTitle ? title : "")
    .navigationBarHidden(!showsNavigationTitle)
    .navigationBarTitleDisplayMode(.inline)
    .nativeSwipeBack()
    .task(id: "\(handle)-\(sortOption.id)") {
      await reload()
    }
    .task(id: "resource-links-\(handle)") {
      await loadResourceLinkRails()
    }
    .refreshable {
      async let products: Void = reload(forceRefresh: true)
      async let links: Void = loadResourceLinkRails(forceRefresh: true)
      _ = await (products, links)
    }
  }

  private var collectionToolbar: some View {
    HStack {
      Spacer()
      Menu {
        Picker("Sort", selection: $sortOption) {
          ForEach(CollectionSortOption.allCases) { option in
            Text(option.label).tag(option)
          }
        }
      } label: {
        HStack(spacing: 9) {
          Image(systemName: "arrow.up.arrow.down")
            .font(.system(size: 16, weight: .semibold))
          Text(sortOption.label)
            .themeScaledFont(size: 12, weight: .semibold)
          Image(systemName: "chevron.down")
            .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(ThemeTokens.ink)
        .frame(minHeight: ThemeTokens.minimumTap)
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Sort products")
      .accessibilityValue(sortOption.label)
    }
    .padding(.horizontal, ThemeTokens.horizontalPadding)
  }

  private func reload(forceRefresh: Bool = false) async {
    let requestID = UUID()
    let requestedSort = sortOption
    activeRequestID = requestID
    isLoading = true
    errorMessage = nil
    defer {
      if activeRequestID == requestID {
        isLoading = false
      }
    }
    do {
      let page = try await appModel.collection(
        handle: handle,
        first: 24,
        sort: requestedSort.sort,
        reverse: requestedSort.reverse,
        forceRefresh: forceRefresh
      )
      guard activeRequestID == requestID,
        sortOption == requestedSort
      else {
        return
      }
      products = page.products
      pageInfo = page.pageInfo
      loadedPageNumber = 1
      let reviewGeneration = UUID()
      reviewRequestGeneration = reviewGeneration
      Task {
        await applyReviewSummaries(
          page: 1,
          generation: reviewGeneration,
          forceRefresh: forceRefresh
        )
      }
    } catch is CancellationError {
      return
    } catch {
      guard activeRequestID == requestID else { return }
      errorMessage = error.localizedDescription
    }
  }

  private func loadNextPage() async {
    guard !isLoading, let cursor = pageInfo.endCursor else { return }
    let requestID = UUID()
    let requestedSort = sortOption
    activeRequestID = requestID
    isLoading = true
    errorMessage = nil
    defer {
      if activeRequestID == requestID {
        isLoading = false
      }
    }
    do {
      let page = try await appModel.collection(
        handle: handle,
        first: 24,
        after: cursor,
        sort: requestedSort.sort,
        reverse: requestedSort.reverse
      )
      guard activeRequestID == requestID,
        sortOption == requestedSort,
        pageInfo.endCursor == cursor
      else {
        return
      }
      products.append(contentsOf: page.products)
      pageInfo = page.pageInfo
      let nextPageNumber = loadedPageNumber + 1
      loadedPageNumber = nextPageNumber
      let reviewGeneration = reviewRequestGeneration
      Task {
        await applyReviewSummaries(
          page: nextPageNumber,
          generation: reviewGeneration
        )
      }
    } catch is CancellationError {
      return
    } catch {
      guard activeRequestID == requestID else { return }
      errorMessage = error.localizedDescription
    }
  }

  private func loadResourceLinkRails(forceRefresh: Bool = false) async {
    let resource = ResourceLinkResource.collection(handle: handle)
    let requestID = UUID()
    resourceLinksRequestID = requestID
    let client = ResourceLinkRailClient.shared

    // Render a previously verified rail first. This keeps collection pills
    // and breadcrumbs stable while Shopify is refreshing the current theme.
    if let cached = await client.cachedRails(for: resource) {
      guard resourceLinksRequestID == requestID else { return }
      resourceLinkRails = cached
      resourceLinkRailsResource = resource
    } else if resourceLinkRailsResource != resource {
      // A different collection must never inherit the previous collection's
      // pills while its own first request is pending.
      resourceLinkRails = .empty
      resourceLinkRailsResource = resource
    }

    do {
      let loaded = try await client.rails(
        for: resource,
        forceRefresh: forceRefresh
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
      // Keep the last valid rail on screen. A failed refresh previously
      // replaced valid pills with an empty rail, which made them appear to
      // load and then disappear.
      guard !Task.isCancelled, resourceLinksRequestID == requestID else {
        return
      }
    }
  }

  private func applyReviewSummaries(
    page: Int,
    generation: UUID,
    forceRefresh: Bool = false
  ) async {
    guard
      let summaries = try? await ProductCardReviewsSource.shared
        .summaries(
          forCollectionHandle: handle,
          page: page,
          forceRefresh: forceRefresh
        ),
      reviewRequestGeneration == generation,
      !Task.isCancelled
    else {
      return
    }
    products = products.applying(reviewSummaries: summaries)
  }
}

private enum CollectionSortOption: String, CaseIterable, Identifiable {
  case featured
  case bestSelling
  case newest
  case priceLow
  case priceHigh
  case title

  var id: String { rawValue }

  var label: String {
    switch self {
    case .featured: return "Featured"
    case .bestSelling: return "Best selling"
    case .newest: return "Newest"
    case .priceLow: return "Price: low to high"
    case .priceHigh: return "Price: high to low"
    case .title: return "A–Z"
    }
  }

  var sort: CollectionSort {
    switch self {
    case .featured: return .featured
    case .bestSelling: return .bestSelling
    case .newest: return .newest
    case .priceLow, .priceHigh: return .price
    case .title: return .title
    }
  }

  var reverse: Bool {
    switch self {
    case .priceHigh: return true
    default: return false
    }
  }
}
