import Foundation

/// Response wrapper for DummyJSON /products endpoint
public struct DummyJSONProductsResponse: Codable, Sendable {
    public let products: [Product]
    public let total: Int
    public let skip: Int
    public let limit: Int
    
    public init(products: [Product], total: Int, skip: Int, limit: Int) {
        self.products = products
        self.total = total
        self.skip = skip
        self.limit = limit
    }
}

/// Concrete APIService implementation fetching live data from DummyJSON (https://dummyjson.com)
public final class DummyJSONAPIService: APIServiceProtocol, @unchecked Sendable {
    public static let shared = DummyJSONAPIService()
    
    private let session: URLSession
    
    /// Toggle to simulate server errors for testing error handling in UI
    public var shouldSimulateError: Bool = false
    
    /// Simulated latency if desired
    public var simulatedLatency: Double = 0.0
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Fetches live products catalog from DummyJSON
    public func fetchProducts() async throws -> [Product] {
        AppLogger.step(4, title: "API Service Request", details: "fetchProducts() called -> GET https://dummyjson.com/products?limit=30")
        
        if simulatedLatency > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedLatency * 1_000_000_000))
        }
        
        if shouldSimulateError {
            AppLogger.step(5, title: "API Service Error", details: "Simulated error flag is active. Throwing .simulatedFailure")
            throw NetworkError.simulatedFailure
        }
        
        guard let url = URL(string: "https://dummyjson.com/products?limit=30") else {
            throw NetworkError.invalidURL
        }
        
        AppLogger.step(5, title: "Background Network Execution", details: "Sending URLSession async request to \(url.absoluteString)")
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            AppLogger.step(5, title: "API Service Error", details: "HTTP status code: \(httpResponse.statusCode)")
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(DummyJSONProductsResponse.self, from: data)
            AppLogger.step(6, title: "API Service Response", details: "Successfully decoded \(decoded.products.count) products from DummyJSON API.")
            return decoded.products
        } catch {
            AppLogger.step(5, title: "API Service Error", details: "JSON Decoding failed: \(error)")
            throw NetworkError.decodingFailed
        }
    }
    
    /// Fetches single product details from DummyJSON by ID
    public func fetchProductDetails(id: Int) async throws -> Product {
        AppLogger.step(4, title: "API Service Request", details: "fetchProductDetails(id: \(id)) called -> GET https://dummyjson.com/products/\(id)")
        
        if simulatedLatency > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedLatency * 1_000_000_000))
        }
        
        if shouldSimulateError {
            AppLogger.step(5, title: "API Service Error", details: "Simulated error flag is active. Throwing .simulatedFailure")
            throw NetworkError.simulatedFailure
        }
        
        guard let url = URL(string: "https://dummyjson.com/products/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        AppLogger.step(5, title: "Background Network Execution", details: "Sending URLSession async request for details to \(url.absoluteString)")
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 404 {
                throw NetworkError.itemNotFound
            }
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let product = try decoder.decode(Product.self, from: data)
            AppLogger.step(6, title: "API Service Response", details: "Successfully retrieved details for: '\(product.title)'")
            return product
        } catch {
            AppLogger.step(5, title: "API Service Error", details: "JSON Decoding product details failed: \(error)")
            throw NetworkError.decodingFailed
        }
    }
    
    /// Submits order for the given cart items
    public func submitOrder(cartItems: [CartItem], promoCode: String?) async throws -> String {
        AppLogger.step(4, title: "API Service Request", details: "submitOrder called with \(cartItems.count) items. Promo: \(promoCode ?? "None")")
        try await Task.sleep(nanoseconds: 600_000_000)
        
        if cartItems.isEmpty {
            throw NetworkError.itemNotFound
        }
        
        let orderID = "ORD-\(Int.random(in: 100000...999999))"
        AppLogger.step(6, title: "API Service Response", details: "Order confirmed! Generated Order ID: \(orderID)")
        return orderID
    }
    
    /// Updates user profile
    public func updateUserProfile(_ profile: UserProfile) async throws -> UserProfile {
        AppLogger.step(4, title: "API Service Request", details: "updateUserProfile called for \(profile.fullName)")
        try await Task.sleep(nanoseconds: 500_000_000)
        AppLogger.step(6, title: "API Service Response", details: "Profile successfully saved.")
        return profile
    }
    
    /// Validates promo codes
    public func validatePromoCode(_ code: String) async throws -> Double {
        AppLogger.step(4, title: "API Service Request", details: "validatePromoCode('\(code)')")
        try await Task.sleep(nanoseconds: 400_000_000)
        
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
