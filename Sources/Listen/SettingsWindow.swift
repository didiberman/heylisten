import Cocoa

class SettingsWindow: NSWindow {
    private var apiKeyField: NSTextField!
    private var regionPopup: NSPopUpButton!
    private var saveButton: NSButton!
    private var testButton: NSButton!
    private var statusLabel: NSTextField!
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 350),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
        setupUI()
        loadCurrentSettings()
    }
    
    private func setupWindow() {
        title = "Hey Listen! Settings"
        isReleasedWhenClosed = false
        center()
        
        // Ensure window can receive input
        level = .normal
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    private func setupUI() {
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 350))
        self.contentView = contentView
        
        // Title
        let titleLabel = NSTextField(labelWithString: "Azure Speech API Configuration")
        titleLabel.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.frame = NSRect(x: 20, y: 290, width: 460, height: 24)
        contentView.addSubview(titleLabel)
        
        // API Key section
        let apiKeyLabel = NSTextField(labelWithString: "Azure Subscription Key:")
        apiKeyLabel.frame = NSRect(x: 20, y: 250, width: 150, height: 20)
        contentView.addSubview(apiKeyLabel)
        
        apiKeyField = NSTextField(frame: NSRect(x: 20, y: 220, width: 460, height: 24))
        apiKeyField.stringValue = ""
        apiKeyField.placeholderString = "Enter your Azure Speech API subscription key"
        apiKeyField.isEditable = true
        apiKeyField.isSelectable = true
        apiKeyField.isBordered = true
        apiKeyField.isBezeled = true
        apiKeyField.bezelStyle = .roundedBezel
        apiKeyField.focusRingType = .default
        apiKeyField.cell?.usesSingleLineMode = true
        apiKeyField.cell?.wraps = false
        apiKeyField.cell?.isScrollable = true
        contentView.addSubview(apiKeyField)
        
        // Region section
        let regionLabel = NSTextField(labelWithString: "Azure Region:")
        regionLabel.frame = NSRect(x: 20, y: 180, width: 150, height: 20)
        contentView.addSubview(regionLabel)
        
        regionPopup = NSPopUpButton(frame: NSRect(x: 20, y: 150, width: 200, height: 24))
        regionPopup.addItems(withTitles: [
            "eastus",
            "eastus2", 
            "westus",
            "westus2",
            "centralus",
            "northcentralus",
            "southcentralus",
            "westcentralus",
            "canadacentral",
            "brazilsouth",
            "northeurope",
            "westeurope",
            "germanywestcentral",
            "uksouth",
            "francecentral",
            "switzerlandnorth",
            "japaneast",
            "japanwest",
            "australiaeast",
            "southeastasia",
            "eastasia",
            "koreacentral",
            "southafricanorth",
            "centralindia"
        ])
        contentView.addSubview(regionPopup)
        
        // Status label
        statusLabel = NSTextField(labelWithString: "")
        statusLabel.frame = NSRect(x: 20, y: 110, width: 460, height: 20)
        statusLabel.textColor = .systemGray
        statusLabel.font = NSFont.systemFont(ofSize: 12)
        contentView.addSubview(statusLabel)
        
        // Buttons
        saveButton = NSButton(title: "Save", target: self, action: #selector(saveSettings))
        saveButton.frame = NSRect(x: 300, y: 40, width: 80, height: 32)
        saveButton.bezelStyle = .rounded
        contentView.addSubview(saveButton)
        
        testButton = NSButton(title: "Test Connection", target: self, action: #selector(testConnection))
        testButton.frame = NSRect(x: 190, y: 40, width: 100, height: 32)
        testButton.bezelStyle = .rounded
        contentView.addSubview(testButton)
        
        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(closeWindow))
        cancelButton.frame = NSRect(x: 400, y: 40, width: 80, height: 32)
        cancelButton.bezelStyle = .rounded
        contentView.addSubview(cancelButton)
        
        // Instructions
        let instructionsLabel = NSTextField(wrappingLabelWithString: """
        To get your Azure Speech API key:
        1. Go to https://portal.azure.com
        2. Create a Speech Service resource (free tier available)
        3. Copy the subscription key from Keys and Endpoint section
        """)
        instructionsLabel.frame = NSRect(x: 20, y: 70, width: 460, height: 60)
        instructionsLabel.font = NSFont.systemFont(ofSize: 11)
        instructionsLabel.textColor = .secondaryLabelColor
        contentView.addSubview(instructionsLabel)
    }
    
    private func loadCurrentSettings() {
        let defaults = UserDefaults.standard
        
        if let savedKey = defaults.string(forKey: "azureApiKey") {
            apiKeyField.stringValue = savedKey
        }
        
        let savedRegion = defaults.string(forKey: "azureRegion") ?? "germanywestcentral"
        regionPopup.selectItem(withTitle: savedRegion)
        
        updateStatus("Current settings loaded")
    }
    
    @objc private func saveSettings() {
        let apiKey = apiKeyField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let region = regionPopup.selectedItem?.title ?? "germanywestcentral"
        
        guard !apiKey.isEmpty else {
            updateStatus("Please enter an API key", isError: true)
            return
        }
        
        // Basic validation - Azure keys are typically 32 characters
        guard apiKey.count >= 20 else {
            updateStatus("API key seems too short. Please check your key.", isError: true)
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.set(apiKey, forKey: "azureApiKey")
        defaults.set(region, forKey: "azureRegion")
        
        // Notify AppDelegate to reload configuration
        NotificationCenter.default.post(name: .azureConfigChanged, object: nil)
        
        updateStatus("Settings saved successfully!")
        
        // Close window after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.close()
        }
    }
    
    @objc private func testConnection() {
        let apiKey = apiKeyField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let region = regionPopup.selectedItem?.title ?? "germanywestcentral"
        
        guard !apiKey.isEmpty else {
            updateStatus("Please enter an API key first", isError: true)
            return
        }
        
        updateStatus("Testing connection...")
        testButton.isEnabled = false
        
        // Create a simple test request to validate the key
        let endpoint = "https://\(region).api.cognitive.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US"
        
        guard let url = URL(string: endpoint) else {
            updateStatus("Invalid region configuration", isError: true)
            testButton.isEnabled = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("audio/wav", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10.0
        
        // Send empty request just to test authentication
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                self?.testButton.isEnabled = true
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 401 {
                        self?.updateStatus("Invalid API key", isError: true)
                    } else if httpResponse.statusCode == 400 {
                        // 400 is expected for empty audio data, but means auth worked
                        self?.updateStatus("Connection successful! API key is valid.", isError: false)
                    } else {
                        self?.updateStatus("Connection test completed (status: \(httpResponse.statusCode))")
                    }
                } else if let error = error {
                    self?.updateStatus("Connection failed: \(error.localizedDescription)", isError: true)
                } else {
                    self?.updateStatus("Unexpected response", isError: true)
                }
            }
        }.resume()
    }
    
    @objc private func closeWindow() {
        close()
    }
    
    private func updateStatus(_ message: String, isError: Bool = false) {
        statusLabel.stringValue = message
        statusLabel.textColor = isError ? .systemRed : .systemGreen
    }
    
    func focusApiKeyField() {
        makeFirstResponder(apiKeyField)
    }
}

extension Notification.Name {
    static let azureConfigChanged = Notification.Name("azureConfigChanged")
}