import SwiftUI

@main
struct PunchClockWatch_Watch_AppApp: App {
    @StateObject private var presetStore = WatchPresetStore()

    init() {
        // Request HealthKit authorization
        WatchHealthKitManager.shared.requestAuthorization { _ in }
    }

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(presetStore)
        }
    }
}
