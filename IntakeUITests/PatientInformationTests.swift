//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


/// Test the following:
/// 1. If a patient is connected with healthkit, does the information in the PatientInfo view show up?
/// 2. If a patient is not connected with healthkit and fills in their information manually, does the information in the PatientInfo view show up?
/// 3. Does the data in each case persist to scrollableView?
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
        app.launchArguments = ["--skipOnboarding", "--testPatient", "--skipToScrollable"]
        app.launch()
        sleep(1)
        let startButton = app.buttons["Create New Form"]
        let isStartButtonExist = startButton.waitForExistence(timeout: 5)
        if isStartButtonExist {
            startButton.tap()
        }
        let next = app.buttons["Next"]
        next.tap()
        XCTAssertTrue(app.staticTexts["Gonzalo Alejandro Dueñas"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["1958-02-06"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["66"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Male"].waitForExistence(timeout: 5))
    }
    
    func testIfCustomDataInScrollable() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--skipToScrollable"]
        app.launch()
        sleep(1)
        let startButton = app.buttons["Create New Form"]
        let isStartButtonExist = startButton.waitForExistence(timeout: 5)
        if isStartButtonExist {
            startButton.tap()
        }
        let nameTextField = app.textFields["Full name"]
        let dobDatePicker = app.datePickers.firstMatch
        let sexPicker = app.buttons["Sex, Female"]
        let next = app.buttons["Next"]
        nameTextField.tap()
        nameTextField.typeText("John Doe")
        dobDatePicker.tap()
        sleep(1)
        dobDatePicker.tap()
        nameTextField.tap()
        sexPicker.tap()
        sleep(1)
        app.buttons["Male"].tap()
        next.tap()
        
        XCTAssertTrue(app.staticTexts["John Doe"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Male"].waitForExistence(timeout: 5))
    }
}
