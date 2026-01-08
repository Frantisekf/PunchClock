import Foundation
import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    private init() {}

    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard isHealthKitAvailable else {
            completion(false)
            return
        }

        let workoutType = HKObjectType.workoutType()
        let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!

        let typesToShare: Set<HKSampleType> = [workoutType, activeEnergy]
        let typesToRead: Set<HKObjectType> = [workoutType]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    func saveWorkout(
        duration: TimeInterval,
        rounds: Int,
        presetName: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard isHealthKitAvailable else {
            completion(false)
            return
        }

        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-duration)

        // Estimate calories: ~10-15 cal/min for boxing/combat sports
        let estimatedCalories = (duration / 60.0) * 12.0
        let energyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: estimatedCalories)

        let workout = HKWorkout(
            activityType: .boxing,
            start: startDate,
            end: endDate,
            duration: duration,
            totalEnergyBurned: energyBurned,
            totalDistance: nil,
            metadata: [
                HKMetadataKeyWorkoutBrandName: "Ring Timer",
                "PresetName": presetName,
                "RoundsCompleted": rounds
            ]
        )

        healthStore.save(workout) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
