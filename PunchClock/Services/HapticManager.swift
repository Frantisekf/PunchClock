import UIKit
import CoreHaptics

final class HapticManager {
    static let shared = HapticManager()

    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let mediumFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()

    private var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    private init() {
        // Prepare generators
        lightFeedback.prepare()
        mediumFeedback.prepare()
        selectionFeedback.prepare()
    }

    /// Light tap feedback - for button taps, selections
    func lightTap() {
        guard supportsHaptics else { return }
        lightFeedback.impactOccurred()
    }

    /// Medium tap feedback - for more significant actions
    func mediumTap() {
        guard supportsHaptics else { return }
        mediumFeedback.impactOccurred()
    }

    /// Selection feedback - for picker changes, toggles
    func selection() {
        guard supportsHaptics else { return }
        selectionFeedback.selectionChanged()
    }
}
