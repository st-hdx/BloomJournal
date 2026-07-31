import XCTest

/// Japanese counterpart to ScreenshotTests: drives the app through each key
/// screen with the simulator forced to Japanese and captures App Store
/// screenshots as XCTAttachments. Run in the Release configuration.
final class ScreenshotTestsJA: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Helpers

    private func makeApp(_ extraArgs: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += extraArgs
        app.launchArguments += ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
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

    private func settle(_ seconds: TimeInterval = 0.8) {
        Thread.sleep(forTimeInterval: seconds)
    }

    // MARK: - 01 Welcome (Onboarding, empty state)

    func testOnboarding() throws {
        let app = makeApp(["-uitestEmpty"])
        app.launch()

        XCTAssertTrue(waitFor(app.staticTexts["Bloom Journal へようこそ"]),
                      "Onboarding welcome screen not shown")
        settle()
        snap("01_welcome_ja")
    }

    // MARK: - 02-08 Main flow (seeded data)

    func testMainFlow() throws {
        let app = makeApp(["-uitestSeed"])
        app.launch()

        // 02 Home
        XCTAssertTrue(waitFor(app.staticTexts["理想のマイホーム"]), "Home not shown")
        settle()
        snap("02_home_ja")

        // 03 Settings (partial-height sheet over Home)
        app.buttons["nav.settings"].tap()
        XCTAssertTrue(waitFor(app.staticTexts["リマインダー設定"]), "Settings sheet not shown")
        settle()
        snap("03_settings_ja")
        dismissSettings(app)
        settle(0.6)

        // 04 Paywall (4 seeded visions >= free limit, Pro off -> paywall)
        app.buttons["nav.addVision"].tap()
        XCTAssertTrue(waitFor(app.buttons["購入を復元する"]), "Paywall not shown")
        settle(1.5)
        snap("04_paywall_ja")
        app.buttons["paywall.close"].tap()
        XCTAssertTrue(app.buttons["paywall.close"].pollUntilGone(timeout: 5),
                      "Paywall did not dismiss")

        // 05 Vision detail
        app.staticTexts["理想のマイホーム"].tap()
        XCTAssertTrue(waitFor(app.buttons["子供部屋が2つある間取り"]),
                      "Vision detail not shown")
        settle()
        snap("05_vision_detail_ja")
        app.navigationBars.buttons.element(boundBy: 0).tap()   // back to Home
        XCTAssertTrue(waitFor(app.buttons["今日のイメージを書き出す"]), "Did not return to Home")

        // 06 Journaling
        app.buttons["今日のイメージを書き出す"].tap()
        let editor = app.textViews.element
        XCTAssertTrue(waitFor(editor), "Journaling editor not shown")
        editor.tap()
        editor.typeText("今日はもう理想のマイホームが目に浮かぶ。子供部屋が2つある明るいリビングと、みんなで囲む大きなテーブル。")
        let quickPathContinue = app.buttons["Continue"]
        if quickPathContinue.waitForExistence(timeout: 3) {
            quickPathContinue.tap()
        }
        settle(1.0)
        snap("06_journaling_ja")

        // 07 Release — choose vision
        app.buttons["完了"].tap()
        XCTAssertTrue(waitFor(app.staticTexts["追記したいビジョンを選んでください"]),
                      "Release (select vision) not shown")
        settle()
        snap("07_release_ja")

        // 08 Release — complete (fades in after ~1.4s of animation)
        app.buttons["意識から解き放つ"].tap()
        XCTAssertTrue(waitFor(app.staticTexts["ビジョンが現実に近づいている"], 12),
                      "Release completion not shown")
        settle()
        snap("08_release_complete_ja")
    }

    // MARK: - Sheet dismissal

    private func dismissSettings(_ app: XCUIApplication) {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.06)).tap()
        if app.staticTexts["リマインダー設定"].pollUntilGone(timeout: 3) { return }

        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.62))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.98))
        start.press(forDuration: 0.15, thenDragTo: end)
        _ = app.staticTexts["リマインダー設定"].pollUntilGone(timeout: 3)
    }
}
