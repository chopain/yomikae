import Foundation
import SwiftUI

class UserSettings: ObservableObject {
    static let shared = UserSettings()

    @AppStorage("chineseSystem") var chineseSystem: ChineseSystem = .simplified
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    private init() {}
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
