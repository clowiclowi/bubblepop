//
//  BubblePopGameUITests.swift
//  BubblePopGameUITests
//
//  Created by Chloe Wilson on 18/4/2025.
//

import XCTest

final class BubblePopGameUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    func testInitialScreen() throws {
        // Verify player name input screen is shown
        XCTAssertTrue(app.textFields["Your Name"].exists, "Player name text field should be visible")
        XCTAssertTrue(app.buttons["Start Game"].exists, "Start Game button should be visible")
        XCTAssertFalse(app.buttons["Start Game"].isEnabled, "Start Game button should be disabled initially")
    }
    
    func testGameStart() throws {
        // Enter player name and start game
        let nameTextField = app.textFields["Your Name"]
        nameTextField.tap()
        nameTextField.typeText("TestPlayer")
        
        let startButton = app.buttons["Start Game"]
        XCTAssertTrue(startButton.isEnabled, "Start Game button should be enabled after entering name")
        startButton.tap()
        
        // Verify game elements are visible
        XCTAssertTrue(app.staticTexts["Welcome, TestPlayer!"].exists, "Welcome message should be visible")
        XCTAssertTrue(app.staticTexts["Time remaining"].exists, "Time remaining should be visible")
        XCTAssertTrue(app.staticTexts["Score: 0"].exists, "Score should be visible")
    }
    
    func testBubbleInteraction() throws {
        // Start game
        let nameTextField = app.textFields["Your Name"]
        nameTextField.tap()
        nameTextField.typeText("TestPlayer")
        app.buttons["Start Game"].tap()
        
        // Wait for bubbles to appear
        let bubble = app.circles.firstMatch
        XCTAssertTrue(bubble.waitForExistence(timeout: 5), "Bubbles should appear within 5 seconds")
        
        // Tap a bubble
        bubble.tap()
        
        // Verify score increased
        let scoreText = app.staticTexts["Score: 0"]
        XCTAssertFalse(scoreText.exists, "Score should have increased after popping bubble")
    }
    
    func testSettings() throws {
        // Start game
        let nameTextField = app.textFields["Your Name"]
        nameTextField.tap()
        nameTextField.typeText("TestPlayer")
        app.buttons["Start Game"].tap()
        
        // Open settings
        app.buttons["gear"].tap()
        
        // Verify settings screen
        XCTAssertTrue(app.navigationBars["Settings"].exists, "Settings screen should be visible")
        XCTAssertTrue(app.staticTexts["Game Time"].exists, "Game time setting should be visible")
        XCTAssertTrue(app.staticTexts["Max Bubbles"].exists, "Max bubbles setting should be visible")
    }
    
    func testHighScores() throws {
        // Start game
        let nameTextField = app.textFields["Your Name"]
        nameTextField.tap()
        nameTextField.typeText("TestPlayer")
        app.buttons["Start Game"].tap()
        
        // Open high scores
        app.buttons["trophy"].tap()
        
        // Verify high scores screen
        XCTAssertTrue(app.navigationBars["High Scores"].exists, "High scores screen should be visible")
    }
    
    func testGameOver() throws {
        // Start game
        let nameTextField = app.textFields["Your Name"]
        nameTextField.tap()
        nameTextField.typeText("TestPlayer")
        app.buttons["Start Game"].tap()
        
        // Wait for game to end (60 seconds)
        let gameOverText = app.staticTexts["Game Over!"]
        XCTAssertTrue(gameOverText.waitForExistence(timeout: 65), "Game over screen should appear after 60 seconds")
        
        // Verify game over screen
        XCTAssertTrue(app.staticTexts["Your final score"].exists, "Final score should be visible")
        XCTAssertTrue(app.buttons["Play Again"].exists, "Play Again button should be visible")
    }
}
