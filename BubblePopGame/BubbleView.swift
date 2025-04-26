//
//  BubbleView.swift
//  BubblePopGame
//
//  Created by Chloe Wilson on 18/4/2025.
//

import SwiftUI


struct Bubble {
    var color: String
    var points: Int
    var position: CGPoint
}

struct BubbleView: View {
    var bubble: Bubble
    var onTap: () -> Void
    
    var body: some View {
        Circle()
            .fill(getColor(for: bubble.color))
            .frame(width: 40, height: 40)
            .position(bubble.position)
            .onTapGesture {
                onTap()
            }
            .shadow(radius: 2)
    }
    
    func getColor(for color: String) -> Color {
        switch color {
        case "red":
            return .red
        case "pink":
            return .pink
        case "green":
            return .green
        case "blue":
            return .blue
        case "black":
            return .black
        default:
            return .gray
        }
    }
}

#Preview {
    BubbleView(bubble: Bubble(color: "green", points: 5, position: CGPoint(x: 100, y: 100))) {
        print("Bubble tapped!")
    }
}
