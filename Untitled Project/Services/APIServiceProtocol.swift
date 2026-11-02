import Foundation

/// Protocol defining the API boundary.
/// In real applications, this decouples the ViewModel from concrete URLSession or Mock implementations.
public protocol APIServiceProtocol: Sendable {
    func fetchProducts() async throws -> [Product]
    func fetchProductDetails(id: Int) async throws -> Product
    func submitOrder(cartItems: [CartItem], promoCode: String?) async throws -> String
    func updateUserProfile(_ profile: UserProfile) async throws -> UserProfile
    func validatePromoCode(_ code: String) async throws -> Double
}
