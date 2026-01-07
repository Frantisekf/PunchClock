import AppIntents
import Foundation

struct StartTimerShortcut: AppIntent {
    static var title: LocalizedStringResource = "Start Boxing Timer"
    static var description = IntentDescription("Start a timer with a selected preset")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Preset")
    var presetName: PresetEntity?

    init() {}

    init(preset: PresetEntity) {
        self.presetName = preset
    }

    func perform() async throws -> some IntentResult {
        let name = presetName?.name ?? "Boxing Standard"
        await MainActor.run {
            NotificationCenter.default.post(
                name: .startTimerFromSiri,
                object: nil,
                userInfo: ["presetName": name]
            )
        }
        return .result()
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Start \(\.$presetName) timer")
    }
}

struct PresetEntity: AppEntity {
    var id: String
    var name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Preset"
    static var defaultQuery = PresetEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct PresetEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [PresetEntity] {
        let allPresets = defaultPresetEntities()
        return allPresets.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [PresetEntity] {
        defaultPresetEntities()
    }

    func defaultResult() async -> PresetEntity? {
        defaultPresetEntities().first
    }

    private func defaultPresetEntities() -> [PresetEntity] {
        [
            PresetEntity(id: "boxing", name: "Boxing Standard"),
            PresetEntity(id: "mma", name: "MMA Style"),
            PresetEntity(id: "muaythai", name: "Muay Thai"),
            PresetEntity(id: "bjj", name: "BJJ Rolling"),
            PresetEntity(id: "quick", name: "Quick Training")
        ]
    }
}

struct PunchClockShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartTimerShortcut(),
            phrases: [
                "Start \(.applicationName)",
                "Start \(.applicationName) timer",
                "Start boxing timer with \(.applicationName)",
                "Start \(\.$presetName) with \(.applicationName)",
                "Begin \(\.$presetName) timer in \(.applicationName)"
            ],
            shortTitle: "Start Timer",
            systemImageName: "timer"
        )
    }
}

extension Notification.Name {
    static let startTimerFromSiri = Notification.Name("startTimerFromSiri")
}
