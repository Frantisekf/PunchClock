//
//  TimerActivityAttributes.swift
//  PunchClock
//
//  Shared between main app and widget extension
//

import ActivityKit
import Foundation

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var phase: String
        var timeRemaining: Int
        var currentRound: Int
        var totalRounds: Int
        var isRunning: Bool
        
        var formattedTime: String {
            let minutes = timeRemaining / 60
            let seconds = timeRemaining % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    var presetName: String
}
