import SwiftUI

struct ShopSheetView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @AccessibilityFocusState private var accessibilityFocus: AccessibilityFocus?
  @GestureState private var dragOffset: CGFloat = 0
  @State private var accordionState = ShopSheetAccordionState()

  let menu: StoreMenu?
  let isLoading: Bool
  let initialFocus: ShopSheetFocusRequest?
  let onRetry: () -> Void
  let onSelect: (StoreMenuItem) -> Void
  let onDismiss: () -> Void
  @State private var didApplyInitialFocus = false

  init(
    menu: StoreMenu?,
    isLoading: Bool,
    initialFocus: ShopSheetFocusRequest? = nil,
    onRetry: @escaping () -> Void = {},
    onSelect: @escaping (StoreMenuItem) -> Void,
    onDismiss: @escaping () -> Void
  ) {
    self.menu = menu
    self.isLoading = isLoading
    self.initialFocus = initialFocus
    self.onRetry = onRetry
    self.onSelect = onSelect
    self.onDismiss = onDismiss
  }

  private let columns = [
    GridItem(.flexible(), spacing: 10),
    GridItem(.flexible(), spacing: 10),
  ]

  private var rootItems: [StoreMenuItem] {
    visibleItems(menu?.items ?? [])
  }

  private var selectedRoot: StoreMenuItem? {
    guard let selectedRootID = accordionState.selectedRootID else {
      return nil
    }
    return rootItems.first(where: { $0.id == selectedRootID })
  }

  private let featuredItems: [StoreMenuItem] = [
    StoreMenuItem(
      id: "featured-trending-on-social",
      title: "Trending on Social",
      url: URL(string: "https://beautyontapp.com/collections/skincare"),
      resourceID: nil,
      items: []
    ),
    StoreMenuItem(
      id: "featured-only-at-beautyontapp",
      title: "Only at BeautyOnTApp",
      url: URL(
        string: "https://beautyontapp.com/collections/only-at-beautyontapp"
      ),
      resourceID: nil,
      items: []
    ),
    StoreMenuItem(
      id: "featured-bestsellers",
      title: "Bestsellers",
      url: URL(string: "https://beautyontapp.com/collections/skincare"),
      resourceID: nil,
      items: []
    ),
    StoreMenuItem(
      id: "featured-hyperpigmentation",
      title: "Hyperpigmentation",
      url: URL(
        string: "https://beautyontapp.com/collections/hyperpigmentation"
      ),
      resourceID: nil,
      items: []
    ),
    StoreMenuItem(
      id: "featured-local-owned-brands",
      title: "Local-Owned Brands",
      url: URL(
        string: "https://beautyontapp.com/collections/only-at-beautyontapp"
      ),
      resourceID: nil,
      items: []
    ),
    StoreMenuItem(
      id: "featured-luxury-skincare",
      title: "Luxury Skincare",
      url: URL(string: "https://beautyontapp.com/collections/dermalogica"),
      resourceID: nil,
      items: []
    ),
    StoreMenuItem(
      id: "featured-k-beauty",
      title: "K-Beauty",
      url: URL(
        string: "https://beautyontapp.com/collections/korean-skincare"
      ),
      resourceID: nil,
      items: []
    ),
  ]

  var body: some View {
    VStack(spacing: 0) {
      dragIndicator
      header
      Divider()
      menuContent
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(sheetBackground)
    .clipShape(
      RoundedRectangle(cornerRadius: 28, style: .continuous)
    )
    .overlay {
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.60), lineWidth: 0.8)
    }
    .shadow(color: Color.black.opacity(0.18), radius: 24, y: 10)
    .offset(y: dragOffset)
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Shop menu")
    .accessibilityIdentifier("shop-modal")
    .accessibilityAddTraits(.isModal)
    .onAppear {
      applyInitialFocusIfAvailable()
      if accordionState.selectedRootID == nil {
        accessibilityFocus = .title
      }
    }
    .onChange(of: accordionState.selectedRootID) { selectedRootID in
      accessibilityFocus = selectedRootID == nil ? .title : .panel
    }
    .onChange(of: rootItems.map(\.id)) { rootIDs in
      accordionState.reconcile(availableRootIDs: Set(rootIDs))
      applyInitialFocusIfAvailable()
    }
    .onChange(of: initialFocus) { _ in
      didApplyInitialFocus = false
      applyInitialFocusIfAvailable()
    }
  }

  private var dragIndicator: some View {
    Capsule()
      .fill(Color.secondary.opacity(0.34))
      .frame(width: 36, height: 5)
      .frame(width: 88, height: ThemeTokens.minimumTap)
      .contentShape(Rectangle())
      .gesture(dismissDragGesture)
      .accessibilityElement()
      .accessibilityLabel("Dismiss Shop menu")
      .accessibilityHint("Swipe down to close")
      .accessibilityIdentifier("shop-modal-grabber")
      .accessibilityAction {
        onDismiss()
      }
  }

  private var header: some View {
    ZStack {
      Text("Shop")
        .themeScaledFont(size: 18, weight: .bold)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("shop-modal-title")
        .accessibilityFocused($accessibilityFocus, equals: .title)

      HStack {
        Spacer()

        Button {
          NativeHaptics.play(.dismiss)
          onDismiss()
        } label: {
          Image(systemName: "xmark")
            .font(.system(size: 17, weight: .medium))
            .frame(
              width: ThemeTokens.minimumTap + 2,
              height: ThemeTokens.minimumTap + 2
            )
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .foregroundStyle(ThemeTokens.ink)
        .adaptiveGlass(in: Circle(), interactive: true)
        .accessibilityLabel("Close Shop menu")
        .accessibilityIdentifier("shop-modal-close")
      }
    }
    .frame(minHeight: 56)
    .padding(.horizontal, 16)
    .padding(.bottom, 4)
  }

  private var menuContent: some View {
    GeometryReader { proxy in
      ZStack(alignment: .top) {
        rootContent
          .accessibilityHidden(selectedRoot != nil)
          .allowsHitTesting(selectedRoot == nil)

        if let selectedRoot {
          Button {
            NativeHaptics.play(.dismiss)
            closeFloatingPanel()
          } label: {
            Color.black.opacity(0.07)
              .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .accessibilityLabel(
            "Close \(displayTitle(selectedRoot.title)) submenu"
          )
          .accessibilityIdentifier("shop-submenu-dismiss")
          .transition(.opacity)

          floatingPanel(for: selectedRoot)
            .frame(
              maxWidth: 480,
              maxHeight: max(260, proxy.size.height - 126)
            )
            .padding(
              .horizontal,
              max(20, min(58, proxy.size.width * 0.14))
            )
            .padding(.top, min(108, proxy.size.height * 0.18))
            .transition(
              reduceMotion
                ? .opacity
                : .scale(scale: 0.97, anchor: .top)
                  .combined(with: .opacity)
            )
            .zIndex(1)
        }
      }
      .animation(
        reduceMotion
          ? nil
          : .spring(response: 0.32, dampingFraction: 0.88),
        value: accordionState.selectedRootID
      )
    }
  }

  @ViewBuilder
  private var rootContent: some View {
    if !rootItems.isEmpty {
      ScrollView(showsIndicators: false) {
        LazyVGrid(columns: columns, spacing: 10) {
          ForEach(rootItems) { item in
            rootTile(item)
          }
        }

        VStack(alignment: .leading, spacing: 10) {
          Text("Featured")
            .themeScaledFont(size: 16, weight: .bold)
            .foregroundStyle(ThemeTokens.muted)
            .padding(.horizontal, 4)
            .accessibilityAddTraits(.isHeader)

          LazyVGrid(columns: columns, spacing: 10) {
            ForEach(featuredItems) { item in
              featuredTile(item)
            }
          }
        }
        .padding(.top, 20)

        Color.clear.frame(height: 90)
      }
      .accessibilityIdentifier("shop-root-menu")
      .padding(.horizontal, 16)
      .padding(.top, 16)
    } else if isLoading {
      VStack(spacing: 12) {
        ProgressView()
          .controlSize(.large)

        Text("Loading Shop")
          .themeScaledFont(size: 15, weight: .semibold)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .accessibilityElement(children: .combine)
      .accessibilityLabel("Loading Shop menu")
      .accessibilityIdentifier("shop-menu-loading")
    } else {
      unavailableContent
    }
  }

  private var unavailableContent: some View {
    VStack(spacing: 12) {
      Image(systemName: "wifi.exclamationmark")
        .font(.system(size: 28, weight: .semibold))
        .foregroundStyle(.secondary)

      Text("Shop menu unavailable")
        .themeScaledFont(size: 16, weight: .bold)

      Text("Reconnect and try again.")
        .themeScaledFont(size: 13)
        .foregroundStyle(.secondary)

      Button {
        NativeHaptics.play(.navigation)
        onRetry()
      } label: {
        Text("Try Again")
          .themeScaledFont(size: 14, weight: .semibold)
          .frame(minWidth: 120)
          .frame(height: ThemeTokens.minimumTap)
      }
      .buttonStyle(.plain)
      .foregroundStyle(ThemeTokens.primaryButtonForeground)
      .background(ThemeTokens.primaryButton)
      .clipShape(Capsule())
      .accessibilityIdentifier("shop-menu-retry")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(24)
  }

  private func rootTile(_ item: StoreMenuItem) -> some View {
    Button {
      if visibleItems(item.items).isEmpty {
        NativeHaptics.play(.navigation)
        onSelect(item)
      } else {
        NativeHaptics.play(.selection)
        accordionState.selectRoot(item.id)
      }
    } label: {
      HStack(spacing: 8) {
        Text(displayTitle(item.title))
          .themeScaledFont(size: 15, weight: .semibold)
          .foregroundStyle(ThemeTokens.ink)
          .multilineTextAlignment(.leading)
          .lineLimit(2)

        Spacer(minLength: 4)

        Image(systemName: shopSymbol(for: item.title))
          .font(.system(size: 20, weight: .regular))
          .symbolRenderingMode(.monochrome)
          .foregroundStyle(shopTint(for: item.title))
          .frame(width: 30, height: 30)
          .accessibilityHidden(true)

        if !visibleItems(item.items).isEmpty {
          Image(systemName: "chevron.right")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
        }
      }
      .padding(.horizontal, 14)
      .frame(maxWidth: .infinity)
      .frame(minHeight: 66)
      .contentShape(Rectangle())
      .adaptiveGlass(
        in: RoundedRectangle(cornerRadius: 20, style: .continuous),
        tint: ThemeTokens.glassControlTint,
        interactive: true
      )
      .overlay {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .stroke(ThemeTokens.separator.opacity(0.60), lineWidth: 0.8)
      }
      .shadow(color: Color.black.opacity(0.06), radius: 9, y: 4)
    }
    .buttonStyle(.plain)
    .accessibilityHint(
      visibleItems(item.items).isEmpty
        ? "Opens \(displayTitle(item.title))"
        : "Opens an accordion menu over the Shop categories"
    )
    .accessibilityIdentifier(
      "shop-item-\(identifierSlug(displayTitle(item.title)))"
    )
  }

  private func featuredTile(_ item: StoreMenuItem) -> some View {
    Button {
      NativeHaptics.play(.navigation)
      onSelect(item)
    } label: {
      HStack(spacing: 8) {
        Text(item.title)
          .themeScaledFont(size: 13.5, weight: .semibold)
          .foregroundStyle(ThemeTokens.ink)
          .multilineTextAlignment(.leading)
          .lineLimit(2)

        Spacer(minLength: 4)

        Image(systemName: "chevron.right")
          .font(.system(size: 11, weight: .semibold))
          .foregroundStyle(.secondary)
          .accessibilityHidden(true)
      }
      .padding(.horizontal, 14)
      .frame(maxWidth: .infinity)
      .frame(minHeight: 52)
      .contentShape(Rectangle())
      .adaptiveGlass(
        in: RoundedRectangle(cornerRadius: 18, style: .continuous),
        tint: ThemeTokens.glassControlTint,
        interactive: true
      )
      .overlay {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
          .stroke(ThemeTokens.separator.opacity(0.60), lineWidth: 0.8)
      }
      .shadow(color: Color.black.opacity(0.045), radius: 7, y: 3)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(item.title)
    .accessibilityHint("Opens \(item.title)")
    .accessibilityIdentifier(
      "shop-featured-\(identifierSlug(item.title))"
    )
  }

  private func floatingPanel(for root: StoreMenuItem) -> some View {
    ScrollView(showsIndicators: true) {
      LazyVStack(spacing: 0) {
        ForEach(visibleItems(root.items)) { item in
          ShopAccordionBranch(
            item: item,
            depth: 0,
            expandedItemIDs: $accordionState.expandedItemIDs,
            reduceMotion: reduceMotion,
            onSelect: onSelect
          )
        }
      }
    }
    .background {
      if reduceTransparency {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
          .fill(Color(uiColor: .systemBackground))
      } else {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
          .fill(.ultraThinMaterial)
      }
    }
    .overlay {
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.60), lineWidth: 0.9)
    }
    .clipShape(
      RoundedRectangle(cornerRadius: 22, style: .continuous)
    )
    .shadow(color: Color.black.opacity(0.16), radius: 24, y: 10)
    .accessibilityElement(children: .contain)
    .accessibilityLabel("\(displayTitle(root.title)) menu")
    .accessibilityIdentifier(
      "shop-panel-\(identifierSlug(displayTitle(root.title)))"
    )
    .accessibilityFocused($accessibilityFocus, equals: .panel)
  }

  private var dismissDragGesture: some Gesture {
    DragGesture(minimumDistance: 3)
      .updating($dragOffset) { value, state, _ in
        state = max(0, value.translation.height)
      }
      .onEnded { value in
        let shouldDismiss =
          value.translation.height > 72
          || value.predictedEndTranslation.height > 140
        if shouldDismiss {
          NativeHaptics.play(.dismiss)
          onDismiss()
        }
      }
  }

  private var sheetBackground: some View {
    ZStack {
      if reduceTransparency {
        Color(uiColor: .systemGroupedBackground)
      } else {
        Rectangle().fill(.ultraThinMaterial)
        ThemeTokens.groupedCanvas.opacity(0.70)
      }

      RadialGradient(
        colors: [
          ThemeTokens.cardSurface.opacity(reduceTransparency ? 0 : 0.34),
          ThemeTokens.cardSurface.opacity(0),
        ],
        center: .top,
        startRadius: 0,
        endRadius: 330
      )
    }
  }

  private func closeFloatingPanel() {
    accordionState.dismissPanel()
  }

  private func applyInitialFocusIfAvailable() {
    guard !didApplyInitialFocus, let initialFocus else {
      return
    }
    guard accordionState.focusRoot(initialFocus, in: rootItems) else {
      return
    }
    didApplyInitialFocus = true
    accessibilityFocus = .panel
  }

  private func visibleItems(_ items: [StoreMenuItem]) -> [StoreMenuItem] {
    items.filter {
      !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
  }

  private func displayTitle(_ title: String) -> String {
    title.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func identifierSlug(_ title: String) -> String {
    title
      .lowercased()
      .replacingOccurrences(
        of: "[^a-z0-9]+",
        with: "-",
        options: .regularExpression
      )
      .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
  }

  private func shopSymbol(for title: String) -> String {
    let normalized =
      title
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()

    if normalized.contains("brand") {
      return "textformat.abc"
    }
    if normalized.contains("korean") {
      return "sparkles"
    }
    if normalized.contains("mini") {
      return "shippingbox"
    }
    if normalized.contains("sun") {
      return "sun.max"
    }
    if normalized.contains("bath") || normalized.contains("body") {
      return "drop"
    }
    if normalized.contains("hair") {
      return "scissors"
    }
    if normalized.contains("make") {
      return "paintbrush"
    }
    if normalized == "men" || normalized.contains("men's") {
      return "person"
    }
    if normalized.contains("fragrance") {
      return "leaf"
    }
    if normalized.contains("under") {
      return "tag"
    }
    if normalized.contains("bundle") {
      return "shippingbox.fill"
    }
    if normalized.contains("book") || normalized.contains("analysis") {
      return "camera.viewfinder"
    }
    return "drop"
  }

  private func shopTint(for title: String) -> Color {
    let normalized = title.lowercased()
    if normalized.contains("sun") || normalized.contains("bath") {
      return ThemeTokens.gold
    }
    if normalized.contains("korean") || normalized.contains("make") {
      return Color(hex: 0xC76A86)
    }
    if normalized.contains("skin") || normalized.contains("fragrance") {
      return Color(hex: 0x4C9A83)
    }
    return Color(hex: 0x5B718B)
  }
}

struct ShopSheetAccordionState: Equatable {
  fileprivate(set) var selectedRootID: String?
  var expandedItemIDs: Set<String> = []

  mutating func selectRoot(_ rootID: String) {
    selectedRootID = rootID
    expandedItemIDs.removeAll()
  }

  mutating func dismissPanel() {
    selectedRootID = nil
    expandedItemIDs.removeAll()
  }

  mutating func reconcile(availableRootIDs: Set<String>) {
    guard let selectedRootID else { return }
    guard !availableRootIDs.contains(selectedRootID) else { return }
    dismissPanel()
  }

  @discardableResult
  mutating func focusRoot(
    _ request: ShopSheetFocusRequest,
    in roots: [StoreMenuItem]
  ) -> Bool {
    let requestedTitle = request.rootTitle.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    let requestedPath = normalizedPath(request.destinationPath)
    guard
      let root = roots.first(where: {
        $0.title.trimmingCharacters(in: .whitespacesAndNewlines)
          .caseInsensitiveCompare(requestedTitle) == .orderedSame
          || normalizedPath($0.url?.path) == requestedPath
      })
    else {
      return false
    }
    selectRoot(root.id)
    return true
  }

  private func normalizedPath(_ path: String?) -> String? {
    guard
      var path = path?
        .trimmingCharacters(in: .whitespacesAndNewlines),
      !path.isEmpty
    else {
      return nil
    }
    if !path.hasPrefix("/") {
      path = "/" + path
    }
    while path.count > 1, path.hasSuffix("/") {
      path.removeLast()
    }
    return path.lowercased()
  }
}

private struct ShopAccordionBranch: View {
  let item: StoreMenuItem
  let depth: Int
  @Binding var expandedItemIDs: Set<String>
  let reduceMotion: Bool
  let onSelect: (StoreMenuItem) -> Void

  private var children: [StoreMenuItem] {
    item.items.filter {
      !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
  }

  private var isExpanded: Bool {
    expandedItemIDs.contains(item.id)
  }

  var body: some View {
    VStack(spacing: 0) {
      Button(action: activate) {
        HStack(spacing: 10) {
          Text(
            item.title.trimmingCharacters(in: .whitespacesAndNewlines)
          )
          .themeScaledFont(
            size: depth == 0 ? 15 : 14,
            weight: depth == 0 ? .semibold : .medium
          )
          .foregroundStyle(ThemeTokens.ink)
          .multilineTextAlignment(.leading)

          Spacer(minLength: 8)

          Image(
            systemName: children.isEmpty
              ? "chevron.right"
              : "chevron.down"
          )
          .font(.system(size: 12, weight: .semibold))
          .foregroundStyle(.secondary)
          .rotationEffect(
            children.isEmpty || isExpanded
              ? .zero
              : .degrees(-90)
          )
        }
        .padding(.leading, 16 + CGFloat(depth) * 14)
        .padding(.trailing, 16)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 54)
        .contentShape(Rectangle())
        .background(
          isExpanded
            ? Color.primary.opacity(0.055)
            : Color.clear
        )
      }
      .buttonStyle(.plain)
      .accessibilityValue(
        children.isEmpty
          ? ""
          : (isExpanded ? "Expanded" : "Collapsed")
      )
      .accessibilityHint(
        children.isEmpty
          ? "Opens \(item.title)"
          : (isExpanded ? "Collapses submenu" : "Expands submenu")
      )
      .accessibilityIdentifier(
        "shop-menu-item-\(identifierSlug(item.title))"
      )

      if isExpanded {
        ForEach(children) { child in
          Divider()
            .padding(.leading, 16 + CGFloat(depth + 1) * 14)

          ShopAccordionBranch(
            item: child,
            depth: depth + 1,
            expandedItemIDs: $expandedItemIDs,
            reduceMotion: reduceMotion,
            onSelect: onSelect
          )
        }
        .transition(.opacity)
      }

      Divider()
        .padding(.leading, 16 + CGFloat(depth) * 14)
    }
  }

  private func activate() {
    guard !children.isEmpty else {
      NativeHaptics.play(.navigation)
      onSelect(item)
      return
    }

    NativeHaptics.play(.selection)

    let update = {
      if expandedItemIDs.contains(item.id) {
        expandedItemIDs.remove(item.id)
      } else {
        expandedItemIDs.insert(item.id)
      }
    }

    if reduceMotion {
      update()
    } else {
      withAnimation(.spring(response: 0.30, dampingFraction: 0.88)) {
        update()
      }
    }
  }

  private func identifierSlug(_ title: String) -> String {
    title
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()
      .replacingOccurrences(
        of: "[^a-z0-9]+",
        with: "-",
        options: .regularExpression
      )
      .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
  }
}

private enum AccessibilityFocus: Hashable {
  case title
  case panel
}
