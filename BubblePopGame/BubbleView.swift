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
    var rotation: Double = 0.0
}

struct BubbleView: View {
    var bubble: Bubble
    var onTap: () -> Void
    @State private var isAnimating = false
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(getColor(for: bubble.color).opacity(0.3))
                .frame(width: 50, height: 50)
                .blur(radius: 5)
            
            // Main bubble
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            getColor(for: bubble.color),
                            getColor(for: bubble.color).opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 15, height: 15)
                        .offset(x: -8, y: -8)
                )
                .shadow(color: getColor(for: bubble.color).opacity(0.5), radius: 5, x: 0, y: 0)
            
            // Points text
            Text("\(bubble.points)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .scaleEffect(bubble.scale)
        .opacity(bubble.opacity)
        .rotationEffect(.degrees(bubble.rotation))
        .position(bubble.position)
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                    onTap()
                }
            }
        }
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
