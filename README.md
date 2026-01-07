# Punch Clock

A clean, no-ads boxing and MMA round timer for iOS.

## Features

- **Customizable Presets** - Create and save workout configurations with custom prepare time, round duration, rest periods, and number of rounds
- **Visual Timer Display** - Full-screen color-coded display (yellow = prepare, red = round, green = rest)
- **Audio Cues**:
  - Bell sound at round start and end
  - Double stick punch warning at 10 seconds remaining
  - Countdown beeps at 3, 2, 1
- **Dynamic Island Support** - Monitor your timer from the Dynamic Island while recording sparring sessions or using other apps
- **Background Audio** - Sounds continue playing when the app is in the background

## Default Presets

| Preset | Prepare | Round | Rest | Rounds |
|--------|---------|-------|------|--------|
| Boxing Standard | 10s | 3:00 | 1:00 | 12 |
| MMA Style | 10s | 5:00 | 1:00 | 5 |
| Quick Training | 5s | 2:00 | 0:30 | 6 |

## Requirements

- iOS 17.0+
- iPhone with Dynamic Island (for Live Activity support)

## Installation

1. Clone this repository
2. Open `PunchClock.xcodeproj` in Xcode
3. Select your development team in Signing & Capabilities
4. Build and run on your device or simulator

## Sound Files

The app requires the following sound files in the main bundle:
- `bell.wav` or `bell.mp3` - Boxing bell sound
- `stick_punch.wav` or `stick_punch.mp3` - Stick/clapper sound
- `countdown.wav` or `countdown.mp3` - Countdown beep

If custom sounds are not provided, the app falls back to system sounds.

## Privacy

Punch Clock does not collect, store, or transmit any personal data. All workout presets are stored locally on your device using UserDefaults.

## License

Copyright © 2026 Frantisek Farkas. All rights reserved.
