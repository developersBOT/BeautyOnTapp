import SwiftUI

struct SignInBar: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
      VStack(alignment: .leading, spacing: 4.3) {
        Text("Sign In for Exclusive Deals 🖤")
          .themeScaledFont(size: 14, weight: .bold)
          .foregroundStyle(ThemeTokens.ink)
          .fixedSize(horizontal: false, vertical: true)

        Button {
          appModel.openProfileCreateAccount()
        } label: {
          (
            Text("Don’t have an account? ")
              .foregroundColor(ThemeTokens.ink)
              + Text("Create an account")
              .foregroundColor(ThemeTokens.link)
          )
          .themeScaledFont(size: 13)
          .lineSpacing(3.3)
          .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Create an account")
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Button {
        appModel.openProfileSignIn()
      } label: {
        Text("Sign In")
          .themeScaledFont(size: 14, weight: .semibold)
          .foregroundStyle(ThemeTokens.primaryButtonForeground)
          .frame(minWidth: 96, minHeight: 44)
          .background(ThemeTokens.primaryButton, in: Capsule())
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Sign In")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .background(ThemeTokens.canvas)
    }
}
