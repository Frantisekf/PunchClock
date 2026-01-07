# PunchClock - Background & Dynamic Island Setup Guide

## 🎯 Background Execution (Timer runs while using Camera)

Your timer now runs in the background using **Audio playback**. This allows you to:
- ✅ Start the timer in PunchClock
- ✅ Switch to Camera app to record your sparring
- ✅ Timer continues running and plays sounds in background

### Required Setup in Xcode:

1. **Select your app target** → **Signing & Capabilities**
2. Click **+ Capability**
3. Add **Background Modes**
4. ✅ Check **"Audio, AirPlay, and Picture in Picture"**

That's it! The audio session is already configured in code.

### How it works:
- The timer plays audio (bell, countdown) which keeps the app alive in background
- Even when silent, the audio session maintains background execution
- Live Activity updates continue showing on Lock Screen

---

## 🏝️ Dynamic Island Setup

Dynamic Island requires a **Widget Extension** to render the UI.

### Step-by-Step Setup:

#### 1. Create Widget Extension
- **File → New → Target**
- Select **Widget Extension**
- Product Name: `PunchClockWidget`
- ✅ **Check "Include Live Activities"** (important!)
- Click **Finish**
- Click **Activate** when prompted

#### 2. Move Files to Widget Target
In Xcode's file navigator, for each file:

**`PunchClockWidgetBundle.swift`:**
- Right-click → **Target Membership**
- ✅ Check `PunchClockWidget`
- ❌ Uncheck `PunchClock` (main app)

**`TimerLiveActivity.swift`:**
- Right-click → **Target Membership**
- ✅ Check `PunchClockWidget`
- ❌ Uncheck `PunchClock` (main app)

**`TimerActivityAttributes.swift`:**
- Right-click → **Target Membership**
- ✅ Check **BOTH** `PunchClock` AND `PunchClockWidget`

#### 3. Uncomment @main in Widget Bundle
In `PunchClockWidgetBundle.swift`, change:
```swift
// @main  // Uncomment this when moved to Widget Extension target
```
to:
```swift
@main
```

#### 4. Add Info.plist Key
- Select **PunchClock** (main app target) → **Info** tab
- Click **+** to add new key
- Key: `NSSupportsLiveActivities`
- Type: **Boolean**
- Value: **YES**

#### 5. Test on Correct Simulator
Use one of these simulators with Dynamic Island:
- iPhone 16 Pro / 16 Pro Max
- iPhone 15 Pro / 15 Pro Max
- iPhone 14 Pro / 14 Pro Max

**Note:** Custom simulators like "iPhone 17 Pro" may not have Dynamic Island properly configured.

---

## 🧪 Testing

### Background Timer:
1. Start a timer in PunchClock
2. Swipe up to go home
3. Open Camera app
4. You should hear the timer sounds (bell, countdown)
5. Check Lock Screen - Live Activity shows progress

### Dynamic Island (after Widget Extension setup):
1. Use iPhone 14 Pro or newer simulator
2. Start a timer
3. Swipe up to go home
4. Look at the Dynamic Island (notch area)
5. You should see timer info
6. Long-press to expand and see full details

---

## 🐛 Troubleshooting

### Background not working?
- Check that **Background Modes → Audio** is enabled
- Check Xcode console for: `✅ Audio session configured for background playback`
- Make sure sounds are enabled (bell/countdown sounds keep app alive)

### Dynamic Island not showing?
- Widget Extension must be created and configured
- Check console for: `✅ Live Activity started successfully!`
- If you see `❌ Live Activities are not enabled`, check Info.plist
- Make sure you're using iPhone 14 Pro or newer simulator

### Timer stops in background?
- Audio session keeps timer alive
- If no sounds play, timer may pause
- Live Activity should still update on Lock Screen

---

## 📱 What You'll See

### While Recording Video:
- **Lock Screen:** Timer with round progress, time remaining
- **Hearing:** Bell sounds for round start/end, countdown beeps
- **Dynamic Island:** Compact timer display (after setup)

### Expanded Dynamic Island:
- Large timer countdown
- Current phase (Get Ready / Fight! / Rest)
- Round progress (Round X/Y)
- Preset name
- Pause indicator if paused

Enjoy your sparring sessions! 🥊📹
