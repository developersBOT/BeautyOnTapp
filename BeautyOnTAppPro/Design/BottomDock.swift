import SwiftUI

/// The original six-destination dock. Search remains in the header so the
/// dock stays a single, balanced glass capsule.
struct BottomDock: View {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var colorSchemeContrast
  @AccessibilityFocusState private var focusedDestination: DockDestination?
  @State private var draggedDestination: DockDestination?
  @State private var dockDragLocationX: CGFloat?
  @State private var dockDragStartCenterX: CGFloat?
  @State private var dockDragHasHorizontalIntent = false
  @State private var lastDragFeedbackDestination: DockDestination?
  @Namespace private var dockLensNamespace
  @ObservedObject var appModel: AppModel
  let shopFocusRequest: Int
  let profileFocusRequest: Int

  var body: some View {
    GeometryReader { proxy in
      let dockWidth = max(proxy.size.width - 6, 1)
      ZStack {
        dockButtons(width: dockWidth)
          .padding(.horizontal, 3)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .contentShape(Rectangle())
      // `.interactive()` gives Liquid Glass its optical touch response; it
      // does not turn a tab bar into a drag selector. This high-priority
      // gesture owns horizontal drags across the full dock while the child
      // buttons still handle ordinary taps.
      .highPriorityGesture(
        dockDragGesture(width: dockWidth)
      )
    }
    .frame(height: 63)
    // The selected lens is the only Liquid Glass surface in the dock. Keep
    // the supporting rail transparent: a pale fill behind `Glass.clear`
    // makes the lens read as a grey capsule instead of clear glass.
    .background(
      reduceTransparency ? ThemeTokens.canvas.opacity(0.98) : Color.clear,
      in: Capsule()
    )
    .overlay {
      Capsule()
        .stroke(
          ThemeTokens.separator.opacity(
            colorSchemeContrast == .increased ? 0.72 : 0.42
          ),
          lineWidth: colorSchemeContrast == .increased ? 1.1 : 0.7
        )
    }
    .padding(.horizontal, 8)
    .padding(.top, 3)
    .padding(.bottom, 1)
    .animation(
      reduceMotion ? nil : ThemeTokens.navigationSpring,
      value: appModel.selectedDock
    )
    .onChange(of: shopFocusRequest) { _ in
      DispatchQueue.main.async {
        focusedDestination = .shop
      }
    }
    .onChange(of: profileFocusRequest) { _ in
      DispatchQueue.main.async {
        focusedDestination = .profile
      }
    }
  }

  private func dockButtons(width: CGFloat) -> some View {
    // A single, persistent selection lens does not need a glass container.
    // A zero-spacing container around it and the foreground row caused the
    // material to merge with its neighbours and bloom into a grey capsule.
    dockButtonStack(width: width)
  }

  private func dockButtonStack(width: CGFloat) -> some View {
    ZStack(alignment: .leading) {
      dockRail(width: width)
      dockSelectionLens(width: width)
      dockButtonRow
        // Keep the glyph/label hierarchy above the material. Liquid Glass
        // owns the lens background, not the foreground content; an explicit
        // z-order prevents the optical pass from washing out the selected
        // destination on dark storefront imagery.
        .frame(width: width, height: 63)
        .zIndex(1)
    }
  }

  private var dockButtonRow: some View {
    HStack(spacing: 0) {
      ForEach(DockDestination.allCases) { destination in
        Button {
          appModel.selectDock(destination)
          NativeHaptics.play(.selection)
        } label: {
          dockLabel(destination)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel(for: destination))
        .accessibilityIdentifier("dock-\(destination.id)")
        .accessibilityAddTraits(isSelected(destination) ? .isSelected : [])
        .accessibilityFocused(
          $focusedDestination,
          equals: destination
        )
        .accessibilityHidden(
          appModel.isShopPresented || appModel.isProfilePresented
        )
      }
    }
  }

  private func isSelected(_ destination: DockDestination) -> Bool {
    destination == (draggedDestination ?? appModel.selectedDock)
  }

  /// The rail is the dock's own material layer, matching the system tab bar:
  /// content scrolls beneath a consistent glass capsule and the moving lens
  /// always samples the rail, never raw storefront imagery. Without it the
  /// icons float on product cards and the lens disappears on busy content.
  @ViewBuilder
  private func dockRail(width: CGFloat) -> some View {
    if reduceTransparency {
      // The opaque fallback background is applied by the outer capsule.
      EmptyView()
    } else if #available(iOS 26.0, *) {
      Capsule()
        .fill(Color.clear)
        .frame(width: width + 6, height: 63)
        .glassEffect(
          Glass.regular.tint(ThemeTokens.glassDockTint),
          in: Capsule()
        )
        .offset(x: -3)
    } else {
      Capsule()
        .fill(.ultraThinMaterial)
        .frame(width: width + 6, height: 63)
        .offset(x: -3)
    }
  }

