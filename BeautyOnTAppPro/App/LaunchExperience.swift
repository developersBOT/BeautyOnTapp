import SwiftUI

enum LaunchExperienceContract {
  static let tagline = "BEAUTY THAT CARES"

  static let rotationDuration: TimeInterval = 3
  static let readinessHoldDuration: TimeInterval = 1.2
  static let fadeDuration: TimeInterval = 0.8
  static let characterDelay: TimeInterval = 0.09
  static let heartDelay: TimeInterval = 0.2
  static let heartFadeDuration: TimeInterval = 0.6

  static let initialRotationDegrees = -90.0
  static let finalRotationDegrees = 0.0
  static let initialScale: CGFloat = 1
  static let finalScale: CGFloat = 1.06

  static let rotationAnimation = Animation.spring(
    response: 0.78,
    dampingFraction: 0.88,
    blendDuration: 0.12
  )
  static let exitScaleAnimation = Animation.spring(
    response: 0.46,
    dampingFraction: 0.92,
    blendDuration: 0.08
  )
}

/// Process-scoped presentation gate. A new SwiftUI scene or a foreground
/// transition cannot replay the launch experience after the first claim.
@MainActor
final class LaunchExperienceProcessGate {
  static let shared = LaunchExperienceProcessGate()

  private var hasPresented = false

  func claimColdStart() -> Bool {
    guard !hasPresented else { return false }
    hasPresented = true
    return true
  }
}

/// The integration surface owned by the App. Call `markReady()` when the
/// native first screen has mounted and its bounded bootstrap work is complete.
/// Readiness can shorten only the 1.2-second hold after the three-second brand
/// animation; it never cuts the brand animation itself short.
@MainActor
final class LaunchExperienceController: ObservableObject {
  @Published private(set) var isPresented: Bool
  @Published private(set) var isReady = false
  @Published private(set) var rotationDegrees: Double
  @Published private(set) var visibleCharacterCount = 0
  @Published private(set) var heartOpacity = 0.0
  @Published private(set) var surfaceOpacity = 1.0
  @Published private(set) var surfaceScale = LaunchExperienceContract.initialScale

  private var hasStarted = false

  init(processGate: LaunchExperienceProcessGate = .shared) {
    let shouldPresent = processGate.claimColdStart()
    isPresented = shouldPresent
    rotationDegrees =
      shouldPresent
      ? LaunchExperienceContract.initialRotationDegrees
      : LaunchExperienceContract.finalRotationDegrees
  }

  func markReady() {
    isReady = true
  }

  func start(reduceMotion: Bool) async {
    guard isPresented, !hasStarted else { return }
    hasStarted = true

    let taglineTask: Task<Void, Never>?
    if reduceMotion {
      rotationDegrees = LaunchExperienceContract.finalRotationDegrees
      visibleCharacterCount = LaunchExperienceContract.tagline.count
      heartOpacity = 1
      taglineTask = nil
    } else {
      withAnimation(LaunchExperienceContract.rotationAnimation) {
        rotationDegrees = LaunchExperienceContract.finalRotationDegrees
      }
      taglineTask = Task { @MainActor [weak self] in
        await self?.animateTagline()
      }
    }

    guard await sleep(LaunchExperienceContract.rotationDuration) else {
      taglineTask?.cancel()
      return
    }
    guard await waitUntilReadyOrHoldExpires() else {
      taglineTask?.cancel()
      return
    }

    withAnimation(ThemeTokens.controlSpring) {
      surfaceOpacity = 0
    }
    if !reduceMotion {
      withAnimation(LaunchExperienceContract.exitScaleAnimation) {
        surfaceScale = LaunchExperienceContract.finalScale
      }
    }

    guard await sleep(LaunchExperienceContract.fadeDuration) else {
      taglineTask?.cancel()
      return
    }
    _ = await taglineTask?.result
    isPresented = false
  }

  private func animateTagline() async {
    for characterCount in 1...LaunchExperienceContract.tagline.count {
      guard await sleep(LaunchExperienceContract.characterDelay) else {
        return
      }
      visibleCharacterCount = characterCount
    }

    guard await sleep(LaunchExperienceContract.heartDelay) else { return }
    withAnimation(ThemeTokens.controlSpring) {
      heartOpacity = 1
    }
  }

  private func waitUntilReadyOrHoldExpires() async -> Bool {
    guard !isReady else { return true }

    let deadline = Date().addingTimeInterval(
      LaunchExperienceContract.readinessHoldDuration
    )
    while !isReady {
      let remaining = deadline.timeIntervalSinceNow
      guard remaining > 0 else { return true }
      guard await sleep(min(remaining, 0.025)) else { return false }
    }
    return true
  }

  private func sleep(_ duration: TimeInterval) async -> Bool {
    guard duration > 0 else { return !Task.isCancelled }
    do {
      try await Task<Never, Never>.sleep(
        nanoseconds: UInt64(duration * 1_000_000_000)
      )
      return !Task.isCancelled
    } catch {
      return false
    }
  }
}

/// Keeps the native app mounted from its first SwiftUI frame while an opaque
/// branded surface runs above it. The controller's process gate makes this a
/// cold-start-only experience; foregrounding the app does not recreate it.
struct LaunchExperience<Content: View>: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @ObservedObject private var controller: LaunchExperienceController

  private let content: Content

  init(
    controller: LaunchExperienceController,
    @ViewBuilder content: () -> Content
  ) {
    self.controller = controller
    self.content = content()
  }

  var body: some View {
    ZStack {
      content
        .accessibilityHidden(controller.isPresented)

      if controller.isPresented {
        LaunchExperienceSurface(controller: controller)
          .zIndex(1_000)
      }
    }
    .task {
      await controller.start(reduceMotion: reduceMotion)
    }
  }
}

private struct LaunchExperienceSurface: View {
  @ObservedObject var controller: LaunchExperienceController

  private var visibleTagline: String {
    String(
      LaunchExperienceContract.tagline.prefix(
        controller.visibleCharacterCount
      )
    )
  }

  var body: some View {
    GeometryReader { proxy in
      let logoWidth = proxy.size.width * 0.75
      let logoHeight = logoWidth * (175.0 / 310.0)

      ZStack {
        Color.black

        VStack(spacing: 0) {
          Image("LaunchLogo")
            .resizable()
            .scaledToFit()
            .frame(width: logoWidth, height: logoHeight)
            .rotationEffect(
              .degrees(controller.rotationDegrees)
            )

          HStack(spacing: 5) {
            Text(visibleTagline)
              .font(.system(size: 15, weight: .bold))
              .tracking(1)
              .foregroundStyle(.white)

            Image("LaunchHeart")
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 18)
              .opacity(controller.heartOpacity)
          }
          .frame(height: 18)
          .padding(.top, 25)
        }
        .scaleEffect(controller.surfaceScale)
      }
      .frame(width: proxy.size.width, height: proxy.size.height)
    }
    .ignoresSafeArea()
    .opacity(controller.surfaceOpacity)
    .background(Color.black)
    .contentShape(Rectangle())
    .preferredColorScheme(.dark)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("BeautyOnTApp. Beauty that cares.")
    .accessibilityIdentifier("launch-experience")
  }
}
