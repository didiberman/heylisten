# Hey, Listen! – Voice-to-Text for macOS

**Hey, Listen!** is a lightweight, privacy-friendly macOS menu bar app that lets you transcribe your voice into text anywhere on your Mac. Hold a configurable key, speak, and release—the text appears instantly in your active application.

## Features

- **Push-to-Talk Transcription:** Hold a key (e.g., Fn, Ctrl, Cmd, etc.), speak, and release to transcribe.
- **Menu Bar Integration:** Runs quietly in your menu bar, always ready.
- **Configurable Trigger Key:** Choose your preferred key for recording.
- **Azure Speech-to-Text:** Uses Microsoft Azure for accurate, fast transcription.
- **Automatic Text Injection:** Inserts transcribed text directly into the active app, or copies to clipboard if permissions are missing.
- **Visual Listening Indicator:** Animated overlay shows when the app is listening.
- **Privacy-First:** No data is stored or sent anywhere except to Azure for transcription.

## Screenshots

*(Add screenshots of the welcome screen, menu bar icon, and listening indicator here)*

## Getting Started

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15+ (for building from source)
- An [Azure Speech Service](https://portal.azure.com) subscription key (free tier available)

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/listen.git
   cd listen
   ```

2. **Configure Azure Speech Service:**
   - Go to the [Azure Portal](https://portal.azure.com) and create a Speech Service resource.
   - Copy your subscription key and region.
   - Open `Sources/Listen/AppDelegate.swift` and replace the placeholder in:
     ```swift
     let azureKey = "YOUR_AZURE_SUBSCRIPTION_KEY"
     speechRecognizer = AzureSpeechRecognizer(subscriptionKey: azureKey, region: "YOUR_REGION")
     ```
   - (See `azure_config.txt` for more details.)

3. **Build and run:**
   - Open the project in Xcode and run, or use SwiftPM:
     ```sh
     swift build
     swift run Listen
     ```

### Permissions

On first launch, the app will request:
- **Microphone access** (to record audio)
- **Speech recognition access** (to transcribe)
- **Accessibility access** (to inject text and monitor key presses)

Grant these in **System Settings > Privacy & Security**.

## Usage

1. Launch the app. The welcome screen will guide you to select your preferred trigger key.
2. After setup, the app runs in your menu bar (microphone icon).
3. **To transcribe:**  
   - Hold your chosen key (e.g., Fn), speak, and release.
   - The transcribed text will appear in your active app, or be copied to your clipboard if accessibility permissions are missing.

## How It Works

- **Global Key Monitoring:** Listens for your chosen key using macOS accessibility APIs.
- **Audio Recording:** Records your voice in WAV format (16kHz, mono) for Azure compatibility.
- **Speech Recognition:** Uploads the audio to Azure's Speech-to-Text API and receives the transcription.
- **Text Injection:** Pastes the result into the current app using simulated Cmd+V, or copies to clipboard as fallback.
- **Visual Feedback:** Shows an animated "Listening..." indicator while recording.

## Project Structure

```
Sources/Listen/
├── AppDelegate.swift         # App lifecycle, menu bar, main logic
├── ListenApp.swift           # SwiftUI entry point, onboarding
├── WelcomeView.swift         # Onboarding UI and key selection
├── GlobalKeyMonitor.swift    # Monitors global key events
├── AudioRecorder.swift       # Handles audio recording
├── SpeechRecognizer.swift    # Azure Speech-to-Text integration
├── TextInjector.swift        # Injects text into active app
├── ListeningIndicator.swift  # Visual listening overlay
├── PermissionManager.swift   # Handles permissions
```

## Configuration

See [`azure_config.txt`](azure_config.txt) for step-by-step Azure setup instructions.

## License

MIT License. See [LICENSE](LICENSE) for details. 