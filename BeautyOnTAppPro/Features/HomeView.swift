import SwiftUI

struct HomeView: View {
  @EnvironmentObject private var appModel: AppModel
  private let snapshot = ThemeHomeSnapshot.bundled

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        LazyVStack(
          alignment: .leading,
          spacing: ThemeTokens.sectionSpacing,
          pinnedViews: [.sectionHeaders]
        ) {
          StoreHeader(
            appModel: appModel,
            presentation: .primary
          )

          if appModel.customerSession.shouldShowHomeAccountBar {
            HomeAccountBar()
          }

          Section {
            ForEach(nativeSections) { section in
              sectionView(
                section,
                containerWidth: proxy.size.width
              )
            }

            NativeHomeFooter()
              // The dock is intentionally floating above the scroll content.
              // Keep only the measured dock clearance after the footer so the
              // final links remain tappable without creating gaps between
              // storefront sections.
              .padding(.bottom, 82)
          } header: {
            StoreHeader(
              appModel: appModel,
              presentation: .tabs
            )
            .zIndex(1)
          }
        }
      }
      .accessibilityIdentifier("home-screen")
      .background(ThemeTokens.canvas)
      .nativeSoftTopScrollEdgeEffect()
      // Storefront content must never collide with the status bar. The soft
      // scroll-edge effect alone is too light over dense product imagery, so
      // a canvas veil covers the physical top strip, dissolving into the
      // pinned tab rail's own gradient directly beneath it.
      .overlay(alignment: .top) {
        LinearGradient(
          stops: [
            .init(color: ThemeTokens.canvas, location: 0),
            .init(color: ThemeTokens.canvas.opacity(0.96), location: 0.72),
            .init(color: ThemeTokens.canvas.opacity(0), location: 1)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        .frame(height: proxy.safeAreaInsets.top + 8)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
      }
    }
    .navigationBarHidden(true)
  }

  private var nativeSections: [ThemeHomeSection] {
    // Every storefront section renders natively, in storefront order —
    // including Shop by Routine and Need a Little Guidance, which the live
    // homepage shows between Bundle Deals and the blog rail.
    snapshot.sections
  }

  @ViewBuilder
  private func sectionView(
    _ section: ThemeHomeSection,
    containerWidth: CGFloat
  ) -> some View {
    switch section {
    case .greeting(_, let greeting):
      GreetingView(greeting: greeting)
    case .hero(_, let slides):
      HeroRailView(
        slides: slides,
        containerWidth: containerWidth
      )
    case .productRail(_, let specification):
      ProductRailView(specification: specification)
    case .smartAnalysis(_, let specification):
      SmartAnalysisView(specification: specification)
    case .contentRail(_, let specification):
      ContentRailView(specification: specification)
    case .routine(_, let specification):
      RoutineRailView(specification: specification)
    case .guidance(_, let specification):
      GuidanceRailView(specification: specification)
    case .blog(_, let specification):
      BlogLinkView(specification: specification)
    case .logos(_, let specification):
      LogoRailView(specification: specification)
    }
  }
}

private struct HomeAccountBar: View {
  @EnvironmentObject private var appModel: AppModel

  var body: some View {
    HStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 2) {
        Text("Sign In for Exclusive Deals 🖤")
          .themeScaledFont(size: 14, weight: .bold)
          .foregroundStyle(ThemeTokens.ink)
          .lineLimit(1)
          .minimumScaleFactor(0.82)

        HStack(spacing: 3) {
          Text("Don’t have an account?")
            .themeScaledFont(size: 13)
            .foregroundStyle(ThemeTokens.ink)

          Button("Create an account") {
            appModel.openProfileCreateAccount()
          }
          .buttonStyle(.plain)
          .themeScaledFont(size: 13)
          .foregroundStyle(ThemeTokens.link)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.76)
      }

      Spacer(minLength: 0)

      Button("Sign In") {
        appModel.openProfileSignIn()
      }
      .buttonStyle(.plain)
      .themeScaledFont(size: 14, weight: .semibold)
      .foregroundStyle(ThemeTokens.primaryButtonForeground)
      .padding(.horizontal, 22)
      .frame(minHeight: ThemeTokens.minimumTap)
      .background(ThemeTokens.ink, in: Capsule())
      .accessibilityIdentifier("home-sign-in")
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(ThemeTokens.canvas)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(ThemeTokens.separator.opacity(0.45))
        .frame(height: 0.7)
    }
    .accessibilityIdentifier("home-account-bar")
  }
}

private struct GreetingView: View {
  @EnvironmentObject private var appModel: AppModel
  @Environment(\.colorScheme) private var colorScheme
  let greeting: ThemeGreeting

  private static let weekdayFormat = Date.FormatStyle()
    .weekday(.wide)
    .locale(Locale(identifier: "en_ZA"))

