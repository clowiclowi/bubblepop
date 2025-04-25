//
//  PlayerNameView.swift
//  BubblePopGame
//
//  Created by Chloe Wilson on 18/4/2025.
//

import SwiftUI

struct PlayerNameView: View {
    @Binding var isGameStarted: Bool
    @Binding var playerName: String // Correctly bind the player name to the parent view
    
    var body: some View {
        VStack {
            Text("Enter Your Name")
                .font(.largeTitle)
                .padding()

            TextField("Your Name", text: $playerName) // Binding to playerName
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            Button(action: {
                if !playerName.isEmpty {
                    isGameStarted = true // Start the game if name is entered
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
    PlayerNameView(isGameStarted: .constant(false), playerName: .constant("")) // Mock bindings for preview
}
