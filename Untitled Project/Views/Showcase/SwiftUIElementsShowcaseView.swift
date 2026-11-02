import SwiftUI

/// Comprehensive showcase view illustrating the most used SwiftUI controls and layouts in an interactive playground
public struct SwiftUIElementsShowcaseView: View {
    // State properties for interactive controls
    @State private var toggleState: Bool = true
    @State private var buttonToggleState: Bool = false
    @State private var sliderValue: Double = 65.0
    @State private var stepperValue: Int = 3
    @State private var textInput: String = "Hello SwiftUI"
    @State private var secureTextInput: String = "secret"
    @State private var textEditorInput: String = "Multi-line text editor content goes here..."
    @State private var selectedPickerOption: Int = 1
    @State private var selectedDate: Date = Date()
    @State private var pickedColor: Color = .purple
    @State private var gaugeValue: Double = 0.72
    @State private var showAlert: Bool = false
    @State private var showActionSheet: Bool = false
    @State private var showModalSheet: Bool = false
    @State private var showFullScreenCover: Bool = false
    
    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    public init() {
        AppLogger.step(1, title: "View Initialized", details: "SwiftUIElementsShowcaseView loaded.")
    }
    
    public var body: some View {
        NavigationStack {
            List {
                // Section 1: Typography & Labels
                Section(header: Label("Typography & Labels", systemImage: "textformat")) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Large Title Display")
                            .font(.largeTitle.weight(.bold))
                        
                        Text("Title 2 with Primary Color")
                            .font(.title2)
                            .foregroundStyle(.primary)
                        
                        Text("Headline with monospaced numbers: 123,456")
                            .font(.headline.monospacedDigit())
                        
                        Text("Subheadline with secondary styling")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("Caption text with *italic* and **bold** markdown")
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                    
                    HStack(spacing: 12) {
                        Label("SF Symbol", systemImage: "sparkles")
                            .foregroundStyle(.purple)
                        
                        Label("Warning", systemImage: "exclamationmark.octagon.fill")
                            .foregroundStyle(.orange)
                        
                        Label("Success", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                // Section 2: Buttons & ButtonStyles
                Section(header: Label("Buttons & Styling", systemImage: "cursorarrow.rays")) {
                    HStack(spacing: 10) {
                        Button("Prominent") {
                            AppLogger.step(2, title: "Button Tap", details: "Prominent button tapped")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Bordered") {
                            AppLogger.step(2, title: "Button Tap", details: "Bordered button tapped")
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Destructive", role: .destructive) {
                            AppLogger.step(2, title: "Button Tap", details: "Destructive button tapped")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack(spacing: 10) {
                        Button {
                            AppLogger.step(2, title: "Button Tap", details: "Rounded capsule button")
                        } label: {
                            Label("Capsule Icon", systemImage: "paperplane.fill")
                                .padding(.horizontal, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(Capsule())
                        
                        ShareLink(item: "Sharing text from SwiftUI Showcase!") {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Section 3: Input Controls (Toggles, Sliders, Steppers)
                Section(header: Label("Interactive Controls", systemImage: "switch.2")) {
                    Toggle("Standard Switch Toggle", isOn: $toggleState)
                    
                    Toggle(isOn: $buttonToggleState) {
                        Label("Button Style Toggle", systemImage: buttonToggleState ? "bell.fill" : "bell.slash")
                    }
                    .toggleStyle(.button)
                    .tint(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Slider Value:")
                            Spacer()
                            Text("\(Int(sliderValue))%")
                                .bold()
                        }
                        Slider(value: $sliderValue, in: 0...100, step: 1)
                    }
                    
                    Stepper("Stepper Count: \(stepperValue)", value: $stepperValue, in: 0...10)
                }
                
                // Section 4: Pickers & Selectors
                Section(header: Label("Pickers & Selectors", systemImage: "list.bullet.rectangle")) {
                    Picker("Segmented Picker", selection: $selectedPickerOption) {
                        Text("Day").tag(0)
                        Text("Week").tag(1)
                        Text("Month").tag(2)
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Menu Picker", selection: $selectedPickerOption) {
                        Text("Option Alpha").tag(0)
                        Text("Option Beta").tag(1)
                        Text("Option Gamma").tag(2)
                    }
                    .pickerStyle(.menu)
                    
                    ColorPicker("Color Picker Selection", selection: $pickedColor)
                    
                    DatePicker("Compact DatePicker", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                }
                
                // Section 5: Text Fields & Editors
                Section(header: Label("Text Input Fields", systemImage: "keyboard")) {
                    TextField("Standard TextField", text: $textInput)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("SecureField (Passwords)", text: $secureTextInput)
                        .textFieldStyle(.roundedBorder)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TextEditor (Multi-line)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $textEditorInput)
                            .frame(height: 70)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.2)))
                    }
                }
                
                // Section 6: Progress & Gauge
                Section(header: Label("Progress & Indicators", systemImage: "gauge.with.needle")) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Indeterminate Progress:")
                            Spacer()
                            ProgressView()
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Determinate Progress (\(Int(sliderValue))%):")
                                .font(.caption)
                            ProgressView(value: sliderValue, total: 100)
                                .tint(.accentColor)
                        }
                        
                        HStack {
                            Text("System Gauge:")
                            Spacer()
                            Gauge(value: gaugeValue) {
                                Text("Battery")
                            } currentValueLabel: {
                                Text("\(Int(gaugeValue * 100))%")
                            }
                            .gaugeStyle(.accessoryCircularCapacity)
                            .tint(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Section 7: LazyVGrid Layout
                Section(header: Label("LazyVGrid & Cards", systemImage: "square.grid.3x3")) {
                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        ForEach(1...6, id: \.self) { item in
                            VStack(spacing: 6) {
                                Image(systemName: "app.badge.fill")
                                    .font(.title2)
                                    .foregroundStyle(pickedColor)
                                Text("Card \(item)")
                                    .font(.caption.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Section 8: Dialogs, Sheets, & Alerts
                Section(header: Label("Alerts & Presentations", systemImage: "rectangle.stack")) {
                    Button("Trigger Alert") {
                        showAlert = true
                    }
                    
                    Button("Show Confirmation Dialog") {
                        showActionSheet = true
                    }
                    
                    Button("Present Modal Sheet") {
                        showModalSheet = true
                    }
                    
                    Button("Present Full Screen Cover") {
                        showFullScreenCover = true
                    }
                }
            }
            .navigationTitle("SwiftUI Showcase")
            .alert("SwiftUI Alert Demo", isPresented: $showAlert) {
                Button("Accept", role: .none) {
                    AppLogger.step(2, title: "Alert Response", details: "User accepted alert")
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This illustrates a native SwiftUI alert modal triggered by @State boolean.")
            }
            .confirmationDialog("Choose Action", isPresented: $showActionSheet, titleVisibility: .visible) {
                Button("Perform Action A") {}
                Button("Perform Action B") {}
                Button("Delete Data", role: .destructive) {}
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showModalSheet) {
                modalSheetContent
            }
            .fullScreenCover(isPresented: $showFullScreenCover) {
                fullScreenCoverContent
            }
        }
    }
    
    // MARK: - Modals
    private var modalSheetContent: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)
                
                Text("Presented Modal Sheet")
                    .font(.title2.weight(.bold))
                
                Text("Sheets are half/full modal view presentations that can be swiped down to dismiss.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Dismiss Sheet") {
                    showModalSheet = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showModalSheet = false }
                }
            }
        }
    }
    
    private var fullScreenCoverContent: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                
                Text("Full Screen Cover")
                    .font(.title2.weight(.bold))
                
                Text("Full screen covers replace the entire window context until explicitly dismissed.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Dismiss Full Screen") {
                    showFullScreenCover = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
