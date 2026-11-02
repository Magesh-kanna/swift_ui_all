import Foundation

/// Implementation of APIServiceProtocol simulating network requests with realistic delay,
/// structured JSON encoding/decoding, and toggleable simulated failures.
public final class MockAPIService: APIServiceProtocol, @unchecked Sendable {
    public static let shared = MockAPIService()
    
    /// Toggle to simulate server errors for testing error handling in UI
    public var shouldSimulateError: Bool = false
    
    /// Simulated network latency in seconds
    public var simulatedLatency: Double = 0.8
    
    private var mockProducts: [Product] = [
        Product(
            title: "SwiftUI Mastery Pro Book",
            description: "Master declarative UI development on Apple platforms with real-world MVVM, Swift Concurrency, and modern architectural patterns.",
            price: 49.99,
            category: .books,
            rating: 4.9,
            ratingCount: 312,
            inStock: true,
            stockCount: 45,
            systemImageName: "book.fill",
            tags: ["Swift", "iOS", "SwiftUI", "Best Seller"],
            isFavorite: true
        ),
        Product(
            title: "Apple Vision Pro Case",
            description: "Premium rugged carrying case custom-molded for Apple Vision Pro, battery pack, and Zeiss optical inserts.",
            price: 199.00,
            category: .electronics,
            rating: 4.8,
            ratingCount: 120,
            inStock: true,
            stockCount: 14,
            systemImageName: "visionpro",
            tags: ["visionOS", "Accessories", "Premium"]
        ),
        Product(
            title: "Ergonomic Mechanical Keyboard",
            description: "Wireless mechanical keyboard with low-profile hot-swappable switches, aluminum body, and RGB backlight.",
            price: 149.50,
            category: .electronics,
            rating: 4.7,
            ratingCount: 840,
            inStock: true,
            stockCount: 22,
            systemImageName: "keyboard",
            tags: ["Desk Setup", "Bluetooth", "Mac"]
        ),
        Product(
            title: "Developer Hoodie - 'Works on My Machine'",
            description: "100% ultra-soft combed cotton hooded sweatshirt tailored for long coding sessions and hackathons.",
            price: 65.00,
            category: .fashion,
            rating: 4.6,
            ratingCount: 215,
            inStock: true,
            stockCount: 30,
            systemImageName: "tshirt.fill",
            tags: ["Apparel", "Comfort", "Dev"]
        ),
        Product(
            title: "Smart Water Bottle & Hydration Tracker",
            description: "Insulated stainless steel water bottle with LED reminder ring and Apple Health sync integration.",
            price: 39.99,
            category: .fitness,
            rating: 4.4,
            ratingCount: 95,
            inStock: true,
            stockCount: 8,
            systemImageName: "waterbottle.fill",
            tags: ["Health", "Fitness", "Smart"]
        ),
        Product(
            title: "Minimalist Wooden Desk Mat",
            description: "Handcrafted natural oak desk organizer mat with magnetic cable management channels.",
            price: 79.00,
            category: .home,
            rating: 4.9,
            ratingCount: 520,
            inStock: false,
            stockCount: 0,
            systemImageName: "desktopcomputer",
            tags: ["Workspace", "Design", "Wood"]
        )
    ]
    
    public init() {}
    
    public func fetchProducts() async throws -> [Product] {
        AppLogger.step(4, title: "API Service Request", details: "fetchProducts() called. Latency: \(simulatedLatency)s")
        
        // Step 5: Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedLatency * 1_000_000_000))
        
        if shouldSimulateError {
            AppLogger.step(5, title: "API Service Error", details: "Simulated error flag is active. Throwing .simulatedFailure")
            throw NetworkError.simulatedFailure
        }
        
        // Simulate JSON serialization / deserialization step
        let encoder = JSONEncoder()
        let data = try encoder.encode(mockProducts)
        let decoder = JSONDecoder()
        let decodedProducts = try decoder.decode([Product].self, from: data)
        
        AppLogger.step(6, title: "API Service Response", details: "Successfully retrieved and decoded \(decodedProducts.count) products.")
        return decodedProducts
    }
    
    public func fetchProductDetails(id: Int) async throws -> Product {
        AppLogger.step(4, title: "API Service Request", details: "fetchProductDetails(id: \(id)) called")
        try await Task.sleep(nanoseconds: UInt64(0.4 * 1_000_000_000))
        
        guard let product = mockProducts.first(where: { $0.id == id }) else {
            AppLogger.step(5, title: "API Service Error", details: "Product with ID \(id) not found.")
            throw NetworkError.itemNotFound
        }
        
        AppLogger.step(6, title: "API Service Response", details: "Found product: \(product.title)")
        return product
    }
    
    public func submitOrder(cartItems: [CartItem], promoCode: String?) async throws -> String {
        AppLogger.step(4, title: "API Service Request", details: "submitOrder called with \(cartItems.count) items. Promo: \(promoCode ?? "None")")
        try await Task.sleep(nanoseconds: UInt64(1.0 * 1_000_000_000))
        
        if cartItems.isEmpty {
            throw NetworkError.itemNotFound
        }
        
        let orderID = "ORD-\(Int.random(in: 100000...999999))"
        AppLogger.step(6, title: "API Service Response", details: "Order confirmed! Generated Order ID: \(orderID)")
        return orderID
    }
    
    public func updateUserProfile(_ profile: UserProfile) async throws -> UserProfile {
        AppLogger.step(4, title: "API Service Request", details: "updateUserProfile called for \(profile.fullName)")
        try await Task.sleep(nanoseconds: UInt64(0.7 * 1_000_000_000))
        
        AppLogger.step(6, title: "API Service Response", details: "Profile successfully saved to server.")
        return profile
    }
    
    public func validatePromoCode(_ code: String) async throws -> Double {
        AppLogger.step(4, title: "API Service Request", details: "validatePromoCode('\(code)')")
        try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if trimmed == "DISCOUNT20" {
            AppLogger.step(6, title: "API Service Response", details: "Promo code valid: 20% discount applied.")
            return 0.20
        } else if trimmed == "SWIFTUI50" {
            AppLogger.step(6, title: "API Service Response", details: "Promo code valid: 50% discount applied.")
            return 0.50
        } else {
            AppLogger.step(5, title: "API Service Error", details: "Invalid promo code: \(code)")
            throw NetworkError.promoCodeInvalid
        }
    }
}
