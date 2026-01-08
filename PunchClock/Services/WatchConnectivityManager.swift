import Foundation
import WatchConnectivity
import Combine

final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    private var session: WCSession?
    @Published var isReachable = false

    private override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func syncPresets(_ presets: [Preset]) {
        guard let session = session, session.activationState == .activated else { return }

        // Convert Preset to dictionary for transfer
        let presetsData = presets.map { preset -> [String: Any] in
            [
                "id": preset.id.uuidString,
                "name": preset.name,
                "prepareTime": preset.prepareTime,
                "roundTime": preset.roundTime,
                "restTime": preset.restTime,
                "numberOfRounds": preset.numberOfRounds
            ]
        }

        let message: [String: Any] = ["presets": presetsData]

        // Use updateApplicationContext for reliable background transfer
        // This ensures the Watch gets the data even if not currently reachable
        do {
            try session.updateApplicationContext(message)
        } catch {
            // Context update failed - will retry on next change
        }

        // Also send immediately if reachable for faster sync
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { _ in
                // Message send failed - applicationContext will handle it
            }
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // iOS only - handle session becoming inactive
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // iOS only - reactivate session
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
}
