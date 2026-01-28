//
//  AgeInputView.swift
//  muchi
//
//  Created by Manik Singh Sarmaal on 28/01/26.
//

import SwiftUI

/// The second step of onboarding - asks the user for their age.
/// Personalizes the greeting using the name from the previous step.
struct AgeInputView: View {
    let name: String
    @Binding var age: Int
    var onComplete: () -> Void
    
    // MARK: - Design Tokens
    private let backgroundColor = Color(red: 0.98, green: 0.98, blue: 0.98) // #FAFAFA
    private let textColor = Color(red: 0.17, green: 0.17, blue: 0.18) // #2C2C2E
    private let accentTeal = Color(red: 0.05, green: 0.65, blue: 0.91) // #0EA5E9
    private let accentTurquoise = Color(red: 0.18, green: 0.83, blue: 0.75) // #2DD4BF
    private let accentDeepBlue = Color(red: 0.01, green: 0.52, blue: 0.78) // #0284C7
    
    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main content
                VStack(spacing: 40) {
                    // Personalized greeting
                    VStack(spacing: 12) {
                        Text("Muchi is excited to meet you! 😄")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(textColor.opacity(0.6))
                        
                        Text("How old are you \(name)?")
                            .font(.system(size: 32, weight: .semibold, design: .default))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Age picker wheel
                    Picker("Age", selection: $age) {
                        ForEach(13...100, id: \.self) { ageValue in
                            Text("\(ageValue)")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(textColor)
                                .tag(ageValue)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .frame(maxWidth: 120)
                    .clipped()
                }
                
                Spacer()
                
                // Complete button
                Button(action: {
                    // Haptic feedback - slightly stronger for completion
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onComplete()
                }) {
                    HStack(spacing: 8) {
                        Text("Cheers to better mornings")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Image(systemName: "sunrise.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.yellow)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [accentTeal, accentTurquoise, accentDeepBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    AgeInputView(name: "Manik", age: .constant(25)) {
        print("Onboarding complete")
    }
}
