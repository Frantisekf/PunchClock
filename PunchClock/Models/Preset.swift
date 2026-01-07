import Foundation

struct Preset: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var prepareTime: Int
    var roundTime: Int
    var restTime: Int
    var numberOfRounds: Int
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        name: String,
        prepareTime: Int,
        roundTime: Int,
        restTime: Int,
        numberOfRounds: Int,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.prepareTime = prepareTime
        self.roundTime = roundTime
        self.restTime = restTime
        self.numberOfRounds = numberOfRounds
        self.isFavorite = isFavorite
    }

    static let boxingStandard = Preset(
        name: "Boxing Standard",
        prepareTime: 10,
        roundTime: 180,
        restTime: 60,
        numberOfRounds: 12
    )

    static let mmaStyle = Preset(
        name: "MMA Style",
        prepareTime: 10,
        roundTime: 300,
        restTime: 60,
        numberOfRounds: 5
    )

    static let quickTraining = Preset(
        name: "Quick Training",
        prepareTime: 5,
        roundTime: 120,
        restTime: 30,
        numberOfRounds: 6
    )

    static let bjjRolling = Preset(
        name: "BJJ Rolling",
        prepareTime: 10,
        roundTime: 360,
        restTime: 60,
        numberOfRounds: 5
    )

    static let muayThai = Preset(
        name: "Muay Thai",
        prepareTime: 10,
        roundTime: 180,
        restTime: 120,
        numberOfRounds: 5
    )

    static let defaultPresets: [Preset] = [
        .boxingStandard,
        .mmaStyle,
        .muayThai,
        .bjjRolling,
        .quickTraining
    ]
}
