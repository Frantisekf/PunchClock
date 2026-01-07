import AVFoundation
import UIKit
import Combine

class SoundManager: ObservableObject {
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
            // Use playback category with mixWithOthers to allow background audio
            // This allows the timer to run while recording video in Camera app
            try audioSession?.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try audioSession?.setActive(true)
            print("✅ Audio session configured for background playback")
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }

    private func preloadSounds() {
        // Preload all sounds for instant playback
        for sound in [Sound.bell, .stickPunch, .countdown] {
            if let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[sound.rawValue] = player
                } catch {
                    print("Failed to load sound \(sound.rawValue): \(error)")
                }
            } else if let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[sound.rawValue] = player
                } catch {
                    print("Failed to load sound \(sound.rawValue): \(error)")
                }
            }
        }
    }

    func playSound(_ sound: Sound) {
        // Try to play loaded sound first
        if let player = audioPlayers[sound.rawValue] {
            player.currentTime = 0
            player.play()
            return
        }

        // Fallback to system sounds if custom sounds aren't loaded
        playSystemSoundFallback(for: sound)
    }

    private func playSystemSoundFallback(for sound: Sound) {
        switch sound {
        case .bell:
            // System sound for bell (alarm-like)
            AudioServicesPlaySystemSound(1304)
        case .stickPunch:
            // System sound for stick punch (tap-like)
            AudioServicesPlaySystemSound(1104)
        case .countdown:
            // System sound for countdown (tick)
            AudioServicesPlaySystemSound(1103)
        }
    }

    func playBell() {
        playSound(.bell)
    }

    func playStickPunch() {
        // Play two quick stick punches
        playSound(.stickPunch)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.playSound(.stickPunch)
        }
    }

    func playCountdown() {
        playSound(.countdown)
    }
}
