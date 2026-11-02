import SwiftUI

/// Modal sheet demonstrating Form controls: Picker, Slider, Toggle, Stepper, DatePicker
public struct ProductFilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedCategory: Product.Category
    @Binding var sortAscending: Bool
    @Binding var simulateError: Bool
    
    @State private var maxPrice: Double = 250.0
    @State private var inStockOnly: Bool = false
    @State private var minimumRating: Int = 4
    @State private var selectedDate: Date = Date()
    
    public init(
        selectedCategory: Binding<Product.Category>,
        sortAscending: Binding<Bool>,
        simulateError: Binding<Bool>
    ) {
        self._selectedCategory = selectedCategory
        self._sortAscending = sortAscending
        self._simulateError = simulateError
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Category & Sorting")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Product.Category.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Toggle(isOn: $sortAscending) {
                        Label(sortAscending ? "Price: Low to High" : "Price: High to Low", systemImage: "arrow.up.arrow.down")
                    }
                }
                
                Section(header: Text("Price Filter")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Max Price:")
                            Spacer()
                            Text("$\(Int(maxPrice))")
                                .bold()
                        }
                        Slider(value: $maxPrice, in: 20...500, step: 10) {
                            Text("Max Price")
                        } minimumValueLabel: {
                            Text("$20")
                        } maximumValueLabel: {
                            Text("$500")
                        }
                    }
                }
                
                Section(header: Text("Availability & Rating")) {
                    Toggle("In-Stock Items Only", isOn: $inStockOnly)
                    
                    Stepper("Minimum Rating: \(minimumRating) ★", value: $minimumRating, in: 1...5)
                }
                
                Section(header: Text("Filter by Added Date")) {
                    DatePicker(
                        "Items Added After",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                }
                
                Section(header: Text("Developer Diagnostics (MVVM Demo)")) {
                    Toggle(isOn: $simulateError) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Simulate Network Error")
                                .foregroundColor(.red)
                            Text("Forces API call to fail to test ErrorView")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Filter Catalog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        AppLogger.step(2, title: "Filter Sheet Dismissed", details: "Closed without applying extra filters")
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        AppLogger.step(2, title: "Filter Sheet Confirmed", details: "Category: \(selectedCategory.rawValue), Ascending: \(sortAscending)")
                        dismiss()
                    }
                }
            }
            .onAppear {
                AppLogger.step(8, title: "View Lifecycle", details: "ProductFilterSheetView presented.")
            }
        }
    }
}
