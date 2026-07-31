import XCTest

/// Drives the app through each key screen in English and captures App Store
/// screenshots as XCTAttachments. Run on iPhone 17 Pro Max in the Release
/// configuration (hides the DEBUG-only Pro toggle on Home).
///
/// Extract the PNGs afterwards with:
///   xcrun xcresulttool export attachments --path <result>.xcresult --output-path <dir>
/// then map manifest.json's suggestedHumanReadableName -> exportedFileName.
final class ScreenshotTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Helpers

    private func makeApp(_ extraArgs: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += extraArgs
        // Force English regardless of the simulator's locale.
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        return app
    }

    private func snap(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @discardableResult
    private func waitFor(_ element: XCUIElement, _ timeout: TimeInterval = 8) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    /// Let a transition / entrance animation settle before capturing.
    private func settle(_ seconds: TimeInterval = 0.8) {
        Thread.sleep(forTimeInterval: seconds)
    }

    // MARK: - 01 Welcome (Onboarding, empty state)

    func testOnboarding() throws {
        let app = makeApp(["-uitestEmpty"])
        app.launch()

        XCTAssertTrue(waitFor(app.staticTexts["Welcome to Bloom Journal"]),
                      "Onboarding welcome screen not shown")
        settle()
        snap("01_welcome_en")
    }

    // MARK: - 02-08 Main flow (seeded data)

    func testMainFlow() throws {
        let app = makeApp(["-uitestSeed"])
        app.launch()

        // 02 Home
        XCTAssertTrue(waitFor(app.staticTexts["Buy my dream home"]), "Home not shown")
        settle()
        snap("02_home_en")

        // 03 Settings (partial-height sheet over Home)
        app.buttons["nav.settings"].tap()
        XCTAssertTrue(waitFor(app.staticTexts["Reminder Settings"]), "Settings sheet not shown")
        settle()
        snap("03_settings_en")
        dismissSettings(app)

        // 04 Paywall (4 seeded visions >= free limit, Pro off -> paywall)
        app.buttons["nav.addVision"].tap()
        XCTAssertTrue(waitFor(app.buttons["Restore Purchases"]), "Paywall not shown")
        settle()
        snap("04_paywall_en")
        app.buttons["paywall.close"].tap()
        XCTAssertTrue(app.buttons["paywall.close"].pollUntilGone(timeout: 5),
                      "Paywall did not dismiss")

        // 05 Vision detail (v1 has a detail -> detail list, not empty state).
        // The detail row is a SwiftUI Button-in-List, so its text is exposed as
        // a Button label, not a StaticText.
        app.staticTexts["Buy my dream home"].tap()
        XCTAssertTrue(waitFor(app.buttons["Big kitchen for hosting friends"]),
                      "Vision detail not shown")
        settle()
        snap("05_vision_detail_en")
        app.navigationBars.buttons.element(boundBy: 0).tap()   // back to Home
        XCTAssertTrue(waitFor(app.buttons["Write today's vision"]), "Did not return to Home")

        // 06 Journaling
        app.buttons["Write today's vision"].tap()
        let editor = app.textViews.element
        XCTAssertTrue(waitFor(editor), "Journaling editor not shown")
        editor.tap()
        editor.typeText("Today I can already picture my dream home — the big kitchen full of friends, laughter, and the smell of coffee in the morning.")
        // iOS shows a one-time QuickPath ("slide to type") tutorial the first
        // time a keyboard appears; it covers the lower half and hides the real
        // keyboard. Dismiss it if present so the shot shows a clean keyboard.
        // It only appears once per simulator install, so tolerate its absence.
        let quickPathContinue = app.buttons["Continue"]
        if quickPathContinue.waitForExistence(timeout: 3) {
            quickPathContinue.tap()
        }
        settle(1.0)
        snap("06_journaling_en")

        // 07 Release — choose vision
        app.buttons["Done"].tap()
        XCTAssertTrue(waitFor(app.staticTexts["Choose which vision to add this to"]),
                      "Release (select vision) not shown")
        settle()
        snap("07_release_en")

        // 08 Release — complete (fades in after ~1.4s of animation)
        app.buttons["Release it from your mind"].tap()
        XCTAssertTrue(waitFor(app.staticTexts["Your vision is getting closer to reality"], 12),
                      "Release completion not shown")
        settle()
        snap("08_release_complete_en")
    }

    // MARK: - Sheet dismissal

    /// The Settings view is a partial-height detent sheet with no close button.
    /// Tapping the dimmed backdrop above it dismisses it; fall back to dragging
    /// the sheet down by its grabber if the tap doesn't take.
    private func dismissSettings(_ app: XCUIApplication) {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.06)).tap()
        if app.staticTexts["Reminder Settings"].pollUntilGone(timeout: 3) { return }

        // Fallback: drag downward starting from the top of the sheet.
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.62))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.98))
        start.press(forDuration: 0.15, thenDragTo: end)
        _ = app.staticTexts["Reminder Settings"].pollUntilGone(timeout: 3)
    }
}
