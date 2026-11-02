import Foundation
import SwiftUI
import Observation

/// Step 0: ViewModel managing the Shopping Cart state and Checkout logic
@Observable
@MainActor
public final class CartViewModel {
    public var items: [CartItem] = []
    public var promoCodeInput: String = ""
    public var discountPercentage: Double = 0.0
    public var promoCodeState: LoadingState<Double> = .idle
    public var checkoutState: LoadingState<String> = .idle
    public var showCheckoutAlert: Bool = false
    public var checkoutAlertMessage: String = ""
    
    private let apiService: APIServiceProtocol
    
    public init(apiService: APIServiceProtocol = DummyJSONAPIService.shared) {
        self.apiService = apiService
        AppLogger.step(1, title: "ViewModel Initialized", details: "CartViewModel ready.")
    }
    
    // MARK: - Computed Properties
    public var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    public var subtotal: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }
    
    public var discountAmount: Double {
        subtotal * discountPercentage
    }
    
    public var taxAmount: Double {
        (subtotal - discountAmount) * 0.08
    }
    
    public var finalTotal: Double {
        max(0, subtotal - discountAmount + taxAmount)
    }
    
    // MARK: - Cart Mutations
    public func addToCart(product: Product, quantity: Int = 1) {
        AppLogger.step(2, title: "User Action: Add to Cart", details: "Adding \(quantity)x '\(product.title)'")
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
        AppLogger.step(7, title: "State Updated", details: "Cart now has \(items.count) distinct items (\(totalItemCount) total)")
    }
    
    public func incrementQuantity(for item: CartItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].quantity += 1
            AppLogger.step(2, title: "User Action", details: "Incremented '\(item.product.title)' quantity to \(items[index].quantity)")
        }
    }
    
    public func decrementQuantity(for item: CartItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
                AppLogger.step(2, title: "User Action", details: "Decremented '\(item.product.title)' quantity to \(items[index].quantity)")
            } else {
                removeItem(at: IndexSet(integer: index))
            }
        }
    }
    
    public func removeItem(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            AppLogger.step(2, title: "User Action: Remove Item", details: "Removed '\(item.product.title)' from cart")
        }
        items.remove(atOffsets: offsets)
    }
    
    public func clearCart() {
        AppLogger.step(2, title: "User Action", details: "Cleared cart contents.")
        items.removeAll()
        discountPercentage = 0.0
        promoCodeInput = ""
    }
    
    // MARK: - API Calls
    public func applyPromoCode() async {
        guard !promoCodeInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        AppLogger.step(3, title: "ViewModel Action", details: "Validating promo code: '\(promoCodeInput)'")
        promoCodeState = .loading
        
        do {
            let discount = try await apiService.validatePromoCode(promoCodeInput)
            self.discountPercentage = discount
            promoCodeState = .success(discount)
            AppLogger.step(7, title: "State Updated", details: "Promo code accepted! \(Int(discount * 100))% off.")
        } catch {
            promoCodeState = .failure(error.localizedDescription)
            AppLogger.step(7, title: "State Updated", details: "Promo code rejected: \(error.localizedDescription)")
        }
    }
    
    public func checkout() async {
        guard !items.isEmpty else { return }
        
        AppLogger.step(3, title: "ViewModel Action", details: "Initiating checkout for \(items.count) items, Total: $\(String(format: "%.2f", finalTotal))")
        checkoutState = .loading
        
        do {
            let orderID = try await apiService.submitOrder(cartItems: items, promoCode: discountPercentage > 0 ? promoCodeInput : nil)
            checkoutState = .success(orderID)
            checkoutAlertMessage = "Thank you! Your order \(orderID) has been placed successfully."
            showCheckoutAlert = true
            items.removeAll()
            discountPercentage = 0.0
            promoCodeInput = ""
            AppLogger.step(7, title: "State Updated", details: "Checkout succeeded with Order ID: \(orderID)")
        } catch {
            checkoutState = .failure(error.localizedDescription)
            checkoutAlertMessage = "Checkout failed: \(error.localizedDescription)"
            showCheckoutAlert = true
            AppLogger.step(7, title: "State Updated", details: "Checkout failed with error: \(error.localizedDescription)")
        }
    }
}
