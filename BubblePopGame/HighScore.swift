import Foundation

struct HighScore: Codable, Identifiable {
    let id: UUID
    let playerName: String
    let score: Int
    let date: Date
    
    init(playerName: String, score: Int) {
        self.id = UUID()
        self.playerName = playerName
        self.score = score
        self.date = Date()
    }
}

class HighScoreManager {
    static let shared = HighScoreManager()
    private let maxHighScores = 10
    private let userDefaultsKey = "highScores"
    
    private init() {}
    
    func getHighScores() -> [HighScore] {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let highScores = try? JSONDecoder().decode([HighScore].self, from: data) {
            return highScores.sorted { $0.score > $1.score }
        }
        return []
    }
    
    func addHighScore(_ highScore: HighScore) {
        var highScores = getHighScores()
        highScores.append(highScore)
        highScores.sort { $0.score > $1.score }
        
        // Keep only top scores
        if highScores.count > maxHighScores {
            highScores = Array(highScores.prefix(maxHighScores))
        }
        
        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func isHighScore(_ score: Int) -> Bool {
        let highScores = getHighScores()
        return highScores.count < maxHighScores || score > highScores.last?.score ?? 0
    }
} 