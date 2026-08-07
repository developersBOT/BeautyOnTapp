import SwiftUI

struct RootView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @StateObject var appModel: AppModel
  @State private var shopFocusRequest = 0
  @State private var profileFocusRequest = 0
  // A sheet dismissal is asynchronous.  Keep the next native presentation
  // behind the profile sheet until SwiftUI has completed its dismissal so a
  // close button is never left under an invisible presentation layer.
  @State private var profileSheetIsDismissed = true

  var body: some View {
    ZStack(alignment: .bottom) {
      rootShell
        .accessibilityHidden(
          appModel.isShopPresented || appModel.isProfilePresented
            || appModel.webDestination != nil
        )
        .allowsHitTesting(
          !appModel.isShopPresented && !appModel.isProfilePresented
            && appModel.webDestination == nil
        )

      if let notice = appModel.transientNotice {
        Text(notice)
          .themeScaledFont(size: 13, weight: .semibold)
          .foregroundStyle(.white)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 18)
          .frame(minHeight: ThemeTokens.minimumTap)
          .background(
            ThemeTokens.ink,
            in: Capsule()
          )
          .shadow(
            color: Color.black.opacity(0.18),
            radius: 12,
            y: 5
          )
          .padding(.horizontal, 24)
          .padding(.bottom, 78)
          .transition(
            .move(edge: .bottom)
              .combined(with: .opacity)
          )
          .accessibilityIdentifier("app-notice")
          .zIndex(10)
      }
    }
    .animation(
      reduceMotion
        ? nil
        : .spring(response: 0.34, dampingFraction: 0.86),
      value: appModel.isShopPresented
    )
    .animation(
      reduceMotion
        ? nil
        : .spring(response: 0.34, dampingFraction: 0.86),
      value: appModel.isProfilePresented
    )
    .animation(
      reduceMotion ? nil : ThemeTokens.controlSpring,
      value: appModel.transientNotice
    )
    .environmentObject(appModel)
    .task {
      await appModel.bootstrap()
    }
    .sheet(
      isPresented: $appModel.isShopPresented,
      onDismiss: shopSheetDidDismiss
    ) {
      ShopSheetView(
        menu: appModel.shopMenu,
        isLoading:
          appModel.isShopMenuLoading
          || !appModel.isBootstrapComplete,
        initialFocus: appModel.shopSheetFocus,
        onRetry: {
          Task {
            await appModel.retryShopMenu()
          }
        },
        onSelect: openShopItem,
        onDismiss: closeShop
      )
      .nativeSheetStyle(.large)
    }
    .sheet(
      isPresented: $appModel.isProfilePresented,
      onDismiss: profileSheetDidDismiss
    ) {
      ProfileSheet(onDismiss: closeProfile)
        .environmentObject(appModel)
        .nativeSheetStyle(.profile)
        .onAppear {
          profileSheetIsDismissed = false
        }
    }
    .fullScreenCover(isPresented: $appModel.isSearchPresented) {
      SearchView()
        .environmentObject(appModel)
    }
    .sheet(
      isPresented: Binding(
        get: {
          appModel.isLovesPresented && profileSheetIsDismissed
        },
        set: { presented in
          if !presented {
            appModel.isLovesPresented = false
          }
        }
      )
    ) {
      LovesView()
        .environmentObject(appModel)
    }
    .fullScreenCover(
      isPresented: Binding(
        get: {
          appModel.isIngredientGuidePresented && profileSheetIsDismissed
        },
        set: { presented in
          if !presented {
            appModel.isIngredientGuidePresented = false
          }
        }
      )
    ) {
      IngredientGuideView {
        appModel.isIngredientGuidePresented = false
      }
    }
    .sheet(
      isPresented: Binding(
        get: {
          appModel.isCartPresented && profileSheetIsDismissed
        },
        set: { presented in
          if !presented {
            appModel.isCartPresented = false
          }
        }
      ),
      onDismiss: {
        Task {
          await appModel.presentRequestedCheckout()
          appModel.presentRequestedFullCart()
        }
      },
      content: {
        CartView(mode: .drawer)
    .environmentObject(appModel)
    .onChange(of: appModel.isProfilePresented) { isPresented in
      if isPresented {
        profileSheetIsDismissed = false
      }
    }
      }
    )
    .fullScreenCover(
      item: $appModel.webDestination,
      onDismiss: {
        appModel.webFlowDidDismiss()
      },
      content: { destination in
        if let session = appModel.webSession {
          WebFlowView(
            session: session,
            destination: destination
          )
        } else {
          ProgressView()
        }
      }
    )
  }

  private var rootShell: some View {
    Group {
      if #available(iOS 16.0, *) {
        ModernRootNavigation(appModel: appModel) {
          rootContent
        }
      } else {
        LegacyRootNavigation(appModel: appModel) {
          rootContent
        }
      }
    }
    .accessibilityHidden(appModel.isShopPresented)
    .allowsHitTesting(!appModel.isShopPresented)
    // Reserve the dock's real footprint instead of laying it over the last
    // product row. This keeps prices, ratings and footer links readable while
    // preserving the floating dock appearance above the safe area.
    .safeAreaInset(edge: .bottom, spacing: 0) {
      if !appModel.isShopPresented && !appModel.isProfilePresented {
        BottomDock(
          appModel: appModel,
          shopFocusRequest: shopFocusRequest,
          profileFocusRequest: profileFocusRequest
        )
        .transition(
          .move(edge: .bottom)
            .combined(with: .opacity)
        )
      }
    }
  }

  private func closeShop() {
    appModel.dismissShop()
  }

  private func shopSheetDidDismiss() {
    appModel.dismissShop()
    shopFocusRequest += 1
  }

  private func closeProfile() {
    appModel.dismissProfile()
  }

  private func profileSheetDidDismiss() {
    profileSheetIsDismissed = true
    appModel.dismissProfile()
    profileFocusRequest += 1
  }

  private func openShopItem(_ item: StoreMenuItem) {
    guard item.items.isEmpty else { return }
    guard let url = verifiedDestinationURL(for: item) else {
      appModel.showTransientNotice(
        "\(item.title) is unavailable right now."
      )
      return
    }
    let title = item.title.trimmingCharacters(
      in: .whitespacesAndNewlines
    )

    if let handle = nativeCollectionHandle(from: url) {
      appModel.showCollection(title: title, handle: handle)
      return
    }

    appModel.openThemeLink(
      title: title,
      link: ThemeLink(url.absoluteString)
    )
    closeShop()
  }

  private func verifiedDestinationURL(
    for item: StoreMenuItem
  ) -> URL? {
    guard let url = item.url,
      ShopifyAsset.isPrimaryStorefrontURL(url),
      url.fragment == nil,
      !url.path.isEmpty,
      url.path != "/"
    else {
      return nil
    }
    return url
  }

  private func nativeCollectionHandle(from url: URL) -> String? {
    guard url.query == nil else { return nil }
    let components = url.pathComponents.filter { $0 != "/" }
    guard components.count == 2,
      components[0].caseInsensitiveCompare("collections")
        == .orderedSame,
      !components[1].isEmpty
    else {
      return nil
    }
    // The theme's old Body Wash link still points to a retired alias. Keep
    // navigation native while resolving it to the live storefront collection.
    switch components[1].lowercased() {
    case "body-wash-1":
      return "body-wash"
    default:
      return components[1]
    }
  }

  @ViewBuilder
  private var rootContent: some View {
    if appModel.rootDockDestination == .stores {
      StoresView()
    } else if appModel.rootDockDestination == .exclusive {
      ExclusiveView()
    } else if let collection = appModel.rootCollection {
      CollectionView(
        title: collection.title,
        handle: collection.handle,
        showsNavigationTitle: false
      )
      .id(collection.id)
    } else {
      HomeView()
    }
  }
}

