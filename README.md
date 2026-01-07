# PunchClock

A combat sports interval timer for iOS with Dynamic Island and Live Activity support.

## Features

- **Customizable Presets** - Create, edit, and save your own timer configurations
- **Built-in Presets** - Boxing, MMA, Muay Thai, BJJ Rolling, and Quick Training
- **Dynamic Island** - Real-time countdown visible while multitasking
- **Live Activity** - Lock screen widget shows current phase and round
- **Audio Cues**
  - Bell sound at round start/end
  - 10-second warning stick punch during rounds
  - 3-second countdown beeps
- **Haptic Feedback** - Feel the countdown and phase changes through vibrations
- **Siri Shortcuts** - Start timers hands-free with voice commands (great when gloved up)
- **Full-Screen Timer** - Color-coded phases (prepare, round, rest)
- **Background Support** - Timer continues running when app is backgrounded

## Requirements

- iOS 16.2+
- Xcode 15+

## Installation

1. Clone the repository
2. Open `PunchClock.xcodeproj` in Xcode
3. Build and run on your device or simulator

## Architecture

```
PunchClock/
├── Models/
│   ├── Preset.swift          # Timer preset configuration
│   ├── PresetStore.swift     # Persistence layer
│   └── TimerState.swift      # Timer state machine
├── Services/
│   ├── TimerManager.swift    # Core timer logic + Live Activity
│   ├── SoundManager.swift    # Audio playback
│   ├── SiriIntents.swift     # Siri Shortcuts integration
│   └── TimerActivityAttributes.swift
├── Views/
│   ├── ContentView.swift     # Main preset list
│   ├── PresetSetupView.swift # Pre-start configuration
│   ├── PresetEditorView.swift# Create/edit presets
│   └── TimerView.swift       # Active timer display
└── PunchClockWidget/
    └── PunchClockWidgetLiveActivity.swift
```

## Timer Phases

| Phase | Color | Description |
|-------|-------|-------------|
| Prepare | Yellow | Countdown before first round |
| Round | Red | Active fighting/training |
| Rest | Green | Break between rounds |
| Finished | Blue | Workout complete |

## Default Presets

| Preset | Round Time | Rest | Rounds |
|--------|------------|------|--------|
| Boxing Standard | 3:00 | 1:00 | 12 |
| MMA Style | 5:00 | 1:00 | 5 |
| Muay Thai | 3:00 | 2:00 | 5 |
| BJJ Rolling | 6:00 | 1:00 | 5 |
| Quick Training | 2:00 | 0:30 | 6 |

## Siri Voice Commands

Start timers hands-free using Siri:

- "Hey Siri, start PunchClock"
- "Hey Siri, start boxing timer with PunchClock"
- "Hey Siri, start MMA Style with PunchClock"

Shortcuts also appear in the Shortcuts app for custom automations.

## License

MIT License