  private var weekday: String {
    Date.now.formatted(Self.weekdayFormat)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .firstTextBaseline, spacing: 4) {
        Text(kickerText.uppercased())
          .tracking(2.8)
          .themeScaledFont(size: 9, weight: .heavy, maximumScale: 1.3)
          .foregroundStyle(ThemeTokens.deepGold)

        if greeting.kicker.contains("🖤") {
          Image(systemName: "heart.fill")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
            .accessibilityHidden(true)
        }
      }
      .accessibilityElement(children: .combine)
      Text("\(greeting.prefix) \(weekday),\n\(personalizedSuffix)")
        .themeScaledFont(size: 18, weight: .bold)
        .foregroundStyle(ThemeTokens.ink)
        .lineSpacing(0)
        .padding(.top, ThemeTokens.greetingTitleTopMargin)
        .padding(.bottom, ThemeTokens.greetingTitleBottomMargin)
      Text(greeting.subtext)
        .themeScaledFont(size: 12)
        .foregroundStyle(ThemeTokens.muted)
        .lineSpacing(4.3)
        .padding(.top, ThemeTokens.greetingSubtextTopMargin)
    }
    .padding(.horizontal, ThemeTokens.horizontalPadding)
    .padding(.top, ThemeTokens.greetingTopMargin)
    .padding(.bottom, ThemeTokens.greetingBottomMargin)
  }

  private var personalizedSuffix: String {
    guard case .signedIn(let firstName) = appModel.customerSession else {
      return greeting.suffix
    }

    let name = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !name.isEmpty else { return greeting.suffix }

    // The theme owns the greeting punctuation and emoji. Only substitute the
    // customer-facing name once the native session has been verified.
    return greeting.suffix.replacingOccurrences(of: "Bestie", with: name)
  }

  private var kickerText: String {
    greeting.kicker
      .replacingOccurrences(of: "🖤", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

private struct HeroRailView: View {
  let slides: [ThemeHeroSlide]
  let containerWidth: CGFloat

  private var slideWidth: CGFloat {
    if containerWidth < 768 {
      return (containerWidth - (0.3 * ThemeTokens.heroSpacing)) / 1.3
    }
    return min(
      (containerWidth - ThemeTokens.heroSpacing) / 2,
      560
    )
  }

  private var imageHeight: CGFloat {
    slideWidth / ThemeTokens.heroImageAspectRatio
  }

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(spacing: ThemeTokens.heroSpacing) {
        ForEach(slides) { slide in
          ThemeDestinationLink(
            link: slide.link,
            title: slide.heading
          ) {
            VStack(spacing: 0) {
              PipelineRemoteImage(
                request: NativeImageRequest(
                  sourceURL: ShopifyAsset.url(
                    from: slide.imageReference,
                    width: 900
                  ),
                  pixelWidth: 900,
                  aspectRatio: ThemeTokens.heroImageAspectRatio
                ),
                accessibilityLabel: nil
              ) { image in
                image
                  .resizable()
                  .scaledToFill()
              } placeholder: {
                Color.black.opacity(0.04)
              }
              .frame(width: slideWidth, height: imageHeight)
              .clipped()

              VStack(alignment: .leading, spacing: 0) {
                Text(slide.heading)
                  .themeScaledFont(size: 15, weight: .bold)
                  .padding(.bottom, 4)
                Text(slide.detail)
                  .themeScaledFont(size: 14)
                  .lineSpacing(4)
                  .lineLimit(3)
                  // Hero cards keep their supplied brand surface in both
                  // appearances, so use the slide's contrast colour rather
                  // than a system label that flips to white in Dark Mode.
                  .foregroundStyle(
                    Color(hexString: slide.textColor) ?? ThemeTokens.ink
                  )
                  .padding(.bottom, 10)
                Text(slide.buttonLabel)
                  .themeScaledFont(
                    size: 14,
                    weight: .semibold
                  )
              }
              .foregroundStyle(Color(hexString: slide.textColor) ?? ThemeTokens.ink)
              .padding(.horizontal, 16)
              .padding(.vertical, 14)
              .frame(width: slideWidth, alignment: .topLeading)
              .frame(
                minHeight: ThemeTokens.heroBodyMinHeight,
                alignment: .topLeading
              )
              .background(
                Color(hexString: slide.backgroundColor)
                  ?? ThemeTokens.cardSurface
              )
              .clipped()
            }
            .clipShape(
              RoundedRectangle(
                cornerRadius: ThemeTokens.cardRadius,
                style: .continuous
              )
            )
            .overlay {
              RoundedRectangle(
                cornerRadius: ThemeTokens.cardRadius,
                style: .continuous
              )
              .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.7)
            }
            .shadow(color: Color.black.opacity(0.08), radius: 12, y: 5)
            .frame(width: slideWidth)
          }
        }
      }
      .padding(.horizontal, ThemeTokens.heroHorizontalInset)
    }
    .padding(.top, ThemeTokens.heroTopMargin)
  }
}

