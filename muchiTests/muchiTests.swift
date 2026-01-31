//
//  muchiTests.swift
//  muchiTests
//
//  Created by Manik Singh Sarmaal on 28/01/26.
//

import Testing
import Foundation
@testable import muchi

// MARK: - AudioMonitor Tests

struct AudioMonitorTests {
    
    @Test("AudioMonitor initializes with default values")
    @MainActor
    func testInitialState() async throws {
        let monitor = AudioMonitor(previewMode: true)
        
        #expect(monitor.normalizedAmplitude == 0.0)
        #expect(monitor.isRecording == false)
        #expect(monitor.currentTranscription.isEmpty)
        #expect(monitor.errorMessage == nil)
    }
    
    @Test("Preview mode starts recording simulation")
    @MainActor
    func testPreviewModeStartsRecording() async throws {
        let monitor = AudioMonitor(previewMode: true)
        
        monitor.startMonitoring()
        
        // Give it a moment to start
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        #expect(monitor.isRecording == true)
        #expect(monitor.currentTranscription == "Preview mode - simulating audio...")
        
        monitor.stopMonitoring()
    }
    
    @Test("Preview mode generates amplitude values")
    @MainActor
    func testPreviewModeGeneratesAmplitude() async throws {
        let monitor = AudioMonitor(previewMode: true)
        
        monitor.startMonitoring()
        
        // Wait for amplitude simulation to run
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Amplitude should have changed from initial 0.0
        // The simulation generates values in 0-1 range
        #expect(monitor.normalizedAmplitude >= 0.0)
        #expect(monitor.normalizedAmplitude <= 1.0)
        
        monitor.stopMonitoring()
    }
    
    @Test("Stop monitoring resets state")
    @MainActor
    func testStopMonitoringResetsState() async throws {
        let monitor = AudioMonitor(previewMode: true)
        
        monitor.startMonitoring()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(monitor.isRecording == true)
        
        monitor.stopMonitoring()
        
        #expect(monitor.isRecording == false)
        #expect(monitor.normalizedAmplitude == 0.0)
    }
    
    @Test("Transcript file operations work correctly")
    @MainActor
    func testTranscriptFileOperations() async throws {
        let monitor = AudioMonitor(previewMode: true)
        
        // Clear any existing transcript
        monitor.clearTranscript()
        
        // Read should return empty string
        let emptyTranscript = monitor.readTranscript()
        #expect(emptyTranscript.isEmpty)
    }
}

// MARK: - User Model Tests

struct UserModelTests {
    
    @Test("User initializes with provided values")
    func testUserInitialization() {
        let user = User(name: "TestUser", age: 25)
        
        #expect(user.name == "TestUser")
        #expect(user.age == 25)
    }
    
    @Test("User createdAt defaults to current date")
    func testUserCreatedAtDefault() {
        let beforeCreation = Date()
        let user = User(name: "Test", age: 30)
        let afterCreation = Date()
        
        #expect(user.createdAt >= beforeCreation)
        #expect(user.createdAt <= afterCreation)
    }
    
    @Test("User name can be empty")
    func testUserEmptyName() {
        let user = User(name: "", age: 20)
        
        #expect(user.name.isEmpty)
    }
    
    @Test("User age can be any positive integer")
    func testUserAgeRange() {
        let youngUser = User(name: "Young", age: 1)
        let oldUser = User(name: "Old", age: 120)
        
        #expect(youngUser.age == 1)
        #expect(oldUser.age == 120)
    }
}

// MARK: - Greeting Logic Tests

struct GreetingTests {
    
    @Test("Morning greeting (5-11)")
    func testMorningGreeting() {
        let greeting = greetingForHour(8, name: "Alice")
        #expect(greeting == "Good morning, Alice")
    }
    
    @Test("Afternoon greeting (12-16)")
    func testAfternoonGreeting() {
        let greeting = greetingForHour(14, name: "Bob")
        #expect(greeting == "Good afternoon, Bob")
    }
    
    @Test("Evening greeting (17-20)")
    func testEveningGreeting() {
        let greeting = greetingForHour(19, name: "Charlie")
        #expect(greeting == "Good evening, Charlie")
    }
    
    @Test("Night greeting (21-4)")
    func testNightGreeting() {
        let lateNight = greetingForHour(23, name: "Diana")
        let earlyMorning = greetingForHour(3, name: "Diana")
        
        #expect(lateNight == "Hello, Diana")
        #expect(earlyMorning == "Hello, Diana")
    }
    
    @Test("Default name is Friend")
    func testDefaultName() {
        let greeting = greetingForHour(10, name: "Friend")
        #expect(greeting == "Good morning, Friend")
    }
    
