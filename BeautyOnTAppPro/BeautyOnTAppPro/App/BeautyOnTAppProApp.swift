import SwiftUI

@main
struct BeautyOnTAppProApp: App {
    @StateObject private var appModel = AppModel()
    @StateObject private var launchExperience = LaunchExperienceController()

    var body: some Scene {
        WindowGroup {
            LaunchExperience(controller: launchExperience) {
                RootView(appModel: appModel)
                    .tint(ThemeTokens.ink)
                    .background {
                        if appModel.isWishlistBridgeActivated {
                            HiddenWishlistWebView(
                                bridge: appModel.wishlistBridge
                            )
                            .frame(width: 1, height: 1)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                        }
                    }
            }
            .onAppear {
                if appModel.isBootstrapComplete {
                    launchExperience.markReady()
                }
            }
            .onChange(of: appModel.isBootstrapComplete) { isReady in
                if isReady {
                    launchExperience.markReady()
                }
            }
        }
    }
}
