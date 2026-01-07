import Foundation
import Combine

struct WorkoutRecord: Identifiable, Codable {
    let id: UUID
    let presetName: String
    let date: Date
    let totalTime: Int // seconds
    let roundsCompleted: Int
    let totalRounds: Int

    init(presetName: String, totalTime: Int, roundsCompleted: Int, totalRounds: Int) {
        self.id = UUID()
        self.presetName = presetName
        self.date = Date()
        self.totalTime = totalTime
        self.roundsCompleted = roundsCompleted
        self.totalRounds = totalRounds
    }

    var isComplete: Bool {
        roundsCompleted >= totalRounds
    }

    var formattedTime: String {
        let minutes = totalTime / 60
        let seconds = totalTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

final class WorkoutHistoryStore: ObservableObject {
    @Published var records: [WorkoutRecord] = []

    private let saveKey = "workoutHistory"

    init() {
        loadRecords()
    }

    func addRecord(_ record: WorkoutRecord) {
        records.insert(record, at: 0)
        saveRecords()
    }

    func clearHistory() {
        records.removeAll()
        saveRecords()
    }

    func deleteRecord(_ record: WorkoutRecord) {
        records.removeAll { $0.id == record.id }
        saveRecords()
    }

    // MARK: - Statistics

    var totalWorkouts: Int {
        records.count
    }

    var totalTrainingTime: Int {
        records.reduce(0) { $0 + $1.totalTime }
    }

    var formattedTotalTime: String {
        let hours = totalTrainingTime / 3600
        let minutes = (totalTrainingTime % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var thisWeekWorkouts: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return records.filter { $0.date > weekAgo }.count
    }

    // MARK: - Persistence

    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([WorkoutRecord].self, from: data) {
            records = decoded
        }
    }
}
