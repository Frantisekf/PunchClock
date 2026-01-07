import Foundation
import Foundation
import Combine
import ActivityKit
import UIKit

// MARK: - Timer Manager

class TimerManager: ObservableObject {
    @Published var state = TimerState()

    private var timer: Timer?
    private var preset: Preset?
    private let soundManager = SoundManager.shared
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    var currentPreset: Preset? {
        preset
    }

    func start(with preset: Preset) {
        self.preset = preset
        state.currentRound = 1
        state.phase = .prepare
        state.timeRemaining = preset.prepareTime
        state.isRunning = true

        // Keep audio session active
        soundManager.setupAudioSession()
        
        startTimer()
        startLiveActivity(preset: preset)
        
        print("✅ Timer started - will continue in background with audio")
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
        
        // Reset to the beginning of the current phase
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
        
        // If paused, resume the timer
        if !state.isRunning {
            resume()
        }
        
        updateLiveActivity()
    }

    private func startTimer() {
        timer?.invalidate()
        
        // Request background task to keep running
        beginBackgroundTask()
        
        // Use RunLoop.common mode to ensure timer fires even during UI events
        // scheduledTimer automatically adds to current run loop
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        // Also add to common mode for better reliability
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
        
        print("⏱️ Timer configured for background execution with background task")
    }

    private func tick() {
        guard let preset = preset else { return }

        // Handle sound cues
        handleSoundCues()

        // Decrement time
        if state.timeRemaining > 0 {
            state.timeRemaining -= 1
        } else {
            // Transition to next phase
            transitionToNextPhase(preset: preset)
        }

        // Update Live Activity
        updateLiveActivity()
    }

    private func handleSoundCues() {
        switch state.phase {
        case .prepare:
            // Play countdown at 3, 2, 1
            if state.timeRemaining <= 3 && state.timeRemaining > 0 {
                soundManager.playCountdown()
            }

        case .round:
            // Play stick punches at 10 seconds remaining
            if state.timeRemaining == 10 {
                soundManager.playStickPunch()
            }
            // Play countdown at 3, 2, 1
            if state.timeRemaining <= 3 && state.timeRemaining > 0 {
                soundManager.playCountdown()
            }

        case .rest:
            // Play countdown at 3, 2, 1
            if state.timeRemaining <= 3 && state.timeRemaining > 0 {
                soundManager.playCountdown()
            }

        default:
            break
        }
    }

    private func transitionToNextPhase(preset: Preset) {
        switch state.phase {
        case .prepare:
            // Start first round
            soundManager.playBell()
            state.phase = .round
            state.timeRemaining = preset.roundTime

        case .round:
            // End of round bell
            soundManager.playBell()

            if state.currentRound >= preset.numberOfRounds {
                // All rounds complete
                state.phase = .finished
                state.isRunning = false
                timer?.invalidate()
                timer = nil
                endBackgroundTask()
            } else {
                // Start rest period
                state.phase = .rest
                state.timeRemaining = preset.restTime
            }

        case .rest:
            // Start next round
            soundManager.playBell()
            state.currentRound += 1
            state.phase = .round
            state.timeRemaining = preset.roundTime

        default:
            break
        }
    }

    deinit {
        timer?.invalidate()
        endBackgroundTask()
    }
    
    // MARK: - Background Task Management
    
    private func beginBackgroundTask() {
        // End any existing background task first
        endBackgroundTask()
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            // This closure is called when the background time is about to expire
            print("⚠️ Background task time expiring, ending task")
            self?.endBackgroundTask()
        }
        
        if backgroundTask != .invalid {
            print("✅ Background task started: \(backgroundTask.rawValue)")
        }
    }
    
    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        
        print("🛑 Ending background task: \(backgroundTask.rawValue)")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }

    // MARK: - Live Activity

    private var currentActivity: Activity<TimerActivityAttributes>?

    private func startLiveActivity(preset: Preset) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("❌ Live Activities are not enabled")
            return
        }

        let attributes = TimerActivityAttributes(presetName: preset.name)
        let contentState = TimerActivityAttributes.ContentState(
            phase: state.phase.rawValue,
            timeRemaining: state.timeRemaining,
            currentRound: state.currentRound,
            totalRounds: preset.numberOfRounds,
            isRunning: state.isRunning
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            print("✅ Live Activity started successfully! ID: \(activity.id)")
        } catch {
            print("❌ Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    private func updateLiveActivity() {
        guard let activity = currentActivity, let preset = preset else { return }

        let contentState = TimerActivityAttributes.ContentState(
            phase: state.phase.rawValue,
            timeRemaining: state.timeRemaining,
            currentRound: state.currentRound,
            totalRounds: preset.numberOfRounds,
            isRunning: state.isRunning
        )

        Task {
            do {
                await activity.update(
                    ActivityContent(state: contentState, staleDate: nil)
                )
            } catch {
                print("⚠️ Failed to update Live Activity: \(error.localizedDescription)")
            }
        }
    }

    private func endLiveActivity() {
        guard let activity = currentActivity, let preset = preset else { return }

        let finalContentState = TimerActivityAttributes.ContentState(
            phase: state.phase.rawValue,
            timeRemaining: state.timeRemaining,
            currentRound: state.currentRound,
            totalRounds: preset.numberOfRounds,
            isRunning: state.isRunning
        )

        Task {
            do {
                await activity.end(
                    ActivityContent(state: finalContentState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
                print("✅ Live Activity ended")
            } catch {
                print("⚠️ Failed to end Live Activity: \(error.localizedDescription)")
            }
        }
        currentActivity = nil
    }
}
