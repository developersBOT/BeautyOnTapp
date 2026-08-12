import SwiftUI

enum CartViewMode {
  case drawer
  case full
}

struct CartView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var appModel: AppModel

  let mode: CartViewMode

  @State private var childSheet: CartChildSheet?

  var body: some View {
    Group {
      if mode == .drawer {
        drawer
      } else {
        fullCart
      }
    }
    .background(ThemeTokens.canvas)
    .task {
      await appModel.retryPendingCartWhenAvailable()
    }
    .sheet(item: $childSheet) { sheet in
      switch sheet {
      case .delivery:
        DeliveryEstimatorSheet(onCheckout: {
          childSheet = nil
          checkout()
        })
          .environmentObject(appModel)
      }
    }
    .nativeSheetStyle(.large)
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(
      mode == .drawer ? "cart-drawer" : "cart-full"
    )
  }

  private var drawer: some View {
    VStack(spacing: 0) {
      cartDrawerHeader

      Divider()

      cartStateContent

      if !appModel.cart.lines.isEmpty {
        drawerSummary
      }
    }
    .background(.ultraThinMaterial)
    .nativeSheetStyle(.large)
  }

  private var fullCart: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 0) {
        StoreHeader(
          appModel: appModel,
          presentation: .complete
        )

        Text("Cart")
          .themeScaledFont(size: 27, weight: .bold)
          .padding(.horizontal, ThemeTokens.horizontalPadding)
          .padding(.top, 26)
          .padding(.bottom, 16)

        if appModel.hasPendingCartRestore {
          restoringCart
            .frame(minHeight: 360)
        } else if appModel.cart.lines.isEmpty {
          emptyCart
            .frame(minHeight: 360)
        } else {
          LazyVStack(spacing: 0) {
            ForEach(appModel.cart.lines) { line in
              CartLineRow(line: line, style: .full)
              if line.id != appModel.cart.lines.last?.id {
                Divider()
                  .padding(.leading, 112)
              }
            }
          }
          .background(ThemeTokens.cardSurface)
          .clipShape(
            RoundedRectangle(
              cornerRadius: 24,
              style: .continuous
            )
          )
          .overlay {
            RoundedRectangle(
              cornerRadius: 24,
              style: .continuous
            )
            .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.7)
          }
          .padding(.horizontal, ThemeTokens.horizontalPadding)

          fullSummary
            .padding(.top, 18)
        }
      }
      .padding(.bottom, 100)
    }
    .navigationBarHidden(true)
    .nativeSoftTopScrollEdgeEffect()
    .nativeSwipeBack()
  }

  private var cartDrawerHeader: some View {
    HStack {
      Text("Cart")
        .themeScaledFont(size: 25, weight: .bold)
        .accessibilityAddTraits(.isHeader)

      Spacer()

      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 17, weight: .semibold))
          .frame(
            width: ThemeTokens.minimumTap,
            height: ThemeTokens.minimumTap
          )
      }
      .buttonStyle(.plain)
      .adaptiveGlass(in: Circle(), interactive: true)
      .accessibilityLabel("Close cart")
      .accessibilityIdentifier("cart-close")
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 14)
  }

  @ViewBuilder
  private var cartStateContent: some View {
    if appModel.hasPendingCartRestore {
      restoringCart
    } else if appModel.cart.lines.isEmpty {
      emptyCart
    } else {
      ScrollView {
        LazyVStack(spacing: 0) {
          ForEach(appModel.cart.lines) { line in
            CartLineRow(line: line, style: .drawer)
            if line.id != appModel.cart.lines.last?.id {
              Divider()
                .padding(.leading, 104)
            }
          }

          if let error = appModel.cartError {
            InlineErrorView(message: error) {
              Task { await appModel.retryCart() }
            }
          }
        }
        .background(ThemeTokens.cardSurface.opacity(0.94))
        .clipShape(
          RoundedRectangle(
            cornerRadius: 22,
            style: .continuous
          )
        )
        .overlay {
          RoundedRectangle(
            cornerRadius: 22,
            style: .continuous
          )
          .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.8)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
      }
    }
  }

  private var emptyCart: some View {
    VStack(spacing: 14) {
      Image(systemName: "bag")
        .themeScaledFont(
          size: 42,
          weight: .light,
          relativeTo: .largeTitle,
          maximumScale: 1.25
        )
        .foregroundStyle(ThemeTokens.muted)

      Text("Your cart is empty")
        .themeScaledFont(size: 19, weight: .bold)

      Text("Your BeautyOnTApp picks will appear here.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

      if let error = appModel.cartError {
        Text(error)
          .font(.footnote)
          .foregroundStyle(ThemeTokens.sale)
          .multilineTextAlignment(.center)
      }

      Button("Continue shopping") {
        if mode == .drawer {
          dismiss()
        } else {
          appModel.selectDock(.home)
        }
      }
      .accessibilityIdentifier("empty-cart-continue")
      .buttonStyle(.borderedProminent)
      .tint(ThemeTokens.ink)
    }
    .padding(30)
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity,
      alignment: .center
    )
  }

  private var restoringCart: some View {
    VStack(spacing: 14) {
      if appModel.isCartBusy {
        ProgressView()
          .tint(ThemeTokens.gold)
        Text("Refreshing your cart")
          .font(.headline)
      } else {
        InlineErrorView(
          message:
            appModel.cartError
            ?? "Your saved cart could not refresh."
        ) {
          Task { await appModel.retryCart() }
        }
      }
    }
    .padding(30)
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity,
      alignment: .center
    )
  }

  private var drawerSummary: some View {
    VStack(spacing: 14) {
      totalRow
      PaymentMethodsCard()
      deliveryCard

      HStack(spacing: 10) {
        Button {
          appModel.requestFullCartAfterCartDismiss()
        } label: {
          Text("VIEW CART")
            .tracking(0.8)
            .themeScaledFont(size: 12, weight: .bold)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .buttonStyle(.plain)
        .foregroundStyle(ThemeTokens.ink)
        .adaptiveGlass(
          in: Capsule(),
          tint: ThemeTokens.glassControlTint,
          interactive: true
        )
        .accessibilityIdentifier("cart-view-full")

        Button {
          checkout()
        } label: {
          Text("CHECK OUT")
            .tracking(0.8)
            .themeScaledFont(size: 12, weight: .bold)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .buttonStyle(.plain)
        .foregroundStyle(ThemeTokens.primaryButtonForeground)
        .background(ThemeTokens.primaryButton, in: Capsule())
        .accessibilityIdentifier("cart-checkout")
      }
      .disabled(appModel.isCartBusy)
    }
    .padding(18)
    .background(ThemeTokens.cardSurface.opacity(0.94))
    .clipShape(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
    )
    .overlay {
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.8)
    }
    .padding(.horizontal, 18)
    .padding(.bottom, 14)
  }

  private var fullSummary: some View {
    VStack(alignment: .leading, spacing: 18) {
      Text("Summary")
        .themeScaledFont(size: 22, weight: .bold)

      HStack {
        Text("Subtotal")
          .themeScaledFont(size: 14)
        Spacer()
        Text(appModel.cart.subtotal.text)
          .themeScaledFont(size: 15, weight: .semibold)
      }

      Divider()

      totalRow

      Text("Tax included. Shipping calculated at checkout.")
        .themeScaledFont(size: 12)
        .foregroundStyle(.secondary)

      PaymentMethodsCard()
      deliveryCard

      Button {
        checkout()
      } label: {
        Text("Check out")
          .themeScaledFont(size: 15, weight: .bold)
          .frame(maxWidth: .infinity)
          .frame(height: 54)
      }
      .buttonStyle(.plain)
      .foregroundStyle(ThemeTokens.primaryButtonForeground)
      .background(ThemeTokens.primaryButton, in: Capsule())
      .disabled(appModel.isCartBusy)
      .accessibilityIdentifier("cart-full-checkout")
    }
    .padding(20)
    .background(ThemeTokens.cardSurface)
    .clipShape(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
    )
    .overlay {
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.7)
    }
    .padding(.horizontal, ThemeTokens.horizontalPadding)
  }

  private var totalRow: some View {
    HStack {
      Text("Total")
        .themeScaledFont(size: 17, weight: .bold)
      Spacer()
      Text("\(appModel.cart.total.text) ZAR")
        .themeScaledFont(size: 18, weight: .bold)
    }
  }

  private var deliveryCard: some View {
    Button {
      NativeHaptics.play(.navigation)
      childSheet = .delivery
    } label: {
      HStack(spacing: 12) {
        Image(systemName: "truck.box")
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(ThemeTokens.deliveryAccent)
          .frame(width: 42, height: 42)
          .background(ThemeTokens.cardSurface, in: Circle())

        VStack(alignment: .leading, spacing: 2) {
          Text("DELIVERY")
            .tracking(1.2)
            .themeScaledFont(size: 9, weight: .bold)
            .foregroundStyle(.secondary)
          Text("Your glow, on the way")
            .themeScaledFont(size: 14, weight: .bold)
          Text("Check available options for your area.")
            .themeScaledFont(size: 11)
            .foregroundStyle(.secondary)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.system(size: 12, weight: .bold))
          .frame(
            width: ThemeTokens.minimumTap,
            height: ThemeTokens.minimumTap
          )
      }
      .padding(12)
      .contentShape(Rectangle())
      .background(ThemeTokens.deliverySurface)
      .clipShape(
        RoundedRectangle(cornerRadius: 18, style: .continuous)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
          .stroke(ThemeTokens.deliveryAccent.opacity(0.28), lineWidth: 0.7)
      }
    }
    .buttonStyle(.plain)
    .nativePressResponse(scale: 0.985)
    .foregroundStyle(ThemeTokens.ink)
    .accessibilityIdentifier("cart-delivery-estimator")
  }

  private func checkout() {
    guard appModel.requestCheckoutAfterCartDismiss() else {
      return
    }
    if mode == .drawer {
      dismiss()
    } else {
      Task {
        await appModel.presentRequestedCheckout()
      }
    }
  }
}

