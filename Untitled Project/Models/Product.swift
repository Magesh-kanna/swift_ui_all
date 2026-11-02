import Foundation

/// Step 0: Domain Model definition for Product
/// Conforms to Identifiable, Codable, and Hashable for use in SwiftUI List, NavigationDestination, and Picker.
public struct Product: Identifiable, Codable, Hashable, Sendable {
    public let id: Int
    public var title: String
    public var description: String
    public var price: Double
    public var discountPercentage: Double?
    public var category: Category
    public var rating: Double
    public var ratingCount: Int
    public var inStock: Bool
    public var stockCount: Int
    public var systemImageName: String
    public var thumbnail: String?
    public var images: [String]?
    public var brand: String?
    public var sku: String?
    public var warrantyInformation: String?
    public var shippingInformation: String?
    public var availabilityStatus: String?
    public var returnPolicy: String?
    public var reviews: [ProductReview]?
    public var tags: [String]
    public var isFavorite: Bool
    
    public enum Category: String, Codable, CaseIterable, Identifiable, Sendable {
        case all = "All"
        case beauty = "Beauty"
        case fragrances = "Fragrances"
        case furniture = "Furniture"
        case groceries = "Groceries"
        case electronics = "Electronics"
        case fashion = "Fashion"
        case home = "Home & Living"
        case fitness = "Fitness"
        case books = "Books"
        case other = "Other"
        
        public var id: String { rawValue }
        
        public init(rawValue: String) {
            let lower = rawValue.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            switch lower {
            case "all":
                self = .all
            case "beauty", "skin-care":
                self = .beauty
            case "fragrances":
                self = .fragrances
            case "furniture":
                self = .furniture
            case "groceries":
                self = .groceries
            case "electronics", "smartphones", "laptops", "tablets", "mobile-accessories":
                self = .electronics
            case "fashion", "mens-shirts", "mens-shoes", "mens-watches", "womens-bags", "womens-dresses", "womens-jewellery", "womens-shoes", "womens-watches", "tops", "sunglasses":
                self = .fashion
            case "home", "home & living", "home-decoration", "kitchen-accessories":
                self = .home
            case "fitness", "sports-accessories", "motorcycle", "vehicle":
                self = .fitness
            case "books":
                self = .books
            default:
                self = .other
            }
        }
        
        public static var allCases: [Category] {
            [.all, .beauty, .fragrances, .furniture, .groceries, .electronics, .fashion, .home, .fitness, .books]
        }
        
