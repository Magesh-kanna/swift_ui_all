import Foundation

/// Step 0: User Profile domain model representing user account details
public struct UserProfile: Codable, Equatable {
    public var fullName: String
    public var email: String
    public var bio: String
    public var birthDate: Date
    public var notificationsEnabled: Bool
    public var newsletterSubscribed: Bool
    public var preferredThemeColor: String
    public var experienceYears: Double
    public var monthlyBudget: Int
    
    public init(
        fullName: String = "Taylor Swiftie",
        email: String = "developer@apple.com",
        bio: String = "Passionate iOS developer building delightful SwiftUI experiences.",
        birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date(),
        notificationsEnabled: Bool = true,
        newsletterSubscribed: Bool = true,
        preferredThemeColor: String = "Blue",
        experienceYears: Double = 3.5,
        monthlyBudget: Int = 150
    ) {
        self.fullName = fullName
        self.email = email
        self.bio = bio
        self.birthDate = birthDate
        self.notificationsEnabled = notificationsEnabled
        self.newsletterSubscribed = newsletterSubscribed
        self.preferredThemeColor = preferredThemeColor
        self.experienceYears = experienceYears
        self.monthlyBudget = monthlyBudget
    }
}
