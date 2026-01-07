import SwiftUI

struct ContentView: View {
    @EnvironmentObject var presetStore: PresetStore
    @StateObject private var timerManager = TimerManager()
    @State private var selectedPreset: Preset?
    @State private var showingPresetEditor = false
    @State private var editingPreset: Preset?

    var body: some View {
        NavigationStack {
            if timerManager.state.phase == .idle {
                presetListView
            } else {
                TimerView(timerManager: timerManager)
            }
        }
    }

    var presetListView: some View {
        List {
            Section {
                ForEach(presetStore.presets) { preset in
                    PresetRow(preset: preset)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPreset = preset
                            timerManager.start(with: preset)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                presetStore.deletePreset(preset)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                editingPreset = preset
                                showingPresetEditor = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            } header: {
                Text("Presets")
            } footer: {
                Text("Tap a preset to start the timer")
            }
        }
        .navigationTitle("PunchClock")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editingPreset = nil
                    showingPresetEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingPresetEditor) {
            PresetEditorView(
                preset: editingPreset,
                onSave: { preset in
                    if editingPreset != nil {
                        presetStore.updatePreset(preset)
                    } else {
                        presetStore.addPreset(preset)
                    }
                }
            )
        }
    }
}

struct PresetRow: View {
    let preset: Preset

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(preset.name)
                .font(.headline)

            HStack(spacing: 16) {
                Label(formatTime(preset.roundTime), systemImage: "timer")
                Label("\(preset.numberOfRounds) rounds", systemImage: "repeat")
                Label(formatTime(preset.restTime) + " rest", systemImage: "pause.circle")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        if secs == 0 {
            return "\(minutes)min"
        }
        return "\(minutes):\(String(format: "%02d", secs))"
    }
}

#Preview {
    ContentView()
        .environmentObject(PresetStore())
}
