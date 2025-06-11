import Foundation

class MinimalAzure {
    static let shared = MinimalAzure()
    
    private init() {}
    
    func sendAudio(_ audioData: Data, completion: @escaping (String?) -> Void) {
        print("🚀 [TEST] Testing with simple HTTP request first...")
        
        // First test: Try a simple GET request to see if URLSession works at all
        testSimpleRequest { success in
            if success {
                print("✅ [TEST] Simple request worked, trying Azure...")
                self.actuallyCallAzure(audioData, completion: completion)
            } else {
                print("❌ [TEST] Even simple request failed!")
                completion(nil)
            }
        }
    }
    
    private func testSimpleRequest(completion: @escaping (Bool) -> Void) {
        print("🔄 [TEST] Testing simple GET to httpbin.org...")
        
        guard let url = URL(string: "https://httpbin.org/get") else {
            print("❌ [TEST] Bad URL")
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print("📨 [TEST] Got response from httpbin")
            
            if let error = error {
                print("❌ [TEST] Error: \(error)")
                completion(false)
            } else {
                print("✅ [TEST] Success!")
                completion(true)
            }
        }
        
        task.resume()
        print("🔄 [TEST] Simple request started")
    }
    
    private func actuallyCallAzure(_ audioData: Data, completion: @escaping (String?) -> Void) {
        print("🚀 [AZURE] Now trying real Azure request")
        
        // Get API key from config file
        guard let configContent = try? String(contentsOfFile: "/Users/yadid/listen/hey_listen_config.txt"),
              !configContent.isEmpty else {
            log("❌ [AZURE] No hey_listen_config.txt file found")
            log("📝 [AZURE] Please create hey_listen_config.txt with your Azure API key")
            completion(nil)
            return
        }
        
        // Parse config file
        var apiKey = ""
        var region = "germanywestcentral"
        
        for line in configContent.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasPrefix("API_KEY=") {
                apiKey = String(trimmed.dropFirst(8))
            } else if trimmed.hasPrefix("REGION=") {
                region = String(trimmed.dropFirst(7))
            }
        }
        
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else {
            log("❌ [AZURE] Please set your API key in hey_listen_config.txt")
            completion(nil)
            return
        }
        
        // Correct Azure Speech-to-Text REST API endpoint
        let urlString = "https://\(region).stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US"
        
        print("🌐 [AZURE] URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ [AZURE] Invalid URL")
            completion(nil)
            return
        }
        
        // Create request with correct Azure headers
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("audio/wav; codecs=audio/pcm; samplerate=16000", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.httpBody = audioData
        request.timeoutInterval = 30.0
        
        print("📤 [AZURE] Sending to Azure...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("📨 [AZURE] Got Azure response")
            
            if let error = error {
                print("❌ [AZURE] Error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("❌ [AZURE] No data")
                completion(nil)
                return
            }
            
            // Try to parse Azure response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("📄 [AZURE] JSON: \(json)")
                    
                    if let status = json["RecognitionStatus"] as? String,
                       status == "Success",
                       let text = json["DisplayText"] as? String {
                        print("✅ [AZURE] Got text: \(text)")
                        completion(text)
                    } else {
                        print("❌ [AZURE] Status not success or no text")
                        completion(nil)
                    }
                } else {
                    print("❌ [AZURE] Not valid JSON")
                    completion(nil)
                }
            } catch {
                print("❌ [AZURE] JSON parse error: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
        print("🔄 [AZURE] Azure task started")
    }
}