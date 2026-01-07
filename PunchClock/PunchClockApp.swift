import SwiftUI
import AppIntents

@main
struct PunchClockApp: App {
    @StateObject private var presetStore = PresetStore()

    init() {
        // Register Siri Shortcuts
        PunchClockShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presetStore)
        }
    }
}
