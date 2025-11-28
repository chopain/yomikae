import SwiftUI

// MARK: - False Friend Banner (Detailed)

struct FalseFriendBanner: View {
    let falseFriend: FalseFriend
    let onTap: (() -> Void)?

    @ObservedObject private var settings = UserSettings.shared

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Main warning row
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundColor(bannerColor)

                    Text("FALSE FRIEND")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(bannerColor)

                    Spacer()

                    // Severity badge
                    SeverityBadge(severity: falseFriend.severity)
                }

                // Affected system notice
                if falseFriend.affectedSystem == .simplifiedOnly {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .font(.caption)
                                .foregroundColor(affectsNoticeColor)

                            Text("Affects Simplified Chinese readers only")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(affectsNoticeColor)
                        }

                        // Show reassurance if user reads Traditional
                        if settings.chineseSystem == .traditional {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)

                                Text("You read Traditional Chinese ✓")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else if falseFriend.affectedSystem == .traditionalOnly {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                            .foregroundColor(affectsNoticeColor)

                        Text("Affects Traditional Chinese readers only")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(affectsNoticeColor)
                    }

                    // Show reassurance if user reads Simplified
                    if settings.chineseSystem == .simplified {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)

                            Text("You read Simplified Chinese ✓")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Category explanation
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: categoryIcon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 16)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(falseFriend.category.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Text(falseFriend.category.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Tap hint if onTap is provided
                if onTap != nil {
                    HStack {
                        Spacer()
                        Text("Tap for details")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
    }

    // MARK: - Computed Properties

    /// Determines if this false friend is relevant to the user
    private var isRelevantToUser: Bool {
        falseFriend.isRelevant(for: settings.chineseSystem)
    }

    /// Banner color based on severity and relevance
    private var bannerColor: Color {
        if !isRelevantToUser {
            return .secondary
        }
        return falseFriend.severity.color
    }

    /// Background color for the banner
    private var backgroundColor: Color {
        if !isRelevantToUser {
            return Color(.systemGray6)
        }
        return falseFriend.severity.color.opacity(0.1)
    }

    /// Border color for the banner
    private var borderColor: Color {
        if !isRelevantToUser {
            return Color(.systemGray4)
        }
        return falseFriend.severity.color.opacity(0.3)
    }

    /// Color for the "affects" notice text
    private var affectsNoticeColor: Color {
        if !isRelevantToUser {
            return .secondary
        }
        return falseFriend.severity.color
    }

    /// Icon for the category
    private var categoryIcon: String {
        switch falseFriend.category {
        case .trueDivergence:
            return "arrow.triangle.branch"
        case .simplificationMerge:
            return "arrow.triangle.merge"
        case .japaneseCoinage:
            return "yensign.circle"
        case .scopeDifference:
            return "scope"
        }
    }
}

// MARK: - Severity Badge

private struct SeverityBadge: View {
    let severity: Severity

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: severity.icon)
                .font(.caption2)

            Text(severity.displayName)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(severity.color)
        .cornerRadius(6)
    }
}

// MARK: - False Friend Badge (Compact)

struct FalseFriendBadge: View {
    let severity: Severity
    let affectedSystem: AffectedSystem

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: severity.icon)
                .font(.system(size: 10))

            // Show "简" indicator if simplified-only
            if affectedSystem == .simplifiedOnly {
                Text("简")
                    .font(.system(size: 10, weight: .bold))
            }
            // Show "繁" indicator if traditional-only
            else if affectedSystem == .traditionalOnly {
                Text("繁")
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(severity.color)
        .cornerRadius(4)
    }
}

// MARK: - Previews

#Preview("Critical - Both Systems") {
    FalseFriendBanner(
        falseFriend: FalseFriend(
            id: "ff1",
            character: "走",
            jpMeanings: ["run"],
            cnMeaningsSimplified: ["walk"],
            cnMeaningsTraditional: ["walk"],
            severity: .critical,
            category: .trueDivergence,
            affectedSystem: .both,
            explanation: "This character has completely different meanings in Japanese and Chinese.",
            examples: [],
            traditionalNote: nil,
            mergedFrom: nil
        ),
        onTap: { print("Tapped") }
    )
    .padding()
}

