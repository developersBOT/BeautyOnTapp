import SwiftUI

enum StoreHeaderPresentation {
  case complete
  case primary
  case tabs
}

struct StoreHeader: View {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.colorScheme) private var colorScheme
  @Namespace private var tabSelectionNamespace
  @ObservedObject var appModel: AppModel
  let presentation: StoreHeaderPresentation
  let activeCollectionHandle: String?

  init(
    appModel: AppModel,
    presentation: StoreHeaderPresentation = .complete,
    activeCollectionHandle: String? = nil
  ) {
    self.appModel = appModel
    self.presentation = presentation
    self.activeCollectionHandle = activeCollectionHandle
  }

  private var tabs: [HeaderTab] {
    if let items = appModel.tabsMenu?.items, !items.isEmpty {
      return items.map {
        HeaderTab(
          id: HeaderTab.stableID(
            collectionHandle: $0.collectionHandle,
            url: $0.url,
            title: $0.title
          ),
          title: $0.title.trimmingCharacters(in: .whitespacesAndNewlines),
          collectionHandle: $0.collectionHandle,
          url: $0.url
        )
      }
    }
    return HeaderTab.fallback
  }

  private var headerGlassTint: Color {
    colorScheme == .dark
      // Keep the dark chrome legible without turning it into a grey sheet.
      ? Color.white.opacity(0.12)
      // On a white storefront, a white tint disappears into the canvas. A
      // near-neutral black tint is still optically light, but lets the
      // regular material's refractive edge read as glass instead of a plain
      // white outline.
      : Color.black.opacity(0.034)
  }

  private var headerSelectionTint: Color {
    colorScheme == .dark
      // A small lift separates the active lens from the neighbouring dark
      // pills without turning the rail into an opaque frosted strip.
      ? Color.white.opacity(0.19)
      // Keep the active lens legible without turning the rail into a grey
      // sheet; the system regular material supplies the optical highlight.
      : Color.black.opacity(0.075)
  }

  private var headerGlassStroke: Color {
    colorScheme == .dark
      ? Color.white.opacity(0.26)
      : Color.black.opacity(0.11)
  }

  private var headerGlassShadow: Color {
    colorScheme == .dark
      ? Color.black.opacity(0.18)
      : Color.black.opacity(0.07)
  }

  @ViewBuilder
  var body: some View {
    switch presentation {
    case .complete:
      VStack(spacing: 0) {
        primaryHeader

        Divider()
          .overlay(ThemeTokens.separator.opacity(0.45))

        tabsBar
      }
      .background(ThemeTokens.canvas)
    case .primary:
      primaryHeader

      Divider()
        .overlay(ThemeTokens.separator.opacity(0.45))
    case .tabs:
      tabsBar
    }
  }

  private var primaryHeader: some View {
    GeometryReader { proxy in
      let metrics = flexibleHeaderMetrics(totalWidth: proxy.size.width)

      headerControls(metrics: metrics)
      .padding(.horizontal, metrics.horizontalPadding)
      .frame(width: proxy.size.width, height: 52)
    }
    .frame(height: 52)
    .background {
      Rectangle()
        .fill(
          ThemeTokens.canvas.opacity(
            reduceTransparency || colorScheme == .light ? 1 : 0.92
          )
        )
    }
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(ThemeTokens.separator.opacity(0.35))
        .frame(height: 0.5)
    }
  }

  @ViewBuilder
  private func headerControls(
    metrics: (
      logo: CGFloat,
      search: CGFloat,
      horizontalPadding: CGFloat,
      spacing: CGFloat
    )
  ) -> some View {
    if #available(iOS 26.0, *) {
      // Match the control-row spacing so adjacent controls remain distinct
      // instead of being sampled as one fused glass shape.
      GlassEffectContainer(spacing: 4) {
        headerControlRow(metrics: metrics)
      }
    } else {
      headerControlRow(metrics: metrics)
    }
  }

  private func headerControlRow(
    metrics: (
      logo: CGFloat,
      search: CGFloat,
      horizontalPadding: CGFloat,
      spacing: CGFloat
    )
  ) -> some View {
    HStack(spacing: metrics.spacing) {
      logo(width: metrics.logo)
      searchButton(width: metrics.search)
      profileButton
      cartButton
      menuButton
    }
  }

  private func logo(width: CGFloat) -> some View {
    Button {
      NativeHaptics.play(.navigation)
      appModel.selectDock(.home)
    } label: {
      ZStack {
        Color.clear

        PipelineRemoteImage(
          request: NativeImageRequest(
            sourceURL: ShopifyAsset.url(
              from:
                "shopify://shop_images/beautyontapp-logo-transparent.png"
            ),
            pixelWidth: 500,
            aspectRatio: max(width / 31.5, 0.1)
          ),
          accessibilityLabel: nil
        ) { image in
          if colorScheme == .dark {
            image
              .resizable()
              .scaledToFill()
              // The storefront logo asset is a black transparent mark. In
              // Dark Mode invert only that mark so it remains legible on the
              // native system background while preserving the light look.
              .colorInvert()
          } else {
            image
              .resizable()
              .scaledToFill()
          }
        } placeholder: {
          Text("BEAUTY ON TAPP")
            .tracking(0.4)
            .themeScaledFont(size: 10.5, weight: .light)
          .foregroundStyle(ThemeTokens.ink)
        }
        .frame(width: width, height: 33)
        .clipped()
      }
      .frame(width: width, height: ThemeTokens.minimumTap)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel("BeautyOnTApp Home")
    .accessibilityIdentifier("header-home")
  }

  private func searchButton(width: CGFloat) -> some View {
    Button {
      NativeHaptics.play(.navigation)
      appModel.presentSearch()
    } label: {
      HStack(spacing: 7) {
        Image(systemName: "magnifyingglass")
          .font(.system(size: 21, weight: .regular))

        Text("Search")
          .themeScaledFont(size: 13)
          .foregroundStyle(ThemeTokens.muted)
          .lineLimit(1)
          .minimumScaleFactor(0.75)
      }
      .foregroundStyle(ThemeTokens.ink)
      .frame(width: width, height: 34)
      .adaptiveGlass(
        in: Capsule(),
        tint: headerGlassTint,
        interactive: true,
        variant: .regular
      )
      .overlay {
        Capsule()
          .stroke(headerGlassStroke, lineWidth: 0.8)
      }
      .shadow(color: headerGlassShadow, radius: 4, y: 1)
      .frame(width: width, height: ThemeTokens.minimumTap)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel("Search")
    .accessibilityIdentifier("header-search")
  }

  private func flexibleHeaderMetrics(
    totalWidth: CGFloat
  ) -> (
    logo: CGFloat,
    search: CGFloat,
    horizontalPadding: CGFloat,
    spacing: CGFloat
  ) {
    let compact = totalWidth < 350
    let horizontalPadding: CGFloat = compact ? 8 : 12
    let spacing: CGFloat = compact ? 3 : 4
    // Only the three trailing controls are fixed. The search capsule and
    // wordmark share the remaining width so neither is squeezed on a phone.
    let fixedWidth =
      (3 * ThemeTokens.minimumTap) + (4 * spacing) + (2 * horizontalPadding)
    let available = max(142, totalWidth - fixedWidth)
    let logoWidth = min(132, max(92, available * 0.50))
    return (
      logoWidth,
      max(64, available - logoWidth),
      horizontalPadding,
      spacing
    )
  }

  private var profileButton: some View {
    Button {
      NativeHaptics.play(.navigation)
      appModel.selectDock(.profile)
    } label: {
      Image(systemName: "person.fill")
        .font(.system(size: 17, weight: .semibold))
        .foregroundStyle(ThemeTokens.ink)
      .frame(width: 36, height: 36)
      .adaptiveGlass(
        in: Circle(),
        tint: headerGlassTint,
        interactive: true,
        variant: .regular
      )
      .overlay {
        Circle()
          .stroke(headerGlassStroke, lineWidth: 0.8)
      }
      .shadow(color: headerGlassShadow, radius: 4, y: 1)
      .contentShape(Rectangle())
      .frame(
        width: ThemeTokens.minimumTap,
        height: ThemeTokens.minimumTap
      )
    }
    .buttonStyle(.plain)
    .frame(
      width: ThemeTokens.minimumTap,
      height: ThemeTokens.minimumTap
    )
    .contentShape(Rectangle())
    .accessibilityLabel("Profile")
    .accessibilityIdentifier("header-profile")
  }

  private var cartButton: some View {
    Button {
      NativeHaptics.play(.navigation)
      appModel.presentCart()
    } label: {
      ZStack(alignment: .topTrailing) {
        HeaderBasketIcon()
          .frame(width: 24, height: 24)

        if appModel.cart.totalQuantity > 0 {
          Text("\(min(appModel.cart.totalQuantity, 99))")
            .themeScaledFont(size: 8, weight: .bold, maximumScale: 1.3)
            .foregroundStyle(.white)
            .frame(minWidth: 15, minHeight: 15)
            .background(Color(hex: 0xD10A2C), in: Circle())
            .offset(x: 5, y: -4)
        }
      }
      .frame(width: 36, height: 36)
      .adaptiveGlass(
        in: Circle(),
        tint: headerGlassTint,
        interactive: true,
        variant: .regular
      )
      .overlay {
        Circle()
          .stroke(headerGlassStroke, lineWidth: 0.8)
      }
      .shadow(color: headerGlassShadow, radius: 4, y: 1)
      .contentShape(Rectangle())
      .frame(
        width: ThemeTokens.minimumTap,
        height: ThemeTokens.minimumTap
      )
    }
    .buttonStyle(.plain)
    .frame(
      width: ThemeTokens.minimumTap,
      height: ThemeTokens.minimumTap
    )
    .contentShape(Rectangle())
    .foregroundStyle(ThemeTokens.ink)
    .accessibilityLabel("Bag, \(appModel.cart.totalQuantity) items")
    .accessibilityIdentifier("header-bag")
  }

  private var menuButton: some View {
    Button {
      NativeHaptics.play(.navigation)
      appModel.selectDock(.shop)
    } label: {
      HeaderMenuIcon()
        .frame(width: 24, height: 24)
        .frame(width: 36, height: 36)
        .adaptiveGlass(
          in: Circle(),
          tint: headerGlassTint,
          interactive: true,
          variant: .regular
        )
        .overlay {
          Circle()
            .stroke(headerGlassStroke, lineWidth: 0.8)
        }
        .shadow(color: headerGlassShadow, radius: 4, y: 1)
        .contentShape(Rectangle())
        .frame(
          width: ThemeTokens.minimumTap,
          height: ThemeTokens.minimumTap
        )
    }
    .buttonStyle(.plain)
    .frame(
      width: ThemeTokens.minimumTap,
      height: ThemeTokens.minimumTap
    )
    .contentShape(Rectangle())
    .foregroundStyle(ThemeTokens.ink)
    .accessibilityLabel("Open menu")
    .accessibilityIdentifier("header-menu")
  }

  private var tabsBar: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      if #available(iOS 26.0, *) {
        GlassEffectContainer(spacing: 5) {
          tabItems
        }
      } else {
        tabItems
      }
    }
    // Match the product-specific rails exactly so each pill row shares the
    // same baseline and the three navigation rails read as one grid.
    .frame(height: ResourceLinkRailMetrics.railHeight)
    // The rail itself is content, not another glass surface. The old
    // translucent rail sat underneath every glass pill and made the active
    // lens read as a frosted strip on iOS 27. A canvas gradient is not a
    // material — it cannot fuse with the pill glass — and it keeps scrolled
    // storefront content from colliding with the status bar and pills the
    // way Apple's soft scroll edge does. It disappears against the canvas
    // when the rail sits at its natural resting position.
    .background {
      if reduceTransparency {
        ThemeTokens.canvas.ignoresSafeArea(edges: .top)
      } else {
        LinearGradient(
          stops: [
            .init(color: ThemeTokens.canvas, location: 0),
            .init(color: ThemeTokens.canvas.opacity(0.94), location: 0.62),
            .init(color: ThemeTokens.canvas.opacity(0), location: 1)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea(edges: .top)
      }
    }
  }

  private var tabItems: some View {
    LazyHStack(
      alignment: .center,
      spacing: ResourceLinkRailMetrics.itemSpacing
    ) {
      ForEach(tabs) { tab in
        tabLink(tab)
      }
    }
    .padding(.horizontal, ResourceLinkRailMetrics.horizontalInset)
    .frame(
      height: ResourceLinkRailMetrics.railHeight,
      alignment: .center
    )
  }

  @ViewBuilder
  private func tabLink(_ tab: HeaderTab) -> some View {
    let isActive =
      (tab.title.caseInsensitiveCompare("Brands") == .orderedSame
        && activeCollectionHandle == "__brands__")
      || (tab.collectionHandle != nil
        && tab.collectionHandle
          == (activeCollectionHandle ?? appModel.rootCollection?.handle))
    let chip = Text(tab.title)
      .tracking(-0.14)
      .themeScaledFont(
        size: 14,
        weight: isActive ? .bold : .semibold
      )
      .foregroundStyle(ThemeTokens.ink)
      .padding(.horizontal, 12)
      .frame(
        height: ResourceLinkRailMetrics.itemHeight,
        alignment: .center
      )
      .modifier(
          HeaderTabSelectionModifier(
            isActive: isActive,
            reduceTransparency: reduceTransparency,
            reduceMotion: reduceMotion,
            selectionTint: headerSelectionTint,
            glassStroke: headerGlassStroke,
            namespace: tabSelectionNamespace
        )
      )
      .frame(
        height: ThemeTokens.minimumTap,
        alignment: .center
      )
      .contentShape(Rectangle())

    if let handle = tab.collectionHandle {
      Button {
        NativeHaptics.play(.selection)
        withAnimation(
          reduceMotion ? nil : ThemeTokens.navigationSpring
        ) {
          appModel.showCollection(title: tab.title, handle: handle)
        }
      } label: {
        chip
      }
      .buttonStyle(.plain)
      .accessibilityAddTraits(isActive ? .isSelected : [])
      .accessibilityIdentifier(tab.accessibilityIdentifier)
    } else if let url = tab.url {
      Button {
        NativeHaptics.play(.selection)
        appModel.openThemeLink(
          title: tab.title,
          link: ThemeLink(url.absoluteString)
        )
      } label: {
        chip
      }
      .buttonStyle(.plain)
      .accessibilityAddTraits(isActive ? .isSelected : [])
      .accessibilityIdentifier(tab.accessibilityIdentifier)
    } else {
      chip
        .accessibilityAddTraits(isActive ? .isSelected : [])
        .accessibilityIdentifier(tab.accessibilityIdentifier)
    }
  }
}

