import SwiftUI
import UIKit

enum NativeHapticRole {
  case selection
  case navigation
  case dismiss
  case destructive
}

@MainActor
private final class NativeHapticGeneratorPool {
  static let shared = NativeHapticGeneratorPool()

  let selection = UISelectionFeedbackGenerator()
  let navigation = UIImpactFeedbackGenerator(style: .soft)
  let dismiss = UIImpactFeedbackGenerator(style: .soft)
  let destructive = UINotificationFeedbackGenerator()
}

enum NativeHaptics {
  /// A single calm interaction language for native controls. UIKit honours
  /// the device System Haptics setting, and the retained generators keep the
  /// response in the same frame as the visual press state.
  @MainActor
  static func prepare(_ role: NativeHapticRole) {
    let pool = NativeHapticGeneratorPool.shared
    switch role {
    case .selection:
      pool.selection.prepare()
    case .navigation:
      pool.navigation.prepare()
    case .dismiss:
      pool.dismiss.prepare()
    case .destructive:
      pool.destructive.prepare()
    }
  }

  @MainActor
  static func play(_ role: NativeHapticRole) {
    let pool = NativeHapticGeneratorPool.shared
    switch role {
    case .selection:
      pool.selection.selectionChanged()
    case .navigation:
      pool.navigation.impactOccurred(intensity: 0.58)
    case .dismiss:
      pool.dismiss.impactOccurred(intensity: 0.48)
    case .destructive:
      pool.destructive.notificationOccurred(.warning)
    }
    prepare(role)
  }
}

extension View {
  /// Gives the native navigation layer Apple's soft scroll-edge treatment on
  /// iOS 26/27 while keeping the older deployment fallback unchanged. The
  /// storefront content remains opaque; only the edge separation adapts as
  /// content moves beneath the header.
  @ViewBuilder
  func nativeSoftTopScrollEdgeEffect() -> some View {
    if #available(iOS 26.0, *) {
      scrollEdgeEffectStyle(.soft, for: .top)
    } else {
      self
    }
  }

  func adaptiveGlass<S: Shape>(
    in shape: S,
    tint: Color? = nil,
    interactive: Bool = false,
    variant: NativeGlassVariant = .regular
  ) -> some View {
    modifier(
      AdaptiveGlassModifier(
        shape: shape,
        tint: tint,
        interactive: interactive,
        variant: variant
      )
    )
  }

  func nativeGlassButton(
    _ role: NativeGlassButtonRole = .standard
  ) -> some View {
    modifier(NativeGlassButtonModifier(role: role))
  }

  func nativePressResponse(
    scale: CGFloat = 0.98
  ) -> some View {
    buttonStyle(NativePressButtonStyle(scale: scale))
  }

  func nativeSheetStyle(
    _ style: NativeSheetStyle
  ) -> some View {
    modifier(NativeSheetPresentationModifier(style: style))
  }
}

enum NativeGlassVariant {
  case regular
  case clear
}

enum NativeGlassButtonRole {
  case standard
  case prominent
}

enum NativeSheetStyle {
  case large
  case profile
  case options
}

private struct NativeSheetPresentationModifier: ViewModifier {
  let style: NativeSheetStyle

  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(iOS 16.4, *) {
      switch style {
      case .large:
        content
          .presentationDetents([.large])
          .presentationDragIndicator(.hidden)
          .presentationCornerRadius(32)
          .presentationBackground(.regularMaterial)
          .presentationContentInteraction(.scrolls)
      case .profile:
        content
          // Profile is a compact action sheet, not a second full screen. The
          // resting detent is sized so the SHOPPING and EXPLORE rows finish on
          // a clean card boundary instead of clipping mid-row; the large
          // detent remains one drag away for the full account surface.
          .presentationDetents([.fraction(0.64), .large])
          .presentationDragIndicator(.hidden)
          .presentationCornerRadius(32)
          .presentationBackground(.regularMaterial)
          .presentationContentInteraction(.scrolls)
      case .options:
        content
          // Product option sheets use a compact fixed detent. The options
          // area scrolls when a product has more values, so a simple product
          // never leaves an empty panel below its two purchase actions.
          .presentationDetents([.height(354)])
          .presentationDragIndicator(.hidden)
          .presentationCornerRadius(32)
          .presentationBackground(.regularMaterial)
          .presentationContentInteraction(.scrolls)
      }
    } else if #available(iOS 16.0, *) {
      switch style {
      case .large:
        content
          .presentationDetents([.large])
          .presentationDragIndicator(.hidden)
      case .profile:
        content
          .presentationDetents([.fraction(0.52)])
          .presentationDragIndicator(.hidden)
      case .options:
        content
          .presentationDetents([.height(354)])
          .presentationDragIndicator(.hidden)
      }
    } else {
      content
    }
  }
}

