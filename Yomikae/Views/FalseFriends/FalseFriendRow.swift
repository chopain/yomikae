import SwiftUI

struct FalseFriendRow: View {
    let falseFriend: FalseFriend

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Left side: Character with severity-colored background
            ZStack(alignment: .topTrailing) {
                Text(falseFriend.character)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(falseFriend.severity.color)
                    )

                // Affected system indicator
                if falseFriend.affectedSystem != .both {
                    Text(affectedSystemIndicator)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(4)
                        .offset(x: 4, y: -4)
                }
            }

            // Right side: Meaning comparison
            VStack(alignment: .leading, spacing: 8) {
                // Japanese meaning
                HStack(spacing: 6) {
                    Text("🇯🇵")
                        .font(.caption)

                    Text(firstJapaneseMeaning)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }

                // Visual separator with "≠" symbol
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.caption2)
                        .foregroundColor(falseFriend.severity.color)

                    Text("≠")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(falseFriend.severity.color)

                    Spacer()
                }

                // Chinese meaning
                HStack(spacing: 6) {
                    Text("🇨🇳")
                        .font(.caption)

                    Text(firstChineseMeaning)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }

                // Category badge
                HStack(spacing: 4) {
                    Image(systemName: categoryIcon)
                        .font(.caption2)

                    Text(falseFriend.category.displayName)
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }

    // MARK: - Computed Properties

    private var firstJapaneseMeaning: String {
        falseFriend.jpMeanings.first ?? "—"
    }

    private var firstChineseMeaning: String {
        falseFriend.cnMeaningsSimplified.first ?? "—"
    }

    private var affectedSystemIndicator: String {
        switch falseFriend.affectedSystem {
        case .simplifiedOnly:
            return "简"
        case .traditionalOnly:
            return "繁"
        case .both:
            return ""
        }
    }

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

// MARK: - Alternative Design: "vs" Style

