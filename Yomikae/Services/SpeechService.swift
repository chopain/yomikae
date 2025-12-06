import AVFoundation
import Combine

/// Identifies which language is currently being spoken
enum SpeakingLanguage: Equatable {
    case none
    case japanese
    case chinese
}

/// Service for text-to-speech functionality using AVSpeechSynthesizer
class SpeechService: NSObject, ObservableObject {
    static let shared = SpeechService()

    @Published private(set) var isSpeaking: Bool = false
    @Published private(set) var speakingLanguage: SpeakingLanguage = .none

    private let synthesizer = AVSpeechSynthesizer()

    private override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true)
            print("[SpeechService] Audio session configured successfully")
        } catch {
            print("[SpeechService] Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Public Methods

    /// Check if Japanese is currently being spoken
    var isSpeakingJapanese: Bool {
        isSpeaking && speakingLanguage == .japanese
    }

    /// Check if Chinese is currently being spoken
    var isSpeakingChinese: Bool {
        isSpeaking && speakingLanguage == .chinese
    }

    /// Speak Japanese text using ja-JP voice
    func speakJapanese(_ text: String) {
        speakingLanguage = .japanese
        speak(text: text, language: "ja-JP")
    }

    /// Speak Chinese text
    /// - Parameters:
    ///   - text: The text to speak
    ///   - traditional: If true, uses zh-TW (Traditional), otherwise zh-CN (Simplified)
    func speakChinese(_ text: String, traditional: Bool = false) {
        speakingLanguage = .chinese
        let language = traditional ? "zh-TW" : "zh-CN"
        speak(text: text, language: language)
    }

    /// Stop any current speech
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - Private Methods

    private func speak(text: String, language: String) {
        print("[SpeechService] speak() called with text: '\(text)', language: \(language)")

        // Stop any current speech first
        stop()

        // Re-activate audio session before speaking
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[SpeechService] Failed to activate audio session: \(error)")
        }

        let utterance = AVSpeechUtterance(string: text)

        // Try to get the requested voice, fall back to any available voice for that language
        if let voice = AVSpeechSynthesisVoice(language: language) {
            utterance.voice = voice
            print("[SpeechService] Using voice: \(voice.language) - \(voice.name)")
        } else {
            // Log available voices for debugging
            print("[SpeechService] No voice found for \(language). Available voices:")
            for voice in AVSpeechSynthesisVoice.speechVoices() {
                print("  - \(voice.language): \(voice.name)")
            }
            // Try to find any voice that starts with the language prefix
            let prefix = String(language.prefix(2))
            if let fallbackVoice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.language.hasPrefix(prefix) }) {
                utterance.voice = fallbackVoice
                print("[SpeechService] Using fallback voice: \(fallbackVoice.language)")
            } else {
                print("[SpeechService] WARNING: No voice available for language prefix '\(prefix)'")
            }
        }

        utterance.rate = UserSettings.shared.speechRate.rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        print("[SpeechService] Speaking utterance...")
        synthesizer.speak(utterance)
        print("[SpeechService] synthesizer.speak() called, isSpeaking: \(synthesizer.isSpeaking)")
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("[SpeechService] didStart - utterance: '\(utterance.speechString)'")
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("[SpeechService] didFinish - utterance: '\(utterance.speechString)'")
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.speakingLanguage = .none
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("[SpeechService] didCancel - utterance: '\(utterance.speechString)'")
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.speakingLanguage = .none
        }
    }
}
