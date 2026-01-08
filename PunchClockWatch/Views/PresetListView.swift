import SwiftUI

struct PresetListView: View {
    @EnvironmentObject var presetStore: WatchPresetStore
    @ObservedObject var timerManager: WatchTimerManager

    var body: some View {
        List {
            ForEach(presetStore.presets) { preset in
                Button {
                    timerManager.start(with: preset)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(preset.name)
                            .font(.headline)

                        HStack(spacing: 8) {
                            Label(formatTime(preset.roundTime), systemImage: "flame.fill")
                                .foregroundColor(.red)
                            Label("\(preset.numberOfRounds)", systemImage: "repeat")
                                .foregroundColor(.secondary)
                        }
                        .font(.caption2)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Ring Timer")
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        if secs == 0 {
            return "\(minutes)m"
        }
        return "\(minutes):\(String(format: "%02d", secs))"
    }
}

#Preview {
    NavigationStack {
        PresetListView(timerManager: WatchTimerManager())
            .environmentObject(WatchPresetStore())
    }
}
