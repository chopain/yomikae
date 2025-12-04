import SwiftUI

/// A view that displays Japanese text with furigana (reading) annotations above kanji.
///
/// Input format: "友達[ともだち]に手紙[てがみ]を書いた[かいた]"
/// - Text in brackets becomes furigana above the preceding kanji
/// - Non-bracketed text displays normally
///
/// Example usage:
/// ```swift
/// FuriganaTextView(text: "友達[ともだち]に手紙[てがみ]を書いた[かいた]")
/// ```
struct FuriganaTextView: View {
    let text: String
    var baseFont: Font = .body
    var furiganaFont: Font = .caption2

    private var segments: [FuriganaSegment] {
        FuriganaParser.parse(text)
    }

    var body: some View {
        FlowLayout(spacing: 0) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                SegmentView(segment: segment, baseFont: baseFont, furiganaFont: furiganaFont)
            }
        }
    }
}

// MARK: - Segment View

private struct SegmentView: View {
    let segment: FuriganaSegment
    let baseFont: Font
    let furiganaFont: Font

    var body: some View {
        if let furigana = segment.furigana {
            // Annotated segment with furigana above
            VStack(spacing: 0) {
                Text(furigana)
                    .font(furiganaFont)
                    .foregroundColor(.secondary)

                Text(segment.text)
                    .font(baseFont)
            }
        } else {
            // Plain text segment - add top padding to align with annotated text
            VStack(spacing: 0) {
                Text(" ")
                    .font(furiganaFont)
                    .foregroundColor(.clear)

                Text(segment.text)
                    .font(baseFont)
            }
        }
    }
}

// MARK: - Furigana Segment Model

struct FuriganaSegment {
    let text: String
    let furigana: String?
}

// MARK: - Furigana Parser

enum FuriganaParser {
    /// Parses text with bracket notation into segments.
    ///
    /// Format: "漢字[かんじ]" where brackets contain the reading for the preceding text.
    ///
    /// - Parameter text: The annotated text to parse
    /// - Returns: Array of segments with optional furigana readings
    static func parse(_ text: String) -> [FuriganaSegment] {
        var segments: [FuriganaSegment] = []
        var currentText = ""
        var index = text.startIndex

        while index < text.endIndex {
            let char = text[index]

            if char == "[" {
                // Find the closing bracket
                if let closingIndex = text[index...].firstIndex(of: "]") {
                    let furiganaStart = text.index(after: index)
                    let furigana = String(text[furiganaStart..<closingIndex])

                    // The preceding text (before the bracket) is the base text for this furigana
                    // We need to figure out how many characters the furigana applies to
                    // For simplicity, assume the furigana applies to all accumulated currentText
                    // that hasn't been added as a segment yet
                    if !currentText.isEmpty {
                        // Find where the kanji portion starts (usually at the end of currentText)
                        // For now, assume the entire currentText is the kanji
                        segments.append(FuriganaSegment(text: currentText, furigana: furigana))
                        currentText = ""
                    }

                    index = text.index(after: closingIndex)
                    continue
                }
            }

            currentText.append(char)
            index = text.index(after: index)
        }

        // Add any remaining text
        if !currentText.isEmpty {
            segments.append(FuriganaSegment(text: currentText, furigana: nil))
        }

        return segments
    }
}

// MARK: - Flow Layout

/// A horizontal flow layout that wraps content to new lines as needed.
struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> ArrangementResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            // Check if we need to wrap to next line
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))

            currentX += size.width
            lineHeight = max(lineHeight, size.height)
            totalWidth = max(totalWidth, currentX)
            totalHeight = max(totalHeight, currentY + lineHeight)
        }

        return ArrangementResult(
            positions: positions,
            size: CGSize(width: totalWidth, height: totalHeight)
        )
    }

    private struct ArrangementResult {
        let positions: [CGPoint]
        let size: CGSize
    }
}

// MARK: - Simple Text View (Fallback)

/// A simple text view for sentences without furigana markup.
/// Use this when the data doesn't have bracket annotations.
struct SimpleJapaneseTextView: View {
    let text: String
    var font: Font = .body

    var body: some View {
        Text(text)
            .font(font)
    }
}

// MARK: - Previews

#Preview("With Furigana") {
    VStack(alignment: .leading, spacing: 20) {
        FuriganaTextView(text: "友達[ともだち]に手紙[てがみ]を書[か]いた。")

        FuriganaTextView(text: "日本語[にほんご]を勉強[べんきょう]しています。")

        FuriganaTextView(
            text: "走[はし]るのが好[す]きです。",
            baseFont: .title3,
            furiganaFont: .caption
        )
    }
    .padding()
}

#Preview("Without Furigana") {
    VStack(alignment: .leading, spacing: 20) {
        SimpleJapaneseTextView(text: "友達に手紙を書いた。")

        SimpleJapaneseTextView(text: "日本語を勉強しています。", font: .title3)
    }
    .padding()
}

#Preview("Mixed Content") {
    VStack(alignment: .leading, spacing: 20) {
        Text("Example with furigana:")
            .font(.headline)

        FuriganaTextView(text: "私[わたし]は毎日[まいにち]本[ほん]を読[よ]みます。")

        Divider()

        Text("Same sentence without markup:")
            .font(.headline)

        SimpleJapaneseTextView(text: "私は毎日本を読みます。")
    }
    .padding()
}
