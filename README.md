# SwiftUI All — Modern iOS Architecture & Component Showcase

[![Swift](https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange.svg?style=flat-square&logo=swift)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0%2B-blue.svg?style=flat-square&logo=apple)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-blueviolet.svg?style=flat-square&logo=swift)](https://developer.apple.com/xcode/swiftui/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0%2B%20%7C%2016.0%2B-informational.svg?style=flat-square&logo=xcode)](https://developer.apple.com/xcode/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%2B%20Observation-success.svg?style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat-square)](LICENSE)

A production-grade, educational iOS reference application built with **modern SwiftUI** and Swift Concurrency. This project serves as an architectural blueprint for scalable iOS applications, combining a real-world e-commerce product catalog with an exhaustive interactive UI component playground and diagnostic tracing.

---

## 🌟 Highlights

- **Pure Modern SwiftUI**: Built with the Swift 5.9+ / 6.0 `@Observable` macro and `@MainActor` isolation, eliminating legacy Combine boilerplate (`ObservableObject`, `@Published`).
- **Structured Concurrency**: Clean `async`/`await` networking pipelines with robust error handling and cancellation support.
- **Protocol-Oriented Architecture**: Decoupled service layer with interchangeable Live API (`DummyJSONAPIService`) and Mock API (`MockAPIService`) implementations.
- **Interactive UI Component Showcase**: A living design system catalog demonstrating essential SwiftUI controls, layouts, feedback indicators, and presentation sheets.
- **Resilient State Management**: Generic `LoadingState<T>` enum cleanly managing `.idle`, `.loading`, `.success(T)`, and `.failure(String)` states with dedicated reusable feedback views.
- **Educational Flow Logging**: Integrated `AppLogger` that outputs step-by-step diagnostic breadcrumbs tracing user interactions, state mutations, and network lifecycles.

---

## 📱 Application Modules & Features

```
┌────────────────────────────────────────────────────────────────────────┐
│                              MainTabView                               │
├─────────────┬─────────────┬─────────────────┬─────────────┬────────────┤
│  🛍️ Catalog  │   🛒 Cart   │   ✨ Showcase    │  👤 Profile  │ ⚙️ Settings │
└─────────────┴─────────────┴─────────────────┴─────────────┴────────────┘
```

### 1. 🛍️ Product Catalog (`ProductListView`)
- **Live REST API Integration**: Fetches real-time catalog data from [DummyJSON](https://dummyjson.com/products).
- **Search & Filtering**: Real-time debounced text search matching product titles, descriptions, and tags.
- **Category Filter Sheet**: Dynamic filtering across categories (Beauty, Fragrances, Furniture, Groceries, Electronics, etc.).
- **Price Sorting**: Ascending and descending price order toggles.
- **Product Card UI (`ProductRowView`)**: Displays asynchronous image caching (`AsyncImage`), rating badges, category tags, stock levels, discount percentages, and favorite toggles.
- **Product Details (`ProductDetailView`)**: Multi-image carousel, full descriptions, brand metadata, reviews, stock availability, and instant Add-to-Cart functionality.
- **State Handling**: Smooth transitions between `LoadingView`, `ErrorView` (with interactive retry action), and `EmptyStateView`.

### 2. 🛒 Shopping Cart (`CartViewModel` & `CartView`)
- **Reactive Shared State**: Shared cart state bound across views with instant badge counter updates on the tab bar.
- **Item Management**: Quantity increment/decrement steppers, swipe-to-delete, and batch clear actions.
- **Order Calculation**: Automatic recalculation of subtotal, tiered discounts, estimated sales tax, and final total.
- **Interactive Checkout Flow**: Simulated checkout process with instant cart reset and user feedback.

### 3. ✨ SwiftUI Component Playground (`SwiftUIElementsShowcaseView`)
An interactive, living catalog of standard iOS SwiftUI controls and layouts:
- **Typography & Labels**: Standard text styles, custom weights, markdown formatting, monospaced digits, and SF Symbols.
- **Buttons & Toggles**: Plain, bordered, bordered prominent, capsule, destructive buttons, and switches.
- **Inputs & Editors**: `TextField` with clear buttons, `SecureField` for passwords, and multi-line `TextEditor`.
- **Value Pickers**: `Slider`, `Stepper`, `ColorPicker`, `DatePicker`, and segmented/menu `Picker` controls.
- **Layout Containers**: `VStack`, `HStack`, `LazyVGrid`, `GroupBox`, and sectioned lists.
- **Indicators & Metrics**: `ProgressView` (determinate and indeterminate) and `Gauge` displays.
- **Presentation Modals**: Native `Alert`, `confirmationDialog` (Action Sheets), modal `Sheet`, and `fullScreenCover`.

### 4. 👤 User Profile (`ProfileView`)
- **Form Architecture**: Native iOS `Form` layout grouping profile information and account preferences.
- **Avatar Header**: Custom avatar presentation with gradient backdrops and role badges (`StatusBadgeView`).
- **Validation**: Real-time form field validation with contextual feedback.

### 5. ⚙️ Settings & Network Diagnostics (`SettingsView`)
- **Theme Selection**: Segmented control for system, light, and dark appearance modes.
- **Custom Accent Colors**: Native `ColorPicker` for personalization.
- **Haptics & Audio**: Toggles for feedback generators.
- **Live Network Simulator**:
  - **Latency Slider**: Inject simulated network latency (0 to 5 seconds) to test asynchronous UI responsiveness.
  - **Error Injection Toggle**: Simulate network failures on demand to verify UI resilience and retry behaviors.

---

## 🏛️ Architecture & Data Flow

This project adheres strictly to **Clean MVVM (Model-View-ViewModel)** with modern Apple design paradigms:

```
┌──────────────────┐           ┌──────────────────┐           ┌──────────────────┐
│      Views       │  ──────>  │    ViewModels    │  ──────>  │     Services     │
│  (Declarative UI │ <───────  │   (@Observable   │ <───────  │ (APIServiceProto │
│   & Navigation)  │   State   │   @MainActor)    │   Async   │   Live & Mock)   │
└──────────────────┘           └──────────────────┘           └──────────────────┘
         │                                                             │
         └───────────────────>   AppLogger   <─────────────────────────┘
                             (Diagnostic Tracing)
```

1. **View Layer**: Pure, lightweight SwiftUI views driven purely by observed state.
2. **ViewModel Layer**: Uses `@Observable` to provide fine-grained, thread-safe reactivity with `@MainActor` ensuring UI updates occur exclusively on the main thread.
3. **Service Layer**: Fully decoupled through `APIServiceProtocol`. Easily toggle between `DummyJSONAPIService` (live HTTP requests via `URLSession`) and `MockAPIService` for unit tests and Xcode Previews.
4. **State Machine (`LoadingState<T>`)**:
   ```swift
   public enum LoadingState<Value> {
       case idle
       case loading
       case success(Value)
       case failure(String)
   }
   ```
5. **AppLogger Tracing**: Provides sequential, numbered diagnostic logs (`Step 0` through `Step 7`) directly to the console and Apple Unified Logging (`os.Logger`).

---

## 📂 Project Directory Structure

```text
Untitled Project/
├── Untitled Project/
│   ├── MyApp.swift                      # Application entry point (@main)
│   ├── ContentView.swift                # Root container view
│   ├── Assets.xcassets                  # Asset catalog (colors, app icons)
│   │
│   ├── Models/                          # Domain and network entities
│   │   ├── Product.swift                # Product model with Codable & Hashable
│   │   ├── CartItem.swift               # Cart item representation
│   │   ├── UserProfile.swift            # User profile data model
│   │   ├── LoadingState.swift           # Generic async UI state enum
│   │   └── NetworkError.swift           # Typed API and network error definitions
│   │
│   ├── Services/                        # Networking and data layer
│   │   ├── APIServiceProtocol.swift     # Contract for product retrieval
│   │   ├── DummyJSONAPIService.swift    # Live REST implementation (dummyjson.com)
│   │   └── MockAPIService.swift         # Mock provider for previews and unit tests
│   │
│   ├── ViewModels/                      # Reactive presentation logic
│   │   ├── ProductListViewModel.swift   # Catalog state, search, and category filter
│   │   ├── CartViewModel.swift          # Cart calculations, additions, and mutations
│   │   ├── ProfileViewModel.swift       # User profile state & form management
│   │   └── SettingsViewModel.swift      # Preferences & network simulation config
│   │
│   ├── Views/                           # UI screens and modular components
│   │   ├── MainTabView.swift            # Five-tab navigation coordinator
│   │   │
│   │   ├── Products/                    # Product catalog views
│   │   │   ├── ProductListView.swift    # Primary catalog view with search & states
│   │   │   ├── ProductRowView.swift     # Individual product card row
│   │   │   ├── ProductDetailView.swift  # Rich product detail view
│   │   │   └── ProductFilterSheetView.swift # Category filter bottom sheet
│   │   │
│   │   ├── Cart/                        # Cart views
│   │   │   └── CartView.swift           # Cart list, item steppers, checkout summary
│   │   │
│   │   ├── Showcase/                    # Component playground
│   │   │   └── SwiftUIElementsShowcaseView.swift # Native SwiftUI controls gallery
│   │   │
│   │   ├── Profile/                     # Profile views
│   │   │   └── ProfileView.swift        # Form controls and personal settings
│   │   │
│   │   ├── Settings/                    # Settings views
│   │   │   └── SettingsView.swift       # Theme, haptics, and network simulation
│   │   │
│   │   └── Components/                  # Reusable UI widgets
│   │       ├── LoadingView.swift        # Animated spinner with custom text
│   │       ├── ErrorView.swift          # Error card with retry callback
│   │       ├── EmptyStateView.swift     # Empty list / no-results placeholder
│   │       └── StatusBadgeView.swift    # Colored badge chip component
│   │
│   └── Utilities/
│       └── AppLogger.swift              # Unified diagnostic console logger
│
└── Untitled Project.xcodeproj           # Xcode project bundle
```

---

## 🛠️ Requirements & Getting Started

### Prerequisites
- **macOS**: Sonoma 14.0 or newer
- **Xcode**: 15.0+ or 16.0+
- **Swift**: 5.9+ / 6.0
- **Deployment Target**: iOS 17.0+

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Magesh-kanna/swift_ui_all.git
   cd swift_ui_all
   ```

2. **Open in Xcode:**
   ```bash
   open "Untitled Project.xcodeproj"
   ```

3. **Select a Target & Destination:**
   - Choose the active scheme in the toolbar.
   - Select any iOS 17+ Simulator (e.g., iPhone 15 Pro, iPhone 16 Pro).

4. **Build and Run:**
   - Press `Cmd + R` to compile and launch.
   - The app will automatically bootstrap and load live products from DummyJSON.

---

## 🧪 Testing Network Conditions in the App

You can test error resilience and loading indicators directly from the app without disabling your Wi-Fi:

1. Open the **Settings** tab.
2. Scroll to the **Mock API Configuration** section.
3. Adjust the **Simulated Network Latency** slider to `2.0s` or higher.
4. Toggle **Simulate API Failures** to ON.
5. Return to the **Catalog** tab and pull-to-refresh or tap reload.
6. Observe the animated `LoadingView` followed by the `ErrorView`, and tap **Retry** once you toggle off failure simulation.

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
