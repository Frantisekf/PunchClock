//
//  PunchClockUITests.swift
//  PunchClockUITests
//
//  Created by Frantisek Farkas on 07.01.2026.
//

import XCTest

final class PunchClockUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Main Screen Tests

    @MainActor
    func testAppLaunches() throws {
        XCTAssertTrue(app.navigationBars["Round Timer"].exists)
    }

    @MainActor
    func testPresetsListExists() throws {
        // Check that preset list is visible
        XCTAssertTrue(app.staticTexts["Boxing Standard"].exists)
    }

    @MainActor
    func testDefaultPresetsVisible() throws {
        XCTAssertTrue(app.staticTexts["Boxing Standard"].exists)
        XCTAssertTrue(app.staticTexts["MMA Style"].exists)
        XCTAssertTrue(app.staticTexts["Muay Thai"].exists)
        XCTAssertTrue(app.staticTexts["BJJ Rolling"].exists)
        XCTAssertTrue(app.staticTexts["Quick Training"].exists)
    }

    @MainActor
    func testAddButtonExists() throws {
        XCTAssertTrue(app.navigationBars.buttons["Add"].exists || app.buttons["plus"].exists)
    }

    // MARK: - Preset Selection Tests

    @MainActor
    func testTapPresetOpensSetup() throws {
        app.staticTexts["Boxing Standard"].tap()

        // Should show the preset setup sheet
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
    }

    @MainActor
    func testPresetSetupHasStartButton() throws {
        app.staticTexts["Boxing Standard"].tap()

        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
    }

    @MainActor
    func testPresetSetupCanBeCancelled() throws {
        app.staticTexts["Boxing Standard"].tap()

        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2))

        cancelButton.tap()

        // Should be back to main screen
        XCTAssertTrue(app.staticTexts["Boxing Standard"].waitForExistence(timeout: 2))
    }

    // MARK: - Timer Tests

    @MainActor
    func testStartTimer() throws {
        app.staticTexts["Boxing Standard"].tap()

        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        startButton.tap()

        // Timer should be running - look for phase indicator
        let getReadyText = app.staticTexts["Get Ready"]
        XCTAssertTrue(getReadyText.waitForExistence(timeout: 2))
    }

    @MainActor
    func testTimerHasPauseButton() throws {
        app.staticTexts["Boxing Standard"].tap()

        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        startButton.tap()

        // Should have pause button
        let pauseButton = app.buttons["Pause"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 2))
    }

    @MainActor
    func testTimerHasStopButton() throws {
        app.staticTexts["Boxing Standard"].tap()

        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        startButton.tap()

        // Should have stop button
        let stopButton = app.buttons["Stop"]
        XCTAssertTrue(stopButton.waitForExistence(timeout: 2))
    }

    // MARK: - Performance Tests

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
