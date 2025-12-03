import SwiftUI

// MARK: - Color Extension

extension Color {
    // MARK: - App Colors

    /// Deep blue primary color (#1E3A5F)
    static let appPrimary = Color(hex: "1E3A5F")

    /// Warm orange accent color (#E07B39)
    static let appAccent = Color(hex: "E07B39")

    /// Red for critical false friends
    static let appCritical = Color.red

    /// Orange for important false friends
    static let appImportant = Color.orange

    /// Yellow for subtle false friends
    static let appSubtle = Color.yellow

    /// System background color
    static let appBackground = Color(.systemBackground)

    /// System secondary background color
    static let appSecondaryBackground = Color(.secondarySystemBackground)

    // MARK: - Semantic Colors

    /// Japanese-themed blue
    static let japaneseBlue = Color(hex: "0066CC")

    /// Chinese-themed red
    static let chineseRed = Color(hex: "DC143C")

    /// Success green
    static let appSuccess = Color.green

    /// Warning color
    static let appWarning = Color.orange

    // MARK: - Hex Initializer

    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (with or without #)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

// MARK: - Theme

struct Theme {
    // MARK: - Colors

    struct Colors {
        static let primary = Color.appPrimary
        static let accent = Color.appAccent
        static let critical = Color.appCritical
        static let important = Color.appImportant
        static let subtle = Color.appSubtle
        static let background = Color.appBackground
        static let secondaryBackground = Color.appSecondaryBackground
        static let japaneseBlue = Color.japaneseBlue
        static let chineseRed = Color.chineseRed
        static let success = Color.appSuccess
        static let warning = Color.appWarning
    }

    // MARK: - Spacing

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Corner Radius

    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }

    // MARK: - Shadows

    struct Shadow {
        static let light = (color: Color.black.opacity(0.05), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.08), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
        static let heavy = (color: Color.black.opacity(0.12), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
    }

    // MARK: - Typography

    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title1 = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let callout = Font.system(size: 16, weight: .regular)
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption1 = Font.system(size: 12, weight: .regular)
        static let caption2 = Font.system(size: 11, weight: .regular)
    }

    // MARK: - Opacity

    struct Opacity {
        static let subtle: Double = 0.05
        static let light: Double = 0.1
        static let medium: Double = 0.2
        static let heavy: Double = 0.3
    }
}

// MARK: - Severity Extension

extension Severity {
    /// Get the theme color for this severity level
    var themeColor: Color {
        switch self {
        case .critical:
            return Theme.Colors.critical
        case .important:
            return Theme.Colors.important
        case .subtle:
            return Theme.Colors.subtle
        }
    }
}
