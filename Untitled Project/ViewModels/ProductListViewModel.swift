import Foundation
import Observation

/// Step 0: ViewModel managing the Product Catalog state
@Observable
@MainActor
public final class ProductListViewModel {
    public var productsState: LoadingState<[Product]> = .idle
    public var searchText: String = ""
    public var selectedCategory: Product.Category = .all
    public var sortAscending: Bool = true
    public var isSimulationErrorEnabled: Bool = false {
        didSet {
            if let mock = apiService as? MockAPIService {
                mock.shouldSimulateError = isSimulationErrorEnabled
            } else if let live = apiService as? DummyJSONAPIService {
                live.shouldSimulateError = isSimulationErrorEnabled
            }
        }
    }
    
    private let apiService: APIServiceProtocol
    
    public init(apiService: APIServiceProtocol = DummyJSONAPIService.shared) {
        self.apiService = apiService
        AppLogger.step(1, title: "ViewModel Initialized", details: "ProductListViewModel ready with live API service.")
    }
    
    public var filteredProducts: [Product] {
        guard case .success(let items) = productsState else { return [] }
        return items.filter { product in
            let matchesCategory = (selectedCategory == .all || product.category == selectedCategory)
            let matchesSearch = searchText.isEmpty || product.title.localizedCaseInsensitiveContains(searchText) || product.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            return matchesCategory && matchesSearch
        }.sorted { first, second in
            sortAscending ? first.price < second.price : first.price > second.price
        }
    }
    
    public func loadProducts() async {
        AppLogger.step(3, title: "ViewModel Action Triggered", details: "loadProducts() transitioning state to .loading")
        productsState = .loading
        
        do {
            let fetched = try await apiService.fetchProducts()
            AppLogger.step(7, title: "ViewModel State Updated", details: "Fetched \(fetched.count) products. Transitioning state to .success")
            productsState = .success(fetched)
        } catch {
            AppLogger.step(7, title: "ViewModel State Updated", details: "Error loading products: \(error.localizedDescription). Transitioning to .failure")
            productsState = .failure(error.localizedDescription)
        }
    }
    
    public func toggleFavorite(for product: Product) {
        guard case .success(var items) = productsState,
              let index = items.firstIndex(where: { $0.id == product.id }) else { return }
        items[index].isFavorite.toggle()
        AppLogger.step(2, title: "User Interaction", details: "Toggled favorite for '\(product.title)' -> \(items[index].isFavorite)")
        productsState = .success(items)
    }
}
