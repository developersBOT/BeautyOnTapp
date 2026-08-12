import SwiftUI
import UIKit

struct BlogFeedView: View {
  @EnvironmentObject private var appModel: AppModel
  let feed: StoreBlogFeed

  @State private var articles: [StoreArticle]
  @State private var pageInfo: StorefrontPageInfo
  @State private var isLoadingFirstPage = false
  @State private var isLoadingMore = false
  @State private var loadError: String?

  init(feed: StoreBlogFeed) {
    self.feed = feed
    _articles = State(initialValue: feed.articles)
    _pageInfo = State(initialValue: feed.pageInfo)
  }

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 0) {
        StoreHeader(appModel: appModel, presentation: .primary)

        Text(feed.title)
          .themeScaledFont(
            size: 27,
            weight: .bold,
            relativeTo: .title,
            maximumScale: 1.35
          )
          .foregroundStyle(ThemeTokens.ink)
          .accessibilityAddTraits(.isHeader)
          .padding(.horizontal, ThemeTokens.horizontalPadding)
          .padding(.top, 18)
          .padding(.bottom, 14)

        if let featuredArticle = articles.first {
          NativeNavigationLink(route: .article(featuredArticle)) {
            FeaturedArticleCard(article: featuredArticle)
          }
          .buttonStyle(.plain)
          .accessibilityIdentifier(
            "blog-featured-article-\(featuredArticle.handle)"
          )
          .padding(.horizontal, ThemeTokens.horizontalPadding)
          .padding(.bottom, 20)
        }

        LazyVStack(spacing: 16) {
          ForEach(Array(articles.dropFirst())) { article in
            NativeNavigationLink(route: .article(article)) {
              ArticleCard(article: article)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(
              "blog-feed-article-\(article.handle)"
            )
          }

          if let loadError {
            VStack(spacing: 10) {
              Text(loadError)
                .themeScaledFont(size: 13, weight: .medium)
                .foregroundStyle(ThemeTokens.muted)
                .multilineTextAlignment(.center)

              Button("Try Again") {
                Task {
                  if articles.isEmpty {
                    await loadFirstPage()
                  } else {
                    await loadMore()
                  }
                }
              }
              .themeScaledFont(size: 14, weight: .semibold)
              .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
          } else if pageInfo.hasNextPage {
            Button {
              Task {
                await loadMore()
              }
            } label: {
              HStack(spacing: 8) {
                if isLoadingMore {
                  ProgressView()
                    .tint(ThemeTokens.primaryButtonForeground)
                }
                Text(isLoadingMore ? "Loading…" : "Load more")
              }
              .themeScaledFont(size: 15, weight: .semibold)
              .foregroundStyle(ThemeTokens.primaryButtonForeground)
              .frame(maxWidth: .infinity)
              .frame(minHeight: ThemeTokens.minimumTap)
              .background(
                ThemeTokens.ink,
                in: Capsule()
              )
            }
            .disabled(isLoadingMore)
            .accessibilityIdentifier("blog-load-more")
          } else if isLoadingFirstPage && articles.isEmpty {
            ProgressView()
              .frame(maxWidth: .infinity)
              .padding(.vertical, 24)
          }
        }
        .padding(.horizontal, ThemeTokens.horizontalPadding)
        .padding(.bottom, 104)
      }
    }
    .background(ThemeTokens.canvas)
    .navigationBarHidden(true)
    .accessibilityIdentifier("blog-feed-\(feed.handle)")
    .task(id: feed.handle) {
      await loadFirstPage()
    }
  }

  @MainActor
  private func loadFirstPage() async {
    guard !isLoadingFirstPage else { return }
    isLoadingFirstPage = true
    loadError = nil
    defer { isLoadingFirstPage = false }

    do {
      let firstPage = try await appModel.client.blog(
        handle: feed.handle,
        first: 12
      )
      articles = firstPage.articles
      pageInfo = firstPage.pageInfo
    } catch is CancellationError {
      return
    } catch {
      if articles.isEmpty {
        loadError =
          "The latest articles couldn’t load. Check your connection and try again."
      }
    }
  }

  @MainActor
  private func loadMore() async {
    guard !isLoadingMore,
      pageInfo.hasNextPage,
      let cursor = pageInfo.endCursor
    else {
      return
    }

    isLoadingMore = true
    loadError = nil
    defer { isLoadingMore = false }

    do {
      let nextPage = try await appModel.client.blog(
        handle: feed.handle,
        first: 12,
        after: cursor
      )
      let existingIDs = Set(articles.map(\.id))
      articles.append(
        contentsOf: nextPage.articles.filter {
          !existingIDs.contains($0.id)
        }
      )
      pageInfo = nextPage.pageInfo
    } catch is CancellationError {
      return
    } catch {
      loadError =
        "More articles couldn’t load. Check your connection and try again."
    }
  }
}

