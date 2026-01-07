import SwiftUI

struct TimerView: View {
    @ObservedObject var timerManager: TimerManager
    @Environment(\.colorScheme) var colorScheme

    private var phaseColor: Color {
        switch timerManager.state.phase {
        case .idle:
            return colorScheme == .dark ? Color.gray.opacity(0.3) : .gray
        case .prepare:
            return colorScheme == .dark ? Color.yellow.opacity(0.4) : .yellow
        case .round:
            return colorScheme == .dark ? Color.red.opacity(0.5) : .red
        case .rest:
            return colorScheme == .dark ? Color.green.opacity(0.4) : .green
        case .finished:
            return colorScheme == .dark ? Color.blue.opacity(0.4) : .blue
        }
    }

    var body: some View {
        ZStack {
            phaseColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: timerManager.state.phase)

            VStack(spacing: 20) {
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
        .navigationBarHidden(true)
        .statusBar(hidden: true)
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

#Preview {
    let manager = TimerManager()
    manager.start(with: .boxingStandard)
    return TimerView(timerManager: manager)
}
