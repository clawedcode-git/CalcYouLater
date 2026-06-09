<div align="center">

<img src="dist/resources/background.png" alt="CalcYouLater Banner" width="620"/>

# CalcYouLater

**The calculator that waits for you.**

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue?logo=apple&logoColor=white)](https://developer.apple.com/macos/)
[![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Android](https://img.shields.io/badge/Android-8.0%2B-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift&logoColor=white)](https://swift.org)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9-7F52FF?logo=kotlin&logoColor=white)](https://kotlinlang.org)
[![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)
[![Release](https://img.shields.io/badge/Release-v1.2-green)](../../releases/latest)
[![NeonBlade](https://img.shields.io/badge/Theme-NeonBlade-%2300d4ff?logo=lightning&logoColor=white)](https://neonbladeui.neuronrush.com)

A native calculator for **macOS, iOS/iPadOS, and Android** — scientific mode, history, unit converter, memory functions, keyboard support, and a witty name.

[**⬇ macOS Installer (.pkg)**](../../releases/latest) · [**⬇ iOS (.ipa)**](../../releases/latest) · [**⬇ Android (.apk)**](../../releases/latest) · [**Report Bug**](../../issues)

</div>

---

## Downloads

| Platform | File | Requirements | How to install |
|----------|------|-------------|----------------|
| **macOS** | `CalcYouLater_Installer.pkg` | macOS 13 Ventura+ | Double-click → follow installer |
| **iOS / iPadOS** | `CalcYouLater-iOS.ipa` | iOS / iPadOS 16+ · arm64 | Sideload via AltStore or Sideloadly |
| **iOS Source** | `CalcYouLater-iOS-src.zip` | Xcode 15+ | Open `.xcodeproj` → ⌘R |
| **Android** | `CalcYouLater-Android.apk` | Android 8.0 Oreo+ (API 26) | Enable *Install unknown apps* → open the APK |

→ All assets on the **[latest Release page](../../releases/latest)**

---

## Screenshots

### macOS

<div align="center">

| Dark Mode | Light Mode |
|:---------:|:----------:|
| <img src="screenshots/standard_dark.png" width="300"/> | <img src="screenshots/standard_light.png" width="300"/> |

| Scientific Mode | History Sidebar | Unit Converter |
|:--------------:|:---------------:|:--------------:|
| <img src="screenshots/scientific_dark.png" width="252"/> | <img src="screenshots/history_dark.png" width="300"/> | <img src="screenshots/converter_light.png" width="300"/> |

</div>

---

### iOS / iPadOS

<div align="center">

| Portrait Dark | Portrait Light | Scientific | History | Memory |
|:---:|:---:|:---:|:---:|:---:|
| <img src="screenshots/ios/portrait_dark.png" width="150"/> | <img src="screenshots/ios/portrait_light.png" width="150"/> | <img src="screenshots/ios/scientific_dark.png" width="150"/> | <img src="screenshots/ios/history_dark.png" width="150"/> | <img src="screenshots/ios/memory_light.png" width="150"/> |

*In landscape, the scientific panel moves to its own column alongside the keypad.*

</div>

---

## Features

### 🧮 Calculator Core
- Full arithmetic with **chained operations** and repeated `=`
- Backspace, sign toggle, percentage
- **Keyboard-first on macOS** — every key you'd expect works
- **Haptic feedback on iOS & Android** — tactile response on every tap

### 🔬 Scientific Mode
Toggle **Sci** to reveal 16 functions:

| Row | Functions |
|-----|-----------|
| Trig | `sin` `cos` `tan` `π` |
| Inverse Trig | `sin⁻¹` `cos⁻¹` `tan⁻¹` `e` |
| Log / Power | `log` `ln` `√` `x²` |
| Extra | `xʸ` `n!` `1/x` `∛x` |

> **On iOS in landscape**, the scientific panel appears as a permanent left column — no toggle needed.

### 📋 History
- Every calculation saved automatically (up to 200 entries)
- **Tap any entry** to recall its result into the display
- **Swipe to delete** individual entries · **Clear All** button
- macOS: slide-in sidebar — iOS: native sheet

### ⇄ Unit Converter
Six categories, 40+ units. Tap **←** (iOS) or **↓** (macOS) to pull the current display value directly in.

| Category | Units |
|----------|-------|
| Length | m, km, cm, mm, mi, ft, in, yd |
| Weight | kg, g, lb, oz, t, mg |
| Temperature | °C, °F, K |
| Area | m², km², cm², ft², in², ha, acre |
| Volume | L, mL, gal, fl oz, cup, tbsp, tsp, m³ |
| Speed | m/s, km/h, mph, knot, ft/s |

### 🧠 Memory
`MC` · `MR` · `M+` · `M−` — purple indicator in display shows stored value

### 🌗 Appearance
System default · Light · Dark — persisted across launches

### ⚡ NeonBlade Theme
A full **cyberpunk / sci-fi** skin powered by the [NeonBlade UI](https://neonbladeui.neuronrush.com) aesthetic.

<div align="center">

| Standard Dark | NeonBlade |
|:---:|:---:|
| <img src="screenshots/standard_dark.png" width="280"/> | <img src="screenshots/neonblade.png" width="280"/> |

</div>

**Toggle:** Click the **`⚡`** bolt button in the toolbar, or press `⌘⇧T`

| Element | NeonBlade Style |
|---------|----------------|
| Button shape | Diagonal **corner-cut** (blade geometry) |
| Operators | Electric cyan `#00d4ff` with neon glow |
| Equals | Hot pink `#ff0066` with neon glow |
| Memory | Electric violet `#a020f0` |
| Scientific | Electric blue `#0066ff` |
| Window | Deep space `#080b14` |
| Display | Scanline overlay · cyan border panel |
| Fonts | Monospaced throughout — terminal aesthetic |
| Hover | Glow intensifies + border brightens |

Theme is **persistent** across launches and always forces **dark mode**.

---

## macOS Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `0` – `9` | Digits |
| `+ - * /` | Operators |
| `Enter` or `=` | Equals |
| `.` | Decimal point |
| `Delete` | Backspace |
| `Esc` | Clear all |
| `%` | Percent |
| `c` / `C` | Clear |
| Click result | Copy to clipboard |

---

## Installation

### macOS — Installer package

1. Download **`CalcYouLater_Installer.pkg`** from [Releases](../../releases/latest)
2. **Before opening**, strip the quarantine flag in Terminal:
   ```bash
   xattr -dr com.apple.quarantine ~/Downloads/CalcYouLater_Installer.pkg
   ```
3. Double-click the `.pkg` and follow the on-screen installer — app lands in `/Applications`
4. Open from Launchpad or Spotlight

> **Why the Terminal step?** CalcYouLater is ad-hoc signed (no paid Apple Developer ID), so macOS Gatekeeper shows a _"cannot be verified"_ warning on first open. The `xattr` command removes the quarantine attribute that triggers this. See the [Gatekeeper section](#-opening-on-any-mac-gatekeeper) below for all available options.

### iOS / iPadOS — Sideloading the IPA

The IPA is **ad-hoc signed** (no App Store). Choose a sideloading method:

| Tool | Cost | Notes |
|------|------|-------|
| **[AltStore](https://altstore.io)** | Free | Installs via Wi-Fi · re-signs every 7 days with your Apple ID |
| **[Sideloadly](https://sideloadly.io)** | Free | Drag-and-drop IPA · USB or Wi-Fi |
| **Xcode** | Free (Xcode required) | Devices & Simulators → drag IPA onto device · needs Developer Mode on |

> Enable **Developer Mode** on iPhone/iPad: Settings → Privacy & Security → Developer Mode.

### iOS — Build from source

**Requires:** macOS + Xcode 15+

```bash
# Clone and build
git clone https://github.com/clawedcode-git/CalcYouLater.git
open CalcYouLater-iOS/CalcYouLater-iOS.xcodeproj
# Select your device → ⌘R
```

### Android — Sideloading the APK

The APK is **self-signed** (not from the Play Store), so Android asks you to allow installs from your browser/file manager the first time.

1. Download **`CalcYouLater-Android.apk`** from [Releases](../../releases/latest) onto your phone
2. Open it (Files app or your browser's downloads)
3. When prompted, tap **Settings → Allow from this source** (or **Settings → Apps → Special access → Install unknown apps**), then go back
4. Tap **Install** → **Open**

> Requires **Android 8.0 (Oreo, API 26) or newer**. If Play Protect shows a warning, choose **Install anyway** — it flags any app not distributed through the Play Store.

### Android — Build from source

**Requires:** JDK 17 + Android SDK (API 34). No Android Studio needed — the Gradle wrapper is committed.

```bash
git clone https://github.com/clawedcode-git/CalcYouLater.git
cd CalcYouLater/CalcYouLater-Android
echo "sdk.dir=$HOME/Library/Android/sdk" > local.properties   # path to your SDK
./gradlew :app:assembleDebug        # debug APK
./gradlew :app:testDebugUnitTest    # run engine unit tests
```

Output: `app/build/outputs/apk/debug/app-debug.apk`

---

## 🔐 Opening on Any Mac (Gatekeeper)

CalcYouLater is **ad-hoc signed** — it does not carry a paid Apple Developer certificate. macOS Gatekeeper will show this warning when you first try to open the installer or the app:

> *"CalcYouLater_Installer.pkg" Not Opened — Apple could not verify it is free of malware.*

This is expected and safe to bypass. Choose any of the methods below:

---

### Option 1 — Terminal (recommended, one command)

Run this **before** opening the installer or app:

```bash
# For the installer .pkg
xattr -dr com.apple.quarantine ~/Downloads/CalcYouLater_Installer.pkg

# For the .app after copying manually
xattr -dr com.apple.quarantine /Applications/CalcYouLater.app
```

Then open normally. The warning will not appear again.

---

### Option 2 — Right-click to open

1. **Right-click** (or Control-click) the `.pkg` or `.app`
2. Choose **Open** from the context menu
3. A new dialog appears — click **Open Anyway**

---

### Option 3 — System Settings

1. Attempt to open the file — click **Done** (do **not** click "Move to Bin")
2. Open **System Settings → Privacy & Security**
3. Scroll to the **Security** section
4. Click **Open Anyway** next to the CalcYouLater entry
5. Authenticate with your password or Touch ID

---

### Why does this happen?

| Cause | Explanation |
|-------|-------------|
| Ad-hoc signature | The app is signed with a local key (`codesign --sign -`), not an Apple-issued certificate |
| No notarisation | Notarisation requires a $99/yr Apple Developer account and Apple's server-side scan |
| Quarantine flag | macOS sets `com.apple.quarantine` on any file downloaded from the internet; `xattr -dr` removes it |

> **For full Gatekeeper approval** (no warnings, anywhere): requires enrolling in the [Apple Developer Program](https://developer.apple.com/programs/) and notarising with `xcrun notarytool submit`.

---

## Project Structure

```
CalcYouLater/                        macOS Xcode project
├── CalcYouLater.xcodeproj/
├── CalcYouLater/
│   ├── CalcYouLaterApp.swift        App entry · appearance & theme binding
│   ├── AppTheme.swift               NeonBlade theme system · CornerCutShape · colors
│   ├── CalculatorEngine.swift       All calculation logic (shared)
│   ├── ContentView.swift            Main layout · keypad · keyboard handler
│   ├── HistoryView.swift            History sidebar
│   ├── ScientificKeypad.swift       Scientific function panel
│   ├── ConverterView.swift          Unit converter sidebar
│   └── Assets.xcassets/
├── dist/                            Installer resources & postinstall script
├── screenshots/                     macOS & iOS mockups
├── generate_icon.swift              App icon generator (AppKit)
├── generate_installer_bg.swift      Installer background generator
├── generate_mockups.swift           macOS screenshot generator
├── generate_ios_mockups.swift       iOS screenshot generator
└── CalcYouLater_Installer.pkg       Distributable macOS installer

CalcYouLater-iOS/                    iOS / iPadOS Xcode project
├── CalcYouLater-iOS.xcodeproj/
└── CalcYouLater-iOS/
    ├── CalcYouLaterApp.swift
    ├── CalculatorEngine.swift       Shared with macOS (pure Swift / Foundation)
    ├── ContentView.swift            Touch UI · portrait + landscape layouts
    ├── HistoryView.swift            History sheet
    └── ConverterView.swift          Converter sheet (Form-based)

CalcYouLater-Android/                Android project (Jetpack Compose · Kotlin)
├── app/build.gradle.kts            minSdk 26 · targetSdk 34 · Compose
├── gradlew · gradle/wrapper/        Committed wrapper (Gradle 8.9)
└── app/src/
    ├── main/java/com/calcyoulater/android/
    │   ├── MainActivity.kt          Activity · sets Compose content
    │   ├── CalcViewModel.kt         State + DataStore persistence
    │   ├── engine/                  Pure-Kotlin port of CalculatorEngine + Converter
    │   ├── theme/                   ThemeMode · CornerCutShape · NeonBlade palette
    │   └── ui/                      Display · keypads · toolbar · history/converter sheets
    └── test/java/…/EngineTest.kt    JVM unit tests (engine + conversions)
```

---

## License

MIT — do whatever you want, just don't remove the pun.

---

<div align="center">
<sub>Built with SwiftUI & Jetpack Compose · macOS (Apple Silicon & Intel) · iOS / iPadOS (arm64) · Android (API 26+) · NeonBlade theme · No telemetry</sub>
</div>