struct ArticleDetailView: View {
  @EnvironmentObject private var appModel: AppModel
  let article: StoreArticle

  @State private var contentBlocks: [ArticleContentBlock] = []
  @State private var previousArticle: StoreArticle?
  @State private var nextArticle: StoreArticle?
  @State private var isSharePresented = false

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 0) {
        StoreHeader(appModel: appModel, presentation: .primary)

        VStack(spacing: 12) {
          Text(article.title)
            .themeScaledFont(
              size: 28,
              weight: .bold,
              relativeTo: .title,
              maximumScale: 1.35
            )
            .foregroundStyle(ThemeTokens.ink)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)

          HStack(spacing: 8) {
            if let authorName = article.authorName,
              !authorName.isEmpty
            {
              Text("By \(authorName)")
            }

            if article.authorName?.isEmpty == false,
              article.publishedAt != nil
            {
              Circle()
                .fill(ThemeTokens.muted)
                .frame(width: 3, height: 3)
                .accessibilityHidden(true)
            }

            if let publishedAt = article.publishedAt {
              Text(
                publishedAt.formatted(
                  date: .long,
                  time: .omitted
                )
              )
            }
          }
          .themeScaledFont(size: 12, weight: .medium)
          .foregroundStyle(ThemeTokens.muted)
          .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, ThemeTokens.horizontalPadding)
        .padding(.top, 20)
        .padding(.bottom, 14)

        if article.image != nil {
          PipelineRemoteImage(
            request: NativeImageRequest(
              sourceURL: ShopifyAsset.url(
                from: article.image?.url.absoluteString,
                width: 1200
              ),
              pixelWidth: 1200,
              aspectRatio: 4.0 / 3.0
            ),
            accessibilityLabel:
              article.image?.altText ?? article.title
          ) { image in
            image
              .resizable()
              .scaledToFill()
          } placeholder: {
            ThemeTokens.elevatedSurface
          }
          .aspectRatio(4.0 / 3.0, contentMode: .fit)
          .clipped()
          .clipShape(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
          )
          .padding(.horizontal, ThemeTokens.horizontalPadding)
          .padding(.bottom, 22)
        }

        LazyVStack(alignment: .leading, spacing: 18) {
          if contentBlocks.isEmpty {
            Text(article.contentText)
              .themeScaledFont(
                size: 16,
                relativeTo: .body,
                maximumScale: 1.8
              )
              .foregroundStyle(ThemeTokens.ink)
              .lineSpacing(5)
              .fixedSize(horizontal: false, vertical: true)
              .textSelection(.enabled)
          } else {
            ForEach(contentBlocks) { block in
              ArticleContentBlockView(block: block)
            }
          }

          if article.onlineStoreURL != nil {
            Divider()
              .padding(.top, 4)

            Button {
              isSharePresented = true
            } label: {
              Label("Share article", systemImage: "square.and.arrow.up")
                .themeScaledFont(size: 15, weight: .semibold)
                .foregroundStyle(ThemeTokens.ink)
                .frame(minHeight: ThemeTokens.minimumTap)
            }
            .accessibilityIdentifier("article-share")
          }

          articleNavigation
        }
        .padding(.horizontal, ThemeTokens.horizontalPadding)
        .padding(.bottom, 104)
      }
    }
    .background(ThemeTokens.canvas)
    .navigationBarHidden(true)
    .accessibilityIdentifier("article-detail-\(article.handle)")
    .sheet(isPresented: $isSharePresented) {
      if let url = article.onlineStoreURL {
        ArticleActivityView(activityItems: [url])
      }
    }
    .task(id: article.id) {
      contentBlocks = ArticleContentRenderer.blocks(
        html: article.contentHTML
      )
      await loadAdjacentArticles()
    }
  }

  @ViewBuilder
  private var articleNavigation: some View {
    if previousArticle != nil || nextArticle != nil {
      Divider()

      HStack(alignment: .top, spacing: 14) {
        if let previousArticle {
          NativeNavigationLink(route: .article(previousArticle)) {
            AdjacentArticleCard(
              label: "Previous",
              article: previousArticle,
              alignment: .leading
            )
          }
          .buttonStyle(.plain)
        }

        Spacer(minLength: 0)

        if let nextArticle {
          NativeNavigationLink(route: .article(nextArticle)) {
            AdjacentArticleCard(
              label: "Next",
              article: nextArticle,
              alignment: .trailing
            )
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  @MainActor
  private func loadAdjacentArticles() async {
    guard !article.blogHandle.isEmpty else { return }
    do {
      let feed = try await appModel.client.blog(
        handle: article.blogHandle,
        first: 50
      )
      guard let index = feed.articles.firstIndex(
        where: { $0.id == article.id }
      ) else {
        return
      }
      previousArticle =
        index > feed.articles.startIndex
        ? feed.articles[index - 1]
        : nil
      let nextIndex = index + 1
      nextArticle =
        nextIndex < feed.articles.endIndex
        ? feed.articles[nextIndex]
        : nil
    } catch {
      previousArticle = nil
      nextArticle = nil
    }
  }
}

private struct FeaturedArticleCard: View {
  let article: StoreArticle

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      PipelineRemoteImage(
        request: NativeImageRequest(
          sourceURL: ShopifyAsset.url(
            from: article.image?.url.absoluteString,
            width: 900
          ),
          pixelWidth: 900,
          aspectRatio: 16.0 / 9.0
        ),
        accessibilityLabel:
          article.image?.altText ?? article.title
      ) { image in
        image.resizable().scaledToFill()
      } placeholder: {
        ThemeTokens.elevatedSurface
      }
      .aspectRatio(16.0 / 9.0, contentMode: .fit)
      .clipped()

      VStack(alignment: .leading, spacing: 10) {
        articleMetadata(article)

        Text(article.title)
          .themeScaledFont(
            size: 22,
            weight: .bold,
            relativeTo: .title3,
            maximumScale: 1.4
          )
          .foregroundStyle(ThemeTokens.ink)
          .fixedSize(horizontal: false, vertical: true)

        if !article.previewText.isEmpty {
          Text(article.previewText)
            .themeScaledFont(size: 15)
            .foregroundStyle(ThemeTokens.ink.opacity(0.76))
            .lineLimit(4)
        }

        Text("Read more")
          .themeScaledFont(size: 14, weight: .semibold)
          .foregroundStyle(ThemeTokens.primaryButtonForeground)
          .padding(.horizontal, 18)
          .frame(minHeight: ThemeTokens.minimumTap)
          .background(ThemeTokens.ink, in: Capsule())
          .padding(.top, 3)
      }
      .padding(18)
    }
    .background(ThemeTokens.cardSurface)
    .clipShape(
      RoundedRectangle(cornerRadius: 22, style: .continuous)
    )
    .overlay {
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.60), lineWidth: 0.7)
    }
  }
}

