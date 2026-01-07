import AVFoundation
import Combine
import UIKit

final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var audioSession: AVAudioSession?

    enum Sound: String {
        case bell = "bell"
        case stickPunch = "stick_punch"
        case countdown = "countdown"
    }

    private init() {
        setupAudioSession()
        preloadSounds()
    }

    func setupAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try audioSession?.setActive(true)
        } catch {
            // Audio session setup failed
        }
    }

    private func preloadSounds() {
        for sound in [Sound.bell, .stickPunch, .countdown] {
            if let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") ??
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

    func playSound(_ sound: Sound) {
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
            AudioServicesPlaySystemSound(1304)
        case .stickPunch:
            AudioServicesPlaySystemSound(1104)
        case .countdown:
            AudioServicesPlaySystemSound(1103)
        }
    }

    func playBell() {
        playSound(.bell)
    }

    func playStickPunch() {
        playSound(.stickPunch)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.playSound(.stickPunch)
        }
    }

    func playCountdown() {
        playSound(.countdown)
    }
}
