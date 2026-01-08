import SwiftUI

@main
struct PunchClockWatchApp: App {
    @StateObject private var presetStore = WatchPresetStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presetStore)
        }
    }
}
