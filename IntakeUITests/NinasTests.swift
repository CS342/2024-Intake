//
//  NinasTests.swift
//  IntakeUITests
//
//  Created by Nina Boord on 3/12/24.
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
//

import XCTest

final class NinasTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.a
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        let app = XCUIApplication()
        if app.buttons["Back"].exists {
            app.buttons["Back"].tap()
        }
        
        // delete any data created as part of the test
        try super.tearDownWithError()
    }
    func testPatientInformation() throws {
        // Goes through UI of PatientInfo
        let app = XCUIApplication()
        app.launch()
        
        let startButton = app.buttons["START"]
        let nameTextField = app.textFields["FULL NAME"]
        let dobDatePicker = app.datePickers["DATE OF BIRTH"]
        let sexPicker = app.datePickers["SEX"]
        let nextOnPatientInfoView = app.buttons["NEXT TO MEDICAL HISTORY"]
        
        startButton.tap()
        nameTextField.tap()
        nameTextField.typeText("John Doe")
        dobDatePicker.tap()
        dobDatePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "January")
        dobDatePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "1")
        dobDatePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "1980")
        sexPicker.tap()
        sexPicker.adjust(toPickerWheelValue: "Male")
        nextOnPatientInfoView.tap()
    }
    
    func testNavigationThroughApp() throws {
        let app = XCUIApplication()
        app.launch()
        
        let startButton = app.buttons["START"]
        let nextOnPatientInfoView = app.buttons["NEXT TO MEDICAL HISTORY"]
        let nextOnMedicalHistoryView = app.buttons["NEXT TO SURGICAL HISTORY"]
        let nextOnSurgicalHistoryView = app.buttons["NEXT TO MEDICATIONS"]
        
        startButton.tap()
        XCTAssertTrue(nextOnPatientInfoView.exists, "Not on the expected view.")
        nextOnPatientInfoView.tap()
        XCTAssertTrue(nextOnMedicalHistoryView.exists, "Not on the expected view.")
        nextOnMedicalHistoryView.tap()
        XCTAssertTrue(nextOnSurgicalHistoryView.exists, "Not on the expected view.")
        nextOnSurgicalHistoryView.tap()
        // Other views are tested seperately
    }
}
