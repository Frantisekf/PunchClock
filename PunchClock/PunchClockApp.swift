import SwiftUI

@main
struct PunchClockApp: App {
    @StateObject private var presetStore = PresetStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presetStore)
        }
    }
}