private struct ArticleCard: View {
  let article: StoreArticle

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      PipelineRemoteImage(
        request: NativeImageRequest(
          sourceURL: ShopifyAsset.url(
            from: article.image?.url.absoluteString,
            width: 760
          ),
          pixelWidth: 760,
          aspectRatio: 4.0 / 3.0
        ),
        accessibilityLabel:
          article.image?.altText ?? article.title
      ) { image in
        image.resizable().scaledToFill()
      } placeholder: {
        ThemeTokens.elevatedSurface
      }
      .aspectRatio(4.0 / 3.0, contentMode: .fit)
      .clipped()
      .clipShape(
        RoundedRectangle(cornerRadius: 17, style: .continuous)
      )

      articleMetadata(article)

      Text(article.title)
        .themeScaledFont(size: 18, weight: .bold)
        .foregroundStyle(ThemeTokens.ink)
        .fixedSize(horizontal: false, vertical: true)

      if !article.previewText.isEmpty {
        Text(article.previewText)
          .themeScaledFont(size: 14)
          .foregroundStyle(ThemeTokens.ink.opacity(0.72))
          .lineLimit(3)
      }
    }
    .padding(.bottom, 8)
  }
}

@ViewBuilder
@MainActor
private func articleMetadata(
  _ article: StoreArticle
) -> some View {
  HStack(spacing: 8) {
    if let tag = article.tags.first, !tag.isEmpty {
      Text(tag.uppercased())
        .tracking(1.1)
        .foregroundStyle(ThemeTokens.deepGold)
    }

    if article.tags.first?.isEmpty == false,
      article.publishedAt != nil
    {
      Circle()
        .fill(ThemeTokens.muted)
        .frame(width: 3, height: 3)
    }

    if let publishedAt = article.publishedAt {
      Text(
        publishedAt.formatted(
          date: .abbreviated,
          time: .omitted
        )
      )
      .foregroundStyle(ThemeTokens.muted)
    }
  }
  .themeScaledFont(size: 10, weight: .bold)
}

