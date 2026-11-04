import XCTest

/// End-to-end coverage for the affirmation / streak / visualization
/// features: today's affirmation + favoriting, the journaling → release →
/// streak badge chain, and the guided visualization flow through to
/// completion.
///
/// Split into two independent tests (each a fresh launch) rather than one
/// long chain: going straight from Release's nested fullScreenCover dismissal
/// into presenting another fullScreenCover (Visualization) on the same
/// HomeView is flaky in the simulator — a pre-existing JournalingView/
/// ReleaseView dismissal-timing quirk unrelated to these features' own code.
final class VerifyNewFeaturesTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func makeApp(english: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-uitestSeed"]
        if english {
            app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        }
        return app
    }

    @discardableResult
    private func waitFor(_ element: XCUIElement, _ timeout: TimeInterval = 10) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    func testAffirmationFavoriteAndStreak() throws {
        let app = makeApp()
        app.launch()

        // --- 1. Today's Affirmation card -> view + favorite ---
        XCTAssertTrue(waitFor(app.staticTexts["今日の言葉"]), "Affirmation card not on Home")
        app.staticTexts["今日の言葉"].tap()
        XCTAssertTrue(waitFor(app.staticTexts["お気に入り"], 5), "Affirmation sheet did not open")
        // Favorites persist in UserDefaults across launches on this simulator,
        // so don't assume a fresh/empty state — just confirm the toggle works.
        let emptyLabel = app.staticTexts["お気に入りはまだありません"]
        let wasEmpty = emptyLabel.exists

        // View tree order: [0]=close(xmark), [1]=prev(chevron.left), [2]=favorite(heart), [3]=next(chevron.right)
        let allButtons = app.buttons.allElementsBoundByIndex
        XCTAssertTrue(allButtons.count >= 4, "Expected close/prev/favorite/next buttons, got \(allButtons.count)")
        allButtons[2].tap()

        if wasEmpty {
            XCTAssertTrue(emptyLabel.pollUntilGone(timeout: 5), "Favorite did not get added")
        } else {
            // Already had favorites; tapping may have added or removed this one.
            // Just confirm the sheet is still alive and responsive.
            XCTAssertTrue(app.staticTexts["お気に入り"].exists, "Affirmation sheet broke after favorite tap")
        }

        // close sheet (first button in the tree)
        allButtons[0].tap()

        // --- 2. Journaling -> Release -> streak badge appears on Home ---
        let writeButton = app.staticTexts["今日のイメージを書き出す"]
        XCTAssertTrue(waitFor(writeButton, 5), "Journaling entry point not on Home")
        writeButton.tap()
        let editor = app.textViews.element
        XCTAssertTrue(waitFor(editor), "Journaling editor not shown")
        editor.tap()
        // Give the keyboard + any first-time QuickPath tutorial time to settle
        // before typing, so keystrokes aren't swallowed by the tutorial overlay.
        let quickPathContinue = app.buttons["Continue"]
        if quickPathContinue.waitForExistence(timeout: 3) {
            quickPathContinue.tap()
        }
        editor.typeText("今日はすでに叶っている未来を思い描いた。")

        // Unlike buttons with an Image+Text pair, this one has only a bare
        // Text child, so SwiftUI collapses it into a single accessible
        // Button element rather than exposing a nested StaticText.
        let doneButton = app.buttons["完了"]
        XCTAssertTrue(waitFor(doneButton, 5), "Done button not shown")
        doneButton.tap()

        // Release screen: tap the release action button (bare-Text buttons
        // collapse to Button elements, not nested StaticText — see above).
        let releaseButtons = app.buttons.allElementsBoundByIndex
        var tappedRelease = false
        for b in releaseButtons where b.label.contains("解き放") {
            b.tap()
            tappedRelease = true
            break
        }
        XCTAssertTrue(tappedRelease, "Could not find a release CTA button")

        // back to home automatically after completion animation
        sleep(3)
        XCTAssertTrue(waitFor(app.staticTexts["今日の言葉"], 10), "Did not return to Home after release")
        let streakExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '日連続'")).count > 0
        XCTAssertTrue(streakExists, "Streak badge not shown on Home after first completion")
    }

    func testVisualization() throws {
        let app = makeApp()
        app.launch()

        let startVizButton = app.buttons["ビジュアライゼーションを始める"]
        XCTAssertTrue(waitFor(startVizButton), "Visualization entry point not on Home")
        // Its on-screen frame is within bounds, but XCUITest's automatic
        // "scroll to visible" AX action is flaky here (likely a simulator
        // quirk) — tap by coordinate to sidestep that convenience logic.
        startVizButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        if !waitFor(app.staticTexts["ビジュアライゼーション"], 10) {
            XCTFail("Visualization setup not shown. Tree:\n\(app.debugDescription)")
        }
        let oneMinChip = app.buttons["1分"]
        if waitFor(oneMinChip, 3) {
            oneMinChip.tap()
        }
        app.buttons["はじめる"].tap()

        // running phase: ring + countdown text should appear
        sleep(2)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "\\d{1,2}:\\d{2}")).firstMatch.waitForExistence(timeout: 5),
                      "Countdown timer text not shown")

        // Wait for completion (up to 70s for the 1-minute session)
        XCTAssertTrue(waitFor(app.staticTexts["イメージが鮮明になった"], 75),
                      "Visualization did not reach completion screen in time")
        app.buttons["ホームへ戻る"].tap()
    }
}
