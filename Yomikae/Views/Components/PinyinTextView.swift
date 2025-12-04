import SwiftUI

/// A view that displays Chinese text with pinyin annotations above characters.
///
/// Input format: "卫生间[wèi shēng jiān]的[de]手纸[shǒu zhǐ]用完了[yòng wán le]"
/// - Text in brackets becomes pinyin above the preceding characters
/// - Non-bracketed text displays normally
///
/// Example usage:
/// ```swift
/// PinyinTextView(text: "卫生间[wèi shēng jiān]的[de]手纸[shǒu zhǐ]")
/// ```
struct PinyinTextView: View {
    let text: String
    var baseFont: Font = .body
    var pinyinFont: Font = .caption2

    private var segments: [PinyinSegment] {
        PinyinParser.parse(text)
    }

    var body: some View {
        FlowLayout(spacing: 0) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                PinyinSegmentView(segment: segment, baseFont: baseFont, pinyinFont: pinyinFont)
            }
        }
    }
}

// MARK: - Segment View

private struct PinyinSegmentView: View {
    let segment: PinyinSegment
    let baseFont: Font
    let pinyinFont: Font

    var body: some View {
        if let pinyin = segment.pinyin {
            // Annotated segment with pinyin above
            VStack(spacing: 0) {
                Text(pinyin)
                    .font(pinyinFont)
                    .foregroundColor(.secondary)

                Text(segment.text)
                    .font(baseFont)
            }
        } else {
            // Plain text segment - add top padding to align with annotated text
            VStack(spacing: 0) {
                Text(" ")
                    .font(pinyinFont)
                    .foregroundColor(.clear)

                Text(segment.text)
                    .font(baseFont)
            }
        }
    }
}

// MARK: - Pinyin Segment Model

struct PinyinSegment {
    let text: String
    let pinyin: String?
}

// MARK: - Pinyin Parser

enum PinyinParser {
    /// Parses text with bracket notation into segments.
    ///
    /// Format: "汉字[hàn zì]" where brackets contain the pinyin for the preceding text.
    ///
    /// - Parameter text: The annotated text to parse
    /// - Returns: Array of segments with optional pinyin readings
    static func parse(_ text: String) -> [PinyinSegment] {
        var segments: [PinyinSegment] = []
        var currentText = ""
        var index = text.startIndex

        while index < text.endIndex {
            let char = text[index]

            if char == "[" {
                // Find the closing bracket
                if let closingIndex = text[index...].firstIndex(of: "]") {
                    let pinyinStart = text.index(after: index)
                    let pinyin = String(text[pinyinStart..<closingIndex])

                    // The preceding text (before the bracket) is the base text for this pinyin
                    if !currentText.isEmpty {
                        segments.append(PinyinSegment(text: currentText, pinyin: pinyin))
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
            segments.append(PinyinSegment(text: currentText, pinyin: nil))
        }

        return segments
    }
}

// MARK: - Simple Text View (Fallback)

/// A simple text view for Chinese sentences without pinyin markup.
/// Use this when the data doesn't have bracket annotations.
struct SimpleChineseTextView: View {
    let text: String
    var font: Font = .body

    var body: some View {
        Text(text)
            .font(font)
    }
}

// MARK: - Previews

#Preview("With Pinyin") {
    VStack(alignment: .leading, spacing: 20) {
        PinyinTextView(text: "卫生间[wèi shēng jiān]的[de]手纸[shǒu zhǐ]用完了[yòng wán le]。")

        PinyinTextView(text: "我[wǒ]在[zài]学习[xué xí]中文[zhōng wén]。")

        PinyinTextView(
            text: "他[tā]走[zǒu]得[de]很[hěn]快[kuài]。",
            baseFont: .title3,
            pinyinFont: .caption
        )
    }
    .padding()
}

#Preview("Without Pinyin") {
    VStack(alignment: .leading, spacing: 20) {
        SimpleChineseTextView(text: "卫生间的手纸用完了。")

        SimpleChineseTextView(text: "我在学习中文。", font: .title3)
    }
    .padding()
}

#Preview("Mixed Content") {
    VStack(alignment: .leading, spacing: 20) {
        Text("Example with pinyin:")
            .font(.headline)

        PinyinTextView(text: "今天[jīn tiān]天气[tiān qì]很[hěn]好[hǎo]。")

        Divider()

        Text("Same sentence without markup:")
            .font(.headline)

        SimpleChineseTextView(text: "今天天气很好。")
    }
    .padding()
}
