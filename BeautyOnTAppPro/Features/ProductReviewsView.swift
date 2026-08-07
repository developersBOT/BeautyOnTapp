import SwiftUI

@MainActor
final class ProductReviewsViewModel: ObservableObject {
  @Published private(set) var document: ProductReviewsDocument?
  @Published private(set) var isLoading = false
  @Published private(set) var isLoadingMore = false
  @Published private(set) var isSorting = false
  @Published private(set) var selectedSort: ProductReviewSort =
    .mostRecent
  @Published private(set) var errorMessage: String?

  private let productHandle: String
  private let source: any ProductReviewsProviding
  private var hasLoaded = false

  init(
    productHandle: String,
    source: any ProductReviewsProviding = ProductReviewsSource.shared
  ) {
    self.productHandle = productHandle
    self.source = source
  }

  func loadIfNeeded() async {
    guard !hasLoaded else { return }
    await load(forceRefresh: false)
  }

  func reload() async {
    await load(forceRefresh: true)
  }

  func loadMore() async {
    guard !isLoading, !isLoadingMore, !isSorting,
      let currentDocument = document,
      currentDocument.canLoadMoreReviews,
      let pagination = currentDocument.pagination
    else {
      return
    }

    isLoadingMore = true
    errorMessage = nil
    defer { isLoadingMore = false }

    do {
      let page = try await source.reviewPage(
        for: pagination,
        page: pagination.currentPage + 1,
        sort: selectedSort
      )
      document = currentDocument.merging(
        page,
        replacingCurrentReviews: false
      )
    } catch is CancellationError {
      return
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  func selectSort(_ sort: ProductReviewSort) async {
    guard sort != selectedSort,
      !isLoading,
      !isLoadingMore,
      !isSorting,
      let currentDocument = document,
      let pagination = currentDocument.pagination
    else {
      return
    }

    let previousSort = selectedSort
    selectedSort = sort
    isSorting = true
    errorMessage = nil
    defer { isSorting = false }

    do {
      let page = try await source.reviewPage(
        for: pagination,
        page: 1,
        sort: sort
      )
      document = currentDocument.merging(
        page,
        replacingCurrentReviews: true
      )
    } catch is CancellationError {
      selectedSort = previousSort
    } catch {
      selectedSort = previousSort
      errorMessage = error.localizedDescription
    }
  }

  private func load(forceRefresh: Bool) async {
    guard !isLoading, !isLoadingMore, !isSorting else { return }
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    do {
      let refreshedDocument = try await source.reviews(
        forProductHandle: productHandle,
        forceRefresh: forceRefresh
      )
      if selectedSort == .mostRecent {
        document = refreshedDocument
      } else if let pagination = refreshedDocument.pagination {
        let page = try await source.reviewPage(
          for: pagination,
          page: 1,
          sort: selectedSort
        )
        document = refreshedDocument.merging(
          page,
          replacingCurrentReviews: true
        )
      } else {
        selectedSort = .mostRecent
        document = refreshedDocument
      }
      hasLoaded = true
    } catch is CancellationError {
      return
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}

struct ProductReviewsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) private var openURL
  @StateObject private var viewModel: ProductReviewsViewModel

  private let productTitle: String
  private let productHandle: String
  private let showsCloseButton: Bool

  init(
    productTitle: String,
    productHandle: String,
    showsCloseButton: Bool = true,
    source: any ProductReviewsProviding = ProductReviewsSource.shared
  ) {
    self.productTitle = productTitle
    self.productHandle = productHandle
    self.showsCloseButton = showsCloseButton
    _viewModel = StateObject(
      wrappedValue: ProductReviewsViewModel(
        productHandle: productHandle,
        source: source
      )
    )
  }

  var body: some View {
    NavigationView {
      content
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            if showsCloseButton {
              Button("Done") {
                dismiss()
              }
              .font(.system(size: 16, weight: .semibold))
              .foregroundStyle(ThemeTokens.ink)
              .accessibilityIdentifier("reviews-done")
            } else {
              EmptyView()
            }
          }
        }
    }
    .navigationViewStyle(.stack)
    .task {
      await viewModel.loadIfNeeded()
    }
  }

  @ViewBuilder
  private var content: some View {
    if let document = viewModel.document {
      reviews(document)
    } else if viewModel.isLoading {
      loadingState
    } else if let errorMessage = viewModel.errorMessage {
      errorState(message: errorMessage)
    } else {
      loadingState
    }
  }

