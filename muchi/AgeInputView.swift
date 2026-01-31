//
//  AgeInputView.swift
//  muchi
//
//  Created by Manik Singh Sarmaal on 28/01/26.
//

import SwiftUI

// MARK: - Josefin Sans Font Extension
extension Font {
    /// Josefin Sans - Light weight
    static func josefinSansLight(size: CGFloat) -> Font {
        .custom("JosefinSans-Light", size: size, relativeTo: .body)
    }
    
    /// Josefin Sans - Regular weight
    static func josefinSansRegular(size: CGFloat) -> Font {
        .custom("JosefinSans-Regular", size: size, relativeTo: .body)
    }
    
    /// Josefin Sans - Medium weight
    static func josefinSansMedium(size: CGFloat) -> Font {
        .custom("JosefinSans-Medium", size: size, relativeTo: .body)
    }
    
    /// Josefin Sans - SemiBold weight
    static func josefinSansSemiBold(size: CGFloat) -> Font {
        .custom("JosefinSans-SemiBold", size: size, relativeTo: .body)
    }
    
    /// Josefin Sans - Bold weight
    static func josefinSansBold(size: CGFloat) -> Font {
        .custom("JosefinSans-Bold", size: size, relativeTo: .body)
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Triangle Shape (for Owl ears)
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Bird View (Day Scene)
struct BirdView: View {
    let startPoint: CGPoint
    let delay: Double
    @State private var flyAnimation = false
    
    var body: some View {
        Image(systemName: "bird.fill")
            .font(.system(size: 14))
            .foregroundColor(.black.opacity(0.6))
            .position(x: flyAnimation ? startPoint.x + 30 : startPoint.x - 30,
                      y: flyAnimation ? startPoint.y - 10 : startPoint.y + 10)
            .opacity(flyAnimation ? 0.8 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true).delay(delay)) {
                    flyAnimation = true
                }
            }
    }
}

// MARK: - Cloud View (Night Scene)
struct CloudView: View {
    let offsetX: CGFloat
    let offsetY: CGFloat
    let scale: CGFloat
    let delay: Double
    @State private var moveAnimation = false
    
    var body: some View {
        Image(systemName: "cloud.fill")
            .font(.system(size: 50))
            .foregroundColor(.white.opacity(0.3))
            .scaleEffect(scale)
            .offset(x: offsetX + (moveAnimation ? 10 : -10), y: offsetY)
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true).delay(delay)) {
                    moveAnimation = true
                }
            }
    }
}

// MARK: - Owl Silhouette (Night Scene)
struct OwlSilhouette: View {
    var body: some View {
        ZStack {
            // Body
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(red: 0.2, green: 0.2, blue: 0.3))
                .frame(width: 30, height: 50)
            
            // Ears
            HStack(spacing: 18) {
                Triangle()
                    .fill(Color(red: 0.2, green: 0.2, blue: 0.3))
                    .frame(width: 10, height: 10)
                Triangle()
                    .fill(Color(red: 0.2, green: 0.2, blue: 0.3))
                    .frame(width: 10, height: 10)
            }
            .offset(y: -25)
            
            // Eyes (Minimalist glowing dots)
            HStack(spacing: 6) {
                Circle().fill(Color.yellow.opacity(0.8)).frame(width: 6, height: 6)
                Circle().fill(Color.yellow.opacity(0.8)).frame(width: 6, height: 6)
            }
            .offset(y: -10)
        }
    }
}

// MARK: - Zen Horizon Scene
/// A beautiful animated scene that shows sun (day) or moon with owl (night)
/// rising from behind the greeting text, creating a peaceful zen moment.
struct ZenHorizonScene: View {
    @State private var appearAnimation = false
    @State private var floatingAnimation = false
    