private struct HeaderTabSelectionModifier: ViewModifier {
  let isActive: Bool
  let reduceTransparency: Bool
  let reduceMotion: Bool
  let selectionTint: Color
  let glassStroke: Color
  let namespace: Namespace.ID
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var colorSchemeContrast

  @ViewBuilder
  func body(content: Content) -> some View {
    if isActive {
      if reduceTransparency {
        content
          .background {
            Capsule()
              .fill(ThemeTokens.controlSurface)
          }
          .overlay {
            Capsule()
              .stroke(
                ThemeTokens.deepGold.opacity(
                  colorSchemeContrast == .increased ? 0.76 : 0.44
                ),
                lineWidth: colorSchemeContrast == .increased ? 1.3 : 1
              )
          }
          .matchedGeometryEffect(
            id: "header-tab-selection",
            in: namespace
          )
      } else if #available(iOS 26.0, *) {
        content
          .glassEffect(
            // The selected collection is the navigation lens.  Use the
            // general-purpose regular material so it remains visibly
            // distinct from the ambient glass on neighbouring filters while
            // still allowing the iOS 27 renderer to refract the rail behind
            // it.
            Glass.regular
              .tint(selectionTint)
              .interactive(),
            in: Capsule()
          )
          .glassEffectID(
            "header-tab-selection",
            in: namespace
          )
          .glassEffectTransition(
            reduceMotion ? .identity : .matchedGeometry
          )
          .overlay {
            Capsule()
              .stroke(
                colorSchemeContrast == .increased
                  ? Color.primary.opacity(0.50)
                  : glassStroke,
                lineWidth: colorSchemeContrast == .increased ? 1.2 : 0.9
              )
          }
          .shadow(
            color: ThemeTokens.deepGold.opacity(0.18),
            radius: 8,
            y: 3
          )
      } else {
        content
          .background(.ultraThinMaterial, in: Capsule())
          .overlay {
            Capsule()
              .stroke(ThemeTokens.deepGold.opacity(0.34), lineWidth: 0.9)
          }
          .matchedGeometryEffect(
            id: "header-tab-selection",
            in: namespace
          )
      }
    } else {
      if #available(iOS 26.0, *), !reduceTransparency {
        // Inactive filters are still navigation controls, but they must not
        // add a second opaque rail behind the selected lens. Keep them in the
        // same GlassEffectContainer and use the platform's un-tinted regular
        // material; only the active item carries the selection tint and
        // matched glass identity.
        content
          .glassEffect(
            Glass.regular.interactive(),
            in: Capsule()
          )
      } else {
        content
          .background {
            Capsule()
              .fill(ThemeTokens.canvas.opacity(0.72))
          }
          .overlay {
            Capsule()
              .stroke(ThemeTokens.separator.opacity(0.42), lineWidth: 0.6)
          }
      }
    }
  }
}

