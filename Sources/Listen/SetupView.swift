import SwiftUI

struct SetupView: View {
    @State private var apiKey: String = ""
    @State private var region: String = "germanywestcentral"
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    let onComplete: () -> Void
    
    let availableRegions = [
        "eastus", "eastus2", "westus", "westus2", "centralus",
        "northeurope", "westeurope", "germanywestcentral", 
        "uksouth", "francecentral", "japaneast", "japanwest",
        "australiaeast", "southeastasia", "eastasia"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Welcome to Hey Listen!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Voice-to-Text for macOS")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            Divider()
            
            // Instructions
            VStack(alignment: .leading, spacing: 15) {
                Text("Setup Azure Speech API")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Go to portal.azure.com and sign in (free account available)")
                    Text("2. Create a new 'Speech Service' resource")
                    Text("3. Choose the free pricing tier (F0)")
                    Text("4. Copy your subscription key from 'Keys and Endpoint'")
                    Text("5. Paste the key below:")
                }
                .font(.body)
                .foregroundColor(.secondary)
                
                Button("Open Azure Portal") {
                    if let url = URL(string: "https://portal.azure.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            
            // Input form
            VStack(alignment: .leading, spacing: 15) {
                Text("Configuration")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Azure Speech API Key:")
                        .fontWeight(.medium)
                    
                    SecureField("Paste your Azure API key here", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.monospaced(.body)())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Region:")
                        .fontWeight(.medium)
                    
                    Picker("Region", selection: $region) {
                        ForEach(availableRegions, id: \.self) { region in
                            Text(region).tag(region)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            
            // Save button
            Button(action: saveConfiguration) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    Text(isLoading ? "Saving..." : "Save Configuration")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            .controlSize(.large)
            
            Spacer()
        }
        .padding(30)
        .frame(width: 600, height: 700)
        .alert("Configuration Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveConfiguration() {
        isLoading = true
        
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate API key format (basic check)
        guard !trimmedKey.isEmpty else {
            showError("Please enter your Azure API key")
            return
        }
        
        guard trimmedKey.count >= 20 else {
            showError("API key seems too short. Please check and try again.")
            return
        }
        
        // Save to UserDefaults
        let preferences = UserPreferences.shared
        preferences.azureApiKey = trimmedKey
        preferences.azureRegion = region
        
        // Also create the config file for backwards compatibility
        createConfigFile(apiKey: trimmedKey, region: region)
        
        // Simulate brief loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            onComplete()
        }
    }
    
    private func createConfigFile(apiKey: String, region: String) {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configPath = homeDir.appendingPathComponent("hey_listen_config.txt")
        
        let configContent = """
# Hey Listen! Configuration File
# ==============================
# This file was automatically created by Hey Listen!

# Your Azure Speech API subscription key
API_KEY=\(apiKey)

# Your Azure region (where you created the Speech resource)
REGION=\(region)
"""
        
        do {
            try configContent.write(to: configPath, atomically: true, encoding: .utf8)
            print("✅ Configuration file created at: \(configPath.path)")
        } catch {
            print("⚠️ Failed to create config file: \(error)")
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showError = true
        isLoading = false
    }
}

#Preview {
    SetupView {
        print("Setup completed")
    }
}