    /// Determines if it's nighttime (7 PM - 6 AM)
    var isNightTime: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 19 || hour < 6
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isNightTime {
                // --- Night Scene ---
                
                // Clouds drifting
                CloudView(offsetX: -60, offsetY: -80, scale: 0.8, delay: 0.5)
                CloudView(offsetX: 70, offsetY: -50, scale: 0.6, delay: 1.2)
                
                // Moon & Owl Group
                ZStack(alignment: .top) {
                    // The Moon
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 100, height: 100)
                        .shadow(color: .white.opacity(0.4), radius: 20, x: 0, y: 0)
                    
                    // The Owl perched on top
                    OwlSilhouette()
                        .offset(y: -24)
                        .scaleEffect(0.28)
                }
                .offset(y: appearAnimation ? -20 : 100)
                .opacity(appearAnimation ? 1 : 0)
                
            } else {
                // --- Day Scene ---
                
                // Birds flying
                BirdView(startPoint: CGPoint(x: 50, y: 20), delay: 0.8)
                BirdView(startPoint: CGPoint(x: 280, y: 10), delay: 1.5)
                BirdView(startPoint: CGPoint(x: 160, y: 0), delay: 2.2)
                
                // The Sun with rotating rays
                ZStack {
                    // Rays
                    ForEach(0..<12, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.orange.opacity(0.4))
                            .frame(width: 4, height: 18)
                            .offset(y: -65)
                            .rotationEffect(.degrees(Double(i) * 30))
                    }
                    .rotationEffect(.degrees(floatingAnimation ? 10 : -10))
                    
                    // Sun Body
                    Circle()
                        .fill(Color.orange.opacity(0.8))
                        .frame(width: 90, height: 90)
                        .overlay(
                            Circle()
                                .stroke(Color.orange.opacity(0.3), lineWidth: 30)
                                .blur(radius: 8)
                        )
                }
                .offset(y: appearAnimation ? -20 : 100)
                .opacity(appearAnimation ? 1 : 0)
            }
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .mask(
            // Mask so sun/moon rises FROM behind the horizon line
            Rectangle()
                .frame(height: 160)
                .offset(y: -10)
        )
        .onAppear {
            // Delayed start for smooth entrance when transitioning from NameInputView
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Rising animation
                withAnimation(.spring(response: 1.0, dampingFraction: 0.75, blendDuration: 0)) {
                    appearAnimation = true
                }
                
                // Continuous floating/rotation animation
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    floatingAnimation = true
                }
            }
        }
    }
}

// MARK: - Age Input View
/// The second step of onboarding - asks the user for their age.
/// Features a zen horizon scene with sun/moon animation above the greeting.
/// Handles empty name scenario with a special message and skip option.
struct AgeInputView: View {
    let name: String
    @Binding var age: Int
    var onComplete: () -> Void
    var onBack: () -> Void
    
    // MARK: - Animation State
    @State private var contentAppeared = false
    
