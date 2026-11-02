import SwiftUI

/// Custom badge view for displaying categories, stock statuses, or tags
public struct StatusBadgeView: View {
    public let text: String
    public let systemImage: String?
    public let color: Color
    
    public init(text: String, systemImage: String? = nil, color: Color = .blue) {
        self.text = text
        self.systemImage = systemImage
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption2)
            }
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
}
