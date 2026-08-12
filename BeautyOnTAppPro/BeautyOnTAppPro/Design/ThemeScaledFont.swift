import SwiftUI

private struct ThemeScaledFontModifier: ViewModifier {
    @ScaledMetric private var scaledSize: CGFloat

    private let baseSize: CGFloat
    private let maximumScale: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design

  init(
    size: CGFloat,
        weight: Font.Weight,
        design: Font.Design,
    relativeTo textStyle: Font.TextStyle?,
    maximumScale: CGFloat
  ) {
    let scaledBaseSize = size * ThemeTokens.typeScale
    baseSize = scaledBaseSize
    self.maximumScale = max(1, maximumScale)
    self.weight = weight
    self.design = design
    _scaledSize = ScaledMetric(
      wrappedValue: scaledBaseSize,
      relativeTo: textStyle
        ?? Self.inferredTextStyle(for: scaledBaseSize)
    )
  }

    @ViewBuilder
    func body(content: Content) -> some View {
        let effectiveSize = min(scaledSize, baseSize * maximumScale)
        let sized = content.font(
            .system(
                size: effectiveSize,
                weight: weight,
                design: design
            )
        )
        if #available(iOS 16.0, *) {
            sized.tracking(Self.tracking(for: effectiveSize))
        } else {
            sized
        }
    }

    /// Size-specific tracking, following SF's optical-size behaviour: small
    /// text opens up slightly for legibility, large display text tightens so
    /// letters do not drift apart as they grow. Body sizes stay neutral.
    private static func tracking(for size: CGFloat) -> CGFloat {
        switch size {
        case ..<12:
            return 0.12
        case ..<20:
            return 0
        case ..<28:
            return -0.26
        default:
            return -0.5
        }
    }

    private static func inferredTextStyle(for size: CGFloat) -> Font.TextStyle {
        switch size {
        case ..<10:
            return .caption2
        case ..<13:
            return .caption
        case ..<16:
            return .subheadline
        case ..<19:
            return .body
        case ..<23:
            return .headline
        default:
            return .title2
        }
    }
}

extension View {
    /// Preserves the exported theme's point size at the default content size
    /// while allowing legible, bounded Dynamic Type growth in fixed card layouts.
    func themeScaledFont(
        size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default,
        relativeTo textStyle: Font.TextStyle? = nil,
        maximumScale: CGFloat = 1.5
    ) -> some View {
        modifier(
            ThemeScaledFontModifier(
                size: size,
                weight: weight,
                design: design,
                relativeTo: textStyle,
                maximumScale: maximumScale
            )
        )
    }
}
