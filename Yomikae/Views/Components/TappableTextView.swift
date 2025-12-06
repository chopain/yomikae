import SwiftUI

/// A text view that makes kanji compounds tappable
struct TappableTextView: View {
    let text: String
    let language: TappableTextLanguage
    let onWordTap: (String) -> Void

    var body: some View {
        let segments = parseText(text)

        // Use a FlowLayout-like approach with HStack and line wrapping
        WrappingHStack(alignment: .leading, spacing: 0) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                if segment.isTappable {
                    Button(action: {
                        onWordTap(segment.text)
                    }) {
                        Text(segment.text)
                            .underline(color: .accentColor.opacity(0.5))
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(segment.text)
                        .foregroundColor(.primary)
                }
            }
        }
    }

    // MARK: - Text Parsing

    private func parseText(_ text: String) -> [TextSegment] {
        var segments: [TextSegment] = []
        var currentSegment = ""
        var isInKanjiSequence = false

        for char: Swift.Character in text {
            let isKanji = char.isKanji

            if isKanji {
                if !isInKanjiSequence {
                    // End non-kanji segment
                    if !currentSegment.isEmpty {
                        segments.append(TextSegment(text: currentSegment, isTappable: false))
                        currentSegment = ""
                    }
                    isInKanjiSequence = true
                }
                currentSegment.append(char)
            } else {
                if isInKanjiSequence {
                    // End kanji segment - only tappable if 1+ kanji
                    if !currentSegment.isEmpty {
                        segments.append(TextSegment(text: currentSegment, isTappable: currentSegment.count >= 1))
                        currentSegment = ""
                    }
                    isInKanjiSequence = false
                }
                currentSegment.append(char)
            }
        }

        // Add final segment
        if !currentSegment.isEmpty {
            segments.append(TextSegment(text: currentSegment, isTappable: isInKanjiSequence && currentSegment.count >= 1))
        }

        return segments
    }
}

// MARK: - Supporting Types

enum TappableTextLanguage {
    case japanese
    case chinese
}

private struct TextSegment {
    let text: String
    let isTappable: Bool
}

// MARK: - Character Extension for Kanji Detection

extension Swift.Character {
    var isKanji: Bool {
        // CJK Unified Ideographs range
        let scalar = self.unicodeScalars.first!
        return (scalar.value >= 0x4E00 && scalar.value <= 0x9FFF) ||  // CJK Unified Ideographs
               (scalar.value >= 0x3400 && scalar.value <= 0x4DBF) ||  // CJK Unified Ideographs Extension A
               (scalar.value >= 0xF900 && scalar.value <= 0xFAFF) ||  // CJK Compatibility Ideographs
               (scalar.value >= 0x20000 && scalar.value <= 0x2A6DF)   // CJK Unified Ideographs Extension B
    }
}

// MARK: - Wrapping HStack

/// A horizontal stack that wraps content to new lines
struct WrappingHStack: Layout {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )

        for (index, subview) in subviews.enumerated() {
            let point = result.positions[index]
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width
                maxX = max(maxX, currentX)
            }

            size = CGSize(width: maxX, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview("Japanese Example") {
    VStack(alignment: .leading, spacing: 20) {
        TappableTextView(
            text: "友達に手紙を書いた",
            language: .japanese,
            onWordTap: { word in
                print("Tapped: \(word)")
            }
        )
        .font(.title3)

        TappableTextView(
            text: "日本語を勉強しています",
            language: .japanese,
            onWordTap: { word in
                print("Tapped: \(word)")
            }
        )
        .font(.body)

        TappableTextView(
            text: "走って学校に行く",
            language: .japanese,
            onWordTap: { word in
                print("Tapped: \(word)")
            }
        )
        .font(.body)
    }
    .padding()
}

#Preview("Chinese Example") {
    TappableTextView(
        text: "我给朋友写了一封信",
        language: .chinese,
        onWordTap: { word in
            print("Tapped: \(word)")
        }
    )
    .font(.title3)
    .padding()
}
