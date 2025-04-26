
//settingsView.swift

import SwiftUI

struct GameSettings {
    var gameTime: Int
    var maxBubbles: Int
    
    static let defaultSettings = GameSettings(gameTime: 60, maxBubbles: 15)
}

struct SettingsView: View {
    @Binding var settings: GameSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Settings")) {
                    Stepper("Game Time: \(settings.gameTime) seconds", value: $settings.gameTime, in: 30...120, step: 5)
                        .onChange(of: settings.gameTime) {
                            if settings.gameTime < 30 {
                                settings.gameTime = 30
                            } else if settings.gameTime > 120 {
                                settings.gameTime = 120
                            }
                        }
                    
                    Stepper("Max Bubbles: \(settings.maxBubbles)", value: $settings.maxBubbles, in: 5...30, step: 1)
                        .onChange(of: settings.maxBubbles) {
                            if settings.maxBubbles < 5 {
                                settings.maxBubbles = 5
                            } else if settings.maxBubbles > 30 {
                                settings.maxBubbles = 30
                            }
                        }
                }
                
                Section(header: Text("About")) {
                    Text("Game Time: Set how long each game lasts (30-120 seconds)")
                    Text("Max Bubbles: Set the maximum number of bubbles on screen (5-30)")
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

#Preview {
    SettingsView(settings: .constant(GameSettings.defaultSettings))
}

