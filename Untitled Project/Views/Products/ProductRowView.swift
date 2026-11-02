import SwiftUI

/// Step 1: Component View representing a single row in the Product Catalog
public struct ProductRowView: View {
    public let product: Product
    public let onToggleFavorite: () -> Void
    public let onQuickAddToCart: () -> Void
    
    public init(
        product: Product,
        onToggleFavorite: @escaping () -> Void,
        onQuickAddToCart: @escaping () -> Void
    ) {
        self.product = product
        self.onToggleFavorite = onToggleFavorite
        self.onQuickAddToCart = onQuickAddToCart
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Product Icon Hero
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 64, height: 64)
                
                if let thumbnail = product.thumbnail, let url = URL(string: thumbnail) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure, .empty:
                            Image(systemName: product.systemImageName)
                                .font(.system(size: 28))
                                .foregroundStyle(.tint)
                        @unknown default:
                            Image(systemName: product.systemImageName)
                                .font(.system(size: 28))
                                .foregroundStyle(.tint)
                        }
                    }
                } else {
                    Image(systemName: product.systemImageName)
                        .font(.system(size: 28))
                        .foregroundStyle(.tint)
                }
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(product.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button {
                        onToggleFavorite()
                    } label: {
                        Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(product.isFavorite ? .red : .secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                HStack(spacing: 6) {
                    StatusBadgeView(
                        text: product.category.rawValue,
                        systemImage: product.category.icon,
                        color: .blue
                    )
                    
                    if product.inStock {
                        StatusBadgeView(text: "In Stock", color: .green)
                    } else {
                        StatusBadgeView(text: "Out of Stock", color: .gray)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", product.rating))
                        .font(.caption.weight(.bold))
                    Text("(\(product.ratingCount))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if product.inStock {
                Button {
                    onQuickAddToCart()
                } label: {
                    Label("Add to Cart", systemImage: "cart.badge.plus")
                }
                .tint(.green)
            }
            
            Button {
                onToggleFavorite()
            } label: {
                Label(product.isFavorite ? "Unfavorite" : "Favorite", systemImage: product.isFavorite ? "heart.slash" : "heart")
            }
            .tint(.orange)
        }
    }
}
