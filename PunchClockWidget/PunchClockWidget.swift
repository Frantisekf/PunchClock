import WidgetKit
import SwiftUI

struct PunchClockWidget: Widget {
    let kind: String = "PunchClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PunchClockWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Punch Clock")
        .description("Quick access to your timer.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let timeline = Timeline(entries: [SimpleEntry(date: Date())], policy: .atEnd)
        completion(timeline)
    }
}

struct PunchClockWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.system(size: 40))
                .foregroundStyle(.red)

            Text("Punch Clock")
                .font(.headline)

            Text(entry.date, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview(as: .systemSmall) {
    PunchClockWidget()
} timeline: {
    SimpleEntry(date: .now)
}
