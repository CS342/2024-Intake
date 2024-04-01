//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest


/// Due to the nature of how conditions are added, this was difficult to test since there are an arbitrary number of rows due to LLM filtering. Therefore, this just checks the existence of the buttons.
class ConditionTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--testPatient", "--testCondition", "--skipToScrollable"]
        app.launch()
    }
    
    func testConditions() throws {
        let app = XCUIApplication()
        
        // Small workaround to wait until the medications loaded into main memory
        sleep(10)
        
        XCTAssertEqual(app.state, .runningForeground)
        app.buttons["Create New Form"].tap()
        
        sleep(5)
        
        XCTAssertTrue(app.navigationBars["Medical History"].buttons["Chat with LLM Assistant"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.navigationBars["Medical History"].buttons["add_condition"].waitForExistence(timeout: 2))
        app.navigationBars["Medical History"].buttons["add_condition"].tap()
    }
}
