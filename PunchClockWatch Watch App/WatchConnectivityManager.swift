import Foundation
import WatchConnectivity
import Combine

final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var receivedPresets: [WatchPreset]?

    private var session: WCSession?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    private func processPresetsData(_ presetsData: [[String: Any]]) {
        let presets = presetsData.compactMap { dict -> WatchPreset? in
            guard let idString = dict["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = dict["name"] as? String,
                  let prepareTime = dict["prepareTime"] as? Int,
                  let roundTime = dict["roundTime"] as? Int,
                  let restTime = dict["restTime"] as? Int,
                  let numberOfRounds = dict["numberOfRounds"] as? Int else {
                return nil
            }

            let reflexEnabled = dict["reflexEnabled"] as? Bool ?? false
            let reflexIntensity = (dict["reflexIntensity"] as? String).flatMap { WatchReflexIntensity(rawValue: $0) } ?? .medium
            let reflexCategories: Set<WatchReflexCueCategory> = {
                guard let rawCategories = dict["reflexCategories"] as? [String] else {
                    return Set(WatchReflexCueCategory.allCases)
                }
                let parsed = Set(rawCategories.compactMap { WatchReflexCueCategory(rawValue: $0) })
                return parsed.isEmpty ? Set(WatchReflexCueCategory.allCases) : parsed
            }()

            return WatchPreset(
                id: id,
                name: name,
                prepareTime: prepareTime,
                roundTime: roundTime,
                restTime: restTime,
                numberOfRounds: numberOfRounds,
                reflexEnabled: reflexEnabled,
                reflexIntensity: reflexIntensity,
                reflexCategories: reflexCategories
            )
        }

        if !presets.isEmpty {
            DispatchQueue.main.async {
                self.receivedPresets = presets
            }
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Check for any pending application context
        if let presetsData = session.receivedApplicationContext["presets"] as? [[String: Any]] {
            processPresetsData(presetsData)
        }
    }

    // Receive immediate messages when Watch is reachable
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let presetsData = message["presets"] as? [[String: Any]] {
            processPresetsData(presetsData)
        }
    }

    // Receive application context updates (works even in background)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        if let presetsData = applicationContext["presets"] as? [[String: Any]] {
            processPresetsData(presetsData)
        }
    }
}
