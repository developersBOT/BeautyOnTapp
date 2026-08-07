import SwiftUI

struct ProfileSheet: View {
  @EnvironmentObject private var appModel: AppModel
  @Environment(\.accessibilityReduceTransparency)
  private var reduceTransparency
  @AccessibilityFocusState private var isTitleFocused: Bool
  @GestureState private var dragOffset: CGFloat = 0

  let onDismiss: () -> Void

  var body: some View {
    sheetBody
      .offset(y: dragOffset)
      .frame(
        maxWidth: .infinity,
        alignment: .top
      )
      .accessibilityElement(children: .contain)
      .accessibilityLabel("Profile")
      .accessibilityIdentifier("profile-modal")
      .accessibilityAddTraits(.isModal)
      .onAppear {
        isTitleFocused = true
      }
  }

  private var sheetBody: some View {
    VStack(spacing: 0) {
      grabber
      header
      Divider()

      ScrollView {
        profileContent
          .padding(.horizontal, 14)
          .padding(.top, 8)
          .padding(.bottom, 8)
      }
      .accessibilityIdentifier("profile-content")

      if isVerifiedSignedIn {
        profileLogoutFooter
      }
    }
    .background {
      ZStack {
        // Keep the sheet surface stable without tinting it into a flat grey
        // panel in Dark Mode. The sheet is the one structural surface; its
        // action cards stay crisp content, not extra glass layers.
        ThemeTokens.groupedCanvas
        RadialGradient(
          colors: [
            ThemeTokens.cardSurface.opacity(reduceTransparency ? 0.08 : 0.12),
            ThemeTokens.cardSurface.opacity(0),
          ],
          center: .top,
          startRadius: 0,
          endRadius: 360
        )
      }
    }
  }

  private var grabber: some View {
    ZStack {
      Capsule()
        .fill(Color.secondary.opacity(0.35))
        .frame(width: 36, height: 5)
    }
    .frame(width: 72, height: 20)
    .contentShape(Rectangle())
    .gesture(dismissDragGesture)
    .accessibilityElement()
    .accessibilityLabel("Dismiss Profile")
    .accessibilityHint("Swipe down to close")
    .accessibilityIdentifier("profile-modal-grabber")
    .accessibilityAction {
      onDismiss()
    }
    .padding(.top, 4)
  }

