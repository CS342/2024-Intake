//
//  AllergyTests.swift
//  IntakeUITests
//
//  Created by Zoya Garg on 3/13/24.

// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT

import Foundation
import XCTest

class AllergyTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--disableFirebase", "--testPatient", "--testAllergy", "--skipToScrollable"]
        app.launch()
    }
    
    func testAllergy() throws {
        let app = XCUIApplication()
        
        sleep(8)
        
        XCTAssertEqual(app.state, .runningForeground)
        
        app.buttons["Create New Form"].tap()
        XCUIApplication().navigationBars["Allergies"].tap()
        app.buttons["Add_allergy"].tap()
        app.textFields["Allergy Name"].tap()
        app.textFields["Allergy Name"].typeText("Peanut")
        app.buttons["Save"].tap()
    }
}
