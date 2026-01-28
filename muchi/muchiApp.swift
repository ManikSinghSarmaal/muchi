//
//  muchiApp.swift
//  muchi
//
//  Created by Manik Singh Sarmaal on 28/01/26.
//

import SwiftUI
import SwiftData

@main
struct muchiApp: App {
    /// Tracks whether the user has completed onboarding
    /// Using AppStorage for instant access at launch (no async needed)
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    /// The shared SwiftData model container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // MARK: - Debug: Reset onboarding for testing (remove this line in production)
        // Comment the line below once you've tested the onboarding flow:
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView {
                    // Animate the transition to the main app
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Previews

/// A preview container that simulates the full app flow
private struct AppPreviewContainer: View {
    @State private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            ContentView()
        } else {
            OnboardingView {
                withAnimation(.easeInOut(duration: 0.3)) {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

#Preview("Full App Flow") {
    AppPreviewContainer()
        .modelContainer(for: User.self, inMemory: true)
}

#Preview("Home Screen Only") {
    ContentView()
        .modelContainer(for: User.self, inMemory: true)
}
