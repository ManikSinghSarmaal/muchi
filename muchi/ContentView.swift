//
//  ContentView.swift
//  muchi
//
//  Created by Manik Singh Sarmaal on 28/01/26.
//

import SwiftUI
import SwiftData

/// The main home screen of muchi - shown after onboarding is complete.
/// Features a voice-reactive orb that listens and transcribes speech.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    /// The audio monitor that handles microphone input and speech recognition
    /// In preview mode, this simulates audio for visual testing
    @StateObject private var audioMonitor: AudioMonitor
    
    /// Initialize with optional preview mode
    init(previewMode: Bool = false) {
        _audioMonitor = StateObject(wrappedValue: AudioMonitor(previewMode: previewMode))
    }
    
    // MARK: - Design Tokens
    private let backgroundColor = Color(red: 0.98, green: 0.98, blue: 0.98) // #FAFAFA
    private let textColor = Color(red: 0.17, green: 0.17, blue: 0.18) // #2C2C2E
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Welcome message with user's name
                Text(greeting)
                    .font(.josefinSansSemiBold(size: 28))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Voice Orb - the main interactive element
                VoiceOrbView(audioMonitor: audioMonitor, baseSize: 200)
                    .frame(width: 280, height: 280)
                
                Spacer()
                
                // Status and transcription area
                VStack(spacing: 12) {
                    // Recording status
                    HStack(spacing: 8) {
                        if audioMonitor.isRecording {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .opacity(pulsingOpacity)
                        }
                        
                        Text(statusText)
                            .font(.josefinSansMedium(size: 16))
                            .foregroundColor(textColor.opacity(0.6))
                    }
                    
                    // Live transcription preview
                    if !audioMonitor.currentTranscription.isEmpty {
                        Text(audioMonitor.currentTranscription)
                            .font(.josefinSansRegular(size: 14))
                            .foregroundColor(textColor.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    
                    // Debug: Amplitude indicator (can be removed later)
                    if audioMonitor.isRecording {
                        Text("Amplitude: \(String(format: "%.2f", audioMonitor.normalizedAmplitude))")
                            .font(.josefinSansRegular(size: 12))
                            .foregroundColor(textColor.opacity(0.3))
                    }
                    
                    // Error message if any
                    if let error = audioMonitor.errorMessage {
                        Text(error)
                            .font(.josefinSansRegular(size: 12))
                            .foregroundColor(.red.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: audioMonitor.currentTranscription)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            // Start listening when the view appears
            audioMonitor.startMonitoring()
        }
        .onDisappear {
            // Clean up when leaving
            audioMonitor.stopMonitoring()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Returns the user's name from SwiftData, or "Friend" if empty/missing
    private var userName: String {
        guard let user = users.first else { return "Friend" }
        let name = user.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Friend" : name
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
    
    /// Status text based on recording state
    private var statusText: String {
        if audioMonitor.isRecording {
            return "Listening..."
        } else if audioMonitor.errorMessage != nil {
            return "Unable to listen"
        } else {
            return "Starting..."
        }
    }
    
    /// Pulsing opacity for the recording indicator
    @State private var isPulsing = false
    private var pulsingOpacity: Double {
        isPulsing ? 0.3 : 1.0
    }
}

#Preview("Live Mode (requires device)") {
    ContentView(previewMode: false)
        .modelContainer(for: User.self, inMemory: true)
}

#Preview("Simulated Audio") {
    ContentView(previewMode: true)
        .modelContainer(for: User.self, inMemory: true)
}
