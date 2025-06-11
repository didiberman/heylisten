import Foundation

class AzureSpeechRecognizer {
    private let subscriptionKey: String
    private let region: String
    private let endpoint: String
    
    init(subscriptionKey: String = "", region: String = "germanywestcentral") {
        self.subscriptionKey = subscriptionKey
        self.region = region
        self.endpoint = "https://\(region).api.cognitive.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US"
    }
    
    func transcribe(audioURL: URL, completion: @escaping (String?) -> Void) {
        print("🎯 [AZURE DEBUG] Starting transcription process")
        print("📁 [AZURE DEBUG] Audio file path: \(audioURL.path)")
        
        guard !subscriptionKey.isEmpty else {
            print("❌ [AZURE DEBUG] Azure subscription key not set or empty")
            completion(nil)
            return
        }
        print("🔑 [AZURE DEBUG] Subscription key present (length: \(subscriptionKey.count))")
        
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("❌ [AZURE DEBUG] Audio file does not exist at path: \(audioURL.path)")
            completion(nil)
            return
        }
        print("✅ [AZURE DEBUG] Audio file exists, proceeding with upload")
        
        // Convert audio file to WAV format if needed (Azure prefers WAV)
        convertAndUploadToAzure(audioURL: audioURL, completion: completion)
    }
    
    private func convertAndUploadToAzure(audioURL: URL, completion: @escaping (String?) -> Void) {
        print("🔄 [AZURE DEBUG] Converting and preparing audio for upload")
        
        do {
            print("📖 [AZURE DEBUG] Reading audio file from disk...")
            let audioData = try Data(contentsOf: audioURL)
            print("✅ [AZURE DEBUG] Successfully read audio data from file")
            
            // Validate audio data
            print("🔍 [AZURE DEBUG] Validating audio data size...")
            guard audioData.count > 1000 else {
                print("❌ [AZURE DEBUG] Audio file too small: \(audioData.count) bytes (minimum: 1000)")
                completion(nil)
                return
            }
            
            guard audioData.count < 10_000_000 else { // 10MB limit
                print("❌ [AZURE DEBUG] Audio file too large: \(audioData.count) bytes (maximum: 10MB)")
                completion(nil)
                return
            }
            
            print("✅ [AZURE DEBUG] Audio data size validation passed: \(audioData.count) bytes")
            print("🌐 [AZURE DEBUG] Target endpoint: \(endpoint)")
            print("🔧 [AZURE DEBUG] Using region: \(region)")
            
            // Log audio file metadata
            if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: audioURL.path) {
                print("📊 [AZURE DEBUG] Audio file metadata:")
                if let fileSize = fileAttributes[.size] as? Int64 {
                    print("   File size on disk: \(fileSize) bytes")
                }
                if let creationDate = fileAttributes[.creationDate] as? Date {
                    print("   Created: \(creationDate)")
                }
                if let modificationDate = fileAttributes[.modificationDate] as? Date {
                    print("   Modified: \(modificationDate)")
                }
            }
            
            // Check if it's a valid WAV file by examining header
            if audioData.count >= 12 {
                let header = audioData.prefix(12)
                let headerString = String(data: header, encoding: .ascii) ?? "N/A"
                print("🎵 [AZURE DEBUG] Audio file header (first 12 bytes): \(headerString)")
                
                // Check for WAV signature
                if audioData.count >= 4 {
                    let riffSignature = audioData.prefix(4)
                    if let riffString = String(data: riffSignature, encoding: .ascii), riffString == "RIFF" {
                        print("✅ [AZURE DEBUG] Valid RIFF/WAV file detected")
                    } else {
                        print("⚠️ [AZURE DEBUG] File doesn't appear to be a WAV file (no RIFF header)")
                    }
                }
            }
            
            print("📤 [AZURE DEBUG] Initiating upload to Azure Speech API...")
            
            // Use the simple HTTP client
            SimpleHTTPClient.postAudioToAzure(
                audioData: audioData,
                endpoint: endpoint,
                subscriptionKey: subscriptionKey
            ) { result in
                print("🔄 [AZURE DEBUG] HTTP client completion handler called")
                print("🧹 [AZURE DEBUG] Cleaning up temporary audio file...")
                
                // Clean up audio file AFTER network completes
                do {
                    try FileManager.default.removeItem(at: audioURL)
                    print("✅ [AZURE DEBUG] Successfully deleted temporary audio file")
                } catch {
                    print("⚠️ [AZURE DEBUG] Failed to delete temporary audio file: \(error.localizedDescription)")
                }
                
                print("🎯 [AZURE DEBUG] Calling final completion with result: \(result ?? "nil")")
                completion(result)
            }
            
        } catch {
            print("❌ [AZURE DEBUG] Failed to read audio file: \(error.localizedDescription)")
            print("   Error domain: \((error as NSError).domain)")
            print("   Error code: \((error as NSError).code)")
            completion(nil)
        }
    }
}