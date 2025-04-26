//
//  BubblePopGameTests.swift
//  BubblePopGameTests
//
//  Created by Chloe Wilson on 18/4/2025.
//

import XCTest
@testable import BubblePopGame

final class BubblePopGameTests: XCTestCase {
    var contentView: ContentView!
    
    override func setUp() {
        super.setUp()
        contentView = ContentView()
    }
    
    override func tearDown() {
        contentView = nil
        super.tearDown()
    }
    
    // Test bubble generation
    func testBubbleGeneration() {
        // Test initial bubble generation
        contentView.startGame()
        XCTAssertFalse(contentView.bubbles.isEmpty, "Bubbles should be generated when game starts")
        
        // Test bubble count is within valid range
        let initialCount = contentView.bubbles.count
        XCTAssertGreaterThanOrEqual(initialCount, 1, "Should generate at least one bubble")
        XCTAssertLessThanOrEqual(initialCount, contentView.settings.maxBubbles, "Should not exceed max bubbles")
    }
    
    // Test bubble popping and regeneration
    func testBubblePopping() {
        contentView.startGame()
        let initialCount = contentView.bubbles.count
        
        // Pop a bubble
        if let firstBubble = contentView.bubbles.first {
            contentView.bubbleTapped(firstBubble)
            
            // Check that a new bubble was generated
            XCTAssertEqual(contentView.bubbles.count, initialCount, "Bubble count should remain the same after popping")
            XCTAssertFalse(contentView.bubbles.contains { $0.position == firstBubble.position }, "Popped bubble should be removed")
        }
    }
    
    // Test scoring system
    func testScoring() {
        contentView.startGame()
        let initialScore = contentView.score
        
        // Test basic scoring
        if let firstBubble = contentView.bubbles.first {
            contentView.bubbleTapped(firstBubble)
            XCTAssertGreaterThan(contentView.score, initialScore, "Score should increase after popping bubble")
        }
        
        // Test consecutive pop bonus
        let scoreBeforeConsecutive = contentView.score
        if let secondBubble = contentView.bubbles.first {
            contentView.bubbleTapped(secondBubble)
            XCTAssertGreaterThan(contentView.score, scoreBeforeConsecutive, "Score should increase more with consecutive pops")
        }
    }
    
    // Test high score system
    func testHighScoreSystem() {
        let highScoreManager = HighScoreManager.shared
        
        // Test adding high score
        let testScore = HighScore(playerName: "TestPlayer", score: 100)
        highScoreManager.addHighScore(testScore)
        
        // Verify high score was added
        let highScores = highScoreManager.getHighScores()
        XCTAssertTrue(highScores.contains { $0.playerName == "TestPlayer" && $0.score == 100 }, "High score should be added")
        
        // Test high score limit
        for i in 1...15 {
            let score = HighScore(playerName: "Player\(i)", score: i * 10)
            highScoreManager.addHighScore(score)
        }
        
        let finalHighScores = highScoreManager.getHighScores()
        XCTAssertLessThanOrEqual(finalHighScores.count, 10, "Should maintain only top 10 high scores")
    }
    
    // Test game settings
    func testGameSettings() {
        let settings = GameSettings.defaultSettings
        
        // Test default values
        XCTAssertEqual(settings.gameTime, 60, "Default game time should be 60 seconds")
        XCTAssertEqual(settings.maxBubbles, 15, "Default max bubbles should be 15")
        
        // Test settings validation
        var customSettings = GameSettings(gameTime: 20, maxBubbles: 3)
        XCTAssertEqual(customSettings.gameTime, 30, "Game time should be clamped to minimum 30 seconds")
        XCTAssertEqual(customSettings.maxBubbles, 5, "Max bubbles should be clamped to minimum 5")
    }
    
    // Test bubble color probabilities
    func testBubbleColorProbabilities() {
        contentView.startGame()
        var colorCounts: [String: Int] = [:]
        
        // Generate many bubbles to test probability distribution
        for _ in 0..<1000 {
            let color = contentView.getRandomBubbleColor()
            colorCounts[color, default: 0] += 1
        }
        
        // Verify probabilities are roughly correct
        let total = Double(colorCounts.values.reduce(0, +))
        for (color, count) in colorCounts {
            let probability = Double(count) / total
            let expectedProbability = contentView.bubbleProbabilities[color] ?? 0
            XCTAssertEqual(probability, expectedProbability, accuracy: 0.1, "Probability for \(color) should be roughly \(expectedProbability)")
        }
    }
}
