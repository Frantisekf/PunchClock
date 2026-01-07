//
//  PunchClockApp.swift
//  PunchClock
//
//  Created by Frantisek Farkas on 07.01.2026.
//

import SwiftUI

@main
struct PunchClockApp: App {
    @StateObject private var presetStore = PresetStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presetStore)
        }
    }
}
