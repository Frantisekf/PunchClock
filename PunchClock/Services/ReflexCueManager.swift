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
    private var comboTimer: Timer?

    // ~30% chance to fire a combo instead of a single cue
    private let comboProbability: Double = 0.3

    private static let combos: [(cues: [String], categories: Set<ReflexCueCategory>)] = [
        // Pure offensive
        (["Jab", "Cross"], [.offensive]),
        (["Jab", "Cross", "Hook"], [.offensive]),
        (["Jab", "Body shot"], [.offensive]),
        (["Cross", "Hook"], [.offensive]),
        (["Hook", "Cross"], [.offensive]),
        (["Jab", "Cross", "Body shot"], [.offensive]),
        // Defensive + counter
        (["Slip", "Cross"], [.defensive, .offensive]),
        (["Slip", "Hook"], [.defensive, .offensive]),
        (["Block", "Cross"], [.defensive, .offensive]),
        (["Parry", "Cross"], [.defensive, .offensive]),
        (["Roll", "Hook"], [.defensive, .offensive]),
        // Movement + offensive
        (["Level change", "Hook"], [.movement, .offensive]),
        (["Pivot", "Cross"], [.movement, .offensive]),
        (["Step back", "Jab"], [.movement, .offensive]),
        // Offensive + defensive (attack then react)
        (["Jab", "Slip"], [.offensive, .defensive]),
        (["Jab", "Roll"], [.offensive, .defensive]),
        (["Cross", "Slip"], [.offensive, .defensive]),
        (["Hook", "Block"], [.offensive, .defensive]),
        (["Jab", "Cross", "Slip"], [.offensive, .defensive]),
        // Defensive + movement
        (["Slip", "Pivot"], [.defensive, .movement]),
        (["Block", "Step back"], [.defensive, .movement]),
    ]

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
            comboTimer?.invalidate()
        }
    }

    func tick(isMuted: Bool) {
        guard isEnabled else { return }

        secondsUntilNextCue -= 1

        if secondsUntilNextCue <= 0 {
            let isCombo = Double.random(in: 0...1) < comboProbability
            if isCombo, let combo = pickRandomCombo() {
                playCombo(combo, isMuted: isMuted)
            } else if let cue = pickRandomCue() {
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
        comboTimer?.invalidate()
        secondsUntilNextCue = randomInterval()
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        comboTimer?.invalidate()
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

    private func pickRandomCombo() -> [String]? {
        let availableCombos = Self.combos.filter { combo in
            combo.categories.isSubset(of: enabledCategories)
        }
        return availableCombos.randomElement()?.cues
    }

    private func playCombo(_ cues: [String], isMuted: Bool) {
        guard let first = cues.first else { return }

        showCueText(first)
        if !isMuted {
            speak(first)
        }

        for (index, cue) in cues.dropFirst().enumerated() {
            let delay = 0.7 * Double(index + 1)
            comboTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.showCueText(cue)
                    if !isMuted {
                        self?.speak(cue)
                    }
                }
            }
        }
    }

    private func randomInterval() -> Int {
        Int.random(in: intensity.intervalRange)
    }

    private func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Aaron_en-US_compact")
            ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 1.2
        utterance.pitchMultiplier = 0.85
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
