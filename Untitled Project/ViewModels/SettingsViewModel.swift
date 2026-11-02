import Foundation
import SwiftUI
import Observation

/// Step 0: ViewModel managing Application Settings and Mock Configuration
@Observable
@MainActor
public final class SettingsViewModel {
    public var isDarkMode: Bool = false
    public var enableHapticFeedback: Bool = true
    public var enableSounds: Bool = true
    public var cacheSizeMB: Int = 128
    public var selectedTheme: String = "Indigo"
    public var simulatedLatency: Double = 0.8 {
        didSet {
            MockAPIService.shared.simulatedLatency = simulatedLatency
            DummyJSONAPIService.shared.simulatedLatency = simulatedLatency
            AppLogger.step(2, title: "Settings Changed", details: "Simulated latency updated to \(String(format: "%.1f", simulatedLatency))s")
        }
    }
    public var simulateNetworkError: Bool = false {
        didSet {
            MockAPIService.shared.shouldSimulateError = simulateNetworkError
            DummyJSONAPIService.shared.shouldSimulateError = simulateNetworkError
            AppLogger.step(2, title: "Settings Changed", details: "Simulate network error set to \(simulateNetworkError)")
        }
    }
    public var showClearCacheAlert: Bool = false
    public var cacheClearedToast: Bool = false
    
    public let themeOptions = ["Indigo", "Blue", "Teal", "Purple", "Orange", "Pink"]
    
    public init() {
        AppLogger.step(1, title: "ViewModel Initialized", details: "SettingsViewModel initialized.")
    }
    
    public func clearCache() {
        AppLogger.step(2, title: "User Action: Clear Cache", details: "Clearing \(cacheSizeMB) MB of cached data.")
        cacheSizeMB = 0
        cacheClearedToast = true
    }
}
