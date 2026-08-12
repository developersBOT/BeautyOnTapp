import SwiftUI

@MainActor
final class BrandsViewModel: ObservableObject {
  @Published private(set) var brands: [NativeBrand] = []
  @Published private(set) var isLoading = false
  @Published private(set) var errorMessage: String?

  private let client: BrandDirectoryClient
  private var hasLoaded = false

  init(client: BrandDirectoryClient = .shared) {
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
      brands = try await client.fetchBrands()
      hasLoaded = true
    } catch is CancellationError {
      return
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}

struct BrandsView: View {
  @EnvironmentObject private var appModel: AppModel
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @StateObject private var viewModel: BrandsViewModel
  @State private var query = ""
  @State private var selectedLetter: String?
  @Namespace private var alphabetSelectionNamespace

  init(client: BrandDirectoryClient = .shared) {
    _viewModel = StateObject(wrappedValue: BrandsViewModel(client: client))
  }

  private var letters: [String] {
    let available = Set(viewModel.brands.compactMap { firstLetter(of: $0.name) })
    return (65...90)
      .compactMap { UnicodeScalar($0).map(String.init) }
      .filter { available.contains($0) }
  }

  private var filteredGroups: [(letter: String, brands: [NativeBrand])] {
    let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()
    let filtered = viewModel.brands.filter { brand in
      guard !normalizedQuery.isEmpty else { return true }
      return brand.name.lowercased().contains(normalizedQuery)
    }

    let grouped = Dictionary(grouping: filtered) {
      firstLetter(of: $0.name) ?? "#"
    }
    return grouped.keys.sorted().compactMap { letter in
      guard let brands = grouped[letter], !brands.isEmpty else { return nil }
      return (letter, brands.sorted {
        $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
      })
    }
  }

