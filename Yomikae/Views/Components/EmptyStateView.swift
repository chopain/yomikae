import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        systemImage: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Icon
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.Colors.accent, Theme.Colors.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolRenderingMode(.hierarchical)

            // Text content
            VStack(spacing: Theme.Spacing.sm) {
                Text(title)
                    .font(Theme.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(message)
                    .font(Theme.Typography.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Theme.Spacing.xxl)

            // Action button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Text(actionTitle)
                            .font(Theme.Typography.headline)

                        Image(systemName: "arrow.right")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.Colors.accent, Theme.Colors.primary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

// MARK: - Preset Empty States

extension EmptyStateView {
    /// Empty search results state
    static func noSearchResults(query: String, action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            systemImage: "magnifyingglass",
            title: "No Results",
            message: "No characters found for '\(query)'\nTry a different search term.",
            actionTitle: action != nil ? "Clear Search" : nil,
            action: action
        )
    }

    /// No recent searches state
    static func noRecentSearches() -> EmptyStateView {
        EmptyStateView(
            systemImage: "clock.arrow.circlepath",
            title: "No Recent Searches",
            message: "Your recently searched characters will appear here."
        )
    }

    /// No false friends state
    static func noFalseFriends(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            systemImage: "checkmark.circle.fill",
            title: "No False Friends Found",
            message: "No false friends match your current filters.\nTry adjusting your search criteria.",
            actionTitle: action != nil ? "Clear Filters" : nil,
            action: action
        )
    }

    /// Generic error state
    static func error(
        title: String = "Something Went Wrong",
        message: String = "We couldn't load the data. Please try again.",
        retryAction: @escaping () -> Void
    ) -> EmptyStateView {
        EmptyStateView(
            systemImage: "exclamationmark.triangle.fill",
            title: title,
            message: message,
            actionTitle: "Try Again",
            action: retryAction
        )
    }

    /// No internet connection state
    static func noConnection(retryAction: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            systemImage: "wifi.slash",
            title: "No Connection",
            message: "Please check your internet connection and try again.",
            actionTitle: "Retry",
            action: retryAction
        )
    }

    /// Success/completion state
    static func success(
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> EmptyStateView {
        EmptyStateView(
            systemImage: "checkmark.circle.fill",
            title: title,
            message: message,
            actionTitle: actionTitle,
            action: action
        )
    }
}

// MARK: - Previews

#Preview("Basic Empty State") {
    EmptyStateView(
        systemImage: "magnifyingglass",
        title: "No Results",
        message: "Try searching for a different character or word."
    )
}

#Preview("Empty State with Action") {
    EmptyStateView(
        systemImage: "tray.fill",
        title: "Nothing Here",
        message: "Get started by adding your first item.",
        actionTitle: "Add Item",
        action: { print("Action tapped") }
    )
}

#Preview("No Search Results") {
    EmptyStateView.noSearchResults(query: "漢字") {
        print("Clear search")
    }
}

#Preview("No Recent Searches") {
    EmptyStateView.noRecentSearches()
}

#Preview("No False Friends") {
    EmptyStateView.noFalseFriends {
        print("Clear filters")
    }
}

#Preview("Error State") {
    EmptyStateView.error {
        print("Retry")
    }
}

#Preview("No Connection") {
    EmptyStateView.noConnection {
        print("Retry")
    }
}

#Preview("Success State") {
    EmptyStateView.success(
        title: "All Done!",
        message: "You've completed all your reviews for today.",
        actionTitle: "Continue Learning",
        action: { print("Continue") }
    )
}
