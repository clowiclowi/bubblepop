//
//  BubbleView.swift
//  BubblePopGame
//
//  Created by Chloe Wilson on 18/4/2025.
//

import SwiftUI

struct Bubble: Identifiable { 
    var id = UUID()
    var color: String
    var points: Int
    var position: CGPoint
    var velocity: CGVector
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0
}

struct BubbleView: View {
    var bubble: Bubble
    var onTap: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(getColor(for: bubble.color))
            .frame(width: 40, height: 40)
            .position(bubble.position)
            .scaleEffect(bubble.scale)
            .opacity(bubble.opacity)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = true
                    onTap()
                }
            }
            .shadow(radius: 2)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
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
    BubbleView(bubble: Bubble(color: "green", points: 5, position: CGPoint(x: 100, y: 100), velocity: CGVector(dx: 1, dy: 1))) {
        print("Bubble tapped!")
    }
}
