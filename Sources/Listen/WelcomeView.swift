import SwiftUI

struct WelcomeView: View {
    @State private var selectedKeyCode: Int = 63 // Default fn key
    @State private var showingKeyPicker = false
    @State private var hasCompletedSetup = false
    
    let onSetupComplete: (Int) -> Void
    
    private let keyOptions = [
        (name: "Fn (Function)", code: 63, description: "Bottom left modifier key"),
        (name: "Control (Left)", code: 59, description: "Control key on the left"),
        (name: "Control (Right)", code: 62, description: "Control key on the right"),
        (name: "Option (Left)", code: 58, description: "Alt/Option key on the left"),
        (name: "Option (Right)", code: 61, description: "Alt/Option key on the right"),
        (name: "Command (Left)", code: 55, description: "Cmd key on the left"),
        (name: "Command (Right)", code: 54, description: "Cmd key on the right"),
        (name: "Space Bar", code: 49, description: "Space bar"),
        (name: "Tab", code: 48, description: "Tab key"),
        (name: "F1", code: 122, description: "Function key F1"),
        (name: "F2", code: 120, description: "Function key F2"),
        (name: "F3", code: 99, description: "Function key F3"),
        (name: "F4", code: 118, description: "Function key F4"),
        (name: "F5", code: 96, description: "Function key F5"),
        (name: "F6", code: 97, description: "Function key F6")
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Hey, Listen!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Voice-to-text made simple")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // Description
            VStack(spacing: 12) {
                Text("Hold a key, speak, release to transcribe")
                    .font(.headline)
                
                Text("Choose which key you'd like to use for recording:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Key Selection
            VStack(spacing: 16) {
                Button(action: {
                    showingKeyPicker = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Trigger Key")
                                .font(.headline)
                            
                            Text(selectedKeyName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(selectedKeyDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.controlBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $showingKeyPicker) {
                    KeyPickerView(
                        selectedKeyCode: $selectedKeyCode,
                        keyOptions: keyOptions,
                        onDismiss: { showingKeyPicker = false }
                    )
                }
                
                // Usage instructions
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    
                    Text("Hold key → Speak → Release → Text appears")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Get Started Button
            VStack(spacing: 16) {
                Button(action: {
                    hasCompletedSetup = true
                    onSetupComplete(selectedKeyCode)
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Get Started")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("Hey, Listen! will run in your menu bar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 40)
        .frame(width: 500, height: 700)
    }
    
    private var selectedKeyName: String {
        keyOptions.first { $0.code == selectedKeyCode }?.name ?? "Unknown"
    }
    
    private var selectedKeyDescription: String {
        keyOptions.first { $0.code == selectedKeyCode }?.description ?? ""
    }
}

struct KeyPickerView: View {
    @Binding var selectedKeyCode: Int
    let keyOptions: [(name: String, code: Int, description: String)]
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Choose Trigger Key")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button("Done") {
                    onDismiss()
                }
                .padding()
            }
            
            Divider()
            
            // Key list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(keyOptions, id: \.code) { option in
                        Button(action: {
                            selectedKeyCode = option.code
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text(option.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedKeyCode == option.code {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(
                                selectedKeyCode == option.code 
                                    ? Color.blue.opacity(0.1)
                                    : Color.clear
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if option.code != keyOptions.last?.code {
                            Divider()
                                .padding(.leading)
                        }
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
    }
}

#Preview {
    WelcomeView { keyCode in
        print("Selected key code: \(keyCode)")
    }
}