import SwiftUI

struct WatchTimerView: View {
    @ObservedObject var timerManager: WatchTimerManager

    private var phaseColor: Color {
        switch timerManager.state.phase {
        case .idle:
            return .gray
        case .prepare:
            return .yellow
        case .round:
            return .red
        case .rest:
            return .green
        case .finished:
            return .green
        }
    }

    var body: some View {
        if timerManager.state.phase == .finished {
            finishedView
        } else {
            timerView
        }
    }

    private var timerView: some View {
        VStack(spacing: 8) {
            // Phase indicator
            Text(timerManager.state.phaseDisplayName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(phaseColor)

            // Time display
            Text(timerManager.state.formattedTime)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.white)

            // Round indicator
            if let preset = timerManager.currentPreset {
                Text("Round \(timerManager.state.currentRound)/\(preset.numberOfRounds)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Controls
            HStack(spacing: 20) {
                Button {
                    timerManager.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)

                Button {
                    timerManager.togglePauseResume()
                } label: {
                    Image(systemName: timerManager.state.isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(phaseColor.opacity(0.3))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                if timerManager.state.phase == .prepare || timerManager.state.phase == .rest {
                    Button {
                        timerManager.skipPhase()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(phaseColor.opacity(0.15))
        .navigationBarHidden(true)
    }

    private var finishedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)

            Text("Done!")
                .font(.title3)
                .fontWeight(.bold)

            Text(formattedTotalTime)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .monospacedDigit()

            if let preset = timerManager.currentPreset {
                Text("\(preset.numberOfRounds) rounds")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button("OK") {
                timerManager.stop()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
    }

    private var formattedTotalTime: String {
        let total = timerManager.totalElapsedTime
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    let manager = WatchTimerManager()
    manager.start(with: .boxingStandard)
    return WatchTimerView(timerManager: manager)
}
