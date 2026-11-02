import SwiftUI

/// User Profile screen demonstrating Form, TextField, SecureField, TextEditor, DatePicker, Stepper, Slider, and Form validation
@MainActor
public struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    
    public init() {
        self.init(viewModel: ProfileViewModel())
    }
    
    public init(viewModel: ProfileViewModel) {
        self._viewModel = State(initialValue: viewModel)
        AppLogger.step(1, title: "View Initialized", details: "ProfileView loaded.")
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Avatar Header
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 72, height: 72)
                            
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 68))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.profile.fullName.isEmpty ? "New Developer" : viewModel.profile.fullName)
                                .font(.title3.weight(.bold))
                            
                            Text(viewModel.profile.email.isEmpty ? "email@domain.com" : viewModel.profile.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            StatusBadgeView(text: "iOS Engineer", systemImage: "apple.terminal", color: .purple)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Account Credentials Section
                Section(header: Text("Personal Information")) {
                    HStack {
                        Label("Full Name", systemImage: "person")
                            .frame(width: 120, alignment: .leading)
                        TextField("Enter your name", text: $viewModel.profile.fullName)
                            .textContentType(.name)
                    }
                    
                    HStack {
                        Label("Email", systemImage: "envelope")
                            .frame(width: 120, alignment: .leading)
                        TextField("name@apple.com", text: $viewModel.profile.email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    
                    HStack {
                        Label("Security PIN", systemImage: "lock")
                            .frame(width: 120, alignment: .leading)
                        SecureField("4-digit PIN", text: $viewModel.securityPin)
                            .keyboardType(.numberPad)
                    }
                    
                    DatePicker(
                        selection: $viewModel.profile.birthDate,
                        displayedComponents: .date
                    ) {
                        Label("Birthday", systemImage: "calendar")
                    }
                }
                
                // Bio / Experience Section (TextEditor)
                Section(header: Text("Bio & Experience")) {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("About Yourself", systemImage: "note.text")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $viewModel.profile.bio)
                            .frame(minHeight: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Swift Experience:")
                            Spacer()
                            Text("\(String(format: "%.1f", viewModel.profile.experienceYears)) years")
                                .bold()
                        }
                        Slider(value: $viewModel.profile.experienceYears, in: 0...15, step: 0.5)
                    }
                    
                    Stepper(
                        "Monthly Dev Budget: $\(viewModel.profile.monthlyBudget)",
                        value: $viewModel.profile.monthlyBudget,
                        in: 0...1000,
                        step: 25
                    )
                }
                
                // Preferences & Toggles
                Section(header: Text("Communication & Style")) {
                    Toggle(isOn: $viewModel.profile.notificationsEnabled) {
                        Label("Push Notifications", systemImage: "bell.badge")
                    }
                    
                    Toggle(isOn: $viewModel.profile.newsletterSubscribed) {
                        Label("Developer Newsletter", systemImage: "newspaper")
                    }
                    
                    Picker("Theme Accent", selection: $viewModel.profile.preferredThemeColor) {
                        Text("Blue").tag("Blue")
                        Text("Purple").tag("Purple")
                        Text("Green").tag("Green")
                        Text("Orange").tag("Orange")
                    }
                    .pickerStyle(.menu)
                }
                
                // Validation Message Banner
                if let errorMsg = viewModel.validationMessage {
                    Section {
                        Label(errorMsg, systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
                
                // Action Buttons
                Section {
                    Button {
                        Task {
                            await viewModel.saveProfile()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.saveState.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 8)
                                Text("Saving Profile...")
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save Profile Changes")
                            }
                            Spacer()
                        }
                        .font(.headline)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.saveState.isLoading)
                    
                    Button(role: .destructive) {
                        viewModel.resetToDefaults()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset to Defaults")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile & Account")
            .alert("Success", isPresented: $viewModel.showConfirmationAlert) {
                Button("Done", role: .cancel) {}
            } message: {
                Text("Your profile has been successfully saved to the server!")
            }
            .onAppear {
                AppLogger.step(8, title: "View Lifecycle", details: "ProfileView appeared.")
            }
        }
    }
}
