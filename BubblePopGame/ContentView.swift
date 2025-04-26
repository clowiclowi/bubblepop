//
//  ContentView.swift
//  BubblePopGame
//
//  Created by Chloe Wilson on 18/4/2025.
//

import SwiftUI

struct ContentView: View {
    @State var score = 0
    @State var timeRemaining = 60
    @State var bubbles: [Bubble] = []
    @State var isGameOver = false
    @State var consecutivePops = 0
    @State var playerName = ""
    @State var screenSize: CGSize = .zero
    @State var bubbleRadius: CGFloat = 20
    @State var settings = GameSettings.defaultSettings
    @State var showSettings = false
    @State var showHighScores = false
    @State var lastPopColor: String? = nil
    @State var gameTimer: Timer? = nil
    @State var movementTimer: Timer? = nil
    @State var showEnterNameScreen = false
    @State var isGameStarted = false

    let bubbleColors = ["red", "pink", "green", "blue", "black"]
    let bubbleProbabilities: [String: Double] = [
        "red": 0.4,
        "pink": 0.3,
        "green": 0.15,
        "blue": 0.1,
        "black": 0.05
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if !showEnterNameScreen {
                    // Welcome screen
                    VStack {
                        Spacer()
                        Text("Welcome to Bubble Pop!")
                            .font(.largeTitle)
                            .bold()
                            .padding()

                        Button(action: {
                            showEnterNameScreen = true
                        }) {
                            Text("Start")
                                .font(.title2)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        Spacer()
                    }
                } else if !isGameStarted {
                    // Enter name screen
                    PlayerNameView(isGameStarted: $isGameStarted, playerName: $playerName, onStartGame: startGame)
                } else {
                    // Game screen
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

                    HStack {
                        GameTimeView(timeRemaining: $timeRemaining)

                        Spacer()

                        VStack {
                            Text("Score: \(score)")
                                .font(.title)

                            if let highScore = HighScoreManager.shared.getHighScores().first {
                                Text("High Score: \(highScore.score)")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                    }

                    ZStack {
                        ForEach(bubbles) { bubble in
                            BubbleView(bubble: bubble) {
                                bubbleTapped(bubble)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                    .onAppear {
                        screenSize = geometry.size
                        print("Screen size set to: \(screenSize)")
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        screenSize = newSize
                        print("Screen size updated to: \(newSize)")
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
            .sheet(isPresented: $showSettings) {
                SettingsView(settings: $settings)
            }
            .sheet(isPresented: $showHighScores) {
                HighScoreView()
            }
        }
    }

    func startGame() {
        print("Starting game with screen size: \(screenSize)")
        score = 0
        isGameOver = false
        timeRemaining = settings.gameTime
        bubbles = []
        lastPopColor = nil

        generateInitialBubbles()

        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                refreshBubbles()
            } else {
                endGame()
            }
        }

        movementTimer?.invalidate()
        movementTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateBubblePositions()
        }
    }

    func generateInitialBubbles() {
        guard screenSize.width > 0, screenSize.height > 0 else { return }

        let bubbleCount = min(settings.maxBubbles, 10)
        var newBubbles: [Bubble] = []

        let columns = Int(screenSize.width / (bubbleRadius * 2.5))
        let rows = Int(screenSize.height / (bubbleRadius * 2.5))

        for _ in 0..<bubbleCount {
            let column = Int.random(in: 0..<columns)
            let row = Int.random(in: 0..<rows)

            let x = CGFloat(column) * (bubbleRadius * 2.5) + bubbleRadius
            let y = CGFloat(row) * (bubbleRadius * 2.5) + bubbleRadius

            let randomColor = getRandomBubbleColor()
            let points = getPoints(for: randomColor)

            let speed = 1.0 + (60.0 - Double(timeRemaining)) / 60.0
            let angle = Double.random(in: 0..<2 * .pi)
            let velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)

            newBubbles.append(Bubble(color: randomColor, points: points, position: CGPoint(x: x, y: y), velocity: velocity))
        }

        bubbles = newBubbles
    }

    func updateBubblePositions() {
        var updatedBubbles: [Bubble] = []

        for var bubble in bubbles {
            bubble.position.x += bubble.velocity.dx
            bubble.position.y += bubble.velocity.dy

            if bubble.position.x < bubbleRadius || bubble.position.x > screenSize.width - bubbleRadius {
                bubble.velocity.dx *= -1
            }
            if bubble.position.y < bubbleRadius || bubble.position.y > screenSize.height - bubbleRadius {
                bubble.velocity.dy *= -1
            }

            bubble.position.x = max(bubbleRadius, min(screenSize.width - bubbleRadius, bubble.position.x))
            bubble.position.y = max(bubbleRadius, min(screenSize.height - bubbleRadius, bubble.position.y))

            updatedBubbles.append(bubble)
        }

        bubbles = updatedBubbles
    }

    func refreshBubbles() {
        guard screenSize.width > 0, screenSize.height > 0 else { return }

        let bubblesToRemove = Int.random(in: 0...bubbles.count / 2)
        bubbles.removeLast(bubblesToRemove)

        let newBubbleCount = min(settings.maxBubbles - bubbles.count, 5)
        for _ in 0..<newBubbleCount {
            let randomColor = getRandomBubbleColor()
            let points = getPoints(for: randomColor)

            let x = CGFloat.random(in: bubbleRadius...(screenSize.width - bubbleRadius))
            let y = CGFloat.random(in: bubbleRadius...(screenSize.height - bubbleRadius))

            let speed = 1.0 + (60.0 - Double(timeRemaining)) / 60.0
            let angle = Double.random(in: 0..<2 * .pi)
            let velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)

            bubbles.append(Bubble(color: randomColor, points: points, position: CGPoint(x: x, y: y), velocity: velocity))
        }
    }

    func bubbleTapped(_ bubble: Bubble) {
        var points = bubble.points
        if let lastColor = lastPopColor, lastColor == bubble.color {
            points = Int(Double(points) * 1.5)
        }
        score += points
        lastPopColor = bubble.color

        if let index = bubbles.firstIndex(where: { $0.position == bubble.position }) {
            var poppedBubble = bubbles[index]
            poppedBubble.scale = 0.1
            poppedBubble.opacity = 0
            bubbles[index] = poppedBubble

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                bubbles.remove(at: index)
                generateNewBubble()
            }
        }
    }

    func generateNewBubble() {
        guard screenSize.width > 0, screenSize.height > 0 else { return }

        let randomColor = getRandomBubbleColor()
        let points = getPoints(for: randomColor)

        let x = CGFloat.random(in: bubbleRadius...(screenSize.width - bubbleRadius))
        let y = CGFloat.random(in: bubbleRadius...(screenSize.height - bubbleRadius))

        let speed = 1.0 + (60.0 - Double(timeRemaining)) / 60.0
        let angle = Double.random(in: 0..<2 * .pi)
        let velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)

        var newBubble = Bubble(color: randomColor, points: points, position: CGPoint(x: x, y: y), velocity: velocity)
        newBubble.scale = 0.1
        newBubble.opacity = 0
        bubbles.append(newBubble)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if let index = bubbles.firstIndex(where: { $0.position == newBubble.position }) {
                bubbles[index].scale = 1.0
                bubbles[index].opacity = 1.0
            }
        }
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

    func endGame() {
        gameTimer?.invalidate()
        movementTimer?.invalidate()

        if HighScoreManager.shared.isHighScore(score) {
            let highScore = HighScore(playerName: playerName, score: score)
            HighScoreManager.shared.addHighScore(highScore)
        }
        isGameOver = true
        showHighScores = true
    }
}

