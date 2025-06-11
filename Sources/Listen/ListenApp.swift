import SwiftUI
import Cocoa

@main
struct ListenApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Don't create any windows - pure menu bar app
        Settings {
            EmptyView()
        }
    }
}