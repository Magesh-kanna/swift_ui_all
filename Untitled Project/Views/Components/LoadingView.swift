import SwiftUI

/// Reusable Loading View displaying an indeterminate ProgressView and status text
public struct LoadingView: View {
    public let message: String
    
    public init(message: String = "Loading data...") {
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.3)
                .tint(.accentColor)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onAppear {
            AppLogger.step(8, title: "View Lifecycle", details: "LoadingView appeared with message: '\(message)'")
        }
    }
}
