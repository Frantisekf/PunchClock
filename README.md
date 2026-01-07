# Ring Timer

A no-nonsense combat sports interval timer for iOS with Dynamic Island and Live Activity support.

**No ads. No subscriptions. One-time lifetime purchase.**

## App Store

### Category
Health & Fitness

### Keywords
boxing timer, mma timer, muay thai timer, bjj timer, hiit timer, interval timer, round timer, workout timer, combat sports, martial arts, kickboxing, sparring timer, training timer, fitness timer, tabata

### Short Description
Professional interval timer for boxing, MMA, BJJ, Muay Thai, and HIIT workouts. Dynamic Island support. No ads.

### Full Description
Ring Timer is the ultimate interval timer built for fighters and athletes. Whether you're boxing, rolling BJJ, doing Muay Thai rounds, or crushing a HIIT session - this timer keeps you focused on training, not fumbling with your phone.

**Why Ring Timer?**
- Start your timer and forget about your phone
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

- **Customizable Presets** - Create, edit, and save your own timer configurations
- **Built-in Presets** - Boxing, MMA, Muay Thai, BJJ Rolling, and Quick Training
- **Dynamic Island** - Real-time countdown visible while multitasking
- **Live Activity** - Lock screen widget shows current phase and round
- **Workout History** - Track your completed sessions with stats
- **Audio Cues** - Bell sound at round start/end, countdown beeps
- **Haptic Feedback** - Feel the countdown and phase changes
- **Mute Mode** - Silence sounds and haptics when needed
- **Background Notifications** - Get alerted even when app is backgrounded
- **Full-Screen Timer** - Color-coded phases (yellow prepare, red round, green rest)
- **Skip & +20s** - Skip prepare/rest phases or add extra rest time
- **Motivational Quotes** - Fighter quotes, Jocko Willink, David Goggins, Stoic philosophy

## Requirements

- iOS 16.2+
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
│   ├── SiriIntents.swift      # Siri Shortcuts integration
│   └── TimerActivityAttributes.swift
├── Views/
│   ├── ContentView.swift      # Main preset list
│   ├── PresetSetupView.swift  # Pre-start configuration
│   ├── PresetEditorView.swift # Create/edit presets
│   ├── TimerView.swift        # Active timer display
│   └── HistoryView.swift      # Workout history
└── PunchClockWidget/
    └── PunchClockWidgetLiveActivity.swift
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

- "Hey Siri, start Boxing Standard in Ring Timer"
- "Hey Siri, start BJJ Rolling in Ring Timer"
- "Hey Siri, start sparring with Ring Timer"

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
| UserNotifications | Background alerts |
| CoreHaptics | Haptic capability check |

## License

MIT License
