//
//  MedicationTests.swift
//  IntakeUITests
//
//  Created by Kate Callon on 3/12/24.
//

import Foundation
import XCTest

class MedicationTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--testPatient", "--testMedication"]
        app.launch()
    }
    
    
    func testMedications() throws {
        let app = XCUIApplication()
        XCTAssertEqual(app.state, .runningForeground)
        app.buttons["Start"].tap()
        
        XCTAssertTrue(app.staticTexts["amLODIPine 2.5 MG Oral Tablet"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Hydrochlorothiazide 25 MG Oral Tablet"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Medication Settings"].buttons["Add New Medication"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.navigationBars["Medication Settings"].buttons["Chat"].waitForExistence(timeout: 2))
        app.navigationBars["Medication Settings"].buttons["Add New Medication"].tap()
        app.buttons["Verapamil Hydrochloride 40 MG"].tap()
        app.buttons["Save Dosage"].tap()
        app.buttons["Add Medication"].tap()
        XCTAssertTrue(app.staticTexts["Verapamil Hydrochloride 40 MG"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Allergies"].waitForExistence(timeout: 2))
    }
}
