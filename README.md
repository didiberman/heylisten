# Hey Listen! 🎙️

**Voice-to-Text for macOS - Transcribe speech anywhere with a simple key press**

Hey Listen! is a lightweight macOS menu bar app that transcribes your speech to text using Azure Speech API. Just hold a key, speak, release, and your words appear where your cursor is!

## ✨ Features

- 🎤 **Push-to-talk recording** - Hold fn key (or any key you choose)
- 🧠 **Azure Speech AI** - High-quality transcription powered by Microsoft Azure
- ⚡ **System-wide text injection** - Works in any app where you can type
- 🔧 **Persistent settings** - Remembers your preferences
- 📝 **Comprehensive logging** - Easy troubleshooting with log files
- 🍎 **Native macOS** - Clean menu bar integration

## 🚀 Quick Start

### 1. Build the App
```bash
./build_production.sh
```

### 2. Configure Azure API
1. Open `~/hey_listen_config.txt` (created automatically on first run)
2. Replace `YOUR_API_KEY_HERE` with your Azure Speech API key
3. Optionally change the region if needed

### 3. Get Azure API Key
1. Go to [Azure Portal](https://portal.azure.com)
2. Create a "Speech Service" resource (free tier available - 5 hours/month)
3. Copy your subscription key from "Keys and Endpoint"

### 4. Grant Permissions
- **Microphone**: For recording your speech
- **Accessibility**: For injecting text into other apps

## 🎯 How to Use

1. **Start recording**: Hold the fn key (or your chosen key)
2. **Speak clearly**: Say what you want to transcribe
3. **Stop recording**: Release the key
4. **Get results**: Transcribed text appears at your cursor location

## 🔧 Configuration

### Config File: `~/hey_listen_config.txt`
```
# Your Azure Speech API subscription key
API_KEY=your_azure_key_here

# Your Azure region (where you created the Speech resource)
REGION=germanywestcentral
```

### Available Regions
- `eastus`, `eastus2`, `westus`, `westus2`, `centralus`
- `northeurope`, `westeurope`, `germanywestcentral`, `uksouth`, `francecentral`
- `japaneast`, `japanwest`, `australiaeast`, `southeastasia`, `eastasia`
- And many more...

## 📊 Monitoring & Troubleshooting

### Log File
All activity is logged to `~/hey_listen.log` with timestamps:
- Access via Menu Bar → "Show Log File"
- Contains detailed request/response information
- Helpful for debugging Azure API issues

### Menu Bar Options
- **Settings**: Configure API key and preferences
- **Show Log File**: Open log file in Finder
- **Quit**: Exit the application

## 🔒 Privacy & Security

- **Audio files**: Temporarily saved, immediately deleted after processing
- **API key**: Stored locally in your config file (never transmitted except to Azure)
- **Transcribed text**: Only injected where you specify, not stored
- **Network**: Only communicates with Azure Speech API

## 🐛 Troubleshooting

### Common Issues

**"Resource not found" error:**
- Check your Azure region in config file
- Verify your API key is correct
- Ensure Azure Speech Service is active

**No text injection:**
- Grant Accessibility permissions in System Preferences
- Try restarting the app after granting permissions

**Recording not working:**
- Grant Microphone permissions in System Preferences
- Check if another app is using the microphone

**App crashes:**
- Check the log file: `~/hey_listen.log`
- Ensure you're running macOS 13.0 or later

### Log Analysis
The log file contains detailed information about:
- Azure API requests and responses
- Audio file processing
- Permission status
- Error details

## 🏗️ Development

### Requirements
- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

### Build from Source
```bash
git clone <repository>
cd listen
swift build
```

### Project Structure
```
Sources/Listen/
├── AppDelegate.swift      # Main app logic
├── AudioRecorder.swift    # Audio recording
├── MinimalAzure.swift     # Azure API client
├── TextInjector.swift     # Text injection
├── GlobalKeyMonitor.swift # Key monitoring
├── Logger.swift           # Logging system
└── UserPreferences.swift  # Settings persistence
```

## 📄 License

This project is available under the MIT License.

## 🤝 Contributing

Contributions welcome! Please feel free to submit issues and pull requests.

---

**Made with ❤️ for seamless voice-to-text on macOS**
