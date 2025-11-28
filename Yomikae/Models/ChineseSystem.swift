import Foundation

enum ChineseSystem: String, Codable, CaseIterable {
    case simplified = "simplified"
    case traditional = "traditional"
    case both = "both"

    var displayName: String {
        switch self {
        case .simplified: return "Simplified (简体字)"
        case .traditional: return "Traditional (繁體字)"
        case .both: return "Both"
        }
    }

    var regions: String {
        switch self {
        case .simplified: return "Mainland China, Singapore, Malaysia"
        case .traditional: return "Taiwan, Hong Kong, Macau"
        case .both: return "All regions"
        }
    }
}
