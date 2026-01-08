import Foundation
import Combine

final class WatchPresetStore: ObservableObject {
    @Published var presets: [WatchPreset] = []

    private let presetsKey = "watch_presets"

    init() {
        loadPresets()
    }

    private func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: presetsKey),
           let decoded = try? JSONDecoder().decode([WatchPreset].self, from: data) {
            presets = decoded
        } else {
            presets = WatchPreset.defaultPresets
        }
    }

    func savePresets() {
        if let encoded = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(encoded, forKey: presetsKey)
        }
    }

    func updatePresets(_ newPresets: [WatchPreset]) {
        presets = newPresets
        savePresets()
    }
}
