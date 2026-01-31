//
//  OnboardingView.swift
//  muchi
//
//  Created by Manik Singh Sarmaal on 28/01/26.
//

import SwiftUI
import SwiftData

/// The container view that manages the stepped onboarding flow.
/// Handles navigation between name and age input screens with smooth animations.
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    @State private var currentStep: OnboardingStep = .name
    @State private var userName: String = ""
    @State private var userAge: Int = 25  // Default to a reasonable age
    
    /// Callback when onboarding is complete
    var onComplete: () -> Void
    
    // MARK: - Onboarding Steps
    enum OnboardingStep {
        case name
        case age
    }
    
    var body: some View {
        ZStack {
            // Name input screen
            if currentStep == .name {
                NameInputView(name: $userName) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        currentStep = .age
                    }
                }
                .transition(.opacity)
            }
            
            // Age input screen
            if currentStep == .age {
                AgeInputView(name: userName, age: $userAge, onComplete: {
                    saveUserAndComplete()
                }, onBack: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        currentStep = .name
                    }
                })
                .transition(.opacity)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Saves the user to SwiftData and marks onboarding as complete
    private func saveUserAndComplete() {
        // Create and save the user
        let user = User(
            name: userName.trimmingCharacters(in: .whitespacesAndNewlines),
            age: userAge
        )
        modelContext.insert(user)
        
        // Mark onboarding as complete in AppStorage
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Notify completion
        onComplete()
    }
}

#Preview {
    OnboardingView {
        print("Onboarding completed!")
    }
    .modelContainer(for: User.self, inMemory: true)
}