private struct HeaderBasketIcon: View {
  var body: some View {
    Canvas { context, size in
      let sx = size.width / 24
      let sy = size.height / 24

      func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x * sx, y: y * sy)
      }

      var path = Path()
      path.move(to: point(1.3, 9.2))
      path.addLine(to: point(22.7, 9.2))
      path.addLine(to: point(19.5, 22))
      path.addLine(to: point(4.5, 22))
      path.closeSubpath()

      path.move(to: point(6.4, 7.2))
      path.addLine(to: point(10.8, 2.9))
      path.addCurve(
        to: point(13.2, 2.9),
        control1: point(11.5, 2.2),
        control2: point(12.5, 2.2)
      )
      path.addLine(to: point(17.6, 7.2))

      path.move(to: point(3.1, 13))
      path.addLine(to: point(20.9, 13))
      path.move(to: point(3.9, 16.8))
      path.addLine(to: point(20.1, 16.8))
      path.move(to: point(4.8, 20.5))
      path.addLine(to: point(19.2, 20.5))

      context.stroke(
        path,
        with: .color(ThemeTokens.ink),
        style: StrokeStyle(
          lineWidth: 1.35,
          lineCap: .round,
          lineJoin: .round
        )
      )
    }
    .accessibilityHidden(true)
  }
}