#Preview("Simplified Only - User Reads Traditional") {
    FalseFriendBanner(
        falseFriend: FalseFriend(
            id: "ff2",
            character: "后",
            jpMeanings: ["emperor", "queen"],
            cnMeaningsSimplified: ["after", "behind"],
            cnMeaningsTraditional: ["empress"],
            severity: .important,
            category: .simplificationMerge,
            affectedSystem: .simplifiedOnly,
            explanation: "Simplified Chinese merged two characters.",
            examples: [],
            traditionalNote: nil,
            mergedFrom: ["後", "后"]
        ),
        onTap: nil
    )
    .padding()
    .onAppear {
        UserSettings.shared.chineseSystem = .traditional
    }
}

#Preview("Simplified Only - User Reads Simplified") {
    FalseFriendBanner(
        falseFriend: FalseFriend(
            id: "ff2",
            character: "后",
            jpMeanings: ["emperor", "queen"],
            cnMeaningsSimplified: ["after", "behind"],
            cnMeaningsTraditional: ["empress"],
            severity: .important,
            category: .simplificationMerge,
            affectedSystem: .simplifiedOnly,
            explanation: "Simplified Chinese merged two characters.",
            examples: [],
            traditionalNote: nil,
            mergedFrom: ["後", "后"]
        ),
        onTap: { print("Tapped") }
    )
    .padding()
    .onAppear {
        UserSettings.shared.chineseSystem = .simplified
    }
}

#Preview("Subtle - Japanese Coinage") {
    FalseFriendBanner(
        falseFriend: FalseFriend(
            id: "ff3",
            character: "腺",
            jpMeanings: ["gland"],
            cnMeaningsSimplified: ["gland"],
            cnMeaningsTraditional: ["gland"],
            severity: .subtle,
            category: .japaneseCoinage,
            affectedSystem: .both,
            explanation: "Character created in Japan for anatomy.",
            examples: [],
            traditionalNote: nil,
            mergedFrom: nil
        ),
        onTap: { print("Tapped") }
    )
    .padding()
}

#Preview("Compact Badges") {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            FalseFriendBadge(severity: .critical, affectedSystem: .both)
            FalseFriendBadge(severity: .important, affectedSystem: .both)
            FalseFriendBadge(severity: .subtle, affectedSystem: .both)
        }

        HStack(spacing: 12) {
            FalseFriendBadge(severity: .critical, affectedSystem: .simplifiedOnly)
            FalseFriendBadge(severity: .important, affectedSystem: .simplifiedOnly)
            FalseFriendBadge(severity: .subtle, affectedSystem: .simplifiedOnly)
        }

        HStack(spacing: 12) {
            FalseFriendBadge(severity: .critical, affectedSystem: .traditionalOnly)
            FalseFriendBadge(severity: .important, affectedSystem: .traditionalOnly)
            FalseFriendBadge(severity: .subtle, affectedSystem: .traditionalOnly)
        }
    }
    .padding()
    .background(Color(.systemBackground))
}

#Preview("All Severities") {
    VStack(spacing: 16) {
        FalseFriendBanner(
            falseFriend: FalseFriend(
                id: "ff1",
                character: "走",
                jpMeanings: ["run"],
                cnMeaningsSimplified: ["walk"],
                cnMeaningsTraditional: ["walk"],
                severity: .critical,
                category: .trueDivergence,
                affectedSystem: .both,
                explanation: "Completely different meanings.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            ),
            onTap: nil
        )

        FalseFriendBanner(
            falseFriend: FalseFriend(
                id: "ff2",
                character: "勉",
                jpMeanings: ["strive"],
                cnMeaningsSimplified: ["reluctantly"],
                cnMeaningsTraditional: ["reluctantly"],
                severity: .important,
                category: .scopeDifference,
                affectedSystem: .both,
                explanation: "Different connotations.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            ),
            onTap: nil
        )

        FalseFriendBanner(
            falseFriend: FalseFriend(
                id: "ff3",
                character: "腺",
                jpMeanings: ["gland"],
                cnMeaningsSimplified: ["gland"],
                cnMeaningsTraditional: ["gland"],
                severity: .subtle,
                category: .japaneseCoinage,
                affectedSystem: .both,
                explanation: "Created in Japan.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            ),
            onTap: nil
        )
    }
    .padding()
}
