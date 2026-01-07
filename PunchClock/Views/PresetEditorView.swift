import SwiftUI

struct PresetEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let preset: Preset?
    let onSave: (Preset) -> Void

    @State private var name: String = ""
    @State private var prepareTime: Int = 10
    @State private var roundMinutes: Int = 3
    @State private var roundSeconds: Int = 0
    @State private var restMinutes: Int = 1
    @State private var restSeconds: Int = 0
    @State private var numberOfRounds: Int = 12

    private var isEditing: Bool { preset != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Preset Name", text: $name)
                }

                Section("Rounds") {
                    Stepper("\(numberOfRounds) rounds", value: $numberOfRounds, in: 1...20)
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
                    Stepper("\(prepareTime) seconds", value: $prepareTime, in: 3...30)
                } header: {
                    Label("Prepare Time", systemImage: "clock.badge.exclamationmark")
                        .foregroundColor(.yellow)
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
                    prepareTime = preset.prepareTime
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
        let roundTime = roundMinutes * 60 + roundSeconds
        let restTime = restMinutes * 60 + restSeconds

        let newPreset = Preset(
            id: preset?.id ?? UUID(),
            name: name,
            prepareTime: prepareTime,
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
