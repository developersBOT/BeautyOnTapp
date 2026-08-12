import SwiftUI

enum ResourceLinkRailMetrics {
  static let railHeight: CGFloat = 44
  static let breadcrumbHeight: CGFloat = 30
  static let itemHeight: CGFloat = 34
  static let fontSize: CGFloat = 14
  static let itemSpacing: CGFloat = 5
  static let horizontalInset: CGFloat = 8
}

struct ResourceLinkRailsView: View {
  let rails: ResourceLinkRails
  let open: (String, ThemeLink) -> Void

  // The featured chip rail (New, Best Seller, Clean, Vegan, …) is useful on
  // the live theme but consumes a full navigation row in the native app. Keep
  // the product/category-specific quick links and breadcrumbs visible while
  // the compact native layout is being evaluated.
  private let showsFeaturedRail = false

  var body: some View {
    if !rails.isEmpty {
      VStack(spacing: 0) {
        if showsFeaturedRail, !rails.featured.isEmpty {
          ResourceLinkRailView(
            kind: .featured,
            items: rails.featured,
            open: open
          )
        }
        if !rails.quick.isEmpty {
          ResourceLinkRailView(
            kind: .quick,
            items: rails.quick,
            open: open
          )
        }
        if !rails.breadcrumb.isEmpty {
          ResourceBreadcrumbView(
            items: rails.breadcrumb,
            open: open
          )
        }
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier("resource-link-rails")
    }
  }
}

private struct ResourceLinkRailView: View {
  @Environment(\.accessibilityReduceTransparency)
  private var reduceTransparency
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.colorSchemeContrast) private var colorSchemeContrast
  @Namespace private var selectionNamespace

  let kind: ResourceLinkRailKind
  let items: [ResourceLinkItem]
  let open: (String, ThemeLink) -> Void

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      if #available(iOS 26.0, *) {
        GlassEffectContainer(spacing: 5) {
          railItems
        }
      } else {
        railItems
      }
    }
    .background {
      if reduceTransparency {
        ThemeTokens.cardSurface
      } else {
        Rectangle().fill(ThemeTokens.canvas.opacity(0.98))
      }
    }
    .frame(height: ResourceLinkRailMetrics.railHeight)
    .overlay(alignment: .top) {
      Rectangle()
        .fill(ThemeTokens.separator.opacity(0.35))
        .frame(height: 0.7)
    }
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(ThemeTokens.separator.opacity(0.56))
        .frame(height: 0.7)
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel(kind.accessibilityLabel)
    .accessibilityIdentifier("resource-link-\(kind.rawValue)-rail")
  }

  private var railItems: some View {
    LazyHStack(
      alignment: .center,
      spacing: ResourceLinkRailMetrics.itemSpacing
    ) {
      ForEach(items) { item in
        Button {
          NativeHaptics.play(.selection)
          open(item.label, item.link)
        } label: {
          HStack(spacing: 9) {
            Text(item.label)
              .kerning(-0.13)
              .lineLimit(1)
            if kind == .featured {
              icon(for: item)
            }
          }
          .themeScaledFont(
            size: ResourceLinkRailMetrics.fontSize,
            weight: item.isCurrent ? .bold : .semibold,
            maximumScale: 1.5
          )
          .foregroundStyle(ThemeTokens.ink)
          .padding(.horizontal, 12)
          .frame(height: ResourceLinkRailMetrics.itemHeight)
          .modifier(
            ResourceLinkSelectionGlassModifier(
              isCurrent: item.isCurrent,
              reduceTransparency: reduceTransparency,
              reduceMotion: reduceMotion,
              increasedContrast: colorSchemeContrast == .increased,
              namespace: selectionNamespace
            )
          )
          .frame(
            height: ThemeTokens.minimumTap,
            alignment: .center
          )
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.label)
        .accessibilityHint("Opens \(item.label)")
        .accessibilityAddTraits(
          item.isCurrent ? .isSelected : []
        )
        .accessibilityIdentifier(
          "resource-link-\(kind.rawValue)-\(item.id)"
        )
      }
    }
    .padding(.horizontal, ResourceLinkRailMetrics.horizontalInset)
    .frame(
      height: ResourceLinkRailMetrics.railHeight,
      alignment: .center
    )
  }

  @ViewBuilder
  private func icon(for item: ResourceLinkItem) -> some View {
    if let imageURL = item.imageURL {
      PipelineRemoteImage(
        request: NativeImageRequest(
          sourceURL: imageURL,
          pixelWidth: 64
        ),
        accessibilityLabel: nil
      ) { image in
        image
          .resizable()
          .scaledToFit()
      } placeholder: {
        Color.clear
      }
      .frame(width: 18, height: 18)
      .accessibilityHidden(true)
    } else if let symbolName = symbolName(for: item.iconHint) {
      Image(systemName: symbolName)
        .font(.system(size: 16, weight: .regular))
        .foregroundStyle(
          item.iconColorHex.map { Color(hex: $0) }
            ?? ThemeTokens.ink
        )
        .frame(width: 18, height: 18)
        .accessibilityHidden(true)
    }
  }

  private func symbolName(for iconHint: String?) -> String? {
    switch iconHint {
    case "sparkle":
      return "sparkles"
    case "award":
      return "rosette"
    case "check":
      return "checkmark.circle"
    case "leaf":
      return "leaf"
    case "mini":
      return "shippingbox"
    case "gift":
      return "gift"
    default:
      return nil
    }
  }
}

