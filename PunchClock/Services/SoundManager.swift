import AVFoundation
import Combine
import UIKit

final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var audioSession: AVAudioSession?
    private var silentPlayer: AVAudioPlayer?

    enum Sound: String {
        case bell = "bell"
        case clapper = "clapper"
        case countdown = "countdown"
    }

    private init() {
        setupAudioSession()
        preloadSounds()
    }

    func setupAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            // Use .playAndRecord with defaultToSpeaker for more reliable background audio
            try audioSession?.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try audioSession?.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            // Audio session setup failed - app will use system sound fallbacks
        }
    }

    func startBackgroundAudio() {
        // Ensure audio session is active for background playback
        setupAudioSession()
    }

    func stopBackgroundAudio() {
        // Keep audio session active for future sounds
    }

    private func preloadSounds() {
        for sound in [Sound.bell, .clapper, .countdown] {
            if let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "m4a") ??
                        Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[sound.rawValue] = player
                } catch {
                    // Sound file failed to load
                }
            }
        }
    }

    private var isEnabled: Bool {
        SettingsStore.shared.soundEnabled
    }

    func playSound(_ sound: Sound) {
        guard isEnabled else { return }
        if let player = audioPlayers[sound.rawValue] {
            player.currentTime = 0
            player.play()
            return
        }
        playSystemSoundFallback(for: sound)
    }

    private func playSystemSoundFallback(for sound: Sound) {
        switch sound {
        case .bell:
            AudioServicesPlayAlertSound(1304)
        case .clapper:
            AudioServicesPlayAlertSound(1104)
        case .countdown:
            AudioServicesPlayAlertSound(1103)
        }
    }

    func playBell() {
        playSound(.bell)
    }

    func playClapper() {
        playSound(.clapper)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.playSound(.clapper)
        }
    }

    func playCountdown() {
        playSound(.countdown)
    }
}