  private func dockDragGesture(width: CGFloat) -> some Gesture {
    DragGesture(minimumDistance: 3, coordinateSpace: .local)
      .onChanged { value in
        guard !appModel.isShopPresented, !appModel.isProfilePresented else {
          return
        }

        // A vertical scroll or a short tap must not steal the interaction from
        // the dock buttons. Once the finger has a horizontal intent, keep the
        // lens under the finger for the rest of the gesture.
        if !dockDragHasHorizontalIntent {
          guard abs(value.translation.width) > abs(value.translation.height)
            else { return }
          dockDragHasHorizontalIntent = true
          let destinations = DockDestination.allCases
          let itemWidth = width / CGFloat(destinations.count)
          let selectedIndex = destinations.firstIndex(
            of: appModel.selectedDock
          ) ?? 0
          dockDragStartCenterX = (CGFloat(selectedIndex) + 0.5) * itemWidth
          lastDragFeedbackDestination = appModel.selectedDock
        }

        // Preserve the lens' presentation position when the drag begins.
        // Using the absolute finger location made the old lens jump as soon
        // as the gesture threshold was crossed. Translation gives true 1:1
        // tracking from the currently selected destination.
        let startCenter = dockDragStartCenterX ?? value.startLocation.x
        let trackedCenter = min(
          max(startCenter + value.translation.width, 0),
          width
        )
        dockDragLocationX = trackedCenter

        let destination = destination(
          at: trackedCenter,
          width: width
        )
        guard draggedDestination != destination else { return }

        // The foreground state follows the lens without a second animation;
        // otherwise the icon swap visibly lags behind the material.
        draggedDestination = destination

        if destination != lastDragFeedbackDestination {
          NativeHaptics.play(.selection)
          lastDragFeedbackDestination = destination
        }
      }
      .onEnded { value in
        let destination: DockDestination?
        if dockDragHasHorizontalIntent {
          let itemWidth = width / CGFloat(DockDestination.allCases.count)
          let trackedCenter = dockDragLocationX
            ?? ((dockDragStartCenterX ?? value.startLocation.x)
              + value.translation.width)
          let projectedRemainder = value.predictedEndTranslation.width
            - value.translation.width
          // Preserve Apple's velocity handoff without allowing a quick one-tab
          // drag to fling past the destination the finger actually reached.
          // The lens may carry at most roughly one third of a tab after lift.
          let cappedProjection = min(
            max(projectedRemainder, -itemWidth * 0.34),
            itemWidth * 0.34
          )
          let projectedCenter = min(
            max(trackedCenter + cappedProjection, 0),
            width
          )
          destination = self.destination(at: projectedCenter, width: width)
            ?? draggedDestination
        } else {
          destination = nil
        }

        if let destination {
          appModel.selectDock(destination)
        }

        withAnimation(
          reduceMotion ? nil : ThemeTokens.gestureMomentumSpring
        ) {
          dockDragLocationX = nil
          draggedDestination = nil
        }
        dockDragStartCenterX = nil
        dockDragHasHorizontalIntent = false
        lastDragFeedbackDestination = nil
      }
  }

