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
- **Full-Screen Timer** - Color-coded phases (prepare, round, rest)
- **Background Support** - Timer continues running when app is backgrounded

## Requirements

- iOS 16.2+
- Xcode 15+

## Installation

1. Clone the repository
2. Open `PunchClock.xcodeproj` in Xcode
3. Build and run on your device or simulator

## Sound Files

The app expects the following sound files in the main bundle:

| File | Purpose |
|------|---------|
| `bell.wav` | Round start/end bell |
| `stick_punch.wav` | 10-second warning |
| `countdown.wav` | Final 3-second beeps |

If sound files are not present, the app falls back to system sounds.

**Recommended sources for royalty-free sounds:**
- [Freesound.org](https://freesound.org)
- [Pixabay Sound Effects](https://pixabay.com/sound-effects)
- [Zapsplat](https://zapsplat.com)

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

## License

MIT License
