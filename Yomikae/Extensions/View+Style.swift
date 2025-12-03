import SwiftUI

// MARK: - View Style Extensions

extension View {
    // MARK: - Card Style

    /// Applies standard card styling with shadow and rounded corners
    /// - Parameters:
    ///   - padding: Internal padding for the card content (default: 16)
    ///   - cornerRadius: Corner radius for the card (default: Theme.CornerRadius.lg)
    ///   - shadowStyle: Shadow style to apply (default: .medium)
    /// - Returns: Styled view
    func cardStyle(
        padding: CGFloat = Theme.Spacing.lg,
        cornerRadius: CGFloat = Theme.CornerRadius.lg,
        shadowStyle: CardShadowStyle = .medium
    ) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Theme.Colors.background)
                    .shadow(
                        color: shadowStyle.shadow.color,
                        radius: shadowStyle.shadow.radius,
                        x: shadowStyle.shadow.x,
                        y: shadowStyle.shadow.y
                    )
            )
    }

    /// Applies card styling with a colored background
    /// - Parameters:
    ///   - color: Background color
    ///   - padding: Internal padding
    ///   - cornerRadius: Corner radius
    /// - Returns: Styled view
    func cardStyle(
        color: Color,
        opacity: Double = Theme.Opacity.light,
        padding: CGFloat = Theme.Spacing.lg,
        cornerRadius: CGFloat = Theme.CornerRadius.lg
    ) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color.opacity(opacity))
            )
    }

    // MARK: - Section Header Style

    /// Applies section header styling
    /// - Parameters:
    ///   - icon: Optional SF Symbol icon name
    ///   - color: Header color (default: primary)
    /// - Returns: Styled view
    func sectionHeaderStyle(
        icon: String? = nil,
        color: Color = Theme.Colors.primary
    ) -> some View {
        modifier(SectionHeaderModifier(icon: icon, color: color))
    }

    // MARK: - Pill Style

    /// Applies pill/badge styling
    /// - Parameters:
    ///   - color: Background color
    ///   - foregroundColor: Text color (default: white)
    /// - Returns: Styled view
    func pillStyle(
        color: Color,
        foregroundColor: Color = .white
    ) -> some View {
        self
            .font(Theme.Typography.caption1)
            .fontWeight(.semibold)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.xs)
            .background(
                Capsule()
                    .fill(color)
            )
    }

    // MARK: - Bordered Style

    /// Applies border styling
    /// - Parameters:
    ///   - color: Border color
    ///   - lineWidth: Border width (default: 1)
    ///   - cornerRadius: Corner radius (default: 8)
    /// - Returns: Styled view
    func borderedStyle(
        color: Color,
        lineWidth: CGFloat = 1,
        cornerRadius: CGFloat = Theme.CornerRadius.sm
    ) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(color, lineWidth: lineWidth)
            )
    }

    // MARK: - Shimmer Effect

    /// Applies a subtle shimmer/loading effect
    /// - Parameter isLoading: Whether to show the shimmer
    /// - Returns: Styled view
    func shimmer(isLoading: Bool = true) -> some View {
        modifier(ShimmerModifier(isLoading: isLoading))
    }
}

// MARK: - Card Shadow Style Enum

enum CardShadowStyle {
    case light
    case medium
    case heavy
    case none

    var shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        switch self {
        case .light:
            return Theme.Shadow.light
        case .medium:
            return Theme.Shadow.medium
        case .heavy:
            return Theme.Shadow.heavy
        case .none:
            return (Color.clear, 0, 0, 0)
        }
    }
}

// MARK: - Section Header Modifier

private struct SectionHeaderModifier: ViewModifier {
    let icon: String?
    let color: Color

    func body(content: Content) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(Theme.Typography.title3)
                    .foregroundColor(color)
            }

            content
                .font(Theme.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Shimmer Modifier

private struct ShimmerModifier: ViewModifier {
    let isLoading: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isLoading {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .white.opacity(0.3),
                                .clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 0.3)
                        .offset(x: phase * geometry.size.width)
                        .mask(content)
                    }
                }
            )
            .onAppear {
                if isLoading {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
            }
    }
}

// MARK: - Preview Helpers

#Preview("Card Styles") {
    ScrollView {
        VStack(spacing: 20) {
            // Standard card
            VStack(alignment: .leading, spacing: 8) {
                Text("Standard Card")
                    .font(Theme.Typography.headline)
                Text("This is a standard card with medium shadow.")
                    .font(Theme.Typography.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()

            // Colored card
            VStack(alignment: .leading, spacing: 8) {
                Text("Colored Card")
                    .font(Theme.Typography.headline)
                Text("This card has a colored background.")
                    .font(Theme.Typography.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle(color: .blue)

            // Light shadow card
            VStack(alignment: .leading, spacing: 8) {
                Text("Light Shadow Card")
                    .font(Theme.Typography.headline)
                Text("This card has a light shadow.")
                    .font(Theme.Typography.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle(shadowStyle: .light)
        }
        .padding()
    }
}

#Preview("Section Headers") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Standard Header")
            .sectionHeaderStyle()

        Text("Header with Icon")
            .sectionHeaderStyle(icon: "star.fill")

        Text("Colored Header")
            .sectionHeaderStyle(icon: "heart.fill", color: .red)
    }
    .padding()
}

#Preview("Pills") {
    VStack(spacing: 12) {
        Text("Critical")
            .pillStyle(color: Theme.Colors.critical)

        Text("Important")
            .pillStyle(color: Theme.Colors.important)

        Text("Subtle")
            .pillStyle(color: Theme.Colors.subtle)

        Text("Accent")
            .pillStyle(color: Theme.Colors.accent)
    }
    .padding()
}

#Preview("Borders") {
    VStack(spacing: 16) {
        Text("Bordered Text")
            .padding()
            .borderedStyle(color: .blue)

        Text("Custom Border")
            .padding()
            .borderedStyle(color: .red, lineWidth: 2, cornerRadius: 12)
    }
    .padding()
}
