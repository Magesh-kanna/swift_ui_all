import SwiftUI

/// Shopping Cart screen demonstrating List mutations, Swipe-to-delete, Stepper, Form fields, and Checkout API flow
public struct CartView: View {
    @Bindable var viewModel: CartViewModel
    @State private var showClearConfirmation: Bool = false
    
    public init(viewModel: CartViewModel) {
        self.viewModel = viewModel
        AppLogger.step(1, title: "View Initialized", details: "CartView loaded with \(viewModel.items.count) items.")
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    EmptyStateView(
                        icon: "cart",
                        title: "Your Cart is Empty",
                        subtitle: "Looks like you haven't added any products to your cart yet.",
                        actionTitle: "Start Shopping"
                    ) {
                        // Return to catalog tab if tapped
                    }
                } else {
                    cartContent
                }
            }
            .navigationTitle("Shopping Cart")
            .toolbar {
                if !viewModel.items.isEmpty {
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Label("Clear", systemImage: "trash")
                        }
                    }
                }
            }
            .confirmationDialog(
                "Are you sure you want to clear your cart?",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Items", role: .destructive) {
                    viewModel.clearCart()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert(
                "Order Status",
                isPresented: $viewModel.showCheckoutAlert
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.checkoutAlertMessage)
            }
        }
    }
    
    private var cartContent: some View {
        List {
            // Cart Items Section
            Section(header: Text("Items (\(viewModel.totalItemCount))")) {
                ForEach(viewModel.items) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.product.systemImageName)
                            .font(.system(size: 24))
                            .frame(width: 48, height: 48)
                            .background(Color.accentColor.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(.tint)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.product.title)
                                .font(.headline)
                                .lineLimit(1)
                            
                            Text("$\(String(format: "%.2f", item.product.price)) each")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // Quantity Stepper controls
                        HStack(spacing: 8) {
                            Button {
                                viewModel.decrementQuantity(for: item)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            
                            Text("\(item.quantity)")
                                .font(.subheadline.weight(.bold))
                                .monospacedDigit()
                                .frame(minWidth: 20)
                            
                            Button {
                                viewModel.incrementQuantity(for: item)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.tint)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: viewModel.removeItem)
            }
            
            // Promo Code Section
            Section(header: Text("Promotional Code")) {
                HStack {
                    TextField("Try 'DISCOUNT20' or 'SWIFTUI50'", text: $viewModel.promoCodeInput)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                    
                    if viewModel.promoCodeState.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Button("Apply") {
                            Task {
                                await viewModel.applyPromoCode()
                            }
                        }
                        .disabled(viewModel.promoCodeInput.isEmpty)
                    }
                }
                
                if viewModel.discountPercentage > 0 {
                    HStack {
                        Label("Discount applied: \(Int(viewModel.discountPercentage * 100))% off", systemImage: "tag.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                } else if let error = viewModel.promoCodeState.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            
            // Order Summary Section
            Section(header: Text("Order Summary")) {
                HStack {
                    Text("Subtotal")
                    Spacer()
                    Text("$\(String(format: "%.2f", viewModel.subtotal))")
                }
                
                if viewModel.discountPercentage > 0 {
                    HStack {
                        Text("Discount (\(Int(viewModel.discountPercentage * 100))%)")
                        Spacer()
                        Text("-$\(String(format: "%.2f", viewModel.discountAmount))")
                            .foregroundStyle(.green)
                    }
                }
                
                HStack {
                    Text("Estimated Tax (8%)")
                    Spacer()
                    Text("$\(String(format: "%.2f", viewModel.taxAmount))")
                }
                
                HStack {
                    Text("Total")
                        .font(.headline.weight(.bold))
                    Spacer()
                    Text("$\(String(format: "%.2f", viewModel.finalTotal))")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(Color.accentColor)
                }
            }
            
            // Checkout Button Section
            Section {
                Button {
                    Task {
                        await viewModel.checkout()
                    }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.checkoutState.isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 8)
                            Text("Processing Payment...")
                                .font(.headline)
                        } else {
                            Image(systemName: "creditcard.fill")
                            Text("Complete Checkout ($\(String(format: "%.2f", viewModel.finalTotal)))")
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.checkoutState.isLoading)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(.insetGrouped)
    }
}
