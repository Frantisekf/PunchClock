import Foundation
import Combine
import WatchKit

final class WatchTimerManager: ObservableObject {
    @Published var state = WatchTimerState()
    @Published var totalElapsedTime: Int = 0

    private var timer: Timer?
    private var preset: WatchPreset?
    private var startTime: Date?

    var currentPreset: WatchPreset? { preset }

    func start(with preset: WatchPreset) {
        self.preset = preset
        state.currentRound = 1
        state.phase = .prepare
        state.timeRemaining = preset.prepareTime
        state.isRunning = true
        startTime = Date()
        totalElapsedTime = 0

        startTimer()
        playStartHaptic()
    }

    func pause() {
        state.isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard state.phase != .idle && state.phase != .finished else { return }
        state.isRunning = true
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        state = WatchTimerState()
    }

    func togglePauseResume() {
        if state.isRunning {
            pause()
        } else {
            resume()
        }
    }

    func skipPhase() {
        guard let preset = preset else { return }
        state.timeRemaining = 0
        transitionToNextPhase(preset: preset)

        if !state.isRunning && state.phase != .finished {
            resume()
        }
    }

    // MARK: - Private Methods

    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard let preset = preset else { return }

        if let start = startTime {
            totalElapsedTime = Int(Date().timeIntervalSince(start))
        }

        handleHaptics()

        if state.timeRemaining > 0 {
            state.timeRemaining -= 1
        } else {
            transitionToNextPhase(preset: preset)
        }
    }

    private func handleHaptics() {
        // Countdown haptics in last 3 seconds
        if state.timeRemaining <= 3 && state.timeRemaining > 0 {
            playCountdownHaptic()
        }
    }

    private func transitionToNextPhase(preset: WatchPreset) {
        switch state.phase {
        case .prepare:
            playPhaseChangeHaptic()
            state.phase = .round
            state.timeRemaining = preset.roundTime

        case .round:
            playPhaseChangeHaptic()

            if state.currentRound >= preset.numberOfRounds {
                state.phase = .finished
                state.isRunning = false
                if let start = startTime {
                    totalElapsedTime = Int(Date().timeIntervalSince(start))
                }
                timer?.invalidate()
                timer = nil
                playFinishHaptic()
            } else {
                state.phase = .rest
                state.timeRemaining = preset.restTime
            }

        case .rest:
            playPhaseChangeHaptic()
            state.currentRound += 1
            state.phase = .round
            state.timeRemaining = preset.roundTime

        default:
            break
        }
    }

    // MARK: - Haptics

    private func playStartHaptic() {
        WKInterfaceDevice.current().play(.start)
    }

    private func playCountdownHaptic() {
        WKInterfaceDevice.current().play(.click)
    }

    private func playPhaseChangeHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }

    private func playFinishHaptic() {
        WKInterfaceDevice.current().play(.success)
    }
}