  private func destination(
    at x: CGFloat,
    width: CGFloat
  ) -> DockDestination? {
    let destinations = DockDestination.allCases
    guard !destinations.isEmpty, width > 0 else { return nil }

    let itemWidth = width / CGFloat(destinations.count)
    let clampedX = min(max(x, 0), max(width - 0.001, 0))
    let index = min(
      Int(clampedX / itemWidth),
      destinations.count - 1
    )
    return destinations[index]
  }

  private func dockLabel(_ destination: DockDestination) -> some View {
    VStack(spacing: 1) {
      ZStack(alignment: .topTrailing) {
        DockIcon(
          destination: destination,
          isSelected: isSelected(destination)
        )
        .frame(
          width: largeArtwork(destination) ? 24 : 21,
          height: largeArtwork(destination) ? 24 : 21
        )
        .frame(height: 25)

        if destination == .profile, appModel.cart.totalQuantity > 0 {
          Text("\(min(appModel.cart.totalQuantity, 99))")
            .themeScaledFont(
              size: 8.5,
              weight: .bold,
              maximumScale: 1.2
            )
            .foregroundStyle(.white)
            .frame(minWidth: 16, minHeight: 16)
            .background(Color(hex: 0xD10A2C), in: Circle())
            .overlay {
              Circle()
                .stroke(Color.white.opacity(0.90), lineWidth: 1)
            }
            .offset(x: 8, y: -5)
            .accessibilityHidden(true)
        }
      }
      .frame(width: 24, height: 25)

      Text(destination == .profile ? profileDockLabel : destination.label)
        .themeScaledFont(
          size: 9.5,
          weight: .semibold,
          maximumScale: 1.3
        )
        .lineLimit(1)
        .minimumScaleFactor(0.74)
    }
    .foregroundStyle(ThemeTokens.ink)
    .frame(maxWidth: .infinity)
    .frame(height: 62)
    .contentShape(Rectangle())
  }

