import SwiftUI

struct ReadingSection: View {
    let flag: String
    let language: String
    let readings: [(label: String, value: String)]
    let meanings: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with flag and language
            HStack(spacing: 8) {
                Text(flag)
                    .font(.title2)

                Text(language)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 12) {
                // Readings
                if !readings.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(readings, id: \.label) { reading in
                            ReadingRow(label: reading.label, value: reading.value)
                        }
                    }
                }

                // Meanings
                if !meanings.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Meanings")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Text(meanings.joined(separator: ", "))
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

// MARK: - Reading Row Component

private struct ReadingRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 90, alignment: .leading)

            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("Japanese Reading") {
    ReadingSection(
        flag: "🇯🇵",
        language: "Japanese",
        readings: [
            (label: "On'yomi", value: "ガク、ガッ"),
            (label: "Kun'yomi", value: "まな.ぶ")
        ],
        meanings: ["study", "learning", "science"]
    )
    .padding()
}

#Preview("Chinese Reading") {
    ReadingSection(
        flag: "🇨🇳",
        language: "Chinese",
        readings: [
            (label: "Pinyin", value: "xué")
        ],
        meanings: ["study", "learn", "school", "knowledge"]
    )
    .padding()
}

#Preview("Multiple Readings") {
    VStack(spacing: 20) {
        ReadingSection(
            flag: "🇯🇵",
            language: "Japanese",
            readings: [
                (label: "On'yomi", value: "ソウ"),
                (label: "Kun'yomi", value: "はし.る")
            ],
            meanings: ["run"]
        )

        ReadingSection(
            flag: "🇨🇳",
            language: "Chinese",
            readings: [
                (label: "Pinyin", value: "zǒu"),
                (label: "Simplified", value: "走"),
                (label: "Traditional", value: "走")
            ],
            meanings: ["walk", "go", "leave"]
        )
    }
    .padding()
}

#Preview("Long Meanings") {
    ReadingSection(
        flag: "🇯🇵",
        language: "Japanese",
        readings: [
            (label: "On'yomi", value: "ベン、メン"),
            (label: "Kun'yomi", value: "つと.める")
        ],
        meanings: [
            "exertion",
            "endeavor",
            "encourage",
            "strive",
            "make effort",
            "diligent"
        ]
    )
    .padding()
}

#Preview("Empty Readings") {
    ReadingSection(
        flag: "🇨🇳",
        language: "Chinese",
        readings: [],
        meanings: ["example", "sample"]
    )
    .padding()
}
