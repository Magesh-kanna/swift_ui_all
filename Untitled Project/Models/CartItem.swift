import Foundation

/// Step 0: Domain Model definition for Cart Item
/// Holds a reference to a product and selected quantity
public struct CartItem: Identifiable, Codable, Hashable {
    public let id: UUID
    public let product: Product
    public var quantity: Int
    
    public init(id: UUID = UUID(), product: Product, quantity: Int = 1) {
        self.id = id
        self.product = product
        self.quantity = quantity
    }
    
    public var subtotal: Double {
        product.price * Double(quantity)
    }
}
