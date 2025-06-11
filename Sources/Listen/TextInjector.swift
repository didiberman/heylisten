import ApplicationServices
import Carbon
import Cocoa

class TextInjector {
    private var hasShownAccessibilityAlert = false
    
    func insertText(_ text: String) {
        guard AXIsProcessTrusted() else {
            print("❌ Accessibility permissions not granted - cannot inject text")
            print("📋 Text copied to clipboard instead: '\(text)'")
            
            // At least copy to clipboard so user can paste manually
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(text, forType: .string)
            
            // Show permission prompt to help user enable accessibility (only once)
            if !hasShownAccessibilityAlert {
                hasShownAccessibilityAlert = true
                DispatchQueue.main.async {
                    self.showAccessibilitySetupAlert()
                }
            }
            return
        }
        
        print("💉 Injecting text: '\(text)'")
        
        // Method 1: Copy to clipboard and paste
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // Small delay to ensure clipboard is set
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Simulate Cmd+V
            let source = CGEventSource(stateID: .hidSystemState)
            
            // Press Cmd
            let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 55, keyDown: true)
            cmdDown?.flags = .maskCommand
            cmdDown?.post(tap: .cghidEventTap)
            
            // Press V
            let vDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true)
            vDown?.flags = .maskCommand
            vDown?.post(tap: .cghidEventTap)
            
            // Release V
            let vUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
            vUp?.post(tap: .cghidEventTap)
            
            // Release Cmd
            let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 55, keyDown: false)
            cmdUp?.post(tap: .cghidEventTap)
            
            print("✅ Text injection complete")
        }
    }
    
    private func showAccessibilitySetupAlert() {
        let alert = NSAlert()
        alert.messageText = "Enable Accessibility to Auto-Type"
        alert.informativeText = "Text was copied to clipboard, but for automatic typing, please:\n\n1. Click 'Open Settings'\n2. Find 'Hey Listen!' in the list\n3. Check the box to enable it\n4. Try recording again!"
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Just Use Clipboard")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Open System Settings directly to Accessibility page
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}