private struct SmartAnalysisView: View {
  @EnvironmentObject private var appModel: AppModel
  let specification: ThemeSmartAnalysis

  var body: some View {
    VStack(alignment: .leading, spacing: 13) {
      HStack(alignment: .center, spacing: 16) {
        VStack(alignment: .leading, spacing: 0) {
          Text(specification.eyebrow.uppercased())
            .tracking(2.4)
            .themeScaledFont(
              size: 9,
              weight: .heavy,
              maximumScale: 1.3
            )
            .foregroundStyle(ThemeTokens.deepGold)
          Text(specification.heading)
            .themeScaledFont(size: 17, weight: .semibold)
            .foregroundStyle(ThemeTokens.ink)
            .padding(.top, 4)
          Text(specification.detail)
            .themeScaledFont(size: 11.5)
            .foregroundStyle(ThemeTokens.muted)
            .lineSpacing(2.8)
            .padding(.top, 5)
            .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .layoutPriority(1)

        ThemeDestinationLink(link: specification.link, title: specification.heading) {
          Text(specification.buttonLabel)
            .themeScaledFont(size: 12.5, weight: .heavy)
            .foregroundStyle(ThemeTokens.onGold)
            // Keep the booking action in its own consistently sized trailing
            // column. It no longer squeezes or visually touches the service
            // title and description on a phone-sized layout.
            .frame(width: 78, height: 42)
            .background(
              LinearGradient(
                colors: [
                  Color(hex: 0xDCC476),
                  ThemeTokens.gold,
                ],
                startPoint: .top,
                endPoint: .bottom
              ),
              in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(
              color: ThemeTokens.gold.opacity(0.38),
              radius: 9,
              y: 4
            )
        }
        .accessibilityHint("Opens Smart Analysis booking")
      }

      HStack(spacing: 8) {
        ForEach(specification.chips) { chip in
          ThemeDestinationLink(link: chip.link, title: chip.label) {
            HStack(spacing: 0) {
              Text("\(chip.label) · ")
                .themeScaledFont(size: 11, weight: .bold)
              Text(chip.price)
                .themeScaledFont(
                  size: 10.5,
                  weight: .bold,
                  design: .monospaced
                )
                .foregroundStyle(ThemeTokens.deepGold)
            }
            .foregroundStyle(ThemeTokens.ink)
            .lineLimit(1)
            .padding(.horizontal, 11)
            .frame(height: 32)
            .background(
              ThemeTokens.ink.opacity(0.05),
              in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay {
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(ThemeTokens.ink.opacity(0.07), lineWidth: 0.7)
            }
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 15)
    .background(
      LinearGradient(
        colors: [
          ThemeTokens.cardSurface,
          ThemeTokens.elevatedSurface,
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      ),
      in: RoundedRectangle(cornerRadius: 22, style: .continuous)
    )
    .overlay {
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .stroke(ThemeTokens.deepGold.opacity(0.28), lineWidth: 0.7)
    }
    .shadow(color: ThemeTokens.deepGold.opacity(0.14), radius: 18, y: 8)
    .padding(.horizontal, 16)
    .padding(.top, 18)
    .task {
      // These are Shopify products, not protected booking pages. Warm their
      // native product payload while the card is visible so tapping either
      // service can transition immediately without exposing a storefront.
      for chip in specification.chips {
        guard case .web(let url) = chip.link,
          let navigation = NativeStorefrontNavigation.parse(url),
          case .product(let handle) = navigation
        else {
          continue
        }
        _ = try? await appModel.product(handle: handle)
      }
    }
  }
}

private struct ContentRailView: View {
  let specification: ThemeContentRail

  private var isAudienceRail: Bool {
    specification.heading.isEmpty
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if !specification.heading.isEmpty || !specification.eyebrow.isEmpty {
        SectionHeading(
          eyebrow: specification.eyebrow,
          title: specification.heading
        )
      }

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(alignment: .top, spacing: 16) {
          ForEach(Array(specification.cards.enumerated()), id: \.element.id) {
            index,
            card in
            ContentCardTile(
              card: card,
              isAudienceCard: isAudienceRail,
              backgroundColor: audienceBackground(at: index)
            )
          }
        }
        .padding(.horizontal, ThemeTokens.horizontalPadding)
        .padding(.vertical, 4)
      }
    }
    .padding(.vertical, ThemeTokens.sectionVerticalPadding)
  }

  private func audienceBackground(at index: Int) -> Color {
  guard isAudienceRail else { return ThemeTokens.cardSurface }
    let colors: [UInt] = [0xC5C5C5, 0xFADFCA, 0xC3CCCD, 0xC8C5BD]
    return Color(hex: colors[index % colors.count])
  }
}

private struct ContentCardTile: View {
  let card: ThemeContentCard
  let isAudienceCard: Bool
  let backgroundColor: Color

  var body: some View {
    ThemeDestinationLink(link: card.link, title: card.heading) {
      VStack(alignment: .leading, spacing: 0) {
        cardImage

        Text(card.heading)
          .themeScaledFont(size: 14, weight: .bold)
          .lineLimit(2)
          .padding(.horizontal, isAudienceCard ? 20 : 10)
          .padding(.top, 28)
        if !card.detailText.isEmpty {
          Text(card.detailText)
            .themeScaledFont(size: 14)
            .foregroundStyle(ThemeTokens.ink.opacity(0.84))
            .lineSpacing(4)
            .lineLimit(4)
            .padding(.horizontal, isAudienceCard ? 20 : 10)
            .padding(.top, 8)
        }
        Spacer(minLength: 8)
        if !card.linkLabel.isEmpty {
          if isAudienceCard {
            Text(card.linkLabel.uppercased())
              .themeScaledFont(size: 14, weight: .semibold)
              .padding(.horizontal, 20)
              .padding(.bottom, 30)
          } else {
            Text(card.linkLabel)
              .themeScaledFont(size: 12, weight: .semibold)
              .padding(.horizontal, 12)
              .frame(height: 32)
              .overlay {
                Capsule()
                  .stroke(ThemeTokens.ink, lineWidth: 2)
              }
              .padding(.horizontal, 10)
              .padding(.bottom, 20)
          }
        }
      }
      .foregroundStyle(ThemeTokens.ink)
      .frame(width: 210)
      .frame(height: 370, alignment: .topLeading)
      .background(backgroundColor)
      .clipShape(
        RoundedRectangle(
          cornerRadius: 18,
          style: .continuous
        )
      )
      .overlay {
        RoundedRectangle(
          cornerRadius: 18,
          style: .continuous
        )
        .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.7)
      }
      .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
    }
  }

  private var cardImage: some View {
    PipelineRemoteImage(
      request: NativeImageRequest(
        sourceURL: ShopifyAsset.url(
          from: card.imageReference,
          width: 700
        ),
        pixelWidth: 700,
        aspectRatio: 4 / 3
      ),
      accessibilityLabel: nil
    ) { image in
      image.resizable().scaledToFill()
    } placeholder: {
      Color.black.opacity(0.04)
    }
    .frame(width: 210, height: 157.5)
    .clipped()
  }
}

private struct RoutineRailView: View {
  let specification: ThemeRoutineRail

  var body: some View {
    VStack(alignment: .leading, spacing: 9) {
      if !specification.introHeading.isEmpty || !specification.introEyebrow.isEmpty {
        SectionHeading(
          eyebrow: specification.introEyebrow,
          title: specification.introHeading
        )
      }
      SectionHeading(eyebrow: "", title: specification.heading)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 8) {
          ForEach(specification.cards) { card in
            ThemeDestinationLink(link: card.link, title: card.name) {
              VStack(alignment: .leading, spacing: 7) {
                Text(card.period.uppercased())
                  .themeScaledFont(
                    size: 9,
                    weight: .bold,
                    maximumScale: 1.3
                  )
                  .foregroundStyle(
                    card.period.lowercased() == "am"
                      ? ThemeTokens.onGold
                      : ThemeTokens.primaryButtonForeground
                  )
                  .padding(.horizontal, 7)
                  .padding(.vertical, 3)
                  .background(
                    card.period.lowercased() == "am"
                      ? Color(hex: 0xECB824)
                      : ThemeTokens.ink,
                    in: Capsule()
                  )
                Text(card.name)
                  .themeScaledFont(
                    size: 12,
                    weight: .semibold
                  )
                  .foregroundStyle(ThemeTokens.ink)
                  .lineLimit(3)
              }
              .frame(width: 112, height: 72, alignment: .topLeading)
              .padding(9)
              .background(
                ThemeTokens.cardSurface,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
              )
              .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                  .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.7)
              }
            }
          }
        }
        .padding(.horizontal, ThemeTokens.horizontalPadding)
        .padding(.vertical, 4)
      }
    }
  }
}

