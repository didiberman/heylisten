import AVFoundation
import Foundation

class AudioRecorder: NSObject {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    
    var currentRecordingURL: URL? {
        return recordingURL
    }
    
    override init() {
        super.init()
    }
    
    func startRecording() {
        guard audioRecorder == nil else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordingURL = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).wav")
        
        guard let url = recordingURL else { return }
        
        // Use WAV format for Azure Speech API compatibility
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,  // Azure prefers 16kHz
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            print("Recording started")
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void = { _ in }) {
        guard let recorder = audioRecorder else {
            print("No active recorder to stop")
            completion(nil)
            return
        }
        
        let urlToReturn = recordingURL
        
        // CRITICAL: Clear delegate BEFORE stopping to prevent delegate callbacks on deallocated object
        recorder.delegate = nil
        
        // Stop recording
        recorder.stop()
        print("Recording stopped")
        
        // Clean up references AFTER delegate is cleared
        audioRecorder = nil
        recordingURL = nil
        
        // Return the URL immediately
        completion(urlToReturn)
    }
    
    // Simple stop without completion handler
    func stopRecording() {
        guard let recorder = audioRecorder else {
            print("No active recorder to stop")
            return
        }
        
        // CRITICAL: Clear delegate BEFORE stopping
        recorder.delegate = nil
        
        // Stop recording
        recorder.stop()
        print("Recording stopped")
        
        // Clean up references
        audioRecorder = nil
        recordingURL = nil
    }
    
    func getCurrentAudioLevel() -> Float {
        guard let recorder = audioRecorder, recorder.isRecording else { return 0.0 }
        
        recorder.updateMeters()
        return recorder.averagePower(forChannel: 0)
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Recording encode error: \(error)")
        }
    }
}