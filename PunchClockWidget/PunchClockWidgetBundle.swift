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