@available(iOS 16.0, *)
private struct ModernRootNavigation<Content: View>: View {
  @ObservedObject var appModel: AppModel
  @State private var path = NavigationPath()
  private let content: Content

  init(
    appModel: AppModel,
    @ViewBuilder content: () -> Content
  ) {
    self.appModel = appModel
    self.content = content()
  }

  var body: some View {
    NavigationStack(path: $path) {
      content
        .navigationDestination(for: NativeRoute.self) { route in
          route.destination
        }
    }
    .onChange(of: appModel.navigationResetID) { _ in
      guard !path.isEmpty else { return }
      path.removeLast(path.count)
    }
    .onChange(of: appModel.presentedNativeProduct) { product in
      guard let product else { return }
      path.append(NativeRoute.product(product))
      appModel.presentedNativeProduct = nil
    }
    .onChange(of: appModel.shouldPresentNativeCart) { shouldPresent in
      guard shouldPresent else { return }
      path.append(NativeRoute.cart)
      appModel.shouldPresentNativeCart = false
    }
    .onChange(of: appModel.shouldPresentNativeBrands) { shouldPresent in
      guard shouldPresent else { return }
      if !path.isEmpty {
        path.removeLast(path.count)
      }
      path.append(NativeRoute.brands)
      appModel.shouldPresentNativeBrands = false
    }
  }
}

private struct LegacyRootNavigation<Content: View>: View {
  @ObservedObject var appModel: AppModel
  private let content: Content

  init(
    appModel: AppModel,
    @ViewBuilder content: () -> Content
  ) {
    self.appModel = appModel
    self.content = content()
  }

  var body: some View {
    NavigationView {
      content
        .navigationBarHidden(true)
        .background {
          VStack {
            NavigationLink(
              isActive: Binding(
                get: { appModel.presentedNativeProduct != nil },
                set: { isActive in
                  if !isActive {
                    appModel.presentedNativeProduct = nil
                  }
                }
              )
            ) {
              if let product = appModel.presentedNativeProduct {
                ProductDetailView(product: product)
              } else {
                EmptyView()
              }
            } label: {
              EmptyView()
            }

            NavigationLink(
              isActive: $appModel.shouldPresentNativeCart
            ) {
              CartView(mode: .full)
            } label: {
              EmptyView()
            }

            NavigationLink(
              isActive: $appModel.shouldPresentNativeBrands
            ) {
              BrandsView()
            } label: {
              EmptyView()
            }
          }
          .hidden()
        }
    }
    .navigationViewStyle(.stack)
    .id(appModel.navigationResetID)
  }
}
