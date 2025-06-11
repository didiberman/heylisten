# Hey Listen! 🎙️

A macOS voice-to-text application that records speech when you hold a function key and transcribes it using Azure Speech API, then injects the text where your cursor is.

## Features

- Hold function key to record speech
- Azure Speech-to-Text transcription
- Automatic text injection at cursor location
- Menu bar application (no console window)
- Persistent user preferences
- Comprehensive logging

## Quick Start

1. **Download**: Get `HeyListen-READY-FOR-FRIENDS.app`
2. **Setup Azure**: 
   - Get an Azure Speech API key
   - Create `azure_config.txt` in your home directory with:
     ```
     YOUR_AZURE_API_KEY
     germanywestcentral
     ```
3. **Run**: Double-click the app
4. **Permissions**: Grant microphone, speech recognition, and accessibility permissions when prompted
5. **Use**: Hold fn key to record, release to transcribe and inject text

## Requirements

- macOS 10.15+
- Azure Speech Service API key
- Microphone access
- Accessibility permissions (for text injection)

## Permissions

The app will request:
- **Microphone**: To record your voice
- **Speech Recognition**: For local speech processing
- **Accessibility**: To inject transcribed text automatically

## Building from Source

```bash
swift build -c release
```

## Architecture

- **Swift/SwiftUI** for native macOS integration
- **AVFoundation** for audio recording
- **Azure Speech API** for transcription
- **Accessibility API** for text injection
- **Menu bar app** design for background operation

## Files

- `Sources/Listen/` - Source code
- `HeyListen-READY-FOR-FRIENDS.app` - Ready-to-use compiled app
- `azure_config_sample.txt` - Sample configuration file

## License

Open source - feel free to modify and distribute!