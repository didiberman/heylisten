import Foundation

class SimpleHTTPClient {
    
    static func postAudioToAzure(
        audioData: Data,
        endpoint: String,
        subscriptionKey: String,
        completion: @escaping (String?) -> Void
    ) {
        print("🚀 [AZURE DEBUG] Starting Azure Speech API request")
        print("🌐 [AZURE DEBUG] Target URL: \(endpoint)")
        print("📊 [AZURE DEBUG] Audio data size: \(audioData.count) bytes")
        
        // Create the simplest possible URLSession request
        guard let url = URL(string: endpoint) else {
            print("❌ [AZURE DEBUG] Invalid URL: \(endpoint)")
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
        
        // Log all request headers (mask the subscription key for security)
        print("📋 [AZURE DEBUG] Request headers:")
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            if key == "Ocp-Apim-Subscription-Key" {
                let maskedKey = String(value.prefix(8)) + "..." + String(value.suffix(4))
                print("   \(key): \(maskedKey)")
            } else {
                print("   \(key): \(value)")
            }
        }
        print("🔧 [AZURE DEBUG] Request method: \(request.httpMethod ?? "Unknown")")
        print("⏱️ [AZURE DEBUG] Timeout: \(request.timeoutInterval)s")
        
        // Use the default session configuration - back to the original working approach
        print("📤 [AZURE DEBUG] Sending request to Azure...")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("📨 [AZURE DEBUG] Received response from Azure")
            
            // Process response
            var result: String? = nil
            
            if let error = error {
                print("❌ [AZURE DEBUG] Network error: \(error.localizedDescription)")
            } else if let httpResponse = response as? HTTPURLResponse,
                      let data = data {
                print("📝 [AZURE DEBUG] Response status: \(httpResponse.statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 [AZURE DEBUG] Raw response: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let status = json["RecognitionStatus"] as? String,
                       status == "Success",
                       let displayText = json["DisplayText"] as? String,
                       !displayText.isEmpty {
                        result = displayText
                        print("✅ [AZURE DEBUG] Transcription: '\(displayText)'")
                    } else {
                        print("❌ [AZURE DEBUG] Recognition failed or empty")
                    }
                } else {
                    print("❌ [AZURE DEBUG] HTTP \(httpResponse.statusCode)")
                }
            }
            
            // Return to main thread for completion
            DispatchQueue.main.async {
                print("🏁 [AZURE DEBUG] Completion called with: \(result ?? "nil")")
                completion(result)
            }
        }
        
        print("▶️ [AZURE DEBUG] Starting task...")
        task.resume()
    }
}