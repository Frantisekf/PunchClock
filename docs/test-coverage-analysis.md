# Test Coverage Analysis

## Overview

| Target | Source Files | Test Files | Unit Tests | UI Tests |
|--------|-------------|------------|------------|----------|
| iPhone App (`PunchClock`) | 21 | 1 | 9 | 11 |
| Watch App (`PunchClockWatch`) | 10 | 1 | 14 | 2 (boilerplate) |
| Widget (`PunchClockWidget`) | 2 | 0 | 0 | 0 |

**Total: 33 source files, 6 test files, 23 unit tests, 13 UI tests**

---

## What's Currently Tested

### iPhone Unit Tests (`PunchClockTests.swift`)
- `Preset` initialization and property values
- `Preset.defaultPresets` existence
- `Preset.boxingStandard` / `Preset.bjjRolling` static preset values
- `TimerState` initial values
- `TimerPhase` raw values
- `PresetStore` initialization, add, and delete
- Total workout time arithmetic

### Watch Unit Tests (`PunchClockWatch_Watch_AppTests.swift`)
- `WatchPreset` initialization, defaults, and specific presets
- `WatchTimerState` initial values, `phaseDisplayName`, `formattedTime`
- `WatchTimerManager` start, pause/resume, toggle, stop, skip phase
- `WatchPresetStore` initial presets and `updatePresets`

### iPhone UI Tests (`PunchClockUITests.swift`)
- App launch and navigation bar title
- Default presets visible in list
- Add button existence
- Tap preset opens setup sheet, start/cancel flow
- Timer screen shows phase text, pause button, stop button
- Launch performance metric

### Watch UI Tests
- Boilerplate only (launch + performance); no real assertions

---

## Gap Analysis: What's NOT Tested

### Priority 1 — High-Impact, Core Logic (Recommend Adding First)

