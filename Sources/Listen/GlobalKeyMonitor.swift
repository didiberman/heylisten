import Cocoa
import Foundation

class GlobalKeyMonitor {
    private var globalMonitor: Any?
    private let callback: (Bool) -> Void
    private var isMonitoring = false
    private var targetKeyCode: UInt16 = 63 // fn key
    private var fnKeyPressed = false
    
    init(callback: @escaping (Bool) -> Void) {
        self.callback = callback
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func setTargetKey(_ keyCode: UInt16) {
        targetKeyCode = keyCode
    }
    
    private func startMonitoring() {
        guard !isMonitoring else { return }
        
        // Monitor for fn key using NSEvent.flagsChanged
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
        }
        
        // Also add local monitor for when our app is active
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
            return event // Always return the event to not consume it
        }
        
        isMonitoring = true
        print("Global fn key monitoring started")
    }
    
    private func stopMonitoring() {
        guard isMonitoring else { return }
        
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        
        isMonitoring = false
        print("Global fn key monitoring stopped")
    }
    
    private func handleFlagsChanged(_ event: NSEvent) {
        // Check if this is the fn key (keyCode 63)
        guard event.keyCode == targetKeyCode else { return }
        
        let fnCurrentlyPressed = event.modifierFlags.contains(.function)
        
        // Only trigger callback on state changes
        if fnCurrentlyPressed != fnKeyPressed {
            fnKeyPressed = fnCurrentlyPressed
            print("fn key \(fnCurrentlyPressed ? "pressed" : "released")")
            callback(fnCurrentlyPressed)
        }
    }
}