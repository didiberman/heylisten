import SwiftUI
import Cocoa

class SetupWindowManager: ObservableObject {
    static let shared = SetupWindowManager()
    
    private var setupWindow: NSWindow?
    
    private init() {}
    
    func showSetupIfNeeded() {
        // Check if API key exists
        let preferences = UserPreferences.shared
        
        // If API key exists, don't show setup
        if let apiKey = preferences.azureApiKey, !apiKey.isEmpty {
            return
        }
        
        // Also check config file as fallback
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configPath = homeDir.appendingPathComponent("hey_listen_config.txt")
        
        if FileManager.default.fileExists(atPath: configPath.path) {
            if let configContent = try? String(contentsOf: configPath),
               configContent.contains("API_KEY=") && !configContent.contains("YOUR_API_KEY_HERE") {
                return // Config file exists with real API key
            }
        }
        
        // Show setup window
        showSetupWindow()
    }
    
    func showSetupWindow() {
        // Close existing window if any
        setupWindow?.close()
        
        let setupView = SetupView {
            DispatchQueue.main.async {
                self.hideSetupWindow()
                // Notify app delegate that setup is complete
                NotificationCenter.default.post(name: .setupComplete, object: nil)
            }
        }
        
        let hostingController = NSHostingController(rootView: setupView)
        
        setupWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 700),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        setupWindow?.title = "Hey Listen! Setup"
        setupWindow?.contentViewController = hostingController
        setupWindow?.center()
        setupWindow?.makeKeyAndOrderFront(nil)
        setupWindow?.isReleasedWhenClosed = false
        
        // Bring app to front
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hideSetupWindow() {
        setupWindow?.close()
        setupWindow = nil
    }
}

extension Notification.Name {
    static let setupComplete = Notification.Name("setupComplete")
}