<p align="center">
<a  href="https://github.com/keefo/NeewerLite">
    <img src="Design/icon_128x128@2x.png" alt="Logo" width="150" height="150">
</a>
</p>

<h1 align="center">NeewerLite-CB100C</h1>

# About This Fork

This is a fork of [keefo/NeewerLite](https://github.com/keefo/NeewerLite), an unofficial macOS app for controlling Neewer LED lights via Bluetooth. This fork focuses on bug fixes, CB100C support, a modernized SwiftUI interface, and a fully reworked Stream Deck+ plugin.

**Original author:** [Xu Lian (keefo)](https://github.com/keefo) — all credit for the original NeewerLite app, BLE protocol reverse-engineering, and command pattern system goes to him. Please consider [sponsoring his work](https://github.com/sponsors/keefo).

# What's Changed

## Bug Fixes (13 bugs fixed)

- **`sendSceneCommand` overwrite bug** — A duplicate `getSceneCommand()` call ran unconditionally after the if/else block, overwriting whatever was computed
- **`fxPatterns` ignored** — Lights with `support17FX: true` AND custom `fxPatterns` in the database (like the CB100C) would use hardcoded FX instead of the database patterns
- **Dead `sendKeepAlive()`** — An early `return` on line 432 made the entire keep-alive function unreachable, so BLE connections would drop silently
- **Wrong saturation formula** — RGB-to-HSV conversion used `dVal / minV` instead of `dVal / maxV`, producing incorrect colors in HSI mode
- **Inverted slider bounds** — `NLSlider` min/max `didSet` checks were backwards, clamping values in the wrong direction
- **Upper-bound slider bug** — `notifyUpperValueChange()` reported `currentValue` instead of `currentUpperValue`, breaking FX range sliders
- **TL40-2 type assignment** — `lightType = 86` was immediately overwritten by `lightType = 0` due to missing `else`
- **Release build database loading** — Bundled `lights.json` only loaded in `#if DEBUG`, so Release builds had no light definitions
- **Force unwraps** — Replaced 3 crash-prone `!` unwraps with safe alternatives (`Int(val)!`, `_macAddress!`, `try!`)
- **`ligthType` typo** — Renamed misspelled lazy var throughout codebase
- **FX endpoint bug** — Server.swift checked `fx9 > 0` instead of `fx17 > 0` for 17-channel lights

## Database Fixes (lights.json)

- **Type 49 (CB100C)** — Added missing `0x00 0x00` padding before checksum in all 11 sourcePattern `cmd` and `defaultCmd` strings
- **Type 40 & 42** — Fixed duplicate FX opcodes: CCT flash `0x05` -> `0x06`, TV screen `0x0E` -> `0x0F`
- **Typo** — Fixed "Signle Color" -> "Single Color" in FX pattern names

## SwiftUI Rewrite

The entire UI has been rewritten in SwiftUI (macOS 14+), replacing ~6,000 lines of AppKit/XIB code with ~1,300 lines of declarative SwiftUI:

- **`MainView`** — Scrollable grid of light cards with header, light count, and scan button with countdown timer
- **`LightCardView`** — Card per light with name, power toggle, and segmented mode picker (CCT / HSI / Source / FX)
- **`CCTModeView`** — Brightness, color temperature, and green-magenta sliders
- **`HSIModeView`** — Interactive color wheel with brightness slider
- **`FXModeView`** — Effect picker with dynamic sliders based on each effect's parameters (speed, brightness, CCT, GM, hue, saturation)
- **`SourceModeView`** — Light source picker with parameter sliders
- **`GradientSlider`** — Custom slider with 7 gradient presets (brightness, CCT, GM, hue, saturation, speed, spark) featuring draggable knob and discrete block mode
- **`ColorWheelView`** — HSI color wheel with drag-to-select
- **`RenameSheet`** — SwiftUI rename dialog via right-click context menu
- **`LightViewModel`** — `@Observable` bridge from the existing `Observable<T>` BLE model to SwiftUI
- **`AppState`** — Singleton light collection with discovered/connected light management

The BLE communication layer (`NeewerLight.swift`, `CommandPatternParser.swift`, etc.) is completely unchanged.

## Stream Deck+ Plugin Overhaul

6 new actions added to the Stream Deck plugin, designed for the Stream Deck+ (4 dials + 8 keys):

### New Dial Actions
- **GM (Green-Magenta)** — Dial adjusts GM tint from -50 to +50, press toggles power
- **FX Speed** — Dial adjusts effect speed 1-10, press toggles power

### New Key Actions
- **CCT Mode** — Switch to CCT mode, shows checkmark when active
- **HSI Mode** — Switch to HSI color mode, shows checkmark when active
- **FX Cycle** — Press to cycle through effects, shows current effect name on key
- **Source Cycle** — Press to cycle through light sources, shows current source name

### New Server Endpoints
- `POST /gm` — Green-magenta control
- `POST /mode` — Mode switching (CCT/HSI/SCE)
- `POST /fxnext` — Cycle through FX effects
- `POST /fxspeed` — Adjust FX speed
- `POST /source` — Cycle through light sources
- Enhanced `GET /listLights` — Now returns mode, GM, hue, saturation, FX name, counts

### Existing Action Fixes
- Fixed HUE encoder range from 0-256 to 0-360
- Fixed FX endpoint checking wrong field for 17-channel lights
- Reduced heartbeat polling from 1s to 3s
- Added 100ms delay between mode switch and command to prevent race conditions

# What Still Needs Work

- [ ] **Extract BLE from AppDelegate** — CoreBluetooth management is still in `AppDelegate.swift` (~1,400 lines). Should be moved to a standalone `BLEManager` class
- [ ] **Delete old AppKit files** — The old view files (`CollectionViewItem.swift`, `NLSlider.swift`, `ColorWheel.swift`, etc.) still compile but are never shown. ~3,000 lines of dead code
- [ ] **SwiftUI Log Monitor** — Replace `LogMonitorViewController.swift` with a SwiftUI log viewer
- [ ] **SwiftUI Pattern Editor** — Replace `PatternEditorPanel.swift` with SwiftUI text editor with syntax highlighting
- [ ] **Audio Spectrogram** — Port `AudioSpectrogramView` to SwiftUI Canvas with `TimelineView` animation
- [ ] **Test more lights** — Only tested with CB100C and CB60. Other Neewer models may need database entries or command pattern adjustments
- [ ] **Stream Deck plugin packaging** — Need Elgato CLI tools for proper `.streamDeckPlugin` packaging. Currently installed by copying folder manually

# Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15+ to build
- Bluetooth-enabled Neewer LED light

# How to Build

1. Clone this repo
2. Open `NeewerLite/NeewerLite.xcodeproj` in Xcode
3. Select the **NeewerLite** scheme, set destination to **My Mac**
4. Build & Run (Cmd+R)
5. The app appears in your menu bar (not the Dock)

## Stream Deck Plugin

```bash
cd NeewerLiteStreamDeck/neewerlite
npm install
npm run build
```

Then copy the plugin to Stream Deck:
```bash
cp -r com.beyondcow.neewerlite.sdPlugin ~/Library/Application\ Support/com.elgato.StreamDeck/Plugins/
```

Restart the Stream Deck app to load the new actions.

# Script Commands

The app supports URL scheme commands for automation:

```bash
# Power
open "neewerlite://turnOnLight"
open "neewerlite://turnOffLight"
open "neewerlite://toggleLight"

# Scan
open "neewerlite://scanLight"

# CCT mode
open "neewerlite://setLightCCT?CCT=3200&Brightness=100"
open "neewerlite://setLightCCT?CCT=3200&GM=-50&Brightness=100"

# HSI mode
open "neewerlite://setLightHSI?RGB=ff00ff&Saturation=100&Brightness=100"
open "neewerlite://setLightHSI?HUE=360&Saturation=100&Brightness=100"

# Scenes
open "neewerlite://setLightScene?Scene=SquadCar"
open "neewerlite://setLightScene?SceneId=1&Brightness=100"

# Target specific light by name
open "neewerlite://turnOnLight?light=MyLight"
```

# Tested Lights

- Neewer CB100C (type 49) — fully tested, all modes working
- Neewer CB60 RGB (type 22) — tested basic functionality

# Credits

- **Original NeewerLite app** — [Xu Lian (keefo)](https://github.com/keefo/NeewerLite)
- **This fork** — [TheASDM](https://github.com/TheASDM)
- **Bug fixes, SwiftUI rewrite, and Stream Deck overhaul** — Built with [Claude Code](https://claude.ai/claude-code)

# License

MIT License — same as the original NeewerLite project. See [LICENSE](LICENSE) for details.
