//
//  PunchClockWidgetBundle.swift
//  PunchClockWidget
//
//  Created by Frantisek Farkas on 07.01.2026.
//

import WidgetKit
import SwiftUI

@main
struct PunchClockWidgetBundle: WidgetBundle {
    var body: some Widget {
        PunchClockWidget()
        PunchClockWidgetControl()
        PunchClockWidgetLiveActivity()
    }
}
