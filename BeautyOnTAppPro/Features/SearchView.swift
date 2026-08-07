import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appModel: AppModel

    @State private var query = ""
    @State private var products: [StoreProduct] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var activeRequestID: UUID?
    @State private var pageInfo = StorefrontPageInfo.end
    @State private var loadedPageNumber = 0

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

    var body: some View {
        NavigationView {
            ScrollView {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(ThemeTokens.muted)
                        Text("Search BeautyOnTApp")
                            .font(.title3.bold())
                        Text("Find a product, brand or concern.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else if isLoading && products.isEmpty {
                    ProgressView()
                        .tint(ThemeTokens.gold)
                        .padding(.top, 80)
                } else if let errorMessage, products.isEmpty {
                    InlineErrorView(message: errorMessage) {
                        Task { await search() }
                    }
                } else if products.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.title)
                        Text("No products found")
                            .font(.headline)
                        Text("Try another product, brand or concern.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 80)
                } else {
                    VStack(spacing: 12) {
                        LazyVGrid(columns: columns, spacing: 9) {
                            ForEach(products) { product in
                                ProductCardView(product: product, width: nil)
                            }
                        }

                        if isLoading {
                            ProgressView()
                                .tint(ThemeTokens.gold)
                                .padding(.vertical, 16)
                        } else if let errorMessage {
                            InlineErrorView(message: errorMessage) {
                                Task { await loadNextPage() }
                            }
                        } else if pageInfo.hasNextPage {
                            Button {
                                Task { await loadNextPage() }
                            } label: {
                                Text("Load more")
                                    .themeScaledFont(size: 13, weight: .semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: ThemeTokens.minimumTap)
                            }
                            .buttonStyle(.bordered)
                            .tint(ThemeTokens.ink)
                            .accessibilityIdentifier("search-load-more")
                            .onAppear {
                                Task { await loadNextPage() }
                            }
                        }
                    }
                    .padding(ThemeTokens.horizontalPadding)
                }
            }
            .accessibilityIdentifier("search-screen")
            .background(ThemeTokens.canvas)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Products, brands and concerns"
            )
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.body.weight(.semibold))
                }
            }
        }
        .navigationViewStyle(.stack)
        .accessibilityIdentifier("search-modal")
        .task(id: query) {
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
                try Task.checkCancellation()
                await search()
            } catch {
                return
            }
        }
    }

    private func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            activeRequestID = nil
            products = []
            pageInfo = .end
            loadedPageNumber = 0
            errorMessage = nil
            isLoading = false
            return
        }

        let requestID = UUID()
        activeRequestID = requestID
        products = []
        pageInfo = .end
        isLoading = true
        errorMessage = nil
        defer {
            if activeRequestID == requestID {
                isLoading = false
            }
        }
        do {
            let page = try await appModel.client.search(trimmed, first: 30)
            guard activeRequestID == requestID,
                  query.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed
            else {
                return
            }
            products = page.products
            pageInfo = page.pageInfo
            loadedPageNumber = 1

            if let summaries = try? await ProductCardReviewsSource.shared
                .summaries(forSearchQuery: trimmed)
            {
                guard activeRequestID == requestID,
                      query.trimmingCharacters(in: .whitespacesAndNewlines)
                        == trimmed
                else {
                    return
                }
                products = products.applying(
                    reviewSummaries: summaries
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
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !isLoading,
              pageInfo.hasNextPage,
              let cursor = pageInfo.endCursor
        else {
            return
        }

        let requestID = UUID()
        activeRequestID = requestID
        isLoading = true
        errorMessage = nil
        defer {
            if activeRequestID == requestID {
                isLoading = false
            }
        }

        do {
            let page = try await appModel.client.search(
                trimmed,
                first: 30,
                after: cursor
            )
            guard activeRequestID == requestID,
                  query.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed,
                  pageInfo.endCursor == cursor
            else {
                return
            }

            var existingIDs = Set(products.map(\.id))
            products.append(
                contentsOf: page.products.filter { existingIDs.insert($0.id).inserted }
            )
            pageInfo = page.pageInfo
            let nextPageNumber = loadedPageNumber + 1
            loadedPageNumber = nextPageNumber

            if let summaries = try? await ProductCardReviewsSource.shared
                .summaries(
                    forSearchQuery: trimmed,
                    page: nextPageNumber
                )
            {
                guard activeRequestID == requestID,
                      query.trimmingCharacters(in: .whitespacesAndNewlines)
                        == trimmed
                else {
                    return
                }
                products = products.applying(
                    reviewSummaries: summaries
                )
            }
        } catch is CancellationError {
            return
        } catch {
            guard activeRequestID == requestID else { return }
            errorMessage = error.localizedDescription
        }
    }
}
