import Foundation

struct Preset: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var prepareTime: Int      // seconds
    var roundTime: Int        // seconds
    var restTime: Int         // seconds
    var numberOfRounds: Int

    init(
        id: UUID = UUID(),
        name: String,
        prepareTime: Int,
        roundTime: Int,
        restTime: Int,
        numberOfRounds: Int
    ) {
        self.id = id
        self.name = name
        self.prepareTime = prepareTime
        self.roundTime = roundTime
        self.restTime = restTime
        self.numberOfRounds = numberOfRounds
    }

    static let boxingStandard = Preset(
        name: "Boxing Standard",
        prepareTime: 10,
        roundTime: 180,      // 3 minutes
        restTime: 60,        // 1 minute
        numberOfRounds: 12
    )

    static let mmaStyle = Preset(
        name: "MMA Style",
        prepareTime: 10,
        roundTime: 300,      // 5 minutes
        restTime: 60,        // 1 minute
        numberOfRounds: 5
    )

    static let quickTraining = Preset(
        name: "Quick Training",
        prepareTime: 5,
        roundTime: 120,      // 2 minutes
        restTime: 30,
        numberOfRounds: 6
    )

    static let defaultPresets: [Preset] = [
        .boxingStandard,
        .mmaStyle,
        .quickTraining
    ]
}
