import Foundation

enum TimerPhase: String, Codable {
    case idle
    case prepare
    case round
    case rest
    case finished
}

struct TimerState {
    var phase: TimerPhase = .idle
    var currentRound: Int = 1
    var timeRemaining: Int = 0
    var isRunning: Bool = false

    var phaseDisplayName: String {
        switch phase {
        case .idle:
            return "Ready"
        case .prepare:
            return "Get Ready"
        case .round:
            return "Round \(currentRound)"
        case .rest:
            return "Rest"
        case .finished:
            return "Finished"
        }
    }

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
