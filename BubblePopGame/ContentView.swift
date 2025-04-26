//
// ContentView.swift
// ContentView.swift

import SwiftUI

struct ContentView: View {
    @State var score = 0
    @State var timeRemaining = 60
    @State var bubbles: [Bubble] = []
    @State var isGameOver = false
    @State var consecutivePops = 0
    @State var playerName = ""  // Store the player name
    @State var screenSize: CGSize = .zero
    @State var bubbleRadius: CGFloat = 20 // Half of bubble width/height
    @State var settings = GameSettings.defaultSettings
    @State var showSettings = false
    @State var showHighScores = false

    let bubbleColors = ["red", "pink", "green", "blue", "black"]
    let bubbleProbabilities: [String: Double] = [
        "red": 0.4,
        "pink": 0.3,
        "green": 0.15,
        "blue": 0.1,
        "black": 0.05
    ]
    
    @State var isGameStarted = false

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
                            showHighScores = true
                        }) {
                            Image(systemName: "trophy")
                                .font(.title)
                                .padding()
                        }
                        
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
                    .onChange(of: geometry.size) { _, newSize in
                        screenSize = newSize
                    }

                    
                    if isGameOver {
                        VStack {
                            Text("Game Over!")
                                .font(.largeTitle)
                                .padding()
                            
                            Text("Your final score: \(score)")
                                .font(.title)
                                .padding()
                            
                            if HighScoreManager.shared.isHighScore(score) {
                                Text("New High Score! 🎉")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                    .padding()
                            }
                            
                            Button(action: {
                                isGameOver = false
                                startGame()
                            }) {
                                Text("Play Again")
                                    .font(.title2)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .onAppear {
                if isGameStarted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        startGame()
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(settings: $settings)
            }
            .sheet(isPresented: $showHighScores) {
                HighScoreView()
            }
        }
    }
    
    struct ScoreView: View {
        @Binding var score: Int

        var body: some View {
            Text("Score: \(score)")
                .font(.title)
                .padding()
        }
    }

    func startGame() {
        print("Starting game with screen size: \(screenSize)")
        score = 0
        isGameOver = false
        timeRemaining = settings.gameTime
        bubbles = []
        
        // Generate initial bubbles immediately
        generateBubbles()
        print("Initial bubbles generated: \(bubbles.count)")
        
        // Timer only for game time, not bubble generation
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }
    
    func generateBubbles() {
        let randomCount = Int.random(in: 1...settings.maxBubbles)
        var newBubbles: [Bubble] = []
        
        // Keep existing bubbles
        newBubbles.append(contentsOf: bubbles)
        
        // Generate new bubbles until we reach the desired count
        while newBubbles.count < randomCount {
            let randomColor = getRandomBubbleColor()
            let points = getPoints(for: randomColor)
            
            if let position = findValidPosition(for: newBubbles) {
                newBubbles.append(Bubble(color: randomColor, points: points, position: position))
            } else {
                print("Failed to find valid position for new bubble")
            }
        }
        
        bubbles = newBubbles
    }
    
    func findValidPosition(for existingBubbles: [Bubble]) -> CGPoint? {
        let maxAttempts = 50
        var attempts = 0
        
        guard screenSize.width > 0, screenSize.height > 0 else {
            print("Invalid screen size: \(screenSize)")
            return nil
        }
        
        while attempts < maxAttempts {
            let x = CGFloat.random(in: bubbleRadius...(screenSize.width - bubbleRadius))
            let y = CGFloat.random(in: bubbleRadius...(screenSize.height - bubbleRadius))
            
            guard !x.isNaN && !y.isNaN else {
                attempts += 1
                continue
            }
            
            let newPosition = CGPoint(x: x, y: y)
            
            let isOverlapping = existingBubbles.contains { existingBubble in
                let distance = sqrt(
                    pow(existingBubble.position.x - newPosition.x, 2) +
                    pow(existingBubble.position.y - newPosition.y, 2)
                )
                return distance < bubbleRadius * 2
            }
            
            if !isOverlapping {
                return newPosition
            }
            
            attempts += 1
        }
        
        return nil
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
        
        return "red"
    }
    
    func getPoints(for color: String) -> Int {
        switch color {
        case "red": return 1
        case "pink": return 2
        case "green": return 5
        case "blue": return 8
        case "black": return 10
        default: return 0
        }
    }
    
    func bubbleTapped(_ bubble: Bubble) {
        score += bubble.points
        
        if consecutivePops > 0 {
            score += Int(Double(bubble.points) * 1.5) - bubble.points
        }
        
        consecutivePops += 1
        
        // Remove the popped bubble
        bubbles.removeAll { $0.position == bubble.position }
        
        // Immediately generate a new bubble to replace it
        generateBubbles()
    }
    
    func endGame() {
        if HighScoreManager.shared.isHighScore(score) {
            let highScore = HighScore(playerName: playerName, score: score)
            HighScoreManager.shared.addHighScore(highScore)
        }
        isGameOver = true
    }
}

