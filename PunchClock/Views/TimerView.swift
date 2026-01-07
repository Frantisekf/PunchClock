import SwiftUI

struct TimerView: View {
    @ObservedObject var timerManager: TimerManager
    var historyStore: WorkoutHistoryStore
    @Environment(\.colorScheme) var colorScheme
    @State private var workoutSaved = false

    private static let finishQuotes: [(quote: String, author: String)] = [
        ("Good.", "Jocko Willink"),
        ("Hard work beats talent when talent doesn't work hard.", "Tim Notke"),
        ("You did what others wouldn't. Now you'll have what others won't.", ""),
        ("The only bad workout is the one that didn't happen.", ""),
        ("Respect the grind.", ""),
        ("One more day. One more step. One more round.", ""),
        ("You don't get what you wish for. You get what you work for.", ""),
        ("Pain is temporary. Pride is forever.", ""),
        ("The body achieves what the mind believes.", ""),
        ("Sweat now. Shine later.", "")
    ]

    @State private var finishQuote = finishQuotes.randomElement() ?? finishQuotes[0]

    private var phaseColor: Color {
        switch timerManager.state.phase {
        case .idle:
            return .gray
        case .prepare:
            return Color(red: 0.95, green: 0.75, blue: 0.1)
        case .round:
            return Color(red: 0.9, green: 0.2, blue: 0.2)
        case .rest:
            return Color(red: 0.2, green: 0.75, blue: 0.4)
        case .finished:
            return Color(red: 0.2, green: 0.75, blue: 0.4)
        }
    }

    private var formattedElapsedTime: String {
        let total = timerManager.totalElapsedTime
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        ZStack {
            phaseColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: timerManager.state.phase)

            if timerManager.state.phase == .finished {
                finishedView
                    .onAppear {
                        saveWorkoutIfNeeded()
                    }
            } else {
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        Button {
                            timerManager.isMuted.toggle()
                        } label: {
                            Image(systemName: timerManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 44, height: 44)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                    }

                    Spacer()

                    Text(timerManager.state.phaseDisplayName)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))

                    Text(timerManager.state.formattedTime)
                        .font(.system(size: 120, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    if let preset = timerManager.currentPreset {
                        RoundProgressView(
                            currentRound: timerManager.state.currentRound,
                            totalRounds: preset.numberOfRounds,
                            phase: timerManager.state.phase
                        )
                        .padding(.horizontal, 40)
                    }

                    Spacer()

                    controlsView
                        .padding(.bottom, 50)
                }
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }

    private var finishedView: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)

            Text("FINISHED")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 8) {
                Text("Total Time")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(formattedElapsedTime)
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }

            if let preset = timerManager.currentPreset {
                Text("\(preset.numberOfRounds) rounds completed")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            VStack(spacing: 8) {
                Text(finishQuote.quote)
                    .font(.title3)
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                if !finishQuote.author.isEmpty {
                    Text("— \(finishQuote.author)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 40)

            Button {
                timerManager.stop()
            } label: {
                Text("Done")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .frame(width: 200, height: 56)
                    .background(Color.white)
                    .cornerRadius(28)
            }
            .padding(.bottom, 50)
        }
    }

    private var controlsView: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                if timerManager.state.phase == .prepare ||
                   timerManager.state.phase == .round ||
                   timerManager.state.phase == .rest {
                    Button {
                        timerManager.restartCurrentRound()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Restart")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                    }
                }

                if timerManager.state.phase == .prepare ||
                   timerManager.state.phase == .rest {
                    Button {
                        timerManager.skipPhase()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Skip")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                    }
                }

                if timerManager.state.phase == .rest {
                    Button {
                        timerManager.addTime(20)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("20s")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                    }
                }
            }

            HStack(spacing: 40) {
                Button {
                    timerManager.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .frame(width: 70, height: 70)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }

                if timerManager.state.phase != .finished {
                    Button {
                        timerManager.togglePauseResume()
                    } label: {
                        Image(systemName: timerManager.state.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .frame(width: 90, height: 90)
                            .background(Color.white.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

struct RoundProgressView: View {
    let currentRound: Int
    let totalRounds: Int
    let phase: TimerPhase

    var body: some View {
        VStack(spacing: 12) {
            Text("Round \(currentRound) of \(totalRounds)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: geometry.size.width * progressPercentage, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private var progressPercentage: CGFloat {
        guard totalRounds > 0 else { return 0 }
        return CGFloat(currentRound) / CGFloat(totalRounds)
    }
}

// MARK: - Private Methods

extension TimerView {
    private func saveWorkoutIfNeeded() {
        guard !workoutSaved, let preset = timerManager.currentPreset else { return }

        let record = WorkoutRecord(
            presetName: preset.name,
            totalTime: timerManager.totalElapsedTime,
            roundsCompleted: timerManager.state.currentRound,
            totalRounds: preset.numberOfRounds
        )

        historyStore.addRecord(record)
        workoutSaved = true
    }
}

#Preview {
    let manager = TimerManager()
    manager.start(with: .boxingStandard)
    return TimerView(timerManager: manager, historyStore: WorkoutHistoryStore())
}
