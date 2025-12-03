import Foundation
import SwiftUI

class UserSettings: ObservableObject {
    static let shared = UserSettings()

    @AppStorage("chineseSystem") var chineseSystem: ChineseSystem = .simplified
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("fontSize") var fontSize: FontSize = .medium
    @AppStorage("recentItemsCount") var recentItemsCount: Int = 10

    private init() {}
}

// MARK: - Font Size

enum FontSize: String, Codable, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"

    var displayName: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }

    var scale: CGFloat {
        switch self {
        case .small: return 0.9
        case .medium: return 1.0
        case .large: return 1.1
        }
    }
}

// Extension to make FontSize work with @AppStorage
extension FontSize: RawRepresentable {
    public init?(rawValue: String) {
        switch rawValue {
        case "small":
            self = .small
        case "medium":
            self = .medium
        case "large":
            self = .large
        default:
            return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .small: return "small"
        case .medium: return "medium"
        case .large: return "large"
        }
    }
}

// Extension to make ChineseSystem work with @AppStorage
extension ChineseSystem: RawRepresentable {
    public init?(rawValue: String) {
        switch rawValue {
        case "simplified":
            self = .simplified
        case "traditional":
            self = .traditional
        case "both":
            self = .both
        default:
            return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .simplified: return "simplified"
        case .traditional: return "traditional"
        case .both: return "both"
        }
    }
}
