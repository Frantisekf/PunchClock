import Foundation

enum WatchReflexIntensity: String, Codable, CaseIterable {
    case low
    case medium
    case high
}

enum WatchReflexCueCategory: String, Codable, CaseIterable, Hashable {
    case defensive
    case movement
    case offensive
}

struct WatchPreset: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var prepareTime: Int
    var roundTime: Int
    var restTime: Int
    var numberOfRounds: Int
    var reflexEnabled: Bool = false
    var reflexIntensity: WatchReflexIntensity = .medium
    var reflexCategories: Set<WatchReflexCueCategory> = Set(WatchReflexCueCategory.allCases)

    init(
        id: UUID = UUID(),
        name: String,
        prepareTime: Int,
        roundTime: Int,
        restTime: Int,
        numberOfRounds: Int,
        reflexEnabled: Bool = false,
        reflexIntensity: WatchReflexIntensity = .medium,
        reflexCategories: Set<WatchReflexCueCategory> = Set(WatchReflexCueCategory.allCases)
    ) {
        self.id = id
        self.name = name
        self.prepareTime = prepareTime
        self.roundTime = roundTime
        self.restTime = restTime
        self.numberOfRounds = numberOfRounds
        self.reflexEnabled = reflexEnabled
        self.reflexIntensity = reflexIntensity
        self.reflexCategories = reflexCategories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        prepareTime = try container.decode(Int.self, forKey: .prepareTime)
        roundTime = try container.decode(Int.self, forKey: .roundTime)
        restTime = try container.decode(Int.self, forKey: .restTime)
        numberOfRounds = try container.decode(Int.self, forKey: .numberOfRounds)
        reflexEnabled = try container.decodeIfPresent(Bool.self, forKey: .reflexEnabled) ?? false
        reflexIntensity = try container.decodeIfPresent(WatchReflexIntensity.self, forKey: .reflexIntensity) ?? .medium
        reflexCategories = try container.decodeIfPresent(Set<WatchReflexCueCategory>.self, forKey: .reflexCategories) ?? Set(WatchReflexCueCategory.allCases)
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
