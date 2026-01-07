import SwiftUI

struct PresetSetupView: View {
    let preset: Preset
    let onStart: (Preset) -> Void
    let onCancel: () -> Void

    @State private var rounds: Int
    @State private var roundMinutes: Int
    @State private var roundSeconds: Int
    @State private var restMinutes: Int
    @State private var restSeconds: Int
    @State private var prepareSeconds: Int

    init(preset: Preset, onStart: @escaping (Preset) -> Void, onCancel: @escaping () -> Void) {
        self.preset = preset
        self.onStart = onStart
        self.onCancel = onCancel

        _rounds = State(initialValue: preset.numberOfRounds)
        _roundMinutes = State(initialValue: preset.roundTime / 60)
        _roundSeconds = State(initialValue: preset.roundTime % 60)
        _restMinutes = State(initialValue: preset.restTime / 60)
        _restSeconds = State(initialValue: preset.restTime % 60)
        _prepareSeconds = State(initialValue: preset.prepareTime)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Rounds") {
                    Stepper("\(rounds) rounds", value: $rounds, in: 1...99)
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
                    Stepper("\(prepareSeconds) seconds", value: $prepareSeconds, in: 3...30)
                } header: {
                    Label("Prepare Time", systemImage: "clock.badge.exclamationmark")
                        .foregroundColor(.yellow)
                }

                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Total Workout")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(totalTimeFormatted)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle(preset.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let adjustedPreset = Preset(
                            id: preset.id,
                            name: preset.name,
                            prepareTime: prepareSeconds,
                            roundTime: roundMinutes * 60 + roundSeconds,
                            restTime: restMinutes * 60 + restSeconds,
                            numberOfRounds: rounds
                        )
                        onStart(adjustedPreset)
                    } label: {
                        Text("Start")
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }

    private var totalTimeFormatted: String {
        let roundTime = roundMinutes * 60 + roundSeconds
        let restTime = restMinutes * 60 + restSeconds
        let total = prepareSeconds + (roundTime * rounds) + (restTime * (rounds - 1))

        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    PresetSetupView(
        preset: .boxingStandard,
        onStart: { _ in },
        onCancel: { }
    )
}
