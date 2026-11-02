import SwiftUI

/// Detail screen for a selected product demonstrating data passing, NavigationStack, async API details fetching, and UI components
public struct ProductDetailView: View {
    public let product: Product
    public let cartViewModel: CartViewModel
    public let onToggleFavorite: () -> Void
    private let apiService: APIServiceProtocol
    
    @State private var detailedProduct: Product?
    @State private var isLoadingDetails: Bool = false
    @State private var quantity: Int = 1
    @State private var showAddedToast: Bool = false
    @State private var selectedColorOption: String = "Space Gray"
    @State private var isBookmarked: Bool = false
    @State private var selectedImageIndex: Int = 0
    
    private let colorOptions = ["Space Gray", "Silver", "Midnight", "Starlight"]
    
    private var displayProduct: Product {
        detailedProduct ?? product
    }
    
    public init(
        product: Product,
        cartViewModel: CartViewModel,
        apiService: APIServiceProtocol = DummyJSONAPIService.shared,
        onToggleFavorite: @escaping () -> Void
    ) {
        self.product = product
        self.cartViewModel = cartViewModel
        self.apiService = apiService
        self.onToggleFavorite = onToggleFavorite
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero Image Card
                heroImageSection
                
                // Title and Pricing Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        StatusBadgeView(
                            text: displayProduct.category.rawValue,
                            systemImage: displayProduct.category.icon,
                            color: .blue
                        )
                        