private struct AdjacentArticleCard: View {
  let label: String
  let article: StoreArticle
  let alignment: HorizontalAlignment

  var body: some View {
    VStack(alignment: alignment, spacing: 6) {
      Text(label.uppercased())
        .tracking(1.1)
        .themeScaledFont(size: 10, weight: .bold)
        .foregroundStyle(ThemeTokens.deepGold)

      Text(article.title)
        .themeScaledFont(size: 13, weight: .semibold)
        .foregroundStyle(ThemeTokens.ink)
        .multilineTextAlignment(
          alignment == .leading ? .leading : .trailing
        )
        .lineLimit(3)
    }
    .frame(maxWidth: 150, alignment: alignment == .leading ? .leading : .trailing)
    .frame(minHeight: ThemeTokens.minimumTap)
  }
}

enum ArticleContentBlock: Identifiable, Equatable {
  case text(id: Int, value: AttributedString)
  case image(id: Int, url: URL, altText: String?)

  var id: Int {
    switch self {
    case .text(let id, _), .image(let id, _, _):
      return id
    }
  }
}

enum ArticleContentRenderer {
  private static let maximumHTMLBytes = 1_000_000

  static func blocks(html: String) -> [ArticleContentBlock] {
    guard !html.isEmpty,
      html.utf8.count <= maximumHTMLBytes
    else {
      return []
    }

    let sanitized = removingUnsafeElements(from: html)
    guard let imageExpression = try? NSRegularExpression(
      pattern: #"(?is)<img\b([^>]*)>"#
    ) else {
      return textBlock(from: sanitized, id: 0).map { [$0] } ?? []
    }

    let range = NSRange(
      sanitized.startIndex..<sanitized.endIndex,
      in: sanitized
    )
    let matches = imageExpression.matches(
      in: sanitized,
      range: range
    )
    var blocks: [ArticleContentBlock] = []
    var cursor = sanitized.startIndex
    var nextID = 0

    for match in matches {
      guard let tagRange = Range(match.range, in: sanitized),
        let attributesRange = Range(match.range(at: 1), in: sanitized)
      else {
        continue
      }

      let textHTML = String(sanitized[cursor..<tagRange.lowerBound])
      if let block = textBlock(from: textHTML, id: nextID) {
        blocks.append(block)
        nextID += 1
      }

      let attributes = String(sanitized[attributesRange])
      if let source = attribute("src", in: attributes),
        let url = verifiedArticleImageURL(source)
      {
        blocks.append(
          .image(
            id: nextID,
            url: url,
            altText: attribute("alt", in: attributes)
          )
        )
        nextID += 1
      }
      cursor = tagRange.upperBound
    }

    if cursor < sanitized.endIndex,
      let block = textBlock(
        from: String(sanitized[cursor...]),
        id: nextID
      )
    {
      blocks.append(block)
    }
    return blocks
  }