        public var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .beauty: return "sparkles"
            case .fragrances: return "drop.fill"
            case .furniture: return "bed.double.fill"
            case .groceries: return "cart.fill"
            case .electronics: return "laptopcomputer"
            case .fashion: return "tshirt"
            case .home: return "house"
            case .fitness: return "figure.run"
            case .books: return "book.closed"
            case .other: return "tag.fill"
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            self.init(rawValue: str)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue.lowercased())
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, price, discountPercentage, category, rating
        case stock, stockCount
        case ratingCount
        case inStock
        case systemImageName
        case thumbnail, images, brand, sku
        case warrantyInformation, shippingInformation, availabilityStatus, returnPolicy
        case reviews, tags, isFavorite
    }
    
    public init(
        id: Int = Int.random(in: 1000...99999),
        title: String,
        description: String,
        price: Double,
        discountPercentage: Double? = nil,
        category: Category,
        rating: Double,
        ratingCount: Int = 0,
        inStock: Bool = true,
        stockCount: Int = 10,
        systemImageName: String? = nil,
        thumbnail: String? = nil,
        images: [String]? = nil,
        brand: String? = nil,
        sku: String? = nil,
        warrantyInformation: String? = nil,
        shippingInformation: String? = nil,
        availabilityStatus: String? = nil,
        returnPolicy: String? = nil,
        reviews: [ProductReview]? = nil,
        tags: [String] = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.discountPercentage = discountPercentage
        self.category = category
        self.rating = rating
        self.ratingCount = ratingCount
        self.inStock = inStock
        self.stockCount = stockCount
        self.systemImageName = systemImageName ?? category.icon
        self.thumbnail = thumbnail
        self.images = images
        self.brand = brand
        self.sku = sku
        self.warrantyInformation = warrantyInformation
        self.shippingInformation = shippingInformation
        self.availabilityStatus = availabilityStatus
        self.returnPolicy = returnPolicy
        self.reviews = reviews
        self.tags = tags
        self.isFavorite = isFavorite
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = (try? container.decode(String.self, forKey: .description)) ?? ""
        self.price = try container.decode(Double.self, forKey: .price)
        self.discountPercentage = try? container.decode(Double.self, forKey: .discountPercentage)
        
        let catString = (try? container.decode(String.self, forKey: .category)) ?? ""
        self.category = Category(rawValue: catString)
        
        self.rating = (try? container.decode(Double.self, forKey: .rating)) ?? 0.0
        
        let decodedReviews = try? container.decode([ProductReview].self, forKey: .reviews)
        self.reviews = decodedReviews
        
        let decodedRatingCount = try? container.decode(Int.self, forKey: .ratingCount)
        self.ratingCount = decodedRatingCount ?? (decodedReviews?.count ?? 0)
        
        let stockVal = (try? container.decode(Int.self, forKey: .stock))
            ?? (try? container.decode(Int.self, forKey: .stockCount))
            ?? 10
        self.stockCount = stockVal
        
        let inStockVal = try? container.decode(Bool.self, forKey: .inStock)
        let availStatus = try? container.decode(String.self, forKey: .availabilityStatus)
        if let inStockVal {
            self.inStock = inStockVal
        } else if let availStatus {
            self.inStock = (availStatus.lowercased() == "in stock" || stockVal > 0)
        } else {
            self.inStock = stockVal > 0
        }
        
        self.thumbnail = try? container.decode(String.self, forKey: .thumbnail)
        self.images = try? container.decode([String].self, forKey: .images)
        self.brand = try? container.decode(String.self, forKey: .brand)
        self.sku = try? container.decode(String.self, forKey: .sku)
        self.warrantyInformation = try? container.decode(String.self, forKey: .warrantyInformation)
        self.shippingInformation = try? container.decode(String.self, forKey: .shippingInformation)
        self.availabilityStatus = availStatus
        self.returnPolicy = try? container.decode(String.self, forKey: .returnPolicy)
        self.tags = (try? container.decode([String].self, forKey: .tags)) ?? []
        self.isFavorite = (try? container.decode(Bool.self, forKey: .isFavorite)) ?? false
        
        if let decodedIcon = try? container.decode(String.self, forKey: .systemImageName) {
            self.systemImageName = decodedIcon
        } else {
            self.systemImageName = self.category.icon
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encodeIfPresent(discountPercentage, forKey: .discountPercentage)
        try container.encode(category, forKey: .category)
        try container.encode(rating, forKey: .rating)
        try container.encode(ratingCount, forKey: .ratingCount)
        try container.encode(inStock, forKey: .inStock)
        try container.encode(stockCount, forKey: .stockCount)
        try container.encode(systemImageName, forKey: .systemImageName)
        try container.encodeIfPresent(thumbnail, forKey: .thumbnail)
        try container.encodeIfPresent(images, forKey: .images)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encodeIfPresent(sku, forKey: .sku)
        try container.encodeIfPresent(warrantyInformation, forKey: .warrantyInformation)
        try container.encodeIfPresent(shippingInformation, forKey: .shippingInformation)
        try container.encodeIfPresent(availabilityStatus, forKey: .availabilityStatus)
        try container.encodeIfPresent(returnPolicy, forKey: .returnPolicy)
        try container.encodeIfPresent(reviews, forKey: .reviews)
        try container.encode(tags, forKey: .tags)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
}

/// Customer review structure matching DummyJSON API schema
public struct ProductReview: Codable, Hashable, Sendable, Identifiable {
    public var id: String { "\(reviewerEmail)-\(date)" }
    public let rating: Int
    public let comment: String
    public let date: String
    public let reviewerName: String
    public let reviewerEmail: String
    
    public init(rating: Int, comment: String, date: String, reviewerName: String, reviewerEmail: String) {
        self.rating = rating
        self.comment = comment
        self.date = date
        self.reviewerName = reviewerName
        self.reviewerEmail = reviewerEmail
    }
}
