import SwiftUI

struct ContentView: View {
    @EnvironmentObject var presetStore: WatchPresetStore
    @StateObject private var timerManager = WatchTimerManager()

    var body: some View {
        NavigationStack {
            if timerManager.state.phase == .idle {
                PresetListView(timerManager: timerManager)
            } else {
                WatchTimerView(timerManager: timerManager)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchPresetStore())
}
