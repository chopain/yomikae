import SwiftUI

/// Displays a compound word with each character separately tappable
struct TappableCharacterRow: View {
    let compound: String
    let highlightColor: Color
    let onCharacterTap: (String) -> Void

    private var characters: [String] {
        compound.map { String($0) }
    }

    var body: some View {
        // Only show if compound has multiple characters
        if characters.count > 1 {
            VStack(spacing: 8) {
                // Row of tappable characters
                HStack(spacing: 4) {
                    ForEach(Array(characters.enumerated()), id: \.offset) { index, char in
                        Button {
                            onCharacterTap(char)
                        } label: {
                            Text(char)
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(highlightColor)
                                .frame(minWidth: 50, minHeight: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(highlightColor.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(highlightColor.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)

                        // Add separator between characters (except last)
                        if index < characters.count - 1 {
                            Text("+")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Hint text
                HStack(spacing: 4) {
                    Image(systemName: "hand.tap")
                        .font(.caption2)
                    Text("Tap each character for details")
                        .font(.caption2)
                }
                .foregroundColor(.secondary.opacity(0.7))
            }
        }
    }
}

// MARK: - Preview

#Preview("Two Characters") {
    TappableCharacterRow(
        compound: "勉強",
        highlightColor: .blue,
        onCharacterTap: { char in
            print("Tapped: \(char)")
        }
    )
    .padding()
}

#Preview("Three Characters") {
    TappableCharacterRow(
        compound: "図書館",
        highlightColor: .red,
        onCharacterTap: { char in
            print("Tapped: \(char)")
        }
    )
    .padding()
}

#Preview("Single Character - Hidden") {
    VStack {
        Text("Single character (should show nothing below):")
        TappableCharacterRow(
            compound: "走",
            highlightColor: .blue,
            onCharacterTap: { char in
                print("Tapped: \(char)")
            }
        )
    }
    .padding()
}

#Preview("Four Characters") {
    TappableCharacterRow(
        compound: "日本語学",
        highlightColor: .purple,
        onCharacterTap: { char in
            print("Tapped: \(char)")
        }
    )
    .padding()
}