private enum CartChildSheet: String, Identifiable {
  case delivery

  var id: String { rawValue }
}

private enum CartLineStyle {
  case drawer
  case full
}

private struct CartLineRow: View {
  @EnvironmentObject private var appModel: AppModel

  let line: StoreCartLine
  let style: CartLineStyle

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      RemoteProductImage(
        url: line.merchandise.image?.url,
        pixelWidth: 240,
        accessibilityLabel: line.product.title
      )
      .frame(
        width: style == .drawer ? 76 : 88,
        height: style == .drawer ? 76 : 88
      )
      .clipShape(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
      )

      VStack(alignment: .leading, spacing: 5) {
        Text(line.product.vendor.uppercased())
          .tracking(0.7)
          .themeScaledFont(size: 9, weight: .bold)
          .foregroundStyle(ThemeTokens.muted)
          .lineLimit(1)

        Text(line.product.title)
          .themeScaledFont(size: 13, weight: .bold)
          .lineLimit(2)

        if line.merchandise.title != "Default Title" {
          Text(line.merchandise.title)
            .themeScaledFont(size: 10)
            .foregroundStyle(.secondary)
            .lineLimit(2)
        }

        if !line.bookingDetails.isEmpty {
          VStack(alignment: .leading, spacing: 3) {
            ForEach(line.bookingDetails, id: \.key) { detail in
              HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("\(detail.key):")
                  .fontWeight(.semibold)
                Text(detail.value)
              }
              .themeScaledFont(size: 9.5)
              .foregroundStyle(.secondary)
            }
          }
          .padding(.top, 2)
        }

