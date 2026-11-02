import SwiftUI

/// Main container View hosting the TabView navigation structure and shared state
public struct MainTabView: View {
    @State private var cartViewModel = CartViewModel()
    @State private var selectedTab: Tab = .catalog
    
    public enum Tab: Int, Hashable {
        case catalog = 0
        case cart = 1
        case showcase = 2
        case profile = 3
        case settings = 4
    }
    
    public init() {
        AppLogger.step(0, title: "App Navigation Bootstrapped", details: "MainTabView created with tabs: Catalog, Cart, Showcase, Profile, Settings.")
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            ProductListView(cartViewModel: cartViewModel)
                .tabItem {
                    Label("Catalog", systemImage: "storefront.fill")
                }
                .tag(Tab.catalog)
            
            CartView(viewModel: cartViewModel)
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }
                .badge(cartViewModel.totalItemCount)
                .tag(Tab.cart)
            
            SwiftUIElementsShowcaseView()
                .tabItem {
                    Label("Showcase", systemImage: "sparkles.rectangle.stack")
                }
                .tag(Tab.showcase)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(Tab.profile)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            AppLogger.step(2, title: "User Navigation: Tab Switched", details: "Switched tab from \(oldValue) to \(newValue)")
        }
    }
}
