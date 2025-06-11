import Foundation
import Speech
import AVFoundation

class LocalSpeechRecognizer {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    init() {
        // Configure for best real-time performance
        speechRecognizer?.defaultTaskHint = .search
    }
    
    func transcribe(audioURL: URL, completion: @escaping (String?) -> Void) {
        print("🎯 [LOCAL SPEECH] Starting local transcription")
        print("📁 [LOCAL SPEECH] Audio file: \(audioURL.path)")
        
        // Check if speech recognition is available
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("❌ [LOCAL SPEECH] Speech recognition not available")
            completion(nil)
            return
        }
        
        // Check permissions
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            print("❌ [LOCAL SPEECH] Speech recognition not authorized")
            completion(nil)
            return
        }
        
        // Cancel any previous task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Create recognition request
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false
        request.taskHint = .search // Optimized for short phrases
        
        print("🚀 [LOCAL SPEECH] Starting recognition task...")
        
        // Perform recognition
        recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
            var isFinal = false
            var transcribedText: String?
            
            if let result = result {
                transcribedText = result.bestTranscription.formattedString
                isFinal = result.isFinal
                print("🎤 [LOCAL SPEECH] Partial result: '\(transcribedText ?? "nil")'")
            }
            
            if error != nil || isFinal {
                print("🏁 [LOCAL SPEECH] Recognition completed")
                if let error = error {
                    print("❌ [LOCAL SPEECH] Error: \(error.localizedDescription)")
                }
                
                // Clean up
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                // Clean up audio file
                do {
                    try FileManager.default.removeItem(at: audioURL)
                    print("🧹 [LOCAL SPEECH] Audio file cleaned up")
                } catch {
                    print("⚠️ [LOCAL SPEECH] Failed to clean up audio file: \(error)")
                }
                
                print("✅ [LOCAL SPEECH] Final result: '\(transcribedText ?? "nil")'")
                completion(transcribedText)
            }
        }
    }
    
    // Check if local speech recognition is available and authorized
    func isAvailable() -> Bool {
        guard let speechRecognizer = speechRecognizer else { return false }
        return speechRecognizer.isAvailable && SFSpeechRecognizer.authorizationStatus() == .authorized
    }
    
    func getAuthorizationStatus() -> SFSpeechRecognizerAuthorizationStatus {
        return SFSpeechRecognizer.authorizationStatus()
    }
}