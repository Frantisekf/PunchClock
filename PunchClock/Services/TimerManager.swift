import Foundation
import Combine
import ActivityKit
import UIKit
import UserNotifications

final class TimerManager: ObservableObject {
    @Published var state = TimerState()
    @Published var totalElapsedTime: Int = 0
    @Published var isMuted: Bool = false
    @Published private(set) var notificationsEnabled: Bool = false

    var liveActivitiesSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    private var timer: Timer?
    private var preset: Preset?
    private var phaseEndTime: Date?
    private var startTime: Date?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var foregroundObserver: NSObjectProtocol?
    private var backgroundObserver: NSObjectProtocol?
    private let soundManager = SoundManager.shared
    private let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let hapticMedium = UIImpactFeedbackGenerator(style: .medium)
    private let hapticLight = UIImpactFeedbackGenerator(style: .light)

    var currentPreset: Preset? { preset }

    init() {
        requestNotificationPermission()

        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.syncTimeWithRealTime()
            self?.cancelScheduledNotifications()
        }

        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.schedulePhaseNotifications()
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.notificationsEnabled = granted
            }
        }
    }

    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    deinit {
        timer?.invalidate()
        endBackgroundTask()
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = backgroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Background Notifications

    private func schedulePhaseNotifications() {
        guard state.isRunning, let preset = preset, !isMuted else { return }

        cancelScheduledNotifications()

        var timeOffset: TimeInterval = TimeInterval(state.timeRemaining)
        var currentRound = state.currentRound
        var currentPhase = state.phase

        // Schedule notifications for all upcoming phase transitions
        while currentPhase != .finished {
            switch currentPhase {
            case .prepare:
                scheduleNotification(at: timeOffset, title: "Round \(currentRound)", body: "Fight!", sound: "bell.mp3")
                currentPhase = .round
                timeOffset += TimeInterval(preset.roundTime)

            case .round:
                if currentRound >= preset.numberOfRounds {
                    scheduleNotification(at: timeOffset, title: "Workout Complete!", body: "Great job!", sound: "bell.mp3")
                    currentPhase = .finished
                } else {
                    scheduleNotification(at: timeOffset, title: "Rest", body: "Round \(currentRound) complete", sound: "bell.mp3")
                    currentPhase = .rest
                    timeOffset += TimeInterval(preset.restTime)
                }

            case .rest:
                currentRound += 1
                scheduleNotification(at: timeOffset, title: "Round \(currentRound)", body: "Fight!", sound: "bell.mp3")
                currentPhase = .round
                timeOffset += TimeInterval(preset.roundTime)

            default:
                break
            }

            // Limit to prevent too many notifications
            if timeOffset > 3600 { break }
        }
    }

    private func scheduleNotification(at timeInterval: TimeInterval, title: String, body: String, sound: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(timeInterval, 1), repeats: false)
        let request = UNNotificationRequest(
            identifier: "timer-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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
        soundManager.startBackgroundAudio()
        startTimer()
        startLiveActivity(preset: preset)
    }

    func pause() {
        state.isRunning = false
        timer?.invalidate()
        timer = nil
        phaseEndTime = nil
        cancelScheduledNotifications()
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
        cancelScheduledNotifications()
        soundManager.stopBackgroundAudio()
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

        // Auto-resume if paused
        if !state.isRunning && state.phase != .finished {
            resume()
        }
    }

    func addTime(_ seconds: Int) {
        state.timeRemaining += seconds
        if let endTime = phaseEndTime {
            phaseEndTime = endTime.addingTimeInterval(TimeInterval(seconds))
        }
        updateLiveActivity()
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
                soundManager.stopBackgroundAudio()
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
