//
//  ContentView.swift
//  muchi
//
//  Created by Manik Singh Sarmaal on 28/01/26.
//

import SwiftUI
import SwiftData

/// The main home screen of muchi - shown after onboarding is complete.
/// This is a placeholder that will be expanded to include the alarm functionality.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    // MARK: - Design Tokens
    private let backgroundColor = Color(red: 0.98, green: 0.98, blue: 0.98) // #FAFAFA
    private let textColor = Color(red: 0.17, green: 0.17, blue: 0.18) // #2C2C2E
    private let accentTeal = Color(red: 0.05, green: 0.65, blue: 0.91) // #0EA5E9
    private let accentTurquoise = Color(red: 0.18, green: 0.83, blue: 0.75) // #2DD4BF
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Welcome message with user's name
                Text(greeting)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(textColor)
                
                // Placeholder for future alarm UI
                VStack(spacing: 16) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [accentTeal.opacity(0.6), accentTurquoise.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Ready to set your first intention?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    Text("Coming soon...")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(textColor.opacity(0.4))

                }
                .padding(.top, 60)
                
                Spacer()
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Computed Properties
    
    /// Returns the user's name from SwiftData, or a fallback
    private var userName: String {
        users.first?.name ?? "Friend"
    }
    
    /// Returns a time-appropriate greeting with the user's name
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userName
        switch hour {
        case 5..<12:
            return "Good morning, \(name)"
        case 12..<17:
            return "Good afternoon, \(name)"
        case 17..<21:
            return "Good evening, \(name)"
        default:
            return "Hello, \(name)"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: User.self, inMemory: true)
}

#Preview {
    ContentView()
        .modelContainer(for: User.self, inMemory: true)
}