private struct GuidanceRailView: View {
  let specification: ThemeGuidance

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      VStack(alignment: .leading, spacing: 3) {
        Text(specification.heading)
          .themeScaledFont(size: 19, weight: .bold)
        Text(specification.subheading)
          .themeScaledFont(size: 13)
          .foregroundStyle(ThemeTokens.muted)
      }
      .padding(.horizontal, ThemeTokens.horizontalPadding)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 7) {
          ForEach(specification.cards) { card in
            ThemeDestinationLink(link: card.link, title: card.heading) {
              VStack(spacing: 7) {
                PipelineRemoteImage(
                  request: NativeImageRequest(
                    sourceURL: ShopifyAsset.url(
                      from: card.imageReference,
                      width: 220
                    ),
                    pixelWidth: 220
                  ),
                  accessibilityLabel: nil
                ) { image in
                  image.resizable().scaledToFit()
                } placeholder: {
                  Color.clear
                }
                .frame(width: 48, height: 48)
                Text(card.heading)
                  .themeScaledFont(
                    size: 11.5,
                    weight: .semibold
                  )
                  .foregroundStyle(ThemeTokens.ink)
                  .multilineTextAlignment(.center)
                  .lineLimit(2)
              }
              .frame(width: 110, height: 108)
              .background(
                ThemeTokens.cardSurface,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
              )
              .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                  .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.7)
              }
            }
          }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
      }
    }
  }
}

