import SwiftUI
import AppIntents

@main
struct PunchClockApp: App {
    @StateObject private var presetStore = PresetStore()
    @StateObject private var historyStore = WorkoutHistoryStore()

    init() {
        // Register Siri Shortcuts
        PunchClockShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presetStore)
                .environmentObject(historyStore)
        }
    }
}
