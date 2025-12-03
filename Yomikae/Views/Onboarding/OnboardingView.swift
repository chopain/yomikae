import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var settings = UserSettings.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo and Title Section
            VStack(spacing: 16) {
                // App Icon/Logo
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 8)

                // App Name
                Text("読み替え")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)

                Text("Yomikae")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                // Tagline
                Text("Learn Japanese kanji using the Chinese you already know")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }

            Spacer()

            // Chinese System Selection
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Which Chinese do you read?")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("This helps us show relevant warnings. Some false friends only affect Simplified Chinese readers.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 12) {
                    ChineseSystemOption(
                        system: .simplified,
                        title: "Simplified Chinese",
                        subtitle: "简体中文",
                        regions: "Mainland China, Singapore",
                        isSelected: settings.chineseSystem == .simplified
                    ) {
                        settings.chineseSystem = .simplified
                    }

                    ChineseSystemOption(
                        system: .traditional,
                        title: "Traditional Chinese",
                        subtitle: "繁體中文",
                        regions: "Taiwan, Hong Kong, Macau",
                        isSelected: settings.chineseSystem == .traditional
                    ) {
                        settings.chineseSystem = .traditional
                    }

                    ChineseSystemOption(
                        system: .both,
                        title: "Both Systems",
                        subtitle: "简体 & 繁體",
                        regions: "I'm comfortable with both",
                        isSelected: settings.chineseSystem == .both
                    ) {
                        settings.chineseSystem = .both
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Get Started Button
            Button(action: {
                settings.hasCompletedOnboarding = true
                dismiss()
            }) {
                HStack {
                    Text("Get Started")
                        .font(.headline)

                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.vertical)
    }
}

// MARK: - Chinese System Option

struct ChineseSystemOption: View {
    let system: ChineseSystem
    let title: String
    let subtitle: String
    let regions: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Radio button
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.accentColor : Color.secondary, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 12, height: 12)
                    }
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text(regions)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Default") {
    OnboardingView()
}

#Preview("Simplified Selected") {
    OnboardingView()
        .onAppear {
            UserSettings.shared.chineseSystem = .simplified
        }
}

#Preview("Traditional Selected") {
    OnboardingView()
        .onAppear {
            UserSettings.shared.chineseSystem = .traditional
        }
}

#Preview("Both Selected") {
    OnboardingView()
        .onAppear {
            UserSettings.shared.chineseSystem = .both
        }
}
