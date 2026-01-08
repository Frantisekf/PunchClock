# Round Timer

A no-nonsense combat sports interval timer for iOS and Apple Watch with Dynamic Island and Live Activity support.

**No ads. No subscriptions. One-time lifetime purchase.**

## App Store

### Category
Health & Fitness

### Keywords
boxing timer, mma timer, muay thai timer, bjj timer, hiit timer, interval timer, round timer, workout timer, combat sports, martial arts, kickboxing, sparring timer, training timer, fitness timer, tabata, apple watch

### Short Description
Professional interval timer for boxing, MMA, BJJ, Muay Thai, and HIIT workouts. Apple Watch + Dynamic Island support. No ads.

### Full Description
Round Timer is the ultimate interval timer built for fighters and athletes. Whether you're boxing, rolling BJJ, doing Muay Thai rounds, or crushing a HIIT session - this timer keeps you focused on training, not fumbling with your phone.

**Why Round Timer?**
- Start your timer and forget about your phone
- Apple Watch app for wrist-based training
- Dynamic Island shows your countdown while multitasking
- Lock screen Live Activity keeps you informed
- Hands-free Siri voice commands (perfect when gloved up)
- Color-coded phases you can see across the gym
- Bell sounds and haptic feedback you can feel

**Perfect for:**
- Boxing (3-minute rounds)
- MMA (5-minute rounds)
- Muay Thai
- Brazilian Jiu-Jitsu rolling
- HIIT / Tabata workouts
- Circuit training
- Any interval-based training

**100% Native. Zero Bloat.**
Built entirely with Apple frameworks. No third-party tracking, no analytics, no data collection. Just a timer that works.

## Features

### iPhone
- **Customizable Presets** - Create, edit, and save your own timer configurations
- **Built-in Presets** - Boxing, MMA, Muay Thai, BJJ Rolling, Heavy Bag HIIT, and Shadowboxing
- **Dynamic Island** - Real-time countdown visible while multitasking
- **Live Activity** - Lock screen widget shows current phase and round
- **Workout History** - Track your completed sessions with stats
- **Audio Cues** - Bell sound at round start/end, countdown beeps
- **Haptic Feedback** - Feel the countdown and phase changes
- **Mute Mode** - Silence sounds and haptics when needed
- **Full-Screen Timer** - Color-coded phases (yellow prepare, red round, green rest)
- **Skip & +20s** - Skip prepare/rest phases or add extra rest time
- **Motivational Quotes** - Fighter quotes, Jocko Willink, David Goggins, Stoic philosophy

### Apple Watch
- **Standalone App** - Works independently without iPhone
- **Full-Screen Colors** - Instantly see your phase from any angle
- **Distinct Haptics** - Double-tap for round start, triple-tap for round end
- **HealthKit Integration** - Workouts save to Apple Fitness with heart rate
- **Simple Controls** - Stop, pause/resume, and skip buttons

## Requirements

- iOS 16.2+
- watchOS 9.0+
- Xcode 15+

## Installation

1. Clone the repository
2. Open `PunchClock.xcodeproj` in Xcode
3. Build and run on your device or simulator

## Architecture

100% native Apple frameworks. Zero third-party dependencies.

```
PunchClock/
├── Models/
│   ├── Preset.swift           # Timer preset configuration
│   ├── PresetStore.swift      # Preset persistence
│   ├── TimerState.swift       # Timer state machine
│   └── WorkoutHistory.swift   # Workout history & stats
├── Services/
│   ├── TimerManager.swift     # Core timer logic + Live Activity
│   ├── SoundManager.swift     # Audio playback
│   ├── HapticManager.swift    # Haptic feedback
│   └── TimerActivityAttributes.swift
├── Views/
│   ├── ContentView.swift      # Main preset list
│   ├── PresetSetupView.swift  # Pre-start configuration
│   ├── PresetEditorView.swift # Create/edit presets
│   ├── TimerView.swift        # Active timer display
│   └── HistoryView.swift      # Workout history
├── PunchClockWidget/
│   └── PunchClockWidgetLiveActivity.swift
└── PunchClockWatch Watch App/
    ├── WatchPreset.swift
    ├── WatchTimerManager.swift
    ├── WatchHealthKitManager.swift
    └── WatchTimerView.swift
```

## Timer Phases

| Phase | Color | Description |
|-------|-------|-------------|
| Prepare | Yellow | Countdown before first round |
| Round | Red | Active fighting/training |
| Rest | Green | Break between rounds |
| Finished | Green | Workout complete |

## Default Presets

| Preset | Round Time | Rest | Rounds | Total |
|--------|------------|------|--------|-------|
| Boxing Standard | 3:00 | 1:00 | 12 | ~47m |
| MMA Style | 5:00 | 1:00 | 5 | ~29m |
| Muay Thai | 3:00 | 2:00 | 5 | ~23m |
| BJJ Rolling | 6:00 | 1:00 | 5 | ~34m |
| Heavy Bag HIIT | 0:30 | 0:30 | 10 | ~10m |
| Shadowboxing | 2:00 | 0:30 | 3 | ~7m |

## Siri Voice Commands

Start timers hands-free (great when gloved up):

- "Hey Siri, start Boxing Standard in Round Timer"
- "Hey Siri, start BJJ Rolling in Round Timer"
- "Hey Siri, start sparring with Round Timer"

## Tech Stack

| Framework | Purpose |
|-----------|---------|
| SwiftUI | UI |
| Foundation | Core types, UserDefaults |
| Combine | Reactive state |
| UIKit | Haptics, background tasks |
| ActivityKit | Live Activities, Dynamic Island |
| WidgetKit | Widget extension |
| AppIntents | Siri Shortcuts |
| AVFoundation | Audio playback |
| HealthKit | Apple Watch workout tracking |
| WatchKit | Apple Watch app |

## License

MIT License
