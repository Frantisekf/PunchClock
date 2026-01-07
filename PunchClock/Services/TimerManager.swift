import Foundation
import Combine
import ActivityKit
import UIKit

final class TimerManager: ObservableObject {
    @Published var state = TimerState()
    @Published var totalElapsedTime: Int = 0
    @Published var isMuted: Bool = false

    private var timer: Timer?
    private var preset: Preset?
    private var phaseEndTime: Date?
    private var startTime: Date?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var foregroundObserver: NSObjectProtocol?
    private let soundManager = SoundManager.shared
    private let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let hapticMedium = UIImpactFeedbackGenerator(style: .medium)
    private let hapticLight = UIImpactFeedbackGenerator(style: .light)

    var currentPreset: Preset? { preset }

    init() {
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.syncTimeWithRealTime()
        }
    }

    deinit {
        timer?.invalidate()
        endBackgroundTask()
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func start(with preset: Preset) {
        self.preset = preset
        state.currentRound = 1
        state.phase = .prepare
        state.timeRemaining = preset.prepareTime
        state.isRunning = true
        startTime = Date()
        totalElapsedTime = 0
        phaseEndTime = Date().addingTimeInterval(TimeInterval(state.timeRemaining))

        soundManager.setupAudioSession()
        startTimer()
        startLiveActivity(preset: preset)
    }

    func pause() {
        state.isRunning = false
        timer?.invalidate()
        timer = nil
        phaseEndTime = nil
        updateLiveActivity()
    }

    func resume() {
        guard state.phase != .idle && state.phase != .finished else { return }
        state.isRunning = true
        phaseEndTime = Date().addingTimeInterval(TimeInterval(state.timeRemaining))
        startTimer()
        updateLiveActivity()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        phaseEndTime = nil
        state = TimerState()
        endLiveActivity()
        endBackgroundTask()
    }

    func togglePauseResume() {
        if state.isRunning {
            pause()
        } else {
            resume()
        }
    }

    func restartCurrentRound() {
        guard let preset = preset else { return }

        switch state.phase {
        case .prepare:
            state.timeRemaining = preset.prepareTime
        case .round:
            state.timeRemaining = preset.roundTime
        case .rest:
            state.timeRemaining = preset.restTime
        default:
            break
        }

        phaseEndTime = Date().addingTimeInterval(TimeInterval(state.timeRemaining))

        if !state.isRunning {
            resume()
        }

        updateLiveActivity()
    }

    func skipPhase() {
        guard let preset = preset else { return }
        state.timeRemaining = 0
        transitionToNextPhase(preset: preset)
    }

    // MARK: - Private Methods

    private func syncTimeWithRealTime() {
        guard state.isRunning, let endTime = phaseEndTime, let preset = preset else { return }

        let remaining = Int(endTime.timeIntervalSince(Date()))

        if remaining > 0 {
            state.timeRemaining = remaining
        } else {
            catchUpPhases(missedSeconds: -remaining, preset: preset)
        }
    }

    private func catchUpPhases(missedSeconds: Int, preset: Preset) {
        var secondsToProcess = missedSeconds

        while secondsToProcess > 0 && state.phase != .finished {
            switch state.phase {
            case .prepare:
                soundManager.playBell()
                state.phase = .round
                state.timeRemaining = preset.roundTime

            case .round:
                soundManager.playBell()
                if state.currentRound >= preset.numberOfRounds {
                    state.phase = .finished
                    state.isRunning = false
                    state.timeRemaining = 0
                    timer?.invalidate()
                    timer = nil
                    endBackgroundTask()
                    endLiveActivity()
                    return
                } else {
                    state.phase = .rest
                    state.timeRemaining = preset.restTime
                }

            case .rest:
                soundManager.playBell()
                state.currentRound += 1
                state.phase = .round
                state.timeRemaining = preset.roundTime

            default:
                return
            }

            if secondsToProcess >= state.timeRemaining {
                secondsToProcess -= state.timeRemaining
                state.timeRemaining = 0
            } else {
                state.timeRemaining -= secondsToProcess
                secondsToProcess = 0
            }
        }

        phaseEndTime = Date().addingTimeInterval(TimeInterval(state.timeRemaining))
        updateLiveActivity()
    }

    private func startTimer() {
        timer?.invalidate()
        beginBackgroundTask()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }

        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    private func tick() {
        guard let preset = preset else { return }

        if let start = startTime {
            totalElapsedTime = Int(Date().timeIntervalSince(start))
        }

        handleSoundCues()

        if state.timeRemaining > 0 {
            state.timeRemaining -= 1
        } else {
            transitionToNextPhase(preset: preset)
        }
    }

    private func handleSoundCues() {
        guard !isMuted else { return }

        switch state.phase {
        case .prepare:
            if state.timeRemaining <= 3 && state.timeRemaining > 0 {
                soundManager.playCountdown()
                hapticLight.impactOccurred()
            }

        case .round:
            if state.timeRemaining == 10 {
                soundManager.playStickPunch()
                hapticMedium.impactOccurred()
            }
            if state.timeRemaining <= 3 && state.timeRemaining > 0 {
                soundManager.playCountdown()
                hapticMedium.impactOccurred()
            }

        case .rest:
            if state.timeRemaining <= 3 && state.timeRemaining > 0 {
                soundManager.playCountdown()
                hapticLight.impactOccurred()
            }

        default:
            break
        }
    }

    private func transitionToNextPhase(preset: Preset) {
        switch state.phase {
        case .prepare:
            if !isMuted {
                soundManager.playBell()
                hapticHeavy.impactOccurred()
            }
            state.phase = .round
            state.timeRemaining = preset.roundTime
            phaseEndTime = Date().addingTimeInterval(TimeInterval(state.timeRemaining))
            updateLiveActivity()

        case .round:
            if !isMuted {
                soundManager.playBell()
                hapticHeavy.impactOccurred()
            }

            if state.currentRound >= preset.numberOfRounds {
                state.phase = .finished
                state.isRunning = false
                phaseEndTime = nil
                if let start = startTime {
                    totalElapsedTime = Int(Date().timeIntervalSince(start))
                }
                timer?.invalidate()
                timer = nil
                endBackgroundTask()
                endLiveActivity()
            } else {
                state.phase = .rest
                state.timeRemaining = preset.restTime
                phaseEndTime = Date().addingTimeInterval(TimeInterval(state.timeRemaining))
                updateLiveActivity()
            }

        case .rest:
            if !isMuted {
                soundManager.playBell()
                hapticHeavy.impactOccurred()
            }
            state.currentRound += 1
            state.phase = .round
            state.timeRemaining = preset.roundTime
            phaseEndTime = Date().addingTimeInterval(TimeInterval(state.timeRemaining))
            updateLiveActivity()

        default:
            break
        }
    }

    // MARK: - Background Task

    private func beginBackgroundTask() {
        endBackgroundTask()

        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }

    // MARK: - Live Activity

    private var currentActivity: Activity<TimerActivityAttributes>?

    private func startLiveActivity(preset: Preset) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = TimerActivityAttributes(presetName: preset.name)
        let contentState = TimerActivityAttributes.ContentState(
            phase: state.phase.rawValue,
            endTime: Date().addingTimeInterval(TimeInterval(state.timeRemaining)),
            timeRemaining: state.timeRemaining,
            currentRound: state.currentRound,
            totalRounds: preset.numberOfRounds,
            isRunning: state.isRunning
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
        } catch {
            // Live Activity failed to start
        }
    }

    private func updateLiveActivity() {
        guard let activity = currentActivity, let preset = preset else { return }

        let contentState = TimerActivityAttributes.ContentState(
            phase: state.phase.rawValue,
            endTime: Date().addingTimeInterval(TimeInterval(state.timeRemaining)),
            timeRemaining: state.timeRemaining,
            currentRound: state.currentRound,
            totalRounds: preset.numberOfRounds,
            isRunning: state.isRunning
        )

        Task {
            await activity.update(ActivityContent(state: contentState, staleDate: nil))
        }
    }

    private func endLiveActivity() {
        guard let activity = currentActivity, let preset = preset else { return }

        let finalContentState = TimerActivityAttributes.ContentState(
            phase: state.phase.rawValue,
            endTime: Date(),
            timeRemaining: 0,
            currentRound: state.currentRound,
            totalRounds: preset.numberOfRounds,
            isRunning: state.isRunning
        )

        Task {
            await activity.end(
                ActivityContent(state: finalContentState, staleDate: nil),
                dismissalPolicy: .immediate
            )
        }
        currentActivity = nil
    }
}
