import Foundation
import Combine
import SwiftUI

class PresetStore: ObservableObject {
    @Published var presets: [Preset] = []

    private let saveKey = "SavedPresets"

    init() {
        loadPresets()
    }

    func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Preset].self, from: data) {
            presets = decoded
        } else {
            // First launch - use default presets
            presets = Preset.defaultPresets
            savePresets()
        }
    }

    func savePresets() {
        if let encoded = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    func addPreset(_ preset: Preset) {
        presets.append(preset)
        savePresets()
    }

    func updatePreset(_ preset: Preset) {
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index] = preset
            savePresets()
        }
    }

    func deletePreset(_ preset: Preset) {
        presets.removeAll { $0.id == preset.id }
        savePresets()
    }

    func deletePresets(at offsets: IndexSet) {
        presets.remove(atOffsets: offsets)
        savePresets()
    }
}
