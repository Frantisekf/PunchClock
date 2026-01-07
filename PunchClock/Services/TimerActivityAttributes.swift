import ActivityKit
import Foundation

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var phase: String
        var endTime: Date
        var currentRound: Int
        var totalRounds: Int
        var isRunning: Bool
    }

    var presetName: String
}