private struct BlogLinkView: View {
  @EnvironmentObject private var appModel: AppModel
  let specification: ThemeBlog

  @State private var feed: StoreBlogFeed?
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var retryID = 0

  var body: some View {
    VStack(alignment: .leading, spacing: 11) {
      HStack(alignment: .firstTextBaseline) {
        Text(specification.heading)
          .themeScaledFont(size: 18, weight: .bold)
          .foregroundStyle(ThemeTokens.ink)

        Spacer()

        if let feed {
          NativeNavigationLink(route: .blog(feed)) {
            Text(specification.linkLabel)
          }
          .themeScaledFont(size: 11, weight: .semibold)
          .foregroundStyle(ThemeTokens.deepGold)
          .buttonStyle(.plain)
          .accessibilityIdentifier("blog-view-all")
        }
      }
      .padding(.horizontal, ThemeTokens.horizontalPadding)

      if let feed, !feed.articles.isEmpty {
        articleRail(feed.articles)
      } else if isLoading {
        loadingRail
      } else {
        Button {
          retryID += 1
        } label: {
          Label(
            errorMessage ?? "Blog posts are unavailable right now.",
            systemImage: "arrow.clockwise"
          )
          .themeScaledFont(size: 13, weight: .semibold)
          .frame(maxWidth: .infinity)
          .frame(minHeight: ThemeTokens.minimumTap)
        }
        .buttonStyle(.plain)
        .foregroundStyle(ThemeTokens.ink)
        .padding(.horizontal, ThemeTokens.horizontalPadding)
        .accessibilityLabel("Retry blog posts")
      }
    }
    .task(id: "\(specification.handle)-\(retryID)") {
      await load()
    }
  }

  private func articleRail(_ articles: [StoreArticle]) -> some View {
    GeometryReader { geometry in
      let availableWidth = max(
        240,
        geometry.size.width - (ThemeTokens.horizontalPadding * 2)
      )
      let cardWidth = min(320, max(220, availableWidth / 1.2))

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(alignment: .top, spacing: 12) {
          ForEach(articles) { article in
            articleLink(article, width: cardWidth)
          }
        }
        .padding(.horizontal, ThemeTokens.horizontalPadding)
        .padding(.bottom, 8)
      }
    }
    .frame(height: 292)
    .accessibilityIdentifier("blog-article-rail")
  }

  private var loadingRail: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(0..<2, id: \.self) { _ in
          RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(ThemeTokens.elevatedSurface)
            .frame(width: 250, height: 245)
        }
      }
      .padding(.horizontal, ThemeTokens.horizontalPadding)
    }
    .redacted(reason: .placeholder)
    .frame(height: 260, alignment: .leading)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Loading blog posts")
  }

  @ViewBuilder
  private func articleLink(
    _ article: StoreArticle,
    width: CGFloat
  ) -> some View {
    if article.onlineStoreURL != nil {
      NativeNavigationLink(route: .article(article)) {
        articleCard(article, width: width)
      }
      .buttonStyle(.plain)
      .accessibilityIdentifier("blog-article-\(article.handle)")
    } else {
      articleCard(article, width: width)
    }
  }

  private func articleCard(
    _ article: StoreArticle,
    width: CGFloat
  ) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      ZStack(alignment: .topLeading) {
        PipelineRemoteImage(
          request: NativeImageRequest(
            sourceURL: ShopifyAsset.url(
              from: article.image?.url.absoluteString,
              width: 720
            ),
            pixelWidth: 720,
            aspectRatio: 1.5
          ),
          accessibilityLabel: nil
        ) { image in
          image
            .resizable()
            .scaledToFill()
        } placeholder: {
          ThemeTokens.elevatedSurface
        }
        .frame(width: width, height: width / 1.5)
        .clipped()

        if specification.showsCategory,
          let category = article.tags.first,
          !category.isEmpty
        {
          Text(category)
            .themeScaledFont(size: 10, weight: .bold)
            .foregroundStyle(ThemeTokens.ink)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(10)
        }
      }

      VStack(alignment: .leading, spacing: 7) {
        Text(article.title)
          .themeScaledFont(size: 14, weight: .bold)
          .foregroundStyle(ThemeTokens.ink)
          .multilineTextAlignment(.leading)
          .lineLimit(3)

        if let publishedAt = article.publishedAt {
          Text(
            publishedAt.formatted(
              .dateTime.day().month(.abbreviated).year()
            )
          )
          .themeScaledFont(size: 11)
          .foregroundStyle(ThemeTokens.muted)
        }
      }
      .padding(12)
    }
    .frame(width: width, alignment: .topLeading)
    .background(ThemeTokens.cardSurface)
    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 18, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.45), lineWidth: 0.7)
    }
    .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
    .accessibilityElement(children: .combine)
  }

  @MainActor
  private func load() async {
    guard !specification.handle.isEmpty else {
      feed = nil
      errorMessage = "Blog posts are unavailable right now."
      return
    }

    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    do {
      feed = try await appModel.client.blog(
        handle: specification.handle,
        first: specification.articleCount
      )
    } catch is CancellationError {
      return
    } catch {
      feed = nil
      errorMessage = error.localizedDescription
    }
  }
}

