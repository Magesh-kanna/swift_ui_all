import Foundation

/// Custom Domain Error enum conforming to LocalizedError for clean user-facing error messages
public enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case serverError(statusCode: Int)
    case decodingFailed
    case simulatedFailure
    case itemNotFound
    case outOfStock
    case promoCodeInvalid
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested endpoint URL was malformed."
        case .serverError(let code):
            return "Server responded with error status code: \(code)."
        case .decodingFailed:
            return "Unable to parse server payload into local model representation."
        case .simulatedFailure:
            return "Simulated network failure triggered for testing and debugging."
        case .itemNotFound:
            return "The requested product was not found in catalog."
        case .outOfStock:
            return "Item is currently out of stock."
        case .promoCodeInvalid:
            return "The promo code entered is invalid or expired (Try 'DISCOUNT20')."
        }
    }
}