  private var header: some View {
    ZStack {
      Text(profileTitle)
        .themeScaledFont(size: 18, weight: .bold)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("profile-modal-title")
        .accessibilityFocused($isTitleFocused)

      HStack {
        Spacer()

        Button {
          NativeHaptics.play(.dismiss)
          onDismiss()
        } label: {
          Image(systemName: "xmark")
            .font(.system(size: 17, weight: .medium))
            .frame(
              width: ThemeTokens.minimumTap,
              height: ThemeTokens.minimumTap
            )
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .foregroundStyle(ThemeTokens.ink)
        .adaptiveGlass(in: Circle(), interactive: true)
        .accessibilityLabel("Close Profile")
        .accessibilityIdentifier("profile-modal-close")
      }
    }
    .padding(.horizontal, 12)
    .padding(.bottom, 8)
  }

  private var profileContent: some View {
    VStack(alignment: .leading, spacing: 8) {
      accountCard

      ProfileMenuSection(title: "Shopping") {
        ProfileActionRow(
          title: "Buy It Again",
          subtitle: "Reorder from in-store and online purchases",
          symbol: "arrow.triangle.2.circlepath",
          foreground: Color(hex: 0x7040A0),
          background: Color(hex: 0xF3EDFF),
          identifier: "profile-buy-it-again",
          action: appModel.openProfileBuyItAgain
        )

        ProfileActionRow(
          title: "Cart",
          subtitle: "Review your items",
          symbol: "bag",
          foreground: Color(hex: 0xA55D13),
          background: Color(hex: 0xFFF5E6),
          badge: appModel.cart.totalQuantity > 0
            ? "\(min(appModel.cart.totalQuantity, 99))"
            : nil,
          identifier: "profile-cart",
          action: appModel.openProfileCart
        )

        ProfileActionRow(
          title: "Track My Order",
          subtitle: "See dispatch status and tracking details",
          symbol: "shippingbox",
          foreground: Color(hex: 0x6951A3),
          background: Color(hex: 0xF1EDFF),
          identifier: "profile-order-tracking",
          action: appModel.openProfileOrderTracking
        )

        ProfileActionRow(
          title: "Stores",
          subtitle: "Choose your store",
          symbol: "storefront",
          foreground: Color(hex: 0x2B6F86),
          background: Color(hex: 0xEAF6FA),
          identifier: "profile-stores",
          action: appModel.openProfileStores
        )
      }

      ProfileMenuSection(title: "Explore") {
        ProfileActionRow(
          title: "Loves",
          subtitle: "View saved products",
          symbol: "heart",
          foreground: Color(hex: 0xB8325D),
          background: Color(hex: 0xFFF0F3),
          identifier: "profile-loves",
          action: appModel.openProfileLoves
        )

        ProfileActionRow(
          title: "Ingredient Guide",
          subtitle: "Learn what skincare ingredients do",
          symbol: "list.bullet.rectangle.portrait",
          foreground: Color(hex: 0x28785A),
          background: Color(hex: 0xEAF8F2),
          identifier: "profile-ingredient-guide",
          action: appModel.openProfileIngredientGuide
        )

        ProfileActionRow(
          title: "Ask Bestie",
          subtitle: "Chat with our beauty assistant",
          symbol: "bestie.sparkle",
          foreground: Color(hex: 0x7947A2),
          background: Color(hex: 0xF6EFFF),
          identifier: "profile-ask-bestie",
          action: appModel.openProfileBestie
        )
      }

      if isVerifiedSignedIn {
        ProfileMenuSection(title: "Account") {
          ProfileActionRow(
            title: "Delete my account",
            subtitle: "Request permanent account deletion",
            symbol: "trash",
            foreground: Color(hex: 0xA62D63),
            background: Color(hex: 0xFFF0F6),
            identifier: "profile-delete-account",
            action: appModel.openProfileDeleteAccount
          )
        }

      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("profile-content-groups")
  }

  private var profileLogoutFooter: some View {
    Button {
      NativeHaptics.play(.destructive)
      appModel.openProfileLogout()
    } label: {
      Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
        .themeScaledFont(size: 15, weight: .semibold)
        .frame(maxWidth: .infinity)
        // A deliberate final action with a generous full-width tap target,
        // without turning the compact profile sheet into a second screen.
        .frame(height: 60)
    }
    .buttonStyle(.plain)
    .foregroundStyle(Color.white)
    .background(Color.black, in: Capsule())
    .overlay {
      Capsule()
        .stroke(Color.white.opacity(0.18), lineWidth: 0.8)
    }
    .shadow(color: Color.black.opacity(0.18), radius: 5, y: 2)
    .contentShape(Capsule())
    .nativePressResponse(scale: 0.985)
    .padding(.horizontal, 20)
    .padding(.top, 10)
    .padding(.bottom, 12)
    .background {
      VStack(spacing: 0) {
        Divider()
        ThemeTokens.groupedCanvas.opacity(0.96)
      }
    }
    .accessibilityHint("Signs out of your BeautyOnTApp account")
    .accessibilityIdentifier("profile-logout")
  }

  private var accountCard: some View {
    Group {
      if isVerifiedSignedIn {
        identityRow
      } else {
        VStack(spacing: 0) {
          identityRow

          if isVerifiedSignedOut {
            ProfileDivider()
            accountEntry
            ProfileDivider()
          } else if appModel.customerSession == .unknown {
            ProfileDivider()
            accountStatus
            ProfileDivider()
          }
        }
        // The profile sheet already owns the material. Keep this account
        // surface solid so it stays crisp and compact instead of adding a
        // second frosted layer behind the sign-in controls.
        .background(
          ThemeTokens.elevatedSurface,
          in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay {
          RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(ThemeTokens.separator.opacity(0.48), lineWidth: 0.7)
        }
        .shadow(color: Color.black.opacity(0.045), radius: 5, y: 2)
      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("profile-account-entry")
  }

  private var identityRow: some View {
    // Keep the greeting live while the profile sheet remains open. A periodic
    // timeline updates at the minute boundary and also recomputes immediately
    // when the sheet is redrawn after returning from the background.
    TimelineView(.periodic(from: Date(), by: 60)) { context in
      identityRow(at: context.date)
    }
  }

  private func identityRow(at date: Date) -> some View {
    HStack(spacing: 13) {
      ProfileAccountIcon(initials: profileInitials)

      Text(ProfileGreeting.text(for: date, firstName: verifiedFirstName))
        .themeScaledFont(size: 17, weight: .semibold)
        .foregroundStyle(ThemeTokens.ink)
        .lineLimit(1)
        .minimumScaleFactor(0.78)

      Spacer(minLength: 8)
    }
    .padding(.horizontal, isVerifiedSignedIn ? 4 : 14)
    .frame(minHeight: 58)
  }

  private var accountEntry: some View {
    VStack(spacing: 8) {
      Button {
        appModel.openProfileSignIn()
      } label: {
        Text("Sign in or create account")
          .themeScaledFont(size: 14, weight: .semibold)
          .frame(maxWidth: .infinity)
          .frame(height: ThemeTokens.minimumTap)
      }
      .buttonStyle(.plain)
      .foregroundStyle(ThemeTokens.primaryButtonForeground)
      .background(ThemeTokens.primaryButton)
      .clipShape(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
      )
      .accessibilityIdentifier("profile-sign-in")

      Text(
        "New here? Enter your email to create a BeautyOnTApp account."
      )
      .themeScaledFont(size: 12.5)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
  }

  private var accountStatus: some View {
    VStack(spacing: 11) {
      if appModel.isCustomerSessionRefreshing {
        HStack(spacing: 10) {
          ProgressView()
            .controlSize(.small)
            .tint(ThemeTokens.ink)
          Text("Checking your secure account…")
            .themeScaledFont(size: 13, weight: .medium)
            .foregroundStyle(.secondary)
        }
        .frame(minHeight: ThemeTokens.minimumTap)
        .accessibilityIdentifier("profile-account-loading")
      } else {
        Text("Your account status couldn’t be verified.")
          .themeScaledFont(size: 13)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)

        Button {
          NativeHaptics.play(.navigation)
          Task {
            await appModel.refreshCustomerSession()
          }
        } label: {
          Text("Try Again")
            .themeScaledFont(size: 14, weight: .semibold)
            .frame(maxWidth: .infinity)
            .frame(height: ThemeTokens.minimumTap)
        }
        .buttonStyle(.plain)
        .foregroundStyle(ThemeTokens.primaryButtonForeground)
        .background(ThemeTokens.primaryButton)
        .clipShape(
          RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .accessibilityIdentifier("profile-account-retry")

        Button("Open secure sign in") {
          NativeHaptics.play(.navigation)
          appModel.openProfileSignIn()
        }
        .buttonStyle(.plain)
        .themeScaledFont(size: 13, weight: .semibold)
        .foregroundStyle(ThemeTokens.ink)
        .frame(minHeight: ThemeTokens.minimumTap)
        .accessibilityIdentifier("profile-account-secure-sign-in")
      }
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 12)
  }

  private var isVerifiedSignedIn: Bool {
    if case .signedIn = appModel.customerSession {
      return true
    }
    return false
  }

  private var isVerifiedSignedOut: Bool {
    appModel.customerSession == .signedOut
  }

  private var verifiedFirstName: String? {
    if case .signedIn(let firstName) = appModel.customerSession {
      return firstName
    }
    return nil
  }

  private var profileInitials: String? {
    guard isVerifiedSignedIn else { return nil }

    let displayName = appModel.customerDisplayName?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let source = (displayName?.isEmpty == false ? displayName : verifiedFirstName)
      ?? ""
    let parts = source.split(whereSeparator: { $0.isWhitespace })
    guard !parts.isEmpty else { return nil }

    return parts.prefix(2)
      .compactMap(\.first)
      .map(String.init)
      .joined()
      .uppercased()
  }

  private var profileTitle: String {
    let displayName = appModel.customerDisplayName?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    if isVerifiedSignedIn, let displayName, !displayName.isEmpty {
      return displayName
    }
    return "Profile"
  }

  private var dismissDragGesture: some Gesture {
    DragGesture(minimumDistance: 3)
      .updating($dragOffset) { value, state, _ in
        state = max(0, value.translation.height)
      }
      .onEnded { value in
        if value.translation.height > 72 || value.predictedEndTranslation.height > 150 {
          onDismiss()
        }
      }
  }
}

enum ProfileGreeting {
  static func text(
    for date: Date,
    firstName: String?,
    calendar: Calendar = .autoupdatingCurrent
  ) -> String {
    let hour = calendar.component(.hour, from: date)
    let prefix: String
    let signedOut: String

    if hour >= 5 && hour < 12 {
      prefix = "Good Morning☀️"
      signedOut = "Good Morning☀️ Bestie."
    } else if hour >= 12 && hour < 17 {
      prefix = "Good Afternoon☀️"
      signedOut = "Good Afternoon☀️ Bestie."
    } else {
      prefix = "Good Evening🌙"
      signedOut = "Good Evening🌙 Bestie."
    }

    guard let firstName,
      !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      return signedOut
    }
    return "\(prefix) \(firstName)"
  }
}

private struct ProfileActionRow: View {
  @Environment(\.colorScheme) private var colorScheme

  let title: String
  let subtitle: String
  let symbol: String
  let foreground: Color
  let background: Color
  var badge: String?
  let identifier: String
  let action: () -> Void

  init(
    title: String,
    subtitle: String,
    symbol: String,
    foreground: Color,
    background: Color,
    badge: String? = nil,
    identifier: String,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.subtitle = subtitle
    self.symbol = symbol
    self.foreground = foreground
    self.background = background
    self.badge = badge
    self.identifier = identifier
    self.action = action
  }

  var body: some View {
    Button {
      NativeHaptics.play(.navigation)
      action()
    } label: {
      HStack(alignment: .center, spacing: 7) {
        VStack(alignment: .leading, spacing: 3) {
          Text(title)
            .themeScaledFont(size: 13, weight: .semibold)
            .foregroundStyle(ThemeTokens.ink)
            .lineLimit(2)
            .minimumScaleFactor(0.88)

          Text(subtitle)
            .themeScaledFont(size: 10)
            .foregroundStyle(.secondary)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        // Keep the icon, item count, and disclosure close together. The
        // whole card remains the hit target, while the trailing affordance
        // reads as one deliberate destination rather than empty space.
        HStack(spacing: 5) {
          ProfileIcon(
            symbol: symbol,
            foreground: foreground,
            background: background
          )

          if let badge {
            Text(badge)
              .themeScaledFont(size: 10, weight: .bold)
              .foregroundStyle(.white)
              .frame(width: 20, height: 20)
              .background(ThemeTokens.sale, in: Circle())
              .accessibilityLabel("\(badge) items")
          }

          Image(systemName: "chevron.right")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
        }
      }
      .padding(.horizontal, 11)
      .padding(.vertical, 7)
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(minHeight: 58, alignment: .center)
      .contentShape(
        RoundedRectangle(cornerRadius: 18, style: .continuous)
      )
      // The sheet owns the material layer. Tiles are opaque semantic content
      // cards, which keeps the profile menu readable and avoids grey
      // glass-on-glass stacking in Dark Mode.
      .background(
        ThemeTokens.cardSurface,
        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
          .stroke(actionStroke, lineWidth: 0.7)
      }
      .shadow(color: actionShadow, radius: 4, y: 2)
    }
    .buttonStyle(.plain)
    .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    .nativePressResponse(scale: 0.98)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(title), \(subtitle)")
    .accessibilityIdentifier(identifier)
  }

  private var actionStroke: Color {
    colorScheme == .dark
      ? Color.white.opacity(0.08)
      : ThemeTokens.separator.opacity(0.52)
  }

  private var actionShadow: Color {
    colorScheme == .dark
      ? Color.black.opacity(0.10)
      : Color.black.opacity(0.045)
  }
}

private struct ProfileMenuSection<Content: View>: View {
  let title: String
  @ViewBuilder let content: Content

  private let columns = [
    GridItem(.flexible(), spacing: 7),
    GridItem(.flexible(), spacing: 7),
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title.uppercased())
        .themeScaledFont(size: 10.5, weight: .bold)
        .foregroundStyle(ThemeTokens.muted)
        .padding(.horizontal, 4)

      LazyVGrid(columns: columns, spacing: 7) {
        content
      }
    }
  }
}

private struct ProfileIcon: View {
  @Environment(\.colorScheme) private var colorScheme
  let symbol: String
  let foreground: Color
  let background: Color

  var body: some View {
    Group {
      if symbol == "bestie.sparkle" {
        BestieMark(
          foreground: colorScheme == .dark ? Color.white : foreground
        )
      } else {
        Image(systemName: symbol)
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(
            colorScheme == .dark ? Color.white : foreground
          )
      }
    }
      .frame(width: 22, height: 22)
      .background(
        colorScheme == .dark ? foreground.opacity(0.20) : background,
        in: RoundedRectangle(
          cornerRadius: 6,
          style: .continuous
        )
      )
      .accessibilityHidden(true)
  }
}

private struct ProfileAccountIcon: View {
  let initials: String?

  var body: some View {
    ZStack {
      if let initials, !initials.isEmpty {
        Text(initials)
          .themeScaledFont(size: 13, weight: .bold)
          .foregroundStyle(ThemeTokens.ink)
      } else {
        Image(systemName: "person.fill")
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(ThemeTokens.ink)
      }
    }
    .frame(width: 44, height: 44)
    .adaptiveGlass(
      in: Circle(),
      tint: ThemeTokens.gold.opacity(0.14),
      interactive: false,
      variant: .regular
    )
    .overlay {
      Circle()
        .stroke(ThemeTokens.gold.opacity(0.28), lineWidth: 0.8)
    }
    .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
    .accessibilityHidden(true)
  }
}

private struct ProfileDivider: View {
  var body: some View {
    Divider()
      .padding(.leading, 70)
      .accessibilityHidden(true)
  }
}
