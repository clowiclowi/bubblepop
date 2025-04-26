import SwiftUI

struct HighScoreView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var highScores: [HighScore] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(highScores) { score in
                    HStack {
                        Text(score.playerName)
                            .font(.headline)
                        Spacer()
                        Text("\(score.score)")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("High Scores")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .onAppear {
                highScores = HighScoreManager.shared.getHighScores()
            }
        }
    }
}

#Preview {
    HighScoreView()
} 