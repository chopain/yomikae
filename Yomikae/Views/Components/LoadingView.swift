import SwiftUI

struct LoadingView: View {
    let message: String?

    init(message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Theme.Colors.accent)

            if let message = message {
                Text(message)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

// MARK: - Inline Loading View

struct InlineLoadingView: View {
    let message: String?

    init(message: String? = "Loading...") {
        self.message = message
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            ProgressView()
                .tint(Theme.Colors.accent)

            if let message = message {
                Text(message)
                    .font(Theme.Typography.callout)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
    }
}

// MARK: - Shimmer Loading Card

struct LoadingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Title shimmer
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(height: 20)
                .frame(maxWidth: 200)

            // Content shimmer
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(height: 16)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(height: 16)
                .frame(maxWidth: 300)
        }
        .cardStyle()
        .shimmer()
    }
}

// MARK: - Previews

#Preview("Full Screen Loading") {
    LoadingView(message: "Loading characters...")
}

#Preview("Loading without message") {
    LoadingView()
}

#Preview("Inline Loading") {
    VStack {
        InlineLoadingView()
        InlineLoadingView(message: "Fetching data...")
        InlineLoadingView(message: nil)
    }
}

#Preview("Loading Cards") {
    ScrollView {
        VStack(spacing: 16) {
            LoadingCard()
            LoadingCard()
            LoadingCard()
        }
        .padding()
    }
}