struct FalseFriendRowVsStyle: View {
    let falseFriend: FalseFriend

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Character badge
            Text(falseFriend.character)
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(falseFriend.severity.color)
                )

            // Meanings comparison with "vs"
            VStack(spacing: 10) {
                // Japanese
                HStack(spacing: 6) {
                    Text("🇯🇵")
                    Text(falseFriend.jpMeanings.first ?? "—")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // VS divider
                Text("vs")
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundColor(falseFriend.severity.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(falseFriend.severity.color.opacity(0.2))
                    )

                // Chinese
                HStack(spacing: 6) {
                    Text("🇨🇳")
                    Text(falseFriend.cnMeaningsSimplified.first ?? "—")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Alternative Design: Compact with Colored Meanings

struct FalseFriendRowCompact: View {
    let falseFriend: FalseFriend

    var body: some View {
        HStack(spacing: 12) {
            // Character
            Text(falseFriend.character)
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(falseFriend.severity.color)
                )

            VStack(alignment: .leading, spacing: 4) {
                // Title with contrast indicator
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(falseFriend.severity.color)

                    Text(falseFriend.severity.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(falseFriend.severity.color)
                }

                // Meanings with contrast
                HStack(spacing: 8) {
                    // Japanese
                    HStack(spacing: 3) {
                        Text("🇯🇵")
                            .font(.system(size: 10))
                        Text(falseFriend.jpMeanings.first ?? "—")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)

                    Text("≠")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    // Chinese
                    HStack(spacing: 3) {
                        Text("🇨🇳")
                            .font(.system(size: 10))
                        Text(falseFriend.cnMeaningsSimplified.first ?? "—")
                            .font(.caption)
                            .foregroundColor(.red)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(4)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

// MARK: - Previews

#Preview("Standard Row - Critical") {
    List {
        FalseFriendRow(
            falseFriend: FalseFriend(
                id: "ff1",
                character: "走",
                jpMeanings: ["run"],
                cnMeaningsSimplified: ["walk", "go"],
                cnMeaningsTraditional: ["walk", "go"],
                severity: .critical,
                category: .trueDivergence,
                affectedSystem: .both,
                explanation: "Different meanings.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            )
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}

#Preview("Standard Row - Important") {
    List {
        FalseFriendRow(
            falseFriend: FalseFriend(
                id: "ff2",
                character: "勉",
                jpMeanings: ["strive", "endeavor"],
                cnMeaningsSimplified: ["reluctantly", "barely"],
                cnMeaningsTraditional: ["reluctantly"],
                severity: .important,
                category: .scopeDifference,
                affectedSystem: .both,
                explanation: "Different connotations.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            )
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}

#Preview("Simplified-Only") {
    List {
        FalseFriendRow(
            falseFriend: FalseFriend(
                id: "ff3",
                character: "后",
                jpMeanings: ["empress", "queen"],
                cnMeaningsSimplified: ["after", "behind"],
                cnMeaningsTraditional: ["empress"],
                severity: .important,
                category: .simplificationMerge,
                affectedSystem: .simplifiedOnly,
                explanation: "Merged in simplified.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: ["後", "后"]
            )
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}

#Preview("All Styles Comparison") {
    ScrollView {
        VStack(spacing: 20) {
            Text("Standard Style")
                .font(.headline)
            FalseFriendRow(
                falseFriend: FalseFriend(
                    id: "ff1",
                    character: "走",
                    jpMeanings: ["run"],
                    cnMeaningsSimplified: ["walk"],
                    cnMeaningsTraditional: ["walk"],
                    severity: .critical,
                    category: .trueDivergence,
                    affectedSystem: .both,
                    explanation: "Different meanings.",
                    examples: [],
                    traditionalNote: nil,
                    mergedFrom: nil
                )
            )

            Divider()

            Text("VS Style")
                .font(.headline)
            FalseFriendRowVsStyle(
                falseFriend: FalseFriend(
                    id: "ff1",
                    character: "走",
                    jpMeanings: ["run"],
                    cnMeaningsSimplified: ["walk"],
                    cnMeaningsTraditional: ["walk"],
                    severity: .critical,
                    category: .trueDivergence,
                    affectedSystem: .both,
                    explanation: "Different meanings.",
                    examples: [],
                    traditionalNote: nil,
                    mergedFrom: nil
                )
            )

            Divider()

            Text("Compact Style")
                .font(.headline)
            FalseFriendRowCompact(
                falseFriend: FalseFriend(
                    id: "ff1",
                    character: "走",
                    jpMeanings: ["run"],
                    cnMeaningsSimplified: ["walk"],
                    cnMeaningsTraditional: ["walk"],
                    severity: .critical,
                    category: .trueDivergence,
                    affectedSystem: .both,
                    explanation: "Different meanings.",
                    examples: [],
                    traditionalNote: nil,
                    mergedFrom: nil
                )
            )
        }
        .padding()
    }
}

#Preview("Multiple Rows") {
    List {
        FalseFriendRow(
            falseFriend: FalseFriend(
                id: "ff1",
                character: "走",
                jpMeanings: ["run"],
                cnMeaningsSimplified: ["walk", "go"],
                cnMeaningsTraditional: ["walk"],
                severity: .critical,
                category: .trueDivergence,
                affectedSystem: .both,
                explanation: "Different meanings.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            )
        )

        FalseFriendRow(
            falseFriend: FalseFriend(
                id: "ff2",
                character: "勉",
                jpMeanings: ["strive", "endeavor"],
                cnMeaningsSimplified: ["reluctantly"],
                cnMeaningsTraditional: ["reluctantly"],
                severity: .important,
                category: .scopeDifference,
                affectedSystem: .both,
                explanation: "Different connotations.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            )
        )

        FalseFriendRow(
            falseFriend: FalseFriend(
                id: "ff3",
                character: "后",
                jpMeanings: ["empress"],
                cnMeaningsSimplified: ["after", "behind"],
                cnMeaningsTraditional: ["empress"],
                severity: .important,
                category: .simplificationMerge,
                affectedSystem: .simplifiedOnly,
                explanation: "Merged in simplified.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            )
        )

        FalseFriendRow(
            falseFriend: FalseFriend(
                id: "ff4",
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
            )
        )
    }
    .listStyle(.plain)
}
