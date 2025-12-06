import SwiftUI

/// A reusable speaker button that shows animation while speech is active
struct SpeakerButton: View {
    var forLanguage: SpeakingLanguage = .none
    let action: () -> Void

    @ObservedObject private var speechService = SpeechService.shared

    private var isThisButtonSpeaking: Bool {
        guard forLanguage != .none else {
            // If no language specified, animate for any speech
            return speechService.isSpeaking
        }
        return speechService.isSpeaking && speechService.speakingLanguage == forLanguage
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: isThisButtonSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.body)
                .foregroundColor(.accentColor)
                .symbolEffect(.variableColor.iterative, isActive: isThisButtonSpeaking)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 20) {
        SpeakerButton {
            print("Speak!")
        }

        Text("Example text")
    }
    .padding()
}