private struct LogoRailView: View {
  let specification: ThemeLogoRail
  private let stageHeight: CGFloat = 64
  private let stageSpacing: CGFloat = 10

  var body: some View {
    LazyVGrid(
      columns: Array(
        repeating: GridItem(.flexible(), spacing: stageSpacing),
        count: 4
      ),
      spacing: stageSpacing
    ) {
      ForEach(specification.logos) { logo in
        LogoTileView(logo: logo, stageHeight: stageHeight)
      }
    }
    .padding(.horizontal, ThemeTokens.horizontalPadding)
    .padding(.top, 18)
    .background(ThemeTokens.canvas)
    .accessibilityIdentifier("home-logo-wall")
  }
}

private struct LogoTileView: View {
  let logo: ThemeLogo
  let stageHeight: CGFloat

  private let contentInsets = EdgeInsets(
    top: 6,
    leading: 7,
    bottom: 6,
    trailing: 7
  )

  private var stageShape: RoundedRectangle {
    RoundedRectangle(
      cornerRadius: ThemeTokens.imageRadius,
      style: .continuous
    )
  }

  private var stageSurface: Color {
    Color(.sRGB, white: 0.985, opacity: 1)
  }

  var body: some View {
    ThemeDestinationLink(link: logo.link, title: logo.altText) {
      ZStack {
        stageSurface

        GeometryReader { proxy in
          PipelineRemoteImage(
            request: NativeImageRequest(
              sourceURL: ShopifyAsset.url(
                from: logo.imageReference,
                width: 384
              ),
              pixelWidth: 384,
              aspectRatio: 3 / 2,
              backgroundTreatment: .none
            ),
            accessibilityLabel: nil
          ) { image in
            image
              .resizable()
              .interpolation(.high)
              .scaledToFit()
              .frame(
                width: proxy.size.width,
                height: proxy.size.height,
                alignment: .center
              )
          } placeholder: {
            stageSurface
          }
        }
        .padding(contentInsets)
        .clipped()
      }
      .frame(maxWidth: .infinity)
      .frame(height: stageHeight)
      .clipShape(stageShape)
      .overlay {
        stageShape.stroke(Color.black.opacity(0.08), lineWidth: 0.7)
      }
      .contentShape(stageShape)
    }
    .accessibilityIdentifier("home-logo-\(logo.id)")
  }
}

enum NativeHomeFooterContent {
  struct Benefit: Identifiable, Equatable {
    let title: String
    let subtitle: String
    let symbol: String
    let link: ThemeLink

    var id: String { title }
  }

  struct Link: Identifiable, Equatable {
    let title: String
    let link: ThemeLink

    var id: String { title }
  }

  // Verified against the public storefront footer and bundled theme export on
  // 31 July 2026. Keep the link labels and destinations in storefront order.
  static let benefits = [
    Benefit(
      title: "Convenient",
      subtitle: "Easy payments, returns, and exchanges.",
      symbol: "creditcard",
      link: .none
    ),
    Benefit(
      title: "Fast Delivery",
      subtitle: "Delivery options shown at checkout.",
      symbol: "truck.box",
      link: .none
    ),
    Benefit(
      title: "Wide Variety",
      subtitle: "1,400+ beauty products to shop on one platform.",
      symbol: "square.grid.2x2",
      link: .collection("skincare")
    ),
    Benefit(
      title: "Find a BeautyOnTApp",
      subtitle: "Choose Your Store",
      symbol: "mappin",
      link: ThemeLink("/pages/locations")
    ),
  ]

