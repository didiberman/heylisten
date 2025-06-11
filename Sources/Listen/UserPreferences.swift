import Foundation

class UserPreferences {
    static let shared = UserPreferences()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Azure Configuration
    
    var azureApiKey: String? {
        get {
            defaults.string(forKey: "azureApiKey")
        }
        set {
            if let value = newValue {
                defaults.set(value, forKey: "azureApiKey")
            } else {
                defaults.removeObject(forKey: "azureApiKey")
            }
        }
    }
    
    var azureRegion: String {
        get {
            defaults.string(forKey: "azureRegion") ?? "germanywestcentral"
        }
        set {
            defaults.set(newValue, forKey: "azureRegion")
        }
    }
    
    // MARK: - App Configuration
    
    var selectedKeyCode: Int {
        get {
            let saved = defaults.integer(forKey: "selectedKeyCode")
            return saved == 0 ? 63 : saved // Default to fn key (63)
        }
        set {
            defaults.set(newValue, forKey: "selectedKeyCode")
        }
    }
    
    var hasSelectedKey: Bool {
        get {
            defaults.bool(forKey: "hasSelectedKey")
        }
        set {
            defaults.set(newValue, forKey: "hasSelectedKey")
        }
    }
    
    var hasCompletedOnboarding: Bool {
        get {
            defaults.bool(forKey: "hasCompletedOnboarding")
        }
        set {
            defaults.set(newValue, forKey: "hasCompletedOnboarding")
        }
    }
    
    // MARK: - Validation
    
    var hasValidAzureConfig: Bool {
        guard let apiKey = azureApiKey,
              !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              apiKey.count >= 20 else {
            return false
        }
        return true
    }
    
    // MARK: - Utility
    
    func clearAllSettings() {
        let keys = ["azureApiKey", "azureRegion", "selectedKeyCode", "hasCompletedOnboarding"]
        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }
    
    func exportSettings() -> [String: Any] {
        return [
            "azureRegion": azureRegion,
            "selectedKeyCode": selectedKeyCode,
            "hasCompletedOnboarding": hasCompletedOnboarding
            // Note: We intentionally don't export the API key for security
        ]
    }
}