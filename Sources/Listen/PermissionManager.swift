import AVFoundation
import Speech
import ApplicationServices
import Cocoa

class PermissionManager {
    static let shared = PermissionManager()
    
    private init() {}
    
    func requestAllPermissions() {
        requestMicrophonePermission()
        requestSpeechRecognitionPermission()
        checkAccessibilityPermissions()
    }
    
    private func requestMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            print("Microphone permission granted")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("Microphone permission granted")
                    } else {
                        print("Microphone permission denied")
                        self.showMicrophonePermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            print("Microphone permission denied")
            showMicrophonePermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Speech recognition permission granted")
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition permission denied")
                    self.showSpeechPermissionAlert()
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func checkAccessibilityPermissions() {
        if !AXIsProcessTrusted() {
            print("Accessibility permissions not granted")
            showAccessibilityPermissionAlert()
        } else {
            print("Accessibility permissions granted")
        }
    }
    
    private func showMicrophonePermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Microphone Access Required"
        alert.informativeText = "Listen needs microphone access to record audio. Please enable it in System Settings > Privacy & Security > Microphone."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showSpeechPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Speech Recognition Access Required"
        alert.informativeText = "Listen needs speech recognition access to transcribe audio. Please enable it in System Settings > Privacy & Security > Speech Recognition."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showAccessibilityPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Access Required"
        alert.informativeText = "Hey Listen! needs accessibility access to inject transcribed text directly where you're typing. Click 'Open Settings' to grant permission."
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Open System Settings directly to Accessibility page
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    // Check if all required permissions are granted
    func allPermissionsGranted() -> Bool {
        let microphoneGranted = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
        let speechGranted = SFSpeechRecognizer.authorizationStatus() == .authorized
        let accessibilityGranted = AXIsProcessTrusted()
        
        return microphoneGranted && speechGranted && accessibilityGranted
    }
}