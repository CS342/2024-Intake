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

// I test the following:
// 1. If a patient is connected with healthkit, does the information in the PatientInfo view show up?
//    and Does the data persist to scrollableView?
// 2. If a patient is not connected with healthkit and fills in their information manually, does the information in the PatientInfo view show up
//    and Does the data persist to scrollableView?
// 3. Does the navigation stack function up to medications? (the rest of the stack should be tested seperately)

import XCTest

final class NinasTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        let app = XCUIApplication()
        if app.buttons["Back"].exists {
            app.buttons["Back"].tap()
        }
        try super.tearDownWithError()
    }
    
    func testIfHealthKitDataInScrollable() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--disableFirebase", "--skipOnboarding", "--testPatient", "--skipToScrollable"]
        let startButton = app.buttons["Start"]
        let nextToScrollableView = app.buttons["Next"]
        startButton.tap()
        nextToScrollableView.tap()
        XCTAssertTrue(app.staticTexts["Gonzalo Alejandro Dueñas"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["1958-02-06"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["66"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Male"].waitForExistence(timeout: 5))
    }
    
    func testIfCustomDataInScrollable() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--disableFirebase", "--skipOnboarding", "--skipToScrollable"]
        app.launch()
        
        let startButton = app.buttons["Start"]
        let nameTextField = app.textFields["Full Name"]
        let dobDatePicker = app.datePickers["Date of Birth"]
        let sexPicker = app.datePickers["Sex"]
        let nextToScrollableView = app.buttons["Next"]
        
        startButton.tap()
        nameTextField.tap()
        nameTextField.typeText("John Doe")
        dobDatePicker.tap()
        dobDatePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "January")
        dobDatePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "1")
        dobDatePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "1980")
        sexPicker.tap()
        sexPicker.adjust(toPickerWheelValue: "Male")
        nextToScrollableView.tap()
        
        XCTAssertTrue(app.staticTexts["John Doe"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["1980-01-01"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["44"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Male"].waitForExistence(timeout: 5))
    }
}
