import SwiftUI

/// Settings view demonstrating system preferences, ColorPicker, Steppers, Sliders, and Diagnostics
@MainActor
public struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var customColor: Color = .blue
    
    public init() {
        self.init(viewModel: SettingsViewModel())
    }
    
    public init(viewModel: SettingsViewModel) {
        self._viewModel = State(initialValue: viewModel)
        AppLogger.step(1, title: "View Initialized", details: "SettingsView loaded.")
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Appearance Section
                Section(header: Text("Appearance & Theme")) {
                    Picker("Theme Style", selection: $viewModel.selectedTheme) {
                        ForEach(viewModel.themeOptions, id: \.self) { theme in
                            Text(theme).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    ColorPicker("Custom Accent Color", selection: $customColor)
                    
                    Toggle(isOn: $viewModel.isDarkMode) {
                        Label("Dark Appearance", systemImage: "moon.stars.fill")
                    }
                }
                
                // Feedback & Controls
                Section(header: Text("Device Haptics & Audio")) {
                    Toggle(isOn: $viewModel.enableHapticFeedback) {
                        Label("Haptic Feedback", systemImage: "hand.tap.fill")
                    }
                    
                    Toggle(isOn: $viewModel.enableSounds) {
                        Label("System Sounds", systemImage: "speaker.wave.2.fill")
                    }
                }
                
                // Networking & API Simulation
                Section(header: Text("Mock API Configuration"), footer: Text("Configure simulated network conditions to test async/await, LoadingView, and ErrorView states.")) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Simulated Latency:")
                            Spacer()
                            Text("\(String(format: "%.1f", viewModel.simulatedLatency))s")
                                .bold()
                        }
                        Slider(value: $viewModel.simulatedLatency, in: 0.1...3.0, step: 0.1)
                    }
                    
                    Toggle(isOn: $viewModel.simulateNetworkError) {
                        VStack(alignment: .leading) {
                            Text("Simulate Network Failure")
                                .foregroundStyle(viewModel.simulateNetworkError ? .red : .primary)
                            Text("Throws simulated server error on next API request")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Storage & Cache
                Section(header: Text("Storage & Memory")) {
                    Stepper("Cache Limit: \(viewModel.cacheSizeMB) MB", value: $viewModel.cacheSizeMB, in: 0...1024, step: 32)
                    
                    Button(role: .destructive) {
                        viewModel.showClearCacheAlert = true
                    } label: {
                        Label("Clear Cached Responses", systemImage: "trash")
                    }
                }
                
                // Educational Architecture Guide
                Section(header: Text("MVVM Architecture Guide (Steps 0 to N)")) {
                    VStack(alignment: .leading, spacing: 8) {
                        archStepRow(step: "0", title: "Domain Models & Protocols", desc: "Data structures (Product, CartItem) and APIServiceProtocol contracts.")
                        archStepRow(step: "1", title: "ViewModel Initialization", desc: "Instantiating @Observable ViewModel with injected services.")
                        archStepRow(step: "2", title: "View Rendering & Bindings", desc: "SwiftUI declarative UI reacts to state changes via @Bindable / @State.")
                        archStepRow(step: "3", title: "User Interaction & Intent", desc: "Buttons, Pull-to-refresh, Search text fields trigger ViewModel functions.")
                        archStepRow(step: "4", title: "Network Request Dispatch", desc: "ViewModel calls asynchronous API endpoints via async/await.")
                        archStepRow(step: "5", title: "Background Network Execution", desc: "Mock network delay, JSON encoding/decoding, or error simulation.")
                        archStepRow(step: "6", title: "Service Response Handling", desc: "Result parsed or thrown error caught by ViewModel.")
                        archStepRow(step: "7", title: "State Mutation on MainActor", desc: "ViewModel updates @Observable loadingState (.loading, .success, .failure).")
                        archStepRow(step: "8", title: "UI Update & Feedback", desc: "SwiftUI automatically re-renders with transitions, alerts, or sheets.")
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings & Diagnostics")
            .confirmationDialog(
                "Are you sure you want to clear cache?",
                isPresented: $viewModel.showClearCacheAlert,
                titleVisibility: .visible
            ) {
                Button("Clear Cache", role: .destructive) {
                    viewModel.clearCache()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Cache Cleared", isPresented: $viewModel.cacheClearedToast) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("All local cached files have been successfully purged.")
            }
            .onAppear {
                AppLogger.step(8, title: "View Lifecycle", details: "SettingsView displayed.")
            }
        }
    }
    
    private func archStepRow(step: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(step)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.accentColor))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
