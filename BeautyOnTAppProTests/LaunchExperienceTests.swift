import UIKit
import XCTest
@testable import BeautyOnTAppPro

@MainActor
final class LaunchExperienceTests: XCTestCase {
    func testTimingMatchesPreservedWebKitLaunchContract() {
        XCTAssertEqual(LaunchExperienceContract.tagline, "BEAUTY THAT CARES")
        XCTAssertEqual(LaunchExperienceContract.rotationDuration, 3, accuracy: 0.001)
        XCTAssertEqual(
            LaunchExperienceContract.readinessHoldDuration,
            1.2,
            accuracy: 0.001
        )
        XCTAssertEqual(LaunchExperienceContract.fadeDuration, 0.8, accuracy: 0.001)
        XCTAssertEqual(LaunchExperienceContract.characterDelay, 0.09, accuracy: 0.001)
        XCTAssertEqual(LaunchExperienceContract.heartDelay, 0.2, accuracy: 0.001)
        XCTAssertEqual(
            LaunchExperienceContract.heartFadeDuration,
            0.6,
            accuracy: 0.001
        )
        XCTAssertEqual(
            LaunchExperienceContract.rotationDuration
                + LaunchExperienceContract.fadeDuration,
            3.8,
            accuracy: 0.001
        )
        XCTAssertEqual(
            LaunchExperienceContract.rotationDuration
                + LaunchExperienceContract.readinessHoldDuration
                + LaunchExperienceContract.fadeDuration,
            5,
            accuracy: 0.001
        )
    }

    func testControllerStartsWithExactVisualState() {
        let controller = LaunchExperienceController(
            processGate: LaunchExperienceProcessGate()
        )

        XCTAssertTrue(controller.isPresented)
        XCTAssertFalse(controller.isReady)
        XCTAssertEqual(controller.rotationDegrees, -90, accuracy: 0.001)
        XCTAssertEqual(controller.visibleCharacterCount, 0)
        XCTAssertEqual(controller.heartOpacity, 0, accuracy: 0.001)
        XCTAssertEqual(controller.surfaceOpacity, 1, accuracy: 0.001)
        XCTAssertEqual(controller.surfaceScale, 1, accuracy: 0.001)
    }

    func testProcessGatePreventsReplayWithinOneProcess() {
        let processGate = LaunchExperienceProcessGate()
        let coldStart = LaunchExperienceController(processGate: processGate)
        let reconstructedRoot = LaunchExperienceController(processGate: processGate)

        XCTAssertTrue(coldStart.isPresented)
        XCTAssertFalse(reconstructedRoot.isPresented)
        XCTAssertEqual(reconstructedRoot.rotationDegrees, 0, accuracy: 0.001)
    }

    func testReadinessIsMonotonic() {
        let controller = LaunchExperienceController(
            processGate: LaunchExperienceProcessGate()
        )

        controller.markReady()
        controller.markReady()

        XCTAssertTrue(controller.isReady)
    }

    func testStaticLaunchUsesBlackBackgroundAndExactLogoAsset() throws {
        let launchScreen = try XCTUnwrap(
            Bundle.main.object(forInfoDictionaryKey: "UILaunchScreen")
                as? [String: Any]
        )

        XCTAssertEqual(launchScreen["UIColorName"] as? String, "LaunchBackground")
        XCTAssertEqual(launchScreen["UIImageName"] as? String, "LaunchLogo")
        XCTAssertEqual(
            launchScreen["UIImageRespectsSafeAreaInsets"] as? Bool,
            false
        )
        XCTAssertNotNil(UIImage(named: "LaunchLogo"))
        XCTAssertNotNil(UIImage(named: "LaunchHeart"))
    }
}
