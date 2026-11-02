import SwiftUI

/// Reusable Empty State View for empty lists or search results
public struct EmptyStateView: View {
    public let icon: String
    public let title: String
    public let subtitle: String
    public let actionTitle: String?
    public let action: (() -> Void)?
    
    public init(
        icon: String = "tray",
        title: String = "No Items Found",
        subtitle: String = "Try adjusting your filters or search query.",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)
            
            Text(title)
                .font(.title3.weight(.semibold))
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let actionTitle, let action {
                Button(action: {
                    AppLogger.step(2, title: "User Action", details: "Empty state action tapped: '\(actionTitle)'")
                    action()
                }) {
                    Text(actionTitle)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