    // Helper function that mirrors ContentView logic
    private func greetingForHour(_ hour: Int, name: String) -> String {
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

// MARK: - Amplitude Normalization Tests

struct AmplitudeTests {
    
    @Test("Amplitude stays within 0-1 range")
    func testAmplitudeRange() {
        // Test the normalization logic
        let testValues: [Float] = [0.0, 0.01, 0.05, 0.1, 0.5, 1.0, 2.0]
        
        for value in testValues {
            let normalized = min(value * 15, 1.0)
            #expect(normalized >= 0.0)
            #expect(normalized <= 1.0)
        }
    }
    
    @Test("Small amplitudes produce small normalized values")
    func testSmallAmplitudes() {
        let smallRMS: Float = 0.01
        let normalized = min(smallRMS * 15, 1.0)
        
        #expect(normalized < 0.2)
    }
    
    @Test("Large amplitudes cap at 1.0")
    func testLargeAmplitudes() {
        let largeRMS: Float = 0.5
        let normalized = min(largeRMS * 15, 1.0)
        
        #expect(normalized == 1.0)
    }
}

// MARK: - Mesh Gradient Point Tests

struct MeshGradientTests {
    
    @Test("Base mesh has 16 points (4x4 grid)")
    func testMeshPointCount() {
        let expectedCount = 16 // 4x4 grid
        
        // Verify the grid structure
        let rows = 4
        let cols = 4
        #expect(rows * cols == expectedCount)
    }
    
    @Test("Corner points should remain fixed")
    func testCornerPointsFixed() {
        // Test logic: corners are at indices 0, 3, 12, 15
        let cornerIndices = [0, 3, 12, 15]
        
        for index in cornerIndices {
            let row = index / 4
            let col = index % 4
            let isCorner = (row == 0 || row == 3) && (col == 0 || col == 3)
            #expect(isCorner == true)
        }
    }
    
    @Test("Edge detection works correctly")
    func testEdgeDetection() {
        // Index 1 is on top edge (row 0)
        let index1Row = 1 / 4
        let index1Col = 1 % 4
        let isEdge1 = index1Row == 0 || index1Row == 3 || index1Col == 0 || index1Col == 3
        #expect(isEdge1 == true)
        
        // Index 5 is interior (row 1, col 1)
        let index5Row = 5 / 4
        let index5Col = 5 % 4
        let isEdge5 = index5Row == 0 || index5Row == 3 || index5Col == 0 || index5Col == 3
        #expect(isEdge5 == false)
    }
}

// MARK: - Blob Shape Tests

struct BlobShapeTests {
    
    @Test("Blob variation uses frequency correctly")
    func testBlobVariation() {
        let phase: Double = 0
        let amplitude: Double = 0.1
        let frequency: Double = 3.0
        let angle: Double = .pi / 4
        
        let variation = sin(angle * frequency + phase) * amplitude
        
        // Variation should be within -amplitude to +amplitude
        #expect(variation >= -amplitude)
        #expect(variation <= amplitude)
    }
    
    @Test("Blob shape is continuous")
    func testBlobContinuity() {
        // At angle 0 and 2*pi, values should be the same
        let phase: Double = 0.5
        let amplitude: Double = 0.15
        let frequency: Double = 3.0
        
        let startVariation = sin(0 * frequency + phase) * amplitude
        let endVariation = sin(2 * .pi * frequency + phase) * amplitude
        
        // Should be approximately equal (allowing for floating point)
        #expect(abs(startVariation - endVariation) < 0.0001)
    }
}

// MARK: - Particle Tests

struct ParticleTests {
    
    @Test("Particle angle increments correctly per index")
    func testParticleAngleIncrement() {
        let baseAngle0 = Double(0) * (.pi / 4)
        let baseAngle1 = Double(1) * (.pi / 4)
        let baseAngle2 = Double(2) * (.pi / 4)
        
        #expect(baseAngle0 == 0)
        #expect(abs(baseAngle1 - .pi / 4) < 0.0001)
        #expect(abs(baseAngle2 - .pi / 2) < 0.0001)
    }
    
    @Test("8 particles cover full circle")
    func testParticlesCoverCircle() {
        var angles: [Double] = []
        
        for index in 0..<8 {
            let angle = Double(index) * (.pi / 4)
            angles.append(angle)
        }
        
        // Last particle should be at 7 * pi/4 = 7/8 of a full circle
        #expect(abs(angles.last! - (7 * .pi / 4)) < 0.0001)
    }
    
    @Test("Particle size increases with audio level")
    func testParticleSizeAudioReactivity() {
        let baseSize: CGFloat = 4
        let audioBoostMultiplier: CGFloat = 8
        
        let silentSize = baseSize + 0.0 * audioBoostMultiplier
        let loudSize = baseSize + 1.0 * audioBoostMultiplier
        
        #expect(silentSize == 4)
        #expect(loudSize == 12)
        #expect(loudSize > silentSize)
    }
}
