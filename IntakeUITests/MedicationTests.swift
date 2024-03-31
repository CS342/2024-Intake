//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest

/// These tests checking if the current patient medications appear, adding a new medication, filling out its information, and seeing if it persists.
class MedicationTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--testPatient", "--testMedication", "--skipToScrollable"]
        app.launch()
    }
    
    func testMedications() throws {
        let app = XCUIApplication()
        
        // Small workaround to wait until the medications loaded into main memory
        sleep(10)
        
        XCTAssertEqual(app.state, .runningForeground)
        app.buttons["Create New Form"].tap()
        
        XCTAssertTrue(app.staticTexts["Hydrochlorothiazide 25 MG Oral Tablet"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["amLODIPine 2.5 MG Oral Tablet"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.navigationBars["Medication Settings"].buttons["Add New Medication"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.navigationBars["Medication Settings"].buttons["Chat"].waitForExistence(timeout: 2))
        app.navigationBars["Medication Settings"].buttons["Add New Medication"].tap()
        app.buttons["Verapamil Hydrochloride 40 MG"].tap()
        app.buttons["Save Dosage"].tap()
        app.buttons["Add Medication"].tap()
        XCTAssertTrue(app.staticTexts["Verapamil Hydrochloride 40 MG"].waitForExistence(timeout: 5))
        app.buttons["Save Medications"].tap()
    }
}