  // The twelve storefront links keep their storefront order, flowed into two
  // equal six-row columns so the block ends on one clean baseline instead of
  // leaving a dead corner under the shorter column.
  static let menuColumns = [
    [
      Link(title: "About Us", link: ThemeLink("/pages/about-us")),
      Link(title: "Careers", link: ThemeLink("/pages/careers")),
      Link(
        title: "Brands on Beauty on TApp",
        link: ThemeLink("/pages/brands")
      ),
      Link(title: "Blog", link: ThemeLink("/blogs/news")),
      Link(
        title: "Gift Vouchers",
        link: ThemeLink("/products/gift-card-1")
      ),
      Link(title: "Contact us", link: ThemeLink("/pages/contact")),
    ],
    [
      Link(
        title: "Ingredient Guide",
        link: ThemeLink("/pages/ingredient-glossary")
      ),
      Link(
        title: "Privacy Policy",
        link: ThemeLink("/policies/privacy-policy")
      ),
      Link(
        title: "Log Return / Exchange",
        link: ThemeLink("/policies/refund-policy")
      ),
      Link(
        title: "Sell on Beauty on TApp",
        link: ThemeLink("/pages/list-your-brand")
      ),
      Link(
        title: "Terms of Service",
        link: ThemeLink("/policies/terms-of-service")
      ),
      Link(
        title: "Delivery & Shipping",
        link: ThemeLink("/pages/delivery")
      ),
    ],
  ]

  static let appStoreLink = Link(
    title: "Download on the App Store",
    link: ThemeLink(
      "https://apps.apple.com/app/beautyontapp/id6754606514"
    )
  )

  static let googlePlayLink = Link(
    title: "Get it on Google Play",
    link: ThemeLink(
      "https://play.google.com/store/apps/details?id=app.shopbeautyontapp.co.za"
    )
  )

  static let socialLinks = [
    Link(
      title: "Facebook",
      link: ThemeLink("https://www.facebook.com/BeautyonTApp/")
    ),
    Link(
      title: "Instagram",
      link: ThemeLink("https://www.instagram.com/beautyontapp/")
    ),
    Link(
      title: "TikTok",
      link: ThemeLink("https://www.tiktok.com/@beautyontapp")
    ),
    Link(
      title: "X",
      link: ThemeLink("https://twitter.com/beautyontapp")
    ),
  ]
}

