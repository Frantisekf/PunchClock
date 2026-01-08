import SwiftUI
import Combine

enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("appearanceMode") private var appearanceModeRaw: String = AppearanceMode.system.rawValue
    @AppStorage("showQuotes") var showQuotes: Bool = false

    var appearanceMode: AppearanceMode {
        get { AppearanceMode(rawValue: appearanceModeRaw) ?? .system }
        set {
            appearanceModeRaw = newValue.rawValue
            objectWillChange.send()
        }
    }

    private init() {}
}
