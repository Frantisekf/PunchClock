//
//  PunchClockWidgetLiveActivity.swift
//  PunchClockWidget
//
//  Created by Frantisek Farkas on 07.01.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Widget

@available(iOS 16.2, *)
struct PunchClockWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            lockScreenView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.3))
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: phaseIcon(for: context.state.phase))
                            .foregroundColor(phaseColor(for: context.state.phase))
                        Text(phaseName(for: context.state.phase))
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 4) {
                        Text("Round")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(context.state.currentRound)/\(context.state.totalRounds)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.formattedTime)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.attributes.presetName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        if !context.state.isRunning {
                            Image(systemName: "pause.circle.fill")
                                .foregroundColor(.orange)
                        }
                    }
                }
            } compactLeading: {
                // Compact Leading (left side of notch)
                Image(systemName: phaseIcon(for: context.state.phase))
                    .foregroundColor(phaseColor(for: context.state.phase))
            } compactTrailing: {
                // Compact Trailing (right side of notch)
                Text(context.state.formattedTime)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            } minimal: {
                // Minimal (when multiple Live Activities are active)
                Image(systemName: "timer")
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Lock Screen View
    
    @ViewBuilder
    func lockScreenView(context: ActivityViewContext<TimerActivityAttributes>) -> some View {
        VStack(spacing: 8) {
            HStack {
                // Phase indicator
                HStack(spacing: 6) {
                    Image(systemName: phaseIcon(for: context.state.phase))
                        .foregroundColor(phaseColor(for: context.state.phase))
                    Text(phaseName(for: context.state.phase))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                // Round counter
                Text("Round \(context.state.currentRound)/\(context.state.totalRounds)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Timer display
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(context.state.formattedTime)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()
                
                if !context.state.isRunning {
                    Image(systemName: "pause.circle.fill")
                        .foregroundColor(.orange)
                }
            }
            
            // Preset name
            Text(context.attributes.presetName)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // MARK: - Helper Functions
    
    func phaseIcon(for phase: String) -> String {
        switch phase {
        case "prepare":
            return "clock.badge.exclamationmark"
        case "round":
            return "flame.fill"
        case "rest":
            return "pause.circle.fill"
        case "finished":
            return "checkmark.circle.fill"
        default:
            return "timer"
        }
    }
    
    func phaseColor(for phase: String) -> Color {
        switch phase {
        case "prepare":
            return .yellow
        case "round":
            return .red
        case "rest":
            return .green
        case "finished":
            return .blue
        default:
            return .gray
        }
    }
    
    func phaseName(for phase: String) -> String {
        switch phase {
        case "prepare":
            return "Get Ready"
        case "round":
            return "Fight!"
        case "rest":
            return "Rest"
        case "finished":
            return "Done"
        default:
            return "Timer"
        }
    }
}

#Preview("Notification", as: .content, using: TimerActivityAttributes(presetName: "Boxing Standard")) {
   PunchClockWidgetLiveActivity()
} contentStates: {
    TimerActivityAttributes.ContentState(phase: "prepare", timeRemaining: 10, currentRound: 1, totalRounds: 12, isRunning: true)
    TimerActivityAttributes.ContentState(phase: "round", timeRemaining: 180, currentRound: 5, totalRounds: 12, isRunning: true)
    TimerActivityAttributes.ContentState(phase: "rest", timeRemaining: 60, currentRound: 5, totalRounds: 12, isRunning: true)
}