  private func reviews(
    _ document: ProductReviewsDocument
  ) -> some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 16) {
        Text(productTitle)
          .themeScaledFont(
            size: 15,
            weight: .semibold,
            relativeTo: .headline,
            maximumScale: 1.8
          )
          .foregroundStyle(ThemeTokens.muted)
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityIdentifier("reviews-product-title")

        summaryCard(document)
        reviewActions(document)

        if document.summary.reviewCount == 0 {
          emptyState(
            title: "No reviews yet",
            message: "Customer reviews will appear here when available."
          )
        } else if document.reviews.isEmpty {
          emptyState(
            title: "Review details unavailable",
            message: "The rating summary loaded, but the review details did not."
          )
        } else {
          if document.hasMoreReviews {
            Text(
              "Showing \(document.reviews.count) of \(document.totalAvailableReviews) reviews"
            )
            .themeScaledFont(
              size: 12,
              relativeTo: .footnote,
              maximumScale: 1.8
            )
            .foregroundStyle(ThemeTokens.muted)
            .accessibilityIdentifier("reviews-page-count")
          }

          ForEach(document.reviews) { review in
            reviewCard(review)
          }

          if document.canLoadMoreReviews {
            loadMoreButton
          }
        }

        if let errorMessage = viewModel.errorMessage {
          ProductReviewsErrorView(message: errorMessage) {
            Task { await viewModel.reload() }
          }
        }
      }
      .padding(.horizontal, ThemeTokens.horizontalPadding)
      .padding(.top, 18)
      .padding(.bottom, 36)
    }
    .background(ThemeTokens.canvas)
    .refreshable {
      await viewModel.reload()
    }
    .accessibilityIdentifier("product-reviews-view")
  }

  private func reviewActions(
    _ document: ProductReviewsDocument
  ) -> some View {
    HStack(spacing: 10) {
      Button {
        openReviewSubmission()
      } label: {
        Label(
          "Write a review",
          systemImage: "square.and.pencil"
        )
        .themeScaledFont(
          size: 13,
          weight: .semibold,
          maximumScale: 1.5
        )
        .lineLimit(1)
        .frame(maxWidth: .infinity)
        .frame(minHeight: ThemeTokens.minimumTap)
      }
      .buttonStyle(.plain)
      .foregroundStyle(ThemeTokens.primaryButtonForeground)
      .background(
        ThemeTokens.primaryButton,
        in: RoundedRectangle(
          cornerRadius: 12,
          style: .continuous
        )
      )
      .accessibilityHint(
        "Opens the verified review form in Safari"
      )
      .accessibilityIdentifier("reviews-write-review")

      if document.summary.reviewCount > 1,
        document.pagination != nil
      {
        Menu {
          ForEach(ProductReviewSort.allCases) { sort in
            Button {
              Task {
                await viewModel.selectSort(sort)
              }
            } label: {
              if sort == viewModel.selectedSort {
                Label(sort.title, systemImage: "checkmark")
              } else {
                Text(sort.title)
              }
            }
          }
        } label: {
          HStack(spacing: 7) {
            if viewModel.isSorting {
              ProgressView()
                .controlSize(.small)
            } else {
              Image(systemName: "arrow.up.arrow.down")
                .accessibilityHidden(true)
            }

            Text(viewModel.selectedSort.title)
              .lineLimit(1)
          }
          .themeScaledFont(
            size: 13,
            weight: .semibold,
            maximumScale: 1.4
          )
          .foregroundStyle(ThemeTokens.ink)
          .frame(maxWidth: .infinity)
          .frame(minHeight: ThemeTokens.minimumTap)
          .background(
            ThemeTokens.controlSurface,
            in: RoundedRectangle(
              cornerRadius: 12,
              style: .continuous
            )
          )
          .overlay {
            RoundedRectangle(
              cornerRadius: 12,
              style: .continuous
            )
            .stroke(ThemeTokens.separator.opacity(0.65), lineWidth: 0.8)
          }
        }
        .disabled(viewModel.isSorting || viewModel.isLoadingMore)
        .accessibilityLabel(
          "Sort reviews, \(viewModel.selectedSort.title)"
        )
        .accessibilityIdentifier("reviews-sort")
      }
    }
  }

  private var loadMoreButton: some View {
    Button {
      Task {
        await viewModel.loadMore()
      }
    } label: {
      HStack(spacing: 8) {
        if viewModel.isLoadingMore {
          ProgressView()
            .tint(ThemeTokens.ink)
        }
        Text(
          viewModel.isLoadingMore
            ? "Loading more…"
            : "Load more reviews"
        )
        .themeScaledFont(
          size: 14,
          weight: .semibold,
          maximumScale: 1.6
        )
      }
      .frame(maxWidth: .infinity)
      .frame(minHeight: ThemeTokens.minimumTap)
    }
    .buttonStyle(.plain)
    .foregroundStyle(ThemeTokens.ink)
    .background(
      ThemeTokens.controlSurface,
      in: RoundedRectangle(
        cornerRadius: 12,
        style: .continuous
      )
    )
    .overlay {
      RoundedRectangle(
        cornerRadius: 12,
        style: .continuous
      )
      .stroke(ThemeTokens.separator.opacity(0.65), lineWidth: 0.8)
    }
    .disabled(viewModel.isLoadingMore)
    .accessibilityIdentifier("reviews-load-more")
  }

  private func openReviewSubmission() {
    guard
      let url = try? ProductReviewSubmissionFlow.requestURL(
        forProductHandle: productHandle
      )
    else {
      return
    }
    openURL(url)
  }

  private func summaryCard(
    _ document: ProductReviewsDocument
  ) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(alignment: .center, spacing: 16) {
        VStack(alignment: .leading, spacing: 4) {
          Text(
            document.summary.averageRating.formatted(
              .number.precision(.fractionLength(1...2))
            )
          )
          .themeScaledFont(
            size: 34,
            weight: .bold,
            relativeTo: .largeTitle,
            maximumScale: 1.5
          )
          .foregroundStyle(ThemeTokens.ink)

          ReviewStars(
            rating: document.summary.averageRating,
            size: 16
          )

          Text(
            document.summary.reviewCount == 1
              ? "Based on 1 review"
              : "Based on \(document.summary.reviewCount) reviews"
          )
          .themeScaledFont(
            size: 12,
            relativeTo: .footnote,
            maximumScale: 1.8
          )
          .foregroundStyle(ThemeTokens.muted)
        }

        if !document.distribution.isEmpty {
          Divider()
          distribution(document.distribution)
        }
      }
    }
    .padding(18)
    .background(
      ThemeTokens.cardSurface,
      in: RoundedRectangle(cornerRadius: 18, style: .continuous)
    )
    .overlay {
      RoundedRectangle(cornerRadius: 18, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.65), lineWidth: 0.8)
    }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("reviews-summary")
  }

  private func distribution(
    _ values: [ProductReviewDistribution]
  ) -> some View {
    VStack(spacing: 5) {
      ForEach(values) { value in
        HStack(spacing: 6) {
          Text("\(value.rating)")
            .themeScaledFont(
              size: 11,
              weight: .semibold,
              maximumScale: 1.6
            )
            .foregroundStyle(ThemeTokens.muted)
            .frame(width: 10, alignment: .trailing)

          Image(systemName: "star.fill")
            .font(.system(size: 8, weight: .semibold))
            .foregroundStyle(Color(hex: 0xF5B700))
            .accessibilityHidden(true)

          ProgressView(
            value: Double(value.percentage),
            total: 100
          )
          .progressViewStyle(.linear)
          .tint(Color(hex: 0xF5B700))
          .frame(minWidth: 58)

          Text("\(value.count)")
            .themeScaledFont(
              size: 10,
              relativeTo: .caption2,
              maximumScale: 1.6
            )
            .foregroundStyle(ThemeTokens.muted)
            .frame(minWidth: 16, alignment: .trailing)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
          "\(value.count) reviews with \(value.rating) stars"
        )
      }
    }
    .frame(maxWidth: .infinity)
  }

  private func reviewCard(_ review: ProductReview) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .top, spacing: 10) {
        ReviewStars(
          rating: Double(review.rating),
          size: 14
        )

        Spacer(minLength: 8)

        if let publishedAt = review.publishedAt {
          Text(
            publishedAt.formatted(
              date: .abbreviated,
              time: .omitted
            )
          )
          .themeScaledFont(
            size: 11,
            relativeTo: .caption,
            maximumScale: 1.8
          )
          .foregroundStyle(ThemeTokens.muted)
        }
      }

      if let title = review.title {
        Text(title)
          .themeScaledFont(
            size: 16,
            weight: .bold,
            relativeTo: .headline,
            maximumScale: 1.8
          )
          .foregroundStyle(ThemeTokens.ink)
          .fixedSize(horizontal: false, vertical: true)
      }

      if let body = review.body {
        Text(body)
          .themeScaledFont(
            size: 14,
            relativeTo: .body,
            maximumScale: 2
          )
          .foregroundStyle(ThemeTokens.ink)
          .lineSpacing(3)
          .fixedSize(horizontal: false, vertical: true)
      }

      if review.author != nil || review.isVerifiedBuyer {
        HStack(spacing: 7) {
          if let author = review.author {
            Text(author)
              .themeScaledFont(
                size: 12,
                weight: .semibold,
                maximumScale: 1.8
              )
              .foregroundStyle(ThemeTokens.muted)
          }

          if review.isVerifiedBuyer {
            Label("Verified", systemImage: "checkmark.seal.fill")
              .labelStyle(.titleAndIcon)
              .themeScaledFont(
                size: 10,
                weight: .semibold,
                maximumScale: 1.6
              )
              .foregroundStyle(ThemeTokens.success)
          }
        }
      }

      if let merchantReply = review.merchantReply {
        VStack(alignment: .leading, spacing: 5) {
          Text("Store response")
            .themeScaledFont(
              size: 11,
              weight: .bold,
              maximumScale: 1.7
            )
            .foregroundStyle(ThemeTokens.ink)
          Text(merchantReply)
            .themeScaledFont(
              size: 12,
              relativeTo: .footnote,
              maximumScale: 1.9
            )
            .foregroundStyle(ThemeTokens.muted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          ThemeTokens.controlSurface,
          in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
      }
    }
    .padding(.vertical, 18)
    .overlay(alignment: .top) {
      Divider()
    }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("review-card-\(review.id)")
  }

  private var loadingState: some View {
    VStack(spacing: 14) {
      ProgressView()
        .tint(ThemeTokens.gold)
      Text("Loading reviews…")
        .themeScaledFont(size: 13, weight: .semibold)
        .foregroundStyle(ThemeTokens.muted)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ThemeTokens.canvas)
    .accessibilityIdentifier("reviews-loading")
  }

  private func errorState(message: String) -> some View {
    ProductReviewsErrorView(message: message) {
      Task { await viewModel.reload() }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ThemeTokens.canvas)
    .accessibilityIdentifier("reviews-error")
  }

  private func emptyState(
    title: String,
    message: String
  ) -> some View {
    VStack(spacing: 8) {
      Image(systemName: "text.bubble")
        .font(.system(size: 28, weight: .light))
        .foregroundStyle(ThemeTokens.soft)
        .accessibilityHidden(true)

      Text(title)
        .themeScaledFont(size: 16, weight: .bold)
        .foregroundStyle(ThemeTokens.ink)

      Text(message)
        .themeScaledFont(
          size: 13,
          relativeTo: .footnote,
          maximumScale: 1.8
        )
        .foregroundStyle(ThemeTokens.muted)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 28)
    .accessibilityElement(children: .combine)
    .accessibilityIdentifier("reviews-empty")
  }
}

