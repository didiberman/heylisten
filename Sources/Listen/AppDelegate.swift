import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var globalKeyMonitor: GlobalKeyMonitor?
    var audioRecorder: AudioRecorder?
    var speechRecognizer: AzureSpeechRecognizer?
    var textInjector: TextInjector?
    // var soundWaveIndicator: SoundWaveIndicator? // Disabled to prevent crashes
    var settingsWindow: SettingsWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        log("🎙️ Hey, Listen! app starting...")
        log("📁 Log file location: \(Logger.shared.getLogPath())")
        
        ensureConfigFileExists()
        setupStatusBar()
        setupComponents()
        requestPermissions()
        
        // Listen for configuration changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(azureConfigChanged),
            name: .azureConfigChanged,
            object: nil
        )
        
        // Listen for setup completion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setupCompleted),
            name: .setupComplete,
            object: nil
        )
        
        // Check if we need to show setup on first launch
        checkAndShowSetup()
        
        // Set up key monitoring with saved preference
        configureTargetKey()
        
        log("✅ Hey, Listen! app ready! Look for microphone icon in menu bar.")
        
        // Send a system notification to confirm the app is running
        let notification = NSUserNotification()
        notification.title = "Hey Listen! is running"
        notification.informativeText = "Look for 'MIC' in your menu bar. Hold fn key to record."
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func configureTargetKey(_ keyCode: Int? = nil) {
        let targetKey = keyCode ?? UserPreferences.shared.selectedKeyCode
        log("🔧 Configuring target key to code: \(targetKey)")
        globalKeyMonitor?.setTargetKey(UInt16(targetKey))
        
        // Save the key preference
        if let keyCode = keyCode {
            UserPreferences.shared.selectedKeyCode = keyCode
            UserPreferences.shared.hasSelectedKey = true
        }
        
        // Keep as regular app so menu bar icon is visible
        
        log("📍 Hold your selected key to start recording, release to transcribe.")
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        print("🛑 App termination requested")
        return .terminateNow
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit when windows close - this is a menu bar app
        return false
    }
    
    private func setupStatusBar() {
        log("🔧 Setting up status bar...")
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let button = statusItem?.button else {
            log("❌ Failed to create status bar button")
            return
        }
        
        // Use microphone emoji icon
        button.title = "🎙️"
        button.toolTip = "Hey Listen! - Voice to Text"
        log("📱 Menu bar icon set")
        
        // Create menu for status bar
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Hey, Listen! - Voice to Text", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        let setupItem = NSMenuItem(title: "Setup API Key...", action: #selector(openSetup), keyEquivalent: "s")
        setupItem.target = self
        menu.addItem(setupItem)
        
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        let logItem = NSMenuItem(title: "Show Log File", action: #selector(showLogFile), keyEquivalent: "l")
        logItem.target = self
        menu.addItem(logItem)
        
        let statusItem = NSMenuItem(title: "Speech Provider Status", action: #selector(showSpeechStatus), keyEquivalent: "")
        statusItem.target = self
        menu.addItem(statusItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit Hey, Listen!", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        self.statusItem?.menu = menu
    }
    
    private func setupComponents() {
        audioRecorder = AudioRecorder()
        textInjector = TextInjector()
        // soundWaveIndicator = SoundWaveIndicator() // Disabled to prevent crashes
        
        // Initialize Azure service (loads config automatically)
        _ = AzureService.shared
        
        globalKeyMonitor = GlobalKeyMonitor { [weak self] isPressed in
            if isPressed {
                self?.startListening()
            } else {
                self?.stopListening()
            }
        }
    }
    
    private func requestPermissions() {
        PermissionManager.shared.requestAllPermissions()
    }
    
    private func loadSecretsFromFile() -> (key: String, region: String) {
        // First try to load from UserDefaults (persistent storage)
        let preferences = UserPreferences.shared
        if let savedKey = preferences.azureApiKey, !savedKey.isEmpty {
            let savedRegion = preferences.azureRegion
            print("✅ Loaded Azure config from UserDefaults - Region: \(savedRegion)")
            return (savedKey, savedRegion)
        }
        
        // Fallback to secrets file if no saved preferences
        let secretsPath = "/Users/yadid/listen/secrets.txt"
        
        guard FileManager.default.fileExists(atPath: secretsPath),
              let secretsContent = try? String(contentsOfFile: secretsPath),
              !secretsContent.isEmpty else {
            print("❌ Failed to load secrets.txt and no saved preferences")
            return ("", "germanywestcentral")
        }
        
        let lines = secretsContent.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }
        
        let key = lines.first ?? ""
        let region = lines.count > 1 ? lines[1] : "germanywestcentral"
        
        // Save to UserDefaults for future use
        if !key.isEmpty {
            preferences.azureApiKey = key
            preferences.azureRegion = region
            print("💾 Saved Azure config to UserDefaults for persistence")
        }
        
        print("✅ Loaded secrets from file - Region: \(region)")
        return (key, region)
    }
    
    private func checkAndShowSetup() {
        // Check if setup is needed and show setup window if required
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            SetupWindowManager.shared.showSetupIfNeeded()
        }
    }
    
    @objc private func setupCompleted() {
        log("✅ Setup completed - refreshing speech services")
        // Refresh unified speech service with new configuration
        UnifiedSpeechService.shared.refreshAzureConfig()
    }
    
    @objc private func azureConfigChanged() {
        print("🔄 Azure configuration changed, reloading...")
        
        let preferences = UserPreferences.shared
        let azureKey = preferences.azureApiKey ?? ""
        let region = preferences.azureRegion
        
        speechRecognizer = AzureSpeechRecognizer(subscriptionKey: azureKey, region: region)
        print("✅ Speech recognizer updated with new configuration")
    }
    
    @objc private func openSetup() {
        log("🔧 Opening setup window...")
        SetupWindowManager.shared.showSetupWindow()
    }
    
    @objc private func openSettings() {
        print("Opening settings window...")
        
        if settingsWindow == nil {
            settingsWindow = SettingsWindow()
        }
        
        // Ensure the app becomes active and the window gets focus
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
        
        // Give the text field focus after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.settingsWindow?.focusApiKeyField()
        }
    }
    
    @objc private func showLogFile() {
        let logPath = Logger.shared.getLogPath()
        log("📁 Opening log file at: \(logPath)")
        NSWorkspace.shared.selectFile(logPath, inFileViewerRootedAtPath: "")
    }
    
    @objc private func showSpeechStatus() {
        let status = UnifiedSpeechService.shared.getProviderStatus()
        
        let alert = NSAlert()
        alert.messageText = "Speech Recognition Status"
        alert.informativeText = status
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func quitApp() {
        log("🛑 Quitting Hey, Listen! app")
        NSApp.terminate(nil)
    }
    
    private func startListening() {
        log("🎤 Starting to listen...")
        // soundWaveIndicator?.show() // Disabled to prevent crashes
        audioRecorder?.startRecording()
    }
    
    private func stopListening() {
        log("🛑 Stopping listening...")
        // soundWaveIndicator?.hide() // Disabled to prevent crashes
        
        // Get the recording URL and stop recording
        let recordingURL = audioRecorder?.currentRecordingURL
        audioRecorder?.stopRecording()
        
        // Process the file and actually call Azure now
        if let audioURL = recordingURL {
            log("📁 Got recording: \(audioURL.path)")
            
            // Use unified speech service (local first, Azure fallback)
            UnifiedSpeechService.shared.transcribe(audioURL: audioURL) { [weak self] text in
                log("📝 Speech result: \(text ?? "nil")")
                
                if let text = text, !text.isEmpty {
                    log("✅ Transcription: '\(text)'")
                    log("💉 About to inject text...")
                    self?.textInjector?.insertText(text)
                    log("💉 Text injection call completed")
                } else {
                    log("❌ No text to inject (empty or nil result)")
                }
            }
        }
        
        log("✅ Stop listening completed WITHOUT indicator")
    }
    
    private func testOnlyIndicatorHide() {
        print("🧪 Testing ONLY indicator hide...")
        // soundWaveIndicator?.hide() // Disabled to prevent crashes
        print("✅ Indicator hide test completed")
    }
    
    private func ensureConfigFileExists() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configPath = homeDir.appendingPathComponent("hey_listen_config.txt")
        
        if !FileManager.default.fileExists(atPath: configPath.path) {
            log("📝 Creating config file at \(configPath.path)")
            
            let configContent = """
# Hey Listen! Configuration File
# ==============================
# 
# Get your free Azure Speech API key at: https://portal.azure.com
# 1. Create a "Speech Service" resource (free tier available)
# 2. Copy your subscription key from "Keys and Endpoint"
# 3. Replace YOUR_API_KEY_HERE with your actual key
# 4. Optionally change the region to match where you created the resource

# Your Azure Speech API subscription key
API_KEY=YOUR_API_KEY_HERE

# Your Azure region (where you created the Speech resource)
REGION=germanywestcentral

# Available regions include:
# eastus, eastus2, westus, westus2, centralus
# northeurope, westeurope, germanywestcentral, uksouth, francecentral
# japaneast, japanwest, australiaeast, southeastasia, eastasia
# And many more...
"""
            
            do {
                try configContent.write(to: configPath, atomically: true, encoding: .utf8)
                log("✅ Config file created successfully")
            } catch {
                log("❌ Failed to create config file: \(error)")
            }
        }
    }
}