    // MARK: - Computed Properties
    private var isNameEmpty: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isNightTime: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 19 || hour < 6
    }
    
    // MARK: - Design Tokens
    private var backgroundColor: LinearGradient {
        isNightTime
        ? LinearGradient(
            colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")],
            startPoint: .top,
            endPoint: .bottom
        )
        : LinearGradient(
            colors: [Color(hex: "FFF3E0"), Color(hex: "FAFAFA")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var textColor: Color {
        isNightTime ? .white.opacity(0.9) : Color(red: 0.17, green: 0.17, blue: 0.18)
    }
    
    private var subtitleColor: Color {
        isNightTime ? .white.opacity(0.6) : Color(red: 0.17, green: 0.17, blue: 0.18).opacity(0.6)
    }
    
    private let accentTeal = Color(red: 0.05, green: 0.65, blue: 0.91)
    private let accentTurquoise = Color(red: 0.18, green: 0.83, blue: 0.75)
    private let accentDeepBlue = Color(red: 0.01, green: 0.52, blue: 0.78)
    
    var body: some View {
        ZStack {
            // Dynamic Background based on time
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation bar (back button for normal flow)
                if !isNameEmpty {
                    HStack {
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            onBack()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(textColor.opacity(0.7))
                                .frame(width: 44, height: 44)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .opacity(contentAppeared ? 1 : 0)
                }
                
                Spacer()
                
                // Main content with zen scene
                VStack(spacing: 0) {
                    // The Zen Horizon Scene (Sun/Moon animation)
                    ZenHorizonScene()
                        .opacity(contentAppeared ? 1 : 0)
                        .offset(y: contentAppeared ? 0 : 30)
                    
                    // Greeting text with horizon line
                    VStack(spacing: 8) {
                        // The Horizon Line (separator between scene and text)
                        Capsule()
                            .fill(isNightTime ? Color.white.opacity(0.5) : Color.black.opacity(0.15))
                            .frame(width: contentAppeared ? 120 : 0, height: 2)
                            .animation(.easeOut(duration: 0.8).delay(0.5), value: contentAppeared)
                        
                        if isNameEmpty {
                            // Empty name message - contemplative typography
                            VStack(spacing: 16) {
                                // Minimal ellipsis as a pause moment
                                Text("· · ·")
                                    .font(.josefinSansLight(size: 24))
                                    .foregroundColor(subtitleColor.opacity(0.5))
                                    .tracking(8)
                                
                                VStack(spacing: 6) {
                                    Text("you rushed")
                                        .font(.josefinSansLight(size: 22))
                                        .foregroundColor(subtitleColor)
                                        .tracking(3)
                                    
                                    Text(" or ")
                                        .font(.josefinSansLight(size: 14))
                                        .foregroundColor(subtitleColor.opacity(0.5))
                                        .tracking(2)
                                    
                                    Text("you prefer to stay unnamed")
                                        .font(.josefinSansLight(size: 18))
                                        .foregroundColor(subtitleColor.opacity(0.8))
                                        .tracking(2)
                                }
                                
                                // Subtle reflection prompt
                                Text("either way, that's okay")
                                    .font(.josefinSansRegular(size: 14))
                                    .foregroundColor(subtitleColor.opacity(0.5))
                                    .tracking(1)
                                    .padding(.top, 8)
                            }
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                            .opacity(contentAppeared ? 1 : 0)
                            .offset(y: contentAppeared ? 0 : 20)
                        } else {
                            // Normal greeting
                            Text("Muchi is excited to meet you!")
                                .font(.josefinSansMedium(size: 17))
                                .foregroundColor(subtitleColor)
                                .tracking(1)
                                .padding(.top, 12)
                                .opacity(contentAppeared ? 1 : 0)
                                .offset(y: contentAppeared ? 0 : 20)
                        }
                    }
                    
                    if !isNameEmpty {
                        // Age question (only shown when name is provided)
                        Text("How old are you, \(name)?")
                            .font(.josefinSansSemiBold(size: 30))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                            .opacity(contentAppeared ? 1 : 0)
                            .offset(y: contentAppeared ? 0 : 20)
                        
                        // Age picker wheel
                        Picker("Age", selection: $age) {
                            ForEach(13...100, id: \.self) { ageValue in
                                Text("\(ageValue)")
                                    .font(.josefinSansMedium(size: 28))
                                    .foregroundColor(textColor)
                                    .tag(ageValue)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                        .frame(maxWidth: 120)
                        .clipped()
                        .padding(.top, 24)
                        .opacity(contentAppeared ? 1 : 0)
                        .scaleEffect(contentAppeared ? 1 : 0.9)
                    }
                }
                
                Spacer()
                
                // Bottom buttons
                if isNameEmpty {
                    // Empty name: Back (left) + Continue (right)
                    HStack(spacing: 16) {
                        // Back button
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            onBack()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Back")
                                    .font(.josefinSansMedium(size: 16))
                            }
                            .foregroundColor(textColor.opacity(0.8))
                            .frame(height: 56)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(textColor.opacity(0.2), lineWidth: 1.5)
                            )
                        }
                        
                        // Continue button
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            onComplete()
                        }) {
                            Text("Continue")
                                .font(.josefinSansSemiBold(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [accentTeal, accentTurquoise],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 30)
                } else {
                    // Normal flow: Cheers to better mornings button
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        onComplete()
                    }) {
                        HStack(spacing: 8) {
                            Text("Cheers to better mornings")
                                .font(.josefinSansSemiBold(size: 18))
                            
                            Image(systemName: "sunrise.fill")
                                .font(.system(size: 22, weight: .medium))
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
                        .shadow(color: accentTeal.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 30)
                }
            }
        }
        .onAppear {
            // Staggered entrance animation for smooth transition from NameInputView
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                contentAppeared = true
            }
        }
    }
}

#Preview("Normal Flow - With Name") {
    AgeInputView(name: "Manik", age: .constant(25), onComplete: {
        print("Onboarding complete")
    }, onBack: {
        print("Back tapped")
    })
}

#Preview("Empty Name Flow") {
    AgeInputView(name: "", age: .constant(25), onComplete: {
        print("Continuing anonymously")
    }, onBack: {
        print("Going back to enter name")
    })
}
