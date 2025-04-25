// ContentView.swift



import SwiftUI

struct ContentView: View {
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var bubbles: [Bubble] = []
    @State private var isGameOver = false
    @State private var consecutivePops = 0
    @State private var playerName = ""  // Store the player name

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
        VStack {
            if !isGameStarted {
                PlayerNameView(isGameStarted: $isGameStarted, playerName: $playerName)
            } else {
                Text("Welcome, \(playerName)!")
                    .font(.title)
                    .padding()
                
                GameTimeView()

                ScoreView(score: $score)
                
                ForEach(bubbles, id: \.position) { bubble in
                    BubbleView(bubble: bubble) {
                        bubbleTapped(bubble)
                    }
                }
                
                if isGameOver {
                    let highScore = UserDefaults.standard.integer(forKey: "highScore") // Get high score from UserDefaults
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
        timeRemaining = 60
        
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
        let randomCount = Int.random(in: 1...15)
        var newBubbles: [Bubble] = []
        
        for _ in 0..<randomCount {
            let randomColor = getRandomBubbleColor()
            let points = getPoints(for: randomColor)
            let randomPosition = CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
            
            newBubbles.append(Bubble(color: randomColor, points: points, position: randomPosition))
        }
        
        bubbles = newBubbles
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

