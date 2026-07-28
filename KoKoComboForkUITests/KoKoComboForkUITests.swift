import XCTest

final class KoKoComboForkUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLargeInvitationFlow() {
        let app = XCUIApplication()
        app.launch()

        let largeInvitationScenario = app.buttons["scenario.3"]
        XCTAssertTrue(largeInvitationScenario.waitForExistence(timeout: 5))
        largeInvitationScenario.tap()

        let invitationCount = app.staticTexts["invitation.count"]
        XCTAssertTrue(invitationCount.waitForExistence(timeout: 10))
        XCTAssertEqual(invitationCount.label, "好友邀請，共 5 位")

        let toggle = app.buttons["invitation.toggle"]
        XCTAssertTrue(toggle.exists)
        XCTAssertEqual(toggle.value as? String, "已展開")

        toggle.tap()
        XCTAssertTrue(waitForValue("已收合", of: toggle))

        toggle.tap()
        XCTAssertTrue(waitForValue("已展開", of: toggle))

        let acceptFirstInvitation = app.buttons["invitation.accept.002"]
        XCTAssertTrue(acceptFirstInvitation.waitForExistence(timeout: 5))
        acceptFirstInvitation.tap()

        let countUpdated = NSPredicate(
            format: "label == %@",
            "好友邀請，共 4 位"
        )
        expectation(for: countUpdated, evaluatedWith: invitationCount)
        waitForExpectations(timeout: 5)
    }

    private func waitForValue(
        _ value: String,
        of element: XCUIElement
    ) -> Bool {
        let predicate = NSPredicate(format: "value == %@", value)
        let expectation = XCTNSPredicateExpectation(
            predicate: predicate,
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: 3) == .completed
    }
}