private struct ResourceLinkSelectionGlassModifier: ViewModifier {
  let isCurrent: Bool
  let reduceTransparency: Bool
  let reduceMotion: Bool
  let increasedContrast: Bool
  let namespace: Namespace.ID

  @ViewBuilder
  func body(content: Content) -> some View {
    if isCurrent {
      if reduceTransparency {
        content
          .background {
            Capsule()
              .fill(ThemeTokens.controlSurface)
          }
          .overlay {
            Capsule()
              .stroke(
                ThemeTokens.deepGold.opacity(increasedContrast ? 0.72 : 0.40),
                lineWidth: increasedContrast ? 1.3 : 1
              )
          }
          .matchedGeometryEffect(
            id: "resource-link-selection",
            in: namespace
          )
      } else if #available(iOS 26.0, *) {
        content
          .glassEffect(
            Glass.regular
              .tint(ThemeTokens.glassSelectionTint)
              .interactive(),
            in: Capsule()
          )
          .glassEffectID(
            "resource-link-selection",
            in: namespace
          )
          .glassEffectTransition(
            reduceMotion ? .identity : .matchedGeometry
          )
          .overlay {
            Capsule()
              .stroke(
                increasedContrast
                  ? ThemeTokens.ink.opacity(0.42)
                  : ThemeTokens.glassStroke,
                lineWidth: increasedContrast ? 1.2 : 0.9
              )
          }
          .shadow(
            color: ThemeTokens.deepGold.opacity(0.16),
            radius: 7,
            y: 2
          )
      } else {
        content
          .background(.ultraThinMaterial, in: Capsule())
          .overlay {
            Capsule()
              .stroke(
                ThemeTokens.deepGold.opacity(increasedContrast ? 0.68 : 0.34),
                lineWidth: increasedContrast ? 1.2 : 0.9
              )
          }
          .matchedGeometryEffect(
            id: "resource-link-selection",
            in: namespace
          )
      }
    } else {
      if #available(iOS 26.0, *) {
        // Secondary and product-specific rails are controls too.  Give their
        // inactive pills the same restrained system lens as the main tabs;
        // the current item still receives the stronger moving selection lens.
        content
          .glassEffect(
            Glass.regular
              .tint(ThemeTokens.glassNavigationTint)
              .interactive(),
            in: Capsule()
          )
          .overlay {
            Capsule()
              .stroke(
              ThemeTokens.glassStroke.opacity(0.72),
                lineWidth: increasedContrast ? 1.1 : 0.7
              )
          }
      } else {
        content
          .background {
            Capsule()
              .fill(ThemeTokens.controlSurface.opacity(0.56))
          }
          .overlay {
            Capsule()
              .stroke(ThemeTokens.separator.opacity(0.56), lineWidth: 0.6)
          }
      }
    }
  }
}

private struct ResourceBreadcrumbView: View {
  let items: [ResourceBreadcrumbItem]
  let open: (String, ThemeLink) -> Void

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 6) {
        ForEach(Array(items.enumerated()), id: \.element.id) {
          offset,
          item in
          if offset > 0 {
            Image(systemName: "chevron.right")
              .font(.system(size: 9, weight: .semibold))
              .foregroundStyle(ThemeTokens.soft)
              .accessibilityHidden(true)
          }

          if let link = item.link {
            Button {
              open(item.label, link)
            } label: {
              Text(item.label)
                .themeScaledFont(
                  size: 11,
                  weight: item.isCurrent
                    ? .semibold
                    : .regular,
                  maximumScale: 1.5
                )
                .foregroundStyle(
                  item.isCurrent
                    ? ThemeTokens.ink
                    : ThemeTokens.muted
                )
                .lineLimit(1)
                .frame(height: ResourceLinkRailMetrics.breadcrumbHeight)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.label)
            .accessibilityHint("Opens \(item.label)")
            .accessibilityAddTraits(
              item.isCurrent ? .isSelected : []
            )
          } else {
            Text(item.label)
              .themeScaledFont(
                size: 11,
                weight: .semibold,
                maximumScale: 1.5
              )
              .foregroundStyle(ThemeTokens.ink)
              .lineLimit(1)
              .frame(height: ResourceLinkRailMetrics.breadcrumbHeight)
              .accessibilityAddTraits(.isSelected)
          }
        }
      }
      .padding(.horizontal, 20)
    }
    .frame(height: ResourceLinkRailMetrics.breadcrumbHeight)
    .background(ThemeTokens.canvas)
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Breadcrumbs")
    .accessibilityIdentifier("resource-breadcrumb")
  }
}
