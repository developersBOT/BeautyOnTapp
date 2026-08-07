import SwiftUI

@MainActor
final class StoresViewModel: ObservableObject {
  @Published private(set) var locations: [StoreLocation] = []
  @Published private(set) var isLoading = false
  @Published private(set) var errorMessage: String?

  private let client: any StoreLocationsFetching
  private var hasLoaded = false

  init(client: any StoreLocationsFetching = StoreLocationsClient.shared) {
    self.client = client
  }

  func loadIfNeeded() async {
    guard !hasLoaded else { return }
    await load()
  }

  func reload() async {
    await load()
  }

  private func load() async {
    guard !isLoading else { return }
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    do {
      locations = try await client.fetchLocations()
      hasLoaded = true
    } catch is CancellationError {
      return
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}

struct StoresView: View {
  @EnvironmentObject private var appModel: AppModel
  @Environment(\.openURL) private var openURL
  @StateObject private var viewModel: StoresViewModel

  init(
    client: any StoreLocationsFetching = StoreLocationsClient.shared
  ) {
    _viewModel = StateObject(
      wrappedValue: StoresViewModel(client: client)
    )
  }

  var body: some View {
    ScrollView {
      LazyVStack(
        alignment: .leading,
        spacing: 0,
        pinnedViews: [.sectionHeaders]
      ) {
        StoreHeader(
          appModel: appModel,
          presentation: .primary
        )

        Section {
          VStack(alignment: .leading, spacing: 9) {
            heading

            if viewModel.isLoading, viewModel.locations.isEmpty {
              loading
            } else if let errorMessage = viewModel.errorMessage,
              viewModel.locations.isEmpty
            {
              errorState(message: errorMessage)
            } else {
              LazyVStack(spacing: 8) {
                ForEach(viewModel.locations) { location in
                  storeCard(location)
                }
              }

              if let errorMessage = viewModel.errorMessage {
                InlineErrorView(message: errorMessage) {
                  Task { await viewModel.reload() }
                }
              }
            }
          }
          .padding(.horizontal, ThemeTokens.horizontalPadding)
          .padding(.top, 8)
          .padding(.bottom, 84)
        }
        header: {
          StoreHeader(
            appModel: appModel,
            presentation: .tabs
          )
          .zIndex(1)
        }
      }
    }
    .background(ThemeTokens.canvas)
    .nativeSoftTopScrollEdgeEffect()
    .navigationBarHidden(true)
    .nativeSwipeBack()
    .accessibilityIdentifier("stores-screen")
    .task {
      await viewModel.loadIfNeeded()
    }
    .refreshable {
      await viewModel.reload()
    }
  }

  private var heading: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("FIND A BEAUTYONTAPP")
        .tracking(2.1)
        .themeScaledFont(size: 9, weight: .bold)
        .foregroundStyle(ThemeTokens.gold)

      Text("Choose Your Store")
        .themeScaledFont(size: 22, weight: .bold)
        .foregroundStyle(ThemeTokens.ink)

      Text("Locations, hours and directions")
        .themeScaledFont(size: 13)
        .foregroundStyle(.secondary)
    }
    .accessibilityElement(children: .combine)
  }

  private var loading: some View {
    VStack(spacing: 12) {
      ProgressView()
        .tint(ThemeTokens.gold)
      Text("Loading store locations")
        .themeScaledFont(size: 14, weight: .semibold)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 70)
    .accessibilityIdentifier("stores-loading")
  }

  private func errorState(message: String) -> some View {
    InlineErrorView(message: message) {
      Task { await viewModel.reload() }
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 40)
    .accessibilityIdentifier("stores-error")
  }

  private func storeCard(_ location: StoreLocation) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(alignment: .top, spacing: 7) {
        Image(systemName: "storefront")
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(ThemeTokens.ink)
          .frame(width: 26, height: 26)
          .background(ThemeTokens.cardSurface, in: Circle())

        VStack(alignment: .leading, spacing: 1) {
          Text(location.name)
            .themeScaledFont(size: 14, weight: .bold)
            .foregroundStyle(ThemeTokens.ink)
            .lineLimit(2)

          if !location.address.lines.isEmpty {
            Text(location.address.lines.joined(separator: "\n"))
              .themeScaledFont(size: 10)
              .foregroundStyle(.secondary)
              .lineLimit(2)
              .fixedSize(horizontal: false, vertical: true)
          }
        }

        Spacer(minLength: 0)
      }

