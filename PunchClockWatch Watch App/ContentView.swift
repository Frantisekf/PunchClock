import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject var presetStore: WatchPresetStore
    @StateObject private var timerManager = WatchTimerManager()

    var body: some View {
        if timerManager.state.phase == .idle {
            PresetListView(timerManager: timerManager)
        } else {
            WatchTimerView(timerManager: timerManager)
        }
    }
}

#Preview {
    WatchContentView()
        .environmentObject(WatchPresetStore())
}
