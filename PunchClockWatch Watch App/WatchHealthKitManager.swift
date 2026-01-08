import Combine
import Foundation
import HealthKit

final class WatchHealthKitManager: NSObject, ObservableObject {
    static let shared = WatchHealthKitManager()

    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?

    @Published var isWorkoutActive = false
    @Published var heartRate: Double = 0

    private override init() {
        super.init()
    }

    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard isHealthKitAvailable else {
            completion(false)
            return
        }

        let workoutType = HKObjectType.workoutType()
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!

        let typesToShare: Set<HKSampleType> = [workoutType, activeEnergy]
        let typesToRead: Set<HKObjectType> = [workoutType, heartRateType, activeEnergy]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    func startWorkout() {
        guard isHealthKitAvailable else { return }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .boxing
        configuration.locationType = .indoor

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()

            workoutSession?.delegate = self
            workoutBuilder?.delegate = self

            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )

            let startDate = Date()
            workoutSession?.startActivity(with: startDate)
            workoutBuilder?.beginCollection(withStart: startDate) { _, _ in }

            DispatchQueue.main.async {
                self.isWorkoutActive = true
            }
        } catch {
            // Failed to start workout session
        }
    }

    func endWorkout() {
        workoutSession?.end()

        workoutBuilder?.endCollection(withEnd: Date()) { [weak self] _, _ in
            self?.workoutBuilder?.finishWorkout { _, _ in
                DispatchQueue.main.async {
                    self?.isWorkoutActive = false
                    self?.heartRate = 0
                }
            }
        }
    }
}

extension WatchHealthKitManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.isWorkoutActive = toState == .running
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}
}

extension WatchHealthKitManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType,
                  quantityType == HKQuantityType.quantityType(forIdentifier: .heartRate) else { continue }

            if let statistics = workoutBuilder.statistics(for: quantityType) {
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                if let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) {
                    DispatchQueue.main.async {
                        self.heartRate = value
                    }
                }
            }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
