import SwiftUI

@main
struct MyApp: App {
    init() {
        AppLogger.step(0, title: "Application Launched", details: "Step 0: App delegate / lifecycle entry point executed.")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
