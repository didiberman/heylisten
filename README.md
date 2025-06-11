# Listenman

**Listenman** is a lightweight macOS menu bar app that transcribes your voice into text and injects it into any application. It supports both local (on-device) and Azure cloud speech recognition, making it fast, private, and reliable.

## Features

- 🎙️ **Menu Bar App**: Runs quietly in your menu bar, always ready to transcribe.
- 🗣️ **Voice-to-Text**: Hold a configurable key, speak, and have your words typed into any app.
- 🔒 **Privacy First**: Uses on-device speech recognition when available; falls back to Azure only if needed.
- ☁️ **Azure Integration**: Supports Microsoft Azure Speech-to-Text for high-accuracy transcription.
- ⚡ **Quick Setup**: Easy configuration for API keys and preferences.
- 🛠️ **Customizable**: Choose your activation key and tweak settings to fit your workflow.
- 📝 **Logging**: Built-in logging for troubleshooting and transparency.

## Screenshots

<!-- Add screenshots here if available -->
![Menu Bar Screenshot](screenshot-menubar.png)
![Setup Window Screenshot](screenshot-setup.png)

## Installation

### Prerequisites

- macOS 12.0 or later
- Xcode 14+ (for building from source)
- An Azure Speech API key (for cloud transcription)

### Download

- [Releases](https://github.com/yourusername/listenman/releases) (coming soon)

### Build from Source

1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/listenman.git
   cd listenman/Sources
   ```
2. Open `Listen.xcodeproj` in Xcode.
3. Build and run the app.

## Usage

1. Launch Listenman. A microphone icon 🎙️ will appear in your menu bar.
2. Open the setup window from the menu to enter your Azure API key (optional, for cloud transcription).
3. Select your preferred activation key in settings.
4. Hold the activation key, speak, and release to transcribe. The text will be injected into your current app.

## Configuration

- **API Key**: Enter your Azure Speech API key in the setup window or place it in a `secrets.txt` file in your home directory.
- **Region**: Set your Azure region in the setup window or as the second line in `secrets.txt`.
- **Activation Key**: Choose which key triggers voice recording in the settings.

### `secrets.txt` Format

```
YOUR_AZURE_API_KEY
YOUR_AZURE_REGION   # e.g., germanywestcentral
```

## Architecture

- **SwiftUI** for UI components and menu bar integration.
- **Cocoa** for macOS-specific features.
- **LocalSpeechRecognizer** for on-device transcription.
- **AzureSpeechRecognizer** and **AzureService** for cloud transcription.
- **TextInjector** for injecting transcribed text into any app.
- **Logger** for logging and troubleshooting.

## Security & Privacy

- Local transcription is used by default when available.
- Azure transcription only sends audio to Microsoft if local recognition fails or is unavailable.
- No audio or transcription data is stored or sent to third parties except Azure (if enabled).

## Troubleshooting

- Check the log file from the menu for detailed error messages.
- Ensure microphone permissions are granted.
- For Azure, verify your API key and region.

## Contributing

Contributions are welcome! Please open issues or pull requests for bug fixes, features, or documentation improvements.

## License

[MIT License](LICENSE)

## Credits

- Built with [Swift](https://swift.org/) and [SwiftUI](https://developer.apple.com/xcode/swiftui/).
- Azure Speech-to-Text by [Microsoft](https://azure.microsoft.com/en-us/services/cognitive-services/speech-to-text/). 
