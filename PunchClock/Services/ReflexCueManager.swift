import Foundation
import AVFoundation
import Combine

final class ReflexCueManager: ObservableObject {
    @Published var currentCueText: String?
    @Published var isEnabled: Bool = false

    private let synthesizer = AVSpeechSynthesizer()
    private var enabledCategories: Set<ReflexCueCategory> = Set(ReflexCueCategory.allCases)
    private var intensity: ReflexIntensity = .medium
    private var secondsUntilNextCue: Int = 0
    private var clearTextTimer: Timer?

    func configure(with preset: Preset) {
        isEnabled = preset.reflexEnabled
        intensity = preset.reflexIntensity
        enabledCategories = preset.reflexCategories
        secondsUntilNextCue = randomInterval()
        prewarmSynthesizer()
    }

    private func prewarmSynthesizer() {
        let utterance = AVSpeechUtterance(string: "")
        utterance.volume = 0
        synthesizer.speak(utterance)
    }

    func toggle() {
        isEnabled.toggle()
        if isEnabled {
            secondsUntilNextCue = randomInterval()
        } else {
            synthesizer.stopSpeaking(at: .immediate)
            currentCueText = nil
            clearTextTimer?.invalidate()
        }
    }

    func tick(isMuted: Bool) {
        guard isEnabled else { return }

        secondsUntilNextCue -= 1

        if secondsUntilNextCue <= 0 {
            if let cue = pickRandomCue() {
                showCueText(cue)
                if !isMuted {
                    speak(cue)
                }
            }
            secondsUntilNextCue = randomInterval()
        }
    }

    func pauseSpeech() {
        synthesizer.stopSpeaking(at: .immediate)
        secondsUntilNextCue = randomInterval()
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isEnabled = false
        currentCueText = nil
        clearTextTimer?.invalidate()
        secondsUntilNextCue = 0
    }

    // MARK: - Private

    private func pickRandomCue() -> String? {
        let allCues = enabledCategories.flatMap { $0.cues }
        return allCues.randomElement()
    }

    private func randomInterval() -> Int {
        Int.random(in: intensity.intervalRange)
    }

    private func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 1.2
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }

    private func showCueText(_ text: String) {
        clearTextTimer?.invalidate()
        currentCueText = text
        clearTextTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.currentCueText = nil
            }
        }
    }
}
