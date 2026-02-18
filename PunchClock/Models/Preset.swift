import Foundation

enum ReflexIntensity: String, Codable, CaseIterable {
    case low
    case medium
    case high

    var intervalRange: ClosedRange<Int> {
        switch self {
        case .low: return 8...12
        case .medium: return 4...7
        case .high: return 2...4
        }
    }

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

enum ReflexCueCategory: String, Codable, CaseIterable, Hashable {
    case defensive
    case movement
    case offensive

    var cues: [String] {
        switch self {
        case .defensive: return ["Slip", "Block", "Parry", "Roll"]
        case .movement: return ["Angle", "Level change", "Pivot", "Step back"]
        case .offensive: return ["Jab", "Cross", "Hook", "Body shot"]
        }
    }

    var displayName: String {
        switch self {
        case .defensive: return "Defensive"
        case .movement: return "Movement"
        case .offensive: return "Offensive"
        }
    }
}

struct Preset: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var prepareTime: Int
    var roundTime: Int
    var restTime: Int
    var numberOfRounds: Int
    var reflexEnabled: Bool = false
    var reflexIntensity: ReflexIntensity = .medium
    var reflexCategories: Set<ReflexCueCategory> = Set(ReflexCueCategory.allCases)

    init(
        id: UUID = UUID(),
        name: String,
        prepareTime: Int,
        roundTime: Int,
        restTime: Int,
        numberOfRounds: Int,
        reflexEnabled: Bool = false,
        reflexIntensity: ReflexIntensity = .medium,
        reflexCategories: Set<ReflexCueCategory> = Set(ReflexCueCategory.allCases)
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
        reflexIntensity = try container.decodeIfPresent(ReflexIntensity.self, forKey: .reflexIntensity) ?? .medium
        reflexCategories = try container.decodeIfPresent(Set<ReflexCueCategory>.self, forKey: .reflexCategories) ?? Set(ReflexCueCategory.allCases)
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

    static let shadowboxing = Preset(
        name: "Shadowboxing",
        prepareTime: 10,
        roundTime: 120,
        restTime: 30,
        numberOfRounds: 3
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

    static let heavyBagHIIT = Preset(
        name: "Heavy Bag HIIT",
        prepareTime: 10,
        roundTime: 30,
        restTime: 30,
        numberOfRounds: 10
    )

    static let defaultPresets: [Preset] = [
        .boxingStandard,
        .mmaStyle,
        .muayThai,
        .bjjRolling,
        .heavyBagHIIT,
        .shadowboxing
    ]
}
