import SwiftUI
import AppIntents
import ActivityKit

@main
struct PunchClockApp: App {
    @StateObject private var presetStore = PresetStore()
    @StateObject private var historyStore = WorkoutHistoryStore()
    @ObservedObject private var settings = SettingsStore.shared

    init() {
        // Register Siri Shortcuts
        PunchClockShortcuts.updateAppShortcutParameters()

        // End any orphaned Live Activities from previous sessions
        cleanupOrphanedLiveActivities()

        // Request notification permission for background alerts
        TimerManager.shared.requestNotificationPermission()
    }

    private func cleanupOrphanedLiveActivities() {
        // If timer isn't running but there are active Live Activities, end them
        if TimerManager.shared.state.phase == .idle {
            for activity in Activity<TimerActivityAttributes>.activities {
                Task {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presetStore)
                .environmentObject(historyStore)
                .preferredColorScheme(settings.appearanceMode.colorScheme)
        }
    }
}
