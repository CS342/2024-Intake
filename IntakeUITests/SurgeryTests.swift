//
//  SurgeryTests.swift
//  IntakeUITests
//
//  Created by Kate Callon on 3/14/24.
//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest

// This tests adding a new surgery, filling out its information, and seeing if it persists. 
class SurgeryTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--disableFirebase", "--testPatient", "--testSurgery", "--skipToScrollable"]
        app.launch()
    }
    
    func testSurgery() throws {
        let app = XCUIApplication()
        
        // Small workaround to wait until the madications loaded into main memory
        sleep(10)
        
        XCTAssertEqual(app.state, .runningForeground)
        app.buttons["Create New Form"].tap()
        
        sleep(5)
        
        XCTAssertTrue(app.navigationBars["Surgical History"].buttons["Chat"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.navigationBars["Surgical History"].buttons["ADD_SURGERY"].waitForExistence(timeout: 2))
        app.navigationBars["Surgical History"].buttons["ADD_SURGERY"].tap()
        app.textFields["SURGERY_NAME"].tap()
        app.textFields["SURGERY_NAME"].typeText("\u{8}\u{8}\u{8}\u{8}\u{8}\u{8}\u{8}")
        app.textFields["SURGERY_NAME"].typeText("Knee Surgery")
        app.textFields["SURGERY_DATE"].tap()
        app.textFields["SURGERY_DATE"].typeText("2001/08/04")
        app.textFields["SURGERY_STATUS"].tap()
        app.textFields["SURGERY_STATUS"].typeText("COMPLETED")
        app.navigationBars["New Surgery"].buttons["Surgical History"].tap()
        XCTAssertTrue(app.staticTexts["Knee Surgery"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        sleep(3)
        XCTAssertTrue(app.navigationBars["Patient Form"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Knee Surgery"].waitForExistence(timeout: 2))
    }
}