private struct NativeHomeFooter: View {
  @EnvironmentObject private var appModel: AppModel

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      benefits
      appBadges
      divider
        .padding(.top, 24)
      menuGrid
        .padding(.vertical, 28)
      divider
      footerBottom
        .padding(.vertical, 24)
    }
    .padding(.horizontal, ThemeTokens.horizontalPadding)
    .padding(.top, 16)
    .background(Color.black)
    .accessibilityIdentifier("home-native-footer")
  }

  private var benefits: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(NativeHomeFooterContent.benefits) { benefit in
        if benefit.title == "Find a BeautyOnTApp" {
          Button {
            appModel.selectDock(.stores)
          } label: {
            benefitLabel(benefit)
          }
          .buttonStyle(.plain)
        } else {
          ThemeDestinationLink(
            link: benefit.link,
            title: benefit.title
          ) {
            benefitLabel(benefit)
          }
        }
      }
    }
    .accessibilityIdentifier("home-footer-benefits")
  }

  private func benefitLabel(
    _ benefit: NativeHomeFooterContent.Benefit
  ) -> some View {
    HStack(spacing: 12) {
      Image(systemName: benefit.symbol)
        .font(.system(size: 17, weight: .regular))
        .foregroundStyle(Color.white)
        .frame(width: 38, height: 38)
        .background(Color.white.opacity(0.08))
        .overlay {
          RoundedRectangle(
            cornerRadius: 11,
            style: .continuous
          )
          .stroke(Color.white.opacity(0.18), lineWidth: 0.8)
        }
        .clipShape(
          RoundedRectangle(
            cornerRadius: 11,
            style: .continuous
          )
        )

      VStack(alignment: .leading, spacing: 2) {
        Text(benefit.title)
          .themeScaledFont(size: 14, weight: .bold)
          .foregroundStyle(Color.white)
        Text(benefit.subtitle)
          .themeScaledFont(size: 12)
          .foregroundStyle(Color.white.opacity(0.72))
      }

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, minHeight: 58)
    .contentShape(Rectangle())
  }

  private var appBadges: some View {
    VStack(alignment: .center, spacing: 14) {
      Text("Download the BeautyOnTApp App")
        .themeScaledFont(size: 15, weight: .bold)
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)

      HStack(spacing: 10) {
        storeBadge(
          NativeHomeFooterContent.appStoreLink,
          symbol: "apple.logo",
          eyebrow: "Download on the",
          store: "App Store"
        )
        storeBadge(
          NativeHomeFooterContent.googlePlayLink,
          symbol: "play.fill",
          eyebrow: "GET IT ON",
          store: "Google Play"
        )
      }
    }
    .padding(.top, 20)
    .accessibilityIdentifier("home-footer-app-badges")
  }

  private func storeBadge(
    _ item: NativeHomeFooterContent.Link,
    symbol: String,
    eyebrow: String,
    store: String
  ) -> some View {
    ThemeDestinationLink(link: item.link, title: item.title) {
      HStack(spacing: 7) {
        Image(systemName: symbol)
          .font(.system(size: 23, weight: .medium))
        VStack(alignment: .leading, spacing: -1) {
          Text(eyebrow)
            .font(.system(size: 7.5, weight: .medium))
          Text(store)
            .font(.system(size: 14, weight: .medium))
        }
      }
      .foregroundStyle(Color.white)
      .frame(maxWidth: .infinity)
      .frame(height: 42)
      .background(Color.black)
      .overlay {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
          .stroke(Color.white.opacity(0.75), lineWidth: 1)
      }
      .clipShape(
        RoundedRectangle(cornerRadius: 7, style: .continuous)
      )
    }
  }

  private var menuGrid: some View {
    HStack(alignment: .top, spacing: 22) {
      ForEach(
        Array(NativeHomeFooterContent.menuColumns.enumerated()),
        id: \.offset
      ) { _, column in
        VStack(alignment: .leading, spacing: 0) {
          ForEach(column) { item in
            menuLink(item)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .accessibilityIdentifier("home-footer-menu")
  }

  @ViewBuilder
  private func menuLink(
    _ item: NativeHomeFooterContent.Link
  ) -> some View {
    if item.title == "Ingredient Guide" {
      Button {
        appModel.openProfileIngredientGuide()
      } label: {
        menuLabel(item.title)
      }
      .buttonStyle(.plain)
    } else {
      ThemeDestinationLink(link: item.link, title: item.title) {
        menuLabel(item.title)
      }
    }
  }

  private func menuLabel(_ title: String) -> some View {
    Text(title)
      .themeScaledFont(size: 12, weight: .medium)
      .foregroundStyle(Color.white.opacity(0.92))
      .multilineTextAlignment(.leading)
      .lineLimit(1)
      .minimumScaleFactor(0.82)
      .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
      .contentShape(Rectangle())
  }

  private var footerBottom: some View {
    HStack(spacing: 16) {
      Text("© 2026 BeautyOnTApp")
        .themeScaledFont(size: 11.5)
        .foregroundStyle(Color.white.opacity(0.78))

      Spacer(minLength: 4)

      ForEach(NativeHomeFooterContent.socialLinks) { item in
        ThemeDestinationLink(link: item.link, title: item.title) {
          socialLabel(item.title)
        }
        .accessibilityLabel(item.title)
      }
    }
    .foregroundStyle(Color.white)
    .accessibilityIdentifier("home-footer-social-links")
  }

  @ViewBuilder
  private func socialLabel(_ title: String) -> some View {
    switch title {
    case "Facebook":
      Text("f")
        .font(.system(size: 18, weight: .black, design: .rounded))
        .frame(width: 24, height: 24)
    case "Instagram":
      Image(systemName: "camera")
        .font(.system(size: 17, weight: .semibold))
        .frame(width: 24, height: 24)
    case "TikTok":
      Image(systemName: "music.note")
        .font(.system(size: 17, weight: .bold))
        .frame(width: 24, height: 24)
    default:
      Text("𝕏")
        .font(.system(size: 17, weight: .semibold))
        .frame(width: 24, height: 24)
    }
  }

  private var divider: some View {
    Rectangle()
      .fill(Color.white.opacity(0.30))
      .frame(height: 0.7)
  }
}

private struct ThemeDestinationLink<Label: View>: View {
  @EnvironmentObject private var appModel: AppModel
  let link: ThemeLink
  let title: String
  private let label: Label

  init(
    link: ThemeLink,
    title: String,
    @ViewBuilder label: () -> Label
  ) {
    self.link = link
    self.title = title
    self.label = label()
  }

  @ViewBuilder
  var body: some View {
    switch link {
    case .collection(let handle):
      NativeNavigationLink(
        route: .collection(title: title, handle: handle)
      ) {
        label
      }
      .buttonStyle(.plain)

    case .web:
      Button {
        NativeHaptics.play(.navigation)
        appModel.openThemeLink(title: title, link: link)
      } label: {
        label
      }
      .nativePressResponse()

    case .booking(let url):
      Button {
        NativeHaptics.play(.navigation)
        appModel.presentWeb(
          title: title,
          url: url,
          allowsExternalNavigation: true,
          allowsCommerceNavigation: true
        )
      } label: {
        label
      }
      .nativePressResponse()

    case .external:
      Button {
        appModel.openThemeLink(title: title, link: link)
      } label: {
        label
      }
      .buttonStyle(.plain)

    case .none:
      label
    }
  }
}
