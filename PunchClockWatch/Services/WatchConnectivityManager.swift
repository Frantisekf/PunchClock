import Foundation
import WatchConnectivity

final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var receivedPresets: [WatchPreset] = []

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Session activated
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        if let data = applicationContext["presets"] as? Data,
           let presets = try? JSONDecoder().decode([WatchPreset].self, from: data) {
            DispatchQueue.main.async {
                self.receivedPresets = presets
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let data = message["presets"] as? Data,
           let presets = try? JSONDecoder().decode([WatchPreset].self, from: data) {
            DispatchQueue.main.async {
                self.receivedPresets = presets
            }
        }
    }
}
