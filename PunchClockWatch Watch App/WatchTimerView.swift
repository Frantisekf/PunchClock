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
        ZStack {
            phaseColor
                .ignoresSafeArea()

            VStack(spacing: 4) {
                Spacer()

                Text(timerManager.state.phaseDisplayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))

                Text(timerManager.state.formattedTime)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)

                if let preset = timerManager.currentPreset {
                    Text("Round \(timerManager.state.currentRound)/\(preset.numberOfRounds)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // Fixed 3-button layout - always same positions
                HStack {
                    Button {
                        timerManager.stop()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        timerManager.togglePauseResume()
                    } label: {
                        Image(systemName: timerManager.state.isRunning ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        timerManager.skipPhase()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .opacity(timerManager.state.phase == .prepare || timerManager.state.phase == .rest ? 1 : 0)
                    }
                    .buttonStyle(.plain)
                    .disabled(timerManager.state.phase == .round)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .navigationBarHidden(true)
    }

    private var finishedView: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()

            VStack(spacing: 8) {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)

                Text("Done!")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(formattedTotalTime)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)

                if let preset = timerManager.currentPreset {
                    Text("\(preset.numberOfRounds) rounds")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Button {
                    timerManager.stop()
                } label: {
                    Text("OK")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(20)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
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