  @ViewBuilder
  private func dockSelectionLens(width: CGFloat) -> some View {
    let itemWidth = width / CGFloat(DockDestination.allCases.count)
    // The selection lens spans its complete destination cell. It keeps the
    // dock's six destinations aligned and lets the glass read as one moving
    // system lens instead of a shrunken button behind the icon.
    // Let the lens reach the optical edge of the selected destination instead
    // of stopping at the inset button cell. This restores the full-width
    // system-tab footprint while retaining a small separation from neighbours.
    let lensWidth = max(itemWidth + 12, 72)
    // Keep the lens at the full selected-tab height. Reducing it made the
    // selection look like a smaller button instead of the dock's moving
    // glass lens.
    let lensHeight: CGFloat = 61
    let selectedIndex = DockDestination.allCases.firstIndex(
      of: draggedDestination ?? appModel.selectedDock
    ) ?? 0
    let selectedCenter = (CGFloat(selectedIndex) + 0.5) * itemWidth
    let center = min(
      max(dockDragLocationX ?? selectedCenter, lensWidth / 2),
      max(width - lensWidth / 2, lensWidth / 2)
    )

    Group {
      if reduceTransparency {
        Capsule()
          .fill(ThemeTokens.controlSurface)
          .overlay {
            Capsule()
              .stroke(ThemeTokens.separator.opacity(0.34), lineWidth: 0.6)
          }
          .frame(width: lensWidth, height: lensHeight)
      } else if #available(iOS 26.0, *) {
        // The selected surface stays clear like the system lens. The visible
        // perimeter supplies the definition; a tinted regular material made
        // the lens read as a grey button on storefront content. Clear glass
        // needs an adaptive edge to remain legible on either appearance.
        let lensEdge = colorScheme == .dark
          ? Color.white.opacity(0.18)
          : Color.black.opacity(0.10)
        Capsule()
          .fill(Color.clear)
          // Resolve the lens size before Liquid Glass samples the backing
          // content. Applying the material to a later-resized shape makes it
          // read as a frosted grey fill rather than a clear moving lens.
          .frame(width: lensWidth, height: lensHeight)
          .glassEffect(
            // The dock buttons own touch feedback. Keeping the moving lens
            // non-interactive prevents the material from brightening into a
            // frosted white button while it travels beneath those controls.
            Glass.clear,
            in: Capsule()
          )
          .glassEffectID("dock-selection-lens", in: dockLensNamespace)
          .overlay {
            Capsule()
              .stroke(lensEdge, lineWidth: 0.8)

            if colorSchemeContrast == .increased {
              Capsule()
                .stroke(Color.primary.opacity(0.52), lineWidth: 1.1)
            }
          }
      } else {
        Capsule()
          .fill(.ultraThinMaterial)
          .overlay {
            Capsule()
              .stroke(ThemeTokens.separator.opacity(0.30), lineWidth: 0.6)
          }
          .frame(width: lensWidth, height: lensHeight)
      }
    }
    .offset(x: center - lensWidth / 2)
  }

  private func largeArtwork(_ destination: DockDestination) -> Bool {
    destination == .shop || destination == .bestie
  }

  private func accessibilityLabel(
    for destination: DockDestination
  ) -> String {
    let label = destination == .profile ? profileDockLabel : destination.label
    guard destination == .profile, appModel.cart.totalQuantity > 0 else {
      return label
    }

    let count = appModel.cart.totalQuantity
    let noun = count == 1 ? "item" : "items"
    return "\(label), \(count) \(noun) in cart"
  }

  private var profileDockLabel: String {
    let name = appModel.customerDisplayName?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard let name, !name.isEmpty else {
      return DockDestination.profile.label
    }
    return name
  }

}

private struct DockIcon: View {
  let destination: DockDestination
  let isSelected: Bool

  var body: some View {
    Group {
      switch destination {
      case .home:
        systemIcon(isSelected ? "house.fill" : "house")
      case .shop:
        systemIcon(isSelected ? "bag.fill" : "bag")
      case .exclusive:
        remoteThemeIcon(
          "beautyontapp-exclusive-icon-transparent-hires.png",
          fallback: "sparkles"
        )
      case .profile:
        systemIcon(isSelected ? "person.fill" : "person")
      case .stores:
        systemIcon(isSelected ? "storefront.fill" : "storefront")
      case .bestie:
        BestieMark(foreground: ThemeTokens.ink)
      }
    }
    .foregroundStyle(ThemeTokens.ink)
    .accessibilityHidden(true)
  }

  private func systemIcon(_ name: String) -> some View {
    Image(systemName: name)
      .font(.system(size: 21, weight: .medium))
      .symbolRenderingMode(.monochrome)
  }

  private func remoteThemeIcon(
    _ filename: String,
    fallback: String
  ) -> some View {
    let encodedFilename =
      filename.addingPercentEncoding(
        withAllowedCharacters: .urlPathAllowed
      ) ?? filename
    let url = URL(
      string: "https://beautyontapp.com/cdn/shop/files/\(encodedFilename)?format=png&width=96"
    )

    return PipelineRemoteImage(
      request: NativeImageRequest(
        sourceURL: url,
        pixelWidth: 96
      ),
      accessibilityLabel: nil
    ) { image in
      image
        .resizable()
        .renderingMode(.template)
        .scaledToFit()
        .foregroundStyle(ThemeTokens.ink)
    } placeholder: {
      Image(systemName: fallback)
        .resizable()
        .scaledToFit()
        .foregroundStyle(ThemeTokens.ink)
    }
  }
}
