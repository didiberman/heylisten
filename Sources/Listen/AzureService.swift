import Foundation

class AzureService {
    static let shared = AzureService()
    
    private let subscriptionKey: String
    private let region: String
    private let endpoint: String
    
    private init() {
        // Load configuration
        let preferences = UserPreferences.shared
        if let savedKey = preferences.azureApiKey, !savedKey.isEmpty {
            self.subscriptionKey = savedKey
            self.region = preferences.azureRegion
        } else {
            // Fallback to secrets file
            let secretsPath = "/Users/yadid/listen/secrets.txt"
            if let secretsContent = try? String(contentsOfFile: secretsPath),
               !secretsContent.isEmpty {
                let lines = secretsContent.components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty && !$0.hasPrefix("#") }
                
                self.subscriptionKey = lines.first ?? ""
                self.region = lines.count > 1 ? lines[1] : "germanywestcentral"
                
                // Save for future use
                if !self.subscriptionKey.isEmpty {
                    preferences.azureApiKey = self.subscriptionKey
                    preferences.azureRegion = self.region
                }
            } else {
                self.subscriptionKey = ""
                self.region = "germanywestcentral"
            }
        }
        
        self.endpoint = "https://\(region).api.cognitive.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US"
        print("🔧 [AZURE SERVICE] Initialized with region: \(region)")
    }
    
    func transcribeAudio(from audioURL: URL, completion: @escaping (String?) -> Void) {
        print("🎯 [AZURE SERVICE] Starting transcription")
        print("📁 [AZURE SERVICE] Audio file: \(audioURL.path)")
        
        guard !subscriptionKey.isEmpty else {
            print("❌ [AZURE SERVICE] No subscription key available")
            completion(nil)
            return
        }
        
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("❌ [AZURE SERVICE] Audio file does not exist")
            completion(nil)
            return
        }
        
        do {
            let audioData = try Data(contentsOf: audioURL)
            print("✅ [AZURE SERVICE] Read \(audioData.count) bytes")
            
            // Validate size
            guard audioData.count > 1000 && audioData.count < 10_000_000 else {
                print("❌ [AZURE SERVICE] Invalid audio size: \(audioData.count)")
                completion(nil)
                return
            }
            
            // Make request
            makeRequest(with: audioData) { result in
                // Clean up file
                try? FileManager.default.removeItem(at: audioURL)
                print("🧹 [AZURE SERVICE] Cleaned up audio file")
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
        } catch {
            print("❌ [AZURE SERVICE] Failed to read audio: \(error)")
            completion(nil)
        }
    }
    
    private func makeRequest(with audioData: Data, completion: @escaping (String?) -> Void) {
        print("🚀 [AZURE SERVICE] Making HTTP request")
        print("🌐 [AZURE SERVICE] URL: \(endpoint)")
        print("📊 [AZURE SERVICE] Data size: \(audioData.count) bytes")
        
        guard let url = URL(string: endpoint) else {
            print("❌ [AZURE SERVICE] Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("audio/wav; codecs=audio/pcm; samplerate=16000", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = audioData
        request.timeoutInterval = 30.0
        
        print("📤 [AZURE SERVICE] Sending request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("📨 [AZURE SERVICE] Got response")
            
            if let error = error {
                print("❌ [AZURE SERVICE] Error: \(error)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [AZURE SERVICE] No HTTP response")
                completion(nil)
                return
            }
            
            print("📝 [AZURE SERVICE] Status: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ [AZURE SERVICE] No data")
                completion(nil)
                return
            }
            
            if let responseText = String(data: data, encoding: .utf8) {
                print("📄 [AZURE SERVICE] Response: \(responseText)")
            }
            
            guard httpResponse.statusCode == 200 else {
                print("❌ [AZURE SERVICE] HTTP error: \(httpResponse.statusCode)")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["RecognitionStatus"] as? String,
                   status == "Success",
                   let displayText = json["DisplayText"] as? String,
                   !displayText.isEmpty {
                    print("✅ [AZURE SERVICE] Success: '\(displayText)'")
                    completion(displayText)
                } else {
                    print("❌ [AZURE SERVICE] Parse failed or empty result")
                    completion(nil)
                }
            } catch {
                print("❌ [AZURE SERVICE] JSON error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}