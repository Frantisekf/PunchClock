import SwiftUI

struct PresetEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let preset: Preset?
    let onSave: (Preset) -> Void

    @State private var name: String = ""
    @State private var prepareMinutes: Int = 0
    @State private var prepareSeconds: Int = 10
    @State private var roundMinutes: Int = 3
    @State private var roundSeconds: Int = 0
    @State private var restMinutes: Int = 1
    @State private var restSeconds: Int = 0
    @State private var numberOfRounds: Int = 12

    private var isEditing: Bool { preset != nil }

    private var prepareTime: Int { prepareMinutes * 60 + prepareSeconds }
    private var roundTime: Int { roundMinutes * 60 + roundSeconds }
    private var restTime: Int { restMinutes * 60 + restSeconds }

    private var totalWorkoutTime: Int {
        prepareTime + (roundTime * numberOfRounds) + (restTime * max(numberOfRounds - 1, 0))
    }

    private var formattedTotalTime: String {
        let hours = totalWorkoutTime / 3600
        let minutes = (totalWorkoutTime % 3600) / 60
        let seconds = totalWorkoutTime % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Preset Name", text: $name)
                }

                Section("Rounds") {
                    Stepper("\(numberOfRounds) rounds", value: $numberOfRounds, in: 1...99)
                }

                Section {
                    HStack {
                        Picker("Minutes", selection: $roundMinutes) {
                            ForEach(0...10, id: \.self) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("Seconds", selection: $roundSeconds) {
                            ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { second in
                                Text("\(second) sec").tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .frame(height: 120)
                } header: {
                    Label("Round Duration", systemImage: "flame.fill")
                        .foregroundColor(.red)
                }

                Section {
                    HStack {
                        Picker("Minutes", selection: $restMinutes) {
                            ForEach(0...5, id: \.self) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("Seconds", selection: $restSeconds) {
                            ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { second in
                                Text("\(second) sec").tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .frame(height: 120)
                } header: {
                    Label("Rest Duration", systemImage: "pause.circle.fill")
                        .foregroundColor(.green)
                }

                Section {
                    HStack {
                        Picker("Minutes", selection: $prepareMinutes) {
                            ForEach(0...2, id: \.self) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("Seconds", selection: $prepareSeconds) {
                            ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { second in
                                Text("\(second) sec").tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .frame(height: 120)
                } header: {
                    Label("Prepare Time", systemImage: "clock.badge.exclamationmark")
                        .foregroundColor(.yellow)
                }

                Section {
                    HStack {
                        Text("Total Workout Time")
                        Spacer()
                        Text(formattedTotalTime)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Preset" : "New Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { savePreset() }
                        .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let preset = preset {
                    name = preset.name
                    prepareMinutes = preset.prepareTime / 60
                    prepareSeconds = preset.prepareTime % 60
                    roundMinutes = preset.roundTime / 60
                    roundSeconds = preset.roundTime % 60
                    restMinutes = preset.restTime / 60
                    restSeconds = preset.restTime % 60
                    numberOfRounds = preset.numberOfRounds
                }
            }
        }
    }

    private func savePreset() {
        let newPreset = Preset(
            id: preset?.id ?? UUID(),
            name: name,
            prepareTime: max(prepareTime, 5),
            roundTime: max(roundTime, 10),
            restTime: max(restTime, 5),
            numberOfRounds: numberOfRounds
        )

        onSave(newPreset)
        dismiss()
    }
}

#Preview {
    PresetEditorView(preset: nil, onSave: { _ in })
}
