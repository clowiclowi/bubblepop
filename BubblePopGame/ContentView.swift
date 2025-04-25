// ContentView.swift



import SwiftUI

struct ContentView: View {
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var bubbles: [Bubble] = []
    @State private var isGameOver = false
    @State private var consecutivePops = 0
    @State private var playerName = ""  // Store the player name
    @State private var screenSize: CGSize = .zero
    @State private var bubbleRadius: CGFloat = 20 // Half of bubble width/height
    @State private var settings = GameSettings.defaultSettings
    @State private var showSettings = false

    let bubbleColors = ["red", "pink", "green", "blue", "black"]
    let bubbleProbabilities: [String: Double] = [
        "red": 0.4,
        "pink": 0.3,
        "green": 0.15,
        "blue": 0.1,
        "black": 0.05
    ]
    
    @State private var isGameStarted = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if !isGameStarted {
                    PlayerNameView(isGameStarted: $isGameStarted, playerName: $playerName)
                } else {
                    HStack {
                        Text("Welcome, \(playerName)!")
                            .font(.title)
                            .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gear")
                                .font(.title)
                                .padding()
                        }
                    }
                    
                    GameTimeView(timeRemaining: $timeRemaining)
                    
                    ScoreView(score: $score)
                    
                    ZStack {
                        ForEach(bubbles, id: \.position) { bubble in
                            BubbleView(bubble: bubble) {
                                bubbleTapped(bubble)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        screenSize = geometry.size
                    }
                    
                    if isGameOver {
                        let highScore = UserDefaults.standard.integer(forKey: "highScore")
                        Text("Game Over! Your final score is \(score)\nHigh Score: \(highScore)")
                            .font(.headline)
                            .padding()
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .onAppear {
                if isGameStarted {
                    startGame()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(settings: $settings)
            }
        }
    }
    
    struct ScoreView: View {
        @Binding var score: Int  // Bind the score to the parent view

        var body: some View {
            Text("Score: \(score)")
                .font(.title)
                .padding()
        }
    }

    func startGame() {
        score = 0
        isGameOver = false
        timeRemaining = settings.gameTime
        
        // Generate bubbles every second
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                generateBubbles()
            } else {
                endGame() // End the game when time runs out
            }
        }
    }
    
    func generateBubbles() {
        let randomCount = Int.random(in: 1...settings.maxBubbles)
        var newBubbles: [Bubble] = []
        
        // Keep some existing bubbles
        let bubblesToKeep = Int.random(in: 0...bubbles.count)
        if bubblesToKeep > 0 {
            newBubbles.append(contentsOf: bubbles.prefix(bubblesToKeep))
        }
        
        // Generate new bubbles
        while newBubbles.count < randomCount {
            let randomColor = getRandomBubbleColor()
            let points = getPoints(for: randomColor)
            
            // Try to find a valid position for the new bubble
            if let position = findValidPosition(for: newBubbles) {
                newBubbles.append(Bubble(color: randomColor, points: points, position: position))
            }
        }
        
        bubbles = newBubbles
    }
    
    func findValidPosition(for existingBubbles: [Bubble]) -> CGPoint? {
        let maxAttempts = 50 // Prevent infinite loops
        var attempts = 0
        
        while attempts < maxAttempts {
            // Generate random position within safe bounds
            let x = CGFloat.random(in: bubbleRadius...(screenSize.width - bubbleRadius))
            let y = CGFloat.random(in: bubbleRadius...(screenSize.height - bubbleRadius))
            let newPosition = CGPoint(x: x, y: y)
            
            // Check if this position overlaps with any existing bubble
            let isOverlapping = existingBubbles.contains { existingBubble in
                let distance = sqrt(
                    pow(existingBubble.position.x - newPosition.x, 2) +
                    pow(existingBubble.position.y - newPosition.y, 2)
                )
                return distance < bubbleRadius * 2 // Minimum distance between bubble centers
            }
            
            if !isOverlapping {
                return newPosition
            }
            
            attempts += 1
        }
        
        return nil // Could not find valid position after max attempts
    }
    
    func getRandomBubbleColor() -> String {
        let randomValue = Double.random(in: 0...1)
        var cumulativeProbability = 0.0
        
        for (color, probability) in bubbleProbabilities {
            cumulativeProbability += probability
            if randomValue <= cumulativeProbability {
                return color
            }
        }
        
        return "red" // Default color in case something goes wrong
    }
    
    func getPoints(for color: String) -> Int {
        switch color {
        case "red":
            return 1
        case "pink":
            return 2
        case "green":
            return 5
        case "blue":
            return 8
        case "black":
            return 10
        default:
            return 0
        }
    }
    
    func bubbleTapped(_ bubble: Bubble) {
        score += bubble.points
        
        // Handle consecutive taps for combo points
        if consecutivePops > 0 {
            score += Int(Double(bubble.points) * 1.5) - bubble.points
        }
        
        consecutivePops += 1
        
        // Remove tapped bubble
        bubbles.removeAll { $0.position == bubble.position }
    }
    
    func endGame() {
        // Save high score if it's higher than the current one
        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "highScore") // Save the new high score
        }
        isGameOver = true
    }
}

