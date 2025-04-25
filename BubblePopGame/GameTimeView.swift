//  GameTimeView.swift
//  BubblePopGame
//
//  Created by Chloe Wilson on 18/4/2025.
//

import SwiftUI

struct GameTimeView: View {
    @Binding var timeRemaining: Int
    @State private var timer: Timer? = nil
    
    var body: some View {
        Text("Time remaining = \(timeRemaining) seconds ")
            .font(.title)
            .padding()
            .onAppear {
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()   
            }
        }
    }
}

#Preview {
    GameTimeView(timeRemaining: .constant(60))
}