private struct AdaptiveGlassModifier<S: Shape>: ViewModifier {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @Environment(\.colorSchemeContrast) private var colorSchemeContrast

  let shape: S
  let tint: Color?
  let interactive: Bool
  let variant: NativeGlassVariant

  @ViewBuilder
  func body(content: Content) -> some View {
    if reduceTransparency {
      content
        .background(Color(uiColor: .systemBackground), in: shape)
        .overlay {
          shape.stroke(
            Color.primary.opacity(
              colorSchemeContrast == .increased ? 0.38 : 0.18
            ),
            lineWidth: colorSchemeContrast == .increased ? 1.2 : 0.8
          )
        }
        .shadow(color: Color.black.opacity(0.10), radius: 10, y: 4)
    } else if #available(iOS 26.0, *) {
      let glass = variant == .clear ? Glass.clear : Glass.regular
      content.glassEffect(
        glass
          .tint(tint)
          .interactive(interactive),
        in: shape
      )
      .overlay {
        if colorSchemeContrast == .increased {
          shape.stroke(Color.primary.opacity(0.38), lineWidth: 1.2)
        }
      }
    } else {
      content
        .background(.ultraThinMaterial, in: shape)
        .overlay {
          shape.stroke(
            ThemeTokens.separator.opacity(
              colorSchemeContrast == .increased ? 0.92 : 0.68
            ),
            lineWidth: colorSchemeContrast == .increased ? 1.2 : 0.8
          )
        }
        .shadow(color: Color.black.opacity(0.11), radius: 18, y: 8)
    }
  }
}

private struct NativeGlassButtonModifier: ViewModifier {
  let role: NativeGlassButtonRole

  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(iOS 26.0, *) {
      switch role {
      case .standard:
        content.buttonStyle(.glass)
      case .prominent:
        content.buttonStyle(.glassProminent)
      }
    } else {
      content.buttonStyle(
        NativePressButtonStyle(scale: 0.98)
      )
    }
  }
}

struct NativePressButtonStyle: ButtonStyle {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  let scale: CGFloat

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .contentShape(Rectangle())
      .scaleEffect(configuration.isPressed && !reduceMotion ? scale : 1)
      .opacity(configuration.isPressed ? 0.93 : 1)
      .animation(
        reduceMotion ? nil : ThemeTokens.controlSpring,
        value: configuration.isPressed
      )
  }
}

struct GlassCard<Content: View>: View {
  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      // Product and list cards are stable content surfaces, not another layer
      // of glass. Restrict material effects to navigation and transient UI.
      .background(
        ThemeTokens.cardSurface,
        in: RoundedRectangle(cornerRadius: ThemeTokens.cardRadius, style: .continuous)
      )
      .overlay {
        RoundedRectangle(cornerRadius: ThemeTokens.cardRadius, style: .continuous)
          .stroke(ThemeTokens.separator.opacity(0.72), lineWidth: 0.8)
      }
      .clipShape(RoundedRectangle(cornerRadius: ThemeTokens.cardRadius, style: .continuous))
      .shadow(color: Color.black.opacity(0.07), radius: 12, y: 5)
  }
}
