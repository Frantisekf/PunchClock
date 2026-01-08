import Foundation

struct WatchPreset: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var prepareTime: Int
    var roundTime: Int
    var restTime: Int
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

    static let boxingStandard = WatchPreset(
        name: "Boxing Standard",
        prepareTime: 10,
        roundTime: 180,
        restTime: 60,
        numberOfRounds: 12
    )

    static let mmaStyle = WatchPreset(
        name: "MMA Style",
        prepareTime: 10,
        roundTime: 300,
        restTime: 60,
        numberOfRounds: 5
    )

    static let shadowboxing = WatchPreset(
        name: "Shadowboxing",
        prepareTime: 10,
        roundTime: 120,
        restTime: 30,
        numberOfRounds: 3
    )

    static let bjjRolling = WatchPreset(
        name: "BJJ Rolling",
        prepareTime: 10,
        roundTime: 360,
        restTime: 60,
        numberOfRounds: 5
    )

    static let muayThai = WatchPreset(
        name: "Muay Thai",
        prepareTime: 10,
        roundTime: 180,
        restTime: 120,
        numberOfRounds: 5
    )

    static let heavyBagHIIT = WatchPreset(
        name: "Heavy Bag HIIT",
        prepareTime: 10,
        roundTime: 30,
        restTime: 30,
        numberOfRounds: 10
    )

    static let defaultPresets: [WatchPreset] = [
        .boxingStandard,
        .mmaStyle,
        .muayThai,
        .bjjRolling,
        .heavyBagHIIT,
        .shadowboxing
    ]
}
