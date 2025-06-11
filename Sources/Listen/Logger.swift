import Foundation

class Logger {
    static let shared = Logger()
    
    private let logFileURL: URL
    private let dateFormatter: DateFormatter
    
    private init() {
        // Create log file in user's home directory
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        self.logFileURL = homeDirectory.appendingPathComponent("hey_listen.log")
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        // Write initial log entry
        log("📅 Hey Listen log started")
    }
    
    func log(_ message: String) {
        let timestamp = dateFormatter.string(from: Date())
        let logEntry = "[\(timestamp)] \(message)\n"
        
        // Print to console (existing behavior)
        print(message)
        
        // Write to log file
        if let data = logEntry.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                // Append to existing file
                if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                // Create new file
                try? data.write(to: logFileURL)
            }
        }
    }
    
    func getLogPath() -> String {
        return logFileURL.path
    }
}

// Global logging function for easy use
func log(_ message: String) {
    Logger.shared.log(message)
}