import SwiftUI

enum ThemeTokens {
  // Keep neutral chrome semantic so the native surface follows the system
  // appearance, Increase Contrast and accessibility settings. Brand accents
  // below remain explicit because they carry BeautyOnTApp meaning.
  static let ink = Color(uiColor: .label)
  static let muted = Color(uiColor: .secondaryLabel)
  static let soft = Color(uiColor: .tertiaryLabel)
  static let gold = Color(hex: 0xC8A951)
  static let deepGold = Color(hex: 0xA48840)
  // Gold remains a branded light surface, so use a stable dark foreground
  // rather than the system background (which becomes light in Dark Mode).
  static let onGold = Color(hex: 0x241D08)
  static let sale = Color(hex: 0xD12B23)
  static let success = Color(hex: 0x16A34A)
  static let canvas = Color(uiColor: .systemBackground)
  static let groupedCanvas = adaptiveSurface(
    light: .systemBackground,
    dark: .systemGroupedBackground
  )
  // Keep the light storefront faithful to the white Shopify surface. The
  // darker alternatives are retained for the deferred dark-mode pass rather
  // than leaking iOS grouped grey into the primary shopping experience.
  static let cardSurface = adaptiveSurface(
    light: .systemBackground,
    dark: .secondarySystemBackground
  )
  static let elevatedSurface = adaptiveSurface(
    light: .systemBackground,
    dark: .tertiarySystemBackground
  )
  static let controlSurface = adaptiveSurface(
    light: .systemBackground,
    dark: .secondarySystemBackground
  )
  static let primaryButton = Color(uiColor: .label)
  static let primaryButtonForeground = Color(uiColor: .systemBackground)
  static let link = Color(uiColor: .link)
  static let deliveryAccent = Color(uiColor: .systemBlue)
  static let noteAccent = Color(uiColor: .systemPurple)
  static let dangerAccent = Color(uiColor: .systemPink)
  static let deliverySurface = Color(uiColor: .systemBlue).opacity(0.12)
  static let noteSurface = Color(uiColor: .systemPurple).opacity(0.12)
  static let successSurface = Color(uiColor: .systemGreen).opacity(0.12)
  static let dangerSurface = Color(uiColor: .systemPink).opacity(0.12)
  static let imageSurface = Color.white
  static let separator = Color(uiColor: .separator)
  // Keep Liquid Glass optically light. The content below should remain the
  // visual anchor; the glass supplies a moving edge and depth, not a blur veil.
  static let glassControlTint = Color.white.opacity(0.10)
  static let glassNavigationTint = Color.white.opacity(0.08)
  static let glassSelectionTint = Color.white.opacity(0.035)
  static let glassOptionSelectionTint = Color.white.opacity(0.22)
  static let glassDockTint = Color.white.opacity(0.14)
  static let glassDockSelectionTint = Color.white.opacity(0.025)
  static let glassStroke = Color.white.opacity(0.32)

  // One deliberate step up across native text keeps labels, product data and
  // controls legible together instead of relying on per-screen overrides.
  static let typeScale: CGFloat = 1.08

  static let cardRadius: CGFloat = 22
  static let imageRadius: CGFloat = 16
  static let sheetRadius: CGFloat = 28
  static let dockRadius: CGFloat = 30
  static let minimumTap: CGFloat = 44

  // Source locked to bot-app-ui.css and the exported homepage template.
  // These are layout values from the storefront, not a new native design scale.
  static let horizontalPadding: CGFloat = 20
  static let sectionSpacing: CGFloat = 0
  static let sectionVerticalPadding: CGFloat = 12

  static let greetingTopMargin: CGFloat = 14
  static let greetingBottomMargin: CGFloat = 4
  static let greetingTitleTopMargin: CGFloat = 7
  static let greetingTitleBottomMargin: CGFloat = 4
  static let greetingSubtextTopMargin: CGFloat = 6

  static let heroHorizontalInset: CGFloat = 10
  static let heroSpacing: CGFloat = 10
  static let heroTopMargin: CGFloat = 10
  static let heroBodyMinHeight: CGFloat = 112
  static let heroImageAspectRatio: CGFloat = 1.5

  static let productCardWidth: CGFloat = 172
  static let productGridCardMaxWidth: CGFloat = 180
  static let productCardImageAspectRatio: CGFloat = 1.12
  static let productCardImageScale: CGFloat = 0.90
  static let productCardCornerRadius: CGFloat = 18
  static let productCardTextSize: CGFloat = 11.5
  static let productCardVendorHeight: CGFloat = 15
  static let productCardTitleHeight: CGFloat = 36
  static let productCardRatingHeight: CGFloat = 18
  static let productCardPriceHeight: CGFloat = 23
  static let productRailTightGap: CGFloat = 2
  static let productRailGap: CGFloat = 10

  // Navigation and control feedback intentionally settle without an elastic
  // rebound. Momentum is reserved for direct-drag lenses only.
  static let controlSpring = Animation.spring(
    response: 0.34,
    dampingFraction: 1.0,
    blendDuration: 0.08
  )
  static let navigationSpring = Animation.spring(
    response: 0.38,
    dampingFraction: 1.0,
    blendDuration: 0.08
  )
  static let gestureMomentumSpring = Animation.spring(
    response: 0.32,
    dampingFraction: 0.82,
    blendDuration: 0.10
  )
  static let imageReveal = Animation.spring(
    response: 0.32,
    dampingFraction: 0.92,
    blendDuration: 0.08
  )

  private static func adaptiveSurface(
    light: UIColor,
    dark: UIColor
  ) -> Color {
    Color(
      uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? dark : light
      }
    )
  }
}

extension Color {
  init(hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: alpha
    )
  }

  init?(hexString: String?) {
    guard var value = hexString?.trimmingCharacters(in: .whitespacesAndNewlines),
      !value.isEmpty
    else {
      return nil
    }
    if value.hasPrefix("#") {
      value.removeFirst()
    }
    guard value.count == 6, let number = UInt(value, radix: 16) else {
      return nil
    }
    self.init(hex: number)
  }
}

enum MoneyFormatter {
  private static let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.numberStyle = .decimal
    formatter.decimalSeparator = "."
    formatter.groupingSeparator = ","
    formatter.usesGroupingSeparator = true
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter
  }()

  static func string(decimal: Decimal) -> String {
    let amount =
      formatter.string(from: decimal as NSDecimalNumber)
      ?? NSDecimalNumber(decimal: decimal).stringValue
    return "R \(amount)"
  }

  static func string(shopifyDecimal: String) -> String {
    string(decimal: Decimal(string: shopifyDecimal) ?? 0)
  }

  static func string(cents: Int) -> String {
    string(decimal: Decimal(cents) / 100)
  }
}