        Text(line.cost.text)
          .themeScaledFont(size: 13, weight: .semibold)
          .padding(.top, 2)

        if line.bookingReservationID == nil {
          quantityControl
            .padding(.top, 5)
        }
      }

      Spacer(minLength: 2)

      Button {
        Task {
          await appModel.setCartLine(line, quantity: 0)
        }
      } label: {
        Image(systemName: "trash")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(ThemeTokens.dangerAccent)
          .frame(
            width: ThemeTokens.minimumTap,
            height: ThemeTokens.minimumTap
          )
          .background(
            ThemeTokens.dangerSurface,
            in: RoundedRectangle(
              cornerRadius: 14,
              style: .continuous
            )
          )
      }
      .buttonStyle(.plain)
      .disabled(appModel.isCartBusy)
      .accessibilityLabel("Remove \(line.product.title)")
    }
    .padding(style == .drawer ? 12 : 16)
    .contentShape(Rectangle())
  }

  private var quantityControl: some View {
    HStack(spacing: 0) {
      quantityButton(
        symbol: "minus",
        label: "Decrease \(line.product.title) quantity"
      ) {
        Task {
          await appModel.setCartLine(
            line,
            quantity: line.quantity - 1
          )
        }
      }

      Text("\(line.quantity)")
        .themeScaledFont(size: 14, weight: .semibold)
        .monospacedDigit()
        .frame(minWidth: 30)

      quantityButton(
        symbol: "plus",
        label: "Increase \(line.product.title) quantity"
      ) {
        Task {
          await appModel.setCartLine(
            line,
            quantity: line.quantity + 1
          )
        }
      }
    }
    .frame(width: 132, height: ThemeTokens.minimumTap)
    .background(ThemeTokens.controlSurface, in: Capsule())
  }

  private func quantityButton(
    symbol: String,
    label: String,
    action: @escaping () -> Void
  ) -> some View {
    Button {
      NativeHaptics.play(.selection)
      action()
    } label: {
      Image(systemName: symbol)
        .font(.system(size: 13, weight: .semibold))
        .frame(
          width: ThemeTokens.minimumTap,
          height: ThemeTokens.minimumTap
        )
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .nativePressResponse(scale: 0.985)
    .disabled(appModel.isCartBusy)
    .accessibilityLabel(label)
  }
}

