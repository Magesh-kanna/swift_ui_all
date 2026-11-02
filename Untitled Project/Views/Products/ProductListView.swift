import SwiftUI

/// Main Catalog screen illustrating List, Searchable, Refreshable, NavigationStack, MVVM binding, and Logging
@MainActor
public struct ProductListView: View {
    @State private var viewModel: ProductListViewModel
    @State private var showFilterSheet: Bool = false
    private let cartViewModel: CartViewModel
    
    public init(cartViewModel: CartViewModel) {
        self.init(viewModel: ProductListViewModel(), cartViewModel: cartViewModel)
    }
    
    public init(viewModel: ProductListViewModel, cartViewModel: CartViewModel) {
        self._viewModel = State(initialValue: viewModel)
        self.cartViewModel = cartViewModel
        AppLogger.step(1, title: "View Initialized", details: "ProductListView initialized with MVVM binding.")
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter Bar (Horizontal Chips)
                categoryFilterBar
                
                // Content Area handling LoadingState (MVVM pattern)
                ZStack {
                    switch viewModel.productsState {
                    case .idle, .loading:
                        LoadingView(message: "Fetching products from DummyJSON API...")
                        
                    case .failure(let errorMsg):
                        ErrorView(message: errorMsg) {
                            Task {
                                await viewModel.loadProducts()
                            }
                        }
                        
                    case .success:
                        if viewModel.filteredProducts.isEmpty {
                            EmptyStateView(
                                icon: "magnifyingglass",
                                title: "No Matching Products",
                                subtitle: "Try clearing your search query or picking another category.",
                                actionTitle: "Clear Filters"
                            ) {
                                viewModel.searchText = ""
                                viewModel.selectedCategory = .all
                            }
                        } else {
                            productList
                        }
                    }
                }
            }
            .navigationTitle("Store Catalog")
            .searchable(text: $viewModel.searchText, prompt: "Search products or tags...")
            .refreshable {
                AppLogger.step(2, title: "User Action: Pull-to-Refresh", details: "Reloading catalog from API")
                await viewModel.loadProducts()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Toggle("Simulate API Error", isOn: $viewModel.isSimulationErrorEnabled)
                        Divider()
                        Button(action: {
                            Task { await viewModel.loadProducts() }
                        }) {
                            Label("Force Reload", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                ProductFilterSheetView(
                    selectedCategory: $viewModel.selectedCategory,
                    sortAscending: $viewModel.sortAscending,
                    simulateError: $viewModel.isSimulationErrorEnabled
                )
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(
                    product: product,
                    cartViewModel: cartViewModel,
                    onToggleFavorite: {
                        viewModel.toggleFavorite(for: product)
                    }
                )
            }
            .task {
                if viewModel.productsState == .idle {
                    AppLogger.step(2, title: "Task Lifecycle", details: "View appeared, executing initial loadProducts() task")
                    await viewModel.loadProducts()
                }
            }
        }
    }
    
    // MARK: - Subviews
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Product.Category.allCases) { category in
                    let isSelected = viewModel.selectedCategory == category
                    Button {
                        AppLogger.step(2, title: "User Action: Category Select", details: "Selected category: \(category.rawValue)")
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                        }
                        .font(.subheadline.weight(isSelected ? .bold : .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
        .dividerBorder()
    }
    
    private var productList: some View {
        List {
            Section {
                ForEach(viewModel.filteredProducts) { product in
                    NavigationLink(value: product) {
                        ProductRowView(
                            product: product,
                            onToggleFavorite: {
                                viewModel.toggleFavorite(for: product)
                            },
                            onQuickAddToCart: {
                                cartViewModel.addToCart(product: product, quantity: 1)
                            }
                        )
                    }
                }
            } header: {
                HStack {
                    Text("\(viewModel.filteredProducts.count) Items Found")
                    Spacer()
                    Text(viewModel.sortAscending ? "Price: Low to High" : "Price: High to Low")
                        .font(.caption2)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private extension View {
    func dividerBorder() -> some View {
        overlay(
            Divider(),
            alignment: .bottom
        )
    }
}