  var body: some View {
    ScrollViewReader { scrollProxy in
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
            VStack(alignment: .leading, spacing: 20) {
              breadcrumb
              heading
              directoryToolbar(scrollProxy: scrollProxy)

              if viewModel.isLoading && viewModel.brands.isEmpty {
                loadingState
              } else if let errorMessage = viewModel.errorMessage,
                viewModel.brands.isEmpty
              {
                errorState(message: errorMessage)
              } else if filteredGroups.isEmpty {
                emptyState
              } else {
                brandGroups
              }
            }
            .padding(.horizontal, ThemeTokens.horizontalPadding)
            .padding(.top, 18)
            .padding(.bottom, 84)
          } header: {
            StoreHeader(
              appModel: appModel,
              presentation: .tabs,
              activeCollectionHandle: "__brands__"
            )
            .zIndex(1)
          }
        }
      }
      .background(ThemeTokens.canvas)
      .navigationBarHidden(true)
      .nativeSwipeBack()
      .accessibilityIdentifier("brands-screen")
      .task {
        await viewModel.loadIfNeeded()
      }
      .refreshable {
        await viewModel.reload()
      }
    }
  }

  private var breadcrumb: some View {
    HStack(spacing: 8) {
      Text("Home")
        .foregroundStyle(ThemeTokens.muted)
      Image(systemName: "chevron.right")
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(ThemeTokens.soft)
      Text("Brands")
        .foregroundStyle(ThemeTokens.ink)
        .font(.system(size: 13, weight: .semibold))
    }
    .themeScaledFont(size: 13)
    .accessibilityElement(children: .combine)
  }

  private var heading: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text("Shop by Brand")
        .themeScaledFont(size: 25, weight: .bold)
        .foregroundStyle(ThemeTokens.ink)
      Text("Search or browse A–Z.")
        .themeScaledFont(size: 15)
        .foregroundStyle(ThemeTokens.muted)
    }
  }

  private func directoryToolbar(
    scrollProxy: ScrollViewProxy
  ) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 9) {
        Image(systemName: "magnifyingglass")
          .font(.system(size: 16, weight: .medium))
          .foregroundStyle(ThemeTokens.muted)

        TextField("Search brands", text: $query)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .themeScaledFont(size: 16)
          .foregroundStyle(ThemeTokens.ink)
          .accessibilityIdentifier("brands-search")

        if !query.isEmpty {
          Button {
            query = ""
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundStyle(ThemeTokens.soft)
          }
          .buttonStyle(.plain)
          .accessibilityLabel("Clear brand search")
        }
      }
      .padding(.horizontal, 15)
      .frame(height: 48)
      .background(ThemeTokens.canvas, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 15, style: .continuous)
          .stroke(ThemeTokens.separator.opacity(0.6), lineWidth: 0.8)
      }

      if !letters.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          alphabetButtons(scrollProxy: scrollProxy)
            .padding(.vertical, 2)
        }
      }
    }
    .padding(12)
    .background {
      if #available(iOS 26.0, *), !reduceTransparency {
        RoundedRectangle(cornerRadius: 21, style: .continuous)
          .fill(.clear)
          .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 21, style: .continuous))
      } else {
        RoundedRectangle(cornerRadius: 21, style: .continuous)
          .fill(ThemeTokens.controlSurface)
      }
    }
    .overlay {
      RoundedRectangle(cornerRadius: 21, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.8)
    }
  }

  @ViewBuilder
  private func alphabetButtons(scrollProxy: ScrollViewProxy) -> some View {
    if #available(iOS 26.0, *), !reduceTransparency {
      GlassEffectContainer(spacing: 5) {
        alphabetButtonRow(scrollProxy: scrollProxy)
      }
    } else {
      alphabetButtonRow(scrollProxy: scrollProxy)
    }
  }

  private func alphabetButtonRow(
    scrollProxy: ScrollViewProxy
  ) -> some View {
    HStack(spacing: 7) {
      ForEach(letters, id: \.self) { letter in
        Button {
          selectLetter(letter, scrollProxy: scrollProxy)
        } label: {
          Text(letter)
            .themeScaledFont(size: 14, weight: .semibold)
            .foregroundStyle(ThemeTokens.ink)
            .frame(width: 39, height: 39)
            .modifier(
              BrandAlphabetSelectionModifier(
                isActive: selectedLetter == letter,
                reduceTransparency: reduceTransparency,
                reduceMotion: reduceMotion,
                namespace: alphabetSelectionNamespace
              )
            )
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityAddTraits(selectedLetter == letter ? .isSelected : [])
        .accessibilityIdentifier("brands-letter-\(letter)")
      }
    }
  }

  private var brandGroups: some View {
    LazyVStack(alignment: .leading, spacing: 26) {
      ForEach(filteredGroups, id: \.letter) { group in
        VStack(alignment: .leading, spacing: 9) {
          Text(group.letter)
            .themeScaledFont(size: 19, weight: .bold)
            .foregroundStyle(ThemeTokens.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 2)
            .overlay(alignment: .bottom) {
              Rectangle()
                .fill(ThemeTokens.separator.opacity(0.65))
                .frame(height: 0.8)
            }
            .id(group.letter)

          LazyVGrid(
            columns: [
              GridItem(.flexible(), spacing: 9),
              GridItem(.flexible(), spacing: 9),
              GridItem(.flexible(), spacing: 9),
            ],
            spacing: 9
          ) {
            ForEach(group.brands) { brand in
              brandButton(brand)
            }
          }
        }
      }
    }
  }

  private func brandButton(_ brand: NativeBrand) -> some View {
    Button {
      guard let handle = brand.handle else { return }
      appModel.showCollection(title: brand.name, handle: handle)
    } label: {
      Text(brand.name)
        .themeScaledFont(size: 14, weight: .semibold)
        .foregroundStyle(ThemeTokens.ink)
        .multilineTextAlignment(.leading)
        .lineLimit(2)
        .minimumScaleFactor(0.82)
        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
        .padding(.horizontal, 12)
    }
    .buttonStyle(.plain)
    .background(ThemeTokens.controlSurface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 15, style: .continuous)
        .stroke(ThemeTokens.separator.opacity(0.62), lineWidth: 0.8)
    }
    .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    .accessibilityIdentifier("brand-\(brand.name.replacingOccurrences(of: " ", with: "-"))")
    .disabled(brand.handle == nil)
  }

  private var loadingState: some View {
    VStack(spacing: 12) {
      ProgressView()
        .tint(ThemeTokens.ink)
      Text("Loading brands…")
        .themeScaledFont(size: 14, weight: .medium)
        .foregroundStyle(ThemeTokens.muted)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 44)
  }

  private func errorState(message: String) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(message)
        .themeScaledFont(size: 14)
        .foregroundStyle(ThemeTokens.muted)
      Button("Try Again") {
        Task { await viewModel.reload() }
      }
      .buttonStyle(.borderedProminent)
      .tint(ThemeTokens.primaryButton)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.vertical, 24)
  }

  private var emptyState: some View {
    Text("No brands match your search.")
      .themeScaledFont(size: 15, weight: .medium)
      .foregroundStyle(ThemeTokens.muted)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, 24)
  }

  private func selectLetter(
    _ letter: String,
    scrollProxy: ScrollViewProxy
  ) {
    selectedLetter = letter
    guard query.isEmpty else { return }
    if reduceMotion {
      scrollProxy.scrollTo(letter, anchor: .top)
    } else {
      withAnimation(ThemeTokens.navigationSpring) {
        scrollProxy.scrollTo(letter, anchor: .top)
      }
    }
  }

  private func firstLetter(of name: String) -> String? {
    guard let first = name.first else { return nil }
    return String(first).uppercased()
  }
}

private struct BrandAlphabetSelectionModifier: ViewModifier {
  let isActive: Bool
  let reduceTransparency: Bool
  let reduceMotion: Bool
  let namespace: Namespace.ID

  @ViewBuilder
  func body(content: Content) -> some View {
    if isActive {
      if #available(iOS 26.0, *), !reduceTransparency {
        content
          .glassEffect(.regular.interactive(), in: Circle())
          .glassEffectID("brands-letter-selection", in: namespace)
          .glassEffectTransition(reduceMotion ? .identity : .matchedGeometry)
          .overlay { Circle().stroke(ThemeTokens.separator, lineWidth: 0.8) }
      } else {
        content
          .background(ThemeTokens.controlSurface, in: Circle())
          .overlay { Circle().stroke(ThemeTokens.separator, lineWidth: 0.8) }
      }
    } else {
      content
        .background(ThemeTokens.canvas, in: Circle())
        .overlay { Circle().stroke(ThemeTokens.separator.opacity(0.55), lineWidth: 0.8) }
    }
  }
}