  private static func textBlock(
    from html: String,
    id: Int
  ) -> ArticleContentBlock? {
    let trimmed = html.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    guard !trimmed.isEmpty else { return nil }

    let wrapped = """
      <html><head><meta charset="utf-8"></head><body>\(trimmed)</body></html>
      """
    guard let data = wrapped.data(using: .utf8),
      let attributed = try? NSAttributedString(
        data: data,
        options: [
          .documentType: NSAttributedString.DocumentType.html,
          .characterEncoding: String.Encoding.utf8.rawValue,
        ],
        documentAttributes: nil
      ),
      !attributed.string.trimmingCharacters(
        in: .whitespacesAndNewlines
      ).isEmpty
    else {
      return nil
    }

    return .text(id: id, value: AttributedString(attributed))
  }

  private static func removingUnsafeElements(
    from html: String
  ) -> String {
    guard let unsafeElements = try? NSRegularExpression(
      pattern:
        #"(?is)<(script|style|iframe|object|embed|form|button|input)\b[^>]*>.*?</\1\s*>|<(script|style|iframe|object|embed|form|button|input)\b[^>]*/?>"#
    ) else {
      return html
    }
    return unsafeElements.stringByReplacingMatches(
      in: html,
      range: NSRange(html.startIndex..<html.endIndex, in: html),
      withTemplate: ""
    )
  }

  private static func attribute(
    _ name: String,
    in source: String
  ) -> String? {
    let escapedName = NSRegularExpression.escapedPattern(
      for: name
    )
    guard let expression = try? NSRegularExpression(
      pattern:
        #"(?is)\b\#(escapedName)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+))"#
    ) else {
      return nil
    }
    let range = NSRange(
      source.startIndex..<source.endIndex,
      in: source
    )
    guard let match = expression.firstMatch(
      in: source,
      range: range
    ) else {
      return nil
    }
    for group in 1...3 where match.range(at: group).location != NSNotFound {
      guard let valueRange = Range(
        match.range(at: group),
        in: source
      ) else {
        continue
      }
      return String(source[valueRange])
    }
    return nil
  }

  private static func verifiedArticleImageURL(
    _ source: String
  ) -> URL? {
    let value = source.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    let url: URL?
    if value.hasPrefix("//") {
      url = URL(string: "https:\(value)")
    } else if value.hasPrefix("/") {
      url = URL(
        string: value,
        relativeTo: ShopifyAsset.shopRoot
      )?.absoluteURL
    } else {
      url = URL(string: value)
    }
    guard let url,
      url.scheme?.lowercased() == "https",
      url.user == nil,
      url.password == nil,
      url.port == nil || url.port == 443,
      let host = url.host?.lowercased(),
      ShopifyAsset.isPrimaryStorefrontURL(url)
        || host == "cdn.shopify.com"
        || host.hasSuffix(".cdn.shopify.com")
    else {
      return nil
    }
    return url
  }
}

private struct ArticleContentBlockView: View {
  let block: ArticleContentBlock

  var body: some View {
    switch block {
    case .text(_, let value):
      Text(value)
        .foregroundStyle(ThemeTokens.ink)
        .lineSpacing(5)
        .fixedSize(horizontal: false, vertical: true)
        .textSelection(.enabled)

    case .image(_, let url, let altText):
      PipelineRemoteImage(
        request: NativeImageRequest(
          sourceURL: url,
          pixelWidth: 1_100
        ),
        accessibilityLabel: altText
      ) { image in
        image
          .resizable()
          .scaledToFit()
      } placeholder: {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .fill(ThemeTokens.elevatedSurface)
          .aspectRatio(4.0 / 3.0, contentMode: .fit)
      }
      .clipShape(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
      )
    }
  }
}

private struct ArticleActivityView: UIViewControllerRepresentable {
  let activityItems: [Any]

  func makeUIViewController(
    context: Context
  ) -> UIActivityViewController {
    UIActivityViewController(
      activityItems: activityItems,
      applicationActivities: nil
    )
  }

  func updateUIViewController(
    _ uiViewController: UIActivityViewController,
    context: Context
  ) {}
}

private extension StoreArticle {
  var previewText: String {
    let source = excerptText.isEmpty ? contentText : excerptText
    let words = source.split(whereSeparator: \.isWhitespace)
    guard words.count > 30 else { return source }
    return words.prefix(30).joined(separator: " ") + "…"
  }
}
