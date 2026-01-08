import XCTest
@testable import PunchClockWatch_Watch_App

final class WatchPresetTests: XCTestCase {

    func testPresetInitialization() {
        let preset = WatchPreset(
            name: "Test Preset",
            prepareTime: 10,
            roundTime: 180,
            restTime: 60,
            numberOfRounds: 5
        )

        XCTAssertEqual(preset.name, "Test Preset")
        XCTAssertEqual(preset.prepareTime, 10)
        XCTAssertEqual(preset.roundTime, 180)
        XCTAssertEqual(preset.restTime, 60)
        XCTAssertEqual(preset.numberOfRounds, 5)
    }

    func testDefaultPresets() {
        let presets = WatchPreset.defaultPresets

        XCTAssertEqual(presets.count, 6)
        XCTAssertEqual(presets[0].name, "Boxing Standard")
        XCTAssertEqual(presets[1].name, "MMA Style")
        XCTAssertEqual(presets[2].name, "Muay Thai")
        XCTAssertEqual(presets[3].name, "BJJ Rolling")
        XCTAssertEqual(presets[4].name, "Heavy Bag HIIT")
        XCTAssertEqual(presets[5].name, "Shadowboxing")
    }

    func testBoxingStandardPreset() {
        let preset = WatchPreset.boxingStandard

        XCTAssertEqual(preset.name, "Boxing Standard")
        XCTAssertEqual(preset.roundTime, 180) // 3 minutes
        XCTAssertEqual(preset.restTime, 60)   // 1 minute
        XCTAssertEqual(preset.numberOfRounds, 12)
    }

    func testHeavyBagHIITPreset() {
        let preset = WatchPreset.heavyBagHIIT

        XCTAssertEqual(preset.name, "Heavy Bag HIIT")
        XCTAssertEqual(preset.roundTime, 30)  // 30 seconds
        XCTAssertEqual(preset.restTime, 30)   // 30 seconds
        XCTAssertEqual(preset.numberOfRounds, 10)
    }
}

final class WatchTimerStateTests: XCTestCase {

    func testInitialState() {
        let state = WatchTimerState()

        XCTAssertEqual(state.phase, .idle)
        XCTAssertEqual(state.currentRound, 1)
        XCTAssertEqual(state.timeRemaining, 0)
        XCTAssertFalse(state.isRunning)
    }

    func testPhaseDisplayNames() {
        var state = WatchTimerState()

        state.phase = .idle
        XCTAssertEqual(state.phaseDisplayName, "Ready")

        state.phase = .prepare
        XCTAssertEqual(state.phaseDisplayName, "Get Ready")

        state.phase = .round
        XCTAssertEqual(state.phaseDisplayName, "Fight!")

        state.phase = .rest
        XCTAssertEqual(state.phaseDisplayName, "Rest")

        state.phase = .finished
        XCTAssertEqual(state.phaseDisplayName, "Done")
    }

    func testFormattedTime() {
        var state = WatchTimerState()

        state.timeRemaining = 0
        XCTAssertEqual(state.formattedTime, "0:00")

        state.timeRemaining = 30
        XCTAssertEqual(state.formattedTime, "0:30")

        state.timeRemaining = 60
        XCTAssertEqual(state.formattedTime, "1:00")

        state.timeRemaining = 90
        XCTAssertEqual(state.formattedTime, "1:30")

        state.timeRemaining = 180
        XCTAssertEqual(state.formattedTime, "3:00")
    }
}

final class WatchTimerManagerTests: XCTestCase {

    func testInitialState() {
        let manager = WatchTimerManager()

        XCTAssertEqual(manager.state.phase, .idle)
        XCTAssertFalse(manager.state.isRunning)
        XCTAssertNil(manager.currentPreset)
    }

    func testStartTimer() {
        let manager = WatchTimerManager()
        let preset = WatchPreset.boxingStandard

        manager.start(with: preset)

        XCTAssertEqual(manager.state.phase, .prepare)
        XCTAssertEqual(manager.state.timeRemaining, preset.prepareTime)
        XCTAssertEqual(manager.state.currentRound, 1)
        XCTAssertTrue(manager.state.isRunning)
        XCTAssertNotNil(manager.currentPreset)
    }

    func testPauseResume() {
        let manager = WatchTimerManager()
        manager.start(with: .boxingStandard)

        XCTAssertTrue(manager.state.isRunning)

        manager.pause()
        XCTAssertFalse(manager.state.isRunning)

        manager.resume()
        XCTAssertTrue(manager.state.isRunning)
    }

    func testTogglePauseResume() {
        let manager = WatchTimerManager()
        manager.start(with: .boxingStandard)

        XCTAssertTrue(manager.state.isRunning)

        manager.togglePauseResume()
        XCTAssertFalse(manager.state.isRunning)

        manager.togglePauseResume()
        XCTAssertTrue(manager.state.isRunning)
    }

    func testStop() {
        let manager = WatchTimerManager()
        manager.start(with: .boxingStandard)

        manager.stop()

        XCTAssertEqual(manager.state.phase, .idle)
        XCTAssertFalse(manager.state.isRunning)
    }

    func testSkipPhase() {
        let manager = WatchTimerManager()
        manager.start(with: .boxingStandard)

        XCTAssertEqual(manager.state.phase, .prepare)

        manager.skipPhase()

        XCTAssertEqual(manager.state.phase, .round)
        XCTAssertTrue(manager.state.isRunning)
    }
}

final class WatchPresetStoreTests: XCTestCase {

    func testInitialPresets() {
        let store = WatchPresetStore()

        XCTAssertFalse(store.presets.isEmpty)
        XCTAssertEqual(store.presets.count, 6)
    }

    func testUpdatePresets() {
        let store = WatchPresetStore()
        let newPresets = [WatchPreset.boxingStandard, WatchPreset.mmaStyle]

        store.updatePresets(newPresets)

        XCTAssertEqual(store.presets.count, 2)
    }
}