#### 1. `TimerState` computed properties (iPhone)
- **File:** `PunchClock/Models/TimerState.swift:17-31`
- `phaseDisplayName` — returns different strings per phase, including round number interpolation
- `formattedTime` — minutes:seconds formatting
- **Risk:** The Watch version of these *is* tested, but the iPhone version is not. The iPhone `phaseDisplayName` differs (uses `"Round \(currentRound)"` vs the Watch's `"Fight!"`), so a regression here would go undetected.

#### 2. `WorkoutRecord` model (iPhone)
- **File:** `PunchClock/Models/WorkoutHistory.swift:4-37`
- `isComplete` computed property (`roundsCompleted >= totalRounds`)
- `formattedTime` — same mm:ss formatting
- `formattedDate` — date formatting output
- **Risk:** Workout history is user-visible and records are persisted. Bugs in `isComplete` could misreport workout status.

#### 3. `WorkoutHistoryStore` (iPhone)
- **File:** `PunchClock/Models/WorkoutHistory.swift:39-102`
- `addRecord`, `deleteRecord`, `clearHistory`
- Statistics: `totalWorkouts`, `totalTrainingTime`, `formattedTotalTime`, `thisWeekWorkouts`
- **Risk:** Statistics are displayed in the History view. `formattedTotalTime` has branching logic (hours vs minutes display). `thisWeekWorkouts` uses calendar date math that could silently break.

#### 4. `TimerManager` phase transition logic (iPhone)
- **File:** `PunchClock/Services/TimerManager.swift:306-369`
- `transitionToNextPhase()` — the core state machine that moves between prepare → round → rest → next round → finished
- Edge cases: last round finishes the timer, `restTime == 0` skips rest, `prepareTime == 0` skips prepare
- `catchUpPhases()` — handles time drift when returning from background
- **Risk:** This is the most critical business logic in the app. A regression in phase transitions means the timer doesn't work correctly. Currently has **zero test coverage**.

#### 5. `Preset` Codable backward compatibility (iPhone)
- **File:** `PunchClock/Models/Preset.swift:80-91`
- Custom `init(from decoder:)` uses `decodeIfPresent` with fallback defaults for `reflexEnabled`, `reflexIntensity`, `reflexCategories`
- **Risk:** If a user saved presets before the reflex feature was added, the decoder must handle missing keys gracefully. This migration path is untested.

### Priority 2 — Important Business Logic

#### 6. `PresetStore.updatePreset()` and `deletePresets(at:)` (iPhone)
- **File:** `PunchClock/Models/PresetStore.swift:38-53`
- Only `addPreset` and `deletePreset` (by object) are tested; update and index-based delete are not.
- **Risk:** Edit preset flow relies on `updatePreset`. Swipe-to-delete in the list uses `deletePresets(at:)`.

#### 7. `SettingsStore` and `AppearanceMode` (iPhone)
- **File:** `PunchClock/Models/SettingsStore.swift`
- `AppearanceMode.colorScheme` mapping (system → nil, light → .light, dark → .dark)
- `SettingsStore.appearanceMode` getter/setter round-trip
- **Risk:** Low runtime risk since it's thin, but the enum-to-ColorScheme mapping is easy to test and worth covering.

#### 8. `ReflexIntensity` interval ranges and `ReflexCueCategory` cues (iPhone)
- **File:** `PunchClock/Models/Preset.swift:3-45`
- `ReflexIntensity.intervalRange` (low: 8...12, medium: 4...7, high: 2...4)
- `ReflexCueCategory.cues` — each category returns specific cue strings
- **Risk:** These values directly control reflex cue timing and content. Changes to ranges or cue lists would go undetected.

#### 9. `TimerManager` helper methods (iPhone)
- `restartCurrentRound()` — resets time for the current phase
- `skipPhase()` — advances to the next phase
- `addTime()` — adds seconds to current timer
- `togglePauseResume()`
- **Risk:** These are user-facing controls. The Watch version of skip/toggle *is* tested, but the iPhone version is not.

### Priority 3 — Moderate Value

#### 10. `WatchTimerManager` full phase transition cycle
- The Watch tests cover start, pause, resume, stop, and one skip. They don't test a multi-round scenario: prepare → round 1 → rest → round 2 → ... → finished.
- **Risk:** The Watch timer might not correctly increment rounds or finish after the last round.

#### 11. `WatchPreset` / `Preset` Codable round-trip encoding
- Encode a preset to JSON, decode it back, assert equality.
- **Risk:** Ensures persistence works correctly, especially with the `Set<ReflexCueCategory>` encoding.

#### 12. Watch UI Tests (currently empty)
- `PunchClockWatch_Watch_AppUITests.swift` has only boilerplate.
- At minimum: verify preset list appears, tap a preset, verify timer starts.

### Priority 4 — Nice to Have

#### 13. `SoundManager` and `HapticManager`
- These depend on hardware (`AVAudioPlayer`, `CoreHaptics`) and are hard to unit test without mocking.
- Consider: extract the "should play" logic (checking `isEnabled`, `supportsHaptics`) into testable pure functions or use protocol-based mocking.

#### 14. `WatchConnectivityManager` / `PhoneConnectivityManager`
- Cross-device communication is inherently hard to unit test.
- Consider: test the data serialization/deserialization layer independently.

#### 15. Widget (`PunchClockWidget`)
- `TimerActivityAttributes` is a simple data struct — low value to test.
- `PunchClockWidgetLiveActivity` is SwiftUI view code — test via UI tests or snapshot tests.

---

## Recommended Action Plan

### Phase 1: Model & State Machine Tests (Highest ROI)
Add tests for iPhone `TimerState` (computed properties), `WorkoutRecord`, `WorkoutHistoryStore`, and `Preset` Codable decoding. These are pure logic, easy to test, and cover the most critical gaps.

**Suggested new test file:** `PunchClockTests/TimerStateTests.swift`
- `testPhaseDisplayName` for all phases including round number
- `testFormattedTime` for 0, 30, 60, 90, edge cases (e.g., 3599)

**Suggested new test file:** `PunchClockTests/WorkoutHistoryTests.swift`
- `testWorkoutRecordIsComplete` / `testWorkoutRecordIsIncomplete`
- `testWorkoutRecordFormattedTime`
- `testHistoryStoreAddAndDelete`
- `testHistoryStoreStatistics`
- `testFormattedTotalTimeHoursAndMinutes`

**Suggested additions to:** `PunchClockTests/PunchClockTests.swift`
- `testPresetCodableRoundTrip`
- `testPresetCodableBackwardCompatibility` (decode JSON without reflex fields)
- `testPresetStoreUpdatePreset`

### Phase 2: Timer Manager Phase Transitions
This is the most impactful test to add but requires either:
- Refactoring `TimerManager` to accept injectable dependencies (clock, sound manager) so phase transitions can be tested without real timers
- Or testing `transitionToNextPhase` indirectly via `skipPhase()` calls

**Key scenarios to cover:**
- prepare → round → rest → round → ... → finished (full cycle)
- `prepareTime == 0` skips directly to round
- `restTime == 0` skips rest between rounds
- Last round transitions to finished
- `catchUpPhases` correctly processes multiple phase transitions

### Phase 3: Reflex System & Remaining Enums
- `ReflexIntensity.intervalRange` values
- `ReflexCueCategory.cues` arrays
- `AppearanceMode.colorScheme` mapping

### Phase 4: Watch & UI Test Expansion
- Flesh out Watch UI tests with real assertions
- Add iPhone UI tests for: pause/resume flow, stop and return to list, create/edit/delete presets, history view navigation, settings toggles