private struct ProductReviewsErrorView: View {
  let message: String
  let retry: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "arrow.clockwise.circle")
        .font(.system(size: 26, weight: .regular))
        .foregroundStyle(ThemeTokens.muted)
        .accessibilityHidden(true)

      Text(message)
        .themeScaledFont(
          size: 13,
          relativeTo: .footnote,
          maximumScale: 1.8
        )
        .foregroundStyle(ThemeTokens.muted)
        .multilineTextAlignment(.center)

      Button("Try Again", action: retry)
        .buttonStyle(.bordered)
        .tint(ThemeTokens.ink)
    }
    .padding(20)
    .accessibilityElement(children: .contain)
  }
}

private struct ReviewStars: View {
  let rating: Double
  let size: CGFloat

  var body: some View {
    HStack(spacing: 1) {
      ForEach(0..<5, id: \.self) { index in
        Image(systemName: symbol(at: index))
          .font(.system(size: size, weight: .semibold))
          .foregroundStyle(Color(hex: 0xF5B700))
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
      "\(rating.formatted(.number.precision(.fractionLength(0...2)))) out of 5 stars"
    )
  }

  private func symbol(at index: Int) -> String {
    let remainder = rating - Double(index)
    if remainder >= 0.75 {
      return "star.fill"
    }
    if remainder >= 0.25 {
      return "star.leadinghalf.filled"
    }
    return "star"
  }
}
