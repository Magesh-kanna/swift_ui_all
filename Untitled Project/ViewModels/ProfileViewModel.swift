import Foundation
import Observation

/// Step 0: ViewModel managing User Profile state, form validation, and save operations
@Observable
@MainActor
public final class ProfileViewModel {
    public var profile: UserProfile
    public var securityPin: String = "1234"
    public var saveState: LoadingState<UserProfile> = .idle
    public var showConfirmationAlert: Bool = false
    public var validationMessage: String? = nil
    
    private let apiService: APIServiceProtocol
    
    public init(profile: UserProfile = UserProfile(), apiService: APIServiceProtocol = MockAPIService.shared) {
        self.profile = profile
        self.apiService = apiService
        AppLogger.step(1, title: "ViewModel Initialized", details: "ProfileViewModel loaded for '\(profile.fullName)'")
    }
    
    public var isValid: Bool {
        let nameValid = !profile.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emailValid = profile.email.contains("@") && profile.email.contains(".")
        return nameValid && emailValid
    }
    
    public func saveProfile() async {
        guard isValid else {
            validationMessage = "Please enter a valid full name and email address."
            AppLogger.step(2, title: "Form Validation Failed", details: validationMessage ?? "")
            return
        }
        
        validationMessage = nil
        AppLogger.step(3, title: "ViewModel Action", details: "Initiating profile update API call")
        saveState = .loading
        
        do {
            let updated = try await apiService.updateUserProfile(profile)
            self.profile = updated
            saveState = .success(updated)
            showConfirmationAlert = true
            AppLogger.step(7, title: "ViewModel State Updated", details: "Profile updated successfully on remote server.")
        } catch {
            saveState = .failure(error.localizedDescription)
            AppLogger.step(7, title: "ViewModel State Updated", details: "Profile update failed: \(error.localizedDescription)")
        }
    }
    
    public func resetToDefaults() {
        AppLogger.step(2, title: "User Action: Reset Profile", details: "Resetting profile fields to default")
        self.profile = UserProfile()
        self.securityPin = "1234"
        self.saveState = .idle
        self.validationMessage = nil
    }
}
