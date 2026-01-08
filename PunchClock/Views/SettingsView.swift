import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settings = SettingsStore.shared

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Sound & Haptics", isOn: $settings.soundEnabled)
                } footer: {
                    Text("Play sounds and vibrations during timer")
                }

                Section {
                    Picker("Appearance", selection: $settings.appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                } footer: {
                    Text("Choose light, dark, or follow system setting")
                }

                Section {
                    Toggle("Show Quotes", isOn: $settings.showQuotes)
                } footer: {
                    Text("Display motivational quotes on the main screen")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
