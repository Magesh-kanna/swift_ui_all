import Foundation

/// Represents the loading lifecycle of asynchronous data fetching
public enum LoadingState<T: Equatable>: Equatable {
    case idle
    case loading
    case success(T)
    case failure(String)
    
    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    public var value: T? {
        if case .success(let val) = self { return val }
        return nil
    }
    
    public var errorMessage: String? {
        if case .failure(let msg) = self { return msg }
        return nil
    }
}
