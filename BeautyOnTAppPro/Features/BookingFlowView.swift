import SwiftUI
import UIKit

struct BookingFlowView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var appModel: AppModel

  let product: StoreProduct
  let variant: StoreVariant

  @State private var stores: [BookEasyStore] = []
  @State private var selectedStore: BookEasyStore?
  @State private var days: [BookEasyDay] = []
  @State private var selectedDay: BookEasyDay?
  @State private var selectedTime: String?
  @State private var displayedMonth = Date()
  @State private var step = Step.store
  @State private var isLoading = false
  @State private var errorMessage: String?

  private enum Step: Int {
    case store = 1
    case schedule = 2
    case review = 3
  }

  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        header
        Divider()

        ScrollView {
          VStack(alignment: .leading, spacing: 18) {
            progress

            if isLoading && stores.isEmpty {
              loadingState
            } else {
              switch step {
              case .store:
                storeStep
              case .schedule:
                scheduleStep
              case .review:
                reviewStep
              }
            }

            if let errorMessage {
              Text(errorMessage)
                .themeScaledFont(size: 12.5, weight: .semibold)
                .foregroundStyle(ThemeTokens.sale)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("booking-error")
            }
          }
          .padding(.horizontal, 20)
          .padding(.top, 16)
          .padding(.bottom, 28)
        }
      }
      .background(ThemeTokens.groupedCanvas)
      .navigationBarHidden(true)
      .task { await loadStores() }
    }
    .navigationViewStyle(.stack)
    .nativeSheetStyle(.large)
    .accessibilityIdentifier("native-booking-flow")
  }

  private var header: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text("Book Smart Analysis")
          .themeScaledFont(size: 18, weight: .bold)
        Text(product.title)
          .themeScaledFont(size: 11.5, weight: .medium)
          .foregroundStyle(.secondary)
      }

      Spacer()

      Button {
        NativeHaptics.play(.dismiss)
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 15, weight: .semibold))
          .frame(width: 44, height: 44)
          .contentShape(Circle())
      }
      .buttonStyle(.plain)
      .adaptiveGlass(in: Circle(), interactive: true)
      .accessibilityLabel("Close booking")
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }

  private var progress: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(stepTitle)
          .themeScaledFont(size: 15, weight: .bold)
        Spacer()
        Text("Step \(step.rawValue) of 3")
          .themeScaledFont(size: 11, weight: .semibold)
          .foregroundStyle(.secondary)
      }
      GeometryReader { proxy in
        Capsule()
          .fill(ThemeTokens.separator.opacity(0.45))
          .overlay(alignment: .leading) {
            Capsule()
              .fill(ThemeTokens.ink)
              .frame(width: proxy.size.width * CGFloat(step.rawValue) / 3)
          }
      }
      .frame(height: 5)
    }
  }

  private var stepTitle: String {
    switch step {
    case .store: return "Choose a store"
    case .schedule: return "Choose a date and time"
    case .review: return "Review your appointment"
    }
  }

  private var loadingState: some View {
    HStack(spacing: 10) {
      ProgressView()
      Text("Loading live booking availability…")
        .themeScaledFont(size: 13, weight: .medium)
    }
    .frame(maxWidth: .infinity, minHeight: 150)
  }

  private var storeStep: some View {
    LazyVGrid(
      columns: [GridItem(.flexible()), GridItem(.flexible())],
      spacing: 12
    ) {
      ForEach(stores) { store in
        Button {
          NativeHaptics.play(.selection)
          selectedStore = store
          selectedDay = nil
          selectedTime = nil
          Task { await loadAvailability(for: store) }
        } label: {
          HStack(spacing: 10) {
            Image(systemName: "storefront")
              .font(.system(size: 15, weight: .semibold))
              .foregroundStyle(ThemeTokens.deepGold)
            Text(store.name)
              .themeScaledFont(size: 12.5, weight: .semibold)
              .multilineTextAlignment(.leading)
              .lineLimit(3)
            Spacer(minLength: 0)
          }
          .padding(14)
          .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
          .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .adaptiveGlass(
          in: RoundedRectangle(cornerRadius: 18, style: .continuous),
          interactive: true
        )
        .accessibilityIdentifier("booking-store-\(store.id)")
      }
    }
  }

  private var scheduleStep: some View {
    VStack(alignment: .leading, spacing: 16) {
      selectedStoreSummary

      HStack {
        Button { changeMonth(by: -1) } label: {
          Image(systemName: "chevron.left")
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)

        Spacer()
        Text(monthTitle)
          .themeScaledFont(size: 14, weight: .bold)
        Spacer()

        Button { changeMonth(by: 1) } label: {
          Image(systemName: "chevron.right")
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
      }

      if isLoading {
        ProgressView("Refreshing availability…")
          .frame(maxWidth: .infinity, minHeight: 90)
      } else if days.isEmpty {
        Text("No appointments are available for this month.")
          .themeScaledFont(size: 13, weight: .medium)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, minHeight: 90)
      } else {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 9) {
            ForEach(days) { day in
              selectionButton(
                title: formattedDate(day.date),
                selected: selectedDay?.id == day.id
              ) {
                selectedDay = day
                selectedTime = nil
              }
              .accessibilityIdentifier("booking-date-\(day.id)")
            }
          }
          .padding(.vertical, 2)
        }

        if let selectedDay {
          LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 10
          ) {
            ForEach(selectedDay.timeSlots, id: \.self) { time in
              selectionButton(
                title: time,
                selected: selectedTime == time
              ) {
                selectedTime = time
              }
              .accessibilityIdentifier("booking-time-\(time)")
            }
          }
        }
      }

      HStack(spacing: 12) {
        secondaryButton("Back") {
          step = .store
        }
        primaryButton("Review", disabled: selectedTime == nil) {
          step = .review
        }
      }
    }
  }

  private var reviewStep: some View {
    VStack(alignment: .leading, spacing: 16) {
      if let store = selectedStore, let day = selectedDay, let time = selectedTime {
        VStack(spacing: 0) {
          reviewRow(icon: "storefront", label: "Store", value: store.name)
          Divider().padding(.leading, 44)
          reviewRow(icon: "calendar", label: "Date", value: formattedDate(day.date))
          Divider().padding(.leading, 44)
          reviewRow(icon: "clock", label: "Time", value: time)
          Divider().padding(.leading, 44)
          reviewRow(
            icon: "person.crop.circle",
            label: "Consultant",
            value: store.teamMemberName
          )
        }
        .padding(14)
        .adaptiveGlass(
          in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )

        Text("The appointment is reserved when it is added to your bag. Complete checkout to confirm it.")
          .themeScaledFont(size: 12, weight: .medium)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)

        HStack(spacing: 12) {
          secondaryButton("Back") { step = .schedule }
          primaryButton("Add appointment", disabled: isLoading) {
            Task { await confirmBooking(store: store, day: day, time: time) }
          }
        }
      }
    }
  }

  private var selectedStoreSummary: some View {
    HStack(spacing: 10) {
      Image(systemName: "storefront")
        .foregroundStyle(ThemeTokens.deepGold)
      Text(selectedStore?.name ?? "")
        .themeScaledFont(size: 13, weight: .semibold)
      Spacer()
      Button("Change") {
        NativeHaptics.play(.navigation)
        step = .store
      }
      .themeScaledFont(size: 11.5, weight: .bold)
    }
    .padding(14)
    .background(ThemeTokens.cardSurface, in: RoundedRectangle(cornerRadius: 16))
  }

  private func selectionButton(
    title: String,
    selected: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button {
      NativeHaptics.play(.selection)
      action()
    } label: {
      Text(title)
        .themeScaledFont(size: 12, weight: .semibold)
        .foregroundStyle(selected ? ThemeTokens.primaryButtonForeground : ThemeTokens.ink)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: 44)
        .contentShape(Capsule())
    }
    .buttonStyle(.plain)
    .background(selected ? ThemeTokens.primaryButton : ThemeTokens.controlSurface, in: Capsule())
    .overlay { Capsule().stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.7) }
  }

  private func primaryButton(
    _ title: String,
    disabled: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button {
      NativeHaptics.play(.navigation)
      action()
    } label: {
      Group {
        if isLoading && title == "Add appointment" {
          ProgressView().tint(ThemeTokens.primaryButtonForeground)
        } else {
          Text(title)
        }
      }
      .themeScaledFont(size: 13, weight: .bold)
      .frame(maxWidth: .infinity, minHeight: 50)
      .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
    .buttonStyle(.plain)
    .foregroundStyle(ThemeTokens.primaryButtonForeground)
    .background(disabled ? ThemeTokens.soft : ThemeTokens.primaryButton, in: RoundedRectangle(cornerRadius: 15))
    .disabled(disabled)
  }

  private func secondaryButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button {
      NativeHaptics.play(.navigation)
      action()
    } label: {
      Text(title)
        .themeScaledFont(size: 13, weight: .bold)
        .frame(maxWidth: .infinity, minHeight: 50)
        .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
    .buttonStyle(.plain)
    .adaptiveGlass(in: RoundedRectangle(cornerRadius: 15), interactive: true)
  }

  private func reviewRow(icon: String, label: String, value: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 15, weight: .semibold))
        .frame(width: 30)
      Text(label)
        .themeScaledFont(size: 12, weight: .semibold)
        .foregroundStyle(.secondary)
        .frame(width: 74, alignment: .leading)
      Text(value)
        .themeScaledFont(size: 12.5, weight: .semibold)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.vertical, 10)
  }

  private var monthTitle: String {
    displayedMonth.formatted(.dateTime.month(.wide).year())
  }

  private func formattedDate(_ raw: String) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_ZA")
    for format in ["yyyy-MM-dd", "dd-MM-yyyy", "MMM d, yyyy", "d MMM yyyy"] {
      formatter.dateFormat = format
      if let date = formatter.date(from: raw) {
        return date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
      }
    }
    return raw
  }

  private func changeMonth(by value: Int) {
    guard let next = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth),
      let store = selectedStore
    else { return }
    displayedMonth = next
    selectedDay = nil
    selectedTime = nil
    NativeHaptics.play(.selection)
    Task { await loadAvailability(for: store) }
  }

  @MainActor
  private func loadStores() async {
    guard let price = Decimal(string: variant.price.amount) else {
      errorMessage = BookEasyError.invalidProduct.localizedDescription
      return
    }
    isLoading = true
    defer { isLoading = false }
    do {
      let availability = try await BookEasyClient.live.availability(
        productID: product.id,
        variantID: variant.id,
        productPrice: price,
        month: displayedMonth
      )
      stores = availability.stores
      guard stores.count == 7 else {
        throw BookEasyError.noBookingStores
      }
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  @MainActor
  private func loadAvailability(for store: BookEasyStore) async {
    guard let price = Decimal(string: variant.price.amount) else { return }
    isLoading = true
    errorMessage = nil
    do {
      let availability = try await BookEasyClient.live.availability(
        productID: product.id,
        variantID: variant.id,
        productPrice: price,
        month: displayedMonth,
        store: store
      )
      stores = availability.stores
      days = availability.days
      step = .schedule
    } catch {
      errorMessage = error.localizedDescription
    }
    isLoading = false
  }

  @MainActor
  private func confirmBooking(
    store: BookEasyStore,
    day: BookEasyDay,
    time: String
  ) async {
    guard !isLoading else { return }
    isLoading = true
    errorMessage = nil
    do {
      let booking = try await BookEasyClient.live.reserve(
        product: product,
        variant: variant,
        store: store,
        day: day,
        time: time
      )
      let added = await appModel.addToCart(
        variant: variant,
        quantity: 1,
        attributes: booking.cartAttributes
      )
      guard added else {
        await BookEasyClient.live.deleteReservation(id: booking.reservationID)
        throw BookEasyError.reservationFailed
      }
      UINotificationFeedbackGenerator().notificationOccurred(.success)
      dismiss()
      appModel.showTransientNotice("Appointment added to your bag.")
      appModel.presentCart()
    } catch {
      errorMessage = error.localizedDescription
    }
    isLoading = false
  }
}

/// Native replacement for the WebKit /pages/make-services page. Lists the two
/// bookable services using the Shop sheet's card language; each opens the
/// native product page, which carries the live price and the "Book an
/// appointment" entry into the native three-step flow.
struct BeautyServicesSheet: View {
  @EnvironmentObject private var appModel: AppModel

  private struct Service: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let tint: Color
    let handle: String
  }

  private let services: [Service] = [
    Service(
      id: "skin-analysis",
      title: "Skin Analysis",
      detail: "Your skin, scientifically understood",
      symbol: "camera.viewfinder",
      tint: Color(hex: 0x4C9A83),
      handle: "skin-analysis-quiz-routine-advice"
    ),
    Service(
      id: "hair-scalp-analysis",
      title: "Hair & Scalp Analysis",
      detail: "Understand your scalp, transform your hair",
      symbol: "scissors",
      tint: Color(hex: 0x5B718B),
      handle: "hair-analyser"
    ),
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ZStack {
        Text("Book Smart Analysis")
          .themeScaledFont(size: 18, weight: .bold)
          .accessibilityAddTraits(.isHeader)

        HStack {
          Spacer()
          Button {
            NativeHaptics.play(.dismiss)
            appModel.isBeautyServicesPresented = false
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 15, weight: .semibold))
              .frame(width: 44, height: 44)
              .contentShape(Circle())
          }
          .buttonStyle(.plain)
          .adaptiveGlass(in: Circle(), interactive: true)
          .accessibilityLabel("Close booking services")
        }
      }
      .frame(minHeight: 56)
      .padding(.horizontal, 16)

      Text("In-store at BeautyOnTApp stores")
        .themeScaledFont(size: 12, weight: .semibold)
        .foregroundStyle(ThemeTokens.muted)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)

      VStack(spacing: 10) {
        ForEach(services) { service in
          serviceTile(service)
        }
      }
      .padding(.horizontal, 16)

      Spacer(minLength: 0)
    }
    .padding(.top, 8)
    .accessibilityIdentifier("beauty-services-sheet")
  }

  private func serviceTile(_ service: Service) -> some View {
    Button {
      NativeHaptics.play(.navigation)
      appModel.showBeautyService(handle: service.handle)
    } label: {
      HStack(spacing: 12) {
        Image(systemName: service.symbol)
          .font(.system(size: 20, weight: .regular))
          .symbolRenderingMode(.monochrome)
          .foregroundStyle(service.tint)
          .frame(width: 30, height: 30)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 2) {
          Text(service.title)
            .themeScaledFont(size: 15, weight: .semibold)
            .foregroundStyle(ThemeTokens.ink)
          Text(service.detail)
            .themeScaledFont(size: 12)
            .foregroundStyle(ThemeTokens.muted)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
        }

        Spacer(minLength: 4)

        Image(systemName: "chevron.right")
          .font(.system(size: 11, weight: .semibold))
          .foregroundStyle(.secondary)
          .accessibilityHidden(true)
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
    .accessibilityHint("Opens \(service.title)")
    .accessibilityIdentifier("beauty-service-\(service.id)")
  }
}