private struct HeaderMenuIcon: View {
  var body: some View {
    Canvas { context, size in
      var path = Path()
      path.move(to: CGPoint(x: 2, y: size.height * 0.36))
      path.addLine(to: CGPoint(x: size.width - 2, y: size.height * 0.36))
      path.move(to: CGPoint(x: 2, y: size.height * 0.65))
      path.addLine(to: CGPoint(x: size.width - 2, y: size.height * 0.65))
      context.stroke(
        path,
        with: .color(ThemeTokens.ink),
        style: StrokeStyle(lineWidth: 2.2, lineCap: .round)
      )
    }
    .accessibilityHidden(true)
  }
}

private struct HeaderTab: Identifiable {
  let id: String
  let title: String
  let collectionHandle: String?
  let url: URL?

  var accessibilityIdentifier: String {
    "header-tab-"
      + title
      .lowercased()
      .replacingOccurrences(
        of: "[^a-z0-9]+",
        with: "-",
        options: .regularExpression
      )
      .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
  }

  static func stableID(
    collectionHandle: String?,
    url: URL?,
    title: String
  ) -> String {
    if let collectionHandle {
      return "collection-\(collectionHandle)"
    }
    if let url {
      return "web-\(url.path)"
    }
    return "label-\(title.lowercased())"
  }

