import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Configure your widget." }

    @Parameter(title: "Favorite Emoji", default: "🥊")
    var favoriteEmoji: String
}