                        if let brand = displayProduct.brand, !brand.isEmpty {
                            StatusBadgeView(
                                text: brand,
                                systemImage: "building.2.crop.circle",
                                color: .purple
                            )
                        }
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", displayProduct.price))")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    
                    Text(displayProduct.title)
                        .font(.title2.weight(.bold))
                    
                    // Rating Row
                    HStack(spacing: 6) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: Double(star) <= displayProduct.rating ? "star.fill" : (Double(star) - 0.5 <= displayProduct.rating ? "star.leadinghalf.filled" : "star"))
                                .foregroundStyle(.yellow)
                                .font(.subheadline)
                        }
                        
                        Text(String(format: "%.1f", displayProduct.rating))
                            .font(.subheadline.weight(.semibold))
                        
                        Text("(\(displayProduct.ratingCount) reviews)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About This Product")
                        .font(.headline)
                    
                    Text(displayProduct.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                
                // Color Variant Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Finish")
                        .font(.headline)
                    
                    Picker("Finish", selection: $selectedColorOption) {
                        ForEach(colorOptions, id: \.self) { color in
                            Text(color).tag(color)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Tags ScrollView
                if !displayProduct.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(displayProduct.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption.weight(.medium))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.secondary.opacity(0.12))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                
                // Shipping & Warranty Information (from live API)
                if displayProduct.shippingInformation != nil || displayProduct.warrantyInformation != nil || displayProduct.returnPolicy != nil {
                    GroupBox(label: Label("Shipping & Warranty", systemImage: "shippingbox.fill")) {
                        VStack(alignment: .leading, spacing: 8) {
                            if let shipping = displayProduct.shippingInformation {
                                HStack(spacing: 8) {
                                    Image(systemName: "box.truck.fill")
                                        .foregroundStyle(.tint)
                                    Text(shipping)
                                        .font(.subheadline)
                                }
                            }
                            if let warranty = displayProduct.warrantyInformation {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .foregroundStyle(.green)
                                    Text(warranty)
                                        .font(.subheadline)
                                }
                            }
                            if let returnPolicy = displayProduct.returnPolicy {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                        .foregroundStyle(.orange)
                                    Text(returnPolicy)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                    }
                }
                
                // Customer Reviews (from live API)
                if let reviews = displayProduct.reviews, !reviews.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Customer Reviews (\(reviews.count))")
                            .font(.headline)
                        
                        ForEach(reviews) { review in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(review.reviewerName)
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    HStack(spacing: 2) {
                                        ForEach(1...5, id: \.self) { star in
                                            Image(systemName: star <= review.rating ? "star.fill" : "star")
                                                .font(.caption2)
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                }
                                Text(review.comment)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                } else {
                    // Customer Satisfaction Breakdown (Fallback)
                    GroupBox(label: Label("Customer Satisfaction", systemImage: "chart.bar.fill")) {
                        VStack(spacing: 8) {
                            HStack {
                                Text("5 Stars")
                                    .font(.caption)
                                    .frame(width: 45, alignment: .leading)
                                ProgressView(value: 0.85)
                                    .tint(.green)
                                Text("85%")
                                    .font(.caption)
                            }
                            HStack {
                                Text("4 Stars")
                                    .font(.caption)
                                    .frame(width: 45, alignment: .leading)
                                ProgressView(value: 0.10)
                                    .tint(.blue)
                                Text("10%")
                                    .font(.caption)
                            }
                            HStack {
                                Text("3 Stars")
                                    .font(.caption)
                                    .frame(width: 45, alignment: .leading)
                                ProgressView(value: 0.05)
                                    .tint(.orange)
                                Text("5%")
                                    .font(.caption)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                
                // Purchase Controls
                VStack(spacing: 12) {
                    if displayProduct.inStock {
                        HStack {
                            Text("Quantity:")
                                .font(.headline)
                            
                            Spacer()
                            
                            Stepper(value: $quantity, in: 1...max(1, displayProduct.stockCount)) {
                                Text("\(quantity)")
                                    .font(.headline.monospacedDigit())
                            }
                            .frame(width: 140)
                        }
                        
                        Button {
                            AppLogger.step(2, title: "Add To Cart Clicked", details: "Added \(quantity) units of '\(displayProduct.title)' to cart")
                            cartViewModel.addToCart(product: displayProduct, quantity: quantity)
                            showAddedToast = true
                        } label: {
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                Text("Add \(quantity) to Cart • $\(String(format: "%.2f", displayProduct.price * Double(quantity)))")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                    } else {
                        Button {} label: {
                            Text("Currently Out of Stock")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                        .disabled(true)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(displayProduct.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    onToggleFavorite()
                } label: {
                    Image(systemName: displayProduct.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(displayProduct.isFavorite ? .red : .primary)
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                ShareLink(item: "Check out \(displayProduct.title) for $\(String(format: "%.2f", displayProduct.price)) on MyApp!")
            }
        }
        .alert("Added to Cart", isPresented: $showAddedToast) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(quantity)x '\(displayProduct.title)' added to your shopping cart.")
        }
        .task {
            AppLogger.step(8, title: "View Lifecycle", details: "ProductDetailView loaded with Product ID: \(product.id)")
            
            // Asynchronously fetch full product details from DummyJSON API
            isLoadingDetails = true
            do {
                let liveDetails = try await apiService.fetchProductDetails(id: product.id)
                self.detailedProduct = liveDetails
                AppLogger.step(6, title: "Live Details Fetched", details: "Updated product details with live DummyJSON data: \(liveDetails.title)")
            } catch {
                AppLogger.step(5, title: "Details Fetch Skipped", details: "Using initial catalog item: \(error.localizedDescription)")
            }
            isLoadingDetails = false
        }
    }
    
    // MARK: - Subviews
    private var heroImageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.accentColor.opacity(0.18), Color.accentColor.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 240)
            
            if let thumbnail = displayProduct.thumbnail, let url = URL(string: thumbnail) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    case .failure:
                        Image(systemName: displayProduct.systemImageName)
                            .font(.system(size: 80))
                            .foregroundStyle(.tint)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: displayProduct.systemImageName)
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)
                    .shadow(color: .accentColor.opacity(0.3), radius: 10, y: 5)
            }
            
            if isLoadingDetails {
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Updating live details...")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 8)
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            StatusBadgeView(
                text: displayProduct.inStock ? "In Stock (\(displayProduct.stockCount))" : "Sold Out",
                systemImage: displayProduct.inStock ? "checkmark.circle.fill" : "xmark.circle.fill",
                color: displayProduct.inStock ? .green : .red
            )
            .padding(16)
        }
    }
}
