import SwiftUI
import UIKit

struct PipelineRemoteImage<Content: View, Placeholder: View>: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  private let request: NativeImageRequest?
  private let accessibilityLabel: String?
  private let content: (Image) -> Content
  private let placeholder: () -> Placeholder

  @State private var preparedImage: PreparedNativeImage?
  @State private var preparedRequest: NativeImageRequest?

  init(
    request: NativeImageRequest?,
    accessibilityLabel: String? = nil,
    @ViewBuilder content: @escaping (Image) -> Content,
    @ViewBuilder placeholder: @escaping () -> Placeholder
  ) {
    self.request = request
    self.accessibilityLabel = accessibilityLabel
    self.content = content
    self.placeholder = placeholder
  }

  var body: some View {
    Group {
      if let preparedImage,
        preparedRequest == request
      {
        content(
          Image(
            uiImage: UIImage(
              cgImage: preparedImage.cgImage,
              scale: 1,
              orientation: .up
            )
          )
        )
        .transition(.opacity)
      } else {
        placeholder()
          .transition(.opacity)
      }
    }
    .animation(
      reduceMotion ? nil : ThemeTokens.imageReveal,
      value: preparedRequest
    )
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(accessibilityLabel ?? "")
    .accessibilityHidden(accessibilityLabel == nil)
    .task(id: request) {
      preparedImage = nil
      preparedRequest = nil

      guard let request else {
        return
      }

      do {
        let image = try await NativeImagePipeline.shared.image(
          for: request
        )
        try Task.checkCancellation()
        preparedImage = image
        preparedRequest = request
      } catch is CancellationError {
        return
      } catch {
        return
      }
    }
  }
}
