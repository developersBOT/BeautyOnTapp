import SwiftUI
import UIKit

struct IngredientGuideView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @AccessibilityFocusState private var isTitleFocused: Bool
  @FocusState private var isSearchFocused: Bool
  @Namespace private var filterLensNamespace
  @State private var interaction = IngredientGuideInteractionState()
  @State private var panelDragOffset: CGFloat = 0

  let guide: IngredientGuideSnapshot
  let onDismiss: () -> Void

  init(
    guide: IngredientGuideSnapshot = .bundled,
    onDismiss: @escaping () -> Void
  ) {
    self.guide = guide
    self.onDismiss = onDismiss
  }

  private var settings: IngredientGuideSettings {
    guide.settings
  }

  private var textColor: Color {
    colorScheme == .dark ? ThemeTokens.ink : (Color(hexString: settings.textColor) ?? ThemeTokens.ink)
  }

  private var mutedColor: Color {
    colorScheme == .dark ? ThemeTokens.muted : (Color(hexString: settings.mutedTextColor) ?? ThemeTokens.muted)
  }

  private var borderColor: Color {
    colorScheme == .dark ? ThemeTokens.separator : (Color(hexString: settings.borderColor) ?? ThemeTokens.separator)
  }

  private var accentColor: Color {
    Color(hexString: settings.accentColor) ?? Color(hex: 0xF5D7DF)
  }

  private var linkColor: Color {
    colorScheme == .dark ? ThemeTokens.link : (Color(hexString: settings.linkColor) ?? ThemeTokens.link)
  }

  private var focusColor: Color {
    colorScheme == .dark ? ThemeTokens.deliveryAccent : (Color(hexString: settings.focusColor) ?? ThemeTokens.deliveryAccent)
  }

  private var visibleIngredients: [IngredientGuideIngredient] {
    guide.matchingIngredients(query: interaction.query)
  }

  var body: some View {
    GeometryReader { proxy in
      let usesCenteredPanel = proxy.size.width >= 768
      let panelWidth = min(
        proxy.size.width - (usesCenteredPanel ? 48 : 0),
        CGFloat(settings.contentWidth)
      )
      let panelHeight = min(
        proxy.size.height * CGFloat(settings.panelHeight) / 100,
        920
      )
      let panelShape = IngredientGuidePanelShape(
        radius: CGFloat(settings.panelRadius),
        roundsAllCorners: usesCenteredPanel
      )

      ZStack(alignment: usesCenteredPanel ? .center : .bottom) {
        backdrop

        panel(bottomSafeArea: proxy.safeAreaInsets.bottom)
          .frame(width: panelWidth, height: panelHeight)
          .offset(y: panelDragOffset)
          // The guide is a navigation-level sheet, so it gets one shared
          // material surface. Keeping the cards and controls opaque inside
          // this surface avoids glass-on-glass smearing while allowing the
          // underlying storefront to remain perceptible on iOS 26/27.
          .adaptiveGlass(
            in: panelShape,
            tint: colorScheme == .dark
              ? Color.white.opacity(0.08)
              : Color.black.opacity(0.025),
            interactive: false,
            variant: .regular
          )
          .clipShape(panelShape)
          .overlay {
            panelShape.stroke(borderColor.opacity(0.55), lineWidth: 0.8)
          }
          .shadow(
            color: Color.black.opacity(0.16),
            radius: 32,
            y: usesCenteredPanel ? 10 : -11
          )
          .gesture(panelDismissGesture)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .ignoresSafeArea()
    .foregroundStyle(textColor)
    .accessibilityElement(children: .contain)
    .accessibilityLabel(settings.heading)
    .accessibilityIdentifier("ingredient-guide")
    .accessibilityAddTraits(.isModal)
    .onAppear {
      isTitleFocused = true
    }
  }

  private var backdrop: some View {
    Button(action: onDismiss) {
      // Keep the backdrop as a simple dimming scrim. The sheet itself owns
      // the single Liquid Glass surface; a second material here would stack
      // glass behind glass and make the guide's text look muddy while it
      // scrolls.
      Color.black.opacity(
        Double(settings.backdropOpacity) / 100
      )
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .ignoresSafeArea()
    .accessibilityLabel(settings.closeLabel)
    .accessibilityIdentifier("ingredient-guide-backdrop")
  }

  private func panel(bottomSafeArea: CGFloat) -> some View {
    VStack(spacing: 0) {
      header

      Divider()
        .overlay(borderColor.opacity(0.42))

      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 0) {
          Text(settings.introText)
            .themeScaledFont(
              size: CGFloat(settings.bodySize),
              relativeTo: .body
            )
            .foregroundStyle(mutedColor)
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 16)

          notice
            .padding(.bottom, 18)

          filterRail
            .padding(.bottom, 14)

          searchField
            .padding(.bottom, 14)

          ingredientList
        }
        .padding(.horizontal, CGFloat(settings.sidePadding))
        .padding(.top, 20)
        .padding(.bottom, 28 + bottomSafeArea)
      }
    }
  }

  private var header: some View {
    VStack(spacing: 8) {
      Capsule()
        .fill(mutedColor.opacity(0.42))
        .frame(width: 36, height: 4)
        .accessibilityHidden(true)

      HStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 2) {
          Text(settings.eyebrow)
            .kerning(1.2)
            .themeScaledFont(
              size: 11,
              weight: .semibold,
              relativeTo: .caption
            )
            .textCase(.uppercase)
            .foregroundStyle(mutedColor)

          Text(settings.heading)
            .kerning(-0.4)
            .themeScaledFont(
              size: CGFloat(settings.headingSize),
              weight: .bold,
              relativeTo: .title2,
              maximumScale: 1.35
            )
            .accessibilityAddTraits(.isHeader)
            .accessibilityFocused($isTitleFocused)
        }

        Spacer(minLength: 0)

        Button {
          NativeHaptics.play(.dismiss)
          onDismiss()
        } label: {
          Image(systemName: "xmark")
            .font(.system(size: 18, weight: .regular))
            .frame(
              width: ThemeTokens.minimumTap,
              height: ThemeTokens.minimumTap
            )
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .background(
          Color(uiColor: .systemGray).opacity(0.08),
          in: Circle()
        )
        .overlay {
          Circle().stroke(borderColor.opacity(0.55), lineWidth: 0.8)
        }
        .accessibilityLabel(settings.closeLabel)
        .accessibilityIdentifier("ingredient-guide-close")
      }
    }
    .frame(minHeight: 78)
    .padding(.horizontal, CGFloat(settings.sidePadding))
    .padding(.top, 8)
  }

  private var panelDismissGesture: some Gesture {
    DragGesture(minimumDistance: 8, coordinateSpace: .local)
      .onChanged { value in
        let downward = max(value.translation.height, 0)
        guard downward > 0 else { return }
        panelDragOffset = downward
      }
      .onEnded { value in
        let predicted = max(value.predictedEndTranslation.height, 0)
        let shouldDismiss = predicted > 140 || panelDragOffset > 110

        if shouldDismiss {
          withAnimation(reduceMotion ? nil : ThemeTokens.navigationSpring) {
            panelDragOffset = 900
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            onDismiss()
          }
        } else {
          withAnimation(reduceMotion ? nil : ThemeTokens.controlSpring) {
            panelDragOffset = 0
          }
        }
      }
  }

  private var notice: some View {
    HStack(alignment: .top, spacing: 11) {
      Image(systemName: "heart.text.clipboard.fill")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(textColor)
        .frame(width: 24, height: 24)
        .background(Color.white.opacity(0.48), in: Circle())
        .accessibilityHidden(true)

      (
        Text(settings.noticeHeading + " ")
          .fontWeight(.bold)
        + Text(settings.noticeText)
      )
      .themeScaledFont(
        size: CGFloat(settings.bodySize - 1),
        relativeTo: .body
      )
      .lineSpacing(3)
      .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 13)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(accentColor.opacity(0.46))
    .clipShape(
      RoundedRectangle(
        cornerRadius: CGFloat(settings.cardRadius - 3),
        style: .continuous
      )
    )
    .overlay {
      RoundedRectangle(
        cornerRadius: CGFloat(settings.cardRadius - 3),
        style: .continuous
      )
      .stroke(accentColor.opacity(0.72), lineWidth: 0.8)
    }
  }

  private var filterRail: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      // The guide is already one navigation-level glass sheet. Filters are
      // content controls inside it, so a semantic selection surface stays
      // crisp instead of stacking another live glass layer over the sheet.
      filterButtons
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel(settings.filterLabel)
  }

  private var filterButtons: some View {
    HStack(spacing: 8) {
      ForEach(guide.filters) { filter in
        filterButton(filter)
      }
    }
    .padding(.horizontal, 1)
    .padding(.vertical, 3)
  }

  @ViewBuilder
  private func filterButton(
    _ filter: IngredientGuideFilter
  ) -> some View {
    let isActive =
      guide.activeFilterID(query: interaction.query) == filter.id
    let button = Button {
      NativeHaptics.play(.selection)
      withAnimation(reduceMotion ? nil : ThemeTokens.controlSpring) {
        interaction.selectFilter(filter, in: guide)
      }
    } label: {
      Text(filter.label)
        .themeScaledFont(
          size: CGFloat(settings.bodySize - 2),
          weight: .semibold,
          relativeTo: .subheadline
        )
        .foregroundStyle(ThemeTokens.ink)
        .lineLimit(1)
        .padding(.horizontal, 13)
        .frame(minHeight: 38)
        .contentShape(Capsule())
        .background { filterSurface(isActive: isActive) }
    }
    .nativePressResponse(scale: 0.97)
    .accessibilityLabel(filter.label)
    .accessibilityIdentifier("ingredient-guide-filter-\(filter.id)")

    if isActive {
      button.accessibilityAddTraits(.isSelected)
    } else {
      button
    }
  }

  @ViewBuilder
  private func filterSurface(isActive: Bool) -> some View {
    if isActive {
      Capsule()
        .fill(
          colorScheme == .dark
            ? Color.white.opacity(0.18)
            : accentColor.opacity(0.26)
        )
        .matchedGeometryEffect(
          id: "ingredient-filter-selection",
          in: filterLensNamespace
        )
        .overlay {
          Capsule().stroke(
            colorScheme == .dark
              ? Color.white.opacity(0.30)
              : accentColor.opacity(0.62),
            lineWidth: 0.8
          )
        }
        .shadow(
          color: colorScheme == .dark
            ? Color.black.opacity(0.16)
            : accentColor.opacity(0.12),
          radius: 4,
          y: 2
        )
    } else {
      Capsule()
        .fill(isActive ? accentColor.opacity(0.18) : ThemeTokens.controlSurface)
        .overlay {
          Capsule().stroke(
            isActive ? accentColor.opacity(0.55) : borderColor.opacity(0.50),
            lineWidth: 0.8
          )
        }
        .shadow(color: Color.black.opacity(0.04), radius: 5, y: 2)
    }
  }

  private var searchField: some View {
    HStack(spacing: 10) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 17, weight: .regular))
        .foregroundStyle(mutedColor)

      TextField(
        settings.searchPlaceholder,
        text: Binding(
          get: { interaction.query },
          set: { interaction.updateQuery($0, in: guide) }
        )
      )
      .focused($isSearchFocused)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
      .submitLabel(.search)
      .themeScaledFont(
        size: CGFloat(max(16, settings.bodySize)),
        relativeTo: .body
      )

      if !interaction.query.isEmpty {
        Button {
          NativeHaptics.play(.selection)
          interaction.updateQuery("", in: guide)
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(mutedColor)
            .frame(width: 32, height: 32)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Clear ingredient search")
      }
    }
    .padding(.horizontal, 15)
    .frame(minHeight: 48)
    .background(
      ThemeTokens.controlSurface,
      in: Capsule()
    )
    .overlay {
      Capsule()
        .stroke(
          isSearchFocused
            ? focusColor
            : borderColor.opacity(0.55),
          lineWidth: isSearchFocused ? 1.5 : 0.8
        )
    }
    .shadow(
      color: isSearchFocused
        ? focusColor.opacity(0.16)
        : Color.black.opacity(0.04),
      radius: isSearchFocused ? 4 : 6
    )
    .accessibilityLabel(settings.searchLabel)
    .accessibilityIdentifier("ingredient-guide-search")
  }

  @ViewBuilder
  private var ingredientList: some View {
    if visibleIngredients.isEmpty {
      Text(settings.noResultsText)
        .themeScaledFont(
          size: CGFloat(settings.bodySize),
          relativeTo: .body
        )
        .foregroundStyle(mutedColor)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(18)
        .accessibilityIdentifier("ingredient-guide-empty")
    } else {
      LazyVStack(spacing: 10) {
        ForEach(visibleIngredients) { ingredient in
          ingredientCard(ingredient)
        }
      }
    }
  }

  private func ingredientCard(
    _ ingredient: IngredientGuideIngredient
  ) -> some View {
    let isExpanded = interaction.expandedIngredientID == ingredient.id
    let ingredientAccent =
      Color(hexString: ingredient.cardAccent) ?? accentColor
    let shape = RoundedRectangle(
      cornerRadius: CGFloat(settings.cardRadius),
      style: .continuous
    )

    return VStack(spacing: 0) {
      Button {
        NativeHaptics.play(.selection)
        withAnimation(reduceMotion ? nil : ThemeTokens.controlSpring) {
          interaction.toggleIngredient(ingredient.id)
        }
      } label: {
        HStack(spacing: 12) {
          VStack(alignment: .leading, spacing: 2) {
            Text(ingredient.title)
              .kerning(-0.2)
              .themeScaledFont(
                size: CGFloat(settings.cardTitleSize),
                weight: .bold,
                relativeTo: .headline
              )
              .foregroundStyle(textColor)
              .frame(maxWidth: .infinity, alignment: .leading)

            if !ingredient.summary.isEmpty {
              Text(ingredient.summary)
                .themeScaledFont(
                  size: CGFloat(settings.bodySize - 2),
                  relativeTo: .subheadline
                )
                .foregroundStyle(mutedColor)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !ingredient.routineLabel.isEmpty {
              Text(ingredient.routineLabel)
                .kerning(0.8)
                .themeScaledFont(
                  size: 10,
                  weight: .bold,
                  relativeTo: .caption2,
                  maximumScale: 1.3
                )
                .textCase(.uppercase)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                  ingredientAccent.opacity(0.45),
                  in: Capsule()
                )
                .overlay {
                  Capsule()
                    .stroke(
                      ingredientAccent.opacity(0.72),
                      lineWidth: 0.8
                    )
                }
                .padding(.top, 3)
            }
          }

          Image(systemName: "chevron.down")
            .font(.system(size: 12, weight: .semibold))
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
            .frame(width: 30, height: 30)
            .background(
              isExpanded
                ? ingredientAccent.opacity(0.34)
                : Color.primary.opacity(0.05),
              in: Circle()
            )
            .foregroundStyle(textColor)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .frame(minHeight: 62)
        .contentShape(Rectangle())
      }
      .nativePressResponse(scale: 0.988)
      .accessibilityLabel(ingredient.title)
      .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
      .accessibilityHint(
        isExpanded ? "Closes ingredient details" : "Opens ingredient details"
      )
      .accessibilityIdentifier("ingredient-card-\(ingredient.id)")

      if isExpanded {
        expandedContent(
          for: ingredient,
          accent: ingredientAccent
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
    .background(
      isExpanded
        ? ingredientAccent.opacity(colorScheme == .dark ? 0.12 : 0.08)
        : ThemeTokens.cardSurface
    )
    .clipShape(shape)
    .overlay(alignment: .leading) {
      Rectangle()
        .fill(ingredientAccent.opacity(0.82))
        .frame(width: 3)
        .accessibilityHidden(true)
    }
    .overlay {
      shape.stroke(borderColor.opacity(0.50), lineWidth: 0.8)
    }
    .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
  }

  private func expandedContent(
    for ingredient: IngredientGuideIngredient,
    accent: Color
  ) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      if !ingredient.body.isEmpty {
        Text(ingredient.body)
          .themeScaledFont(
            size: CGFloat(settings.bodySize),
            relativeTo: .body
          )
          .foregroundStyle(mutedColor)
          .lineSpacing(4)
          .fixedSize(horizontal: false, vertical: true)
      }

      if !ingredient.worksWith.isEmpty
        || !ingredient.cautionWith.isEmpty
        || !ingredient.beginnerTip.isEmpty
      {
        VStack(spacing: 8) {
          if !ingredient.worksWith.isEmpty {
            factBox(
              heading: "Pairs well with",
              text: ingredient.worksWith,
              tint: Color(hex: 0xEAF8F2).opacity(0.62)
            )
          }

          if !ingredient.cautionWith.isEmpty {
            factBox(
              heading: "Use with care",
              text: ingredient.cautionWith,
              tint: Color(hex: 0xFFF7E1).opacity(0.68)
            )
          }

          if !ingredient.beginnerTip.isEmpty {
            factBox(
              heading: "Beginner tip",
              text: ingredient.beginnerTip,
              tint: accent.opacity(0.24)
            )
          }
        }
        .padding(.top, 13)
      }

      sourceLinks(for: ingredient)
    }
    .padding(.horizontal, 15)
    .padding(.bottom, 16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityIdentifier("ingredient-card-body-\(ingredient.id)")
  }

  private func factBox(
    heading: String,
    text: String,
    tint: Color
  ) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(heading)
        .themeScaledFont(
          size: CGFloat(settings.bodySize - 3),
          weight: .bold,
          relativeTo: .subheadline
        )
        .foregroundStyle(textColor)

      Text(text)
        .themeScaledFont(
          size: CGFloat(settings.bodySize - 2),
          relativeTo: .subheadline
        )
        .foregroundStyle(mutedColor)
        .lineSpacing(2)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 11)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(tint)
    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 13, style: .continuous)
        .stroke(borderColor.opacity(0.42), lineWidth: 0.8)
    }
  }

  @ViewBuilder
  private func sourceLinks(
    for ingredient: IngredientGuideIngredient
  ) -> some View {
    if ingredient.pairingSourceURL != nil
      || ingredient.sourceURL != nil
    {
      VStack(alignment: .leading, spacing: 7) {
        if let pairingURL = ingredient.pairingSourceURL,
          !ingredient.pairingSourceLabel.isEmpty
        {
          sourceLink(
            ingredient.pairingSourceLabel,
            destination: pairingURL
          )
        }

        if let sourceURL = ingredient.sourceURL,
          !ingredient.sourceLabel.isEmpty
        {
          sourceLink(
            ingredient.sourceLabel,
            destination: sourceURL
          )
        }
      }
      .padding(.top, 10)
    }
  }

  private func sourceLink(
    _ label: String,
    destination: URL
  ) -> some View {
    Link(destination: destination) {
      HStack(spacing: 6) {
        Text(label)
          .themeScaledFont(
            size: CGFloat(settings.bodySize - 2),
            weight: .semibold,
            relativeTo: .subheadline
          )
          .multilineTextAlignment(.leading)

        Image(systemName: "arrow.up.right")
          .font(.system(size: 10, weight: .bold))
      }
      .foregroundStyle(linkColor)
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape(Rectangle())
    }
  }
}

private struct IngredientGuidePanelShape: Shape {
  let radius: CGFloat
  let roundsAllCorners: Bool

  func path(in rect: CGRect) -> Path {
    Path(
      UIBezierPath(
        roundedRect: rect,
        byRoundingCorners:
          roundsAllCorners
          ? .allCorners
          : [.topLeft, .topRight],
        cornerRadii: CGSize(width: radius, height: radius)
      ).cgPath
    )
  }
}
