//
//  AudioMonitor.swift
//  muchi
//
//  Created by Manik Singh Sarmaal on 01/02/26.
//

import AVFoundation
import Speech
import Combine

/// AudioMonitor handles microphone input, amplitude calculation, and speech-to-text transcription.
/// It provides real-time audio level feedback for visual animations and transcribes speech to a local file.
@MainActor
class AudioMonitor: ObservableObject {
    // MARK: - Published Properties
    
    /// Normalized amplitude (0.0 to 1.0) for driving visual animations
    @Published var normalizedAmplitude: Float = 0.0
    
    /// Whether the audio engine is currently recording
    @Published var isRecording = false
    
    /// The current live transcription (updates as user speaks)
    @Published var currentTranscription: String = ""
    
    /// Error message if something goes wrong
    @Published var errorMessage: String?
    
    // MARK: - Preview Mode
    
    /// When true, simulates audio input for Xcode Previews (no real microphone access)
    private let isPreviewMode: Bool
    private var previewTimer: Timer?
    private var previewPhase: Double = 0
    
    // MARK: - Private Properties
    
    private var audioEngine: AVAudioEngine?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    /// Smoothing factor for amplitude (higher = more responsive, lower = smoother)
    private let smoothingFactor: Float = 0.3
    private var smoothedAmplitude: Float = 0.0
    
    /// Transcript file URL in the app's Documents directory
    private var transcriptURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("voice_transcript.txt")
    }
    
    // MARK: - Initialization
    
    /// Creates an AudioMonitor
    /// - Parameter previewMode: Set to true for Xcode Previews to simulate audio without microphone
    init(previewMode: Bool = false) {
        self.isPreviewMode = previewMode
        if !previewMode {
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        }
    }
    
    // MARK: - Public Methods
    
    /// Starts monitoring microphone input and speech recognition
    func startMonitoring() {
        // Use preview mode for simulated audio
        if isPreviewMode {
            startPreviewSimulation()
            return
        }
        
        // Request both permissions
        requestPermissions { [weak self] granted in
            guard granted else {
                Task { @MainActor in
                    self?.errorMessage = "Microphone or speech recognition permission denied"
                }
                return
            }
            
            Task { @MainActor in
                self?.setupAudioEngineAndSpeechRecognition()
            }
        }
    }
    
    /// Stops monitoring and cleans up resources
    func stopMonitoring() {
        // Stop preview simulation if active
        previewTimer?.invalidate()
        previewTimer = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        
        isRecording = false
        normalizedAmplitude = 0.0
    }
    
    // MARK: - Preview Simulation
    
    /// Starts a simulated audio input for Xcode Previews
    private func startPreviewSimulation() {
        isRecording = true
        currentTranscription = "Preview mode - simulating audio..."
        
        // Create a timer that simulates amplitude changes
        previewTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.previewPhase += 0.1
                
                // Simulate organic amplitude using sine waves
                let wave1 = sin(self.previewPhase) * 0.3
                let wave2 = sin(self.previewPhase * 2.3) * 0.2
                let wave3 = sin(self.previewPhase * 0.7) * 0.15
                let combined = Float(0.3 + wave1 + wave2 + wave3)
                
                self.normalizedAmplitude = max(0, min(1, combined))
            }
        }
    }
    
    /// Clears the transcript file
    func clearTranscript() {
        try? FileManager.default.removeItem(at: transcriptURL)
    }
    
    /// Reads the entire transcript file
    func readTranscript() -> String {
        (try? String(contentsOf: transcriptURL, encoding: .utf8)) ?? ""
    }
    
    // MARK: - Private Methods
    
    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        // First request microphone permission
        AVAudioApplication.requestRecordPermission { [weak self] micGranted in
            guard micGranted else {
                completion(false)
                return
            }
            
            // Then request speech recognition permission
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    let speechGranted = status == .authorized
                    if !speechGranted {
                        Task { @MainActor in
                            self?.errorMessage = "Speech recognition not authorized"
                        }
                    }
                    completion(speechGranted)
                }
            }
        }
    }
    
    private func setupAudioEngineAndSpeechRecognition() {
        // Configure audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Failed to configure audio session: \(error.localizedDescription)"
            return
        }
        
        // Setup audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Setup speech recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create speech recognition request"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.addsPunctuation = true
        
        // Start recognition task
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognizer not available"
            return
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                if let result = result {
                    let transcription = result.bestTranscription.formattedString
                    self?.currentTranscription = transcription
                    
                    // If this is a final result, append to transcript file
                    if result.isFinal {
                        self?.appendToTranscript(transcription)
                        self?.currentTranscription = ""
                    }
                }
                
                if let error = error {
                    // Don't treat cancellation as an error
                    if (error as NSError).code != 216 { // Cancelled error code
                        self?.errorMessage = "Recognition error: \(error.localizedDescription)"
                    }
                }
            }
        }
        
        // Install tap on input node for both amplitude and speech
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            // Send buffer to speech recognizer
            self?.recognitionRequest?.append(buffer)
            
            // Process amplitude
            self?.processAudioBuffer(buffer)
        }
        
        // Start the audio engine
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        // Calculate RMS (root mean square) amplitude
        var sum: Float = 0
        for i in 0..<frameLength {
            sum += channelData[i] * channelData[i]
        }
        let rms = sqrt(sum / Float(frameLength))
        
        // Apply smoothing for fluid animation
        smoothedAmplitude = (smoothingFactor * rms) + ((1 - smoothingFactor) * smoothedAmplitude)
        
        // Normalize to 0.0-1.0 range (adjust multiplier based on testing)
        let normalized = min(smoothedAmplitude * 15, 1.0)
        
        Task { @MainActor [weak self] in
            self?.normalizedAmplitude = normalized
        }
    }
    
    // MARK: - Transcript File Methods
    
    private func appendToTranscript(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let entry = "[\(timestamp)] \(text)\n"
        
        guard let data = entry.data(using: .utf8) else { return }
        
        if FileManager.default.fileExists(atPath: transcriptURL.path) {
            // Append to existing file
            if let fileHandle = try? FileHandle(forWritingTo: transcriptURL) {
                defer { try? fileHandle.close() }
                _ = try? fileHandle.seekToEnd()
                try? fileHandle.write(contentsOf: data)
            }
        } else {
            // Create new file
            try? data.write(to: transcriptURL)
        }
        
        print("📝 Transcript saved to: \(transcriptURL.path)")
    }
}