      if !location.openingHours.isEmpty {
        Divider()
        VStack(alignment: .leading, spacing: 2) {
          Label("Hours", systemImage: "clock")
            .themeScaledFont(size: 9, weight: .semibold)
            .foregroundStyle(ThemeTokens.ink)

          ForEach(location.openingHours.prefix(2)) { hours in
            HStack(alignment: .firstTextBaseline, spacing: 8) {
              Text(hours.daySummary)
                .themeScaledFont(size: 9, weight: .medium)
                .lineLimit(1)
              Spacer(minLength: 8)
              Text("\(hours.opens)–\(hours.closes)")
                .themeScaledFont(size: 9, weight: .semibold)
                .monospacedDigit()
            }
            .foregroundStyle(.secondary)
          }
        }
      }

      if location.telephone != nil || location.email != nil {
        contactDetails(location)
      }

      actionButtons(location)
    }
    .padding(8)
    .adaptiveGlass(
      in: RoundedRectangle(cornerRadius: 14, style: .continuous),
      tint: ThemeTokens.glassControlTint,
      interactive: false
    )
    .overlay {
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.7)
    }
    .shadow(color: Color.black.opacity(0.045), radius: 5, y: 2)
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(
      "store-\(accessibilitySlug(location.name))"
    )
  }

  @ViewBuilder
  private func contactDetails(_ location: StoreLocation) -> some View {
    Divider()
    VStack(alignment: .leading, spacing: 2) {
      if let telephone = location.telephone {
        Label(telephone, systemImage: "phone")
          .themeScaledFont(size: 10)
          .foregroundStyle(.secondary)
      }
      if let email = location.email {
        Label(email, systemImage: "envelope")
          .themeScaledFont(size: 10)
          .foregroundStyle(.secondary)
      }
    }
  }

  private func actionButtons(_ location: StoreLocation) -> some View {
    HStack(spacing: 10) {
      if let telephoneURL = location.telephoneURL {
        actionButton(
          label: "Call",
          symbol: "phone.fill",
          primary: false
        ) {
          openURL(telephoneURL)
        }
      }

      if let emailURL = location.emailURL {
        actionButton(
          label: "Email",
          symbol: "envelope.fill",
          primary: false
        ) {
          openURL(emailURL)
        }
      }

      if let mapsURL = location.mapsURL {
        actionButton(
          label: "Directions",
          symbol: "arrow.triangle.turn.up.right.diamond.fill",
          primary: true
        ) {
          openURL(mapsURL)
        }
      }
    }
  }

  private func actionButton(
    label: String,
    symbol: String,
    primary: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Label(label, systemImage: symbol)
        .themeScaledFont(size: 11, weight: .semibold)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
        // Keep the full 44-point accessibility hit target, but use a slimmer
        // visual capsule so store cards do not become button-heavy.
        .frame(height: 32)
    }
    .frame(minHeight: ThemeTokens.minimumTap)
    .buttonStyle(.plain)
    .nativePressResponse(scale: 0.985)
    .foregroundStyle(
      primary ? ThemeTokens.primaryButtonForeground : ThemeTokens.ink
    )
    .background {
      if primary {
        Capsule()
          .fill(ThemeTokens.primaryButton)
      } else {
        Capsule()
          .adaptiveGlass(
            in: Capsule(),
            tint: ThemeTokens.glassControlTint,
            interactive: true
          )
          .overlay {
            Capsule()
              .stroke(ThemeTokens.separator.opacity(0.52), lineWidth: 0.7)
          }
      }
    }
  }

  private func accessibilitySlug(_ value: String) -> String {
    value
      .lowercased()
      .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
      .joined(separator: "-")
  }
}