  static let fallback: [HeaderTab] = [
    .web("Brands", "/pages/brands"),
    .collection("Skincare", "skincare"),
    .collection("Korean Skincare", "korean-skincare"),
    .collection("Bath & Body", "body-wash-and-lotions"),
    .collection("Moisturisers", "moisturisers"),
    .collection("Shower Gel", "shower-gel"),
    .collection("Mini Size", "mini-size"),
    .collection("Beauty Under R200", "smart-collection"),
    .collection("Bundle Deals", "bundle-deals"),
    .collection("Sunscreen", "sunscreen"),
    .collection("Hair-care", "hair"),
    .collection("Make Up", "make-up"),
    .collection("Fragrance", "cologne"),
    .collection("Men", "beard"),
    .collection("Sale & Offers", "clearance-sale"),
    .web("Book Smart Analysis", "/pages/make-services"),
  ]

  private static func collection(_ title: String, _ handle: String) -> HeaderTab {
    HeaderTab(
      id: "collection-\(handle)",
      title: title,
      collectionHandle: handle,
      url: ShopifyAsset.shopRoot.appendingPathComponent("collections/\(handle)")
    )
  }

  private static func web(_ title: String, _ path: String) -> HeaderTab {
    HeaderTab(
      id: "web-\(path)",
      title: title,
      collectionHandle: nil,
      url: ShopifyAsset.shopRoot.appendingPathComponent(
        String(path.drop(while: { $0 == "/" }))
      )
    )
  }
}
