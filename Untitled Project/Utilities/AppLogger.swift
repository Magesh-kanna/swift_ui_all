import Foundation
import os

/// Step-by-Step Educational Logger for the MVVM Architecture Flow
public enum AppLogger {
    private static let logger = Logger(subsystem: "com.example.MyApp", category: "MVVMFlow")
    
    public static func step(_ stepNumber: Int, title: String, details: String = "", file: String = #file, function: String = #function) {
        let fileName = (file as NSString).lastPathComponent
        let formatted = "📍 [STEP \(stepNumber): \(title.uppercased())] [\(fileName)::\(function)] \(details)"
        print(formatted)
        logger.info("\(formatted, privacy: .public)")
    }
    
    public static func newStep() {
        print("newStep")
    }
}
