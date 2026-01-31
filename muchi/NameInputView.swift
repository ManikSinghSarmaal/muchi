//
//  NameInputView.swift
//  muchi
//
//  Created by Manik Singh Sarmaal on 28/01/26.
//

import SwiftUI

// // MARK: - Josefin Sans Font Extension
// extension Font {
//     /// Josefin Sans - Light weight
//     static func josefinSansLight(size: CGFloat) -> Font {
//         .custom("JosefinSans-Light", size: size, relativeTo: .body)
//     }
    
//     /// Josefin Sans - Regular weight
//     static func josefinSansRegular(size: CGFloat) -> Font {
//         .custom("JosefinSans-Regular", size: size, relativeTo: .body)
//     }
    
//     /// Josefin Sans - Medium weight
//     static func josefinSansMedium(size: CGFloat) -> Font {
//         .custom("JosefinSans-Medium", size: size, relativeTo: .body)
//     }
    
//     /// Josefin Sans - SemiBold weight
//     static func josefinSansSemiBold(size: CGFloat) -> Font {
//         .custom("JosefinSans-SemiBold", size: size, relativeTo: .body)
//     }
    
//     /// Josefin Sans - Bold weight
//     static func josefinSansBold(size: CGFloat) -> Font {
//         .custom("JosefinSans-Bold", size: size, relativeTo: .body)
//     }
// }

/// The first step of onboarding - asks the user for their name.
struct NameInputView: View {
    @Binding var name: String
    var onContinue: () -> Void
    
    @FocusState private var isNameFieldFocused: Bool
    
    // MARK: - Design Tokens
    private let backgroundColor = Color(red: 0.98, green: 0.98, blue: 0.98) // #FAFAFA
    private let textColor = Color(red: 0.17, green: 0.17, blue: 0.18) // #2C2C2E
    private let accentTeal = Color(red: 0.05, green: 0.65, blue: 0.91) // #0EA5E9
    private let accentTurquoise = Color(red: 0.18, green: 0.83, blue: 0.75) // #2DD4BF
    
    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main content
                VStack(spacing: 40) {
                    // Greeting text
                    VStack(spacing: 12) {
                        Text("Hey there 👋")
                            .font(.josefinSansMedium(size: 17))
                            .foregroundColor(textColor.opacity(0.6))
                            .tracking(1)
                        
                        Text("What do I call you?")
                            .font(.josefinSansSemiBold(size: 32))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Name input field with underline
                    VStack(spacing: 8) {
                        TextField("Your name", text: $name)
                            .font(.josefinSansRegular(size: 24))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .focused($isNameFieldFocused)
                        
                        // Animated underline
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [accentTeal, accentTurquoise],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 2)
                            .frame(maxWidth: 200)
                            .scaleEffect(x: isNameFieldFocused || !name.isEmpty ? 1 : 0.3, anchor: .center)
                            .opacity(isNameFieldFocused || !name.isEmpty ? 1 : 0.3)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isNameFieldFocused)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: name.isEmpty)
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
                    // Haptic feedback for delight
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    onContinue()
                }) {
                    Text("Continue")
                        .font(.josefinSansSemiBold(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: canContinue ? [accentTeal, accentTurquoise] : [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .disabled(!canContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .animation(.easeInOut(duration: 0.2), value: canContinue)
            }
        }
        .onAppear {
            // Auto-focus the text field after a brief delay for smooth transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFieldFocused = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// User can continue only if they've entered a non-empty name
    // add a feature whcich does semething like if the user sets name as empty, add something like in the next page, oh so you dont want to introduce yourself, makes sense, feel free to contiue forward
    // and also add a back button to let user go back to the previous page and re-enter the name if done by mistake or incorrectly
    private var canContinue: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    NameInputView(name: .constant("")) {
        print("Continue tapped")
    }
}
