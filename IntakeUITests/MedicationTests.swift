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
        //app.buttons["Start"].tap()
        app.buttons["Next"].tap()
        //XCTEstAssert( app.navigationBars["Medical History"].staticTexts["Medical History"]
                
    }
    
}
