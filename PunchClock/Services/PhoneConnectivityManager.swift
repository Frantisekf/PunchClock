import Combine
import Foundation
import WatchConnectivity

final class PhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = PhoneConnectivityManager()

    @Published var isWatchAppInstalled = false

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendPresetsToWatch(_ presets: [Preset]) {
        guard WCSession.default.isWatchAppInstalled else { return }

        // Convert Preset to a format Watch can decode
        let watchPresets = presets.map { preset in
            [
                "id": preset.id.uuidString,
                "name": preset.name,
                "prepareTime": preset.prepareTime,
                "roundTime": preset.roundTime,
                "restTime": preset.restTime,
                "numberOfRounds": preset.numberOfRounds
            ] as [String: Any]
        }

        if let data = try? JSONSerialization.data(withJSONObject: watchPresets) {
            do {
                try WCSession.default.updateApplicationContext(["presets": data])
            } catch {
                // Failed to send
            }
        }
    }
}

extension PhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }
}
