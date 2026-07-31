import XCTest

/// `waitForNonExistence(timeout:)` isn't available in every XCTest toolchain
/// this project gets built with, so poll manually instead.
extension XCUIElement {
    func pollUntilGone(timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if !exists { return true }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.1))
        }
        return !exists
    }
}
