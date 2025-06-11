import Foundation

enum SpeechProvider {
    case local
    case azure
}

class UnifiedSpeechService {
    static let shared = UnifiedSpeechService()
    
    private let localRecognizer = LocalSpeechRecognizer()
    private var azureRecognizer: AzureSpeechRecognizer?
    
    private init() {
        setupAzureRecognizer()
    }
    
    var preferredProvider: SpeechProvider {
        // Use local first if available, fallback to Azure
        if localRecognizer.isAvailable() {
            return .local
        } else if azureRecognizer != nil && hasValidAzureConfig() {
            return .azure
        } else {
            return .local // Still prefer local even if not authorized yet
        }
    }
    
    func transcribe(audioURL: URL, completion: @escaping (String?) -> Void) {
        let provider = preferredProvider
        
        switch provider {
        case .local:
            logMessage("🎯 Using LOCAL speech recognition")
            localRecognizer.transcribe(audioURL: audioURL) { [weak self] result in
                if result != nil {
                    completion(result)
                } else {
                    // Fallback to Azure if local fails
                    logMessage("⚠️ Local speech failed, trying Azure fallback...")
                    self?.useAzureFallback(audioURL: audioURL, completion: completion)
                }
            }
            
        case .azure:
            logMessage("🎯 Using AZURE speech recognition")
            useAzureFallback(audioURL: audioURL, completion: completion)
        }
    }
    
    private func useAzureFallback(audioURL: URL, completion: @escaping (String?) -> Void) {
        guard let azureRecognizer = azureRecognizer else {
            logMessage("❌ No Azure recognizer available")
            completion(nil)
            return
        }
        
        azureRecognizer.transcribe(audioURL: audioURL, completion: completion)
    }
    
    private func setupAzureRecognizer() {
        let preferences = UserPreferences.shared
        if let apiKey = preferences.azureApiKey, !apiKey.isEmpty {
            let region = preferences.azureRegion
            azureRecognizer = AzureSpeechRecognizer(subscriptionKey: apiKey, region: region)
        }
    }
    
    private func hasValidAzureConfig() -> Bool {
        let preferences = UserPreferences.shared
        return preferences.azureApiKey != nil && !preferences.azureApiKey!.isEmpty
    }
    
    func refreshAzureConfig() {
        setupAzureRecognizer()
    }
    
    func getProviderStatus() -> String {
        let localStatus = localRecognizer.isAvailable() ? "✅ Available" : "❌ Not Authorized"
        let azureStatus = hasValidAzureConfig() ? "✅ Configured" : "❌ No API Key"
        
        return """
        Local Speech: \(localStatus)
        Azure Speech: \(azureStatus)
        Preferred: \(preferredProvider == .local ? "Local" : "Azure")
        """
    }
}

private func logMessage(_ message: String) {
    Logger.shared.log(message)
}