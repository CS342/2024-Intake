//
//  NinasTests.swift
//  IntakeUITests
//
//  Created by Nina Boord on 3/12/24.
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
        // UI tests must launch the application that they test.
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

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testNavigationThroughApp() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