private struct PaymentMethodsCard: View {
  private let methods = [
    "Pay",
    "Capitec Pay",
    "G Pay",
    "payflex",
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Pay your way")
        .themeScaledFont(size: 12, weight: .bold)

      HStack(spacing: 7) {
        ForEach(methods, id: \.self) { method in
          Text(method)
            .themeScaledFont(
              size: method == "Capitec Pay" ? 9 : 11,
              weight: .semibold
            )
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(ThemeTokens.controlSurface)
            .clipShape(
              RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
              )
            )
            .overlay {
              RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
              )
              .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.7)
            }
        }
      }

      Text("Options shown securely at checkout.")
        .themeScaledFont(size: 10)
        .foregroundStyle(.secondary)
    }
    .padding(12)
    .background(ThemeTokens.cardSurface)
    .clipShape(
      RoundedRectangle(cornerRadius: 18, style: .continuous)
    )
    .overlay {
      RoundedRectangle(cornerRadius: 18, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.7)
    }
  }
}

private struct DeliveryEstimatorSheet: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var appModel: AppModel

  let onCheckout: () -> Void

  @State private var selectedProvinceCode = "GP"
  @State private var postalCode = ""
  @State private var deliveryOptions: [StoreDeliveryOption] = []
  @State private var didRequestEstimate = false
  @State private var isProvincePickerPresented = false

  private var sortedDeliveryOptions: [StoreDeliveryOption] {
    deliveryOptions.sorted { lhs, rhs in
      let lhsPriority = deliveryPriority(lhs.title)
      let rhsPriority = deliveryPriority(rhs.title)
      if lhsPriority != rhsPriority {
        return lhsPriority < rhsPriority
      }
      return lhs.estimatedCost.amount < rhs.estimatedCost.amount
    }
  }

  var body: some View {
    ZStack {
      estimatorContent

      if isProvincePickerPresented {
        provincePickerOverlay
          .transition(
            reduceMotion
              ? .opacity
              : .scale(scale: 0.96).combined(with: .opacity)
          )
          .zIndex(2)
      }
    }
    .animation(
      reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.88),
      value: isProvincePickerPresented
    )
  }

  private var estimatorContent: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 5) {
            Text("Check your delivery")
              .themeScaledFont(size: 23, weight: .bold)
            Text(
              "Enter your delivery location to view available rates before checkout."
            )
            .themeScaledFont(size: 13)
            .foregroundStyle(.secondary)
          }

          Spacer()

          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 17, weight: .semibold))
              .frame(
                width: ThemeTokens.minimumTap,
                height: ThemeTokens.minimumTap
              )
          }
          .buttonStyle(.plain)
          .adaptiveGlass(in: Circle(), interactive: true)
          .accessibilityLabel("Close delivery estimator")
        }

        if !sortedDeliveryOptions.isEmpty {
          VStack(alignment: .leading, spacing: 9) {
            ForEach(sortedDeliveryOptions) { option in
              HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundStyle(ThemeTokens.success)
                Text(displayTitle(option.title))
                  .themeScaledFont(size: 13, weight: .semibold)
                Spacer()
                Text(option.estimatedCost.text)
                  .themeScaledFont(size: 13, weight: .bold)
              }
            }
          }
          .accessibilityElement(children: .contain)
          .accessibilityIdentifier("delivery-options")
          .padding(14)
          .background(
            ThemeTokens.successSurface,
            in: RoundedRectangle(
              cornerRadius: 18,
              style: .continuous
            )
          )

          Button(action: onCheckout) {
            Label("Continue to checkout", systemImage: "lock.fill")
              .themeScaledFont(size: 15, weight: .bold)
              .frame(maxWidth: .infinity)
              .frame(height: 52)
          }
          .buttonStyle(.plain)
          .foregroundStyle(ThemeTokens.primaryButtonForeground)
          .background(ThemeTokens.primaryButton, in: Capsule())
          .accessibilityHint(
            "Continues to secure checkout with the delivery options shown"
          )
          .accessibilityIdentifier("delivery-continue-checkout")
        }

        locationField(
          title: "Country",
          value: "South Africa"
        )

        Button {
          isProvincePickerPresented = true
        } label: {
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text("State/Province")
                .themeScaledFont(size: 10)
                .foregroundStyle(.secondary)
              Text(
                SouthAfricaProvince.name(
                  for: selectedProvinceCode
                )
              )
                .themeScaledFont(size: 15, weight: .medium)
            }
            Spacer()
            Image(systemName: "chevron.down")
              .font(.system(size: 12, weight: .bold))
          }
          .padding(.horizontal, 16)
          .frame(minHeight: 66)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(ThemeTokens.ink)
        .adaptiveGlass(
          in: RoundedRectangle(
            cornerRadius: 18,
            style: .continuous
          ),
          tint: ThemeTokens.glassControlTint,
          interactive: true
        )
        .accessibilityIdentifier("delivery-province")

        VStack(alignment: .leading, spacing: 4) {
          Text("Postcode")
            .themeScaledFont(size: 10)
            .foregroundStyle(.secondary)
          // Keep the field genuinely blank until the customer enters a
          // postcode; do not imply a saved or pre-filled delivery location.
          TextField("", text: $postalCode)
            .keyboardType(.numberPad)
            .textContentType(.postalCode)
            .font(.body)
            .accessibilityLabel("Postcode")
            .accessibilityIdentifier("delivery-postcode")
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 66)
        .background(ThemeTokens.controlSurface)
        .clipShape(
          RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .accessibilityIdentifier("delivery-postcode")

        if didRequestEstimate,
          sortedDeliveryOptions.isEmpty,
          !appModel.isCartBusy
        {
          Text(
            appModel.cartError
              ?? "No delivery options were returned for this location."
          )
          .themeScaledFont(size: 12, weight: .medium)
          .foregroundStyle(ThemeTokens.sale)
          .accessibilityIdentifier("delivery-options-empty")
        }

        Button {
          requestEstimate()
        } label: {
          Group {
            if appModel.isCartBusy {
              ProgressView()
                .tint(ThemeTokens.primaryButtonForeground)
            } else {
              Text("Get Estimate")
                .themeScaledFont(size: 15, weight: .bold)
            }
          }
          .frame(maxWidth: .infinity)
          .frame(height: 54)
        }
        .buttonStyle(.plain)
        .foregroundStyle(ThemeTokens.primaryButtonForeground)
        .background(ThemeTokens.primaryButton, in: Capsule())
        .disabled(
          appModel.isCartBusy
            || postalCode.trimmingCharacters(
              in: .whitespacesAndNewlines
            ).isEmpty
        )
        .accessibilityIdentifier("delivery-get-estimate")
      }
      .padding(20)
    }
    .background(.ultraThinMaterial)
    .nativeSheetStyle(.large)
  }

  private var provincePickerOverlay: some View {
    ZStack {
      Color.black.opacity(0.14)
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
          isProvincePickerPresented = false
        }
        .accessibilityHidden(true)

      VStack(spacing: 0) {
        ForEach(SouthAfricaProvince.all) { province in
          Button {
            selectedProvinceCode = province.code
            isProvincePickerPresented = false
            UISelectionFeedbackGenerator().selectionChanged()
          } label: {
            HStack(spacing: 12) {
              Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .opacity(
                  selectedProvinceCode == province.code ? 1 : 0
                )

              Text(province.name)
                .themeScaledFont(size: 15, weight: .medium)

              Spacer()
            }
            .foregroundStyle(ThemeTokens.ink)
            .padding(.horizontal, 18)
            .frame(minHeight: ThemeTokens.minimumTap)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .accessibilityLabel(province.name)
          .accessibilityIdentifier(
            "delivery-province-\(province.code.lowercased())"
          )
        }
      }
      .padding(.vertical, 8)
      .frame(maxWidth: 306)
      .adaptiveGlass(
        in: RoundedRectangle(
          cornerRadius: 28,
          style: .continuous
        ),
        tint: ThemeTokens.glassNavigationTint,
        interactive: true
      )
      .shadow(color: Color.black.opacity(0.18), radius: 24, y: 12)
      .padding(.horizontal, 36)
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier("delivery-province-picker")
    }
  }

  private func locationField(
    title: String,
    value: String
  ) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .themeScaledFont(size: 10)
        .foregroundStyle(.secondary)
      Text(value)
        .themeScaledFont(size: 15, weight: .medium)
    }
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity, minHeight: 66, alignment: .leading)
    .background(ThemeTokens.controlSurface)
    .clipShape(
      RoundedRectangle(cornerRadius: 18, style: .continuous)
    )
  }

  private func requestEstimate() {
    let normalizedPostcode = postalCode
      .filter(\.isNumber)
      .prefix(4)
    postalCode = String(normalizedPostcode)
    // Never leave a previous postcode's rates visible while a new lookup is
    // in flight. This is especially important when a valid postcode is
    // followed by one with no configured rates.
    deliveryOptions = []
    guard normalizedPostcode.count == 4 else {
      didRequestEstimate = true
      return
    }

    didRequestEstimate = true
    Task {
      deliveryOptions = await appModel.estimateDelivery(
        provinceCode: selectedProvinceCode,
        postalCode: String(normalizedPostcode)
      )
      if !deliveryOptions.isEmpty {
        UINotificationFeedbackGenerator()
          .notificationOccurred(.success)
      }
    }
  }

  private func deliveryPriority(_ title: String) -> Int {
    let normalized = title.lowercased()
    return normalized.contains("same-day")
      || normalized.hasPrefix("local delivery")
      ? 0
      : 1
  }

  private func displayTitle(_ title: String) -> String {
    if title.lowercased().hasPrefix("local delivery") {
      return title.replacingOccurrences(
        of: "local delivery",
        with: "Same-day delivery",
        options: [.caseInsensitive, .anchored]
      )
    }
    return title
  }
}
