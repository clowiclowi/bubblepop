//
//  PlayerNameView.swift
//  BubblePopGame
//
//  Created by Chloe Wilson on 18/4/2025.
//

import SwiftUI

struct PlayerNameView: View {
    @Binding var isGameStarted: Bool
    @Binding var playerName: String
    var onStartGame: () -> Void // <-- Add this

    var body: some View {
        VStack {
            Text("Enter Your Name")
                .font(.largeTitle)
                .padding()

            TextField("Your Name", text: $playerName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never) // updated SwiftUI for autocapitalization
                .disableAutocorrection(true)
            
            Button(action: {
                if !playerName.isEmpty {
                    isGameStarted = true
                    onStartGame() // <-- Call startGame here
                }
            }) {
                Text("Start Game")
                    .padding()
                    .background(playerName.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(playerName.isEmpty)
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    PlayerNameView(isGameStarted: .constant(false), playerName: .constant(""), onStartGame: {})
}

